Global("MAIN_NAME",nil)
Global("MAIN_ID",nil)
Global("MAIN_POS",nil)
Global("RUN", false)

function Distance()
    local pos = avatar.GetPos()
    local BOT_POS = ToAbsCoord(MAIN_POS)
    local AVATAR_POS = ToAbsCoord(pos)
    local dist = (BOT_POS.X-AVATAR_POS.X)^2 + (BOT_POS.Y-AVATAR_POS.Y)^2
    return dist
end

function OnAvatarCreated(params)
	avatar.SendChatMessage(debugCommon.ToWString( "HELLO" ))
end

function OnChatMessage( params )
	ParamsToConsole(params,"CHAT")
	local message = debugCommon.FromWString(params.msg)
	if message == "HELLO" and params.chatType == 1 then
		MAIN_NAME = params.sender
		MAIN_ID = getUnitID(debugCommon.FromWString(MAIN_NAME))
		MAIN_POS = debugMission.InteractiveObjectGetPos( MAIN_ID )
		RUN = true
		local pos = GetPositionAtDistance(avatar.GetPos(), avatar.GetDir(), 120)
		qaMission.AvatarSetPos( pos )
	end
	if message == "END" and params.chatType == 1 then
		common.QuitGame()
	end
end

function getUnitID(unitname)
	local units = avatar.GetUnitList()
	local Wname = common.GetEmptyWString()
	local name = ""
	for key, value in units do
		Wname = unit.GetName( value )
		name = debugCommon.FromWString(Wname)
		if unitname == name then
			common.LogInfo("find botID")
			return value
		end
	end
end

function OnAvatarPosChanged( params )
	if RUN then
	    local dist = Distance()
	    common.LogInfo("distance "..tostring(dist))
		if dist > 100 then
			RUN = false			
			avatar.SendWhisper( MAIN_NAME , debugCommon.ToWString( "QUIT" ) )
		end
	end
end
function Init()
	local login = {login = "scanner1", pass = "", avatar = "childScan2"}
	InitLoging(login)
	common.RegisterEventHandler( OnChatMessage, "EVENT_CHAT_MESSAGE")
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED")
	common.RegisterEventHandler( OnAvatarPosChanged, "EVENT_AVATAR_POS_CHANGED" )
end

--
-- main initialization
--

Init()
