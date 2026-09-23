-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\InteractSecond\\InteractSecondView.lua

local logger = require("Core.Log.LoggerManager").getLogger("InteractSecondView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local InteractSecondView = Class.LightClass("InteractSecondView", UIView)

function InteractSecondView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.multiSelectHintUWidget = self.objectReference:GetRefValue("multiSelectHintUWidget")
	self.petSwitchCtrlInteractBtn = self.objectReference:GetRefValue("petSwitchCtrlInteractBtn")
	self.petSwitchCtrlInteractBtnKB = self.objectReference:GetRefValue("petSwitchCtrlInteractBtnKB")
	self.petSwitchCtrlIcon = self.objectReference:GetRefValue("petSwitchCtrlIcon")
	self.catchUButton = self.objectReference:GetRefValue("catchUButton")
	self.panelCaptureUWidget = self.objectReference:GetRefValue("panelCaptureUWidget")
	self.interactionNewUWidget = self.objectReference:GetRefValue("interactionNewUWidget")
	self.dialogueUWidget = self.objectReference:GetRefValue("dialogueUWidget")
	self.textInfoUSDFText = self.objectReference:GetRefValue("textInfoUSDFText")
	self.txtNameUSDFText = self.objectReference:GetRefValue("txtNameUSDFText")
	self.multiSelectHintUContainer = self.objectReference:GetRefValue("multiSelectHintUContainer")
end

function InteractSecondView:registerObjects()
	self.listUList = self.interactionNewUWidget.transform:GetComponent("ObjectReference"):GetRefValue("listUList")
end

function InteractSecondView:initView()
	return
end

return InteractSecondView
