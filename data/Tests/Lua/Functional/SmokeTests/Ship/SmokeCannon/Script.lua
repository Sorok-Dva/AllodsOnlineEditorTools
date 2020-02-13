Global( "TEST_NAME", "Smoke.ShipCannon author: Vashenko Anton; date: 11.12.2008; task: 51298" )

-- param
Global( "SUMMON_SHIP_SPELL", nil )
Global( "INDEX_CANNON", nil )
-- /param

Global( "START_POS", nil )
Global( "SHIP_ID", nil )
Global( "DEV_ID", nil )

Global( "INDEX_ACTION", nil )

Global( "ERROR_MESSAGE", nil )



function PrintDevicesInfo( shipId )
	SHIP_ID = shipId
	PrintListDeviceShip( SHIP_ID, MoveToCannon )
end

function MoveToCannon()
	local devIndex = GetTransportDeviceIndex( SHIP_ID, SHIP_CANNON_DEV, INDEX_CANNON )
	DEV_ID = GetTransportDeviceId( SHIP_ID, devIndex )

	local indexSecCannon = 9 - INDEX_CANNON
	local secondCannonId = GetTransportDeviceId( SHIP_ID, GetTransportDeviceIndex( SHIP_ID, SHIP_CANNON_DEV, indexSecCannon ) )
	TeleportToDevice( DEV_ID, secondCannonId, 4, UseCannon, ErrorFunc )
end

function UseCannon()
	StartUsingTransportDevice( DEV_ID, PrintDeviceInfo, ErrorFunc )
end

function PrintDeviceInfo()
	INDEX_ACTION = -1
	PrintActiveUsableDeviceInfo( RunDevice, ErrorFunc )
end

function RunDevice()
	INDEX_ACTION = INDEX_ACTION + 1
	Log( "run device. index=" .. tostring( INDEX_ACTION ) )
	if INDEX_ACTION <= 3 then
		ShotCannon( SHIP_ID, INDEX_ACTION, RunDevice, ErrorFunc )
	else
		StopUsingTransportDevice( DEV_ID, Done, ErrorFunc )
	end
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
	INDEX_CANNON = tonumber( developerAddon.GetParam( "IndexCannon" ) )

	local login = {
		login = developerAddon.GetParam( "login" ),
		pass = developerAddon.GetParam(	"password" ),
		avatar = developerAddon.GetParam( "avatar" )
	}
	InitLoging(login)

	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
end

Init()