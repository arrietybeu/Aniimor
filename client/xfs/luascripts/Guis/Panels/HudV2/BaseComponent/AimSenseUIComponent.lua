-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\AimSenseUIComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("AimSenseUIComponent")
local Class = require("Core.Framework.Class")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local UIUtils = UIUtils
local STABLE_GROUND_LAYERS = CS.FunPlus.WorldX.Const.LayerDefine.STABLE_GROUND_LAYERS
local AimSenseUIComponent = Class.LightClass("AimSenseUIComponent", HudBaseComponent)

function AimSenseUIComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.panelRectTransform = objectReference:GetRefValue("panelRectTransform")
end

function AimSenseUIComponent:initView()
	local panelRectTransform = self.panelRectTransform
	local aimSenseRadiusSqr = (panelRectTransform.rect.width * 0.5)^2 + (panelRectTransform.rect.height * 0.5)^2

	function pg.me.checkAimSenseFun(worldPos)
		if UIUtils.CheckInViewPort(worldPos) then
			local localPos = UIUtils.WorldToUILocalPosition(worldPos, panelRectTransform)
			local valid = localPos.x^2 + localPos.y^2 < aimSenseRadiusSqr

			return valid and not pg.global.physicsMgr:CheckCameraRaycastToPosEx(worldPos.x, worldPos.y, worldPos.z, STABLE_GROUND_LAYERS)
		end
	end

	self.uWidget:SetActive(self.senseVisible or false)
end

function AimSenseUIComponent:onEnterAimSense()
	self:setSenseVisible(true)
	self:tryShowComponent()
end

function AimSenseUIComponent:onLeaveAimSense()
	self:setSenseVisible(false)
end

function AimSenseUIComponent:setSenseVisible(value)
	self.senseVisible = value

	if self.uWidget then
		self.uWidget:SetActive(value)
	end
end

function AimSenseUIComponent:onDestroy()
	HudBaseComponent.onDestroy(self)
end

return AimSenseUIComponent
