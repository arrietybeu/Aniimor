-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseLayoutComponent\\BaseRMComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("BaseRMComponent")
local Class = require("Core.Framework.Class")
local LuaUIUtils = require("Utils.LuaUIUtils")
local HudSplicingCfg = require("Guis.Panels.HudV2.HudSplicingCfg")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local BaseRMComponent = Class.LightClass("BaseRMComponent", HudBaseComponent)

function BaseRMComponent:findObjects()
	return
end

function BaseRMComponent:initView()
	return
end

function BaseRMComponent:bindComponent()
	self.petList = self:getBaseComponentCls(HudSplicingCfg.componentName.petList).new(self, self.view.uiNode.transform, {
		isAutoLoad = true,
		parentTrans = self.view.uiNode.transform,
		compName = HudSplicingCfg.componentName.petList
	})
end

function BaseRMComponent:onDestroy()
	HudBaseComponent.onDestroy(self)
end

function BaseRMComponent:switchTeamPetHotKey()
	if not self.gamepadSwitchPetTeamButtons then
		return
	end

	for _, obj in ipairs(self.gamepadSwitchPetTeamButtons) do
		LuaUIUtils.setUIViewVisible(obj, false)
	end

	if self.curPetIdx then
		LuaUIUtils.setUIViewVisible(self.gamepadSwitchPetTeamButtons[self.curPetIdx], true)
	end
end

return BaseRMComponent
