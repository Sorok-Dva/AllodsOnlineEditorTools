-- MailBox

function LogMailInfo( mailId )
	LogInfo( "Mail game id: ", mailId )

	local info = mailBox.RequestMailInfo( mailId, true )
	if not info then
		LogInfo( "No mail info" )
		LogInfo( "" )
		return
	end

	local header = info.header
	if not header then
		LogInfo( "No mail header info" )
	else
		LogInfo( "Mail header info:" )

		LogInfo( "  participantName: ", debugCommon.FromWString( header.participantName ) )
		LogInfo( "  subject: ", debugCommon.FromWString( header.subject ) )
		LogInfo( "  hasMoney: ", header.hasMoney )
		LogInfo( "  hasItems: ", header.hasItems )
		LogInfo( "  isReturned: ", header.isReturned )
		LogInfo( "  isReadByRecipient: ", header.isReadByRecipient )
		LogInfo( "  isReadByOwner: ", header.isReadByOwner )
		local time = header.remainingTime
		LogInfo( "  remainingTime: " )
		LogInfo( "		d: ", time.d )
		LogInfo( "		h: ", time.h )
		LogInfo( "		m: ", time.m )
		LogInfo( "		s: ", time.s )
	end

	local body = info.body
	if not body then
		LogInfo( "No mail body info" )
	else
		LogInfo( "Mail body info:" )
		LogInfo( "  text: ", debugCommon.FromWString( body.text ) )
		LogInfo( "  money: ", body.money )
		LogInfo( "  items count: ", GetTableSize( body.items ) )
		for i = 0, GetTableSize( body.items ) - 1 do
			local itemId = body.items[i]
			local info = avatar.GetItemInfo( itemId )
			if info then
				LogInfo( "item: ", i, ", name: ", debugCommon.FromWString( info.name ) )
			else
				LogInfo( "wrong item info" )
			end
		end
	end

	LogInfo( "" )
end

function LogMailIds()
	local mailIds = mailBox.RequestMailIds()
	LogInfo( "Mail ids total: ", GetTableSize( mailIds ) )
	for i = 0, GetTableSize( mailIds ) - 1 do
		LogInfo( "mail: ", i, ", gameId: ", mailIds[i] )
	end
end

function LogAllMails()
	LogInfo( "Limits: " )
	local limits = mailBox.GetLimits()
	LogInfo( "  maxMailItemsCount: ", limits.maxMailItemsCount )
	
	local mailIds = mailBox.RequestMailIds()
	LogInfo( "Mails total: ", GetTableSize( mailIds ) )
	for i = 0, GetTableSize( mailIds ) - 1 do
		LogInfo( "mail: ", i, ", gameId: ", mailIds[i] )
		LogMailInfo( mailIds[i] )
	end
end

-- "EVENT_MAIL_CREATE_RESULT"

function OnEventMailCreateResult( params )
	LogInfo( "EVENT_MAIL_CREATE_RESULT" )
	LogInfo( "  sysResult: ", params.sysResult )
	LogInfo( "  recipientName: ", debugCommon.FromWString( params.recipientName ) )
	LogInfo( "" )
end

-- "EVENT_MAIL_BOX_UPDATED"

function OnEventMailBoxUpdated( params )
	LogInfo( "EVENT_MAIL_BOX_UPDATED" )
	
	LogMailIds()
	LogAllMails()
end

-- "EVENT_MAIL_UPDATED"

function OnEventMailUpdated( params )
	LogInfo( "EVENT_MAIL_UPDATED" )
	
	LogMailInfo( params.mailId )
end

-- "EVENT_MAIL_EXTRACT_MONEY_RESULT"
function OnEventMailExtractMoneyResult( params )
	LogInfo( "EVENT_MAIL_EXTRACT_MONEY_RESULT: ", params.mailId, "/", params.sysResult )
end

-- "EVENT_MAIL_EXTRACT_ITEMS_RESULT"
function OnEventMailExtractItemsResult( params )
	LogInfo( "EVENT_MAIL_EXTRACT_ITEMS_RESULT: ", params.mailId, "/", params.sysResult )
end

-- "EVENT_MAIL_RETURN_RESULT"
function OnEventMailReturnResult( params )
	LogInfo( "EVENT_MAIL_RETURN_RESULT: ", params.mailId, "/", params.sysResult )

	LogMailIds()
end

-- "EVENT_MAIL_DELETE_RESULT"
function OnEventMailDeleteResult( params )
	LogInfo( "EVENT_MAIL_DELETE_RESULT: ", params.mailId, "/", params.sysResult )
	
	LogMailIds()
end

-- TEST

function Test01()
	LogInfo( "TEST: 01: MailBox: Open" )

	mailBox.Open()
end

function Test02()
	LogInfo( "TEST: 02: MailBox: CreateSomeMails, recipientName: MAE1" )

	for i = 0, 4 do
		local recipientName = debugCommon.ToWString( "MAE1" )
		local subject = debugCommon.ToWString( "Test02 subject" )
		local body = debugCommon.ToWString( "Test02 body" )
		local money = i * 5
		mailBox.CreateMail( recipientName, subject, body, money, nil )
	end
end

function Test03()
	LogInfo( "TEST: 02: MailBox: CreateSomeMails, recipientName: 001" )

	for i = 0, 1 do
		local recipientName = debugCommon.ToWString( "001" )
		local subject = debugCommon.ToWString( "Test03 subject" )
		local body = debugCommon.ToWString( "Test03 body" )
		local money = i * 5
		local items = {}
		items[0] = i
		items[1] = i + 5
		mailBox.CreateMail( recipientName, subject, body, money, items )
	end
end

function Test04()
	LogInfo( "TEST: 04" )

	local mailIds = mailBox.RequestMailIds()
	mailBox.ExtractMailMoney( mailIds[0] )

--[[
	local mailIds = mailBox.RequestMailIds()
	for i = 0, GetTableSize( mailIds ) - 1 do
		if i == 1 then
			mailBox.ExtractMailMoney( mailIds[i] )
			mailBox.ExtractMailItems( mailIds[i], nil )
			mailBox.ReturnMailToSender( mailIds[i] )
		end
	end
--]]

--	mailBox.Close()
end

function Test05()
	LogInfo( "TEST: 05" )
	
	local mailIds = mailBox.RequestMailIds()
	mailBox.DeleteMail( mailIds[0] )

--	for i = 0, GetTableSize( mailIds ) - 1, 2 do
--		mailBox.DeleteMail( mailIds[i] )
--	end
end

-- "EVENT_MAIL_BOX_TEST"

function OnEventMailBoxTest( params )
	LogInfo( "EVENT_MAIL_BOX_TEST: ", params.index )

	if params.index == 1 then
		Test01()
	elseif params.index == 2 then
		Test02()
	elseif params.index == 3 then
		Test03()
	elseif params.index == 4 then
		Test04()
	elseif params.index == 5 then
		Test05()
	end
end


-- MailBox initialization 

function InitMailBox()
	LogInfo( "InitMailBox" )
	
	common.RegisterEventHandler( OnEventMailCreateResult, "EVENT_MAIL_CREATE_RESULT" )
	common.RegisterEventHandler( OnEventMailBoxUpdated, "EVENT_MAIL_BOX_UPDATED" )
	common.RegisterEventHandler( OnEventMailUpdated, "EVENT_MAIL_UPDATED" )

	common.RegisterEventHandler( OnEventMailExtractMoneyResult, "EVENT_MAIL_EXTRACT_MONEY_RESULT" )
	common.RegisterEventHandler( OnEventMailExtractItemsResult, "EVENT_MAIL_EXTRACT_ITEMS_RESULT" )
	common.RegisterEventHandler( OnEventMailReturnResult, "EVENT_MAIL_RETURN_RESULT" )
	common.RegisterEventHandler( OnEventMailDeleteResult, "EVENT_MAIL_DELETE_RESULT" )

	common.RegisterEventHandler( OnEventMailBoxTest, "EVENT_MAIL_BOX_TEST" )
end
