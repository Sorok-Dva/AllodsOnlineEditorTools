Global( "TEST_NAME", "SmokeTest.Quest.UseItemSummonMob; author: Liventsev Andrey, date: 18.07.08, task 32208" )


Global( "NPC_NAME", "Tests/Maps/Test/Instances/QuestGiver_SpawnMob_From_Item.(MobWorld).xdb" )
Global( "QUEST_NAME", "Tests/FunctionalTests/Lua/Quests/SpawnMob_From_Item/SpawnMob_From_Item.xdb" )
Global( "MOB_NAME", "Tests/Maps/Test/Instances/Quest_SpawnWithTimer_Add.(MobWorld).xdb" )
Global( "ITEM_NAME", "Tests/Items/SpawnMob_From_Item.(ItemResource).xdb" )

Global( "MAP_RESOURCE", "/Tests/Maps/Lua/MapResource.xdb" )
Global( "COUNT_MOBS", nil )
Global( "MAX_COUNT_MOBS", 5 )

function SummonNPC()	
	local newPos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), 1 )
	SummonMob( NPC_NAME, MAP_RESOURCE, newPos, 0, Accept, ErrorFunc )
end

function Accept( unitId )
	if GetItemSlot( ITEM_NAME ) == nil then
		AcceptQuest( unitId, QUEST_NAME, AddQuestItem, ErrorFunc )
	else
		AcceptQuest( unitId, QUEST_NAME, BeforeKillNext, ErrorFunc )
	end	
end

function AddQuestItem()
	AddItem( ITEM_NAME, 1, KillNext, ErrorFunc )
end

function BeforeKillNext()
	qaMission.AvatarRevive()
	StartTimer( 1000, KillNext )
end

function KillNext()
	if	COUNT_MOBS == nil then
	    COUNT_MOBS = 0
	else
	    COUNT_MOBS = COUNT_MOBS + 1
	end
	
	if COUNT_MOBS >= MAX_COUNT_MOBS then
		ReturnQuest( GetMobId( NPC_NAME ), QUEST_NAME, Done, ErrorFunc )
	else
		Log()
		Log( "KillNext. count=" .. tostring( COUNT_MOBS ) )
		UseItem( ITEM_NAME, 3000, KillSummonedMob, ErrorFunc )
	end
end

function KillSummonedMob()
	Log( "id=" .. tostring( GetMobId(MOB_NAME) ) )
	KillMob( GetMobId( MOB_NAME ), BeforeKillNext, ErrorFunc )
end

function Done()
	DisintagrateMob( NPC_NAME )
	DisintagrateMob( MOB_NAME )
	Success( TEST_NAME )
end

function ErrorFunc( text )
	DisintagrateMob( NPC_NAME )
	DisintagrateMob( MOB_NAME )
	Warn( TEST_NAME, text )
end

------------------------------------- EVENTS ---------------------------------------

function OnAvatarCreated()
	StartTest( TEST_NAME )
	
	LevelUp( 20, nil, SummonNPC, ErrorFunc )
end


function Init()
	local login = {
		login = developerAddon.GetParam( "login"),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" ),
		create = "AutoMage"
	}
	InitLoging(login)

	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
end

Init()