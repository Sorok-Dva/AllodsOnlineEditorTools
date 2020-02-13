function SetTestName()
	TEST_NAME = "Group Test for Relogin and Teleport"
end

function NextStep()
	PULL_ERRORS = nil
	PULL_ERRORS = {}
	PULL = nil
	PULL = {}
	local time_wait = 20000
	if STEP == 0 then -- собираемся рядом
		STEP_TEXT = "teleport all in one place"
		TeleportCommand(SLAVE..NUM[1], 10,100,1)
		TeleportCommand(SLAVE..NUM[2], 11,100,1)
		TeleportCommand(SLAVE..NUM[3], 12,100,1)
		TeleportCommand(SLAVE..NUM[4], 13,100,1)
		TeleportCommand(SLAVE..NUM[5], 14,100,1)
		TeleportCommand(SLAVE..NUM[6], 15,100,1)
		STEP = 1
	elseif STEP == 1 then -- выходим из группы, принимаем только от лидера
		STEP_TEXT = "accept in group from 1"
		AcceptInviteCommand(SLAVE..NUM[1], SLAVE..NUM[2])
		AcceptInviteCommand(SLAVE..NUM[1], SLAVE..NUM[3])
		AcceptInviteCommand(SLAVE..NUM[1], SLAVE..NUM[4])
		AcceptInviteCommand(SLAVE..NUM[1], SLAVE..NUM[5])
		AcceptInviteCommand(SLAVE..NUM[1], SLAVE..NUM[6])
		STEP = 101
	elseif STEP == 101 then -- смотрим что все тут
		STEP_TEXT = "check all visible"
		CheckPlaceForVisibleCommand(SLAVE..NUM[1],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[2],crTable( SLAVE..NUM[1], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[3],crTable( SLAVE..NUM[2], SLAVE..NUM[1], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[4],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[1], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[5],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[1], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[6],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[1]))
		STEP = 2
	elseif STEP == 2 then -- создаем группу лидер 1
		STEP_TEXT = "invite 2,3,4,5,6"
		InviteInGroupCommand(SLAVE..NUM[1], crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[6]))
		STEP = 3
	elseif STEP == 3 then -- портимся подальше
		STEP_TEXT = "teleport all random place"
		TeleportCommand(SLAVE..NUM[1], 10,500,1)
		TeleportCommand(SLAVE..NUM[2], 11,600,1)
		TeleportCommand(SLAVE..NUM[3], 12,700,1)
		TeleportCommand(SLAVE..NUM[4], 13,200,1)
		TeleportCommand(SLAVE..NUM[5], 14,300,1)
		TeleportCommand(SLAVE..NUM[6], 15,400,1)
		STEP = 4
	elseif STEP == 4 then -- портимся
		STEP_TEXT = "teleport all random place"
		TeleportCommand(SLAVE..NUM[1], 100,100,1)
		TeleportCommand(SLAVE..NUM[2], 200,100,1)
		TeleportCommand(SLAVE..NUM[3], 300,100,1)
		TeleportCommand(SLAVE..NUM[4], 400,100,1)
		TeleportCommand(SLAVE..NUM[5], 500,100,1)
		TeleportCommand(SLAVE..NUM[6], 600,100,1)
		STEP = 5
	elseif STEP == 5 then -- портимся
		STEP_TEXT = "teleport all in one place"
		TeleportCommand(SLAVE..NUM[1], 10,100,1)
		TeleportCommand(SLAVE..NUM[2], 11,100,1)
		TeleportCommand(SLAVE..NUM[3], 12,100,1)
		TeleportCommand(SLAVE..NUM[4], 13,100,1)
		TeleportCommand(SLAVE..NUM[5], 14,100,1)
		TeleportCommand(SLAVE..NUM[6], 15,100,1)
		STEP = 6
	elseif STEP == 6 then -- смотрим что все тут
		STEP_TEXT = "check visible"
		CheckPlaceForVisibleCommand(SLAVE..NUM[1],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[2],crTable( SLAVE..NUM[1], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[3],crTable( SLAVE..NUM[2], SLAVE..NUM[1], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[4],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[1], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[5],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[1], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[6],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[1]))
		STEP = 7
	elseif STEP == 7 then -- двое в релог, двое портятся
		STEP_TEXT = "1,2 relogin, 3,4 teleport"
		RelogBotCommand(SLAVE..NUM[1])
		RelogBotCommand(SLAVE..NUM[2])
		TeleportCommand(SLAVE..NUM[3], 300,100,1)
		TeleportCommand(SLAVE..NUM[4], 400,100,1)
		time_wait = 40000
		STEP = 8
	elseif STEP == 8 then -- смотрим что все тут
		STEP_TEXT = "Check visible"
		CheckPlaceForVisibleCommand(SLAVE..NUM[1],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[2],crTable( SLAVE..NUM[1], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[3],crTable( SLAVE..NUM[2], SLAVE..NUM[1], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[4],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[1], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[5],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[1], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[6],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[1]))
		STEP = 9
	elseif STEP == 9 then -- двое в релог, двое портятся
		STEP_TEXT = "5,6 relog, 3,4 - teleport"
		RelogBotCommand(SLAVE..NUM[5])
		RelogBotCommand(SLAVE..NUM[6])
		TeleportCommand(SLAVE..NUM[3], 12,100,1)
		TeleportCommand(SLAVE..NUM[4], 13,100,1)
		time_wait = 40000
		STEP = 10
	elseif STEP == 10 then -- смотрим что все тут
		STEP_TEXT = "check visible"
		CheckPlaceForVisibleCommand(SLAVE..NUM[1],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[2],crTable( SLAVE..NUM[1], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[3],crTable( SLAVE..NUM[2], SLAVE..NUM[1], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[4],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[1], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[5],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[1], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[6],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[1]))
		STEP = 11
	elseif STEP == 11 then -- покидаем группу
		STEP_TEXT = "leave group"
		LeaveBotCommand(SLAVE..NUM[1])
		LeaveBotCommand(SLAVE..NUM[2])
		LeaveBotCommand(SLAVE..NUM[3])
		LeaveBotCommand(SLAVE..NUM[4])
		LeaveBotCommand(SLAVE..NUM[5])
		--LeaveBotCommand(SLAVE..NUM[6])
		STEP = 12
	elseif STEP == 12 then -- закрываемся
		STEP_TEXT = "quit"
		QuitBotCommand(SLAVE..NUM[1])
		QuitBotCommand(SLAVE..NUM[2])
		QuitBotCommand(SLAVE..NUM[3])
		QuitBotCommand(SLAVE..NUM[4])
		QuitBotCommand(SLAVE..NUM[5])
		QuitBotCommand(SLAVE..NUM[6])
		STEP = -1
	else
		Success(TEST_NAME)
	end
	Log("Step - "..tostring(STEP)..": "..tostring(STEP_TEXT))
	StartTimer( time_wait, ErrorFunc10sec, nil )
end
