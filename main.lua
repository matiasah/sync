local sync = require("sync")

Server = require("sync.Server")
Class = require("sync.Class")

function love.load()
	
	sv = Server:new()
	sv2 = Server:new()
	
	sv:Connect( tostring(sv2) )
	
	local firstClass = Class:new(sv, "test")
	local secondClass = Class:new(sv2, "test")
	
	firstClass:AddAttribute("x"):SetReliable(false):SetSequenced(false):SetDelay(0.4)
	secondClass:AddAttribute("x"):SetReliable(false):SetSequenced(false)
	secondClass:SetConstructor({new = function () return {} end})
	
	object1 = {x = 0}
	
	function sv:OnConnect(Peer)
		
		firstClass:Create(object1):Share(Peer)
		
	end
	
end

function love.update()
	
	sv:Update()
	sv2:Update()
	
	local obj = sv2:ReceiveObject()
	
	if obj then
		
		object2 = obj
		
	end
	
	if object2 then
		
		object1.x = object1.x + 1
		print(object2.x)
		
	end
	
end