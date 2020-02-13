Global( "TEST_NAME", "UnitTests.GetOffhandSpeed" )

Global( "MOB_NAME", "Tests/Maps/Test/Instances/FarmTarget.(MobWorld).xdb")
Global( "MAP_RESOURCE", "/Tests/Maps/Lua/MapResource.xdb" )
Global( "SPELL_NAME", "Client/GMUIHelper/AutoAttackMelee.(SpellSingleTarget).xdb")


function SelectMob( mobId )
	SelectTarget( mobId, RunMeleeSpell, ErrorFunc )
end

function RunMeleeSpell()
	if GetSpellId( SPELL_NAME ) == nil then
		ErrorFunc( "Can't find spell. spellName=" .. SPELL_NAME )
	else
		StartTimer( 5000, ErrorFunc, "Event OnAvatarCombatStatusChanged did not come" )
		avatar.RunSpell( GetSpellId( SPELL_NAME ) )
	end
end

function Done()
	DisintagrateMob( MOB_NAME )
	StartTimer( 2000, Success, TEST_NAME )
end

function ErrorFunc( text )
	DisintagrateMob( MOB_NAME )
	Warn( TEST_NAME, text )
end




----------------------------- EVENTS -----------------------------------

function OnAvatarCreated()
	StartTest( TEST_NAME )

	local newPos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), 1 )
	SummonMob( MOB_NAME, MAP_RESOURCE, newPos, 0, SelectMob, ErrorFunc )
end

function OnAvatarCombatStatusChanged( params )
	if params.inCombat then
		StopTimer()
		local errorText = ""
		local speed = avatar.GetOffhandSpeed()
		
		if speed.base == nil then
			errorText = "speed.base is null"
		end
		if speed.effective == nil then
			errorText = errorText .. "speed.effective is null"
		end
		
		if errorText == "" then
			Log( "base speed=" .. tostring( speed.base ))
			Log( "effective speed=" .. tostring( speed.effective ))
			Done()
		else
			ErrorFunc( errorText )
		end
	end
end

function Init()
	local login = {
		login = developerAddon.GetParam( "login"),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" )
	}
	InitLoging(login)

	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
	common.RegisterEventHandler( OnAvatarCombatStatusChanged, "EVENT_AVATAR_COMBAT_STATUS_CHANGED" ) 
end

Init()
