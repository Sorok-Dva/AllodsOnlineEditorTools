-- author: Liventsev Andrey, date: 22.12.2008, bug#34553
-- Ударить моба на n% жизней (лучше брать с запасом)

Global( "KICK_MOB_FUNC_PASS",  nil )
Global( "KICK_MOB_FUNC_ERROR", nil )
Global( "KICK_MOB_MOB_ID",     nil )
Global( "KICK_MOB_HEALTH_PERCENTS", nil )

Global( "KICK_MOB_SPELL_1", "Mechanics/Spells/Cheats/Dmg10/spell.xdb" )
Global( "KICK_MOB_SPELL_2", "Mechanics/Spells/Cheats/Dmg70/spell.xdb" )
Global( "KICK_MOB_VAL_1", 10 )
Global( "KICK_MOB_VAL_2", 70 )


function KickMob( mobId, percents, passFunc, errorFunc )
	KICK_MOB_FUNC_PASS = passFunc
	KICK_MOB_FUNC_ERROR = errorFunc
	KICK_MOB_MOB_ID = mobId
	KICK_MOB_HEALTH_PERCENTS = percents
	
	LearnSpell( KICK_MOB_SPELL_1, KickMobLearnSpell, KICK_MOB_FUNC_ERROR )
end

function KickMobLearnSpell()
	LearnSpell( KICK_MOB_SPELL_2, KickMobSelectTarget, KICK_MOB_FUNC_ERROR )
end

function KickMobSelectTarget()
	SelectTarget( KICK_MOB_MOB_ID, KickMobCastNext, KICK_MOB_FUNC_ERROR )
end

function KickMobCastNext()
	local health = debugMission.UnitGetHealth( KICK_MOB_MOB_ID ).percents
	KickMobLog( tostring( health ) .. " now. should be " .. tostring(KICK_MOB_HEALTH_PERCENTS) )
	if health <= KICK_MOB_HEALTH_PERCENTS then
		KickMobLog( "SUCCESS" )
		KICK_MOB_FUNC_PASS()

	elseif health - KICK_MOB_VAL_2 > 0 then 
		KickMobLog( "set " .. tostring(KICK_MOB_VAL_2) .. " percents of damage"  )
		CastSpell( GetSpellId( KICK_MOB_SPELL_2 ), nil, 1000, KickMobSomeWait, KICK_MOB_FUNC_ERROR, nil, true )

	elseif health - KICK_MOB_VAL_1 > 0 then
		KickMobLog( "set " .. tostring(KICK_MOB_VAL_1) .. " percents of damage"  )
		CastSpell( GetSpellId( KICK_MOB_SPELL_1 ), nil, 1000, KickMobSomeWait, KICK_MOB_FUNC_ERROR, nil, true )
	end
end

function KickMobSomeWait()
	StartPrivateTimer( 1000, KickMobCastNext )
end

function KickMobLog( text )
	Log( text, "Units.KickMob" )
end
