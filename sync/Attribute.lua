module("sync.Attribute", package.seeall)

Attribute = {}
Attribute.__index = Attribute
Attribute.__type = "Attribute"

Attribute.Reliable = false
Attribute.Sequenced = false
Attribute.Channel = 0

function Attribute:new(Name)
	
	local self = setmetatable( {}, Attribute )
	
	self.Name = Name
	
	return self
	
end

function Attribute:SetReliable(Reliable)
	
	self.Reliable = Reliable
	
end

function Attribute:GetReliable()
	
	return self.Reliable
	
end

function Attribute:SetSequenced(Sequenced)
	
	self.Sequenced = Sequenced
	
end

function Attribute:GetSequenced()
	
	return self.Sequenced
	
end

function Attribute:GetFlags()
	
	if self.Reliable then
		
		return "reliable"
		
	elseif self.Sequenced then
		
		return "sequenced"
		
	end
	
	return "unreliable"
	
end

function Attribute:SetChannel(Channel)
	
	self.Channel = Channel
	
end

function Attribute:GetChannel()
	
	return self.Channel
	
end

function Attribute:Get(Object)
	
	return Object[self.Name]
	
end

return Attribute