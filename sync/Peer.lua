module("sync.Peer", package.seeall)

Peer = {}
Peer.__index = Peer
Peer.__type = "Peer"

Peer.AddressLength = 4
Peer.NumberLength = 8

function Peer:new(EnetPeer)
	
	local self = setmetatable( {}, Peer )
	
	self.Peer = EnetPeer
	
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

return Peer