function SetTestName()
	TEST_NAME = "Group Test for Teleport on 2 maps"
end

function NextStep()
	PULL_ERRORS = nil
	PULL_ERRORS = {}
	PULL = nil
	PULL = {}
	local time_wait = 20000

	if STEP == 0 then -- собираемся рядом
		STEP_TEXT = "teleport all one place"
		TeleportCommand(SLAVE..NUM[1], 10,100,1)
		TeleportCommand(SLAVE..NUM[2], 11,100,1)
		TeleportCommand(SLAVE..NUM[3], 12,100,1)
		TeleportCommand(SLAVE..NUM[4], 13,100,1)
		TeleportCommand(SLAVE..NUM[5], 14,100,1)
		TeleportCommand(SLAVE..NUM[6], 15,100,1)
		STEP = 1
	elseif STEP == 1 then -- смотрим что все тут
		STEP_TEXT = "accept group from 1"
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
		STEP_TEXT = "1 invite 2,3,4,5,6"
		InviteInGroupCommand(SLAVE..NUM[1], crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[6]))
		STEP = 3
	elseif STEP == 3 then -- портимся на другую карту 3е
		STEP_TEXT = "1,2,3 tp to Lua2"
		TeleportCommand(SLAVE..NUM[1], 10,10,1,"Tests/Maps/Lua2/MapResource.xdb")
		TeleportCommand(SLAVE..NUM[2], 11,10,1,"Tests/Maps/Lua2/MapResource.xdb")
		TeleportCommand(SLAVE..NUM[3], 12,10,1,"Tests/Maps/Lua2/MapResource.xdb")
		STEP = 4
	elseif STEP == 4 then -- смотрим рядом что видим рядом
		STEP_TEXT = "check all visible near"
		CheckPlaceForVisibleCommand(SLAVE..NUM[1],crTable( SLAVE..NUM[2], SLAVE..NUM[3]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[2],crTable( SLAVE..NUM[1], SLAVE..NUM[3]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[3],crTable( SLAVE..NUM[2], SLAVE..NUM[1]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[4],crTable( SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[5],crTable( SLAVE..NUM[4], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[6],crTable( SLAVE..NUM[5], SLAVE..NUM[4]))
		STEP = 401
	elseif STEP == 401 then -- смотрим что видим на другой карте.
		STEP_TEXT = "check all visible on other map"
		CheckPlaceForVisibleCommand(SLAVE..NUM[1],crTable( SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[2],crTable( SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[3],crTable( SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[4],crTable( SLAVE..NUM[1], SLAVE..NUM[2], SLAVE..NUM[3]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[5],crTable( SLAVE..NUM[1], SLAVE..NUM[2], SLAVE..NUM[3]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[6],crTable( SLAVE..NUM[1], SLAVE..NUM[2], SLAVE..NUM[3]))
		STEP = 5
	elseif STEP == 5 then -- портимся на другую карту остальные
		STEP_TEXT = "4,5,6 tp to Lua2"
		TeleportCommand(SLAVE..NUM[4], 13,10,1,"Tests/Maps/Lua2/MapResource.xdb")
		TeleportCommand(SLAVE..NUM[5], 14,10,1,"Tests/Maps/Lua2/MapResource.xdb")
		TeleportCommand(SLAVE..NUM[6], 15,10,1,"Tests/Maps/Lua2/MapResource.xdb")
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
	elseif STEP == 7 then -- портимся все на другую карту все рядом
		STEP_TEXT = "teleport all to Lua map"
		TeleportCommand(SLAVE..NUM[1], 10,100,1)
		TeleportCommand(SLAVE..NUM[2], 11,100,1)
		TeleportCommand(SLAVE..NUM[3], 12,100,1)
		TeleportCommand(SLAVE..NUM[4], 13,100,1)
		TeleportCommand(SLAVE..NUM[5], 14,100,1)
		TeleportCommand(SLAVE..NUM[6], 15,100,1)
		STEP = 8
	elseif STEP == 8 then -- смотрим что все тут
		STEP_TEXT = "check all visible"
		CheckPlaceForVisibleCommand(SLAVE..NUM[1],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[2],crTable( SLAVE..NUM[1], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[3],crTable( SLAVE..NUM[2], SLAVE..NUM[1], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[4],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[1], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[5],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[1], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[6],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[1]))
		STEP = 9
	elseif STEP == 9 then -- портимся на другую карту все рядом
		STEP_TEXT = "teleport all to Lua2 map"
		TeleportCommand(SLAVE..NUM[1], 10,100,1,"Tests/Maps/Lua2/MapResource.xdb")
		TeleportCommand(SLAVE..NUM[2], 11,100,1,"Tests/Maps/Lua2/MapResource.xdb")
		TeleportCommand(SLAVE..NUM[3], 12,100,1,"Tests/Maps/Lua2/MapResource.xdb")
		TeleportCommand(SLAVE..NUM[4], 13,100,1,"Tests/Maps/Lua2/MapResource.xdb")
		TeleportCommand(SLAVE..NUM[5], 14,100,1,"Tests/Maps/Lua2/MapResource.xdb")
		TeleportCommand(SLAVE..NUM[6], 15,100,1,"Tests/Maps/Lua2/MapResource.xdb")
		STEP = 10
	elseif STEP == 10 then -- смотрим что все тут
		STEP_TEXT = "check all visible"
		CheckPlaceForVisibleCommand(SLAVE..NUM[1],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[2],crTable( SLAVE..NUM[1], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[3],crTable( SLAVE..NUM[2], SLAVE..NUM[1], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[4],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[1], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[5],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[1], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[6],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[1]))
		STEP = 11
	elseif STEP == 11 then -- портимся в одно место
		STEP_TEXT = "teleport in one place Lua map"
		TeleportCommand(SLAVE..NUM[1], 10,100,1)
		TeleportCommand(SLAVE..NUM[2], 11,100,1)
		TeleportCommand(SLAVE..NUM[3], 12,100,1)
		TeleportCommand(SLAVE..NUM[4], 13,100,1)
		TeleportCommand(SLAVE..NUM[5], 14,100,1)
		TeleportCommand(SLAVE..NUM[6], 15,100,1)
		STEP = 12
	elseif STEP == 12 then -- смотрим что все тут
		STEP_TEXT = "check all visible"
		CheckPlaceForVisibleCommand(SLAVE..NUM[1],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[2],crTable( SLAVE..NUM[1], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[3],crTable( SLAVE..NUM[2], SLAVE..NUM[1], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[4],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[1], SLAVE..NUM[5], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[5],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[1], SLAVE..NUM[6]))
		CheckPlaceForVisibleCommand(SLAVE..NUM[6],crTable( SLAVE..NUM[2], SLAVE..NUM[3], SLAVE..NUM[4], SLAVE..NUM[5], SLAVE..NUM[1]))
		STEP = 13
	elseif STEP == 13 then -- покидаем группу
		STEP_TEXT = "leave group"
		LeaveBotCommand(SLAVE..NUM[1])
		LeaveBotCommand(SLAVE..NUM[2])
		LeaveBotCommand(SLAVE..NUM[3])
		LeaveBotCommand(SLAVE..NUM[4])
		LeaveBotCommand(SLAVE..NUM[5])
		--LeaveBotCommand(SLAVE..NUM[6])
		STEP = 14
	elseif STEP == 14 then -- закрываемся
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
