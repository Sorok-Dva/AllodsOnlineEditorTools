Global( "TEST_NAME", "SmokeTest.Quest.UseItemOnNpc; author: Liventsev Andrey, date: 11.08.08, task 32207" )


Global( "NPC_NAME", "Tests/Maps/Test/Instances/QuestGiver_UseItemOnMe.(MobWorld).xdb" )
Global( "QUEST_NAME", "Tests/FunctionalTests/Lua/Quests/UseItemOnMe/UseItemOnMe.xdb" )
Global( "ITEM_NAME", "Tests/Items/Quest_UseItemOnMe.(ItemResource).xdb" )

Global( "NPC_ID", nil )

Global( "MAP_RESOURCE", "/Tests/Maps/Lua/MapResource.xdb" )


function Accept( unitId )
	if GetItemSlot( ITEM_NAME ) == nil then
		AcceptQuest( unitId, QUEST_NAME, AddQuestItem, ErrorFunc )
	else
		AcceptQuest( unitId, QUEST_NAME, UseItemToNpc, ErrorFunc )
	end	
end

function AddQuestItem()
	AddItem( ITEM_NAME, 1, UseItemToNpc, ErrorFunc )
end

function UseItemToNpc()
	local slot = GetItemSlot( ITEM_NAME )
	avatar.InventoryUseItem( slot )
	
	StartTimer( 2000, Return )
end

function Return()
	ReturnQuest( GetMobId( NPC_NAME ), QUEST_NAME, Done, ErrorFunc )
end

function Done()
	DisintagrateMob( NPC_NAME )
	Success( TEST_NAME )
end

function ErrorFunc( text )
	DisintagrateMob( NPC_NAME )
	Warn( TEST_NAME, text )
end


------------------------------------- EVENTS ---------------------------------------

function OnAvatarCreated()
	local newPos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), 1 )
	SummonMob( NPC_NAME, MAP_RESOURCE, newPos, 0, Accept, ErrorFunc )
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