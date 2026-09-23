-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TradeMarketHistoryPet\\TradeMarketHistoryPetView.lua

local logger = require("Core.Log.LoggerManager").getLogger("TradeMarketHistoryPetView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local TradeMarketHistoryPetView = Class.LightClass("TradeMarketHistoryPetView", UIView)

function TradeMarketHistoryPetView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.tMPUSDFText = objectReference:GetRefValue("tMPUSDFText")
	self.listCurrencyUList = objectReference:GetRefValue("listCurrencyUList")
	self.petInfoPanelObjectReference = objectReference:GetRefValue("petInfoPanelObjectReference")

	self:_findRightPanelObjects(self.petInfoPanelObjectReference)

	self.coinObjectReference = objectReference:GetRefValue("coinObjectReference")
	self.txtDetailsUSDFText = objectReference:GetRefValue("txtDetailsUSDFText")
	self.countDownUCountDown = objectReference:GetRefValue("countDownUCountDown")
	self.reviewUWidget = objectReference:GetRefValue("reviewUWidget")
	self.imgIcon = self.coinObjectReference:GetRefValue("imgIcon")
	self.txtNum = self.coinObjectReference:GetRefValue("txtNum")
	self.btnClick = self.coinObjectReference:GetRefValue("btnClick")
end

function TradeMarketHistoryPetView:_findRightPanelObjects(objectReference)
	self.panelAbilityUContainer = objectReference:GetRefValue("panelAbilityUContainer")
	self.panelSkillUContainer = objectReference:GetRefValue("panelSkillUContainer")
	self.panelInfoUContainer = objectReference:GetRefValue("panelInfoUContainer")
	self.rightPanelUComponent = objectReference:GetRefValue("rightPanelUComponent")
	self.attributeBtn = objectReference:GetRefValue("attributeBtn")
	self.skillBtn = objectReference:GetRefValue("skillBtn")
	self.infoBtn = objectReference:GetRefValue("infoBtn")
end

function TradeMarketHistoryPetView:registerObjects()
	return
end

function TradeMarketHistoryPetView:initView()
	return
end

return TradeMarketHistoryPetView
