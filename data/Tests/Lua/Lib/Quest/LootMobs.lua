-- author: Liventsev Andrey, date: 03.07.2008, bug#37937
-- Библиотека для выполнения квестов типа налутить мобов


Global( "QLM_MOB_LIST",       nil )
Global( "QLM_LOOT_NAME",      nil )
Global( "QLM_LOOT_COUNT",     nil )

Global( "QLM_PASS_FUNCTION",  nil )
Global( "QLM_ERROR_FUNCTION", nil )

Global( "QLM_CRITICAL_MAX_COUNT", 100 ) --  если не получится найти QLM_CRITICAL_MAX_COUNT мобов подряд - падаем с ошибкой
Global( "QLM_CRITICAL_COUNT", nil )

Global( "QLM_MOB_TABLE", nil )


-- Метод для сбора нужного количества предметов с мобов. После выполнения вызывается метод functionName
-- В любом случае если квест состоит только из лута, приходит событие EVENT_QUEST_UPDATED
function LootMobs( mobList, lootName, lootCount, passFunc, errorFunc )
	Log( "" )
	Log( "" )
	Log( "looting mobs. item=" .. lootName, "Quests.LootMobs" )

	QLM_MOB_LIST = mobList
	QLM_LOOT_NAME = lootName
	QLM_LOOT_COUNT = lootCount
	QLM_PASS_FUNCTION = passFunc
	QLM_ERROR_FUNCTION = errorFunc
	
	QLM_CRITICAL_COUNT = 0
	QLM_MOB_TABLE = GetLootOwner( QLM_MOB_LIST, QLM_LOOT_NAME )
	Log( "count mobs: " .. tostring( GetTableSize( QLM_MOB_TABLE )), "Quests.LootMobs" )
	if GetTableSize( QLM_MOB_TABLE ) == 0 then
		QLM_ERROR_FUNCTION( "Can't find loot owner for item=" .. QLM_LOOT_NAME )
	end
	
	QLM_LootingNextMob()
end

function QLM_LootingNextMob( mobId )
	local count = GetCountItem( QLM_LOOT_NAME )
	Log( "" )
	Log( "loot tracker info " .. tostring( count ) .. "/" .. tostring( QLM_LOOT_COUNT ) .. "  criticalCount=" .. tostring(QLM_CRITICAL_COUNT), "Quests.LootMobs" )
	
	if QLM_CRITICAL_COUNT >= QLM_CRITICAL_MAX_COUNT then
		QLM_ERROR_FUNCTION( "Can't find mob in " .. tostring(QKM_CRITICAL_MAX_COUNT) .. " times" )
		
	elseif count >= QLM_LOOT_COUNT then
		QLM_PASS_FUNCTION()

	else
		if mobId ~= nil then
			QLM_CRITICAL_COUNT = 0
			LootMob( mobId, QLM_LootingNextMob, QLM_ERROR_FUNCTION )
			
		else
			for index, mobInfo in QLM_MOB_TABLE do
				local id = GetMobId( ParseObjName( mobInfo.name, OBJ_TYPE_MOB_WORLD ))
				if id ~= nil then
					QLM_CRITICAL_COUNT = 0
			    	LootMob( id, QLM_LootingNextMob, QLM_ERROR_FUNCTION )
					return
				end
			end
			
			local mobInfo = GetRandomTableElement( QLM_MOB_TABLE )
			local position = GetRandomTableElement( mobInfo.positions )
			local pos = {
				X = position.x,
				Y = position.y,
				Z = position.z
			}
			QLM_CRITICAL_COUNT = QLM_CRITICAL_COUNT + 1
			local name = ParseObjName( mobInfo.name, OBJ_TYPE_MOB_WORLD )
			FindMob( name, ToStandartCoord( pos ), QLM_LootingNextMob, QLM_ERROR_FUNCTION )
		end
	end	
end
