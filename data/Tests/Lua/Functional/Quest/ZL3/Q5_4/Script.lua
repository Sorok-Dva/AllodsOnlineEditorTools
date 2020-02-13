Global( "TEST_NAME", "ZL3, Q5_4. author: Grigoriev Anton; date: 05.12.2008; Task 49575" )

-- params from xdb
Global( "QUEST_NAME", nil )
Global( "REQ_LEVEL", nil )
Global( "REQ_QUESTS", nil )

Global( "NPC1_NAME", nil)
Global( "NPC2_NAME", nil)

Global( "ITEM1_NAME", nil )
Global( "ITEM1_COUNT", nil )
Global( "POINT1_COORD", nil )

Global( "ITEM2_NAME", nil )
Global( "ITEM2_COUNT", nil )
Global( "POINT2_COORD", nil )

Global( "MOB_LIST", nil )
Global( "QUEST_LIST", nil )
-- /params


-- function Step1()
    -- UseInventoryItem( ITEM1_NAME, ITEM1_COUNT, Step2, ErrorFunc )
-- end

-- function Step2()
    -- UseInventoryItem( ITEM2_NAME, ITEM2_COUNT, StepLast, ErrorFunc )
-- end
function StepFirst()
	Log( "" )
	Log( "Accept:" )
    local npcCoord = GetMobCoords( MOB_LIST, NPC1_NAME, TEST_NAME )
    AcceptQuest( QUEST_NAME, NPC1_NAME, npcCoord[1], Step1, ErrorFunc )
end

function Step1()
	Log( "" )
	Log( "Complete:" )
    CompleteQuest( QUEST_NAME, StepLast)
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
    
    NPC1_NAME = developerAddon.GetParam( "NPC1Name" )
    NPC2_NAME = developerAddon.GetParam( "NPC2Name" )

	ITEM1_NAME = developerAddon.GetParam( "Item1Name" )
	ITEM1_COUNT = tonumber( developerAddon.GetParam( "Item1Count" ))
 
	ITEM2_NAME = developerAddon.GetParam( "Item2Name" )
	ITEM2_COUNT = tonumber( developerAddon.GetParam( "Item2Count" ))

	-- local pos1 = {
			-- X1 = tonumber( developerAddon.GetParam( "PlaceX1" )),
			-- Y1 = tonumber( developerAddon.GetParam( "PlaceY1" )),
			-- Z1 = tonumber( developerAddon.GetParam( "PlaceZ1" ))
	-- }
	-- POINT1_COORD = ToStandartCoord( pos1 )

	-- local pos2 = {
			-- X2 = tonumber( developerAddon.GetParam( "PlaceX2" )),
			-- Y2 = tonumber( developerAddon.GetParam( "PlaceY2" )),
			-- Z2 = tonumber( developerAddon.GetParam( "PlaceZ2" ))
	-- }
	-- POINT2_COORD = ToStandartCoord( pos2 )

	
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