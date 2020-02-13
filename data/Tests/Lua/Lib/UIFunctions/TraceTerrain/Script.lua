function OnTraceDebug( params )
	local tracePos = qaMission.DebugTraceTerrain( params.pos )
	common.SendEvent("EVENT_TRACE_RESULT",{pos = tracePos})
end

function OnFindGoodTerrainInDirectionDebug( params )
	local tracePos = qaMission.DebugFindGoodTerrainInDirection( params.pos, params.direction )
	common.SendEvent("EVENT_FIND_GOOD_TERRAIN_IN_DIRECTION_RESULT",{pos = tracePos})
end

function Init()
	LogInfo("UI Addon for Trace Launched")
	common.RegisterEventHandler( OnTraceDebug, "EVENT_TRACE_DEBUG")
	common.RegisterEventHandler( OnFindGoodTerrainInDirectionDebug, "EVENT_FIND_GOOD_TERRAIN_IN_DIRECTION_DEBUG")
end

--
-- main initialization
--

Init()
