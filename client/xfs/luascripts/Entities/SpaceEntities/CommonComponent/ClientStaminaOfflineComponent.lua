-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientStaminaOfflineComponent.lua

local class = require("Core.Framework.Class")
local StaminaComponent = require("Common.Components.StaminaComponent")
local ClientStaminaOfflineComponent = class.Component("ClientStaminaOfflineComponent", StaminaComponent)

function ClientStaminaOfflineComponent:checkStaminaCost(tagType, costRatioFix)
	return true
end

function ClientStaminaOfflineComponent:getStaminaCost(costType, tagType, costRatioFix)
	return 0
end

return ClientStaminaOfflineComponent
