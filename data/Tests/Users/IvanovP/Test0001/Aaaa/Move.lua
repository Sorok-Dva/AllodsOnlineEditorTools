
--
--------- EVENTS -------------------------------------------------------------
--

-- EVENT_AVATAR_CREATED

function OnAvatarCreated( params ) 
  local pos = avatar.GetPos()
  debugMission.AvatarSetScriptControl( true )
  local moveParams = {}
  moveParams.deltaX = 10
  moveParams.deltaY = 10
  moveParams.deltaZ = 0
  moveParams.yaw = math.rad( 90 )
  debugMission.AvatarMoveAndRotate( moveParams )
end
  

--
-- main initialization function --------------------------------------------------------
--

function InitTeleport(params)	
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED")
end

--
-- main initialization
--


