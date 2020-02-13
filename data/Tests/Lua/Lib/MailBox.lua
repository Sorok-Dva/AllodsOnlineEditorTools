-- author: Liventsev Andrey, date: 08.04.2009
-- Ф-ции для почты

Global( "MB_NPC_ID", nil )
Global( "MB_PASS_FUNCTION", nil )
Global( "MB_ERROR_FUNCTION", nil )

Global( "MB_SEND_MAIL_PRICE", 50 )


Global( "MB_RECIPIENT_NAME", nil )
Global( "MB_COUNT_MONEY_TO_MAIL", nil )
Global( "MB_ITEMS_TO_MAIL", nil )
Global( "MB_COUNT_MONEY_BEFORE", nil )
Global( "MB_ITEM_INDEX", nil )
Global( "MB_MAIL_INDEX", nil )
Global( "MB_ITEM_NAME", nil )
Global( "MB_MAIL_ID", nil )

Global( "MB_ACTION_NUM", nil ) -- номер экшена для закрытия событий в порядке объявления ф-ций

--начинает разговор с почтовым НПС
function OpenMailBox( npcId, passFunc, errorFunc )
	MailBoxLog( "request mail box... npcId=" .. tostring( npcId ) )
	
	MB_ACTION_NUM = 1
 	MB_NPC_ID = npcId
	MB_PASS_FUNCTION = passFunc
	MB_ERROR_FUNCTION = errorFunc
	
	if MB_NPC_ID ~= nil then
		MoveToMobId( MB_NPC_ID, MB_StartTalk, nil, MB_ERROR_FUNCTION )
	else
		MB_ERROR_FUNCTION( "mail npcId is nil" )
	end
end

function CloseMailBox( passFunc, errorFunc )
	MailBoxLog( "closing mail box..." )
	
	MB_ACTION_NUM = 2
	MB_PASS_FUNCTION = passFunc
	MB_ERROR_FUNCTION = errorFunc
	
	if mailBox.IsActive() == false then
		MB_ERROR_FUNCTION( "Can't close mail box: mail box is not active" )
	else
		common.RegisterEventHandler( MB_OnMailBoxClosed, "EVENT_MAIL_BOX_CLOSED" )
		StartPrivateTimer( 10000, MB_Error, "EVENT_MAIL_BOX_CLOSED not coming" )
		mailBox.Close()
	end	
end

-- http://intra/wiki/a1/FunctionMailBoxCreateMail
function SendMail( nameWString, titleWString, textWString, money, items, passFunc, errorFunc )
	MailBoxLog( "Sending mail to " .. FromWString( nameWString ) )

	MB_ACTION_NUM = 3
	MB_PASS_FUNCTION = passFunc
	MB_ERROR_FUNCTION = errorFunc
	MB_RECIPIENT_NAME = nameWString
	MB_COUNT_MONEY_TO_MAIL = money
	MB_ITEMS_TO_MAIL = items
	MB_COUNT_MONEY_BEFORE = avatar.GetMoney()	

	if mailBox.IsActive() == false then
		MB_ERROR_FUNCTION( "Can't send mail: mail box is not active" )
	else
		common.RegisterEventHandler( MB_OnMailCreateResult, "EVENT_MAIL_CREATE_RESULT" )
		StartPrivateTimer( 10000, MB_Error, "EVENT_MAIL_CREATE_RESULT not coming" )
		local sended = mailBox.CreateMail( nameWString, titleWString, textWString, MB_COUNT_MONEY_TO_MAIL, MB_ITEMS_TO_MAIL )
		MailBoxLog( "sended=" .. tostring( sended ))
		-- todo: bug#61956
	end	
end

function ClearMailBox( passFunc, errorFunc )
	MailBoxLog( "Clearing mail box..." )

	MB_ACTION_NUM = 4
	MB_PASS_FUNCTION = passFunc
	MB_ERROR_FUNCTION = errorFunc

	if mailBox.IsActive() == false then
		MB_ERROR_FUNCTION( "Can't clear mail box: mail box is not active" )
	else
		common.RegisterEventHandler( MB_OnMailDeleteResult, "EVENT_MAIL_DELETE_RESULT" )
		MB_DeleteNextMail()
	end
end

function MB_DeleteNextMail()
	for index, mailId in mailBox.RequestMailIds() do 
		MB_MAIL_ID = mailId
		local count = GetTableSize(mailBox.RequestMailIds())
		Log( "delete mail:" .. tostring( mailId ) )
		local isGood = mailBox.DeleteMail( mailId )
		if isGood == false then
			MailBoxLog( "Can't delete mail. subject:" .. FromWString( mailBox.RequestMailInfo( mailId, true ).subject ))
		end
		StartPrivateCheckTimer( 5000, MB_CheckMailBoxForCountMails, count-1, MB_ERROR_FUNCTION, "Can't clear mail box", MB_DeleteNextMail )
		return
	end
	
	MailBoxLog()
	MB_Pass()
end

function TakeAllFromMail( mailId, passFunc, errorFunc )
	MailBoxLog( "Taking all from mail...  count=" .. tostring( GetTableSize( mailBox.RequestMailInfo( mailId, true ).body.items )))

	MB_ACTION_NUM = 5
	MB_PASS_FUNCTION = passFunc
	MB_ERROR_FUNCTION = errorFunc
	MB_MAIL_ID = mailId
	MB_ITEMS_FROM_MAIL = {}

	if mailBox.IsActive() == false then
		MB_Error( "Can't take all from mail: mail box is not active" )
	else
		MB_ITEM_INDEX = 0
		common.RegisterEventHandler( MB_OnMailExtractItemsResult, "EVENT_MAIL_EXTRACT_ITEMS_RESULT" )
		MB_TakeNextItem()
	end
end	
	
function MB_TakeNextItem()
	if MB_ITEM_INDEX > 4 then
		MB_Error( "Too much items in mail..." )
		return
	end
	
	local mail = mailBox.RequestMailInfo( MB_MAIL_ID, true )
	for slot, itemId in mail.body.items do 
		Log( "slot=" .. tostring(slot) .. "   itemId=" .. tostring( itemId ))
		if itemId ~= nil then
			MB_ITEM_INDEX = MB_ITEM_INDEX + 1
			local info = avatar.GetItemInfo( itemId )
			MB_ITEM_NAME = info.debugInstanceFileName
			MailBoxLog( "taking item=" .. MB_ITEM_NAME .. "   from slot=" .. tostring( slot ))

			StartPrivateCheckTimer( 5000, MB_CheckItemsAfterTaking, GetCountItem( MB_ITEM_NAME ) + info.stackCount, MB_Error, "Can't take items from mail", MB_TakeNextItem )
			local success = mailBox.ExtractMailItems( MB_MAIL_ID, slot )
			if success == false then
				MailBoxLog( "ACHTING!!! Can't take item" )
				MB_Error( "Can't take item from mail. itemName=" .. MB_ITEM_NAME )
			end
			return
		end
	end
	
	local moneyFromMail = mailBox.RequestMailInfo( MB_MAIL_ID, true ).body.money
	MailBoxLog( "taking money: " .. tostring( moneyFromMail ))
	common.RegisterEventHandler( MB_OnMailExtractMoneyResult, "EVENT_MAIL_EXTRACT_MONEY_RESULT" )
	StartPrivateCheckTimer( 5000, MB_CheckMoneyAfterTaking, avatar.GetMoney() + moneyFromMail, MB_Error, "Can't take money from mail", MB_Pass )
	mailBox.ExtractMailMoney( MB_MAIL_ID )	
end

function MB_CheckMailBoxForCountMails( countMails )
	if GetTableSize( mailBox.RequestMailIds() ) == countMails then
		MailBoxLog( "done" )
	end
	Log( tostring(GetTableSize( mailBox.RequestMailIds() )) )
	return GetTableSize( mailBox.RequestMailIds() ) == countMails
end

function MB_StartTalk()
	common.RegisterEventHandler( MB_OnTalkStarted, "EVENT_TALK_STARTED" )
	common.RegisterEventHandler( MB_OnInteractionStarted, "EVENT_INTERACTION_STARTED" )
	
	StartPrivateTimer( 10000, MB_Error, "EVENT_TALK_STARTED not coming" )
	avatar.StartInteract( MB_NPC_ID )
end

function MB_CheckMoneyAfterSend()
	if avatar.GetMoney() == MB_COUNT_MONEY_BEFORE - MB_SEND_MAIL_PRICE - MB_COUNT_MONEY_TO_MAIL then
		MailBoxLog( "done: " .. tostring(avatar.GetMoney()) .. " == " .. tostring( MB_COUNT_MONEY_BEFORE ) .. "-" .. tostring( MB_SEND_MAIL_PRICE ) .. "-" .. tostring( MB_COUNT_MONEY_TO_MAIL ))
	end
	return avatar.GetMoney() == MB_COUNT_MONEY_BEFORE - MB_SEND_MAIL_PRICE - MB_COUNT_MONEY_TO_MAIL
end

function MB_CheckItemsAfterTaking( countItem )
	if GetCountItem( MB_ITEM_NAME ) == countItem then
		MailBoxLog( "done" )
	end	
	return GetCountItem( MB_ITEM_NAME ) == countItem
end
function MB_TakeMoney( mailId )

end
function MB_CheckMoneyAfterTaking( countMoney )
	if avatar.GetMoney() == countMoney then
		MailBoxLog( "done" )
	end
	return avatar.GetMoney() == countMoney
end


function MB_Stop()
	if MB_ACTION_NUM == 1 then
		common.UnRegisterEventHandler( "EVENT_TALK_STARTED" )
		common.UnRegisterEventHandler( "EVENT_INTERACTION_STARTED" )
		common.UnRegisterEventHandler( "EVENT_MAIL_BOX_ACTIVATED" )

	elseif MB_ACTION_NUM == 2 then
		common.UnRegisterEventHandler( "EVENT_MAIL_BOX_CLOSED" )

	elseif MB_ACTION_NUM == 3 then
		common.UnRegisterEventHandler( "EVENT_MAIL_CREATE_RESULT" )
		
	elseif MB_ACTION_NUM == 4 then
		common.UnRegisterEventHandler( "EVENT_MAIL_DELETE_RESULT" )
		
	elseif MB_ACTION_NUM == 5 then
		common.UnRegisterEventHandler( "EVENT_MAIL_EXTRACT_ITEMS_RESULT" )
		common.UnRegisterEventHandler( "EVENT_MAIL_EXTRACT_MONEY_RESULT" )
	end
end

function MB_Pass()
	MailBoxLog( "Success" )
	Log()
	MB_Stop()
	MB_PASS_FUNCTION()
end

function MB_Error( text )
	MB_Stop()
	MB_ERROR_FUNCTION( text )
end

function MailBoxLog( text )
	Log( text, "MailBox" )
end


---------------------------- EVENTS ----------

function MB_OnTalkStarted( params )
	MailBoxLog( "On talk started --> request interactions" )
    avatar.RequestInteractions()
	StartPrivateTimer( 10000, MB_Error, "EVENT_INTERACTION_STARTED not coming" )
end

function MB_OnInteractionStarted( params )
	MailBoxLog( "interaction started" )
	StopPrivateTimer()

    if params.isMailBox == true then
		common.RegisterEventHandler( MB_OnMailBoxActivated, "EVENT_MAIL_BOX_ACTIVATED" )
		StartPrivateTimer( 10000, MB_Error, "EVENT_MAIL_BOX_ACTIVATED not coming" )
		mailBox.Open()
	else	
		MB_Error( "npc is not mail box" )
	end
end

function MB_OnMailBoxActivated()
	StopPrivateTimer()
	MB_Pass()
end

function MB_OnMailCreateResult( params )
	if common.CompareWString( MB_RECIPIENT_NAME, params.recipientName ) == 0 then
		StopPrivateTimer()
		if params.sysResult == "ENUM_CreateMailResult_Succeeded" then
			StartPrivateCheckTimer( 5000, MB_CheckMoneyAfterSend, nil, MB_Error, "Mail sended successfull but money not decremented", MB_Pass )
		else
			MB_Error( "Mail create result fail: " .. params.sysResult )
		end
	end
end

function MB_OnMailBoxClosed()
	StopPrivateTimer()
	MB_Pass()
end

function MB_OnMailExtractItemsResult( params )
	if params.mailId == MB_MAIL_ID then
		if params.sysResult ~= "ENUM_MailServiceReply_Succeeded" then
			MB_Error( "Can't take item from mail. itemName=: " .. params.sysResult .. "   itemName=" .. MB_ITEM_NAME )
		end
	end
end

function MB_OnMailDeleteResult( params )
	if params.mailId == MB_MAIL_ID then
		if params.sysResult ~= "ENUM_MailServiceReply_Succeeded" then
			MB_Error( "Can't delete mail: " .. params.sysResult )
		end
	end	
end

function MB_OnMailExtractMoneyResult( params )
	if params.mailId == MB_MAIL_ID then
		if params.sysResult ~= "ENUM_MailServiceReply_Succeeded" then
			MB_Error( "Can't take money from mail: " .. params.sysResult )
		end
	end	
end
