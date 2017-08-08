module("sync.Object", package.seeall)

Sync			=	require("sync")
Messages		=	require("sync.messages")
Functions	=	require("sync.functions")

Object = {}
Object.__index = Object
Object.__type = "Object"

Object.Remote = false

WeakValues = {__mode = "v"}

function Object:new(Class, Value)
	
	local self = setmetatable( {}, Object )
	
	self.Class = Class
	self.Server = Class:GetServer()
	self.Object = Value
	self.Address = Functions.AddressOf(Value)
	self.Value = {}
	self.Sent = {}
	self.Peers = setmetatable( {}, WeakValues )
	
	return self
	
end

function Object:GetObject()
	
	return self.Object
	
end

function Object:GetAddress()
	
	return self.Address
	
end

function Object:SetAddress(Address)
	
	self.Address = Address
	
end

function Object:FetchChanges()
	
	local Changes = {}
	local Time = love.timer.getTime()
	
	for Name, Attribute in pairs(self.Class:GetAttributes()) do
		
		if not self.Sent[Name] or Time - self.Sent[Name] >= Attribute:GetDelay() then
			
			local Value = Attribute:Get(self.Object)
			
			if self.Value[Name] ~= Value then
				
				Changes[Name]		= Value
				self.Value[Name]	= Value
				self.Sent[Name] = Time
				
			end
			
		end
		
	end
	
	return Changes
	
end

function Object:PushChanges()
	
	local Server = self.Server
	local Changes = self:FetchChanges()

	local Attributes = self.Class:GetAttributes()
	local Datagrams = {}
	
	local Address = self.Address
	local AddressLength = Sync.AddressLength
	local AddressMessage = ""
	
	for i = 1, AddressLength do
		
		local Byte = Address % 256
		
		Address = ( Address - Byte ) / 256
		AddressMessage = AddressMessage .. string.char(Byte)
		
	end

	for Index, Value in pairs(Changes) do
		
		local Header = Messages.toByte {
			Remote	= self.Remote,
			Push		= true,
		}
		
		local Attribute = Attributes[Index]
		local StringIndex
		local IndexType = type(Index)
		
		local Datagram = string.char(Header) .. AddressMessage
		
		if IndexType == "number" then
			
			StringIndex = string.char(Messages.Number) .. Functions.numberToString(Index)
			
		elseif IndexType == "string" then
			
			local Length = #Index
			local Byte1 = Length % 256
			local Byte2 = ( Length - Byte1 ) / 256
			
			StringIndex = string.char(Messages.String) .. string.char(Byte1) .. string.char(Byte2) .. Index
			
		end
		
		if StringIndex then
			
			local StringValue
			local ValueType = type(Value)
			
			if ValueType == "number" then
				
				StringValue = string.char(Messages.Number) .. Functions.numberToString(Value)
				
			elseif ValueType == "string" then
				
				local Length = #Value
				local Byte1 = Length % 256
				local Byte2 = ( Length - Byte1 ) / 256
				
				StringValue = string.char(Messages.String) .. string.char(Byte1) .. string.char(Byte2) .. Value
				
			elseif ValueType == "nil" then
				
				StringValue = string.char(Messages.Nil)
				
			else
				
				local NetworkObject = self.Server:GetLocalObject(Value)
				
				if NetworkObject then
					
					local Address = NetworkObject:GetAddress()
					local AddressLength = Sync.AddressLength
					local AddressMessage = ""
					
					for i = 1, AddressLength do
						
						local Byte = Address % 256
						
						Address = ( Address - Byte ) / 256
						AddressMessage = AddressMessage .. string.char(Byte)
						
					end
					
					StringValue = string.char(Messages.Object) .. AddressMessage
					
				end
				
			end
			
			if StringValue then
				
				local Packet = {}
				
				Packet[1] = Datagram .. StringIndex .. StringValue
				Packet[2] = Attribute:GetChannel()
				Packet[3] = Attribute:GetFlags()
				
				table.insert(Datagrams, Packet)
				
			end
			
		end
		
	end
	
	for Index, Peer in pairs(self.Peers) do
		
		for _, Datagram in pairs(Datagrams) do
			
			Peer:Send(unpack(Datagram))
			
		end
		
	end
	
end

function Object:Share(Peer)
	
	table.insert(self.Peers, Peer)
	
	self:Send(Peer)
	
end

function Object:Send(Peer)
	
	local Header = Messages.toByte {
		Remote = self.Remote,
		Create = true,
	}
	
	local Address = self.Address
	local AddressLength = Sync.AddressLength
	local AddressMessage = ""
	
	for i = 1, AddressLength do
		
		local Byte = Address % 256
		
		Address = ( Address - Byte ) / 256
		AddressMessage = AddressMessage .. string.char(Byte)
		
	end
	
	local Name = self.Class:GetName()
	local Datagram = string.char(Header) .. string.char(#Name) .. Name .. AddressMessage
	
	for Index, Attribute in pairs(self.Class:GetAttributes()) do
		
		local Value = Attribute:Get(self.Object)
		
		local StringIndex
		local IndexType = type(Index)
		
		if IndexType == "number" then
			
			StringIndex = string.char(Messages.Number) .. Functions.numberToString(Index)
			
		elseif IndexType == "string" then
			
			local Length = #Index
			local Byte1 = Length % 256
			local Byte2 = ( Length - Byte1 ) / 256
			
			StringIndex = string.char(Messages.String) .. string.char(Byte1) .. string.char(Byte2) .. Index
			
		end
		
		if StringIndex then
			
			local StringValue
			local ValueType = type(Value)
			
			if ValueType == "number" then
				
				StringValue = string.char(Messages.Number) .. Functions.numberToString(Value)
				
			elseif ValueType == "string" then
				
				local Length = #Value
				local Byte1 = Length % 256
				local Byte2 = ( Length - Byte1 ) / 256
				
				StringValue = string.char(Messages.String) .. string.char(Byte1) .. string.char(Byte2) .. Value
				
			elseif ValueType == "nil" then
				
				StringValue = string.char(Messages.Nil)
				
			else
				
				local NetworkObject = self:GetLocalObject(Value)
				
				if NetworkObject then
					
					local Address = NetworkObject:GetAddress()
					local AddressLength = Sync.AddressLength
					local AddressMessage = ""
					
					for i = 1, AddressLength do
						
						local Byte = Address % 256
						
						Address = ( Address - Byte ) / 256
						AddressMessage = AddressMessage .. string.char(Byte)
						
					end
					
					StringValue = string.char(Messages.Object) .. AddressMessage
					
				end
				
			end
			
			if StringValue then
				
				Datagram = Datagram .. StringIndex .. StringValue
				
			end
			
		end
		
	end
	
	Peer:Send(Datagram, self.Class:GetCreateChannel(), self.Class:GetCreateFlags())
	
end

function Object:SetRemote(Remote)
	
	self.Remote = Remote
	
end

function Object:GetRemote()
	
	return self.Remote
	
end

function Object:SetValue(Index, Value)
	
	local Attributes = self.Class:GetAttributes()
	local Attribute = Attributes[Index]
	
	if Attribute then
		
		Attribute:Set(self.Object, Value)
		self.Value[Index] = Value
		
	end
	
end

return Object