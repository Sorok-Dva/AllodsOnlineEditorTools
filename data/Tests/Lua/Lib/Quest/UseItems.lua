-- author: Liventsev Andrey, date: 18.09.2008, bug#37937
-- Либа для квестов типа поюхать предмет из инвентаря на цель

Global( "QUI_MOB_NAME", nil )
Global( "QUI_MOB_PLACES", nil )
Global( "QUI_ITEM_NAME", nil )
Global( "QUI_USES_COUNT", nil )
Global( "QUI_USE_TIME", nil )
Global( "QUI_PASS_FUNCTION", nil )
Global( "QUI_ERROR_FUNCTION", nil )
Global( "QUI_CHECK_FUNCTION", nil )

Global( "QUI_CUR_USES", nil ) 

Global( "QUI_CRITICAL_MAX_COUNT", 100 ) --  если не получится поюзать QUI_CRITICAL_MAX_COUNT итемов подряд - падаем с ошибкой
Global( "QUI_CRITICAL_COUNT", nil )


function UseItemsToTargets( mobName, mobPlaces, itemName, usesCount, useTime, checkFunc, passFunc, errorFunc )
	QUI_MOB_NAME = mobName
	QUI_MOB_PLACES = mobPlaces
	QUI_ITEM_NAME = itemName
	QUI_USES_COUNT = usesCount
	QUI_USE_TIME = useTime
	QUI_PASS_FUNCTION = passFunc
	QUI_ERROR_FUNCTION = errorFunc
	QUI_CHECK_FUNCTION = checkFunc
	
	QUI_CRITICAL_COUNT = 0
	QUI_CUR_USES = 0
	
	Log( "" )
	QUI_Log( "Start using items" )
	
	
	QUI_UseNextToTarget()
end

function QUI_UseNextToTarget( mobId )
	QUI_Log( "use next device: " .. tostring( QUI_CUR_USES ) .. "/" .. tostring( QUI_USES_COUNT ))
	
	if QUI_CRITICAL_COUNT >= QUI_CRITICAL_MAX_COUNT then
		QUI_ERROR_FUNCTION( "Can't use item in " .. tostring(QUI_CRITICAL_MAX_COUNT) .. " times" )
		
	elseif QUI_CUR_USES >= QUI_USES_COUNT then
		QUI_Log( "SUCCESS" )
		QUI_PASS_FUNCTION()

	else
		if mobId ~= nil then
			UseItemToTarget( mobId, QUI_ITEM_NAME, QUI_USE_TIME, QUI_AfterUseOnTarget, QUI_ERROR_FUNCTION )
		else
		    local id = GetMobId( QUI_MOB_NAME )
		    if id ~= nil then
		    	UseItemToTarget( mobId, QUI_ITEM_NAME, QUI_USE_TIME, QUI_AfterUseOnTarget, QUI_ERROR_FUNCTION )
		    else
				QUI_CRITICAL_COUNT = QUI_CRITICAL_COUNT + 1
				FindMob( QUI_MOB_NAME, QUI_MOB_PLACES[GetRandomTableIndex( QUI_MOB_PLACES )], QUI_UseNextToTarget, QUI_ERROR_FUNCTION )
			end
		end
	end	
end

function QUI_AfterUseOnTarget()
	if QUI_CHECK_FUNCTION() == true then
		QUI_CRITICAL_COUNT = 0
		QUI_CUR_USES = QUI_CUR_USES + 1
		QUI_Log( "using item SUCCESS" )
	else
		QUI_Log( "using item CAN'T EXECUTE" )
	end
	QUI_UseNextToTarget()
end

function QUI_Log( text )
	Log( text, "Quests.UseItems" )
end
