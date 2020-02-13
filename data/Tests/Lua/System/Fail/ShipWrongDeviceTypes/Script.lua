-- Task: 48910. Смок тест корабля.

Global( "TEST_NAME", "TypeDevice" )
Global( "SUMMON_SHIP_SPELL", nil )
Global( "DESUMMON_SHIP_SPELL", nil )
Global( "TRANSPORT_CHANGED", false )

function SummonShip()
	LearnAndCastSpell( SUMMON_SHIP_SPELL, TEST_NAME )
	StartPrivateCheckTimer( 20000, CheckShipCreate, nil, FuncError, "Not ship created", GetListDeviceShip, nil )
end

function GetListDeviceShip()
	local transportId = unit.GetTransport( avatar.GetId() )
	
	if transportId then
		local devices = transport.GetDevices( transportId )
		
		Log( "" )
		Log( "const USDEV_CANNON = " ..tostring( USDEV_CANNON ) .. " != " .. "const USDEV_TORPEDO = " .. tostring( USDEV_TORPEDO ) )
		Log( "" )
		
		for i, deviceId in devices do
			if deviceId then
				local typeDev = device.GetUsableDeviceType( deviceId )
				if typeDev ~= USDEV_NOT_USABLE_DEVICE then
					if typeDev == USDEV_CANNON then
						Log( "USDEV_CANNON: Type = " .. tostring( USDEV_CANNON ) )
					elseif typeDev == USDEV_TORPEDO then
						Log( "USDEV_TORPEDO: Type = " .. tostring( USDEV_TORPEDO ) )
					end
				else
					TextError( "Device impossible to use" )
				end
			else
				TextError( "Device not found. Index = " .. tostring( i ) )
			end
		end
	else
		FuncError( "Ship id = nil" )
	end
	DesummonShip()
end

function DesummonShip()
	LearnAndCastSpell( DESUMMON_SHIP_SPELL, TEST_NAME )
	StartPrivateCheckTimer( 20000, CheckShipFree, nil, FuncError, "Not ship desummon", Done, nil )
end

function Done()
	Success( TEST_NAME )
end

function FuncError( text )
	Warn( TEST_NAME, text )
end

function TextError( text )
	Log ( "Error: " .. text )
end

function CheckShipCreate()
	local transportId = unit.GetTransport( avatar.GetId() )
	if transportId and TRANSPORT_CHANGED then
	    TRANSPORT_CHANGED = false
	    return true
	else
		return false
	end
end

function CheckShipFree()
	local transportId = unit.GetTransport( avatar.GetId() )
	if transportId then
	    return false
	elseif TRANSPORT_CHANGED then
		TRANSPORT_CHANGED = false
		return true
	end
end


-- Events


function OnEventAvatarCreated( params )
	SummonShip()
end

function OnEventAvatarTransportChanged()
	TRANSPORT_CHANGED = true
end

function Init()
	local login = {
		login = developerAddon.GetParam( "login" ),
		pass = developerAddon.GetParam(	"password" ),
		avatar = developerAddon.GetParam( "avatar" )
		}
		
	SUMMON_SHIP_SPELL = tostring( developerAddon.GetParam( "SummonShipSpell" ) )
	DESUMMON_SHIP_SPELL = tostring( developerAddon.GetParam( "DesummonShipSpell" ) )

	InitLoging(login)
	
	common.RegisterEventHandler( OnEventAvatarCreated, "EVENT_AVATAR_CREATED" )
	common.RegisterEventHandler( OnEventAvatarTransportChanged, "EVENT_AVATAR_TRANSPORT_CHANGED" )
	common.RegisterEventHandler( OnEventAvatarPosChanged, "EVENT_AVATAR_POS_CHANGED" )
	common.RegisterEventHandler( OnEventCannonShotStarted, "EVENT_CANNON_SHOT_STARTED" )
	common.RegisterEventHandler( OnEventDeviceCooldownStarted, "EVENT_DEVICE_COOLDOWN_STARTED" )
	common.RegisterEventHandler( OnEventDeviceCooldownFinished, "EVENT_DEVICE_COOLDOWN_FINISHED" )
	common.RegisterEventHandler( OnEventTransportObservingStarted, "EVENT_TRANSPORT_OBSERVING_STARTED" )
	common.RegisterEventHandler( OnEventTransportObservingFinished, "EVENT_TRANSPORT_OBSERVING_FINISHED" )
end

Init()