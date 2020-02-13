function OnAvatarCustomInput( params )
	if params.func == "ACI_ENABLE" then
		qaMission.AvatarCustomInputEnable( params.enable )

	elseif params.func == "ACI_SETDIR" then
		qaMission.AvatarCustomInputEnable( params.yaw )
		
	elseif params.func == "ACI_MOVE" then
		qaMission.AvatarCustomInputMove( params.on )
		
	elseif params.func == "ACI_JUMP" then
		qaMission.AvatarCustomInputJump( params.on )
		
	else
	    common.LogInfo( "common", "&^%&^%&^%&^%&^%&^% WRONG AVATAR_CUSTOM_INPUT EVENT" )
	end
end


function Init()
	common.LogInfo( "common", "UI Addon for Avatar Custom Input enabled")
	common.RegisterEventHandler( OnAvatarCustomInput, "EVENT_AVATAR_CUSTOM_INPUT")
end

--
-- main initialization
--

Init()
