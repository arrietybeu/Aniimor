-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CommonItemTip\\CommonItemTipCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("CommonItemTipCtrl")
local CommonItemTipCtrl = Class.LightClass("CommonItemTipCtrl", UICtrl)
local UIConst = require("Const.UIConst")
local ItemData = require("Data.item_data")
local ItemTypeShowData = require("Data.item_type_show_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local HotkeyConst = require("Const.HotkeyConst")
local ItemConst = require("Common.Const.ItemConst")
local rectTransformUtility = CS.UnityEngine.RectTransformUtility
local TimerManager = require("Core.Timer.TimerManager")
local CONTENT_READY_TIMEOUT = 3

CommonItemTipCtrl.messages = {
	[MessageName.UI_ON_SHOW] = {
		"onUIShow",
		true
	},
	[MessageName.UI_ON_HIDE] = {
		"onUIHide",
		true
	},
	[MessageName.ITEM_GEN_STATUS_LOCKED] = {
		"onItemLockStatusChanged",
		true
	}
}
CommonItemTipCtrl.ITEM_SOURCE_TRIGGER_TYPE = {
	MAP_MARK = 2,
	TIPS = 1
}
CommonItemTipCtrl.ITEM_SOURCE_TRIGGER_FUNC = {
	[CommonItemTipCtrl.ITEM_SOURCE_TRIGGER_TYPE.TIPS] = "showItemSourceTips",
	[CommonItemTipCtrl.ITEM_SOURCE_TRIGGER_TYPE.MAP_MARK] = "markItemSourceInMap"
}

function CommonItemTipCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function CommonItemTipCtrl:addListener()
	UICtrl.addListener(self)
	self.view.gamepadVirtualCloseBtnUButton:SetGamepadAction("Raw/GamepadButtonEast", nil, function()
		if self.iData.extra and self.iData.extra.closeFun then
			self.iData.extra.closeFun()
		end

		self:closePopUpForm()
		self:close()
	end)
	self.view.gamepadVirtualCloseBtnUButton:SetHotkeyBanRay(true)

	function self.view.rootCmp.luaCloseAction()
		if self.iData.extra and self.iData.extra.closeFun then
			self.iData.extra.closeFun()
		end

		self:close()
	end

	function self.view.rootCmp.luaSetScale()
		local scale = Vector3.one * (self.iData.scale or 1)

		self.view.transform.localScale = scale
	end

	self.view.scrollInfo:SetDenyNavScroll(true)
end

function CommonItemTipCtrl:closePopUpForm()
	if self.view and self.view.rootCmp then
		self.view.rootCmp:ClosePopUpForm()
	end
end

function CommonItemTipCtrl:removePendingNavigationPopup()
	local token = self.pendingNavigationPopupToken

	if token == nil then
		return
	end

	self.pendingNavigationPopupToken = nil

	pg.global.navMgr:UnregisterPendingNavigationPopup(token)
end

function CommonItemTipCtrl:bindPendingNavigationPopup()
	local token = self.pendingNavigationPopupToken

	if token == nil then
		return
	end

	self.pendingNavigationPopupToken = nil

	pg.global.navMgr:BindPendingNavigationPopup(token)
end

function CommonItemTipCtrl:registerPendingNavigationPopup(data)
	self:removePendingNavigationPopup()

	if data.navigationPopupOwner == nil or data.targetRect == nil or data.autoClose == false or data.shouldAddGraphicRaycaster == false then
		return
	end

	local token

	token = pg.global.navMgr:RegisterPendingNavigationPopup(data.navigationPopupOwner, function()
		if self.pendingNavigationPopupToken ~= token then
			return
		end

		self.pendingNavigationPopupToken = nil

		self:closeImmediately()
	end)

	if token ~= 0 then
		self.pendingNavigationPopupToken = token
	end
end

function CommonItemTipCtrl:startOpen(info, cb, closeCb)
	self:registerPendingNavigationPopup(info)
	UICtrl.startOpen(self, info, cb, closeCb)
end

function CommonItemTipCtrl:onOpen(data)
	UICtrl.onOpen(self, data)

	self.iData = data

	if self.iData.extra and self.iData.extra.openFun then
		self.iData.extra.openFun()
	end

	if self.iData.enableBtn == nil then
		self.iData.enableBtn = true
	end

	self:refreshView()
end

function CommonItemTipCtrl:checkCanOpen(showNotice, data)
	if data == nil or data.id == nil then
		return false
	end

	self.iData = data

	return true
end

function CommonItemTipCtrl:refreshView()
	if self.iData == nil then
		return
	end

	self:restoreTipOpacity()
	self:cancelPendingTipOpen()

	local outerOnSourceClicked = self.iData.onSourceClicked

	function self.iData.onSourceClicked(data)
		if outerOnSourceClicked then
			outerOnSourceClicked(data)
		end

		local openClueSeekTip = data and data.type == LuaUIUtils.ITEM_SOURCE_TYPE_TIPS

		if not openClueSeekTip then
			if self.iData and self.iData.closeOnJumpToSource then
				self.iData.closeOnJumpToSource(data)
			end

			self:close()
		end
	end

	self.contentReadyToken = (self.contentReadyToken or 0) + 1

	local token = self.contentReadyToken
	local contentReady = false

	function self.iData.onContentReady()
		if self.contentReadyToken ~= token then
			return
		end

		contentReady = true

		if self.tipShownBeforeContentReady then
			self.tipShownBeforeContentReady = false

			self:hideTipForRelayout(token)

			return
		end

		self:onTipContentReady(token)
	end

	LuaUIUtils.refreshItemInfo(self.view.rootCmp, self.iData)

	local autoVer = self.iData.autoVer or false
	local autoHor = self.iData.autoHor or false

	self.view.rootCmp:SetInstanceId("CommonItemTip")
	self.view.rootCmp:SetAutoVertical(autoVer, autoHor)

	if self.iData.verAlign then
		self.view.rootCmp:SetVerAlignment(self.iData.verAlign)
	end

	if self.iData.horAlign then
		self.view.rootCmp:SetHorAlignment(self.iData.horAlign)
	end

	if self.iData.autoClose ~= nil then
		self.view.rootCmp:SetAutoClose(self.iData.autoClose)
	end

	if self.iData.checkTouchBegin ~= nil then
		self.view.rootCmp:SetCheckTouchState(self.iData.checkTouchBegin)
	end

	if self.iData.rayCastParent then
		self.view.rootCmp:AddRayOcclusionMask(self.iData.rayCastParent, self.iData.addSibling or 0)
	end

	if self.iData.fixedHeight then
		local oc = self.view.transform:GetComponent("ObjectReference")
		local scrollRect = oc:GetRefValue("scrollInfo")

		self.view.rootCmp:SetFixedHeight(scrollRect, self.iData.fixedHeight)
	end

	if self.iData.padding ~= nil then
		self.view.rootCmp:SetPadding(self.iData.padding)
	end

	if self.iData.hierarchyMode ~= nil then
		self.view.rootCmp:SetHierarchy(self.iData.hierarchyMode, self.iData.sortingOrder or 1)
	end

	self.view.rootCmp:SetSingleDisplay(self.iData.singleDisplay or false)
	self.view.rootCmp:SetValidateTouchFunc(function(pos)
		if pg.game.guide:isInFocusGuide() then
			return false
		end

		local rt = self.view and self.view.transform

		if rt and rectTransformUtility.RectangleContainsScreenPoint(rt, pos, CS.XGUI.UWidget.uiCamera) then
			return false
		end

		local target = self.iData and self.iData.targetRect
		local targetRt = NotNil(target) and target:GetComponent("RectTransform") or nil

		if NotNil(targetRt) and rectTransformUtility.RectangleContainsScreenPoint(targetRt, pos, CS.XGUI.UWidget.uiCamera) then
			return false
		end

		if self.iData.validateTouch and not self.iData.validateTouch(pos) then
			return false
		end

		return true
	end)

	if self.iData.targetRect then
		if contentReady then
			self:openTipPopup()
		else
			self.pendingOpenToken = token
			self.tipOpacityBackup = self.view.rootCmp.renderOpacity
			self.view.rootCmp.renderOpacity = 0
			self.contentReadyTimer = self:startTimer(function()
				self.contentReadyTimer = nil
				self.tipShownBeforeContentReady = true

				self:onTipContentReady(token)
			end, CONTENT_READY_TIMEOUT)
		end
	end
end

function CommonItemTipCtrl:onTipContentReady(token)
	if self.pendingOpenToken ~= token then
		return
	end

	self.pendingOpenToken = nil

	if self.contentReadyTimer then
		self:killTimer(self.contentReadyTimer)

		self.contentReadyTimer = nil
	end

	if not self:checkUIShow() or self.iData == nil or IsNil(self.iData.targetRect) then
		self:restoreTipOpacity()

		return
	end

	self:hideTipForRelayout(token)
end

function CommonItemTipCtrl:openTipPopup()
	local addGraphicRaycaster = self.iData.shouldAddGraphicRaycaster

	self.view.rootCmp:OpenPopup(self.iData.targetRect, addGraphicRaycaster == nil and true or addGraphicRaycaster)
	self:bindPendingNavigationPopup()

	if addGraphicRaycaster == false then
		self:setIsGamepadModel(false)

		self.view.widget.enableNavRegion = false
	end
end

function CommonItemTipCtrl:restoreTipOpacity()
	if self.view and NotNil(self.view.rootCmp) then
		self.view.rootCmp.renderOpacity = self.tipOpacityBackup or 1
	end
end

function CommonItemTipCtrl:hideTipForRelayout(token)
	if not self.view or IsNil(self.view.rootCmp) then
		return
	end

	self.view.rootCmp.renderOpacity = 0

	if self.relayoutHideFrameId then
		TimerManager.delFrameCb(self.relayoutHideFrameId)
	end

	self.relayoutHideFrameId = self:startFrameTimer(function()
		self.relayoutHideFrameId = nil

		if self.contentReadyToken ~= token then
			return
		end

		if not self:checkUIShow() or self.iData == nil or IsNil(self.iData.targetRect) then
			self:restoreTipOpacity()

			return
		end

		self:openTipPopup()
		self:restoreTipOpacity()
	end, 1)
end

function CommonItemTipCtrl:cancelPendingTipOpen()
	self.pendingOpenToken = nil
	self.tipShownBeforeContentReady = false

	if self.contentReadyTimer then
		self:killTimer(self.contentReadyTimer)

		self.contentReadyTimer = nil
	end

	if self.relayoutHideFrameId then
		TimerManager.delFrameCb(self.relayoutHideFrameId)

		self.relayoutHideFrameId = nil
	end
end

function CommonItemTipCtrl:close()
	self:cancelPendingTipOpen()
	UICtrl.close(self)
end

function CommonItemTipCtrl:closeImmediately()
	self:cancelPendingTipOpen()
	self:removePendingNavigationPopup()
	UICtrl.closeImmediately(self)
end

function CommonItemTipCtrl:onItemLockStatusChanged(info)
	if not info or not self.iData or not self.view or not self.view.rootCmp then
		return
	end

	if self.iData.invId ~= info.invId or self.iData.genID ~= info.genId then
		return
	end

	PetManagementDataHelper.refreshItemTipLockStatusFromInventory(self.view.rootCmp, self.iData)
end

function CommonItemTipCtrl:onDestroy()
	self:cancelPendingTipOpen()
	self:restoreTipOpacity()
	self:removePendingNavigationPopup()
	self:setIsGamepadModel(true)

	self.view.widget.enableNavRegion = true
end

function CommonItemTipCtrl:onUIShow(uid)
	if not self:checkUIShow() or uid == UIConst.UI_ID_COMMON_ITEM_TIP or uid == UIConst.UI_ID_GUIDE_PANEL or uid == UIConst.UI_ID_CLUE_SEEK_TIP then
		return
	end

	self:close()
end

function CommonItemTipCtrl:onUIHide(uid)
	if not self:checkUIShow() or uid == UIConst.UI_ID_GUIDE_PANEL or uid == UIConst.UI_ID_GUIDE_POPUP_PANEL or uid == UIConst.UI_ID_CLUE_SEEK_TIP then
		return
	end

	self:close()
end

return CommonItemTipCtrl
