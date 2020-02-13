Global( "TEST_NAME", "Check Mentor. author: Liventsev Andrey, date: 11.07.08, bugId 37339" )

-- params from xdb
Global( "VALID_ABILITY", nil )
Global( "INVALID_ABILITY", nil )
Global( "VALID_SPELL", nil )
Global( "INVALID_SPELL", nil )
Global( "REQ_LEVEL", nil )
Global( "MENTOR", nil )
-- /params

Global( "MAP_NAME", "/Tests/Maps/Lua/MapResource.xdb" )


function ErrorFunc( text )
	DisintagrateMob( MENTOR )
	Warn( TEST_NAME, text )
end

function Done()
	DisintagrateMob( MENTOR )
	Success( TEST_NAME )
end

function SelectingMentor( unitId )
	StartTalk( unitId, StartTrade, ErrorFunc )
end

function StartTrade()
	Log( "" )
	Log( "starting trade for learning all spells and abilities..." )
	StartTimer( 10000, ErrorFunc, "event OnTrainerListUpdated not coming" )
	avatar.RequestTrainer()
end

function CheckSpellBook( shouldBe )
	local spellBook = avatar.GetSpellBook()
	local learnedSpell = false
	for index, id in spellBook do
		local spellInfo = avatar.GetSpellInfo( id )
		local name = spellInfo.debugName
		if shouldBe == false then
			if name == VALID_SPELL or name == INVALID_SPELL then
				ErrorFunc( "Avatar already learned spell " .. name )
			end
		else
			if name == VALID_SPELL then
				Log( "valid spell learned: " .. name )
				learnedSpell = true
			elseif name == INVALID_SPELL then
				ErrorFunc( "Avatar can learn spell " .. name .. " for " .. tostring( REQ_LEVEL ) .. " level" )
			end
		end
	end
	
	local abilityBook = avatar.GetAbilities()
	local learnedAbility = false
	for index, id in abilityBook do
		local abilityInfo = avatar.GetAbilityInfo( id )
		local name = abilityInfo.sysInfo
		if shouldBe == false then
			if name == VALID_ABILITY or name == INVALID_ABILITY then
				ErrorFunc( "Avatar already learned ability " .. name )
			end
		else
			if name == VALID_ABILITY then
				Log( "valid ability learned: " .. name )
				learnedAbility = true
			elseif name == INVALID_ABILITY then
				ErrorFunc( "Avatar can learn ability " .. name .. " for " .. tostring( REQ_LEVEL ) .. " level" )
			end
		end
	end
	
	if shouldBe == true then
		if learnedSpell == false then
			ErrorFunc( "Avatar did not learn spell " .. VALID_SPELL )
		elseif learnedAbility == false then
			ErrorFunc( "Avatar did not learn ability " .. INVALID_SPELL  )
		else
			Done()
		end
	else
		local newPos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), 1 )
		SummonMob( MENTOR, MAP_NAME, newPos, 2, SelectingMentor, ErrorFunc )
	end
end


----------------------------------- EVENTS -------------------------------------


function OnAvatarCreated()
	StartTest( TEST_NAME )
	qaMission.AvatarGiveMoney( 100000 )
	qaMission.AvatarLevelUp( REQ_LEVEL ) 

	CheckSpellBook( false )
end

function OnTrainerListUpdated()
	StopTimer()
	
	local list = avatar.GetTrainerSpells()
	for index in list do
		local spellId = list[index].id
		local spell = avatar.GetSpellInfo( spellId )
		local conditions = avatar.GetLearnSpellConditions( spellId )
		
		if conditions.canLearn == true then
			if spell.debugName == VALID_SPELL then
				Log( "learning spell " .. spell.debugName .. "    required spell ! " )
			else
				Log( "learning spell " .. spell.debugName )
			end
			StartTimer( 10000, ErrorFunc, "event OnTrainerListUpdated not coming" )
			avatar.LearnSpell( spellId )
			return
			
		elseif spell.debugName == VALID_SPELL then
			local cause = ""
			for index, reason in conditions.failedConditions do
				cause = cause .. " " .. reason
			end
			ErrorFunc( "Can't learn valid spell " .. VALID_SPELL .. " cause " .. cause )
			return
		end
	end
	
	list = avatar.GetTrainerAbilities()
	for index in list do
		local abilityId = list[index].id
		local ability = avatar.GetAbilityInfo( abilityId )

		local conditions = avatar.GetLearnAbilityConditions( abilityId )
	
		if conditions.canLearn then
			if ability.sysInfo == VALID_ABILITY then
				Log( "learning ability " .. ability.sysInfo .. "   -- required ability! " )	
			else
				Log( "learning ability " .. ability.sysInfo )	
			end

			StartTimer( 10000, ErrorFunc, "event OnTrainerListUpdated not coming" )
			avatar.LearnAbility( abilityId )
			return
			
		elseif ability.sysInfo == VALID_ABILITY then
			local cause = ""
			for index, reason in conditions.failedConditions do
				cause = cause .. " " .. reason
			end
			ErrorFunc( "Can't learn valid ability " .. VALID_ABILITY .. " cause " .. cause )
			return
		end
	end
	
	Log( "" )
	Log( "all spells and abilities learned. Checking results..." )
	StartTimer( 5000, CheckSpellBook, true )
end	


function Init()
	local login = {
		login = developerAddon.GetParam( "login"),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" )
	}
	InitLoging( login )
	
	VALID_ABILITY = developerAddon.GetParam( "ValidAbility" )
	INVALID_ABILITY = developerAddon.GetParam( "InvalidAbility" )
	VALID_SPELL = developerAddon.GetParam( "ValidSpell" )
	INVALID_SPELL = developerAddon.GetParam( "InvalidSpell" )
	REQ_LEVEL = tonumber(developerAddon.GetParam( "ReqLevel" ))
	MENTOR = developerAddon.GetParam( "MentorName" )
	
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
	common.RegisterEventHandler( OnTrainerListUpdated, "EVENT_TRAINER_LIST_UPDATED" )
end


Init()