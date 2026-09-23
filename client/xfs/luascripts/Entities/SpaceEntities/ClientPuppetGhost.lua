-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientPuppetGhost.lua

local class = require("Core.Framework.Class")
local ClientPuppet = require("Entities.SpaceEntities.ClientPuppet")
local ClientBeCarryComponent = require("Entities.SpaceEntities.CommonComponent.ClientBeCarryComponent")
local ClientPuppetGhost = class.Class("ClientPuppetGhost", ClientPuppet)
local ClientPuppetGhostComponents = {
	ClientBeCarryComponent
}

class.AddComponents(ClientPuppetGhost, ClientPuppetGhostComponents)

function ClientPuppetGhost:needLimitCount()
	return false
end

return ClientPuppetGhost
