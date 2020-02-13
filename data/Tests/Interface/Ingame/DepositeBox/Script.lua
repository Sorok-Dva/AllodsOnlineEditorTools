--
-- DepositeBox
--

function Test01()
	LogInfo( "TEST: 01" )
	
--	depositeBox.OpenByItem( 0 )
	depositeBox.OpenByInteractor()
end

function Test02()
	LogInfo( "TEST: 02" )
	
	depositeBox.PutIn( 1, 3, nil )
end

function Test03()
	LogInfo( "TEST: 03" )
	
	depositeBox.TakeFrom( 3, nil, nil )
end

function Test04()
	LogInfo( "TEST: 04" )
	
	if not depositeBox.IsChangeTypeByItem( 2 ) then
		LogInfo( "TEST: 04 - wrong item type" )
	else
		depositeBox.ChangeTypeByItem( 2 )
	end
end

function Test05()
	LogInfo( "TEST: 05" )
	
	depositeBox.TakeFrom( 0, nil, nil )
	depositeBox.TakeFrom( 1, nil, nil )
	depositeBox.TakeFrom( 2, nil, nil )
	depositeBox.TakeFrom( 3, nil, nil )
	depositeBox.TakeFrom( 4, nil, nil )
end

-- "EVENT_DEPOSITE_BOX_TEST"

function On_EVENT_DEPOSITE_BOX_TEST( params )
	LogInfo( "EVENT_DEPOSITE_BOX_TEST: ", params.index )

	if params.index == 1 then
		Test01()
	elseif params.index == 2 then
		Test02()
	elseif params.index == 3 then
		Test03()
	elseif params.index == 4 then
		Test04()
	elseif params.index == 5 then
		Test05()
	end
end

-- "EVENT_DEPOSITE_BOX_CHANGED"

function On_EVENT_DEPOSITE_BOX_CHANGED( params )
	LogInfo( "" )
	LogInfo( "EVENT_DEPOSITE_BOX_CHANGED" )
	
	local count = depositeBox.GetSlotCount()
	for i = 0, count - 1 do
		local id = depositeBox.GetItemId( i )
		if id then
			local info = avatar.GetItemInfo( id )
			LogInfo( "name: ", FromWs( info.name ) )
		end
	end
	
	LogInfo( "" )
end

-- DepositeBox initialization 

function InitDepositeBox()
	LogInfo( "InitDepositeBox" )

	common.RegisterEventHandler( On_EVENT_DEPOSITE_BOX_TEST, "EVENT_DEPOSITE_BOX_TEST" )
	common.RegisterEventHandler( On_EVENT_DEPOSITE_BOX_CHANGED, "EVENT_DEPOSITE_BOX_CHANGED" )
end

InitDepositeBox()
