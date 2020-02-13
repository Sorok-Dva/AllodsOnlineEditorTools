qaMission.AvatarSetPos-- ф-ция для использования одного девайса

Global( "USE_DEV_PASS_FUNCTION",  nil )
Global( "USE_DEV_ERROR_FUNCTION", nil )
Global( "USE_DEV_DEV_ID", nil )
Global( "USE_DEV_TIME", nil )
Global( "USE_DEV_POSITION", nil )

function UseDev( devId, useTime, passFunc, errorFunc )
	USE_DEV_PASS_FUNCTION  = passFunc
	USE_DEV_ERROR_FUNCTION = errorFunc
	USE_DEV_DEV_ID = devId
	USE_DEV_TIME = useTime
	
	Log( "move to device: id=" .. tostring(USE_DEV_DEV_ID) )
	local pos = debugMission.InteractiveObjectGetPos( USE_DEV_DEV_ID )
	( pos )
	USE_DEV_POSITION = pos
	
	StartPrivateTimer( 3000, UseDevUseDevice )
end

function UseDevUseDevice()
	for index, id in avatar.GetDeviceList() do
		if id == USE_DEV_DEV_ID then
			object.Use( USE_DEV_DEV_ID, 169 )
			StartPrivateTimer( USE_DEV_TIME, USE_DEV_PASS_FUNCTION )		
			return
		end
	end
	
	local pos = ToAbsCoord( USE_DEV_POSITION )
	USE_DEV_ERROR_FUNCTION( "Can't find device after teleport. id=" .. tostring(USE_DEV_DEV_ID) .. " pos: x=" .. tostring(pos.X) .. " y=" .. tostring( pos.Y ) .. " z=" .. tostring( pos.Z ))
end
