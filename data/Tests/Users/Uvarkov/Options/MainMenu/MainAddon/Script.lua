Global( "theOptionId", nil )

-- SCRIPT for MainMenu addon

function OnReactionCheck( params )
	local wtCheckBox = mainForm:GetChildChecked( params.sender, true )
	if wtCheckBox:GetVariant() == 0 then
		wtCheckBox:SetVariant( 1 )
	else
		wtCheckBox:SetVariant( 0 )
	end
end

-- REACTION "button_exit"

function OnReactionExit( params )
	mainMenu.ExitGame()
end

-- REACTION "enter_server"

-- "EVENT_LOGIN_END"

function OnEventLoginEnd( params )
	
	local scriptParams = {}

	-- TODO: нужно выводить дополнительную информацию о версии
--[[
	local msg = "Cannot login, reason: " .. params.sysText .. " (" .. params.code .. ")"
	if params.code == LOGINRESULT_WRONGVERSION then
		LogWarning( msg, ", server version: ", params.serverVersion, ", client version: ", params.clientVersion )
	else
		LogWarning( msg )
	end
--]]
	
	if params.sysResult ~= "ENUM_LoginResult_LOGINSUCCESS" then
		local text = common.GetAddonRelatedTextGroup( "LoginResults", params.sysResult )
		if common.IsEmptyWString( text ) then
			text = debugCommon.ToWString( params.sysResult )
		end
		scriptParams.header = text

		common.SendEvent( "SCRIPT_SHOW_CONNECTION_MESSAGE_BOX", scriptParams )
	else
		-- show nothing
		LogInfo( "Login Successful!" )
	end
end

-- "EVENT_CONNECTION_FAILED"

function OnEventConnectionFailed( params )

	LogInfo ( "Connection Failed!" )

	local scriptParams = {}

	if params.sysResult ~= "ENUM_ECS_OK" then
		local text = common.GetAddonRelatedTextGroup( "ConnectionResults", params.sysResult )
		if common.IsEmptyWString( text ) then
			text = debugCommon.ToWString( params.sysResult )
		end
		scriptParams.header = text

		common.SendEvent( "SCRIPT_SHOW_CONNECTION_MESSAGE_BOX", scriptParams )
	end
end

-- "EVENT_ACCOUNT_STATE_CHANGED"
function OnEventAccountStateChanged()
	local busy = mainMenu.IsAccountBusy()

	local wtCenterPanel = mainForm:GetChildChecked( "CenterPanel", true )
	wtCenterPanel:Enable( not busy )

	local wtRightPanel = mainForm:GetChildChecked( "RightPanel", true )
	wtRightPanel:Enable( not busy )
end

function LogOptionInfo( optionIndex, optionId )
	local optionInfo = options.GetOptionInfo( optionId )
	LogInfo( "    option: ", optionIndex )
	if optionInfo then
		if optionInfo.sysCustomType == "test" then
			theOptionId = optionId
		end
		
		LogInfo( "     isEnabled: ", optionInfo.isEnabled )
		LogInfo( "     dataType: ", optionInfo.dataType )
		LogInfo( "     viewType: ", optionInfo.viewType )
		LogInfo( "     sysCustomId: ", optionInfo.sysCustomId )
		LogInfo( "     sysCustomType: ", optionInfo.sysCustomType )
		LogInfo( "     name: ", debugCommon.FromWString( optionInfo.name ) )
		LogInfo( "     desc: ", debugCommon.FromWString( optionInfo.description ) )
		LogInfo( "     minName: ", debugCommon.FromWString( optionInfo.minName ) )
		LogInfo( "     minDesc: ", debugCommon.FromWString( optionInfo.minDescription ) )
		LogInfo( "     maxName: ", debugCommon.FromWString( optionInfo.maxName ) )
		LogInfo( "     maxDesc: ", debugCommon.FromWString( optionInfo.maxDescription ) )
		LogInfo( "     defaultIndex: ", optionInfo.defaultIndex )
		LogInfo( "     baseIndex: ", optionInfo.baseIndex )
		LogInfo( "     currentIndex: ", optionInfo.currentIndex )
		LogInfo( "     values: ")
		for i = 0, GetTableSize( optionInfo.values ) - 1 do
			local value = optionInfo.values[i]
			LogInfo( "      name: ", debugCommon.FromWString( value.name ) )
			LogInfo( "      desc: ", debugCommon.FromWString( value.description ) )
			LogInfo( "      floatValue: ", value.floatValue )
		end
	else
		LogInfo( "    empty option" )
	end
end

function LogOptionBlock( blockIndex, blockId )
	local collectionInfo = options.GetCollectionInfo( blockId )
	LogInfo( "   block: ", blockIndex )
	if collectionInfo then
		LogInfo( "    isEnabled: ", collectionInfo.isEnabled )
		LogInfo( "    sysCustomType: ", collectionInfo.sysCustomType )
		LogInfo( "    name: ", debugCommon.FromWString( collectionInfo.name ) )
		LogInfo( "    desc: ", debugCommon.FromWString( collectionInfo.description ) )
	else
		LogInfo( "   empty block" )
	end

	local optionsIds = options.GetOptionIds( blockId )
	for optionIndex = 0, GetTableSize( optionsIds ) - 1 do
		LogOptionInfo( optionIndex, optionsIds[optionIndex] )
	end
end

function LogOptionGroup( groupIndex, groupId )
	local collectionInfo = options.GetCollectionInfo( groupId )
	LogInfo( "  group: ", groupIndex )
	if collectionInfo then
		LogInfo( "   isEnabled: ", collectionInfo.isEnabled )
		LogInfo( "   sysCustomType: ", collectionInfo.sysCustomType )
		LogInfo( "   name: ", debugCommon.FromWString( collectionInfo.name ) )
		LogInfo( "   desc: ", debugCommon.FromWString( collectionInfo.description ) )
	else
		LogInfo( "  empty group" )
	end

	local blockIds = options.GetBlockIds( groupId )
	for blockIndex = 0, GetTableSize( blockIds ) - 1 do
		LogOptionBlock( blockIndex, blockIds[blockIndex] )
	end
end

function LogOptionPage( pageIndex, pageId )
	local collectionInfo = options.GetCollectionInfo( pageId )
	LogInfo( " page: ", pageIndex )
	if collectionInfo then
		LogInfo( "  isEnabled: ", collectionInfo.isEnabled )
		LogInfo( "  sysCustomType: ", collectionInfo.sysCustomType )
		LogInfo( "  name: ", debugCommon.FromWString( collectionInfo.name ) )
		LogInfo( "  desc: ", debugCommon.FromWString( collectionInfo.description ) )
	else
		LogInfo( " empty page" )
	end

	local groupIds = options.GetGroupIds( pageId )
	for groupIndex = 0, GetTableSize( groupIds ) - 1 do
		LogOptionGroup( groupIndex, groupIds[groupIndex] )
	end
end

function LogOptions()
	LogInfo( "" )
	LogInfo( "options: " )
	local pageIds = options.GetPageIds()
	for pageIndex = 0, GetTableSize( pageIds ) - 1 do
		LogOptionPage( pageIndex, pageIds[pageIndex] )
	end
end

function OnReactionLogin( params )
	local wtAccountEdit = mainForm:GetChildChecked( "AccountNameEdit", true )
	local login = wtAccountEdit:GetText()
	local wtPasswordEdit = mainForm:GetChildChecked( "PasswordEdit", true )
	local password = wtPasswordEdit:GetText()

--    LogInfo( "Trying To Login..." )
    
	mainMenu.Login( login, login )	
end

function OnReactionLogin2( params )
	options.Update()

	local wtAccountEdit = mainForm:GetChildChecked( "AccountNameEdit", true )
	local login = wtAccountEdit:GetText()

	if theOptionId then
--		options.OptionResetToDefault( theOptionId )
		local optionInfo = options.GetOptionInfo( theOptionId )
		if optionInfo then
--			LogInfo( "optionInfo.valueCount: ", optionInfo.valueCount )
			LogInfo( "GetTableSize( optionInfo.values ): ", GetTableSize( optionInfo.values ) )

			local nextIndex = optionInfo.currentIndex + 1
			LogInfo( "nextIndex: ", nextIndex )
			if nextIndex >= optionInfo.valueCount then
--			if nextIndex >= GetTableSize( optionInfo.values ) then
				nextIndex = 0
			end
			options.SetOptionCurrentIndex( theOptionId, nextIndex )
--			options.Apply( theOptionId )
		end
	end

--[[
	if theOptionId then
		local optionInfo = options.GetOptionInfo( theOptionId )
		if optionInfo then
			options.SetOptionCurrentIndex( theOptionId, 3 )
			options.Apply( theOptionId )
		end
	end
--]]

	LogOptions()
end

-- REACTION "enter_built_in_server"

function OnReactionEnterBuiltInServer( params )
	mainMenu.EnterBuiltInServer()
end


--
-- main initialization function
--

function Init()
--	LogInfo( "Main Menu: Main Addon" )

	common.RegisterReactionHandler( OnReactionCheck, "checkbox" )
	common.RegisterReactionHandler( OnReactionExit, "button_exit" )
	common.RegisterReactionHandler( OnReactionEnterBuiltInServer, "enter_built_in_server" )
	common.RegisterReactionHandler( OnReactionLogin, "enter_server" )

	common.RegisterEventHandler( OnEventLoginEnd, "EVENT_LOGIN_END" )
	common.RegisterEventHandler( OnEventConnectionFailed, "EVENT_CONNECTION_FAILED" )
	common.RegisterEventHandler( OnEventAccountStateChanged, "EVENT_ACCOUNT_STATE_CHANGED" )

	local accountEdit = mainForm:GetChildChecked( "AccountNameEdit", true )
	if accountEdit:IsEnabled() then
		accountEdit:SetFocus( true )
	end

	common.SetCursor( "default" )
	
	
--	local fogPanel = mainForm:GetChildChecked( "Panel01", true )
--	fogPanel:SetBackgroundColor( { r = 1.0; g = 0.0; b = 0.0; a = 1.0 } )
	
--	options.Update()
--	LogOptions()

--[[	
	local customId = options.GetOptionByCustomId( "test03" )
	if customId then
		local info = options.GetOptionInfo( customId )
		if info then
			LogInfo( "Custom option found: ", info.sysCustomId )
		end
	end
--]]
end

--
-- main initialization
--

Init()
