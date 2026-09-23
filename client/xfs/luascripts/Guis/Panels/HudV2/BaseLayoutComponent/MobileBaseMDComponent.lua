-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseLayoutComponent\\MobileBaseMDComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("MobileBaseMDComponent")
local Class = require("Core.Framework.Class")
local HudSplicingCfg = require("Guis.Panels.HudV2.HudSplicingCfg")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local MobileBaseMDComponent = Class.LightClass("MobileBaseMDComponent", HudBaseComponent)

function MobileBaseMDComponent:findObjects()
	return
end

function MobileBaseMDComponent:initView()
	self:tryRestoreNpcDuelInCombat()
end

function MobileBaseMDComponent:tryRestoreNpcDuelInCombat()
	if not self.npcDuelInCombat then
		return
	end

	local space = pg.me and pg.me.space

	if space and type(space.npcDuelDungeonIsReady) == "function" and space:npcDuelDungeonIsReady() then
		self.npcDuelInCombat:tryShowComponent()
	end
end

function MobileBaseMDComponent:bindComponent()
	self.hpFuse = self:getBaseComponentCls(HudSplicingCfg.componentName.mobileHpFuse).new(self, nil, {
		isAutoLoad = true,
		parentTrans = self.view.uiNode.transform,
		compName = HudSplicingCfg.componentName.mobileHpFuse
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
	self.npcDuelInCombat = self:getBaseComponentCls(HudSplicingCfg.componentName.npcDuelInCombat).new(self, nil, {
		isAutoLoad = false,
		parentTrans = self.view.uiNode.transform,
		compName = HudSplicingCfg.componentName.npcDuelInCombat
	})
end

function MobileBaseMDComponent:showNpcDuelInCombat(bol)
	if bol then
		self.npcDuelInCombat:tryShowComponent()
	else
		self.npcDuelInCombat:tryCloseComponent()
	end
end

function MobileBaseMDComponent:onDestroy()
	HudBaseComponent.onDestroy(self)
end

return MobileBaseMDComponent
