function OnTraceTransportDebug( params )
	common.LogInfo( "common", "EVENT_TRACE_TR_DEBUG" )
	local tracePos = qaMission.DebugTraceTransport( params.pos )
	common.SendEvent("EVENT_TRACE_TR_RESULT",{pos = tracePos})
end

function Init()
	common.LogInfo( "common", "UI Addon for TraceTransport Launched" )
	common.RegisterEventHandler( OnTraceTransportDebug, "EVENT_TRACE_TR_DEBUG")
end

--
-- main initialization
--

Init()
