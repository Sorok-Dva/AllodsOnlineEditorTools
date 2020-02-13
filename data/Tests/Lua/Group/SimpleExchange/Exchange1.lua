function SetTestName()
	TEST_NAME = "Group Test for simple exchanging. author: Liventsev Andrey. date: 17.03.2009. task# 58613"
end

function NextStep()
	PULL_ERRORS = nil
	PULL_ERRORS = {}
	PULL = nil
	PULL = {}
	local time_wait = 20000
	if STEP == 0 then -- собираемся рядом
		STEP_TEXT = "put 2 avatars together"
		TeleportCommand( SLAVE..NUM[1], 10, 100, 1 )
		TeleportCommand( SLAVE..NUM[2], 11, 100, 1 )
		STEP = 1

	elseif STEP == 1 then -- принимаем приглашение на торговлю
		STEP_TEXT = "ready for accepting invite to exchange"
		AcceptExchangeCommand( SLAVE..NUM[2], SLAVE..NUM[1] )
		STEP = 101

	elseif STEP == 101 then -- первый пытается торговать со вторым
		STEP_TEXT = "first inviting second one to exchange"
		InviteToExchangeCommand( SLAVE..NUM[1], SLAVE..NUM[2] )
		STEP = 201

	elseif STEP == 201 then -- закрываемся
		STEP_TEXT = "close all bots"
		QuitBotCommand( SLAVE..NUM[1] )
		QuitBotCommand( SLAVE..NUM[2] )
		STEP = -1
	else
		Success( TEST_NAME )
	end
	Log( "Step - " .. tostring( STEP ) .. ": " .. tostring( STEP_TEXT ))
	StartTimer( time_wait, ErrorFunc10sec, nil )
end
