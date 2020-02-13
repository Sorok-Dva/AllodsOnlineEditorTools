-- ф-ция для использования одного девайса

Global( "WBUD_PASS_FUNCTION",  nil )
Global( "WBUD_ERROR_FUNCTION", nil )
Global( "WBUD_DEV_ID", nil )
Global( "WBUD_TIME", nil )
Global( "WBUD_POSITION", nil )

function UseDev( devId, useTime, passFunc, errorFunc )
	WBUD_PASS_FUNCTION  = passFunc
	WBUD_ERROR_FUNCTION = errorFunc
	WBUD_DEV_ID = devId
	WBUD_TIME = useTime
	
	Log( "move to device: id=" .. tostring(WBUD_DEV_ID) )
	local pos = debugMission.InteractiveObjectGetPos( WBUD_DEV_ID )
	WBUD_POSITION = pos
	MoveToPos( pos, WBUD_UseDevice )
end

function WBUD_UseDevice()
	for index, id in avatar.GetDeviceList() do
		if id == WBUD_DEV_ID then
			object.Use( WBUD_DEV_ID, 169 )
			StartPrivateTimer( WBUD_TIME, WBUD_PASS_FUNCTION )		
			return
		end
	end
	
	local pos = ToAbsCoord( WBUD_POSITION )
	WBUD_ERROR_FUNCTION( "Can't find device after teleport. id=" .. tostring(USE_DEV_DEV_ID) .. " pos: x=" .. tostring(pos.X) .. " y=" .. tostring( pos.Y ) .. " z=" .. tostring( pos.Z ))
end
