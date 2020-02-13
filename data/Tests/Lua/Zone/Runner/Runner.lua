Global( "TEST_NAME", "Zone runner. bug#37373, author: Liventsev Andrey, date: 09.07.08" )

-- вся область делится на квадраты со стороной step. запоминаются все квадраты где мы уже были

-- param
Global( "MAP", nil )
Global( "Xo", nil )
Global( "Yo", nil )
Global( "Zo", nil )
Global( "MinX", nil )
Global( "MinY", nil )

Global( "ZONE_SIZE_X",  0 )
Global( "ZONE_SIZE_Y",  0 )
Global( "STEP", nil )
Global( "ROTATE_VALUE", nil )
-- /param



Global( "SQUARE_COUNT_X", 0 )
Global( "SQUARE_COUNT_Y", 0 )
Global( "CAMERA_DISTANCE", 400 )

Global( "INVISIBILITY_CHEAT_SPELL", "Mechanics/Spells/Cheats/GreaterInvisibility/Spell.xdb" )
Global( "INVISIBILITY_CHEAT_BUFF",  "Mechanics/Spells/Cheats/GreaterInvisibility/Buff.xdb" )

Global( "CUR_POS", nil )
Global( "ROTATE_COUNT", 0 )
Global( "PLACE_TABLE", {} ) -- матрица для зпоминания квадратов в которых мы уже были
Global( "WARNINGS", {} )



function CastInvis()
	CastSpellToTarget( avatar.GetId(), GetSpellId(INVISIBILITY_CHEAT_SPELL), nil, 5000, InitCamera, ErrorFunc, nil, true )
end

function CastInvis2()
	CastSpellToTarget( avatar.GetId(), GetSpellId(INVISIBILITY_CHEAT_SPELL), nil, 5000, EmptyFunction, ErrorFunc, nil, true )
end


-- возвращает номер квадрата для координаты pos
function GetSquare( pos )
	local absPos = ToAbsCoord( pos )
	local result = {}

	if absPos.X < MinX then
		absPos.X = MinX
	end
	if absPos.X > MinX + ZONE_SIZE_X then
		absPos.X = MinX + ZONE_SIZE_X
	end

	if absPos.Y < MinY then
		absPos.Y = MinY
	end
	if absPos.Y > MinY + ZONE_SIZE_Y then
		absPos.Y = MinY + ZONE_SIZE_Y
	end

	result.x = math.floor( (absPos.X - MinX ) / STEP ) + 1
	result.y = math.floor( (absPos.Y - MinY ) / STEP ) + 1
	
	return result
end

-- помечает квадрат с координатой pos как помеченную
function MarkSquare( pos )
	local square = GetSquare( pos )
	PLACE_TABLE[square.x][square.y] = true
end

-- возвращает true если в квадрате с координатой pos мы уже были
function IsMarkedSquare( pos )
	local square = GetSquare( pos )
	
	return PLACE_TABLE[square.x][square.y]
end

function CheckPoints( pos )
	CUR_POS = pos
	CheckSquares( pos, 1 )
end

-- проверяет 4 точки вокруг аватара (против часовой точки, начиная с "девяти часов")
-- если в точке мы еще ны были и там есть террейн - кладем в стек
function CheckSquares( pos, point )
	local direc = {}
	direc.X = 0.0
	direc.Y = 0.0
	direc.Z = 0.0
	
	if point == 1 then
		local absPos = ToAbsCoord( CUR_POS )
		direc.X = direc.X - STEP
		CheckDot( absPos, direc, 2 )
		
	elseif point == 2 then
		if pos ~= nil and pos.globalX ~= 0 and pos.globalY ~= 0 then
			StackPush( pos )
		end
	
		local absPos = ToAbsCoord( CUR_POS )
		direc.Y = direc.Y - STEP
		CheckDot( absPos, direc, 3 ) 

    elseif point == 3 then
		if pos ~= nil and pos.globalX ~= 0 and pos.globalY ~= 0 then
			StackPush( pos )
		end
		    
    	local absPos = ToAbsCoord( CUR_POS )
		direc.X = direc.X + STEP
		CheckDot( absPos, direc, 4 ) 
	
	elseif point == 4 then
		if pos ~= nil and pos.globalX ~= 0 and pos.globalY ~= 0 then
			StackPush( pos )
		end
	
		local absPos = ToAbsCoord( CUR_POS )
		direc.Y = direc.Y + STEP
		CheckDot( absPos, direc, 5 ) 
			
	elseif point == 5 then
		if pos ~= nil and pos.globalX ~= 0 and pos.globalY ~= 0 then
			StackPush( pos )
		end
	
		Rotate()
	end	
end

-- если в точке pos мы еще ны были и там есть террейн - кладем в стек
function CheckDot( _pos, direc, point )

	local pos=ToStandartCoord( _pos )

    local _newPos = _pos
	_newPos.X = _newPos.X + direc.X
	_newPos.Y = _newPos.Y + direc.Y
	_newPos.Z = _newPos.Z + direc.Z

	local newPos=ToStandartCoord( _newPos )

	if IsMarkedSquare( newPos ) == false then
		FindGoodTerrainInDirection( pos, direc, CheckSquares, point )
	else
		CheckSquares( nil, point )
	end
end


function MoveAvatarToNextPos()
	if StackSize() > 0 then
		local pos = StackPop()
		if not IsMarkedSquare( pos ) then
			MarkSquare( pos )

			if debugMission.GetMap().debugName ~= MAP then
				local aPos = ToAbsCoord( pos )
				SetCameraPos( pos, RadToDegr( avatar.GetDir()), CAMERA_DISTANCE)
				Log( "teleport to another map. MAP=" .. MAP .. " " .. PrintCoord( aPos ))
				qaMission.TeleportMap( MAP, aPos.X, aPos.Y, aPos.Z )
				
				StartTimer( 20000, CheckPoints, pos )
			else
				qaMission.AvatarSetPos( pos )
				SetCameraPos( pos, RadToDegr( avatar.GetDir()), CAMERA_DISTANCE)
				StartTimer( 5000, CheckPoints, pos )
			end
		else
			MoveAvatarToNextPos()
		end
	else
		Done()
	end
end


-- поворачивает персонажа на ROTATE_COUNT градусов. Проверяет что сделали полный оборот
function Rotate()
	if ROTATE_COUNT < 360 then
		local curPos = ToAbsCoord( avatar.GetPos() )
		local perfString = debugMission.PerfomanceStatus( curPos.X, curPos.Y, ROTATE_COUNT )
		if perfString == nil then
			Log( "debugMission.PerfomanceStatus returned a nil. input parameters:" )
			Log( "    x=" .. tostring(curPos.X) .. " y=" .. tostring(curPos.Y) .. " rotate=" .. tostring( ROTATE_COUNT ))
			Warn( TEST_NAME, "debugMission.PerfomanceStatus returned nil" )
		end

		local outputString =  "x| " .. tostring( curPos.X ) .. "| y| " .. tostring( curPos.Y ) .. "| " .. "yaw| " .. tostring( ROTATE_COUNT ) .. "| "  .. perfString
		Log( outputString  )
		Log()
		debugMission.PerfomanceLog( outputString  )
		
	    ROTATE_COUNT = ROTATE_COUNT + ROTATE_VALUE
		
	    CCISetDir( DegrToRad( ROTATE_COUNT ))

	    StartTimer( 2000, Rotate )
	    
	else
		ROTATE_COUNT = 0
		MoveAvatarToNextPos()
	end
end

-- выдает координаты камеры, кот. будет находитсья за точкой pos в направлении dir на расстоянии range
function SetCameraPos( pos, dir, range )
	local aPos = ToAbsCoord( pos )
	local cameraPos = {
		X = aPos.X - 5,
		Y = aPos.Y,
		Z = aPos.Z + 2
	}

    CCISetDir( 0 )
	CCIMove( ToStandartCoord( cameraPos ) )
end

function InitCamera()
	Log( "InitCamera" )
	InitCameraCustomInput()
	SetCameraPos( avatar.GetPos(), RadToDegr( avatar.GetDir()), CAMERA_DISTANCE )

	CCIEnable( true )

	StartTimer( 2000, MoveAvatarToNextPos )
end


function Done()
	if GetTableSize( WARNINGS ) > 0 then
		Log()
		Log()
		Log( " -- WARNINGS --" )
		for index, warn in WARNINGS do
			Log( "  " .. warn )
		end
		Log()
	end	

	Success( TEST_NAME )
end

function ErrorFunc( text )
	if GetTableSize( WARNINGS ) > 0 then
		Log()
		Log()
		Log( " -- WARNINGS --" )
		for index, warn in WARNINGS do
			Log( "  " .. warn )
		end
		Log()
	end	
	
	Warn( TEST_NAME, text )
end

---------------------------------------- EVENTS --------------------------------

function OnAvatarCreated( params )
	StartTest( TEST_NAME )
	
	qaMission.TeleportMap( MAP, Xo, Yo, Zo )
	StartTimer( 20000, AfterFirstTeleport )
end
	
function AfterFirstTeleport()	
	Log( "Init AvatarCusmotInput" )
	InitAvatarCustomInput()
	ACIEnable( true )

	Log( "InitFindGoodTerrainInDirection" )
	InitFindGoodTerrainInDirection()
	
	Log( "Init NoClip" )
	InitNoClip()
	SetNoClip( true )
	
    -- инициализация массива для хранения значений (были мы в этой точке или нет)	
	SQUARE_COUNT_X = math.ceil( ZONE_SIZE_X / STEP ) + 2
	SQUARE_COUNT_Y = math.ceil( ZONE_SIZE_Y / STEP ) + 2
	local i =0
	local j =0

	for i=1, SQUARE_COUNT_X-1 do
		local tmp = {}
		tmp[0] = true
		for j=1, SQUARE_COUNT_Y-1 do
			tmp[j] = false
		end
		tmp[SQUARE_COUNT_Y]=true
		PLACE_TABLE[i]= tmp
	end

	local tmp1 = {}
	for j=0, SQUARE_COUNT_Y do
		tmp1[j] = true
	end
	PLACE_TABLE[0]= tmp1
	PLACE_TABLE[SQUARE_COUNT_X]= tmp1
	
	local pos = {
	    X = Xo,
	    Y = Yo,
	    Z = Zo
	}
	local newPos = ToStandartCoord( pos )
	StackPush( newPos )
	
	Log( "start" )

	if GetBuffInfo( avatar.GetId(), INVISIBILITY_CHEAT_BUFF ) == nil then
		LearnSpell( INVISIBILITY_CHEAT_SPELL, CastInvis, ErrorFunc )
	else
		StartTimer( 7000, InitCamera )
	end
end

function OnUnitDeadChanged( params )
	if params.unitId == avatar.GetId() and unit.IsDead( avatar.GetId() ) == true then
		if CUR_POS ~= nil then
			Log( "Avatar dead in pos=" .. PrintCoord( CUR_POS ))
		else
			Log( "Avatar dead in pos=" .. PrintCoord( avatar.GetPos()))
		end
		table.insert( WARNINGS, "Avatar dead in pos=" .. PrintCoord( avatar.GetPos()))
		qaMission.AvatarRevive()
		
		StartTimer2( 1000, CastInvis2 )
	end
end

function Init()
	MAP = developerAddon.GetParam( "map" )

	Xo = tonumber( developerAddon.GetParam( "StartX" ))
	Yo = tonumber( developerAddon.GetParam( "StartY" ))
	Zo = tonumber( developerAddon.GetParam( "StartZ" ))

	MinX = tonumber( developerAddon.GetParam( "MinX" ))
	MinY = tonumber( developerAddon.GetParam( "MinY" ))

	STEP = tonumber( developerAddon.GetParam( "Step" ))
	ZONE_SIZE_X = tonumber( developerAddon.GetParam( "ZoneWidth" ))
	ZONE_SIZE_Y = tonumber( developerAddon.GetParam( "ZoneHeight" ))
	ROTATE_VALUE = tonumber( developerAddon.GetParam( "RotateDegr" ))

	local login = {
		login = developerAddon.GetParam( "login" ),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" ),
		create = "AutoMage",
		delete = true
	}
	InitLoging( login )


	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
	common.RegisterEventHandler( OnUnitDeadChanged, "EVENT_UNIT_DEAD_CHANGED" )
end

Init()
