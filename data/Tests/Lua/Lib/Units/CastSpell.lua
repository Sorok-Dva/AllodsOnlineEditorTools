--кубик CastSpell( spellId, pos, time, funcPass, funcError, effects )
--pos - если AE или таргет то передается обычный то unitId, он из него возмет поз при надобности
-- Также можно дать GamePostion {posX = 0, posY = 0, posZ = 0}
--time - время таймаута для кубика
--funcPass - функцию возврата при Success
--funcError - функцию возврата при Error - (text, code)
-- поле effects - table таблиц. заполнять table.insert !!! Если не нужен еффект, оставьте nilом
-- обязательное поле type -  брать из констант effects
-- для EFFECT_DAMAGE
-- damageSource - брать из констант damage source
-- targetId - id того кто получает дмж
-- sourceId - id Того кто бьет
-- для EFFECT_BUFF
-- unitId - id того на ком должен появится буфф
-- buffName - xdb этого буффа
-- для EFFECT_HEAL
-- unitId - id того кого лечит
-- healerId - id того кто лечит

-- есть метод CastSpellToTarget, кот. перед кастом выбирает в цель нужного моба (исп. SelectTarget.lua)

Global("CASTSPELL_ERROR_FUNC",nil)
Global("CASTSPELL_PASS_FUNC",nil)
Global("CASTSPELL_PASS_PARAMS",nil)

Global("CASTSPELL_CHECK",false)
Global("CASTSPELL_EFFECTS",nil)
Global("CASTSPELL_STARTED",false)
Global("CASTSPELL_ERROR_TEXT","")
Global("CASTSPELL_ERROR_CODE","")
Global("CASTSPELL_SPELL_ID",nil)
Global("CASTSPELL_SPELL_NAME","")
Global("CASTSPELL_POS",nil)
Global("CASTSPELL_TIME",nil)
Global("CASTSPELL_PREPARED",false)
Global("CASTSPELL_2PHASE",false)
Global("CASTSPELL_CHEAT",nil)
Global("CASTSPELL_ACTION_START",false)
Global("CASTSPELL_ACTION_STOP",false)
Global("CAST_STATE_ERROR",false)
Global("CASTSPELL_CHANNELING",true)

---- CONSTANTS ----
--- effects -----
Global("EFFECT_DAMAGE",0)
Global("EFFECT_BUFF",1)
Global("EFFECT_HEAL",2)
-- damage source ----
Global( "CHECKDMG_SOURCE_SPELL",      0 )
Global( "CHECKDMG_SOURCE_DOT",	      1 )
Global( "CHECKDMG_SOURCE_MAINATTACK", 2 )
Global( "CHECKDMG_SOURCE_OFFATTACK",  3 )
Global( "CHECKDMG_SOURCE_OTHER",      4 )

---
Global("CASTSPELL_EVENT_DMG_RECEIVED",-1)
Global("CASTSPELL_EVENT_HEAL_RECEIVED",-1)
Global("CASTSPELL_EVENT_BUFF_RECEIVED",-1)

---
Global("CASTSPELL20TIMES_ERROR_FUNC",nil)
Global("CASTSPELL20TIMES_PASS_FUNC",nil)
Global("CASTSPELL20TIMES_COUNTER",0)
Global("CASTSPELL20TIMES_TIME",nil)
Global("CASTSPELL20TIMES_POS",nil)
Global("CASTSPELL20TIMES",false)

function CastSpell20Times( spellId, pos, time, funcPass, funcError, effects, cheat, passParams )
	CastSpellSet20Times( false, "CastSpell20Times" )
	StartCastSpellEvents( effects)
	CASTSPELL20TIMES_ERROR_FUNC = funcError
	--Log("errorFunc "..tostring(CASTSPELL20TIMES_ERROR_FUNC))
	CASTSPELL20TIMES_PASS_FUNC = funcPass
	CASTSPELL20TIMES_COUNTER = 0
	CASTSPELL20TIMES_TIME = time
	CASTSPELL20TIMES_POS = pos
	CastSpellSet20Times( true, "CastSpell20Times" )
	CASTSPELL_EFFECTS = effects
	CASTSPELL_PASS_PARAMS = passParams
	CASTSPELL_CHEAT = cheat
	local spellInfo = avatar.GetSpellInfo( spellId )
	CASTSPELL_SPELL_NAME = debugCommon.FromWString(spellInfo.name) 
	
	CastSpell( spellId, pos, time, Pass20Times, Error20Times, effects, cheat)
end

function CastSpellSet20Times( boolean, func )
	CASTSPELL20TIMES = boolean
	CastSpellLog("Set 20Times"..tostring(CASTSPELL20TIMES).." in func "..tostring(func))
end

function Error20Times(text,code)
	if code == "ENUM_ActionFailCause_Cooldown" and CASTSPELL20TIMES_COUNTER < 20 then
		CASTSPELL20TIMES_COUNTER = CASTSPELL20TIMES_COUNTER + 1
		StartPrivateTimer(500,CastSpell1Sec)
	else
		CastSpellSet20Times( false, "Error20Times" )
		StopCastSpellEvents( CASTSPELL_EFFECTS, "Error20Times")
		--Log("errorFunc "..tostring(CASTSPELL20TIMES_ERROR_FUNC))
		CASTSPELL20TIMES_ERROR_FUNC(text,code)
	end
end

function Pass20Times()
	CastSpellSet20Times( false, "Pass20Times" )
	StopCastSpellEvents(CASTSPELL_EFFECTS, "Pass20Times")
	CASTSPELL20TIMES_PASS_FUNC()
end

function CastSpell1Sec()
	CastSpell( CASTSPELL_SPELL_ID, CASTSPELL20TIMES_POS, CASTSPELL20TIMES_TIME, Pass20Times, Error20Times, CASTSPELL_EFFECTS, CASTSPELL_CHEAT, CASTSPELL_PASS_PARAMS )
end
---
--TODO надо делать отмену каста после препаре
function CastSpell( spellId, pos, time, funcPass, funcError, effects, cheat, passParams )
	CASTSPELL_PASS_FUNC = funcPass
	CASTSPELL_PASS_PARAMS = passParams
	CASTSPELL_ERROR_FUNC = funcError
	CASTSPELL_SPELL_ID = spellId
	CASTSPELL_ERROR_CODE = ""
	CASTSPELL_EFFECTS = effects
	CASTSPELL_POS = pos
	CASTSPELL_TIME = time
	CAST_STATE_ERROR = false
	CASTSPELL_CHEAT = cheat
	local spellInfo = avatar.GetSpellInfo( spellId )
--	targetType: number (enum) -- может принимать одно из след. значений: SPELL_TYPE_SELF, SPELL_TYPE_CURRENT_TARGET, c, SPELL_TYPE_CURRENT_TARGET_NOT_SELF

	CastSpellLog("spellInfo.prepared "..tostring(spellInfo.prepared).." spellInfo.prepareDuration "..tostring(spellInfo.prepareDuration).." cheat "..tostring(cheat).." spellInfo.launchWhenReady "..tostring(spellInfo.launchWhenReady).." spellInfo.targetType "..tostring(spellInfo.targetType))
	CASTSPELL_PREPARED = spellInfo.prepared or (spellInfo.prepareDuration == 0) or cheat ~= nil or spellInfo.launchWhenReady or (spellInfo.targetType == SPELL_TYPE_SELF)
	local addTime = 0
	if not spellInfo.prepared then
	    addTime = spellInfo.prepareDuration
	end
	CASTSPELL_CHANNELING = true
	if cheat ~= nil then
			CASTSPELL_CHANNELING = false
	end
	CASTSPELL_ACTION_START = false
	CASTSPELL_ACTION_STOP = false
	CASTSPELL_SPELL_NAME = debugCommon.FromWString(spellInfo.name) 
	CastSpellLog("Begin..."..CASTSPELL_SPELL_NAME.." id - "..tostring(spellId))
	if CASTSPELL_PREPARED then
		if CASTSPELL_EFFECTS ~= nil then
		    for i,effect in CASTSPELL_EFFECTS do
				if effect.type == EFFECT_DAMAGE then
					effect.check = false
					CastSpellLog("Starting waiting appearence dmg source: "..tostring(effect.damageSource).."...")
				elseif effect.type == EFFECT_BUFF then
					effect.check = false
				    CastSpellLog("Starting waiting appearence buff: "..effect.buffName.."...")
				elseif effect.type == EFFECT_HEAL then
	       			effect.check = false
				    effect.spellId = spellId
					CastSpellLog("Starting waiting Heal received for unitId:"..tostring(effect.unitId).."...")
				end
			end
		end
		if not CASTSPELL_2PHASE then
			StartCastSpellEvents( CASTSPELL_EFFECTS)
		end
		CASTSPELL_2PHASE = false
		CASTSPELL_CHECK = false
		CASTSPELL_STARTED = false
		if spellInfo.targetType == SPELL_TYPE_CURRENT_TARGET or spellInfo.targetType == SPELL_TYPE_CURRENT_TARGET_NOT_SELF then
			CastSpellLog("Try to Run Spell to Target.."..spellInfo.debugName)
			if pos ~= nil then
				avatar.RunTargetSpell( spellId, pos )
			else
				avatar.RunSpell( spellId )
			end
		elseif spellInfo.targetType == SPELL_TYPE_POINT then
			CastSpellLog("Try to Run AE Spell.."..spellInfo.debugName)
			if type(pos) == "table" then
				avatar.RunAESpell( spellId, pos )
			else
				local unitPos = debugMission.InteractiveObjectGetPos( pos )
				if unitPos == nil then
					return funcError("Cant get pos for AE spell")
				end
				local absUPos = ToAbsCoord( unitPos )
				avatar.RunAESpell( spellId, {posX = absUPos.X, posY = absUPos.Y, posZ = absUPos.Z} )
			end
		elseif spellInfo.targetType == SPELL_TYPE_SELF then
			CastSpellLog("Try to Run Spell to Self.."..spellInfo.debugName)
			avatar.RunSpell( spellId )
		end
		CASTSPELL_ERROR_TEXT = "Prepared Spell Not launched FAIL : timeout"
		if cheat ~= nil then
			CastSpellTimeForActionStart()
		else
			StartPrivateTimer( 500 + addTime, CastSpellTimeForActionStart, nil )
		end
	else
		CASTSPELL_2PHASE = true
		StartCastSpellEvents( CASTSPELL_EFFECTS)
		CASTSPELL_CHECK = false
		CASTSPELL_STARTED = false
		if spellInfo.targetType == SPELL_TYPE_CURRENT_TARGET or spellInfo.targetType == SPELL_TYPE_CURRENT_TARGET_NOT_SELF then
			CastSpellLog("Try to Prepare Spell to Target..."..spellInfo.debugName)
			if pos ~= nil and cheat == nil then
				avatar.RunTargetSpell( spellId, pos )
			else
				avatar.RunSpell( spellId )
			end
		elseif spellInfo.targetType == SPELL_TYPE_POINT then
			CastSpellLog("Try to Prepare AE Spell.."..spellInfo.debugName)
			if type(pos) == "table" then
				CastSpellLog("AE Point From Table..")
				avatar.RunAESpell( spellId, pos )
			else
				local unitPos = debugMission.InteractiveObjectGetPos( pos )
				if unitPos == nil then
					return funcError("Cant get pos for AE spell")
				end
				local absUPos = ToAbsCoord( unitPos )
				CastSpellLog("AE Point From targetId.. "..tostring(absUPos.X).." "..tostring(absUPos.Y).." "..tostring(absUPos.Z))
				avatar.RunAESpell( spellId, {posX = absUPos.X, posY = absUPos.Y, posZ = absUPos.Z} )
			end
		elseif spellInfo.targetType == SPELL_TYPE_SELF then
			CastSpellLog("Try to Prepare Spell to Self.."..spellInfo.debugName)
			avatar.RunSpell( spellId )
		end
		CASTSPELL_ERROR_TEXT = "Not started prepare FAIL : timeout"
		StartPrivateCheckTimer( CASTSPELL_TIME + spellInfo.prepareDuration, CastCheck, nil, CastError, nil, CastPrepared, nil )
	end
end
-- eto dlya Channeling spellov
function CastSpellTimeForActionStart()
	if CAST_STATE_ERROR then
		CastSpellLog(" CastSpellTimeForActionStart after error ")
		return
	end
	Log("CastSpellTimeForActionStart 20times "..tostring(CASTSPELL20TIMES))
	StartPrivateCheckTimer( CASTSPELL_TIME, CastCheck, nil, CastError, nil, CastSuccess, nil )
end

function CastSpellToTarget( targetId, spellId, pos, time, funcPass, funcError, effects, cheat, passParams )
	CastSpellLog("Cast spell to target")
	CASTSPELL_PASS_FUNC = funcPass
	CASTSPELL_PASS_PARAMS = passParams
	CASTSPELL_ERROR_FUNC = funcError
	CASTSPELL_SPELL_ID = spellId
	CASTSPELL_POS = pos
	CASTSPELL_TIME = time
	CASTSPELL_EFFECTS = effects
	CASTSPELL_CHEAT = cheat
	
	CastSpellLog( "Selecting target:" .. tostring(targetId) )
	SelectTarget( targetId, RunCastSpell, funcError )
end

function RunCastSpell()
	CastSpellLog("Run cast spell")
	CastSpell( CASTSPELL_SPELL_ID, CASTSPELL_POS, CASTSPELL_TIME, CASTSPELL_PASS_FUNC, CASTSPELL_ERROR_FUNC, CASTSPELL_EFFECTS, CASTSPELL_CHEAT )	
end

function CastCheck()
	if CAST_STATE_ERROR then
		CastSpellLog(" CastCheck after error " )
		return false
	end
--	if CASTSPELL_CHEAT then
--		return ( CASTSPELL_CHECK or CASTSPELL_STARTED )
--	end
	local action = true
	if CASTSPELL_ACTION_START then
		action = CASTSPELL_ACTION_STOP
	end
	if not CASTSPELL_PREPARED then
	    local spellInfo = avatar.GetSpellInfo( CASTSPELL_SPELL_ID )
	    --CastSpellLog(spellInfo.debugName.." prepared: "..tostring(spellInfo.prepared))
		if CASTSPELL_CHECK then
			return CastSuccess()
		end
		return spellInfo.prepared and action
	end
	
	if CASTSPELL_EFFECTS == nil then
		return CASTSPELL_CHECK-- and CASTSPELL_STARTED
	else
	    local Chk = true
     	for i,effect in CASTSPELL_EFFECTS do
     	    if effect.check ~= nil then
	        	Chk = Chk and effect.check
			end
	    end
	    return CASTSPELL_CHECK and Chk and action
	end
end

function CastPrepared()
	CastSpellLog("Run prepared spell")
	--пора отменять автокаст в либе
	--CastSuccess()
    CastSpell( CASTSPELL_SPELL_ID, CASTSPELL_POS, CASTSPELL_TIME, CASTSPELL_PASS_FUNC, CASTSPELL_ERROR_FUNC, CASTSPELL_EFFECTS )
end

function CastError()
	CAST_STATE_ERROR = true
	StopPrivateCheckTimer()
	StopPrivateTimer()
    StopCastSpellEvents( CASTSPELL_EFFECTS, "CastError" )
    if CASTSPELL_EVENT_DMG_RECEIVED == 0 then
        CastSpellLog("ACHTUNG!!! EVENT_DMG_RECEIVED not coming")
    end
    if CASTSPELL_EVENT_HEAL_RECEIVED == 0 then
        CastSpellLog("ACHTUNG!!! EVENT_HEAL_RECEIVED not coming")
    end
	if CASTSPELL_EVENT_BUFF_RECEIVED == 0 then
	    CastSpellLog("ACHTUNG!!! EVENT_BUFF_RECEIVED not coming!!")
    end
	CASTSPELL_ERROR_FUNC(CASTSPELL_ERROR_TEXT.." code "..CASTSPELL_ERROR_CODE,CASTSPELL_ERROR_CODE)
end

function CastSuccess()
	Log("CastSuccess 20times "..tostring(CASTSPELL20TIMES))
	StopPrivateCheckTimer()
	StopCastSpellEvents( CASTSPELL_EFFECTS, "CastSuccess")
    CASTSPELL_PASS_FUNC(CASTSPELL_PASS_PARAMS)
end
function CastSpellLog(msg)
    Log(msg,"CastSpell")
end

function StopCastSpellEvents( effects, fromFunc)
	--CastSpellLog("stop events "..CASTSPELL_SPELL_NAME.." 20times"..tostring(twentytimes).." func "..fromFunc)
	if not CASTSPELL20TIMES then 
		common.UnRegisterEventHandler( "EVENT_ACTION_FAILED_SPELL" )
		common.UnRegisterEventHandler( "EVENT_ACTION_RESULT_SPECIAL_SPELL" )
		common.UnRegisterEventHandler( "EVENT_ACTION_PROGRESS_START" )			
		common.UnRegisterEventHandler( "EVENT_ACTION_PROGRESS_FINISH" )
		if effects ~= nil then
			for i,effect in effects do
			    if effect.type == EFFECT_DAMAGE then
			    	common.UnRegisterEventHandler( "EVENT_UNIT_DAMAGE_RECEIVED" )
			    	CASTSPELL_EVENT_DMG_RECEIVED = -1
			    elseif effect.type == EFFECT_BUFF then
			    	common.UnRegisterEventHandler( "EVENT_UNIT_BUFFS_CHANGED" )
			    	CASTSPELL_EVENT_BUFF_RECEIVED = -1
			    elseif effect.type == EFFECT_HEAL then
			        common.UnRegisterEventHandler( "EVENT_HEALING_RECEIVED" )
			        CASTSPELL_EVENT_HEAL_RECEIVED = -1
			    end
			end
		end	
	end
end
function StartCastSpellEvents( effects )
	if not CASTSPELL20TIMES then 
		--CastSpellLog("start events "..CASTSPELL_SPELL_NAME)
		common.RegisterEventHandler( OnSpellResult, "EVENT_ACTION_FAILED_SPELL" )
		common.RegisterEventHandler( OnSpellSpecialResult, "EVENT_ACTION_RESULT_SPECIAL_SPELL" )
		common.RegisterEventHandler( OnActionProgressStart, "EVENT_ACTION_PROGRESS_START" )
		common.RegisterEventHandler( OnActionProgressStop, "EVENT_ACTION_PROGRESS_FINISH" )
		if effects ~= nil then
			for i,effect in effects do
			    if effect.type == EFFECT_DAMAGE then
			        common.RegisterEventHandler( OnUnitDamageReceived, "EVENT_UNIT_DAMAGE_RECEIVED" )
			        CASTSPELL_EVENT_DMG_RECEIVED = 0
			    elseif effect.type == EFFECT_BUFF then
			    	common.RegisterEventHandler( OnUnitBuffsChanged, "EVENT_UNIT_BUFFS_CHANGED" )
			    	CASTSPELL_EVENT_BUFF_RECEIVED = 0
			    elseif effect.type == EFFECT_HEAL then
			        common.RegisterEventHandler( OnHealingReceived, "EVENT_HEALING_RECEIVED" )
			        CASTSPELL_EVENT_HEAL_RECEIVED = 0
			    end
			end
		end	
	end
end

-- EVENT_SPELL_RESULT

function OnSpellSpecialResult( params )
	local id = params.spellId
	local spell = avatar.GetSpellInfo(id)

	CastSpellLog( "on spell special result. unitID=" .. tostring(params.unitId) .. " " .. tostring( avatar.GetId() ).." spell "..debugCommon.FromWString(spell.name))
 if params.unitId == avatar.GetId() then --and params.spellId == CASTSPELL_SPELL_ID then
	if params.sysId == "ENUM_ACTION_RESULT_SPECIAL_STARTED" then -- ACTION_STARTED
		CASTSPELL_STARTED = true
		CASTSPELL_ERROR_TEXT = "Prepare Started!, not success Prepare FAIL : timeout"
		CastSpellLog("Spell successfuly started!")
		
	elseif params.sysId == "ENUM_ACTION_RESULT_SPECIAL_LAUNCHED" then --ACTION_LAUNCHED
		CastSpellLog("Spell successfuly launched!")
		if CASTSPELL_EFFECTS ~= nil then
			CASTSPELL_ERROR_TEXT = "Fuck! Effects not appear!!"
		else
		    CASTSPELL_ERROR_TEXT = "Kakayto fignya "
		end
        CASTSPELL_ERROR_CODE = params.sysId
		CASTSPELL_CHECK = true
	else
		--ACTION_FAILED
		if CASTSPELL_STARTED then
			CASTSPELL_ERROR_TEXT = "Prepare Started.. FAIL :"..params.sysId
		else
			CASTSPELL_ERROR_TEXT = "Prepare Not Started FAIL :"..params.sysId
		end
		CASTSPELL_ERROR_CODE = params.sysId

		CastError()
	end
 end
end

function OnSpellResult( params )
	local id = params.spellId
	local spell = avatar.GetSpellInfo(id)
	
	CastSpellLog( "on spell result. unitID=" .. tostring(params.unitId) .. " " .. tostring( avatar.GetId() ).." msg: "..params.sysId.." spell "..debugCommon.FromWString(spell.name))
 --if params.unitId == avatar.GetId() then --and params.spellId == CASTSPELL_SPELL_ID then
	if params.sysId ~= "ENUM_ActionFailCause_NoFail" then
		CASTSPELL_ERROR_CODE = params.sysId
		--ACTION_FAILED
		if CASTSPELL_STARTED then
			CASTSPELL_ERROR_TEXT = "Started, not Launched FAIL :"..params.sysId
		else
			CASTSPELL_ERROR_TEXT = "Not started FAIL :"..params.sysId
		end
		CastError()
    end
-- end
end

-------EVENT_ACTION_PROGRESS_START
function OnActionProgressStart( params )
	CastSpellLog("ACTION PROGRESS START")
	if CASTSPELL_CHANNELING then
		CASTSPELL_ACTION_START = true
	end
end
-------EVENT_ACTION_PROGRESS_STOP
function OnActionProgressStop( params )
	if CASTSPELL_CHANNELING then
		CastSpellLog("ACTION PROGRESS STOP")
		CASTSPELL_ACTION_STOP = true
	end
end


-- EVENT_UNIT_DAMAGE_RECEIVED

function OnUnitDamageReceived( params )
-- source: ObjectId (not nil) - идентификатор того кто наносит повреждения
-- target: ObjectId (not nil) - идентификатор того кто получает повреждения
-- damageSource: number (enum DAMAGE_SOURCE_...) - источник повреждений, константы:
    CASTSPELL_EVENT_DMG_RECEIVED = 1
	for i,effect in CASTSPELL_EFFECTS do
		if effect.type == EFFECT_DAMAGE then
			if params.source == effect.sourceId and params.target == effect.targetId and params.damageSource == effect.damageSource then
	    		CastSpellLog("Damage received " .. tostring( params.source ))
        		effect.check = true
        	end
		end
	end
end


-- EVENT_UNIT_BUFFS_CHANGED
function OnUnitBuffsChanged( params)
-- unitId: ObjectId (not nil)
    CASTSPELL_EVENT_BUFF_RECEIVED = 1
	for i,effect in CASTSPELL_EFFECTS do
		if effect.type == EFFECT_BUFF then
   			if params.unitId == effect.unitId then
   			    local buffInfo = GetBuffInfo( effect.unitId, effect.buffName )
			    if buffInfo ~= nil then
                    CastSpellLog("Buff appeared: "..effect.buffName)
        			effect.check = true
        		end
			end
		end
	end
end

-- EVENT_HEALING_RECEIVED
function OnHealingReceived( params )
-- unitId: ObjectId (not nil) - идентификатор вылеченного юнита
-- healerId: ObjectId (not nil) - идентификатор лекаря
-- heal: number (integer) - на сколько единиц юнит был вылечен
-- spellId: SpellId / nil - Id спелла, которым лечили, если лечили спеллом.
-- critical: boolean - был ли крит при лечении
    CASTSPELL_EVENT_HEAL_RECEIVED = 1
	for i,effect in CASTSPELL_EFFECTS do
		if effect.type == EFFECT_HEAL then
   			if params.unitId == effect.unitId and effect.healerId == params.healerId then -- and CHECKHEAL_SPELLID = params.spellId then
      		CastSpellLog("Heal received!")
        	effect.check = true
        	end
		end
	end
end

function RemoveBuff( buffName )
	for index = 1, unit.GetBuffCount( avatar.GetId() ) do
		if unit.GetBuff( avatar.GetId(), index-1 ).debugName == buffName then
			Log( "remove buff " .. buffName )
			avatar.RemoveBuff( index-1 )
		end
	end
end

function RemoveAllBuffs( )
	for index = 1, unit.GetBuffCount( avatar.GetId() ) do
		Log( "remove buff " .. unit.GetBuff( avatar.GetId(), index-1 ).debugName )
		avatar.RemoveBuff( index-1 )
	end
end
