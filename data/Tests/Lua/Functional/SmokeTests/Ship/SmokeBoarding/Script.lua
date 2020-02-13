Global( "TEST_NAME", "Smoke.ShipBoardingParent author: Vashenko Anton; date: 19.12.2008; task: 51298" )

-- param
Global( "SUMMON_SHIP_SPELL", nil )
Global( "INDEX_CANNON", nil )
-- /param

Global( "CANNON_INDEX_ACTION", 3 )



Global( "DEBUFF_NAME", "Mechanics/Ships/Lazareth/Buff.xdb" )

Global( "START_POS", nil )

Global( "SHIP_ID", nil )
Global( "CANNON_ID", nil )



Global( "CHEST_ID", nil )

Global( "ERROR_MESSAGE", nil )

Global( "CHILD_NAME", nil )
Global( "CHILD_PREFIX", "Child:" )
Global( "PARENT_PREFIX", "Parent:" )

Global( "ERROR_TEXT", "Error" )
Global( "DONE_TEXT", "Done" )
Global( "START_BOARDING", "StartBoarding" )
Global( "TAKE_CHEST", "TakeChest" )

Global( "PARENT_FUNC_PASS", nil )
Global( "CHECK_START_BOARDING", nil )
Global( "INDEX_CYCLE_BOARDING", nil )



function TeleportToCannon( shipId )
	SHIP_ID = shipId
	
	local devIndex = GetTransportDeviceIndex( SHIP_ID, SHIP_CANNON_DEV, INDEX_CANNON )
	CANNON_ID = GetTransportDeviceId( SHIP_ID, devIndex )
	
	local indexSecCannon = 9 - INDEX_CANNON
	local secondCannonId = GetTransportDeviceId( SHIP_ID, GetTransportDeviceIndex( SHIP_ID, SHIP_CANNON_DEV, indexSecCannon ) )
	TeleportToDevice( CANNON_ID, secondCannonId, 4, RunChildAddon )
end

function RunChildAddon()
	-- ждем когда child нам ответит, но на всякий случай запускаем выход
	StartTimer( 90000, ErrorFunc, "Can't recieve response from child addon" )
	developerAddon.RunChildGame( "Child.(DeveloperAddon).xdb", " -silentMode" )
end



function InitBoarding()
	Log( "Use cannon" )
	
	object.Use( CANNON_ID, 120 )
	StartPrivateCheckTimer( 5500, device.IsInUse, CANNON_ID, ErrorFunc, "Can't start using boarding cannon", StartBoarding, nil )
end
function StartBoarding()
	Log( "Start boarding" )

	CHECK_START_BOARDING = false
	
	avatar.RunUsableDeviceAction( CANNON_INDEX_ACTION )
	StartPrivateTimer( 15000, ErrorFunc, "Can't start boarding (EVENT_ABORDAGE_STARTED did not come)" )
end



function TeleportToEnemyTreasure()
	Log( "teleport to enemy treasure" )
	local transportId = unit.GetTransport( avatar.GetId() )
	local devIndex = GetTransportDeviceIndex( transportId, USDEV_TREASURE, 1 )
	local devId = GetTransportDeviceId( transportId, devIndex )
	
	TeleportToDevice( devId, transportId, 3, UseEnemyChest )
end

function UseEnemyChest()
	-- if INDEX_CYCLE_BOARDING == 1 then
		-- UseChest( TeleportToMyShip )
	-- elseif INDEX_CYCLE_BOARDING == 2 then
		-- UseChest( TeleportToUpperDeck )	
	-- end
end

function TeleportToMyShip()
	TeleportBetweenShip( TeleportToMyTreasure )
end

function TeleportToMyTreasure()
	Log( "tp to treasure" )
	INDEX_CYCLE_BOARDING = INDEX_CYCLE_BOARDING + 1
	TeleportToTreasure( TeleportToEnemyShip )
end

function TeleportToUpperDeck()
	local transportId = unit.GetTransport( avatar.GetId() )
	local pos = debugMission.InteractiveObjectGetPos( transportId )
	qaMission.AvatarSetPos( pos )
	StartTimer( 2000, KillAvatarOnEnemyShip )
end

function KillAvatarOnEnemyShip()
	KillMob( avatar.GetId(), AvatarRessurect, ErrorFunc )
end

function AvatarRessurect()
	group.ChatWhisper( debugCommon.ToWString( CHILD_NAME ), debugCommon.ToWString( PARENT_PREFIX .. TAKE_CHEST ) )
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
	StartPrivateCheckTimer( 35000, CheckDebuffNotExistsFunction, nil, ErrorFunc, "Avatar have respawn-debuff for 35 sec", CheckOnMyShip, nil )
end
function CheckDebuffNotExistsFunction()
	return GetBuffInfo( avatar.GetId(), DEBUFF_NAME ) == nil
end

function CheckOnMyShip()
	if unit.GetTransport( avatar.GetId() ) ~= SHIP_ID then
		ErrorFunc( "Avatar respawn on other ship. MyShipId = " .. tostring( SHIP_ID ) .. ", ship_id = " .. tostring( unit.GetTransport( avatar.GetId() ) ) )
	else
		WaitFinishedBoarding()
	end
end

function WaitFinishedBoarding()
	StartTimer( 210, ErrorFunc, "Abordage not finished" )
end


function TeleportToEnemyShip()
	TeleportBetweenShip( TeleportToEnemyTreasure )
end



function TeleportToTreasure( funcPass )
	local transportId = unit.GetTransport( avatar.GetId() )
	local devIndex = GetTransportDeviceIndex( transportId, USDEV_TREASURE, 1 )
	local devId = GetTransportDeviceId( transportId, devIndex )
	TeleportToDevice( devId, transportId, 3, funcPass )
end

function UseChest( funcPass )
	TeleportToDevice( CHEST_ID , unit.GetTransport( avatar.GetId() ), UsingChest )
end
function UsingChest()
	object.Use( CHEST_ID, 119 )
	StartPrivateCheckTimer( 5000, CheckDebuffChestExists, nil, ErrorFunc, "Avatar don't have chest-debuff", PARENT_FUNC_PASS, nil )
end
function CheckDebuffChestExists()
	return GetBuffInfo( avatar.GetId(), DEBUFF_CHEST_NAME ) ~= nil
end




function Done()
	group.ChatWhisper( debugCommon.ToWString( CHILD_NAME ), debugCommon.ToWString( PARENT_PREFIX .. DONE_TEXT ) )
	DisintShip()
end

function ErrorFunc( text )
	group.ChatWhisper( debugCommon.ToWString( CHILD_NAME ), debugCommon.ToWString( PARENT_PREFIX .. ERROR_TEXT ) )
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
	SummonShip( SUMMON_SHIP_SPELL, TeleportToCannon, ErrorFunc, ToStandartCoord( pos ))
end

function OnChatMessage( params )
	if params.chatType == CHAT_TYPE_WHISPER then
		local message = debugCommon.FromWString( params.msg )
		local i, j = string.find( message, CHILD_PREFIX )
		if i ~= nil and j ~= nil then
			local prefix = string.sub( message, i, j )
			local command = string.sub( message, j+1 )
			
			Log( "child message: prefix=" .. prefix .."  message=" .. command )
			
			if command == ERROR_TEXT then
				DisintShip()
			elseif  command == START_BOARDING then
				StopTimer()
				InitBoarding()
			end
		end
	end
end

function OnAbordageStarted()
	if CHECK_START_BOARDING == false then
		Log( "abordage started" )
		CHECK_START_BOARDING = true
		StopPrivateTimer()
		TeleportBetweenShip( TeleportToEnemyTreasure, ErrorFunc )
	end	
end

function OnAbordageFinished()
	Done()
end

function Init()
	SUMMON_SHIP_SPELL = developerAddon.GetParam( "SummonShipSpell" )
	INDEX_CANNON = tonumber( developerAddon.GetParam( "IndexCannon" ) )
	CHILD_NAME = developerAddon.GetParam( "ChildName" )

	local login = {
		login = developerAddon.GetParam( "login" ),
		pass = developerAddon.GetParam(	"password" ),
		avatar = developerAddon.GetParam( "avatar" )
	}
	InitLoging(login)

	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
	common.RegisterEventHandler( OnChatMessage, "EVENT_CHAT_MESSAGE" )
	common.RegisterEventHandler( OnAbordageStarted, "EVENT_ABORDAGE_STARTED" )
	common.RegisterEventHandler( OnAbordageFinished, "EVENT_ABORDAGE_FINISHED" )
end

Init()