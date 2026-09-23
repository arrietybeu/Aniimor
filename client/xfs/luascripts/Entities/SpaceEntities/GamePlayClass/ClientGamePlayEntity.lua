-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\GamePlayClass\\ClientGamePlayEntity.lua

local class = require("Core.Framework.Class")
local ClientEntity = require("Core.Client.ClientEntity")
local ClientGamePlayEntity = class.Class("ClientGamePlayEntity", ClientEntity)

function ClientGamePlayEntity:init(dict)
	local result = ClientGamePlayEntity.super.init(self, dict)

	self.sandboxId = dict.sandboxId

	return result
end

return ClientGamePlayEntity
