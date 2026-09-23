-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\Areas\\PA2TipArea.lua

local Class = require("Core.Framework.Class")
local BaseTipArea = require("Guis.Panels.Tips.BaseTipArea")
local PA2TipArea = Class.LightClass("PA2TipArea", BaseTipArea)

function PA2TipArea:onCtor(info)
	return
end

function PA2TipArea:closePanel()
	self:clearRunItems()
end

return PA2TipArea
