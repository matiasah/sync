module("sync.Object", package.seeall)

Messages		= require("sync.messages")
Functions	= require("sync.functions")

Object = {}
Object.__index = Object
Object.__type = "Object"

Object.Remote = false

WeakValues = {__mode = "v"}

function Object:new(Class, Object)
	
	local self = setmetatable( {}, Object )
	
	self.Class = Class
	self.Server = Class:GetServer()
	self.Object = Object
	self.Address = Functions.AddressOf(Object)
	self.Value = {}
	self.Peers = setmetatable( {}, WeakValues )
	
	return self
	
end

function Object:GetObject()
	
	return self.Object
	
end

function Object:GetAddress()
	
	return self.Address
	
end

function Object:FetchChanges()
	
	local Changes = {}
	
	for Name, Attribute in pairs(self.Class:GetAttributes()) do
		
		local Value = Attribute:Get(self.Object)
		
		if self.Value[Name] ~= Value then
			
			Changes[Name]		= Value
			self.Value[Name]	= Value
			
		end
		
	end
	
	return Changes
	
end

function Object:PushChanges()
	
	local Server = self.Server
	local Changes = self:FetchChanges()

	local Attributes = self:GetAttributes()
	local Datagrams = {}

	for Index, Value in pairs(Changes) do
		
		local Attribute = Attributes[Index]
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
				
			else
				
				local NetworkObject = self:GetLocalObject(Value)
				
				if NetworkObject then
					
					local Address = NetworkObject:GetAddress()
					
					local Byte1 = Address % 256; Address = ( Address - Byte1 ) / 256
					local Byte2 = Address % 256; Address = ( Address - Byte2 ) / 256
					local Byte3 = Address % 256; Address = ( Address - Byte3 ) / 256
					local Byte4 = Address
					
					StringValue = string.char(Messages.Object) .. string.char(Byte1) .. string.char(Byte2) .. string.char(Byte3) .. string.char(Byte4)
					
				end
				
			end
			
			if StringValue then
				
				local Byte = Messages.toByte {
					Remote	= self.Remote,
					Push		= true,
				}
				
				table.insert(Datagrams, {string.char(Byte) .. StringIndex .. StringValue, Attribute:GetChannel(), Attribute:GetFlags()})
				
			end
			
		end
		
	end
	
	for Index, Peer in pairs(self.Peers) do
		
		for _, Datagram in pairs(Datagrams) do
			
			Peer:send(unpack(Datagram))
			
		end
		
	end
	
end

function Object:Share(Peer)
	
	table.insert(self.Peers, Peer)
	
	self:Send(Peer)
	
end

function Object:Send(Peer)
	
	local Byte = Messages.toByte {
		Remote = self.Remote,
		Create = true,
	}
	
	local Datagram = string.char(Byte)
	
	for Index, Attribute in pairs(self.Class:GetAttributes()) do
		
		local Value = Attribute:Get(Index)
		
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
				
			elseif IndexType == "string" then
				
				local Length = #Value
				local Byte1 = Length % 256
				local Byte2 = ( Length - Byte1 ) / 256
				
				StringValue = string.char(Messages.String) .. string.char(Byte1) .. string.char(Byte2) .. Value
				
			else
				
				local NetworkObject = self:GetLocalObject(Value)
				
				if NetworkObject then
					
					local Address = NetworkObject:GetAddress()
					
					local Byte1 = Address % 256; Address = ( Address - Byte1 ) / 256
					local Byte2 = Address % 256; Address = ( Address - Byte2 ) / 256
					local Byte3 = Address % 256; Address = ( Address - Byte3 ) / 256
					local Byte4 = Address
					
					StringValue = string.char(Messages.Object) .. string.char(Byte1) .. string.char(Byte2) .. string.char(Byte3) .. string.char(Byte4)
					
				end
				
			end
			
			if StringValue then
				
				local Byte = Messages.toByte {
					Remote	= self.Remote,
					Push		= true,
				}
				
				Datagram = Datagram .. string.char(Byte) .. StringIndex .. StringValue
				
			end
			
		end
		
	end
	
	Peer:send(Datagram, self.Class:GetCreateChannel(), self.Class:GetCreateFlags())
	
end

function Object:SetRemote(Remote)
	
	self.Remote = Remote
	
end

function Object:GetRemote()
	
	return self.Remote
	
end

return Object