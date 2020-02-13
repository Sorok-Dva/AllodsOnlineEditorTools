Global( "TEST_NAME", "SmokeTest.Quest.GroupCheck; author: Grigoriev Anton, date: 22.08.08, bug 37340" )

Global( "GET_OUT_TEXT", "GetOut!" )
Global( "ADDON_PREFIX", "GroupCheck:" )
Global( "ERROR_TEXT",   "TrackerError" )
Global( "DONE_TEXT",    "TrackerDone" )

Global( "LEADER_NAME", nil )
Global( "IS_GETTING_LEADER_NAME", 0 )

Global( "LEADER_ID", nil )
Global( "MESSAGE_FOR_SEND", "I am ready, let is go!" )

function RunScript()
	StartTest( TEST_NAME )

	StepLog("Followers created and try to send his NAME to Leader...")

	local followersName = debugCommon.FromWString( unit.GetName( avatar.GetId() ))
	StepLog( "FollowersName: " .. followersName )

	StepLog("	Followers NAME sended to Leader!")
	debugShard.DebugNotify("GroupCheck:"..followersName, false )
end

function StepLog(msg)
	LogResult({isError = false,test = "GroupCheck",text = msg})
end

-- проверяет отправителя сообщения и возвращает сообщение без префикса в удачном случае
function CheckNotifySender( params )
	local id = avatar.GetId()
	local name = unit.GetName(id)
	if debugCommon.FromWString( params.sender ) ~= debugCommon.FromWString(name) then
		local message = debugCommon.FromWString( params.message )
		local a, b = string.find( message, ADDON_PREFIX )
		if a ~= nil and b ~= nil then
		    local message = string.sub( message, b+1 )

			if LEADER_NAME == nil then
			    StepLog( "Getting followers name: " .. message )
	            LEADER_NAME = message
			end

			return message
		end
	end

	return nil
end

function CheckForBeingGroup( shouldBeInGroup )
	local name = debugCommon.ToWString( LEADER_NAME )
	if shouldBeInGroup == true then
		return group.GetMemberIndexByName( name ) ~= nil and group.GetMemberIndexByName( name ) >= 0
	else
		return group.GetMemberIndexByName( name ) == -1 or group.GetMemberIndexByName( name ) == nil
	end
end

function Done()
	debugShard.DebugNotify( ADDON_PREFIX .. DONE_TEXT, false )
 	Success( TEST_NAME, true )
end

function ErrorFunc( text )
	debugShard.DebugNotify( ADDON_PREFIX .. ERROR_TEXT, false )
	Warn( TEST_NAME, text, true )
end

----------------------------- EVENTS -----------------------------------

function OnGroupDeslineBusy()
	ErrorFunc("Unable to invite avatar..." .. declinerName)
end

function OnGroupDesline()
	ErrorFunc("Avatar not accepted..." .. declinerName)
end

function OnGroupInviteFailed(param)
	ErrorFunc(param.name..": "..param.sysReason)
end

function OnGroupAcceptError()
    ErrorFunc("Avatar not come in group..." .. avatar.GetName(avatar.GetId()))
end

function OnAvatarCreated()
	StartTimer( 2000, RunScript )
end

function OnDebugNotify( params )
	local message = CheckNotifySender( params )
	
	if message ~= nil then
	    if message == ERROR_TEXT then
	        Warn( TEST_NAME, "Exit reason - command from other addon" )
	        return
	    end
	    if message == DONE_TEXT then
			Success( TEST_NAME )
			return
	    end
	
		if IS_GETTING_LEADER_NAME == 0 then
			
			local units = avatar.GetUnitList()
			for index, id in units do
				if unit.IsPlayer( id ) and debugCommon.FromWString(unit.GetName(id)) == LEADER_NAME then
                    IS_GETTING_LEADER_NAME = 1
					LEADER_ID = id
					
					StepLog( "Followers send to Leader..." .. ADDON_PREFIX .. MESSAGE_FOR_SEND)
					debugShard.DebugNotify( ADDON_PREFIX .. MESSAGE_FOR_SEND, false )
					break
				end
			end
			if LEADER_ID == nil then
				ErrorFunc( "Can not find leader id by name " .. LEADER_NAME )
			end
  		elseif IS_GETTING_LEADER_NAME == 1 then
			StepLog( "Followers leaving the group...")
			group.Leave()
			IS_GETTING_LEADER_NAME = 2
		elseif IS_GETTING_LEADER_NAME == 2 then
		    StartCheckTimer(3000, CheckForBeingGroup, true, ErrorFunc, "Group not changed...", OnGroupChanged, nil )
			StepLog( "Follower sending GroupInvite to Leader")
			group.Invite( LEADER_ID )
	    end
	end
end

function OnGroupInvite(params)
	StepLog("Follower OnGroupInvite STARTED")
	if debugCommon.FromWString( params.inviterName ) == LEADER_NAME then
		StepLog("Followers GroupAccept!")
        group.Accept()
	else
	    ErrorFunc( "Group invite not from leader: " .. debugCommon.FromWString( params.inviterName ))
	end
end

function OnGroupChanged()
	StepLog( "Leader invited in group!" )
	StepLog( "Follower Try To ChangeLeader..." )
 	StartTimer(5000, CheckForChangeLider)
	group.SetLeader( debugCommon.ToWString( LEADER_NAME ))
end

function CheckForChangeLider()
	Log( "Check for change lider" )
	local name = debugCommon.ToWString( LEADER_NAME )
    if group.GetLeaderIndex() == group.GetMemberIndexByName( name ) then
        StepLog("Leader is changed!")
		StepLog("Follower leave the group!")
		group.Leave()
		Done()
    else
        ErrorFunc("Can not change the leader!!!")
    end
end

function Init()
	local login = {
		login = developerAddon.GetParam( "login"),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" )
	}
	InitLoging(login)

    common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
	common.RegisterEventHandler( OnDebugNotify, "EVENT_DEBUG_NOTIFY" )
	common.RegisterEventHandler( OnGroupInvite, "EVENT_GROUP_INVITE" )
	common.RegisterEventHandler( OnGroupInviteFailed, "EVENT_GROUP_INVITE_FAILED" )
	common.RegisterEventHandler( OnGroupAcceptError, "EVENT_GROUP_ACCEPT_ERROR" )
	common.RegisterEventHandler( OnGroupDeslineBusy, "EVENT_GROUP_DECLINE_BUSY" )
    common.RegisterEventHandler( OnGroupDesline, "EVENT_GROUP_DECLINE" )
end

Init()