Global( "TEST_NAME", "ZL2, Q2_2. author: Grigoriev Anton; date: 08.12.2008; Task 41636" )

-- params from xdb
Global( "QUEST_NAME", nil )

Global( "MOB1_NAME", nil )
Global( "MOB2_NAME", nil )
Global( "MOB3_NAME", nil )

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
	local mobCoords = GetMobCoords( MOB_LIST, MOB3_NAME, TEST_NAME )
	KillMobs( QUEST_NAME, MOB3_NAME, mobCoords, StepLast, ErrorFunc )
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

	MOB_NAME1 = developerAddon.GetParam( "MobName1" )
	MOB_NAME2 = developerAddon.GetParam( "MobName2" )
	MOB_NAME3 = developerAddon.GetParam( "MobName3" )
	
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
