-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Puzzle\\PuzzleView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local PuzzleView = Class.LightClass("PuzzleView", UIView)

function PuzzleView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.btnBackUButton = self.objectReference:GetRefValue("btnBackUButton")
	self.titleUBaseText = self.objectReference:GetRefValue("titleUBaseText")
	self.btnResetUButton = self.objectReference:GetRefValue("btnResetUButton")
	self.btnViewUButton = self.objectReference:GetRefValue("btnViewUButton")
	self.times3Transform = self.objectReference:GetRefValue("times3Transform")
	self.times4Transform = self.objectReference:GetRefValue("times4Transform")
	self.btnFinishUButton = self.objectReference:GetRefValue("btnFinishUButton")
	self.rootUWidget = self.objectReference:GetRefValue("rootUWidget")
	self.widgetAnimation = self.objectReference:GetRefValue("widgetAnimation")
	self.uIPbJigsawUComponent = self.objectReference:GetRefValue("uIPbJigsawUComponent")
	self.imgPreviewUImage = self.objectReference:GetRefValue("imgPreviewUImage")
	self.imgFinishUImage = self.objectReference:GetRefValue("imgFinishUImage")
	self.vXImgFinishUImage = self.objectReference:GetRefValue("vXImgFinishUImage")
	self.vfxImageUImage = self.objectReference:GetRefValue("vfxImageUImage")
	self.btnAgainUButton = self.objectReference:GetRefValue("btnAgainUButton")
	self.txtNameUBaseText = self.objectReference:GetRefValue("txtNameUBaseText")
	self.previewRectTransform = self.objectReference:GetRefValue("previewRectTransform")
	self.leftPanelRectTransform = self.objectReference:GetRefValue("leftPanelRectTransform")
	self.consoleBarRectTransform = self.objectReference:GetRefValue("consoleBarRectTransform")
	self.txtTitleUBaseText = self.objectReference:GetRefValue("txtTitleUBaseText")
	self.keyHintUButton = self.objectReference:GetRefValue("keyHintUButton")
	self.resetObjectReference = self.btnResetUButton:GetComponent("ObjectReference")
	self.uIBtn1stConfirmUButton = self.resetObjectReference:GetRefValue("uIBtn1stConfirmUButton")
	self.txtNameUText = self.resetObjectReference:GetRefValue("txtNameUText")
	self.keyHintObjectReference = self.keyHintUButton:GetComponent("ObjectReference")
	self.keyHotKeyContent = self.keyHintObjectReference:GetRefValue("keyHotKeyContent")
	self.keyHotKeyText = self.keyHotKeyContent:GetComponent("TextPlus")
	self.btnTipsUText = self.keyHintObjectReference:GetRefValue("btnTipsUText")
	self.keyUList = self.keyHintObjectReference:GetRefValue("keyUList")
	self.progressPressContainerUContainer = self.keyHintObjectReference:GetRefValue("progressPressContainerUContainer")
end

function PuzzleView:registerObjects()
	return
end

function PuzzleView:initView()
	return
end

return PuzzleView
