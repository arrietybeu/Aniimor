-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TradeMarketSellPet\\TradeMarketSellPetView.lua

local logger = require("Core.Log.LoggerManager").getLogger("TradeMarketSellPetView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local TradeMarketSellPetView = Class.LightClass("TradeMarketSellPetView", UIView)

function TradeMarketSellPetView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.tMPUSDFText = objectReference:GetRefValue("tMPUSDFText")
	self.listCurrencyUList = objectReference:GetRefValue("listCurrencyUList")
	self.txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	self.btnInfoUButton = objectReference:GetRefValue("btnInfoUButton")
	self.listPetUList = objectReference:GetRefValue("listPetUList")
	self.txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
	self.listPet2UList = objectReference:GetRefValue("listPet2UList")
	self.btnHistoryUButton = objectReference:GetRefValue("btnHistoryUButton")
	self.tipsUWidget = objectReference:GetRefValue("tipsUWidget")
	self.textRequireUSDFText = objectReference:GetRefValue("textRequireUSDFText")
	self.btnConfirmUButton = objectReference:GetRefValue("btnConfirmUButton")
	self.txtBoothFeeUSDFText = objectReference:GetRefValue("txtBoothFeeUSDFText")
	self.numSelectorUNumSelector = objectReference:GetRefValue("numSelectorUNumSelector")
	self.petInfoPanelObjectReference = objectReference:GetRefValue("petInfoPanelObjectReference")

	self:_findRightPanelObjects(self.petInfoPanelObjectReference)

	local historyOC = self.btnHistoryUButton:GetComponent("ObjectReference")

	self.historyTxtNameUText = historyOC:GetRefValue("txtNameUText")

	local confirmBtnOC = self.btnConfirmUButton:GetComponent("ObjectReference")

	self.confirmTxtNameUText = confirmBtnOC:GetRefValue("txtNameUText")
end

function TradeMarketSellPetView:_findRightPanelObjects(objectReference)
	self.panelAbilityUContainer = objectReference:GetRefValue("panelAbilityUContainer")
	self.panelSkillUContainer = objectReference:GetRefValue("panelSkillUContainer")
	self.panelInfoUContainer = objectReference:GetRefValue("panelInfoUContainer")
	self.rightPanelUComponent = objectReference:GetRefValue("rightPanelUComponent")
	self.attributeBtn = objectReference:GetRefValue("attributeBtn")
	self.skillBtn = objectReference:GetRefValue("skillBtn")
	self.infoBtn = objectReference:GetRefValue("infoBtn")
end

function TradeMarketSellPetView:registerObjects()
	return
end

function TradeMarketSellPetView:initView()
	return
end

return TradeMarketSellPetView
