Global( "TEST_NAME", "ZL3, Q3_2. author: Grigoriev Anton; date: 05.12.2008; Task 49575" )

-- params from xdb
Global( "QUEST_NAME", nil )
Global( "REQ_LEVEL", nil )
Global( "REQ_QUESTS", nil )

Global( "NPC1_NAME", nil)
Global( "NPC2_NAME", nil)

Global( "MOB_LIST", nil )
Global( "QUEST_LIST", nil )
-- /params

Global( "MAP_NAME", "/Maps/Kania/MapResource.xdb" )

function StepFirst()
	Log( "Accept:" )
    local npcCoord = GetMobCoords( MOB_LIST, NPC1_NAME, TEST_NAME )
    AcceptQuest( QUEST_NAME, NPC1_NAME, npcCoord[1], Step1, ErrorFunc )
end

function Step1()
	Log( "Complete:" )
    CompleteQuest( QUEST_NAME, PreStepLast)
end

function PreStepLast()
    local newPos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), 1 )
	SummonMob( NPC2_NAME, MAP_NAME, newPos, 2, StepLast, ErrorFunc )
end

function StepLast( mobId )
	ReturnQuest( mobId, QUEST_NAME, DisMob, ErrorFunc )
end

function DisMob()
	DisintagrateMob( NPC2_NAME )
	StartTimer(1000, Done)
end

-- function StepLast()
	-- Log( "Return:" )
    -- local npcCoord = GetMobCoords( MOB_LIST, NPC2_NAME, TEST_NAME )
    -- ReturnQuest( QUEST_NAME, NPC2_NAME, npcCoord[1], Done, ErrorFunc )
-- end

function Done()
	Success( TEST_NAME )
end

function ErrorFunc( text )
    Warn( TEST_NAME, text )
end

------------------------------ EVENTS -----------------------------------------

function OnAvatarCreated( params )
    StartTest( TEST_NAME )
    
	DoReqConditions( QUEST_NAME, QUEST_LIST, StepFirst, ErrorFunc )
end

function Init()
    QUEST_NAME = developerAddon.GetParam( "QuestName" )
   
    NPC1_NAME = developerAddon.GetParam( "NPC1Name" )
    NPC2_NAME = developerAddon.GetParam( "NPC2Name" )

    MOB_LIST = developerAddon.LoadMobList()
    if MOB_LIST == nil or GetTableSize(MOB_LIST)==0 then
        Warn( TEST_NAME, "mob list is empty" )
    end

	QUEST_LIST = developerAddon.LoadQuestList()
	if QUEST_LIST == nil or GetTableSize(QUEST_LIST) == 0 then
		Warn( TEST_NAME, "quest list is empty" )
	end	


    local login = {
        login = developerAddon.GetParam( "login" ),
        pass = developerAddon.GetParam( "password" ),
        avatar = developerAddon.GetParam( "avatar" )
    }
    InitLoging( login )

    common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
end

Init()