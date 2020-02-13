-- тест для проверки места респавна аватара
Global( "TEST_NAME", "SmokeTest.RespawnPlace; author: Liventsev Andrey, date: 02.10.2008" )

-- params from xdb
Global( "START_PLACE", nil )
Global( "RESPAWN_PLACE", nil ) 

Global( "RESPAWN_RANGE", 10 )
-- /params


Global( "KILLING_SPELL", "Mechanics/Spells/Cheats/Kill/spell.xdb" )

function SelectingTarget()
	SelectTarget( avatar.GetId(), Suicide, ErrorFunc )
end

function Suicide()
	LearnAndCastSpell( KILLING_SPELL, TEST_NAME )
	
end

function CheckPlace()
	local pos = ToAbsCoord( avatar.GetPos() )    
	Log( "check avatar spawn coord: x=" .. tostring(pos.X) .. " y=" .. tostring(pos.Y) .. " z=" .. tostring(pos.Z) )
	
	local difX = math.abs( pos.X-RESPAWN_PLACE.X )
	local difY = math.abs( pos.Y-RESPAWN_PLACE.Y )
	local difZ = math.abs( pos.Z-RESPAWN_PLACE.Z )
	if difX < RESPAWN_RANGE and difY < RESPAWN_RANGE and difZ < RESPAWN_RANGE then
		return true
	else
		return false
	end
end

function ErrorFunc( text )
	Warn( TEST_NAME, text )
end

-------------------------------------- EVENTS ---------------------------------

function OnAvatarCreated( params )
	StartTest( TEST_NAME )

	StartTimer( 10000, SelectingTarget )
	qaMission.AvatarSetPos( START_PLACE )
end

function OnUnitDeadChanged( params )
	if params.unitId == avatar.GetId() and unit.IsDead( params.unitId ) then
		debugMission.Log( "unit is dead" )
		avatar.Respawn()
		StartCheckTimer( 10000, CheckPlace, nil, ErrorFunc, "Wrong respawn place", Success, TEST_NAME )
	end
end

function Init()
	local login = {
		login = developerAddon.GetParam( "login"),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" )
	}
	InitLoging(login)

	local pos = {
	    X = tonumber( developerAddon.GetParam( "StartX" )),
	    Y = tonumber( developerAddon.GetParam( "StartY" )),
	    Z = tonumber( developerAddon.GetParam( "StartZ" ))
	}
	START_PLACE = ToStandartCoord( pos )


	pos = {
	    X = tonumber( developerAddon.GetParam( "RespawnX" )),
	    Y = tonumber( developerAddon.GetParam( "RespawnY" )),
	    Z = tonumber( developerAddon.GetParam( "RespawnZ" ))
	}
	RESPAWN_PLACE = pos
	RESPAWN_RANGE = tonumber( developerAddon.GetParam( "RespawnRange" ))
	
	
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
	common.RegisterEventHandler( OnUnitDeadChanged, "EVENT_UNIT_DEAD_CHANGED" )
end


Init()