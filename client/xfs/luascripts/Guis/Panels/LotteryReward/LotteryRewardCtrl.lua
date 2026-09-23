-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\LotteryReward\\LotteryRewardCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local Utils = require("Common.Utils.Utils")
local UIConst = require("Const.UIConst")
local HotkeyConst = require("Const.HotkeyConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LotteryRewardModel = require("Guis.Panels.LotteryReward.LotteryRewardModel")
local CallbackHandler = require("Core.Common.CallbackHandler")
local LotteryRewardCtrl = Class.LightClass("LotteryRewardCtrl", UICtrl)

LotteryRewardCtrl.modelClz = LotteryRewardModel
LotteryRewardCtrl.messages = {}

function LotteryRewardCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function LotteryRewardCtrl:addListener()
	function self.view.closeBtn.luaClick()
		self:closeReward()
	end

	function self.view.btnConfirm.luaClick()
		self:drawAgain()
	end

	function self.view.btnShare.luaClick()
		self:openRewardShare()
	end

	self:addNavFocusListener(CallbackHandler(self, "refreshItemListConsoleBarState"), "LotteryRewardItemList")
end

function LotteryRewardCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self._drawAgainRequested = false
	self._openInfo = Utils.isTable(info) and info or {}
	self._viewData = self.model:buildViewData(self._openInfo)

	self.view:setInfo(self._viewData)
	ClientTextUtils.setText(self.view.txtBtnConfirm, self.model:getDrawButtonText(self._viewData.drawCount))
	self:refreshConfirmGamepad()
	self:refreshItemListConsoleBarState()
end

function LotteryRewardCtrl:setItemListConsoleBarState(show)
	local consoleBar = CS.XGUI.Navigation.ConsoleBar

	if not consoleBar or not consoleBar.SetStateForAll then
		return
	end

	consoleBar.SetStateForAll("Show", show == true)
end

function LotteryRewardCtrl:isFocusOnItemList()
	if not pg.game.input:isUsingGamepad() then
		return false
	end

	local navMgr = CS.XGUI.Navigation.NavManager.Instance
	local itemList = self.view and self.view.itemList or nil
	local focusedItem = navMgr and navMgr.CurrentFocusedUContent or nil

	if not itemList or not focusedItem or IsNil(focusedItem) then
		return false
	end

	local buttons = itemList:GetAllButtons()

	if not buttons then
		return false
	end

	for index = 0, buttons.Length - 1 do
		if buttons[index] == focusedItem then
			return true
		end
	end

	return false
end

function LotteryRewardCtrl:refreshItemListConsoleBarState()
	self:setItemListConsoleBarState(self:isFocusOnItemList())
end

function LotteryRewardCtrl:refreshConfirmGamepad()
	local button = self.view and self.view.btnConfirm or nil

	if not button or IsNil(button) then
		return
	end

	local drawCount = self._viewData and tonumber(self._viewData.drawCount) or 1
	local actionPath = drawCount == 10 and HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonNorth or HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadButtonWest
	local hotKeyContentObject
	local objectReference = button:GetComponent("ObjectReference")
	local hotKeyContent = objectReference and objectReference:GetRefValue("keyHotKeyContent") or nil

	if hotKeyContent and not IsNil(hotKeyContent) then
		hotKeyContentObject = hotKeyContent.gameObject
	else
		local keyTransform = button.transform:Find("LayoutBox/Key") or button.transform:Find("PanelText/Key") or button.transform:Find("Key")

		if keyTransform and not IsNil(keyTransform) then
			hotKeyContentObject = keyTransform.gameObject
		end
	end

	if hotKeyContentObject then
		button:SetGamepadAction(actionPath, hotKeyContentObject)
	else
		button:SetGamepadAction(actionPath)
	end
end

function LotteryRewardCtrl:openRewardShare()
	if not self._viewData or not self._viewData.shareReward then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_LOTTERY_REWARD_SHARE, {
		drawId = self._openInfo.drawId,
		drawItems = self._openInfo.drawItems,
		rewardItem = self._viewData.shareReward,
		shareCallback = function(shareInfo)
			self:onShareSuccess(shareInfo)
		end
	})
end

function LotteryRewardCtrl:onShareSuccess(shareInfo)
	if not self._viewData then
		return
	end

	local curCanShareCount = self.model:getCurCanShareCount(self._openInfo and self._openInfo.drawId)

	self._viewData.curCanShareCount = curCanShareCount
	self._viewData.canShare = self._viewData.shareReward ~= nil and curCanShareCount > 0

	if Utils.isTable(shareInfo) then
		shareInfo.curCanShareCount = curCanShareCount
	end

	self.view:setInfo(self._viewData)

	local shareCallback = self._openInfo.shareCallback

	if type(shareCallback) == "function" then
		shareCallback(shareInfo)
	end
end

function LotteryRewardCtrl:drawAgain()
	if self._drawAgainRequested then
		return
	end

	local drawAgainCallback = self._openInfo and self._openInfo.drawAgainCallback or nil

	if type(drawAgainCallback) ~= "function" then
		self:closeReward()

		return
	end

	self._drawAgainRequested = true

	local drawCount = self._viewData and self._viewData.drawCount or 1
	local skipAnimation = self._openInfo and self._openInfo.skipAnimation == true

	self:dismiss()
	drawAgainCallback(drawCount, skipAnimation)
end

function LotteryRewardCtrl:closeReward()
	local closeCallback = self._openInfo and self._openInfo.closeCallback or nil

	self:dismiss()

	if type(closeCallback) == "function" then
		closeCallback()
	end
end

function LotteryRewardCtrl:onHide()
	self:setItemListConsoleBarState(false)
	UICtrl.onHide(self)
end

function LotteryRewardCtrl:onDestroy()
	self:setItemListConsoleBarState(false)

	self._openInfo = nil
	self._viewData = nil
	self._drawAgainRequested = nil

	UICtrl.onDestroy(self)
end

return LotteryRewardCtrl
