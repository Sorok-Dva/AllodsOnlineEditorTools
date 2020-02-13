-- author: Liventsev Andrey, date: 01.04.2008
-- Библиотека для выполнения квестовой подзадачи типа "наюзать предметов"

Global( "WBQUD_MOB_LIST",   nil )
Global( "WBQUD_QUEST_NAME", nil )
Global( "WBQUD_DEV_NAME",   nil )
Global( "WBQUD_PASS_FUNCTION",  nil )
Global( "WBQUD_NEXT_FUNCTION", nil )

Global( "WBQUD_DEV_PLACES", nil )
Global( "WBQUD_LAST_PROGRESS_VALUE",   nil )

Global( "WBQUD_CRITICAL_COUNT", nil )
Global( "WBQUD_CRITICAL_MAX_COUNT", 20 ) --  если не получится найти WBQUD_CRITICAL_MAX_COUNT двайсов подряд - падаем с ошибкой


-- Метод для юза девайсов
-- Передается имя квеста и имя подзадачи (оно же - имя девайса)
-- Если в течении WBQUD_CRITICAL_MAX_COUNT попыток счетчик подзадачи не поменялся, то выходим с ошибкой
function UseDevs( mobList, questName, devName, passFunc, errorFunc )
    Log( "Start using devices", "Quests.UseDevs" )
	
	WBQUD_MOB_LIST = mobList
	WBQUD_QUEST_NAME = questName
	WBQUD_DEV_NAME = devName
	WBQUD_DEV_PLACES = GetDevCoords( mobList, devName )
	WBQUD_PASS_FUNCTION = passFunc
	
	WBQUD_LAST_PROGRESS_VALUE = 0
	WBQUD_CRITICAL_COUNT = -1

	WBQUD_UseNextDev()
end

function WBQUD_UseNextDev()
	local objective = GetQuestObjective( WBQUD_QUEST_NAME, WBQUD_DEV_NAME )
	
	Log()
	Log( "Use next device: " .. tostring( objective.progress ) .. "/" .. tostring( objective.required ), "WorldBot.UseDevs" )
	
	if objective.progress >= objective.required then
		WBQUD_PASS_FUNCTION()
		return
	end
	
	if WBQUD_CRITICAL_COUNT >= WBQUD_CRITICAL_MAX_COUNT then -- счетчик не меняется на УЖЕ_ДОХРЕНА_ДЕВАЙСОВ
		local text = "Tracker not changed or can't find device. name=" .. tostring( WBQUD_DEV_NAME )
		Log( text, "WorldBot.UseDevs" )
		
		WBQUD_NEXT_FUNCTION = nil
		WBQUD_Warn( text )

		CompleteQuestByCheat( WBQUD_QUEST_NAME, WBQUD_PASS_FUNCTION )
		return	
	end
	
	if WBQUD_LAST_PROGRESS_VALUE < objective.progress then -- если счетчик изменился
		WBQUD_LAST_PROGRESS_VALUE = objective.progress
		WBQUD_CRITICAL_COUNT = 0
	else
		WBQUD_CRITICAL_COUNT = WBQUD_CRITICAL_COUNT + 1
	end
	
	WBQUD_UseDev()
end

function WBQUD_UseDev( devId )
	WBQUD_NEXT_FUNCTION = WBQUD_UseNextDev
	
	if devId ~= nil then
		WBQKM_CRITICAL_COUNT = 0
		UseDev( devId, 5000, WBQUD_UseNextDev, WBQUD_Warn )

	else
		local dId = GetDevId( WBQUD_DEV_NAME, 1 )
		if dId ~= nil then
			WBQKM_CRITICAL_COUNT = 0
			UseDev( dId, 5000, WBQUD_UseNextDev, WBQUD_Warn )
		else
			WBQUD_MoveToNextDev()
		end
	end
end

function WBQUD_MoveToNextDev()
	WBQUD_CRITICAL_COUNT = WBQUD_CRITICAL_COUNT + 1
	MoveToPos( WBQUD_DEV_PLACES[GetRandomTableIndex( WBQUD_DEV_PLACES )], WBQUD_UseNextDev )
end

function WBQUD_Warn()
	local params = {
		text = text,
		quest = WBQUD_QUEST_NAME
	}
	WB_Warn( params )
	
	if WBQUD_NEXT_FUNCTION ~= nil then
		WBQUD_NEXT_FUNCTION()
	end	
end
