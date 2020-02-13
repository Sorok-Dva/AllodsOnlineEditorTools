Global( "TEST_NAME", "SmokeTest.PassiveAgroCheck author: Liventsev Andrey, date: 24.07.08, task 37327" )

Global( "MOB_NAME",   nil )

Global( "MAP_RESOURCE", "/Tests/Maps/Lua/MapResource.xdb" )
Global( "AUTO_ATTACK", "Client/GMUIHelper/AutoAttackMelee.(SpellSingleTarget).xdb" )

Global( "IMMUNE_SPELL", "Mechanics/Spells/Cheats/IDDQD/Spell.xdb" )


Global( "MOB_ID", nil )

function BeforeCheckAgroList( mobId )
	MOB_ID = mobId
	LearnAndCastSpell( IMMUNE_SPELL, TEST_NAME )
	StartTimer( 2000, CheckAgroList )
end

function CheckAgroList()
	if IsAggresive( MOB_ID ) then
		ErrorFunc( "Mob is aggresive (should be aggresive)" )
		return
	end
	
	SelectTarget( MOB_ID, TryToAttack, ErrorFunc )
end

function TryToAttack()
	Log( "attack mob" )
	avatar.RunSpell( GetSpellId( AUTO_ATTACK ) )
	StartCheckTimer( 10000, IsAggresive, MOB_ID, ErrorFunc, "Mob still not aggresive to avatar", Done )
end

function IsAggresive( mobId )
	local aggro = debugMission.UnitGetAggroList( mobId )
	if aggro ~= nil then
		for unitId, value in aggro do
		    if unitId == avatar.GetId() then
				return true
			end
		end
	end
	
	return false
end

function Done()
	DisintagrateMob( MOB_NAME )
	StartTimer( 1000, Success, TEST_NAME )
end

function ErrorFunc( text )
	DisintagrateMob( MOB_NAME )
	StartTimer( 1000, Warning, text )
end

function Warning( text )
	Warn( TEST_NAME, text )
end


--------------------------------------- EVENTS --------------------------------------------

function OnAvatarCreated()
	StartTest( TEST_NAME )
	
	Log( "summoning mob..." )
	local newPos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), 1 )
	SummonMob( MOB_NAME, MAP_RESOURCE, newPos, 0, BeforeCheckAgroList, ErrorFunc )
end


function Init()
	local login = {
		login = developerAddon.GetParam( "login"),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" )
	}
	InitLoging(login)

    MOB_NAME = developerAddon.GetParam( "mobName" )

	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
end

Init()


