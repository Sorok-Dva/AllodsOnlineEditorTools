function OnCameraCustomInput( params )
	if params.func == "CCI_ENABLE" then
		qaMission.AvatarCustomCameraControllerEnable( params.enable )

	elseif params.func == "CCI_SETANGLE" then
		qaMission.AvatarCustomCameraSetAngle( params.angle )
		
	elseif params.func == "CCI_SETPOSITION" then
		qaMission.AvatarCustomCameraSetPosition( params.pos )
	else
	    LogInfo( "&^%&^%&^%&^%&^%&^% WRONG CAMERA_CUSTOM_INPUT EVENT" )
	end
end


function Init()
	LogInfo("UI Addon for Camera Custom Input enabled")
	common.RegisterEventHandler( OnCameraCustomInput, "EVENT_CAMERA_CUSTOM_INPUT")
end

--
-- main initialization
--

Init()