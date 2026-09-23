-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseLayoutComponent\\BaseRUComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("BaseRUComponent")
local Class = require("Core.Framework.Class")
local HudSplicingCfg = require("Guis.Panels.HudV2.HudSplicingCfg")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local BaseRUComponent = Class.LightClass("BaseRUComponent", HudBaseComponent)

function BaseRUComponent:findObjects()
	return
end

function BaseRUComponent:initView()
	return
end

function BaseRUComponent:bindComponent()
	self.funcList = self:getBaseComponentCls(HudSplicingCfg.componentName.funcList).new(self, self.view.uiNode.transform, {
		isAutoLoad = true,
		parentTrans = self.view.uiNode.transform,
		compName = HudSplicingCfg.componentName.funcList
	})
end

function BaseRUComponent:onDestroy()
	HudBaseComponent.onDestroy(self)
end

return BaseRUComponent
