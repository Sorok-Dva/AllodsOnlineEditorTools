Global( "TEST_NAME", "ShipsAndPets.Bot author: Liventsev Andrey. date: 25.06.09. task:  67420" )

Global( "CLASS", nil ) 
Global( "CLASSES", nil ) -- таблица с возможными классами
Global( "COORDS",  nil ) -- таблица с возможными координатами

Global( "BOT_STATE_MOVE_TO_SHIP",  1 )
Global( "BOT_STATE_WAIT_FOR_SHIP", 2 )

Global( "PET_SPELL", "Mechanics/Spells/Necromancer/SummonSkeleton/Spell01.xdb" )

function BotNextStep()
	Log()
	Log( "BotNextStep " .. tostring( BOT_STATE ))
	if BOT_STATE == BOT_STATE_MOVE_TO_SHIP then
		Log( "move to ship" )
		BOT_STATE = BOT_STATE_WAIT_FOR_SHIP
		local elem = GetRandomTableElement( COORDS )
		MoveToPos( elem.pos, BotNextStep, nil, nil, nil, nil, nil, nil, elem.map )

	elseif BOT_STATE == BOT_STATE_WAIT_FOR_SHIP then
		Log( "wait for ship" )
		local tIds = avatar.GetTransportList()
		if GetTableSize( tIds ) == nil then
			StartTimer( 5000, BotNextStep )
		else
			local tId = GetRandomTableElement( tIds )
			local pos = debugMission.InteractiveObjectGetPos( tIds )
			Log( "pos= " .. PrintCoord( pos ) )
		end
		
		
	else
		GlobalState()
	end
end

function SummonNecroPet( spellId )
	CastSpell( spellId, nil, 2000, BotNextStep, ErrorFunc )
end




function ErrorFunc( text )
	Warn( TEST_NAME, text )
end



function OnAvatarCreated( params )
	BOT_STATE = BOT_STATE_MOVE_TO_SHIP
	if CLASS == "Necromancer" then
		LearnSpell( PET_SPELL, SummonNecroPet, ErrorFunc )
	else
		BotNextStep()
	end
end




function Init()
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
	
	COORDS = {}
	local pos = {
		X = tonumber( developerAddon.GetParam( "pos1X" )),
		Y = tonumber( developerAddon.GetParam( "pos1Y" )),
		Z = tonumber( developerAddon.GetParam( "pos1Z" ))
	}
	local elem = {
		pos = pos,
		map = developerAddon.GetParam( "map1" )
	}
	table.insert( COORDS, elem )
	
	CLASSES = {}
	table.insert( CLASSES, "Necromancer" )
	table.insert( CLASSES, "Druid" )
	-- CLASS = GetRandomTableElement( CLASSES )	
	CLASS = "Necromancer"
	
	Log( "pos=" .. PrintCoord( pos ))
	BotLogin( ErrorFunc, "Auto" .. CLASS, true )
end

Init()

