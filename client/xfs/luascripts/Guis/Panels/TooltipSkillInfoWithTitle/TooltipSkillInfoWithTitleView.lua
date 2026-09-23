-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TooltipSkillInfoWithTitle\\TooltipSkillInfoWithTitleView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TooltipSkillInfoWithTitleView = Class.LightClass("TooltipSkillInfoWithTitleView", UIView)

function TooltipSkillInfoWithTitleView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.txtTitle = self.objectReference:GetRefValue("txtTitle")
	self.txtNum = self.objectReference:GetRefValue("txtNum")
	self.txtDesc = self.objectReference:GetRefValue("txtDesc")
	self.listDetailsUList = self.objectReference:GetRefValue("listDetailsUList")
	self.popupProxyObject = CS.UnityEngine.GameObject("TooltipSkillInfoWithTitlePopupProxy", typeof(CS.UnityEngine.RectTransform))
	self.popupProxyObject.layer = self.gameObject.layer
	self.popupProxyTransform = self.popupProxyObject.transform

	self.popupProxyTransform:SetParent(self.transform.parent, false)

	self.rootCmp = self.popupProxyObject:AddComponent(typeof(CS.XGUI.UPopupForm))
end

function TooltipSkillInfoWithTitleView:registerObjects()
	return
end

function TooltipSkillInfoWithTitleView:initView()
	return
end

function TooltipSkillInfoWithTitleView:renderTooltipSkillInfoWithTitle(title, desc, detailsList)
	self.widget:TryChangePage("Btn", 0)
	self.widget:TryChangePage("headTitle", 1)
	ClientTextUtils.setText(self.txtTitle, title)
	ClientTextUtils.setText(self.txtNum, "")
	ClientTextUtils.setText(self.txtDesc, desc)

	detailsList = detailsList or {}

	self.listDetailsUList.gameObject:SetActiveEx(#detailsList > 0)

	function self.listDetailsUList.luaRenderItem(button, _, data)
		local itemObjectReference = button:GetComponent("ObjectReference")
		local txtDetailsUSDFText = itemObjectReference:GetRefValue("txtDetailsUSDFText")

		ClientTextUtils.setText(txtDetailsUSDFText, data.text)
	end

	self.listDetailsUList:SetList(detailsList)
end

function TooltipSkillInfoWithTitleView:onDestroy()
	if NotNil(self.popupProxyObject) then
		CS.UnityEngine.Object.Destroy(self.popupProxyObject)
	end

	self.popupProxyObject = nil
	self.popupProxyTransform = nil
	self.rootCmp = nil
end

return TooltipSkillInfoWithTitleView
