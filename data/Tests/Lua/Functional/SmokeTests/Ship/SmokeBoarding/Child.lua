Global( "TEST_NAME", "Smoke.ShipBoardingChild author: Vashenko Anton; date: 19.12.2008; task: 51298" )

-- param
Global( "SUMMON_SHIP_SPELL", nil )
-- /param

Global( "LOOT_CHEST", "Mechanics/Ships/Treasury/LootChest.xdb" )
Global( "DEBUFF_CHEST_NAME", "Mechanics/Ships/Treasury/Buff.xdb" )

Global( "START_POS", nil )

Global( "SHIP_ID", nil )
Global( "CHEST_ID", nil )

Global( "ERROR_MESSAGE", nil )

Global( "PARENT_NAME", nil )
Global( "CHILD_PREFIX", "Child:" )
Global( "PARENT_PREFIX", "Parent:" )

Global( "ERROR_TEXT", "Error" )
Global( "DONE_TEXT", "Done" )
Global( "START_BOARDING", "StartBoarding" )
Global( "TAKE_CHEST", "TakeChest" )

Global( "CHILD_FUNC_PASS", nil )

function BeforeSendMessageStartBoarding( shipId )
	SHIP_ID = shipId
	-- ждем, чтобы корабли выравнялись по вертикали
	StartTimer( 3000, SendMessageStartBoarding )
end

function SendMessageStartBoarding()
	group.ChatWhisper( debugCommon.ToWString( PARENT_NAME ), debugCommon.ToWString( CHILD_PREFIX .. START_BOARDING ) )
end



function TeleportToUpperDeck()
	local transportId = unit.GetTransport( avatar.GetId() )
	local pos = debugMission.InteractiveObjectGetPos( transportId )
	qaMission.AvatarSetPos( pos )
	StartTimer( 2000, UseChestOnMyShip )
end

function UseChestOnMyShip()
	UseChest( TeleportToMyTreasure )
end

function UseChest( funcPass )
	CHILD_FUNC_PASS = funcPass
	CHEST_ID = GetChestId()
	TeleportToDevice( CHEST_ID , unit.GetTransport( avatar.GetId() ), UsingChest )
end

function TeleportToDevice( firstDevId, secDevId, funcPass )
	local firstPos = debugMission.InteractiveObjectGetPos( firstDevId )
	local secondPos = debugMission.InteractiveObjectGetPos( secDevId )
	local resultPos = GetPosFromPointToPoint( firstPos, secondPos, 3 )
	qaMission.AvatarSetPos( resultPos )
	StartPrivateCheckTimer( 2000, CheckTeleportToDevice, firstDevId, ErrorFunc, "Can't teleport to device. firstDevId = " .. tostring( firstDevId ) .. ", secDevId = " .. tostring( secDevId ), funcPass, nil )
end
function CheckTeleportToDevice( deviceId )
	return avatar.IsObjectInMeleeRange( deviceId )
end


function GetChestId()
	local devices = avatar.GetDeviceList()
	for i, deviceId in devices do
		if unit.DeviceGetDebugName( deviceId ).xdbFileName == LOOT_CHEST then
			return deviceId
		end
	end
	return nil
end

function UsingChest()
	object.Use( CHEST_ID, 119 )
	StartPrivateCheckTimer( 5000, CheckDebuffChestExists, nil, ErrorFunc, "Avatar don't have chest-debuff", CHILD_FUNC_PASS, nil )
end
function CheckDebuffChestExists()
	return GetBuffInfo( avatar.GetId(), DEBUFF_CHEST_NAME ) ~= nil
end

function TeleportToMyTreasure()
	TeleportToTreasure( CheckDebuffChestUnExists )
end

function TeleportToTreasure( funcPass )
	local transportId = unit.GetTransport( avatar.GetId() )
	local devIndex = GetTransportDeviceIndex( transportId, USDEV_TREASURE, 1 )
	local devId = GetTransportDeviceId( transportId, devIndex )
	TeleportToDevice( devId, transportId, funcPass )
end



function CheckDebuffChestUnExists()
	if GetBuffInfo( avatar.GetId(), DEBUFF_CHEST_NAME ) == nil then
		WaitFinishedBoarding()
	else
		ErrorFunc()
	end
end

function WaitFinishedBoarding()
	StartTimer( 210, ErrorFunc, "Abordage not finished" )
end

function Done()
	group.ChatWhisper( debugCommon.ToWString( PARENT_NAME ), debugCommon.ToWString( CHILD_PREFIX .. DONE_TEXT ) )
	DisintShip()
end

function ErrorFunc( text )
	group.ChatWhisper( debugCommon.ToWString( PARENT_NAME ), debugCommon.ToWString( CHILD_PREFIX .. ERROR_TEXT ) )
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
		Y = 1170,
		Z = 15
	}
	SummonShip( SUMMON_SHIP_SPELL, BeforeSendMessageStartBoarding, ErrorFunc, ToStandartCoord( pos ))
end

function OnAbordageFinished()
	Done()
end

function OnChatMessage( params )
	if params.chatType == CHAT_TYPE_WHISPER then
		local message = debugCommon.FromWString( params.msg )
		local i, j = string.find( message, PARENT_PREFIX )
		if i ~= nil and j ~= nil then
			local prefix = string.sub( message, i, j )
		
			if prefix == PARENT_PREFIX then
				Log( "prefix="..prefix )

				local command = string.sub( message, j + 1, -1 )
				Log( "command="..command )
			
				if command == ERROR_TEXT then
					DisintShip()
				elseif command == TAKE_CHEST then
					TeleportToUpperDeck()
				end
			end
		end
	end
end

function Init()
	SUMMON_SHIP_SPELL = developerAddon.GetParam( "SummonShipSpell" )
	PARENT_NAME = developerAddon.GetParam( "ParentName" )

	local login = {
		login = developerAddon.GetParam( "login" ),
		pass = developerAddon.GetParam(	"password" ),
		avatar = developerAddon.GetParam( "avatar" )
	}
	InitLoging(login)

	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
	common.RegisterEventHandler( OnChatMessage, "EVENT_CHAT_MESSAGE" )
	common.RegisterEventHandler( OnAbordageFinished, "EVENT_ABORDAGE_FINISHED" )
end

Init()