module("sync.Class", package.seeall)

Attribute	= require("sync.Attribute")
Object		= require("sync.Object")

Class = {}
Class.__index = Class
Class.__type = "Class"

Class.CreateChannel = 0
Class.CreateReliable = true
Class.CreateSequenced = true

Class.RemoveChannel = 0
Class.RemoveReliable = true
Class.RemoveSequenced = true

function Class:new(Server, Name)
	
	local self = setmetatable( {}, Class )
	
	self.Attributes = {}
	self.Name = Name
	
	self.Server = Server
	self.Server:SetClass(Name, self)
	
	return self
	
end

function Class:Create(Obj)
	
	local NetworkObject = Object:new(self, Obj)
	
	self.Server:AddLocalObject(NetworkObject)
	
	return NetworkObject
	
end

function Class:SetConstructor(Constructor)
	
	self.Constructor = Constructor
	
end

function Class:GetConstructor()
	
	return self.Constructor
	
end

function Class:GetServer()
	
	return self.Server
	
end

function Class:GetName()
	
	return self.Name
	
end

function Class:SetCreateChannel(Channel)
	
	self.CreateChannel = Channel
	
end

function Class:SetCreateReliable(Reliable)
	
	self.CreateReliable = Reliable
	
end

function Class:SetCreateSequenced(Sequenced)
	
	self.CreateSequenced = Sequenced
	
end

function Class:GetCreateChannel()
	
	return self.CreateChannel
	
end

function Class:GetCreateReliable()
	
	return self.CreateReliable
	
end

function Class:GetCreateSequenced()
	
	return self.CreateSequenced
	
end

function Class:GetCreateFlags()
	
	if self.CreateReliable then
		
		return "reliable"
		
	elseif self.CreateSequenced then
		
		return "sequenced"
		
	end
	
	return "unreliable"
	
end

function Class:SetRemoveChannel(Channel)
	
	self.RemoveChannel = Channel
	
end

function Class:SetRemoveReliable(Reliable)
	
	self.RemoveReliable = Reliable
	
end

function Class:SetRemoveSequenced(Sequenced)
	
	self.RemoveSequenced = Sequenced
	
end

function Class:GetRemoveChannel()
	
	return self.RemoveChannel
	
end

function Class:GetRemoveReliable()
	
	return self.RemoveReliable
	
end

function Class:GetRemoveSequenced()
	
	return self.RemoveSequenced
	
end

function Class:GetRemoveFlags()
	
	if self.RemoveReliable then
		
		return "reliable"
		
	elseif self.RemoveSequenced then
		
		return "sequenced"
		
	end
	
	return "unreliable"
	
end

function Class:AddGetterMethod(Atribute, Name)
	
end

function Class:AddAttribute(Attribute)
	
	self.Attributes[Attribute] = Attribute:new()
	
end

function Class:GetAttributes()
	
	return self.Attributes
	
end

return Class