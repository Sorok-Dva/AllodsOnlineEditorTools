Global( "TEST_NAME", "ZL2, Q5_2. author: Grigoriev Anton; date: 17.12.2008; Task 41636" )

-- params from xdb
Global( "QUEST_NAME", nil )

Global( "MOB1_NAME", nil )
Global( "MOB2_NAME", nil )

Global( "LOOT3_NAME", nil )
Global( "LOOT3_COUNT", nil )

Global( "MOB_LIST", nil )
Global( "QUEST_LIST", nil )
-- /params

function StepFirst()
	AcceptQuest( QUEST_LIST, QUEST_NAME, MOB_LIST, Step1, ErrorFunc )
end

function Step1()
    local mobCoords = GetMobCoords( MOB_LIST, MOB1_NAME, TEST_NAME )
    KillMobs( QUEST_NAME, MOB1_NAME, mobCoords, Step2, ErrorFunc )
end

function Step2()
    local mobCoords = GetMobCoords( MOB_LIST, MOB2_NAME, TEST_NAME )
    KillMobs( QUEST_NAME, MOB2_NAME, mobCoords, Step3, ErrorFunc )
end

function Step3()
	LootMobs( MOB_LIST, LOOT3_NAME, LOOT3_COUNT, StepLast, ErrorFunc )
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
    
	MOB1_COUNT = developerAddon.GetParam( "Mob1Count" )
    MOB2_COUNT = developerAddon.GetParam( "Mob2Count" )	
	
	LOOT3_NAME = developerAddon.GetParam( "Loot3Name" )
    LOOT3_COUNT = tonumber( developerAddon.GetParam( "Loot3Count" ))

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