--
-- Global vars
--

Global( "HTTP_REQUEST", "http://192.168.10.81:8080/twf/test.do?request=" )
Global("UNIT_NAME", "BJ bee")
Global("P4ELKA", "Пчелка для фарма")
Global("SPELL_NAME", "Огненная стрела (Ранк 1)")
Global("CHANGE_TARGET", false)
Global("INGAME", false)
-- EVENT_AVATAR_CREATED

function OnEventAvatarCreated( params )
	LogInfo( "Main Menu QA addon: OnEventAvatarCreated" )

--[[
	local pos = {}
	pos.localX = 1
	pos.localY = 30
	pos.localZ = 100
	pos.globalX = 0
	pos.globalY = 0
	pos.globalZ = 0
	debugMission.SetPos( pos )
--]]

--[[
	local moveParams = {}
	moveParams.deltaX = 10
	moveParams.deltaY = 10
	moveParams.deltaZ = 100
	moveParams.yaw = math.rad( 90 ) -- похоже, сейчас не поддерживается в коде
	debugMission.MoveAndRotate( moveParams )
--]]
end

-- EVENT_DEBUG_TIMER

function OnDebugTimer( params )
 if (INGAME == true) then
	if (CHANGE_TARGET == true) then
		local target = TargetUnit(P4ELKA)
		local id =  avatar.GetId()
		local mp = unit.GetManaPercentage( id )
		local hp = unit.GetHealthPercentage( id )
		if (target ~= nil) and (mp > 99) and (hp > 99)then
			avatar.SelectTarget(target)
		end
	end
 end
end
-- summon mob
function CreateMob(pos)
	local mobID = debugMission.SummonMob("/Tests/Interface/Ingame/QAMain/Bee.xdb", "Maps/Test/MapResource.xdb", pos, 0 )
	return mobID
end
-- pri zahode v igru
function OnAvatarCreated( params )
   INGAME = true
   local spellBook = avatar.GetSpellBook()
   for key, value in spellBook  do
	  local spellInfo = avatar.GetSpellInfo( value )
	     LogInfo( "SpellName "..spellInfo.name )
	     LogInfo( "SpellId "..tostring( value ) )
	end
end
-- mob uda4no sozdalsya
function OnSummonCreated( params )
	LogInfo("SUMMON_MOB_OK")
end
-- mob ne sozdalsya
function OnSummonNotCreated(params)
	LogInfo("SUMMON_MOB_FAILED")
end
-- Polu4it idSpell po imeni
function GetSpellIdByName( nameSpell)
   local spellBook = avatar.GetSpellBook()
   for i, idSpell in  ipairs( spellBook )  do
	  local spellInfo = avatar.GetSpellInfo( idSpell )
	  if spellInfo.name == nameSpell then
	     LogInfo( "SpellName "..spellInfo.name )
	     LogInfo( "SpellId "..tostring( idSpell ) )
	     return idSpell
	  end
   end
   return nil
end
-- Cast spell s imenem
function CastSpell(spell)
	local idSpell = GetSpellIdByName( spell)
	if (idSpell == nil) then
		LogInfo("Wrong spell")
	else
        avatar.RunSpell( idSpell )
	end
end
-- Vibrat' unit po imeni
function TargetUnit(name)
 	local units = avatar.GetUnitList()
    local id = nil
	if units == nil then
	    LogInfo("No units near Avatar")
	    return nil
	else
		for key, value in units do
			local curname = unit.GetName(value)
  			local live = unit.IsDead( value )
  			if (curname == name) and (live == false) then
	  			LogInfo( "id: " .. tostring( value ) )
	  			LogInfo( "name: " .. tostring( name ) )
  			    return units[key]
  			end
		end
		return nil
	end
end
-- EVENT Target change
function OnTargetChanged( params )
	if (params.unitId == nil) then
	    LogInfo("No target")
     	CHANGE_TARGET = true
	else
	    -- T.e. esli v targete ne nil to target ne menyat', a esli nil to iskat
	    local name = unit.GetName(params.unitId)
	    LogInfo("Target: "..tostring(name))
	    CHANGE_TARGET = false
        local live = unit.IsDead( params.unitId )
        if not live then
	    -- TODO - dobratsya do moba))
	    --
		   local uPos = debugMission.UnitGetPos( params.unitId )
		   local aDir = debugMission.UnitGetDir( avatar.GetId())
		   local Pi = math.pi
		   local Pi2 = Pi/2
		   if (aDir >= 0) and (aDir < Pi2) then
		   -- 1 4etverd
		   uPos.localX = uPos.localX - 15
		   uPos.localY = uPos.localY - 15
		   elseif (aDir >= Pi2) and (aDir < Pi) then
		   -- 2 4etverd
		   uPos.localX = uPos.localX + 15
		   uPos.localY = uPos.localY - 15
		   elseif (aDir >= -Pi) and (aDir < -Pi2) then
		   -- 3 4etverd
		   uPos.localX = uPos.localX + 15
		   uPos.localY = uPos.localY + 15
		   elseif (aDir >= -Pi2) and (aDir < 0) then
		   -- 4 4etverd
		   uPos.localX = uPos.localX - 15
		   uPos.localY = uPos.localY + 15
		   end
		   LogInfo("X tp: "..tostring(uPos.localX))
		   LogInfo("X tp: "..tostring(uPos.localY))
           debugMission.AvatarSetPos( uPos )
           CastSpell(SPELL_NAME)
        end
	end
end


-- Select Target UNIT_NAME kak tolko poyavitsya
function OnUnitSpawned( params )
	CHANGE_TARGET = true
end
-- SPELL RESULT!!!!
function OnEventSpellResult( params )
	local description = avatar.GetSpellResult( params.code )
	local name = unit.GetName(params.unitId)
    LogInfo("Spell failed: "..tostring(name))
    LogInfo("Spell failed: "..tostring(params.name))
    LogInfo("Spell failed: "..tostring(params.success))
	LogInfo("Spell failed: "..tostring(params.code))
	LogInfo("Spell failed: "..tostring(description))
end
-- On DMg Recieved
function OnUnitDmgRecieved( params )
	LogInfo("Dmg: "..tostring(params.amount))
	LogInfo("Element: "..GetElementString(params.element))
	--Esli Dmg ot avatara to proverit, giv li mob, esli net to iskat novii target
    if params.source == avatar.GetId() then
	  	assertLess(22,params.amount)
	  	CHANGE_TARGET = unit.IsDead( params.target )
	end
end
-- UNIT DIE
function OnUnitDie(params)
	local name = unit.GetName(params.unitId)
	LogInfo("unit die: "..tostring(name))
end
function OnProgressStart( params )
	LogInfo("Progress Start: "..tostring(params.name))
end

function OnProgressFinish( params )
  LogInfo("progress finish")
	local unitId = avatar.GetTarget()
    if (unitId ~= nil) then
        local live = unit.IsDead( unitId )
        if not live then
           CastSpell(SPELL_NAME)
        end
    end
end


function GetElementString(id)
	if id == 0 then
		return "PHYSICAL"
	elseif id == 1 then
	    return "FIRE"
	elseif id == 2 then
		return "COLD"
	elseif id == 3 then
		return "LIGHTNING"
	elseif id == 4 then
		return "HOLY"
	elseif id == 5 then
		return "SHADOW"
	elseif id == 6 then
		return "POISON"
	elseif id == 7 then
		return "DISEASE"
	else
	    return "PZDC"
	end
end
function assertLess( expected, actual)
	if actual > expected then
     	debugMission.Log("Test failed: DMG > 18")
	end
end


--
-- main initialization function
--

function Init()
--	LogInfo( "Main Menu QA addon" )

	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )

    common.RegisterEventHandler( OnTargetChanged, "EVENT_AVATAR_TARGET_CHANGED" )
	common.RegisterEventHandler( OnUnitDmgRecieved, "EVENT_UNIT_DAMAGE_RECEIVED" )
	common.RegisterEventHandler( OnSummonCreated, "EVENT_DEBUG_SUMMON_MOB_OK" )
	common.RegisterEventHandler( OnSummonNotCreated, "EVENT_DEBUG_SUMMON_MOB_FAILED" )
	common.RegisterEventHandler( OnUnitSpawned, "EVENT_UNIT_SPAWNED" )
	common.RegisterEventHandler( OnEventSpellResult, "EVENT_SPELL_RESULT" )
	common.RegisterEventHandler( OnUnitDie, "EVENT_UNIT_DEAD_CHANGED")
	common.RegisterEventHandler( OnProgressFinish, "EVENT_ACTION_PROGRESS_FINISH")
	common.RegisterEventHandler( OnProgressStart, "EVENT_ACTION_PROGRESS_START")
-- 	common.RegisterEventHandler( OnEventAvatarCreated, "EVENT_AVATAR_CREATED" )

	common.RegisterEventHandler( OnDebugTimer, "EVENT_DEBUG_TIMER" )

--	debugCommon.HttpGET( HTTP_REQUEST .. "MissionQAMainAddon" )
end

--
-- main initialization
--

Init()
