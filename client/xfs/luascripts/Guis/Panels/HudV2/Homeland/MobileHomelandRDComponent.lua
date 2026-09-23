-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\Homeland\\MobileHomelandRDComponent.lua

local Class = require("Core.Framework.Class")
local HudSplicingCfg = require("Guis.Panels.HudV2.HudSplicingCfg")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local MobileHomelandRDComponent = Class.LightClass("MobileHomelandRDComponent", HudBaseComponent)

function MobileHomelandRDComponent:findObjects()
	return
end

function MobileHomelandRDComponent:initView()
	return
end

function MobileHomelandRDComponent:bindComponent()
	self.mobile3C = self:getBaseComponentCls(HudSplicingCfg.componentName.mobile3C).new(self, nil, {
		isAutoLoad = true,
		parentTrans = self.view.uiNode.transform,
		compName = HudSplicingCfg.componentName.mobile3C
	})
	self.mobileSkill = self:getBaseComponentCls(HudSplicingCfg.componentName.mobileSkill).new(self, nil, {
		isAutoLoad = true,
		parentTrans = self.view.uiNode.transform,
		compName = HudSplicingCfg.componentName.mobileSkill
	})
end

function MobileHomelandRDComponent:onDestroy()
	HudBaseComponent.onDestroy(self)
end

return MobileHomelandRDComponent
