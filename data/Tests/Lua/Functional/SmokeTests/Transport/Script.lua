Global( "TEST_NAME", "SmokeTest.Ship; author: Liventsev Andrey, date: 16.09.08, task 37349" )

Global( "START_POS",  nil )
Global( "SHIP_POS",   nil )
Global( "END_POS", nil )
Global( "SHIP_TIME", nil )
Global( "ARRIVE_TIME", nil )

Global( "START_SEARCHING", false )

function SearchingForShip()
	if not START_SEARCHING then
	    Log( "Start searching ship" )
	    START_SEARCHING = true
	    StartTimer( 1000 * SHIP_TIME, ErrorFunc, "Can not find ship" )
	end

	TraceTransport( SHIP_POS, CheckResults, nil )
end

function CheckResults( pos ) 

	if pos.globalX ~= 0 and pos.globalY ~= 0 then
		avatar.ChatSay( debugCommon.ToWString( "ship founded" ) )
		Log( "find ship. all on a board!!!" )
		pos.localZ = pos.localZ + 0.5
		qaMission.AvatarSetPos( pos )
		StopTimer()
		StartCheckTimer( 1000 * ARRIVE_TIME, CheckDistance, nil, ErrorFunc, "Can't arrive destination point", Success, TEST_NAME )

	else
		avatar.ChatSay( debugCommon.ToWString( "ship not founded" ) )
		StartTimer( 200, SearchingForShip )
	end
end

function CheckDistance()
	if GetDistanceBetweenPoints( avatar.GetPos(), END_POS, true ) <= 10 then
	    Log( "Arrive destination point" )
	    return true
	else
	    return false
	end
end

function ErrorFunc( text )
    Warn( TEST_NAME, text )
end


--------------------------------------- EVENTS --------------------------------------------

function OnAvatarCreated()
	StartTest( TEST_NAME )
	InitTraceTransport()
	
	qaMission.AvatarSetPos( START_POS )
	StartTimer( 5000, SearchingForShip )
end

function Init()
	local pos = {
		X = tonumber( developerAddon.GetParam( "StartX" ) ),
		Y = tonumber( developerAddon.GetParam( "StartY" ) ),
		Z = tonumber( developerAddon.GetParam( "StartZ" ) )
	}
	START_POS = ToStandartCoord( pos )

	pos = {
		X = tonumber( developerAddon.GetParam( "ShipX" ) ),
		Y = tonumber( developerAddon.GetParam( "ShipY" ) ),
		Z = 0
	}
	SHIP_POS = ToStandartCoord( pos )

	pos = {
		X = tonumber( developerAddon.GetParam( "EndX" ) ),
		Y = tonumber( developerAddon.GetParam( "EndY" ) ),
		Z = 0
	}
	END_POS = ToStandartCoord( pos )

	SHIP_TIME = tonumber( developerAddon.GetParam( "TimeForTraceShip" ))
	ARRIVE_TIME = tonumber( developerAddon.GetParam( "TimeForArriving" ))

	local login = {
		login = developerAddon.GetParam( "login"),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" )
	}
	InitLoging(login)
	
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
end

Init()
