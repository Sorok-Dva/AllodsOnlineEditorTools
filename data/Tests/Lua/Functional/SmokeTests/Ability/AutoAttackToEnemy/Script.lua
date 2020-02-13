Global( "TEST_NAME", "SmokeTest.AutoAttackToEnemy; author: Liventsev Andrey, date: 24.07.08, bug 37322" )

-- params
Global( "MOB_NAME",   nil )
Global( "WEAPON_NAME",  nil )
-- /params

Global( "MAP_RESOURCE", "/Tests/Maps/Lua/MapResource.xdb" )
-- Global( "AUTO_ATTACK", "Client/GMUIHelper/AutoAttackMelee.(SpellSingleTarget).xdb" )
Global( "AUTO_ATTACK", "Mechanics/Spells/AutoAttack/MeleeDamage.xdb" )

Global( "MOB_ID", nil )

Global( "CHECK_ATTACK11", nil )
Global( "CHECK_ATTACK12", nil )

Global( "CHECK_ATTACK21", nil )
Global( "CHECK_ATTACK22", nil )

Global( "IMMUNE_SPELL", "Mechanics/Spells/Cheats/IDDQD/Spell.xdb" )


function SummonMob1()
	local newPos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), 0.5 )
	SummonMob( MOB_NAME, MAP_RESOURCE, newPos, 0, TryToAttack1, ErrorFunc )
end

function TryToAttack1( unitId )
	MOB_ID = unitId
    SelectTarget( MOB_ID, AttackMob1, ErrorFunc )
end

function AttackMob1()
    StartTimer1( 10000, ErrorFunc, "Can not attack mob 1" )
	Log( "spell id=" .. tostring( GetSpellId( AUTO_ATTACK ) ))
    avatar.RunSpell( GetSpellId( AUTO_ATTACK ))
end


function SummonMob2()
	local newPos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), 0.5 )
	SummonMob( MOB_NAME, MAP_RESOURCE, newPos, 0, TryToAttack2, ErrorFunc )
end

function TryToAttack2( unitId )
	MOB_ID = unitId
    SelectTarget( MOB_ID, AttackMob2, ErrorFunc )
end

function AttackMob2()
    StartTimer1( 10000, ErrorFunc, "Can not attack mob 2" )
    avatar.RunSpell( GetSpellId( AUTO_ATTACK ))
end


function Done()
	DisintagrateMob( MOB_NAME )
	StartTimer( 1000, Success, TEST_NAME )
end

function ErrorFunc( text )
	DisintagrateMob( MOB_NAME )
	StartTimer( 1000, ErrorFunc2 )
end
function ErrorFunc2( text )
	Warn( TEST_NAME, text )
end


--------------------------------------- EVENTS --------------------------------------------

function OnAvatarCreated()
	StartTest( TEST_NAME )

	CHECK_ATTACK11 = false
	CHECK_ATTACK12 = false
	
	CHECK_ATTACK21 = false
	CHECK_ATTACK22 = false

	local pos = {
		X = 100,
		Y = 100,
		Z = 1
	}
	qaMission.AvatarSetPos( ToStandartCoord( pos ))
	LearnAndCastSpell( IMMUNE_SPELL, TEST_NAME )
	
	StartTimer1( 5000, SummonMob1 )
end

function OnInventoryItemAdded( params )
	local itemId = avatar.GetInventoryItemId( params.slot )
	local itemInfo = avatar.GetItemInfo( itemId )
	if itemInfo.debugInstanceFileName == WEAPON_NAME then
		StopTimer1()
        avatar.EquipItem( params.slot )
        
		DisintagrateMob( MOB_NAME )
		StartTimer1( 2000, SummonMob2 )
	end
end

function OnEquipFailed( params )
	Warn( TEST_NAME, "Can not equip item" )
end

function OnUnitDamageReceived( params )
	Log( "On unit damage received. from=" .. tostring(params.source) .. " to=" .. tostring(params.target))
	if params.source == avatar.GetId() and params.target == MOB_ID then
		if CHECK_ATTACK12 == false then
			if CHECK_ATTACK11 == false then
			    StopTimer1()
			    Log( "Run auto attack 1" )
				CHECK_ATTACK11 = true
				
				StartTimer1( 10000, ErrorFunc, "Can't attack mob" )
				local newPos = GetPositionAtDistance( avatar.GetPos(), math.pi - avatar.GetDir(), 5 )
				qaMission.AvatarSetPos( newPos )
			else
				StopTimer1()
			    Log( "Mob received damage" )
				CHECK_ATTACK12 = true
				
				StartTimer1( 3000, ErrorFunc, "item " .. WEAPON_NAME .. " did not added" )
				DisintagrateMob( MOB_NAME )
				qaMission.AvatarCreateItem( WEAPON_NAME )
			end	

		elseif CHECK_ATTACK22 == false then
			if CHECK_ATTACK21 == false then
			    StopTimer1()
			    Log( "Run auto attack 2" )
				CHECK_ATTACK21 = true
				
				StartTimer1( 10000, ErrorFunc, "Can't attack mob" )
				local newPos = GetPositionAtDistance( avatar.GetPos(), math.pi - avatar.GetDir(), 5 )
				qaMission.AvatarSetPos( newPos )
			else
				StopTimer1()
			    Log( "Mob received damage" )
				CHECK_ATTACK22 = true
				
				Done()
			end	
		end	
	end
end


function Init()
	local login = {
		login = developerAddon.GetParam( "login"),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" ),
		create = "AutoMage"
	}
	InitLoging(login)

    MOB_NAME = developerAddon.GetParam( "mobName" )
    WEAPON_NAME = developerAddon.GetParam( "weaponName" )
    
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
	common.RegisterEventHandler( OnInventoryItemAdded, "EVENT_INVENTORY_ITEM_ADDED" )
	common.RegisterEventHandler( OnEquipFailed, "EVENT_EQUIP_FAILED" )
	common.RegisterEventHandler( OnUnitDamageReceived, "EVENT_UNIT_DAMAGE_RECEIVED" )
end

Init()


