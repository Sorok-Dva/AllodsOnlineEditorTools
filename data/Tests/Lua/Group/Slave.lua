Global( "TEST_NAME", "Prorabov rab #1" )

Global( "PARENT", "Prorab" )

function Done()
	Success( TEST_NAME )
end

function ErrorFunc( text )
	Log("[ERROR]   :"..text)
	qaMission.DebugNotify( CreateMessage( PARENT, ERROR, {t = text} ), false )
end



function OnAvatarCreated()
	AvatarDone()
end

function OnDebugNotify( params )
	if debugCommon.FromWString( params.sender ) == PARENT then
		local message = debugCommon.FromWString( params.message )
		local messageParams = ParseMessage( message )
		
		if messageParams ~= nil then
			if messageParams.command == TELEPORT then
				TeleportAvatar( messageParams.params )

			elseif messageParams.command == RELOGIN then
				ReloginAvatar()
			elseif messageParams.command == CHECK_PLACE then
				CheckPlaceForVisibleAvatars( messageParams.params )
				
			elseif messageParams.command == CHECK_PLACE_UN then
				CheckPlaceForUnVisibleAvatars( messageParams.params )
				
			elseif messageParams.command == CHECK_GROUP then
				CheckGroupForVisibleAvatars( messageParams.params )
				
			elseif messageParams.command == CHECK_GROUP_UN then
				CheckGroupForUnVisibleAvatars( messageParams.params )
				
			elseif messageParams.command == ACCEPT_INVITE then
				AcceptInvite( messageParams.params )
				
			elseif messageParams.command == INVITE then
				InviteAvatar( messageParams.params )

			elseif messageParams.command == ACCEPT_EXCHANGE then
				AcceptExchange( messageParams.params )
				
			elseif messageParams.command == EXCHANGE_INVITE then
				InviteToExchange( messageParams.params )


				
				
			elseif messageParams.command == CHANGE_LEADER then
				ChangeLeader( messageParams.params )

			elseif messageParams.command == LEAVE_GROUP then
				LeaveGroup()
				
			elseif messageParams.command == PING then
				PingAvatar( messageParams.params )
				
			elseif messageParams.command == EXIT then
				ExitAvatar( messageParams.params )
			end
		end	
	end
end

function OnGroupInviteFailed( params )
	local msg = "invite failed: " .. debugCommon.FromWString( name ) .. " reason:" .. sysReason
	qaMission.DebugNotify( CreateMessage( PARENT, ERROR, msg ), false )
end

function OnGroupInvite( params )
	local name = debugCommon.FromWString( params.inviterName )
	if ACCEPT_INVITE_FROM == name then
		group.Accept()
		ACCEPT_INVITE_FROM = nil
		AvatarDone()

	else
		qaMission.DebugNotify( CreateMessage( PARENT, ERROR, "Avatar " .. developerAddon.GetParam( "login" ) .. " received unexpected invite from " .. name ), false )	
	end
end

function OnItemsExchangedInvited()
	Log( "items exchanged invited" )
end


function Init()
	local login = {
		login = developerAddon.GetParam( "login" ),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" )
	}
	InitLoging(login)

	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
	common.RegisterEventHandler( OnDebugNotify, "EVENT_DEBUG_NOTIFY" )
	common.RegisterEventHandler( OnGroupInviteFailed, "EVENT_GROUP_INVITE_FAILED" )
	common.RegisterEventHandler( OnGroupInvite, "EVENT_GROUP_INVITE" )
	common.RegisterEventHandler( OnItemsExchangedInvited, "EVENT_ITEMS_EXCHANGE_INVITED" )
	
end

Init()
