
--
--------- EVENTS -------------------------------------------------------------
--

-- EVENT_AVATAR_CREATED

function OnAvatarCreated( params ) 
  local coord = {}   
  coord.globalX = 71
  coord.globalY = 161
  coord.globalZ = 0
  coord.localX = 26
  coord.localY = 5
  coord.localZ = 10
--  debugMission.AvatarSetPos( coord )
end
  
-- "EVENT_AVATAR_TARGET_CHANGED"

function OnEventAvatarTagretChanged( params )

	local id = params.unitId
	local xdb = debugMission.UnitGetXDB(id)
	LogInfo( "XDB: " .. tostring( xdb ) )
--	debugMission.AvatarLearnSpell("Mechanics/Spells/Cheats/IDDQD/Spell.xdb")
--	debugMission.AvatarLevelUp(10)
--	debugMission.AvatarLearnUp()
--	debugCommon.SetErrorReturn()
	local coord = {}   
	coord.globalX = 71
	coord.globalY = 161
	coord.globalZ = 0
	coord.localX = 26
	coord.localY = 5
	coord.localZ = 10
	local coord1 = {}
	coord1 = debugMission.UnitGetPos( id )
	LogInfo ("Coord: " .. tostring(coord1.globalX) .. " " .. tostring(coord1.localX) .. " " .. tostring(coord1.globalY) .. " " .. tostring(coord1.localY) .. " " .. tostring(coord1.globalZ) .. " " .. tostring(coord1.localZ) )
	debugMission.AvatarSetPos( coord1 )
	debugMission.RepfomanceLog("Kill em all")
	
end

--
-- main initialization function --------------------------------------------------------
--

function Init()	
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED")
	common.RegisterEventHandler( OnEventAvatarTagretChanged, "EVENT_AVATAR_TARGET_CHANGED" )
end

Init()

