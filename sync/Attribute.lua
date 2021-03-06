module("sync.Attribute", package.seeall)

Attribute = {}
Attribute.__index = Attribute
Attribute.__type = "Attribute"

Attribute.Reliable = false
Attribute.Sequenced = false
Attribute.Channel = 0

Attribute.Delay = 0
Attribute.Index = 0

function Attribute:new(Name)
	
	local self = setmetatable( {}, Attribute )
	
	self.Name = Name
	
	return self
	
end

function Attribute:SetDelay(Delay)
	
	self.Delay = Delay
	
	return self
	
end

function Attribute:GetDelay()
	
	return self.Delay
	
end

function Attribute:SetReliable(Reliable)
	
	self.Reliable = Reliable
	
	return self
	
end

function Attribute:GetReliable()
	
	return self.Reliable
	
end

function Attribute:SetSequenced(Sequenced)
	
	self.Sequenced = Sequenced
	
	return self
	
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
	
	return self
	
end

function Attribute:GetChannel()
	
	return self.Channel
	
end

function Attribute:Get(Object)
	
	if self.Getter then
		
		return self.Getter(Object)
		
	end
	
	return Object[self.Name]
	
end

function Attribute:Set(Object, Value)
	
	if self.Setter then
		
		return self.Setter(Object, Value)
		
	end
	
	Object[self.Name] = Value
	
end

function Attribute:SetIndex(Index)
	
	self.Index = Index
	
end

function Attribute:GetIndex()
	
	return self.Index
	
end

function Attribute:GetName()
	
	return self.Name
	
end

function Attribute:SetSetter(Setter)
	
	self.Setter = Setter
	
	return self
	
end

function Attribute:GetSetter()
	
	return self.Setter
	
end

function Attribute:SetGetter(Getter)
	
	self.Getter = Getter
	
	return self
	
end

function Attribute:GetGetter()
	
	return self.Getter
	
end

return Attribute