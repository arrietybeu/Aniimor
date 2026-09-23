-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientModelTransmogComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local AppearancePointEnum = require("Data.appearance_point_enum")
local EffectConst = require("Const.EffectConst")
local ClientAbilityUtils = require("Utils.ClientAbilityUtils")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local Utils = require("Common.Utils.Utils")
local ClientEffectUtils = require("Utils.ClientEffectUtils")
local PetTransmogUtils = require("GameApp.PetTransmog.PetTransmogUtils")
local Const = require("Common.Const.Const")
local AbilityConst = require("Common.Const.AbilityConst")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local EffReplaceData = require("Data.eff_replace_data")
local PetTransmogSoltData = require("Data.pet_transmog_solt_data")
local TransmogStateEffectData = require("Data.transmog_state_effect_data")
local DyeConfigData = require("Common.Data.ParmonDyeData.dye_config_data")
local LIGHT_SUFFIX = "_Light"
local ShaderView = CS.FunPlus.WorldX.Model.ShaderView
local ClientModelTransmogComponent = Class.Component("ClientModelTransmogComponent")

function ClientModelTransmogComponent:ctor(...)
	if self.className == "ClientPet" or self.className == "ClientPuppet" then
		self.isWaitTransmogCallback = true
	end

	self.parmonDyeRefreshVersion = 0
end

function ClientModelTransmogComponent.loadParmonDyeConfig(dataId, shinyStyle)
	if not dataId or shinyStyle == nil then
		return
	end

	local dyeData = DyeConfigData[string.format("%s.prefab", dataId)]

	return dyeData and dyeData[shinyStyle]
end

function ClientModelTransmogComponent:start()
	self.transmogShinyEffectIns = {}

	self:initTransmogStateEffects()

	if Utils.isPet(self) then
		self:applyTransmogScheme(nil, true)

		return
	end

	local petInfo = self.petInfo

	if not petInfo then
		local pet = AbilityUtils.getPet(self)

		if pet and self.basePetPrototypeId and self.basePetPrototypeId == pet.basePetPrototypeId then
			petInfo = pet.petInfo
		end
	end

	if petInfo or self.selectTransmogScheme then
		local selectTransmogScheme = self.selectTransmogScheme or PetTransmogUtils.getSelectedScheme(petInfo)
		local transmogData, shinyEffectId = PetTransmogUtils.getSchemeTransmogData(petInfo and petInfo.templateId or self.templateId, selectTransmogScheme)

		self:setTransmogData(transmogData, shinyEffectId)
	end
end

function ClientModelTransmogComponent:getTransmogPetInfo()
	if self.petInfo then
		return self.petInfo
	end

	local pet = AbilityUtils.getPet(self)

	if pet and self.basePetPrototypeId and self.basePetPrototypeId == pet.basePetPrototypeId then
		return pet.petInfo
	end
end

function ClientModelTransmogComponent:initTransmogStateEffects()
	local petInfo = self:getTransmogPetInfo()
	local templateId = petInfo and petInfo.templateId or self.templateId

	self.transmogStateEffectData = TransmogStateEffectData[tonumber(templateId) or templateId]
	self.transmogStateEffectIds = {}
	self.transmogStateEffectStateMaps = {}
	self.transmogStateEffectRPCStates = {}

	if not self.transmogStateEffectData then
		return
	end

	local rpcStateMap = {}

	for effectKey, effectInfo in pairs(self.transmogStateEffectData) do
		local effectStateMap = {}

		self.transmogStateEffectStateMaps[effectKey] = effectStateMap

		for _, stateName in ipairs(effectInfo.steateList or EMPTY_TABLE) do
			local state = CharacterStateConst[stateName]

			if state then
				effectStateMap[state] = true
				rpcStateMap[state] = true
			end
		end
	end

	for state, _ in pairs(rpcStateMap) do
		table.insert(self.transmogStateEffectRPCStates, state)
	end

	table.sort(self.transmogStateEffectRPCStates)
	self:registerTransmogStateRPCStates()
end

function ClientModelTransmogComponent:registerTransmogStateRPCStates()
	if self.transmogStateEffectRPCRegistered or not self.addDynamicRPCState then
		return
	end

	if #self.transmogStateEffectRPCStates == 0 then
		return
	end

	self:addDynamicRPCState(nil, self.transmogStateEffectRPCStates)

	self.transmogStateEffectRPCRegistered = true
end

function ClientModelTransmogComponent:unregisterTransmogStateRPCStates()
	if not self.transmogStateEffectRPCRegistered or not self.removeDynamicRPCState then
		return
	end

	self:removeDynamicRPCState(nil, self.transmogStateEffectRPCStates)

	self.transmogStateEffectRPCRegistered = nil
end

function ClientModelTransmogComponent:isTransmogStateEffectResourcesMatched(resources)
	if not resources or resources == "" then
		return true
	end

	local petInfo = self:getTransmogPetInfo()
	local scheme = petInfo and (petInfo.selectTransmogScheme or PetTransmogUtils.getSelectedScheme(petInfo))
	local holeIds = scheme and scheme.holeIds

	if not holeIds then
		return false
	end

	for _, holeId in pairs(holeIds) do
		local slotConfig = PetTransmogSoltData[holeId]

		if slotConfig and slotConfig.resources == resources then
			return true
		end
	end

	return false
end

function ClientModelTransmogComponent:canPlayTransmogStateEffect(effectInfo)
	if effectInfo.suitId and effectInfo.suitId >= 0 and self:getTransmogSuitId() ~= effectInfo.suitId then
		return false
	end

	return self:isTransmogStateEffectResourcesMatched(effectInfo.resources)
end

function ClientModelTransmogComponent:playTransmogStateEffect(effectKey, effectInfo)
	if self.transmogStateEffectIds[effectKey] then
		return
	end

	local suitColorId = self:getSuitColorId()

	if not suitColorId then
		return
	end

	local effectIds = {}
	local playedBoneMap = {}

	for _, colorBoneInfo in ipairs(effectInfo.suitColorBones or EMPTY_TABLE) do
		local colorId = colorBoneInfo[1]
		local bone = colorBoneInfo[2]

		if colorId == suitColorId and bone and not playedBoneMap[bone] then
			playedBoneMap[bone] = true

			local effectId = self:playEffectRaw(effectKey, {
				duration = -1,
				speed = 1,
				mountType = EffectConst.MountType.Model,
				followType = EffectConst.FollowType.FollowPosRot,
				bone = bone
			})

			if effectId and effectId ~= 0 then
				table.insert(effectIds, effectId)
			end
		end
	end

	if #effectIds > 0 then
		self.transmogStateEffectIds[effectKey] = effectIds
	end
end

function ClientModelTransmogComponent:stopTransmogStateEffect(effectKey)
	local effectIds = self.transmogStateEffectIds and self.transmogStateEffectIds[effectKey]

	if not effectIds then
		return
	end

	for _, effectId in ipairs(effectIds) do
		self:stopEffectById(effectId, false)
	end

	self.transmogStateEffectIds[effectKey] = nil
end

function ClientModelTransmogComponent:stopAllTransmogStateEffects()
	if not self.transmogStateEffectIds then
		return
	end

	for effectKey, _ in pairs(self.transmogStateEffectIds) do
		self:stopTransmogStateEffect(effectKey)
	end
end

function ClientModelTransmogComponent:refreshTransmogStateEffects(state, force, effective)
	if not state or not self.transmogStateEffectData then
		return
	end

	if force or not self:isAllHolesGolden(effective) then
		self:stopAllTransmogStateEffects()
	end

	for effectKey, effectInfo in pairs(self.transmogStateEffectData) do
		local stateMap = self.transmogStateEffectStateMaps[effectKey]
		local isActiveState = stateMap and stateMap[state]

		if isActiveState and self:canPlayTransmogStateEffect(effectInfo) then
			self:playTransmogStateEffect(effectKey, effectInfo)
		else
			self:stopTransmogStateEffect(effectKey)
		end
	end
end

function ClientModelTransmogComponent:setTransmogData(transmogData, transmogShinyEffects, transmogSignature, force, effective)
	if not force and transmogSignature and self.transmogSignature == transmogSignature then
		return
	end

	self.transmogSignature = transmogSignature
	self.transmogData = transmogData
	self.transmogShinyEffects = transmogShinyEffects

	self:playTransmogEffects()
	self:refreshAppearance()

	local modelView = self.eModel and self.eModel.modelModelView

	if NotNil(modelView) and modelView:IsAnimatorRead() then
		self:onTransmogAnimatorReady()
	end

	self:refreshTransmogStateEffects(self.motionState, true, effective)

	if self.modelSwitchSyncEnts then
		for entity, _ in pairs(self.modelSwitchSyncEnts) do
			entity:setTransmogData(transmogData, self.transmogShinyEffects, transmogSignature, force)
			ClientAbilityUtils.refreshCutSceneAppearance(self, entity)
		end
	end

	local isMe = self == pg.me or Utils.isPet(self) and self:getMasterEntity() == pg.me

	if isMe then
		local player = self:getMasterEntity()

		if player and player:isInPreparesList(self) then
			local suitId = AbilityUtils.getSuitId(self, effective)
			local abilityInfo = self:getSkillByType(AbilityConst.ULTIMATE_ABILITY)

			if not abilityInfo then
				return
			end

			local abilityData = abilityInfo and pg.global.abilityMgr:getAbilityTemplate(abilityInfo.abilityId)

			if abilityData and (abilityData.preloadCutScenesBySuit or abilityData.preloadCutSceneBySuitDefaultResId) then
				local resName = abilityData.preloadCutScenesBySuit and abilityData.preloadCutScenesBySuit[suitId] or abilityData.preloadCutSceneBySuitDefaultResId

				if resName ~= self.suitCutSceneResId then
					if self.suitCutSceneResId then
						ClientAbilityUtils.unPreloadCutScene(self, self.suitCutSceneResId)
					end

					self.suitCutSceneResId = resName

					ClientAbilityUtils.preloadCutScene(self, resName)
				end
			end
		end
	end

	self:replaceTransmogReplaceEff(effective)
end

function ClientModelTransmogComponent:EVENT_OnMergeAppearanceData(configData, extraData)
	if not self.transmogData then
		return
	end

	local suitId = Utils.isPuppet(self) and self:getConfigData().useSuitModel and AbilityUtils.getSuitId(self:getMasterEntity())

	if suitId and (suitId == 4 or suitId == 5) then
		return
	end

	if not extraData.partItems then
		extraData.partItems = {}
	end

	local hat = self.transmogData[AppearancePointEnum.Hat]

	if hat then
		extraData.partItems[AppearancePointEnum.Hat] = {
			isAvatarWearPart = false,
			resId = hat.resId
		}
	end

	local coat = self.transmogData[AppearancePointEnum.Coat]

	if coat then
		extraData.partItems[AppearancePointEnum.Coat] = {
			isAvatarWearPart = false,
			resId = coat.resId
		}
	end

	local wing = self.transmogData[AppearancePointEnum.Wing]

	if wing then
		extraData.partItems[AppearancePointEnum.Wing] = {
			isAvatarWearPart = false,
			resId = wing.resId
		}
	end
end

function ClientModelTransmogComponent:getDyeConfig()
	if not self.eModel or IsNil(self.eModel.shaderView) then
		return
	end

	local petInfo = self:getTransmogPetInfo()
	local configData = self:getConfigData()
	local shinyStyle = self.shinyStyle or petInfo and petInfo.shinyStyle or 0

	shinyStyle = shinyStyle == 0 and configData.forceShinyStyle or shinyStyle

	local label = self.label or petInfo and petInfo.label

	if Utils.isLabelDark(label) then
		shinyStyle = "dark2"
	elseif not ToBool(configData.isModelColorChange) and Utils.isLabelShiny(label) and shinyStyle ~= 0 then
		shinyStyle = "shiny"
	end

	shinyStyle = shinyStyle or 0

	local prefabResId = configData.prefabResID

	if not prefabResId then
		return
	end

	local dataId = string.match(prefabResId, "%$E?_?([%w_]+)%.prefab")
	local data = ClientModelTransmogComponent.loadParmonDyeConfig(dataId, shinyStyle)

	return data
end

function ClientModelTransmogComponent:playShinnyPreset()
	if not self.eModel or IsNil(self.eModel.shaderView) then
		return
	end

	local petInfo = self:getTransmogPetInfo()
	local label = self.label or petInfo and petInfo.label
	local shinyStyle = self.shinyStyle or petInfo and petInfo.shinyStyle

	if not shinyStyle or shinyStyle == 0 then
		return
	end

	if not Utils.isLabelShiny(label) then
		return
	end

	local configData = self:getConfigData()
	local dyeConfig = ClientModelTransmogComponent.loadParmonDyeConfig(configData.shinyStyleColorId, shinyStyle)
	local shinyEffect = dyeConfig and dyeConfig.shinyEffect or EffectConst.SHINY_EFFECTS[shinyStyle]

	if shinyEffect then
		if self.lastShinyEffectPreset then
			self.eModel.shaderView:StopPreset(self.lastShinyEffectPreset)
		end

		ClientEffectUtils.PlayPresetImmediately(self, shinyEffect, -1, false)

		self.lastShinyEffectPreset = shinyEffect
	end
end

function ClientModelTransmogComponent:clearPetShinyAppearance()
	if not self.eModel or IsNil(self.eModel.shaderView) then
		return
	end

	local shaderView = self.eModel.shaderView
	local configData = self:getConfigData() or EMPTY_TABLE
	local shinyStyle = self.shinyStyle or 0
	local dyeConfig = self:getDyeConfig()

	if configData.prefabResID then
		for renderName, _ in pairs(dyeConfig and dyeConfig.materialEffect or EMPTY_TABLE) do
			local presetKey = string.format("%s_%s_shiny_%d", configData.prefabResID, renderName, shinyStyle)

			shaderView:RemoveMaterialEffectByFilterName(presetKey, renderName, false)
		end
	end

	local shinyDyeConfig = ClientModelTransmogComponent.loadParmonDyeConfig(configData.shinyStyleColorId, shinyStyle)
	local shinyEffect = shinyDyeConfig and shinyDyeConfig.shinyEffect or EffectConst.SHINY_EFFECTS[shinyStyle]

	if shinyEffect then
		shaderView:StopPreset(shinyEffect)
	end

	shaderView:SetBaseMaterialByPreset({})

	if NotNil(self.eModel.modelView) then
		for _, rendererName in pairs(self.dyeDisableRenderers or EMPTY_TABLE) do
			self.eModel.modelView:SetSubModelVisible(rendererName, true)
		end
	end

	self.dyeDisableRenderers = {}
end

function ClientModelTransmogComponent:onParmonDyeRefreshFinished(refreshVersion)
	if refreshVersion ~= self.parmonDyeRefreshVersion then
		return
	end

	ClientEffectUtils.executeWaitTransmogCallbackList(self)
end

function ClientModelTransmogComponent:EVENT_OnModelRefreshed()
	self:refreshParmonDye()
end

function ClientModelTransmogComponent:refreshDyeMaterialEffect(dyeConfig, shinyStyle)
	if dyeConfig.materialEffect then
		local shaderView = self.eModel.shaderView
		local prefabResId = self:getConfigData().prefabResID
		local platformName = IS_MOBILE and "Mobile" or "PC"

		for renderName, info in pairs(dyeConfig.materialEffect) do
			local materialEffectData = info[platformName]

			if materialEffectData then
				local materialEffect = string.format("%s_%s_shiny_%d", prefabResId, renderName, shinyStyle)

				ShaderView.AddMaterialEffectInfo(materialEffect, materialEffectData)
				shaderView:ApplyMaterialEffectByFilterName(materialEffect, renderName, false, true)
			end
		end

		self.lastDyeMaterialEffect = {
			dyeConfig.materialEffect,
			shinyStyle
		}
	else
		self.lastDyeMaterialEffect = nil
	end
end

function ClientModelTransmogComponent:refreshParmonDye()
	if not self.eModel then
		return
	end

	local shaderView = self.eModel.shaderView

	if IsNil(shaderView) then
		return
	end

	self.parmonDyeRefreshVersion = (self.parmonDyeRefreshVersion or 0) + 1

	local refreshVersion = self.parmonDyeRefreshVersion

	self.isWaitTransmogCallback = true

	local petInfo = self:getTransmogPetInfo()
	local shinyStyle = self.shinyStyle or petInfo and petInfo.shinyStyle or 0

	if shinyStyle == 0 then
		local configData = self:getConfigData()

		shinyStyle = configData.forceShinyStyle
	end

	local dyeConfig = self:getDyeConfig()

	if not dyeConfig then
		self:playShinnyPreset()

		if self.modelSwitchSyncEnts then
			for entity, _ in pairs(self.modelSwitchSyncEnts) do
				entity:refreshParmonDye()
			end
		end

		self:onParmonDyeRefreshFinished(refreshVersion)

		return
	end

	local allRendererNames = shaderView:GetAllRendererNames()
	local count = allRendererNames.Count
	local dyeList = {}

	if self.dyeDisableRenderers then
		for _, name in pairs(self.dyeDisableRenderers) do
			self.eModel.modelView:SetSubModelVisible(name, true)
		end
	end

	local shinyStyle = self.shinyStyle or petInfo and petInfo.shinyStyle or 0

	if shinyStyle == 0 then
		local configData = self:getConfigData()

		shinyStyle = configData.forceShinyStyle or shinyStyle
	end

	self.dyeDisableRenderers = {}

	for i = 0, count - 1 do
		local name = allRendererNames[i]
		local matPresetList = dyeConfig[name]

		if matPresetList then
			local renderPresetList = {}

			if matPresetList.Enable == false then
				table.insert(self.dyeDisableRenderers, name)
				self.eModel.modelView:SetSubModelVisible(name, false)
			else
				for matName, presetList in pairs(matPresetList) do
					if type(presetList) == "string" then
						presetList = {
							presetList
						}
					end

					for _, presetName in pairs(presetList) do
						table.insert(renderPresetList, {
							matName,
							presetName
						})
					end
				end

				if next(renderPresetList) then
					dyeList[name] = renderPresetList
				end
			end
		end
	end

	if self.lastDyeMaterialEffect then
		local prefabResId = self:getConfigData().prefabResID
		local platformName = IS_MOBILE and "Mobile" or "PC"
		local lastMaterialEffect, lastShinyStyle = unpack(self.lastDyeMaterialEffect)

		for renderName, info in pairs(lastMaterialEffect) do
			local materialEffectData = info[platformName]

			if materialEffectData then
				local lastMaterialEffect = string.format("%s_%s_shiny_%d", prefabResId, renderName, lastShinyStyle)

				shaderView:RemoveMaterialEffectByFilterName(lastMaterialEffect, renderName)
			end
		end
	end

	local hasDyeList = next(dyeList) ~= nil

	if (hasDyeList or dyeConfig.materialEffect) and IS_MOBILE then
		shaderView:SetEnableHLod(false)
	end

	self:playShinnyPreset()

	if hasDyeList then
		shaderView:SetBaseMaterialByPreset(dyeList, function()
			self:refreshDyeMaterialEffect(dyeConfig, shinyStyle)
			self:onParmonDyeRefreshFinished(refreshVersion)
		end)
	else
		shaderView:SetBaseMaterialByPreset(dyeList)
		self:refreshDyeMaterialEffect(dyeConfig, shinyStyle)
		self:onParmonDyeRefreshFinished(refreshVersion)
	end

	if self.modelSwitchSyncEnts then
		for entity, _ in pairs(self.modelSwitchSyncEnts) do
			entity:refreshParmonDye()
		end
	end
end

function ClientModelTransmogComponent:isAllHolesGolden(effective)
	local petInfo = self:getTransmogPetInfo()
	local scheme = effective or petInfo and (petInfo.selectTransmogScheme or PetTransmogUtils.getSelectedScheme(petInfo))

	if not scheme or not scheme.holeIds then
		return false
	end

	if #scheme.holeIds < 5 then
		return false
	end

	for _, holeId in pairs(scheme.holeIds) do
		local cfg = PetTransmogUtils.getSlotConfig(holeId)
		local quality = cfg and cfg.quality or 0

		if quality ~= 5 then
			return false
		end
	end

	return true
end

function ClientModelTransmogComponent:getSuitColorId(effective)
	if not self:isAllHolesGolden(effective) then
		return nil
	end

	local petInfo = self:getTransmogPetInfo()

	if not petInfo then
		return
	end

	local selectTransmogScheme = petInfo.selectTransmogScheme or PetTransmogUtils.getSelectedScheme(petInfo)

	if not selectTransmogScheme then
		return
	end

	local holeIds = selectTransmogScheme.holeIds

	if not holeIds then
		return nil
	end

	local colorSlotId = selectTransmogScheme.holeIds[Const.PetTransmogSlotType.Color]
	local colorStr = (PetTransmogSoltData[colorSlotId] or EMPTY_TABLE).resources

	return colorStr
end

function ClientModelTransmogComponent:getTransmogSuitId()
	return AbilityUtils.getSuitId(self) or 0
end

function ClientModelTransmogComponent:replaceTransmogReplaceEff(effective)
	self:removeReplaceEffKeys(self.colorReplaceEffKey)
	self:removeReplaceEffKeys(self.suitReplaceEffKey)

	local petInfo = self:getTransmogPetInfo()

	if not petInfo then
		return
	end

	local selectTransmogScheme = effective or petInfo.selectTransmogScheme or PetTransmogUtils.getSelectedScheme(petInfo)

	if not selectTransmogScheme then
		return
	end

	local holeIds = selectTransmogScheme.holeIds

	if not holeIds then
		return nil
	end

	local templetId = math.floor(self:getConfigData().petPrototypeId / 100)
	local effReplaceData = EffReplaceData[templetId]

	if not effReplaceData then
		return
	end

	local colorSlotId = selectTransmogScheme.holeIds[Const.PetTransmogSlotType.Color]
	local colorStr = (PetTransmogSoltData[colorSlotId] or EMPTY_TABLE).resources
	local colorKey, colorTable, suitKey, suitTable

	if colorStr and self:isAllHolesGolden(effective) then
		colorKey = string.format("%d_Color_%s", templetId, colorStr)
		colorTable = effReplaceData[colorKey]
	end

	if colorKey ~= self.colorReplaceEffKey then
		self:addReplaceEffKeys(colorKey, colorTable)
	end

	self.colorReplaceEffKey = colorKey

	local suitId = AbilityUtils.getSuitId(self, effective)

	if suitId then
		suitKey = string.format("%d_Suit_%02d", templetId, suitId)
		suitTable = effReplaceData[suitKey]
	end

	if suitKey ~= self.suitReplaceEffKey then
		self:addReplaceEffKeys(suitKey, suitTable)
	end

	self.suitReplaceEffKey = suitKey
end

function ClientModelTransmogComponent:onTransmogAnimatorReady()
	if not self.transmogData then
		return
	end

	if not self.eModel then
		return
	end

	local modelView = self.eModel.modelModelView

	if IsNil(modelView) or IsNil(modelView.partModel) then
		return
	end

	self.transmogEffectIds = self.transmogEffectIds or {}

	for partId, info in pairs(self.transmogData) do
		modelView.partModel:SetRenderVisibleBySuffix(partId, LIGHT_SUFFIX, info.isLight or false)
	end
end

function ClientModelTransmogComponent:playTransmogEffects()
	self:stopAllTransmogEffects()

	if not self.transmogData or Utils.isPuppet(self) and ToBool(self.srcCastingCombatContextId) then
		return
	end

	self.transmogEffectIds = self.transmogEffectIds or {}

	for _, info in pairs(self.transmogData) do
		if info.effects then
			for _, effectInfo in ipairs(info.effects) do
				local extInfo = {
					duration = -1,
					mountType = EffectConst.MountType.Model,
					followType = EffectConst.FollowType.FollowPosRot
				}

				if effectInfo.effectBone and effectInfo.effectBone ~= "" then
					if ClientEffectUtils.getBestFitCommonMount(self, effectInfo.effectBone) then
						extInfo.commonMount = effectInfo.effectBone
					else
						self.logger:debug("transmog, addEffect bone", effectInfo.effectBone)

						extInfo.bone = effectInfo.effectBone
					end
				end

				local effId = self:playEffectRaw(effectInfo.effectResId, extInfo)

				if effId and effId ~= 0 then
					self.transmogEffectIds[#self.transmogEffectIds + 1] = effId
				end
			end
		end
	end

	if Utils.isTable(self.transmogShinyEffects) then
		for _, effectInf0 in ipairs(self.transmogShinyEffects) do
			local effectName, effectBone = unpack(effectInf0)
			local extInfo = {
				duration = -1,
				mountType = EffectConst.MountType.Model,
				followType = EffectConst.FollowType.FollowPosRot
			}

			if effectBone and effectBone ~= "" then
				if ClientEffectUtils.getBestFitCommonMount(self, effectBone) then
					extInfo.commonMount = effectBone
				else
					extInfo.bone = effectBone
				end
			end

			local effId = self:playEffectRaw(effectName, extInfo)

			if effId and effId ~= 0 then
				table.insert(self.transmogShinyEffectIns, effId)
			end
		end
	end
end

function ClientModelTransmogComponent:EVENT_OnAnimatorReady()
	self:onTransmogAnimatorReady()
	self:refreshTransmogStateEffects(self.motionState, true)
end

function ClientModelTransmogComponent:EVENT_OnCharacterStateChange(oldState, newState)
	self:refreshTransmogStateEffects(newState)
end

function ClientModelTransmogComponent:stopAllTransmogEffects()
	if self.transmogEffectIds then
		for _, effId in pairs(self.transmogEffectIds) do
			self:stopEffectById(effId)
		end

		self.transmogEffectIds = nil
	end

	for _, insId in ipairs(self.transmogShinyEffectIns) do
		self:stopEffectById(insId)
	end

	self.transmogShinyEffectIns = {}
end

function ClientModelTransmogComponent:preDestroy()
	self:stopAllTransmogStateEffects()
end

function ClientModelTransmogComponent:destroy()
	self:unregisterTransmogStateRPCStates()
end

function ClientModelTransmogComponent:testTransmog()
	local data = {
		[AppearancePointEnum.Hat] = {
			resId = "$E_P_Parmon_Suit_10213_Body_01_A_01.prefab",
			isLight = true,
			effects = {
				{
					effectBone = "Bone Wing",
					effectResId = "$Eff_Parmon_Suit_10213_Hat_04_B_01.prefab"
				}
			}
		},
		[AppearancePointEnum.Coat] = {
			resId = "$E_P_Parmon_Suit_10213_Hat_01_A_01.prefab"
		},
		[AppearancePointEnum.Wing] = {
			resId = "$E_P_Parmon_Suit_10213_Wing_01_A_01.prefab"
		}
	}

	self:setTransmogData(data, {
		{
			"$Eff_Parmon_Suit_10213_05_C_01_All.prefab",
			"CM_Common_Buff"
		}
	}, nil, nil)
end

return ClientModelTransmogComponent
