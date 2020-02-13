Global("AFTER_TRACE_TR_FUNC", nil)
Global("AFTER_TRACE_TR_PARAMS", nil)

function OnTraceTransportResult( params )
	common.LogInfo( "common", "EVENT_TRACE_TR_RESULT" )
 	AFTER_TRACE_TR_FUNC(params.pos,AFTER_TRACE_PARAMS)
end

function TraceTransport(tracePos, func, params)
    AFTER_TRACE_TR_FUNC = func
    AFTER_TRACE_TR_PARAMS = params
    common.LogInfo( "common", "send event to TraceTransport UI addon")
	common.SendEvent("EVENT_TRACE_TR_DEBUG",{pos = tracePos})
end

function InitTraceTransport()
	common.RegisterEventHandler( OnTraceTransportResult, "EVENT_TRACE_TR_RESULT")
	common.LogInfo( "common", "send event to manager UI addon" )
	common.SendEvent("EVENT_ENABLE_UI_ADDON",{addon = "DebugTraceTransport"})
end
