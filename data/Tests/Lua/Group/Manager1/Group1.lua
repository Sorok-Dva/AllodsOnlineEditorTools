function SetTestName()
	TEST_NAME = "Group Test for Teleport and Range Visible in group"
end

function NextStep()
	PULL_ERRORS = nil
	PULL_ERRORS = {}
	PULL = nil
	PULL = {}
	local time_wait = 20000
	if STEP == 0 then -- собираемся 3 рядом, 3е вдалеке
		STEP_TEXT = "teleport 3near, 3 long range"
		TeleportCommand(SLAVE..NUM[1], 10,100,1)
		TeleportCommand(SLAVE..NUM[2], 11,100,1)
		TeleportCommand(SLAVE..NUM[3], 12,100,1)
		TeleportCommand(SLAVE..NUM[4], 13,210,1)
		TeleportCommand(SLAVE..NUM[5], 14,210,1)
		TeleportCommand(SLAVE..NUM[6], 15,210,1)
		STEP = 1
	elseif STEP == 1 then -- выходим из группы, принимаем только от лидера
		STEP_TEXT = "accept in group from 1"
		AcceptInviteCommand(SLAVE..NUM[1], SLAVE..NUM[2])
		AcceptInviteCommand(SLAVE..NUM[1], SLAVE..NUM[3])
		AcceptInviteCommand(SLAVE..NUM[1], SLAVE..NUM[4])
		AcceptInviteCommand(SLAVE..NUM[1], SLAVE..NUM[5])
		AcceptInviteCommand(SLAVE..NUM[1], SLAVE..NUM[6])
		STEP = 101
	elseif STEP == 101 then -- смотирм что видим только рядом
		STEP_TEXT = "check that visible only near"
		CheckPlaceForVisibleCommand(SLAVE..NUM[1],crTable( SLAVE..NUM[2], SLAVE..NUM[3]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[2],crTable( SLAVE..NUM[1], SLAVE..NUM[3]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[3],crTable( SLAVE..NUM[2], SLAVE..NUM[1]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[4],crTable( SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[5],crTable( SLAVE..NUM[4], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[6],crTable( SLAVE..NUM[5], SLAVE..NUM[4]))
		STEP = 102
	elseif STEP == 102 then -- смотрим что не видим вдали
		STEP_TEXT = "check that not visible long range"
		CheckPlaceForUnvisibleCommand(SLAVE..NUM[1],crTable( SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForUnvisibleCommand(SLAVE..NUM[2],crTable( SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForUnvisibleCommand(SLAVE..NUM[3],crTable( SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForUnvisibleCommand(SLAVE..NUM[4],crTable( SLAVE..NUM[1], SLAVE..NUM[2], SLAVE..NUM[3]))
		CheckPlaceForUnvisibleCommand(SLAVE..NUM[5],crTable( SLAVE..NUM[1], SLAVE..NUM[2], SLAVE..NUM[3]))
		CheckPlaceForUnvisibleCommand(SLAVE..NUM[6],crTable( SLAVE..NUM[1], SLAVE..NUM[2], SLAVE..NUM[3]))
		STEP = 2
	elseif STEP == 2 then -- собираемся рядом
		STEP_TEXT = "teleport all in one place"
		TeleportCommand(SLAVE..NUM[4], 13,100,1)
		TeleportCommand(SLAVE..NUM[5], 14,100,1)
		TeleportCommand(SLAVE..NUM[6], 15,100,1)
		STEP = 3
	elseif STEP == 3 then -- смотрим что все тут
		STEP_TEXT = "check all visible"
		CheckPlaceForVisibleCommand(SLAVE..NUM[1],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[2],crTable( SLAVE..NUM[1], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[3],crTable( SLAVE..NUM[2], SLAVE..NUM[1], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[4],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[1], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[5],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[1], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[6],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[1]))
		STEP = 4
	elseif STEP == 4 then -- создаем группу лидер 1
		STEP_TEXT = "1 invite 2,3,4,5,6"
		InviteInGroupCommand(SLAVE..NUM[1], crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[6]))
		STEP = 5
	elseif STEP == 5 then -- портимся в даль
		STEP_TEXT = "1,2,3 teleport long range"
		TeleportCommand(SLAVE..NUM[1], 10,500,1)
		TeleportCommand(SLAVE..NUM[2], 11,500,1)
		TeleportCommand(SLAVE..NUM[3], 12,500,1)
		STEP = 6
	elseif STEP == 6 then -- смотрим что все тут
		STEP_TEXT = "check all visible"
		CheckPlaceForVisibleCommand(SLAVE..NUM[1],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[2],crTable( SLAVE..NUM[1], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[3],crTable( SLAVE..NUM[2], SLAVE..NUM[1], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[4],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[1], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[5],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[1], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[6],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[1]))
		STEP = 7
	elseif STEP == 7 then -- покидаем группу
		STEP_TEXT = "leave group"
		LeaveBotCommand(SLAVE..NUM[1])
		LeaveBotCommand(SLAVE..NUM[2])
		LeaveBotCommand(SLAVE..NUM[3])
		LeaveBotCommand(SLAVE..NUM[4])
		LeaveBotCommand(SLAVE..NUM[5])
		--LeaveBotCommand(SLAVE..NUM[6])
		STEP = 8
	elseif STEP == 8 then -- закрываемся
		STEP_TEXT = "quit"
		QuitBotCommand(SLAVE..NUM[1])
		QuitBotCommand(SLAVE..NUM[2])
		QuitBotCommand(SLAVE..NUM[3])
		QuitBotCommand(SLAVE..NUM[4])
		QuitBotCommand(SLAVE..NUM[5])
		QuitBotCommand(SLAVE..NUM[6])
		STEP = -1
	else
		Success( TEST_NAME )
	end
	Log("Step - "..tostring(STEP)..": "..tostring(STEP_TEXT))
	StartTimer( time_wait, ErrorFunc10sec, nil )
end
