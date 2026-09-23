-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\DialogueModule\\Dialogue\\DialogueView.lua

local UIView = require("Guis.UIView")
local Class = require("Core.Framework.Class")
local DialogueView = Class.LightClass("DialogueView", UIView)
local LuaUIUtils = require("Utils.LuaUIUtils")
local SysConfigData = require("Data.sys_config_data")
local logger = require("Core.Log.LoggerManager").getLogger("DialogueView")
local ClientTextUtils = require("Utils.ClientTextUtils")

function DialogueView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.panelObj = self.objectReference:GetRefValue("panelObj")
	self.panelAnim = self.objectReference:GetRefValue("panelAnim")
	self.dialoguePanel = self.objectReference:GetRefValue("dialoguePanel")
	self.nextIcon = self.objectReference:GetRefValue("nextIcon")
	self.dialogueNamePanel = self.objectReference:GetRefValue("dialogueNamePanel")
	self.dialogueName = self.objectReference:GetRefValue("dialogueName")
	self.dialogueText = self.objectReference:GetRefValue("dialogueText")
	self.nextBtn = self.objectReference:GetRefValue("nextBtn")
	self.btnLayout = self.objectReference:GetRefValue("btnLayout")
	self.dialogueBranchListBtnTransform = self.objectReference:GetRefValue("dialogueBranchListBtnTransform")
	self.reviewLogBtn = self.objectReference:GetRefValue("reviewLogBtn")
	self.reviewLogIcon = self.objectReference:GetRefValue("reviewLogIcon")
	self.boxDialogueUComponent = self.objectReference:GetRefValue("boxDialogueUComponent")
	self.listCurrencyUList = self.objectReference:GetRefValue("listCurrencyUList")
	self.btnTipsUSDFText = self.objectReference:GetRefValue("btnTipsUSDFText")
	self.belogginginUWidget = self.objectReference:GetRefValue("belogginginUWidget")
	self.imgNextUWidget = self.objectReference:GetRefValue("imgNextUWidget")
end

function DialogueView:initView()
	LuaUIUtils.setUIViewVisible(self.btnLayout, false)
end

function DialogueView:showDialogue()
	self.panelObj:TryChangePage("Sence", 1)
	LuaUIUtils.setUIViewVisible(self.dialoguePanel, true)
	LuaUIUtils.setUIViewVisible(self.nextIcon, true)
end

function DialogueView:switchPlayMode(isPlaying)
	local val = isPlaying and 1 or 0

	self.panelObj:TryChangePage("state", val)
end

return DialogueView
