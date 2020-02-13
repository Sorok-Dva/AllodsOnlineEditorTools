-- author: Liventsev Andrey, date: 01.04.2008
-- Библиотека для выполнения квестовой подзадачи типа "налутить девайсов"

Global( "WBLD_MOB_LIST",   nil )
Global( "WBLD_QUEST_NAME", nil )
Global( "WBLD_ITEM_NAME",  nil )
Global( "WBLD_PASS_FUNCTION",  nil )

Global( "WBLD_CUR_DEV_POS",   nil )
Global( "WBLD_CUR_DEV_NAME",  nil )
Global( "WBLD_DEV_TABLE", nil )

Global( "WBLD_CRITICAL_MAX_COUNT", 100 ) --  если не получится найти WBLD_CRITICAL_MAX_COUNT двайсов подряд - падаем с ошибкой
Global( "WBLD_CRITICAL_COUNT", nil )


-- Метод для сбора предметов с девайсов
-- Передается имя квеста и имя подзадачи (оно же - имя итема)
-- Если в течении WBQLM_CRITICAL_MAX_COUNT попыток счетчик подзадачи не поменялся, то выходим с ошибкой
function LootDevs( mobList, questName, itemName, passFunc )
	Log()
	Log()
    Log( "looting devices. item=" .. itemName, "WorldBot.LootDevs" )
	
	WBLD_MOB_LIST = mobList
	WBLD_QUEST_NAME = questName
	WBLD_ITEM_NAME = itemName

	WBLD_PASS_FUNCTION = passFunc

	WBLD_Start()
	
	WBLD_CRITICAL_COUNT = 0
	WBLD_DEV_TABLE = GetLootDeviceOwner( WBLD_MOB_LIST, WBLD_ITEM_NAME )
	
	if GetTableSize( WBLD_DEV_TABLE ) == 0 then
		Log( "Can't find loot owner(device) for item=" .. WBLD_ITEM_NAME .. "  quest=" .. WBLD_QUEST_NAME, "WorldBot.LootDevs" )
		local params = {
			text = "Can't find loot owner(device) for item=" .. WBLD_ITEM_NAME .. "  quest=" .. WBLD_QUEST_NAME,
			quest = WBLD_QUEST_NAME
		}
		WB_Warn( params )
		WBLD_Stop()
		CompleteQuestByCheat( WBLD_QUEST_NAME, WBLD_Pass )
		return
	end
	
	Log( "Count devices: " .. tostring( GetTableSize( WBLD_DEV_TABLE )), "WorldBot.LootDevs" )
	WBLD_LootNextDev()
end	

function WBLD_LootNextDev()
	StopTimer1()
	local objective = GetQuestObjective( WBLD_QUEST_NAME, WBLD_ITEM_NAME )
	local count = GetCountItem( WBLD_ITEM_NAME )
	
	Log()
	Log( "loot next device: " .. tostring( count ) .. "/" .. tostring( objective.required ), "WorldBot.LootDevs" )
	if count >= objective.required then
		WBLD_Pass()

	else
		if WBLD_CRITICAL_COUNT >= WBLD_CRITICAL_MAX_COUNT then	
			ErrorFunc( "Can't find device in " .. tostring(WBLD_CRITICAL_MAX_COUNT) .. " times" )

		else
			WBLD_CRITICAL_COUNT = WBLD_CRITICAL_COUNT + 1
			for index, devInfo in WBLD_DEV_TABLE do
				local id = GetDevId( ParseObjName( devInfo.name, OBJ_TYPE_CHEST_RESOURCE ))
				if id ~= nil then
					local pos = debugMission.InteractiveObjectGetPos( id )
					WBLD_CUR_DEV_POS = ToAbsCoord( pos )
					WBLD_CUR_DEV_NAME = ParseObjName( devInfo.name, OBJ_TYPE_CHEST_RESOURCE )

					Log( "move to device. pos: " .. PrintCoord(WBLD_CUR_DEV_POS), "WorldBot.LootDevs")
					MoveToPos( pos, WBLD_LootDevice )
					return
				end
			end	

			local devInfo = GetRandomTableElement( WBLD_DEV_TABLE )
			local position = GetRandomTableElement( devInfo.positions )
			local pos = {
				X = position.x,
				Y = position.y,
				Z = position.z
			}
			
			WBLD_CUR_DEV_POS = pos
			WBLD_CUR_DEV_NAME = ParseObjName( devInfo.name, OBJ_TYPE_CHEST_RESOURCE )
			Log( "move to device place. pos: " .. PrintCoord(WBLD_CUR_DEV_POS), "WorldBot.LootDevs")
			MoveToPos( pos, WBLD_LootNextDev )
		end
	end
end

function WBLD_LootDevice()
	local devId = GetDevId( WBLD_CUR_DEV_NAME, 1 )
	if devId == nil then
		local text = "Can't find device after teleport. name=" .. WBLD_CUR_DEV_NAME .. " pos: " .. PrintCoord(WBLD_CUR_DEV_POS)
		Log( text, "WorldBot.LootDevs" )
		local params = {
			text = text,
			quest = WBLD_QUEST_NAME
		}
		WB_Warn( params )
		WBLD_LootNextDev()
	else

		Log( "using device", "WorldBot.LoodDevs" )
		object.Use( devId, 10 )
		StartPrivateTimer( 10000, WBLD_LootNextDev )
	end	
end



function WBLD_Start()
	common.RegisterEventHandler( WBLD_OnLootBagOpenStateChanged, "EVENT_LOOT_BAG_OPEN_STATE_CHANGED" )
end

function WBLD_Stop()
	common.UnRegisterEventHandler( "EVENT_LOOT_BAG_OPEN_STATE_CHANGED" )
end

function WBLD_Pass()
	Log( "Done", "WorldBot.LootDevs" )
	WBLD_Stop()
	WBLD_PASS_FUNCTION()
end

--------------------------------------- EVENTS ---------------------------------


function WBLD_OnLootBagOpenStateChanged( params )
	if avatar.IsLootBagOpen() then
		local loot = avatar.GetLootBagSlots()
		local lootTable = loot.items
		if lootTable ~= nil then
			for slot, itemId in lootTable do
				local itemInfo = avatar.GetItemInfo( itemId )
				if itemInfo.debugInstanceFileName == WBLD_ITEM_NAME then
					WBLD_CRITICAL_COUNT = 0
				end
			end
			avatar.TakeAllLoot()
		end
		
		StartPrivateTimer( 1000, WBLD_LootNextDev )
	end	
end
