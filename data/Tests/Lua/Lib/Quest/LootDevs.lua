qaMission.AvatarSetPos-- author: Liventsev Andrey, date: 16.09.2008, bug#34555
-- Библиотека для выполнения квестов типа налутить предметов
-- Все что требуется - вызвать метод LootDevs с параметрами. После лута нужных предметов вызовется ф-ция passFunc

Global( "LD_MOB_LIST",        nil )
Global( "LD_ITEM_NAME",       nil )
Global( "LD_ITEM_COUNT",      nil )

Global( "LD_PASS_FUNCTION",   nil )
Global( "LD_ERROR_FUNCTION",  nil )

Global( "LD_CRITICAL_MAX_COUNT", 100 ) --  если не получится найти LD_CRITICAL_MAX_COUNT двайсов подряд - падаем с ошибкой
Global( "LD_CRITICAL_COUNT", nil )

Global( "LD_DEV_POS",   nil )
Global( "LD_DEV_NAME",  nil )
Global( "LD_DEV_TABLE", nil )


-- Метод для лута нужного количества предметов. После выполнения вызывается метод functionName
-- В любом случае если квест состоит только из лута, приходит событие EVENT_QUEST_UPDATED
function LootDevs( mobList, itemName, itemCount, passFunc, errorFunc )
	Log( "" )
	Log( "" )
	Log( "" )
    Log( "looting devices. item=" .. itemName, "Quests.LootDevs" )
	
	LD_MOB_LIST = mobList
	LD_ITEM_NAME = itemName
	LD_ITEM_COUNT = itemCount
	
	LD_PASS_FUNCTION = passFunc
	LD_ERROR_FUNCTION = errorFunc

	LDStart()
	
	LD_CRITICAL_COUNT = 0
	LD_DEV_TABLE = GetLootDeviceOwner( LD_MOB_LIST, LD_ITEM_NAME )
	Log( "count devices: " .. tostring( GetTableSize( LD_DEV_TABLE )), "Quests.LootDevs" )
	if GetTableSize( LD_DEV_TABLE ) == 0 then
		LD_ERROR_FUNCTION( "Can't find loot owner for item=" .. LD_ITEM_NAME )
	end	
	
	LD_LootNextDev()
end

function LD_LootNextDev()
	local count = GetCountItem( LD_ITEM_NAME )
	
	Log( "" )
	Log( "loot next device: " .. tostring( count ) .. "/" .. tostring( LD_ITEM_COUNT ), "Quests.LootDevs" )
	if count >= LD_ITEM_COUNT then
		LDStop()
		LD_PASS_FUNCTION()
	else
		if LD_CRITICAL_COUNT >= LD_CRITICAL_MAX_COUNT then	
			ErrorFunc( "Can't find device in " .. tostring(LD_CRITICAL_MAX_COUNT) .. " times" )

		else
			for index, devInfo in LD_DEV_TABLE do
				local id = GetDevId( ParseObjName( devInfo.name, OBJ_TYPE_CHEST_RESOURCE ))
				if id ~= nil then
					LD_DEV_NAME = ParseObjName( devInfo.name, OBJ_TYPE_CHEST_RESOURCE )
					local pos = debugMission.InteractiveObjectGetPos( id )
					LD_DEV_POS = ToAbsCoord( pos )

					Log( "move to device:  x=" .. tostring( LD_DEV_POS.X ) .. "  y=" .. tostring( LD_DEV_POS.Y ) .. " z=" .. tostring( LD_DEV_POS.Z ), "Quests.LootDevs" )
					( pos )
					StartPrivateTimer( 3000, LD_LootDevice, id )
					return
				end
			end	

			local devInfo = GetRandomTableElement( LD_DEV_TABLE )
			local position = GetRandomTableElement( devInfo.positions )
			local pos = {
				X = position.x,
				Y = position.y,
				Z = position.z
			}
			LD_CRITICAL_COUNT = LD_CRITICAL_COUNT + 1
			LD_DEV_POS = pos
			Log( "move to spawn place:   x=" .. tostring(pos.X) .. " y=" .. tostring( pos.Y ) .. " z=" .. tostring( pos.Z ), "Quests.LootDevs" )
			LD_DEV_NAME = ParseObjName( devInfo.name, OBJ_TYPE_CHEST_RESOURCE )
			
			qaMission.AvatarSetPos( ToStandartCoord( pos ))
			StartPrivateTimer( 3000, LD_LootNextDev )
		end
	end
end

function LD_LootDevice( devId )
	if GetDevId( LD_DEV_NAME ) == nil then
		LD_ERROR_FUNCTION( "Can't find device after teleport. name=" .. LD_DEV_NAME .. " pos: x=" .. tostring(LD_DEV_POS.X) .. " y=" .. tostring( LD_DEV_POS.Y ) .. " z=" .. tostring( LD_DEV_POS.Z ))
	else
		object.Use( devId, 10 )
		StartPrivateTimer( 10000, LD_LootNextDev )
	end	
end


function LDStart()
	common.RegisterEventHandler( LD_OnLootBagOpenStateChanged, "EVENT_LOOT_BAG_OPEN_STATE_CHANGED" )
	common.RegisterEventHandler( LD_OnUnitDeadChanged, "EVENT_UNIT_DEAD_CHANGED" )
	
end

function LDStop()
	common.UnRegisterEventHandler( "EVENT_LOOT_BAG_OPEN_STATE_CHANGED" )
	common.UnRegisterEventHandler( "EVENT_UNIT_DEAD_CHANGED" )
end

--------------------------------------- EVENTS ---------------------------------


function LD_OnLootBagOpenStateChanged( params )
	if avatar.IsLootBagOpen() then
		local loot = avatar.GetLootBagSlots()
		local lootTable = loot.items
		if lootTable ~= nil then
			for slot, itemId in lootTable do
				local itemInfo = avatar.GetItemInfo( itemId )
				Log( itemInfo.debugInstanceFileName .. "   ==  " .. LD_ITEM_NAME )
				if itemInfo.debugInstanceFileName == LD_ITEM_NAME then
					Log( "loot item " .. itemInfo.debugInstanceFileName .. " count=" .. tostring( itemInfo.stackCount ), "Quests.LootDevs" )
					LD_CRITICAL_COUNT = 0
				end
			end
			avatar.TakeAllLoot()
		end
		
		StartPrivateTimer( 1000, LD_LootNextDev )
	end	
end

function LD_OnUnitDeadChanged( params )
	if params.unitId == avatar.GetId() then
		LD_ERROR_FUNCTION( "Avatar dead after teleport to device. name= " .. LD_DEV_NAME .. " pos: x=" .. tostring(LD_DEV_POS.X) .. " y=" .. tostring( LD_DEV_POS.Y ) .. " z=" .. tostring( LD_DEV_POS.Z ))
	end
end
