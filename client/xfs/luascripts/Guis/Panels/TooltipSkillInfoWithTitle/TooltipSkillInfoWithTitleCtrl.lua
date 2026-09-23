-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TooltipSkillInfoWithTitle\\TooltipSkillInfoWithTitleCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local LuaUIUtils = require("Utils.LuaUIUtils")
local HotkeyConst = require("Const.HotkeyConst")
local TimerManager = require("Core.Timer.TimerManager")
local TooltipSkillInfoWithTitleCtrl = Class.LightClass("TooltipSkillInfoWithTitleCtrl", UICtrl)

TooltipSkillInfoWithTitleCtrl.messages = {
	[MessageName.UI_ON_HIDE] = {
		"onUIHide",
		true
	}
}

function TooltipSkillInfoWithTitleCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function TooltipSkillInfoWithTitleCtrl:addListener()
	LuaUIUtils.bindHotKey(self.view.gameObject, HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel, function()
		self:close()
	end)

	function self.view.rootCmp.luaCloseAction()
		self:close()
	end

	function self.view.rootCmp.luaSetScale()
		local scale = Vector3.one * (self.iData.scale or 1)

		self.view.transform.localScale = scale
		self.view.popupProxyTransform.localScale = scale
	end
end

function TooltipSkillInfoWithTitleCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function TooltipSkillInfoWithTitleCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.iData = info
end

function TooltipSkillInfoWithTitleCtrl:checkCanOpen(showNotice, data)
	if data == nil then
		return false
	end

	self.iData = data

	return true
end

function TooltipSkillInfoWithTitleCtrl:onUIHide()
	if self:checkUIShow() then
		self:close()
	end
end

function TooltipSkillInfoWithTitleCtrl:renderTooltipSkillInfoWithTitle()
	self.view:renderTooltipSkillInfoWithTitle(self.iData.title, self.iData.infoText, self.iData.detailsList)
end

function TooltipSkillInfoWithTitleCtrl:onShow()
	if self.iData == nil then
		return
	end

	self:renderTooltipSkillInfoWithTitle()

	self.view.widget.renderOpacity = 0

	local data = self.iData

	TimerManager.addNextFrameCb(function()
		if self.iData ~= data or not self:checkUIShow() or not self.view or IsNil(self.view.widget) then
			return
		end

		if IsNil(data.targetRect) then
			self.view.widget.renderOpacity = 1

			return
		end

		local tooltipRectTransform = self.view.transform
		local popupProxyTransform = self.view.popupProxyTransform

		popupProxyTransform.pivot = tooltipRectTransform.pivot
		popupProxyTransform.sizeDelta = Vector2(tooltipRectTransform.rect.width, tooltipRectTransform.rect.height)

		self.view.rootCmp:SetAutoVertical(data.autoVer or false, data.autoHor or false)
		self.view.rootCmp:OpenPopup(data.targetRect)
		tooltipRectTransform:SetPivotEx(popupProxyTransform.pivot.x, popupProxyTransform.pivot.y)

		tooltipRectTransform.position = popupProxyTransform.position

		if data.tooltipAnchor then
			LuaUIUtils.alignTooltipToAnchorLeftTop(self.view.widget, data.tooltipAnchor)
		end

		self.view.widget.renderOpacity = 1
	end)
end

function TooltipSkillInfoWithTitleCtrl:onHide()
	return
end

return TooltipSkillInfoWithTitleCtrl
