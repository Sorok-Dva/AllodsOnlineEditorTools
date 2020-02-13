Global( "TEST_NAME", "SmokeTest.Quest.DefendObject; author: Liventsev Andrey, date: 13.08.08, task 32209" )


Global( "NPC_NAME", "Tests/Maps/Test/Instances/QuestGiver_SpawnWithTimer_Boss_And_Add.(MobWorld).xdb" )
Global( "QUEST_NAME", "Tests/FunctionalTests/Lua/Quests/SpawnWithTimer_Boss_And_Add/SpawnWithTimer_Boss_And_Add.xdb" )
Global( "MOB_NAME", "Tests/Maps/Test/Instances/Quest_SpawnWithTimer_Boss.(MobWorld).xdb" )
Global( "MOB2_NAME", "Tests/Maps/Test/Instances/Quest_SpawnWithTimer_Add.(MobWorld).xdb" )
Global( "MAP_RESOURCE", "/Tests/Maps/Lua/MapResource.xdb" )
Global( "IMMUNE_SPELL", "Mechanics/Spells/Cheats/IDDQD/Spell.xdb" )


Global( "COUNT_MOBS", 0 )
Global( "MAX_COUNT_MOBS", 3 )
Global( "KILLING_MOB", false )


function SummonNPC()
	local newPos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), 1 )
	SummonMob( NPC_NAME, MAP_RESOURCE, newPos, 0, BeforeAccept, ErrorFunc )
end

function BeforeAccept( unitId )
	StartTimer( 1000, Accept, unitId )
end

function Accept( unitId )
	AcceptQuest( unitId, QUEST_NAME, MoveToMobsPlace, ErrorFunc )
end

-- в течении 30 сек. проверяем мобов на саммон:
-- если ни один из наших мобов не появился - делаем ошибку.
-- если появился наш моб - убиваем его, увеличиваем счетчик (если нужно) и запускаем таймер опять
-- самая большая сложность - очистить за собой карту (см. LeaveMap)
function MoveToMobsPlace()
	local pos = {
		X = 15.1468, Y = 12.9864, Z = 0
	}
	qaMission.AvatarSetPos( ToStandartCoord( pos ))
	
	StartNewCheckTimer()
end



function CheckForSpawnedMobs()
	if GetMobId( MOB_NAME ) ~= nil or GetMobId( MOB2_NAME ) ~= nil then
		Log( "find mob, id1=" .. tostring( GetMobId(MOB_NAME) ) .. "  id2=" .. tostring( GetMobId( MOB2_NAME )))
	end
	return GetMobId( MOB_NAME ) ~= nil or GetMobId( MOB2_NAME ) ~= nil
end

function KillNextMob()
	if GetMobId( MOB_NAME ) ~= nil then
		StartTimer( 2000, KillAfterWait, GetMobId( MOB_NAME ) )

	elseif GetMobId( MOB2_NAME ) ~= nil then
		KILLING_MOB = true
		StartTimer( 2000, KillAfterWait, GetMobId( MOB2_NAME ) )

	else
	    StopCheckTimer()
		ErrorFunc( "That's impossible!!" )
	end
end

function KillAfterWait( mobId )
	KillMob( mobId, StartNewCheckTimer, ErrorFunc )
end

function StartNewCheckTimer()
	Log( "killed mob" )
	if KILLING_MOB == true then
		KILLING_MOB = false
	    COUNT_MOBS = COUNT_MOBS + 1
	    
	    Log( "   inc count=" .. tostring( COUNT_MOBS ) )
	    if COUNT_MOBS >= MAX_COUNT_MOBS then
	        StopCheckTimer()
			MoveToNPCPlace()
			StartTimer( 2000, Return )
		else
			StartCheckTimer( 30000, CheckForSpawnedMobs, nil, ErrorFunc, "next unit did not summoned", KillNextMob, nil  )
	    end
	    
	else
		Log( "   count=" .. tostring( COUNT_MOBS ) )
		StartCheckTimer( 30000, CheckForSpawnedMobs, nil, ErrorFunc, "next unit did not summoned", KillNextMob, nil  )
	end
end



function MoveToNPCPlace()
	local newPos = {
	    X = 50, Y = 50, Z = 0
	}
	qaMission.AvatarSetPos( ToStandartCoord( newPos ))
end

function Return()
    ReturnQuest( GetMobId( NPC_NAME ), QUEST_NAME, Done, ErrorFunc )
end

function Done()
	DisintagrateMob( NPC_NAME )
	DisintagrateMob( MOB_NAME )
	DisintagrateMob( MOB2_NAME )
	
	Success( TEST_NAME )
end

function ErrorFunc( text )
	DisintagrateMob( MOB_NAME )
	DisintagrateMob( MOB2_NAME )
	MoveToNPCPlace()
	
	StartTimer( 2000, LeaveMap, text )
end

function LeaveMap( text )
	DisintagrateMob( NPC_NAME )
	Warn( TEST_NAME, text )
end




------------------------------------- EVENTS ---------------------------------------

function OnAvatarCreated()
	StartTest( TEST_NAME )

	MoveToNPCPlace()
	StartTimer( 2000, SummonNPC )
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