-- ф-ция для убийства моба 

Global( "WBKM_SPELL", "Mechanics/Spells/Cheats/PowerWordKill/Spell.xdb" )

Global( "WBKM_FUNC_PASS",  nil )
Global( "WBKM_FUNC_ERROR", nil )
Global( "WBKM_MOB_ID", nil )

Global( "WBKM_ROTATE_COUNT", nil ) -- сколько раз мы пытаемся убить моба - делаем несколько поворотов


function KillMob( mobId, funcPass, funcError )
	Log( "start killing mob. id=" .. tostring( mobId ), "WorldBot.KillMob")

	WBKM_FUNC_PASS  = funcPass
	WBKM_FUNC_ERROR = funcError
	WBKM_MOB_ID = mobId
	WBKM_ROTATE_COUNT = 0
	qaMission.AvatarSetScriptControl( true )
	LearnSpell( WBKM_SPELL, WBKM_SelectTarget, WBKM_Error )
end

function WBKM_SelectTarget()
	SelectTarget( WBKM_MOB_ID, WBKM_RotateToMob, WBKM_Error )
end

function WBKM_RotateToMob()
	if avatar.GetId() == WBKM_MOB_ID then
		WBKM_ROTATE_COUNT = 3
		WBKM_CastSpell()
	else
		WBKM_ROTATE_COUNT = WBKM_ROTATE_COUNT + 1
		Log( "Rotate to mob", "WorldBot.KillMob" )
		
		local dir = GetAngleBetweenPoints( avatar.GetPos(), debugMission.InteractiveObjectGetPos( WBKM_MOB_ID ))
		if RadToDegr(dir ) >= 30 or RadToDegr(dir) <= -30 then
			local moveParams = {
				deltaX = 0,
				deltaY = 0,
				deltaZ = 0,
				yaw = dir
			}
			group.ChatZone( debugCommon.ToWString( "rotate " .. tostring(WBKM_ROTATE_COUNT) ) )

			qaMission.AvatarMoveAndRotate( moveParams )
		end	
		StartPrivateTimer( 2000, WBKM_CastSpell )
	end	
end

function WBKM_CastSpell()
	if unit.IsDead( WBKM_MOB_ID ) == true then
		WBKM_Success()
		return
	end

	if WBKM_ROTATE_COUNT >= 3 then
		Log( "Cast spell in last time", "WorldBot.KillMob" )
		CastSpell( GetSpellId( WBKM_SPELL ), nil, 1000, WBKM_CheckEffect, WBKM_Error, nil, true )
	else
		CastSpell( GetSpellId( WBKM_SPELL ), nil, 1000, WBKM_CheckEffect, WBKM_SelectTarget, nil, true )
	end
end

function WBKM_CheckEffect()
	Log( "check effect" )
	StartPrivateCheckTimer( 10000, unit.IsDead, WBKM_MOB_ID, WBKM_Error, "Can not killing mob", WBKM_Success, nil )
end


function WBKM_Success()
--	qaMission.AvatarSetScriptControl( false )
	Log( "Done", "WorldBot.KillMob" )
	WBKM_FUNC_PASS()
end

function WBKM_Error( text )
	Log( "WBKM_ERROR" .. tostring( text ))
	qaMission.AvatarSetScriptControl( false )
	WBKM_FUNC_ERROR( text )
end
