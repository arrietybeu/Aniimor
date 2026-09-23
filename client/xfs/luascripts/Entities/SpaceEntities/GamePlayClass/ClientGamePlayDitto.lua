-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\GamePlayClass\\ClientGamePlayDitto.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local ClientGamePlayEntity = require("Entities.SpaceEntities.GamePlayClass.ClientGamePlayEntity")
local SandboxConst = require("Common.Const.SandboxConst")
local ClientConst = require("Const.ClientConst")
local CallbackHandler = require("Core.Common.CallbackHandler")
local ClientGamePlayDitto = class.Class("ClientGamePlayDitto", ClientGamePlayEntity)
local Vector3 = Vector3
local Quaternion = Quaternion

function ClientGamePlayDitto:ctor(entityId)
	ClientGamePlayDitto.super.ctor(self, entityId)

	self.waitingEntity = false

	self:addRepeatTimer(0.2, CallbackHandler(self, "tick"))

	self.dittoPos = Vector3()
	self.dittoRot = Quaternion()
end

function ClientGamePlayDitto:init(dict)
	ClientGamePlayDitto.super.init(self, dict)

	self.flyTime = dict.flyTime
	self.startDialogueId = dict.startDialogueId
	self.successDialogueId = dict.successDialogueId
	self.failDialogueId = dict.failDialogueId
	self.dittoStaticId = dict.dittoStaticId

	return true
end

function ClientGamePlayDitto:on_status_changed(old, new)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("Ditto ClientGamePlayDitto status change, old=%d, new=%d", old, new)
	end

	if new == SandboxConst.DITTO_STATE.FIRST_ACTIVE or new == SandboxConst.DITTO_STATE.REPEAT_ACTIVE then
		self.waitingEntity = true
	elseif new == SandboxConst.DITTO_STATE.SUCCESS then
		pg.game.dialogue:playDialogue(self.successDialogueId, function()
			local npc = self:getNpc()

			npc:setVisible(ClientConst.MODEL_VISIBLE_KEY.DITTO, false, false)
			self:serverMsg("RPC_CS_SuccessDialogue")
		end, self.dittoPos, self.dittoRot, function(dialogueItem)
			dialogueItem:SetEntityBindings(self.bindings)
		end)
	elseif new == SandboxConst.DITTO_STATE.FAIL then
		pg.game.dialogue:playDialogue(self.failDialogueId, function()
			local npc = self:getNpc()

			npc:setVisible(ClientConst.MODEL_VISIBLE_KEY.DITTO, true, true)
			self:serverMsg("RPC_CS_FailDialogue")
		end, self.dittoPos, self.dittoRot, function(dialogueItem)
			dialogueItem:SetEntityBindings(self.bindings)
		end)
	elseif new == SandboxConst.DITTO_STATE.OUT_OF_RANGE then
		local npc = self:getNpc()

		npc:setVisible(ClientConst.MODEL_VISIBLE_KEY.DITTO, true, true)
	elseif new == SandboxConst.DITTO_STATE.INACTIVE then
		local npc = self:getNpc()

		npc:setVisible(ClientConst.MODEL_VISIBLE_KEY.DITTO, true, true)
	end
end

function ClientGamePlayDitto:on_puppetIds_changed(old, new)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("Ditto ClientGamePlayDitto puppetIds change, old=%d, new=%d", old, new)
	end

	for _, puppetId in ipairs(self.puppetIds) do
		local puppet = pg.getEntity(puppetId)

		if puppet then
			puppet:setVisible(ClientConst.MODEL_VISIBLE_KEY.DIALOGUE_TIMELINE, false, false)
		end
	end
end

function ClientGamePlayDitto:tick()
	if self.waitingEntity then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:info("Ditto ClientGamePlayDitto tick WaitingEntity")
		end

		local npc = self:getNpc()

		if not npc or not npc:modelLoaded() then
			return
		end

		local bindings = {
			npc = self.npcId
		}

		for i, puppetId in ipairs(self.puppetIds) do
			bindings["puppet_" .. i] = puppetId
		end

		self.bindings = bindings
		self.waitingEntity = false

		pg.game.dialogue:playDialogue(self.startDialogueId, function()
			self:serverMsg("RPC_CS_StartDialogue")
			npc:setVisible(ClientConst.MODEL_VISIBLE_KEY.DITTO, false, false)
		end, npc:getPosition(), npc:getRotation():ToEulerAngles(), function(dialogueItem)
			dialogueItem:SetEntityBindings(self.bindings)
		end)
	end

	local ditto = pg.me.space:getEntityByStaticId(self.dittoStaticId)

	if ditto then
		self.dittoPos = ditto:getPosition()

		local playerPos = pg.me:getPosition()

		self.dittoRot = Quaternion.LookRotation(playerPos - self.dittoPos, Vector3.up):ToEulerAngles()
	end

	local sandbox = pg.me.space:getSandbox(self.sandboxId)
	local shouldShowPhoto = self.status == SandboxConst.DITTO_STATE.FIRST_ACTIVE or self.status == SandboxConst.DITTO_STATE.REPEAT_ACTIVE

	shouldShowPhoto = shouldShowPhoto and sandbox and sandbox.isPhotoIdentifyActive

	if shouldShowPhoto then
		pg.global.ui.interact:enterTriggerPhotoIdentifyInteract(self.sandboxId)
	else
		pg.global.ui.interact:leaveTriggerPhotoIdentifyInteract(self.sandboxId)
	end
end

function ClientGamePlayDitto:getNpc()
	return pg.getEntity(self.npcId)
end

function ClientGamePlayDitto:destroy()
	pg.global.ui.interact:leaveTriggerPhotoIdentifyInteract(self.sandboxId)
	ClientGamePlayDitto.super.destroy(self)
end

return ClientGamePlayDitto
