function OnEnableUIAddon( params )
	common.LogInfo("common","EVENT_ENABLE_UI_ADDON - load addon: "..params.addon)
	common.StateLoadManagedAddon( params.addon )
end

function OnDisableUIAddon( params )
	common.LogInfo("common","EVENT_DISABLE_UI_ADDON - addon: "..params.addon)
	common.StateUnloadManagedAddon( params.addon )
end

function Init()
	--common.LogInfo("common","Manager UI of Addons... Launched")
	common.RegisterEventHandler( OnEnableUIAddon, "EVENT_ENABLE_UI_ADDON")
	common.RegisterEventHandler( OnDisableUIAddon, "EVENT_DISABLE_UI_ADDON")
end

--
-- main initialization
--

Init()
