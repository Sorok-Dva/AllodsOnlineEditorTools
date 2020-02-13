Global( "TEST_NAME", "loot statistics bot; author: Liventsev Andrey, date: 06.03.2009, task 59003" )

Global( "CUR_MOB_INDEX", nil )
Global( "COUNT_MOBS",    nil )
Global( "MOB_NAME",      nil )
Global( "MOB_RUS_NAME",  nil )
Global( "CUR_MOB_ID",    nil )
Global( "MONEY_NAME", "Items/Mechanics/Money.xdb" )

Global( "ITEM_TABLE",       nil )   -- таблица со статистикой выпадени€ итемов (веро€тность падени€, среднее количество)
Global( "ITEM_QUALITY_TABLE", nil ) -- таблица со статистикой выпадани€ итемов (качество, веро€тность) 
Global( "QUALITY_NAMES", {"COMMON", "UNCOMMON", "RARE", "EPIC"} )
Global( "MONEY_COUNT", nil )
Global( "MONEY_TOTAL_COUNT", nil )

Global( "INIVISIBILITY_SPELL", "Mechanics/Spells/Cheats/GreaterInvisibility/Spell.xdb" )
Global( "INIVISIBILITY_BUFF", "Mechanics/Spells/Cheats/GreaterInvisibility/Buff.xdb" )

Global( "JUNK_TAKED", nil )
Global( "COMMON_TAKED", nil )
Global( "UNCOMMON_TAKED", nil )
Global( "RARE_TAKED", nil )
Global( "EPIC_TAKED", nil )

Global( "OBJECT_USE_INDEX", nil )
Global( "BAG_OPENED",       nil )

function Log(text)
	common.LogInfo("common",text)
end

function Done()
	Log( "Done" )
	group.ChatWhisper( object.GetName( avatar.GetId() ), debugCommon.ToWString( "loot status: done" ) )

	Log( "-- lootbot: '" .. MOB_RUS_NAME .. "',  оличество мобов: " .. tostring( CUR_MOB_INDEX ) .. " " .. MOB_NAME )
	
	local str1 = PrintItemTable( ITEM_TABLE )
	local str2 = PrintItemQualityTable( ITEM_QUALITY_TABLE )
	local str3 = PrintMoneyInfo()
	debugCommon.SetClipboardText(str1..str2..str3)
	qaMission.AvatarSetScriptControl( false )
	common.UnRegisterEventHandler( "EVENT_LOOT_MARK" )
    common.UnRegisterEventHandler( "EVENT_LOOT_BAG_OPEN_STATE_CHANGED" )
	
	UnCastInvisibility()
end

function ErrorFunc( text )
	Log( "Error: " .. text )
	group.ChatWhisper( object.GetName( avatar.GetId() ), debugCommon.ToWString( "loot status: error" ) )
	
	Log( " оличество мобов: " .. tostring( COUNT_MOBS ))
	PrintItemTable( ITEM_TABLE )
	PrintItemQualityTable( ITEM_QUALITY_TABLE )
	PrintMoneyInfo()
	
	qaMission.AvatarSetScriptControl( false )
	common.UnRegisterEventHandler( "EVENT_LOOT_MARK" )
    common.UnRegisterEventHandler( "EVENT_LOOT_BAG_OPEN_STATE_CHANGED" )
	
	UnCastInvisibility()
end


function StartLootBot( mobName, mobCount )
	CUR_MOB_INDEX = 0
	COUNT_MOBS = mobCount
	MOB_NAME = mobName
	ITEM_TABLE = {}
	ITEM_QUALITY_TABLE = {}
	MONEY_COUNT = 0
	MONEY_TOTAL_COUNT = 0
	MOB_RUS_NAME = nil

	common.RegisterEventHandler( OnLootMark, "EVENT_LOOT_MARK" )
    common.RegisterEventHandler( OnLootBagOpenStateChanged, "EVENT_LOOT_BAG_OPEN_STATE_CHANGED" )
	
	LearnSpell( INIVISIBILITY_SPELL, CastInivisibility, ErrorFunc )
end

function CastInivisibility()
	if GetBuffInfo( avatar.GetId(), INIVISIBILITY_BUFF ) ~= nil then
		BeforeSummonNext()
		
	else
		local effects = {
			type = EFFECT_BUFF,
			unitId = avatar.GetId(),
			buffName = INIVISIBILITY_BUFF
		}
		Log( tostring( effects.type ) )
		CastSpell( GetSpellId( INIVISIBILITY_SPELL ), nil, 2000, BeforeSummonNext, ErrorFunc, {effects}, true )
	end	
end

function UnCastInvisibility()
	local count = unit.GetBuffCount( avatar.GetId() )
	local i=0
	for i=0, count-1 do
	    local buff = unit.GetBuff( avatar.GetId(), i )
	    if buff.debugName == INIVISIBILITY_BUFF or string.find( buff.debugName, INIVISIBILITY_BUFF ) then
	        avatar.RemoveBuff( i )
			return
	    end
	end
end

function BeforeSummonNext()
	StartTimer( 1000, SummonNext )
end

function SummonNext()
	if CUR_MOB_INDEX >= COUNT_MOBS then
		Done()

	else
		Log( "Summon next. " .. tostring( CUR_MOB_INDEX+1 ) .. "/" .. tostring( COUNT_MOBS ))
		local newPos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), 0.7 )
		SummonMob( MOB_NAME, debugMission.GetMap().debugName, newPos, 0, Kill, SummonError )
	end	
end

function SummonError()
	local newPos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), 0.7 )
	SummonMob( MOB_NAME, debugMission.GetMap().debugName, newPos, 0, Kill, SummonError )
end

function Kill( unitId )
	CUR_MOB_ID = unitId
	if MOB_RUS_NAME == nil then
		MOB_RUS_NAME = debugCommon.FromWString( object.GetName( unitId ))
	end
	
	local faction = unit.GetFaction( unitId )
	if not faction.isFriend then
		CUR_MOB_INDEX = CUR_MOB_INDEX + 1
		
		--- ждем событие 
		StartTimer( 5000, NoLootFunction )
		--KillMob( unitId, EmptyFunction, ErrorFunc )
		SelectTarget(unitId, KillOnSelect, ErrorFunc)
	else
		Log( "Mob " .. tostring( CUR_MOB_NAME ) .. " is friendly. Skip it." )
		
		DisintagrateMob( CUR_MOB_NAME )
		CUR_MOB_INDEX = CUR_MOB_INDEX + 1
		BeforeSummonNext()
	end
end

function KillOnSelect()
	qaMission.SendCustomMsg("kill")
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
			Log( "using object. id=" .. tostring( CUR_MOB_ID ))
			
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
		Log( "using object in " .. tostring( OBJECT_USE_INDEX+1 )  .. " time. id=" .. CUR_MOB_ID )
		StartTimer( 500, ObjectUse, CUR_MOB_ID )

		OBJECT_USE_INDEX = OBJECT_USE_INDEX + 1
	    StartTimer1( 3000, UseObject )
	end
end

function ObjectUse( objectId )
	object.Use( objectId, 1 )
end

function NoLootFunction()
	Log( "   no loot (" )
	SummonNext()
end




-- ƒобавл€ет итем в статистику падени€ лута (количество, шансы) или обновл€ет уже существ. информацию
function AddItemToItemTable( itemInfo )
	local itemName = itemInfo.debugInstanceFileName
	
	local item = ITEM_TABLE[ itemName ]
	if item == nil then
	    item = {
			name = itemInfo.name,
			debugName = itemInfo.debugInstanceFileName,
			count = 0,
			totalCount = 0
		}
	end

	item.count = item.count + 1
	item.totalCount = item.totalCount + itemInfo.stackCount
	
	ITEM_TABLE[ itemName ] = item
end

-- ƒобавл€ет итем в статистику падени€ лута (шанс, среднее кол-во) или обновл€ет уже существ. информацию
function AddItemToItemQualityTable( itemInfo )
	local item = ITEM_QUALITY_TABLE[ itemInfo.quality ]
	if item == nil then
		item = {
			quality = itemInfo.quality,
			count = 0,
			totalCount = 0
		}
	end
	
	if itemInfo.quality == ITEM_QUALITY_JUNK and JUNK_TAKED == false then
		JUNK_TAKED = true
		item.count = item.count + 1
		
	elseif itemInfo.quality == ITEM_QUALITY_COMMON and COMMON_TAKED == false then
		COMMON_TAKED = true
		item.count = item.count + 1

	elseif itemInfo.quality == ITEM_QUALITY_UNCOMMON and UNCOMMON_TAKED == false then
		UNCOMMON_TAKED = true
		item.count = item.count + 1

	elseif itemInfo.quality == ITEM_QUALITY_RARE and RARE_TAKED == false then
		RARE_TAKED = true
		item.count = item.count + 1

	elseif itemInfo.quality == ITEM_QUALITY_EPIC and EPIC_TAKED == false then
		EPIC_TAKED = true
		item.count = item.count + 1
	end

	item.totalCount = item.totalCount + itemInfo.stackCount
	
	ITEM_QUALITY_TABLE[ itemInfo.quality ] = item
end




function PrintItemTable( table )
	Log( "--        —татистика по количеству предметов:" )
	local str = "Statistics by quantity items\n"
	for index, item in table do
		
		Log( debugCommon.FromWString( item.name ) .. "   " .. item.debugName )
		str = str .. debugCommon.FromWString( item.name ) .. "   " .. item.debugName.."\n"
		local chance = 100 * item.count / COUNT_MOBS
		local lootCount = item.totalCount / item.count	
		Log( "chance: " .. tostring( chance ) .. "%  count:" .. tostring( lootCount ))
		str = str .. "chance: " .. tostring( chance ) .. "%  count:" .. tostring( lootCount ).."\n"
	end
	return str
end

function PrintItemQualityTable( table )

	Log( "--        —татистика по качеству предметов:" )
	local str = "Statistics by quality items\n"
	for index, item in table do
		if item.quality == ITEM_QUALITY_JUNK then
			Log( "junk:" )
			str = str .. "junk:" .."\n"
		elseif item.quality == ITEM_QUALITY_COMMON then
			Log( "common:" )
			str = str .. "common:" .."\n"
		elseif item.quality == ITEM_QUALITY_UNCOMMON then
			Log( "uncommon:" )
			str = str .. "uncommon:" .."\n"
		elseif item.quality == ITEM_QUALITY_RARE then
			Log( "rare:" )
			str = str .. "rare:" .."\n"
		elseif item.quality == ITEM_QUALITY_EPIC then
			Log( "epic:" )
			str = str .. "epic:" .."\n"
		end			
		
		local chance = 100 * item.count / COUNT_MOBS
		local lootCount = item.totalCount / item.count	
		Log( "chance: " .. tostring( chance ) .. "%  count:" .. tostring( lootCount ))
		str = str .. "chance: " .. tostring( chance ) .. "%  count:" .. tostring( lootCount ) .."\n"
	end
	return str
end

function PrintMoneyInfo()
	Log( "--        —татистика по количеству денег:" )
	local str = "Statistics by quantity money\n"
	local chance = 100 * MONEY_COUNT / COUNT_MOBS
	local lootCount = 0
	if MONEY_COUNT ~= 0 then
		lootCount = MONEY_TOTAL_COUNT / MONEY_COUNT
	end	
	Log( "chance: " .. tostring( chance ) .. "%  count:" .. tostring( lootCount ))
	str = str .. "chance: " .. tostring( chance ) .. "%  count:" .. tostring( lootCount ) .."\n"
	return str
end





----------------------------------------- EVENTS ----------------------------------------------

function OnChatMessage( params )
	local msg = debugCommon.FromWString( params.msg )
	if  string.sub( msg, 1, 7 ) == "lootbot" then
		group.ChatWhisper( object.GetName( avatar.GetId() ), debugCommon.ToWString( TEST_NAME ) )
		--StartTest( TEST_NAME )
		
		if avatar.GetTarget() ~= nil then
			group.ChatWhisper( object.GetName( avatar.GetId() ), debugCommon.ToWString( "loot status: starting (" ..  string.sub( msg, 8 ) .. ")..." ) )
			StartLootBot( qaMission.UnitGetXDB( avatar.GetTarget() ), tonumber( string.sub( msg, 8 )))
		else
			group.ChatWhisper( object.GetName( avatar.GetId() ), debugCommon.ToWString( "empty target" ) )		
		end
	end	
end

function OnLootMark( params )
	Log( "Mob killed, OnLootMark" )
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

		local count = 0
		local loot = avatar.GetLootBagSlots()
		local lootTable = loot.items

		JUNK_TAKED = false
		COMMON_TAKED = false
		UNCOMMON_TAKED = false
		RARE_TAKED = false
		EPIC_TAKED = false
		if lootTable ~= nil then
			for slot, itemId in lootTable do
				local itemInfo = avatar.GetItemInfo( itemId )
				
				Log( "    taking loot: " .. itemInfo.debugInstanceFileName .. " price=" .. tostring( itemInfo.sellPrice ) .. "  count=" .. tostring( itemInfo.stackCount ))
				AddItemToItemTable( itemInfo )
			    AddItemToItemQualityTable( itemInfo )
			end
			
			Log( "    taking money: " .. tostring( loot.money ) )
			if loot.money ~= 0 then
				MONEY_COUNT = MONEY_COUNT + 1
				MONEY_TOTAL_COUNT = MONEY_TOTAL_COUNT + loot.money
			end
		end

		qaMission.DisintegrateRespawnable( CUR_MOB_ID )
		BeforeSummonNext()
	end
end




function Init()
	common.LogInfo("common","Init LootStatisticsBot")
	common.RegisterEventHandler( OnChatMessage, "EVENT_CHAT_MESSAGE" )
end

Init()