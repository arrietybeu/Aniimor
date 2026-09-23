-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BpGift\\BpGiftCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("BpGiftCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local BattlePassData = require("Data.event_battlepass_data")
local RechargeUtils = require("GameApp.Recharge.RechargeUtils")
local RechargeConst = require("GameApp.Recharge.RechargeConst")
local BpGiftCtrl = Class.LightClass("BpGiftCtrl", UICtrl)
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade

BpGiftCtrl.messages = {}

function BpGiftCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function BpGiftCtrl:addListener()
	local view = self.view

	if view.btnBGClose then
		function view.btnBGClose.luaClick()
			self:dismiss()
		end
	end

	if view.btnClose then
		function view.btnClose.luaClick()
			self:dismiss()
		end
	end

	if view.listUList then
		function view.listUList.luaRenderItem(button, _, data)
			self:_renderTierItem(button, data)
		end

		function view.listUList.luaClick(button, data)
			if data then
				if self._selectedButton then
					self._selectedButton:SetSelected(false)
				end

				self._selectedIndex = data.index
				self._selectedButton = button

				button:SetSelected(true)
			end
		end
	end

	if view.btnConfirm then
		function view.btnConfirm.luaClick()
			self:_onConfirm()
		end
	end
end

function BpGiftCtrl:onDestroy()
	self._destroyed = true

	UICtrl.onDestroy(self)

	if PlatformBridgeLuaFacade:supportsCommerce() then
		PlatformBridgeLuaFacade.HideStoreIcon()
	end
end

function BpGiftCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	if PlatformBridgeLuaFacade:supportsCommerce() then
		PlatformBridgeLuaFacade.DisplayStoreIcon(3)
	end
end

function BpGiftCtrl:onShow()
	self._destroyed = false

	local view = self.view

	if view.textUBaseText then
		ClientTextUtils.setText(view.textUBaseText, pg.getGameString("BATTLEPASS_GIFT_TITLE"))
	end

	if view.txtSendBtn then
		ClientTextUtils.setText(view.txtSendBtn, pg.getGameString("BATTLEPASS_GIFT_CHOOSE"))
	end

	self._selectedIndex = 1

	local actData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.BattlePass)
	local phase = actData and actData.activityBase and actData.activityBase.activityPhase

	self._bpData = phase and BattlePassData[phase]
	self._tierList = self:_buildTierList()

	if view.listUList then
		view.listUList:SetList(self._tierList)
	end
end

function BpGiftCtrl:_buildTierList()
	local bpData = self._bpData

	if not bpData then
		return {}
	end

	local list = {}
	local info1 = RechargeUtils.getProductsInfo(RechargeConst.RECHARGE_TYPE.BP, RechargeConst.RECHARGE_BP_TYPE.NORMAL)
	local price1 = ""

	if info1 and info1.sdkInfo then
		price1 = RechargeUtils.getProductsPrice(info1)
	end

	list[#list + 1] = {
		index = 1,
		commodityId = bpData.battlePassTier1Id,
		name = bpData.tierName1 and pg.getLocalizationText(bpData.tierName1) or "",
		price = price1,
		productInfo = info1,
		img = bpData.advancedImage and bpData.advancedImage[1]
	}

	local info2 = RechargeUtils.getProductsInfo(RechargeConst.RECHARGE_TYPE.BP, RechargeConst.RECHARGE_BP_TYPE.ADVANCED)
	local price2 = ""

	if info2 and info2.sdkInfo then
		price2 = RechargeUtils.getProductsPrice(info2)
	end

	list[#list + 1] = {
		index = 2,
		commodityId = bpData.battlePassTier2Id,
		name = bpData.tierName2 and pg.getLocalizationText(bpData.tierName2) or "",
		price = price2,
		productInfo = info2,
		img = bpData.collectionImage and bpData.collectionImage[1]
	}

	return list
end

function BpGiftCtrl:_renderTierItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")

	if not objectReference then
		return
	end

	local txtName = objectReference:GetRefValue("txtNameUBaseText")
	local txtPrice = objectReference:GetRefValue("txtUBaseText")
	local bgUImage = objectReference:GetRefValue("bgUImage")

	if txtName then
		ClientTextUtils.setText(txtName, data.name or "")
	end

	if txtPrice then
		ClientTextUtils.setText(txtPrice, data.price or "")
	end

	if bgUImage and data.img then
		bgUImage.url = data.img
	end

	local isSelected = data.index == self._selectedIndex

	button:SetSelected(isSelected)

	if isSelected then
		self._selectedButton = button
	end
end

function BpGiftCtrl:_onConfirm()
	local item = self._tierList and self._tierList[self._selectedIndex or 1]

	if not item then
		return
	end

	local view = self.view

	if view.btnConfirm then
		view.btnConfirm.interactable = false
	end

	local friendList = pg.game.chat:getFriendList() or {}
	local friendIds = {}

	for _, friend in ipairs(friendList) do
		friendIds[#friendIds + 1] = friend.playerId
	end

	self.model:requestFriendBpStatus(friendIds, function(hasGiftMap)
		if self._destroyed then
			return
		end

		facade:sendMsgToUI(MessageName.BATTLEPASS_SHOW_GIFT_FRIEND_LIST, {
			commodityId = item.commodityId,
			productInfo = item.productInfo,
			hasGiftMap = hasGiftMap
		})
		self:dismiss()
	end)
end

function BpGiftCtrl:onHide()
	return
end

return BpGiftCtrl
