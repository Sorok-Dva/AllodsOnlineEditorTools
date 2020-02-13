Global( "TEST_NAME", "SmokeTest.ShortLootSilverMobs; author: Liventsev Andrey, date: 02.09.08, task 34588" )

Global( "MOB_LIST", nil )

Global( "MAP_RESOURCE", "/Tests/Maps/Lua/MapResource.xdb" )
Global( "ZONE_NAME", nil )
Global( "CUR_MOB_NAME", nil )
Global( "CUR_MOB_ID", nil )

Global( "CUR_MOB_INDEX", nil ) -- индекс текущего моба в списке мобов
Global( "CUR_MOB_COUNT", nil ) -- количество уже убитых мобов
Global( "COUNT_MOB_FOR_KILL", nil ) -- сколько мобов нужно убить для теста
Global( "CUR_MOB_COUNT_ITEM", nil ) -- из скольких мобов выпал зеленый лут
Global( "CUR_MOB_TOTAL_COUNT_ITEM", nil ) -- количество выпавшего зеленого лута

Global( "MOBS_TABLE", nil )
Global( "MOBS_TABLE_INDEX", nil )
Global( "OBJECT_USE_INDEX", nil ) -- сколько раз пытается делать лут

Global( "MOB_TABLE", nil )
Global( "BAG_OPENED", nil )

Global( "MAX_COUNT_MOB", 3 )
Global( "SILVER_COUNT_MOB", nil )

function DestroyAllItems()
	local count = 0
	for index = 0, avatar.GetInventorySize()-1 do
	    if avatar.GetInventoryItemId( index ) ~= nil then
			count = count + 1
	        avatar.InventoryDestroyItem( index )
	    end
	end
	Log( "destroyed " .. tostring(count) .. " items from inventory. " )
end

function BeforeSummonNext()
	StartTimer( 1000, SummonNext )
end

function SummonNext()
	Log( "" )
	Log( "Summon next. index=" .. tostring( CUR_MOB_INDEX ) .. "      " .. tostring(CUR_MOB_COUNT+1) .. "/" .. tostring(COUNT_MOB_FOR_KILL))

	if CUR_MOB_COUNT >= COUNT_MOB_FOR_KILL then
		CUR_MOB_INDEX = CUR_MOB_INDEX + 1
		SILVER_COUNT_MOB = SILVER_COUNT_MOB + 1
		CUR_MOB_COUNT = 0
		
		Log( "--------------" )
		Log( "insert to table. name=" .. tostring(CUR_MOB_NAME) .. " count=" .. tostring( CUR_MOB_COUNT_ITEM ) )
		Log( "--------------" )
		local tmp = {
			name = CUR_MOB_NAME,
			count = CUR_MOB_COUNT_ITEM,
			totalCount = CUR_MOB_TOTAL_COUNT_ITEM
		}
		MOBS_TABLE[ MOBS_TABLE_INDEX ] = tmp
		
		MOBS_TABLE_INDEX = MOBS_TABLE_INDEX + 1
		CUR_MOB_COUNT_ITEM = 0
		CUR_MOB_TOTAL_COUNT_ITEM = 0
		
		DestroyAllItems()
		BeforeSummonNext()

	elseif SILVER_COUNT_MOB <= MAX_COUNT_MOB and CUR_MOB_INDEX <= GetTableSize( MOB_TABLE ) then
		CUR_MOB_NAME = ParseObjName( MOB_TABLE[ CUR_MOB_INDEX ].name, OBJ_TYPE_MOB_WORLD ) 
		Log( "summoning mob. name=" .. tostring( CUR_MOB_NAME ))
		local newPos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), 1 )
		SummonMob( CUR_MOB_NAME, MAP_RESOURCE, newPos, 0, Kill, ErrorFunc )

	else
		Log( "Done" )
		PrintResults()
		Log( "" )
		Log( "" )
	    StartTimer( 1000, Done )
	end	
end

function Kill( unitId )
	CUR_MOB_ID = unitId
	
	local faction = unit.GetFaction( unitId )
	local quality = unit.GetQuality( unitId )

	if quality == UNIT_QUALITY_FLAVOR_ELITE and faction.isFriend == false then
	    Log( "------------ silver!!! id=" .. tostring( unitId ))
		CUR_MOB_COUNT = CUR_MOB_COUNT + 1
		StartTimer( 5000, NoLootFunction )
		KillMob( unitId, EmptyFunction, ErrorFunc )
		
	else
		Log( "not silver or friend" )
		DisintagrateMob( CUR_MOB_NAME )
		CUR_MOB_INDEX = CUR_MOB_INDEX + 1
		BeforeSummonNext()
	end
end

function NoLootFunction()
	Log( "   no loot (" )
	SummonNext()
end

function SelectingTarget()
	Log( "silver mob killed, selecting for looting" )
	SelectTarget( CUR_MOB_ID, BeforeOpenBag, ErrorFunc )
end

function BeforeOpenBag()
	StartTimer( 2000, OpenBag )
end

function OpenBag()
    Log( "mob selected" )
	if unit.IsDead( CUR_MOB_ID ) then
		if unit.IsUsable( CUR_MOB_ID ) then
			Log( "using object. id=" .. tostring(CUR_MOB_ID) )
			
	        BAG_OPENED = false
	        OBJECT_USE_INDEX = 0
			UseObject()
		end
	end
end

function UseObject()
	if OBJECT_USE_INDEX > 10 then
		Log( "no loot (" )
		StopTimer()
		BeforeSummonNext()
	else
		Log( "using object in " .. tostring( OBJECT_USE_INDEX+1 )  .. " time id=" .. CUR_MOB_ID )
		StartTimer( 1000, ObjectUse, CUR_MOB_ID )

		OBJECT_USE_INDEX = OBJECT_USE_INDEX + 1
	    StartTimer1( 3000, UseObject )
	end
end

function ObjectUse( objectId )
	object.Use( objectId, 1 )
end

function PrintResults()
	Log( "" )
	Log( "" )
	Log( "" )
	Log( "Количество мобов каждого типа:" .. tostring( COUNT_MOB_FOR_KILL ))
	Log( "" )
	Log( "     --- количество лута качества выше среднего: --- ")
	for index, mob in MOBS_TABLE do
		local chance = 100 * mob.count / COUNT_MOB_FOR_KILL
		local lootCount =0
		if mob.count ~= 0 then
			lootCount = mob.totalCount/mob.count
		end
	    Log( "шанс выпадения=" .. tostring(chance) .. "% среднее количество=" .. tostring(lootCount) .. " name=" .. mob.name )
	end
	Log( "" )
	Log( "" )
	Log( "" )
	Log( "" )
end

function GetMobsByZone( zone )
	local result = {}
	for index, mob in MOB_LIST do
		if ParseObjName( mob.name, OBJ_TYPE_MOB_WORLD ) ~= nil then
			if ParseObjName( mob.zone, OBJ_TYPE_ZONE ) == zone then
				table.insert( result, mob )
			end
		end
	end
	
	return result
end

function Done()
	DisintagrateMob( CUR_MOB_NAME )
	Success( TEST_NAME )
end

function ErrorFunc( text )
	PrintResults()
	DisintagrateMob( CUR_MOB_NAME )
	Warn( TEST_NAME, text )
end




--------------------------------------- EVENTS --------------------------------------------

function OnAvatarCreated()
	StartTest( TEST_NAME )
	
	CUR_MOB_INDEX = 1
	SILVER_COUNT_MOB = 1
	CUR_MOB_COUNT = 0
	
	MOBS_TABLE = {}
	MOBS_TABLE_INDEX = 1
	CUR_MOB_COUNT_ITEM = 0
	CUR_MOB_TOTAL_COUNT_ITEM = 0

	MOB_TABLE = GetMobsByZone( ZONE_NAME )
	Log( "count mobs: " .. tostring( GetTableSize( MOB_TABLE )))

    ImmuneAvatar( BeforeSummonNext, ErrorFunc )
end

function OnLootMark( params )
	Log( "Mob killed, LootMark" )
	if params.unitId == CUR_MOB_ID then
	    if params.enabled == true then
	        Log( "loot droped" )
	        StartTimer( 500, SelectingTarget )
	        
	    else
	        Log( "no more loot" )
	    end
	end
end

function OnLootBagOpenStateChanged( params )
	if BAG_OPENED == false then
		Log( "bag opened:" )
		BAG_OPENED = true
		StopTimer1()

		local hasSilverItem = false
		local count = 0
		local loot = avatar.GetLootBagSlots()
		local lootTable = loot.items

		if lootTable ~= nil then
			for slot, itemId in lootTable do
				local itemInfo = avatar.GetItemInfo( itemId )
				if itemInfo.quality == ITEM_QUALITY_UNCOMMON or itemInfo.quality == ITEM_QUALITY_EPIC then
				    hasSilverItem = true
				    CUR_MOB_TOTAL_COUNT_ITEM = CUR_MOB_TOTAL_COUNT_ITEM + 1
				    Log( "   silver loot. name=" .. tostring( itemInfo.debugInstanceFileName ) )
				else
				    Log( "   not silver loot. name=" .. tostring( itemInfo.debugInstanceFileName ) )
				end
				avatar.TakeLoot( slot )
			end
			avatar.TakeLootMoney()
		end
		
		if hasSilverItem == true then
			CUR_MOB_COUNT_ITEM = CUR_MOB_COUNT_ITEM + 1
		end

		BeforeSummonNext()
	end
end

function Init()
	local login = {
		login = developerAddon.GetParam( "login"),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" )
	}
	InitLoging(login)
	
	MOB_LIST = developerAddon.LoadMobList()
	if MOB_LIST == nil or GetTableSize( MOB_LIST ) == 0 then
		Warn( TEST_NAME, "mob list is empty" )
	end	
		
	ZONE_NAME = developerAddon.GetParam( "zoneName" )
    COUNT_MOB_FOR_KILL = tonumber(developerAddon.GetParam( "mobCount" ))
    
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
	common.RegisterEventHandler( OnLootMark, "EVENT_LOOT_MARK" )
    common.RegisterEventHandler( OnLootBagOpenStateChanged, "EVENT_LOOT_BAG_OPEN_STATE_CHANGED" )
end

Init()