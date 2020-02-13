function PreMissionCreateAvatar( avatarName, avatarTemplate, avatarVariation )
    common.LogInfo( "common", "send event to PreMissionCreateAvatar UI addon")
	common.SendEvent( "EVENT_PRE_CREATE_DEBUG", {name=debugCommon.ToWString( avatarName ), template=avatarTemplate, variation=avatarVariation })
end

function InitPreMissionCreateAvatar()
	common.LogInfo( "common", "loading UI addon: PreMissionCreateAvatar" )
	common.SendEvent("EVENT_ENABLE_UI_ADDON",{addon = "PreMissionCreateAvatar"})
end
