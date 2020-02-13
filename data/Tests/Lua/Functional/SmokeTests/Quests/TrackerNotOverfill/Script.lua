Global( "TEST_NAME", "SmokeTest.Quest.TrackerNotOverfill; author: Liventsev Andrey, date: 21.08.08, bug 32218" )

Global( "NPC_NAME", "Tests/Maps/Test/Instances/QuestGiver_Kill_N_Targets.(MobWorld).xdb" )
Global( "MOB_NAME", "Tests/Maps/Test/Instances/FarmTarget.(MobWorld).xdb" )
Global( "MAP_RESOURCE", "/Tests/Maps/Lua/MapResource.xdb" )
Global( "QUEST_NAME", "Tests/FunctionalTests/Lua/Quests/Kill_N_Targets/Kill_N_Targets.xdb" )

Global( "COUNT_MOBS", nil )
Global( "COUNT_FOR_KILL", 4 )

function BeforeAccept( unitId )
	StartTimer( 2000, Accept, unitId )
end

function Accept( unitId )
	COUNT_MOBS = 0
	AcceptQuest( unitId, QUEST_NAME, KillNext, ErrorFunc )
end

function KillNext()
	if COUNT_MOBS >= COUNT_FOR_KILL then
	    Check()
	    return
	end
	
	COUNT_MOBS = COUNT_MOBS + 1
	Log()
	Log( "Killing next mob: " .. tostring( COUNT_MOBS ) .. "/" .. tostring( COUNT_FOR_KILL ))
    SummonAndKillMob( MOB_NAME, MAP_RESOURCE, KillNext, Done )
end

function Check()
	Log()
	Log( "all mob killed. checking for tracker..." )
	local progress = avatar.GetQuestProgress( GetQuestId( QUEST_NAME ) )
	local obj = progress.objectives[0]
	Log( "tracker values: progress=" .. tostring( obj.progress ) .. " required=" .. tostring( obj.required ))
	if obj.progress == obj.required then
		ReturnQuest( GetMobId( NPC_NAME ), QUEST_NAME, Done, ErrorFunc )
	else
	    ErrorFunc( "Tracker not changed" )
	end
end

function Done()
	DisintagrateMob( NPC_NAME )
	StartTimer( 2000, Success, TEST_NAME )
end

function ErrorFunc( text )
	DisintagrateMob( NPC_NAME )
	StartTimer( 2000, ErrorFunc2, text )
end

function ErrorFunc2( text )
	Warn( TEST_NAME, text )
end

------------------------------ EVENTS --------------------------------------

function OnAvatarCreated()
	StartTest( TEST_NAME )
	
	local newPos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), 1 )
	SummonMob( NPC_NAME, MAP_RESOURCE, newPos, 0, BeforeAccept, ErrorFunc )
end


function Init()
	local login = {
		login = developerAddon.GetParam( "login"),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" )
	}
	InitLoging(login)

	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
end

Init()