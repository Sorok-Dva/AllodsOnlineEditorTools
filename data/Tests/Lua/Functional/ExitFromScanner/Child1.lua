Global("LOGOUT",false)
function OnAvatarCreated(params)
	avatar.SendChatMessage(debugCommon.ToWString( "HELLO" ))
end

function OnDebugTimer( params )
	if TIMER then
		TIME = TIME + params.delta
    	if TIME >= TIME_FINISH then
    	    TIMER = false
    	    if TIMER_FUNC ~= nil then
    	    	TIMER_FUNC()
    	    end
        end
    end
end

function OnChatMessage( params )
	ParamsToConsole(params,"CHAT")
	local message = debugCommon.FromWString(params.msg)
	if message == "HELLO" and params.chatType == 1 then
		LOGOUT = true
		avatar.SendWhisper( params.sender , debugCommon.ToWString( "QUIT" ) )
		mission.Logout()
	end
end
function OnCustomGameStateChanged( params )
	if LOGOUT and params.registered and params.stateDebugName == "class Game::PreMission" then
		common.QuitGame()
	end
end
function Init()
	local login = {login = "scanner1", pass = "", avatar = "childScan1"}
	InitLoging(login)
	
	common.RegisterEventHandler( OnChatMessage, "EVENT_CHAT_MESSAGE")
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED")
end

--
-- main initialization
--

Init()
