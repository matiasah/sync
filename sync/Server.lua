module("sync.Server", package.seeall)

enet = require("enet")

Functions	= require("sync.functions")
Messages		= require("sync.messages")

Server = {}
Server.__index = Server
Server.__type = "Server"

WeakValues = {__mode = "v"}
WeakKeys = {__mode = "k"}

function Server:new(Port)
	
	local self = setmetatable( {}, Server )
	local Port = Port or 0
	
	self.Socket = enet.host_create("0.0.0.0:" .. Port)
	self.Peer = {}
	
	self.Class = {}
	
	self.LocalObject = setmetatable( {}, WeakKeys )	-- The local objects table
	self.RemoteObject = {}	-- The remote objects table
	
	self.LocalAddress = setmetatable( {}, WeakValues )
	self.RemoteAddress = {}
	
	return self
	
end

function Server:Update()
	
	local Event
	
	repeat
		
		Event = self.Socket:service(0)
		
		if Event.type == "connect" then
			
			table.insert(self.Peer, Event.peer)
			
		elseif Event.type == "disconnect" then
			
			for Index, Peer in pairs(self.Peer) do
				
				if Peer == self.Peer then
					
					self.Peer[Index] = nil
					
				end
				
			end
			
		elseif Event.type == "receive" then
			
			self:Receive(Event.peer, Event.data)
			
		end
		
	until Event == nil
	
end

function Server:Connect(Address)
	
	self.Socket:connect(Address)
	
end

function Server:Receive(Peer, Data)
	
	local Byte = Data:byte(1); Data = Data:sub(2)
	local Message = Messages.toTable(Byte)
	
	if Message.Remote then
		
	elseif Message.Create then
		
		local ClassNameLength	= Data:byte(1); Data = Data:sub(2)
		local ClassName			= Data:sub(1, ClassNameLength); Data = Data:sub(ClassNameLength + 1)
		
		local Class = self.Class[Class]
		
		if Class then
			
			local Constructor = Class:GetConstructor()
			local Attributes = Class:GetAttributes()
			local Object = Constructor:new()
			
			local Address = Data:byte(1) + Data:byte(2) * 256 + Data:byte(3) * 65536 + Data:byte(4) * 16777216; Data = Data:sub(5)
			local NetworkObject = Object:new(Class, Object)
			
			NetworkObject:SetRemote(true)
			NetworkObject:SetAddress(Address)
			
			self.RemoteObject[Object] = NetworkObject
			self.RemoteAddress[Address] = Object
			
			while #Data > 0 do
				
				local IndexType = Data:byte(1); Data = Data:sub(2)
				local Index
				
				if IndexType == Messages.Number then
					
					Index = Functions.numberFromString(Data:sub(1, 8))
					Data = Data:sub(9)
					
				elseif IndexType == Messages.String then
					
					local IndexLength = Data:byte(1) + Data:byte(2) * 256
					
					Data = Data:sub(3)
					Index = Data:sub(1, IndexLength)
					
				end
				
				local ValueType = Data:byte(1); Data = Data:sub(2)
				local Value
				
				if ValueType == Messages.Number then
					
					Value = Functions.numberFromString(Data:sub(1, 8))
					Data = Data:sub(9)
					
				elseif ValueType == Messages.String then
					
					local ValueLength = Data:byte(1) + Data:byte(2) * 256
					
					Data = Data:sub(3)
					Value = Data:sub(1, ValueLength)
					
				elseif ValueType == Messages.Object then
					
					local ObjectAddress = Data:byte(1) + Data:byte(2) * 256 + Data:byte(3) * 65536 + Data:byte(4) * 16777216
					
					Data = Data:sub(5)
					Value = self.RemoteAddress[ObjectAddress]
					
				end
				
				if Index and Value then
					
					local Attribute = Attributes[Index]
					
					if Attribute then
						
						Attribute:Set(Object, Value)
						
					end
					
				end
				
			end
			
		end
		
	elseif Message.Remove then
		
		
		
	end
	
end

function Server:SetClass(Name, Class)
	
	self.Class[Name] = Class
	
end

function Server:GetAddress()
	
	return self.Socket:get_socket_address()
	
end

function Server:AddLocalObject(Object)
	
	local Obj = Object:GetObject()
	
	self.LocalObject[Obj] = Object
	self.LocalAddress[Functions.AddressOf(Obj)] = Object
	
end

function Server:AddRemoteObject(Object)
	
	local Obj = Object:GetObject()
	
	self.RemoteObject[Obj] = Object
	self.RemoteAddress[Functions.AddressOf(Obj)] = Object
	
end

function Server:HasObject(Object)
	
	if self.LocalObject[Object] then
		
		return true
		
	end
	
	if self.RemoteObject[Object] then
		
		return true
		
	end
	
	return false
	
end

function Server:GetLocalObject(Object)
	
	return self.LocalObject[Object]
	
end

function Server:GetRemoteObject(Object)
	
	return self.RemoteObject[Object]
	
end

return Server