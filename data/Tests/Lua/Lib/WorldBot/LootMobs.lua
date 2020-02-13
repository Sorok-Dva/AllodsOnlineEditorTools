-- author: Liventsev Andrey, date: 01.04.2008
-- Библиотека для выполнения квестовой подзадачи типа "налутить мобов"

Global( "WBQLM_MOB_LIST",       nil )
Global( "WBQLM_QUEST_NAME",       nil )
Global( "WBQLM_ITEM_NAME",      nil )
Global( "WBQLM_PASS_FUNCTION",  nil )
Global( "WBQLM_NEXT_FUNCTION", nil )

Global( "WBQLM_MOB_TABLE", nil )

Global( "WBQLM_CRITICAL_MAX_COUNT", 20 ) --  если не получится найти WBQLM_CRITICAL_MAX_COUNT мобов подряд - падаем с ошибкой
Global( "WBQLM_CRITICAL_COUNT", nil )


-- Метод для сбора предметов с мобов
-- Передается имя квеста и имя подзадачи (оно же - имя итема)
-- Если в течении WBQLM_CRITICAL_MAX_COUNT попыток счетчик подзадачи не поменялся, то выходим с ошибкой
function LootMobs( mobList, questName, itemName, passFunc )
	Log()
	Log()
	Log( "looting mobs. item=" .. itemName, "WorldBot.LootMobs" )

	WBQLM_MOB_LIST = mobList
	WBQLM_QUEST_NAME = questName
	WBQLM_ITEM_NAME = itemName
	WBQLM_PASS_FUNCTION = passFunc
	
	WBQLM_CRITICAL_COUNT = 0
	WBQLM_MOB_TABLE = GetLootOwner( WBQLM_MOB_LIST, WBQLM_ITEM_NAME )

	Log( "count mobs: " .. tostring( GetTableSize( WBQLM_MOB_TABLE )), "WorldBot.LootMobs" )
	if GetTableSize( WBQLM_MOB_TABLE ) == 0 then
		local quests = {}
		table.insert( quests, WBQLM_QUEST_NAME )
		
		local params = {
			text = "Can't find loot owner(mob) for item=" .. WBQLM_ITEM_NAME .. "  quest=" .. WBQLM_QUEST_NAME,
			quests = quests
		}
		WB_Warn( params )
		
		AbandonQuestByCheat( WBQLM_QUEST_NAME, WBQLM_PASS_FUNCTION )
	else
		WBQLM_LootingNextMob()
	end		
end

function WBQLM_LootingNextMob( mobId )
	local objective = GetQuestObjective( WBQLM_QUEST_NAME, WBQLM_ITEM_NAME )
	local count = GetCountItem( WBQLM_ITEM_NAME )
	
	Log()
	Log( "loot next mob: " .. tostring( count ) .. "/" .. tostring( objective.required ), "WorldBot.LootMobs" )
	if count >= objective.required then
		WBQLM_PASS_FUNCTION()
		return
	end
	
	if WBQLM_CRITICAL_COUNT >= WBQLM_CRITICAL_MAX_COUNT then
		local text = "Can't find mob in " .. tostring(WBQLM_CRITICAL_MAX_COUNT) .. " times"
		Log( text, "WorldBot.LootMobs" )
		WBQLM_NEXT_FUNCTION = nil
		WBQLM_Warn( text )
		
		CompleteQuestByCheat( WBQLM_QUEST_NAME, WBQLM_PASS_FUNCTION )
		return
	end

	WBQLM_NEXT_FUNCTION = WBQLM_LootingNextMob
	if mobId ~= nil then
		WBQLM_CRITICAL_COUNT = 0
		LootMob( mobId, WBQLM_LootingNextMob, WBQLM_Warn )
		
	else
		for index, mobInfo in WBQLM_MOB_TABLE do
			local id = GetMobId( ParseObjName( mobInfo.name, OBJ_TYPE_MOB_WORLD ))
			if id ~= nil then
				WBQLM_CRITICAL_COUNT = 0
				LootMob( id, WBQLM_LootingNextMob, WBQLM_Warn )
				return
			end
		end
		
		local mobInfo = GetRandomTableElement( WBQLM_MOB_TABLE )
		local position = GetRandomTableElement( mobInfo.positions )
		local pos = {
			X = position.x,
			Y = position.y,
			Z = position.z
		}
		WBQLM_CRITICAL_COUNT = WBQLM_CRITICAL_COUNT + 1
		local name = ParseObjName( mobInfo.name, OBJ_TYPE_MOB_WORLD )
		FindMob( name, ToStandartCoord( pos ), WBQLM_LootingNextMob, WBQLM_Warn )
	end	
end

function WBQLM_Warn( text )
	local params = {
		text = text,
		quest = WBQLM_QUEST_NAME
	}
	WB_Warn( params )
	
	if WBQLM_NEXT_FUNCTION ~= nil then
		WBQLM_NEXT_FUNCTION()
	end	
end
