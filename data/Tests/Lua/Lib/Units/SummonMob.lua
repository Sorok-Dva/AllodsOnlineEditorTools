-- Итак, есть функция SummonMob( mobName,mapResource, mobPostion, mobDir, funcPass, funcError )
-- Суммонит моба в нужной позиции, и после того как моб появляется на карте запускает funcPass
-- передает в нее ID этого моба.
-- Если же за 10 сек моб не появляется запускает funcError передает в нее строку с ошибкой

Global( "SUMMON_MOB_NAME", nil )
Global( "SUMMON_MOB_POS", nil )
Global( "SUMMON_MOB_PASS_FUNC", nil )
Global( "SUMMON_MOB_PASS_ERROR", nil )
Global( "SUMMON_MOB_ID", nil )
Global( "SUMMON_D_DIST", 2 )
Global( "SUMMON_EVENTS", false )

Global( "DESUMMON_CHECK",false)
Global( "DESUMMON_MOB_ID",false)

Global( "SUMMONED_IDS", nil )
Global( "DESUMMON_ALL_POS", nil )
Global( "DESUMMON_ALL_PASS", nil )
Global( "DESUMMON_ALL_ERROR", nil )
Global( "DESUMMON_ALL_FAIL", nil )

function SummonMob( mobName, mapResource, mobPosition, mobDir, funcPass, funcError, dist )
	if dist ~= nil then
		SUMMON_D_DIST = dist
	end
	if SUMMONED_IDS == nil then
	    SUMMONED_IDS = {}
	end

	StartSummonEvents()
	SUMMON_MOB_NAME = mobName
	SUMMON_MOB_POS = mobPosition
	SUMMON_MOB_PASS_FUNC = funcPass
	SUMMON_MOB_PASS_ERROR = funcError
	SUMMON_EVENTS = false
	local str_pos = ""
	for k,v in mobPosition do
		str_pos = str_pos..tostring(k).." - "..tostring(v)..", "
	end
    SummonLog( "Try summon mob..." .. mobName.." map "..mapResource.." pos "..str_pos.." dir "..tostring(mobDir) )
	
	local mob = qaMission.SummonMob(mobName, mapResource, mobPosition, mobDir )
	if mob == -1 then
		SummonError("Wrong parameters to summon")
	end
--	SummonLog( "mob " .. tostring(mob) )
	StartPrivateCheckTimer( 10000, SummonEventsCheck, nil, SummonError, "summon events not coming", SummonLog, "Events coming" )
end
function SummonEventsCheck()
	return SUMMON_EVENTS
end

function DeSummon( mobId, Pass, Error, secondTime )
    DESUMMON_MOB_ID = mobId
    DESUMMON_PASS = Pass
    DESUMMON_ERROR = Error
	if type(secondTime) == "boolean" then
	    if not secondTime then
	    	DESUMMON_CHECK = false
	    	common.RegisterEventHandler( SM_OnUnitDespawned, "EVENT_UNIT_DESPAWNED" )
	    end
		StartPrivateCheckTimer( 10000, DeSummonCheck, nil, DeSummonError, "summon mob failed or not spawned", DeSummonPass, nil )
	else
		DESUMMON_CHECK = false
		common.RegisterEventHandler( SM_OnUnitDespawned, "EVENT_UNIT_DESPAWNED" )
	    StartPrivateCheckTimer( 10000, DeSummonCheck, nil, DeSummonError, nil, DeSummonPass, nil )
	end
	SummonLog( "try desintegrate..." .. tostring( mobId ))
	qaMission.DisintegrateRespawnable( mobId )
end
function DeSummonCheck()
	return DESUMMON_CHECK
end

function DeSummonAllSummoned(Pass)
	if type(Pass) == "function" then
		SummonLog("Desummon All ")
		DESUMMON_ALL_PASS = Pass
    elseif type(Pass) == "string" then
		for i,id in SUMMONED_IDS do
			if DESUMMON_ALL_POS == i then
       		    SummonLog(" cant desummon "..tostring(id))
				table.remove(SUMMONED_IDS,i)
			end
		end
	end
	if SUMMONED_IDS ~= nil then
		for i,id in SUMMONED_IDS do
			SummonLog("i: "..tostring(i).." id: "..tostring(id))
			DESUMMON_ALL_POS = i
			return DeSummon(id, DeSummonAllSummoned, DeSummonAllSummoned)
		end
	end
	SUMMONED_IDS = nil
	DESUMMON_ALL_PASS()
end




function SummonPass()
	SummonLog( "mob summoned. id=" .. tostring(SUMMON_MOB_ID), "SummonMob" )
	StopSummonEvents()
	table.insert(SUMMONED_IDS, SUMMON_MOB_ID)
	for i,id in SUMMONED_IDS do
--		SummonLog("i: "..tostring(i).." id: "..tostring(id))
	end
    SUMMON_MOB_PASS_FUNC( SUMMON_MOB_ID )
end

function SummonError(text)
	SummonLog( "ERROR "..text )
	StopSummonEvents()
    SUMMON_MOB_PASS_ERROR( text )
end

function DeSummonPass()
	SummonLog( "DisintegrateInteractive Success!" )
	common.UnRegisterEventHandler( "EVENT_UNIT_DESPAWNED" )
	if DESUMMON_MOB_ID ~= nil and SUMMONED_IDS ~= nil then
		for i,id in SUMMONED_IDS do
			if DESUMMON_MOB_ID == id then
				table.remove(SUMMONED_IDS, i)
			end
		end
	end
	DESUMMON_PASS()
end

function DeSummonError(text)
	if text == nil then
		SummonLog( "DisintegrateInteractive ERROR, try one more time.." )
    	DeSummon( DESUMMON_MOB_ID, DESUMMON_PASS, DESUMMON_ERROR, true )
    else
    	SummonLog( "DisintegrateInteractive ERROR second time, fuck!" )	
    	common.UnRegisterEventHandler( "EVENT_UNIT_DESPAWNED" )
    	DESUMMON_ERROR(text)
    end
end



function StartSummonEvents()
	common.RegisterEventHandler( SM_OnDebugSummonMobOk, "EVENT_DEBUG_SUMMON_MOB_OK" )
	common.RegisterEventHandler( SM_OnDebugSummonMobFailed, "EVENT_DEBUG_SUMMON_MOB_FAILED" )
end

function StopSummonEvents()
	common.UnRegisterEventHandler( "EVENT_DEBUG_SUMMON_MOB_OK" )
	common.UnRegisterEventHandler( "EVENT_DEBUG_SUMMON_MOB_FAILED" )
end

function SummonLog( text )
	Log( text, "Units.SummonMob" )
end


------------------------ EVENTS ----------------

function SM_OnDebugSummonMobOk( params )
	SummonLog( "On debug summon mob ok. Checking place for mob..." )
	SUMMON_EVENTS = true
	StartPrivateCheckTimer( 10000, SummonMobCheckPlace, nil, SummonError, "summon mob Ok, but cant find in point", SummonPass, nil )
end
function SummonMobCheckPlace()
	local units = avatar.GetUnitList()
	for key, unitId in units do
		if not unit.IsPlayer( unitId ) then
			if not unit.IsDead( unitId ) then
			    if qaMission.UnitGetXDB( unitId ) == SUMMON_MOB_NAME then
			    	local dist = GetDistanceFromPosition( unitId, SUMMON_MOB_POS )
			        if dist < SUMMON_D_DIST then
			        	SUMMON_MOB_ID = unitId
			            return true
			        end
			    end
			end
		end
	end
	
	return false
end

-- EVENT_DEBUG_SUMMON_MOB_FAILED
function SM_OnDebugSummonMobFailed( params )
	SummonLog( "Summon mob failed. requestId=" .. tostring( params.requestId ))
	SUMMON_EVENTS = true
	SummonError( "Summon mob failed. mobName=" .. params.mobWorld )
end

function SM_OnUnitDespawned( params )
	if params.unitId == DESUMMON_MOB_ID then
	    DESUMMON_CHECK = true
	end
end



