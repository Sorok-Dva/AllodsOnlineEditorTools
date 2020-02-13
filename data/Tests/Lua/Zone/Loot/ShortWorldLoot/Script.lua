Global( "TEST_NAME", "SmokeTest.ShortLootMobs; author: Liventsev Andrey, date: 02.09.08" )

Global( "MOB_LIST", nil )

Global( "MAP_RESOURCE", "/Tests/Maps/Lua/MapResource.xdb" )
Global( "ZONE_NAME", nil )
Global( "CUR_MOB_NAME", nil )
Global( "CUR_MOB_ID", nil )


Global( "CUR_MOB_INDEX", nil ) -- индекс текущего моба в списке мобов
Global( "CUR_MOB_COUNT", nil ) -- количество уже убитых мобов
Global( "COUNT_MOB_FOR_KILL", nil ) -- сколько мобов нужно убить для теста

Global( "OBJECT_USE_INDEX", nil ) -- сколько раз пытается делать лут

Global( "ITEM_TABLE", nil ) -- таблица моб-итемы со статистикой выпадения предметов (количество, вероятность)
Global( "ITEM_QUALITY_TABLE", nil ) -- таблица моб-итемы со статисткой выпадания итемов (качество, вероятность) и денег
Global( "QUALITY_NAMES", {"COMMON", "UNCOMMON", "RARE", "EPIC"} )
Global( "ITEM_QUALITY_MONEY", 10 )
Global( "MONEY_NAME", "Items/Mechanics/Money.xdb" )


Global( "MOB_TABLE", nil )
Global( "MAX_COUNT_MOB", 3 )
Global( "BAG_OPENED", nil )


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
	
	local done = true
	if CUR_MOB_COUNT >= COUNT_MOB_FOR_KILL then
		CUR_MOB_INDEX = CUR_MOB_INDEX + 1
		CUR_MOB_COUNT = 0
		DestroyAllItems()
		BeforeSummonNext()

	elseif CUR_MOB_INDEX <= MAX_COUNT_MOB and CUR_MOB_INDEX <= GetTableSize( MOB_TABLE ) then
		CUR_MOB_NAME = ParseObjName( MOB_TABLE[ CUR_MOB_INDEX ].name, OBJ_TYPE_MOB_WORLD ) 
		Log( "summoning mob. name=" .. tostring( CUR_MOB_NAME ))
		local newPos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), 1 )
		SummonMob( CUR_MOB_NAME, MAP_RESOURCE, newPos, 0, Kill, ErrorFunc )
		done = false
		Log( "break" )	
		
	else
		Log( "Done" )
	    PrintItemTable( ITEM_TABLE )
	    PrintItemQualityTable( ITEM_QUALITY_TABLE )
		Log( "" )
		Log( "" )
	    StartTimer( 1000, Done )
	end
end


function Kill( unitId )
	CUR_MOB_ID = unitId
	
	local faction = unit.GetFaction( unitId )
	local faction = unit.GetFaction( unitId )
	if not faction.isFriend then
		CUR_MOB_COUNT = CUR_MOB_COUNT + 1
		
		StartTimer( 10000, NoLootFunction )
		KillMob( unitId, Nothing, ErrorFunc )
	else
		Log( "Mob " .. tostring( CUR_MOB_NAME ) .. " is friendly. Skip it." )
		
		DisintagrateMob( CUR_MOB_NAME )
		CUR_MOB_INDEX = CUR_MOB_INDEX + 1
		BeforeSummonNext()
	end
end

function NoLootFunction()
	Log( "   no loot (" )
	AddMobToItemTable( CUR_MOB_NAME )
	SummonNext()
end

function SelectingTarget()
	Log( "mob killed, selecting for loot" )
	SelectTarget( CUR_MOB_ID, BeforeOpenBag, ErrorFunc )
end

function BeforeOpenBag()
	StartTimer( 500, OpenBag )
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

function PrintItemTable( table )
	Log( "--" )
	Log( "--" )
	Log( "--" )
	Log( "--        Количество мобов каждого типа:" .. tostring( COUNT_MOB_FOR_KILL ))
	Log( "--" )
	Log( "--" )
	Log( "--        Статистика по количеству предметов:" )

	for index, mob in table do
		Log( "--" )
	    Log( "-- " .. debugCommon.FromWString( mob.title ) .. "   " .. tostring( mob.name ) )
	    for index1, item in mob.items do
			local chance = 100 * item.count / COUNT_MOB_FOR_KILL
			local lootCount = item.totalCount / item.count
	        Log( "--   шанс выпадения=" .. tostring( chance ) .. "%  |   среднее уколичество лута=" .. tostring( lootCount ) .. "  | " .. item.name )
	    end
	end
end

function PrintItemQualityTable( table )
	Log( "--" )
	Log( "--" )
	Log( "--" )
	Log( "--" )
	Log( "--       Статистика по качеству предметов" )
	Log( "--" )

	for index, mob in table do
	    Log( "--" )
	    Log( "-- " .. debugCommon.FromWString( mob.title ) .. "   " .. tostring( mob.name ) )
	    for index1, item in mob.items do
			if item.quality == ITEM_QUALITY_MONEY then
			    Log( "--   MONEY: среднее кол-во: " .. tostring( item.count / COUNT_MOB_FOR_KILL ) )
			elseif item.quality == ITEM_QUALITY_JUNK then
			    Log( "--   JUNK: средняя стоимость лута: " .. tostring( item.price / COUNT_MOB_FOR_KILL ) )
			else
				local chance = 100 * item.count / COUNT_MOB_FOR_KILL
				local lootCount = item.totalCount / item.count
			    Log( "--   " .. QUALITY_NAMES[ item.quality ] .. ": шанс выпадения=" .. tostring( chance ) .. "%    среднее количество лута=" .. tostring( lootCount ))
			end
	    end
	end
end

-- Добавляет моба в статистику мобов. Используется если моб не дает лута, а вывести в статистку надо
function AddMobToItemTable( mobName )
	local mobInfo = ITEM_TABLE[ mobName ]
	if mobInfo == nil then
		mobInfo = {
		    name = mobName,
		    title = unit.GetName( CUR_MOB_ID ),
		    items = {}
		}
		ITEM_TABLE[ mobName ] = mobInfo
	end
end

-- Добавляет итем в статистику падения лута (количество, шансы) или обновляет уже существ. информацию
function AddItemToItemTable( mobName, itemInfo )
	local itemName = itemInfo.debugInstanceFileName
	local mobInfo = ITEM_TABLE[ mobName ]
	if mobInfo == nil then
		mobInfo = {
		    name = mobName,
		    title = unit.GetName( CUR_MOB_ID ),
		    items = {}
		}
	end
	
	local item = mobInfo.items[ itemName ]
	if item == nil then
	    item = {
			name = itemInfo.debugInstanceFileName,
			count = 0,
			totalCount = 0
		}
	end
	
	item.count = item.count + 1
	item.totalCount = item.totalCount + itemInfo.stackCount
	
	mobInfo.items[ itemName ] = item
	ITEM_TABLE[ mobName ] = mobInfo
end

-- Добавляет итем в статистику падения лута (качество, шансы, стоимость) или обновляет уже существ. информацию
function AddItemToItemQualityTable( mobName, itemInfo )
	local mobInfo = ITEM_QUALITY_TABLE[ mobName ]
	if mobInfo == nil then
		mobInfo = {
		    name = mobName,
		    title = unit.GetName( CUR_MOB_ID ),
			items = {}
		}
	end

	local item = mobInfo.items[ itemInfo.quality ]
	if itemInfo.quality == ITEM_QUALITY_JUNK then
		if item == nil then
		    item = {
		        quality = itemInfo.quality,
				price = 0
			}
		end

		item.price = item.price + itemInfo.sellPrice

	else
		if item == nil then
		    item = {
		        quality = itemInfo.quality,
				count = 0,
				totalCount = 0
			}
		end

		item.count = item.count + 1
		item.totalCount = item.totalCount + itemInfo.stackCount
	end
	
	mobInfo.items[ itemInfo.quality ] = item
	ITEM_QUALITY_TABLE[ mobName ] = mobInfo
end

-- Добавляет деньги в статистику падения лута или обновляет уже существ. информацию
function AddMoneyToItemQualityTable( mobName, money )
	local mobInfo = ITEM_QUALITY_TABLE[ mobName ]
	if mobInfo == nil then
		mobInfo = {
		    name = mobName,
		    title = unit.GetName( CUR_MOB_ID ),
			items = {}
		}
	end

	local moneyInfo = mobInfo.items[ ITEM_QUALITY_MONEY ]
	if moneyInfo == nil then
	    moneyInfo = {
	        quality = ITEM_QUALITY_MONEY,
	        count = 0
	    }
	end
	
	moneyInfo.count = moneyInfo.count + money
	
	mobInfo.items[ ITEM_QUALITY_MONEY ] = moneyInfo
	ITEM_QUALITY_TABLE[ mobName ] = mobInfo
end




function Done()
	DisintagrateMob( CUR_MOB_NAME )
	Success( TEST_NAME )
end

function ErrorFunc( text )
	PrintItemTable( ITEM_TABLE )
	PrintItemQualityTable( ITEM_QUALITY_TABLE )
	
	DisintagrateMob( CUR_MOB_NAME )
	StartTimer( 1000, ExitScript, text )
end

function ExitScript( text )
	Warn( TEST_NAME, text )
end

function Nothing()
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

--------------------------------------- EVENTS --------------------------------------------

function OnAvatarCreated()
	StartTest( TEST_NAME )
	Log( "avatar created" )
	
	CUR_MOB_INDEX = 1
	CUR_MOB_COUNT = 0
	
	ITEM_TABLE = {}
	ITEM_QUALITY_TABLE = {}

	DestroyAllItems()
	
	MOB_TABLE = GetMobsByZone( ZONE_NAME )
	Log( "count mobs: " .. tostring( GetTableSize( MOB_TABLE )))

	ImmuneAvatar( BeforeSummonNext, ErrorFunc )
end

function OnLootMark( params )
	Log( "Mob killed, LootMark" )
	if params.unitId == CUR_MOB_ID then
	    if params.enabled == true then
	        Log( "loot droped" )
	        StartTimer( 1000, SelectingTarget )
	        
	    else
	        Log( "no more loot" )
	    end
	end
end

function OnLootBagOpenStateChanged( params )
	if not BAG_OPENED then
		Log( "bag opened:" )
		BAG_OPENED = true
		StopTimer1()

		local count = 0
		local loot = avatar.GetLootBagSlots()
		local lootTable = loot.items

		if lootTable ~= nil then
			for slot, itemId in lootTable do
				local itemInfo = avatar.GetItemInfo( itemId )
				
				Log( "    taking loot: " .. itemInfo.debugInstanceFileName .. " price=" .. tostring( itemInfo.sellPrice ) .. "  count=" .. tostring( itemInfo.stackCount ))
				AddItemToItemTable( CUR_MOB_NAME, itemInfo )
				if itemInfo.debugInstanceFileName == MONEY_NAME then
				    AddMoneyToItemQualityTable( CUR_MOB_NAME, itemInfo.stackCount )
				else
				    AddItemToItemQualityTable( CUR_MOB_NAME, itemInfo )
				end

				avatar.TakeLoot( slot )
			end
			Log( "    taking money: " .. tostring( loot.money ) )
			AddMoneyToItemQualityTable( CUR_MOB_NAME, loot.money )

			avatar.TakeLootMoney()
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