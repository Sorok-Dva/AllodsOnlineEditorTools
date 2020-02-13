Global( "TEST_NAME", "Smoke.ShipAltar author: Vashenko Anton; date: 11.12.2008; task: 51298" )

-- param
Global( "SUMMON_SHIP_SPELL", nil )
-- /param

Global( "DEBUFF_NAME", "Mechanics/Ships/Lazareth/Buff.xdb" )
Global( "LAZARETH_DEV_TYPE", USDEV_LAZARETH ) -- из AddonBase

Global( "START_POS", nil )
Global( "SHIP_ID", nil )
Global( "DEV_ID", nil )

Global( "ERROR_MESSAGE", nil )



-- respawn
function PrintDevicesInfo( shipId )
	SHIP_ID = shipId
	PrintListDeviceShip( SHIP_ID, KillAvatar )
end

function KillAvatar()
	KillMob( avatar.GetId(), AvatarRessurect, ErrorFunc )
end

function AvatarRessurect()
	avatar.Respawn()
	StartPrivateCheckTimer( 5000, CheckRessurect, nil, ErrorFunc, "Avatar did not spawned on ship", CheckDebuffExists, nil )
end

function CheckRessurect()
	return not unit.IsDead( avatar.GetId() )
end

function CheckDebuffExists()
	StartPrivateCheckTimer( 5000, CheckDebuffExistsFunction, nil, ErrorFunc, "Avatar don't have respawn-debuff", CheckDebuffNotExists, nil )
end
function CheckDebuffExistsFunction()
	return GetBuffInfo( avatar.GetId(), DEBUFF_NAME ) ~= nil
end

function CheckDebuffNotExists()
	StartPrivateCheckTimer( 35000, CheckDebuffNotExistsFunction, nil, ErrorFunc, "Avatar have respawn-debuff for 35 sec", UseLazareth, nil )
end
function CheckDebuffNotExistsFunction()
	return GetBuffInfo( avatar.GetId(), DEBUFF_NAME ) == nil
end


-- lazareth
function UseLazareth()
	local devIndex = GetTransportDeviceIndex( SHIP_ID, LAZARETH_DEV_TYPE, 1 )
	DEV_ID = GetTransportDeviceId( SHIP_ID, devIndex )
	StartUsingTransportDevice( DEV_ID, PrintDeviceInfo, ErrorFunc )
end

function PrintDeviceInfo()
	PrintActiveUsableDeviceInfo( StopUseLazareth, ErrorFunc )
end

function StopUseLazareth()
	StopUsingTransportDevice( DEV_ID, Done, ErrorFunc )
end




function Done()
	DisintShip()
end

function ErrorFunc( text )
	ERROR_MESSAGE = text
	DisintShip()
end

function DisintShip()
	if unit.GetTransport( avatar.GetId() ) ~= nil then
		Log( "Disintegrate ship" )
		debugMission.DisintegrateInteractive( unit.GetTransport( avatar.GetId() ) )
	end

	qaMission.AvatarRevive()
	qaMission.AvatarSetPos( START_POS )
	StartTimer( 2000, CloseScript )	
end

function CloseScript()
	if StringIsBlank( ERROR_MESSAGE ) == false then
		Warn( TEST_NAME, ERROR_MESSAGE )
	else
		Success( TEST_NAME )
	end
end




---------------------------------------- EVENTS -------------------------------------

function OnAvatarCreated( params )
	StartTest( TEST_NAME )

	START_POS = avatar.GetPos()
	local pos = {
		X = 11100,
		Y = 1370,
		Z = 15
	}
	SummonShip( SUMMON_SHIP_SPELL, PrintDevicesInfo, ErrorFunc, ToStandartCoord( pos ))	
end

function Init()
	SUMMON_SHIP_SPELL = developerAddon.GetParam( "SummonShipSpell" )

	local login = {
		login = developerAddon.GetParam( "login" ),
		pass = developerAddon.GetParam(	"password" ),
		avatar = developerAddon.GetParam( "avatar" )
	}
	InitLoging(login)
	
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
end

Init()