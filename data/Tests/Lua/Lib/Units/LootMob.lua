-- ф-ция для убийства моба с помощью заклинания Kill
-- Передается id живого моба
-- Для лута всех предметов вызывать LootMob
-- Для лута какого-то конкретного - LootMobTakeItem, при этом проверяется что в сумку попал нужный предмет

Global( "LM_PASS_FUNCTION",  nil )
Global( "LM_ERROR_FUNCTION", nil )
Global( "LM_MOB_ID", nil )
Global( "LM_ITEM_NAME", nil )
Global( "LM_TAKE_ALL", nil )

Global( "LM_IS_LOOTED", false )
Global( "LM_LOOT_MARKED", nil )

Global( "LM_FILTER", 10 )

function LootMob( mobId, passFunc, errorFunc )
	Log( "looting mob. id=" .. tostring( mobId ), "Units.LootMob" )
	
	LM_Start()
	
	LM_IS_LOOTED = false
	LM_TAKE_ALL = true
	LM_PASS_FUNCTION = passFunc
	LM_ERROR_FUNCTION = errorFunc
	LM_MOB_ID = mobId
	
	LM_LOOT_MARKED = false
	KillMob( mobId, LM_StartWaitingForLoot, LM_ERROR_FUNCTION )
end

function LootMobTakeItem( mobId, itemName, passFunc, errorFunc )
    LM_Start()
    
	LM_IS_LOOTED = false
	LM_TAKE_ALL = false
	LM_ITEM_NAME = itemName
	LM_PASS_FUNCTION = passFunc
	LM_ERROR_FUNCTION = errorFunc
	LM_MOB_ID = mobId
	
	LM_LOOT_MARKED = false
	KillMob( mobId, LM_StartWaitingForLoot, LM_ERROR_FUNCTION )
end

function LM_LootingMob()
	Log( "LM_LootingMob" )
	if unit.IsDead( LM_MOB_ID ) and unit.IsUsable( LM_MOB_ID ) then
		local pos = debugMission.InteractiveObjectGetPos( LM_MOB_ID )
		qaMission.AvatarSetPos( pos )
		Log( "before use" )
		StartPrivateTimer( 1000, LM_UseMob )
		
	else
		LM_ERROR_FUNCTION( "Can not loot mob - mob is not dead or mob is not usable" )
	end
end

function LM_UseMob()
	Log( "LM_UseMob. id=" .. tostring( LM_MOB_ID ), "Units.LootMob" )
	object.Use( LM_MOB_ID, LM_FILTER )
	StartPrivateCheckTimer( 15000, LM_CheckLoot, nil, LM_PassFunc, nil, LM_PassFunc, nil )
end

function LM_CheckLoot()
	return LM_IS_LOOTED
end

function LM_CheckChangedSlot( slot )
	if LM_TAKE_ALL == false then
		local itemId = avatar.GetInventoryItemId( slot )
		local itemInfo = avatar.GetItemInfo( itemId )
		if itemInfo.debugInstanceFileName == LM_ITEM_NAME then
			LM_IS_LOOTED = true
		end
	end
end

function LM_StartWaitingForLoot()
	if LM_LOOT_MARKED == false then
		StartPrivateTimer( 5000, LM_NoLoot )
	end	
end

function LM_NoLoot()
    Log( "Unit LootMob: no loot", "Units.LootMob" )
	if LM_TAKE_ALL == false then
		LM_ERROR_FUNCTION( "Mob does not have required item" )
	else
		LM_PassFunc()
	end
end

function LM_PassFunc()
	LM_Stop()
	LM_PASS_FUNCTION()
end

function LM_Start()
	common.RegisterEventHandler( LM_OnLootBagOpenStateChanged, "EVENT_LOOT_BAG_OPEN_STATE_CHANGED" )
	common.RegisterEventHandler( LM_OnInventoryItemAdded, "EVENT_INVENTORY_ITEM_ADDED" )
	common.RegisterEventHandler( LM_OnInventoryItemChanged, "EVENT_INVENTORY_ITEM_CHANGED" )
	common.RegisterEventHandler( LM_OnLootMark, "EVENT_LOOT_MARK" )
end

function LM_Stop()
	common.UnRegisterEventHandler( "EVENT_LOOT_BAG_OPEN_STATE_CHANGED" )
	common.UnRegisterEventHandler( "EVENT_INVENTORY_ITEM_ADDED" )
	common.UnRegisterEventHandler( "EVENT_INVENTORY_ITEM_CHANGED" )
	common.UnRegisterEventHandler( "EVENT_LOOT_MARK" )
end

---------------------------- EVENTS ----------------------------------------------

function LM_OnLootBagOpenStateChanged( params )
	Log( "Loot bag open state changed" )
	if avatar.IsLootBagOpen() then
		if LM_TAKE_ALL == true then
			avatar.TakeAllLoot()
			LM_IS_LOOTED = true

		else
			local count = 0
			local loot = avatar.GetLootBagSlots()
			local lootTable = loot.items

			if lootTable ~= nil then
				for slot, itemId in lootTable do
					local itemInfo = avatar.GetItemInfo( itemId )
					local name = itemInfo.debugInstanceFileName
					Log( "name=" .. tostring(name) )
					if name == LM_ITEM_NAME then
						avatar.TakeLoot( slot )
						count = count + 1
					end
				end
			end

			if count == 0 then
				LM_ERROR_FUNCTION( "Mob does not have required item" )
			end
		end	
	end
end

function LM_OnInventoryItemAdded( params )
	LM_CheckChangedSlot( params.slot )
end

function LM_OnInventoryItemChanged( params )
	LM_CheckChangedSlot( params.slot )
end

function LM_OnLootMark( params )
	Log( "LM_Loot_Mark", "Units.LootMob" )
	if params.unitId == LM_MOB_ID then
		LM_LOOT_MARKED = true
		StopPrivateTimer()
		if params.enabled == true then
			Log( "Dead mob available for loot", "Units.LootMob" )
			StartPrivateTimer( 500, LM_LootingMob )
		end
	end
end
