-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientMagnesisComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local InputCommand = require("GameApp.Input.InputCommand")
local MessageName = require("Const.MessageName")
local InputBuffer = require("GameApp.Input.InputBuffer")
local HotkeyConst = require("Const.HotkeyConst")
local ClientConst = require("Const.ClientConst")
local NoticeDef = require("Common.NoticeDef")
local SysConfigData = require("Data.sys_config_data")
local PlayableEventConst = require("Const.PlayableEventConst")
local VolumeEffectConst = require("Const.VolumeEffectConst")
local Const = require("Common.Const.Const")
local MagneticObject = CS.FunPlus.WorldX.Entities.EnvObj.MagneticObject
local MagnesisControlState = CS.FunPlus.WorldX.Entities.Components.MagnesisControlState
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local SandboxConst = require("Common.Const.SandboxConst")
local Vector3 = Vector3
local typeof = typeof
local NotNil = NotNil
local ToBool = ToBool
local unpack = unpack
local MAGNESIS_GRAB_RESULT = {
	FAILED_KINEMATIC_TARGET = 0,
	FAILED_NO_TARGET = -1,
	SUCCESS = 1
}
local ClientMagnesisComponent = Class.Component("ClientMagnesisComponent")

function ClientMagnesisComponent:ctor()
	self.isGrabbing = false
	self.isThrowing = false
	self.curMagneticObjects = {}
	self.combatContext = nil
	self.triggerActions = nil
	self.onStartActions = nil
	self.onFinishActions = nil
	self.controllingEnt = nil
	self.magnesisInputBuffer = InputBuffer.new()
	self.maxIndicateDistance = SysConfigData.maxMagnesisIndicationDis or 30
	self.emptyTable = {}
	self.combatContextNeedReturn = false
end

function ClientMagnesisComponent:preDestroy()
	self:setMagnesisModeEnable(false)
end

function ClientMagnesisComponent:setMagnesisModeEnable(enable)
	self:enableMagnesisMode(enable)
	pg.game.input:enableCatchInput(not enable)
	pg.global.inputMgr:SetInputActionEnabled(HotkeyConst.INPUT_MAP_ACTION_KEY.Camera_Zoom, not enable, HotkeyConst.INPUT_BLOCK_FLAG.Magnesis)
	pg.game:setModuleEnable("Magnesis", ClientConst.ModuleKey.NormalAttack, not enable)
	pg.game.camera.playerCameraMode:enableMagnesisCameraMode(enable)
	facade:sendMsgToUI(MessageName.MAGNESIS_MODE_CHANGE, enable)
end

function ClientMagnesisComponent:enableMagnesisMode(enable)
	if enable then
		self:onMagnesisAbilityStart()
		self:onEnterMagnesisMode()
	else
		if self.eModel and self.eModel:IsControlling(Const.COMPONENT_MAGNESIS_CONTROLLER) then
			self:onStopMagnesisControl()
		end

		self:onLeaveMagnesisMode()
		self:onMagnesisAbilityEnd()
	end
end

function ClientMagnesisComponent:magnesisGrabOrThrow()
	if not self.isGrabbing then
		local magneticObj = self.eModel:TryGetCurLockedMagneticObj(Const.COMPONENT_MAGNESIS_CONTROLLER)

		if NotNil(magneticObj) then
			local globalId = magneticObj:GetGlobalId()

			if ToBool(globalId) then
				self:serverMsg("RPC_CS_OnMagnesisControl", globalId, function(msg)
					if msg ~= NoticeDef.SUCCESS then
						pg.global.showBubbleMessageById(msg)

						return
					end

					local ret = self.eModel:MagnesisGrab(Const.COMPONENT_MAGNESIS_CONTROLLER, magneticObj)

					if ret == MAGNESIS_GRAB_RESULT.SUCCESS then
						self.isGrabbing = true
						self.isThrowing = false

						self:onMagnesisSuccessGrab(globalId)
						self:onMagnesisAim(0)
					elseif ret == MAGNESIS_GRAB_RESULT.FAILED_KINEMATIC_TARGET then
						self:onMagnesisGrabKinematicFailed()
					end
				end)
			end
		end
	else
		self.magnesisInputBuffer:enqueue(InputCommand.MagnesisRelease)
	end
end

function ClientMagnesisComponent:magnesisCancel()
	if EnableBotTest then
		return
	end

	if self.eModel.controlState == MagnesisControlState.None then
		return
	end

	if self.isThrowing then
		return false
	end

	self:setMagnesisModeEnable(false)
end

function ClientMagnesisComponent:magnesisUpdateControlDistance(axis)
	self.eModel:UpdateControlDistance(Const.COMPONENT_MAGNESIS_CONTROLLER, axis)
end

function ClientMagnesisComponent:registerMagnesisAbilityActions(combatContext, triggerActions, onStartActions, onFinishActions)
	self.combatContext = combatContext
	self.triggerActions = triggerActions
	self.onStartActions = onStartActions
	self.onFinishActions = onFinishActions
end

function ClientMagnesisComponent:onMagnesisAbilityStart()
	pg.game.controller.lockHelper:cancelForceLockTarget()

	if not self.combatContext then
		self:serverMsg("RPC_CS_OnMagnesisLevel", self.emptyTable, true)

		return
	end

	self:addCombatContextRefCnt(self.combatContext)
	self:serverMsg("RPC_CS_OnMagnesisLevel", self.combatContext:getRPCDynamicInfo(), true)

	if self.onStartActions then
		pg.global.abilityMgr.combatAction:doActionIds(self.onStartActions, self.combatContext)
	end

	self.combatContextNeedReturn = true
end

function ClientMagnesisComponent:onMagnesisAbilityEnd()
	if not self.combatContext then
		self:serverMsg("RPC_CS_OnMagnesisLevel", self.emptyTable, false)

		return
	end

	if not self.combatContextNeedReturn then
		return
	end

	self.combatContextNeedReturn = false

	self:serverMsg("RPC_CS_OnMagnesisLevel", self.combatContext:getRPCDynamicInfo(), false)

	if self.onFinishActions then
		pg.global.abilityMgr.combatAction:doActionIds(self.onFinishActions, self.combatContext)
	end

	self:returnCombatContext(self.combatContext)
end

function ClientMagnesisComponent:onEnterMagnesisMode()
	self:addAnimEventListeners()
	pg.game.camera:addVolumeEffect(VolumeEffectConst.MAGNESIS_EFFECT)
	self:refreshMagnesisTargetsTips()

	self.tipTimer = self:addRepeatTimer(0.5, function()
		self:refreshMagnesisTargetsTips()
	end)

	pg.game.audio:triggerEvent("rulepower_control_start")

	self.eModel.controlState = MagnesisControlState.Ready

	self.magnesisInputBuffer:clear()
	AIControllerUtils.sendAIEvent(self:getCurPetEntity(), "Msg_MasterMagnesisMode")
end

function ClientMagnesisComponent:onLeaveMagnesisMode()
	self:removeAnimEventListeners()
	pg.game.camera:delVolumeEffect(VolumeEffectConst.MAGNESIS_EFFECT)
	self:stopMagnesisTargetsTips()
	pg.game.audio:triggerEvent("rulepower_control_end")
	pg.game.audio:stopEvent("rulepower_control_catching_loop")

	if self.eModel then
		self.eModel.controlState = MagnesisControlState.None
	end

	self.controllingEnt = nil
end

function ClientMagnesisComponent:onMagneticObjectHit(actorId, actorPartIdx, hitPos, hitNormal)
	if not self.combatContext then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("@hyj Magnesis OnMagneticObjectHit error: combatContext is nil")
		end

		return
	end

	local triggerActions = self.triggerActions

	if not ToBool(triggerActions) then
		return false
	end

	local hitEntity = pg.getEntityByActorId(actorId)

	if hitEntity == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("@hyj hitEntity is nil", actorId)
		end

		return false
	end

	if hitEntity.useHitBox and actorPartIdx == 0 then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("@hyj not hit part", actorId)
		end

		return false
	end

	hitPos = Vector3(unpack(hitPos))
	self.combatContext.constCasterInfo.attackPos = hitPos
	self.combatContext.runtimeTargetInfo = pg.global.abilityMgr.runtimeTargetInfoPool:get(true)

	self.combatContext.runtimeTargetInfo:initTarget(actorId, hitPos, 1, actorPartIdx)
	self:serverMsg("RPC_CS_MagnesisHitTarget", self.combatContext:getRPCDynamicInfo())
	pg.global.abilityMgr.combatAction:doActionIds(triggerActions, self.combatContext)
	pg.global.abilityMgr.runtimeTargetInfoPool:returnObject(self.combatContext.runtimeTargetInfo)

	self.combatContext.runtimeTargetInfo = nil

	return true
end

function ClientMagnesisComponent:onMagnesisAim(isAim)
	facade:sendMsgToUI(MessageName.MAGNESIS_AIM, isAim)

	if isAim == 1 then
		pg.game.audio:triggerEvent("rulepower_control_aim")
	end
end

function ClientMagnesisComponent:onMagnesisSuccessGrab(globalId)
	self:stopMagnesisTargetsTips()
	facade:sendMsgToUI(MessageName.MAGNESIS_SWITCH_BEHAVIOR, true)
	pg.game.audio:triggerEvent("rulepower_control_catching_loop")

	local ent = pg.getEntityByGlobalId(globalId)
	local eventData = {
		id = ent.staticId
	}

	facade:sendLuaEvent(ent.staticId .. SandboxConst.COMMON_EVENT.LEVELITEM_ENTER_MAGNESIS, eventData)
end

function ClientMagnesisComponent:onMagnesisGrabKinematicFailed()
	pg.global.showBubbleMessageRaw(pg.getGameString("FAILED_KINEMATIC_TARGET"))
	self:magnesisCancel()
end

function ClientMagnesisComponent:onMagnesisThrow()
	if self.controllingEnt then
		self.controllingEnt:playMagnesisEffect("Eff_Item_ExploreSkill_SnatchThrow")
	end

	self:stopMagnesisLoopEffects()
	self:serverMsg("RPC_CS_OnMagnesisThrow", self.eModel:GetThrowTargetPos(Const.COMPONENT_MAGNESIS_CONTROLLER), function()
		self.eModel:MagnesisThrow(Const.COMPONENT_MAGNESIS_CONTROLLER)

		self.isThrowing = false

		self:magnesisCancel()

		self.exitAfterThrow = nil
	end)

	self.isGrabbing = false
	self.isThrowing = true
end

function ClientMagnesisComponent:onStopMagnesisControl()
	self:stopMagnesisLoopEffects()
	self.eModel:MagnesisCancel(Const.COMPONENT_MAGNESIS_CONTROLLER)

	self.isGrabbing = false
	self.isThrowing = false
end

function ClientMagnesisComponent:addAnimEventListeners()
	function self.playMagnesisBeginEffectsHandler()
		self:playMagnesisBeginEffects()
	end

	function self.playMagnesisLoopEffectsHandler()
		self:playMagnesisLoopEffects()
	end

	function self.onMagnesisThrowHandler()
		self:onMagnesisThrow()

		self.exitAfterThrow = true
	end

	function self.onMagnesisCancelHandler()
		self:magnesisCancel()

		self.exitAfterThrow = nil
	end

	self.eventEmitter:onceEventListener(PlayableEventConst.magnesisBegin, self.playMagnesisBeginEffectsHandler)
	self.eventEmitter:onceEventListener(PlayableEventConst.magnesisLoop, self.playMagnesisLoopEffectsHandler)
	self.eventEmitter:onceEventListener(PlayableEventConst.magnesisThrow, self.onMagnesisThrowHandler)
end

function ClientMagnesisComponent:removeAnimEventListeners()
	self.eventEmitter:removeEventListener(PlayableEventConst.magnesisBegin, self.playMagnesisBeginEffectsHandler)
	self.eventEmitter:removeEventListener(PlayableEventConst.magnesisLoop, self.playMagnesisLoopEffectsHandler)
	self.eventEmitter:removeEventListener(PlayableEventConst.magnesisThrow, self.onMagnesisThrowHandler)
end

function ClientMagnesisComponent:refreshMagnesisTargetsTips()
	self:showTips(self.curMagneticObjects, false)

	self.curMagneticObjects = self:tryGetMagnesisTargets()

	self:showTips(self.curMagneticObjects, true)
end

function ClientMagnesisComponent:tryGetMagnesisTargets()
	local maxDis = self.maxIndicateDistance
	local all = pg.getEntities()
	local playerPos = pg.pawn:getPosition()
	local magnesisTargets = {}

	for envId, _ in pairs(all) do
		local ent = all[envId]
		local physxComponent = ent.getEModelMonoComponent and ent:getEModelMonoComponent(Const.COMPONENT_IDX_PHYSX)

		if NotNil(physxComponent) then
			local magneticObj = physxComponent.gameObject:GetComponent(typeof(MagneticObject))

			if NotNil(magneticObj) then
				local targetPos = ent:getPosition()
				local targetDistance = Vector3.Distance(playerPos, targetPos)

				if targetDistance < maxDis then
					magnesisTargets[envId] = magneticObj
				end
			end
		end
	end

	return magnesisTargets
end

function ClientMagnesisComponent:showTips(entities, enable)
	for envId, _ in pairs(entities) do
		local magneticObj = entities[envId]

		if NotNil(magneticObj) then
			magneticObj:EnableTipMaterial(enable)
		end
	end
end

function ClientMagnesisComponent:stopMagnesisTargetsTips()
	if ToBool(self.curMagneticObjects) then
		self:showTips(self.curMagneticObjects, false)

		self.curMagneticObjects = {}
	end

	if self.tipTimer then
		self:removeTimer(self.tipTimer)

		self.tipTimer = nil
	end
end

function ClientMagnesisComponent:playMagnesisBeginEffects()
	local controllingTargetGlobalId = self.eModel:GetControllingTargetId(Const.COMPONENT_MAGNESIS_CONTROLLER)
	local targetEnt = pg.getEntityByGlobalId(controllingTargetGlobalId)

	if targetEnt then
		self.controllingEnt = targetEnt

		targetEnt:playMagnesisEffect("Eff_Item_ExploreSkill_SnatchBegin")
	end
end

function ClientMagnesisComponent:playMagnesisLoopEffects()
	self:stopMagnesisLoopEffects()

	if self.controllingEnt then
		self.playerEffectId = self:playSyncMagnesisEffect("Eff_Avatar_Girl_ExploreSkill_SnatchLoop")
		self.targetEffectId = self.controllingEnt:playMagnesisEffect("Eff_Item_ExploreSkill_SnatchLoop")
	end
end

function ClientMagnesisComponent:stopMagnesisLoopEffects()
	if self.playerEffectId then
		self:stopSyncMagnesisEffect("Eff_Avatar_Girl_ExploreSkill_SnatchLoop", self.playerEffectId)

		self.playerEffectId = nil
	end

	if self.targetEffectId and self.controllingEnt then
		self.controllingEnt:stopMagnesisEffect("Eff_Item_ExploreSkill_SnatchLoop", self.targetEffectId)

		self.targetEffectId = nil
	end
end

function ClientMagnesisComponent:isMagnesisControlling()
	return self.eModel:IsControlling(Const.COMPONENT_MAGNESIS_CONTROLLER)
end

function ClientMagnesisComponent:isMagnesisReady()
	return self.eModel and self.eModel.controlState == MagnesisControlState.Ready
end

function ClientMagnesisComponent:isInMagnesisMode()
	return self.eModel.controlState ~= MagnesisControlState.None
end

function ClientMagnesisComponent:tryPerformMagnesis(inputCommand)
	local first = self.magnesisInputBuffer:first()

	if self:MAGNESIS_THROW_ST() and first == InputCommand.MagnesisRelease then
		self.magnesisInputBuffer:dequeue()
	end

	if first == inputCommand then
		self.magnesisInputBuffer:dequeue()

		return true
	end

	return false
end

function ClientMagnesisComponent:doQuickMagnesisGrab(distance)
	if self:MAGNESIS_ST() then
		local cloestDistance = distance
		local pawn = pg.pawn
		local playerPos = pawn:getPosition() + Vector3(0, pawn.eModel.height, 0)
		local curMagneticObj, globalId

		for envId, _ in pairs(self.curMagneticObjects) do
			local ent = pg.getEntityByGlobalId(envId)
			local magneticObj = self.curMagneticObjects[envId]

			if ent and not ent.isMagnesisControlling and NotNil(magneticObj) then
				local targetPos = ent:getPosition()
				local targetDistance = Vector3.Distance(playerPos, targetPos)

				if targetDistance < cloestDistance then
					cloestDistance = targetDistance
					curMagneticObj = magneticObj
					globalId = envId
				end
			end
		end

		if NotNil(curMagneticObj) and ToBool(globalId) then
			self:forceGrabMagneticObejct(curMagneticObj, globalId)
		end
	end
end

function ClientMagnesisComponent:forceGrabMagneticObejct(magneticObj, globalId)
	self:serverMsg("RPC_CS_OnMagnesisControl", globalId, function(msg)
		if msg ~= NoticeDef.SUCCESS then
			pg.global.showBubbleMessage(msg)

			return
		end

		if self.eModel:MagnesisForceGrab(Const.COMPONENT_MAGNESIS_CONTROLLER, magneticObj) then
			self:onMagnesisSuccessGrab(globalId)

			self.isGrabbing = true

			self:onMagnesisAim(0)
		else
			self:onMagnesisGrabKinematicFailed()
		end
	end)
end

function ClientMagnesisComponent:playSyncMagnesisEffect(effectId)
	local effInstanceId = self:playEffect(effectId)

	self:serverMsgNoGC("RPC_CS_SyncPlayerPlayMagnesisEffect", effectId)

	return effInstanceId
end

function ClientMagnesisComponent:stopSyncMagnesisEffect(effectId, instanceId)
	if self:hasEModelComponent(Const.COMPONENT_INDEX_EFFECT) then
		if instanceId then
			self:stopEffectById(instanceId)
		else
			self:stopEffect(effectId)
		end
	end

	self:serverMsgNoGC("RPC_CS_SyncPlayerStopMagnesisEffect", effectId)
end

function ClientMagnesisComponent:onLeaveSpace()
	self:magnesisCancel()
end

return ClientMagnesisComponent
