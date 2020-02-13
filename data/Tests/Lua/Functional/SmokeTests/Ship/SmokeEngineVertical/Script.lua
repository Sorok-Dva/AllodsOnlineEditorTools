Global( "TEST_NAME", "Smoke.ShipEngineVertical author: Vashenko Anton; date: 11.12.2008; task: 51298" )

-- param
Global( "SUMMON_SHIP_SPELL", nil )
-- /param

Global( "START_POS", nil )
Global( "SHIP_ID", nil )
Global( "DEV_ID", nil )

Global( "INDEX_ACTION", nil )

Global( "ERROR_MESSAGE", nil )


function PrintDevicesInfo( shipId )
	SHIP_ID = shipId
	PrintListDeviceShip( SHIP_ID, MoveToEngine )
end

function MoveToEngine()
	local deviceIndex = GetTransportDeviceIndex( SHIP_ID, SHIP_ENGINE_DEV, 2 )
	DEV_ID = GetTransportDeviceId( SHIP_ID, deviceIndex )

	TeleportToDevice( DEV_ID, SHIP_ID, 3, UseVerticalEngine, ErrorFunc )
end

function UseVerticalEngine()
	StartUsingTransportDevice( DEV_ID, PrintDeviceInfo, ErrorFunc )
end

function PrintDeviceInfo()
	INDEX_ACTION = -1
	PrintActiveUsableDeviceInfo( ChangeSpeed, ErrorFunc )
end

function ChangeSpeed()
	INDEX_ACTION = INDEX_ACTION + 1
	if INDEX_ACTION == 0 then
		RunVerticalEngine( SHIP_ID, INDEX_ACTION, true, WaitMaxSpeed, ErrorFunc )
	elseif INDEX_ACTION == 1 then
		RunVerticalEngine( SHIP_ID, INDEX_ACTION, false, WaitMaxSpeed, ErrorFunc )
	else
		RunVerticalEngine( SHIP_ID, INDEX_ACTION, nil, WaitStop, ErrorFunc )
	end
end

function WaitMaxSpeed()
	StartTimer( 3000, GetSpeed, nil )
end

function GetSpeed()
	Log( "max speed for index action=" .. tostring(INDEX_ACTION) .. " is " .. tostring( GetTransportVerticalSpeed( SHIP_ID ) ) )
	ChangeSpeed()
end

function WaitStop()
	StartCheckTimer( 20000, CheckForStopping, nil, ErrorFunc, "Ship vertical speed is not 0 after stopping", StopMove )
end

function CheckForStopping()
	return GetTransportVerticalSpeed( SHIP_ID ) == 0
end

function StopMove()
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