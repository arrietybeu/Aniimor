-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FishingCapture\\FishingCaptureView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local FishingCaptureView = Class.LightClass("FishingCaptureView", UIView)

function FishingCaptureView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnBackUButton = objectReference:GetRefValue("btnBackUButton")
	self.btnConfirmUButton = objectReference:GetRefValue("btnConfirmUButton")
	self.dungeonNameUText = objectReference:GetRefValue("dungeonNameUText")
	self.rewardUList = objectReference:GetRefValue("rewardUList")
	self.challengeUText = objectReference:GetRefValue("challengeUText")
	self.consoleBarTransform = objectReference:GetRefValue("consoleBarTransform")
	self.recommendEleList = objectReference:GetRefValue("recommendEleList")
	self.elementRecommendUWidget = objectReference:GetRefValue("elementRecommendUWidget")
	self.listCurrencyUList = objectReference:GetRefValue("listCurrencyUList")
	self.rewardUWidget = objectReference:GetRefValue("rewardUWidget")
	self.rewardList = objectReference:GetRefValue("rewardList")
	self.txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	self.backTitle = objectReference:GetRefValue("backTitle")
	self.txtDetailsUScrollRect = objectReference:GetRefValue("txtDetailsUScrollRect")
	self.rewardTitleUSDFText = objectReference:GetRefValue("rewardTitleUSDFText")
	self.txtLevelUBaseText = objectReference:GetRefValue("txtLevelUBaseText")
	self.txtTipsUBaseText = objectReference:GetRefValue("txtTipsUBaseText")
	self.bringItemUList = objectReference:GetRefValue("bringItemUList")
	self.txtLevelNameUBaseText = objectReference:GetRefValue("txtLevelNameUBaseText")
	self.timeTitleTxt = objectReference:GetRefValue("timeTitleTxt")
	self.countDownUCountDown = objectReference:GetRefValue("countDownUCountDown")
	self.btnInfoUButton = objectReference:GetRefValue("btnInfoUButton")
	self.infoTxt = objectReference:GetRefValue("infoTxt")
	self.bg1UContainer = objectReference:GetRefValue("bg1UContainer")
	self.bg2UContainer = objectReference:GetRefValue("bg2UContainer")
	self.entranceBgUContainers = {
		self.bg1UContainer,
		self.bg2UContainer
	}
end

function FishingCaptureView:registerObjects()
	return
end

function FishingCaptureView:initView()
	return
end

return FishingCaptureView
