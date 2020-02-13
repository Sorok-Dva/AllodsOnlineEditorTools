Global("AFTER_RANGE_FUNC",nil)
Global("ERROR_RANGE_FUNC",nil)
function TestersKill( )
	local avId = avatar.GetId()
	local priTarget = unit.GetPrimaryTarget( avId )
	local secTarget = unit.GetTarget( avId )
    local Target = nil
    
	if priTarget ~= nil then
		Target = priTarget
	else
		Target = secTarget
	end
	local takt = developerAddon.LoadTactics()
	common.LogInfo("common"," takt ".. tostring(takt))
	common.LogInfo("common"," target ".. tostring(Target))
	InitKillMob(Target,takt,100,EndKill,EndKill,RangeFunction,EndKill)
end

function RangeFunction(func, errorFunc)
	AFTER_RANGE_FUNC = func
	ERROR_RANGE_FUNC = errorFunc
	return GetTableAngles()
end

function GetTableAngles()
	local a = 0
	local ret = {}
	while a <= 2*math.pi() do
		table.insert(ret,a)
		a = a + math.pi()/6
	end
	return FindCleanPlace( 38, ret)
end

function FindCleanPlace( distance, angles )
	local units = avatar.GetUnitList()
	local aPos = avatar.GetPos()

	local curNum = 1
	local tPos = nil
	local directions = {}
	local aggro = false
	local inCirclePoint = false
	local inTriangle = false

	for a, curDir in angles do
		tPos = GetPositionAtDistance( aPos, curDir, distance )
		table.insert(directions, {pos = tPos, dir = curDir, unitsNear = {}, unitsTriangle = {} })
		for k, unitId in units do
			aggro = CheckMobAggro(unitId)
			inCirclePoint = GetDistanceFromPosition( unitId, tPos, false ) < 25
			inTriangle = PointInTriangle(debugMission.InteractiveObjectGetPos( unitId ),
				aPos,
				GetPositionAtDistance( aPos, AngleInc( curDir, 30, true ), distance ),
				GetPositionAtDistance( aPos, AngleDec( curDir, 30, true ), distance )) then
			if aggro and inCirclePoint then 
				table.insert( directions[curNum].unitsNear, unitId )			
			end
			if aggro and inTriangle then
				table.insert( directions[curNum].unitsTriangle, unitId )			
			end
		end
		if CheckNullTable( directions[curNum].unitsNear ) and CheckNullTable( directions[curNum].unitsTriangle ) then
			return OnFindDirection(directions[curNum])
		end
		curNum = curNum + 1
	end
	local minNum = 0
	local minAmount = 10000
	local curAmount = 0
	for i,direction in directions do
		if CheckNullTable( directions[curNum].unitsNear ) then
			return OnFindDirection(direction)
		end
		curAmount = CheckSizeTable( directions[curNum].unitsNear )
		if curAmount < minAmount then
			minAmount = curAmount
			minNum = i
		end
	end
	return OnFindDirection(directions[minNum])
end

function OnFindDirection(direction)
	-- TODO
	MoveToPos( direction.pos, AFTER_RANGE_FUNC, nil)
end

function CheckNullTable(table)
	for i in table do
		return false
	end
	return true
end

function CheckSizeTable(table)
	local amount = 0
	for i in table do
		amount = amount + 1
	end
	return amount
end


function CheckMobAggro(unitId)
	local info = unit.GetFaction( unitId )
	return not faction.isFriend and not info.isPassive
end

function EndKill(params)
	if type(params) == "table" then
		group.ChatYell( debugCommon.ToWString( "success"..tostring( params.kill ) ) )
	else
		group.ChatYell( debugCommon.ToWString( tostring( params ) ) )
	end
end

function OnChatMessage(params)
	local message = debugCommon.FromWString( params.msg )
	if message == "START" then
		TestersKill( )
	end
end
-------------------------------------------------------------------------------
-- INITIALIZATION
-------------------------------------------------------------------------------
function Init()
	-- register keyboard reactions
	
	common.RegisterEventHandler( OnChatMessage, "EVENT_CHAT_MESSAGE")
end
-------------------------------------------------------------------------------

Init()