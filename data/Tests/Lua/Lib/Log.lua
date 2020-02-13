-- Вызывается в начале теста. Лог + уведомление в чат о начале теста
function StartTest(testname)
	local state = common.GetStateDebugName()
    if state == "class Game::Mission" then
		qaMission.AvatarRevive()
		group.ChatSay( debugCommon.ToWString(testname) )
	end
	developerAddon.LogTest("..")
    developerAddon.LogTest("Start Test: "..testname.." !")
    developerAddon.LogTest("..")
end
-- Выводит в консоль таблицу
function ParamsToConsole(table, name)
	cLog(name)
	for key, value in table do
		cLog(tostring(key).." : "..tostring(value))
	end
end
-- Выводит в лог спеллбуку
function SpellBookToLog()
    local spellBook = avatar.GetSpellBook()
	for i, idSpell in spellBook do
	   	local spellInfo = avatar.GetSpellInfo( idSpell )
	   	Log(tostring(i).." - "..tostring(idSpell).." - "..spellInfo.debugName)
	end
end
-- Выводит текст в консоль
function cLog(text)
	common.LogInfo( "common", text )
end

-- Выводит в лог уведомление об успешном прохождения теста/юнита
function LogSuccess(Test)
	LogResult({isError = false, test = Test, text = nil},true)
end

-- Выводит в лог уведомление об ошибке прохождения теста/юнита
function LogErr(msg,Test)
	LogResult({isError = true, test = Test, text = msg},true)
end

-- Выводит в лог уведомление
function Log(msg,Test)
	if Test == nil then
		LogResult({isError = nil, test = nil, text = msg})
	else
		LogResult({isError = nil, test = Test, text = msg})
	end
end



-- Выводит в лог результат/уведомление теста/юнита (используется внутри либы)
--params.isError - bool
--params.test - TestName
--params.text - Text
function LogResult(params, toAcc)
    local str = ""
    local prefix = ""
	local time = "["..tostring(TIME_SEC).."] "
	if type(params.text) == "string" then
		str = params.text
	end
	if type(params.isError) == "boolean" then
		if params.isError then
			prefix = "-- ERROR --\t"
		else
		    prefix = "-- SUCCESS --\t"
		end
	end
	if params.test ~= nil then
	    prefix = prefix .. "\t\t\t\t[" .. params.test .. "]" .. "\t"
	end

	developerAddon.LogTest(time..prefix..str)
	if toAcc ~= nil then
		LogToAccountFile(prefix..str)
	end
end

-- Выводит текст в лог аккунта (используется внутри либы)
function LogToAccountFile(text, withoutTime)
local time = "["..tostring(TIME_SEC).."] "
	local state = common.GetStateDebugName()
    if state == "class Game::MainMenu" or state == "class Game::MainState" then
		cLog(time..text)
	elseif state == "class Game::PreMission" then
		if withoutTime == nil then
			debugShard.Log(time..text)
		else
			debugShard.Log(text)
		end
	elseif state == "class Game::Mission" then
	    if withoutTime == nil then
			debugMission.Log(time..text)
		else
			debugMission.Log(text)
		end
	end
end

-- использует настройки из BotConfig
function SendHttpMsg( bot, text )
	qaCommon.HttpGET( BOT_LISTENER_ADDRESS .. "/msg?bot=" .. bot .. "&msg=" .. text )
end


function PrintAvatarTarget()
end
