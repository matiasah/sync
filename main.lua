local sync = require("sync")

Server = require("sync.Server")
Class = require("sync.Class")

function love.load()
	
	sv = Server:new()
	sv2 = Server:new()
	
	sv:Connect( tostring(sv2) )
	
	local firstClass = Class:new(sv, "test")
	local secondClass = Class:new(sv2, "test")
	
	firstClass:AddAttribute("x"):SetReliable(false):SetSequenced(false):SetDelay(0.2)
	secondClass:AddAttribute("x"):SetReliable(false):SetSequenced(false)
	secondClass:SetConstructor({new = function () return {} end})
	
	object1 = {x = 0}
	
	function sv:OnConnect(Peer)
		
		firstClass:Create(object1):Share(Peer)
		
	end
	
end

local t = love.timer.getTime()

function love.update()
	
	sv:Update()
	sv2:Update()
	
	local obj = sv2:ReceiveObject()
	
	if obj then
		
		object2 = obj
		
	end
	
	if love.timer.getTime() - t > 1 then
		
		if object1 then
			
			object1 = nil
			
		end
		
	end
	
	if object2 and object1 then
		
		object1.x = object1.x + 1
		--print(object2.x)
		
	end
	
end

function cnt(t)
	
	local c = 0
	
	for k, v in pairs(t) do
		
		c = c + 1
		
	end
	
	return c
	
end