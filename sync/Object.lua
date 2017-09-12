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
	self.Object = setmetatable( {Value}, WeakValues )
	self.Address = Functions.AddressOf(Value)
	self.Value = {}
	self.Sent = {}
	self.Peers = setmetatable( {}, WeakValues )
	
	self.Proxy = newproxy(true)
	
	local Metatable = getmetatable(self.Proxy)
	
	Metatable.__index = self
	Metatable.__newindex = self
	Metatable.__gc = Object.__gc
	
	return self.Proxy
	
end

function Object:__gc()
	
	if not self.Remote then
		
		local Address = self.Address
		local AddressLength = Sync.AddressLength
		local AddressMessage = ""
		
		for i = 1, AddressLength do
			
			local Byte = Address % 256
			
			Address = ( Address - Byte ) / 256
			AddressMessage = AddressMessage .. string.char(Byte)
			
		end
		
		local Header = Messages.toByte {
			Remote	= self.Remote,
			Remove	= true,
		}
		
		for Index, Peer in pairs(self.Peers) do
			
			Peer:Send( string.char(Header) .. AddressMessage )
			
		end
		
	end
	
end

function Object:GetObject()
	
	return self.Object[1]
	
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
		
		local Sent = self.Sent[Name]
		
		if not Sent or ( Time - Sent ) >= Attribute:GetDelay() then
			
			local Value = Attribute:Get(self.Object[1])
			
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
		local Datagram = string.char(Header) .. AddressMessage
		local StringIndex = string.char(Attribute:GetIndex())
		
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
		
		local Value = Attribute:Get(self.Object[1])
		local Datagram = string.char(Header) .. AddressMessage
		
		local StringIndex = string.char(Attribute:GetIndex())
		
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
		
		Attribute:Set(self.Object[1], Value)
		self.Value[Index] = Value
		
	end
	
end

function Object:GetClass()
	
	return self.Class
	
end

return Object