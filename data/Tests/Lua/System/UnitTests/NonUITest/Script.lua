Global( "TEST_NAME", "NonUITest. Special for Petya.; author: Liventsev Andrey" )


Global( "NPC_NAME", "Tests/Maps/Test/Instances/QuestGiver_TalkWithMe.(MobWorld).xdb" )
Global( "MAP_RESOURCE", "/Tests/Maps/Lua/MapResource.xdb" )

function Summon()
	local newPos = avatar.GetPos()
	local aPos = ToAbsCoord( newPos )
	Log( "summoning mob in z=" .. tostring(aPos.Z ) )
	SummonMob( NPC_NAME, MAP_RESOURCE, newPos, 0, BeforeMoveToZero, ErrorFunc )
end

function BeforeMoveToZero()
	StartTimer( 10000, MoveToZero )
end

function MoveToZero()
	Log( "teleport to z=10" )
	
	local aPos	= ToAbsCoord( avatar.GetPos())
	aPos.Z = 10
	qaMission.AvatarSetPos( ToStandartCoord( aPos ) )
	
	StartTimer( 10000, SummonAgain )
end

function SummonAgain()
	local newPos = avatar.GetPos()
	local aPos = ToAbsCoord( newPos )
	Log( "summoning mob in z=" .. tostring(aPos.Z ) )
	SummonMob( NPC_NAME, MAP_RESOURCE, newPos, 0, Ping, ErrorFunc )
end

function Ping()
	Log( "ping" )
	StartTimer( 1000, Ping )
end


function ErrorFunc( text )
	Warn( TEST_NAME, text )
end



--------------------------------------- EVENTS --------------------------------------------

function OnAvatarCreated()
	StartTest( TEST_NAME )
	
	local aPos	= ToAbsCoord( avatar.GetPos())
	Log( "avatar created in z=" .. tostring( aPos.Z ) )
	aPos.Z = 0
	Log( "teleport to z=0" )
	
	qaMission.AvatarSetPos( ToStandartCoord( aPos ) )
	StartTimer( 10000, Summon )
end



function Init()
	local login = {
		login = developerAddon.GetParam( "login" ),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" ),
		create = "AutoMage",
		delete = true
	}
	InitLoging( login )

	
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
end

Init()