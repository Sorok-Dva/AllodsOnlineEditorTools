Global( "debug", {} )
Global( "skillId", nil )

-- MISC FUNCTIONS 

---------------------------------------------------------
-- Вывод таблиц
---------------------------------------------------------

function LogParams( params, strPrefix )
	if not strPrefix then
		strPrefix = ""
	end

	LogInfo( strPrefix , params and GetTableSize( params ), " items:" )

	if not params then
		return
	end

  for i, val in params do
		if "table" == type( val ) then
			LogInfo( strPrefix, i, " = table:" )
			LogParams( val, strPrefix .. "  ")
		elseif common.IsWString( val ) then
			LogInfo( strPrefix, i, " = '", debugCommon.FromWString( val ), "'" )
		else
			LogInfo( strPrefix, i, " = ", val )
		end
  end
end

---------------------------------------------------------
-- Обработка клавиш
---------------------------------------------------------
-- Personal/input.cfg:
--
-- commonbindsection
-- bindsection mission
-- bind test1 'CTRL' + 'T'
-- bind test2 'CTRL' + 'Y'
-- bind test3 'CTRL' + 'U'
-- bind test4 'CTRL' + 'I'
-- bind test5 'CTRL' + 'O'
-- bind test6 'CTRL' + 'P'
-- bind test7 'CTRL' + 'J'
-- bind test8 'CTRL' + 'K'
-- bind test9 'CTRL' + 'L'


function OnTest1()
	LogInfo( "====================== Test 1 - Ctrl T" ) -- T
end

function OnTest2()
	LogInfo( "====================== Test 2 - Ctrl Y" ) -- Y
end

function OnTest3()
	LogInfo( "====================== Test 3 - Ctrl U" ) --U
end

function OnTest4()
	LogInfo( "====================== Test 4 - Ctrl I" )  -- I
end

function OnTest5()
	LogInfo( "====================== Test 5 - Ctrl O" )  -- O
end

function OnTest6()
	LogInfo( "====================== Test 6 - Ctrl P" ) -- P
end


---------------------------------------------------------
-- Обработка сообщений
---------------------------------------------------------


function EVENT_ ( params )
	LogInfo("================================ EVENT_")
	LogParams( params )
end      



function Init()
	LogInfo( "Test Addon" )

	common.RegisterReactionHandler( OnTest1, "test1" )
	common.RegisterReactionHandler( OnTest2, "test2" )
	common.RegisterReactionHandler( OnTest3, "test3" )
	common.RegisterReactionHandler( OnTest4, "test4" )
	common.RegisterReactionHandler( OnTest5, "test5" )
	common.RegisterReactionHandler( OnTest6, "test6" )

	common.RegisterEventHandler( EVENT_, "EVENT_" )



end

-- custom initialization

Init()
