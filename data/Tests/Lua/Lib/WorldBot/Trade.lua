-- author: Liventsev Andrey, date: 02.04.2009, task#52335
-- Библиотека для торговли бота

Global( "WBT_MOB_LIST", nil )

Global( "WBT_PASS_FUNC", nil )
Global( "WBT_ERROR_FUNC", nil )

Global( "WBT_VENDOR_NAME", nil )
Global( "WBT_NPC_LIST", nil )
Global( "WBT_NPC_INDEX", nil )
Global( "WBT_ZONE", nil )

Global( "WBT_INVISIBILITY_CHEAT_SPELL", "Mechanics/Spells/Cheats/GreaterInvisibility/Spell.xdb" )
Global( "WBT_INVISIBILITY_CHEAT_BUFF",  "Mechanics/Spells/Cheats/GreaterInvisibility/Buff.xdb" )



function CheckBag( mobList, zone, passFunc, errorFunc )
	WBT_MOB_LIST = mobList
	WBT_ZONE = zone
	WBT_PASS_FUNC = passFunc
	WBT_ERROR_FUNC = errorFunc
	
	local items = avatar.GetInventoryItemIds()
	local countItems = GetTableSize( items )
	local notQuestItems = 0
	Log()
	Log( "bag status: " .. tostring( countItems ) .. "/" .. tostring( avatar.GetInventorySize()), "WorldBot.Trade" ) 
	Log()
	if countItems/avatar.GetInventorySize() >= 0.1 then
		for index, itemId in items do
			if itemId ~= nil then
				local item = avatar.GetItemInfo( itemId )
--				Log( "name=" .. FromWString( item.name ) .. " debugName=" .. item.debugInstanceFileName  .. "  dressSlot = " .. tostring( item.dressSlot ), "WorldBot.Trade" )
				if item.dressSlot ~= nil and avatar.GetItemDressConditions( itemId ).sysFirstCondition == "ENUM_DressResult_Success" then
					local equipedItem = GetEquipItemByDressSlot( item.dressSlot )
					if equipedItem == nil or ( equipedItem ~= nil and CompareItems( equipedItem, item  ) == -1 ) then -- если на персе нет шмотки такого типа или шмотка хуже, чем новая
						if equipedItem ~= nil then
							notQuestItems = notQuestItems + 1
						end
--						Log( "-- equip item", "WorldBot.Trade" )
						avatar.EquipItem( GetItemSlot( item.debugInstanceFileName ))
					end
				elseif item.isQuestRelated ~= true then
					notQuestItems = notQuestItems + 1
				end	
			end
		end
	end

	local countItems = GetTableSize( items )
	if notQuestItems > 5 then
		if false then
			if WBT_VENDOR_NAME ~= nil then
				Log( "get mob coord: " .. WBT_VENDOR_NAME )
				local coord = GetMobCoords( WBT_MOB_LIST, WBT_VENDOR_NAME )
				Log( "coord=" .. tostring(coord) .. "  t=" .. GetTableSize( coord ))
				WBT_MoveToVendor( coord[1] )
				
			else
				Log( "Start searching vendor", "WorldBot.Trade" )
				WBT_NPC_LIST = GetMobsByZone( WBT_ZONE, WBT_MOB_LIST )
				WBT_NPC_INDEX = 0
				
				if GetBuffInfo( avatar.GetId(), WBT_INVISIBILITY_CHEAT_BUFF ) == nil then
					LearnSpell( WBT_INVISIBILITY_CHEAT_SPELL, WBT_CastInvis, WBT_ERROR_FUNC )
				else
					WBT_CheckForVendor()
				end		
			end	
		else
			Log( "Destroy all items", "WorldBot.Trade" )
			for index, iId in avatar.GetInventoryItemIds() do
				local slot = avatar.GetInventoryItemSlot( iId )
				avatar.InventoryDestroyItem( slot )
			end
			WBT_PASS_FUNC()
		end		
	else
		WBT_PASS_FUNC()
	end
end

function WBT_CastInvis()
	CastSpellToTarget( avatar.GetId(), GetSpellId(WBT_INVISIBILITY_CHEAT_SPELL), nil, 2000, WBT_CheckForVendor, WBT_ERROR_FUNC, nil, true )
end

function WBT_CheckForVendor()
	Log( "Check for vendor", "WorldBot.Trade" )
	for i, mobId in avatar.GetUnitList() do 
		if object.IsVendor( mobId ) == true then
			WBT_VENDOR_NAME = qaMission.UnitGetXDB( mobId )
			Log( "find vendor: " .. WBT_VENDOR_NAME, "WorldBot.Trade" )

			local coord = debugMission.InteractiveObjectGetPos( mobId )
			WBT_MoveToVendor( coord )
			return
		end
	end
	
	WBT_MoveToNextMob()
end

function WBT_MoveToNextMob()
	Log( "MoveToNextMob : " .. tostring( WBT_NPC_INDEX ) .. "/" .. tostring( GetTableSize( WBT_NPC_LIST ) ) , "WorldBot.Trade" )
	WBT_NPC_INDEX = WBT_NPC_INDEX + 1
	if WBT_NPC_INDEX > GetTableSize( WBT_NPC_LIST ) then
		Log( "can't find vendor in zone" )
		WBT_ERROR_FUNC( "Can't find vendor in zone=" .. WBT_ZONE )

	else
		local mobName = WBT_NPC_LIST[WBT_NPC_INDEX]
		if string.find( mobName, "Characters/" ) ~= nil then
			local coord = GetMobCoords( WB_MOB_LIST, mobName )[1]
			MoveToMob( coord, mobName, WBT_CheckForVendor, nil, WBT_MobNotFound )
		else 
			WBT_MoveToNextMob()
		end	
	end	
end
function WBT_MobNotFound( text )
	WB_Warn( text )
	WBT_MoveToNextMob()
end


function WBT_MoveToVendor( pos )
	Log( "pos=" .. tostring(pos) )
	Log( "pos1=" .. PrintCoord(pos) )
	MoveToMob( pos, WBT_VENDOR_NAME, WBT_BeforeStartTrade, nil, WBT_ERROR_FUNC )
end

function WBT_BeforeStartTrade()
	SelectTarget( GetMobId(WBT_VENDOR_NAME), WBT_BeforeStartTrade2, WBT_ERROR_FUNC )
end
function WBT_BeforeStartTrade2()
	StartPrivateTimer( 2000, SetMaxReputationToTarget, WBT_StartTrade )
end
function WBT_StartTrade()
	SellAllItems( WBT_VENDOR_NAME, WBT_PASS_FUNC, WBT_ERROR_FUNC )
end



-- возвращает -1, если item1 хуже item2, 0 если равны, 1 если лучше
function CompareItems( item1Info, item2Info )
	if item1Info.isWeapon == true and item2Info.isWeapon == true then
		return CompareInts( GetDPSByItemInfo( item1Info ), GetDPSByItemInfo( item2Info ) )

	elseif item1Info.isWeapon == false and item2Info.isWeapon == false then
		return CompareInts( item1Info.bonus.misc.armor, item2Info.bonus.misc.armor )

	else
		WB_ERROR_FUNCTION( "Not weapon, not armor" )
	end
end

function CompareInts( int1, int2 )
	Log( "compare items: " .. tostring( int1 ) .. " and " .. tostring( int2 ), "WorldBot.Trade" )
	if int1 < int2 then
		return -1
	elseif int1 > int2 then
		return 1
	else
		return 0
	end
end

