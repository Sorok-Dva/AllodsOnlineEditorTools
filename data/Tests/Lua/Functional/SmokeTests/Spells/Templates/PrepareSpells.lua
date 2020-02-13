-- для нее нужны либы Log,Login,CastSpell,LearnSpell,SelectTarget
-- CastPrepareSpells(unitId, afterFunc)
-- эту запускаем перед кастом спелла
-- LearnPrepareSpells(afterFunc)
-- Эту запускаем после левелапа
-- GetPrepareSpellsFromAddon()
-- эту вызываем в Inite

Global( "PREPARE_NORMALIZE" , "Mechanics/Spells/Cheats/EquipNormalization/Spell.xdb" )
Global( "PREPARE_STEP_NEED_REVIVE" , -1 )
Global( "PREPARE_SPELLS" , nil )
Global( "PREPARE_SPELLS_STEP", 0)
Global( "PREPARE_SPELLS_NUM", 0)
Global( "PREPARE_AFTER_FUNC", nil )
Global( "PREPARE_TARGET_UNIT", nil )

--- КАСТ вспомогательные заклинания
function GetTargetPrepareSpell(num)
	for i,value in PREPARE_SPELLS do
		if i == num then
			return value.target
		end
	end
	return nil
end
-- внешняя функция
function CastPrepareSpells(unitId, afterFunc)
	PREPARE_AFTER_FUNC = afterFunc
	PREPARE_TARGET_UNIT = unitId
	PrepareCastSpells()
end

function PrepareCastSpells()
	PREPARE_SPELLS_STEP = PREPARE_SPELLS_STEP + 1
	if PREPARE_SPELLS_STEP <= PREPARE_SPELLS_NUM then
		local tgt = GetTargetPrepareSpell(PREPARE_SPELLS_STEP)
		if tgt == "self" then
			TargetSelf( CastSpellPrepare, Warn )
		elseif tgt == "unit" or tgt == "member" then
			if PREPARE_TARGET_UNIT ~= nil then
				SelectTarget( PREPARE_TARGET_UNIT, CastSpellPrepare, Warn )
			else
				UnselectTarget( CastSpellPrepare, Warn )
			end
		elseif tgt == "buff" then
			AttachBuffPrepare(GetPrepareSpell(PREPARE_SPELLS_STEP,tgt))
		elseif tgt == "item" then
			CreateItemPrepare(GetPrepareSpell(PREPARE_SPELLS_STEP,tgt))
		elseif tgt == "wait" then
			if GetPrepareSpell(PREPARE_SPELLS_STEP,tgt) == "revive" then
				qaMission.AvatarRevive()
			end
			StartTimer(500, PrepareCastSpells)		
		else
			UnselectTarget( CastSpellPrepare, Warn )
		end
	else
		PREPARE_SPELLS_STEP = 0
		return PREPARE_AFTER_FUNC()
	end
end

function CreateItemPrepare(item)
	qaMission.SendCustomMsg("create_item "..item)
	StartTimer(100,PrepareCastSpells,nil)
end

function AttachBuffPrepare(buff)
	qaMission.SendCustomMsg("attach_buff "..buff)
	StartTimer(500,PrepareCastSpells,nil)
end

function CastSpellPrepare()
	local id = GetPrepareSpell(PREPARE_SPELLS_STEP)
    CastSpell( id, nil, 10000, WaitTimeForSpellPrepare, ErrorFunc)
end

function WaitTimeForSpellPrepare()
	if PREPARE_SPELLS_STEP == PREPARE_STEP_NEED_REVIVE then
		qaMission.AvatarRevive()
	end
	StartTimer(1000, PrepareCastSpells)
end

function GetCheatSpell(spell)
    if spell == "dmg70" then
        return "Mechanics/Spells/Cheats/Dmg70/spell.xdb"
	elseif spell == "kill" then
		return "Mechanics/Spells/Cheats/Kill/spell.xdb"
	elseif spell == "normalize" then
	    return "Mechanics/Spells/Cheats/Normalization/Spell.xdb"
	elseif spell == "curse" then
	    return "Mechanics/Spells/Cheats/CurseOfOXid/Spell.xdb"
	else
	    return spell
	end
end

---- ОБУЧЕНИЕ
function LearnPrepareSpell(num)
	local spellName = GetPrepareSpell(PREPARE_SPELLS_STEP)
	if spellName ~= nil then
		spellName = GetCheatSpell(spellName)
		local spellId = GetSpellId(spellName)
		if spellId == nil then
			return LearnSpell( spellName, PrepareLearnSpells, ErrorFunc)
		else
			SetIdPrepareSpell(num,spellId)
		end
	end
	PrepareLearnSpells()
end

function GetPrepareSpell(num,target)
	for i,value in PREPARE_SPELLS do
		if i == num then 
			if target ~= nil then
				if value.target == target then
					return value.spell
				end
			else
				if value.target == "unit" or value.target == "self" or value.target == "member" then
					return value.spell
				end
			end
		end
	end
	return nil
end

function SetIdPrepareSpell(num,id)
	--Log("try set id "..tostring(num).."    "..tostring(id))
	for i,value in PREPARE_SPELLS do
		if i == num then
			--Log(tostring(id))
			value.spell = id
			return
		end
	end
	return Warn("Error in scrip. Cant Set Id for Prepare Spell "..tostring(num))
end

function PrepareLearnSpells(id)
	--Log("PrepareLearnSpells "..tostring(id))
	if id ~= nil then
		SetIdPrepareSpell(PREPARE_SPELLS_STEP,id)
	end
	PREPARE_SPELLS_STEP = PREPARE_SPELLS_STEP + 1
	
	if PREPARE_SPELLS_STEP <= PREPARE_SPELLS_NUM then
		LearnPrepareSpell(PREPARE_SPELLS_STEP)
	else
		PREPARE_SPELLS_STEP = 0
		return PREPARE_AFTER_FUNC()
	end
end
-- внешняя функция
function LearnPrepareSpells(afterFunc)
	PREPARE_AFTER_FUNC = afterFunc
	PrepareLearnSpells()
end

function InsertNormalizeInPrepare()
	table.insert(PREPARE_SPELLS,{spell = PREPARE_NORMALIZE, target = "self"})
	PREPARE_SPELLS_NUM = PREPARE_SPELLS_NUM + 1
	PREPARE_STEP_NEED_REVIVE = PREPARE_SPELLS_NUM
end
function InsertWaitAndReviveInPrepare()
	table.insert(PREPARE_SPELLS,{spell = "revive", target = "wait"})
	PREPARE_SPELLS_NUM = PREPARE_SPELLS_NUM + 1
end
-- внешняя функция
function GetPrepareSpellsFromAddon()
	PREPARE_SPELLS = {}
	--InsertNormalizeInPrepare()
	local prepSpell = "aaa"
	local i = 0
	while prepSpell ~= "" do
		prepSpell = developerAddon.GetParam( "SpellPrepare"..tostring(i) )
		if prepSpell ~= "" then
			table.insert(PREPARE_SPELLS,{spell = prepSpell, target = developerAddon.GetParam( "SpellPrepareTarget"..tostring(i) )})
			PREPARE_SPELLS_NUM = PREPARE_SPELLS_NUM + 1
		end
		i = i + 1
	end
	--InsertWaitAndReviveInPrepare()
end
