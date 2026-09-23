-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetDispatchSurveyCompleted\\PetDispatchSurveyCompletedView.lua

local Class = require("Core.Framework.Class")
local ClientTextUtils = require("Utils.ClientTextUtils")
local UIView = require("Guis.UIView")
local PetDispatchSurveyCompletedView = Class.LightClass("PetDispatchSurveyCompletedView", UIView)

function PetDispatchSurveyCompletedView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.adveRewardUWidget = objectReference:GetRefValue("adveRewardUWidget")
	self.baserewardUWidget = objectReference:GetRefValue("baserewardUWidget")
	self.textAdveTitle = objectReference:GetRefValue("textAdveTitle")
	self.textAdveRewardAdveDes = objectReference:GetRefValue("textAdveRewardAdveDes")
	self.textRewardAdveTitle2 = objectReference:GetRefValue("textRewardAdveTitle2")
	self.listRewardAdveUList = objectReference:GetRefValue("listRewardAdveUList")
	self.textBaseTitle = objectReference:GetRefValue("textBaseTitle")
	self.textBaseDes = objectReference:GetRefValue("textBaseDes")
	self.textRewardBaseTitle = objectReference:GetRefValue("textRewardBaseTitle")
	self.listRewardBaseUList = objectReference:GetRefValue("listRewardBaseUList")
	self.textTitle = objectReference:GetRefValue("textTitle")
	self.backGroundCloseUButton = objectReference:GetRefValue("backGroundCloseUButton")
	self.txtTips = objectReference:GetRefValue("txtTips")
	self.imgPicUImage = objectReference:GetRefValue("imgPicUImage")
	self.rootUComponent = objectReference:GetRefValue("rootUComponent")
	self.BackGroundClose = objectReference:GetRefValue("BackGroundClose")
	self.petUWidget = objectReference:GetRefValue("petUWidget")
	self.petHeadUButton = objectReference:GetRefValue("petHeadUButton")
	self.txtAttriUSDFText = objectReference:GetRefValue("txtAttriUSDFText")
	self.txtNumBeforeUSDFText = objectReference:GetRefValue("txtNumBeforeUSDFText")
	self.txtNumAfterUSDFText = objectReference:GetRefValue("txtNumAfterUSDFText")
	self.imgPicLUImage = objectReference:GetRefValue("imgPicLUImage")
	self.tipsTouchAnyConsoleUWidget = objectReference:GetRefValue("tipsTouchAnyConsoleUWidget")
end

function PetDispatchSurveyCompletedView:registerObjects()
	return
end

function PetDispatchSurveyCompletedView:initView()
	ClientTextUtils.setText(self.textTitle, pg.getGameString("DISPATCH_TASK_FINISHED_RESULT"))
	ClientTextUtils.setText(self.textAdveTitle, pg.getGameString("DISPATCH_TASK_ADVENTURE_RESULT_TITLE"))
	ClientTextUtils.setText(self.textRewardAdveTitle2, pg.getGameString("DISPATCH_TASK_ADVENTURE_AWARD"))
	ClientTextUtils.setText(self.textBaseTitle, pg.getGameString("DISPATCH_TASK_FIND"))
	ClientTextUtils.setText(self.textRewardBaseTitle, pg.getGameString("DISPATCH_TASK_AWARD_BASE"))
end

return PetDispatchSurveyCompletedView
