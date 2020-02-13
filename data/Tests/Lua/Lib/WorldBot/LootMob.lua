-- ф-ция для лута моба
-- Передается id живого моба
-- Для лута всех предметов вызывать LootMob

Global( "WBLM_PASS_FUNCTION",  nil )
Global( "WBLM_ERROR_FUNCTION", nil )
Global( "WBLM_MOB_ID", nil )
Global( "WBLM_ITEM_NAME", nil )
Global( "WBLM_TAKE_ALL", nil )

Global( "WBLM_IS_LOOTED", false )
Global( "WBLM_LOOT_MARKED", nil )

Global( "WBLM_FILTER", 10 )

function LootMob( mobId, passFunc, errorFunc )
	Log( "start looting mob. id=" .. tostring( mobId ), "WorldBot.LootMob" )
	
	WBLM_Start()
	
	WBLM_IS_LOOTED = false
	WBLM_TAKE_ALL = true
	WBLM_PASS_FUNCTION = passFunc
	WBLM_ERROR_FUNCTION = errorFunc
	WBLM_MOB_ID = mobId
	
	WBLM_LOOT_MARKED = false
	KillMob( mobId, WBLM_StartWaitingForLoot, WBLM_ERROR_FUNCTION )
end

function LootMobTakeItem( mobId, itemName, passFunc, errorFunc )
    WBLM_Start()
    
	WBLM_IS_LOOTED = false
	WBLM_TAKE_ALL = false
	WBLM_ITEM_NAME = itemName
	WBLM_PASS_FUNCTION = passFunc
	WBLM_ERROR_FUNCTION = errorFunc
	WBLM_MOB_ID = mobId
	
	WBLM_LOOT_MARKED = false
	KillMob( mobId, WBLM_StartWaitingForLoot, WBLM_ERROR_FUNCTION )
end

function WBLM_LootingMob()
	local isDead = unit.IsDead( WBLM_MOB_ID )
	local isUsable = unit.IsUsable( WBLM_MOB_ID )
	Log( "WBLM_LootingMob: " .. tostring(WBLM_MOB_ID) .. " " .. tostring(isDead) .. " " .. tostring( isUsable ) )
	
	if unit.IsDead( WBLM_MOB_ID ) and unit.IsUsable( WBLM_MOB_ID ) then
		local pos = debugMission.InteractiveObjectGetPos( WBLM_MOB_ID )
		Log( "move to mob: " .. PrintCoord( pos ), "WorldBot.LootMob")
		qaMission.AvatarSetPos( pos )
		StartPrivateTimer( 1000, WBLM_UseMob )
		
	else
		StartPrivateTimer( 1000, WBLM_LootingMob )
--		WBLM_ERROR_FUNCTION( "Can not loot mob: Mob is dead = " .. tostring( isDead ) .. "   isUsable=" .. tostring( isUsable ))
	end
end

function WBLM_UseMob()
	Log( "WBLM_UseMob. id=" .. tostring( WBLM_MOB_ID ), "WorldBot.LootMob" )
	object.Use( WBLM_MOB_ID, WBLM_FILTER )
	StartPrivateCheckTimer( 15000, WBLM_CheckLoot, nil, WBLM_PassFunc, nil, WBLM_PassFunc, nil )
end

function WBLM_CheckLoot()
	return WBLM_IS_LOOTED
end

function WBLM_CheckChangedSlot( slot )
	if WBLM_TAKE_ALL == false then
		local itemId = avatar.GetInventoryItemId( slot )
		local itemInfo = avatar.GetItemInfo( itemId )
		if itemInfo.debugInstanceFileName == WBLM_ITEM_NAME then
			WBLM_IS_LOOTED = true
		end
	end
end

function WBLM_StartWaitingForLoot()
	if WBLM_LOOT_MARKED == false then
		StartPrivateTimer( 5000, WBLM_NoLoot )
	end	
end

function WBLM_NoLoot()
    Log( "Unit LootMob: no loot", "WorldBot.LootMob" )
	if WBLM_TAKE_ALL == false then
		WBLM_ERROR_FUNCTION( "Mob does not have required item" )
	else
		WBLM_PassFunc()
	end
end

function WBLM_PassFunc()
	WBLM_Stop()
	Log( "Done", "WorldBot.LootMob" )
	WBLM_PASS_FUNCTION()
end

function WBLM_Start()
	common.RegisterEventHandler( WBLM_OnLootBagOpenStateChanged, "EVENT_LOOT_BAG_OPEN_STATE_CHANGED" )
	common.RegisterEventHandler( WBLM_OnInventoryItemAdded, "EVENT_INVENTORY_ITEM_ADDED" )
	common.RegisterEventHandler( WBLM_OnInventoryItemChanged, "EVENT_INVENTORY_ITEM_CHANGED" )
	common.RegisterEventHandler( WBLM_OnLootMark, "EVENT_LOOT_MARK" )
end

function WBLM_Stop()
	common.UnRegisterEventHandler( "EVENT_LOOT_BAG_OPEN_STATE_CHANGED" )
	common.UnRegisterEventHandler( "EVENT_INVENTORY_ITEM_ADDED" )
	common.UnRegisterEventHandler( "EVENT_INVENTORY_ITEM_CHANGED" )
	common.UnRegisterEventHandler( "EVENT_LOOT_MARK" )
end

---------------------------- EVENTS ----------------------------------------------

function WBLM_OnLootBagOpenStateChanged( params )
	if avatar.IsLootBagOpen() then
		if WBLM_TAKE_ALL == true then
			avatar.TakeAllLoot()
			WBLM_IS_LOOTED = true

		else
			local count = 0
			local loot = avatar.GetLootBagSlots()
			local lootTable = loot.items

			if lootTable ~= nil then
				for slot, itemId in lootTable do
					local itemInfo = avatar.GetItemInfo( itemId )
					local name = itemInfo.debugInstanceFileName
					if name == WBLM_ITEM_NAME then
						avatar.TakeLoot( slot )
						count = count + 1
					end
				end
			end

			if count == 0 then
				WBLM_ERROR_FUNCTION( "Mob does not have required item" )
			end
		end	
	end
end

function WBLM_OnInventoryItemAdded( params )
	WBLM_CheckChangedSlot( params.slot )
end

function WBLM_OnInventoryItemChanged( params )
	WBLM_CheckChangedSlot( params.slot )
end

function WBLM_OnLootMark( params )
	if params.unitId == WBLM_MOB_ID then
		local isDead = unit.IsDead( WBLM_MOB_ID )
		local isUsable = unit.IsUsable( WBLM_MOB_ID )
	
		WBLM_LOOT_MARKED = true
		if params.enabled == true then
			Log( "Dead mob available for loot", "WorldBot.LootMob" )
			StartPrivateTimer( 500, WBLM_LootingMob )
		else
			StopPrivateTimer()
			WBLM_NoLoot()
		end
	end
end
