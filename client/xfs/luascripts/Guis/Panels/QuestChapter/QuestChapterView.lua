-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\QuestChapter\\QuestChapterView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local QuestChapterView = Class.LightClass("QuestChapterView", UIView)

function QuestChapterView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.chapterRoot = objectReference:GetRefValue("chapterRoot")
	self.rootCom = objectReference:GetRefValue("rootCom")
end

function QuestChapterView:getChapterObjects(chapterRef)
	self.objectReference = chapterRef:GetComponent("ObjectReference")
	self.mainCom = self.objectReference:GetRefValue("mainCom")
	self.caChapterTxt = self.objectReference:GetRefValue("caChapterTxt")
	self.caChapterNameTxt = self.objectReference:GetRefValue("caChapterNameTxt")
	self.scChapterTypeNameTxt = self.objectReference:GetRefValue("scChapterTypeNameTxt")
	self.scSectionNameTxt = self.objectReference:GetRefValue("scSectionNameTxt")
	self.caSectionContentTxt = self.objectReference:GetRefValue("caSectionContentTxt")
	self.scSectionContentTxt = self.objectReference:GetRefValue("scSectionContentTxt")
	self.caChapterShadowTxt = self.objectReference:GetRefValue("caChapterShadowTxt")
	self.scChapterNameShadowTxt = self.objectReference:GetRefValue("scChapterNameShadowTxt")
	self.expressionUImage = self.objectReference:GetRefValue("expressionUImage")
	self.completeUImage = self.objectReference:GetRefValue("completeUImage")
	self.complete01UImage = self.objectReference:GetRefValue("complete01UImage")
	self.textTimeUBaseText = self.objectReference:GetRefValue("textTimeUBaseText")
	self.mainTitleTextUBaseText = self.objectReference:GetRefValue("mainTitleTextUBaseText")
	self.chapterAppearAnimation = self.objectReference:GetRefValue("chapterAppearAnimation")
	self.sectionCompleteAnimation = self.objectReference:GetRefValue("sectionCompleteAnimation")
	self.chapterAppearUWidget = self.objectReference:GetRefValue("chapterAppearUWidget")
	self.sectionCompleteUWidget = self.objectReference:GetRefValue("sectionCompleteUWidget")
	self.textBgUWidget = self.objectReference:GetRefValue("textBgUWidget")
	self.completeTextBgUWidget = self.objectReference:GetRefValue("completeTextBgUWidget")
end

function QuestChapterView:registerObjects()
	return
end

function QuestChapterView:initView()
	return
end

return QuestChapterView
