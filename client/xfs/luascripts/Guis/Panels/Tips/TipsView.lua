-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Tips\\TipsView.lua

local UIView = require("Guis.UIView")
local Class = require("Core.Framework.Class")
local TipsView = Class.LightClass("TipsView", UIView)

function TipsView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.rootComponent = self.transform:GetComponent("UComponent")
	self.restraintRoot = self.objectReference:GetRefValue("restraintRoot")
	self.textTipsRoot = self.objectReference:GetRefValue("textTipsRoot")
	self.confirmRoot = self.objectReference:GetRefValue("confirmRoot")
	self.inputField = self.objectReference:GetRefValue("inputField")
	self.quest = self.objectReference:GetRefValue("questUContainer")

	self.quest:SetActive(false)

	self.target = self.objectReference:GetRefValue("targetUContainer")
	self.challengeHud = self.objectReference:GetRefValue("limitChallengeHud")
	self.aiHelperContainer = self.objectReference:GetRefValue("aihelperContainer")
	self.textInfoUContainer = self.objectReference:GetRefValue("textInfoUContainer")
	self.eventRoot = self.objectReference:GetRefValue("eventRoot")
	self.eventAppRoot = self.objectReference:GetRefValue("eventAppRoot")
	self.popContainerUContainer = self.objectReference:GetRefValue("popContainerUContainer")
	self.marqueeRectTransform = self.objectReference:GetRefValue("marqueeRectTransform")
	self.dangerUContainer = self.objectReference:GetRefValue("dangerUContainer")
	self.spaceBuffToastUContainer = self.objectReference:GetRefValue("spaceBuffToastUContainer")
	self.questAreaUWidget = self.objectReference:GetRefValue("questAreaUWidget")
end

function TipsView:initView()
	return
end

function TipsView:switchHelpShow()
	if self.helpOpen then
		self:onCloseBtnClick()
	else
		self:showHelp()
	end
end

function TipsView:showHelp()
	self.closeHelpBtn:SetActiveFastest(true)
end

local questObjectiveItemsComs = {}

function TipsView:getQuestObjectiveItemComs(btn)
	if questObjectiveItemsComs[btn] == nil then
		questObjectiveItemsComs[btn] = {}
		questObjectiveItemsComs[btn].numlTxt = btn:Find("Widget/TxtNum"):GetComponent("UBaseText")
		questObjectiveItemsComs[btn].detailTxt = btn:Find("Widget/TxtName"):GetComponent("UBaseText")
	end

	return questObjectiveItemsComs[btn]
end

function TipsView:onDestroy()
	for k in next, questObjectiveItemsComs do
		questObjectiveItemsComs[k] = nil
	end
end

return TipsView
