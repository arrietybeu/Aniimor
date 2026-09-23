-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\HudV2View.lua

local logger = require("Core.Log.LoggerManager").getLogger("HudV2View")
local HudSplicingCfg = require("Guis.Panels.HudV2.HudSplicingCfg")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HudV2View = Class.LightClass("HudV2View", UIView)

function HudV2View:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.uIDUSDFText = objectReference:GetRefValue("uIDUSDFText")
	self.statisticsTextUSDFText = objectReference:GetRefValue("statisticsTextUSDFText")
	self.uiWorldNode = objectReference:GetRefValue("uiWorldNode")
	self.uiNode = objectReference:GetRefValue("uiNode")
	self.uiCoverNode = objectReference:GetRefValue("uiCoverNode")
	self.uIEventSystemListener = objectReference:GetRefValue("uIEventSystemListener")
	self.rootComponent = self.transform:GetComponent("UComponent")
end

function HudV2View:registerObjects()
	return
end

function HudV2View:initView()
	return
end

function HudV2View:loadResByConfig(hudType)
	return
end

function HudV2View:switchGuideLabel(pageId)
	self.rootComponent:TryChangePage("guideLabel", pageId)
end

return HudV2View
