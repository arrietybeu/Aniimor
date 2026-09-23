-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseLayoutComponent\\BaseMDComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("BaseMDComponent")
local Class = require("Core.Framework.Class")
local HudSplicingCfg = require("Guis.Panels.HudV2.HudSplicingCfg")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local BaseMDComponent = Class.LightClass("BaseMDComponent", HudBaseComponent)

function BaseMDComponent:findObjects()
	return
end

function BaseMDComponent:initView()
	self:tryRestoreNpcDuelInCombat()
end

function BaseMDComponent:tryRestoreNpcDuelInCombat()
	if not self.npcDuelInCombat then
		return
	end

	local space = pg.me and pg.me.space

	if space and type(space.npcDuelDungeonIsReady) == "function" and space:npcDuelDungeonIsReady() then
		self.npcDuelInCombat:tryShowComponent()
	end
end

function BaseMDComponent:bindComponent()
	self.hpFuse = self:getBaseComponentCls(HudSplicingCfg.componentName.hp).new(self, nil, {
		isAutoLoad = true,
		parentTrans = self.view.uiNode.transform,
		compName = HudSplicingCfg.componentName.hp
	})
	self.npcDuelInCombat = self:getBaseComponentCls(HudSplicingCfg.componentName.npcDuelInCombat).new(self, nil, {
		isAutoLoad = false,
		parentTrans = self.view.uiNode.transform,
		compName = HudSplicingCfg.componentName.npcDuelInCombat
	})
	self.robEggSprite = self:getBaseComponentCls(HudSplicingCfg.componentName.robEggSprite).new(self, nil, {
		isAutoLoad = true,
		parentTrans = self.view.uiNode.transform,
		compName = HudSplicingCfg.componentName.robEggSprite
	})
	self.interactSign = self:getBaseComponentCls(HudSplicingCfg.componentName.interactSign).new(self, nil, {
		isAutoLoad = true,
		parentTrans = self.view.uiWorldNode.transform,
		compName = HudSplicingCfg.componentName.interactSign
	})
	self.switchMode = self:getBaseComponentCls(HudSplicingCfg.componentName.switchMode).new(self, nil, {
		isAutoLoad = false,
		parentTrans = self.view.uiNode.transform,
		compName = HudSplicingCfg.componentName.switchMode
	})
	self.focusFrame = self:getBaseComponentCls(HudSplicingCfg.componentName.focusFrame).new(self, nil, {
		isAutoLoad = true,
		parentTrans = self.view.uiWorldNode.transform,
		compName = HudSplicingCfg.componentName.focusFrame
	})
end

function BaseMDComponent:showNpcDuelInCombat(bol)
	if bol then
		self.npcDuelInCombat:tryShowComponent()
	else
		self.npcDuelInCombat:tryCloseComponent()
	end
end

function BaseMDComponent:showSeamlessVFX()
	if self.switchMode then
		self.switchMode:showSeamlessVFX()
	end
end

function BaseMDComponent:onDestroy()
	HudBaseComponent.onDestroy(self)
end

return BaseMDComponent
