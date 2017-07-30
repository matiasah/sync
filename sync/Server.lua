module("sync.Server", package.seeall)

enet = require("enet")

Functions = require("sync.functions")

Server = {}
Server.__index = Server
Server.__type = "Server"

WeakValues = {__mode = "v"}
WeakKeys = {__mode = "k"}

function Server:new(Port)
	
	local self = setmetatable( {}, Server )
	local Port = Port or 0
	
	self.Socket = enet.host_create("*:" .. Port)
	
	self.LocalObject = setmetatable( {}, WeakKeys )	-- The local objects table
	self.RemoteObject = {}	-- The remote objects table
	self.Peer = {}
	
	self.LocalAddress = setmetatable( {}, WeakValues )
	self.RemoteAddress = {}
	
	return self
	
end

function Server:Update()
	
end

function Server:UpdateInput()
	
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

function Server:Receive(Peer, Data)
	
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