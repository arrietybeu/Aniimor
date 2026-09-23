-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientLine.lua

local Class = require("Core.Framework.Class")
local ClientTown = require("Entities.SpaceEntities.ClientTown")
local ClientLine = Class.Class("ClientLine", ClientTown)

function ClientLine:ctor(entityId)
	ClientLine.super.ctor(self, entityId)

	self.lineNo = 0
end

function ClientLine:init(dict)
	ClientLine.super.init(self, dict)

	self.lineNo = dict.lineNo or 0

	return true
end

return ClientLine
