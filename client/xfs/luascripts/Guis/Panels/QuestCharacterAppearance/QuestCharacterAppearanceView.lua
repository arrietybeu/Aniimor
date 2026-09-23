-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\QuestCharacterAppearance\\QuestCharacterAppearanceView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local QuestCharacterAppearanceView = Class.LightClass("QuestCharacterAppearanceView", UIView)

function QuestCharacterAppearanceView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.rootUComponent = self.objectReference:GetRefValue("rootUComponent")
	self.textNameUBaseText = self.objectReference:GetRefValue("textNameUBaseText")
	self.textTitleUBaseText = self.objectReference:GetRefValue("textTitleUBaseText")
	self.textLevelUBaseText = self.objectReference:GetRefValue("textLevelUBaseText")
	self.panelTransform = self.objectReference:GetRefValue("panelTransform")
	self.rootAnimation = self.objectReference:GetRefValue("rootAnimation")
	self.safeBoxMobileTransform = self.objectReference:GetRefValue("safeBoxMobileTransform")
end

function QuestCharacterAppearanceView:registerObjects()
	return
end

function QuestCharacterAppearanceView:initView()
	return
end

return QuestCharacterAppearanceView
