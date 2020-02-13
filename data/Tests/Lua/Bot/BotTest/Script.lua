-- ТЕСТОВЫЙ БОТ. ДЛЯ ОТЛАДКИ МЕХАНИКИ
Global( "TEST_BOT_TEST_NAME", "TestBot. author: LiventsevAndrey. date: 27.06.09" ) 


Global( "TEST_BOT_START",  "start"   )   
Global( "TEST_BOT_STOP",   "stop"    )
Global( "TEST_BOT_MOVE1",  "move1"   ) -- двигаемся по квадрату
Global( "TEST_BOT_MOVE2",  "move2"   )
Global( "TEST_BOT_MOVE3",  "move3"   )
Global( "TEST_BOT_MOVE4",  "move4"   )
Global( "TEST_BOT_SUMMON", "summon"  ) -- саммоним моба
Global( "TEST_BOT_KILL",   "kill"    ) -- убиваем его

Global( "TEST_BOT_MOB_NAME", "Tests/Maps/Test/Instances/QuestGiver_SpawnWithTimer_Boss_And_Add.(MobWorld).xdb" )


function BotTestStart()
	Ping( "BotTestStart" )
	SetTestName( TEST_BOT_TEST_NAME )
	BotNextState( TEST_BOT_NAME .. "." .. TEST_BOT_MOVE1 )
end

function BotTestStop()
	Ping( "BotTestStop" )
	SetTestName( DEFAULT_TEST_NAME )
	BotNextState( WAIT_STATE )
end

function BotTestMove1()
	Ping( "BotTestMove1" )
	local pos = ToAbsCoord( avatar.GetPos())
	pos.X = pos.X + 2
	pos.Y = pos.Y + 2
	pos.Z = pos.Z + 1
	MoveToPos( pos, BotNextState, TEST_BOT_NAME .. "." .. TEST_BOT_MOVE2, 3000, nil, nil, ErrorFunc )
end

function BotTestMove2()
	Ping( "BotTestMove2" )
	local pos = ToAbsCoord( avatar.GetPos())
	pos.X = pos.X - 2
	pos.Y = pos.Y + 2
	pos.Z = pos.Z + 1
	MoveToPos( pos, BotNextState, TEST_BOT_NAME .. "." .. TEST_BOT_MOVE3, 3000, nil, nil, ErrorFunc )
end

function BotTestMove3()
	Ping( "BotTestMove3" )
	local pos = ToAbsCoord( avatar.GetPos())
	pos.X = pos.X - 2
	pos.Y = pos.Y - 2
	pos.Z = pos.Z + 1
	MoveToPos( pos, BotNextState, TEST_BOT_NAME .. "." .. TEST_BOT_MOVE4, 3000, nil, nil, ErrorFunc )
end

function BotTestMove4()
	Ping( "BotTestMove4" )
	local pos = ToAbsCoord( avatar.GetPos())
	pos.X = pos.X + 2
	pos.Y = pos.Y - 2
	pos.Z = pos.Z + 1
	MoveToPos( pos, BotNextState, TEST_BOT_NAME .. "." .. TEST_BOT_SUMMON, 3000, nil, nil, ErrorFunc )
end

function BotTestSummon()
	Ping( "BotTestSummon" )
	local newPos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), 1 )
	local map = "/Tests/Maps/Lua/MapResource.xdb"
	Log( "compare maps;  ".. map .. "  == " .. debugMission.GetMap().debugName  )
	SummonMob( TEST_BOT_MOB_NAME, map, newPos, 0, BotTestSummonAfter, ErrorFunc )
end
function BotTestSummonAfter()
	BotNextState( TEST_BOT_NAME .. "." .. TEST_BOT_KILL )
end

function BotTestKill()
	Ping( "BotTestKill" )
	local id = GetMobId( TEST_BOT_MOB_NAME )
	if id ~= nil then
		KillMob( id, BotTestKillAfter, ErrorFunc )
	else
		BotTestKillAfter()
	end
end
function BotTestKillAfter()
	BotNextState( TEST_BOT_NAME .. "." .. TEST_BOT_MOVE1 )
end





function InitBotTest()
	TEST_BOT_STATES = {}
	TEST_BOT_STATES[ TEST_BOT_START  ] = BotTestStart
	TEST_BOT_STATES[ TEST_BOT_STOP   ] = BotTestStop 
	TEST_BOT_STATES[ TEST_BOT_MOVE1  ] = BotTestMove1
	TEST_BOT_STATES[ TEST_BOT_MOVE2  ] = BotTestMove2
	TEST_BOT_STATES[ TEST_BOT_MOVE3  ] = BotTestMove3
	TEST_BOT_STATES[ TEST_BOT_MOVE4  ] = BotTestMove4
	TEST_BOT_STATES[ TEST_BOT_SUMMON ] = BotTestSummon
	TEST_BOT_STATES[ TEST_BOT_KILL   ] = BotTestKill 
end

InitBotTest()