module("sync.Server", package.seeall)

enet = require("enet")

Sync			=	require("sync")
Functions	=	require("sync.functions")
Messages		=	require("sync.messages")
Object		=	require("sync.Object")
Peer			=	require("sync.Peer")

Server = {}
Server.__index = Server
Server.__type = "Server"

WeakValues = {__mode = "v"}
WeakKeys = {__mode = "k"}

function Server:new(Port)
	
	local self = setmetatable( {}, Server )
	local Port = Port or 0
	
	self.Socket = enet.host_create("localhost:" .. Port)
	self.Peer = {}
	
	self.Class = {}
	
	self.LocalObject = setmetatable( {}, WeakKeys )	-- The local objects table
	self.LocalAddress = setmetatable( {}, WeakValues )
	
	self.QueuedObjects = setmetatable( {}, WeakValues )
	
	return self
	
end

function Server:__tostring()
	
	return self.Socket:get_socket_address()
	
end

function Server:Update()
	
	local Event
	
	repeat
		
		Event = self.Socket:service()
		
		if Event then
			
			if Event.type == "connect" then
				
				local newPeer = Peer:new(Event.peer)
				
				newPeer:SetAddressLength(Event.data)
				
				self.Peer[Event.peer] = newPeer
				self:OnConnect(newPeer)
				
			elseif Event.type == "disconnect" then
				
				self.Peer[Event.peer] = nil
				
			elseif Event.type == "receive" then
				
				self:Receive(self.Peer[Event.peer], Event.data)
				
			end
			
		end
		
	until Event == nil
	
	for Object, NetworkObject in pairs(self.LocalObject) do
		
		NetworkObject:PushChanges()
		
	end
	
end

function Server:OnConnect(Peer)
	
end

function Server:Connect(Address)
	
	self.Socket:connect(Address, 1, Sync.AddressLength)
	
end

function Server:Receive(Peer, Data)
	
	local Byte = Data:byte(1); Data = Data:sub(2)
	local Message = Messages.toTable(Byte)
	
	local AddressLength = Peer:GetAddressLength()
	local NumberLength = Peer:GetNumberLength()
	
	if Message.Push then
		
		local Address = 0
		local Exponent = 1
		
		for i = 1, AddressLength do
			
			Address = Address + Data:byte(i) * Exponent
			Exponent = Exponent * 256
			
		end
		
		Data = Data:sub(AddressLength + 1)
		
		local Obj
		
		if Message.Remote then
			
			Obj = self.LocalAddress[Address]
			
		else
			
			Obj = Peer:GetRemoteAddress(Address)
			
		end
		
		if Obj then
			
			local NetworkObject
			
			if Message.Remote then
				
				NetworkObject = self.LocalObject[Obj]
				
			else
				
				NetworkObject = Peer:GetRemoteObject(Obj)
				
			end
			
			if NetworkObject then
				
				local IndexValue = Data:byte(1); Data = Data:sub(2)
				local Index = NetworkObject:GetClass():GetAttributeAt(IndexValue):GetName()
				
				local ValueType = Data:byte(1); Data = Data:sub(2)
				local Value
				
				if ValueType == Messages.Number then
					
					Value = Functions.numberFromString(Data:sub(1, NumberLength))
					Data = Data:sub(NumberLength + 1)
					
				elseif ValueType == Messages.String then
					
					local ValueLength = Data:byte(1) + Data:byte(2) * 256
					
					Data = Data:sub(3)
					Value = Data:sub(1, ValueLength)
					Data = Data:sub(ValueLength + 1)
					
				elseif ValueType == Messages.Nil then
					
					Value = nil
					
				elseif ValueType == Messages.Object then
					
					local Address = 0
					local Exponent = 1
					
					for i = 1, AddressLength do
						
						Address = Address + Data:byte(i) * Exponent
						Exponent = Exponent * 256
						
					end
					
					Data = Data:sub(AddressLength + 1)
					Value = Peer:GetRemoteAddress(Address)
					
				end
				
				if Index then
					
					NetworkObject:SetValue(Index, Value)
					
				end
				
			end
			
		end
		
	elseif Message.Create then
		
		local ClassNameLength	= Data:byte(1); Data = Data:sub(2)
		local ClassName			= Data:sub(1, ClassNameLength); Data = Data:sub(ClassNameLength + 1)
		
		local Class = self.Class[ClassName]
		
		if Class then
			
			local Constructor = Class:GetConstructor()
			
			if not Constructor then
				
				return error("Missing constructor method (new) for class '" .. Constructor .. "'")
				
			end
			
			local Attributes = Class:GetAttributes()
			local Obj = Constructor:new()
			
			if Obj then
				
				local Address = 0
				local Exponent = 1
				
				for i = 1, AddressLength do
					
					Address = Address + Data:byte(i) * Exponent
					Exponent = Exponent * 256
					
				end
				
				Data = Data:sub(AddressLength + 1)
				
				local NetworkObject = Object:new(Class, Obj)
				
				NetworkObject:SetRemote(true)
				NetworkObject:SetAddress(Address)
				
				Peer:SetRemoteObject(Object, NetworkObject)
				Peer:SetRemoteAddress(Address, Obj)
				
				while #Data > 0 do
					
					local IndexValue = Data:byte(1); Data = Data:sub(2)
					local Index = NetworkObject:GetClass():GetAttributeAt(IndexValue):GetName()
					
					local ValueType = Data:byte(1); Data = Data:sub(2)
					local Value
					
					if ValueType == Messages.Number then
						
						Value = Functions.numberFromString(Data:sub(1, NumberLength))
						Data = Data:sub(NumberLength + 1)
						
					elseif ValueType == Messages.String then
						
						local ValueLength = Data:byte(1) + Data:byte(2) * 256
						
						Data = Data:sub(3)
						Value = Data:sub(1, ValueLength)
						Data = Data:sub(ValueLength + 1)
						
					elseif ValueType == Messages.Nil then
						
						Value = nil
						
					elseif ValueType == Messages.Object then
						
						local ObjectAddress = Data:byte(1) + Data:byte(2) * 256 + Data:byte(3) * 65536 + Data:byte(4) * 16777216
						
						Data = Data:sub(5)
						Value = Peer:GetRemoteAddress(ObjectAddress)
						
					end
					
					if Index then
						
						local Attribute = Attributes[Index]
						
						if Attribute then
							
							Attribute:Set(Obj, Value)
							
						end
						
					end
					
				end
				
				table.insert(self.QueuedObjects, Obj)
				
				Peer:SetRemoteAddress(Address, Obj)
				Peer:SetRemoteObject(Obj, NetworkObject)
				
			end
			
		end
		
	elseif Message.Remove then
		
		local Address = 0
		local Exponent = 1
		
		for i = 1, AddressLength do
			
			Address = Address + Data:byte(i) * Exponent
			Exponent = Exponent * 256
			
		end
		
		local Data = Data:sub(AddressLength + 1)
		local Object = Peer:GetRemoteAddress(Address)
		
		-- finish this part
		
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

function Server:ReceiveObject()
	
	local Index, Object = next(self.QueuedObjects)
	
	if Object then
		
		self.QueuedObjects[Index] = nil
		
	end
	
	return Object
	
end

return Server