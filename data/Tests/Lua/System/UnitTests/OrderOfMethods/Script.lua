Global( "TEST_NAME", "OrderOfMethods; author: Liventsev Andrey, date: 22.09.08, task 43105" )

function Main()
	Log( "Run Main Function" )
	
	local aPos = ToAbsCoord( avatar.GetPos() )
	aPos.Z = aPos.Z + 1
	local pos = ToStandartCoord( aPos )
	
	ErrorFunc( "Exit from test" )
	Log( "CmdSetPosition" )
	qaMission.AvatarSetPos( pos )
end

function ErrorFunc( text )
	Log( "CmdLeaveMission" )
    Warn( TEST_NAME, text )
end


--------------------------------------- EVENTS --------------------------------------------

function OnAvatarCreated()
	StartTest( TEST_NAME )
	
	StartTimer( 5000, Main )
end

function Init()
	local login = {
		login = developerAddon.GetParam( "login"),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" )
	}
	InitLoging(login)
	
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
end

Init()