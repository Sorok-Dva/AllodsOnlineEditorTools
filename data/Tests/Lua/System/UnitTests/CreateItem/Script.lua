Global( "TEST_NAME", "Lua Unit Test на функцию qaMission.AvatarCreateItem( path ). author: Grigoriev Anton; date: 08.12.2008; Task 50338" )

-- params from xdb
Global( "ITEM_NAME", nil )
-- /params

function DestroyItem( slot )
	avatar.InventoryDestroyItem( slot )
	StartCheckTimer( 3000, CheckDestroyedItem, slot, ErrorFunc, "Can't destroy item", Done ) 
end

function CheckDestroyedItem( slot )
	return avatar.GetInventoryItemId( slot ) == nil
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
	qaMission.AvatarCreateItem( ITEM_NAME )
	StartTimer( 10000, ErrorFunc, "Can not create item: EVENT_INVENTORY_ITEM_ADDED did not come" )
end

function OnInventoryItemAdded( params )
	local slot = params.slot
	local itemInfo = avatar.GetItemInfo( avatar.GetInventoryItemId( slot ) )
	if itemInfo.debugInstanceFileName == ITEM_NAME then
		Log( "Item successfully added" )
		StartTimer( 1000, DestroyItem, slot )
	end
end

function Init()
   	ITEM_NAME = developerAddon.GetParam( "ItemName" )
   
    local login = {
        login = developerAddon.GetParam( "login" ),
        pass = developerAddon.GetParam( "password" ),
        avatar = developerAddon.GetParam( "avatar" )
    }
    InitLoging( login )

    common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
	common.RegisterEventHandler( OnInventoryItemAdded, "EVENT_INVENTORY_ITEM_ADDED" )
end

Init()