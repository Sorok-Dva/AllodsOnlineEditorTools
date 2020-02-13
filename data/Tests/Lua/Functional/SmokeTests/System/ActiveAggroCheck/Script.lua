Global( "TEST_NAME", "SmokeTest.ActiveAgroCheck; author: Liventsev Andrey, date: 24.07.08, task 37325" )

Global( "MOB_NAME",   nil )

Global( "MAP_RESOURCE", "/Tests/Maps/Lua/MapResource.xdb" )

Global( "MOB_ID", nil )
Global( "DISTANCE", nil )


function MainFunc( mobId )
	Log( "checking agro list (1)..." )
	
	MOB_ID = mobId
	
	if IsAggresive( MOB_ID ) then
		ErrorFunc( "Mob aggresive to avatar" )
		return
	end
	
	local pos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), DISTANCE )
	qaMission.AvatarSetPos( pos )
	StartCheckTimer( 10000, IsAggresive, mobId, ErrorFunc, "Avatar still not in mob aggro list, but should be", Done )
end

function IsAggresive( mobId )
	local aggro = debugMission.UnitGetAggroList( mobId )
	if aggro ~= nil then
		for unitId, value in aggro do
		    if unitId == avatar.GetId() then
				return true
			end
		end
	end
	
	return false
end

function Done()
	DisintagrateMob( MOB_NAME )
	StartTimer( 1000, Success, TEST_NAME )
end

function ErrorFunc( text )
	DisintagrateMob( MOB_NAME )
	StartTimer( 1000, Warning, text )
end

function Warning( text )
	Warn( TEST_NAME, text )
end


--------------------------------------- EVENTS --------------------------------------------

function OnAvatarCreated()
	StartTest( TEST_NAME )
	
	Log( "summoning mob..." )
	local newPos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), DISTANCE + 10 )
	SummonMob( MOB_NAME, MAP_RESOURCE, newPos, avatar.GetDir() - math.pi, MainFunc, ErrorFunc )
end

function Init()
	local login = {
		login = developerAddon.GetParam( "login"),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" )
	}
	InitLoging(login)

    MOB_NAME = developerAddon.GetParam( "mobName" )
    DISTANCE = tonumber( developerAddon.GetParam( "aggroRadius" ))

	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
end

Init()


