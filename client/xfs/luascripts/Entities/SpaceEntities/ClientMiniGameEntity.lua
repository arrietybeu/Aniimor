-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientMiniGameEntity.lua

local Class = require("Core.Framework.Class")
local ClientVirtualAIEntity = require("Entities.SpaceEntities.ClientVirtualAIEntity")
local ClientMiniGameEntity = Class.Class("ClientMiniGameEntity", ClientVirtualAIEntity)

function ClientMiniGameEntity:checkVirtualAIEnable()
	return false
end

function ClientMiniGameEntity:getVirtualAIAgentName()
	return "VirtualAIAgent"
end

return ClientMiniGameEntity
