-- Итак, есть функция Learn( spell, funcPass, funcError ) которая учит нужное заклинание
-- после того как у аватара появляется это заклинание в спеллбуке, она запускат функцию funcPass  с параметрами id spella в спеллюуке
-- если же за 10 сек заклинание не появляется выдает ошибку.
-- ACHTUNG!!! у себя в скрипте функция funcError может принимать в параметрах стринг,
-- в котором будет текст ошибки

Global( "LEARN_SPELL_PASS_FUNC", nil )
Global( "LEARN_SPELL_ERROR_FUNC", nil )
Global( "LEARN_SPELL_SPELL", nil )
Global( "LEARN_SPELL_SPELL_ID", nil )
Global( "LEARN_SPELL_TESTNAME", nil )

Global( "LEARN_SPELL_IMMUNE_PASS_FUNC", nil )
Global( "LS_IMMUNE_SPELL", "Mechanics/Spells/Cheats/IDDQD/Spell.xdb" )
Global( "LS_IMMUNE_BUFF", "Mechanics/Spells/Cheats/IDDQD/Buff.xdb" )

function LearnSpell( spell, funcPass, funcError)
	LEARN_SPELL_SPELL = spell
	if GetSpellId( spell ) ~= nil then
		Log( "Spell already learned", "Units.LearnSpell" )
		funcPass( GetSpellId( spell ) )
	else
		LEARN_SPELL_PASS_FUNC = funcPass
		LEARN_SPELL_ERROR_FUNC = funcError

		qaMission.AvatarLearnSpell( LEARN_SPELL_SPELL )
		Log( "Try Learn Spell " .. spell .. "...", "LearnSpell" )
		StartPrivateCheckTimer( 30000, LearnSpellCheckFunc, nil, ErrorLearnSpell, "Can't learn spell", PassLearnSpell, LEARN_SPELL_SPELL_ID )
	end
end

function LearnAndCastSpell( spell, testName )
	LEARN_SPELL_TESTNAME = testName
	LearnSpell( spell, StandardPassLearnSpell, StandardErrorLearnSpell )
end

function ImmuneAvatar( funcPass, funcError, spell, buff )
	if spell ~= nil then
		LS_IMMUNE_SPELL = spell
		LS_IMMUNE_BUFF = buff
	end
	if AvatarIsImmune() == true then
		funcPass()

	else
		Log( "casting immune spell", "Units.LearnSpell" )
		LEARN_SPELL_IMMUNE_PASS_FUNC = funcPass
		LEARN_SPELL_ERROR_FUNC = funcError
		LearnSpell( LS_IMMUNE_SPELL, CastingImmuneSpell, LEARN_SPELL_ERROR_FUNC )
	end
end



function CastingImmuneSpell()
	avatar.RunSpell( GetSpellId( LS_IMMUNE_SPELL ))
	StartPrivateCheckTimer( 10000, AvatarIsImmune, nil, LEARN_SPELL_ERROR_FUNC, "Can't cast immune spell", LEARN_SPELL_IMMUNE_PASS_FUNC, nil )
end

function AvatarIsImmune()
	return GetBuffInfo( avatar.GetId(), LS_IMMUNE_BUFF ) ~= nil
end

function LearnSpellCheckFunc()
	LEARN_SPELL_SPELL_ID = GetSpellId( LEARN_SPELL_SPELL )
	return LEARN_SPELL_SPELL_ID ~= nil
end

function PassLearnSpell()
	Log( "spell learned", "LearnSpell" )
	LEARN_SPELL_PASS_FUNC(LEARN_SPELL_SPELL_ID)
end

function ErrorLearnSpell()
	LogErr("spell not apeear in 10 sec","LearnSpell")
    LEARN_SPELL_ERROR_FUNC()
end

function StandardPassLearnSpell()
	local id = GetSpellId( LEARN_SPELL_SPELL )
	
	if id ~= nil then
	    avatar.RunSpell( id )
	else
		debugMission.Log( "WARNING: Lib: LearnSpell.lua failed: CANT FIND LEARNED SPELL" )
		mission.Logout()
	end
end

function StandardErrorLearnSpell( testName )
 	debugMission.Log( "WARNING: Test: " .. LEARN_SPELL_TESTNAME .. " failed: CANT LEARN SPELL" )
	mission.Logout()
end
