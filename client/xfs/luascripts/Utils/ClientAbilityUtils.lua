-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\ClientAbilityUtils.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("ClientAbilityUtils")
local Class = require("Core.Framework.Class")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local PlayableConst = require("Common.Const.PlayableConst")
local BuffConfigData = require("Data.buff_config_data")
local AbilityConst = require("Common.Const.AbilityConst")
local HitBoxData = require("Common.Data.hitbox_data")
local AttributeIdData = require("Data.attribute_id_data")
local ClientSwitch = require("Common.ClientSwitch")
local ClientAbilityConst = require("Const.ClientAbilityConst")
local AttributeConst = require("Common.Const.AttributeConst")
local EffectConst = require("Const.EffectConst")
local AudioConst = require("Const.AudioConst")
local ClientConst = require("Const.ClientConst")
local ClientModelUtils = require("Utils.ClientModelUtils")
local Utils = require("Common.Utils.Utils")
local BossRushUtils = require("Utils.BossRushUtils")
local CombatActionTool = require("Common.Ability.CombatActionTool")
local ClientEffectUtils = require("Utils.ClientEffectUtils")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local PetTransmogUtils = require("GameApp.PetTransmog.PetTransmogUtils")
local ConflictTypes = require("Common.ConflictTypes")
local AbilitySettingGlobalConstData = require("Data.ability_setting_global_const_data")
local AbilityConst = require("Common.Const.AbilityConst")
local CombatLogger = require("Common.Ability.CombatLogger")
local Time = require("Core.Common.Time")
local ImpulseData = require("Data.impulse_data")
local pg = pg
local Lume = require("Core.Common.lume")
local BuffCalcValueData = require("Data.buff_calc_value_data")
local AbilityCalcValData = require("Data.ability_calc_value_data")
local TimelineCalcValData = require("Data.timeline_calc_value_data")
local ElementPropData = require("Data.element_prop_data")
local EffectData = require("Data.effect_data")
local Const = require("Common.Const.Const")
local ClientAbilityUtils = Class.LiteClass("ClientAbilityUtils", AbilityUtils)
local Vector3 = Vector3
local Quaternion = Quaternion
local ToBool = ToBool
local bitBor = bit.bor
local CombatRTPCType = AudioConst.COMBAT_RTPC_TYPE

function ClientAbilityUtils.preloadAllAbility(entity)
	for _, ability in pairs(entity.abilityMap or EMPTY_TABLE) do
		ClientAbilityUtils.preloadAbility(entity, ability.abilityId)
	end

	for _, ability in pairs(entity.stolenAbilityMap or EMPTY_TABLE) do
		ClientAbilityUtils.preloadAbility(entity, ability.abilityId)
	end

	for _, ability in pairs(entity.callFriendsAbilityMap or EMPTY_TABLE) do
		ClientAbilityUtils.preloadAbility(entity, ability.abilityId)
	end
end

function ClientAbilityUtils.prepareAbilityModel(entity, data)
	if entity:hasEModelComponent(Const.COMPONENT_IDX_PLAYABLE) and data.preloadAnims then
		local keys = {}

		for _, name in ipairs(data.preloadAnims) do
			if PlayableConst[name] ~= nil then
				table.insert(keys, PlayableConst[name])
			end
		end

		entity.eModel:PreloadAnimations(Const.COMPONENT_IDX_PLAYABLE, keys)
	end

	if ToBool(data.rigConfig) and IsNil(entity.dynamicRigMap[data.rigConfig]) then
		entity:addDynamicRigComponent(data.rigConfig, data.rigBoneData, data.rigAnimatorEffectId)
	end
end

function ClientAbilityUtils.preloadAbility(entity, abilityId)
	if Utils.isPet(entity) then
		local player = entity:getMasterEntity()

		if player and not player:isInPreparesList(entity) then
			return
		end
	end

	if entity:checkArkSceneState() then
		local abilityParamData = pg.global.abilityMgr:getAbilityParamData(abilityId)

		if not abilityParamData or not abilityParamData.arkCd then
			return
		end
	end

	local data = pg.global.abilityMgr:getAbilityTemplate(abilityId)

	ClientAbilityUtils.prepareAbilityModel(entity, data)

	entity.abilityPreloadMap = entity.abilityPreloadMap or {}

	if entity.abilityPreloadMap[abilityId] then
		return
	end

	entity.abilityPreloadMap[abilityId] = true

	if ToBool(data.burrowEnterBuffIds) or ToBool(data.burrowExitCastAbilityId) then
		local enterBuffIds = data.burrowEnterBuffIds
		local exitCastAbilityId = data.burrowExitCastAbilityId

		entity:setEntityCacheVal(AbilityConst.COMBAT_EVENT_ON_BURROW_STATE_CHANGE, {
			duration = data.burrowDuration,
			enterBuffIds = enterBuffIds,
			exitCastAbilityId = exitCastAbilityId,
			burrowAbilityId = abilityId or 0,
			switchToAbilityId = data.burrowSwitchToAbilityId
		})
	end

	entity:addDynamicRPCState(data.parentDynamicRPCStates, data.dynamicRPCStates)

	local isMobile = IS_MOBILE
	local isMe = entity == pg.me or Utils.isPet(entity) and entity:getMasterEntity() == pg.me

	if (not isMobile or isMe or Utils.isBoss(entity) or Utils.isElite(entity)) and data.preloadEffs then
		for _, effectId in ipairs(data.preloadEffs) do
			local effectData = EffectData[effectId] or {}

			for _, effectItem in ipairs(effectData) do
				if string.notNilOrEmpty(effectItem.resID) then
					pg.global.effectMgr:PreLoadEffect(effectItem.resID)
				elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
					logger:error("@hyj effect resID is null", effectId)
				end
			end
		end
	end

	if isMe then
		entity.isPreloadCutScene = true

		if data.preloadCutScenes then
			for _, resId in ipairs(data.preloadCutScenes) do
				ClientAbilityUtils.preloadCutScene(entity, resId)
			end
		end

		if data.preloadCutScenesBySuit or data.preloadCutSceneBySuitDefaultResId then
			local suitId = AbilityUtils.getSuitId(entity)
			local resId = data.preloadCutScenesBySuit and data.preloadCutScenesBySuit[suitId] or data.preloadCutSceneBySuitDefaultResId

			entity.suitCutSceneResId = resId

			ClientAbilityUtils.preloadCutScene(entity, resId)
		end
	end
end

function ClientAbilityUtils.unPreloadAllAbility(entity)
	for abilityId in pairs(entity.abilityPreloadMap or EMPTY_TABLE) do
		ClientAbilityUtils.unPreloadAbility(entity, abilityId)
	end

	entity.abilityPreloadMap = nil
end

function ClientAbilityUtils.unPreloadAbility(entity, abilityId)
	if not entity.abilityPreloadMap or not entity.abilityPreloadMap[abilityId] then
		return
	end

	entity.abilityPreloadMap[abilityId] = nil

	if entity:checkArkSceneState() then
		local abilityParamData = pg.global.abilityMgr:getAbilityParamData(abilityId)

		if not abilityParamData or not abilityParamData.arkCd then
			return
		end
	end

	local data = pg.global.abilityMgr:getAbilityTemplate(abilityId)

	if ToBool(data.rigConfig) then
		entity:removeDynamicRigComponent(data.rigConfig)
	end

	entity:removeDynamicRPCState(data.parentDynamicRPCStates, data.dynamicRPCStates)

	local isMobile = IS_MOBILE
	local isMe = entity == pg.me or Utils.isPet(entity) and entity:getMasterEntity() == pg.me

	if (not isMobile or isMe or Utils.isBoss(entity) or Utils.isElite(entity)) and data.preloadEffs then
		for _, effectId in ipairs(data.preloadEffs) do
			local effectData = EffectData[effectId] or {}

			for _, effectItem in ipairs(effectData) do
				pg.global.effectMgr:UnPreLoadEffect(effectItem.resID)
			end
		end
	end

	if isMe and entity.isPreloadCutScene then
		if data.preloadCutScenes then
			for _, resId in ipairs(data.preloadCutScenes) do
				ClientAbilityUtils.unPreloadCutScene(entity, resId)
			end
		end

		if data.preloadCutScenesBySuit or data.preloadCutSceneBySuitDefaultResId then
			if entity.suitCutSceneResId then
				ClientAbilityUtils.unPreloadCutScene(entity, entity.suitCutSceneResId)
			end

			local suitId = AbilityUtils.getSuitId(entity)
			local resId = data.preloadCutScenesBySuit and data.preloadCutScenesBySuit[suitId] or data.preloadCutSceneBySuitDefaultResId

			ClientAbilityUtils.unPreloadCutScene(entity, resId)
		end
	end
end

function ClientAbilityUtils.getBuffIcon(buffTemplateId)
	local buffConfigData = BuffConfigData[buffTemplateId]

	if buffConfigData and buffConfigData.icon then
		return buffConfigData.icon
	end

	local buffBpData = pg.global.abilityMgr:getBuffTemplate(buffTemplateId)

	if buffBpData and buffBpData.icon and buffBpData.icon ~= "" then
		return string.format("$XGUI_Texture/Icon/Skill_Buff_Icon/%s.png", buffBpData.icon)
	end

	return nil
end

function ClientAbilityUtils.getBuffName(buffTemplateId)
	local buffConfigData = BuffConfigData[buffTemplateId]

	return buffConfigData and buffConfigData.buffName or ""
end

function ClientAbilityUtils.getBuffDesc(buffTemplateId, layer, level, petInfo)
	local LuaUIUtils = require("Utils.LuaUIUtils")

	LuaUIUtils.customRichTextData.level = level
	LuaUIUtils.customRichTextData.petInfo = petInfo

	local buffConfigData = BuffConfigData[buffTemplateId]
	local buffDesc = buffConfigData.buffDesc

	if layer then
		local layerDescKey = string.format("layer%dDesc", layer)

		buffDesc = buffConfigData[layerDescKey] or buffDesc
	end

	local buffDesc = pg.parseDescText(buffDesc, buffConfigData)

	LuaUIUtils.customRichTextData.level = nil
	LuaUIUtils.customRichTextData.petInfo = nil

	return buffDesc or ""
end

function ClientAbilityUtils.playScarDecalEff(targetEnt, hitPos, rotRadian)
	if not targetEnt.enableSpawnDecal then
		return
	end

	if targetEnt.actorBuff:hasTag(AbilityConst.BUFF_TAG_IMMUNE_DAMAGE) or targetEnt.actorBuff:hasTag(AbilityConst.BUFF_TAG_INVINCIBLE) then
		return
	end

	if targetEnt.lastScarDecalTime and Time.realSecondCache - targetEnt.lastScarDecalTime < 3 then
		return
	end

	targetEnt.lastScarDecalTime = Time.realSecondCache

	local dir = hitPos - targetEnt:getPosition()

	dir.y = 0

	local hitRot

	if Vector3.SqrMagnitude(dir) < 0.01 then
		hitRot = Quaternion.AngleAxis(rotRadian * math.rad2Deg, Vector3.forward)
	else
		hitRot = Quaternion.LookRotation(Vector3.SetNormalize(dir), Vector3.up) * Quaternion.AngleAxis(rotRadian * math.rad2Deg, Vector3.forward)
	end

	targetEnt.eModel.shaderView:SpawnDecal(hitPos, hitRot)
end

local extInfoCache = {}

function ClientAbilityUtils.doPlayHitEffect(targetEntity, combatContext, effectKey, playScarDecal, pos, radian)
	effectKey = targetEntity.replaceHitEffect or effectKey

	local dirX, dirY, dirZ = pg.global.cameraMgr:GetWorldCameraXYPlaneDirEx(radian)
	local dir = Vector3(dirX, dirY, dirZ)
	local efxRot = Quaternion.LookRotation(dir, Vector3.up)
	local extInfo = extInfoCache

	Lume.clear(extInfo)

	extInfo.position = pos
	extInfo.rotation = efxRot:ToEulerAngles()
	extInfo.mountType = EffectConst.MountType.World
	extInfo.followType = EffectConst.FollowType.Global

	local casterEnt = CombatActionTool.getCasterEnt(combatContext)

	casterEnt = casterEnt or pg.getEntityByActorId(CombatActionTool.parseActorIdSrc(combatContext))

	if ClientSwitch.EnableEffectMpeLodDown and targetEntity.space and (targetEntity.space:isMultiPlayerEnv() or BossRushUtils.isBossRushMultiPlayerEnv()) then
		local enableMpeLodDown = true

		if targetEntity.isMainPlayer or targetEntity.isMainPet then
			enableMpeLodDown = false
		end

		if casterEnt and (casterEnt.isMainPlayer or casterEnt.isMainPet) then
			enableMpeLodDown = false
		end

		extInfo.enableMpeLodDown = enableMpeLodDown
		extInfo.mpeLodDownLevel = EffectConst.MAX_LOD_DOWN_LEVEL
	end

	if targetEntity.combatAction then
		targetEntity.combatAction:setEffectExtraData(extInfo, combatContext, targetEntity, true)
	end

	if casterEnt then
		casterEnt:playEffect(effectKey, extInfo)
	else
		targetEntity:playEffect(effectKey, extInfo)
	end

	if playScarDecal then
		ClientAbilityUtils.playScarDecalEff(targetEntity, pos, radian)
	end
end

function ClientAbilityUtils.playHitEffects(hitEffectList, defaultHitEff, hitEffectByAction, hitPos, targetEntity, combatContext, attackData, playScarDecal)
	if targetEntity.disableHitEffect then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			CombatLogger.debug("targetEntity disable PlayHitEffects", targetEntity.actorId)
		end

		return
	end

	Vector3.enableCreateFromCache()

	local rotAngle
	local impulseData = ImpulseData[attackData.impulseId]

	playScarDecal = playScarDecal and impulseData and impulseData.impulseType >= AbilityConst.ATTACK_FORCE_KNOCK_HEAVY

	if hitEffectList then
		for idx, hitEffectData in ipairs(hitEffectList) do
			local efxPos

			if hitEffectData.posMode == AbilityConst.POS_ON_HIT_POSITION then
				efxPos = hitPos
			elseif hitEffectData.posMode == AbilityConst.POS_ROOT_POS then
				efxPos = targetEntity:getPosition()
			end

			local radian = 0

			if hitEffectData.rotAngle then
				if rotAngle == nil then
					rotAngle = hitEffectData.rotAngle
				end

				if hitEffectData.addRandomAngle then
					radian = (hitEffectData.rotAngle + math.random(-30, 30)) * math.deg2Rad
				else
					radian = hitEffectData.rotAngle * math.deg2Rad
				end
			else
				radian = math.random(360) * math.deg2Rad
			end

			ClientAbilityUtils.doPlayHitEffect(targetEntity, combatContext, hitEffectData.id, playScarDecal, efxPos, radian)
		end
	end

	if defaultHitEff then
		local radian = 0

		if rotAngle then
			radian = rotAngle * math.deg2Rad
		else
			radian = math.random(360) * math.deg2Rad
		end

		ClientAbilityUtils.doPlayHitEffect(targetEntity, combatContext, defaultHitEff, playScarDecal, hitPos, radian)
	end

	if hitEffectByAction then
		local hitEffect = pg.global.abilityMgr.combatAction:doAction(hitEffectByAction, combatContext)

		if type(hitEffect) == "string" then
			local radian = 0

			if rotAngle then
				radian = rotAngle * math.deg2Rad
			else
				radian = math.random(360) * math.deg2Rad
			end

			ClientAbilityUtils.doPlayHitEffect(targetEntity, combatContext, hitEffect, playScarDecal, hitPos, radian)
		end
	end

	Vector3.disableCreateFromCache()
end

function ClientAbilityUtils.playProjectileEffect(ownerEntity, effectGeneratorId, effectId, projectileTransform, effectTimeInitOffset, combatContext)
	Lume.clear(extInfoCache)

	extInfoCache.enableMpeLodDown = ClientAbilityUtils.checkEnableMpeLodDown(ownerEntity)
	extInfoCache.mpeLodDownLevel = EffectConst.MIN_LOD_DOWN_LEVEL
	extInfoCache.startTime = effectTimeInitOffset

	ClientAbilityUtils.setCombatAudioInfo(extInfoCache, combatContext)

	return pg.game.effect:playEffectOn(effectGeneratorId, effectId, projectileTransform, extInfoCache)
end

function ClientAbilityUtils.setEffectMpeLodInfo(extraData, targetEntity, casterEntity)
	if extraData == nil then
		return
	end

	extraData.enableMpeLodDown = ClientAbilityUtils.checkEnableMpeLodDown(targetEntity, casterEntity)
	extraData.mpeLodDownLevel = EffectConst.MIN_LOD_DOWN_LEVEL
end

function ClientAbilityUtils.checkEnableMpeLodDown(ent, casterEnt)
	if not ClientSwitch.EnableEffectMpeLodDown then
		return false
	end

	if ent == nil or ent.space == nil then
		return false
	end

	if ent.space:isMultiPlayerEnv() or BossRushUtils.isBossRushMultiPlayerEnv() then
		local playerEnt = Utils.getMasterPlayer(ent)

		if (not playerEnt or not playerEnt.isMainPlayer) and not Utils.isSemanticallyBoss(ent) then
			if casterEnt and (casterEnt.isMainPlayer or casterEnt.isMainPet) then
				return false
			else
				return true
			end
		end
	end

	return false
end

function ClientAbilityUtils.getPartData(entity, partIndex)
	local hitBoxData = HitBoxData[entity.useHitBox].hitBoxNodes

	return hitBoxData and hitBoxData[partIndex] or nil
end

function ClientAbilityUtils.getAttributeStr(attributeId, value)
	if not value then
		return ""
	end

	local attributeName = AttributeConst.ID2NAME[attributeId]
	local showType = AttributeIdData[attributeName] and AttributeIdData[attributeName].showType or ClientAbilityConst.ATTRIBUTE_SHOW_TYPE.INT

	if showType == ClientAbilityConst.ATTRIBUTE_SHOW_TYPE.INT then
		return tostring(math.ceil(value))
	elseif showType == ClientAbilityConst.ATTRIBUTE_SHOW_TYPE.PERCENT then
		return string.format("%.1f%%", value * 100)
	elseif showType == ClientAbilityConst.ATTRIBUTE_SHOW_TYPE.FLOAT then
		return Utils.m_customParseFloatPropVal(value)
	else
		return string.format("not supported showType, attributeId %d, showType %d", attributeId, showType)
	end
end

function ClientAbilityUtils.refreshCutSceneAppearance(owner, virtualEntity)
	local petInfo = owner.petInfo
	local petData = owner:getConfigData()

	if not virtualEntity.eModel or IsNil(virtualEntity.eModel.modelView) then
		return
	end

	local modelView = virtualEntity.eModel.modelView
	local label = petInfo and petInfo.label or owner.label or 0
	local gender = petInfo and petInfo.gender or owner.gender or 0
	local extraInfo = ClientModelUtils.getModelExtraInfo(petData, label, gender, false)

	extraInfo.attachEffects = {}
	extraInfo.modelNeedBones = true

	virtualEntity:postComponentMethod("EVENT_OnMergeAppearanceData", virtualEntity:getConfigData(), extraInfo)
	ClientModelUtils.applyPetAppearance(modelView.modelInfo, petData, extraInfo)
	modelView:RefreshModels()
	modelView.shaderView:SetMultiPassForce32Layer(true, ClientAbilityConst.MULTI_PASS_LAYER)
	virtualEntity:attachBaseEffects(extraInfo.attachEffects)
end

function ClientAbilityUtils.isSkillExCutSceneBindValid(owner, virtualEntity, cutSceneItem)
	if owner == nil or owner.isDestroyed or not owner.eModel then
		return false
	end

	if virtualEntity == nil or virtualEntity.isDestroyed or not virtualEntity.eModel then
		return false
	end

	if cutSceneItem == nil or cutSceneItem:isDestroyed() or IsNil(cutSceneItem.cutscene) then
		return false
	end

	return true
end

function ClientAbilityUtils.getSkillExCutSceneExtraData(owner, overrideState, hideGround)
	local function bindCallback(cutSceneItem, virtualEntity, bindKey, bindParam, isAsync)
		if not ClientAbilityUtils.isSkillExCutSceneBindValid(owner, virtualEntity, cutSceneItem) then
			return false
		end

		cutSceneItem.cutscene.isDisableShadow = true

		local petInfo = owner.petInfo
		local petData = owner:getConfigData()
		local parentTrans = virtualEntity.eModel.transform.parent

		if parentTrans.name == "EntityRoot" then
			error("parentTrans error, entity root")

			return
		end

		virtualEntity.eModel:SetTransformParent(cutSceneItem.cutscene.rootObject.transform.parent)
		virtualEntity:setConfigData(petData)
		virtualEntity.eModel:ToggleLodTick(false)

		virtualEntity.petInfo = petInfo
		virtualEntity.templateId = petInfo and petInfo.templateId or owner.templateId

		local animatorReadyCallback

		function animatorReadyCallback()
			if not ClientAbilityUtils.isSkillExCutSceneBindValid(owner, virtualEntity, cutSceneItem) then
				return
			end

			cutSceneItem:rebindAnimator(virtualEntity.eModel.modelSkeletonView)
			virtualEntity:setModelLayer(ClientConst.LayerDefine.LAYER_CUTSCENE)

			if PetTransmogUtils.isTemplateTransmogable(owner.templateId) then
				cutSceneItem.cutscene.beforePlayCallback = animatorReadyCallback
			end
		end

		if not owner.transmogData then
			ClientAbilityUtils.refreshCutSceneAppearance(owner, virtualEntity)
		end

		virtualEntity:setModelLayer(ClientConst.LayerDefine.LAYER_CUTSCENE)

		if not ClientAbilityUtils.isSkillExCutSceneBindValid(owner, virtualEntity, cutSceneItem) then
			return false
		end

		virtualEntity.capsuleHeight = owner.eModel.height

		local loadCallback

		function loadCallback()
			if not ClientAbilityUtils.isSkillExCutSceneBindValid(owner, virtualEntity, cutSceneItem) then
				return
			end

			local _, clipConfig = owner.eModel:TryGetPlayableClipConfig(Const.COMPONENT_IDX_PLAYABLE, AnimationUtils.getID(overrideState))
			local clipKey, assetKey, subAssetName

			if clipConfig then
				clipKey = clipConfig.clipKey
				assetKey = clipConfig.assetKey
				subAssetName = clipConfig.subAssetName
			end

			local labelSuffix = ""
			local petPrototypeId = owner:getConfigData().petPrototypeId
			local isRainbowType = Utils.isRainbowType(petPrototypeId)
			local isShiny = Utils.isLabelShiny(owner.label)

			if isRainbowType then
				labelSuffix = "_Rainbow"
			end

			if isShiny then
				labelSuffix = labelSuffix .. "_Shiny"
			end

			cutSceneItem:rebind(parentTrans.gameObject, virtualEntity.eModel.modelSkeletonView, clipKey, assetKey, subAssetName, labelSuffix, owner.eModel)

			if hideGround ~= false then
				cutSceneItem:hideGround()
			end

			if PetTransmogUtils.isTemplateTransmogable(owner.templateId) then
				cutSceneItem.cutscene.beforePlayCallback = animatorReadyCallback
			end

			virtualEntity.eModel:SetActive(false)
		end

		if NotNil(virtualEntity.eModel.modelView) and virtualEntity.eModel.modelView:IsAnimatorRead() then
			loadCallback()
		else
			virtualEntity.onAnimatorReadyCallback = loadCallback
		end

		if not ClientAbilityUtils.isSkillExCutSceneBindValid(owner, virtualEntity, cutSceneItem) then
			return false
		end

		owner:addModelSwitchSyncEnt(virtualEntity)

		return not isAsync
	end

	return {
		isSetActiveNoRebind = true,
		dontDestroy = true,
		applySoundListener = false,
		bindCallback = bindCallback,
		gender = owner.gender
	}
end

function ClientAbilityUtils.getImpulseInteractTag(abilityId, impulseId)
	local isNormalAttack = AbilityUtils.isNormalAttack(abilityId)
	local interactTag = isNormalAttack and (ImpulseData[impulseId] or EMPTY_TABLE).normalAttackInteractTag or (ImpulseData[impulseId] or EMPTY_TABLE).interactTag

	return interactTag
end

function ClientAbilityUtils.getImpulse(abilityId, impulseId)
	local isNormalAttack = AbilityUtils.isNormalAttack(abilityId)
	local interactTag = isNormalAttack and (ImpulseData[impulseId] or EMPTY_TABLE).normalAttackInteractTag or (ImpulseData[impulseId] or EMPTY_TABLE).interactTag
	local physicsImpulse = AbilitySettingGlobalConstData.physicsImpulse[interactTag] or 0

	if type(physicsImpulse) ~= "number" then
		physicsImpulse = 0
	end

	return physicsImpulse
end

function ClientAbilityUtils.getElementLevel(ent, combatContext, chemElementId)
	local abilityParamData = pg.global.abilityMgr:getAbilityParamData(combatContext.abilityId, combatContext.buffTemplateId)

	ent = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_CASTER)) or ent
	ent = (Utils.isCreation(ent) or Utils.isPuppet(ent)) and ent:getMasterEntity() or ent
	chemElementId = AbilityConst.ECS_ELEMENT_2_ABILITY[chemElementId] or chemElementId

	if abilityParamData then
		local configData = ent and ent:getConfigData()
		local configElementLevels = configData and configData.elementLevels
		local elementName = chemElementId and ElementPropData[chemElementId] and ElementPropData[chemElementId].name
		local configElementLevel = elementName and configElementLevels and configElementLevels[elementName] or 0

		if type(configElementLevel) ~= "number" then
			configElementLevel = 0
		end

		return math.max(1, configElementLevel + (abilityParamData.elementLevel or 0))
	end

	local configData = ent and ent:getConfigData()
	local configElementLevels = configData and configData.elementLevels
	local elementName = chemElementId and ElementPropData[chemElementId] and ElementPropData[chemElementId].name
	local configElementLevel = elementName and configElementLevels and configElementLevels[elementName] or 0

	if type(configElementLevel) ~= "number" then
		configElementLevel = 0
	end

	return math.max(1, configElementLevel)
end

function ClientAbilityUtils.getElementValue(actionData, combatContext)
	local calcData = combatContext.nodeMap[actionData.calcResultNodeId]

	if not calcData then
		return 0, 0, 0
	end

	local casterEntity = pg.getEntityByActorId(CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_SRC))

	casterEntity = (Utils.isCreation(casterEntity) or Utils.isPuppet(casterEntity)) and casterEntity:getMasterEntity() or casterEntity

	local paramData = pg.global.abilityMgr:getAbilityParamData(combatContext.abilityId, combatContext.buffTemplateId)
	local power = AbilityUtils.getAbilityParamPower(paramData, casterEntity)
	local attackData = calcData.attackData
	local overrideEcsPower = attackData and attackData.overrideEcsPower or 0
	local ecsPower = overrideEcsPower > 0 and overrideEcsPower or paramData.ecsPower or 0
	local instanceDmgRateV = 0

	if calcData.calcInfoByLuaConfig and calcData.calcInfoByLuaConfig.instant_dmg_rate_v then
		local paramName = calcData.calcInfoByLuaConfig.instant_dmg_rate_v
		local calcType = calcData.calcInfoByLuaConfig.type
		local id = calcData.calcInfoByLuaConfig.id
		local level = 1
		local configData

		if calcType == AbilityConst.CALC_PARAM_TYPES.BUFF then
			level = combatContext:buff() and combatContext:buff().buffData.level or 1
			configData = BuffCalcValueData
		elseif calcType == AbilityConst.CALC_PARAM_TYPES.ABILITY then
			local ability = CombatActionTool.getCasterAbility(combatContext)

			level = ability and ability.abilityLevel or 1
			configData = AbilityCalcValData
		elseif calcType == AbilityConst.CALC_PARAM_TYPES.TIMELINE then
			configData = TimelineCalcValData
		else
			CombatActionTool.logDebug(combatContext, "not support calcType")
		end

		if configData then
			local data

			if calcType ~= AbilityConst.CALC_PARAM_TYPES.TIMELINE then
				data = ((configData[id] or EMPTY_TABLE)[paramName] or EMPTY_TABLE)[level]
			else
				data = (configData[id] or EMPTY_TABLE)[paramName]
			end

			if not data then
				CombatActionTool.logDebug(combatContext, "not found attribute value by lua config", id, paramName, level)

				instanceDmgRateV = 0
			else
				instanceDmgRateV = CombatActionTool.getCalcValue(data, casterEntity and casterEntity.actorCombatAttribute)
			end
		end
	end

	if instanceDmgRateV == 0 and calcData.calcInfo and calcData.calcInfo.instant_dmg_rate_v then
		instanceDmgRateV = pg.global.abilityMgr.combatAction:getVal(calcData.calcInfo.instant_dmg_rate_v, combatContext)
	end

	if type(instanceDmgRateV) ~= "number" then
		instanceDmgRateV = 0
	end

	if type(power) ~= "number" then
		power = 0
	end

	if type(ecsPower) ~= "number" then
		ecsPower = 0
	end

	return instanceDmgRateV * power, instanceDmgRateV * ecsPower, instanceDmgRateV
end

function ClientAbilityUtils.actOnEnvObjDirectly(collider, hitPos, actionData, combatContext)
	local abilityId = combatContext.abilityId
	local chemElementId = pg.global.abilityMgr:getEcsElement(abilityId) or 0
	local actorId = CombatActionTool.parseActorId(combatContext, AbilityConst.COMBAT_TARGET_TYPE_OWNER)
	local ownerEntity = pg.getEntityByActorId(actorId)
	local impulseId = AbilityUtils.getAttackDataImpulseId(actionData)
	local physicsImpulse = ClientAbilityUtils.getImpulse(combatContext.abilityId, impulseId)
	local elementLevel = ClientAbilityUtils.getElementLevel(ownerEntity, combatContext, chemElementId)
	local elementValue, ecsElementValue, instanceDmgRateV = ClientAbilityUtils.getElementValue(actionData, combatContext)

	pg.global.physicsMgr:SetChemHitInfo(actorId, combatContext.abilityId or 0, chemElementId or 0, physicsImpulse or 0, elementLevel, elementValue, ecsElementValue, instanceDmgRateV)
	pg.global.physicsMgr:ActOnElementDirectly(collider, hitPos)
	pg.global.physicsMgr:ClearChemHitInfo()
end

function ClientAbilityUtils.getSelectedPosTarget(abilityId)
	local abilityTemplate = pg.global.abilityMgr:getAbilityTemplate(abilityId)

	if abilityTemplate.abilityIndicator == ClientAbilityConst.IndicatorType.SelectPos and abilityTemplate.selectPosTarget then
		return abilityTemplate.selectPosTarget
	end

	return nil
end

function ClientAbilityUtils.needShowAbilityIndicator(abilityId)
	local abilityId = pg.pawn:getSwitchSkill(abilityId)
	local abilityTemplate = pg.global.abilityMgr:getAbilityTemplate(abilityId)

	return abilityTemplate.abilityIndicator ~= nil
end

function ClientAbilityUtils.showAbilityIndicator(abilityId)
	local abilityId = pg.pawn:getSwitchSkill(abilityId)
	local abilityTemplate = pg.global.abilityMgr:getAbilityTemplate(abilityId)

	if not abilityTemplate.abilityIndicator then
		return false
	end

	local result, reason = pg.pawn:checkCanCastAbilityNoTarget(abilityId, nil, false)

	if not result then
		pg.game.controller:showUseSkillFailedMsg(abilityId, result, reason)

		return true
	end

	local selectPosTarget = abilityTemplate.abilityIndicator == ClientAbilityConst.IndicatorType.SelectPos and abilityTemplate.selectPosTarget

	if selectPosTarget then
		if pg.pawn:checkStatus(ConflictTypes.CT_ABILITY_INDICATOR_SEL_POS) then
			pg.pawn:showAbilityIndicatorSelPos(abilityId, selectPosTarget)
		end

		return true
	end

	local indicatorAimData = abilityTemplate.abilityIndicator == ClientAbilityConst.IndicatorType.ShowAim and abilityTemplate.indicatorAimData

	if indicatorAimData and pg.pawn:checkStatus(ConflictTypes.CT_ABILITY_INDICATOR_AIM) then
		pg.pawn:showAbilityIndicatorAim(abilityId, indicatorAimData)
	end

	local aimWalkTarget = abilityTemplate.abilityIndicator == ClientAbilityConst.IndicatorType.AimWalk and abilityTemplate.aimWalkTarget

	if aimWalkTarget and pg.pawn:checkStatus(ConflictTypes.CT_ABILITY_INDICATOR_AIM_WALK) then
		pg.pawn:showAbilityIndicatorAimWalk(abilityId, aimWalkTarget)
	end

	return false
end

function ClientAbilityUtils.hideAbilityIndicator(needCastAbility, abilityId)
	local abilityId = pg.pawn:getSwitchSkill(abilityId)
	local abilityTemplate = pg.global.abilityMgr:getAbilityTemplate(abilityId)

	if not abilityTemplate.abilityIndicator then
		return
	end

	local abilityType = abilityTemplate.abilityType
	local selectPosTarget = abilityTemplate.abilityIndicator == ClientAbilityConst.IndicatorType.SelectPos and abilityTemplate.selectPosTarget

	if selectPosTarget then
		if pg.pawn.abilityIndicatorSelPosData then
			pg.pawn:hideAbilityIndicatorSelPos(needCastAbility, nil)

			pg.pawn.abilityIndicatorSelPosData = nil

			if pg.pawn.updateStateCache then
				pg.pawn:updateStateCache("ABILITY_INDICATOR_SEL_POS_ST")
			end
		else
			pg.game.controller:useSkill(abilityId, abilityType)
		end

		return
	end

	local aimData = abilityTemplate.abilityIndicator == ClientAbilityConst.IndicatorType.ShowAim and abilityTemplate.indicatorAimData

	if aimData then
		if pg.pawn.abilityIndicatorAimData then
			pg.pawn:hideAbilityIndicatorAim(needCastAbility, nil, abilityId, abilityType)

			pg.pawn.abilityIndicatorAimData = nil

			if pg.pawn.updateStateCache then
				pg.pawn:updateStateCache("ABILITY_INDICATOR_AIM_ST")
			end
		else
			pg.game.controller:useSkill(abilityId, abilityType)
		end

		return
	end

	local aimWalkData = abilityTemplate.abilityIndicator == ClientAbilityConst.IndicatorType.AimWalk and abilityTemplate.aimWalkTarget

	if aimWalkData then
		if pg.pawn.abilityIndicatorAimWalkData then
			pg.pawn:hideAbilityIndicatorAimWalk(needCastAbility, nil, abilityId, abilityType)

			pg.pawn.abilityIndicatorAimWalkData = nil

			if pg.pawn.updateStateCache then
				pg.pawn:updateStateCache("ABILITY_INDICATOR_AIM_WALK_ST")
			end
		else
			pg.game.controller:useSkill(abilityId, abilityType)
		end

		return
	end
end

function ClientAbilityUtils.checkHideAbilityIndicator(abilityId)
	local abilityTemplate = pg.global.abilityMgr:getAbilityTemplate(abilityId)

	if not abilityTemplate.abilityIndicator then
		return
	end

	local selectPosTarget = abilityTemplate.abilityIndicator == ClientAbilityConst.IndicatorType.SelectPos and abilityTemplate.selectPosTarget

	if selectPosTarget then
		if pg.pawn.abilityIndicatorSelPosData and pg.pawn.abilityIndicatorSelPosData.abilityId == abilityId then
			pg.pawn:hideAbilityIndicatorSelPos(false, nil)

			pg.pawn.abilityIndicatorSelPosData = nil

			if pg.pawn.updateStateCache then
				pg.pawn:updateStateCache("ABILITY_INDICATOR_SEL_POS_ST")
			end
		end

		return
	end

	local aimData = abilityTemplate.abilityIndicator == ClientAbilityConst.IndicatorType.ShowAim and abilityTemplate.indicatorAimData

	if aimData then
		if pg.pawn.abilityIndicatorAimData and pg.pawn.abilityIndicatorAimData.abilityId == abilityId then
			pg.pawn:hideAbilityIndicatorAim(false, nil)

			pg.pawn.abilityIndicatorAimData = nil

			if pg.pawn.updateStateCache then
				pg.pawn:updateStateCache("ABILITY_INDICATOR_AIM_ST")
			end
		end

		return
	end

	local aimWalkData = abilityTemplate.abilityIndicator == ClientAbilityConst.IndicatorType.AimWalk and abilityTemplate.aimWalkTarget

	if aimWalkData then
		if pg.pawn.abilityIndicatorAimWalkData and pg.pawn.abilityIndicatorAimData.abilityId == abilityId then
			pg.pawn:hideAbilityIndicatorAimWalk(false, nil)

			pg.pawn.abilityIndicatorAimWalkData = nil

			if pg.pawn.updateStateCache then
				pg.pawn:updateStateCache("ABILITY_INDICATOR_AIM_WALK_ST")
			end
		end

		return
	end
end

function ClientAbilityUtils.parseElementType2HitRippleStr(elementType, isBigBody)
	if isBigBody then
		return (ElementPropData[elementType] or EMPTY_TABLE).hitRipplePreset or "HitRipple_Default"
	else
		return (ElementPropData[elementType] or EMPTY_TABLE).hitRipplePreset_pet or "HitRipple_Default"
	end
end

function ClientAbilityUtils.getCutSceneName(entity, resId)
	return string.format("%s_%s", entity.actorId, resId)
end

function ClientAbilityUtils.preloadCutScene(entity, resId)
	if not string.notNilOrEmpty(resId) then
		return
	end

	local cutSceneName = ClientAbilityUtils.getCutSceneName(entity, resId)

	pg.game.cutscene:preloadCutscene(cutSceneName, resId, ClientAbilityConst.PLAY_CUT_SCENE_POS, nil, ClientAbilityUtils.getSkillExCutSceneExtraData(entity))

	return cutSceneName
end

function ClientAbilityUtils.unPreloadCutScene(entity, resId)
	if not string.notNilOrEmpty(resId) then
		return
	end

	local cutSceneName = ClientAbilityUtils.getCutSceneName(entity, resId)

	pg.game.cutscene:unPreloadCutScene(cutSceneName)

	return cutSceneName
end

function ClientAbilityUtils.getDamageSourceEntity(combatContext)
	local damageSourceEntity = CombatActionTool.getCasterEnt(combatContext)

	if not damageSourceEntity then
		return nil
	end

	damageSourceEntity = damageSourceEntity and (Utils.isCreation(damageSourceEntity) and damageSourceEntity.getMasterEntity and damageSourceEntity:getMasterEntity() or damageSourceEntity)

	return damageSourceEntity
end

function ClientAbilityUtils.setCombatAudioInfo(extraData, combatContext, targetEntity, isHit)
	local combatSkipSkillCutScene = false
	local combatIsHit = isHit == true
	local combatIsCaster1P = false
	local combatIsTarget1P = targetEntity == pg.pawn
	local casterEntity = ClientAbilityUtils.getDamageSourceEntity(combatContext)

	if pg.space then
		combatSkipSkillCutScene = pg.space:checkSkipSkillCutScene()
	end

	if casterEntity then
		combatIsCaster1P = casterEntity == pg.pawn or Utils.isBoss(casterEntity) or Utils.isElite(casterEntity)
	end

	local combatRTPCType = CombatRTPCType.NONE

	if combatIsCaster1P then
		combatRTPCType = bitBor(combatRTPCType, CombatRTPCType.VOLUME_3P)
	end

	if not combatSkipSkillCutScene then
		combatRTPCType = bitBor(combatRTPCType, CombatRTPCType.VOLUME_EX)
	end

	if combatIsHit then
		if combatIsCaster1P then
			combatRTPCType = bitBor(combatRTPCType, CombatRTPCType.VOLUME_HIT_1P_3P_LEVEL_2)
		elseif combatIsTarget1P then
			combatRTPCType = bitBor(combatRTPCType, CombatRTPCType.VOLUME_HIT_1P_3P_LEVEL_1)
		end
	end

	if extraData then
		extraData.combatRTPCType = combatRTPCType
	end

	return combatRTPCType
end

function ClientAbilityUtils.getCombatRTPCType(combatContext, targetEntity, isHit)
	return ClientAbilityUtils.setCombatAudioInfo(nil, combatContext, targetEntity, isHit)
end

function ClientAbilityUtils.setProjectileCombatInfo(projectile, combatRTPCType)
	if projectile and combatRTPCType then
		projectile:SetCombatInfo(combatRTPCType)
	end
end

function ClientAbilityUtils.getSkipCutSceneOffsetTime(combatContext)
	local abilityTemplate = combatContext:getAbilityTemplate()
	local cutSceneDuration = abilityTemplate and abilityTemplate.cutSceneDuration or 0

	if cutSceneDuration <= 0 then
		return 0
	end

	if not combatContext.isCutSceneFastForwarding then
		local owner = CombatActionTool.getOwnerEntity(combatContext)
		local player = owner and AbilityUtils.getPlayer(owner)
		local shouldSkip = player and player.isCutSceneFastforward

		if not shouldSkip and owner and owner.space then
			shouldSkip = owner.space:checkSkipSkillCutScene()
		end

		if not shouldSkip then
			return 0
		end
	end

	local timeline = combatContext:timeline()

	if not timeline or timeline.playRate <= 0 then
		return 0
	end

	return cutSceneDuration / timeline.playRate
end

return ClientAbilityUtils
