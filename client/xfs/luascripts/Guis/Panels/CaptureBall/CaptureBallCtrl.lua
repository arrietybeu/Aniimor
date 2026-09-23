-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CaptureBall\\CaptureBallCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("CaptureBallCtrl")
local CaptureBallPCComponent = require("Guis.Panels.CaptureBall.Component.CaptureBallPCComponent")
local CaptureBallMobileComponent = require("Guis.Panels.CaptureBall.Component.CaptureBallMobileComponent")
local AimUIComponent = require("Guis.Panels.CaptureBall.Component.AimUIComponent")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientUtils = require("Utils.ClientUtils")
local ClientConst = require("Const.ClientConst")
local CaptureConst = require("Common.Const.CaptureConst")
local CaptureBallCtrl = Class.LightClass("CaptureBallCtrl", UICtrl)

CaptureBallCtrl.messages = {
	[MessageName.CATCH_MODE_CHANGE_UI] = {
		"onCatchModeChange",
		true
	},
	[MessageName.CATCH_LOCK_PUPPET_MSG] = {
		"onCatchLockPuppetMsg",
		true
	},
	[MessageName.ITEM_COUNT_MAP_CHANGE] = {
		"refreshInfo",
		true
	},
	[MessageName.ON_NOTIFY_ITEM] = {
		"refreshInfo",
		true
	},
	[MessageName.ON_BACKPACK_QUICK_BALL_CHANGE] = {
		"refreshInfo",
		true
	}
}

function CaptureBallCtrl:onCreate(info)
	self.itemListInitialized = false
	self.normalItemList = {}
	self.paidItemList = {}
	self.normalSelectCastItem = nil
	self.paidSelectCastItem = nil
	self.activeBar = CaptureConst.BALL_BAR_TYPE.NORMAL
	self.curSelectCastItem = nil
	self.curItemList = self.normalItemList
	self._keepNormalSlotEmptyUntilCatchExit = nil

	UICtrl.onCreate(self, info)
end

function CaptureBallCtrl:onOpen()
	if not pg.me or not pg.me.isInCatchMode or not pg.me:isInCatchMode() then
		self:hide()

		return
	end

	if pg.me.isThrowItem and pg.me:isThrowItem() then
		self:hide()

		return
	end
end

function CaptureBallCtrl:onShow()
	if not pg.me or not pg.me.isInCatchMode or not pg.me:isInCatchMode() then
		self:hide()

		return
	end

	if pg.me.isThrowItem and pg.me:isThrowItem() then
		self:hide()

		return
	end

	local currentContextItemId = pg.me.currentContext and pg.me.currentContext.itemId

	self:_refreshInfo(false, currentContextItemId)

	if not self.captureBallComponent then
		self:loadPlatformComponent()
	else
		self.captureBallComponent:refreshSelectItemData(self.curSelectCastItem)
	end

	if not self.aim then
		self.aim = AimUIComponent.new(self, self.view.catchAimObjectReference.transform)
	end

	if self._pendingAimVisible ~= nil then
		self.aim:switchAimVisible(self._pendingAimVisible)

		self._pendingAimVisible = nil
	end

	if pg.me and pg.me.isInCatchMode and pg.me:isInCatchMode() then
		self.aim:_syncLockStateFromCamera()
	end
end

function CaptureBallCtrl:onSwitchCatchBall()
	self:refreshItemList()
	self:refreshSelectItemData()
end

function CaptureBallCtrl:loadPlatformComponent()
	if pg.global.ui:runPlatformByMobile() then
		local container = self.view.mobileUContainer

		if not IsNil(container.content) then
			self.captureBallComponent = CaptureBallMobileComponent.new(self, container.content.transform)

			self:applyPendingThrowItemMode()
		else
			container:LoadDefaultUrlManually(function()
				self.captureBallComponent = CaptureBallMobileComponent.new(self, container.content.transform)

				self:applyPendingThrowItemMode()
			end)
		end
	else
		local container = self.view.pcUContainer

		if not IsNil(container.content) then
			self.captureBallComponent = CaptureBallPCComponent.new(self, container.content.transform)

			self:applyPendingThrowItemMode()
		else
			container:LoadDefaultUrlManually(function()
				self.captureBallComponent = CaptureBallPCComponent.new(self, container.content.transform)

				self:applyPendingThrowItemMode()
			end)
		end
	end
end

function CaptureBallCtrl:applyPendingThrowItemMode()
	if self._pendingThrowItemMode ~= nil and self.captureBallComponent and self.captureBallComponent.onThrowItemMode then
		self.captureBallComponent:onThrowItemMode(self._pendingThrowItemMode)

		self._pendingThrowItemMode = nil
	end

	if self._pendingFastThrowMode ~= nil and self.captureBallComponent and self.captureBallComponent.setFastThrowMode then
		self.captureBallComponent:setFastThrowMode(self._pendingFastThrowMode)

		self._pendingFastThrowMode = nil
	end
end

function CaptureBallCtrl:onCatchModeChange(enable)
	if self.aim and self.aim.onCatchModeChange then
		self.aim:onCatchModeChange(enable)
	end

	if not enable then
		self._keepNormalSlotEmptyUntilCatchExit = nil

		self:resetBarFocus()
		self:refreshSelectItemData()
		self:hide()
	end
end

function CaptureBallCtrl:onCatchLockPuppetMsg(isLock, isInField)
	if self.aim and self.aim.catchLockPuppetMsg then
		self.aim:catchLockPuppetMsg(isLock, isInField)
	end

	if self.captureBallComponent and self.captureBallComponent.onCatchLockPuppetMsg then
		self.captureBallComponent:onCatchLockPuppetMsg(isLock, isInField)
	end
end

function CaptureBallCtrl:onDestroy()
	UICtrl.onDestroy(self)

	self.captureBallComponent = nil
	self.aim = nil
	self.normalItemList = nil
	self.paidItemList = nil
	self.itemListInitialized = nil
	self.normalSelectCastItem = nil
	self.paidSelectCastItem = nil
	self.curItemList = nil
	self.curSelectCastItem = nil
	self._pendingAimVisible = nil
	self._pendingThrowItemMode = nil
	self._pendingFastThrowMode = nil
	self._keepNormalSlotEmptyUntilCatchExit = nil
end

function CaptureBallCtrl:refreshInfo()
	self:_refreshInfo(true)
end

function CaptureBallCtrl:_refreshInfo(shouldNotifySwitch, preferredItemId)
	local oldActiveBar = self.activeBar
	local oldActiveItemId = self.curSelectCastItem and self.curSelectCastItem.itemId
	local keepNormalSlotEmpty = self:_shouldKeepNormalSlotEmptyAfterFastThrow(oldActiveBar, oldActiveItemId)

	self:refreshItemList(preferredItemId, keepNormalSlotEmpty)

	local newActiveItemId = self.curSelectCastItem and self.curSelectCastItem.itemId

	self:refreshSelectItemData()

	if shouldNotifySwitch and newActiveItemId and (oldActiveBar ~= self.activeBar or oldActiveItemId ~= newActiveItemId) and pg.game.controller.onHandleSwitchProp then
		pg.game.controller:onHandleSwitchProp()
	end

	if self.captureBallComponent then
		if pg.global.ui:runPlatformByMobile() then
			self.captureBallComponent:refreshBallPanelList()
		else
			self.captureBallComponent:refreshInfo()
		end
	end
end

function CaptureBallCtrl:onFocusChanged(focus)
	if self.captureBallComponent and not pg.global.ui:runPlatformByMobile() then
		self.captureBallComponent:onFocusChanged(focus)
	end
end

function CaptureBallCtrl:refreshThrowItemInfo(itemId)
	if self.captureBallComponent and self.captureBallComponent.refreshThrowItemInfo then
		self.captureBallComponent:refreshThrowItemInfo(itemId)
	end
end

function CaptureBallCtrl:onThrowItemMode(isThrow)
	if self.captureBallComponent and self.captureBallComponent.onThrowItemMode then
		self.captureBallComponent:onThrowItemMode(isThrow)

		self._pendingThrowItemMode = nil
	else
		self._pendingThrowItemMode = isThrow or nil
	end

	self:switchAimVisible(not isThrow)
end

function CaptureBallCtrl:setFastThrowMode(enable)
	if self.captureBallComponent and self.captureBallComponent.setFastThrowMode then
		self.captureBallComponent:setFastThrowMode(enable)

		self._pendingFastThrowMode = nil
	else
		self._pendingFastThrowMode = enable or nil
	end
end

function CaptureBallCtrl:_shouldKeepNormalSlotEmptyAfterFastThrow(oldActiveBar, oldActiveItemId)
	if self._keepNormalSlotEmptyUntilCatchExit then
		return true
	end

	if oldActiveBar ~= CaptureConst.BALL_BAR_TYPE.NORMAL or not oldActiveItemId or ClientUtils.getItemCountById(oldActiveItemId) > 0 then
		return false
	end

	local ballBtnComp = pg.global.ui.hudV2 and pg.global.ui.hudV2.RD and pg.global.ui.hudV2.RD.ballBtn
	local shouldKeepNormalSlotEmpty = ballBtnComp and ballBtnComp.checkFastThrowMode and ballBtnComp:checkFastThrowMode() or false

	if shouldKeepNormalSlotEmpty then
		self._keepNormalSlotEmptyUntilCatchExit = true
	end

	return shouldKeepNormalSlotEmpty
end

function CaptureBallCtrl:refreshItemList(preferredItemId, keepNormalSlotEmpty)
	local oldNormalItemId = self.normalSelectCastItem and self.normalSelectCastItem.itemId
	local oldPaidItemId = self.paidSelectCastItem and self.paidSelectCastItem.itemId

	self.normalItemList = {}
	self.paidItemList = {}

	table.mergeList(self.normalItemList, self.model:getCapturePropInfos())
	table.mergeList(self.paidItemList, self.model:getPaidCapturePropInfos())

	if self:_findValidItemById(self.normalItemList, preferredItemId) then
		oldNormalItemId = preferredItemId
		self.activeBar = CaptureConst.BALL_BAR_TYPE.NORMAL
	elseif self:_findValidItemById(self.paidItemList, preferredItemId) then
		oldPaidItemId = preferredItemId
		self.activeBar = CaptureConst.BALL_BAR_TYPE.PAID
	end

	self:_reconcileBarSelections(oldNormalItemId, oldPaidItemId, keepNormalSlotEmpty)

	self.itemListInitialized = true
end

function CaptureBallCtrl:_findItemById(itemList, itemId)
	if not itemId then
		return nil
	end

	for _, item in ipairs(itemList or EMPTY_TABLE) do
		if item.itemId == itemId then
			return item
		end
	end

	return nil
end

function CaptureBallCtrl:_findValidItemById(itemList, itemId)
	local item = self:_findItemById(itemList, itemId)

	if item and ClientUtils.getItemCountById(item.itemId) > 0 then
		return item
	end

	return nil
end

function CaptureBallCtrl:_findFirstValidItem(itemList)
	for _, item in ipairs(itemList or EMPTY_TABLE) do
		if item.itemId and ClientUtils.getItemCountById(item.itemId) > 0 then
			return item
		end
	end

	return nil
end

function CaptureBallCtrl:_reconcileBarSelections(oldNormalItemId, oldPaidItemId, keepNormalSlotEmpty)
	self.normalSelectCastItem = self:_findValidItemById(self.normalItemList, oldNormalItemId)

	if not self.normalSelectCastItem then
		local selectItemId = pg.global.prefsCacheUtils:getInt(ClientConst.PrefKey.CatchSelectItemId, nil)

		self.normalSelectCastItem = self:_findValidItemById(self.normalItemList, selectItemId) or self:_findFirstValidItem(self.normalItemList)
	end

	self.paidSelectCastItem = self:_findValidItemById(self.paidItemList, oldPaidItemId) or self:_findFirstValidItem(self.paidItemList)

	if self.activeBar == CaptureConst.BALL_BAR_TYPE.PAID then
		if not self.paidSelectCastItem then
			self.activeBar = CaptureConst.BALL_BAR_TYPE.NORMAL
		end
	elseif not self.normalSelectCastItem and self.paidSelectCastItem then
		self.activeBar = CaptureConst.BALL_BAR_TYPE.NORMAL
	end

	if not self.normalSelectCastItem and not self.paidSelectCastItem then
		self.activeBar = CaptureConst.BALL_BAR_TYPE.NORMAL
	end

	if keepNormalSlotEmpty then
		self.activeBar = CaptureConst.BALL_BAR_TYPE.NORMAL
		self.curItemList = self.normalItemList
		self.curSelectCastItem = nil
	else
		self:_syncActiveBarState()
	end
end

function CaptureBallCtrl:_syncActiveBarState()
	self.curItemList = self:getItemList(self.activeBar)
	self.curSelectCastItem = self:getSelectItem(self.activeBar)
end

function CaptureBallCtrl:getActiveBar()
	return self.activeBar
end

function CaptureBallCtrl:getItemList(barType)
	barType = barType or self.activeBar

	if barType == CaptureConst.BALL_BAR_TYPE.PAID then
		return self.paidItemList
	end

	return self.normalItemList
end

function CaptureBallCtrl:getSelectItem(barType)
	barType = barType or self.activeBar

	if barType == CaptureConst.BALL_BAR_TYPE.PAID then
		return self.paidSelectCastItem
	end

	return self.normalSelectCastItem
end

function CaptureBallCtrl:canSwitchBar()
	return self.normalSelectCastItem ~= nil and self.paidSelectCastItem ~= nil
end

function CaptureBallCtrl:switchActiveBar()
	if not self:canSwitchBar() then
		return false
	end

	if self.activeBar == CaptureConst.BALL_BAR_TYPE.NORMAL then
		self.activeBar = CaptureConst.BALL_BAR_TYPE.PAID
	else
		self.activeBar = CaptureConst.BALL_BAR_TYPE.NORMAL
	end

	self:_syncActiveBarState()
	self:refreshSelectItemData()

	if pg.game.controller.onHandleSwitchProp then
		pg.game.controller:onHandleSwitchProp()
	end

	return true
end

function CaptureBallCtrl:resetBarFocus()
	self.activeBar = CaptureConst.BALL_BAR_TYPE.NORMAL
	self.paidSelectCastItem = nil

	self:_syncActiveBarState()
end

function CaptureBallCtrl:isPaidBarActive()
	return self.activeBar == CaptureConst.BALL_BAR_TYPE.PAID
end

function CaptureBallCtrl:getBarViewState()
	return {
		normalList = self.normalItemList,
		paidList = self.paidItemList,
		normalSelectedItem = self.normalSelectCastItem,
		paidSelectedItem = self.paidSelectCastItem,
		activeBar = self.activeBar,
		showSwitchBarHint = self:canSwitchBar(),
		isPaidBarActive = self:isPaidBarActive()
	}
end

function CaptureBallCtrl:checkItemIndexValid(itemIndex)
	return itemIndex > 0 and itemIndex <= #self.curItemList
end

function CaptureBallCtrl:selectItem(itemIndex, barType)
	barType = barType or self.activeBar

	local itemList = self:getItemList(barType)

	if #itemList == 0 then
		return 0
	end

	itemIndex = math.clamp(itemIndex, 1, #itemList)

	if self:realSelectItem(itemIndex, barType) then
		return itemIndex
	end

	return 0
end

function CaptureBallCtrl:getCurIndex()
	for itemIndex = 1, #self.curItemList do
		local ballItem = self.curItemList[itemIndex]

		if self.curSelectCastItem and self.curSelectCastItem.itemId == ballItem.itemId then
			return itemIndex
		end
	end

	return 0
end

function CaptureBallCtrl:selectItemById(itemId, barType)
	if not itemId or ClientUtils.getItemCountById(itemId) <= 0 then
		return
	end

	barType = barType or self.activeBar

	local itemList = self:getItemList(barType)

	if itemList then
		for i, item in ipairs(itemList) do
			if item.itemId == itemId then
				self:selectItem(i, barType)

				return
			end
		end
	end
end

function CaptureBallCtrl:realSelectItem(itemIndex, barType)
	barType = barType or self.activeBar

	local itemList = self:getItemList(barType)

	if #itemList == 0 then
		return false
	end

	itemIndex = math.clamp(itemIndex, 1, #itemList)

	local newCastItem = itemList[itemIndex]

	if not newCastItem then
		return false
	end

	local oldCastItem = self:getSelectItem(barType)

	if oldCastItem and oldCastItem.itemId == newCastItem.itemId and self.activeBar == barType then
		return false
	end

	if barType == CaptureConst.BALL_BAR_TYPE.PAID then
		self.paidSelectCastItem = newCastItem
	else
		self.normalSelectCastItem = newCastItem

		pg.global.prefsCacheUtils:setInt(ClientConst.PrefKey.CatchSelectItemId, newCastItem.itemId)
	end

	self.activeBar = barType

	self:_syncActiveBarState()
	self:refreshSelectItemData()

	if pg.game.controller.onHandleSwitchProp then
		pg.game.controller:onHandleSwitchProp()
	end

	return true
end

function CaptureBallCtrl:refreshSelectItemData()
	if self.itemListInitialized == false or self.itemListInitialized == nil and self.normalItemList == nil then
		return
	end

	if self.captureBallComponent then
		self.captureBallComponent:refreshSelectItemData(self.curSelectCastItem)
	end

	local ballComp = pg.global.ui.hudV2 and pg.global.ui.hudV2.LD and pg.global.ui.hudV2.LD.ball

	if ballComp then
		ballComp:syncSelectedItem(self.curSelectCastItem)
	end

	local ballBtnComp = pg.global.ui.hudV2 and pg.global.ui.hudV2.RD and pg.global.ui.hudV2.RD.ballBtn

	if ballBtnComp then
		ballBtnComp:syncSelectedItem(self.curSelectCastItem and self.curSelectCastItem.itemId)
	end
end

function CaptureBallCtrl:selectDefault()
	if #self.curItemList == 0 then
		return
	end

	self:selectItem(1)
end

function CaptureBallCtrl:getCurSelectPropId()
	if self.curSelectCastItem then
		return self.curSelectCastItem.itemId
	end

	return nil
end

function CaptureBallCtrl:switchAimVisible(visible)
	if self.aim then
		self.aim:switchAimVisible(visible)
	else
		self._pendingAimVisible = visible
	end
end

function CaptureBallCtrl:onSwitchBigDriveBallMode(bigDriveBall)
	if bigDriveBall then
		self:hide()
	elseif pg.me and pg.me:isInCatchMode() and not pg.me:isFastThrowPresentationFinished() then
		self:show()
	end
end

return CaptureBallCtrl
