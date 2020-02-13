Global( "TEST_NAME", "SmokeTest.Vendor CheckItems; author: Liventsev Andrey, date: 10.10.08, task ?" )

Global( "VENDOR_NAME", "Tests/Maps/Test/Instances/Vendor2.(MobWorld).xdb" )
Global( "MAP_NAME", "/Tests/Maps/Lua/MapResource.xdb" )
Global( "VENDOR_ID", nil )


function OnCreateVendor( vendorId )
	VENDOR_ID = vendorId
	SelectTarget( VENDOR_ID, OnSelectVendor, ErrorFunc )
end

function OnSelectVendor(  )
    StartTalk( VENDOR_ID, OnTalkStarted, ErrorFunc )
end

function OnTalkStarted( type )
	StartTimer( 5000, ErrorFunc, "EVENT_VENDOR_LIST_UPDATED did not come" )
	avatar.RequestVendor()	
end

function Done()
	DisintagrateMob( VENDOR_NAME )
	Success( TEST_NAME )
end

function ErrorFunc( text )
	DisintagrateMob( VENDOR_NAME )
	Warn( TEST_NAME, text )
end






--------------------------------------- EVENTS --------------------------------

function OnAvatarCreated( params )
   StartTest( TEST_NAME )
   
   local vendorPos = GetPositionAtDistance(avatar.GetPos(), avatar.GetDir(), 1 )
   SummonMob( VENDOR_NAME, MAP_NAME, vendorPos, 0, OnCreateVendor, ErrorFunc )
end

function OnVendorListUpdated( params )
	StopTimer()
	local items = avatar.GetVendorList()
	
	if items == nil or GetTableSize( items ) == 0 then
		ErrorFunc( "Vendors item list is null or empty" )
	else
		Log( "Vendor items:" )
		for index, item in items do
			local itemInfo = avatar.GetItemInfo( item.id )
			Log( "   name=" .. itemInfo.debugInstanceFileName )
			Log( "   price=" .. tostring( item.price ))
			Log( "   count=" .. tostring( item.quantity ))
			Log( "" )
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
	InitLoging( login )  
	
	common.RegisterEventHandler( OnAvatarCreated, "EVENT_AVATAR_CREATED" )
	common.RegisterEventHandler( OnVendorListUpdated, "EVENT_VENDOR_LIST_UPDATED" )
end

Init()


