Global( "TEST_NAME", "ItemMallBase; author: Liventsev Andrey, date: 13.04.09, task 61624" )

function Done()
	Success( TEST_NAME )
end

function ErrorFunc( text )
	Warn( TEST_NAME, text )
end



function Step1( subCategories )
	ItemMallGetItemsBySubCategoryId( subCategories[0], Step2, ErrorFunc )
end

function Step2( items )
	ItemMallBuyItem( items[0].itemId, Done, ErrorFunc )
end


--------------------------------------- EVENTS --------------------------------------------
function OnAvatarCreated()
	StartTest( TEST_NAME )
	
	ItemMallGetSubCategories( itemMall.GetCategories()[0], Step1, ErrorFunc )
end

function Init()
	local login = {
		login = developerAddon.GetParam( "login"),
		pass = developerAddon.GetParam( "password" ),
		avatar = developerAddon.GetParam( "avatar" ),
		create = "AutoMage"
	}
	InitLoging(login)
	
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
end

Init()