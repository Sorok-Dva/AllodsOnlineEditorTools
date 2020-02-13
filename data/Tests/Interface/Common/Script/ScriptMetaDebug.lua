-- ScriptMetaDebug.lua
-- 11:12 18.05.2009
--------------------------------------------------------------------------------
rawset( math, "round", function( number, limit )
	local multiplier = 10 ^ ( limit or 0 )
	return math.floor( number * multiplier + 0.5 ) / multiplier
end )
--------------------------------------------------------------------------------
rawset( math, "clamp", function( number, min, max )
	if min and max then
		min = math.min( min, max )
		max = math.max( min, max )
	end
	
	return ( min and number < min and min ) or ( max and number < max and max ) or number
end )
--------------------------------------------------------------------------------
rawset( math, "sign", function( number )
	return number < 0 and -1 or 1
end )
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
Global( "metadbg", 
	{
		hash = { [ _G ] = "_G" },
		wrap = {},
		traceindent = -1,
		tableindent = 0,
		indentchar = "  ",
		tracename = false,
		filter = "TableStringFilter",
		verbose = true,
		declared = {}
	}
)
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
totracestringraw = function( arg )
	local chain = {}
	
	for id = 1, arg.n do
		chain[ id ] = metadbg.getfromhash( arg[ id ] )
	end
	
	return table.concat( chain )
end
--------------------------------------------------------------------------------
traceraw = function( ... )
	common.LogInfo( common.GetAddonName(), totracestringraw( arg ) )
end
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
trace = function( ... )
	if metadbg.verbose then 
		common.LogInfo( common.GetAddonName(), metadbg.totracestring( arg, " - ", " - " ) )
	end
end
--------------------------------------------------------------------------------
tracein = function( ... )
	if metadbg.verbose then 
		common.LogInfo( common.GetAddonName(), metadbg.totracestring( arg, ">> " ) )
	end
end
--------------------------------------------------------------------------------
traceout = function( ... )
	if metadbg.verbose then 
		common.LogInfo( common.GetAddonName(), metadbg.totracestring( arg, "<< " ) )

		if metadbg.traceindent == 0 then
			common.LogInfo( common.GetAddonName(), "   --- ---" )
		end
	end
end
--------------------------------------------------------------------------------
tabletolog = function( tab )
	if not tab then return "nil" end
	local result = {}

	metadbg.tableindent = metadbg.tableindent + 1
	local indent = string.rep( metadbg.indentchar, metadbg.tableindent )
	
	for id, val in pairs( tab ) do
		local v = type( val ) == "string" and "\"" .. val .. "\"" or val
		v = val == tab and "self" or v
		
		if rawget( _G, metadbg.filter ) then
			v = _G[ metadbg.filter ]( id, v )
		end
		
		table.insert( result, indent .. metadbg.indextostring( id ) .. " = " .. metadbg.valuetostring( v, tabletolog ) )
		table.insert( result, ",\n" )
	end

	metadbg.tableindent = metadbg.tableindent - 1
	indent = string.rep( metadbg.indentchar, metadbg.tableindent )
	
	if table.getn( result ) == 0 then
		table.insert( result, "{}" )
		
	else
		table.remove( result )
		table.insert( result, 1, "{\n" )
		table.insert( result, "\n" .. indent .. "}" )
	end
		
	return table.concat( result )
end
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
metadbg.indextostring = function( index )
	if type( index ) == "string" then
		return index
	else
		return "[ " .. metadbg.getfromhash( index ) .. " ]"
	end
end
--------------------------------------------------------------------------------
metadbg.valuetostring = function( value, tablehandler )
	local valuetype = type( value )
	
	if valuetype == "string" then
		return value
		
	elseif valuetype == "number" then
		return tostring( math.round( value, 3 ) )
		
	elseif valuetype == "table" then
		return metadbg.hash[ value ] or tablehandler( value )
	
	elseif common.IsWString( value ) then
		return "\'" .. debugCommon.FromWString( value ) .. "\'"

	elseif valuetype == "function"
	or valuetype == "userdata" then
		return metadbg.getfromhash( value )

	else
		return tostring( value )
	end
end
--------------------------------------------------------------------------------
metadbg.tabletostring = function( tab )
	if not tab then return "nil" end
	local result = {}
		
	for id, val in pairs( tab ) do
		local v = type( val ) == "string" and "\"" .. val .. "\"" or val
		v = val == tab and "self" or v
		
		if rawget( _G, metadbg.filter ) then
			v = _G[ metadbg.filter ]( id, v )
		end
		
		table.insert( result, metadbg.indextostring( id ) .. " = " .. metadbg.valuetostring( v, metadbg.tabletostring ) )
		table.insert( result, ", " )
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
metadbg.totracestring = function( arg, prefix, suffix )
	local chain = {}
	
	for id = 1, arg.n do
		chain[ id ] = metadbg.valuetostring( arg[ id ], metadbg.tabletostring )
	end
	
	if metadbg.tracename then
		if suffix then
			table.insert( chain, 1, suffix )
		end
		
		table.insert( chain, 1, metadbg.tracename )
		
		if prefix then
			table.insert( chain, 1, prefix )
		end
	end
	
	if metadbg.traceindent > 0 then
		table.insert( chain, 1, string.rep( metadbg.indentchar, metadbg.traceindent ) )
	end
	
	return table.concat( chain )
end
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
metadbg.setuptracein = function( arg, parent )
	local input = {}
	for id = 1, table.getn( arg ) do
		local val = arg[ id ]
		
		if val ~= parent then
			local v = type( val ) == "string" and "\"" .. val .. "\"" or val
			table.insert( input, v )
			
		else
			table.insert( input, "self" )
		end
		
		table.insert( input, ", " )
	end
	
	if table.getn( arg ) == 0 then
		table.insert( input, 1, "()" )
		
	else
		table.insert( input, 1, "( " )
		table.remove( input )
		table.insert( input, " )" )
	end
	
	return unpack( input )
end
--------------------------------------------------------------------------------
metadbg.setuptraceout = function( out )
	local output = {}
	for id = 1, table.getn( out ) do
		local v = out[ id ]
		v = type( v ) == "string" and "\"" .. v .. "\"" or v
		table.insert( output, v )
		table.insert( output, ", " )
	end
	
	if table.getn( out ) ~= 0 then
		table.remove( output )
		table.insert( output, 1, " returns " )
	end

	return unpack( output )
end
--------------------------------------------------------------------------------
metadbg.setuptracemeta = function( tab, id, val, prefix )
	local tabname = tab ~= _G and metadbg.hash[ tab ] or nil
	local idname = metadbg.indextostring( id )

	local v = type( val ) == "string" and "\"" .. val .. "\"" or val
	return prefix or "", tabname or "", tabname and type( id ) == "string" and "." or "", idname, " = ", v
end
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
metadbg.addtohash = function( tab, id, val )
	if not metadbg.hash[ val ] and metadbg.hash[ tab ] then
		--traceraw( "  Hash adding - ", tab, ( type( id ) == "string" and "." or "" ), metadbg.indextostring( id ), ", val = ", val )
		local prefix = tab ~= _G and metadbg.hash[ tab ] or ""

		if tab ~= _G and type( id ) == "string" then
			prefix = prefix .. "."
		end
		--traceraw( "  Hash adding - prefix = ", prefix )
		
		metadbg.hash[ val ] = prefix .. metadbg.indextostring( id )
	end
	--traceraw( "  Hash adding - metadbg.hash[ ", tostring( val ), " ] = ", metadbg.hash[ val ] )
end
--------------------------------------------------------------------------------
metadbg.getfromhash = function( val )
	return metadbg.hash[ val ] or tostring( val )
end
--------------------------------------------------------------------------------
metadbg.wrapfunction = function( tab, id, val )
	--traceraw( "  Function wrapping - ", tab, ( type( id ) == "string" and "." or "" ), metadbg.indextostring( id ), ", val = ", val )
	local func
	func = function( ... )
		metadbg.reprocessarg( arg )
	
		local backname = metadbg.tracename
		metadbg.tracename = metadbg.getfromhash( func )
		metadbg.traceindent = metadbg.traceindent + 1
		
		tracein( metadbg.setuptracein( arg, tab ) )

		local out = { val( unpack( arg ) ) }

		traceout( metadbg.setuptraceout( out ) )
		
		metadbg.traceindent = metadbg.traceindent - 1
		metadbg.tracename = backname
	
		return unpack( out )
	end
	
	return func
end
--------------------------------------------------------------------------------
metadbg.reprocess = function( tab, id, val )
	--traceraw( metadbg.setuptracemeta( tab, id, val, " - Reprocessing: " ) )
	local valtype = type( val )
	
	if valtype == "function"
	and id ~= metadbg.filter then
		if not metadbg.wrap[ val ] then
			local source = val
			local v = metadbg.wrapfunction( tab, id, source )
			metadbg.wrap[ v ], val = { source = source, parent = tab }, v
	
		else
			local parent = metadbg.wrap[ val ].parent
	
			if metadbg.hash[ tab ] and tab ~= parent then
				local source = metadbg.wrap[ val ].source
				local v = metadbg.wrapfunction( tab, id, source )
				metadbg.wrap[ v ], val = { source = source, parent = tab }, v
			end
		end
	end
	
	if valtype == "table"
	or valtype == "userdata"
	or valtype == "function" then
		metadbg.addtohash( tab, id, val )
	end
		
	if val ~= tab
	and valtype == "table" then
		
		if not getmetatable( val ) then
			--trace( metadbg.setuptracemeta( tab, id, val, " - Metatable setting: " ) )
			setmetatable( val, metadbg.mttable )
		end
		
		for i, v in val do
			metadbg.reprocess( val, i, v )
		end
	end

	rawset( tab, id, val )
end
--------------------------------------------------------------------------------
metadbg.reprocessarg = function( arg )
	--trace( "Reprocessing arguments ... arg = ", metadbg.tabletostring( arg ) )
	for id = 1, table.getn( arg ) do
		--trace( "Reprocessing arguments ... arg[ ", id, " ] = ", tostring( arg[ id ] ) )
		metadbg.reprocess( arg, id, arg[ id ] )
	end
end
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
metadbg._newindextable = function( tab, id, val )
	trace( metadbg.setuptracemeta( tab, id, val, "new: " ) )
	metadbg.reprocess( tab, id, val )
end
--------------------------------------------------------------------------------
metadbg._newindexglobal = function( tab, id, val )
	if type( val ) ~= "function" and not metadbg.declared[ id ] then
		common.LogError( "common", "Attempt to write to undeclared global variable: " .. id )
	end
	
	metadbg.reprocess( _G, id, val )
end
--------------------------------------------------------------------------------
metadbg._indexglobal = function( tab, id, val )
	if not metadbg.declared[ id ] then
		common.LogError( "common", "Attempt to read undeclared global variable: " .. id )
	end
	
	return nil
end
--------------------------------------------------------------------------------
function Global( id, val )
	if id == "__debug" or id == "o_O" then metadbg.verbose = val end

	if metadbg.declared[ id ] then
		common.LogWarning( "common", "Global variable " .. id .. " already declared" )
		
	else
		if metadbg.verbose then trace( metadbg.setuptracemeta( _G, id, val, "new: " ) ) end
		metadbg.declared[ id ] = true
	end
	
	metadbg.reprocess( _G, id, val )
end
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
metadbg.init = function( self )
	self.mttable = {
		__newindex = metadbg._newindextable
	}
	
	self.mtglobal = {
		__metatable = "Back off!",
		__newindex = metadbg._newindexglobal,
		__index = metadbg._indexglobal
	}
	
	local mtweak = { __mode = "k" }

	setmetatable( self.hash, mtweak )
	setmetatable( self.wrap, mtweak )
	
	setmetatable( _G, self.mtglobal )
end
--------------------------------------------------------------------------------
metadbg:init()
--------------------------------------------------------------------------------