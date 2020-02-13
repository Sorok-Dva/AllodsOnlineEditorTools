-- ScriptAdvancedLogInfo.lua
-- Cross add-on utility functions
-- 16:45 11.02.2009
-- Requires: ScriptCommonUtility.lua
--------------------------------------------------------------------------------
Global( "logIndent", -1 )
Global( "tableIndent", 0 )
--------------------------------------------------------------------------------
function RdTo( number, limit )
	local multiplier = 10 ^ ( limit or 3 )
	return math.floor( number * multiplier + 0.5 ) / multiplier
end
--------------------------------------------------------------------------------
function TableStringFilter( id, value )
	if type( value ) == "number" then	
		return RdTo( value )
	end
	
	return value
end
--------------------------------------------------------------------------------
function TableToString( params )
	if type( params ) ~= "table" then
		return tostring( params )
	end
	
	local result = {}
		
	for id, value in params do
		local val = nil
		
		if type( value ) == "string" then
			val = "\"" .. value .. "\""
	
		elseif IsWs( value ) then
			val = "\'" .. FromWs( value ) .. "\'"
			
		else
			val = TableStringFilter( id, value )
		end
		
		if val ~= nil then
			local index = tostring( id )
		
			if type( id ) ~= "string" then
				index = "[ " .. index .. " ]"
			end
			
			table.insert( result, index .. " = " .. TableToString( val ) )
			table.insert( result, ", " )
		end
	end
		
	if table.getn( result ) == 0 then
		table.insert( result, "{}" )
	else
		table.remove( result )
		table.insert( result, 1, "{ " )
		table.insert( result, " }" )
	end

	return table.concat( result )
end
--------------------------------------------------------------------------------
function TableToLog( params )
	if type( params ) ~= "table" then
		return tostring( params )
	end
	tableIndent = tableIndent + 1
	local indent = string.rep( "\t", tableIndent )
	
	local result = {}
	
	for id, value in params do
		local val = nil
		
		if type( value ) == "string" then
			val = "\"" .. value .. "\""
	
		elseif IsWs( value ) then
			val = "\'" .. FromWs( value ) .. "\'"
			
		else
			val = TableStringFilter( id, value )
		end
		
		if val ~= nil then
			local index = tostring( id )
		
			if type( id ) ~= "string" then
				index = "[ " .. index .. " ]"
			end
			
			table.insert( result, "\n" .. indent .. index .. " = " .. TableToLog( val ) )
			table.insert( result, ", " )
		end
	end
	
	tableIndent = tableIndent - 1
	indent = string.rep( "\t", tableIndent )
	
	if table.getn( result ) == 0 then
		table.insert( result, "{}" )
	else
		table.remove( result )
		table.insert( result, 1, "{ " )
		table.insert( result, "\n" .. indent .. " }" )
	end
	
	return table.concat( result )
end
--------------------------------------------------------------------------------
function LogInfoIn( ... )
	logIndent = logIndent + 1
	table.insert( arg, 1, string.rep( "\t", Clamp( logIndent, 0 ) ) .. ">>" )
	common.LogInfo( common.GetAddonName(), GetMethodArgumentsString( arg ) )
end
--------------------------------------------------------------------------------
function LogInfoAt( ... )
	table.insert( arg, 1, string.rep( "\t", Clamp( logIndent, 0 ) ) .. " -" )
	common.LogInfo( common.GetAddonName(), GetMethodArgumentsString( arg ) )
end
--------------------------------------------------------------------------------
function LogInfoOut( ... )
	table.insert( arg, 1, string.rep( "\t", Clamp( logIndent, 0 ) ) .. "<<" )
	logIndent = Clamp( logIndent - 1, -1 )
	common.LogInfo( common.GetAddonName(), GetMethodArgumentsString( arg ) )
	if logIndent == -1 then
		LogInfo( "       ---  ---" )
	end
end
--------------------------------------------------------------------------------
function LogInfoBlink( ... )
	table.insert( arg, 1, string.rep( "\t", logIndent + 1 ) .. "<>" )
	common.LogInfo( common.GetAddonName(), GetMethodArgumentsString( arg ) )
end
--------------------------------------------------------------------------------
