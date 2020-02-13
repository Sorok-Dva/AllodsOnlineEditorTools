Global( "TEST_NAME", "SmokeTest.Quest.TakeQuestFromItem; author: Liventsev Andrey, date: 18.07.08, task 32204" )
 
Global( "ITEM_NAME", "Tests/Items/Quest_Giver.(ItemResource).xdb" )
Global( "QUEST_NAME", "Tests/FunctionalTests/Lua/Quests/Item_Get_Recieve/Item_Get_Recieve.xdb" )  
                       
Global( "QUEST_ID", nil )


function TakeQuestFromItem()
	StartTimer( 3000, ErrorFunc, "EVENT OnItemQuestsReceived did not come" )
	avatar.RequestItemQuests( GetItemSlot( ITEM_NAME ))	
end

function CheckQuestBook()
	if GetQuestId( QUEST_NAME ) ~= nil then
		Log( "quest accepted" )
	end
	return GetQuestId( QUEST_NAME ) ~= nil
end

function DestroyItem()
	local slot = GetItemSlot( ITEM_NAME )
	Log( "destroy item. slot=" .. tostring(slot) )
	if slot ~= nil then
		avatar.InventoryDestroyItem( slot )
	end
end


function ErrorFunc( text )
	DestroyItem()
	Warn( TEST_NAME, text )
end

function Done()
	DestroyItem()
	Success( TEST_NAME )
end

------------------------------- EVENTS -----------------------------------------

function OnAvatarCreated()
	StartTest( TEST_NAME )
	if GetItemSlot( ITEM_NAME ) == nil then
		AddItem( ITEM_NAME, 1, TakeQuestFromItem, ErrorFunc )
	else
		TakeQuestFromItem()
	end	
end

function OnItemQuestsReceived( params )
	Log( "available quests:" )
	local quests = avatar.GetAvailableItemQuests( params.slot )
	for index, id in quests do
		Log( "   id=" .. tostring( id ) .. "  name=" .. avatar.GetQuestInfo( id ).debugName )
		if avatar.GetQuestInfo( id ).debugName == QUEST_NAME then
			StopTimer()
			QUEST_ID = id
			Log( "try to accept quest..." )
			StartCheckTimer( 5000, CheckQuestBook, nil, ErrorFunc, "Quest did not accepted", Done, nil )
			avatar.AcceptQuest( id )
			break
		end
	end
end

function Init()
	local login = {
		login = developerAddon.GetParam( "login"),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" ),
		class = "AutoMage"
	}
	InitLoging(login)

	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
	common.RegisterEventHandler( OnItemQuestsReceived, "EVENT_ITEM_QUESTS_RECEIVED" )
end

Init()