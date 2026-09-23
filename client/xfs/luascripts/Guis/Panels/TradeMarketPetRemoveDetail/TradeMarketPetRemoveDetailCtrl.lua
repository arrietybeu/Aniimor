-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TradeMarketPetRemoveDetail\\TradeMarketPetRemoveDetailCtrl.lua

local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local TradeMarketUtils = require("Guis.Utils.TradeMarketUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TradeMarketPetDetailBaseCtrl = require("Guis.Panels.TradeMarketPetDetail.TradeMarketPetDetailBaseCtrl")
local NoticeDef = require("Common.NoticeDef")
local MessageName = require("Const.MessageName")
local TradeMarketPetSnapshotDetailComponent = require("Guis.Panels.TradeMarketPetDetail.Component.TradeMarketPetSnapshotDetailComponent")
local TradeMarketPetRemoveDetailCtrl = Class.LightClass("TradeMarketPetRemoveDetailCtrl", TradeMarketPetDetailBaseCtrl)

TradeMarketPetRemoveDetailCtrl.messages = {
	[MessageName.ON_GET_TRADE_LISTINGS] = {
		"onGetTradeListings",
		true
	}
}

function TradeMarketPetRemoveDetailCtrl:createPetDetailComponent()
	return TradeMarketPetSnapshotDetailComponent.new(self)
end

function TradeMarketPetRemoveDetailCtrl:addListener()
	TradeMarketPetRemoveDetailCtrl.super.addListener(self)

	function self.view.btnPurchaseUButton.luaClick()
		self:onRemoveClicked()
	end

	function self.view.listPetUList.luaClick(button, data)
		if not data or not data.listingId then
			return
		end

		TradeMarketUtils.openBuyPetDetailUI(data.tradeItemId or self.petTemplateId, data)
	end
end

function TradeMarketPetRemoveDetailCtrl:onOpen(info)
	self.petData = info.petData
	self.listingData = info.listingData

	TradeMarketPetRemoveDetailCtrl.super.onOpen(self, info)
	self.view.widget:TryChangePage("Launch", 0)
	self.view.listCoinsUList:SetActiveFastest(true)
	ClientTextUtils.setText(self.view.btnTxtNameUText, pg.getGameString("BTN_CANCEL_SELL"))
	ClientTextUtils.setText(self.view.titleUSDFText, pg.getGameString("TRADE_PET_REMOVE_TITLE"))
	self:refreshPetDetailView()
end

function TradeMarketPetRemoveDetailCtrl:refreshPetDetailView()
	local petInfo = self.petData and (self.petData.petInfo or self.petData)

	if not petInfo or not petInfo.templateId then
		self:refreshPetDetail({
			isEmpty = true
		})

		return
	end

	self:refreshPetDetail(petInfo, petInfo)
end

function TradeMarketPetRemoveDetailCtrl:onRemoveClicked()
	if self.isRemoving or not self.listingData or not self.listingData.listingId then
		return
	end

	self.isRemoving = true

	pg.me:reqRemoveTradeItem(self.listingData.listingId, function(noticeCode)
		self.isRemoving = false

		if noticeCode ~= NoticeDef.SUCCESS then
			return
		end

		pg.global.ui.tips:showTextTip(pg.getGameString("TRADE_REMOVE_OK_TIP"))
		self:dismiss()
	end)
end

function TradeMarketPetRemoveDetailCtrl:onDestroy()
	self.view.btnSortUButton.luaClick = nil
	self.view.listTab3thUList.luaRenderItem = nil
	self.view.listTab3thUList.luaClick = nil
	self.view.btnPurchaseUButton.luaClick = nil
	self.view.listPetUList.luaClick = nil
	self.petData = nil
	self.listingData = nil
	self.isRemoving = nil

	TradeMarketPetRemoveDetailCtrl.super.onDestroy(self)
end

return TradeMarketPetRemoveDetailCtrl
