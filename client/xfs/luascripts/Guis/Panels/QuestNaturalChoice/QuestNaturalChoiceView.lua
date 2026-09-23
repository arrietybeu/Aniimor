-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\QuestNaturalChoice\\QuestNaturalChoiceView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local QuestNaturalChoiceView = Class.LightClass("QuestNaturalChoiceView", UIView)

function QuestNaturalChoiceView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.txtTitleUBaseText = self.objectReference:GetRefValue("txtTitleUBaseText")
	self.listOptionUList = self.objectReference:GetRefValue("listOptionUList")
	self.root = self.objectReference:GetRefValue("listOptionUList")
	self.rootAnimation = self.objectReference:GetRefValue("rootAnimation")
end

function QuestNaturalChoiceView:registerObjects()
	return
end

function QuestNaturalChoiceView:initView()
	return
end

return QuestNaturalChoiceView
