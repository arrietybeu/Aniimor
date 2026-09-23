-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TradeMarketPetDetail\\TradeMarketPetDetailBaseView.lua

local logger = require("Core.Log.LoggerManager").getLogger("TradeMarketPetDetailBaseView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local TradeMarketPetDetailBaseView = Class.LightClass("TradeMarketPetDetailBaseView", UIView)

function TradeMarketPetDetailBaseView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.titleUSDFText = objectReference:GetRefValue("titleUSDFText")
	self.listCurrencyUList = objectReference:GetRefValue("listCurrencyUList")
	self.listTab3thUList = objectReference:GetRefValue("listTab3thUList")
	self.listPetUList = objectReference:GetRefValue("listPetUList")
	self.btnSortUButton = objectReference:GetRefValue("btnSortUButton")
	self.petInfoPanelObjectReference = objectReference:GetRefValue("petInfoPanelObjectReference")
	self.listCoinsUList = objectReference:GetRefValue("listCoinsUList")
	self.btnPurchaseUButton = objectReference:GetRefValue("btnPurchaseUButton")
	self.txtTipsUSDFText = objectReference:GetRefValue("txtTipsUSDFText")
	self.numSelectorUNumSelector = objectReference:GetRefValue("numSelectorUNumSelector")
	self.txtBoothFeeUSDFText = objectReference:GetRefValue("txtBoothFeeUSDFText")
	self.btnAttentionUButton = objectReference:GetRefValue("btnAttentionUButton")
	self.progressAttentionUProgress = objectReference:GetRefValue("progressAttentionUProgress")

	self:_findRightPanelObjects(self.petInfoPanelObjectReference)

	local btnOC = self.btnPurchaseUButton:GetComponent("ObjectReference")

	self.btnTxtNameUText = btnOC:GetRefValue("txtNameUText")

	self.btnAttentionUButton:SetActiveFastest(false)
end

function TradeMarketPetDetailBaseView:_findRightPanelObjects(objectReference)
	self.panelAbilityUContainer = objectReference:GetRefValue("panelAbilityUContainer")
	self.panelSkillUContainer = objectReference:GetRefValue("panelSkillUContainer")
	self.panelInfoUContainer = objectReference:GetRefValue("panelInfoUContainer")
	self.rightPanelUComponent = objectReference:GetRefValue("rightPanelUComponent")
	self.attributeBtn = objectReference:GetRefValue("attributeBtn")
	self.skillBtn = objectReference:GetRefValue("skillBtn")
	self.infoBtn = objectReference:GetRefValue("infoBtn")
end

function TradeMarketPetDetailBaseView:registerObjects()
	return
end

function TradeMarketPetDetailBaseView:initView()
	return
end

return TradeMarketPetDetailBaseView
