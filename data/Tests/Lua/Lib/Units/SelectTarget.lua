-- Есть функция SelectTarget( unitId, funcPass, funcError )
-- Выбирает указанного юнита в цель аватара и запускает ф-цию funcPass
-- Если же за 10 сек моб не появляется запускает funcError передает в нее строку с ошибкой

Global( "SELECT_TARGET_ID", nil )

function SelectTarget( unitId, passFunc, errorFunc )
	SELECT_TARGET_ID = unitId
	
	local distance = GetDistanceFromPosition( SELECT_TARGET_ID, avatar.GetPos() )
	Log( "Selecting target. id=" .. tostring( unitId ) .. " isDead=" .. tostring( unit.IsDead( unitId )) .. ". distance=" .. tostring( distance ), "Units.SelectTarget" )
	
	StartPrivateCheckTimer( 10000, SelectTargetTargetCheck, nil, errorFunc, "cant target this "..tostring(SELECT_TARGET_ID) .. ". distance=" .. tostring( distance ), passFunc, SELECT_TARGET_ID )
end

function TargetSelf( passFunc, errorFunc )
	SELECT_TARGET_ID = avatar.GetId()
	StartPrivateCheckTimer( 10000, SelectTargetTargetCheck, nil, errorFunc, "cant target self", passFunc, nil )
end

function TargetSelfFull( passFunc, passFuncParam, errorFunc )
	SELECT_TARGET_ID = avatar.GetId()
	StartPrivateCheckTimer( 10000, SelectTargetTargetCheck, nil, errorFunc, "cant target self", passFunc, passFuncParam )
end

function UnselectTarget( passFunc, errorFunc )
	avatar.UnselectTarget()
	StartPrivateCheckTimer( 10000, SelectTargetUnselectTargetCheck, nil, errorFunc, "cant unselect target ", passFunc, nil )
end

function UnselectTargetAdv( passFunc, passFuncParam, errorFunc )
	avatar.UnselectTarget()
	StartPrivateCheckTimer( 10000, SelectTargetUnselectTargetCheck, nil, errorFunc, "cant unselect target ", passFunc, passFuncParam )
end

function SelectTargetTargetCheck()
	avatar.SelectTarget( SELECT_TARGET_ID )
	return SELECT_TARGET_ID == avatar.GetTarget()
end

function SelectTargetUnselectTargetCheck()
	avatar.UnselectTarget()
	return avatar.GetTarget() == nil
end