-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseLayoutComponent\\BaseRDComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("BaseRDComponent")
local Class = require("Core.Framework.Class")
local HudSplicingCfg = require("Guis.Panels.HudV2.HudSplicingCfg")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local ExploreBtnComponent = require("Guis.Panels.HudV2.BaseComponent.ExploreBtnComponent")
local AimUIComponent = require("Guis.Panels.HudV2.BaseComponent.AimUIComponent")
local AimSenseUIComponent = require("Guis.Panels.HudV2.BaseComponent.AimSenseUIComponent")
local LuaUIUtils = require("Utils.LuaUIUtils")
local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local BaseRDComponent = Class.LightClass("BaseRDComponent", HudBaseComponent)

BaseRDComponent.messages = {
	[MessageName.ENTER_AIM_SENSE] = {
		"onEnterAimSense",
		true
	},
	[MessageName.LEAVE_AIM_SENSE] = {
		"onLeaveAimSense",
		true
	},
	[MessageName.PLAYER_START_CARRY] = {
		"onPlayerStartCarryEnt",
		true
	},
	[MessageName.PLAYER_STOP_CARRY] = {
		"onPlayerStopCarryEnt",
		true
	}
}

function BaseRDComponent:findObjects()
	return
end

function BaseRDComponent:initView()
	return
end

function BaseRDComponent:bindComponent()
	self.skill = self:getBaseComponentCls(HudSplicingCfg.componentName.skillRD).new(self, nil, {
		isAutoLoad = true,
		parentTrans = self.view.uiNode.transform,
		compName = HudSplicingCfg.componentName.skillRD
	})
	self.carryEntOperate = self:getBaseComponentCls(HudSplicingCfg.componentName.carryEntOperate).new(self, nil, {
		parentTrans = self.view.uiNode.transform,
		compName = HudSplicingCfg.componentName.carryEntOperate
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
end

function BaseRDComponent:onExploreModeChanged(inExplore)
	if self.skill and self.skill.transform then
		LuaUIUtils.setUIViewVisible(self.skill.transform.gameObject, not inExplore)
	end
end

function BaseRDComponent:onPlayerStartCarryEnt()
	self:setSkillVisible(false)
	pg.global.ui.interact:setUIHide(UIConst.UI_HIDE_KEY.CARRY_ENT, true)

	self.carryEntOperate.wantShow = true

	if self.carryEntOperate:tryShowComponent() then
		self.carryEntOperate:refreshOperateBtns()
	end
end

function BaseRDComponent:onPlayerStopCarryEnt()
	self:setSkillVisible(true)
	pg.global.ui.interact:setUIHide(UIConst.UI_HIDE_KEY.CARRY_ENT, false)

	self.carryEntOperate.wantShow = false

	self.carryEntOperate:tryCloseComponent()
end

function BaseRDComponent:setSkillVisible(visible)
	if self.skill and self.skill.uWidget then
		LuaUIUtils.setUIVisible(self.skill.uWidget, visible)
	end
end

function BaseRDComponent:onEnterAimSense()
	self.aimSense:onEnterAimSense()
end

function BaseRDComponent:onLeaveAimSense()
	self.aimSense:onLeaveAimSense()
end

function BaseRDComponent:onDestroy()
	HudBaseComponent.onDestroy(self)
end

return BaseRDComponent
