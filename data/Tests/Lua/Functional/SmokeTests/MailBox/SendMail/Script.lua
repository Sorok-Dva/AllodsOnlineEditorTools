Global( "TEST_NAME", "SendMail; author: Liventsev Andrey, date: 06.04.09, task 61625" )

Global( "MOB_NAME", "Tests/FunctionalTests/MobWorld/MailmanTest.xdb" )
Global( "SEND_TO", nil )
Global( "MAP_RESOURCE", "/Tests/Maps/Lua/MapResource.xdb" )

Global( "ITEM_NAME_1", "Items/Mechanics/ZombieDenture10.xdb" )
Global( "ITEM_NAME_2", "Items/Mechanics/YakPelt20.xdb" )
Global( "ITEM_NAME_3", "Items/Mechanics/Vendor7Sword.xdb" )

function AddItem2()
	AddItem( ITEM_NAME_2, 1, AddItem3, ErrorFunc )
end

function AddItem3()
	AddItem( ITEM_NAME_3, 1, Summon, ErrorFunc )
end


function Summon()
	local newPos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), 0.5 )
	SummonMob( MOB_NAME, MAP_RESOURCE, newPos, 0, OpenMail, ErrorFunc )
end

function OpenMail( npcId )
	OpenMailBox( npcId, BeforeOpenLetters, ErrorFunc )
end

function BeforeOpenLetters()
	StartTimer( 2000, OpenLetters )
end

function OpenLetters()
	local items = {}
	items[0] = GetItemSlot( ITEM_NAME_1 )
	items[1] = GetItemSlot( ITEM_NAME_2 )
	items[2] = GetItemSlot( ITEM_NAME_3 )
	
	SendMail( ToWString( SEND_TO ), ToWString( "Subject of a test mail" ), ToWString( "Здравствуй, дедушка" ), 125, items, CloseMail, ErrorFunc )
end


function ClearMail()
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
	AddItem( ITEM_NAME_1, 1, AddItem2, ErrorFunc )
end

function Init()
	local login = {
		login = developerAddon.GetParam( "login"),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" ),
		create = "AutoMage"
	}
	InitLoging(login)
	
	SEND_TO = developerAddon.GetParam( "sendTo" )
	
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
end

Init()