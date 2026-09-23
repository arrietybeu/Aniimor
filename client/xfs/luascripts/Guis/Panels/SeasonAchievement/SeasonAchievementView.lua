-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SeasonAchievement\\SeasonAchievementView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local SeasonAchievementView = Class.LightClass("SeasonAchievementView", UIView)

function SeasonAchievementView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.rootUComponent = self.transform:GetComponent("UComponent")
	self.btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	self.txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	self.subTitleIconUImage = objectReference:GetRefValue("subTitleIconUImage")
	self.subTitleUSDFText = objectReference:GetRefValue("subTitleUSDFText")
	self.listManualUList = objectReference:GetRefValue("listManualUList")
	self.topAchievementInfo = objectReference:GetRefValue("topAchievementInfo")

	local topObjectReference = self.topAchievementInfo.transform:GetComponent("ObjectReference")

	self.timeUCountDown = topObjectReference:GetRefValue("timeUCountDown")
	self.txtLevelUSDFText = topObjectReference:GetRefValue("txtLevelUSDFText")
	self.progressUSDFText = topObjectReference:GetRefValue("progressUSDFText")
	self.progressUProgress = topObjectReference:GetRefValue("progressUProgress")
	self.listRewardUList = topObjectReference:GetRefValue("listRewardUList")
	self.stageRewardItemUButton = topObjectReference:GetRefValue("stageRewardItemUButton")
	self.titleUSDFText = topObjectReference:GetRefValue("titleUSDFText")
	self.btnBadgeUButton = topObjectReference:GetRefValue("btnBadgeUButton")
	self.btnIconUButton = topObjectReference:GetRefValue("btnIconUButton")
	self.iconUImage = topObjectReference:GetRefValue("iconUImage")
	self.subManualUComponent = objectReference:GetRefValue("subManualUComponent")
end

function SeasonAchievementView:findSubManualObjects(content)
	local subManualObjectReference = content:GetComponent("ObjectReference")

	self.btnBackUButton = subManualObjectReference:GetRefValue("btnBackUButton")
	self.taskUList = subManualObjectReference:GetRefValue("taskUList")
	self.btnGetAllUButton = subManualObjectReference:GetRefValue("btnGetAllUButton")

	local btnGetAllObjectReference = self.btnGetAllUButton:GetComponent("ObjectReference")

	self.btnGetAllNameUText = btnGetAllObjectReference:GetRefValue("txtNameUText")
	self.leftArrowUButton = subManualObjectReference:GetRefValue("leftArrowUButton")
	self.rightArrowUButton = subManualObjectReference:GetRefValue("rightArrowUButton")
	self.textBgUImage = subManualObjectReference:GetRefValue("textBgUImage")
	self.manualCardInfo = subManualObjectReference:GetRefValue("manualCardInfo")

	local manualCardObjectReference = self.manualCardInfo.transform:GetComponent("ObjectReference")

	self.manualTitleUSDFText = manualCardObjectReference:GetRefValue("txtManualTitleUSDFText")
	self.manualBgUImage = manualCardObjectReference:GetRefValue("bgUImage")
	self.manualIconBgUImage = manualCardObjectReference:GetRefValue("iconBgUImage")
	self.manualIconUImage = manualCardObjectReference:GetRefValue("manualIconUImage")
	self.manualProgressUSDFText = manualCardObjectReference:GetRefValue("txtProgressUSDFText")

	local objectsValid = not IsNil(self.btnBackUButton) and not IsNil(self.taskUList) and not IsNil(self.btnGetAllUButton) and not IsNil(self.btnGetAllNameUText) and not IsNil(self.leftArrowUButton) and not IsNil(self.rightArrowUButton) and not IsNil(self.textBgUImage) and not IsNil(self.manualTitleUSDFText) and not IsNil(self.manualBgUImage) and not IsNil(self.manualIconUImage) and not IsNil(self.manualProgressUSDFText)

	return objectsValid
end

function SeasonAchievementView:registerObjects()
	return
end

function SeasonAchievementView:initView()
	return
end

return SeasonAchievementView
