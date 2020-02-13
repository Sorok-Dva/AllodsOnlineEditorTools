Global( "DEFAULT_TEMPLATE", "AutoMage" )
Global( "BOT_LOGIN_NAME", "LuaBot" )

function BotLogin( errorFunc, template, isHadaganFaction )
	local botShards = {}
	if BOT_SHARD_NAME ~= nil then
		table.insert( botShards, BOT_SHARD_NAME )
	else
		botShards = SHARD_NAMES
	end
	
	local login
	if BOT_ACCOUNT_NAME ~= nil then
		local numb = 0
		if type( BOT_ACCOUNT_NAME ) == "string" then
			numb = string.find( BOT_ACCOUNT_NAME, "[0-9]+" )
			if numb == nil then
				errorFunc( "wrong BOT_ACCOUNT_NAME - " .. tostring( BOT_ACCOUNT_NAME ) )
				return
			end
			numb = string.sub( BOT_ACCOUNT_NAME, numb )
			numb = tonumber( numb )
			if type( numb ) ~= "number" then
				errorFunc( "wrong BOT_ACCOUNT_NAME - "..tostring( BOT_ACCOUNT_NAME ) )
				return
			end
		elseif type( BOT_ACCOUNT_NAME ) == "number" then
			numb = BOT_ACCOUNT_NAME
		else
			errorFunc( "wrong BOT_ACCOUNT_NAME - "..tostring( BOT_ACCOUNT_NAME ) )
			return 
		end
		
		local tmpl = template
		if tmpl == nil then
			tmpl = DEFAULT_TEMPLATE
		end
		if isHadaganFaction ~= nil then
			template = template .. "Empire"
		end
			
		BOT_LOGIN_NAME = BOT_LOGIN_NAME .. tostring( numb )
		login = { login = "luabot"..tostring( numb ),
					pass = "luabot"..tostring( numb ),
					avatar = BOT_LOGIN_NAME,
					create = tmpl,
					delete = "true",
					shards = botShards }
	else
		errorFunc( "BOT_ACCOUNT_NAME is null" )
		return
	end
	
	SendHttpMsg( BOT_LOGIN_NAME, "ImComingIn!" )
	InitLoging( login )
end

function ParseNotify( text )
	local result = {
		sender = nil,
		startNum = nil,
		endNum = nil,
		nextState = nil,
		params = nil
	}
	
	local strings = Split( FromWString( text ), ":" )
	if GetTableSize( strings ) >= 3 then
		result.sender = strings[1]
		result.nextState = strings[3]
		if GetTableSize( strings ) == 4 then
			result.params = Split( strings[4], "_" )
		end
		
		local nums = Split( strings[2], "_" )
		if GetTableSize( nums ) == 2 then
			result.startNum = tonumber( nums[1] )
			result.endNum = tonumber( nums[2] )
		else
			Log( "Wrong notify format: can't parse bot nums" )
			return nil
		end		
		
		return result
	else
		Log( "Wrong notify format: can't parse notify message" )
		return nil
	end	
end
