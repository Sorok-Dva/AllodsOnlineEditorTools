Global( "TEST_NAME", "SmokeTest.Quest.LevelUp; author: Grigoriev Anton, date: 19.08.08, task #38232" )


Global( "MAP_RESOURCE", "/Tests/Maps/Lua/MapResource.xdb" )
Global("LEVEL_UPPER1", 10)
Global("LEVEL_UPPER2", 51)
Global("CHECK", true)

function Done()
	Success( TEST_NAME )
end

function ErrorFunc( text )
	Warn( TEST_NAME, text )
end


--------------------------------------- EVENTS ------------------------------------

function OnAvatarCreated()
	StartTest( TEST_NAME )
	
	local level = unit.GetLevel( avatar.GetId() )

	qaMission.SendCustomMsg("level_up " .. tostring( LEVEL_UPPER1 ))
	StartTimer( 2000, ErrorFunc, "EVENT_UNIT_LEVEL_CHANGED did not come" )
end

function OnUnitLevelChanged( params )
	StopTimer()

	local curLevel = unit.GetLevel( avatar.GetId() )
 	if params.unitId == avatar.GetId() then
		if CHECK then
			CHECK = false
			if curLevel == LEVEL_UPPER1 then
				Log( "level up to " .. LEVEL_UPPER1 )
		  	    qaMission.SendCustomMsg("level_up " .. tostring( LEVEL_UPPER2 ))
		 		StartTimer( 2000, ErrorFunc, "EVENT_UNIT_LEVEL_CHANGED did not come" )
	    	else
				ErrorFunc( "Can not level up to " .. LEVEL_UPPER1 )
			end
		else
		    if curLevel ~= LEVEL_UPPER2 then
				Log( "Can not level up to " .. LEVEL_UPPER2 .. " only to " .. tostring(curLevel))
   				Done()
	    	else
				ErrorFunc( "Level can be only 50, but it's changed to : " .. curLevel)
			end
		end
	end
end

function Init()
	local login = {
		login = developerAddon.GetParam( "login"),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" )
	}
	InitLoging(login)

	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
	common.RegisterEventHandler( OnUnitLevelChanged, "EVENT_UNIT_LEVEL_CHANGED" )
end

Init()