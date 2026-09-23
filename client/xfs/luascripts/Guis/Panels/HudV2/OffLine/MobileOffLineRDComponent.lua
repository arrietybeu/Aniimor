-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\OffLine\\MobileOffLineRDComponent.lua

local Class = require("Core.Framework.Class")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local HudSplicingCfg = require("Guis.Panels.HudV2.HudSplicingCfg")
local BallBtnComponent = require("Guis.Panels.HudV2.BaseComponent.BallBtnComponent")
local MobileOffLineRDComponent = Class.LightClass("MobileOffLineRDComponent", HudBaseComponent)

function MobileOffLineRDComponent:findObjects()
	return
end

function MobileOffLineRDComponent:initView()
	return
end

function MobileOffLineRDComponent:bindComponent()
	self.ballBtn = BallBtnComponent.new(self, nil, {
		isAutoLoad = true,
		parentTrans = self.view.uiNode.transform,
		compName = HudSplicingCfg.componentName.mobileBallBtn
	})
end

return MobileOffLineRDComponent
