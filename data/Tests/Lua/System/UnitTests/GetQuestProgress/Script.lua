Global( "TEST_NAME", "UnitTests.GetMainhandSpeed" )

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
			local quest = avatar.GetQuestProgress( id )
			if quest.state == nil then
				errorText = errorText .. "state, "
			else
				Log( "state=" .. tostring( quest.state ))
			end
			local obj = quest.objectives[0]
			if obj.progress == nil then
				errorText = errorText .. "objectives.progress, "
			else
				Log( "progress=" .. tostring( obj.progress ))
			end
			if obj.required == nil then
				errorText = errorText .. "objectives.required "
			else
				Log( "required=" .. tostring( obj.required ))
			end	
			if errorText ~= "" then
				ErrorFunc( errorText .. " fields is null for quest " .. avatar.GetQuestInfo( id ).debugName ) 
				return
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
