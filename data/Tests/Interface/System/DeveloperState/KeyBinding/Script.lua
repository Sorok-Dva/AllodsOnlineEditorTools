Global( "action", 0 )

function BindingTestBind( bind )
	if not bind then
		return
	end

	LogInfo( "   sysName: ", bind.sysName )
	LogInfo( "   name: ", debugCommon.FromWString( bind.name ) )
	for i = 0, GetTableSize( bind.keys ) - 1 do
		local key = bind.keys[i]
		LogInfo( "    key ", i, ": ", debugCommon.FromWString( key ) )
	end
end

function BindingTestSection( section )
	if not section then
		return
	end

	LogInfo( "  sysName: ", section.sysName )
	LogInfo( "  name: ", debugCommon.FromWString( section.name ) )
	for i = 0, GetTableSize( section.bindNames ) - 1 do
		local bindName = section.bindNames[i]
		LogInfo( "   bind ", i, ": ", bindName )

		local bind = binding.GetBind( section.sysName, bindName )
		BindingTestBind( bind )
	end
end

function BindingTestSections()
	LogInfo( "sections:" )

	local sections = binding.GetSections()
--	for i = 0, GetTableSize( sections ) - 1 do
	for i = 2, 2 do
		local sectionName = sections[i]
		LogInfo( " section ", i, ": ", sectionName )

		local section = binding.GetSection( sectionName )
		BindingTestSection( section )
	end
end

function BindingTestLogInfo()
	LogInfo( " IsWaitingRebind: ", binding.IsWaitingRebind() )
	LogInfo( " HasRebind: ", binding.HasRebind() )
	local conflict = binding.GetRebindConflict()
	LogInfo( " GetRebindConflict: isConflict = ", conflict.isConflict, ", sysSection = ", conflict.sysSection, ", sysBind = ", conflict.sysBind )
end

function Test01()
	LogInfo( "Test01()" )
	
	LogInfo( "Pre:" )
	BindingTestLogInfo()
	LogInfo( " IsWaitingRebind: ", binding.IsWaitingRebind() )
	LogInfo( " HasRebind: ", binding.HasRebind() )
	local conflict = binding.GetRebindConflict()
	LogInfo( " GetRebindConflict: isConflict = ", conflict.isConflict, ", sysSection = ", conflict.sysSection, ", sysBind = ", conflict.sysBind )

	binding.StartRebind( "mission_movement", "player_forward", 0 )

	LogInfo( "Post:" )
	BindingTestLogInfo()
end

function Test02()
	binding.StartRebind( "mission_movement", "player_forward", 1 )
--	BindingTestSections()
end

function Test03()
	LogInfo( "binding.Apply()" )

	binding.Apply()
--	binding.RemoveBind( "mission_movement", "player_forward", 0 )
--	BindingTestSections()
end

function Test04()
	binding.StartRebind( "mission_movement", "player_forward", 1 )
--	binding.RemoveBind( "mission_movement", "player_forward", 0 )
--	BindingTestSections()
end

function Test05()
	LogInfo( "binding.ResetToDefault()" )

	binding.ResetToDefault()
--	binding.StartRebind( "mission_movement", "player_forward", 1 )
--	BindingTestSections()
end

function BindingTestRebind()
	LogInfo( "BindingTestRebind" )
	
	action = action + 1
	if action == 1 then
		Test01()
	elseif action == 2 then
		Test02()
	elseif action == 3 then
		Test03()
	elseif action == 4 then
		Test04()
	elseif action == 5 then
		Test05()
	else
		action = 0
	end
end

function BindingTest()
	LogInfo( "" )
	LogInfo( "BindingTest" )
	LogInfo( "" )

	BindingTestRebind()
	BindingTestSections()
end

-- "EVENT_BINDING_CHANGED"

function OnEVENT_BINDING_CHANGED( params )
	LogInfo( "EVENT_BINDING_CHANGED" )

	LogInfo( "Pre:" )
	BindingTestLogInfo()
	
	if binding.HasRebind() then
		binding.ApplyRebind()
		BindingTestSections()
	end

	LogInfo( "Post:" )
	BindingTestLogInfo()
end

common.RegisterEventHandler( OnEVENT_BINDING_CHANGED, "EVENT_BINDING_CHANGED" )
