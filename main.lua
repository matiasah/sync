local sync = require("sync")
local f = require("sync.functions")

local str = f.numberToString(math.pi)

collectgarbage()

local n = f.numberFromString(str)
print(n)
print(math.pi)