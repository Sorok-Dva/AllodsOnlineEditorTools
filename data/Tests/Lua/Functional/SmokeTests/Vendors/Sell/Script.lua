Global( "TEST_NAME", "SmokeTest.Vendor SellItem; author: Liventsev Andrey, date: 10.10.08, task ?" )

Global( "VENDOR_NAME", "Tests/Maps/Test/Instances/Vendor1.(MobWorld).xdb" )
Global( "MAP_NAME", "/Tests/Maps/Lua/MapResource.xdb" )
Global( "ITEM_NAME", "Tests/Items/1HDagger.(ItemResource).xdb" )

Global( "VENDOR_ID", nil )
Global( "MONEY_AMOUNT", 10000 )
Global( "MONEY_START", 0 )

function CheckMoney()
	local money = avatar.GetMoney()
	return money == MONEY_START + MONEY_AMOUNT
end

function SummonVendor()
	local vendorPos = GetPositionAtDistance(avatar.GetPos(), avatar.GetDir(), 1)
	SummonMob( VENDOR_NAME, MAP_NAME, vendorPos, 0, AddingItem, ErrorFunc )
end

function AddingItem()
	AddItem( ITEM_NAME, 2, SellingItem, ErrorFunc )
end

function SellingItem()
	SellItem( VENDOR_NAME, ITEM_NAME, 1, Done, ErrorFunc )
end


function Done()
	DisintagrateMob( VENDOR_NAME )
	Success( TEST_NAME )
end

function ErrorFunc( text )
	DisintagrateMob( VENDOR_NAME )
	Warn( TEST_NAME, text )
end

----------------------------------- EVENTS ------------------------------------

function OnAvatarCreated( params )
   StartTest( TEST_NAME )
   MONEY_START = avatar.GetMoney()
   
   qaMission.AvatarGiveMoney( MONEY_AMOUNT )
   StartCheckTimer( 5000, CheckMoney, nil, ErrorFunc, "cant take money", SummonVendor, nil )
end

function Init()   
	local login = {
		login = developerAddon.GetParam( "login"),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" )
	}
	InitLoging( login )
	
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
end

Init()


