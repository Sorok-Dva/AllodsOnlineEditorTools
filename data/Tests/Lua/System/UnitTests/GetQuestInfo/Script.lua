Global( "TEST_NAME", "UnitTests.GetQuestInfo" )

Global( "QUEST_NAME", "Tests/FunctionalTests/Lua/Quests/Kill_N_Targets/Kill_N_Targets.xdb" )


function Done()
	Success( TEST_NAME )
end

function ErrorFunc( text )
	Warn( TEST_NAME, text )
end

function CheckQuestBook()	
	local book = avatar.GetQuestBook()
	if book == nil or GetTableSize(book) == 0 then
		ErrorFunc( "quest book is empty" )
	else
		for index, id in book do
			local errorText = ""
			local quest = avatar.GetQuestInfo( id )
			if quest.level == nil then
				errorText = errorText .. "level, "
			end
			if quest.rewardMoney == nil then
				errorText = errorText .. "rewardMoney, "
			end
			if quest.rewardExperience == nil then
				errorText = errorText .. "rewardExperience, "
			end	
			if errorText ~= "" then
				ErrorFunc( errorText .. " fields is null for quest " .. quest.debugName ) 
			end
		end
		Done()
	end
end



----------------------------- EVENTS -----------------------------------

function OnAvatarCreated()
	StartTest( TEST_NAME )

	qaMission.AvatarTargetGiveQuest( QUEST_NAME )
	StartTimer( 1000, CheckQuestBook )
end


function Init()
	local login = {
		login = developerAddon.GetParam( "login"),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" )
	}
	InitLoging(login)

	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
end

Init()
