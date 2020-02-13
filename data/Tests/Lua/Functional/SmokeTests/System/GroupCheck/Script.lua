Global( "TEST_NAME", "SmokeTest.Quest.GroupCheck; author: Grigoriev Anton, date: 22.08.08, bug 37340" )

Global( "ADDON_PREFIX", "GroupCheck:" )
Global( "ERROR_TEXT",   "TrackerError" )
Global( "DONE_TEXT",    "TrackerDone" )

Global( "FOLLOWER_NAME", nil )
Global( "IS_GETTING_FOLLOWER_NAME", true)

Global("FOLLOWER_ID", nil)
Global( "MESSAGE_FOR_SEND", "You in group, can get out!" )

--25.06.2008 11:48:52 - Ivanov Peter
--ѕараметров нет.
--“ест проходит двум€ ботами, синохронизирующимис€ между собой. ѕервый берет в группу второго, второй соглашаетс€,
--потом выходит из группы и берет в группу первого. “от соглашаетс€, и второй передает ему лидерство.
--ѕровер€етс€, что все это получилось сделать.

function ExitFromTest( text )
	debugCommon.FromWString( unit.GetName( id ))
end

function StepLog(msg)
	LogResult({isError = false,test = "GroupCheck",text = msg})
end

-- провер€ет отправител€ сообщени€ и возвращает сообщение без префикса в удачном случае
function CheckNotifySender( params )
	local id = avatar.GetId()
	local name = unit.GetName(id)
	if debugCommon.FromWString( params.sender ) ~= debugCommon.FromWString(name) then
		local message = debugCommon.FromWString( params.message )
		local a, b = string.find( message, ADDON_PREFIX )
		if a ~= nil and b ~= nil then
		    local message = string.sub( message, b+1 )

			if FOLLOWER_NAME == nil then
			    StepLog( "Getting followers name: " .. message )
	            FOLLOWER_NAME = message
			end

			return message
		end
	end

	return nil
end

function CheckForBeingGroup( shouldBeInGroup )
	local name = debugCommon.ToWString( FOLLOWER_NAME )
 	if shouldBeInGroup == true then
		return group.GetMemberIndexByName( name ) ~= nil and group.GetMemberIndexByName( name ) >= 0
	else
		return group.GetMemberIndexByName( name ) == -1 or group.GetMemberIndexByName( name ) == nil
	end
end

function Done()
	debugShard.DebugNotify( ADDON_PREFIX .. DONE_TEXT, false )
 	Success( TEST_NAME )
end

function ErrorFunc( text )
	debugShard.DebugNotify( ADDON_PREFIX .. ERROR_TEXT, false )
	Warn( TEST_NAME, text )
end

----------------------------- EVENTS -----------------------------------

function OnGroupDeslineBusy()
	ErrorFunc("Impussible to invite avatar " .. declinerName)
end

function OnGroupDesline()
	ErrorFunc("Avatar not accepted " .. declinerName)
end

function OnGroupInviteFailed(param)
	ErrorFunc(param.name..": "..param.sysReason)
end

function OnGroupAcceptError()
    ErrorFunc("Avatar not come in group" .. avatar.GetName(avatar.GetId()))
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

		if IS_GETTING_FOLLOWER_NAME then
      		local units = avatar.GetUnitList()
			for index, id in units do
				if unit.IsPlayer( id ) and debugCommon.FromWString(unit.GetName(id)) == FOLLOWER_NAME then
					IS_GETTING_FOLLOWER_NAME = false
					FOLLOWER_ID = id

					local leaderName = unit.GetName( avatar.GetId() )
					StepLog( "Leader sending his NAME to Followers: " .. debugCommon.FromWString( leaderName ))
					debugShard.DebugNotify( "GroupCheck:" .. debugCommon.FromWString( leaderName ), false )

					break
				end
			end
			if FOLLOWER_ID == nil then
				ErrorFunc( "Can not find followers id by name " .. FOLLOWER_NAME )
			end
			
		else
   			StartCheckTimer(3000, CheckForBeingGroup, true, ErrorFunc, "Group not changed...", OnGroupChanged, nil )
			StepLog( "Leader sending GroupInvite to Follower")
			group.Invite( FOLLOWER_ID )
			
		end
	end
end

function OnGroupChanged()
	StepLog( "Follower invited in group!" )
	StepLog( "Leader sending GroupLeave to Followers" )
	StartCheckTimer( 5000, CheckForBeingGroup, false, ErrorFunc, "Follower can not leave group", ReadyForGroupAccept )
	debugShard.DebugNotify( ADDON_PREFIX .. " Get out from my group", false )
end

function ReadyForGroupAccept()
    debugShard.DebugNotify( ADDON_PREFIX .. "I Am Rady For Group Accept", false )
end

function OnGroupInvite(params)
	StepLog("Leader OnGroupInvite STARTED")
	if debugCommon.FromWString( params.inviterName ) == FOLLOWER_NAME then
		StepLog("Followers GroupAccept!")
        group.Accept()
	else
	    ErrorFunc( "Group invite not from leader: " .. debugCommon.FromWString( params.inviterName ))
	end
end

function Init()
	local login = {
		login = developerAddon.GetParam( "login"),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" )
	}
	InitLoging(login)

 	common.RegisterEventHandler( OnDebugNotify, "EVENT_DEBUG_NOTIFY" )
    common.RegisterEventHandler( OnGroupInvite, "EVENT_GROUP_INVITE" )
    common.RegisterEventHandler( OnGroupInviteFailed, "EVENT_GROUP_INVITE_FAILED" )
    common.RegisterEventHandler( OnGroupAcceptError, "EVENT_GROUP_ACCEPT_ERROR" )
	common.RegisterEventHandler( OnGroupDeslineBusy, "EVENT_GROUP_DECLINE_BUSY" )
    common.RegisterEventHandler( OnGroupDesline, "EVENT_GROUP_DECLINE" )

    developerAddon.RunChildGame( "Child.(DeveloperAddon).xdb", " -silentMode" )
end

Init()