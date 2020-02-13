function OnSetNoClip ( params )
	common.LogInfo( "common", "EVENT_NO_CLIP")
	qaMission.AvatarCustomInputNoClip( params.enable )
end

function Init()
	common.LogInfo( "common", "UI Addon for No Clip Launched")
	common.RegisterEventHandler( OnSetNoClip, "EVENT_SET_NO_CLIP")
end

--
-- main initialization
--

Init()

