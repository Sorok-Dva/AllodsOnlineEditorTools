-- ScriptMetaDebug2.lua
-- 21:16 13.07.2009
--------------------------------------------------------------------------------
do
	Global( "trace", { tostring = {} } )
	local hash = {}
	local declared = {}
	local preprocess = {}
	local process = {}
	local argtostring
	local wrapfunction
	local argtotrace
	local callstack = {}
	local excluded = {}
	local included = {}
	local filter
	local _tostring = tostring
	local _mt = {
		__newindex = function( tab, key, val )
			trace( "new: ", hash.name( tab, key ), " = ", ( filter( key, val ) or trace.tostring( val ) ) )
			process( tab, key, val )
		end
	}
	local _globalmt = {
		__newindex = function( tab, key, val )
			if type( val ) ~= "function" and not declared[ key ] then
				common.LogError( "common", "Attempt to write to undeclared global variable: " .. key )
			end
			
			trace( "global: ", hash.name( tab, key ), " = ", ( filter( key, val ) or trace.tostring( val ) ) )
			process( tab, key, val )
		end,
		__index = function( tab, key, val )
			if not declared[ key ] then
				common.LogError( "common", "Attempt to read undeclared global variable: " .. key )
			end
			
			return nil
		end
	}
	------------------------------------------------------------------------------
	tabletolog = function( val )
		return trace.tostring( val, false, false )
	end
	------------------------------------------------------------------------------
	setmetatable( hash, { __mode = "k" } )
	setmetatable( excluded, { __mode = "k" } )
	setmetatable( included, { __mode = "k" } )
	------------------------------------------------------------------------------
	local related = function( self, val )
		local info = hash:get( val )
		local tabinfo = hash:get( info.tab )
		local keyinfo = hash:get( info.key )

		return info ~= nil
			and ( self[ val ]
			or self[ info.tab ]
			or self[ info.key ]
			or info.name and self[ info.name ]
			or tabinfo and self[ tabinfo.key ]
			or keyinfo and self[ keyinfo.key ] )
	end
	------------------------------------------------------------------------------
	setmetatable( excluded, { __call = related } )
	setmetatable( included, { __call = related } )
	------------------------------------------------------------------------------
	trace.exclude = function( ... )
		for k = 1, arg.n do
			local val = arg[ k ]
			if included[ val ] then
				included[ val ] = nil
				
			else
				excluded[ val ] = true
			end
		end
	end
	------------------------------------------------------------------------------
	trace.include = function( ... )
		for k = 1, arg.n do
			local val = arg[ k ]
			if excluded[ val ] then
				excluded[ val ] = nil
				
			else
				included[ val ] = true
			end
		end
	end
	------------------------------------------------------------------------------
	filter = function( key, val )
	end
	------------------------------------------------------------------------------
	trace.filter = function( func )
		trace.exclude( func )
		
		filter = function( key, val )
			local out = func( key, val )
			if out and type( out ) ~= "string" then
				LogWarning( "Invalid filter structure, only \"string\" type return permitted" )
				out = nil
			end
			return out
		end
	end
	------------------------------------------------------------------------------
	trace.callstack = function( flat )
		local out = {}
		flat = flat ~= false
		
		for k = 1, table.getn( callstack ) do
			local prefix = flat and " " or ( "\n" .. string.rep( "  ", k ) )
			local func = callstack[ k ]
			
			table.insert( out, prefix .. ">> " .. hash:getname( func ) )
		end
		
		trace( "callstack:", table.concat( out ) )
	end
	------------------------------------------------------------------------------
	callstack.add = function( self, func )
		table.insert( self, func )
	end
	------------------------------------------------------------------------------
	callstack.cut = function( self )
		table.remove( self )
	end
	------------------------------------------------------------------------------
	callstack.traceable = function( self )
		local traceable = true
		
		for k = 1, table.getn( self ) do
			local v = self[ k ]
			
			if traceable then
				if excluded( v ) then
					traceable = included( v )
				end
				
			else
				if included( v ) then
					traceable = not excluded( v )
				end
			end
		end
		
		return traceable
	end
	------------------------------------------------------------------------------
	trace.__call = function( self, ... )
		local depth = table.getn( callstack )
		local func = callstack[ depth ]
		
		if callstack:traceable() then
			if func then
				local name = hash:getname( func )
				local prefix = string.rep( "  ", depth - 1 )
				print( prefix, " - ", name, " - ", argtotrace( arg, false ) )
				
			else
				print( argtotrace( arg, false ) )
			end
		end
	end
	------------------------------------------------------------------------------
	argtotrace = function( arg, brief )
		local out = {}
		for key = 1, arg.n or table.maxn( arg ) or 0 do
			local val = arg[ key ]
			table.insert( out, trace.tostring( val, brief ) )
		end
		
		return table.concat( out )
	end
	------------------------------------------------------------------------------
	argtostring = function( arg, parent, brief )
		local out = {}
		for key = 1, arg.n or table.maxn( arg ) or 0 do
			local val = arg[ key ]
			val = val ~= parent and trace.tostring( val, brief ) or "self"
			table.insert( out, " " .. val )
			table.insert( out, "," )
		end
		
		if table.getn( out ) ~= 0 then
			out[ table.getn( out ) ] = " "
		end
		
		return table.concat( out )
	end
	------------------------------------------------------------------------------
	wrapfunction = function( tab, key, val )
		local func
	
		func = function( ... )
			local name = hash:getname( func )
			local depth = table.getn( callstack )
			local prefix = string.rep( "  ", depth )
			
			callstack:add( func )
			local traceable = callstack:traceable()
			
			if traceable then
				print( prefix .. ">> ", name, "(", argtostring( arg, tab, true ), ")" )
			end
			
			local out = { val( unpack( arg ) ) }
			
			callstack:cut()
			
			if traceable then
				print( prefix .. "<< ", name, ( table.isempty( out ) and "" or " returns" ) .. argtostring( out, tab, false ) )
				if depth == 0 then print( "   --- ---" ) end
			end
			
			return unpack( out )
		end

		return func
	end
	------------------------------------------------------------------------------
	-- HASH HANDLER
	------------------------------------------------------------------------------
	hash.name = function( tab, key )
		if key == nil then
			return
		end
		
		local path = tab and hash:got( tab ) and hash:getname( tab ) or nil
		local name = key
		
		if type( name ) == "string" then
			if path then
				path = path .. "."
			end
			
		else
			name = "[ " .. tostring( key ) .. " ]"
		end
		
		if path then
			name = path .. name
		end
		
		return name
	end
	------------------------------------------------------------------------------
	hash.get = function( self, val )
		return self[ val ]
	end
	------------------------------------------------------------------------------
	hash.getname = function( self, val )
		return self[ val ].name
	end
	------------------------------------------------------------------------------
	hash.add = function( self, tab, key, val, keyval )
		keyval = keyval or val
		self[ keyval ] = { tab = tab, key = key, val = val }
		self[ keyval ].name = self.name( tab, key )
	end
	------------------------------------------------------------------------------
	hash.got = function( self, val )
		return self[ val ] ~= nil and type( self[ val ] ) == "table"
	end
	------------------------------------------------------------------------------
	-- PREPROCESS PROCEDURE
	------------------------------------------------------------------------------
	preprocess.__call = function( self, tab, key, val )
		if val then
			self[ type( val ) ]( tab, key, val )
		end
	end
	------------------------------------------------------------------------------
	preprocess[ "table" ] = function( tab, key, val )
		if not hash:got( val ) then
			hash:add( tab, key, val )
			
			for k, v in val do
				preprocess( val, k, v )
			end
		end
	end
	------------------------------------------------------------------------------
	preprocess[ "userdata" ] = function( tab, key, val )
		if not hash:got( val ) then
			hash:add( tab, key, val )
		end
	end
	------------------------------------------------------------------------------
	preprocess[ "number" ] = function( tab, key, val )
	end
	------------------------------------------------------------------------------
	preprocess[ "function" ] = preprocess[ "userdata" ]
	preprocess[ "string" ] = preprocess[ "number" ]
	preprocess[ "boolean" ] = preprocess[ "number" ]
	------------------------------------------------------------------------------
	setmetatable( preprocess, preprocess )
	------------------------------------------------------------------------------
	-- PROCESS PROCEDURE
	------------------------------------------------------------------------------
	process.__call = function( self, tab, key, val, rewrap )
		if val ~= nil then
			rewrap = rewrap ~= false
			self[ type( val ) ]( tab, key, val, rewrap )
		end
		
		if tab == _G then
			declared[ key ] = true
		end
	end
	------------------------------------------------------------------------------
	process[ "table" ] = function( tab, key, val, rewrap )
		if not hash:got( val ) then
			hash:add( tab, key, val )
			
			for k, v in val do
				process( val, k, v, rewrap )
			end
			
			if tab then
				addmetatable( val, _mt )
				rawset( tab, key, val )
			end
		
		elseif rewrap
		and ( hash[ val ].tab ~= tab or hash[ val ].key ~= key ) then
			hash:add( tab, key, val )
			
			if tab then
				rawset( tab, key, val )
			end
		end
	end
	------------------------------------------------------------------------------
	process[ "userdata" ] = function( tab, key, val, rewrap )
		if not hash:got( val ) or rewrap
		and ( hash[ val ].tab ~= tab or hash[ val ].key ~= key ) then
			hash:add( tab, key, val )
			if tab then rawset( tab, key, val ) end
		end
	end
	------------------------------------------------------------------------------
	process[ "function" ] = function( tab, key, val, rewrap )
		local new = val
		
		if not hash:got( val ) then
			new = wrapfunction( tab, key, val )
			hash:add( tab, key, val, new )
		
		elseif rewrap
		and ( hash[ val ].tab ~= tab or hash[ val ].key ~= key ) then
			local original = hash[ val ].val
			new = wrapfunction( tab, key, original )
			hash:add( tab, key, original, new )
		end
		
		if tab then rawset( tab, key, new ) end
	end
	------------------------------------------------------------------------------
	process[ "number" ] = function( tab, key, val )
		if tab then rawset( tab, key, val ) end
	end
	------------------------------------------------------------------------------
	process[ "string" ] = process[ "number" ]
	process[ "boolean" ] = process[ "number" ]
	------------------------------------------------------------------------------
	setmetatable( process, process )
	------------------------------------------------------------------------------
	-- TOSTRING
	------------------------------------------------------------------------------
	tostring = function( val )
		local name = hash:got( val ) and hash:getname( val ) or nil
		return name and ( type( val ) .. ": " .. name ) or _tostring( val )
	end
	------------------------------------------------------------------------------
	trace.tostring.__call = function( self, val, brief, flat )
		if val ~= nil then
			flat = flat ~= false
			brief = brief ~= false
			return brief and hash:got( val ) and hash:getname( val ) or self[ type( val ) ]( val, brief, flat )
		end
		return "nil"
	end
	------------------------------------------------------------------------------
	do
		local done = {}
		local depth = 0
	------------------------------------------------------------------------------
		trace.tostring[ "table" ] = function( val, brief, flat )
			local out = {}
	
			if not done[ val ] then
				done[ val ] = "self"
			end
		
			depth = depth + 1
			local prefix = flat and " " or ( "\n" .. string.rep( "  ", depth ) )
		
			for k, v in val do
				local key = type( k ) == "string" and k or ( "[ " .. tostring( k ) .. " ]" )
			
				if not done[ v ] then
					if type( v ) == "table" then
						local path = done[ val ]
						done[ v ] = path .. ( type( k ) == "string" and ( "." .. key ) or key )
					end
					
					table.insert( out, prefix .. key .. " = " .. ( filter( k, v ) or trace.tostring( v, brief, flat ) ) )
			
				else
					table.insert( out, prefix .. key .. " = " .. ( hash:got( v ) and hash:getname( v ) or done[ v ] ) )
				end
			
				table.insert( out, "," )
			end
		
			depth = depth - 1
			prefix = flat and " " or ( "\n" .. string.rep( "  ", depth ) )
		
			if depth == 0 then
				done = {}
			end
		
			if table.getsize( out ) == 0 then
				table.insert( out, "{}" )
			else
				table.remove( out )
				table.insert( out, 1, "{" )
				table.insert( out, prefix .. "}" )
			end
		
			return table.concat( out )
		end
	end
	------------------------------------------------------------------------------
	trace.tostring[ "number" ] = function( val, brief )
		return tostring( math.round( val, 3 ) )
	end
	------------------------------------------------------------------------------
	trace.tostring[ "function" ] = tostring
	trace.tostring[ "userdata" ] = function( val )
		if common.IsWString( val ) then
			return "WString: \'" .. debugCommon.FromWString( val ) .. "\'"
			
		elseif common.IsValuedText( val ) then
			return "ValuedText: " .. string.sub( tostring( val ) , -8 )
		
		else
			return tostring( val )
		end
	end
	trace.tostring[ "boolean" ] = tostring
	trace.tostring[ "string" ] = tostring
	------------------------------------------------------------------------------
	setmetatable( trace.tostring, trace.tostring )
	------------------------------------------------------------------------------
	-- DEBUG INITIATOR
	------------------------------------------------------------------------------
	trace.enable = function()
		preprocess( nil, nil, _G )
		setmetatable( _G, _globalmt )
		
		Global = function( key, val )
			if declared[ key ] then
				common.LogWarning( "common", "Global variable " .. key .. " already declared" )
			end
		
			trace( "global: ", hash.name( _G, key ), " = ", trace.tostring( val ) )
			process( _G, key, val )
		end
	end
	------------------------------------------------------------------------------
	setmetatable( trace, trace )
	------------------------------------------------------------------------------
end
--------------------------------------------------------------------------------