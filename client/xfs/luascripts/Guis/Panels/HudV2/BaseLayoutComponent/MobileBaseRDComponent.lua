-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseLayoutComponent\\MobileBaseRDComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("MobileBaseRDComponent")
local Class = require("Core.Framework.Class")
local HudSplicingCfg = require("Guis.Panels.HudV2.HudSplicingCfg")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local BallBtnComponent = require("Guis.Panels.HudV2.BaseComponent.BallBtnComponent")
local ExploreBtnComponent = require("Guis.Panels.HudV2.BaseComponent.ExploreBtnComponent")
local AimUIComponent = require("Guis.Panels.HudV2.BaseComponent.AimUIComponent")
local AimSenseUIComponent = require("Guis.Panels.HudV2.BaseComponent.AimSenseUIComponent")
local MobileCarryEntOperateUIComponent = require("Guis.Panels.HudV2.BaseComponent.MobileCarryEntOperateUIComponent")
local LuaUIUtils = require("Utils.LuaUIUtils")
local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local MobileBaseRDComponent = Class.LightClass("MobileBaseRDComponent", HudBaseComponent)

MobileBaseRDComponent.messages = {
	[MessageName.PLAYER_START_CARRY] = {
		"onPlayerStartCarryEnt",
		true
	},
	[MessageName.PLAYER_STOP_CARRY] = {
		"onPlayerStopCarryEnt",
		true
	},
	[MessageName.ENTER_AIM_SENSE] = {
		"onEnterAimSense",
		true
	},
	[MessageName.LEAVE_AIM_SENSE] = {
		"onLeaveAimSense",
		true
	}
}

function MobileBaseRDComponent:findObjects()
	return
end

function MobileBaseRDComponent:initView()
	return
end

function MobileBaseRDComponent:bindComponent()
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
	self.mobileExplore = self:getBaseComponentCls(HudSplicingCfg.componentName.mobileExplore).new(self, nil, {
		isAutoLoad = true,
		parentTrans = self.view.uiNode.transform,
		compName = HudSplicingCfg.componentName.mobileExplore
	})
	self.ballBtn = BallBtnComponent.new(self, nil, {
		isAutoLoad = true,
		parentTrans = self.view.uiNode.transform,
		compName = HudSplicingCfg.componentName.mobileBallBtn
	})
	self.exploreBtn = ExploreBtnComponent.new(self, nil, {
		isAutoLoad = true,
		parentTrans = self.view.uiNode.transform,
		compName = HudSplicingCfg.componentName.exploreBtn
	})
	self.aim = AimUIComponent.new(self, nil, {
		isAutoLoad = true,
		parentTrans = self.view.uiWorldNode.transform,
		compName = HudSplicingCfg.componentName.aim
	})
	self.aimSense = AimSenseUIComponent.new(self, nil, {
		parentTrans = self.view.uiNode.transform,
		compName = HudSplicingCfg.componentName.aimSense
	})
	self.interactGesture = self:getBaseComponentCls(HudSplicingCfg.componentName.interactGesture).new(self, nil, {
		parentTrans = self.view.uiNode.transform,
		compName = HudSplicingCfg.componentName.interactGesture
	})
	self.mobileCarryEntOperate = MobileCarryEntOperateUIComponent.new(self, nil, {
		isAutoLoad = true,
		parentTrans = self.view.uiNode.transform,
		compName = HudSplicingCfg.componentName.mobileCarryEntOperate
	})
end

function MobileBaseRDComponent:onPlayerStartCarryEnt()
	self:setSkillVisible(false)
	pg.global.ui.interact:setUIHide(UIConst.UI_HIDE_KEY.CARRY_ENT, true)

	self.mobileCarryEntOperate.wantShow = true

	self.mobileCarryEntOperate:showOperateBtns()
end

function MobileBaseRDComponent:onPlayerStopCarryEnt()
	self:setSkillVisible(true)
	pg.global.ui.interact:setUIHide(UIConst.UI_HIDE_KEY.CARRY_ENT, false)

	self.mobileCarryEntOperate.wantShow = false

	self.mobileCarryEntOperate:hideOperateBtns()
end

function MobileBaseRDComponent:setSkillVisible(visible)
	if self.mobileSkill and self.mobileSkill.uWidget then
		LuaUIUtils.setUIVisible(self.mobileSkill.uWidget, visible)
	end

	if self.mobile3C and self.mobile3C.uWidget then
		LuaUIUtils.setUIVisible(self.mobile3C.uWidget, visible)
	end
end

function MobileBaseRDComponent:onExploreModeChanged(inExplore)
	if self.mobileSkill and self.mobileSkill.transform then
		LuaUIUtils.setUIViewVisible(self.mobileSkill.transform.gameObject, not inExplore)
	end

	if self.mobile3C and self.mobile3C.onExploreModeChanged then
		self.mobile3C:onExploreModeChanged(inExplore)
	end
end

function MobileBaseRDComponent:notifyNormalAtkBtnStateChanged(visible)
	if self.mobile3C and self.mobile3C.notifyNormalAtkBtnStateChanged then
		self.mobile3C:notifyNormalAtkBtnStateChanged(visible)
	end
end

function MobileBaseRDComponent:onEnterAimSense()
	self.aimSense:onEnterAimSense()
end

function MobileBaseRDComponent:onLeaveAimSense()
	self.aimSense:onLeaveAimSense()
end

function MobileBaseRDComponent:onDestroy()
	HudBaseComponent.onDestroy(self)
end

return MobileBaseRDComponent
