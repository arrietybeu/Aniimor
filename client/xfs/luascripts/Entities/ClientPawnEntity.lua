-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\ClientPawnEntity.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local ClientModelEntity = require("Entities.ClientModelEntity")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local ClientModelUtils = require("Utils.ClientModelUtils")
local VoxelUtils = require("Common.Utils.VoxelUtils")
local EffectCommonMountData = require("Common.Data.Effect.effect_common_mount_data")
local Const = require("Common.Const.Const")
local DialogueConst = require("Const.DialogueConst")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local SysConfigData = require("Data.sys_config_data")
local Utils = require("Common.Utils.Utils")
local MessageName = require("Const.MessageName")
local ClientUtils = require("Utils.ClientUtils")
local NoticeDef = require("Common.NoticeDef")
local UIConst = require("Const.UIConst")
local Vector3 = Vector3
local Quaternion = Quaternion
local ClientPawnEntity = Class.Class("ClientPawnEntity", ClientModelEntity)
local ClientConst = require("Const.ClientConst")
local ClientActorComponent = require("Entities.SpaceEntities.CommonComponent.ClientActorComponent")
local ClientModelComponent = require("Entities.SpaceEntities.CommonComponent.ClientModelComponent")
local ClientPhysicsComponent = require("Entities.SpaceEntities.CommonComponent.ClientPhysicsComponent")
local ClientAnimationComponent = require("Entities.SpaceEntities.CommonComponent.ClientAnimationComponent")
local ClientAudioComponent = require("Entities.SpaceEntities.CommonComponent.ClientAudioComponent")
local ClientEffectComponent = require("Entities.SpaceEntities.PlayerComponent.ClientEffectComponent")
local PawnComponents = {
	ClientActorComponent,
	ClientModelComponent,
	ClientPhysicsComponent,
	ClientAnimationComponent,
	ClientAudioComponent,
	ClientEffectComponent
}

if EnableBotTest then
	PawnComponents = {
		ClientActorComponent,
		ClientAudioComponent,
		ClientAnimationComponent,
		ClientEffectComponent
	}
end

Class.AddComponents(ClientPawnEntity, PawnComponents)

function ClientPawnEntity:ctor(entityId)
	ClientPawnEntity.super.ctor(self, entityId)
end

function ClientPawnEntity:destroy()
	if self.waitModelMark then
		pg.global.scene:markWaitEntity(self.id, false)

		self.waitModelMark = nil
	end

	ClientPawnEntity.super.destroy(self)
end

function ClientPawnEntity:init(bdict)
	local result = ClientPawnEntity.super.init(self, bdict)

	self.deformData = nil

	return result
end

function ClientPawnEntity:isDeforming()
	return self.deformData and true or false
end

function ClientPawnEntity:deformTo(deformData, deformContext)
	self:postComponentMethod("EVENT_Deform")

	self.deformData = deformData
	self.deformContext = deformContext

	self:onConfigDataChange()
end

function ClientPawnEntity:isDeformToPlayer()
	return self.deformContext and self.deformContext.isPlayer
end

function ClientPawnEntity:isDeformToPuppet(templateId)
	if not self:isDeforming() then
		return false
	end

	if not self.deformContext or not self.deformContext.isPuppet then
		return false
	end

	if templateId ~= nil and templateId ~= self.deformContext.templateId then
		return false
	end

	return true
end

function ClientPawnEntity:isDeformToPet(templateId)
	if not self:isDeforming() then
		return false
	end

	if not self.deformContext or not self.deformContext.isPet then
		return false
	end

	if templateId ~= nil and templateId ~= self.deformContext.templateId then
		return false
	end

	return true
end

function ClientPawnEntity:onConfigDataChange()
	self:postComponentMethod("EVENT_ConfigDataChange")
	self:refreshAppearance(true)

	if self.eModel then
		self.eModel:ResetController(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER)
	end

	if Utils.isPet(self) and self.calcAndRefreshModelScale then
		self:calcAndRefreshModelScale(true)
	end

	self:refreshPhysxData()

	if self.applyMotionProp then
		self:applyMotionProp()
	end

	self:setControllerMachine()

	if self.refreshStepHeight and pg.pawn == self then
		self:refreshStepHeight()
	end

	if pg.game.camera.targetPlayer == self and self.eModel then
		pg.game.camera:refreshTargetPlayer()
	end

	if self.refreshTopLogo then
		self:refreshTopLogo()
	end
end

function ClientPawnEntity:onRefreshAppearance(configData, extraData, forceRefreshPlayable)
	ClientPawnEntity.super.onRefreshAppearance(self, configData, extraData, forceRefreshPlayable)

	local modelView = self.eModel.modelModelView

	if self.deformContext and self.deformContext.modelRefreshCallback then
		modelView.modelInfo.physiqueModelInfo.refreshCallback = self.deformContext.modelRefreshCallback
	end

	local individuationIds = self:getIndividuationIds()

	ClientModelUtils.applyIndividuation(self, individuationIds)
	self.eModel:SetDebugImagePath(Const.COMPONENT_INDEX_MODEL, configData.debugImageResID)
	self:setLookAtInfo()
	self:refreshAttachEffects()
end

function ClientPawnEntity:refreshModel(configData, extraData)
	local modelView = self.eModel.modelModelView

	ClientModelUtils.applyModelAppearance(modelView.modelInfo, configData, extraData)
	ClientModelUtils.refreshModels(self, modelView)
end

function ClientPawnEntity:onModelRefreshed()
	if self.waitModelMark then
		pg.global.scene:markWaitEntity(self.id, false)

		self.waitModelMark = nil
	end

	self.isModelLoaded = true

	ClientPawnEntity.super.onModelRefreshed(self)
	self:setModelLoaded(true)

	local modelText = self:getConfigData().modelText

	if modelText then
		local showText = pg.getLocalizationText(modelText)

		self.eModel.modelView:SetModelText(showText, ClientConst.ModelTextType.Default)
	end
end

function ClientPawnEntity:getModelExtraData(configData, petInfo)
	local label = self:getLabel()
	local gender = self:getGender()
	local canAttachEffs = self:getCanAttachEffs()

	return ClientModelUtils.getModelExtraInfo(configData, label or 0, gender or 0, canAttachEffs, nil, petInfo)
end

function ClientPawnEntity:setLookAtInfo()
	local configData = self:getConfigData()
	local mountData = (EffectCommonMountData[configData.prefabResID] or EMPTY_TABLE).CM_LookAt

	if mountData then
		local pos = mountData.position
		local lookAtBone = mountData.bone

		self.eModel:SetLookaAtInfo(Const.COMPONENT_INDEX_MODEL, lookAtBone, pos or Vector3.constZero)
	end
end

function ClientPawnEntity:getCanAttachEffs()
	return true
end

function ClientPawnEntity:refreshAttachEffects()
	local attachEffects = {}

	if self.spEffs then
		local ret = {}

		for _, key in ipairs(self.spEffs) do
			ret[#ret + 1] = {
				effectKey = key
			}
		end

		attachEffects = ret
	else
		local configData = self:getConfigData()
		local label = self:getLabel()
		local petInfo = Utils.isPet(self) and self.petInfo or nil
		local extraData = ClientModelUtils.getModelExtraInfo(configData, label or 0, self.gender, not self:hideTitleAndEffs(), nil, petInfo)

		attachEffects = extraData.attachEffects
	end

	if self.attachBaseEffects then
		self:attachBaseEffects(attachEffects)
	end
end

function ClientPawnEntity:onActiveChange(active)
	if active then
		local individuationIds = self:getIndividuationIds()

		ClientModelUtils.applyIndividuation(self, individuationIds)
	end

	ClientPawnEntity.super.onActiveChange(self, active)
end

function ClientPawnEntity:hideTitleAndEffs()
	return false
end

function ClientPawnEntity:onBeControlled(oldEnt)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientModelEntity onBeControlled", self.id)
	end

	self:applyCharacterControllerProp()

	self.beControlled = true

	self:postComponentMethod("EVENT_Before_BeControlled")

	local st, err = xpcall(function()
		self:restoreCharacterState()
	end, debug.traceback)

	if not st then
		local exceptionError = err or "unknown error occurred"

		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("%s onBeControlled failed, %s", self:repr(), exceptionError)
		end
	end

	self:refreshStepHeight()
	self:postComponentMethod("EVENT_BeControlled")
end

function ClientPawnEntity:onLoseControlled()
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientModelEntity onLoseControlled", self.id)
	end

	self.beControlled = false

	self:postComponentMethod("EVENT_LoseControlled")
end

function ClientPawnEntity:followTarget(targetActorId)
	if Utils.checkIsAuthorityMaster(self) and (Utils.isPlayer(self) or Utils.isPlayerPet(self)) then
		return self.eModel:SetFollowTarget(Const.COMPONENT_FOLLOW_OTHER, targetActorId)
	end

	return false
end

function ClientPawnEntity:setFollowTargetDistanceByIndex(followIndex)
	if Utils.checkIsAuthorityMaster(self) and (Utils.isPlayer(self) or Utils.isPlayerPet(self)) then
		self.eModel:SetStopSqrDistanceByIndex(Const.COMPONENT_FOLLOW_OTHER, followIndex)
	end
end

function ClientPawnEntity:cancelFollowTarget()
	if Utils.checkIsAuthorityMaster(self) and (Utils.isPlayer(self) or Utils.isPlayerPet(self)) then
		self.eModel:SetFollowTarget(Const.COMPONENT_FOLLOW_OTHER, 0)
	end
end

function ClientPawnEntity:setControllerMachine(fromState)
	if self:hasEModelComponent(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER) then
		self:refreshHeightLimit()

		local configData = self:getConfigData()

		self.eModel:SetControllerMachine(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, ClientModelUtils.getAnimController(configData), fromState or CharacterStateConst.NONE)
	end
end

function ClientPawnEntity:syncPosThisFrame()
	pg.world.setIsSyncPosThisFrame(self.actorId, true)
end

function ClientPawnEntity:restoreCharacterState()
	if not self:hasEModelComponent(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER) then
		return
	end

	local controller = pg.game.controller
	local moveAxis = controller.moveAxis

	if moveAxis ~= nil and (moveAxis[1] ~= 0 or moveAxis[2] ~= 0) then
		self.eModel:OnHandleMove(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, moveAxis[1], moveAxis[2], moveAxis[3])
	end

	local switchInfo = controller.switchInfo
	local fromState, startVelocity, startRotation, abilityStateDuration, abilityVelocity

	if switchInfo.enabled then
		if not switchInfo.filterState or CharacterStateConst.isChildOfState(switchInfo.pendingCharacterState, CharacterStateConst.LOCOMOTION) then
			fromState = switchInfo.pendingCharacterState
			startVelocity = switchInfo.pendingVelocity
			startRotation = switchInfo.pendingRotation
			abilityStateDuration = switchInfo.pendingAbilityStateDuration
			abilityVelocity = switchInfo.pendingAbilityVelocity
		end

		controller:resetControllerState()
	end

	local controllerComponent = self:getEModelComponent(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER)
	local abilityCharacterStateInfo = NotNil(controllerComponent) and controllerComponent.abilityCharacterStateInfo or nil

	if startVelocity and abilityCharacterStateInfo then
		self.eModel:SetVelocity(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, startVelocity)
	end

	if abilityStateDuration and abilityCharacterStateInfo then
		abilityCharacterStateInfo.abilityStateDuration = abilityStateDuration
	end

	if abilityVelocity and abilityCharacterStateInfo then
		abilityCharacterStateInfo.abilityVelocity = abilityVelocity
	end

	if self:SPECIAL_DEFENSE_ST() then
		fromState = CharacterStateConst.SPECIALDEFENSE
	end

	if fromState == CharacterStateConst.LAND then
		fromState = nil
	end

	self:setControllerMachine(fromState or CharacterStateConst.NONE)
end

function ClientPawnEntity:getTemplateData()
	return {}
end

function ClientPawnEntity:getConfigData()
	if self.deformData then
		return self.deformData
	end

	local baseConfigData = self:getTemplateData()

	return baseConfigData
end

function ClientPawnEntity:getLowGravityJumpScale(status)
	local v = 1

	if status == 1 then
		v = self:getConfigData().animScaleInInflate or SysConfigData.defaultAnimScaleInInflate or 3
	elseif status == 2 then
		v = self:getConfigData().animScaleInLowGravity or SysConfigData.defaultAnimScaleInLowGravity or 3
	elseif status == 3 then
		v = self:getConfigData().animScaleInLowGravityAndInflate or SysConfigData.defaultAnimScaleInLowGravityAndInflate or 6
	end

	return v
end

function ClientPawnEntity:getLogicSmInitParams()
	local data = self:getConfigData()
	local ret = {}

	if data.canBurrow then
		table.insert(ret, "Burrow")
	end

	if data.canFly or data.canFloat or data.canInflate then
		table.insert(ret, "Fly")
	end

	if data.canInflate then
		table.insert(ret, "InflateDash")
	end

	if data.canSpeedBurst then
		table.insert(ret, "SpeedBurst")
	end

	if data.canHighJump then
		table.insert(ret, "HighJump")
	end

	return ret
end

function ClientPawnEntity:tick(deltaTime)
	ClientPawnEntity.super.tick(self, deltaTime)
	self:postComponentMethod("tick", deltaTime)
end

function ClientPawnEntity:getLabel()
	if self.deformContext and self.deformContext.label then
		return self.deformContext.label
	end

	return self.label
end

function ClientPawnEntity:getGender()
	return self.gender
end

function ClientPawnEntity:getIndividuationIds()
	if self.deformContext and self.deformContext.individuationIds then
		return self.deformContext.individuationIds
	end

	return self.individuationIds
end

function ClientPawnEntity:onHitAirWall(tipType, dialogueId)
	if not self.isMainPet and not self.isMainPlayer or not self.beControlled then
		return
	end

	if tipType == UIConst.AIR_WALL_TIP_TYPE.Dialogue then
		dialogueId = dialogueId ~= -1 and dialogueId or DialogueConst.NOTICE_HIT_AIR_WALL

		pg.game.communication:startNpcDialog(dialogueId)
	elseif tipType == UIConst.AIR_WALL_TIP_TYPE.A3Text then
		-- block empty
	else
		pg.game.home:tryShowAreaLockTip(self:getPosition())
	end
end

function ClientPawnEntity:checkEnableVoxelUpdate()
	return true
end

function ClientPawnEntity:modelLoaded()
	if not self.eModel then
		return false
	end

	local modelView = self.eModel.modelModelView

	return modelView.firstLoaded
end

function ClientPawnEntity:getTopLogoFollowStrategy()
	return ClientUtils.getEntityTopLogoFollowStrategy(self)
end

function ClientPawnEntity:getTopLogoHeight(strategy, entry)
	return ClientUtils.getEntityTopLogoHeight(self, strategy, entry)
end

return ClientPawnEntity
