Global( "TEST_NAME", "ZL3, Q12_4. author: Grigoriev Anton; date: 19.12.2008; Task 49575" )

-- params from xdb
Global( "QUEST_NAME", nil )

Global( "ITEM1_NAME", nil )
Global( "NPC2_NAME", nil)

Global( "MOB_LIST", nil )
Global( "QUEST_LIST", nil )
-- /params

function StepFirst()
	Log( "" )
	Log( "Accept:" )
	AcceptQuestFromItem( QUEST_NAME, ITEM1_NAME, StepLast, ErrorFunc )
end

function StepLast()
	Log( "" )
	Log( "Return:" )
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
    
    ITEM1_NAME = developerAddon.GetParam( "Item1Name" )
    NPC2_NAME = developerAddon.GetParam( "NPC2Name" )

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