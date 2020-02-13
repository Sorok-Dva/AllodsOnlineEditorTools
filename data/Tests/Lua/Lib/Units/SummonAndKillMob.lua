Global( "SUMMON_AND_KILLMOB_FUNC_ERROR", nil )
Global( "SUMMON_AND_KILLMOB_FUNC_PASS",  nil )

function SummonAndKillMob( mobName, mapResource, funcPass, funcError )
	SUMMON_AND_KILLMOB_FUNC_ERROR = funcError
	SUMMON_AND_KILLMOB_FUNC_PASS  = funcPass

	local newPos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), 1 )
	SummonMob( mobName, mapResource, newPos, 0, KillAfterSummon, funcError )
end

function KillAfterSummon( mobId )
	KillMob( mobId, SUMMON_AND_KILLMOB_FUNC_PASS, SUMMON_AND_KILLMOB_FUNC_ERROR )
end
