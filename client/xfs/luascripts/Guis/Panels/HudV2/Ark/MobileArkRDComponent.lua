-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\Ark\\MobileArkRDComponent.lua

local Class = require("Core.Framework.Class")
local HudSplicingCfg = require("Guis.Panels.HudV2.HudSplicingCfg")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local MobileCarryEntOperateUIComponent = require("Guis.Panels.HudV2.BaseComponent.MobileCarryEntOperateUIComponent")
local LuaUIUtils = require("Utils.LuaUIUtils")
local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local MobileArkRDComponent = Class.LightClass("MobileArkRDComponent", HudBaseComponent)
local ExploreBtnComponent = require("Guis.Panels.HudV2.BaseComponent.ExploreBtnComponent")

MobileArkRDComponent.messages = {
	[MessageName.PLAYER_START_CARRY] = {
		"onPlayerStartCarryEnt",
		true
	},
	[MessageName.PLAYER_STOP_CARRY] = {
		"onPlayerStopCarryEnt",
		true
	}
}

function MobileArkRDComponent:findObjects()
	return
end

function MobileArkRDComponent:initView()
	return
end

function MobileArkRDComponent:bindComponent()
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
	self.mobileCarryEntOperate = MobileCarryEntOperateUIComponent.new(self, nil, {
		isAutoLoad = true,
		parentTrans = self.view.uiNode.transform,
		compName = HudSplicingCfg.componentName.mobileCarryEntOperate
	})
	self.interactGesture = self:getBaseComponentCls(HudSplicingCfg.componentName.interactGesture).new(self, nil, {
		parentTrans = self.view.uiNode.transform,
		compName = HudSplicingCfg.componentName.interactGesture
	})
	self.exploreBtn = ExploreBtnComponent.new(self, nil, {
		isAutoLoad = true,
		parentTrans = self.view.uiNode.transform,
		compName = HudSplicingCfg.componentName.exploreBtn
	})
end

function MobileArkRDComponent:onPlayerStartCarryEnt()
	self:setSkillVisible(false)
	pg.global.ui.interact:setUIHide(UIConst.UI_HIDE_KEY.CARRY_ENT, true)

	self.mobileCarryEntOperate.wantShow = true

	self.mobileCarryEntOperate:showOperateBtns()
end

function MobileArkRDComponent:onPlayerStopCarryEnt()
	self:setSkillVisible(true)
	pg.global.ui.interact:setUIHide(UIConst.UI_HIDE_KEY.CARRY_ENT, false)

	self.mobileCarryEntOperate.wantShow = false

	self.mobileCarryEntOperate:hideOperateBtns()
end

function MobileArkRDComponent:setSkillVisible(visible)
	if self.mobileSkill and self.mobileSkill.uWidget then
		LuaUIUtils.setUIVisible(self.mobileSkill.uWidget, visible)
	end

	if self.mobile3C and self.mobile3C.uWidget then
		LuaUIUtils.setUIVisible(self.mobile3C.uWidget, visible)
	end
end

function MobileArkRDComponent:onDestroy()
	HudBaseComponent.onDestroy(self)
end

return MobileArkRDComponent
