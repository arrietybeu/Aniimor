-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientPlayerInteractNpcComponent.lua

local Time = require("Core.Common.Time")
local Class = require("Core.Framework.Class")
local ClientPlayerInteractNpcComponent = Class.Component("ClientPlayerInteractNpcComponent")

function ClientPlayerInteractNpcComponent:ctor()
	self.dialogueInterCD = {}
	self.dialogueInterState = {}
	self.isInDialogue = false
	self.npcInteractCDInfo = {}
end

function ClientPlayerInteractNpcComponent:tryTriggerDialogue(entId, dialogCd)
	if self.isInDialogue then
		return false
	end

	if self.dialogueInterState[entId] then
		return false
	end

	local now = Time.realSecondCache

	if not self.dialogueInterCD[entId] then
		self.dialogueInterCD[entId] = now
		self.dialogueInterState[entId] = true

		return true
	end

	if dialogCd <= now - self.dialogueInterCD[entId] then
		self.dialogueInterCD[entId] = now
		self.dialogueInterState[entId] = true

		return true
	end

	return false
end

function ClientPlayerInteractNpcComponent:refreshDialogueEndTime(entId)
	local now = Time.realSecondCache

	self.dialogueInterCD[entId] = now
	self.dialogueInterState[entId] = false
end

return ClientPlayerInteractNpcComponent
