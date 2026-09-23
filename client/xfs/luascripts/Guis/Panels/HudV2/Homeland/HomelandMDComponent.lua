-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\Homeland\\HomelandMDComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomelandMDComponent")
local Class = require("Core.Framework.Class")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local HomelandMDComponent = Class.LightClass("HomelandMDComponent", HudBaseComponent)

function HomelandMDComponent:findObjects()
	return
end

function HomelandMDComponent:initView()
	return
end

function HomelandMDComponent:bindComponent()
	self.homeFunc = self:getBaseComponentCls("homeFunc").new(self, self.view.uiNode.transform, {
		compName = "homeFunc",
		isAutoLoad = true,
		parentTrans = self.view.uiNode.transform
	})
end

function HomelandMDComponent:onDestroy()
	HudBaseComponent.onDestroy(self)
end

return HomelandMDComponent
