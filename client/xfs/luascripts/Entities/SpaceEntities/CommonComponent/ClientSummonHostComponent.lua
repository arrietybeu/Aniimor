-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientSummonHostComponent.lua

local class = require("Core.Framework.Class")
local LxGeometry = require("Common.Ability.LxGeometry")
local AbilityConst = require("Common.Const.AbilityConst")
local ClientSummonHostComponent = class.Component("ClientSummonHostComponent")

function ClientSummonHostComponent:init(dict)
	return true
end

function ClientSummonHostComponent:isSummonHost()
	return
end

return ClientSummonHostComponent
