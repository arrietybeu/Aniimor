-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientPlayerGhost.lua

local class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local ClientPawnEntity = require("Entities.ClientPawnEntity")
local ClientConst = require("Const.ClientConst")
local AvatarData = require("Data.avatar_data")
local ClientModelUtils = require("Utils.ClientModelUtils")
local CustomTypeFactory = require("Core.PropertySync.CustomTypeFactory")
local EntityManager = require("Core.Common.EntityManager")
local Utils = require("Common.Utils.Utils")
local ClientTopLogoComponent = require("Entities.SpaceEntities.CommonComponent.ClientTopLogoComponent")
local ClientPlayerInteractComponent = require("Entities.SpaceEntities.PlayerComponent.ClientPlayerInteractComponent")
local SysConfigData = require("Data.sys_config_data")
local PlayableConst = require("Const.PlayableConst")
local LuaTimeline = require("GameApp.Timeline.LuaTimeline")
local ClientPlayerGhost = class.Class("ClientPlayerGhost", ClientPawnEntity)

ClientPlayerGhost.PLAYER_GHOST_PM_PRESET = "Digital_Boss_Blue"
ClientPlayerGhost.MAPPING_GHOST_DISSOLVE_DURATION = 0.6
ClientPlayerGhost.MAPPING_GHOST_DEFAULT_APPEAR_DURATION = 0.8
ClientPlayerGhost.MAPPING_GHOST_LINK_DURATION = 1
ClientPlayerGhost.MAPPING_GHOST_LINK_DISSOLVE_OFFSET = 0.2
ClientPlayerGhost.MAPPING_GHOST_SWITCH_TO_PET_EFFECT = "Eff_Switch_Hit"
ClientPlayerGhost.MAPPING_GHOST_SWITCH_TO_PLAYER_EFFECT = "Eff_Switch_Hit_Normal"

class.AddComponents(ClientPlayerGhost, {
	ClientTopLogoComponent,
	ClientPlayerInteractComponent
})

function ClientPlayerGhost:init(dict)
	local result = ClientPlayerGhost.super.init(self, dict)

	self.playerGhostFlashElapsed = 0
	self.isPlayerGhostSpecialMat = false
	self.uid = Utils.getSourceUidByPlayerGhostUid(self.playerUid)
	self.clenUsrType = Const.CLEN_USR_TYPE_PLAYER_GHOST
	self.forbiddenTopLogo = false
	self.topLogoType = ClientConst.TopLogoType.Player

	EntityManager.addUidEntity(self.playerUid, self)

	local appearanceData = dict and dict.appearanceData

	if appearanceData then
		local curShow = appearanceData.curShow

		if curShow and curShow.getRawTable then
			curShow = curShow:getRawTable()
		end

		local properties = rawget(self, "__Properties__")
		local curShowObject

		if not properties or properties.curShow == nil then
			curShowObject = CustomTypeFactory.createReadonly("AppearanceCustomOne", "curShow", curShow or {}, self, nil, true)
		end

		if properties then
			properties.templateId = appearanceData.templateId or properties.templateId
			properties.body = appearanceData.body or properties.body
			properties.avatarConfig = appearanceData.avatarConfig or ""
			properties.avatarPresetKey = appearanceData.avatarPresetKey or 0

			if properties.curShow == nil and curShowObject then
				properties.curShow = curShowObject
			end
		else
			rawset(self, "templateId", appearanceData.templateId)
			rawset(self, "body", appearanceData.body)
			rawset(self, "avatarConfig", appearanceData.avatarConfig or "")
			rawset(self, "avatarPresetKey", appearanceData.avatarPresetKey or 0)
			rawset(self, "curShow", curShowObject)
		end
	end

	return result
end

function ClientPlayerGhost:destroy()
	EntityManager.removeUidEntity(self.playerUid)
	ClientPlayerGhost.super.destroy(self)
end

function ClientPlayerGhost:ctor(entityId)
	ClientPlayerGhost.super.ctor(self, entityId)

	self.actorType = Const.ACTOR_TYPE_PLAYER_GHOST
	self.isClientEnt = false
end

function ClientPlayerGhost:initializeComponents()
	ClientPlayerGhost.super.initializeComponents(self)

	if self.eModel then
		self:addEModelComponent(Const.COMPONENT_INDEX_IK)
	end
end

function ClientPlayerGhost:postInitializeComponents()
	ClientPlayerGhost.super.postInitializeComponents(self)
	self:refreshMappingPetGhostVisible()
end

function ClientPlayerGhost:refreshMappingPetGhostVisible()
	local showPlayerGhost = self.mappingPetGhostVisible ~= true

	self:setActive(ClientConst.MODEL_VISIBLE_KEY.MAPPING_GHOST, showPlayerGhost)
end

function ClientPlayerGhost:getMappingGhostAppearDuration()
	return SysConfigData.switchAppearTime or ClientPlayerGhost.MAPPING_GHOST_DEFAULT_APPEAR_DURATION
end

function ClientPlayerGhost:playMappingSwitchEffect(entity, effectId)
	if entity and not entity.isDestroyed then
		entity:playEffect(effectId, {
			position = Vector3(0, entity:getHeight() * 0.5, 0)
		})
	end
end

function ClientPlayerGhost:playMappingPetGhostSwitchEffect(petGhost, effectId)
	if not petGhost or petGhost.isDestroyed then
		return
	end

	petGhost:refreshMappingGhostVisible(true)
	petGhost:playSwitchAppearEffect(self:getMappingGhostAppearDuration())
	self:playMappingSwitchEffect(petGhost, effectId)
end

function ClientPlayerGhost:getMappingPetGhost(sourcePetId)
	local petGhost = self.mappingPetGhost

	if petGhost and not petGhost.isDestroyed and (not sourcePetId or sourcePetId == "" or petGhost.id == Utils.getPetGhostId(sourcePetId, pg.me.space.id)) then
		return petGhost
	end
end

function ClientPlayerGhost:applyMappingPetGhostVisible(petGhost, showPetGhost)
	if petGhost and not petGhost.isDestroyed then
		petGhost:refreshMappingGhostVisible(showPetGhost)
	elseif not showPetGhost then
		self.mappingPetGhostVisible = false

		self:refreshMappingPetGhostVisible()
	end
end

function ClientPlayerGhost:stopMappingPetSwitchTimeline()
	local timeline = self.mappingPetSwitchTimeline

	if timeline then
		self.mappingPetSwitchTimeline = nil

		timeline:stop()
	end
end

function ClientPlayerGhost:playMappingPlayerToPetEffect(petGhost)
	self:stopMappingPetSwitchTimeline()

	if not petGhost or petGhost.isDestroyed then
		return
	end

	if self:getConfigData().disableAppearDissolve or not self.eModel then
		petGhost:forceSetPosRot(self:getPosition(), self:getRotation(), false, true)
		self:playMappingPetGhostSwitchEffect(petGhost, ClientPlayerGhost.MAPPING_GHOST_SWITCH_TO_PLAYER_EFFECT)

		return
	end

	local timeline = LuaTimeline.new()

	self.mappingPetSwitchTimeline = timeline

	timeline:setDuration(ClientPlayerGhost.MAPPING_GHOST_LINK_DURATION)
	timeline:createAndAddTrigger(0, function()
		if not self.isDestroyed and self.eModel then
			self:playAnimation(PlayableConst.Link)

			self.eModel.enableFollow = false
		end
	end)
	timeline:createAndAddTrigger(ClientPlayerGhost.MAPPING_GHOST_LINK_DURATION - ClientPlayerGhost.MAPPING_GHOST_DISSOLVE_DURATION, function()
		if not self.isDestroyed and self.eModel then
			self:playSwitchDissolveEffect(ClientPlayerGhost.MAPPING_GHOST_DISSOLVE_DURATION, nil, ClientPlayerGhost.MAPPING_GHOST_LINK_DISSOLVE_OFFSET)
		end
	end)
	timeline:createAndAddTrigger(ClientPlayerGhost.MAPPING_GHOST_LINK_DURATION, function()
		if not self.isDestroyed and not petGhost.isDestroyed then
			petGhost:forceSetPosRot(self:getPosition(), self:getRotation(), false, true)
			self:playMappingPetGhostSwitchEffect(petGhost, ClientPlayerGhost.MAPPING_GHOST_SWITCH_TO_PLAYER_EFFECT)
		end

		if not self.isDestroyed and self.eModel then
			self.eModel.enableFollow = true
		end
	end)
	timeline:setStopCallback(function()
		if not self.isDestroyed and self.eModel then
			self:stopAnimation(PlayableConst.Link)

			self.eModel.enableFollow = true
		end

		if self.mappingPetSwitchTimeline == timeline then
			self.mappingPetSwitchTimeline = nil
		end
	end)
	timeline:start()
end

function ClientPlayerGhost:playMappingPetToPlayerEffect(petGhost)
	self:stopMappingPetSwitchTimeline()
	self:applyMappingPetGhostVisible(petGhost, false)
	self:playSwitchAppearEffect(self:getMappingGhostAppearDuration())
	self:playMappingSwitchEffect(self, ClientPlayerGhost.MAPPING_GHOST_SWITCH_TO_PLAYER_EFFECT)
end

function ClientPlayerGhost:RPC_SC_OnControlToFollow(inputEvent, params, oldPetTemplateId, oldPetId, newPetId)
	local petGhost = self:getMappingPetGhost(oldPetId)

	if inputEvent == Const.EVENT_LEAVE_PET then
		self:playMappingPetToPlayerEffect(petGhost)
	else
		self:stopMappingPetSwitchTimeline()
		self:applyMappingPetGhostVisible(petGhost, false)
	end
end

function ClientPlayerGhost:RPC_SC_OnSwithToSingle(inputEvent, params, oldPetId)
	self:playMappingPetToPlayerEffect(self:getMappingPetGhost(oldPetId))
end

function ClientPlayerGhost:RPC_SC_OnSwitchToControll(inputEvent, params, oldPetId, newPetId)
	local petGhost = self:getMappingPetGhost(newPetId)

	if inputEvent == Const.EVENT_ENTER_PET then
		self:playMappingPlayerToPetEffect(petGhost)
	else
		self:stopMappingPetSwitchTimeline()
		self:applyMappingPetGhostVisible(petGhost, true)
	end
end

function ClientPlayerGhost:RPC_SC_OnControlToControl(inputEvent, params, oldPetTemplateId, newPetTemplateId, oldPetId, newPetId)
	self:stopMappingPetSwitchTimeline()
	self:playMappingPetGhostSwitchEffect(self:getMappingPetGhost(newPetId) or self.mappingPetGhost, ClientPlayerGhost.MAPPING_GHOST_SWITCH_TO_PET_EFFECT)
end

function ClientPlayerGhost:RPC_SC_OnSingleToFollow(inputEvent, params, newPetId)
	self:stopMappingPetSwitchTimeline()

	local petGhost = self:getMappingPetGhost(newPetId)

	if petGhost and params.showPosition then
		petGhost:forceSetPosRot(Vector3.Convert(params.showPosition), self:getRotation(), false, true)
	end

	self:applyMappingPetGhostVisible(petGhost, false)
end

function ClientPlayerGhost:getTemplateData()
	return AvatarData[self.templateId] or {}
end

function ClientPlayerGhost:getGender()
	local avatarData = AvatarData[self.templateId]

	return avatarData and avatarData.gender
end

function ClientPlayerGhost:refreshModel(configData, extraData)
	local modelView = self.eModel.modelModelView
	local presetKey = pg.game.avatar:getPresetKey(self)

	if presetKey and presetKey ~= 0 then
		ClientModelUtils.initModelInfoByCustomData(self, presetKey, configData, extraData)
		ClientModelUtils.refreshModels(self, modelView)
	else
		ClientPlayerGhost.super.refreshModel(self, configData, extraData)
	end

	local bodySize = modelView.modelInfo:GetBodySize()

	self:setModelScale(ClientConst.MODEL_SCALE_KEY.AVATAR, bodySize)
end

function ClientPlayerGhost:onModelRefreshed()
	ClientPlayerGhost.super.onModelRefreshed(self)
	self:refreshPlayerGhostPm()
end

function ClientPlayerGhost:refreshPlayerGhostPm()
	if self.eModel and self.eModel.shaderView then
		if self.isPlayerGhostSpecialMat then
			ClientEffectUtils.PlayPreset(self, ClientPlayerGhost.PLAYER_GHOST_PM_PRESET, 0, false)
		else
			ClientEffectUtils.StopPreset(self, ClientPlayerGhost.PLAYER_GHOST_PM_PRESET)
		end
	end
end

function ClientPlayerGhost:tick(deltaTime)
	ClientPlayerGhost.super.tick(self, deltaTime)

	local interval = SysConfigData.PLAYER_GHOST_FLASH_INTERVAL
	local normalDuration = interval[1]
	local specialDuration = interval[2]

	self.playerGhostFlashElapsed = self.playerGhostFlashElapsed and self.playerGhostFlashElapsed + deltaTime or 0

	local isSpecialMat = normalDuration <= self.playerGhostFlashElapsed % (normalDuration + specialDuration)

	if self.isPlayerGhostSpecialMat ~= isSpecialMat then
		self.isPlayerGhostSpecialMat = isSpecialMat

		self:refreshPlayerGhostPm()
	end
end

function ClientPlayerGhost:setModelLayer()
	if self.eModel then
		self.eModel:SetModelLayer(ClientConst.LayerDefine.LAYER_PLAYER)
	end
end

function ClientPlayerGhost:getCsEntityType()
	return ClientConst.ENTITY_CS_TYPE.PLAYER
end

function ClientPlayerGhost:repr()
	return string.format("ClientPlayerGhost(entityId=%s, playerUid=%s, playerId=%s)", self.id, self.playerUid, self.playerId)
end

return ClientPlayerGhost
