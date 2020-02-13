qaMission.AvatarSetPos-- author: Liventsev Andrey, date: 16.09.2008, bug#34555
-- Библиотека для выполнения квестов типа наюзать предметов

Global( "UD_DEV_NAME",   nil )
Global( "UD_DEV_PLACES", nil )
Global( "UD_DEV_COUNT",  nil )
Global( "UD_USE_TIME",   nil )

Global( "UD_CRITICAL_MAX_COUNT", 100 ) --  если не получится найти UD_CRITICAL_MAX_COUNT двайсов подряд - падаем с ошибкой
Global( "UD_CRITICAL_COUNT", nil )

Global( "UD_PASS_FUNCTION",  nil )
Global( "UD_CHECK_FUNCTION", nil )
Global( "UD_ERROR_FUNCTION", nil )

Global( "UD_COUNT", nil )

-- Метод для использования нужного кол-ва предметов. 
-- checkFunc: поверка эффекта от использования ( в большинстве случаев будет тупо ExitTest.ReturnTrue)
function UseDevs( devName, devPlaces, devCount, useTime, checkFunc, passFunc, errorFunc )
	Log( "" )
	Log( "" )
	Log( "" )
    Log( "Start using devices", "Quests.UseDevs" )

	UD_DEV_NAME = devName
	UD_DEV_COUNT = devCount
	UD_DEV_PLACES = devPlaces
	UD_USE_TIME = useTime
	
	UD_CHECK_FUNCTION = checkFunc
	UD_PASS_FUNCTION = passFunc
	UD_ERROR_FUNCTION = errorFunc
	
	UD_COUNT = 0

	
	UD_CRITICAL_COUNT = 0
	UD_UseNextDev()
end

function UD_UseNextDev( devId )
	Log( "" )
	Log( "Use next device: " .. tostring( UD_COUNT ) .. "/" .. tostring( UD_DEV_COUNT ), "Quests.UseDevs" )
	if UD_COUNT >= UD_DEV_COUNT then
		UD_PASS_FUNCTION()
	
	else
		if UD_CRITICAL_COUNT >= UD_CRITICAL_MAX_COUNT then	
			UD_ERROR_FUNCTION( "Can't find device in " .. tostring(UD_CRITICAL_MAX_COUNT) .. " times" )
		
		elseif devId ~= nil then
			UD_UseDevice( devId )

		else
			local devId = GetDevId( UD_DEV_NAME )
			if devId ~= nil then
				UD_UseDevice( devId )
			else
				UD_CRITICAL_COUNT = UD_CRITICAL_COUNT + 1
				( UD_DEV_PLACES[GetRandomTableIndex( UD_DEV_PLACES )] )
				StartPrivateTimer( 5000, UD_UseNextDev )			
			end
		end
	end
end

function UD_UseDevice( devId )
	UD_CRITICAL_COUNT = 0
	UseDev( devId, UD_USE_TIME, UD_CheckEffect, UD_ERROR_FUNCTION )
end

function UD_CheckEffect()
	if UD_CHECK_FUNCTION() == true then
		UD_COUNT = UD_COUNT + 1
		UD_UseNextDev()
	else
		UD_UseNextDev()
	end
end

