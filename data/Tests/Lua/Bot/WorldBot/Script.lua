Global( "TEST_NAME", "WorldBot v0.1; author: Liventsev Andrey, date: 06.04.09, task 60909" )

Global( "MOB_LIST", nil )
Global( "QUEST_LIST", nil )

Global( "NPC_TABLE", nil )
Global( "NPC_INDEX", nil )
Global( "ZONE", nil )
Global( "MAP", nil )
Global( "LEVEL", nil )

function Done()
	Success( TEST_NAME )
end

function ErrorFunc( text )
	Warn( TEST_NAME, text )
end

Global( "dir", 0 )
Global( "y", 0 )


--------------------------------------- EVENTS --------------------------------------------

function OnAvatarCreated()
	Log( "av created" )
	StartTest( TEST_NAME )

	LevelUp( LEVEL, nil, RunBot, ErrorFunc )
end

-- function AAA()

	-- y = y + 1
	-- dir = -120
	-- local moveParams = {
		-- deltaX = 0,
		-- deltaY = y,
		-- deltaZ = 0,
		-- yaw = DegrToRad( dir )
	-- }
	-- qaMission.AvatarMoveAndRotate( moveParams )
	-- StartTimer( 3000, AAA )
-- end

function RunBot()
	-- local ignoreList = {}
	-- table.insert( ignoreList, "World/Quests/ArchipelagoLeague1/Quest2_3Repit/Quest2_3Repit.xdb" )
	InitWorldBot( QUEST_LIST, MOB_LIST, ZONE, MAP, Done, ErrorFunc )
	RunWorldBot()
end

function Mmove()
	local pos =  ToAbsCoord( avatar.GetPos())
	qaMission.TeleportMap( "Maps/Kania/MapResource.xdb", pos.X + 5, pos.Y + 5, pos.Z )
end

function Init()
	MOB_LIST = developerAddon.LoadMobList()
	QUEST_LIST = developerAddon.LoadQuestList()
	ZONE = developerAddon.GetParam( "zone" )
	MAP = developerAddon.GetParam( "map" )
	LEVEL = tonumber( developerAddon.GetParam( "level" ))
	
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
	
	WorldBotLogin( developerAddon.GetParam( "faction" ), ErrorFunc )
end

Init()