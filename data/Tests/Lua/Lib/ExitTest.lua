
function DisintagrateMob( mobName )
	local id = GetMobId( mobName )
	if id ~= nil then
		Log( "Disintagrate mob. id=" .. tostring( id ) )
		qaMission.DisintegrateRespawnable( id )
	end
end

function ReturnTrue()
	return true
end

function ReturnFalse()
	return false
end

function EmptyFunction()
end

--- Вставляю метод Включения скрипт контрола. 
--- передвать {time = 2000, lag = 300, dX = 6, func = Success, errorFunc = Warn}
-- время между SetScript и MoveAndRotate, лаг - время ожидания на MoveAndRotate, dX - расстояние перемещения.
-- лучше пользоватся этими константами

function SetScriptControl(params)
	if params.count == nil then
		params.count = 1
		params.lag_count = 1
		params.X = 0
	end
	if params.count <= 3 then
		Log("Try SetScriptControl..."..tostring(params.count).." time. Lag: "..tostring(params.lag))
		qaMission.AvatarSetScriptControl( true )
		StartTimer(params.time * params.count, CheckScriptControl, params)
	else
		params.errorFunc("Cant Enable ScriptControl 3 times")
	end
end

function CheckScriptControl(params)
	local avPos = avatar.GetPos()
	local absPos = ToAbsCoord( avPos )
	if params.X == 0 then
		if params.count == 1 then
			params.startX = absPos.X
			params.startDir = avatar.GetDir()
		end
		local moveParams = {
			deltaX = params.dX,
			deltaY = 0,
			deltaZ = 0,
			yaw = 0
		}
		Log("Cur X: "..tostring(absPos.X).." Try Move for "..tostring(moveParams.deltaX).." m")
		params.X = absPos.X + moveParams.deltaX
		qaMission.AvatarMoveAndRotate( moveParams )	
		StartTimer(params.lag, CheckScriptControl, params )
	else
		if params.X == absPos.X then
			Log("Cur X: "..tostring(absPos.X).." Test Move success")
			ScriptControlSuccess(params)
		else
			Log("Cur X: "..tostring(absPos.X).." Test Move fail")
			if params.lag_count <= 3 then
				params.lag_count = params.lag_count + 1
				StartTimer(params.lag, CheckScriptControl, params )
			else
				params.count = params.count + 1
				params.X = 0
				params.lag_count = 1
				params.lag = params.lag * 2
				SetScriptControl(params)
			end
		end
	end
end

function ScriptControlSuccess(params)
	local avPos = avatar.GetPos()
	local absPos = ToAbsCoord( avPos )
	
	local moveParams = {
		deltaX = params.startX - absPos.X,
		deltaY = 0,
		deltaZ = 0,
		yaw = params.startDir }

	local fin_lag = ( params.lag*params.lag_count ) + 200
	Log("Lag "..tostring(fin_lag))

	qaMission.AvatarMoveAndRotate( moveParams )	
	StartTimer(fin_lag, params.func, fin_lag )
end
