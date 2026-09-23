-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Effect\\EffectSystem.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local SystemBase = require("GameApp.Core.SystemBase")
local Class = require("Core.Framework.Class")
local EffectData = require("Data.effect_data")
local EffectConst = require("Const.EffectConst")
local LuaCSharpArr = require("Utils.LuaCSharpArr")
local MessageName = require("Const.MessageName")
local logger = LoggerManager.getLogger("EffectSystem")
local lume = require("Core.Common.lume")
local TeamLinkController = require("GameApp.Effect.TeamLinkController")
local ToBool = ToBool
local ClientEffectUtils = require("Utils.ClientEffectUtils")
local EffectSystem = Class.LightClass("EffectSystem", SystemBase)

function EffectSystem:getMessageBindMap()
	return {
		[MessageName.TIMESCALE_CHANGE] = "onTimeScaleChange"
	}
end

function EffectSystem:onCtor()
	self.usingItems = {}
	self.footStepItems = {}
	self.memArr = LuaCSharpArr.New(EffectConst.EFFECT_SHARE_MEM_LEN)
	self.guid = 0
	self.electricLinkDict = {}
	self.timeScaleEffectId = nil
	self.entityPreloadEffectInfo = {}
	self.cacheTable = {}
	self.curBuffIdList = {}

	local cacheTableMeta = {
		__index = function(tbl, key)
			local ret
			local extraInfo = self.cacheTable.extraInfo
			local rawInfo = self.cacheTable.rawInfo

			if extraInfo[key] ~= nil then
				ret = extraInfo[key]
			elseif rawInfo[key] ~= nil then
				ret = rawInfo[key]
			else
				ret = EffectConst.DEFAULT_SHARE_MEM[key]
			end

			if type(ret) == "boolean" then
				return ret and 1 or 0
			else
				return ret
			end
		end
	}

	setmetatable(self.cacheTable, cacheTableMeta)
end

function EffectSystem:onDestroy()
	self.memArr:DestroyCSharpAccess()
end

function EffectSystem:onTimeScaleChange(timeScale)
	self:setTimeScale(0, timeScale)
end

function EffectSystem:setTimeScale(generatorId, timeScale)
	generatorId = generatorId or 0

	pg.global.effectMgr:SetTimeScale(generatorId, timeScale, 1)
end

function EffectSystem:preloadCustomEffects()
	for _, preloadEffId in ipairs(EffectConst.CUSTOM_PRELOAD_EFF_IDS) do
		local effectInfo = EffectData[preloadEffId]

		if effectInfo then
			for _, item in pairs(effectInfo) do
				pg.global.effectMgr:PreLoadEffect(item.resID)
			end
		end
	end
end

function EffectSystem:preloadEntityEffect(entityId, effectId)
	if string.isNilOrEmpty(effectId) or not entityId then
		return
	end

	local entityPreloadInfo = self.entityPreloadEffectInfo[entityId]

	if not entityPreloadInfo then
		entityPreloadInfo = {}
		self.entityPreloadEffectInfo[entityId] = entityPreloadInfo
	end

	local refCount = entityPreloadInfo[effectId] or 0

	refCount = refCount + 1
	entityPreloadInfo[effectId] = refCount

	if refCount == 1 then
		local effectInfo = EffectData[effectId]

		if effectInfo then
			for _, item in pairs(effectInfo) do
				pg.global.effectMgr:PreLoadEffect(item.resID)
			end
		else
			pg.global.effectMgr:PreLoadEffect(effectId)
		end
	end
end

function EffectSystem:unPreloadEntityEffect(entityId, effectId)
	if string.isNilOrEmpty(effectId) or not entityId then
		return
	end

	local entityPreloadInfo = self.entityPreloadEffectInfo[entityId]

	if not entityPreloadInfo then
		return
	end

	local refCount = entityPreloadInfo[effectId]

	if not refCount then
		return
	end

	refCount = refCount - 1

	if refCount <= 0 then
		entityPreloadInfo[effectId] = nil

		if next(entityPreloadInfo) == nil then
			self.entityPreloadEffectInfo[entityId] = nil
		end

		local effectInfo = EffectData[effectId]

		if effectInfo then
			for _, item in pairs(effectInfo) do
				pg.global.effectMgr:UnPreLoadEffect(item.resID)
			end
		else
			pg.global.effectMgr:UnPreLoadEffect(effectId)
		end
	else
		entityPreloadInfo[effectId] = refCount
	end
end

function EffectSystem:unPreloadAllEntityEffect(entityId)
	if not entityId then
		return
	end

	local entityPreloadInfo = self.entityPreloadEffectInfo[entityId]

	if not entityPreloadInfo then
		return
	end

	for effectId, refCount in pairs(entityPreloadInfo) do
		local effectInfo = EffectData[effectId]

		if effectInfo then
			for effectKey, item in pairs(effectInfo) do
				pg.global.effectMgr:UnPreLoadEffect(item.resID)
			end
		else
			pg.global.effectMgr:UnPreLoadEffect(effectId)
		end
	end

	self.entityPreloadEffectInfo[entityId] = nil
end

function EffectSystem:preloadEffects()
	for key, items in pairs(EffectData) do
		for effectKey, item in pairs(items) do
			if item.preload then
				pg.global.effectMgr:PreLoadEffect(item.resID)
			end
		end
	end
end

function EffectSystem:setShareMem(memArr, rawInfo, extraInfo)
	lume.clear(self.cacheTable)

	self.cacheTable.extraInfo = extraInfo
	self.cacheTable.rawInfo = rawInfo

	local mergeInfo = self.cacheTable

	mergeInfo.resID = mergeInfo.resID

	local vec = mergeInfo.position

	mergeInfo.positionX = vec and (vec.x or vec[1]) or 0
	mergeInfo.positionY = vec and (vec.y or vec[2]) or 0
	mergeInfo.positionZ = vec and (vec.z or vec[3]) or 0
	vec = mergeInfo.rotation
	mergeInfo.rotationX = vec and (vec.x or vec[1]) or 0
	mergeInfo.rotationY = vec and (vec.y or vec[2]) or 0
	mergeInfo.rotationZ = vec and (vec.z or vec[3]) or 0
	vec = mergeInfo.scale

	local extraScale = mergeInfo.extraScale or 1

	if type(vec) == "number" then
		mergeInfo.scaleX = vec * extraScale
		mergeInfo.scaleY = vec * extraScale
		mergeInfo.scaleZ = vec * extraScale
	else
		mergeInfo.scaleX = (vec and (vec.x or vec[1]) or 1) * extraScale
		mergeInfo.scaleY = (vec and (vec.y or vec[2]) or 1) * extraScale
		mergeInfo.scaleZ = (vec and (vec.z or vec[3]) or 1) * extraScale
	end

	vec = mergeInfo.linkEndOffset
	mergeInfo.linkEndOffsetX = vec and (vec.x or vec[1]) or 0
	mergeInfo.linkEndOffsetY = vec and (vec.y or vec[2]) or 0
	mergeInfo.linkEndOffsetZ = vec and (vec.z or vec[3]) or 0

	for k, v in pairs(EffectConst.EFFECT_NAME_TO_INDEX) do
		memArr[v] = mergeInfo[k]
	end
end

function EffectSystem:createEffectConfigInfo(rawInfo, extraInfo)
	local configInfo = pg.global.effectMgr:GetEffectConfig()

	self:setShareMem(self.memArr, rawInfo, extraInfo)
	configInfo:SetShareMem(self.memArr:GetCSharpAccess())

	if extraInfo.linkStartTrans then
		configInfo.linkStartTrans = extraInfo.linkStartTrans
	elseif extraInfo.linkStartTransActorId then
		configInfo.linkStartTrans = CSEntityManager:GetPositionAgentByActorId(extraInfo.linkStartTransActorId)
	end

	if extraInfo.linkStartPos then
		configInfo.linkStartPos = extraInfo.linkStartPos
		configInfo.useLinkStartPos = true
	end

	if extraInfo.linkEndTrans then
		configInfo.linkEndTrans = extraInfo.linkEndTrans
	end

	if extraInfo.linkEndBone then
		configInfo.linkEndBone = extraInfo.linkEndBone
	end

	if extraInfo.linkEndEntId then
		configInfo.linkEndEntId = extraInfo.linkEndEntId
	end

	if extraInfo.linkEndDir then
		configInfo.linkEndDir = extraInfo.linkEndDir
		configInfo.useLinkEndDir = true
	end

	if extraInfo.linkEndDist then
		configInfo.linkEndDist = extraInfo.linkEndDist
	end

	if extraInfo.linkRaycastTestLayers then
		configInfo.linkRaycastTestLayers = extraInfo.linkRaycastTestLayers
		configInfo.useLinkRaycastTest = true
	end

	if extraInfo.useLinkEndWorldPos then
		configInfo.useLinkEndWorldPos = true
		configInfo.useLinkRaycastTest = false
	end

	if extraInfo.linkEndEffectId then
		configInfo.syncLinkEndEffectId = extraInfo.linkEndEffectId
	end

	if extraInfo.targetTrans then
		configInfo.targetTrans = extraInfo.targetTrans

		if extraInfo.targetTransOffset then
			configInfo.targetTransOffset = extraInfo.targetTransOffset
		end
	elseif extraInfo.targetTransActorId then
		configInfo.targetTrans = CSEntityManager:GetPositionAgentByActorId(extraInfo.targetTransActorId)

		if extraInfo.targetTransOffset then
			configInfo.targetTransOffset = extraInfo.targetTransOffset
		end
	end

	if extraInfo.alwaysTowardsCameraCenter then
		configInfo.alwaysTowardsCameraCenter = extraInfo.alwaysTowardsCameraCenter
	end

	if rawInfo.changeColor and extraInfo.customHue then
		configInfo.useCustomColor = true
		configInfo.customHue = extraInfo.customHue
	end

	if extraInfo.loadCallback then
		configInfo.loadCallback = extraInfo.loadCallback
	end

	if extraInfo.customUpdateCallback then
		configInfo.customUpdateCallback = extraInfo.customUpdateCallback
	end

	if extraInfo.manualSetProgress then
		configInfo.manualSetProgress = true
	end

	if extraInfo.effectDestroyTags then
		configInfo.effectDestroyTags = extraInfo.effectDestroyTags
	end

	if extraInfo.useEffectDestroyTagsLayer then
		configInfo.useEffectDestroyTagsLayer = extraInfo.useEffectDestroyTagsLayer
	end

	if extraInfo.useEffectDestroyStateList then
		configInfo.useEffectDestroyStateList = extraInfo.useEffectDestroyStateList
	end

	if extraInfo.playEffectStateList then
		configInfo.playEffectStateList = extraInfo.playEffectStateList
	end

	if extraInfo.playableLayer then
		configInfo.playableLayer = extraInfo.playableLayer
	end

	if rawInfo.ignoreOwnerDestroy or extraInfo.ignoreOwnerDestroy then
		configInfo.ignoreOwnerDestroy = true
	end

	local alignChildName = extraInfo.alignChildName or rawInfo.alignChildName

	if not string.isNilOrEmpty(alignChildName) then
		configInfo.alignChildName = alignChildName
	end

	if extraInfo.endCallback then
		configInfo.endCallback = extraInfo.endCallback
	end

	if extraInfo.isBillboard then
		configInfo.isBillboard = extraInfo.isBillboard
	end

	if rawInfo.ignoreSelfCollision or extraInfo.ignoreSelfCollision then
		configInfo.ignoreSelfCollision = true
	end

	if rawInfo.disableCollider or extraInfo.disableCollider then
		configInfo.disableCollider = true
	end

	if rawInfo.isMergeSameEffect or extraInfo.isMergeSameEffect then
		configInfo.isMergeSameEffect = true
	end

	if rawInfo.maxInsCount or extraInfo.maxInsCount then
		configInfo.maxInsCount = rawInfo.maxInsCount or extraInfo.maxInsCount
	end

	if rawInfo.controllingPetIds then
		local controllingPetIds = {}

		for _, id in pairs(rawInfo.controllingPetIds) do
			table.insert(controllingPetIds, id)
		end

		configInfo.controllingPetIds = controllingPetIds
	end

	if rawInfo.buffId then
		configInfo.buffId = rawInfo.buffId
	end

	if rawInfo.presetName or extraInfo.presetName then
		configInfo.presetName = rawInfo.presetName or extraInfo.presetName
		configInfo.presetDuration = rawInfo.presetDuration or extraInfo.presetDuration
		configInfo.presetDisableWhenFinish = rawInfo.presetDisableWhenFinish or extraInfo.presetDisableWhenFinish
	end

	return configInfo
end

function EffectSystem:createGenerator(transform, owner, isSyncInstantiate)
	if isSyncInstantiate == nil then
		isSyncInstantiate = false
	end

	return pg.global.effectMgr:CreateGenerator(transform, owner, isSyncInstantiate)
end

function EffectSystem:destroyGenerator(generatorId)
	if generatorId == nil then
		return
	end

	pg.global.effectMgr:DestroyGenerator(generatorId)
end

function EffectSystem:setPlaySpeed(generatorId, effectKey, speed)
	pg.global.effectMgr:SetPlaySpeed(generatorId, effectKey, speed)
end

function EffectSystem:playEffect(generatorId, effectKey, extInfo, forceSync)
	if string.isNilOrEmpty(effectKey) then
		return 0
	end

	generatorId = generatorId or 0
	extInfo = extInfo or {}

	local ed = EffectData[effectKey] or {}

	if ed == nil then
		ed = {}

		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("effectKey not valid", effectKey)
		end
	end

	local effId = 0

	for _, rawInfo in ipairs(ed) do
		local effectConfigInfo = pg.game.effect:createEffectConfigInfo(rawInfo, extInfo)
		local id = pg.global.effectMgr:PlayEffect(generatorId, effectKey, effectConfigInfo, effId, forceSync or false)

		effId = id
	end

	return effId
end

function EffectSystem:playEffectOn(generatorId, effectKey, trans, extInfo, forceSync)
	extInfo = extInfo or {}
	extInfo.mountType = EffectConst.MountType.Custom
	extInfo.targetTrans = trans

	return self:playEffect(generatorId, effectKey, extInfo, forceSync)
end

function EffectSystem:playEffectAt(generatorId, effectKey, position, eulerAngles, srcEntity, extInfo, forceSync)
	extInfo = extInfo or {}
	extInfo.position = position
	extInfo.rotation = eulerAngles or Vector3.zero
	extInfo.mountType = EffectConst.MountType.World
	extInfo.followType = EffectConst.FollowType.Global
	extInfo.speed = extInfo.speed or 1
	extInfo.distance = extInfo.distance or 0

	if not ToBool(generatorId) then
		self:worldEffectApplyScale(effectKey, extInfo, srcEntity)
	end

	return self:playEffect(generatorId, effectKey, extInfo, forceSync)
end

function EffectSystem:worldEffectApplyScale(effectKey, extInfo, srcEntity)
	local ed = EffectData[effectKey] or {}

	if srcEntity and ed[1] and ed[1].useModelSize and srcEntity.getModelScale then
		local modelScale = srcEntity:getModelScale()

		extInfo.extraScale = modelScale
	end
end

function EffectSystem:getEntityGeneratorId(entityId)
	local entity = pg.getEntity(entityId)

	if entity and entity.eModel then
		return entity.eModel.effectGeneratorId or 0
	end

	return 0
end

function EffectSystem:playRawEffectAt(generatorId, resId, position, extraInfo)
	generatorId = generatorId or 0

	local rawInfo = {
		duration = 5,
		resID = resId,
		mountType = EffectConst.MountType.World,
		followType = EffectConst.FollowType.Global
	}

	extraInfo = extraInfo or {}
	extraInfo.position = position
	extraInfo.distance = 0
	extraInfo.layer = 1

	local effectConfigInfo = self:createEffectConfigInfo(rawInfo, extraInfo)

	return pg.global.effectMgr:PlayEffect(generatorId, resId, effectConfigInfo)
end

function EffectSystem:playRawEffectOn(generatorId, resId, trans, extraInfo)
	generatorId = generatorId or 0

	local rawInfo = {
		duration = 5,
		resID = resId,
		mountType = EffectConst.MountType.Custom
	}

	extraInfo = extraInfo or {}
	extraInfo.targetTrans = trans
	extraInfo.distance = 0
	extraInfo.layer = 1

	local effectConfigInfo = self:createEffectConfigInfo(rawInfo, extraInfo)

	return pg.global.effectMgr:PlayEffect(generatorId, resId, effectConfigInfo)
end

function EffectSystem:playRawEffect(generatorId, resId, extraInfo)
	generatorId = generatorId or 0

	local rawInfo = {
		resID = resId
	}
	local effectConfigInfo = self:createEffectConfigInfo(rawInfo, extraInfo)

	return pg.global.effectMgr:PlayEffect(generatorId, resId, effectConfigInfo)
end

function EffectSystem:stopEffect(generatorId, effectId, reclaim, drop)
	reclaim = reclaim or false
	generatorId = generatorId or 0

	if drop then
		pg.global.effectMgr:DropEffectById(generatorId, effectId)
	end

	pg.global.effectMgr:StopEffectById(generatorId, effectId, reclaim)
end

function EffectSystem:setEffectVisible(generatorId, effectId, visible)
	pg.global.effectMgr:SetEffectVisibleById(generatorId, effectId, visible)
end

function EffectSystem:setCurrentBuffIdList(buffDataList)
	table.clear(self.curBuffIdList)

	for _, buffData in pairs(buffDataList) do
		if buffData.templateId then
			table.insert(self.curBuffIdList, buffData.templateId)
		end
	end

	pg.global.effectMgr:SetHavingBuffId(self.curBuffIdList)
end

function EffectSystem:getTeamLinkController()
	if self.teamLinkController then
		return self.teamLinkController
	end

	self.teamLinkController = TeamLinkController()

	return self.teamLinkController
end

function EffectSystem:onPlayerDestroy(player)
	SystemBase.onPlayerDestroy(self, player)

	self.teamLinkController = nil
end

return EffectSystem
