function SetTestName()
	TEST_NAME = "Instance Test for Share Instance"
end

function NextStep()
	PULL_ERRORS = nil
	PULL_ERRORS = {}
	PULL = nil
	PULL = {}
	local time_wait = 20000
	if STEP == 0 then -- чтобы точно быть не в группу
		STEP_TEXT = "accept from 1"
		AcceptInviteCommand(SLAVE..NUM[1], SLAVE..NUM[2])
		AcceptInviteCommand(SLAVE..NUM[1], SLAVE..NUM[3])
		AcceptInviteCommand(SLAVE..NUM[1], SLAVE..NUM[4])
		AcceptInviteCommand(SLAVE..NUM[1], SLAVE..NUM[5])
		AcceptInviteCommand(SLAVE..NUM[1], SLAVE..NUM[6])
		STEP = 1
	elseif STEP == 1 then -- портимся в одно место
		STEP_TEXT = "teleport all near"
		TeleportCommand(SLAVE..NUM[1], 10,100,1)
		TeleportCommand(SLAVE..NUM[2], 11,100,1)
		TeleportCommand(SLAVE..NUM[3], 12,100,1)
		TeleportCommand(SLAVE..NUM[4], 13,100,1)
		TeleportCommand(SLAVE..NUM[5], 14,100,1)
		TeleportCommand(SLAVE..NUM[6], 15,100,1)
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
		STEP_TEXT = "1 invite 2,3,4,5"
		InviteInGroupCommand(SLAVE..NUM[1], crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[5]))
		STEP = 201
	elseif STEP == 201 then -- все кроме лидера и 6ого портимся в инст
		STEP_TEXT = "2,3,4,5 tp to Inst"
		TeleportCommand(SLAVE..NUM[2], 10,250,1,"Tests/Maps/TestInstance/MapResource.xdb")
		TeleportCommand(SLAVE..NUM[3], 11,250,1,"Tests/Maps/TestInstance/MapResource.xdb")
		TeleportCommand(SLAVE..NUM[4], 12,250,1,"Tests/Maps/TestInstance/MapResource.xdb")
		TeleportCommand(SLAVE..NUM[5], 13,250,1,"Tests/Maps/TestInstance/MapResource.xdb")
		STEP = 3
	elseif STEP == 3 then -- смотрим что лидер и 6ой видят друг друга на другой карте
		STEP_TEXT = "check that visible 1 to 6 and 6 to 1"
		CheckPlaceForVisibleCommand(SLAVE..NUM[1],crTable( SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[6],crTable( SLAVE..NUM[1]))
		STEP = 4
	elseif STEP == 4 then -- берем в группу 6ого
		STEP_TEXT = "1 invite 6"
		InviteInGroupCommand(SLAVE..NUM[1], crTable( SLAVE..NUM[6] ))
		STEP = 5
	elseif STEP == 5 then -- смотрим что все тут
		STEP_TEXT = "check all visible"
		CheckPlaceForVisibleCommand(SLAVE..NUM[1],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[2],crTable( SLAVE..NUM[1], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[3],crTable( SLAVE..NUM[2], SLAVE..NUM[1], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[4],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[1], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[5],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[1], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[6],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[1]))
		STEP = 6
	elseif STEP == 6 then -- портимся лидер и 6ой в инст
		STEP_TEXT = "1,6 tp to Inst"
		TeleportCommand(SLAVE..NUM[1], 14,250,1,"Tests/Maps/TestInstance/MapResource.xdb")
		TeleportCommand(SLAVE..NUM[6], 15,250,1,"Tests/Maps/TestInstance/MapResource.xdb")
		STEP = 601
	elseif STEP == 601 then -- смотрим что все тут
		STEP_TEXT = "check all visible"
		CheckPlaceForVisibleCommand(SLAVE..NUM[1],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[2],crTable( SLAVE..NUM[1], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[3],crTable( SLAVE..NUM[2], SLAVE..NUM[1], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[4],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[1], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[5],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[1], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[6],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[1]))
		STEP = 602
	elseif STEP == 602 then -- портимся обратно
		STEP_TEXT = "teleport all to Lua map"
		TeleportCommand(SLAVE..NUM[1], 10,100,1)
		TeleportCommand(SLAVE..NUM[2], 11,100,1)
		TeleportCommand(SLAVE..NUM[3], 12,100,1)
		TeleportCommand(SLAVE..NUM[4], 13,100,1)
		TeleportCommand(SLAVE..NUM[5], 14,100,1)
		TeleportCommand(SLAVE..NUM[6], 15,100,1)
		STEP = 7
	elseif STEP == 7 then -- выходим из группы
		STEP_TEXT = "leave"
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
		Success(TEST_NAME)
	end
	Log("Step - "..tostring(STEP)..": "..tostring(STEP_TEXT))
	StartTimer( time_wait, ErrorFunc10sec, nil )
end
