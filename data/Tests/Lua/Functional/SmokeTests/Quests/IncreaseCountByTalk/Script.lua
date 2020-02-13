Global( "TEST_NAME", "SmokeTest.Quest.IncreaseCountByTalk; author: Liventsev Andrey, date: 26.11.08, task 40988" )

Global( "QUEST_NAME", "Tests/FunctionalTests/Lua/Quests/Increase_Count_By_Talk/Increase_Count_By_Talk.xdb" )
Global( "NPC_NAME", "Tests/Maps/Test/Instances/QuestGiver_Increase_Count_By_Talk.(MobWorld).xdb" )
Global( "TARGET_NAME", "Tests/Maps/Test/Instances/QuestGiver_Increase_Count_By_Talk_Target.(MobWorld).xdb" )

Global( "MAP_RESOURCE", "/Tests/Maps/Lua/MapResource.xdb" )


function Accept( unitId )
	AcceptQuest( unitId, QUEST_NAME, MoveForward, ErrorFunc )
end

function MoveForward()
	local pos = avatar.GetPos()
	pos = ToAbsCoord( pos )
	pos.X = pos.X + 5
	qaMission.AvatarSetPos( ToStandartCoord( pos ))
	StartTimer( 3000, SummonTarget )
end

function SummonTarget()
	local newPos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), 1 )
	SummonMob( TARGET_NAME, MAP_RESOURCE, newPos, 0, Talking, ErrorFunc )
end

function Talking( targetId )
	local progress = avatar.GetQuestProgress( GetQuestId( QUEST_NAME ))
	if progress.objectives[0].progress == 0 then
		StartTimer( 10000, ErrorFunc, "EVENT_TALK_STARTED not coming" )
		common.RegisterEventHandler( OnInteractionStarted, "EVENT_INTERACTION_STARTED" )		
		common.RegisterEventHandler( OnTalkStarted, "EVENT_TALK_STARTED" )		
		avatar.StartInteract( targetId )
	else
		ErrorFunc( "Quest progress=" .. tostring(progress.objectives[0].progress) .. " (not 0)" )
	end	
end

function MoveBackward()
	local progress = avatar.GetQuestProgress( GetQuestId( QUEST_NAME ))
	if progress.objectives[0].progress == 1 then
		Log( "tracker increased by talk!" )
		
		qaMission.AvatarSetPos( debugMission.InteractiveObjectGetPos( GetMobId( NPC_NAME )))
		StartTimer( 2000, Return )
	else
		ErrorFunc( "Quest progress=" .. tostring(progress.objectives[0].progress) .. " (not increased)" )
	end
end

function Return()
	ReturnQuest( GetMobId( NPC_NAME ), QUEST_NAME, Done, ErrorFunc )
end

function Done()
	DisintagrateMob( TARGET_NAME )
	DisintagrateMob( NPC_NAME )
	StartTimer( 3000, Success, TEST_NAME )
end

function ErrorFunc( text )
	DisintagrateMob( TARGET_NAME )
	DisintagrateMob( NPC_NAME )
	StartTimer( 3000, ErrorFunc2, text )
end

function ErrorFunc2( text )
	Warn( TEST_NAME, text )
end

--------------------------------------- EVENTS --------------------------------------------

function OnAvatarCreated()
	StartTest( TEST_NAME )
	local newPos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), 1 )
	SummonMob( NPC_NAME, MAP_RESOURCE, newPos, 0, Accept, ErrorFunc )
end

function OnTalkStarted( params )
	Log( "On talk started --> request interactions" )
	StartTimer( 10000, ErrorFunc, "EVENT_INTERACTION_STARTED not coming" )
	
	avatar.RequestInteractions()
end

function OnInteractionStarted( params )
	Log( "interaction started" )
	StopTimer()
	
	MoveBackward()
end

function Init()
	local login = {
		login = developerAddon.GetParam( "login"),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" ),
		class = "AutoMage"
	}
	InitLoging( login )
	
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
end

Init()
