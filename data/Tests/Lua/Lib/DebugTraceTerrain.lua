Global("AFTER_TRACE_FUNC", nil)
Global("AFTER_TRACE_PARAMS", nil)

function OnTraceResult( params )
 	AFTER_TRACE_FUNC(params.pos,AFTER_TRACE_PARAMS)
end

function TraceTerrain(tracePos, func, params)
    AFTER_TRACE_FUNC = func
    AFTER_TRACE_PARAMS = params
	common.SendEvent("EVENT_TRACE_DEBUG",{pos = tracePos})
end

function InitTraceTerrain()
	common.RegisterEventHandler( OnTraceResult, "EVENT_TRACE_RESULT")
	common.SendEvent("EVENT_ENABLE_UI_ADDON",{addon = "DebugTraceTerrain"})
end
