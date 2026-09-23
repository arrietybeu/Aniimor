-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TrainPreference\\TrainPreferenceView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local TrainPreferenceView = Class.LightClass("TrainPreferenceView", UIView)

function TrainPreferenceView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.listCenter = self.objectReference:GetRefValue("listCenter")
	self.txtTips = self.objectReference:GetRefValue("txtTips")
	self.btnCancelUButton = self.objectReference:GetRefValue("btnCancelUButton")
	self.btnConfirmUButton = self.objectReference:GetRefValue("btnConfirmUButton")
	self.txtTitleUBaseText = self.objectReference:GetRefValue("txtTitleUBaseText")
end

local tabComs = {}

function TrainPreferenceView:getQuestItemComs(btn)
	if tabComs[btn] == nil then
		local objectReference = btn.transform:GetComponent("ObjectReference")

		tabComs[btn] = {}
		tabComs[btn].itemObj = objectReference
		tabComs[btn].button = objectReference:GetRefValue("button")
		tabComs[btn].image = objectReference:GetRefValue("image")
		tabComs[btn].name = objectReference:GetRefValue("name")
		tabComs[btn].details = objectReference:GetRefValue("details")
	end

	return tabComs[btn]
end

function TrainPreferenceView:registerObjects()
	return
end

function TrainPreferenceView:initView()
	return
end

function TrainPreferenceView:setResearchProgress()
	return
end

function TrainPreferenceView:onDestroy()
	for k in next, tabComs do
		tabComs[k] = nil
	end
end

return TrainPreferenceView
