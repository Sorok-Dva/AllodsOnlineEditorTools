--
-- Global vars
--

-- declare global var


Global("TEST_NAME", "FireArrowTest")
Global("UNIT_NAME", "FarmTarget")
Global("SPELL_NAME", "FireArrow")
Global("SPELL_ID",nil)
Global("TARGET_ID",nil)
Global("AVATAR_ID",nil)
Global("CHANGE_TARGET", false)
Global("DISTANCE", 20)
Global("INGAME", false)
Global("INCOMBAT",false)
Global("WAIT_TARGET", false)
Global("WAIT_POS", false)
Global("SPELL_CANNOT_STRIKE",0)
Global("SPELL_CANNOT_STRIKE_MAX",20)
Global("COUNT",0)
-- EVENT_AVATAR_CREATED

-- EVENT_DEBUG_TIMER

function OnDebugTimer( params )
 if INGAME then
 	--ParamsToConsole(params, "EVENT_GAME_STATE_CHANGED")
 	if TARGET_ID == nil then
 		TARGET_ID = GetUnitID(UNIT_NAME)
		if TARGET_ID ~= nil then
		    COUNT = COUNT + 1
		    missionError("TARGET: "..tostring(TARGET_ID))
		    missionError("COUNT: "..tostring(COUNT))
			CHANGE_TARGET = true
		end
	end
	if CHANGE_TARGET then
		--local mp = unit.GetManaPercentage( AVATAR_ID )
		--local hp = unit.GetHealthPercentage( AVATAR_ID )
		--if (mp > 79) and (hp > 95)then
		    common.LogInfo("select TARGET")
		    qaMission.AvatarRevive()
			avatar.SelectTarget(TARGET_ID)
			WAIT_TARGET = true
		--end
	end
 end
end
function missionError( text )
  debugMission.Log( TEST_NAME.."\t"..text)
end
function GetSpellID( nameSpell)
   local spellBook = avatar.GetSpellBook()
   for i, idSpell in spellBook do
	  local spellInfo = avatar.GetSpellInfo( idSpell )
	  common.LogInfo(spellInfo.debugName)
	  if string.find( spellInfo.debugName, nameSpell ) then
	     --common.LogInfo( "GetSpellId "..tostring( idSpell ).." - "..nameSpell )
	     return idSpell
	  end
   end
   missionError("Wrong Taktik. Spell "..nameSpell.." out of spellbook")
   BotExit()
   return nil
end

function GetUnitID( name )
 	local units = avatar.GetUnitList()
 	if units == nil then
	    missionError("No units near avatar")
	    return nil
	else
		for key, value in units do
			local curname = qaMission.UnitGetXDB(value)
			if curname == nil then
				common.LogInfo("key "..tostring(key).." value "..tostring(value))
			else
			--common.LogInfo(curname)
  				local dead = unit.IsDead( value )
  				if string.find( curname, name ) and not dead then
					local aggro = debugMission.UnitGetAggroList( value )
  			    	if aggro == nil then
						return value
					end
  				end
  			end
		end
		return nil
	end
end
function BotExit()
	common.QuitGame()	
end
-- pri zahode v igru
function OnAvatarCreated( params )
	ParamsToConsole(params, "EVENT_AVATAR_CREATED")
	--common.LogInfo( "OnAvatarCreated" )
   INGAME = true
   SPELL_ID = GetSpellID(SPELL_NAME)
   AVATAR_ID = avatar.GetId()
end


-- EVENT Target change
function OnTargetChanged( params )
	ParamsToConsole(params, "EVENT_TARGET_CHANGED")
	local unitId = avatar.GetTarget()
	common.LogInfo("TARGET_ID "..tostring(TARGET_ID).." unitId "..tostring(unitId).." WAIT_TARGET "..tostring(WAIT_TARGET))
	if TARGET_ID ~= unitId then
	    return false
	end
	if not WAIT_TARGET then
		return false
	else
		WAIT_TARGET = false
	end
	if unitId == nil then
	    common.LogInfo("No target")
 	else
	    -- T.e. esli v targete ne nil to target ne menyat', a esli nil to iskat
	    --local name = unit.GetName(unitId)
	    --common.LogInfo("Target: "..tostring(name))
	    CHANGE_TARGET = false
        local live = unit.IsDead(unitId )
        if not live then
	    -- TODO - dobratsya do moba))
	    --
		   local unitPos = debugMission.UnitGetPos( unitId )
		   local avatarDir = debugMission.UnitGetDir( AVATAR_ID)
		   if avatarDir>0 then
		   avatarDir = avatarDir - math.pi
		   else
		   avatarDir = avatarDir + math.pi
		   end
		   local avatarPos = PositionAtDistance(unitPos, avatarDir, DISTANCE)
		   qaMission.AvatarSetPos( avatarPos )
		   WAIT_POS = true
        else
            CHANGE_TARGET = true
            TARGET_ID = nil
        end
	end
end


-- SPELL RESULT!!!!
function OnSpellResult( params )
	if params.unitId == AVATAR_ID then
		if not params.success then
			if params.code == 12 then
				ParamsToConsole(params, "EVENT_SPELL_RESULT")
			end
	    	if params.code == 2  then  -- действие невозможно
	        --common.LogInfo("SPELLRESULT - ".." id : "..tostring(params.code))
	        	if SPELL_CANNOT_STRIKE < SPELL_CANNOT_STRIKE_MAX then
					SPELL_CANNOT_STRIKE = SPELL_CANNOT_STRIKE + 1
					missionError("nevozmozhno")
          			avatar.RunSpell( SPELL_ID )
	        	else
	            	SPELL_CANNOT_STRIKE = 0
	        		missionError("spell cannot strike : nevozmozhno")
	        		BotExit()
				end
			end
			if params.code == 4 then
	        	if SPELL_CANNOT_STRIKE < SPELL_CANNOT_STRIKE_MAX then
					SPELL_CANNOT_STRIKE = SPELL_CANNOT_STRIKE + 1
					missionError("range")
          			avatar.RunSpell( SPELL_ID )
	        	else
	            	SPELL_CANNOT_STRIKE = 0
	        		missionError("spell cannot strike : distance")
	        		BotExit()
				end
			end
			if params.code == 39 then
 	        	if SPELL_CANNOT_STRIKE < SPELL_CANNOT_STRIKE_MAX then
					SPELL_CANNOT_STRIKE = SPELL_CANNOT_STRIKE + 1
					missionError("cancel")
          			avatar.RunSpell( SPELL_ID )
	        	else
	            	SPELL_CANNOT_STRIKE = 0
	        		missionError("spell cannot strike : cancel")
	        		BotExit()
				end
			end
	    end
	    if params.success then
	        SPELL_CANNOT_STRIKE = 0
	    end
	end
end
-- On DMg Recieved
function OnUnitDmgRecieved( params )
	--common.LogInfo("Dmg: "..tostring(params.amount))
	--common.LogInfo("Element: "..GetElementString(params.element))
	--Esli Dmg ot avatara to proverit, giv li mob, esli net to iskat novii target
    if params.source == AVATAR_ID then
	  	assertLess(22,params.amount)
	end
end
-- UNIT DIE
function OnUnitDie(params)
	if params.unitId == TARGET_ID then
		local dead = unit.IsDead(params.unitId)
		if dead then
			TARGET_ID = nil
			avatar.UnselectTarget()
		end
	end
	if params.unitId == AVATAR_ID then
	    missionError("avatar die")
	end
end
function OnProgressStart( params )
	--common.LogInfo("Progress Start: "..tostring(params.name))
end

function OnProgressFinish( params )
  --common.LogInfo("progress finish")
	local unitId = avatar.GetTarget()
    if (unitId ~= nil) then
        local live = unit.IsDead( unitId )
        if not live then
           avatar.RunSpell( SPELL_ID )
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
     	missionError("Test failed: DMG > 18")
	end
end

function OnAvatarPosChanged( params )
	if WAIT_POS then
	    WAIT_POS = false
	    avatar.RunSpell( SPELL_ID )
	end
end

--
-- main initialization function
--

function Init()
--	common.LogInfo( "Main Menu QA addon" )
	InitLoginAdv()
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
    common.RegisterEventHandler( OnTargetChanged, "EVENT_AVATAR_TARGET_CHANGED" )
	common.RegisterEventHandler( OnUnitDmgRecieved, "EVENT_UNIT_DAMAGE_RECEIVED" )
	common.RegisterEventHandler( OnSpellResult, "EVENT_SPELL_RESULT" )
	common.RegisterEventHandler( OnUnitDie, "EVENT_UNIT_DEAD_CHANGED")
	common.RegisterEventHandler( OnProgressFinish, "EVENT_ACTION_PROGRESS_FINISH")
	common.RegisterEventHandler( OnProgressStart, "EVENT_ACTION_PROGRESS_START")
	common.RegisterEventHandler( OnDebugTimer, "EVENT_DEBUG_TIMER" )
    common.RegisterEventHandler( OnAvatarPosChanged, "EVENT_AVATAR_POS_CHANGED")
--	debugCommon.HttpGET( HTTP_REQUEST .. "MissionQAMainAddon" )
end

--
-- main initialization
--

Init()
