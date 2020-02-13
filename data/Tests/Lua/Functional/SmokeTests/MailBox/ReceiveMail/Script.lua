Global( "TEST_NAME", "ItemMall; author: Liventsev Andrey, date: 06.04.09, task 60909" )

Global( "MOB_NAME", "Tests/FunctionalTests/MobWorld/MailmanTest.xdb" )
Global( "RECIEVE_FROM", nil )
Global( "MAP_RESOURCE", "/Tests/Maps/Lua/MapResource.xdb" )

Global( "ITEM_NAME_1", "Items/Mechanics/ZombieDenture10.xdb" )
Global( "ITEM_NAME_2", "Items/Mechanics/YakPelt20.xdb" )
Global( "ITEM_NAME_3", "Items/Mechanics/Vendor7Sword.xdb" )

Global( "LETTER_INDEX", nil )


function Summon()
	local newPos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), 0.5 )
	SummonMob( MOB_NAME, MAP_RESOURCE, newPos, 0, OpenMail, ErrorFunc )
end

function OpenMail( npcId )
	OpenMailBox( npcId, BeforeOpenLetters, ErrorFunc )
end

function BeforeOpenLetters()
	LETTER_INDEX = 0
	Log( "letters: (" .. tostring( GetTableSize(mailBox.RequestMailIds()) ) .. ")" )
--	StartTimer( 10000, OpenLetters )
end

function OpenLetters()
	for index, mailId in mailBox.RequestMailIds() do
		if LETTER_INDEX == index then
			LETTER_INDEX = LETTER_INDEX + 1
			TakeAllFromMail( mailId, OpenLetters, ErrorFunc )
			return
		end	
	end
	
	ClearMailBox( CloseMail, ErrorFunc )
end

function CloseMail()
	CloseMailBox( Done, ErrorFunc )
end

function Done()
	Success( TEST_NAME )
	DisintagrateMob( MOB_NAME )
end

function ErrorFunc( text )
	DisintagrateMob( MOB_NAME )
	Warn( TEST_NAME, text )
end



--------------------------------------- EVENTS --------------------------------------------

function OnAvatarCreated()
	StartTest( TEST_NAME )

	qaMission.AvatarGiveMoney( 1000000 )
	Summon()
end

function Init()
	local login = {
		login = developerAddon.GetParam( "login"),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" ),
		create = "AutoMage"
	}
	InitLoging(login)
	
	RECIEVE_FROM = developerAddon.GetParam( "receiveFrom" )
	
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
end

Init()