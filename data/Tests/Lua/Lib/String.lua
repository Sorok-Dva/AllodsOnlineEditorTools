
function StringIsBlank( s )
	return s == nil or s == ""
end

function FromWString( text )
	return debugCommon.FromWString( text )
end

function ToWString( text )
	return debugCommon.ToWString( text )
end

function Split( text, char )
	if text == nil or char == nil then
		return nil
	end

	local indexes = SplitFindIndexes( text, char, 1 )
	
	local result = {}
	local oldIndex = 0
	for i, index in indexes do
		table.insert( result, string.sub( text, oldIndex+1, index-1 ) )
		oldIndex = index
	end
	table.insert( result, string.sub( text, oldIndex+1 ) )
	
	return result
end

function SplitFindIndexes( text, char, start )
	cLog( "")
	cLog( "split text: " .. text .. " from " .. tostring(start))
	
	local result = {}
	if start == nil then
		start = 1
	end
	
	local index = string.find( text, char, start, true )
	cLog( "index=" .. tostring( index ) )
	if index ~= nil then
		table.insert( result, index )
		JoinTables( result, SplitFindIndexes( text, char, index+1 ) )
	end
	
	return result
end

-- true если string1 начинается с string2
function StartsWith( string1, string2 )
	return string.sub( string1, 1, string.len( string2 ) ) == string2
end
