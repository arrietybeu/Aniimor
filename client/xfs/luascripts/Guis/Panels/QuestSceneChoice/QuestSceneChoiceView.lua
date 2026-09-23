-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\QuestSceneChoice\\QuestSceneChoiceView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local QuestSceneChoiceView = Class.LightClass("QuestSceneChoiceView", UIView)

function QuestSceneChoiceView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.rootUComponent = self.objectReference:GetRefValue("rootUComponent")
	self.txtTitleUBaseText = self.objectReference:GetRefValue("txtTitleUBaseText")
	self.emojiUContainer = self.objectReference:GetRefValue("emojiUContainer")
	self.progressUProgress = self.objectReference:GetRefValue("progressUProgress")
	self.lProgressUProgress = self.objectReference:GetRefValue("lProgressUProgress")
	self.lTxtOptionUBaseText = self.objectReference:GetRefValue("lTxtOptionUBaseText")
	self.lTxtNumUBaseText = self.objectReference:GetRefValue("lTxtNumUBaseText")
	self.lPlayerNameUScrollList = self.objectReference:GetRefValue("lPlayerNameUScrollList")
	self.rProgressUProgress = self.objectReference:GetRefValue("rProgressUProgress")
	self.rTxtOptionUBaseText = self.objectReference:GetRefValue("rTxtOptionUBaseText")
	self.rTxtNumUBaseText = self.objectReference:GetRefValue("rTxtNumUBaseText")
	self.rPlayerNameUScrollList = self.objectReference:GetRefValue("rPlayerNameUScrollList")
	self.btnOptionLUButton = self.objectReference:GetRefValue("btnOptionLUButton")
	self.btnOptionRUButton = self.objectReference:GetRefValue("btnOptionRUButton")
	self.btnOptionLUComponent = self.objectReference:GetRefValue("btnOptionLUComponent")
	self.btnOptionRUComponent = self.objectReference:GetRefValue("btnOptionRUComponent")
	self.lSliderSelUSlider = self.objectReference:GetRefValue("lSliderSelUSlider")
	self.rSliderSelUSlider = self.objectReference:GetRefValue("rSliderSelUSlider")
	self.lFrameSelUImage = self.objectReference:GetRefValue("lFrameSelUImage")
	self.lIconSelUImage = self.objectReference:GetRefValue("lIconSelUImage")
	self.rFrameSelUImage = self.objectReference:GetRefValue("rFrameSelUImage")
	self.rIconSelUImage = self.objectReference:GetRefValue("rIconSelUImage")
end

function QuestSceneChoiceView:registerObjects()
	return
end

function QuestSceneChoiceView:initView()
	return
end

return QuestSceneChoiceView
