-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Survey\\SurveyView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local SurveyView = Class.LightClass("SurveyView", UIView)

function SurveyView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.surveyList = self.objectReference:GetRefValue("listUList")
	self.btnClose = self.objectReference:GetRefValue("btnClose")
end

local itemsComs = {}

function SurveyView:getItemComs(btn)
	if itemsComs[btn] == nil then
		local objectReference = btn.transform:GetComponent("ObjectReference")

		itemsComs[btn] = {}
		itemsComs[btn].questItemObj = objectReference
		itemsComs[btn].rewardList = objectReference:GetRefValue("rewardList")
		itemsComs[btn].questItem = objectReference:GetRefValue("questItem")
		itemsComs[btn].title = objectReference:GetRefValue("title")
		itemsComs[btn].arrow = objectReference:GetRefValue("arrow")
		itemsComs[btn].time = objectReference:GetRefValue("time")
		itemsComs[btn].tips = objectReference:GetRefValue("tips")
	end

	return itemsComs[btn]
end

function SurveyView:registerObjects()
	return
end

function SurveyView:initView()
	return
end

function SurveyView:onDestroy()
	for k in next, itemsComs do
		itemsComs[k] = nil
	end
end

return SurveyView
