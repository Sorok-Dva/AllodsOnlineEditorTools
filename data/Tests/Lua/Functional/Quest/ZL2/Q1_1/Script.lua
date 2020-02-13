Global( "TEST_NAME", "ZL2, Q1_1. author: Grigoriev Anton; date: 17.12.2008; Task 41636" )

-- params from xdb
Global( "QUEST_NAME", nil )

Global( "LOOT1_NAME", nil )
Global( "LOOT1_COUNT", nil )

Global( "LOOT2_NAME", nil )
Global( "LOOT2_COUNT", nil )

Global( "MOB_LIST", nil )
Global( "QUEST_LIST", nil )
-- /params

function StepFirst()
	AcceptQuest( QUEST_LIST, QUEST_NAME, MOB_LIST, Step1, ErrorFunc )
end

function Step1()
	LootMobs( MOB_LIST, LOOT1_NAME, LOOT1_COUNT, Step2, ErrorFunc )
end

function Step2()
	LootMobs( MOB_LIST, LOOT2_NAME, LOOT2_COUNT, StepLast, ErrorFunc )
end

function StepLast()
	ReturnQuest( QUEST_LIST, QUEST_NAME, MOB_LIST, Done, ErrorFunc )
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
    
	LOOT1_NAME = developerAddon.GetParam( "Loot1Name" )
    LOOT1_COUNT = tonumber( developerAddon.GetParam( "Loot1Count" ))

	LOOT2_NAME = developerAddon.GetParam( "Loot2Name" )
    LOOT2_COUNT = tonumber( developerAddon.GetParam( "Loot2Count" ))
    
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