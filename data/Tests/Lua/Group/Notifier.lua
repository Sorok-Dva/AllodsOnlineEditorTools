
Global( "INVITE",         "invite"         )
Global( "ACCEPT_INVITE",  "accept_invite"  )
Global( "LEAVE_GROUP",    "leave_group"    )
Global( "CHANGE_LEADER",  "change_leader"  )

Global( "TELEPORT",       "teleport"       )
Global( "RELOGIN",        "relogin"        )
Global( "CHECK_PLACE",    "check_place"    )
Global( "CHECK_PLACE_UN", "check_place_un" )
Global( "CHECK_GROUP",    "check_group"    )
Global( "CHECK_GROUP_UN", "check_group_un" )
Global( "PING",           "ping"           )
Global( "EXIT",           "exit"           )

-- Exchange
Global( "ACCEPT_EXCHANGE", "accept_exchange" )
Global( "EXCHANGE_INVITE", "exchange_invite" )
Global( "EXCHANGE_PUT",    "exchange_put"    )
Global( "EXCHANGE_TAKE",   "exchange_take"   )
Global( "EXCHANGE_AGREE",  "exchange_agree"  )
Global( "EXCHANGE_CANCEL", "exchange_cancel" )



Global( "DONE",  "done"  )
Global( "ROGER", "roger" )
Global( "ERROR", "error" )
 
Global( "ACCEPT_INVITE_FROM", nil ) 
Global( "ACCEPT_EXCHANGE_FROM", nil ) 
function ParamsToStr(ps)
	local ret = ""
	for i,p in ps do
		ret = ret .. " " .. tostring(p)
	end
	return ret
end
 
function AvatarDone()
	Log( "done" )
	qaMission.DebugNotify( CreateMessage( PARENT, DONE ), false )
end

 -- парсит сторку. возвращает имя  и список параметров
function ParseMessage( notify )
	local nameIndex = string.find( notify, "!" )
	if nameIndex ~= nil then
		--Log( "parsing message: " .. notify )
		local name = string.sub( notify, 1, nameIndex-1 )
		local avatarName = debugCommon.FromWString( unit.GetName( avatar.GetId() ))
		--Log( avatarName .. "=" .. name )
		
		if name == avatarName then
			local comIndex = string.find( notify, ":", nameIndex-1 )
			if comIndex ~= nil then
				local command = string.sub( notify, nameIndex+1, comIndex-1 )
				--Log( "command=" .. command )
				
				local params = {}
				local prevParamIndex = comIndex+1
				local curParamIndex = string.find( notify, ",", prevParamIndex )
				while curParamIndex ~= nil do
					table.insert( params, string.sub( notify, prevParamIndex, curParamIndex-1 ) )
					--Log( "param=" .. string.sub( notify, prevParamIndex, curParamIndex-1 ) )
					prevParamIndex = curParamIndex + 1
					
					curParamIndex = string.find( notify, ",", prevParamIndex )
				end
				
				--Log( "param=" .. string.sub( notify, prevParamIndex ) )
				table.insert( params, string.sub( notify, prevParamIndex ) )
				
				local result = {
					command = command,
					params = params
				}
				
				return result
			end
		end
	end

	return nil
end

function CreateMessage( avatar, command, params )
	local result = avatar .. "!" .. command .. ":"

	if params ~= nil then
		for index, param in params do
			result = result .. param .. ","
		end
		return string.sub( result, 1, string.len( result ) -1 )
		
	else
		return result
	end	
end



-- команды для рабов

-- телепорт в указанную точку  - 3 параметра - координаты
function TeleportAvatar( params )
	Log( "Teleporting to " .. params[4] .. " " .. params[1] .. " " .. params[2] .. " " .. params[3] .. " ..." )
	local absPos = {
		X = tonumber( params[1] ),
		Y = tonumber( params[2] ),
		Z = tonumber( params[3] )
	}
	local pos = ToStandartCoord( absPos )
	Log(tostring(absPos.X))
	Log(tostring(absPos.Y))
	Log(tostring(absPos.Z))
	
	qaMission.DebugNotify( CreateMessage( PARENT, ROGER ), false )
	qaMission.SendCustomMsg( "tpmap " .. params[4] .. " " .. params[1] .. " " .. params[2] .. " " .. params[3] )
	--qaMission.AvatarSetPos( pos )
	StartCheckTimer( 10000, CheckAvatarPos, pos, ErrorFunc, "Can't teleport", AvatarDone, nil )
end
function CheckAvatarPos( pos )
	local dist = GetDistanceFromPosition( avatar.GetId(), pos )
	Log("DIST "..tostring(dist))
	return dist < 10
end

-- релог аватара
function ReloginAvatar()
	Log( "Reloginig..." )
	
	qaMission.DebugNotify( CreateMessage( PARENT, ROGER ), false )
	--Logout( false )
	--StartTimer( 10000, LoginAvatar )
	Restart()
end
function LoginAvatar()
	local login = {
		login = developerAddon.GetParam( "login"),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" )
	}
	InitLoging( login )
end

-- команда пригласить аватара в группу  - params[i] - имя аватара
function InviteAvatar( params )
	Log( "inviting avatars " .. ParamsToStr(params) )
	qaMission.DebugNotify( CreateMessage( PARENT, ROGER ), false )
	
	local units = avatar.GetUnitList()
	local check = nil
	for index, unitName in params do
		check = unitName
		for index2, unitId in units  do
			if debugCommon.FromWString( unit.GetName( unitId )) == unitName then
				group.Invite( unitId )
				check = nil
			end
		end
		if check ~= nil then
			return ErrorFunc( "Can't find avatar " .. check .. " for inviting in group " )
		end
	end
	AvatarDone()
end

-- команда на принятие приглашения от игрока - params[1] - имя приглашающего аватара
function AcceptInvite( params )
	Log( "accepting invite from" .. params[1] .. "..." )
	group.Leave()
	qaMission.DebugNotify( CreateMessage( PARENT, ROGER ), false )
	ACCEPT_INVITE_FROM = params[1]
end

-- команда проверить наличие аватаров в области видимости - params[i] - список аватаров
function CheckPlaceForVisibleAvatars( params )
	Log( "checking place for visible avatars..." ..ParamsToStr(params))
	qaMission.DebugNotify( CreateMessage( PARENT, ROGER ), false )

	local avatars = {}
	local result = true
	local check = false
	local units = avatar.GetUnitList()
	for index1, avatarName in params do
		check = false
		for index2, unitId in units do
			if debugCommon.FromWString( unit.GetName( unitId )) == avatarName then
				check = true
				break
			end
		end	
		if not check then
			result = false
			table.insert( avatars, avatarName )
		end
	end	

	if result == true then
		Log( "done: all avatats are visible" )
		qaMission.DebugNotify( CreateMessage( PARENT, DONE ), false )
		
	else
		local str = ""
		for index, avatarName in avatars do
			str = str .. avatarName .. "_"
		end
		str = str .. "  "
		
		Log( "[ERROR]   : not visible avatars: " .. string.sub( str, 1, string.len( str )-2 ))
		qaMission.DebugNotify( CreateMessage( PARENT, ERROR, {t = "I can't see " .. str} ), false )
	end
end

-- команда проверить отсутствие аватаров в области видимости - params[i] - список аватаров
function CheckPlaceForUnVisibleAvatars( params )
	Log( "checking place for UN visible avatars..."..ParamsToStr(params) )
	qaMission.DebugNotify( CreateMessage( PARENT, ROGER ), false )

	local avatars = {}
	local check = false
	local result = true
	local units = avatar.GetUnitList()
	for index1, avatarName in params do
		for index2, unitId in units do
			check = false
			if debugCommon.FromWString( unit.GetName( unitId )) == avatarName then
				check = true
				break
			end
		end	
		if check then
			result = false
			table.insert( avatars, avatarName )
		end
	end	

	if result == true then
		Log( "done: all avatats are not visible" )
		qaMission.DebugNotify( CreateMessage( PARENT, DONE ), false )
		
	else
		local str = ""
		for index, avatarName in avatars do
			str = str .. avatarName .. "_"
		end
		str = str .. "  "
		
		Log( "[ERROR]   : visible avatars: " .. string.sub( str, 1, string.len( str )-2 ))
		qaMission.DebugNotify( CreateMessage( PARENT, ERROR, {t = "I can see " .. str }), false )
	end
end

-- команда проверить наличие аватаров в группе - params[i] - список аватаров
function CheckGroupForVisibleAvatars( params )
	Log( "checking group for visible avatars..." ..ParamsToStr(params))
	qaMission.DebugNotify( CreateMessage( PARENT, ROGER ), false )

	local avatars = {}
	local result = true
	local units = group.GetMembers()
	for index1, avatarName in params do
		for index2, unitInfo in units do
			if debugCommon.FromWString( unitInfo.name ) == avatarName then
				break
			end
			result = false
			table.insert( avatars, avatarName )
		end	
	end	

	if result == true then
		Log( "done: all avatats are visible" )
		qaMission.DebugNotify( CreateMessage( PARENT, DONE ), false )
		
	else
		local str = ""
		for index, avatarName in avatars do
			str = str .. avatarName .. "_"
		end
		str = str .. "  "
		
		Log( "[ERROR]   : not visible avatars: " .. string.sub( str, 1, string.len( str )-2 ))
		qaMission.DebugNotify( CreateMessage( PARENT, ERROR, {t = "I can't see " .. str } ), false )
	end
end

-- команда проверить отсутствие аватаров в группе - params[i] - список аватаров
function CheckGroupForUnVisibleAvatars( params )
	Log( "checking group for visible avatars..." ..ParamsToStr(params))
	qaMission.DebugNotify( CreateMessage( PARENT, ROGER ), false )

	local avatars = {}
	local result = true
	local units = group.GetMembers()
	for index1, avatarName in params do
		for index2, unitInfo in units do
			if debugCommon.FromWString( unitInfo.name ) == avatarName then
				result = false
				table.insert( avatars, avatarName )
				break
			end
		end	
	end	

	if result == true then
		Log( "done: all avatats are not visible" )
		qaMission.DebugNotify( CreateMessage( PARENT, DONE ), false )

	else
		local str = ""
		for index, avatarName in avatars do
			str = str .. avatarName .. "_"
		end
		str = str .. "  "
		
		Log( "[ERROR]   : visible avatars: " .. string.sub( str, 1, string.len( str )-2 ))
		qaMission.DebugNotify( CreateMessage( PARENT, ERROR, {t = "I can see " .. str} ), false )
	end
end

-- команда покинуть группу
function LeaveGroup()
	Log( "leaving group..." )
	qaMission.DebugNotify( CreateMessage( PARENT, ROGER ), false )
	
	group.Leave()
	StartCheckTimer( 10000, CheckNotInGroup, nil, ErrorFunc, "Im in group for 10 sec", AvatarDone, nil )
end
function CheckNotInGroup()
	return GetTableSize( group.GetMembers()) == 0
end

-- команда передать лидерство - params[1] - имя аватара
function ChangeLeader( params )
	Log( "changing leader..." ..ParamsToStr(params))
	
	local members = group.GetMembers()
	for index, member in members do 
		if debugCommon.FromWString( member.name ) == params[1] then
			group.SetLeader( member.name )
			StartCheckTimer( 10000, CheckLeader, member.name, ErrorFunc, "Can't change leader", AvatarDone, nil )
		end
	end

	Log( "[ERROR]   :Can't find avatar in group: " .. params[1] )
	qaMission.DebugNotify( CreateMessage( PARENT, ERROR, {t = "Can't find avatar for changing leader"} ), false )
end
function CheckLeader( name )
	return group.GetMemberNameByIndex( group.GetLeaderIndex()) == name
end

function AcceptExchange( params )
	Log( "accepting for exchange from " .. params[1] .. "..." )
	qaMission.DebugNotify( CreateMessage( PARENT, ROGER ), false )
	ACCEPT_EXCHANGE_FROM = params[1]
end

function InviteToExchange( params )
	Log( "inviting avatar " .. params[1] .. " to exchange..." )
	qaMission.DebugNotify( CreateMessage( PARENT, ROGER ), false )

	cLog( " -- inviting" )
	interaction.InviteToExchange( debugCommon.ToWString( params[1] ))
	AvatarDone()
end



function PingAvatar()
	Log( "pinging..." )
	qaMission.DebugNotify( CreateMessage( PARENT, DONE ), false )
end

function ExitAvatar()
	Log( "exiting..." )
	qaMission.DebugNotify( CreateMessage( PARENT, ROGER ), false )
	Logout( true )
end
