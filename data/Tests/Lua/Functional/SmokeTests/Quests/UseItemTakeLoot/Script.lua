Global( "TEST_NAME", "SmokeTest.Quest.UseItemAndLootMob; author: Liventsev Andrey, date: 12.08.08, task 32213" )

-- params
Global( "NPC_NAME",   "Tests/Maps/Test/Instances/QuestGiver_Change_Mob_World_OnItem_Use.(MobWorld).xdb" )
Global( "QUEST_NAME", "Tests/FunctionalTests/Lua/Quests/Change_Mob_World_OnItem_Use/Change_Mob_World_OnItem_Use.xdb" )
Global( "MOB_NAME",   "Tests/Maps/Test/Instances/FarmTarget.(MobWorld).xdb" )
Global( "MOB_NAME_AFTER_USE", "Tests/Maps/Test/Instances/QuestLootTarget.(MobWorld).xdb" )
Global( "ITEM_NAME",  "Tests/Items/Change_Mob_World_OnItem_Use.(ItemResource).xdb" )
Global( "MAP_RESOURCE", "/Tests/Maps/Lua/MapResource.xdb" )
-- /params

Global( "COUNT_MOB", 0 )
Global( "MAX_COUNT_MOB", 5 )
Global( "START_POS", nil )

function SummonNPC()	
	local newPos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), 0.5 )
	SummonMob( NPC_NAME, MAP_RESOURCE, newPos, avatar.GetDir() - math.pi/2, Accept, ErrorFunc )
end

function Accept( npcId )
	AcceptQuest( npcId, QUEST_NAME, SomeMove, ErrorFunc )
end

function SomeMove()
	local newPos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), 10 )
	qaMission.AvatarSetPos( newPos )
	if GetItemSlot( ITEM_NAME ) == nil then
		StartTimer( 1000, AddQuestItem )
	else
		StartTimer( 1000, SummonNextMob )
	end	
end

function AddQuestItem()
	AddItem( ITEM_NAME, 1, SummonNextMob, ErrorFunc )
end

function SummonNextMob()
	Log()
	Log( "Summon next mob: " .. tostring(COUNT_MOB) .. "/" .. tostring( MAX_COUNT_MOB ))
	qaMission.AvatarRevive()
	if COUNT_MOB < MAX_COUNT_MOB then
	    COUNT_MOB = COUNT_MOB + 1

		local newPos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), 0.2 )
		SummonMob( MOB_NAME, MAP_RESOURCE, newPos, avatar.GetDir(), SelectingTarget, ErrorFunc )
	else

		qaMission.AvatarSetPos( START_POS )
		StartTimer( 3000, ReturningQuest )
	end
end

function SelectingTarget( unitId )
	SelectTarget( unitId, UseItemToMob, ErrorFunc )
end

function UseItemToMob()
	local slot = GetItemSlot( ITEM_NAME )
	avatar.InventoryUseItem( slot )
	
	StartTimer( 2000, KillAndLootMob )
end

function KillAndLootMob()
	if GetMobId( MOB_NAME_AFTER_USE ) ~= nil then
		LootMob( GetMobId( MOB_NAME_AFTER_USE ), SummonNextMob, ErrorFunc )

	else
		ErrorFunc( "Can't use item to mob - not effect" )
	end	
end

function ReturningQuest()
	ReturnQuest( GetMobId( NPC_NAME ), QUEST_NAME, Done, ErrorFunc )
end

function Done()
	DisintagrateMob( NPC_NAME )
	DisintagrateMob( MOB_NAME )
	DisintagrateMob( MOB_NAME_AFTER_USE )
	StartTimer( 2000, Success, TEST_NAME )
end

function ErrorFunc( text )
	DisintagrateMob( NPC_NAME )
	DisintagrateMob( MOB_NAME )
	DisintagrateMob( MOB_NAME_AFTER_USE )
	StartTimer( 2000, ErrorFunc2, text )
end

function ErrorFunc2( text )
	Warn( TEST_NAME, text )
end


--------------------------------------- EVENTS ------------------------------------

function OnAvatarCreated()
	StartTest( TEST_NAME )

	START_POS = avatar.GetPos()
	LevelUp( 40, nil, SummonNPC, ErrorFunc )
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


