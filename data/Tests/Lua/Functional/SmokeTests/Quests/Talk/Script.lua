Global( "TEST_NAME", "SmokeTest.Quest.Talk; author: Liventsev Andrey, date: 23.07.08, task 39834" )


Global( "NPC_NAME", "Tests/Maps/Test/Instances/QuestGiver_TalkWithMe.(MobWorld).xdb" )
Global( "QUEST_NAME", "Tests/FunctionalTests/Lua/Quests/TalkWithMe/TalkWithMe.xdb" )

Global( "MAP_RESOURCE", "/Tests/Maps/Lua/MapResource.xdb" )

function Accept( unitId )
	Log( "Accepting quest..." )
	AcceptQuest( unitId, QUEST_NAME, WaitAMinute, ErrorFunc )
end

function WaitAMinute()
	StartTimer( 2000, Return )
end

function Return()
	Log( "Returning quest..." )
	ReturnQuest( GetMobId( NPC_NAME ), QUEST_NAME, Done, ErrorFunc )
end

function Done()
	DisintagrateMob( NPC_NAME )
	Success( TEST_NAME )
end

function ErrorFunc( text )
	DisintagrateMob( NPC_NAME )
	Warn( TEST_NAME, text )
end


--------------------------------------- EVENTS --------------------------------------------

function OnAvatarCreated()
	StartTest( TEST_NAME )
	Log( "Summoning NPC..." )
	local newPos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), 1 )
	SummonMob( NPC_NAME, MAP_RESOURCE, newPos, 0, Accept, ErrorFunc )
end


function Init()
	local login = {
		login = developerAddon.GetParam( "login"),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" ),
		create = "AutoMage"
	}
	InitLoging(login)

	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
end

Init()