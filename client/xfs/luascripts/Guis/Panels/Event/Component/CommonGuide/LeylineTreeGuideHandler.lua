-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\Component\\CommonGuide\\LeylineTreeGuideHandler.lua

local Class = require("Core.Framework.Class")
local GuideHandlerBase = require("Guis.Panels.Event.Component.CommonGuide.GuideHandlerBase")
local LeylineTreeGuideHandler = Class.LightClass("LeylineTreeGuideHandler", GuideHandlerBase)

function LeylineTreeGuideHandler:getOwnedRefKeys()
	return {
		"leylineUpWidget"
	}
end

function LeylineTreeGuideHandler:onFindObjects(objectReference)
	self.leylineUpWidget = objectReference:GetRefValue("leylineUpWidget")
end

function LeylineTreeGuideHandler:onRefresh()
	self.leylineUpWidget:SetActive(true)
end

function LeylineTreeGuideHandler:onExit()
	self.leylineUpWidget:SetActive(false)
end

return LeylineTreeGuideHandler
