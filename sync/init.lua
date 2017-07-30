local Path = ...
local Sync = {}

Sync.path = Path:gsub("%.", "/")

package.loaded["sync"]						=	Sync
package.preload["sync.Attribute"]		=	assert(love.filesystem.load(Sync.path.."/Attribute.lua"))
package.preload["sync.Class"]				=	assert(love.filesystem.load(Sync.path.."/Class.lua"))
package.preload["sync.Object"]			=	assert(love.filesystem.load(Sync.path.."/Object.lua"))
package.preload["sync.Server"]			=	assert(love.filesystem.load(Sync.path.."/Server.lua"))

package.preload["sync.messages"]			=	assert(love.filesystem.load(Sync.path.."/messages.lua"))
package.preload["sync.functions"]		=	assert(love.filesystem.load(Sync.path.."/functions.lua"))

return Sync