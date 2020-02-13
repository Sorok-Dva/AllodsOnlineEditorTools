Global( "CHECK_FOR_INCREASE_SPEED", nil )
Global( "CHECK_FOR_INCREASE_DIR", nil )

Global( "SHIP_TRANSPORT_SPEED", nil )

Global( "SHIP_ENERGY_BEFORE_SHOT", nil )
Global( "SHIP_SHIP_ID", nil )


Global( "SHIP_CHECK_FOR_CANNON_COOLDOWN", nil )

Global( "SHIP_SUMMON_POS", nil )
Global( "SHIP_Z_COORD", nil )

Global( "SHIP_FUNC_PASS", nil )
Global( "SHIP_FUNC_ERROR", nil )

Global( "SHIP_CHEST_NAME", "Mechanics/Ships/Treasury/LootChest.xdb" )
Global( "CHEST_DEBUFF_NAME", "Mechanics/Ships/Treasury/Buff.xdb" )

Global( "SHIP_TELEPORT_DEV",  USDEV_TELEPORT )
Global( "SHIP_CANNON_DEV",    USDEV_CANNON )
Global( "SHIP_NAVIGATOR_DEV", USDEV_NAVIGATOR )
Global( "SHIP_ENGINE_DEV",    USDEV_REMOTE_ENGINE_HORIZONTAL )
Global( "SHIP_REACTOR_DEV",   USDEV_REACTOR )
Global( "SHIP_RUDDER_DEV",    USDEV_REMOTE_RUDDER )
Global( "SHIP_SHIELD_DEV",    USDEV_SHIELD )

-- Ship ------------------------------------------

-- саммонит корабль (прыгаем на 32*5 метров вверх, саммоним корабль спеллом, прыгаем на 32*2 метра вверх, падаем на корабль)
-- pos - необязатльный параметр - если надо засаммонит корабль в указанной точке
function SummonShip( summonShipSpell, funcPass, funcError, pos )
	ShipLog( "Try to summon ship" )
	if unit.GetTransport( avatar.GetId() ) ~= nil then
		funcError( "Can't summon ship: avatar already on the ship" )
	else
		SHIP_FUNC_PASS = funcPass
		SHIP_FUNC_ERROR = funcError
		SHIP_SUMMON_POS = pos

		ShipLog( "Summoning ship..." )
		LearnSpell( summonShipSpell, SS_ToSky, SHIP_FUNC_ERROR )
	end	
end

function SS_ToSky( spellId )
	local pos
	if SHIP_SUMMON_POS ~= nil then
		pos = SHIP_SUMMON_POS
	else
		pos = avatar.GetPos()
		pos.globalX = pos.globalX + 20
		pos.globalY = pos.globalY + 20
		pos.globalZ = pos.globalZ + 5
	end

	qaMission.AvatarSetPos( pos )
	CastSpell( spellId, nil, 2000, SS_ToSky2, SHIP_FUNC_ERROR, nil, true )
end

function SS_ToSky2()
	local pos = avatar.GetPos()
	pos.globalZ = pos.globalZ + 2
	qaMission.AvatarSetPos( pos )
	
	StartPrivateCheckTimer( 20000, SS_CheckFunc, nil, SHIP_FUNC_ERROR, "Can't summon ship", SS_PassFunc, nil )	
end
-- проверка, что корабль перестал падать
function SS_CheckFunc()
	local stopMoving = false
	if unit.GetTransport( avatar.GetId() ) ~= nil then
		local newPos = ToAbsCoord( avatar.GetPos() ).Z
		if SHIP_Z_COORD ~= nil then
			stopMoving = (SHIP_Z_COORD - newPos) < 0.001
		end
		SHIP_Z_COORD = newPos
	end

	return stopMoving
end

function SS_PassFunc()
	SHIP_FUNC_PASS( unit.GetTransport( avatar.GetId() ) )
end




-- Device ----------------------------------------------

function StartUsingTransportDevice( devId, funcPass, funcError )
	local deviceName = qaMission.DeviceGetDebugName( devId )
	ShipLog( "Start using device. id=" .. tostring( devId ) .. " name=" .. deviceName )
	if device.CanUse( devId ) == false then
	    funcError( "Device is not usable. name=" .. deviceName )
	end

	local d = GetDistanceFromPosition( devId, avatar.GetPos())
	Log( "distance=" .. tostring(d))
	object.Use( devId, 114 )
	StartPrivateCheckTimer( 3000, device.IsInUse, devId, funcError, "Can't start using device", funcPass, nil )
end

function StopUsingTransportDevice( devId, funcPass, funcError )
	ShipLog( "Stop using device. id=" .. tostring(devId ) )
	if device.IsInUse( devId ) == false then
		funcError( "Trying to stop using unused device. name=" .. unit.DeviceGetDebugName( devId ).xdbFileName )
	end	

	avatar.DeactivateUsableDevice()
	StartPrivateCheckTimer( 1500, StopUsingTransportDeviceCheckFunc, devId, funcError,"Can't stop using device", funcPass, nil )
end
function StopUsingTransportDeviceCheckFunc( devId )
	return not device.IsInUse( devId )
end




function ShotCannon( transportId, indexAction, funcPass, funcError )
	Log("")
	ShipLog( "Shot cannon. action #" .. tostring( indexAction ) )
	
	SHIP_CHECK_FOR_CANNON_COOLDOWN = false
	SHIP_SHIP_ID = transportId
	SHIP_ENERGY_BEFORE_SHOT = GetEnergyShip( transportId )
	SHIP_FUNC_PASS = funcPass
	SHIP_FUNC_ERROR = funcError
	common.RegisterEventHandler( SS_OnCannonShotStarted, "EVENT_CANNON_SHOT_STARTED" )
	common.RegisterEventHandler( SS_OnDeviceCooldownFinished, "EVENT_DEVICE_COOLDOWN_FINISHED" )
	
	StartPrivateTimer( 5000, SHIP_FUNC_ERROR, "Can't shot from cannon (EVENT_CANNON_SHOT_STARTED did not come). action#" .. tostring( indexAction ))	

	avatar.RunUsableDeviceAction( indexAction ) -- ждем события EVENT_CANNON_SHOT_STARTED 
end




-- Zoom-------------------------------------------------

function NavigatorZoomOnShip( transportId, funcPass, funcError )
	SHIP_SHIP_ID = transportId
	SHIP_FUNC_PASS = funcPass
	SHIP_FUNC_ERROR = funcError
	common.RegisterEventHandler( SS_OnTransportObservingStarted, "EVENT_TRANSPORT_OBSERVING_STARTED" )

	StartPrivateTimer( 3000, SHIP_FUNC_ERROR, "EVENT_TRANSPORT_OBSERVING_STARTED did not come - can't zoom on" )
	device.NavigatorZoomInTransport( transportId )
end

function NavigatorUnZoomOnShip( funcPass, funcError )
	SHIP_FUNC_PASS = funcPass
	common.RegisterEventHandler( SS_OnTransportObservingFinished, "EVENT_TRANSPORT_OBSERVING_FINISHED" )

	StartPrivateTimer( 3000, funcError, "EVENT_TRANSPORT_OBSERVING_FINISHED did not come - can't zoom out" )
	device.NavigatorZoomOut()
end




-- Reactor ---------------------------------------------

function DesummonShipUseReactor( funcPass, funcError )
	avatar.RunUsableDeviceAction( 0 )
	StartPrivateCheckTimer( 40000, SS_ReactorCheckFunc, nil, funcError, "Failed to destroy the ship through the reactor", funcPass, nil )
end
function SS_ReactorCheckFunc()
	return unit.GetTransport( avatar.GetId() ) == nil
end





--  Engine ----------------------------------------------

-- checkForIncreaseSpeed - если true проверяем на увеличение скорости, если false на уменьшение, если nil - не проверяем
function RunHorizontalEngine( transportId, indexAction, checkForIncreaseSpeed, funcPass, funcError )
	Log("")
	ShipLog( "Use horizontal engine, action = " .. tostring( indexAction ) )
	
	SHIP_SHIP_ID = transportId
	SHIP_FUNC_PASS = funcPass
	SHIP_FUNC_ERROR = funcError
	CHECK_FOR_INCREASE_SPEED = checkForIncreaseSpeed
	SHIP_TRANSPORT_SPEED = GetTransportHorizontalSpeed( SHIP_SHIP_ID )
	
	avatar.RunUsableDeviceAction( indexAction )	
	if CHECK_FOR_INCREASE_SPEED ~= nil then
		StartPrivateTimer( 1000, SS_CheckChangeHSpeed )
	else
		SHIP_FUNC_PASS()
	end	
end
function SS_CheckChangeHSpeed()
	local passed = nil
	local text = nil

	if CHECK_FOR_INCREASE_SPEED == true then
		passed = SHIP_TRANSPORT_SPEED < GetTransportHorizontalSpeed( SHIP_SHIP_ID )
		text = "Speed did not increase after using horizontal engine"
	else
		passed = SHIP_TRANSPORT_SPEED > GetTransportHorizontalSpeed( SHIP_SHIP_ID )
		text = "Speed did not decrease after using horizontal engine"	
	end
	
	if passed == true then
		SHIP_FUNC_PASS()
	else
		SHIP_FUNC_ERROR( text )
	end
end

function RunVerticalEngine( transportId, indexAction, checkForIncreaseSpeed, funcPass, funcError )
	Log("")
	ShipLog( "Use vertical engine, action = " .. tostring( indexAction ) )
	
	SHIP_SHIP_ID = transportId
	SHIP_FUNC_PASS = funcPass
	SHIP_FUNC_ERROR = funcError
	CHECK_FOR_INCREASE_SPEED = checkForIncreaseSpeed
	SHIP_TRANSPORT_SPEED = GetTransportVerticalSpeed( SHIP_SHIP_ID )
	
	avatar.RunUsableDeviceAction( indexAction )	
	StartPrivateTimer( 1000, SS_CheckChangeVSpeed )
end
function SS_CheckChangeVSpeed()
	local passed = nil
	local text = nil
	
	if CHECK_FOR_INCREASE_SPEED == nil then
		SHIP_FUNC_PASS()
		return
	elseif CHECK_FOR_INCREASE_SPEED == true then
		passed = SHIP_TRANSPORT_SPEED < GetTransportVerticalSpeed( SHIP_SHIP_ID )
		text = "Speed did not increase after using vertical engine"
	else
		passed = SHIP_TRANSPORT_SPEED > GetTransportVerticalSpeed( SHIP_SHIP_ID )
		text = "Speed did not decrease after using vertical engine"	
	end
	
	if passed == true then
		SHIP_FUNC_PASS()
	else
		SHIP_FUNC_ERROR( text )
	end
end

function RunHorizontalRudder( transportId, indexAction, checkForIncreaseDir, funcPass, funcError )
	ShipLog( "use rudder. actionIndex = " .. tostring( indexAction ) )
	INDEX_ACTION_DEV = indexAction

	SHIP_SHIP_ID = transportId
	SHIP_FUNC_PASS = funcPass
	SHIP_FUNC_ERROR = funcError
	CHECK_FOR_INCREASE_DIR = checkForIncreaseDir
	SHIP_TRANSPORT_SPEED = GetTransportDirectionSpeed( transportId )
	
	avatar.RunUsableDeviceAction( indexAction )
	StartPrivateTimer( 1000, SS_CheckChangeDir )
end
function SS_CheckChangeDir()
	local passed = nil
	local text = nil
	
	Log( " -- dir: " )
	Log( tostring( SHIP_TRANSPORT_SPEED ))
	Log( tostring( GetTransportDirectionSpeed( SHIP_SHIP_ID ) ))
	
	if CHECK_FOR_INCREASE_DIR == nil then
		SHIP_FUNC_PASS()
		return 
		
	elseif CHECK_FOR_INCREASE_DIR == true then
		passed = SHIP_TRANSPORT_SPEED < GetTransportDirectionSpeed( SHIP_SHIP_ID )
		text = "Ship direction velocity did not increase"
	else
		passed = SHIP_TRANSPORT_SPEED > GetTransportDirectionSpeed( SHIP_SHIP_ID )
		text = "Ship direction velocity did not decrease"		
	end

	if passed == true then
		SHIP_FUNC_PASS()
	else
		SHIP_FUNC_ERROR( text )
	end	
end



function UseChest( passFunc, errorFunc, checkForDebuff )
	ShipLog( "Using chest..." )
	SHIP_FUNC_PASS = funcPass
	SHIP_FUNC_ERROR = funcError
	
	TeleportToDevice( GetChestId() , unit.GetTransport( avatar.GetId() ), 3, SS_UseChest )
end

function SS_UseChest()
	object.Use( GetChestId(), 119 )
	StartPrivateCheckTimer( 5000, SS_CheckChestDebuff, nil, ErrorFunc, "Avatar don't have chest debuff", SHIP_FUNC_PASS )
end

function SS_CheckChestDebuff()
	return GetBuffInfo( avatar.GetId(), CHEST_DEBUFF_NAME ) ~= nil
end



-- телепорт к Телепортатору и ожидание телепорта на другой корабль
function TeleportBetweenShip( funcPass, funcError )
	ShipLog( "teleport to another ship... my ShipId=" .. tostring( unit.GetTransport( avatar.GetId() )))
	
	local transportId = unit.GetTransport( avatar.GetId() )
	local devIndex = GetTransportDeviceIndex( transportId, SHIP_TELEPORT_DEV, 1 )
	local devId = GetTransportDeviceId( transportId, devIndex )
	TeleportToDevice( devId, transportId, 3, EmptyFunction )
	
	local transportId = unit.GetTransport( avatar.GetId() )
	StartPrivateCheckTimer( 45000, SS_CheckTeleportToShip, transportId, funcError, "Can't teleport to ship", funcPass, nil )
end
function SS_CheckTeleportToShip( transportId )
	local shipId = unit.GetTransport( avatar.GetId() )
	if shipId ~= nil and shipId ~= transportId then
		ShipLog( "teleprt to another ship DONE" )
	end
	return shipId ~= nil and shipId ~= transportId
end



-- телепортирует к девайсу. если задан secDevId, то телепортируемся к девайсу со смещением в distance метров - чтобы можно было поюзать
function TeleportToDevice( firstDevId, secDevId, distance, funcPass, funcError )
	SHIP_FUNC_PASS = funcPass
	SHIP_FUNC_ERROR = funcError
	
	local firstPos = debugMission.InteractiveObjectGetPos( firstDevId )
	local pos = firstPos
	if secDevId ~= nil and distance ~= nil then
		local secondPos = debugMission.InteractiveObjectGetPos( secDevId )
		pos = GetPosFromPointToPoint( firstPos, secondPos, distance )
	end	
	pos = ToAbsCoord( pos )
	pos.Z = pos.Z + 1
	
	qaMission.AvatarSetPos( ToStandartCoord( pos ))
	StartPrivateTimer( 3000, funcPass )
end


-- возвращает энергию реактора
function GetEnergyShip( transportId )
	local energy = transport.GetEnergy( transportId )
	return energy.value
end

-- возвращает номер девайса на корабле по порядковому номеру определенного типа
-- пример - 5 пушек на корабде имеют индексы от 10 до 15
-- для входных параметров "пушка", 3 вернет 13
function GetTransportDeviceIndex( transportId, indexTypeDev, index )
	if transportId == nil then
		return nil
	end
	
	local num = 1
	local devices = transport.GetDevices( transportId )
	for i, deviceId in devices do
		local typeDev = device.GetUsableDeviceType( deviceId )
		if typeDev == indexTypeDev then
			if num == index then
				return i
			else
				num = num + 1
			end
		end
	end
	
	return nil
end

-- возвращает Id девайса по его индексу
function GetTransportDeviceId( transportId, index )
	local devices = transport.GetDevices( transportId )
	if devices then
		return devices[index]
	else
		TextShipError( "devices nil. index = " .. tostring( index ) )
		return nil
	end
end

-- получаем инфу о возможных действиях
function PrintActiveUsableDeviceInfo( funcPass, funcError )
	local deviceInfo = avatar.GetActiveUsableDeviceInfo()
	if deviceInfo then
		local actions = deviceInfo.actions

		Log( "" )
		Log( "" )
		ShipLog( "  ----------------- print device info ---------------------" )
		ShipLog( "DeviceName: " .. debugCommon.FromWString( deviceInfo.name ) .. ", actions count: " .. GetTableSize( actions ) )

		local countDev = GetTableSize( actions )
		
		for i = 0,  countDev - 1 do
  			local action = actions[i]
			ShipLog( " action: " .. i .. ", name: " .. debugCommon.FromWString( action.name ) )
		end
		Log( "" )
		Log( "" )
		funcPass()
	else
		funcError( "Active usable device not founded" )
	end
end

-- сбор начальных состояний девайсов корабля
function PrintListDeviceShip( transportId, funcPass )
	if transportId then
		Log( "" )
		Log( "" )
		ShipLog( "  ----------------- print transport info ---------------------" )
		local transportHealth = transport.GetHealth( transportId )
	
  		if transportHealth then
  			ShipLog("Transport")
    		ShipLog( "   value = " .. transportHealth.value )
    		ShipLog( "   limitBase = " .. transportHealth.limitBase )
    		ShipLog( "   limitResult = " .. transportHealth.limitResult )
    	else
    		TextShipError( "Health = nil" )
  		end
  		
		Log( "" )
		ShipLog( "Check device" )

		-- проверяем все устройства
		local devices = transport.GetDevices( transportId )
		
		for i, deviceId in devices do
			if deviceId then
				-- имя
				local name = device.GetName( deviceId )
				if name then
					ShipLog( "Device name = " .. debugCommon.FromWString( name ) )
				end
				
				-- хиты
				local health  = device.GetHealth ( deviceId )
				if health then
					ShipLog( "health = " .. health.value )
				end
		
				-- true если устройство выключено
				local deviceCanNotWork = device.IsOffline( deviceId )
				if deviceCanNotWork then
					TextShipError( "Device offline" )
				else
					ShipLog( "Device work" )
				end
				
				-- можно ли использовать устройство?			
				local isUsable = device.IsUsable( deviceId )
				if isUsable then
					ShipLog( "Device is usable" )
				else
					TextShipError( "Device not usable" )
				end
				
				-- устройство используется кем-либо?
				local isInUse = device.IsInUse( deviceId )
				if isInUse then
					TextShipError( "Device is used" )
				else
					ShipLog( "Device not used" )
				end
				
				-- слот и сторона
				local slotInfo = device.GetShipSlotInfo( deviceId )
				
				if slotInfo then
					local slotIndex = slotInfo.interfaceSlot
					local side = slotInfo.side
					ShipLog( "interfaceSlot = " .. slotIndex )

					if side == SHIP_SIDE_NONE then
						TextShipError( "side = side not found" )
					elseif side == SHIP_SIDE_GENERAL then
						ShipLog( "side = general" )
					elseif side == SHIP_SIDE_FRONT then
						ShipLog( "side = front" )
					elseif side == SHIP_SIDE_REAR then
						ShipLog( "side = rear" )
					elseif side == SHIP_SIDE_LEFT then
						ShipLog( "side = left" )
					elseif side == SHIP_SIDE_RIGHT then
						ShipLog( "side = right" )
					end
				end
				
				-- тип устройства
				local typeDev = device.GetUsableDeviceType( deviceId )
				
				if typeDev ~= USDEV_NOT_USABLE_DEVICE then
					if typeDev == USDEV_REACTOR then
						ShipLog( "type = reactor" )
						local energy = transport.GetEnergy( transportId )
  						if energy then
    						local value = energy.value
    						ShipLog ( "Energy value = " .. value )
    						local limitBase = energy.limitBase
    						ShipLog ( "Energy limitBase = " .. limitBase )
    						local limitResult = energy.limitResult
    						ShipLog ( "Energy limitResult = " .. limitResult )
    						
    						if value ~= 0 then
    							TextShipError( "Energy reactor != 0" )
    						end
    					else
    						TextShipError( "Energy = nil" )
  						end
					elseif typeDev == USDEV_ENGINE_HORIZONTAL then
						-- двигатель
						ShipLog( "type = engine horizontal" )
					elseif typeDev == USDEV_ENGINE_VERTICAL then
						-- двигатель высоты
						ShipLog( "type = engine vertical" )
					elseif typeDev == USDEV_RUDDER then
						-- руль
						ShipLog( "type = rudder" )
					elseif typeDev == USDEV_CANNON then
						-- пушка
						ShipLog( "type = cannon" )
					elseif typeDev == USDEV_TORPEDO then
						-- торпеда
						ShipLog( "type = torpedo" )
					elseif typeDev == USDEV_SHIELD then
						-- щит
						ShipLog( "type = shield" )
						local strength = device.GetShieldStrength( deviceId )
						if strength then
  							ShipLog( "Strength = " .. strength.value )
  							ShipLog( "StrengthMax = " .. strength.maxValue )
  						else
  							TextShipError( "Strength shield = nil" )
						end
					elseif typeDev == USDEV_NAVIGATOR then
						-- визор
						ShipLog( "type = navigator" )
					elseif typeDev == USDEV_REPAIR then
						-- ремонт
						ShipLog( "type = repair" )
					elseif typeDev == USDEV_TELEPORT then
						-- телепорт
						ShipLog( "type = teleport" )
					elseif typeDev == USDEV_LAZARETH then
						-- лазарет
						ShipLog( "type = lazareth" )
					end
				else
					TextShipError( "Device impossible to use" )
				end -- if type ~= ...
				Log( "" )
			else
				TextShipError( "Device not found. Index = " .. tostring( i ) )
			end -- if deviceId ...
		end -- for i, deviceId ...
		
		funcPass()
	else
		TextShipError( "Ship id = nil" )
	end
end

function GetTransportHorizontalSpeed( transportId )
	local velocities = transport.GetVelocities( transportId )
	return velocities.horizontal
end

function GetTransportVerticalSpeed( transportId )
	local velocities = transport.GetVelocities( transportId )
	return velocities.vertical
end

function GetTransportDirectionSpeed( transportId )
	local velocities = transport.GetVelocities( transportId )
	return velocities.angular
end

function GetChestId()
	local devices = avatar.GetDeviceList()
	for i, deviceId in devices do
		if qaMission.DeviceGetDebugName( deviceId ) == SHIP_CHEST_NAME then
			return deviceId
		end
	end
	return nil
end






function ShipLog( text )
	Log( text, "Ship" )
end

function TextShipError( text )
	Log( " --------------------------  SHIP WARNING ------------------------ ")
	Log( "       " .. text )
end

------------------------------------------------ EVENTS ------------------------------------------

function SS_OnCannonShotStarted( params )
	ShipLog ( "Energy before shot = " .. tostring( SHIP_ENERGY_BEFORE_SHOT ) .. ", energy last shot = " .. tostring( GetEnergyShip( SHIP_SHIP_ID ) ) )
	SHIP_CHECK_FOR_CANNON_COOLDOWN = true
	StartPrivateTimer( 60000, SHIP_FUNC_ERROR, "Colldown not finished (maybe not started)" )
end

function SS_OnDeviceCooldownFinished()
	if SHIP_CHECK_FOR_CANNON_COOLDOWN == true then
		StopPrivateTimer()
		common.UnRegisterEventHandler( "EVENT_CANNON_SHOT_STARTED" )
		common.UnRegisterEventHandler( "EVENT_DEVICE_COOLDOWN_FINISHED" )

		SHIP_FUNC_PASS()
	end	
end

function SS_OnTransportObservingStarted()
	StopPrivateTimer()
	common.UnRegisterEventHandler( "EVENT_TRANSPORT_OBSERVING_STARTED" )
	
	if avatar.GetObservedTransport() == SHIP_SHIP_ID then
		Log( "good" )
		SHIP_FUNC_PASS()
	else
		SHIP_FUNC_ERROR( "Zoom on wrong transport. id=" .. tostring( avatar.GetObservedTransport() ) .. " (should be " .. tostring(SHIP_SHIP_ID) .. ")" )
	end	
end

function SS_OnTransportObservingFinished()
	StopPrivateTimer()
	common.UnRegisterEventHandler( "EVENT_TRANSPORT_OBSERVING_FINISHED" )
	
	Log( "good" )
	SHIP_FUNC_PASS()
end
