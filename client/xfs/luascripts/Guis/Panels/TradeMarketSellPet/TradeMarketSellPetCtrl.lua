-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TradeMarketSellPet\\TradeMarketSellPetCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("TradeMarketSellPetCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local LuaUIUtils = require("Utils.LuaUIUtils")
local TradeMarketUtils = require("Guis.Utils.TradeMarketUtils")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local NoticeDef = require("Common.NoticeDef")
local TradeMarketSellPetDetailComponent = require("Guis.Panels.TradeMarketSellPet.Component.TradeMarketSellPetDetailComponent")
local TimerManager = require("Core.Timer.TimerManager")
local Time = require("Core.Common.Time")
local TradeMarketSellPetCtrl = Class.LightClass("TradeMarketSellPetCtrl", UICtrl)

TradeMarketSellPetCtrl.messages = {
	[MessageName.ON_GET_TRADE_MY_ON_SALE] = {
		"onGetMyListings",
		true
	}
}

function TradeMarketSellPetCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.petDetails = TradeMarketSellPetDetailComponent.new(self)
end

function TradeMarketSellPetCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:dismiss()
	end

	function self.view.listPetUList.luaRenderItem(button, index, data)
		TradeMarketUtils.renderMyOnSellPetItem(button, index, data)
	end

	function self.view.listPetUList.luaClick(button, data)
		if not data or data.isEmpty then
			return
		end

		TradeMarketUtils.openRemovePetDetailUI(data)
	end

	function self.view.listPet2UList.luaRenderItem(button, index, data)
		TradeMarketUtils.renderPetItem(button, index, data)
	end

	function self.view.listPet2UList.luaClick(button, data)
		self:_setBagItemSelect(button)
		self:refreshPetPanel(data)
	end

	function self.view.btnConfirmUButton.luaClick()
		local data = self._curSelectData

		if not data or data.isEmpty or data.isFrozen == true then
			return
		end

		if data.needWash == true then
			LuaUIUtils.petManagementSelectPet(data.id)

			return
		end

		if data.canSell ~= true or self._hasRemainCount ~= true then
			return
		end

		TradeMarketUtils.openSellPetDetailUI(data)
	end

	function self.view.btnHistoryUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_TRADE_MARKET_HISTORY)
	end

	self.view.btnInfoUButton.enabledTooltip = false

	function self.view.btnInfoUButton.luaClick()
		pg.global.ui.tips:openCommonPopUpTipById(43)
	end
end

function TradeMarketSellPetCtrl:onDestroy()
	self:_clearFreezeRefreshTimer()
	UICtrl.onDestroy(self)

	self._curSelectBtn = nil
	self._curSelectData = nil
	self._hasRemainCount = nil
end

function TradeMarketSellPetCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self._curSelectBtn = nil
	self._curSelectData = nil
	self._hasRemainCount = false
	self.hasShown = false
end

function TradeMarketSellPetCtrl:onShow()
	self.hasShown = true

	self:refreshViewData()
end

function TradeMarketSellPetCtrl:onVisibleChange(visible)
	if visible and self.hasShown then
		self:refreshViewData()
	else
		self:_clearFreezeRefreshTimer()
	end
end

function TradeMarketSellPetCtrl:refreshViewData()
	self:initView()
	pg.me:reqGetMyListings(function(code, data)
		if code == NoticeDef.SUCCESS and data then
			self:onGetMyListings(data)
		end
	end)
end

function TradeMarketSellPetCtrl:onGetMyListings(data)
	local sellingData, sellingCount = self.model:getSellingData(data and data.listings)

	self.view.listPetUList:SetList(sellingData)

	local maxCount = TradeMarketUtils.getPetSellMaxCount()

	ClientTextUtils.setText(self.view.txtNumUSDFText, string.format("%d/%d", sellingCount, maxCount))

	self._hasRemainCount = sellingCount < maxCount

	self:refreshSellState()
end

function TradeMarketSellPetCtrl:onHide()
	self:_clearFreezeRefreshTimer()
end

function TradeMarketSellPetCtrl:initView()
	self._curSelectBtn = nil
	self._curSelectData = nil
	self._hasRemainCount = false

	ClientTextUtils.setText(self.view.tMPUSDFText, pg.getGameString("TITLE_PET_SELL"))
	ClientTextUtils.setText(self.view.historyTxtNameUText, pg.getGameString("TRADE_HISTORY"))
	ClientTextUtils.setText(self.view.confirmTxtNameUText, pg.getGameString("DECOMPOSE"))
	ClientTextUtils.setText(self.view.txtTitleUSDFText, pg.getGameString("TRADE_ON_SALE_TITLE"))
	ClientTextUtils.setText(self.view.txtNumUSDFText, string.format("%d/%d", 0, TradeMarketUtils.getPetSellMaxCount()))
	LuaUIUtils.setTopCurrencyItemList(self.view.listCurrencyUList, self.uid)
	self.view.tipsUWidget:SetActiveFastest(false)
	self.view.btnConfirmUButton:SetActiveFastest(true)

	self.view.btnConfirmUButton.visualInteractable = false

	ClientTextUtils.setText(self.view.textRequireUSDFText, "")
	self:refreshPetBagData()
end

function TradeMarketSellPetCtrl:refreshPetBagData()
	self._curSelectBtn = nil
	self._curSelectData = nil

	local petsData = self.model:getCanSellPetData()

	self.view.listPet2UList:SetList(petsData)
	self:_scheduleFreezeRefresh(petsData)

	local res, btn = self.view.listPet2UList:TryGetChildAt(0)

	if res then
		btn:OnClickSimulate()
	else
		self:refreshPetPanel(nil)
	end
end

function TradeMarketSellPetCtrl:_clearFreezeRefreshTimer()
	if self._freezeRefreshTimer then
		TimerManager.removeTimer(self._freezeRefreshTimer)

		self._freezeRefreshTimer = nil
	end
end

function TradeMarketSellPetCtrl:_scheduleFreezeRefresh(petsData)
	self:_clearFreezeRefreshTimer()

	local curTimeTs = Time.secondCache or Time.getSecond()
	local nearestEndTs

	for _, data in ipairs(petsData or EMPTY_TABLE) do
		if data.isFrozen == true and data.frozenEndTs and curTimeTs < data.frozenEndTs and (not nearestEndTs or nearestEndTs > data.frozenEndTs) then
			nearestEndTs = data.frozenEndTs
		end
	end

	if nearestEndTs then
		self._freezeRefreshTimer = TimerManager.addTimer(math.max(nearestEndTs - curTimeTs, 0.1), function()
			self._freezeRefreshTimer = nil

			self:refreshPetBagData()
		end)
	end
end

function TradeMarketSellPetCtrl:refreshPetPanel(data)
	self._curSelectData = data

	if not data or data.isEmpty then
		self.petDetails:refreshPetInfoDetail({
			isEmpty = true
		})
		self:refreshSellState()

		return
	end

	self.petDetails:refreshPetInfoDetail(data)
	self:refreshSellState()
end

function TradeMarketSellPetCtrl:refreshSellState()
	local data = self._curSelectData
	local hasPetData = data ~= nil and not data.isEmpty
	local isFrozen = hasPetData and data.isFrozen == true
	local needWash = hasPetData and data.needWash == true and not isFrozen
	local canInteract = hasPetData and not isFrozen and (needWash or data.canSell == true and self._hasRemainCount == true)
	local disabledReasonKey = hasPetData and data.sellDisabledReasonKey or nil
	local showTips = disabledReasonKey ~= nil

	self.view.btnConfirmUButton:SetActiveFastest(true)

	self.view.btnConfirmUButton.visualInteractable = canInteract

	ClientTextUtils.setText(self.view.confirmTxtNameUText, pg.getGameString(needWash and "GOTO_TRAIN" or "DECOMPOSE"))
	self.view.tipsUWidget:SetActiveFastest(showTips)
	ClientTextUtils.setText(self.view.textRequireUSDFText, showTips and pg.getGameString(disabledReasonKey) or "")
end

function TradeMarketSellPetCtrl:renderBagItem(button, index, data)
	button.draggable = false
	button.luaBeginDrag = nil
	button.luaEndDrag = nil

	local objectReference = button:GetComponent("ObjectReference")
	local petIdDisplay = objectReference:GetRefValue("petIdDisplay")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local priceIconUImage = objectReference:GetRefValue("priceIconUImage")
	local numCPUSDFText = objectReference:GetRefValue("numCPUSDFText")
	local listTagUList = objectReference:GetRefValue("listTagUList")
	local frozenUContainer = objectReference:GetRefValue("frozenUContainer")
	local disableUContainer = objectReference:GetRefValue("disableUContainer")
	local attentionUContainer = objectReference:GetRefValue("attentionUContainer")
	local priceUWidget = objectReference:GetRefValue("priceUWidget")

	frozenUContainer:SetActiveFastest(false)
	disableUContainer:SetActiveFastest(false)
	attentionUContainer:SetActiveFastest(false)
	priceUWidget:SetActiveFastest(false)

	if not data or data.isEmpty then
		return
	end

	frozenUContainer:SetActiveFastest(data.isFrozen == true)
	disableUContainer:SetActiveFastest(data.needWash == true and data.isFrozen ~= true)

	iconUImage.url = LuaUIUtils.getPetIcon(data.iconName, LuaUIUtils.PET_ICON, data.label, data.gender)

	function listTagUList.luaRenderItem(tagButton, tagIndex, tagData)
		LuaUIUtils.renderPetTagList(tagButton, tagData)
		LuaUIUtils.setPetTagLabelToolTip(tagButton, LuaUIUtils.getPetTagInfo(data.templateId, data.label, data.bodySizeType, data.shinyStyle))
	end

	listTagUList:SetList(LuaUIUtils.getPetTagList(data))
end

function TradeMarketSellPetCtrl:_setBagItemSelect(newBtn)
	if self._curSelectBtn == newBtn then
		return
	end

	if self._curSelectBtn then
		self._curSelectBtn:SetSelected(false)
	end

	self._curSelectBtn = newBtn

	self._curSelectBtn:SetSelected(true)
end

return TradeMarketSellPetCtrl
