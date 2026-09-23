-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SpecialTrainChapterTip\\SpecialTrainChapterTipView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local SpecialTrainChapterTipView = Class.LightClass("SpecialTrainChapterTipView", UIView)

function SpecialTrainChapterTipView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.textUBaseText = objectReference:GetRefValue("textUBaseText")
	self.middleUImage = objectReference:GetRefValue("middleUImage")
	self.textDecUBaseText = objectReference:GetRefValue("textDecUBaseText")
	self.listStageUList = objectReference:GetRefValue("listStageUList")
	self.listRewardUList = objectReference:GetRefValue("listRewardUList")
	self.rewardText = objectReference:GetRefValue("rewardText")
	self.dateText = objectReference:GetRefValue("dateText")
	self.backGroundCloseUButton = objectReference:GetRefValue("backGroundCloseUButton")
	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.textTitleUSDFText = objectReference:GetRefValue("textTitleUSDFText")
	self.textUSDFText = objectReference:GetRefValue("textUSDFText")
	self.textInfoUSDFText = objectReference:GetRefValue("textInfoUSDFText")
	self.rewardBtnTipsUSDFText = objectReference:GetRefValue("rewardBtnTipsUSDFText")
	self.closeUSDFText = objectReference:GetRefValue("closeUSDFText")
end

function SpecialTrainChapterTipView:registerObjects()
	return
end

function SpecialTrainChapterTipView:initView()
	return
end

return SpecialTrainChapterTipView
