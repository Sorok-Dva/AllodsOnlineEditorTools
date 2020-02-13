Global( "TEST_NAME", "System.UnitTest.CheckKillCheat; author: Liventsev Andrey, date: 26.08.08, task 40900" )

-- params
Global( "MOB_NAME", nil )
-- /params

Global( "MAP_RESOURCE", "/Tests/Maps/Lua/MapResource.xdb" )


function TryToKill( unitId )
	KillMob( unitId, Done, ErrorFunc )
end


function Done()
	DisintagrateMob( MOB_NAME )
	Success( TEST_NAME )
end

function ErrorFunc( text )
	DisintagrateMob( MOB_NAME )
	Warn( TEST_NAME, text )
end

--------------------------------------- EVENTS --------------------------------------------

function OnAvatarCreated()
	StartTest( TEST_NAME )

	local newPos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), 1 )
	SummonMob( MOB_NAME, MAP_RESOURCE, newPos, 0, TryToKill, ErrorFunc )
end

function Init()   
	MOB_NAME = developerAddon.GetParam( "mobName" )

	local login = {
		login = developerAddon.GetParam( "login" ),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" )
	}
	InitLoging(login)

	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
end

Init()
