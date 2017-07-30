module("sync.Functions", package.seeall)

ffi = require("ffi")

Functions = {}

function Functions.AddressOf(Object)
	
	local String = tostring(Object)
	local Match = String:match("%w+%: (%w+)")
	
	return tonumber(Match, 16), Match
	
end

function Functions.numberToString(Number)
	
	local Double = ffi.new("double [1]", Number)
	
	return ffi.string(Double, 8)
	
end

function Functions.numberFromString(String)
	
	local Double = ffi.cast("double *", String)
	
	return tonumber(Double[0])
	
end

return Functions