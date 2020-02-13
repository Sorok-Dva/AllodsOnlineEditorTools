Global( "TEST_NAME", "AL1, quest4_2. author: Liventsev Andrey; date: 09.07.2008" )

-- params from xdb
Global( "QUEST_NAME", nil )

Global( "LOOT_NAME", nil )
Global( "LOOT_COUNT", nil )

Global( "ITEM1_NAME", nil )
Global( "ITEM1_COUNT", nil )

Global( "ITEM2_NAME", nil )
Global( "ITEM2_COUNT", nil )

Global( "MOB_LIST", nil )
Global( "QUEST_LIST", nil )
-- /params


function StepFirst()
	AcceptQuest( QUEST_LIST, QUEST_NAME, MOB_LIST, Step1, ErrorFunc )
end

function Step1()
	LootMobs( MOB_LIST, LOOT_NAME, LOOT_COUNT, Step2, ErrorFunc )
end

function Step2()
	LootDevs( MOB_LIST, ITEM1_NAME, ITEM1_COUNT, Step3, ErrorFunc )	
end

function Step3()
	LootDevs( MOB_LIST, ITEM2_NAME, ITEM2_COUNT, StepLast, ErrorFunc )	
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
	
	LOOT_NAME = developerAddon.GetParam( "LootName" )
	LOOT_COUNT = tonumber( developerAddon.GetParam( "LootCount" ))

	ITEM1_NAME = developerAddon.GetParam( "Item1Name" )
	ITEM1_COUNT = tonumber( developerAddon.GetParam( "Item1Count" ))
	
	ITEM2_NAME = developerAddon.GetParam( "Item2Name" )
	ITEM2_COUNT = tonumber( developerAddon.GetParam( "Item2Count" ))

	MOB_LIST = developerAddon.LoadMobList()
	if MOB_LIST == nil then
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
