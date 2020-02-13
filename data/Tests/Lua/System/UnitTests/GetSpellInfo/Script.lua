Global( "TEST_NAME", "UnitTests.GetSpellInfo" )

function Done()
	Success( TEST_NAME )
end

function ErrorFunc( text )
	Warn( TEST_NAME, text )
end

function CheckQuestBook()

end


----------------------------- EVENTS -----------------------------------

function OnAvatarCreated()
	StartTest( TEST_NAME )

	local book = avatar.GetSpellBook()
	if book == nil or GetTableSize(book) == 0 then
		ErrorFunc( "spell book is empty" )
	else
		Log( "spell info:" )
		for index, id in book do
			local errorText = ""
			local spell = avatar.GetSpellInfo( id )
			if spell.debugName == nil then
				errorText = errorText .. "debugName, "
			else
				Log( spell.debugName )
			end			
			if spell.prepareDuration == nil then
				errorText = errorText .. "prepareDuration, "
			else
				Log( "  prepareDuration= " .. tostring(spell.prepareDuration) )
			end
			if spell.range == nil then
				errorText = errorText .. "range, "
			else
				Log( "  range= " .. tostring(spell.range) )
			end
			if spell.rank == nil then
				errorText = errorText .. "rank, "
			else
				Log( "  rank= " .. tostring(spell.rank) )
			end
			if errorText ~= "" then
				ErrorFunc( errorText .. " fields is null for spell " .. spell.debugName ) 
			end
		end
		Done()
	end
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
