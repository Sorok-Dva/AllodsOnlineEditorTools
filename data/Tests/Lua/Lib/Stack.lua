-- author: Ahmetov Ruslan, date: 3.07.2008

Global( "LIB_STACK", {} )

function StackPush( p )
	table.insert( LIB_STACK, p )
end

function StackPop()
	if StackSize() > 0 then
		local ret = LIB_STACK[StackSize()]
		table.remove( LIB_STACK )
	
		return ret
	else
		return nil
	end
end

function StackSize()
	local count = 0
	for i, v in LIB_STACK do
		count = count + 1
	end
	
	return count
end
