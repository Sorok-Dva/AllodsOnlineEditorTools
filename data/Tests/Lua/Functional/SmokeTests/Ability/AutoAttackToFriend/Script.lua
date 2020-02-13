Global( "TEST_NAME", "SmokeTest.AutoAttackToFriend author: Liventsev Andrey, date: 24.07.08, bug 37324" )

Global( "MOB_NAME",   nil )
Global( "WEAPON_NAME",  nil )

Global( "MAP_RESOURCE", "/Tests/Maps/Lua/MapResource.xdb" )
Global( "AUTO_ATTACK", "Mechanics/Spells/AutoAttack/MeleeDamage.xdb" )
-- Global( "AUTO_ATTACK", "Client/GMUIHelper/AutoAttackMelee.(SpellSingleTarget).xdb" )

Global( "MOB_ID", nil )

function Summon()
	local newPos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), 1 )
	SummonMob( MOB_NAME, MAP_RESOURCE, newPos, 0, TryToAttack, ErrorFunc )
end

function TryToAttack( unitId )
	MOB_ID = unitId
    SelectTarget( MOB_ID, AttackMob, ErrorFunc )
end

function AttackMob()
    local spellBook = avatar.GetSpellBook()
    StartTimer( 10000, Done )
    avatar.RunSpell( GetSpellId( AUTO_ATTACK ))
end

function Done()
	Log( "Done" )
	DisintagrateMob( MOB_NAME )
	WaitASec( Success, TEST_NAME )
end

function ErrorFunc( text )
	Log( "Error " .. tostring( text ) )
	DisintagrateMob( MOB_NAME )
	WaitASec( Warning, text )
end

function Warning( text )
	Warn( TEST_NAME, text )
end

function WaitASec( funcName, funcParam )
	StartTimer( 1000, funcName, funcParam )
end

--------------------------------------- EVENTS --------------------------------------------

function OnAvatarCreated()
	StartTest( TEST_NAME )
	qaMission.AvatarCreateItem( WEAPON_NAME )
	StartTimer( 3000, ErrorFunc, "item " .. WEAPON_NAME .. " did not added" )
end

function OnInventoryItemAdded( params )
	local itemId = avatar.GetInventoryItemId( params.slot )
	local itemInfo = avatar.GetItemInfo( itemId )
	if itemInfo.debugInstanceFileName == WEAPON_NAME then
		StopTimer()
		StartTimer( 2000, Summon )
		avatar.EquipItem( params.slot )
	end
end

function OnEquipFailed( params )
	Warn( TEST_NAME, "Can not equip item" )
end

function OnUnitDamageReceived( params )
	if params.source == avatar.GetId() and params.target == MOB_ID then
	    StopTimer()
	    Log( "Damage received" )
    	ErrorFunc( "Attack a friendly mob is possible" )
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


