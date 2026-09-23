-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\SwitchModeUIComponent.lua

local Class = require("Core.Framework.Class")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local SwitchModeUIComponent = Class.LightClass("SwitchModeUIComponent", HudBaseComponent)

function SwitchModeUIComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.uIPbSwitchAnimation = objectReference:GetRefValue("uIPbSwitchAnimation")
end

function SwitchModeUIComponent:initView()
	self:playSeamlessVFX()
end

function SwitchModeUIComponent:showSeamlessVFX()
	if self:tryShowComponent() then
		self:playSeamlessVFX()
	end
end

function SwitchModeUIComponent:playSeamlessVFX()
	UIUtils.PlayAnimation(self.uIPbSwitchAnimation, "VX_Ani_Switch_In", function()
		self:tryCloseComponent()
	end)
	pg.game.effect:playEffect(nil, "Eff_Seamless_Cross", nil, true)
end

function SwitchModeUIComponent:onDestroy()
	HudBaseComponent.onDestroy(self)
end

return SwitchModeUIComponent
