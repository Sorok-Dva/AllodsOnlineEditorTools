Global("RESP_FARMER_COORDS",nil)
Global("RESP_FARMER_COORD_I",0)
Global("RESP_FARMER_COORD_MAX",0)
Global("RESP_FARMER_MOBNAMES", nil)
Global("RESP_FARMER_MOBID", nil)
Global("RESP_FARMER_MOBS", nil)
Global("RESP_FARMER_MOBI", nil)
Global("RESP_FARMER_SPELLID", nil)
Global("RESP_FARMER_KILLID", nil)
Global("RESP_FARMER_LAG", nil)
Global("RESP_TIME_FOR_FIGHT", 20000)
Global("RESP_TIME_START_FIND", 0)
Global("RESP_TIME_STOP_FIND", 0)


Global("RESP_NEXT_FUNC", nil)
Global("RESP_ERROR_FUNC", nil)
Global("RESP_STOP_FARM", false)

Global("RESP_CURRENT_COORDS", "")
Global("RESP_TAKEN_COORDS", {})
Global("RESP_BOT_NAME", "")
Global("RESP_BOT_NUM", 0)
Global("RESP_PREFIX", "Im taken Place:")
Global("RESP_PREFIX_OUT", "Im out from Place:")

function InitRespawnMobs( mobNames, zoneName, zoneTp, mobList, killTime, funcPass, funcError )
	RESP_STOP_FARM = false
	RESP_NEXT_FUNC = funcPass
	RESP_ERROR_FUNC = funcError
	RESP_FARMER_MOBNAMES = mobNames
	RESP_FARMER_COORDS = {}
	for j, v in mobNames do
		Log("mob "..v.." zone "..zoneName )
		local cur_coords = GetMobCoordsZone( mobList, v, zoneName )
		if cur_coords == nil then
			return RespFatalError( "Cant get cur_coords " )	
		end
		for jj,cc in cur_coords do
			table.insert(RESP_FARMER_COORDS,cc)
		end
	end
	RESP_FARMER_COORD_I = 1
	RESP_TIME_FOR_FIGHT = killTime
	OnStateDebugNotify = OnRespStateDebugNotify
	local amount = 0
	for i,k in RESP_FARMER_COORDS do
		amount = amount + 1
	end

	local name = debugCommon.FromWString( object.GetName( avatar.GetId() ) )
	RESP_BOT_NUM = RespGetNumFromName(name)
	if RESP_BOT_NUM == nil then
		return RespFatalError( "Cant get num " )
	end
	RESP_BOT_NAME = name
	RESP_FARMER_COORD_MAX = amount

	RespLog("tpmap "..zoneTp.." "..tostring(RESP_FARMER_COORDS[1].X).." "..tostring(RESP_FARMER_COORDS[1].Y).." "..tostring(RESP_FARMER_COORDS[1].Z))
	qaMission.SendCustomMsg("tpmap "..zoneTp.." "..tostring(RESP_FARMER_COORDS[1].X).." "..tostring(RESP_FARMER_COORDS[1].Y).." "..tostring(RESP_FARMER_COORDS[1].Z))
	StartTimer(5000, RespCheckTPMAP, {zone = zoneTp, pos = RESP_FARMER_COORDS[1], count = 1})
end

function RespLog(txt)
	LogToAccountFile("RESPAWN: "..txt)
end

function RespCheckTPMAP(params)
	local map = debugMission.GetMap()
	if map ~= nil then
		map = map.debugName
	end
	RespLog("cur zone "..tostring(map))
	if map == params.zone then
		local avPos = avatar.GetPos()
		local absPos = ToAbsCoord( avPos )
		RespLog("X "..tostring(absPos.X).." Y "..tostring(absPos.Y).." Z "..tostring(absPos.Z))
		local cmp = RespCompareCoordinates(absPos,params.pos)
		if cmp == nil then
			return RespFatalError( "Wrong coordinates to compare CheckTPMAP " )	
		end
		if cmp then
			return RespStartState()
		end
	end
	if params.count < 5 then
		StartTimer(5000, RespCheckTPMAP, params)
		params.count = params.count + 1
	else
		return RespFatalError( "Cant tpmap " )	
	end
end

function RespStartState()
	RespLog("StartState Respawn")
	StartTimer(1000, SetScriptControl,{time = 1000, lag = 200, dX = 6, func = RespLearnAggroSpell, errorFunc = RespFatalError})
end

function RespStopFarm()
	RespLog("StopState Respawn")
	RESP_STOP_FARM = true
end

function RespFatalError( txt )
	Warn( tostring(txt) )
	--RESP_ERROR_FUNC(tostring(txt))
end

function RespLearnAggroSpell( lag )
	RESP_FARMER_LAG = lag
	RespLog("Learn dmg10 cheat")
	LearnSpell( "Mechanics/Spells/Cheats/Dmg10/spell.xdb", RespLearnKillSpell, RespFatalError)
end

function RespLearnKillSpell( id )
	RESP_FARMER_SPELLID = id
	RespLog("Learn kill cheat")
	LearnSpell( "Mechanics/Spells/Cheats/Kill/spell.xdb", RespImmune, RespFatalError)
end

--TODO добавить инвиз ..............................................
function RespImmune( id )
	RESP_FARMER_KILLID = id
	RespLog("ImmuneAvatar")
	ImmuneAvatar( RespMoveToFirstPos, RespFatalError, "Mechanics/Spells/Cheats/Highlander/Spell.xdb", "Mechanics/Spells/Cheats/Highlander/Buff.xdb" )
end

function RespMoveToFirstPos( )
	RespLog("start...")
	RespStartFindNextMob( true, true)
end

function RespGetNextPoint()
	RespLog("Get next point")
	RESP_FARMER_COORD_I = RESP_FARMER_COORD_I + 1
	if RESP_FARMER_COORD_I > RESP_FARMER_COORD_MAX then
		RESP_FARMER_COORD_I = 1
	end
end

function RespFindMobInPos(first)
	RespLog("FindMob in pos")
	if first ~= nil then
		RESP_FARMER_MOBS = avatar.GetUnitList()
		RESP_FARMER_MOBI = 0
	end
	for count, mobId in RESP_FARMER_MOBS do
		if count > RESP_FARMER_MOBI then
			local dead = unit.IsDead( mobId )
			local player = unit.IsPlayer( mobId )
			if not dead and not player then
				for k,v in RESP_FARMER_MOBNAMES do
					if qaMission.UnitGetXDB( mobId ) == v then
						if debugMission.UnitGetAggroList( mobId ) == nil then
							RESP_FARMER_MOBI = count
							return mobId
						end
					end
				end
			end
		end
	end
	return nil
end
-- ищем моба в точке респа
function RespStartFindNextMob(nextPos,startTime)
	if RESP_STOP_FARM then
		StopTimer()
		return RESP_NEXT_FUNC()
	end

	if startTime ~= nil then
		RespLog("Start FindNextMob")
		RESP_TIME_START_FIND = TIME_SEC
	end
	local curPoint = RespFindMobInPos(nextPos)

	
	if curPoint == nil then
		RespGetNextPoint()
		MoveToPos( RESP_FARMER_COORDS[RESP_FARMER_COORD_I], RespStartFindNextMob, true,5000)
	else
		-- TODO nado sna4alo glyanut ne zabil li kto
		RESP_FARMER_MOBID = curPoint
		local position = debugMission.InteractiveObjectGetPos( RESP_FARMER_MOBID )
		local pos = ToAbsCoord( position )
		local near = RespCompareCoordinates(RESP_FARMER_COORDS[RESP_FARMER_COORD_I], pos, 1000)
		if near then
			if RespCheckFirstToPlace(20000,pos,true) then
				RespTakePlace(pos)
				StartTimer(4000,CheckTakenPlace,pos)
			else
				RespLog("Place Taken "..tostring(pos.X).." "..tostring(pos.Y).." "..tostring(pos.Z))
				StartTimer(1000,RespStartFindNextMob,nil)
			end
		else
			RespLog("wrong mob "..tostring(pos.X).." "..tostring(pos.Y).." "..tostring(pos.Z))
			StartTimer(1000,RespStartFindNextMob,nil)
		end
	end
end
-- проверяем доступно ли нам это место
function CheckTakenPlace(pos)
	RespLog("CheckTakenPlace")
	local isFirst = RespCheckFirstToPlace(RESP_BOT_NUM,pos)
	RespLog("isFirst "..tostring(isFirst))
	if isFirst ~= nil then
		if isFirst then
			RESP_TIME_STOP_FIND = TIME_SEC
			RespSendFindTime()
			pos.X = pos.X - 1
			MoveToPos( pos, RespSelectMob, nil, 3000)
		else
			RespOutPlace()
			RespStartFindNextMob()
		end
	else
		RespLog("isFirst nil")
	end
end

function RespAttackTheMob()
	RespLog("AttackTheMob")
	CastSpell( RESP_FARMER_SPELLID , RESP_FARMER_MOBID, 10000, RespStartOgidanie, RespFailAttack, nil , true)
end

function RespSelectMob( func )
	RespLog("SelectTheMob")
	SelectTarget( RESP_FARMER_MOBID, RespAttackTheMob, RespCantSelectMob )
end

function RespCantSelectMob()
	RespOutPlace()
	-------------------------------------------------------------
	RespMoveToFirstPos()
end

function RespFailAttack(text, code)
	if code == "ENUM_ActionFailCause_NotInFront" then
		RespRotateToMob(RespAttackTheMob)
	else
		-- TODO 1
		RespCantSelectMob()
		--RespFatalError( "Cant att "..text )
	end
end

function RespRotateToMob(nextfunc)
	RespLog( "Avatar dir "..tostring(avatar.GetDir()) )
	local avPos = avatar.GetPos()
	local uPos = debugMission.InteractiveObjectGetPos( RESP_FARMER_MOBID )
	local dir = GetAngleBetweenPoints( avPos, uPos)
	if dir == nil then
		RespLog( "Rotate to mob Points is same dx = dy = 0 " )
		return RespAttackTheMob()
	end
	RespLog( "Rotate to mob dir "..tostring(dir))
	local moveParams = {
		deltaX = 0,
		deltaY = 0,
		deltaZ = 0,
		yaw = dir
	}
	
	qaMission.AvatarMoveAndRotate ( moveParams )
	StartTimer( RESP_FARMER_LAG, RespCheckRotate, {needdir = dir, count = 1, func = nextfunc})
end

function RespCheckRotate(params)
	local avdir = avatar.GetDir()
	RespLog( "Avatar dir "..tostring(avdir))
	local dDir = math.abs(avdir - params.needdir)
	local znak = avdir*params.needdir
	if dDir < 0.05 and znak > 0 then
		params.func()
	else
		if params.count < 5 then
			params.count = params.count + 1
			StartTimer( RESP_FARMER_LAG, RespCheckRotate, params)
		else
			RespCantSelectMob()
			--RespFatalError( "Cant rotate 5 times " )
		end
	end
end

function RespStartOgidanie()
	RespLog("StartTimerOfFight")
	StartTimer(RESP_TIME_FOR_FIGHT,RespKillMob,nil)
end

function RespKillMob()
	RespLog("KillMob")
	CastSpell( RESP_FARMER_KILLID , RESP_FARMER_MOBID, 10000, RespAfterKill, RespFailKill, nil , true)
end

function RespAfterKill()
	RespLog("AfterKill")
	RespOutPlace()
	-------------------------------------------------------------
	RespMoveToFirstPos()
end

function RespFailKill(text, code)
	if code == "ENUM_ActionFailCause_NotInFront" then
		RespRotateToMob(RespKillMob)
	else
		RespCantSelectMob()
		--RespFatalError( "Cant kill "..text )
		-- TODO 2
	end
end
-- подписываемся для всех
function RespTakePlace(pos)
	local str = ""
	str = str..tostring(pos.X).." "..tostring(pos.Y).." "..tostring(pos.Z)
	RespLog("Take Place "..str)
	RESP_CURRENT_COORDS = str
	qaMission.DebugNotify( RESP_PREFIX..str.."!", false )
end
-- Отписываемся для всех
function RespOutPlace()
	if RESP_CURRENT_COORDS ~= nil then
		local str = RESP_CURRENT_COORDS
		RESP_CURRENT_COORDS = nil
		qaMission.DebugNotify( RESP_PREFIX_OUT..str.."!", false )
	end
end

function OnRespStateDebugNotify(params)
	local coords = RespGetNotifyMessage( params, RESP_PREFIX )
	local coordsOut = RespGetNotifyMessage( params, RESP_PREFIX_OUT )
	local num = RespGetNumFromName(debugCommon.FromWString(params.sender))
	if num == nil then
		return
	end
	if coords ~= nil then
		local koords = RespGetKoordsFromStr( coords )
		table.insert(RESP_TAKEN_COORDS,{n = num,k = koords})
		RespLog("INSERT\t"..tostring(num))
	end
	if coordsOut ~= nil then
		local koords = RespGetKoordsFromStr( coordsOut )
		local index = RespGetIndexKoords(num, koords)
		if index ~= nil then
			table.remove(RESP_TAKEN_COORDS,index)
			RespLog("REMOVE\t"..tostring(num))
		else
			RespLog("!!!Cant delete "..tostring(num))
			--TODO ругатся т.к. не удалил
		end
	end

end
-- отправляем слушателю время и логируем
function RespSendFindTime()
	local t = RESP_TIME_STOP_FIND - RESP_TIME_START_FIND
	RespLog("FindTime:"..tostring(t))
	SendMsgHttp("FindTime:"..tostring(t))
end

-- Сравнивает свои координаты с теми что есть а таблице и если мой номер наименьший то true
function RespCheckFirstToPlace(n,k,nofirst)
	for i,v in RESP_TAKEN_COORDS do
		local compare = RespCompareCoordinates(v.k,k)
		if compare ~= nil then
			if compare then
				if nofirst == nil then
					if n > v.n then
						return false
					end
				else
					return false
				end
			end
		else
			return nil
		end
	end
	return true
end
-- Найти индекс по номеру и координатам
function RespGetIndexKoords(n, k)
	for i,v in RESP_TAKEN_COORDS do
		if v.n == n then
			local compare = RespCompareCoordinates(v.k,k)
			if compare ~= nil then
				if compare then
					return i
				end
			else
				return nil
			end
		end
	end
end
-- сравниваем координаты на расстояние 15 м между ними
function RespCompareCoordinates(k1,k2,r)
	if k1.X == nil or k2.X == nil then
		return nil
	end
	local dx = math.abs(k1.X - k2.X)
	local dy = math.abs(k1.Y - k2.Y)
	local dz = math.abs(k1.Z - k2.Z)
	local sum = (dx*dx) + (dy*dy)-- + (dz*dz)
	sum = math.sqrt(sum)
	local dist = 15
	if r ~= nil then
		dist = r
	end
	if sum < dist then
		return true
	else
		return false
	end
end
-- из "1 2 3" делает таблицу {X = 1, Y = 2, Z = 3} проверено
function RespGetKoordsFromStr(str)
	local ind1 = string.find(str," ")
	local ind2 = string.find(str," ", ind1+1)
	local str1 = string.sub(str,1,ind1)
	local str2 = string.sub(str,ind1+1,ind2)
	local str3 = string.sub(str,ind2+1)
	local x = tonumber(str1)
	local y = tonumber(str2)
	local z = tonumber(str3)
	if x ~= nil and y ~= nil and z ~= nil then
		return {X = x,Y = y, Z = z}
	else
		return nil
	end
end
--- из "LuaBot1" вытаскивает номер 
function RespGetNumFromName(name)
	if type(name) ~= "string" then
		return nil
	end
	local ind = string.find(name,"[0-9]+")
	if ind == nil then
		return nil
	end
	local num = string.sub(name, ind)
	num = tonumber(num)
	return num
end

function RespGetNotifyMessage( params, prefix )
	if debugCommon.FromWString( params.sender ) ~= RESP_BOT_NAME then
		local message = debugCommon.FromWString( params.message )
		local a, b = string.find( message, prefix )
		if a ~= nil and b ~= nil then
		    local endInd = string.find(message,"!",b+1 )
    	    if endInd == nil then
		        return nil
		    end
		    message = string.sub( message, b+1,endInd-1 )
			return message
		end
	end
	return nil
end
