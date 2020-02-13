Global( "TEST_NAME", "SmokeTest.Loot.Take; author: Liventsev Andrey, date: 16.07.08, bug 32373" )

Global( "MOB_NAME", "Creatures/Bee/Instances/Bee4Silver.xdb" )
Global( "MAP_RESOURCE", "/Tests/Maps/Lua/MapResource.xdb" )
Global( "ITEM_NAME", "Items/Mechanics/BeeWings.xdb" )

function Step1( mobId )
	LootMobTakeItem( mobId, ITEM_NAME, Done, ErrorFunc )
end

function Done()
	Success( TEST_NAME )
end

function ErrorFunc( text )
	Warn( TEST_NAME, text )
end


------------------ events -----------------

function OnAvatarCreated()
	StartTest( TEST_NAME )

	local newPos = GetPositionAtDistance( avatar.GetPos(), avatar.GetDir(), 1 )
	SummonMob( MOB_NAME, MAP_RESOURCE, newPos, 0, Step1, ErrorFunc )
end

function Init()
	local login = {
		login = developerAddon.GetParam( "login"),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" ),
		create = "AutoMage"
	}
	InitLoging( login )

	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
end

Init()