Global( "TEST_NAME", "ZL3, Q11_4. author: Grigoriev Anton; date: 05.12.2008; Task 49575" )

-- params from xdb
Global( "QUEST_NAME", nil )

Global( "NPC1_NAME", nil)
Global( "NPC2_NAME", nil)

Global( "DEV1_NAME", nil )
Global( "ITEM1_NAME", nil )
Global( "ITEM1_COUNT", nil )

Global( "MOB_LIST", nil )
Global( "QUEST_LIST", nil )
-- /params


function StepFirst()
    local npcCoord = GetMobCoords( MOB_LIST, NPC1_NAME, TEST_NAME )
    AcceptQuest( QUEST_NAME, NPC1_NAME, npcCoord[1], Step1, ErrorFunc )
end

function Step1()
    local devCoords = GetDevCoords( MOB_LIST, DEV1_NAME, TEST_NAME )
    LootDevs( DEV1_NAME, devCoords, ITEM1_NAME, ITEM1_COUNT, StepLast, ErrorFunc )
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

	DEV1_NAME = developerAddon.GetParam( "Dev1Name" )
	ITEM1_NAME = developerAddon.GetParam( "Item1Name" )
    ITEM1_COUNT = tonumber( developerAddon.GetParam( "Item1Count" ))
   
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