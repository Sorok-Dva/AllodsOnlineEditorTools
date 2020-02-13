-- author: Liventsev Andrey, date: 01.04.2008
-- Библиотека для выполнения квестовой подзадачи типа "наубивать мобов"

Global( "WBQKM_MOB_LIST",       nil )
Global( "WBQKM_MOB_NAME",       nil )
Global( "WBQKM_QUEST_NAME",     nil )
Global( "WBQKM_PASS_FUNCTION",  nil )

Global( "WBQKM_LAST_PROGRESS_VALUE", nil )
Global( "WBQKM_MOB_COORDS",     nil )

Global( "WBQKM_CRITICAL_MAX_COUNT", 20 ) --  если не получится найти WBQKM_CRITICAL_MAX_COUNT мобов подряд - падаем с ошибкой
Global( "WBQKM_CRITICAL_COUNT", nil ) 
Global( "WBQKM_NEXT_FUNCTION", nil )

-- Метод для убийства мобов. 
-- Передается имя квеста и имя подзадачи (оно же - имя моба)
-- Есди в течении WBQKM_CRITICAL_MAX_COUNT попыток счетчик подзадачи не поменялся, то выходим с ошибкой
function KillMobs( mobList, questName, mobName, passFunc )
	Log()
	Log()
	Log( "KillMobs. questName=" .. tostring( questName ) .. " mobName=" .. tostring( mobName ), "WorldBot.KillMobs")
	
	WBQKM_MOB_LIST = mobList
	WBQKM_QUEST_NAME = questName
	WBQKM_MOB_NAME = mobName
	WBQKM_PASS_FUNCTION = passFunc
	
	local objective = GetQuestObjective( WBQKM_QUEST_NAME, WBQKM_MOB_NAME )
	WBQKM_MOB_COORDS = GetMobCoords( WBQKM_MOB_LIST, objective.sysDebugName )

	WBQKM_CRITICAL_COUNT = -1
	WBQKM_LAST_PROGRESS_VALUE = 0
	
	WBQKM_KillNextMob()
end

function WBQKM_KillNextMob()
	local objective = GetQuestObjective( WBQKM_QUEST_NAME, WBQKM_MOB_NAME )
	
	Log()
	Log( "kill next mob: " .. tostring( objective.progress ) .. "/" .. tostring( objective.required ), "WorldBot.KillMobs" )
	if objective.progress >= objective.required then
		WBQKM_PASS_FUNCTION()
		return
	end
	
	if WBQKM_CRITICAL_COUNT >= WBQKM_CRITICAL_MAX_COUNT then -- счетчик не меняется на УЖЕ_ДОХРЕНА_МОБОВ
		WBQKM_NEXT_FUNCTION = nil
		local text = "Tracker not changed or can't find mob. name=" .. tostring( WBQKM_MOB_NAME )
		WBQKM_Warn( text )
		Log( text, "WorldBot.KillMobs" )

		CompleteQuestByCheat( WBQKM_QUEST_NAME, WBQKM_PASS_FUNCTION )
		return	
	end	

	if WBQKM_LAST_PROGRESS_VALUE < objective.progress then -- если счетчик изменился
		WBQKM_LAST_PROGRESS_VALUE = objective.progress
		WBQKM_CRITICAL_COUNT = 0

	else
		WBQKM_CRITICAL_COUNT = WBQKM_CRITICAL_COUNT + 1
	end
		
	WBQKM_KillMob()
end

function WBQKM_KillMob( mobId )
	WBQKM_NEXT_FUNCTION = WBQKM_KillNextMob
	
	if mobId ~= nil then
		KillMob( mobId, WBQKM_KillNextMob, WBQKM_Warn )
	else

		if GetMobId( WBQKM_MOB_NAME ) ~= nil then
			KillMob( GetMobId( WBQKM_MOB_NAME ), WBQKM_KillNextMob, WBQKM_Warn )
		else
			FindMob( WBQKM_MOB_NAME, WBQKM_MOB_COORDS[GetRandomTableIndex( WBQKM_MOB_COORDS )], WBQKM_KillNextMob, WBQKM_Warn )
		end		
	end
end

function WBQKM_Warn( text )
	local params = {
		text = text,
		quest = WBQKM_QUEST_NAME
	}
	WB_Warn( params )
	
	if WBQKM_NEXT_FUNCTION ~= nil then
		WBQKM_NEXT_FUNCTION()
	end	
end
