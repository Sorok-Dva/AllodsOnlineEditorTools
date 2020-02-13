--
-- Global vars
--

Global("TIME_CONST", nil)
Global("KILL_MOB_TEST", "KillMob")

-- GLobal table TAkt
Global("TAKT",nil)
Global("TAKT_LEVEL",nil)
--
Global("KILLMOB_ENEMY_ID",nil)
Global("KILLMOB_ENEMY_KIND",nil)
Global("KILLMOB_ENEMY_ID_SEC",nil)
Global("KILLMOB_AVATAR_ID",nil)
Global("KILLMOB_ENEMY_NAME",nil)
Global("KILLMOB_RANGE_FUNC",nil)
Global("KILLMOB_SUCCESS_FUNC",nil)
Global("KILLMOB_ERROR_FUNC",nil)
Global("KILLMOB_FATALERROR_FUNC",nil)
Global("KILLMOB_ARROW_PARAMS",nil)

-- STATES
Global("STATE", 0)
Global("PREFIGHT",1)
Global("CHOOSE",2)
Global("FIGHT",3)
Global("STATE_WAIT",7)
Global("STATE_ERROR",4)
Global("STATE_SUCCESS",5)
Global("STATE_KILLED",6)

--FOR PREFIGHT
Global("PREFIGHT_KEY", 0)
Global("PRESPELL_FIRST_TRY",true)
Global("PREBUFF_BUFFNAME",nil)
--FOR FIGHT
Global("FIGHT_STEP", nil)
Global("FIGHT_PLAN",nil)
Global("FIGHT_ID",nil)
Global("BLOCK_FIGHT_KEY", 0)
-- For CastSpell
Global("MAX_FAIL_CAUSE", 20)

Global("DISABLED_AMOUNT", 0)
Global("NOT_ENERGY_AMOUNT", 0)
Global("NOT_NOTARGET_AMOUNT", 0)
Global("COUNT_FINISH_AUTOATTACK", 0)

-- for step
Global("AVATAR_SPEED", 5)
Global("SCRIPT_LAG_TIME", 1000)


--FOR CHOOSE
Global("MP_CONDITION",0)
Global("BOT_CHECK_CHOOSE", false)
Global("BOT_ALIVE_FUNC", nil)

Global("KILL_TIME",nil)
Global("AVATAR_DIR",nil)

-- CHECK unit Fight
Global("AGGRO_POINTS",0)
Global("CHECK_UNIT_FIGHT",false)
-- CHECK Damage
Global("DAMAGE_POINTS_AVATAR",0)
Global("DAMAGE_POINTS_UNIT",0)
Global("DAMAGE_POINTS_UNIT_AA",0)
Global("ENEMY_ABILITIES",{})

Global("CASTSPELL_MAX_LAG",5000)
-------===================================================================
------------------------==================================================

function KillMobFatalError( msg )
	SetState(STATE_ERROR)
	LogResult({isError = true, test = KILL_MOB_TEST, text = msg})
	-- TODO
	
	KillMobStopEvents()
	common.LogInfo("common"," fatal error ")
	KILLMOB_FATALERROR_FUNC(msg)
end

function KillMobSuccess(unitdie)
	-- TODO
	KillMobStopEvents()

	common.LogInfo("common"," success ")
	Log("KillMobSucces kill: "..tostring(unitdie))
	local abilki = GetAbilitiesOfEnemy()
	KILLMOB_SUCCESS_FUNC({kill = unitdie, killTime = KILL_TIME, dmgAvatar = DAMAGE_POINTS_AVATAR, dmgUnit = DAMAGE_POINTS_UNIT, dmgUnitAA = DAMAGE_POINTS_UNIT_AA, unitAbilities = abilki, mobKind = KILLMOB_ENEMY_KIND})
end

function KillMobError(text)
	SetState(STATE_ERROR)
	KillMobStopEvents()

	common.LogInfo("common"," error ")
	KILLMOB_ERROR_FUNC(text)
end

function KillMobLog(msg)
	Log("[ZooKillMob]\t"..msg)
end

function SetState(state)
	if state == STATE_ERROR or state == STATE_SUCCESS then
		KillMobLog("STATE set to : "..tostring(state))
    	StopAllTimers()
		if KILLMOB_ENEMY_ID ~= nil then
			KILLMOB_ENEMY_ID = nil
		end
	end
	STATE = state
end

function ArrowsDescript(arrow)
	if arrow == "fire" then
		return "EnchantIncendiaryArrow"
	elseif arrow == "crit" then
		return "EnchantHeartseekingArrow"
	elseif arrow == "sleepy" then
		return "EnchantTranquilArrow"
	elseif arrow == "flash" then
		return "EnchantOverchargedArrow"
	elseif arrow == "uncast" then
		return "EnchantBurrowingArrow"
	else
		KillMobFatalError( "wrong arrow <"..arrow..">" )
	end
end

function ArrowsEnchant( )
	
	if KILLMOB_ARROW_PARAMS.count > 7 then
		return PreFight()
	end
	local arrow = ArrowsDescript(KILLMOB_ARROW_PARAMS.enchant[KILLMOB_ARROW_PARAMS.count])
	local arrId = GetSpellId(arrow)
	
	if arrId ~= nil then
		KILLMOB_ARROW_PARAMS.count = KILLMOB_ARROW_PARAMS.count + 1
		CastSpell(arrId, nil, CASTSPELL_MAX_LAG, StopCastArrow, ErrorArrows, nil, true )
	else
		KillMobError( "cant find arrow in SpellBook <"..arrow..">" )
	end
end

function StopCastArrow( )
	KillMobLog("StopCastArrow")
	avatar.StopCasting( )
	StartTimer(500, ArrowsEnchant, nil)
end

function ErrorArrows(text, code)
	if code == "ENUM_ActionFailCause_Canceled" then
		--return StartTimer(500, ArrowsEnchant, nil)
		return
	end
	KillMobFatalError( text )
end

function PreBuff(buffname)
	--KillMobLog("PreBuff "..buffname)
	PRESPELL_FIRST_TRY = true
	PREBUFF_BUFFNAME = buffname
	local spellId = GetSpellId(buffname)
	if spellId ~= nil then
		CastSpell20Times( spellId, nil, CASTSPELL_MAX_LAG, PreFight, ErrorPreBuff)	
	else
		KillMobLog("cant PreBuff "..buffname)
		PreFight()
	end
end

function ErrorPreBuff(text, code)
	if code == "ENUM_ActionFailCause_Void" then
		return PreFight()
	end
	if PRESPELL_FIRST_TRY then
		PRESPELL_FIRST_TRY = false
		KillMobLog(text)
		CastSpell20Times( GetSpellId(PREBUFF_BUFFNAME), nil, CASTSPELL_MAX_LAG, PreFight, ErrorPreBuff)		
	else
		PreFight()
		--KillMobError("Cant finished prebuff sec time "..text)
	end
end

function PreCheat(xdbCheat)
	qaMission.SendCustomMsg("cast_spell "..xdbCheat)
end

function NecroPet(action)
	if KILLMOB_AVATAR_ID == nil then
	    return nil
	end
	local petId = unit.GetActivePet( KILLMOB_AVATAR_ID )
	if petId == nil then
	    return nil
	end
	if action == "hold" then
		avatar.SetPetAggroMode( PET_AGGRO_DEFENSIVE )
	elseif action == "aggro" then
		avatar.SetPetAggroMode( PET_AGGRO_AGGRESIVE )
	elseif action == "passiv" then
		avatar.SetPetAggroMode( PET_AGGRO_PASSIVE )
	end
end

function PreFight(id, secId)
	if STATE ~= PREFIGHT then
	    return false
	end
	if id ~= nil then
		KILLMOB_ENEMY_ID = id
		KILLMOB_ENEMY_ID_SEC = secId
		KILLMOB_ENEMY_NAME = debugCommon.FromWString(object.GetName( KILLMOB_ENEMY_ID ) )
		KILLMOB_ENEMY_KIND = qaMission.UnitGetKind( id )
	end
	

	for key, value in TAKT[1].conditions do
	  if key>PREFIGHT_KEY then
		if debugCommon.FromWString(value.rule) == "prebuff" then
        	PREFIGHT_KEY = key
			return PreBuff(debugCommon.FromWString(value.param))
		elseif debugCommon.FromWString(value.rule) == "range" then
			PREFIGHT_KEY = key
			return KILLMOB_RANGE_FUNC(PreFight,KillMobError,tonumber(debugCommon.FromWString(value.param)))
		elseif debugCommon.FromWString(value.rule) == "arrows" then
			PREFIGHT_KEY = key
			local params = debugCommon.FromWString(value.param)
			local pos, after, a1,a2,a3,a4,a5,a6,a7 = string.find(params,"(%w*) (%w*) (%w*) (%w*) (%w*) (%w*) (%w*)")
			if pos ~= nil then
				local arrows = {}
				table.insert(arrows,a1)
				table.insert(arrows,a2)
				table.insert(arrows,a3)
				table.insert(arrows,a4)
				table.insert(arrows,a5)
				table.insert(arrows,a6)
				table.insert(arrows,a7)
				KILLMOB_ARROW_PARAMS = {enchant = arrows, count = 1}
				return ArrowsEnchant()
			else
				KillMobFatalError( "wrong arrows num "..params )
			end
		elseif debugCommon.FromWString(value.rule) == "precheat" then
			PreCheat(debugCommon.FromWString(value.param))
		elseif debugCommon.FromWString(value.rule) == "necropet" then
			NecroPet(debugCommon.FromWString(value.param))
		elseif debugCommon.FromWString(value.rule) == "level_min" then
			KillMobLog("level_min "..debugCommon.FromWString(value.param))
  		elseif debugCommon.FromWString(value.rule) == "level_max" then
			KillMobLog("level_max "..debugCommon.FromWString(value.param))
  		elseif debugCommon.FromWString(value.rule) == "level" then
			KillMobLog("level "..debugCommon.FromWString(value.param))
		elseif debugCommon.FromWString(value.rule) == "class" then
			KillMobLog("class "..debugCommon.FromWString(value.param))
		else
			 
  		    return KillMobFatalError("Wrong Taktik. This rev of Bot dont have rule "..debugCommon.FromWString(value.rule))
  		end
  	  end
	end
	return StartFight()
end

function StartFight()
	KillMobLog("StartFight!!!")
	qaMission.AvatarRevive()
	FIGHT_ID = TAKT[1]
	FIGHT_PLAN = TAKT[1].spells
	DAMAGE_POINTS_AVATAR = 0
	DAMAGE_POINTS_UNIT = 0
	DAMAGE_POINTS_UNIT_AA = 0
	ENEMY_ABILITIES = nil
	ENEMY_ABILITIES = {}
	SetState(FIGHT)
	------------------------------------------------------------------------------Start Fight!!!
	AGGRO_POINTS = 0
	CHECK_UNIT_FIGHT = true
	StartTimer1( 15000, CheckUnitFightErr, nil)
	ActiveTime()
	KILL_TIME = TIME_SEC
	StartTimer(500,StartFight1Sec,nil)
end
function StartFight1Sec()
	KillMobStartEventsSpawn()
	BlockFight()
end
function CheckUnitTarget()
	if KILLMOB_ENEMY_ID == nil and ( STATE ~= FIGHT or STATE ~= CHOOSE ) then
	    return false
	else
	    local chk = CheckUnitFight()
		if type(chk) == "boolean" then
			return chk
		end
	    if chk.tgt and chk.aggro and chk.att and chk.inc then
	    	return true
	    else
	    	return false
	    end
    end
end

function CheckUnitFight()
	if ( STATE == FIGHT or STATE == CHOOSE ) and KILLMOB_ENEMY_ID ~= nil then
		local target = unit.GetTarget( KILLMOB_ENEMY_ID )
		local mobAttack = unit.IsAbleToAttack( KILLMOB_ENEMY_ID )
		local inCombat = unit.IsInCombat(KILLMOB_AVATAR_ID)
		if target == nil or mobAttack == nil or inCombat == nil then
			return false
		end
		return {tgt = (KILLMOB_AVATAR_ID == target), att = mobAttack.Mainhand or mobAttack.Offhand or mobAttack.Ranged, aggro = (AGGRO_POINTS > 0), inc = inCombat }
	end
	return false
end

function CheckUnitFightErr()
    local chk = CheckUnitFight()
	if type(chk) == "table" then
		KillMobLog("Enemy targeting you: "..tostring(chk.tgt).."; Able to attack: "..tostring(chk.att).."; Aggressive: "..tostring(chk.aggro).."; and Avatar in combat: "..tostring(chk.inc))
	end
	--KillMobError("Enemy dont fight with you")
	KillMobLog("Enemy dont fight with you")
end

function CheckManaUse(id)
    local class = unit.GetClass( id )
    if class.className == "DRUID" then 
		return class.manaType == MANA_TYPE_MANA
    elseif class.className == "MAGE" then
    	return class.manaType == MANA_TYPE_MANA
    elseif class.className == "NECROMANCER" then
        return class.manaType == MANA_TYPE_MANA
    elseif class.className == "PALADIN" then
        return class.manaType == MANA_TYPE_ENERGY
    elseif class.className == "PRIEST" then
    	return class.manaType == MANA_TYPE_MANA
    elseif class.className == "PSIONIC" then
        return class.manaType == MANA_TYPE_MANA
    elseif class.className == "STALKER" then
        return class.manaType == MANA_TYPE_ENERGY
    elseif class.className == "WARRIOR" then
        return class.manaType == MANA_TYPE_ENERGY
    else
        return false
    end
end

function BlockFight()
	if STATE ~= FIGHT then
	    return false
	end
	if CHECK_UNIT_FIGHT then
		if CheckUnitTarget() then
			CHECK_UNIT_FIGHT = false
			StopTimer1()
		end
	end
	NOT_ENERGY_AMOUNT  = 0
	DISABLED_AMOUNT = 0
	NOT_NOTARGET_AMOUNT  = 0
	COUNT_FINISH_AUTOATTACK = 0
    --KillMobLog("Fight "..STATE.." key "..tostring(BLOCK_FIGHT_KEY).." plan"..tostring(FIGHT_PLAN))
	--ParamsToConsole(FIGHT_PLAN,"PLAN")
	for key, value in FIGHT_PLAN do
		--KillMobLog("key "..tostring(key).." value "..tostring(value))
		if key > BLOCK_FIGHT_KEY then
			--KillMobLog("key "..tostring(key).." value "..tostring(value))
			BLOCK_FIGHT_KEY = key
			FIGHT_STEP = value
			
			return FightStep()
		end
	end
	return FightFinish(false)
end

function needTarget(target)
	local n = tonumber(target)
	if n ~= nil then
		return false
	end
	if target == "target" then
		if KILLMOB_ENEMY_ID == avatar.GetTarget() then
			return false
		end
	elseif target == "self" then
		if KILLMOB_AVATAR_ID == avatar.GetTarget() then
			return false
		end
	elseif target == "none" then
		return false
	else
		KillMobFatalError("Wrong Taktik. This rev of Bot dont have type of target "..target)
		return false
	end
	return true
end

function FightStep()
	if STATE ~= FIGHT then
	    return false
	end
	if needTarget(debugCommon.FromWString(FIGHT_STEP.target)) then
        --KillMobLog("FightStep need target... Select Target..")
		if debugCommon.FromWString(FIGHT_STEP.target) == "target" then
			return SelectTarget( KILLMOB_ENEMY_ID, FightStep, KillMobError ) -- TODO
		elseif debugCommon.FromWString(FIGHT_STEP.target) == "self" then
			return TargetSelf( FightStep1sec, KillMobError) -- TODO
		else
			KillMobFatalError("Wrong Taktik. This rev of Bot dont have type of target "..debugCommon.FromWString(FIGHT_STEP.target))
		end
	else
		if debugCommon.FromWString(FIGHT_STEP.name) == "maxEnergy" then
			KillMobLog("maxEnergy")
			return WaitMaxEnergy()
		elseif debugCommon.FromWString(FIGHT_STEP.name) == "waitEnergy" then
			KillMobLog("waitEnergy - "..debugCommon.FromWString(FIGHT_STEP.target))
			return WaitEnergy(tonumber(debugCommon.FromWString(FIGHT_STEP.target)))
		elseif debugCommon.FromWString(FIGHT_STEP.name) == "step" then
			KillMobLog("Step")
			AVATAR_DIR = avatar.GetDir()
			qaMission.AvatarSetScriptControl( true )
			return StartTimer(SCRIPT_LAG_TIME,runToTarget,nil)
		elseif debugCommon.FromWString(FIGHT_STEP.name) == "magestep" then
			KillMobLog("MageStep")
			qaMission.AvatarSetScriptControl( true )
			return StartTimer(SCRIPT_LAG_TIME,runFromTarget,nil)
		elseif debugCommon.FromWString(FIGHT_STEP.name) == "AutoAttackMelee" then
		    KillMobLog("Enable AutoAttack")
		    avatar.RunSpell(GetSpellId("AutoAttackMelee"))
		    return BlockFight()
		else
			local spellId = GetSpellId(debugCommon.FromWString(FIGHT_STEP.name))
			KillMobLog("cast spell - "..debugCommon.FromWString(FIGHT_STEP.name).." id: "..tostring(spellId).." target "..tostring(KILLMOB_ENEMY_ID))
			if spellId ~= nil then
				CastSpell20Times( spellId , KILLMOB_ENEMY_ID, CASTSPELL_MAX_LAG, BlockFight, ErrorFightStep)	
			else
				KillMobLog("SPELL ID == NIL")
				BlockFight()
			end
		end
	end
end

function ErrorFightStep(text, code)
	--Log("ErrorFightStep "..code)
	if STATE ~= FIGHT then
		Log("State dont Fight "..code.." "..text)
	    return false
	end
	if code == "ENUM_ActionFailCause_NotInFront" then
		-- надо повернутся
		qaMission.AvatarSetScriptControl( true )
		StartTimer(SCRIPT_LAG_TIME , RotateToMob, nil )
		return
	elseif code == "ENUM_ActionFailCause_TooFar" then
	    -- надо забить
     	FightFinish(true)
		return
	elseif code == "ENUM_ActionFailCause_Resisted" then
	    -- надо забить
     	FightFinish(true)
	    return
	elseif code == "ENUM_ActionFailCause_InterruptedMove" then
     	FightFinish(true)
	    return
	elseif code == "ENUM_ActionFailCause_InterruptedDamage" then
		FightFinish(true)
		return
	elseif code == "ENUM_ActionFailCause_Evaded" then
	    -- надо забить
     	FightFinish(true)
	    return
	elseif code == "ENUM_ActionFailCause_Immune" then
		-- надо забить
    	FightFinish(true)
	    return
	elseif code == "ENUM_ActionFailCause_NotEnemy" then
    	if DISABLED_AMOUNT < MAX_FAIL_CAUSE then
			StartTimer(1000,FightStep,true)
			DISABLED_AMOUNT = DISABLED_AMOUNT + 1
			return
		else
			DISABLED_AMOUNT = 0
			KillMobLog("20 times ENUM_ActionFailCause_Disabled or Void or NotEnemy or Dead in one FightStep")
			KillMobError()
			return
		end
	elseif code == "ENUM_ActionFailCause_BarrierInNotActive" then
	    -- надо забить
    	FightFinish(true)
	    return
	elseif code == "ENUM_ActionFailCause_InterruptedMove" then
	    -- надо забить
    	FightFinish(true)
	    return
	elseif code == "ENUM_ActionFailCause_Dead" then
    	if DISABLED_AMOUNT < MAX_FAIL_CAUSE then
			StartTimer(1000,FightStep,true)
			DISABLED_AMOUNT = DISABLED_AMOUNT + 1
			return
		else
			DISABLED_AMOUNT = 0
			KillMobLog("20 times ENUM_ActionFailCause_Disabled or Void or NotEnemy or Dead in one FightStep")
			KillMobError()
			return
		end
	elseif code == "ENUM_ActionFailCause_NotEnoughMana" then
	    -- надо ждать
    	--FightFinish(true)
		KILL_TIME = TIME_SEC - KILL_TIME
		KillMobSuccess(false)
	    return
    elseif code == "ENUM_ActionFailCause_NotEnoughEnergy" then
        -- надо ждать
		--Log("in block")
		if NOT_ENERGY_AMOUNT < MAX_FAIL_CAUSE then
			--Log("amount "..tostring(NOT_ENERGY_AMOUNT).." max "..tostring(MAX_FAIL_CAUSE))
		   	StartTimer(1000,FightStep,nil)
			NOT_ENERGY_AMOUNT = NOT_ENERGY_AMOUNT + 1
			return
		else
			NOT_ENERGY_AMOUNT  = 0
			KillMobError("20 times ENUM_ActionFailCause_NotEnoughEnergy in one FightStep")
			return			
		end
    elseif code == "ENUM_ActionFailCause_NotEnoughCombatAdvantage" then
        -- надо думать =)
    	FightFinish(true)
	    return
		
	elseif code == "ENUM_ActionFailCause_NoTarget" then -------------------------XZ
		if NOT_NOTARGET_AMOUNT < 3 then
			NOT_NOTARGET_AMOUNT = NOT_NOTARGET_AMOUNT + 1 
			StartTimer(500,FightStep,nil)
		else
			NOT_NOTARGET_AMOUNT = 0
			FightFinish(true)
		end
		return
	elseif code == "ENUM_ActionFailCause_Void" then -------------------------XZ
    	if DISABLED_AMOUNT < MAX_FAIL_CAUSE then
			StartTimer(1000,FightStep,true)
			DISABLED_AMOUNT = DISABLED_AMOUNT + 1
			return
		else
			DISABLED_AMOUNT = 0
			KillMobLog("20 times ENUM_ActionFailCause_Disabled or Void or NotEnemy or Dead in one FightStep")
			KillMobError()
			return
		end
	elseif code == "ENUM_ActionFailCause_Disabled" then
    	if DISABLED_AMOUNT < MAX_FAIL_CAUSE then
			StartTimer(1000,FightStep,true)
			DISABLED_AMOUNT = DISABLED_AMOUNT + 1
			return
		else
			DISABLED_AMOUNT = 0
			KillMobLog("20 times ENUM_ActionFailCause_Disabled or Void or NotEnemy or Dead in one FightStep")
			KillMobError()
			return
		end
	elseif code == "ENUM_ActionFailCause_Occupied" then
		-- надо думать =)
    	FightFinish(true)
	    return
	elseif code == "ENUM_ActionFailCause_NoTargetPoint" then
		StartTimer(1000,FightStep,true)
	else
		FightStepQuit(text)
	end
end
function FightStepQuit(text)
	if STATE == FIGHT or STATE == PREFIGHT then
		KillMobError(text)
	end
end

function runFromTarget()
	if not DistToTarget(25) then
		KillMobLog( "runFromTarget not 25 m")
		local avPos = avatar.GetPos()
		local avAbsPos = ToAbsCoord( avPos )
		local moveParams = GetMoveParams( avatar.GetPos(), debugMission.InteractiveObjectGetPos( KILLMOB_ENEMY_ID ))
		moveParams.deltaX = - moveParams.deltaX
		moveParams.deltaY = - moveParams.deltaY
		
		avAbsPos.X = avAbsPos.X + moveParams.deltaX
		avAbsPos.Y = avAbsPos.Y + moveParams.deltaY
		
  		qaMission.AvatarMoveAndRotate( moveParams )
		
		return StartTimer(SCRIPT_LAG_TIME,runToTargetCheck,{pos = avAbsPos,count = 1, func = runFromTarget})
	else
		--qaMission.AvatarSetScriptControl( false )
		return StartTimer(SCRIPT_LAG_TIME,BlockFight,nil)
	end
end

function runToTarget()
	if not inMeleeRange() then
		KillMobLog( "runToTarget not in MeleeRange")
		local avPos = avatar.GetPos()
		local avAbsPos = ToAbsCoord( avPos )

		local moveParams = GetMoveParams( avatar.GetPos(), debugMission.InteractiveObjectGetPos( KILLMOB_ENEMY_ID ))
		avAbsPos.X = avAbsPos.X + moveParams.deltaX
		avAbsPos.Y = avAbsPos.Y + moveParams.deltaY
  		qaMission.AvatarMoveAndRotate( moveParams )
		
		return StartTimer(SCRIPT_LAG_TIME,runToTargetCheck,{pos = avAbsPos,count =1, func = runToTarget})
	else
		--qaMission.AvatarSetScriptControl( false )
		return StartTimer(SCRIPT_LAG_TIME,BlockFight,nil)
	end
end

function runToTargetCheck(params)
	local avPos = avatar.GetPos()
	local avAbsPos = ToAbsCoord( avPos )
	local dX = math.abs(avAbsPos.X - params.pos.X)
	local dY = math.abs(avAbsPos.Y - params.pos.Y)
	if dX < 0.1 and dY < 0.1 then
		return params.func()
	else
		if params.count < 10 then
			params.count = params.count + 1
			KillMobLog("runToTarget second check")
			StartTimer((SCRIPT_LAG_TIME / 2),runToTargetCheck,params)
		else
			KillMobError("cant move and rotat !!!!!!!!!!!!!!!!!!!!!!!!!!1")
		end
	end
end

function GetMoveParams( pos1, pos2 )
	local dir = GetAngleBetweenPoints( pos1, pos2)
	local dX = AVATAR_SPEED * math.cos(dir)
	local dY = AVATAR_SPEED * math.sin(dir)
	Log("MoveParams "..tostring(dX).." "..tostring(dY).." "..tostring(dir).."----------------================" )
	return {
		deltaX = dX,
		deltaY = dY,
		deltaZ = 0,
		yaw = dir
	}
end

function RotateToMobCheck(params)
	local avPos = avatar.GetPos()
	local uPos = debugMission.InteractiveObjectGetPos( KILLMOB_ENEMY_ID )
	local dir = GetAngleBetweenPoints( avPos, uPos)
	local delta = math.abs(dir - params.d)
	if delta < 0.01 then
		--qaMission.AvatarSetScriptControl( false )
		FightStep()
	else
		if params.count < 10 then
			params.count = params.count + 1
			KillMobLog("RotateToTarget second check")
			StartPrivateTimer( (SCRIPT_LAG_TIME / 2), RotateToMobCheck, params )
		else
			KillMobError("cant move and rotate !!!!!!!!!!!!!!!!!!!!!!!!!!2")
		end
	end
end

function RotateToMob()
	KillMobLog( "Rotate to mob "..tostring(avatar.GetDir()), "Zoo" )
	local avPos = avatar.GetPos()
	--ParamsToConsole(avPos,"Avatar Pos")
	local uPos = debugMission.InteractiveObjectGetPos( KILLMOB_ENEMY_ID )
	--ParamsToConsole(uPos,"Enemy Pos")
	local dir = GetAngleBetweenPoints( avPos, uPos)
	if dir == nil then
		KillMobLog( "Rotate to mob Points is same dx = dy = 0 ", "Zoo" )
		return NextFunc()
	end
	KillMobLog( "Rotate to mob dir "..tostring(dir), "Zoo" )
	local moveParams = {
		deltaX = 0,
		deltaY = 0,
		deltaZ = 0,
		yaw = dir
	}
	
	qaMission.AvatarMoveAndRotate ( moveParams )
	return StartPrivateTimer( SCRIPT_LAG_TIME, RotateToMobCheck, {d =  dir, count = 1} )
end

function FightFinish(finish)
    --KillMobLog("FightFinish "..tostring(finish).." "..debugCommon.FromWString(FIGHT_ID.endCondition.type))
	if STATE ~= FIGHT then
	    return false
	end
	if finish then
		SetState( CHOOSE )
		--StartTimer(SCRIPT_LAG_TIME,BotChoose,nil)
		StartTimer(2000,BotChoose,nil)
	else
		if debugCommon.FromWString(FIGHT_ID.endCondition.type) == "instant" then
		    FightFinish(true)
		elseif debugCommon.FromWString(FIGHT_ID.endCondition.type) == "IfDotIfCAThenEnergy" then
			local params = debugCommon.FromWString(FIGHT_ID.endCondition.param)
			local pos, after, dotName, CAamount, energy = string.find(params,"(%w*) (%w*) (%w*)")
			if UnitHaveBuff(KILLMOB_ENEMY_ID, dotName, nil) and AvatarHaveCA( tonumber(CAamount) ) then
				WaitEnergy(tonumber(energy),true)
			else
				FightFinish(true)
			end
		elseif debugCommon.FromWString(FIGHT_ID.endCondition.type) == "buff" then
			StartCheckTimer( 30000, CheckBuffOnPers, debugCommon.FromWString(FIGHT_ID.endCondition.param), KillMobError, "Buff not disapper, Cant finish block fight", FightFinish, true )
		elseif debugCommon.FromWString(FIGHT_ID.endCondition.type) == "AutoAttack" then
		    if AutoAttackActive() then
				FightFinish(true)
				COUNT_FINISH_AUTOATTACK = 0
			else
				avatar.RunSpell(GetSpellId("AutoAttackMelee"))
				if COUNT_FINISH_AUTOATTACK < 6 then
					COUNT_FINISH_AUTOATTACK = COUNT_FINISH_AUTOATTACK + 1
					StartTimer(600,FightFinish,false)
				else
					COUNT_FINISH_AUTOATTACK = 0
					KillMobError("6 times autoattack not enable 4 сек")
				end
			end
		elseif debugCommon.FromWString(FIGHT_ID.endCondition.type) == "distance" then
			FightFinish(true)
		else
		    KillMobFatalError("Wrong Taktik. This rev of Bot dont have endCondition rule "..debugCommon.FromWString(value.rule))
		end
	end
end

function CheckBuffOnPers(buffname,id)
	if STATE == FIGHT or STATE == CHOOSE then
		local have = UnitHaveBuff(KILLMOB_AVATAR_ID,buffname, nil)
		return not have
	end
	return false
end

function WaitMaxEnergy()
	local mp = unit.GetMana( KILLMOB_AVATAR_ID )
	if mp.percents < 95 then
		return StartTimer(1000,WaitMaxEnergy,nil)
	else
		return BlockFight()
	end
end

function WaitEnergy(amount,ending)
	local mp = unit.GetMana( KILLMOB_AVATAR_ID )
	if mp.percents < amount then
		return StartTimer(1000,WaitEnergy,amount)
	else
		if ending ~= nil then
			return FightFinish(true)
		else
			return BlockFight()
		end
	end
end

function ZooKillMobCheckAlive(passFunc)
	LogToAccountFile("ZooKillMobCheckAlive")
	KillMobLog("----------====================--------CHECK ALIVE")
	BOT_CHECK_CHOOSE = true
	BOT_ALIVE_FUNC = passFunc
end

function BotChoose()
  if STATE ~= CHOOSE then
  	return false
  end
  LogToAccountFile("BotChoose")
  if BOT_CHECK_CHOOSE then
	BOT_CHECK_CHOOSE = false
	LogToAccountFile("ZooKillMobAlive")
	KillMobLog("----------====================--------IM ALIVE!!!!!!!!")
	BOT_ALIVE_FUNC()
  end

  local condition = 0
  for k, ik in TAKT_LEVEL do
	local v = TAKT[ik]
	local spellName = debugCommon.FromWString(v.spells[1].name)
	KillMobLog("--------------Choose "..tostring(ik).." spell "..spellName)
	condition = 0
	MP_CONDITION = 0
	for key, value in v.conditions do
		if debugCommon.FromWString(value.rule) == "nodot" then
			if UnitHaveBuff(KILLMOB_ENEMY_ID,debugCommon.FromWString(value.param), nil, 1000) then
			   condition = condition + 1
			   break
			end
		elseif debugCommon.FromWString(value.rule) == "nobuff" then
			if UnitHaveBuff(KILLMOB_AVATAR_ID,debugCommon.FromWString(value.param), nil) then
			   condition = condition + 1
			   break
			end
		elseif debugCommon.FromWString(value.rule) == "havemp" then
			if not AvatarHaveMp(tonumber(debugCommon.FromWString(value.param))) then
				condition = condition + 1
				break
			end
		elseif debugCommon.FromWString(value.rule) == "havempoints" then
			if not AvatarHaveMPoints(tonumber(debugCommon.FromWString(value.param))) then
				condition = condition + 1
				break
			end
		elseif debugCommon.FromWString(value.rule) == "hpless" then
			if not AvatarHpLess(tonumber(debugCommon.FromWString(value.param))) then
				condition = condition + 1
				break
			end
		elseif debugCommon.FromWString(value.rule) == "active" then
			if not AvatarActiveSpell(debugCommon.FromWString(value.param)) then
				condition = condition + 1
				break
			end
		elseif debugCommon.FromWString(value.rule) == "havebuff" then
			if not UnitHaveBuff(KILLMOB_AVATAR_ID,debugCommon.FromWString(value.param), nil) then
				condition = condition + 1
				break
			end
		elseif debugCommon.FromWString(value.rule) == "targetusemana" then
			if not UnitUseMana() then
				condition = condition + 1
				break
			end
		elseif debugCommon.FromWString(value.rule) == "targetNotUseMana" then
			if UnitUseMana() then
				condition = condition + 1
				break
			end
		elseif debugCommon.FromWString(value.rule) == "AvatarHaveDotGroup" then
			local dotGroup = {}
			
			    dotGroup = debugCommon.FromWString(value.param)
		    if not UnitHaveDotGroup( KILLMOB_AVATAR_ID, dotGroup ) then
				condition = condition + 1
				break
			end
		elseif debugCommon.FromWString(value.rule) == "UnitNoDotGroup" then
			local dotGroup = debugCommon.FromWString(value.param)
		    if not UnitHaveDotGroup( KILLMOB_ENEMY_ID, dotGroup ) then
				condition = condition + 1
				break
			end
		elseif debugCommon.FromWString(value.rule) == "range" then
			if not DistToTarget(tonumber(debugCommon.FromWString(value.param))) then
				condition = condition + 1
				break
			end
		elseif debugCommon.FromWString(value.rule) == "rangelesser" then
			if DistToTarget(tonumber(debugCommon.FromWString(value.param))) then
				condition = condition + 1
				break
			end
		elseif debugCommon.FromWString(value.rule) == "meleerange" then
            --if not DistLesser(5,"meleerange") then
			if not inMeleeRange() then
				condition = condition + 1
				break
			end
		elseif debugCommon.FromWString(value.rule) == "notmeleerange" then
            --if DistLesser(5,"notmeleerange") then
			if inMeleeRange() then
				condition = condition + 1
				break
			end
		elseif debugCommon.FromWString(value.rule) == "AutoAttackActive" then
			condition = condition + 1
			break
		elseif debugCommon.FromWString(value.rule) == "canons" then
			if not haveItemInBag("Mechanics/Spells/Paladin/Canon/Item.xdb",tonumber(debugCommon.FromWString(value.param))) then
				condition = condition + 1
				break
			end
		elseif debugCommon.FromWString(value.rule) == "tgthp" then
			if not TargetHp(tonumber(debugCommon.FromWString(value.param))) then
				condition = condition + 1
				break
			end
		elseif debugCommon.FromWString(value.rule) == "tgthpbigger" then
			if TargetHp(tonumber(debugCommon.FromWString(value.param))) then
				condition = condition + 1
				break
			end
		elseif debugCommon.FromWString(value.rule) == "barrier" then
			if not BarrierBigger(tonumber(debugCommon.FromWString(value.param))) then
				condition = condition + 1
				break
			end
		elseif debugCommon.FromWString(value.rule) == "havedot" then
			if not UnitHaveBuff(KILLMOB_ENEMY_ID,debugCommon.FromWString(value.param), nil, 1000) then
				condition = condition + 1
				break
			end
		elseif debugCommon.FromWString(value.rule) == "havedotmax" then
			if not UnitHaveBuff(KILLMOB_ENEMY_ID,debugCommon.FromWString(value.param), false) then
				condition = condition + 1
				break
			end
		elseif debugCommon.FromWString(value.rule) == "nodotmax" then
			if not UnitHaveBuff(KILLMOB_ENEMY_ID,debugCommon.FromWString(value.param), false, nil, true) then
				condition = condition + 1
				break
			end
		elseif debugCommon.FromWString(value.rule) == "haveCA" then
			if not AvatarHaveCA(tonumber(debugCommon.FromWString(value.param))) then
				condition = condition + 1
				break
			end
		elseif debugCommon.FromWString(value.rule) == "havePC" then
			if not AvatarHavePC(tonumber(debugCommon.FromWString(value.param))) then
				condition = condition + 1
				break
			end
		elseif debugCommon.FromWString(value.rule) == "haveBP" then
			if not AvatarHaveBP(tonumber(debugCommon.FromWString(value.param))) then
				condition = condition + 1
				break
			end
		elseif debugCommon.FromWString(value.rule) == "abledisarm" then
			--if not UnitAbleToDisarm() then
				condition = condition + 1
				break
			--end
		elseif debugCommon.FromWString(value.rule) == "havearrows" then
			if AvatarHaveArrows() then
				condition = condition + 1
				break
			end
		elseif debugCommon.FromWString(value.rule) == "donthavemp" then
			if AvatarHaveMp(tonumber(debugCommon.FromWString(value.param))) then
				condition = condition + 1
				break
			end
		elseif debugCommon.FromWString(value.rule) == "nothaveinstmax" then
			if UnitHaveBuff(KILLMOB_AVATAR_ID,debugCommon.FromWString(value.param), true) then
				condition = condition + 1
				break
			end
		elseif debugCommon.FromWString(value.rule) == "haveinstmax" then
			if not UnitHaveBuff(KILLMOB_AVATAR_ID,debugCommon.FromWString(value.param), true) then
				condition = condition + 1
				break
			end
		elseif debugCommon.FromWString(value.rule) == "speed" then
			local sp = debugMission.UnitGetSpeed( KILLMOB_ENEMY_ID )
			sp = tonumber(sp.effective)
			KillMobLog("CHOOSE speed "..tostring(sp))
			if sp ~= nil then
				if sp < 0.01 then
					condition = condition + 1
				end
			else
				condition = condition + 1
			end
			break
		else
  		    KillMobFatalError("Wrong Taktik. This rev of Bot dont have condition rule "..debugCommon.FromWString(value.rule))
  		end
  		--KillMobLog("inchoose "..debugCommon.FromWString(value.rule).." condition = "..tostring(condition))
	end
	if STATE ~= CHOOSE then
		return false
	end
	if condition == 0 then
		FIGHT_ID = v
		FIGHT_PLAN = v.spells
		BLOCK_FIGHT_KEY = 0
		SetState( FIGHT)
        return BlockFight()
	end
  end
  StartTimer(TIME_CONST,BotChoose,nil)
end

function AvatarHaveArrows()
	local arrows = avatar.GetStalkerCartridgeArrows()
	if arrows == nil then
		return false
	end
	local count = 0
	for arrow in arrows do
		count = count + 1
	end
	if count > 0 then
		return true
	end
	return false
end
function AvatarHaveCA( amount )
	local cA = avatar.GetWarriorCombatAdvantage()
	KillMobLog("CHOOSE AvatarHaveCA - "..tostring(cA).." need "..tostring(amount))
	if cA ~= nil then
		if cA >= amount then
			return true
		end
	end
	return false
end
function AvatarHavePC( amount )
	local pc = avatar.GetDruidPetCommandPoints()
	KillMobLog("CHOOSE AvatarHavePC - "..tostring(pc).." need "..tostring(amount))
	if pc ~= nil then
		if type(pc.value) == "number" then
			if pc.value >= amount then
				return true
			end
		end
	end
	return false
end
function AvatarHaveBP( amount )
	local bloodPool = avatar.GetNecromancerBloodPool()
	if bloodPool == nil then
		return false
	end
	if bloodPool.value ~= nil then
		KillMobLog("CHOOSE AvatarHaveBP - "..tostring(bloodPool.value).." need "..tostring(amount))
		if type(bloodPool.value) == "number" then
			if bloodPool.value >= amount then
				return true
			end
		end
	end
	return false
end
function UnitAbleToDisarm()

	return false
end

function AvatarActiveSpell(spellname)
  if STATE ~= CHOOSE and STATE ~= FIGHT and STATE ~= PREFIGHT then
  	return false
  end
	local spellID = GetSpellId(spellname)
	local spellinfo = avatar.GetSpellInfo(spellID)
	KillMobLog("CHOOSE AvatarActive Spell: Cooldown "..tostring(spellinfo.cooldownRemainingMs).." spell "..spellinfo.debugName)
	if spellinfo.cooldownRemainingMs > 1001 then
		return false
	else
		return true
	end
	--return spellinfo.enabled
end

function UnitHaveBuff(unitId,buffname,stackMage,remaining, nomaxstack)
	if STATE ~= CHOOSE and STATE ~= FIGHT and STATE ~= PREFIGHT then
		return false
	end
	local activeBuffs = unit.GetBuffCount(unitId)
	local checkTime = true
	while activeBuffs > 0 do
		local buff = unit.GetBuff( unitId, activeBuffs -1)
		KillMobLog("CHOOSE UnitHaveBuff - "..buff.debugName.." "..tostring(buff.remainingMs))
		if string.find(buff.debugName, buffname) then
		    if remaining ~= nil then
				checkTime = ( buff.remainingMs >= remaining )
			end
			if stackMage ~= nil then
				local maxStack = false
				if stackMage then
					KillMobLog("Stack for MAGE")
					maxStack = ( buff.stackCount + 1 == buff.stackLimit )
				else
					maxStack = ( buff.stackCount == buff.stackLimit )
				end
				KillMobLog("StackIsMax: "..tostring(maxStack).." buff.stackCount "..tostring(buff.stackCount).." buff.stackLimit "..tostring(buff.stackLimit))
				if nomaxstack ~= nil then
					return ( not maxStack ) and checkTime 
				end
					return maxStack and checkTime
			else
				return checkTime
			end
		end 
		activeBuffs = activeBuffs - 1
	end
	return false
end

function AvatarHaveMp(amount)
  if STATE ~= CHOOSE and STATE ~= FIGHT and STATE ~= PREFIGHT then
  	return false
  end
	local mp = unit.GetMana( KILLMOB_AVATAR_ID )
	
	MP_CONDITION = MP_CONDITION + (mp.maxMana*amount/100)
	KillMobLog("CHOOSE AvatarHaveMp - "..tostring(mp.mana).." need - "..tostring(MP_CONDITION))
	if mp.mana >= MP_CONDITION then
		return true
	end
	return false
end
function AvatarHaveMPoints(amount)
  if STATE ~= CHOOSE and STATE ~= FIGHT and STATE ~= PREFIGHT then
  	return false
  end
	MP_CONDITION = MP_CONDITION + amount
	local mp = unit.GetMana( KILLMOB_AVATAR_ID )
	KillMobLog("CHOOSE AvatarHaveMPoints - "..tostring(mp.mana).." need "..tostring(MP_CONDITION))
	if mp.mana > MP_CONDITION then
		return true
	end
	return false
end

function AvatarHpLess(amount)
  if STATE ~= CHOOSE and STATE ~= FIGHT and STATE ~= PREFIGHT then
  	return false
  end
	local hp = unit.GetHealthPercentage( KILLMOB_AVATAR_ID )
	KillMobLog("CHOOSE AvatarHpLess - "..tostring(hp).." need - "..tostring(amount))
	if hp < amount then
		return true
	end
	return false
end
function UnitUseMana(amount)
  if STATE ~= CHOOSE and STATE ~= FIGHT and STATE ~= PREFIGHT then
  	return false
  end
	local class = unit.GetClass( KILLMOB_ENEMY_ID )
	KillMobLog("CHOOSE UnitUseMana - "..tostring(class.manaType).."need - 0")
	if class.manaType == 0 then
		return true
	end
	return false
end
function UnitHaveDotGroup(unitId,dotGroups)
  if STATE ~= CHOOSE and STATE ~= FIGHT and STATE ~= PREFIGHT then
  	return false
  end
	local activeBuffs = unit.GetBuffCount(unitId)
	while activeBuffs > 0 do
		local buff = unit.GetBuff( unitId, activeBuffs -1)
		if not buff.isPositive then
		    KillMobLog("AvatarHaveDot..."..dot_group)
			if dotGroups ~= nil then
				for numb, debugGroup in buff.debugGroups do
					for igroup, needGroup in dotGroups do
						if string.find(debugGroup,needGroup) then
							
						end
					end
				end
			end
		end
		activeBuffs = activeBuffs - 1
	end
	return false
end
function DistToTarget(value)
  if STATE ~= CHOOSE and STATE ~= FIGHT and STATE ~= PREFIGHT then
  	return false
  end
    local dist = GetDistanceFromPosition(KILLMOB_ENEMY_ID,avatar.GetPos())
	KillMobLog("CHOOSE DistToTarget - "..tostring(dist).." need - "..tostring(value))
    return dist >= value
end
function DistLesser(value)
  if STATE ~= CHOOSE and STATE ~= FIGHT and STATE ~= PREFIGHT then
  	return false
  end
    local dist = GetDistanceFromPosition(KILLMOB_ENEMY_ID,avatar.GetPos())
	KillMobLog("CHOOSE DistLesser "..tostring(dist))
	local result = (dist <= value)
    return result
end

function inMeleeRange()
  if STATE ~= CHOOSE and STATE ~= FIGHT and STATE ~= PREFIGHT then
  	return false
  end
	return DistLesser(4)
	--return avatar.IsTargetInMeleeRange()
end
function AutoAttackActive()
  if STATE ~= CHOOSE and STATE ~= FIGHT and STATE ~= PREFIGHT then
  	return false
  end
	local autoAttack = avatar.GetAutoattack()
	if STATE == CHOOSE then
		KillMobLog("CHOOSE AutoAttackActive - "..tostring(autoAttack.isOn).."need - 0")
	end
	if STATE == FIGHT then
		KillMobLog("FightFinish AutoAttackActive - "..tostring(autoAttack.isOn).."need - 1")
	end
	if autoAttack.isOn == 0 then
	    return false
	else
	    return true
	end
end

function BarrierBigger(percent)                                         
  if STATE ~= CHOOSE and STATE ~= FIGHT and STATE ~= PREFIGHT then
  	return false
  end

	local avHp = unit.GetHealth( KILLMOB_AVATAR_ID )
	local maxDmg = avHp.maxHealth * percent / 100
	local barriers = avatar.GetBarriersInfo()
	KillMobLog("CHOOSE BarrierBigger - Dmg in 1 barrier "..tostring(barriers[0].damage).." time "..tostring(barriers[0].remainingTimeMs).." need "..tostring(maxDmg))
	if barriers[0].damage > maxDmg and barriers[0].remainingTimeMs > 1000 then
	    return true
	end
	return false
end

function TargetHp(percent)
  if STATE ~= CHOOSE and STATE ~= FIGHT and STATE ~= PREFIGHT then
  	return false
  end
    --KillMobLog("TargetHp...")
	local hp = unit.GetHealthPercentage( KILLMOB_ENEMY_ID )
	KillMobLog("CHOOSE TargetHp - "..tostring(hp).." need "..tostring(percent))
	if hp < percent then
		return true
	end
	return false
end

function haveItemInBag(item,count)
  if STATE ~= CHOOSE and STATE ~= FIGHT and STATE ~= PREFIGHT then
  	return false
  end
	local numberInBag = GetCountItem( item )
	KillMobLog("CHOOSE HaveItemInBag in bag "..tostring(numberInBag).." need "..tostring(count))
	if numberInBag >= count then
		return true
	end
	return false
end
---------------------------------------

--------------------------------------------------------------------------------
------------------------------------------------------------%% EVENTS %%--------
--------------------------------------------------------------------------------
-----------------------------------------------------%%% EVENT_UNIT_SPAWNED %%%--
function OnUnitSpawnedKillMob( params )
	--Log("unitSpawn!!!!!")
	if STATE == STATE_WAIT and KILLMOB_AVATAR_ID ~= nil then
		Log("unitSpawn! in state WAIT")
		local aggroList = debugMission.UnitGetAggroList( params.unitId )
		if aggroList ~= nil then
			Log("unitSpawn! aggro not nil")
			for key,value in aggroList do
				if key ~= nil then
					if key == KILLMOB_AVATAR_ID then
						Log("unitSpawn! in aggro avatarId")
						local aggro = ( AGGRO_POINTS * 3 / 4 )
						if value > aggro then
							KILLMOB_ENEMY_ID = params.unitId
							KillMobLog("PrimaryTarget spawned")
							SetState(CHOOSE)
							BotChoose()
						end
					end
				end
			end
		end
	end
end
-----------------------------------------------------%%% EVENT_UNIT_DESPAWNED %%%--
function OnUnitDespawnedKillMob( params )
	Log("unitDespawn!!!!!")
	if STATE == FIGHT or STATE == CHOOSE then
		if params.unitId == KILLMOB_ENEMY_ID then
			
			KILLMOB_ENEMY_ID = nil
			KillMobLog("PrimaryTarget despawned")
			SetState(STATE_WAIT)
		end
	end
	if KILLMOB_ENEMY_ID_SEC ~= nil then
		if params.unitId == KILLMOB_ENEMY_ID_SEC then
			KillMobLog("SecondTarget propal")
			KILLMOB_ENEMY_ID_SEC = nil
		end
	end
end
-----------------------------------------------%%% EVENT_UNIT_FACTION_CHANGED %%%--
function OnUnitFactionChanged( params )
	if KILLMOB_ENEMY_ID == params.unitId then
		local faction = unit.GetFaction( params.unitId )
		if faction.isFriend then
			SetState(STATE_KILLED)
			KILL_TIME = TIME_SEC - KILL_TIME
			StopTimer()
			StartTimer(2000,KillMobSuccess,true)
		end
	end
end
-----------------------------------------------%%% EVENT_UNIT_DEAD_CHANGED %%%--
function OnUnitDeadChanged( params )
-- поля:
-- unitId: ObjectId (not nil)
	local unitIsDead = unit.IsDead( params.unitId )

	if KILLMOB_ENEMY_ID == params.unitId and unitIsDead then
        SetState(STATE_KILLED)
        KILL_TIME = TIME_SEC - KILL_TIME
		StopTimer()
		StartTimer(2000,KillMobSuccess,true)
  	end
	if KILLMOB_AVATAR_ID == params.unitId and unitIsDead then
        SetState(STATE_KILLED)
		KILL_TIME = TIME_SEC - KILL_TIME
		StopTimer()
    	StartTimer(2000,KillMobSuccess,false)
	end
end
------------------------------------------------- EVENT_UNIT_AGGRO_LIST_CHANGED
function OnUnitAggroListChanged( params )
	local enemyId = KILLMOB_ENEMY_ID
	local avatarId = KILLMOB_AVATAR_ID
	if enemyId ~= nil and avatarId ~= nil then
		if params.unitId == enemyId then
			if STATE == FIGHT or STATE == CHOOSE then
				local aggroList = debugMission.UnitGetAggroList( params.unitId )
				if aggroList ~= nil then
					for key,value in aggroList do
						if key ~= nil then
							if key == avatarId then
								AGGRO_POINTS = value
							--KillMobLog("AggroPoints: "..tostring(value))
							end
						end
					end
				end
			end
		end
	end
end

--------------------------------------------------- EVENT_UNIT_DAMAGE_RECEIVED
Global("BOT_STAT", nil)

function BotStatInit()
	BOT_STAT = {}
	BOT_STAT.dmg = 0
	BOT_STAT.count = 0
	BOT_STAT.tomb = BotStatInitCCSpell()
	BOT_STAT.fire = BotStatInitSpell()
	BOT_STAT.shock = BotStatInitSpell()
end

function BotStatInitSpell()
	return {Min = -1, Max = -1, RelMin = -1, RelMax = -1, AbsMin = -1, AbsMax = -1, Resisted = 0, Count = 0, fullResist = 0, withoutResist = 0, fullAbsorb = 0, Crit = 0, noAbsorb = 0, dmg = 0, dmgCount = 0}
end
function BotStatInitCCSpell()
	return {Resisted = 0, Count = 0}
end

function BotStatLog()
	for i, v in BOT_STAT do
		if type(v) == "table" then
			LogToAccountFile(tostring(i), true)
			for k, t in v do
				LogToAccountFile(tostring(k).." : "..tostring(t), true)
			end
		end
	end
	local rel = BOT_STAT.dmg / BOT_STAT.count
	LogToAccountFile("DAMAGE "..tostring(BOT_STAT.dmg).." relative "..tostring(rel), true)
end

function BotStatAddDmg(damag)
   	if BOT_STAT == nil then
	    return nil
	end
	BOT_STAT.dmg = BOT_STAT.dmg + damag
	BOT_STAT.count = BOT_STAT.count + 1
end

function BotStatAddMin(cur, amount)
	--common.LogInfo("common","BOTSTATAddMIN "..tostring(cur).." : "..tostring(amount))
	if cur == -1 then
		return amount
	else
		if cur > amount then
			return amount
		else
			return cur
		end
	end
end

function BotStatAddMax(cur, amount)
	if cur == -1 then
		return amount
	else
		if cur < amount then
			return amount
		else
			return cur
		end
	end
end

function BotStatAddSpell(spell,isResisted, amount, resist, fullResist, absorb, fullAbsorb, crit)
	--for k, t in spell do
	--	common.LogInfo("common",tostring(k).." : "..tostring(t))
	--end

	spell.Count = spell.Count + 1
	if isResisted then
		spell.Resisted = spell.Resisted + 1
	end
	if crit then
		if amount ~= nil then
			amount = amount / 2
		end
		if resist ~= nil then
			resist = resist / 2
		end
		spell.Crit = spell.Crit + 1
	end
	if fullResist then
		spell.fullResist = spell.fullResist + 1
	end
	if fullResist == nil and fullAbsorb == nil then
		spell.Min = BotStatAddMin(spell.Min, amount)
		spell.Max = BotStatAddMax(spell.Max, amount)
		spell.dmg = spell.dmg + amount
		spell.dmgCount = spell.dmgCount + 1
		if resist ~= nil then
			local relResist = resist * 100 / amount
			spell.RelMin = BotStatAddMin(spell.RelMin, relResist)
			spell.RelMax = BotStatAddMax(spell.RelMax, relResist)
		else
			spell.withoutResist = spell.withoutResist + 1
		end
	end
	if fullAbsorb then
		spell.fullAbsorb = spell.fullAbsorb + 1
	end
	if absorb ~= nil then
		spell.AbsMin = BotStatAddMin(spell.AbsMin, absorb)
		spell.AbsMax = BotStatAddMax(spell.AbsMax, absorb)
	else
		spell.noAbsorb = spell.noAbsorb + 1
	end
end

function BotStatAddCCSpell(spell,isResisted)
	spell.Count = spell.Count + 1
	if isResisted then
		spell.Resisted = spell.Resisted + 1
	end
end

function OnUnitDamageReceived(params)
	if KILLMOB_ENEMY_ID ~= nil and KILLMOB_AVATAR_ID ~= nil then
		if params.target == KILLMOB_AVATAR_ID and params.source == KILLMOB_ENEMY_ID then
			--dps моба
			local dmgAmount = 0
			if params.amount ~= nil then
			    dmgAmount = params.amount
			end
			DAMAGE_POINTS_UNIT = DAMAGE_POINTS_UNIT + dmgAmount
			-- statBot
			if params.amount ~= nil then
				BotStatAddDmg(dmgAmount)
			end
			-- endStatBot
			if params.ability ~= nil then
				if params.spellId ~= nil then
					--TODO вносим
					local sinfo = avatar.GetSpellInfo( params.spellId )
					EnemyUseAbility( sinfo.debugName, "dmg", dmgAmount )
				end
				if params.abilityId ~= nil then
					--TODO вносим
					local ainfo = avatar.GetAbilityInfo(params.abilityId)
					EnemyUseAbility( ainfo.sysInfo, "dmgA", dmgAmount )
				end
			end
		end
		if params.target == KILLMOB_ENEMY_ID and params.source == KILLMOB_AVATAR_ID then
			--dps аватара.
			DAMAGE_POINTS_AVATAR = DAMAGE_POINTS_AVATAR + params.amount
			-- statBot
			if params.damageSource == DAMAGE_SOURCE_SPELL then
				local SpellName = nil
				if params.spellId ~= nil then
					local spInfo = avatar.GetSpellInfo(params.spellId)
					SpellName = spInfo.debugName
				end
				if SpellName ~= nil and BOT_STAT ~= nil then
					if string.find(SpellName,"FireArrow") then
						--common.LogInfo("common",tostring(params.isResisted).." "..tostring(params.amount).." "..tostring(params.resist).." "..tostring(params.fullResist).." "..tostring(params.absorb).." "..tostring(params.fullAbsorb))
						BotStatAddSpell(BOT_STAT.fire,params.isResisted, params.amount, params.resist, params.fullResist, params.absorb, params.fullAbsorb, params.criticalDamage)
					end
					if string.find(SpellName,"ShockingGrasp") then
						BotStatAddSpell(BOT_STAT.shock,params.isResisted, params.amount, params.resist, params.fullResist, params.absorb, params.fullAbsorb, params.criticalDamage)
					end
					if string.find(SpellName,"IceTomb") then
						BotStatAddCCSpell(BOT_STAT.tomb,params.isResisted)
					end
				end
			end
			-- end Stat bot
		end
	end
end
--------------------------------------------------------------------CHECK MANA
function CheckMana(ability)
	if KILLMOB_ENEMY_ID ~= nil then
		local unitMana = unit.GetManaPercentage( KILLMOB_ENEMY_ID )
		if unitMana == nil then
			return
		end
		if unitMana < 100 then
			LogToAccountFile(KILLMOB_ENEMY_NAME.."\tUSE\t"..ability)
		else
			LogToAccountFile(KILLMOB_ENEMY_NAME.."\tNOT\t"..ability)
		end
	end
end

function OnUnitBuffsChanged( params )
	if params.unitId == KILLMOB_ENEMY_ID then
		local activeBuffs = unit.GetBuffCount(params.unitId)
		for i = 0, activeBuffs - 1, 1 do
			local buff = unit.GetBuff( params.unitId, i )
			if buff.isPositive then	
				-- TODO вносим sysName
				EnemyUseAbility( buff.debugName, "positive" )
				-- TODO лог debugGroups
				for k, v in buff.debugGroups do
					LogToAccountFile(tostring(k).." - "..tostring(v))
				end
			end
		end
	end
	if params.unitId == KILLMOB_AVATAR_ID then
		local activeBuffs = unit.GetBuffCount(params.unitId)
		for i = 0, activeBuffs - 1, 1 do
			local buff = unit.GetBuff( params.unitId, i )
			if not buff.isPositive then	
				-- TODO вносим sysName
				EnemyUseAbility( buff.debugName, "negative" )
				-- TODO лог debugGroups
				for k, v in buff.debugGroups do
					LogToAccountFile(tostring(k).." - "..tostring(v))
				end
			end
		end
	end
end

function EnemyUseAbility(xdb,txt, dmg)
	LogToAccountFile("EnemyUseAbility "..xdb)
	if xdb == "Mechanics/GameRoot/NoSpell.xdb" then
		DAMAGE_POINTS_UNIT_AA = DAMAGE_POINTS_UNIT_AA + dmg
		return
	end
	local nilcheck = true
	for i, a in ENEMY_ABILITIES do
		if a == xdb then
			nilcheck = false
		end
	end
	if nilcheck then
		table.insert(ENEMY_ABILITIES, xdb)
	end
	CheckMana(xdb)
end

function GetAbilitiesOfEnemy()
	local ret = ""
	for i, a in ENEMY_ABILITIES do
		if i > 1 then
			ret = ret .. "," .. a
		else
			ret = a
		end
		LogToAccountFile(ret)
	end
	ret = ret.."!"
	LogToAccountFile(ret)
	return ret
end
--
-- main initialization function
--
function KillMobStartEventsSpawn()
	common.RegisterEventHandler( OnUnitSpawnedKillMob, "EVENT_UNIT_SPAWNED" )
	common.RegisterEventHandler( OnUnitDespawnedKillMob, "EVENT_UNIT_DESPAWNED" )
end

function KillMobStopEventsSpawn()
	common.UnRegisterEventHandler( "EVENT_UNIT_SPAWNED" )
	common.UnRegisterEventHandler( "EVENT_UNIT_DESPAWNED" )
end

function KillMobStartEvents()
	common.LogInfo("common"," start events KILL MOB")
    common.RegisterEventHandler( OnUnitDeadChanged, "EVENT_UNIT_DEAD_CHANGED")
	common.RegisterEventHandler( OnUnitFactionChanged, "EVENT_UNIT_FACTION_CHANGED")
    common.RegisterEventHandler( OnUnitAggroListChanged, "EVENT_UNIT_AGGRO_LIST_CHANGED")
	common.RegisterEventHandler( OnUnitDamageReceived, "EVENT_UNIT_DAMAGE_RECEIVED")
	common.RegisterEventHandler( OnUnitBuffsChanged, "EVENT_UNIT_BUFFS_CHANGED")
end

function KillMobStopEvents()
	common.LogInfo("common"," stop events KILL MOB")
	qaMission.AvatarSetScriptControl( false )
	StopAllTimers()
	KillMobStopEventsSpawn()
    common.UnRegisterEventHandler( "EVENT_UNIT_DEAD_CHANGED")
	common.UnRegisterEventHandler( "EVENT_UNIT_FACTION_CHANGED")
    common.UnRegisterEventHandler( "EVENT_UNIT_AGGRO_LIST_CHANGED")
	common.UnRegisterEventHandler( "EVENT_UNIT_DAMAGE_RECEIVED")
	common.UnRegisterEventHandler( "EVENT_UNIT_BUFFS_CHANGED")
end

function GetLagScriptControl(lag)
	SCRIPT_LAG_TIME = lag * 3 / 2
	AVATAR_SPEED = ( SCRIPT_LAG_TIME / 1000 ) * 6
	KillMobLog("ScriptLag set to "..tostring(SCRIPT_LAG_TIME))
	SetState(PREFIGHT)
	PREFIGHT_KEY = 0
	BLOCK_FIGHT_KEY = 0
	--qaMission.AvatarSetScriptControl( false )
	PreFight()
end

function GetLeveleTaktiks(takt)
	local lvltakt = {}
	local insert = true
	for i, action in takt do
		insert = true
        for k, value in action.conditions do
            if debugCommon.FromWString(value.rule) == "active" then
				insert = false
				local spell = debugCommon.FromWString(value.param)
				local id = GetSpellId(spell)
				if id ~= nil then
					table.insert(lvltakt, i)
				end
            end
        end
		if insert and i > 1 then
			table.insert(lvltakt, i)
		end
	end
	return lvltakt
end

function InitKillMob(id,taktika,time_const,SuccessFunc,ErrorFunc,RangeFunc,FatalError, castSpellLag)
	if id ~= nil then
		KILLMOB_ENEMY_ID = id
		KILLMOB_ENEMY_NAME = debugCommon.FromWString( object.GetName( KILLMOB_ENEMY_ID ) )
	end
	KILLMOB_AVATAR_ID = avatar.GetId()
	KILLMOB_RANGE_FUNC = RangeFunc
	KILLMOB_SUCCESS_FUNC = SuccessFunc
	KILLMOB_ERROR_FUNC = ErrorFunc
	KILLMOB_FATALERROR_FUNC = ErrorFunc
	TAKT = taktika
	TIME_CONST = time_const
	if castSpellLag ~= nil then
		CASTSPELL_MAX_LAG = castSpellLag
	end
	
	KillMobStartEvents()
	common.LogInfo("common"," killmob Start")
	KillMobLog("killmob Start")
	
	TAKT_LEVEL = GetLeveleTaktiks( TAKT )

	StartTimer(1000, SetScriptControl,{time = 1000, lag = 200, dX = 6, func = GetLagScriptControl, errorFunc = Warn})
end
