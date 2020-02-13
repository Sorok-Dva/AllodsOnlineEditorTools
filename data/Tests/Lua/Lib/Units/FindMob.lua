-- author: Liventsev Andrey, date: 18.09.2008, task# 43086
-- ƒл€ поиска мобов

Global( "FM_MOB_NAME",       nil )
Global( "FM_MOB_PLACE",      nil )
Global( "FM_NEED_TO_SELECT", nil ) 
Global( "FM_PASS_FUNCTION",  nil )
Global( "FM_ERROR_FUNCTION", nil )

-- ѕросто телепортит в указанную точку, и ищет там моба. ѕо окончании вызывает ф-цию passFunc с id найденного моба
-- ≈сли id не найден - значит никого там нет ))
-- необ€зательный параметр needToSelect - нужно ли выбрать моба в цель. ≈сли не указан, то в цель не выбираем
function FindMob( mobName, mobPlace, passFunction, errorFunction, needToSelect )
	FM_MOB_NAME = mobName
	FM_MOB_PLACE = mobPlace
	FM_PASS_FUNCTION = passFunction
	FM_ERROR_FUNCTION = errorFunction
	FM_NEED_TO_SELECT = needToSelect

	Log( "mob to mobPlace: " .. PrintCoord( FM_MOB_PLACE ), "Units.FindMob" )
    qaMission.AvatarSetPos( FM_MOB_PLACE )
    StartPrivateTimer( 3000, FM_SearchMob )
end

function FM_SearchMob()
	local mobId = GetMobId( FM_MOB_NAME )
	if mobId ~= nil then
		Log( "Mob founded: id=" .. tostring( mobId ) .. " distance=" .. tostring( GetDistanceFromPosition( mobId, avatar.GetPos() )), "Units.FindMob" )
		if FM_NEED_TO_SELECT == nil or FM_NEED_TO_SELECT == false then
			FM_PASS_FUNCTION( mobId )
		else
			SelectTarget( mobId, FM_PASS_FUNCTION, FM_ERROR_FUNCTION )
		end

	else
		Log( "Cant find mob", "Units.FindMob" )
		FM_PASS_FUNCTION( nil )
	end
end
