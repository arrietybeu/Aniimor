-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\Component\\PaidWipeTestComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("PaidWipeTestComponent")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local UIConst = require("Const.UIConst")
local CashShopConst = require("Const.CashShopConst")
local Utils = require("Common.Utils.Utils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local RebateGearData = require("Data.rechage_rebate_gear_data")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local ItemConst = require("Common.Const.ItemConst")
local EventContainerComponent = require("Guis.Panels.Event.Component.EventContainerComponent")
local RechargeUtils = require("GameApp.Recharge.RechargeUtils")
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade
local PaidWipeTestComponent = Class.LightClass("PaidWipeTestComponent", EventContainerComponent)

function PaidWipeTestComponent:findObjects()
	if not self:checkContentLoaded() then
		return
	end

	local objectReference = self.transform:GetChild(0):GetComponent("ObjectReference")

	self.txtStag1 = objectReference:GetRefValue("txtStag1")
	self.txtStag2 = objectReference:GetRefValue("txtStag2")
	self.txtStag3 = objectReference:GetRefValue("txtStag3")
	self.txtStagDesc1 = objectReference:GetRefValue("txtStagDesc1")
	self.txtStagDesc2 = objectReference:GetRefValue("txtStagDesc2")
	self.txtStagDesc3 = objectReference:GetRefValue("txtStagDesc3")
	self.eventTitleUContainer = objectReference:GetRefValue("eventTitleUContainer")
	self.txtRechargeTtitle = objectReference:GetRefValue("txtRechargeTtitle")
	self.txtAmount = objectReference:GetRefValue("txtAmount")
	self.txtSymbol = objectReference:GetRefValue("txtSymbol")
	self.txtReturnTitle = objectReference:GetRefValue("txtReturnTitle")
	self.txtReturnNum = objectReference:GetRefValue("txtReturnNum")
	self.btnGoto = objectReference:GetRefValue("btnGoto")
	self.txtBtnGoto = objectReference:GetRefValue("txtBtnGoto")
	self.buttonUButton = objectReference:GetRefValue("buttonUButton")
	self.button2UButton = objectReference:GetRefValue("button2UButton")
	self.button3UButton = objectReference:GetRefValue("button3UButton")
	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
end

function PaidWipeTestComponent:addListener()
	function self.btnGoto.luaClick()
		if not ClientCashShopUtils.canOpenCashShop() then
			return
		end

		if pg.global.platform:isPS() and RechargeUtils.isEmptyStore() then
			PlatformBridgeLuaFacade.ShowCommonMessageDialogEmptyStore()

			return
		end

		pg.global.ui:open(UIConst.UI_ID_CASH_SHOP, {
			tabId = CashShopConst.CategoryType.RECHARGE
		})
	end

	function self.buttonUButton.luaClick()
		self:onClickReward(self.buttonUButton)
	end

	function self.button2UButton.luaClick()
		self:onClickReward(self.button2UButton)
	end

	function self.button3UButton.luaClick()
		self:onClickReward(self.button3UButton)
	end
end

function PaidWipeTestComponent:onClickReward(btn)
	pg.global.ui.commonItemTip:open({
		id = ItemConst.ITEM_SPECIAL_MONEY_CASH_BOUND,
		targetRect = btn
	})
end

function PaidWipeTestComponent:onContentReady()
	local amont = RebateGearData[1701].endsum
	local rebateRate = RebateGearData[1701].rebateRate

	ClientTextUtils.setText(self.txtStag1, pg.getGameString(pg.getFormatText(pg.getGameString("TOPUPEVEBT_RETURN_TIER1"), amont)))
	ClientTextUtils.setText(self.txtStagDesc1, pg.getGameString(pg.getFormatText(pg.getGameString("TOPUPEVEBT_RETURN_AMOUNT"), rebateRate)))

	local amont2 = RebateGearData[1702].endsum
	local rebateRate2 = RebateGearData[1702].rebateRate

	ClientTextUtils.setText(self.txtStag2, pg.getGameString(pg.getFormatText(pg.getGameString("TOPUPEVEBT_RETURN_TIER2"), amont2)))
	ClientTextUtils.setText(self.txtStagDesc2, pg.getGameString(pg.getFormatText(pg.getGameString("TOPUPEVEBT_RETURN_AMOUNT"), rebateRate2)))
	ClientTextUtils.setText(self.txtStag3, pg.getGameString("TOPUPEVEBT_RETURN_BPCARD"))
	ClientTextUtils.setText(self.txtStagDesc3, pg.getGameString("TOPUPEVEBT_RETURN_BPRULE"))
	ClientTextUtils.setText(self.txtRechargeTtitle, pg.getGameString("TOPUPEVEBT_RETURN_TOTAL"))
	ClientTextUtils.setText(self.txtReturnTitle, pg.getGameString("TOPUPEVEBT_RETURN_OBT"))
	ClientTextUtils.setText(self.txtBtnGoto, pg.getGameString("TOPUPEVEBT_RETURN_GOPOS"))
end

function PaidWipeTestComponent:onBeforeRefreshPage()
	EventContainerComponent.onBeforeRefreshPage(self)

	if self.rootUComponent then
		self.rootUComponent:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
	end
end

function PaidWipeTestComponent:refreshPage()
	local eventTimeCfg = Utils.getEventTimeConfig(self.eventId)
	local eventEndDayTime = eventTimeCfg and eventTimeCfg.tabEndDayTime

	self:setEventTitle(self.eventTitleUContainer, eventEndDayTime)

	local strSymboy = Utils.getRechargeCurrentSymboy()

	if strSymboy then
		ClientTextUtils.setText(self.txtSymbol, pg.getLocalizationText(strSymboy))
	end

	local curActData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.RechargeRebate)
	local rechargeSum = curActData and curActData.rechargeSum or 0

	ClientTextUtils.setText(self.txtAmount, pg.getLocalizationText(rechargeSum))

	local rebate = Utils.getRechargeRebateAmount(rechargeSum)

	ClientTextUtils.setText(self.txtReturnNum, pg.getLocalizationText(rebate))
end

function PaidWipeTestComponent:onDestroy()
	UIComponent.onDestroy(self)
end

return PaidWipeTestComponent
