
function OnAvatarCreated(params)
	avatar.SendChatMessage(debugCommon.ToWString( "HELLO" ))
end

function OnChatMessage( params )
	ParamsToConsole(params,"CHAT")
	local message = debugCommon.FromWString(params.msg)
	if message == "HELLO" and params.chatType == 1 then
		avatar.SendWhisper( params.sender , debugCommon.ToWString( "QUIT" ) )
		common.QuitGame()
	end
end
function Init()
	local login = {login = "scanner1", pass = "", avatar = "childScan3"}
	InitLoging(login)
	common.RegisterEventHandler( OnChatMessage, "EVENT_CHAT_MESSAGE")
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED")
end


--
-- main initialization
--

Init()
