Global("AFTER_FIND_GOOD_TERRAIN_IN_DIRECTION_FUNC", nil)
Global("AFTER_FIND_GOOD_TERRAIN_IN_DIRECTION_PARAMS", nil)

function OnFindGoodTerrainInDirectionResult( params )
 	AFTER_FIND_GOOD_TERRAIN_IN_DIRECTION_FUNC(params.pos,AFTER_FIND_GOOD_TERRAIN_IN_DIRECTION_PARAMS)
end

function FindGoodTerrainInDirection(tracePos, dest, func, params)
    AFTER_FIND_GOOD_TERRAIN_IN_DIRECTION_FUNC = func
    AFTER_FIND_GOOD_TERRAIN_IN_DIRECTION_PARAMS = params
	common.SendEvent("EVENT_FIND_GOOD_TERRAIN_IN_DIRECTION_DEBUG",{pos = tracePos, direction = dest})
end

function InitFindGoodTerrainInDirection()
	common.RegisterEventHandler( OnFindGoodTerrainInDirectionResult, "EVENT_FIND_GOOD_TERRAIN_IN_DIRECTION_RESULT")
	common.SendEvent("EVENT_ENABLE_UI_ADDON",{addon = "DebugTraceTerrain"})
end
