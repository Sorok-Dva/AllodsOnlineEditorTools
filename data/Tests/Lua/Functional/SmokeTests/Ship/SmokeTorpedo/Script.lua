Global( "TEST_NAME", "Smoke.ShipTorpedo author: Vashenko Anton; date: 11.12.2008; task: 51298" )

-- param
Global( "SUMMON_SHIP_SPELL", nil )
Global( "INDEX_TORPEDO", nil )
-- /param

Global( "TORPEDO_DEV_TYPE", USDEV_CANNON )
Global( "START_POS", nil )
Global( "SHIP_ID", nil )
Global( "DEV_ID", nil )
Global( "ERROR_MESSAGE", nil )


function PrintDevicesInfo( shipId )
	SHIP_ID = shipId
	PrintListDeviceShip( SHIP_ID, MoveToTorpedos )
end

function MoveToTorpedos()
	local devIndex = GetTransportDeviceIndex( SHIP_ID, SHIP_CANNON_DEV, INDEX_TORPEDO )
	DEV_ID = GetTransportDeviceId( SHIP_ID, devIndex )

	local indexSecCannon = 8 + 11 - INDEX_TORPEDO
	local secondCannonId = GetTransportDeviceId( SHIP_ID, GetTransportDeviceIndex( SHIP_ID, SHIP_CANNON_DEV, indexSecCannon ) )
	
	TeleportToDevice( DEV_ID, secondCannonId, 3, UseTorpedo, ErrorFunc )
end

function UseTorpedo()
	StartUsingTransportDevice( DEV_ID, PrintDeviceInfo, ErrorFunc )
end

function PrintDeviceInfo()
	PrintActiveUsableDeviceInfo( RunDevice, ErrorFunc )
end

function RunDevice()
	Log( "run device. index=0" )
	ShotCannon( SHIP_ID, 0, StopUseTorpedo, ErrorFunc )
end

function StopUseTorpedo()
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
	INDEX_TORPEDO = 8 + tonumber( developerAddon.GetParam( "IndexTorpedo" ) )
	
	local login = {
		login = developerAddon.GetParam( "login" ),
		pass = developerAddon.GetParam(	"password" ),
		avatar = developerAddon.GetParam( "avatar" )
	}
	InitLoging(login)
	
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
end

Init()