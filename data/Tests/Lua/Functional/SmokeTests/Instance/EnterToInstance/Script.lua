Global( "TEST_NAME", "SmokeTest.EnterToInstance; author: Liventsev Andrey, date: 12.08.08, task 37342" )

-- params from xdb
Global( "START_PLACE", nil )
Global( "DISTANCE",    nil )
Global( "DIRECTION",   nil )

Global( "MOB_NAME", nil )
-- /params

Global( "IMMUNE_SPELL", "Mechanics/Spells/Cheats/IDDQD/Spell.xdb" )


function GoToInstance()
    ACIMove( true )
    StartCheckTimer( 10000, CheckDistance, nil, ErrorFunc, "Can't leave start place (" , BeforeCheckForMob, nil )
end

function CheckDistance()
	local id = avatar.GetId()
	Log( "check distance: ".. tostring( GetDistanceFromPosition( id, START_PLACE ) ) )
	return GetDistanceFromPosition( id, START_PLACE ) > DISTANCE
end

function BeforeCheckForMob()
	StartTimer( 5000, CheckForMob )
end

function CheckForMob()
	Log( "Check for mob: " .. tostring( GetMobId( MOB_NAME )))
	if GetMobId( MOB_NAME ) == nil then
	    ErrorFunc( "I am too far from door but don't see mob" )
	    
	else
	    Success( TEST_NAME )
	end
end


function ErrorFunc( text )
	Warn( TEST_NAME, text )
end

-------------------------------------- EVENTS ---------------------------------

function OnAvatarCreated( params )
	StartTest( TEST_NAME )
	LearnAndCastSpell( IMMUNE_SPELL, TEST_NAME )

    InitAvatarCustomInput()
    ACIEnable( true )
    
    qaMission.AvatarSetPos( START_PLACE )
    ACISetDir( DegrToRad( DIRECTION ))
    
    StartTimer( 10000, GoToInstance )
end


function Init()
	local login = {
		login = developerAddon.GetParam( "login"),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" ),
		create = "AutoMage"
	}
	InitLoging(login)

	local pos = {
	    X = tonumber( developerAddon.GetParam( "StartX" )),
	    Y = tonumber( developerAddon.GetParam( "StartY" )),
	    Z = tonumber( developerAddon.GetParam( "StartZ" ))
	}
	
	START_PLACE = ToStandartCoord( pos )
	MOB_NAME  = developerAddon.GetParam( "MobName" )
	DIRECTION = tonumber( developerAddon.GetParam( "Direction" ))
	DISTANCE  = tonumber( developerAddon.GetParam( "Distance" ))

	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
end


Init()