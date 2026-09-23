-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientSimpleLookAtComponent.lua

local CommonConst = require("Common.Const.Const")
local class = require("Core.Framework.Class")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local ClientConst = require("Const.ClientConst")
local Utils = require("Common.Utils.Utils")
local Time = require("Core.Common.Time")
local typeof = typeof
local SimpleLookAtComponent = CS.FunPlus.WorldX.Animations.SimpleLookAtComponent
local ClientSimpleLookAtComponent = class.Component("ClientSimpleLookAtComponent")

function ClientSimpleLookAtComponent:EVENT_OnModelRefreshed()
	self.canModelLookAt = self:isEntityCanLookAt()

	if not self.canModelLookAt then
		return
	end

	self:addEModelComponent(CommonConst.COMPONENT_INDEX_IK)

	self.simpleIKComp = self.eModel:AddDynamicRigComponent(CommonConst.COMPONENT_INDEX_IK, typeof(SimpleLookAtComponent))

	if not self.npcLookAtTriggerId and Utils.isNpc(self) and self:getCfgCanLookAt() then
		self.npcLookAtTriggerId = self.eModel:CreateSphereTrigger(ClientConst.TriggerType.NPC_LOOK_AT, 5)
		self.lastPawnDistanceSqr = 0
		self.isLookingAtTemporaryEntity = false
		self.lookAtTemporaryEntityTimer = 0
	end
end

function ClientSimpleLookAtComponent:EVENT_OnAnimatorReady()
	if self.refreshAutoBlink then
		self:refreshAutoBlink()
	end
end

function ClientSimpleLookAtComponent:onLeaveSpace()
	self.lastPawnDistanceSqr = 0
	self.isLookingAtTemporaryEntity = false
	self.lookAtTemporaryEntityTimer = 0

	if self.npcLookAtTriggerId then
		self.eModel:DestroyTrigger(self.npcLookAtTriggerId)

		self.npcLookAtTriggerId = nil
	end
end

function ClientSimpleLookAtComponent:onSeamlessPostEnterSpace()
	self.canModelLookAt = self:isEntityCanLookAt()

	if not self.canModelLookAt then
		return
	end

	self:addEModelComponent(CommonConst.COMPONENT_INDEX_IK)

	if IsNil(self.simpleIKComp) then
		self.simpleIKComp = self.eModel:AddDynamicRigComponent(CommonConst.COMPONENT_INDEX_IK, typeof(SimpleLookAtComponent))
	end

	if not self.npcLookAtTriggerId and Utils.isNpc(self) and self:getCfgCanLookAt() then
		self.npcLookAtTriggerId = self.eModel:CreateSphereTrigger(ClientConst.TriggerType.NPC_LOOK_AT, 5)
		self.lastPawnDistanceSqr = 0
		self.isLookingAtTemporaryEntity = false
		self.lookAtTemporaryEntityTimer = 0
	end
end

function ClientSimpleLookAtComponent:onTriggerEnter(userData)
	if userData == ClientConst.TriggerType.NPC_LOOK_AT then
		self:onEnterLookAtTrigger()
	end
end

function ClientSimpleLookAtComponent:onTriggerExit(userData)
	if userData == ClientConst.TriggerType.NPC_LOOK_AT then
		self:onLeaveLookAtTrigger()
	end
end

function ClientSimpleLookAtComponent:isEntityCanLookAt()
	if Utils.isPetNpc(self) or Utils.isPet(self) then
		return self:getCfgCanLookAt()
	end

	return true
end

function ClientSimpleLookAtComponent:getCfgCanLookAt()
	if self.getSceneEntityCfg then
		return self:getSceneEntityCfg("canLookAt")
	end

	if self.getConfigData then
		return self:getConfigData().canLookAt
	end

	return false
end

function ClientSimpleLookAtComponent:disableDefaultLookAtComp(disable)
	if not self:hasEModelComponent(CommonConst.COMPONENT_INDEX_IK) then
		return
	end

	local lookAtComponent = self.eModel.ikLookAtComponent

	if IsNil(lookAtComponent) then
		return
	end

	if disable then
		self.eModel:EnableRigComponent(CommonConst.COMPONENT_INDEX_IK, lookAtComponent, false)
	else
		local enableLookAt = ToBool(self.lookAtFields) and not self.lookAtFields.abandon

		self.eModel:EnableRigComponent(CommonConst.COMPONENT_INDEX_IK, lookAtComponent, enableLookAt)
	end
end

function ClientSimpleLookAtComponent:lookAtRole(entity, disableAngleLimit, fadeTime)
	if not entity then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			self.logger:debug("Trigger LookAtRole failed: targetEntity not exist", self.actorId)
		end

		return
	end

	if entity == self then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			self.logger:debug("Trigger LookAtRole failed: targetEntity is self", self.actorId)
		end

		return
	end

	if not self.canModelLookAt then
		return
	end

	if not self.simpleIKComp then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			self.logger:debug("Trigger LookAtRole failed: ikComp not exist", self.actorId)
		end

		return
	end

	self:disableDefaultLookAtComp(true)

	if disableAngleLimit == nil then
		disableAngleLimit = true
	end

	fadeTime = fadeTime or 0.2

	self.simpleIKComp:LookAtEntity(entity.id, disableAngleLimit)
	self.eModel:EnableRigComponent(CommonConst.COMPONENT_INDEX_IK, self.simpleIKComp, true, fadeTime)

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("Trigger LookAtRole: %d -> %d", self.actorId, entity.actorId)
	end
end

function ClientSimpleLookAtComponent:lookAtTemporaryRole(entity, fadeTime)
	if not entity then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			self.logger:debug("Trigger LookAtTemporaryRole failed: targetEntity not exist", self.actorId)
		end

		return
	end

	if entity == self then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			self.logger:debug("Trigger LookAtTemporaryRole failed: targetEntity is self", self.actorId)
		end

		return
	end

	if not self.canModelLookAt then
		return
	end

	if not self.simpleIKComp then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			self.logger:debug("Trigger LookAtTemporaryRole failed: ikComp not exist", self.actorId)
		end

		return
	end

	if not self:canAnimTriggerLookAt() then
		return
	end

	fadeTime = fadeTime or 0.2

	self:disableDefaultLookAtComp(true)
	self.simpleIKComp:LookAtTemporaryEntity(entity.actorId)
	self.eModel:EnableRigComponent(CommonConst.COMPONENT_INDEX_IK, self.simpleIKComp, true, fadeTime)

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("Trigger LookAtTemporaryRole: %d -> %d", self.actorId, entity.actorId)
	end
end

function ClientSimpleLookAtComponent:lookAtCamera(camera, disableAngleLimit, fadeTime)
	if not self.canModelLookAt then
		return
	end

	if not self.simpleIKComp then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			self.logger:debug("Trigger LookAtCamera failed: ikComp not exist", self.actorId)
		end

		return
	end

	self:disableDefaultLookAtComp(true)

	if disableAngleLimit == nil then
		disableAngleLimit = true
	end

	fadeTime = fadeTime or 0.2

	self.simpleIKComp:LookAtCamera(camera, disableAngleLimit)
	self.eModel:EnableRigComponent(CommonConst.COMPONENT_INDEX_IK, self.simpleIKComp, true, fadeTime)
end

function ClientSimpleLookAtComponent:lookAtPos(pos, disableAngleLimit, fadeTime)
	if not self.canModelLookAt then
		return
	end

	if not self.simpleIKComp then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			self.logger:debug("Trigger LookAtPos failed: ikComp not exist", self.actorId)
		end

		return
	end

	if disableAngleLimit == nil then
		disableAngleLimit = true
	end

	fadeTime = fadeTime or 0.2

	self:disableDefaultLookAtComp(true)
	self.simpleIKComp:LookAtPos(pos, disableAngleLimit)
	self.eModel:EnableRigComponent(CommonConst.COMPONENT_INDEX_IK, self.simpleIKComp, true, fadeTime)
end

function ClientSimpleLookAtComponent:enableLookAtCameraCenter(enable)
	if not self.canModelLookAt then
		return
	end

	if not self.simpleIKComp then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			self.logger:debug("Trigger LookAtPos failed: ikComp not exist", self.actorId)
		end

		return
	end

	if enable then
		self:disableDefaultLookAtComp(true)
		self.simpleIKComp:LookAtCameraCenter()
		self.eModel:EnableRigComponent(CommonConst.COMPONENT_INDEX_IK, self.simpleIKComp, true)
	else
		self:cancelLookAtRole()
		self.eModel:EnableRigComponent(CommonConst.COMPONENT_INDEX_IK, self.simpleIKComp, false)
	end
end

function ClientSimpleLookAtComponent:cancelLookAtRole(fadeTime)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("Trigger CancelLookAtRole", self.actorId)
	end

	if IsNil(self.simpleIKComp) then
		return
	end

	if fadeTime and fadeTime > 0 then
		self.simpleIKComp:StopLookAt(fadeTime)
	else
		self.simpleIKComp:ResetLookAt()
	end

	self:disableDefaultLookAtComp(false)
end

function ClientSimpleLookAtComponent:canAnimTriggerLookAt()
	if self.simpleIKComp then
		return self.simpleIKComp:CheckAnimCanLookAt()
	end

	return false
end

function ClientSimpleLookAtComponent:onEnterLookAtTrigger()
	if self.triggerLookAtTimer ~= nil then
		self:removeTimer(self.triggerLookAtTimer)

		self.triggerLookAtTimer = nil
	end

	if self:canAnimTriggerLookAt() then
		self.lastPawnDistanceSqr = Vector3.SqrDistance(pg.pawn:getPositionAgentPosition(), self:getPositionAgentPosition())

		if self.lastPawnDistanceSqr <= 9 then
			self:lookAtTemporaryRole(pg.pawn)

			self.lookAtTemporaryEntityTimer = 2
			self.isLookingAtTemporaryEntity = true
		end

		self.triggerLookAtTimer = self:addRepeatTimer(0, function()
			self:tickTriggerLookAtPlayer()
		end)
	end
end

function ClientSimpleLookAtComponent:onLeaveLookAtTrigger()
	if self.simpleIKComp then
		self.simpleIKComp:ClearTemporaryEntity()
	end

	if self.triggerLookAtTimer ~= nil then
		self:removeTimer(self.triggerLookAtTimer)

		self.triggerLookAtTimer = nil
	end

	self.isLookingAtTemporaryEntity = false
	self.lookAtTemporaryEntityTimer = 0
end

function ClientSimpleLookAtComponent:tickTriggerLookAtPlayer()
	if not self.isInDialogue and not pg.game.dialogue:isPlayingDialogueGraph() and pg.pawn then
		Vector3.enableCreateFromCache()

		local curDistanceSqrWithPawn = Vector3.SqrDistance(pg.pawn:getPositionAgentPosition(), self:getPositionAgentPosition())

		Vector3.disableCreateFromCache()

		if curDistanceSqrWithPawn <= 9 then
			if math.abs(curDistanceSqrWithPawn - self.lastPawnDistanceSqr) > 0.0001 then
				self.lastPawnDistanceSqr = curDistanceSqrWithPawn

				if not self.isLookingAtTemporaryEntity then
					self.isLookingAtTemporaryEntity = true

					self:lookAtTemporaryRole(pg.pawn)
				end

				self.lookAtTemporaryEntityTimer = 2
			end
		else
			self.lookAtTemporaryEntityTimer = -1
		end

		if pg.pawn:inAbility() then
			if not self.isLookingAtTemporaryEntity then
				self:lookAtTemporaryRole(pg.pawn)

				self.isLookingAtTemporaryEntity = true
			end

			self.lookAtTemporaryEntityTimer = 2
		end

		self.lookAtTemporaryEntityTimer = self.lookAtTemporaryEntityTimer - Time.unscaledDeltaTime

		if self.isLookingAtTemporaryEntity and self.lookAtTemporaryEntityTimer <= 0 then
			self.simpleIKComp:ClearTemporaryEntity()

			self.isLookingAtTemporaryEntity = false
			self.lookAtTemporaryEntityTimer = 0
		end
	end
end

function ClientSimpleLookAtComponent:preDestroy()
	if self.npcLookAtTriggerId and self.eModel and Utils.isNpc(self) then
		self.eModel:DestroyTrigger(self.npcLookAtTriggerId)

		self.npcLookAtTriggerId = nil
	end
end

function ClientSimpleLookAtComponent:destroy()
	self.simpleIKComp = nil

	if self.triggerLookAtTimer ~= nil then
		self:removeTimer(self.triggerLookAtTimer)

		self.triggerLookAtTimer = nil
	end
end

return ClientSimpleLookAtComponent
