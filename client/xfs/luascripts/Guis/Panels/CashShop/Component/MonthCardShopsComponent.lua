-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CashShop\\Component\\MonthCardShopsComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("MonthCardShopsComponent")
local Class = require("Core.Framework.Class")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local RechargeUtils = require("GameApp.Recharge.RechargeUtils")
local RechargeConst = require("GameApp.Recharge.RechargeConst")
local CashShopConst = require("Const.CashShopConst")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local BattlePassData = require("Data.event_battlepass_data")
local CashShopContainerComponent = require("Guis.Panels.CashShop.Component.CashShopContainerComponent")
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade
local MonthCardShopsComponent = Class.LightClass("MonthCardShopsComponent", CashShopContainerComponent)

function MonthCardShopsComponent:findObjects()
	if not self:checkContentLoaded() then
		return
	end

	CashShopContainerComponent.findObjects(self)

	local objectReference = self.transform:GetChild(0):GetComponent("ObjectReference")

	self.monthlyCard = objectReference:GetRefValue("monthlyCard")
	self.battlePassTransform = objectReference:GetRefValue("battlePassTransform")
	self.rootUComponent = objectReference:GetRefValue("rootUComponent")

	local battlePassObjectReference = self.battlePassTransform:GetComponent("ObjectReference")

	self.moneyListUButton = battlePassObjectReference:GetRefValue("moneyListUButton")
end

function MonthCardShopsComponent:refreshPage()
	if not self:checkContentLoaded() then
		return
	end

	local actData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.BattlePass)
	local phase = actData and actData.activityBase and actData.activityBase.activityPhase or 0
	local bpActive = phase ~= 0

	if not bpActive and self._groupList then
		local curShopType = self._currentGroupData and self._currentGroupData.shopType

		if curShopType and curShopType - 1 == CashShopConst.CardShopType.BattlePass then
			for i, g in ipairs(self._groupList) do
				if g.shopType and g.shopType - 1 == CashShopConst.CardShopType.MonthCard then
					self._currentGroupData = g
					self._currentGroupId = g.id
					self.categoryId = g.id

					if self.listGroupTab then
						self.listGroupTab:SelectItem(i - 1)
					end

					break
				end
			end
		end
	end

	local showType = self._currentGroupData and self._currentGroupData.shopType
	local showIndex = (showType or CashShopConst.CardShopType.MonthCard + 1) - 1

	if not bpActive then
		if self.listGroupTab then
			self.listGroupTab.gameObject:SetActiveEx(false)
		end

		showIndex = CashShopConst.CardShopType.MonthCard
	elseif self.listGroupTab and self._groupList and #self._groupList > 0 then
		self.listGroupTab.gameObject:SetActiveEx(true)
	end

	local showBattlePass = showIndex == CashShopConst.CardShopType.BattlePass

	self.rootUComponent:TryChangePage("Type", showIndex)

	local cashShopMoneyList = self.ctrl.view.moneyListUButton

	cashShopMoneyList.gameObject:SetActiveEx(not showBattlePass)
	self.moneyListUButton.gameObject:SetActiveEx(showBattlePass)
	RechargeUtils.setupMoneyList(showBattlePass and self.moneyListUButton or cashShopMoneyList)
	self:_syncEnvironment(showBattlePass)

	if showIndex == CashShopConst.CardShopType.MonthCard then
		self._showingBP = false

		if self.monthlyCard then
			local productInfo = RechargeUtils.getProductsInfo()

			LuaUIUtils.renderMonthCard(self.monthlyCard, function()
				self.ctrl:showFriendList(30023, productInfo)
			end)

			local avatarComponent = self.ctrl.avatarComponent

			if avatarComponent then
				avatarComponent:hideAllEntities()
			end

			self._showingModel = false

			self:_syncBackground()
		end
	else
		local avatarComponent = self.ctrl.avatarComponent

		if avatarComponent then
			local actData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.BattlePass)
			local phase = actData and actData.activityBase and actData.activityBase.activityPhase
			local bpData = phase and BattlePassData[phase]

			if bpData and bpData.passPetModelingId then
				local idx = CashShopConst.PetActionType.CashShop
				local animKey = bpData.passPetMovementId and bpData.passPetMovementId[idx]
				local posXYZ = bpData.postionIndex and bpData.postionIndex[idx]
				local rotXYZ = bpData.rotationIndex and bpData.rotationIndex[idx]
				local scaleXYZ = bpData.scaleIndex and bpData.scaleIndex[idx]

				avatarComponent:showPetByModelingId(bpData.passPetModelingId, animKey, posXYZ, rotXYZ, scaleXYZ)
			end
		end

		self._showingBP = true

		if self.battlePassTransform then
			ClientCashShopUtils.renderBPInfo(self.battlePassTransform, function(type)
				local rechargeInfo = RechargeUtils.getProductsInfo(RechargeConst.RECHARGE_TYPE.BP, type)

				if rechargeInfo then
					pg.game.recharge:requestBuy(rechargeInfo.packageId, rechargeInfo.productId, rechargeInfo.cfgInfo and rechargeInfo.cfgInfo.des or "", CashShopConst.CategoryType.MONTHLYCARD)
				end
			end)
		end
	end

	if self.ctrl._refreshBPRotateConsoleBar then
		self.ctrl:_refreshBPRotateConsoleBar()
	end
end

function MonthCardShopsComponent:isShowingBP()
	return self._showingBP == true
end

function MonthCardShopsComponent:_getMonthCardInvokeTarget()
	return self.rootUComponent
end

function MonthCardShopsComponent:onBattlePassChange()
	self:refreshPage()
end

function MonthCardShopsComponent:HideStoreIcon()
	if pg.setPSIconUIVisiable("MonthCardShopsComponent", false) == false and PlatformBridgeLuaFacade.supportsCommerce() then
		PlatformBridgeLuaFacade.HideStoreIcon()
	end
end

function MonthCardShopsComponent:ShowStoreIcon()
	if PlatformBridgeLuaFacade.supportsCommerce() then
		PlatformBridgeLuaFacade.DisplayStoreIcon(1)
	end

	pg.setPSIconUIVisiable("MonthCardShopsComponent", true)
end

function MonthCardShopsComponent:onExitPage()
	self.entered = false

	CashShopContainerComponent.onExitPage(self)

	local cashShopMoneyList = self.ctrl.view.moneyListUButton

	cashShopMoneyList.gameObject:SetActiveEx(true)

	if self._showingBP then
		RechargeUtils.setupMoneyList(cashShopMoneyList)
	end

	self:HideStoreIcon()
end

function MonthCardShopsComponent:onEnterPage(tabId)
	self.entered = true

	CashShopContainerComponent.onEnterPage(self, tabId)
	self:ShowStoreIcon()
end

function MonthCardShopsComponent:onDestroy()
	self.entered = false

	CashShopContainerComponent.onDestroy(self)
	self:HideStoreIcon()
end

function MonthCardShopsComponent:onVisibleChange(visible)
	logger:info("MonthCardShopsComponent:onVisibleChange visible:%s, self.entered:%s", tostring(visible), tostring(self.entered))
	CashShopContainerComponent.onVisibleChange(self, visible)

	if visible and self.entered then
		self:ShowStoreIcon()
	else
		self:HideStoreIcon()
	end
end

return MonthCardShopsComponent
