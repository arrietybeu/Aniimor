-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TowerFastTrain\\TowerFastTrainView.lua

local logger = require("Core.Log.LoggerManager").getLogger("TowerFastTrainView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local TowerFastTrainView = Class.LightClass("TowerFastTrainView", UIView)

function TowerFastTrainView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.titleUBaseText = objectReference:GetRefValue("titleUBaseText")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.btnCancelUButton = objectReference:GetRefValue("btnCancelUButton")
	self.btnConfirmUButton = objectReference:GetRefValue("btnConfirmUButton")
	self.trainTypeUList = objectReference:GetRefValue("trainTypeUList")
	self.levelElementUButton = objectReference:GetRefValue("levelElementUButton")
	self.levelNameUBaseText = objectReference:GetRefValue("levelNameUBaseText")
	self.lvUBaseText = objectReference:GetRefValue("lvUBaseText")
	self.rewardTitleUBaseText = objectReference:GetRefValue("rewardTitleUBaseText")
	self.rewardItemUList = objectReference:GetRefValue("rewardItemUList")
	self.trainTimesTitleUBaseText = objectReference:GetRefValue("trainTimesTitleUBaseText")
	self.trainTimesUNumSelector = objectReference:GetRefValue("trainTimesUNumSelector")
	self.costUBaseText = objectReference:GetRefValue("costUBaseText")
	self.coin1UButton = objectReference:GetRefValue("coin1UButton")
	self.coin2UButton = objectReference:GetRefValue("coin2UButton")
	self.quickTrainingUBaseText = objectReference:GetRefValue("quickTrainingUBaseText")
	self.quickTrainNumUBaseText = objectReference:GetRefValue("quickTrainNumUBaseText")
	self.quickTrainProgressUBaseText = objectReference:GetRefValue("quickTrainProgressUBaseText")
	self.trainFinishRewardUList = objectReference:GetRefValue("trainFinishRewardUList")
	self.listCurrencyUList = objectReference:GetRefValue("listCurrencyUList")
end

function TowerFastTrainView:registerObjects()
	local btnConfirmObjectReference = self.btnConfirmUButton:GetComponent("ObjectReference")

	self.btnConfirmUText = btnConfirmObjectReference:GetRefValue("txtNameUText")

	local btnCancelObjectReference = self.btnCancelUButton:GetComponent("ObjectReference")

	self.btnCancelUText = btnCancelObjectReference:GetRefValue("txtNameUText")
end

function TowerFastTrainView:initView()
	return
end

return TowerFastTrainView
