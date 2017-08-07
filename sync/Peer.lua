module("sync.Peer", package.seeall)

Functions = require("sync.Functions")

Peer = {}
Peer.__index = Peer
Peer.__type = "Peer"

Peer.AddressLength = 4
Peer.NumberLength = 8

function Peer:new(EnetPeer)
	
	local self = setmetatable( {}, Peer )
	
	self.Peer = EnetPeer
	self.RemoteObject = {}
	self.RemoteAddress = {}
	
	return self
	
end

function Peer:SetAddressLength(AddressLength)
	
	self.AddressLength = AddressLength
	
end

function Peer:GetAddressLength()
	
	return self.AddressLength
	
end

function Peer:SetNumberLength(NumberLength)
	
	self.NumberLength = NumberLength
	
end

function Peer:GetNumberLength()
	
	return self.NumberLength
	
end

function Peer:GetPeer()
	
	return self.Peer
	
end

function Peer:SetRemoteObject(Object, NetworkObject)
	
	self.RemoteObject[Object] = NetworkObject
	
end

function Peer:GetRemoteObject(Object)
	
	return self.RemoteObject[Object]
	
end

function Peer:SetRemoteAddress(Address, Object)
	
	self.RemoteAddress[Address] = Object
	
end

function Peer:GetRemoteAddress(Address)
	
	return self.RemoteAddress[Address]
	
end

function Peer:AddRemoteObject(Object)
	
	local Obj = Object:GetObject()
	
	self.RemoteObject[Obj] = Object
	self.RemoteAddress[Functions.AddressOf(Obj)] = Object
	
end

function Peer:Send(...)
	
	self.Peer:send(...)
	
end

return Peer