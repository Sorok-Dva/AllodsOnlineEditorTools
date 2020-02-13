Global( "TEST_NAME", "Smoke.ShipRudderHorizontal author: Vashenko Anton; date: 11.12.2008; task: 51298" )

-- param
Global( "SUMMON_SHIP_SPELL", nil )
-- /param

Global( "START_POS", nil )
Global( "DEV_ID", nil )
Global( "SHIP_ID", nil )

Global( "INDEX_ACTION",  nil )

Global( "ERROR_MESSAGE", nil )

function PrintDevicesInfo( shipId )
	SHIP_ID = shipId
	PrintListDeviceShip( SHIP_ID, MoveToEngine )
end

function MoveToEngine()
	local engineIndex = GetTransportDeviceIndex( SHIP_ID, SHIP_ENGINE_DEV, 1 )
	DEV_ID = GetTransportDeviceId( SHIP_ID, engineIndex )

	TeleportToDevice( DEV_ID, SHIP_ID, 3, UseEngineShip, ErrorFunc )
end

function UseEngineShip( )
	StartUsingTransportDevice( DEV_ID, SetShipSpeed, ErrorFunc )
end

function SetShipSpeed()
	RunHorizontalEngine( SHIP_ID, 2, nil, StopUsingEngine, ErrorFunc )
end

function StopUsingEngine()
	StopUsingTransportDevice( DEV_ID, MoveToRudder, ErrorFunc )
end

function MoveToRudder()
	local rudderIndex = GetTransportDeviceIndex( SHIP_ID, SHIP_RUDDER_DEV, 1 )
	DEV_ID = GetTransportDeviceId( SHIP_ID, rudderIndex )

	TeleportToDevice( DEV_ID, SHIP_ID, 3, UseRudderShip, ErrorFunc )
end

function UseRudderShip()
	StartUsingTransportDevice( DEV_ID, PrintDeviceInfo, ErrorFunc )
end

function PrintDeviceInfo()
	INDEX_ACTION = -1
	PrintActiveUsableDeviceInfo( RunRudder, ErrorFunc )
end

function RunRudder()
	Log( "RunRudder: " .. tostring( INDEX_ACTION ) )
	INDEX_ACTION = INDEX_ACTION + 1
	if INDEX_ACTION == 0 then
		RunHorizontalRudder( SHIP_ID, INDEX_ACTION, true, BeforeNextRunRudder, ErrorFunc )
	elseif INDEX_ACTION == 1 then
		RunHorizontalRudder( SHIP_ID, INDEX_ACTION, false, BeforeNextRunRudder, ErrorFunc )
	elseif INDEX_ACTION == 2 then
		RunRudder()
	elseif INDEX_ACTION == 3 then
		RunHorizontalRudder( SHIP_ID, INDEX_ACTION, false, BeforeNextRunRudder, ErrorFunc )
	elseif INDEX_ACTION == 4 then
		RunHorizontalRudder( SHIP_ID, INDEX_ACTION, false, StopDirection, ErrorFunc )
	end
end

function BeforeNextRunRudder()
	StartTimer( 1000, RunRudder )
end

function StopDirection()
	RunHorizontalRudder( SHIP_ID, 2, nil, BeforeCheckForStopDirection, ErrorFunc )
end

function BeforeCheckForStopDirection()
	StartTimer( 3000, CheckForStopDirection )
end

function CheckForStopDirection()
	if GetTransportDirectionSpeed( SHIP_ID ) == 0 then
		StopUsingTransportDevice( DEV_ID, Done, ErrorFunc )
	else
		ErrorFunc( "Ship direction speed is not 0 after stopping" )
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

	local login = {
		login = developerAddon.GetParam( "login" ),
		pass = developerAddon.GetParam(	"password" ),
		avatar = developerAddon.GetParam( "avatar" )
	}
	InitLoging(login)
	
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
end

Init()