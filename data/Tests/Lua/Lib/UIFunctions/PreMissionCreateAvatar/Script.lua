function OnPreCreateDebug( params )
	common.LogInfo( "common", "EVENT_TRACE_TR_DEBUG" )
	preMission.CreateAvatar( params.name, params.template, params.variation )
end

function Init()
	common.LogInfo( "common", "UI Addon for PreMissionCreateAvatar Launched" )
	common.RegisterEventHandler( OnPreCreateDebug, "EVENT_PRE_CREATE_DEBUG" )
end

Init()
