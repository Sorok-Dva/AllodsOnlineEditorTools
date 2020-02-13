Global("STATE", 1)
Global("FIRST",1)
Global("SECOND",2)
Global("THRID",3)
Global("FINISH", 4)

Global("TIME",0)
Global("TIME_FINISH",0)
Global("TIMER", false)
Global("TIMER_FUNC",nil)

Global("BOT_NAME",nil)
Global("BOT_ID",nil)

Global("AVATAR_NAME",nil)
-- EVENT_AVATAR_CREATED
function OnAvatarCreated( params )
	AVATAR_NAME = debugCommon.FromWString(unit.GetName(avatar.GetId()))
	startTimer(1000, Starter)
end

-- EVENT_UNIT_BUFFS_ELEMENT_CHANGED
function Starter()
	if STATE == FIRST then
		developerAddon.RunChildGame( "Child1.(DeveloperAddon).xdb" )
		common.LogInfo("Child1 running")
	elseif STATE == SECOND then
		developerAddon.RunChildGame( "Child2.(DeveloperAddon).xdb" )
	elseif STATE == THRID then
		developerAddon.RunChildGame( "Child3.(DeveloperAddon).xdb" )
	elseif STATE == FINISH then
		avatar.SendWhisper( debugCommon.ToWString(BOT_NAME) , debugCommon.ToWString( "END" ) )
		common.LogInfo("FINISH")
		common.QuitGame()
	end
end
-- EVENT_DEBUG_TIMER

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

function OnUnitDespawned( params )
	ParamsToConsole(params,"UNIT_DESPAWNED")
	if params.unitId == BOT_ID and STATE ~= FINISH then
		TIMER = false
	if STATE == FIRST then
	Success( "AVATAR despawned after logout" )
	elseif STATE == SECOND then
	Success( "AVATAR despawned after out of range" )
	elseif STATE == THRID then
	Success( "AVATAR despawned after dissconnect" )
	end
		nextChild()
	end
end

function startTimer(millisec, func)
	TIME = 0
	TIME_FINISH = millisec
	TIMER = true
	TIMER_FUNC = func
end

function OnChatMessage( params )
	local message = debugCommon.FromWString(params.msg)
	local sender = debugCommon.FromWString(params.sender)
	if message == "HELLO" and sender~=AVATAR_NAME then
	    BOT_NAME = sender
	    BOT_ID = getUnitID(BOT_NAME)
	    common.LogInfo("BOT_ID "..tostring(BOT_ID))
	end
	if message == "QUIT" and params.chatType == 1 then
		waitDespawn()
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
			avatar.SendWhisper( debugCommon.ToWString(BOT_NAME) , debugCommon.ToWString( "HELLO" ) )
			return value
		end
	end
end

function errorDespawn()
	if STATE == FIRST then
	missionError( "AVATAR REMOVE", "10 sec not despawned after logout" )
	elseif STATE == SECOND then
	missionError( "AVATAR REMOVE", "10 sec not despawned after out of range" )
	elseif STATE == THRID then
	missionError( "AVATAR REMOVE", "70 sec not despawned after dissconnect" )
	end
	nextChild()
end

function nextChild()
	if STATE == FIRST then
	STATE = SECOND
	elseif STATE == SECOND then
	STATE = THRID
	elseif STATE == THRID then
	STATE = FINISH
	end
	startTimer(2000, Starter)
end
function waitDespawn()
	if STATE == FIRST then
		startTimer(10000, errorDespawn)
	elseif STATE == SECOND then
		startTimer(10000, errorDespawn)
	elseif STATE == THRID then
		startTimer(70000, errorDespawn)
	end
end

function Init()
	local login = {login = "scanner", pass = "", avatar = "mainScan"}
	InitLoging(login)
    common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
	common.RegisterEventHandler( OnDebugTimer, "EVENT_DEBUG_TIMER" )
	common.RegisterEventHandler( OnChatMessage, "EVENT_CHAT_MESSAGE")
	common.RegisterEventHandler( OnUnitDespawned, "EVENT_UNIT_DESPAWNED")
end

--
-- main initialization
--

Init()
