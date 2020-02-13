Global( "TEST_NAME", "SmokeTest.Quest.TrackerChange; author: Liventsev Andrey, date: 21.08.08, bug 32218" )

Global( "NPC_NAME", "Tests/Maps/Test/Instances/QuestGiver_Kill_N_Targets.(MobWorld).xdb" )
Global( "MOB_NAME", "Tests/Maps/Test/Instances/FarmTarget.(MobWorld).xdb" )
Global( "MAP_RESOURCE", "/Tests/Maps/Lua/MapResource.xdb" )
Global( "QUEST_NAME", "Tests/FunctionalTests/Lua/Quests/Kill_N_Targets/Kill_N_Targets.xdb" )

Global( "COUNT_MOBS", nil )

function BeforeAccept( unitId )
	StartTimer( 2000, Accept, unitId )
end

function Accept( unitId )
	AcceptQuest( unitId, QUEST_NAME, KillNext, ErrorFunc )
end

function KillNext()
	Log( "Killing one mob" )
    SummonAndKillMob( MOB_NAME, MAP_RESOURCE, BeforeCheck, ErrorFunc )
end

function BeforeCheck()
	StartTimer( 2000, Check )
end

function Check()
	Log( "mob killed. checking for tracker..." )
	local progress = avatar.GetQuestProgress( GetQuestId( QUEST_NAME ))
	local obj = progress.objectives[0]
	Log( "tracker values: progress=" .. tostring( obj.progress ) .. " required=" .. tostring( obj.required ))
	if obj.progress == 1 then
		ReturnQuest( GetMobId( NPC_NAME ), QUEST_NAME, ReturnQuestPass, Done )
	else
	    ErrorFunc( "Tracker not changed" )
	end
end

function ReturnQuestPass()
	local obj = avatar.GetQuestProgress( GetQuestId( QUEST_NAME ) ).objectives[0]
	ErrorFunc( "Quest returned (progress " .. tostring(obj.progress) .. "/" .. tostring(obj.required ) .. ")" )
end

function Done()
	DisintagrateMob( MOB_NAME )
	DisintagrateMob( NPC_NAME )
	StartTimer( 3000, Success, TEST_NAME )
end

function ErrorFunc( text )
	DisintagrateMob( MOB_NAME )
	DisintagrateMob( NPC_NAME )
	StartTimer( 3000, ErrorFunc2, text )
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
		avatar = developerAddon.GetParam( "avatar" ),
		create = "AutoMage"
	}
	InitLoging(login)

	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
end

Init()