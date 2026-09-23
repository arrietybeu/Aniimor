-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PvpBattle\\Component\\PvpPrepareComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local PvpPrepareComponent = Class.LightClass("PvpPrepareComponent", UIComponent)

function PvpPrepareComponent:findObjects()
	self.anim = self.transform:GetComponent("Animation")
end

function PvpPrepareComponent:initView()
	self:hide()
end

function PvpPrepareComponent:startCountDown()
	self:show()
	pg.game.audio:triggerEvent("SFX_UI_PVP_Countdown")
	self.anim:Play("VX_Pb_PVP_StartCountDown_On")
end

function PvpPrepareComponent:endCountDown()
	self:hide()
end

return PvpPrepareComponent
