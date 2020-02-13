-- ф-ция для убийства моба с помощью заклинания Kill

Global( "KILL_MOB_SPELL", "Mechanics/Spells/Cheats/PowerWordKill/Spell.xdb" )
Global( "NINJA_ABILITY", "Mechanics/Spells/Stalker/Ninjutsu/Ability.xdb" )

Global( "KILL_MOB_FUNC_PASS",  nil )
Global( "KILL_MOB_FUNC_ERROR", nil )
Global( "KILL_MOB_MOB_ID", nil )

Global( "KILL_MOB_ROTATE_COUNT", nil ) -- сколько раз мы пытаемся убить моба - делаем несколько поворотов


function KillMob( mobId, funcPass, funcError )
	Log( "killing mob. id=" .. tostring( mobId ), "Units.KillMob")
	KILL_MOB_FUNC_PASS  = funcPass
	KILL_MOB_FUNC_ERROR = funcError
	KILL_MOB_MOB_ID = mobId
	KILL_MOB_ROTATE_COUNT = 0
	LearnSpell( KILL_MOB_SPELL, KillMobSelectTarget, KILL_MOB_FUNC_ERROR )
end

function KillMobSelectTarget()
	SelectTarget( KILL_MOB_MOB_ID, KillMobRotateToMob, KILL_MOB_FUNC_ERROR )
end

function KillMobRotateToMob()
	if avatar.GetId() == KILL_MOB_MOB_ID then
		KILL_MOB_ROTATE_COUNT = 3
		KillMobCastSpell()
	else
		KILL_MOB_ROTATE_COUNT = KILL_MOB_ROTATE_COUNT + 1
		Log( "Rotate to mob", "Units.KillMob" )

		qaMission.AvatarSetScriptControl( true )
		local dir = GetAngleBetweenPoints( avatar.GetPos(), debugMission.InteractiveObjectGetPos( KILL_MOB_MOB_ID ))
		if dir >= 0.001 then
			local moveParams = {
				deltaX = 0,
				deltaY = 0,
				deltaZ = 0,
				yaw = dir
			}
			qaMission.AvatarMoveAndRotate( moveParams )
		end	
		StartPrivateTimer( 4000, KillMobCastSpell )
	end	
end

function KillMobCastSpell()
	if unit.IsDead( KILL_MOB_MOB_ID ) == true then
		KillMobSuccess()
		return
	end

	if KILL_MOB_ROTATE_COUNT >= 3 then
		Log( "Cast spell in last time", "Units.KillMob" )
		CastSpell( GetSpellId( KILL_MOB_SPELL ), nil, 1000, KillMobCheckEffect, KILL_MOB_FUNC_ERROR, nil, true )
	else
		CastSpell( GetSpellId( KILL_MOB_SPELL ), nil, 1000, KillMobCheckEffect, KillMobSelectTarget, nil, true )
	end
end

function KillMobCheckEffect()
	StartPrivateCheckTimer( 10000, unit.IsDead, KILL_MOB_MOB_ID, KILL_MOB_FUNC_ERROR, "Can not killing mob", KillMobSuccess, nil )
end


function KillMobSuccess()
	qaMission.AvatarSetScriptControl( false )
	KILL_MOB_FUNC_PASS()
end
