Global( "DEFAULT_TEST_NAME", "Script not determined" )
Global( "TEST_NAME", nil )

Global( "MY_NUM", nil )
Global( "BOT_NAME", nil )
Global( "BOT_MANAGER_PREFIX", "BotManager" )

Global( "CUR_STATE", nil )  -- текущее состояние бота. Имеет формат "botName.stateName"
Global( "NEXT_STATE", nil )  -- состояние в которое должен перейти бот
Global( "NEXT_STATE_PARAMS", nil )  -- состояние в которое должен перейти бот


-- BotManager:50_55:testBot.start:1_2_3
-- BotManager:50_55:testBot.summon:1_2_3


Global( "SUCCESS_STATE", "main.successState" ) -- Команда на выход
Global( "WAIT_STATE",    "main.waitState"    ) -- Тупо ожидание новой команды

Global( "MAIN_BOT_NAME", "main" )
Global( "TEST_BOT_NAME", "testBot" )
Global( "TEST_BOT_STATES", nil )




-- если NEXT_STATE ~= nil тогда мы получили команду сменить состояние
function BotNextState( stateName, stateParams )
	if NEXT_STATE ~= nil then
		stateName = NEXT_STATE
		stateParams = NEXT_STATE_PARAMS
		NEXT_STATE = nil
		NEXT_STATE_PARAMS = nil
	end
	
	RunState( stateName, stateParams )
end

function RunState( stateName, stateParams )
	if StartsWith( stateName, MAIN_BOT_NAME ) then
		if stateName == SUCCESS_STATE then
			-- todo stopping CUR_STATE and Success
		elseif stateName == WAIT_STATE then
			Ping( "I'm waiting..." )
			StartTimer( 5000, BotNextState, WAIT_STATE )
		end
		return
		
	elseif StartsWith( stateName, TEST_BOT_NAME ) then
		local state = Split( stateName, "." )[2]
		TEST_BOT_STATES[ state ]( stateParams )
		return
	end
	
	ErrorFunc( "Unknown state: " .. tostring( stateName ) )
end




function Ping( text )
--	SendHttpMsg( BOT_NAME, text )
	Log( text )
end

function SetTestName( name )
	TEST_NAME = "LuaBot#" .. tostring( MY_NUM ) .. "  " .. name 
end

function ErrorFunc( text )
	Ping( "ErrorFunc: " .. text )
	Warn( TEST_NAME, text ) 
end


-------------------------------------------------------------------

function OnAvatarCreated( params )
	if params.id == avatar.GetId() then
		Ping( "I'm logged in" )
		BotNextState( WAIT_STATE )
	end
end

function OnDebugNotify( params )
	Log( "debug notify: " .. FromWString( params.message ))
	local notify = ParseNotify( params.message )
	if notify ~= nil and notify.sender == BOT_MANAGER_PREFIX and MY_NUM >= notify.startNum and MY_NUM <= notify.endNum then
		NEXT_STATE = notify.nextState
		NEXT_STATE_PARAMS = notify.params
	end
end

function OnChatMessage( params )
	local msg = FromWString( params.msg )
	qaMission.DebugNotify( msg, true )
end



function Init()
	common.RegisterEventHandler( OnDebugNotify, "EVENT_DEBUG_NOTIFY" )
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
	common.RegisterEventHandler( OnChatMessage, "EVENT_CHAT_MESSAGE" )
	
	MY_NUM = BOT_ACCOUNT_NAME -- запоминаем номер бота
	BOT_NAME = BOT_ACCOUNT_NAME .. tostring( MY_NUM )
	
	SetTestName( DEFAULT_TEST_NAME )
	BotLogin( ErrorFunc )
end

Init()
