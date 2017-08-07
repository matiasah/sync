module("sync.messages", package.seeall)

Messages = {}

Messages.Remote	= 1
Messages.Create	= 2
Messages.Remove	= 4
Messages.Push		= 8

Messages.Object	= 1
Messages.Number	= 2
Messages.String	= 3
Messages.Nil		= 4

function Messages.toTable(Byte)
	
	local Table = {}
	
	if Byte >= 8 then
		
		Byte = Byte - 8
		Table.Push = true
		
	end
	
	if Byte >= 4 then
		
		Byte = Byte - 4
		Table.Remove = true
		
	end
	
	if Byte >= 2 then
		
		Byte = Byte - 2
		Table.Create = true
		
	end
	
	if Byte >= 1 then
		
		Byte = Byte - 1
		Table.Remote = true
		
	end
	
	return Table
	
end

function Messages.toByte(Table)
	
	local Byte = 0
	
	if Table.Remote then
		
		Byte = Byte + 1
		
	end
	
	if Table.Create then
		
		Byte = Byte + 2
		
	end
	
	if Table.Remove then
		
		Byte = Byte + 4
		
	end
	
	if Table.Push then
		
		Byte = Byte + 8
		
	end
	
	return Byte
	
end

return Messages