Global( "TEST_NAME", "UnitTests.GetSpellBook" )

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
		Log( "spell book:" )
		for index, id in book do
			Log( "   " .. avatar.GetSpellInfo( id ).debugName )
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
