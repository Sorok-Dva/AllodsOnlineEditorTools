Global( "TEST_NAME", "AL1, quest3_1. author: Liventsev Andrey; date: 09.07.2008" )

-- params from xdb
Global( "QUEST_NAME", nil )

Global( "NPC2_NAME", nil)

Global( "ITEM_NAME", nil )

Global( "MOB_LIST", nil )
Global( "QUEST_LIST", nil )
-- /params



function StepFirst()
	AcceptQuest( QUEST_LIST, QUEST_NAME, MOB_LIST, Step1, ErrorFunc )
end

function Step1()
	local npcCoords = GetMobCoords( MOB_LIST, NPC2_NAME, TEST_NAME )
	UseItemsToTargets( NPC2_NAME, npcCoords, ITEM_NAME, 1, 8000, CheckUsingItem, StepLast, ErrorFunc )
end
function CheckUsingItem()
	return GetCountItem( ITEM_NAME ) == 0
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

	NPC2_NAME = developerAddon.GetParam( "NPC2Name" )

	ITEM_NAME = developerAddon.GetParam( "ItemName" )
	
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
