Global( "TEST_NAME", "ZL3, Q6_4. author: Grigoriev Anton; date: 05.12.2008; Task 49575" )

-- params from xdb
Global( "QUEST_NAME", nil )
Global( "REQ_LEVEL", nil )
Global( "REQ_QUESTS", nil )

Global( "NPC1_NAME", nil)
Global( "NPC2_NAME", nil)

Global( "MOB1_NAME", nil )
Global( "LOOT1_NAME", nil )
Global( "LOOT1_COUNT", nil )

Global( "MOB_LIST", nil )
Global( "QUEST_LIST", nil )
-- /params

function StepFirst()
    local npcCoord = GetMobCoords( MOB_LIST, NPC1_NAME, TEST_NAME )
    AcceptQuest( QUEST_NAME, NPC1_NAME, npcCoord[1], Step1, ErrorFunc )
end

function Step1()
    local mobCoords = GetMobCoords( MOB_LIST, MOB1_NAME, TEST_NAME )
    LootMobs( MOB1_NAME, mobCoords, LOOT1_NAME, LOOT1_COUNT, StepLast, ErrorFunc )
end

function StepLast()
    local npcCoord = GetMobCoords( MOB_LIST, NPC2_NAME, TEST_NAME )
    ReturnQuest( QUEST_NAME, NPC2_NAME, npcCoord[1], Done, ErrorFunc )
end

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

	MOB1_NAME = developerAddon.GetParam( "Mob1Name" )
	LOOT1_NAME = developerAddon.GetParam( "Loot1Name" )
    LOOT1_COUNT = tonumber( developerAddon.GetParam( "Loot1Count" ))
    
    MOB_LIST = developerAddon.LoadMobList()
    if MOB_LIST == nil or GetTableSize(MOB_LIST) == 0 then
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