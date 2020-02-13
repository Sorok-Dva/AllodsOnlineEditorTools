Global( "TEST_NAME", "Smoke.ShipReactor author: Vashenko Anton; date: 11.12.2008; task: 51298" )

-- param
Global( "SUMMON_SHIP_SPELL", nil )
-- /param

Global( "START_POS", nil )
Global( "SHIP_ID", nil )
Global( "DEV_ID", nil )

Global( "ERROR_MESSAGE", nil )


function PrintDevicesInfo( shipId )
	SHIP_ID = shipId
	PrintListDeviceShip( SHIP_ID, MoveToReactor )
end

function MoveToReactor()
	local devIndex = GetTransportDeviceIndex( SHIP_ID, SHIP_REACTOR_DEV, 1 )
	DEV_ID = GetTransportDeviceId( SHIP_ID, devIndex )

	TeleportToDevice( DEV_ID, SHIP_ID, 3, UseReactor, ErrorFunc )
end

function UseReactor()
	StartUsingTransportDevice( DEV_ID, PrintDeviceInfo, ErrorFunc )
end

function PrintDeviceInfo()
	PrintActiveUsableDeviceInfo( RunDevice, ErrorFunc )
end

function RunDevice()
	DesummonShipUseReactor( Done, ErrorFunc )
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