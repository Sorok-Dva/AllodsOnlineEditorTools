--Ќаложение заклинаний на другого перса.
Global( "TEST_NAME", "Child Spell for Group" )

Global( "PARENT_NAME", nil )
Global( "PARENT_ID", nil )
Global( "PING", false )
function StepLog(msg)
	Log(msg,"SpellForFriend")
end

function Done()
	qaMission.DebugNotify( DONE_TEXT, false )
	StopPing()
 	Success( TEST_NAME, true )
end

function ErrorFunc( text )
	StopPing()
	qaMission.DebugNotify( ERROR_TEXT, false )
	Warn( TEST_NAME, text, true )
end
function StopPing()
	StopTimer1()
	StopTimer2()
	PING = false
end

function StartPing()
	PING = true
	StartTimer1(3000,ErrorFunc,"dont ping Main!!!")
end
----------------------------- EVENTS -----------------------------------
function StartAlone()
	StartTimer1(30000,ErrorFunc,"Main not answer for 30 sec")
	StepLog("Send Start Msg...")
	qaMission.DebugNotify(CHILD_START_MSG, false )
end

function OnAvatarCreated()
 	StepLog("Child created" )
	StepLog("Check in group...")
	LeaveGroupOnStart(StartAlone)
end

function OnResurrectRequested( params )
	if params.unitId == PARENT_ID then
		avatar.ResurrectReply( true )
	end
end

function OnDebugNotify( params )
	if PARENT_NAME == nil then
		if debugCommon.FromWString(params.message) == MAIN_ANSWER_MSG then
			PARENT_NAME = params.sender
			StepLog("Get Answer from Main...Ok")
			StopTimer1()
			StartPing()
			StartTimer2(1000,PingMsg,false)
			TryStart()
		end
	else
		if common.CompareWString(PARENT_NAME,params.sender) == 0 then
			if debugCommon.FromWString(params.message) == PING_ANSWER_MSG and PING then
				StartTimer1(3000,ErrorFunc,"dont ping Main!!!")
				return StartTimer2(1000,PingMsg,false)
			end
			if debugCommon.FromWString(params.message) == ERROR_TEXT then
				StopPing()
				Warn( TEST_NAME, "Exit reason - command from child addon", true )
			end
			if debugCommon.FromWString(params.message) == DONE_TEXT then
				StopPing()
				Success( TEST_NAME, true )
			end
			local strCoords = GetDataFromMsg( params.message, TP_TO_COORDINATES )
			if strCoords~=nil then
				StepLog("Get coordinates from main... ")
			    local first = string.find( strCoords, " " )
			    local x = tonumber(string.sub(strCoords,1,first))
			    local second = string.find(strCoords," ",first+1)
			    local y = tonumber(string.sub(strCoords,first+1,second))
			    local z = tonumber(string.sub(strCoords,second+1)) + 0.1
			    local absPos = {X = x,Y = y, Z = z}
			    local stPos = ToStandartCoord( absPos )
			    StepLog("Teleport to main... try")
			    qaMission.AvatarSetPos( stPos )
			    StartTimer(1000, AfterTeleport, stPos)
			end
		end
	end
end

function AfterTeleport(pos)
    if GetDistanceFromPosition( avatar.GetId(), pos ) < 5 then
        StepLog("Teleport to main... Ok")
        TryStart()
	else
	    StepLog("Wait appear in true coordinates..")
	    StartTimer(1000, AfterTeleport, pos)
	end
end

function TryStart()
	local user = findUser(debugCommon.FromWString(PARENT_NAME))
	StepLog("Check distance... ")
	if user==nil then
	    StepLog("Send msg that too far from main... avatar.GetUnitList is nil ")
        qaMission.DebugNotify(CHILD_DIST_TOO_MUCH, false )
        return
	end
	if user.dist>6 then
		StepLog("Send msg that too far from main... "..tostring(user.dist))
		qaMission.DebugNotify(CHILD_DIST_TOO_MUCH, false )
		return
	end
	PARENT_ID = user.id
	StepLog("Invite..."..tostring(user.id))
	group.Invite(user.id)
	
end



function Init()
	local login = {
		login = developerAddon.GetParam( "login"),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" )
	}
	InitLoging(login)

    common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
    common.RegisterEventHandler( OnDebugNotify, "EVENT_DEBUG_NOTIFY")
	common.RegisterEventHandler( OnResurrectRequested, "EVENT_RESURRECT_REQUESTED")
end

Init()