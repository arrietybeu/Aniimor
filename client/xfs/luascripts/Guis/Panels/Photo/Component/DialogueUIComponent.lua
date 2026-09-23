-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Photo\\Component\\DialogueUIComponent.lua

local Class = require("Core.Framework.Class")
local TimerManager = require("Core.Timer.TimerManager")
local PhotoIdentifyData = require("Data.photo_identify_data")
local NpcDialogueData = require("Data.npc_dialogue_data")
local PhotoConditionTrigger = require("Utils.PhotoConditionTrigger")
local UICtrl = require("Guis.UICtrl")
local UIComponent = require("Guis.Helper.UIComponent")
local DialogueUIComponent = Class.LightClass("DialogueUIComponent", UIComponent)
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")

function DialogueUIComponent:ctor(ctrl, trans)
	UIComponent.ctor(self, ctrl, trans)
	LuaUIUtils.setUIViewVisible(self.view.dialogue, false)
	LuaUIUtils.setUIViewVisible(self.view.aside, false)

	self.dialogueTimer = nil
	self.monologueTimer = nil
	self.needShowDialogue = false
	self.needShowMonologue = false
	self.triggerPhotoId = nil
end

function DialogueUIComponent:initView()
	function self.view.dialogueNextBtn.luaClick()
		if self.dialogueTimer ~= nil then
			TimerManager.removeTimer(self.dialogueTimer)

			self.dialogueTimer = nil
		end

		self:closeDialogue()
	end
end

function DialogueUIComponent:showMonologue()
	LuaUIUtils.setUIViewVisible(self.view.monologue, true)
end

function DialogueUIComponent:closeMonologue()
	LuaUIUtils.setUIViewVisible(self.view.monologue, false)
end

function DialogueUIComponent:showDialogue()
	LuaUIUtils.setUIViewVisible(self.view.dialogue, true)
	self.view.dialogue:TryChangePage("Sence", 1)
	LuaUIUtils.setUIViewVisible(self.view.aside, false)
	LuaUIUtils.setUIViewVisible(self.view.photoShowSaveBtn, false)
	LuaUIUtils.setUIViewVisible(self.view.photoShowListShare, false)
end

function DialogueUIComponent:closeDialogue()
	LuaUIUtils.setUIViewVisible(self.view.dialogue, false)
	LuaUIUtils.setUIViewVisible(self.view.photoShowSaveBtn, true)
	LuaUIUtils.setUIViewVisible(self.view.photoShowListShare, true)
end

function DialogueUIComponent:refreshDialogueContext(monologueText, dialogueText)
	ClientTextUtils.setText(self.view.monologueText, pg.getLocalizationText(monologueText))
	ClientTextUtils.setText(self.view.dialogueText, pg.getLocalizationText(dialogueText))
end

function DialogueUIComponent:onShow()
	return
end

function DialogueUIComponent:update()
	if self.needShowMonologue and not self.monologueTimer and not self.dialogueTimer then
		self:showMonologue()

		self.needShowMonologue = false
		self.monologueTimer = TimerManager.addTimer(3, function()
			self:closeMonologue()
			self:clearMonologueTimer()
		end)
	end
end

function DialogueUIComponent:dismiss()
	UICtrl.dismiss(self)
	self:clearDialogueTimer()
	self:clearMonologueTimer()
end

function DialogueUIComponent:onTakePhotoBtnClick()
	if self.needShowDialogue then
		self:closeMonologue()
		self:showDialogue()
		self:clearDialogueTimer()

		self.dialogueTimer = TimerManager.addTimer(3, function()
			self:closeDialogue()
			self:clearDialogueTimer()
		end)
		self.needShowDialogue = false
	else
		self:closeDialogue()

		if self.dialogueTimer then
			self:clearDialogueTimer()
		end
	end
end

function DialogueUIComponent:setPhotoMonologue(photoId)
	if photoId and not self:checkTriggerPhotoId(photoId) then
		local photoInfo = PhotoIdentifyData[photoId]
		local beforeDialogueData = photoInfo ~= nil and NpcDialogueData[photoInfo.beforeText]

		if beforeDialogueData ~= nil and beforeDialogueData[1] ~= nil then
			local monologueText = beforeDialogueData[1].chat

			self:refreshDialogueContext(monologueText, nil)

			self.needShowMonologue = true
		end
	elseif photoId == nil then
		self.triggerPhotoId = nil
		self.needShowMonologue = false

		self:closeMonologue()

		if self.monologueTimer then
			self:clearMonologueTimer()
		end
	end
end

function DialogueUIComponent:setPhotoDialogue(photoId)
	if photoId then
		local photoInfo = PhotoIdentifyData[photoId]

		if photoInfo ~= nil and photoInfo.highlightText then
			local highlightDialogueData = NpcDialogueData[photoInfo.highlightText]

			if highlightDialogueData ~= nil and highlightDialogueData[1] ~= nil then
				local dialogueText = highlightDialogueData[1].chat

				self:refreshDialogueContext(nil, dialogueText)

				self.needShowDialogue = true
			end
		end
	else
		self.needShowDialogue = false

		self:closeDialogue()

		if self.dialogueTimer then
			self:clearDialogueTimer()
		end
	end
end

function DialogueUIComponent:clearDialogueTimer()
	if self.dialogueTimer ~= nil then
		TimerManager.removeTimer(self.dialogueTimer)

		self.dialogueTimer = nil
	end
end

function DialogueUIComponent:clearMonologueTimer()
	if self.monologueTimer ~= nil then
		TimerManager.removeTimer(self.monologueTimer)

		self.monologueTimer = nil
	end
end

function DialogueUIComponent:checkTriggerPhotoId(photoId)
	if self.triggerPhotoId == nil then
		self.triggerPhotoId = photoId

		return false
	end

	return true
end

return DialogueUIComponent
