Global( "TEST_NAME", "SmokeTest.Quest.LootMobs; author: Liventsev Andrey, date: 23.07.08, task 39826" )


Global( "NPC_NAME", "Tests/Maps/Test/Instances/QuestGiver_Loot_N_Targets_100_Percent.(MobWorld).xdb" )
Global( "QUEST_NAME", "Tests/FunctionalTests/Lua/Quests/Loot_N_Targets_100_Percent/Loot_N_Targets_100_Percent.xdb" )
Global( "MOB_NAME", "Tests/Maps/Test/Instances/LootTarget.(MobWorld).xdb" )

Global( "MAP_RESOURCE", "/Tests/Maps/Lua/MapResource.xdb" )

Global( "COUNT_MOBS", nil )
Global( "MAX_COUNT_MOBS", 3 )


function Accept( unitId )
	Log( "Accepting quest..." )
	AcceptQuest( unitId, QUEST_NAME, SummonNext, ErrorFunc )
end

function SummonNext()
	if	COUNT_MOBS == nil then
	    COUNT_MOBS = 0
	else
	    COUNT_MOBS = COUNT_MOBS + 1
	end
	
	Log()
	Log( "LootNext. count=" .. tostring( COUNT_MOBS ) )
	if COUNT_MOBS >= MAX_COUNT_MOBS then
		local coord = debugMission.InteractiveObjectGetPos( GetMobId( NPC_NAME ))
		qaMission.AvatarSetPos( coord )
		StartTimer( 3000, Return )
		
	else
		Log( "Summoning mob..." )
		local newPos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), 1 )
		SummonMob( MOB_NAME, MAP_RESOURCE, newPos, 0, LootNext, ErrorFunc )
	end	
end

function LootNext( mobId )
	Log( "Kill and loot..." )
	LootMob( mobId, SummonNext, ErrorFunc )
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
		class = "AutoMage"
	}
	InitLoging(login)

	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
end

Init()
