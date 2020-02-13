
Global( "SPELL_PATH", "Mechanics/Spells/Cheats/GreaterInvisibility/Spell.xdb" )

Global( "coords", {} )

Global( "spellId", nil )

Global( "state", 0 )

Global( "timerCount", 0 )

Global( "timerWait", 500 )

Global( "timerOn", false )

Global( "nextPos", {} )

-----------------


function GetSpellIdByName( spellPath )
   common.LogInfo ( "GetSpellIdByName nameSpell = " .. tostring ( spellPath ) )
   local spellBook = avatar.GetSpellBook()
   for i, idSpell in spellBook do
	  local spellInfo = avatar.GetSpellInfo( idSpell )

	  if spellInfo.debugName == spellPath then
	     common.LogInfo( "SpellName "..tostring( spellInfo.name ) )
	     common.LogInfo( "SpellId "..tostring( idSpell ) )
	     return idSpell
	  end
   end
end  

function InitCoords()
  local coord = {}
  coord.globalX = 71
  coord.globalY = 161
  coord.globalZ = 0
  coord.localX = 4
  coord.localY = 4
  coord.localZ = 20
  table.insert( coords, 1, coord )

  local coord = {}
  coord.globalX = 72
  coord.globalY = 163
  coord.globalZ = 0
  coord.localX = 19
  coord.localY = 26
  coord.localZ = 20
  table.insert( coords, 2, coord )
  
  local coord = {}
  coord.globalX = 73
  coord.globalY = 172
  coord.globalZ = 0
  coord.localX = 14
  coord.localY = 9
  coord.localZ = 50
  table.insert( coords, 3, coord )
  
  local coord = {}
  coord.globalX = 77
  coord.globalY = 174
  coord.globalZ = 0
  coord.localX = 14
  coord.localY = 12
  coord.localZ = 50
  table.insert( coords, 4, coord )
  
  local coord = {}
  coord.globalX = 75
  coord.globalY = 179
  coord.globalZ = -1
  coord.localX = 31
  coord.localY = 12
  coord.localZ = 50
  table.insert( coords, 5, coord )
  
  local coord = {}
  coord.globalX = 82
  coord.globalY = 168
  coord.globalZ = 0
  coord.localX = 21
  coord.localY = 16
  coord.localZ = 10
  table.insert( coords, 6, coord )
  
  local coord = {}
  coord.globalX = 84
  coord.globalY = 168
  coord.globalZ = 0
  coord.localX = 26
  coord.localY = 23
  coord.localZ = 31
  table.insert( coords, 7, coord )
  
  local coord = {}
  coord.globalX = 87
  coord.globalY = 168
  coord.globalZ = 1
  coord.localX = 7
  coord.localY = 7
  coord.localZ = 3
  table.insert( coords, 8, coord )
  
  local coord = {}
  coord.globalX = 84
  coord.globalY = 168
  coord.globalZ = 0
  coord.localX = 26
  coord.localY = 23
  coord.localZ = 31
  table.insert( coords, 9, coord )
  
  local coord = {}
  coord.globalX = 82
  coord.globalY = 168
  coord.globalZ = 0
  coord.localX = 21
  coord.localY = 16
  coord.localZ = 10
  table.insert( coords, 10, coord )
  
  local coord = {}
  coord.globalX = 80
  coord.globalY = 166
  coord.globalZ = 0
  coord.localX = 27
  coord.localY = 12
  coord.localZ = 12
  table.insert( coords, 11, coord )
  
  local coord = {}
  coord.globalX = 81
  coord.globalY = 160
  coord.globalZ = -1
  coord.localX = 28
  coord.localY = 15
  coord.localZ = 18
  table.insert( coords, 12, coord )
  

  local coord = {}
  coord.globalX = 81
  coord.globalY = 160
  coord.globalZ = -1
  coord.localX = 28
  coord.localY = 15
  coord.localZ = 18
  table.insert( coords, 13, coord )

  local coord = {}
  coord.globalX = 71
  coord.globalY = 161
  coord.globalZ = 0
  coord.localX = 6
  coord.localY = 12
  coord.localZ = 11
  table.insert( coords, 14, coord )

end

-- EVENT_AVATAR_CREATED

function OnAvatarCreated( params )
   qaMission.AvatarLearnSpell( SPELL_PATH )         		
   spellId = GetSpellIdByName( SPELL_PATH ) 
   InitCoords()
   avatar.RunSpell( spellId )
   state = 1
   nextPos = coords[state]
--   qaMission.AvatarSetPos( nextPos )
   timerOn = true
   timerCount = timerWait
end


-- EVENT_AVATAR_POS_CHANGED
function OnAvatarPosChanged( params )
  if timerCount  > 0 then
   return
  end

  common.LogInfo( "Avatar changed position" )
  if state < 14 then
     state = state + 1
     nextPos = coords[state]
--     qaMission.AvatarSetPos( nextPos )
     timerOn = true
     timerCount = timerWait
  elseif state == 14 then
--    debugCommon.SetErrorReturn()
    debugCommon.SetIgnoreAssertInResult()
    common.QuitGame()
  end

end

-- EVENT_GAME_STATE_CHANGED
function OnGameStateChanged( params )
  if timerCount > 0 then
     debugShard.Log( "Coordinates of error point:" )
     debugShard.Log( "gobalX: "..tostring( nextPos.globalX ) )
     debugShard.Log( "gobalY: "..tostring( nextPos.globalY ) )
     debugShard.Log( "gobalZ: "..tostring( nextPos.globalZ ) )
     debugShard.Log( "localX: "..tostring( nextPos.localX ) )
     debugShard.Log( "localY: "..tostring( nextPos.localY ) )
     debugShard.Log( "localZ: "..tostring( nextPos.localZ ) )
     common.QuitGame()
  end
end

-- EVENT_DEBUG_TIMER
function OnDebugTimer( params )
   if timerOn then
      if timerCount > 0 then
         timerCount = timerCount - 1
      else
        timerOn = false
        qaMission.AvatarSetPos( nextPos )
      end
   end
end

function Init()
   local loging = {login = "ZoneRun", pass = "", avatar = "AL1Run1"}
   InitLoging(loging)
   common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
   common.RegisterEventHandler( OnAvatarPosChanged, "EVENT_AVATAR_POS_CHANGED" )
   common.RegisterEventHandler( OnDebugTimer, "EVENT_DEBUG_TIMER" )
end

--
-- main initialization
--

Init()
