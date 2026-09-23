-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BpPurchase\\BpPurchaseCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local RechargeUtils = require("GameApp.Recharge.RechargeUtils")
local RechargeConst = require("GameApp.Recharge.RechargeConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local CashShopConst = require("Const.CashShopConst")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local MessageName = require("Const.MessageName")
local LuaUIUtils = require("Utils.LuaUIUtils")
local logger = require("Core.Log.LoggerManager").getLogger("BpPurchaseCtrl")
local BattlePassData = require("Data.event_battlepass_data")
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade
local AvatarPreviewComponent = require("Guis.Panels.CashShop.Component.AvatarPreviewComponent")
local BpPurchaseCtrl = Class.LightClass("BpPurchaseCtrl", UICtrl)

BpPurchaseCtrl.messages = {
	[MessageName.BATTLEPASS_CHANGE] = {
		"onBattlePassChange",
		true
	},
	[MessageName.CASH_SHOP_REWARD_CHANGED] = {
		"_refreshBPInfo",
		true
	},
	[MessageName.COMMON_SWITCH_STATE_CHANGED] = {
		"_refreshMoneyList",
		true
	}
}

function BpPurchaseCtrl:_showBattlePassPet(actionType)
	if not self.avatarComponent then
		return
	end

	local actData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.BattlePass)

	if not actData then
		return
	end

	local phase = actData.activityBase and actData.activityBase.activityPhase
	local bpData = phase and BattlePassData[phase]

	if not bpData or not bpData.passPetModelingId then
		return
	end

	local movementIds = bpData.passPetMovementId
	local animKey = movementIds and movementIds[actionType]
	local posXYZ = bpData.postionIndex and bpData.postionIndex[actionType]
	local rotXYZ = bpData.rotationIndex and bpData.rotationIndex[actionType]
	local scaleXYZ = bpData.scaleIndex and bpData.scaleIndex[actionType]

	self.avatarComponent:showPetByModelingId(bpData.passPetModelingId, animKey, posXYZ, rotXYZ, scaleXYZ)
end

function BpPurchaseCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.avatarComponent = AvatarPreviewComponent.new(self, self.view.transform, {
		disableCameraZoom = true,
		presetKey = pg.game.avatar:getPresetKey(pg.me),
		sceneType = UISceneConst.BP_PURCHASE_SCENE
	})
end

function BpPurchaseCtrl:addListener()
	local view = self.view

	if view.btnBack then
		function view.btnBack.luaClick()
			self:dismiss()
		end
	end
end

function BpPurchaseCtrl:onDestroy()
	if self.avatarComponent then
		self.avatarComponent:onDestroy()

		self.avatarComponent = nil
	end

	UICtrl.onDestroy(self)
end

function BpPurchaseCtrl:onOpen(info)
	self._closeRequested = false
	self._destroyRequested = false

	UICtrl.onOpen(self, info)
end

function BpPurchaseCtrl:close()
	if self._closeRequested then
		return
	end

	self._closeRequested = true

	UICtrl.close(self)
end

function BpPurchaseCtrl:closeImmediately()
	if self._destroyRequested then
		return
	end

	self._closeRequested = true
	self._destroyRequested = true

	UICtrl.closeImmediately(self)
end

function BpPurchaseCtrl:onShow()
	local view = self.view

	if not view.rootUComponent then
		return
	end

	pg.game.audio:triggerEvent("SFX_BP_PURCHASE_In")
	ClientTextUtils.setText(view.txtBackName, pg.getGameString("BATTLEPASS_MAIN_TITLE"))
	self:_refreshBPInfo()
	self:_showBattlePassPet(CashShopConst.PetActionType.BattlePassPurchase)
	self:DisplayStoreIcon()
	self:_refreshMoneyList()
end

function BpPurchaseCtrl:_refreshMoneyList()
	RechargeUtils.setupMoneyList(self.view.moneyListUButton)
end

function BpPurchaseCtrl:_onBuyClick(bpType)
	local rechargeInfo = RechargeUtils.getProductsInfo(RechargeConst.RECHARGE_TYPE.BP, bpType)

	if rechargeInfo then
		pg.game.recharge:requestBuy(rechargeInfo.packageId, rechargeInfo.productId, rechargeInfo.cfgInfo and rechargeInfo.cfgInfo.des or "")
	end
end

function BpPurchaseCtrl:_refreshBPInfo()
	local view = self.view

	if not view.rootUComponent then
		return
	end

	ClientCashShopUtils.renderBPInfo(view.rootUComponent.transform, function(bpType)
		self:_onBuyClick(bpType)
	end)
end

function BpPurchaseCtrl:onBattlePassChange(data)
	self:_refreshBPInfo()
	LuaUIUtils.tryOpenBattlePassUnlockPopup(data)
end

function BpPurchaseCtrl:onHide()
	self:HideStoreIcon()
end

function BpPurchaseCtrl:DisplayStoreIcon()
	pg.setPSIconUIVisiable("BpPurchaseCtrl", true)

	if PlatformBridgeLuaFacade:supportsCommerce() then
		PlatformBridgeLuaFacade.DisplayStoreIcon(2)
	end
end

function BpPurchaseCtrl:HideStoreIcon()
	if pg.setPSIconUIVisiable("BpPurchaseCtrl", false) == false and PlatformBridgeLuaFacade:supportsCommerce() then
		PlatformBridgeLuaFacade.HideStoreIcon()
	end
end

function BpPurchaseCtrl:onVisibleChange(visible)
	if self.avatarComponent then
		if visible then
			self.avatarComponent:registerGesture(self.view and self.view.maskRayBoxTrans)
		else
			self.avatarComponent:unRegisterGesture()
		end
	end

	logger:info("BpPurchaseCtrl:onVisibleChange visible:%s", tostring(visible))
end

return BpPurchaseCtrl
