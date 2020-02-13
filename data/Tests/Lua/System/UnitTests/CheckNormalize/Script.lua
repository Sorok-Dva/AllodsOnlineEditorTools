Global( "TEST_NAME", "SmokeTest.Quest.CheckNormalize; author: Grigoriev Anton, date: 19.08.08, task #38234" )


Global( "MAP_RESOURCE", "/Tests/Maps/Lua/MapResource.xdb" )

--params
Global( "BUFF", nil)
--/params

function Done()
	Success( TEST_NAME )
end

function ErrorFunc( text )
	Warn( TEST_NAME, text )
end


--------------------------------------- EVENTS ------------------------------------

function OnAvatarBuffsChanged(params)
	if params.unitId == avatar.GetId() then
		Log( "buffs changed. count=" .. tostring(unit.GetBuffCount( params.unitId )) )
		StopTimer()
		
		for i=0, unit.GetBuffCount( params.unitId )-1 do
			local buffInfo = unit.GetBuff( params.unitId, i )
			if BUFF == buffInfo.debugName then
				Log("Avatar get buff ", BUFF, ", count buff is ", i)
				Done()
				return
			end
		end
		
       ErrorFunc("Avatar not get buff ", BUFF)
 	end
end

function OnAvatarCreated()
	StartTest( TEST_NAME )

	qaMission.SendCustomMsg( "normalize" )
	StartTimer( 2000, ErrorFunc, "EVENT_UNIT_BUFFS_CHANGED did not come" )
end

function Init()
	local login = {
		login = developerAddon.GetParam( "login"),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" )
	}
	InitLoging(login)

    BUFF = developerAddon.GetParam( "buff" )

	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
    common.RegisterEventHandler( OnAvatarBuffsChanged, "EVENT_UNIT_BUFFS_CHANGED" )
end

Init()