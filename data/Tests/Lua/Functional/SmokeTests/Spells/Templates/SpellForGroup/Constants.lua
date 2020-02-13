
Global( "CHILD_START_MSG", "ChildForSpellForGroup" )
Global( "MAIN_ANSWER_MSG", "MainSpellForGroup" )
Global( "PING_QUESTION_MSG", "SpellForGroup_MainYouAreAlive" )
Global( "PING_ANSWER_MSG", "SpellForGroup_ChildImAlive" )
Global( "CHILD_DIST_TOO_MUCH", "ChildToFarFromMain")
Global( "ERROR_TEXT",   "TrackerError" )
Global( "DONE_TEXT",    "TrackerDone" )
Global( "TP_TO_COORDINATES",    "TeleportTo:" )

function GetDataFromMsg( msg, prefix )
	local message = debugCommon.FromWString( msg )
	local a, b = string.find( message, prefix )
	if a ~= nil and b ~= nil then
		return string.sub( message, b+1 )
	end
	return nil
end

function findUser(name)
	local units = avatar.GetUnitList()
	Log("Try findUser - "..name)
	for index, unitId in units do
		if unit.IsPlayer( unitId ) and debugCommon.FromWString(unit.GetName(unitId)) == name then
			local d = GetDistanceFromPosition( avatar.GetId(), debugMission.InteractiveObjectGetPos( unitId ))
				Log("Success findUser - "..unitId.." dist: "..tostring(d))
			return {dist =  d, id = unitId}
		end
	end
	Log("Success findUser - not found")
	return nil
end

function LeaveGroupOnStart(params)
	local try_mem = 0
	local afterFunc = params
	if type(afterFunc) == "table" then
		try_mem = params.try
		afterFunc = params.func
	end
	local members = group.GetMembers()
	local haveGroup = false
	if members ~= nil then
		for i, member in members do
			haveGroup = true
		end
	end
	if haveGroup then
		Log("in group >= 2 members try leave...")
		group.Leave()
		StartTimer(500, afterFunc, nil)
	else
		if try_mem < 3 then
			StartTimer(500, LeaveGroupOnStart, {func = afterFunc, try = try_mem + 1})
		else
			Log("not in group!")
			StartTimer(500, afterFunc, nil)
		end
	end
end

function PingMsg(answer)
	--Log("ping ok")
	if answer then
		qaMission.DebugNotify( PING_ANSWER_MSG, false )
	else
		qaMission.DebugNotify( PING_QUESTION_MSG, false )
	end
end
