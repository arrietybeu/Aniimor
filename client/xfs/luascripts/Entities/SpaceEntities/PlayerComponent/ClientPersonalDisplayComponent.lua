-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientPersonalDisplayComponent.lua

local class = require("Core.Framework.Class")
local ClientPersonalDisplayComponent = class.Component("ClientPersonalDisplayComponent")

function ClientPersonalDisplayComponent:init(dict)
	self.displayShelves = dict.displayShelves or {}

	return true
end

function ClientPersonalDisplayComponent:RPC_SC_DisplayShelvesUpdate(shelfId, shelf)
	self.displayShelves[shelfId] = shelf
end

return ClientPersonalDisplayComponent
