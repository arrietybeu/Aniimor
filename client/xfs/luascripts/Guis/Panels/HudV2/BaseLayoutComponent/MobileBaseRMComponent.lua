-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseLayoutComponent\\MobileBaseRMComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("MobileBaseRMComponent")
local Class = require("Core.Framework.Class")
local LuaUIUtils = require("Utils.LuaUIUtils")
local HudSplicingCfg = require("Guis.Panels.HudV2.HudSplicingCfg")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local MobileBaseRMComponent = Class.LightClass("MobileBaseRMComponent", HudBaseComponent)

function MobileBaseRMComponent:findObjects()
	return
end

function MobileBaseRMComponent:initView()
	return
end

function MobileBaseRMComponent:bindComponent()
	self.petList = self:getBaseComponentCls(HudSplicingCfg.componentName.mobilePetList).new(self, self.view.uiNode.transform, {
		isAutoLoad = true,
		parentTrans = self.view.uiNode.transform,
		compName = HudSplicingCfg.componentName.mobilePetList
	})
end

function MobileBaseRMComponent:onDestroy()
	HudBaseComponent.onDestroy(self)
end

function MobileBaseRMComponent:switchTeamPetHotKey()
	return
end

return MobileBaseRMComponent
