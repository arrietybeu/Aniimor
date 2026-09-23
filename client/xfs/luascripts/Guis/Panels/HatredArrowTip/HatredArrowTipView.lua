-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HatredArrowTip\\HatredArrowTipView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local HatredArrowTipView = Class.LightClass("HatredArrowTipView", UIView)
local GameObject = CS.UnityEngine.GameObject

function HatredArrowTipView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.arrowRegionRectTransform = self.objectReference:GetRefValue("arrowRegionRectTransform")
	self.dangerRectTransform = self.objectReference:GetRefValue("dangerRectTransform")
	self.questRectTransform = self.objectReference:GetRefValue("questRectTransform")
	self.dangerTransform = self.objectReference:GetRefValue("dangerTransform")
	self.runAcrossRectTransform = self.objectReference:GetRefValue("runAcrossRectTransform")
end

function HatredArrowTipView:registerObjects()
	return
end

function HatredArrowTipView:initView()
	local function inner(i)
		local name = string.format("markerListTransformLayer%s", i)

		self[name] = GameObject(string.format("Layer%s", i))

		local rectTrans = self[name]:AddComponent(typeof(CS.UnityEngine.RectTransform))

		rectTrans:SetParent(self.transform, false)

		rectTrans.localPosition = Vector3.zero
		rectTrans.localScale = Vector3.one
		rectTrans.anchorMin = Vector2.zero
		rectTrans.anchorMax = Vector2.one
		rectTrans.sizeDelta = Vector2.zero
	end

	for i = 0, 8 do
		inner(i)
	end

	inner(99)
	inner(100)
end

return HatredArrowTipView
