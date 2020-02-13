--Наложение заклинаний на другого перса.
Global( "TEST_NAME", "SpellForGroup" )

Global( "CHILD_NAME", nil )
Global( "CHILD_ID", nil )
Global( "PING", false )

Global( "CHK_CR_MEM", nil )

Global( "LEVEL", nil )
Global( "TARGET", nil )
Global( "TEST_SPELL", nil )
Global( "SPELL_TO_POINT", false)

Global( "COUNT_TO_FAR", 0 )
Global( "COUNT_TO_FAR_MAX", 10 )
Global( "SPELL_IS_ABILITY", false)
Global( "GROUP_CHANGED", false)



--Кастует основное заклинание на Child.
function CastSpellOnChild()
 	StepLog("Cast Prepare spells... Ok")
	StepLog("Case TestSpell: " .. TEST_SPELL.." try")

	local testSpell = GetSpellId( TEST_SPELL )
	if not SPELL_IS_ABILITY then
		if SPELL_TO_POINT then
			local point = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), 20 )
			local absPos = ToAbsCoord(point)
			local newPoint = {posX = absPos.X,posY = absPos.Y,posZ = absPos.Z}
			CastSpell( testSpell, newPoint, 10000, WachTime, WachError )
		else
			CastSpell20Times( testSpell, nil, 10000, WachTime, WachError )
		end
	else
		WachTime()
	end
	
end

function WachTime()
	StepLog("Case TestSpell: " .. TEST_SPELL.." Ok")
	StartTimer(2000, Done)
end

function WachError(text)
	StartTimer(2000,ErrorFunc,text)
end

function StepLog(msg)
	Log(msg,"SpellForGroup")
end

function Done()
	StopPing()
	qaMission.DebugNotify( DONE_TEXT, false )
 	StartTimer(5000, Success, TEST_NAME )
end

function ErrorFunc( text )
	qaMission.DebugNotify( ERROR_TEXT, false )
	StopPing()
	Warn(  TEST_NAME, text )
end

function LearnAdvSpells()
	LearnPrepareSpells(OnSpellsPrepared)
end

function OnSpellsPrepared()
	StepLog("Learn prepare spells... Ok")
	StepLog("Start Child Addon... try")
	StartTimer1(60000,ErrorFunc,"Child not coming in game for 30 sec")
    developerAddon.RunChildGame( "Child.(DeveloperAddon).xdb", " -silentMode" )
end

function CastPrepSp(id)
	CHILD_ID = id
	CastPrepareSpells(id, StartInGroup)
end

function StopPing()
	StopTimer1()
	PING = false
end

function StartPing()
	PING = true
	StartTimer1(3000,ErrorFunc,"dont ping Child!!!")
end
----------------------------- EVENTS -----------------------------------
function StartAlone()
	local spells = {}
	local abilki = {}
	if SPELL_IS_ABILITY then
		table.insert(abilki,TEST_SPELL)
	else
		table.insert(spells,TEST_SPELL)
	end
	StepLog("LevelUp... try")
	LevelUp( LEVEL, spells, LearnAdvSpells, ErrorFunc, abilki)
end

function OnAvatarCreated()
	StepLog("Check in group")
	LeaveGroupOnStart(StartAlone)
end

function OnDebugNotify( params )
	if CHILD_NAME == nil then
		if debugCommon.FromWString(params.message) == CHILD_START_MSG then
			CHILD_NAME = params.sender
			StopTimer1()
			StepLog("Start Child Addon... Ok")
			StepLog("Child check distance and invite me... Try")
			qaMission.DebugNotify(MAIN_ANSWER_MSG, false )
			StartPing()
		end
	else
		if common.CompareWString(CHILD_NAME, params.sender) == 0 then
			if debugCommon.FromWString(params.message) == PING_QUESTION_MSG and PING then
				StartTimer1(3000,ErrorFunc,"dont ping Child!!!")
				return PingMsg(true)
			end
			if debugCommon.FromWString(params.message) == ERROR_TEXT then
				StopPing()
				Warn( TEST_NAME, "Exit reason - command from child addon" )
				return
			end
			if debugCommon.FromWString(params.message) == DONE_TEXT then
				StopPing()
				Success( TEST_NAME )
				return
			end
			if debugCommon.FromWString(params.message) == CHILD_DIST_TOO_MUCH then
			    if COUNT_TO_FAR < COUNT_TO_FAR_MAX then
					StepLog("Send coordinates near me... Try "..tostring(COUNT_TO_FAR).." time")
					local pos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), 5 )
					local absPos = ToAbsCoord( pos )
					local strPos = absPos.X.." "..absPos.Y.." "..absPos.Z
					qaMission.DebugNotify(TP_TO_COORDINATES..strPos, false )
					COUNT_TO_FAR = COUNT_TO_FAR + 1
					return
				else
					ErrorFunc( "Cant find avatar near me" )
				end
			end
		end
	end
end

function OnGroupAcceptError( params )
	StopAllTimers()
	ErrorFunc( "OnGroupAcceptError" )
end

function OnGroupInvite(params)
	if common.CompareWString(params.inviterName,CHILD_NAME) == 0 then
		StepLog("Child check distance and invite me... Ok child - "..debugCommon.FromWString(CHILD_NAME))
		StopTimer()
		local user = findUser(debugCommon.FromWString(CHILD_NAME))
		if user == nil then
			return ErrorFunc( "cant find child !!!" )
		end
		--StartCheckTimer( 5000, CheckGroupCreate, nil, ErrorFunc, "Cant accept to group", CastPrepSp, user.id )
		StartCheckTimer( 5000, CheckGroupCreate, nil, CastPrepSp, user.id, CastPrepSp, user.id )
	    group.Accept()
	    StepLog("Accept to group... try")

	    --StartTimer(5000, ErrorFunc, "Cant accept to group")
	end
end

function CheckGroupCreate()
	local members = group.GetMembers()
	NabludatelMembers(members)
	if members~= nil and CHILD_NAME ~= nil then
		for i, member in members do
			if common.CompareWString(CHILD_NAME, member.name) == 0 then
				StepLog("Accept to group... Ok")
				return true
			end
		end
	end
	return false
end

function StartInGroup()
	StepLog("Target type: "..TARGET)
	if TARGET == "member" then
		StepLog("Select member... try "..tostring(CHILD_ID))
		SelectTarget( CHILD_ID, CastSpellOnChild, ErrorFunc )
	elseif TARGET == "none" then
	    -- TODO Unselect
		CastSpellOnChild()
	elseif TARGET == "aura" then
		-- спросить чилда о буффе.
		Done()
	elseif TARGET == "self" then
		TargetSelf( CastSpellOnChild, ErrorFunc )
	elseif TARGET == "point" then
		SPELL_TO_POINT = true
		CastSpellOnChild()
	end
end

function NabludatelMembers(members)
	local str = ""
	if members ~= nil then
		for i,mem in members do
			str = str .. debugCommon.FromWString(mem.name).. ","
		end
	else
		str = "nil"
	end
	if CHK_CR_MEM ~= str then
		Log("GROUP: "..str)
		CHK_CR_MEM = str
	end
end

function OnGroupChanged(params)
	local members = group.GetMembers()
	NabludatelMembers(members)
	--Log("members: "..tostring(members).." group ch: "..tostring(GROUP_CHANGED).." child: "..tostring(CHILD_NAME))
--	if members~= nil and not GROUP_CHANGED and CHILD_NAME ~= nil then
--		for i, member in members do
--			Log("member "..debugCommon.FromWString(member.name))
--			if common.CompareWString(CHILD_NAME, member.name) == 0 then
--				StopTimer()
--				GROUP_CHANGED = true
--				StepLog("Accept to group... Ok")
--				return StartInGroup(CastPrepareSpells)
--			end
--		end
--	end
end

function Init()
	local login = {
		login = developerAddon.GetParam( "login"),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" )
	}
	InitLoging(login)

    local level = developerAddon.GetParam( "Level" )
    if level ~= "" then
    	LEVEL = tonumber(level)
    end
    local target = developerAddon.GetParam( "Target" )
    if target ~= "" then
        TARGET = target
    end
 	local ability = developerAddon.GetParam( "SpellIsAbility" )
	if ability ~= "" then
		if ability == "true" then
			SPELL_IS_ABILITY = true
		elseif ability == "false" then
			SPELL_IS_ABILITY = false
		else
			TEST_ERROR_TEXT = "Wrong SpellIsAbility parametr"
			return ClearExitErr()
		end
	end   
	TEST_SPELL = developerAddon.GetParam( "Spell" )
	GetPrepareSpellsFromAddon()
	TEST_NAME = TEST_SPELL.." - "..developerAddon.GetParam( "avatar" )..". Template: "..TEST_NAME
    common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
    common.RegisterEventHandler( OnDebugNotify, "EVENT_DEBUG_NOTIFY")
    common.RegisterEventHandler( OnGroupInvite, "EVENT_GROUP_INVITE")
    common.RegisterEventHandler( OnGroupChanged, "EVENT_GROUP_CHANGED")
	common.RegisterEventHandler( OnGroupAcceptError, "EVENT_GROUP_ACCEPT_ERROR")
end

Init()