-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseLayoutComponent\\BaseMUComponent.lua

local Class = require("Core.Framework.Class")
local HudSplicingCfg = require("Guis.Panels.HudV2.HudSplicingCfg")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local BaseMUComponent = Class.LightClass("BaseMUComponent", HudBaseComponent)

function BaseMUComponent:bindComponent()
	self.chatBullet = self:getBaseComponentCls(HudSplicingCfg.componentName.chatBullet).new(self, nil, {
		isFixRoot = true,
		compName = HudSplicingCfg.componentName.chatBullet
	})
end

function BaseMUComponent:onDestroy()
	HudBaseComponent.onDestroy(self)
end

return BaseMUComponent
