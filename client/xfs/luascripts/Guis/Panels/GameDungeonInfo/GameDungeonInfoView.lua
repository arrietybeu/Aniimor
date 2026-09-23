-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GameDungeonInfo\\GameDungeonInfoView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local GameDungeonInfoView = Class.LightClass("GameDungeonInfoView", UIView)

function GameDungeonInfoView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.picUImage = self.objectReference:GetRefValue("picUImage")
	self.btnBackUButton = self.objectReference:GetRefValue("btnBackUButton")
	self.currencyItemUButton = self.objectReference:GetRefValue("currencyItemUButton")
	self.btnConfirmUButton = self.objectReference:GetRefValue("btnConfirmUButton")
	self.dungeonNameUText = self.objectReference:GetRefValue("dungeonNameUText")
	self.rewardUList = self.objectReference:GetRefValue("rewardUList")
	self.challengeUText = self.objectReference:GetRefValue("challengeUText")
	self.consoleBarTransform = self.objectReference:GetRefValue("consoleBarTransform")
	self.peopleNumUBaseText = self.objectReference:GetRefValue("peopleNumUBaseText")
	self.recommendEleList = self.objectReference:GetRefValue("recommendEleList")
	self.skillListUList = self.objectReference:GetRefValue("skillListUList")
	self.chestNumUBaseText = self.objectReference:GetRefValue("chestNumUBaseText")
	self.elementRecommendUWidget = self.objectReference:GetRefValue("elementRecommendUWidget")
	self.skillRecommendUWidget = self.objectReference:GetRefValue("skillRecommendUWidget")
	self.chestUWidget = self.objectReference:GetRefValue("chestUWidget")
	self.petLimitUWidget = self.objectReference:GetRefValue("petLimitUWidget")
	self.petLimitListUList = self.objectReference:GetRefValue("petLimitListUList")
	self.listCurrencyUList = self.objectReference:GetRefValue("listCurrencyUList")
	self.textPanelUWidget = self.objectReference:GetRefValue("textPanelUWidget")
	self.textPanelTxtName = self.objectReference:GetRefValue("textPanelTxtName")
	self.textPanelDesc = self.objectReference:GetRefValue("textPanelDesc")
	self.rewardUWidget = self.objectReference:GetRefValue("rewardUWidget")
	self.rewardList = self.objectReference:GetRefValue("rewardList")
	self.txtNameUSDFText = self.objectReference:GetRefValue("txtNameUSDFText")
	self.elementTxtDetails = self.objectReference:GetRefValue("elementTxtDetails")
	self.btnMatchUComponent = self.objectReference:GetRefValue("btnMatchUComponent")
	self.txtDetailsUScrollRect = self.objectReference:GetRefValue("txtDetailsUScrollRect")
	self.rewardTitleUSDFText = self.objectReference:GetRefValue("rewardTitleUSDFText")
	self.chatUContainer = self.objectReference:GetRefValue("chatUContainer")
end

function GameDungeonInfoView:registerObjects()
	return
end

function GameDungeonInfoView:initView()
	return
end

return GameDungeonInfoView
