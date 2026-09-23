-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientLeylineFlower.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local class = require("Core.Framework.Class")
local ClientModelEntity = require("Entities.ClientModelEntity")
local PuppetData = require("Data.puppet_data")
local LeylineTreePuppetData = require("Data.leylinetree_puppet_data")
local LeylineFLowerEffectStageData = require("Data.leyline_flower_effect_stage_data")
local PlentyHappenEffectData = require("Data.plenty_happen_effect_data")
local ClientModelUtils = require("Utils.ClientModelUtils")
local ClientEffectUtils = require("Utils.ClientEffectUtils")
local ClientConst = require("Const.ClientConst")
local LeylineFlowerConst = require("Const.LeylineFlowerConst")
local MessageName = require("Const.MessageName")
local AreaRainbowPetLevelData = require("Data.area_rainbowPet_level_data")
local logger = require("Core.Log.LoggerManager").getLogger("ClientLeylineFlower")
local ClientLeylineFlower = class.Class("ClientLeylineFlower", ClientModelEntity)
local ClientAoiComponent = require("Entities.SpaceEntities.CommonComponent.ClientAoiComponent")
local ClientModelComponent = require("Entities.SpaceEntities.CommonComponent.ClientModelComponent")
local ClientAuthorityComponent = require("Entities.SpaceEntities.CommonComponent.ClientAuthorityComponent")
local ClientAnimationComponent = require("Entities.SpaceEntities.CommonComponent.ClientAnimationComponent")
local ClientNpcInteractComponent = require("Entities.SpaceEntities.CommonComponent.ClientNpcInteractComponent")
local ClientEffectComponent = require("Entities.SpaceEntities.PlayerComponent.ClientEffectComponent")
local ClientPhysicsComponent = require("Entities.SpaceEntities.CommonComponent.ClientPhysicsComponent")
local ClientSpecialStateRecoverComponent = require("Entities.SpaceEntities.CommonComponent.ClientSpecialStateRecoverComponent")
local ClientAudioComponent = require("Entities.SpaceEntities.CommonComponent.ClientAudioComponent")
local Components = {
	ClientAoiComponent,
	ClientModelComponent,
	ClientAudioComponent,
	ClientAuthorityComponent,
	ClientNpcInteractComponent,
	ClientSpecialStateRecoverComponent,
	ClientEffectComponent,
	ClientPhysicsComponent,
	ClientAnimationComponent
}

class.AddComponents(ClientLeylineFlower, Components)

local RAINBOW_STAGE_MATERIAL_EFFECT_KEYS = {
	"LeaderFlower_RainbowStage1",
	"LeaderFlower_RainbowStage2",
	"LeaderFlower_RainbowStage3",
	"LeaderFlower_RainbowStage4",
	"LeaderFlower_RainbowStage5"
}
local DEFAULT_BONE_EFFECT_GROWING_RATIO = 1
local BONE_EFFECT_BASE_SCALE = 0.5

local function _toVec3(raw, defaultX, defaultY, defaultZ)
	raw = raw or EMPTY_TABLE

	return Vector3(raw[1] or defaultX, raw[2] or defaultY, raw[3] or defaultZ)
end

local function _toRotation(raw)
	return Quaternion.Euler(raw[1] or 0, raw[2] or 0, raw[3] or 0)
end

local function _getStageEffectList(stage)
	local stageData = LeylineFLowerEffectStageData.data or LeylineFLowerEffectStageData

	return stageData and stageData[stage] or nil
end

local function _getPlentyPillarEffectData(bloomQuality)
	bloomQuality = tonumber(bloomQuality) or 1

	if bloomQuality <= 0 then
		bloomQuality = 1
	end

	return PlentyHappenEffectData[bloomQuality]
end

local function _getPlentyPillarEffectKey(bloomQuality)
	local effectData = _getPlentyPillarEffectData(bloomQuality)

	return effectData and effectData.resId2 or nil
end

local function _getCurrentFlowerInfo(entity)
	if not pg.me or not pg.me.getCurFlowerInfo then
		return nil
	end

	return pg.me:getCurFlowerInfo(entity.staticId)
end

local function _calcBloomRatio(entity, bloomCatchCount)
	if not bloomCatchCount then
		return nil
	end

	local plentyTableId = entity.plentyTableId or 1

	if plentyTableId <= 0 then
		plentyTableId = 1
	end

	local leylineTreePuppetData = LeylineTreePuppetData[plentyTableId]

	if not leylineTreePuppetData then
		return nil
	end

	local maxRefresh = leylineTreePuppetData.maxRefresh or 60

	if maxRefresh <= 0 then
		return nil
	end

	return math.clamp(bloomCatchCount / maxRefresh, 0, 1)
end

local function _refreshGrowingRatioScales(entity, bloomCatchCount)
	local ratio = _calcBloomRatio(entity, bloomCatchCount)

	if ratio == nil then
		return
	end

	local function applyScale(effId, trans, growingRatio)
		if not ToBool(effId) or not growingRatio or growingRatio <= 0 then
			return
		end

		trans = trans or EMPTY_TABLE

		local baseScale = _toVec3(trans.scale, 1, 1, 1)
		local growScale = BONE_EFFECT_BASE_SCALE * (1 + ratio * growingRatio)

		entity:setEffectScale(effId, Vector3(baseScale.x * growScale, baseScale.y * growScale, baseScale.z * growScale))
	end

	local function getGrowingRatio(effectKey, configuredRatio)
		if not entity:isEffectBoundToBone(effectKey) then
			return configuredRatio or -1
		end

		return configuredRatio and configuredRatio > 0 and configuredRatio or DEFAULT_BONE_EFFECT_GROWING_RATIO
	end

	local stageEffectList = _getStageEffectList(entity.flowerState) or EMPTY_TABLE

	for _, effectCfg in ipairs(stageEffectList) do
		local index = effectCfg.index
		local effectInfo = index and entity.flowerStageEffectMap[index] or nil
		local effId = effectInfo and effectInfo.effId or nil
		local growingRatio = getGrowingRatio(effectInfo and effectInfo.resId, effectCfg.growingRatio)

		applyScale(effId, effectCfg.trans, growingRatio)
	end

	local openIdleData = entity.openIdleRainbowStage and AreaRainbowPetLevelData[entity.openIdleRainbowStage] or nil

	applyScale(entity.openIdleEffectId, openIdleData and openIdleData.trans, getGrowingRatio(entity.openIdleEffectKey))

	local plentyData = _getPlentyPillarEffectData(entity.plentyPillarBloomQuality)

	applyScale(entity.plentyPillarEffectId, plentyData and plentyData.trans, getGrowingRatio(entity.plentyPillarEffectKey))
end

function ClientLeylineFlower:ctor(entityId)
	ClientLeylineFlower.super.ctor(self, entityId)

	self.inited = false
	self.flowerStageEffectMap = {}
	self.plentyPillarEffectId = nil
	self.plentyPillarEffectKey = nil
	self.plentyPillarBloomQuality = nil
	self.openIdleEffectId = nil
	self.openIdleEffectKey = nil
	self.openIdleRainbowStage = nil
end

function ClientLeylineFlower:init(bdict)
	ClientLeylineFlower.super.init(self, bdict)

	self.templateId = bdict.templateId
	self.entityCanMove = false

	return true
end

function ClientLeylineFlower:onEnterSpace()
	pg.space:addLeylineFlowerMap(self.id, self.templateId)
	self:refreshFlowerStageEffects(nil, self.flowerState)

	local flowerInfo = _getCurrentFlowerInfo(self)

	self:refreshPlentyPillarEffect(self.flowerState, flowerInfo and flowerInfo.bloomQuality)
	self:refreshOpenIdleEffect(self.flowerState, flowerInfo and flowerInfo.rainbowStage)
	self:notifyRainbowStageAppearance()
	self:refreshLoopAudio(self.flowerState)
end

function ClientLeylineFlower:refreshAppearance()
	ClientLeylineFlower.super.refreshAppearance(self)
end

function ClientLeylineFlower:refreshModel(configData, extraData)
	local modelView = self.eModel.modelModelView

	ClientModelUtils.applyModelAppearance(modelView.modelInfo, configData, extraData)
	modelView:RefreshModels()
end

function ClientLeylineFlower:onModelRefreshed()
	ClientLeylineFlower.super.onModelRefreshed(self)
	self:notifyRainbowStageAppearance()
end

function ClientLeylineFlower:notifyRainbowStageAppearance()
	if not pg.me or not pg.me.getCurFlowerInfo then
		return
	end

	local flowerInfo = pg.me:getCurFlowerInfo(self.staticId)

	if not flowerInfo or not flowerInfo.rainbowStage then
		return
	end

	facade:SendMessageCommand(MessageName.LEYLINEFLOWER_RAINBOW_STAGE_CHANGED, {
		leylineFlowerId = self.staticId,
		rainbowStage = flowerInfo.rainbowStage
	})
end

function ClientLeylineFlower:clearRainbowStageMaterialEffects()
	for _, tblInfo in ipairs(AreaRainbowPetLevelData) do
		if tblInfo.materialEffect then
			ClientEffectUtils.StopMaterialEffect(self, tblInfo.materialEffect)
		end
	end
end

function ClientLeylineFlower:refreshRainbowStageAppearance(rainbowStage)
	local levelData = AreaRainbowPetLevelData[rainbowStage]
	local materialEffectKey = levelData and levelData.materialEffect or nil

	if not materialEffectKey then
		logger:error("refreshRainbowStageAppearance invalid rainbowStage", self.staticId, rainbowStage)

		return
	end

	local scale = levelData.flowerScale or 1

	self:setModelScale(ClientConst.MODEL_SCALE_KEY.DEFAULT, scale)
	self:clearRainbowStageMaterialEffects()
	ClientEffectUtils.ApplyMaterialEffect(self, materialEffectKey)
	self:refreshOpenIdleEffect(self.flowerState, rainbowStage)
end

function ClientLeylineFlower:stopOpenIdleEffect()
	if ToBool(self.openIdleEffectId) then
		self:stopEffectById(self.openIdleEffectId)
	end

	self.openIdleEffectId = nil
	self.openIdleEffectKey = nil
	self.openIdleRainbowStage = nil
end

function ClientLeylineFlower:refreshOpenIdleEffect(flowerState, rainbowStage)
	local levelData = rainbowStage and AreaRainbowPetLevelData[rainbowStage] or nil
	local effectKey

	if flowerState == LeylineFlowerConst.FLOWER_STATE.Blooming and levelData then
		effectKey = levelData.resId
	end

	local trans = levelData and levelData.trans or {}

	if effectKey == self.openIdleEffectKey and ToBool(self.openIdleEffectId) then
		self:setEffectPosRot(self.openIdleEffectId, _toVec3(trans.pos, 0, 0, 0), _toRotation(trans.rot))
		self:setEffectScale(self.openIdleEffectId, _toVec3(trans.scale, 1, 1, 1))

		self.openIdleRainbowStage = rainbowStage

		_refreshGrowingRatioScales(self, self.bloomCatchCount)

		return
	end

	self:stopOpenIdleEffect()

	if flowerState ~= LeylineFlowerConst.FLOWER_STATE.Blooming then
		return
	end

	if not levelData or not effectKey then
		logger:error("refreshOpenIdleEffect invalid config", self.staticId, flowerState, rainbowStage)

		return
	end

	local extraInfo = {}

	if trans.pos then
		extraInfo.position = trans.pos
	end

	if trans.rot then
		extraInfo.rotation = trans.rot
	end

	if trans.scale then
		extraInfo.scale = trans.scale
	end

	local effectId = self:playEffect(effectKey, extraInfo)

	logger:info("refreshOpenIdleEffect play", effectKey, "effId=", effectId, "flowerState=", flowerState, "rainbowStage=", rainbowStage)

	if not ToBool(effectId) then
		logger:error("refreshOpenIdleEffect failed", self.staticId, flowerState, rainbowStage, effectKey)

		return
	end

	self.openIdleEffectId = effectId
	self.openIdleEffectKey = effectKey
	self.openIdleRainbowStage = rainbowStage

	_refreshGrowingRatioScales(self, self.bloomCatchCount)
end

function ClientLeylineFlower:stopPlentyPillarEffect()
	if ToBool(self.plentyPillarEffectId) then
		self:stopEffectById(self.plentyPillarEffectId)
	end

	self.plentyPillarEffectId = nil
	self.plentyPillarEffectKey = nil
	self.plentyPillarBloomQuality = nil
end

function ClientLeylineFlower:refreshPlentyPillarEffect(flowerState, bloomQuality)
	local effectKey

	if flowerState == LeylineFlowerConst.FLOWER_STATE.Budding then
		effectKey = _getPlentyPillarEffectKey(bloomQuality)
	end

	if effectKey == self.plentyPillarEffectKey and ToBool(self.plentyPillarEffectId) then
		self.plentyPillarBloomQuality = bloomQuality

		_refreshGrowingRatioScales(self, self.bloomCatchCount)

		return
	end

	self:stopPlentyPillarEffect()

	if not effectKey then
		return
	end

	local effectId = self:playEffect(effectKey)

	logger:info("refreshPlentyPillarEffect play", effectKey, "effId=", effectId, "canPlay=", self:canPlayEffect())

	if not ToBool(effectId) then
		logger:error("refreshPlentyPillarEffect failed", self.staticId, flowerState, bloomQuality, effectKey)

		return
	end

	self.plentyPillarEffectId = effectId
	self.plentyPillarEffectKey = effectKey
	self.plentyPillarBloomQuality = bloomQuality

	_refreshGrowingRatioScales(self, self.bloomCatchCount)
end

function ClientLeylineFlower:refreshPlentyPillarEffectByCurrentInfo(flowerState)
	local flowerInfo = _getCurrentFlowerInfo(self)

	self:refreshPlentyPillarEffect(flowerState or self.flowerState, flowerInfo and flowerInfo.bloomQuality)
end

function ClientLeylineFlower:destroy()
	ClientLeylineFlower.super.destroy(self)
	pg.space:removeLeylineFlowerMap(self.templateId)
end

function ClientLeylineFlower:preDestroy()
	self:stopOpenIdleEffect()
	self:stopPlentyPillarEffect()
	self:stopAllLoopAudio()

	for _, effectInfo in pairs(self.flowerStageEffectMap or EMPTY_TABLE) do
		if effectInfo.effId then
			self:stopEffectById(effectInfo.effId)
		end
	end

	self.flowerStageEffectMap = {}

	self:clearRainbowStageMaterialEffects()
	ClientLeylineFlower.super.preDestroy(self)
end

function ClientLeylineFlower:getConfigData()
	return PuppetData[self.templateId] or {}
end

function ClientLeylineFlower:on_flowerState_changed(oldv, newv)
	logger:info("on_flowerState_changed", oldv, newv)
	self:refreshFlowerStageEffects(oldv, newv)
	self:refreshPlentyPillarEffectByCurrentInfo(newv)

	local flowerInfo = _getCurrentFlowerInfo(self)

	self:refreshOpenIdleEffect(newv, flowerInfo and flowerInfo.rainbowStage)

	if newv == LeylineFlowerConst.FLOWER_STATE.Fruiting then
		pg.me:doEventByData({
			"startAIRemind",
			{
				117
			}
		})
	end

	self:handleFlowerStateAudioEvent(oldv, newv)

	if pg.me.isUsingSpaceOwnerMap and pg.me:isUsingSpaceOwnerMap() then
		if self.specialStateUpdate then
			self:specialStateUpdate()
		end

		facade:SendMessageCommand(MessageName.LEYLINEFLOWER_FLOWER_STATE_CHANGED, {
			oldValue = oldv,
			newValue = newv,
			leylineFlowerId = self.staticId
		})
	end
end

function ClientLeylineFlower:stopAllLoopAudio()
	local audioEvent = LeylineFlowerConst.FLOWER_AUDIO_EVENT

	self:stopSoundEvent(audioEvent.BudLoop)
	self:stopSoundEvent(audioEvent.BloomLoop)
	self:stopSoundEvent(audioEvent.EnergyBallLoop)
	self:stopSoundEvent(audioEvent.GrowLoop)
end

function ClientLeylineFlower:refreshLoopAudio(flowerState)
	local audioEvent = LeylineFlowerConst.FLOWER_AUDIO_EVENT

	if flowerState == LeylineFlowerConst.FLOWER_STATE.Growing then
		self:playSoundEvent(audioEvent.GrowLoop)
	elseif flowerState == LeylineFlowerConst.FLOWER_STATE.Budding then
		self:playSoundEvent(audioEvent.BudLoop)
	elseif flowerState == LeylineFlowerConst.FLOWER_STATE.Blooming then
		self:playSoundEvent(audioEvent.BloomLoop)
		self:playSoundEvent(audioEvent.EnergyBallLoop)
	elseif flowerState == LeylineFlowerConst.FLOWER_STATE.Fruiting then
		self:playSoundEvent(audioEvent.BloomLoop)
	end
end

function ClientLeylineFlower:handleFlowerStateAudioEvent(oldv, newv)
	local audioEvent = LeylineFlowerConst.FLOWER_AUDIO_EVENT

	self:stopAllLoopAudio()
	self:refreshLoopAudio(newv)

	if newv == LeylineFlowerConst.FLOWER_STATE.Growing then
		self:playSoundEvent(audioEvent.Grow)
	elseif newv == LeylineFlowerConst.FLOWER_STATE.Budding then
		-- block empty
	elseif newv == LeylineFlowerConst.FLOWER_STATE.Blooming then
		self:playSoundEvent(audioEvent.Bloom)
	elseif newv == LeylineFlowerConst.FLOWER_STATE.Withering then
		self:playSoundEvent(audioEvent.FlowersFade)
	end
end

function ClientLeylineFlower:on_bloomCatchCount_changed(oldv, newv)
	_refreshGrowingRatioScales(self, newv)
end

function ClientLeylineFlower:refreshFlowerStageEffects(oldStage, newStage)
	local newEffectList = _getStageEffectList(newStage) or {}
	local newIndexMap = {}

	for _, effectCfg in ipairs(newEffectList) do
		if effectCfg.index then
			newIndexMap[effectCfg.index] = effectCfg
		end
	end

	for index, effectInfo in pairs(self.flowerStageEffectMap) do
		if not newIndexMap[index] and effectInfo.effId then
			self:stopEffectById(effectInfo.effId)

			self.flowerStageEffectMap[index] = nil
		end
	end

	for _, effectCfg in ipairs(newEffectList) do
		local index = effectCfg.index
		local resId = effectCfg.resId

		if index and resId then
			local cached = self.flowerStageEffectMap[index]
			local effId = cached and cached.effId or nil

			if cached and cached.resId ~= resId and effId then
				self:stopEffectById(effId)

				cached = nil
				effId = nil
			end

			if not ToBool(effId) then
				effId = self:playEffect(resId)

				logger:info("refreshFlowerStageEffects play", resId, "effId=", effId, "canPlay=", self:canPlayEffect())
			end

			if ToBool(effId) then
				local trans = effectCfg.trans or {}

				self:setEffectPosRot(effId, _toVec3(trans.pos, 0, 0, 0), _toRotation(trans.rot))
				self:setEffectScale(effId, _toVec3(trans.scale, 1, 1, 1))

				self.flowerStageEffectMap[index] = {
					effId = effId,
					resId = resId
				}
			end
		end
	end

	_refreshGrowingRatioScales(self, self.bloomCatchCount)
end

return ClientLeylineFlower
