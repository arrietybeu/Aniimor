-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TradeMarketHistoryPet\\TradeMarketHistoryPetCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("TradeMarketHistoryPetCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local TradeMarketUtils = require("Guis.Utils.TradeMarketUtils")
local TradeMarketPetSnapshotDetailComponent = require("Guis.Panels.TradeMarketPetDetail.Component.TradeMarketPetSnapshotDetailComponent")
local TradeMarketHistoryPetCtrl = Class.LightClass("TradeMarketHistoryPetCtrl", UICtrl)

TradeMarketHistoryPetCtrl.messages = {}

function TradeMarketHistoryPetCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.petDetails = TradeMarketPetSnapshotDetailComponent.new(self)
end

function TradeMarketHistoryPetCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:dismiss()
	end

	ClientTextUtils.setText(self.view.tMPUSDFText, pg.getGameString("TRADE_HISTORY"))

	function self.view.btnClick.luaRenderTooltip(btn, tooltip)
		LuaUIUtils.refreshItemInfo(tooltip, {
			itemId = TradeMarketUtils.getTradeCurrency()
		})
	end
end

function TradeMarketHistoryPetCtrl:closeImmediately()
	self:clearPetModel()
	self:restoreBackground()
	UICtrl.closeImmediately(self)
end

function TradeMarketHistoryPetCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function TradeMarketHistoryPetCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	ClientTextUtils.setText(self.view.tMPUSDFText, pg.getGameString("TRADE_HISTORY"))

	self.info = info

	LuaUIUtils.setTopCurrencyItemList(self.view.listCurrencyUList, self.uid)
	self:initView()
end

function TradeMarketHistoryPetCtrl:onShow()
	return
end

function TradeMarketHistoryPetCtrl:onHide()
	return
end

function TradeMarketHistoryPetCtrl:initView()
	if self.uiScene then
		if not self.hasPreviousBackground then
			self.previousBackground = self.uiScene._currentBgType
			self.hasPreviousBackground = true
		end

		self.uiScene:switchBackground("T_LVUIBP_BackGroud_03_CA.png")
	end

	local displayPetData = self.petDetails:refreshPetInfoDetail(self.info.assetSnapshot)

	self:showPetModel(displayPetData or self.info.assetSnapshot)

	self.view.imgIcon.url = TradeMarketUtils.getTradeCurrencyUrlPath()

	ClientTextUtils.setText(self.view.txtNum, self.info.dealPrice)

	local tradedTime = LuaUIUtils.timeStampToUtcString(self.info.dealTs, UIConst.TargetTimeType.Long, false)
	local timeStr

	timeStr = self.info.isBuyer and "PURCHASE" or "SOLD"

	ClientTextUtils.setText(self.view.txtDetailsUSDFText, string.format("%s %s", tradedTime, pg.getGameString(timeStr)))

	if self.info.auditEndTs and self.info.auditEndTs > 0 then
		self.view.reviewUWidget:SetActiveFastest(true)
		LuaUIUtils.setCountDownTime(self.view.countDownUCountDown, self.info.auditEndTs, UIConst.TimeType.Short)
	else
		self.view.reviewUWidget:SetActiveFastest(false)
	end
end

function TradeMarketHistoryPetCtrl:showPetModel(petInfo)
	if not petInfo or not petInfo.templateId or not self.uiScene then
		return
	end

	if self.curPetInfo and self.curPetInfo.templateId ~= petInfo.templateId then
		self.uiScene:destroyPet(self.curPetInfo.templateId)
	end

	self.curPetInfo = petInfo
	self.curPetId = petInfo.id

	local scale, offset = self.model.getPetScaleAndOffset(petInfo.templateId)

	self.uiScene:showPetTemplate(petInfo, scale, offset)

	local entity = self.uiScene:getEntity(petInfo.templateId)

	if entity then
		self.petDetails:applyPetModelAppearance(entity, petInfo)
	end
end

function TradeMarketHistoryPetCtrl:clearPetModel()
	if self.curPetInfo and self.curPetInfo.templateId and self.uiScene then
		self.uiScene:destroyPet(self.curPetInfo.templateId)
	end

	self.curPetInfo = nil
	self.curPetId = nil
end

function TradeMarketHistoryPetCtrl:restoreBackground()
	if self.hasPreviousBackground and self.uiScene then
		self.uiScene:switchBackground(self.previousBackground)
	end

	self.previousBackground = nil
	self.hasPreviousBackground = nil
end

return TradeMarketHistoryPetCtrl
