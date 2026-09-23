-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\ClientSimpleVirtualPlayer.lua

local Class = require("Core.Framework.Class")
local ClientSimpleVirtualEntity = require("Entities.ClientSimpleVirtualEntity")
local ClientConst = require("Const.ClientConst")
local Utils = require("Common.Utils.Utils")
local ClientModelUtils = require("Utils.ClientModelUtils")
local AppearanceEffectUtils = require("Utils.AppearanceEffectUtils")
local ClientAppearanceComponent = require("Entities.SpaceEntities.CommonComponent.ClientAppearanceComponent")
local AvatarData = require("Data.avatar_data")
local AvatarPresetData = require("Data.avatar_preset_data")
local AppearanceData = require("Data.appearance_data")
local AppearanceSuitData = require("Data.appearance_suit_data")
local AppearancePointEnum = require("Data.appearance_point_enum")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local ClientSimpleVirtualPlayer = Class.Class("ClientSimpleVirtualPlayer", ClientSimpleVirtualEntity)
local ClientVirtualPlayerComponents = {
	ClientAppearanceComponent
}

Class.AddComponents(ClientSimpleVirtualPlayer, ClientVirtualPlayerComponents)

local function getAppearanceData(configId)
	return AppearanceData[configId] or {}
end

function ClientSimpleVirtualPlayer:init(dict)
	ClientSimpleVirtualPlayer.super.init(self, dict)

	if dict then
		self.copyEntity = dict.copyEntity
		self.isAppearancePreview = dict.isAppearancePreview == true
		self.templateId = self.copyEntity and self.copyEntity.templateId or dict.templateId
		self.avatarPresetKey = self.copyEntity and self.copyEntity.avatarPresetKey or dict.avatarPresetKey
		self.avatarConfig = self.copyEntity and self.copyEntity.avatarConfig or dict.avatarConfig
		self.curShow = self.copyEntity and self.copyEntity.curShow or dict.curShow
		self.syncLoad = dict.syncLoad
		self.needFacialHighLight = dict.needFacialHighLight
		self.useDefaultParts = dict.useDefaultParts
		self.customShow = {}

		if self.copyEntity and self.copyEntity.curShow and self.copyEntity.curShow.customShow then
			for partId, configId in pairs(self.copyEntity.curShow.customShow) do
				self.customShow[partId] = configId
			end
		end

		self.customShowPreview = {}
	end
end

function ClientSimpleVirtualPlayer:postInitializeComponents()
	ClientSimpleVirtualPlayer.super.postInitializeComponents(self)

	self.eModel.isMainAuthority = true
end

function ClientSimpleVirtualPlayer:onModelRefreshed()
	ClientSimpleVirtualPlayer.super.onModelRefreshed(self)
	pgUtils.DisablePlayerLight(self.eModel)
end

function ClientSimpleVirtualPlayer:onAnimatorReady()
	ClientSimpleVirtualPlayer.super.onAnimatorReady(self)

	local modelView = self.eModel.modelModelView

	self:addTimer(0.1, function()
		modelView:RefreshDecal()
	end)
end

function ClientSimpleVirtualPlayer:getConfigData()
	if self.templateId then
		return AvatarData[self.templateId] or {}
	end

	return {}
end

function ClientSimpleVirtualPlayer:refreshAppearance()
	if not self.eModel then
		return
	end

	self.appearanceEffectInfo = {}

	local configData = self:getConfigData()
	local modelView = self.eModel.modelModelView

	modelView.isAppearancePreview = self.isAppearancePreview

	if self.copyEntity then
		modelView.modelInfo:CopyFrom(self.copyEntity.eModel.modelModelView.modelInfo)
		AppearanceEffectUtils.copyAppearanceInfo(self, self.copyEntity)
	elseif self.useDefaultParts then
		modelView.modelInfo:ParseAvatarRuntimeData(self.avatarPresetKey)
		modelView.modelInfo:ParseToModelInfo()

		modelView.modelInfo.physiqueModelInfo.modelInfoPathID = configData.modelInfoRef or ""

		ClientModelUtils.setupDefaultHairRes(modelView.modelInfo, self.avatarPresetKey)

		local defaultSuitId = pg.game.avatar:getAvatarPresetData(self.avatarPresetKey).defaultSuit
		local clothesIdList = AppearanceSuitData[defaultSuitId].appearanceList or {}

		for _, id in ipairs(clothesIdList) do
			local clothesData = AppearanceData[id]

			if clothesData then
				AppearanceEffectUtils.setPartAppearance(self, id, true)
				modelView.modelInfo.partModelInfo:ModifyPartItem(clothesData.res, Utils.deepCopyTable(clothesData.points))
			end
		end
	else
		ClientModelUtils.initModelInfoByCustomData(self, self.avatarPresetKey, configData)
	end

	if self.needFacialHighLight then
		local GameConst = CS.FunPlus.WorldX.Const.GameConst
		local highLightInfo = AvatarUtils.getModelResPart(self, self.avatarPresetKey, GameConst.PART_FACE_HIGH_LIGHT)
		local highLightResId = highLightInfo and highLightInfo.resId or ""

		if highLightResId ~= "" then
			modelView.modelInfo.partModelInfo:ModifyPartItem(highLightResId, {
				GameConst.PART_FACE_HIGH_LIGHT
			})
		end
	end

	modelView.modelInfo.physiqueModelInfo.isAlwaysAnimate = true

	ClientModelUtils.applyAnimController(self, self.eModel, configData)
	self.eModel:AddShadowComp(ClientConst.ShadowPriority.Appearance)

	modelView.forceLoadPart = true

	ClientModelUtils.refreshModels(self, modelView)

	modelView.forceLoadPart = false

	local bodySize = modelView.modelInfo:GetBodySize()

	self:setModelScale(ClientConst.MODEL_SCALE_KEY.AVATAR, bodySize)
end

function ClientSimpleVirtualPlayer:getAppearanceConfigId(slotId, applyPreview, ignorePreviewSetToZero)
	local configId = self.curShow.customShow[slotId]

	if self.customShow and self.customShow[slotId] ~= nil then
		configId = self.customShow[slotId]
	end

	if applyPreview and self.customShowPreview and next(self.customShowPreview) then
		if self.customShowPreview[slotId] ~= nil then
			configId = self.customShowPreview[slotId]
		elseif not ignorePreviewSetToZero then
			configId = 0
		end
	end

	return configId
end

function ClientSimpleVirtualPlayer:syncToServer()
	local actions = {}

	for partId = AppearancePointEnum.Coat, AppearancePointEnum.Shoes do
		local oldClothesId = pg.me.curShow.customShow[partId]
		local newClothesId = self.customShow[partId]

		if newClothesId ~= nil and newClothesId ~= oldClothesId then
			if newClothesId == 0 then
				local isExist = false

				for _, action in ipairs(actions) do
					if action[1] == oldClothesId then
						isExist = true
					end
				end

				if not isExist then
					table.insert(actions, {
						oldClothesId,
						false,
						partId
					})
				end
			else
				local isExist = false

				for _, action in ipairs(actions) do
					if action[1] == newClothesId then
						isExist = true
					end
				end

				if not isExist then
					table.insert(actions, {
						newClothesId,
						true,
						partId
					})
				end
			end
		end
	end

	for partId = AppearancePointEnum.Fringe, AppearancePointEnum.Plait do
		local oldConfigId = pg.me.curShow.customShow[partId]
		local newConfigId = self.customShow[partId]

		if newConfigId ~= nil and newConfigId ~= oldConfigId then
			if newConfigId == 0 then
				table.insert(actions, {
					oldConfigId,
					false,
					partId
				})
			else
				table.insert(actions, {
					newConfigId,
					true,
					partId
				})
			end
		end
	end

	local jewelryEquipActions = {}

	for partId = AppearancePointEnum.Jewelry1, AppearancePointEnum.Jewelry10 do
		local oldConfigId = pg.me.curShow.customShow[partId]
		local newConfigId = self.customShow[partId]

		if newConfigId ~= nil and newConfigId ~= oldConfigId then
			if oldConfigId and oldConfigId ~= 0 then
				table.insert(actions, {
					oldConfigId,
					false,
					partId
				})
			end

			if newConfigId ~= 0 then
				table.insert(jewelryEquipActions, {
					newConfigId,
					true,
					partId
				})
			end
		end
	end

	for _, action in ipairs(jewelryEquipActions) do
		table.insert(actions, action)
	end

	for partId = AppearancePointEnum.FootPrint, AppearancePointEnum.Effect do
		local oldConfigId = pg.me.curShow.customShow[partId]
		local newConfigId = self.customShow[partId]

		if newConfigId and newConfigId ~= oldConfigId then
			if newConfigId == 0 then
				table.insert(actions, {
					oldConfigId,
					false,
					partId
				})
			else
				table.insert(actions, {
					newConfigId,
					true,
					partId
				})
			end
		end
	end

	if not Utils.isEmptyTable(actions) then
		pg.me:serverMsg("RPC_CS_MultiSetAppearanceShow", actions)
	end
end

function ClientSimpleVirtualPlayer:setCustomShow(configId, isApply, slotId)
	if slotId then
		self:setAppearanceSimple(self.customShow, configId, isApply, slotId)
		self:setAppearanceSimple(self.customShowPreview, configId, isApply, slotId)
	else
		self:setAppearanceWithOccupy(self.customShow, configId, isApply)
		self:setAppearanceWithOccupy(self.customShowPreview, configId, isApply)
	end
end

function ClientSimpleVirtualPlayer:setCustomShowPreview(configId, isApply, slotId)
	if slotId then
		self:setAppearanceSimple(self.customShowPreview, configId, isApply, slotId)
	else
		self:setAppearanceWithOccupyForPreview(configId, isApply)
	end
end

function ClientSimpleVirtualPlayer:setAppearanceWithOccupy(refTable, configId, isApply)
	local data = getAppearanceData(configId)

	if isApply then
		local clearedOld = {}

		for _, slotId in ipairs(data.points) do
			local oldConfigId = refTable[slotId]

			if oldConfigId and oldConfigId ~= 0 and not clearedOld[oldConfigId] then
				clearedOld[oldConfigId] = true

				local oldData = getAppearanceData(oldConfigId)

				for _, sId in ipairs(oldData.points) do
					refTable[sId] = 0
				end
			end

			refTable[slotId] = configId
		end
	else
		for _, slotId in ipairs(data.points) do
			if refTable[slotId] == configId then
				refTable[slotId] = 0
			end
		end
	end
end

function ClientSimpleVirtualPlayer:setAppearanceWithOccupyForPreview(configId, isApply)
	local data = getAppearanceData(configId)
	local refTable = self.customShowPreview

	if not isApply then
		for _, slotId in ipairs(data.points) do
			if refTable[slotId] == configId then
				refTable[slotId] = 0
			end
		end

		return
	end

	local clearedOld = {}

	for _, slotId in ipairs(data.points) do
		local oldConfigId = refTable[slotId]

		if oldConfigId == nil and self.customShow then
			oldConfigId = self.customShow[slotId]
		end

		if oldConfigId and oldConfigId ~= 0 and not clearedOld[oldConfigId] then
			clearedOld[oldConfigId] = true

			local oldData = getAppearanceData(oldConfigId)

			for _, sId in ipairs(oldData.points) do
				refTable[sId] = 0
			end
		end

		refTable[slotId] = configId
	end
end

function ClientSimpleVirtualPlayer:setAppearanceSimple(refTable, configId, isApply, slotId)
	if isApply then
		refTable[slotId] = configId
	elseif refTable[slotId] == configId then
		refTable[slotId] = 0
	end
end

function ClientSimpleVirtualPlayer:cancelAppearanceBySlotWithOccupy(refTable, slotId, force)
	local clearValue = force and 0 or nil
	local configId = refTable[slotId]

	if not configId or configId == 0 then
		refTable[slotId] = clearValue

		return
	end

	local data = getAppearanceData(configId)

	if data.points and #data.points > 0 then
		for _, sId in ipairs(data.points) do
			if refTable[sId] == configId then
				refTable[sId] = clearValue
			end
		end
	else
		refTable[slotId] = clearValue
	end
end

function ClientSimpleVirtualPlayer:cancelCustomShowPreview(slotId, force)
	self:cancelAppearanceBySlotWithOccupy(self.customShowPreview, slotId, force)
end

function ClientSimpleVirtualPlayer:cancelCustomShow(slotId, force)
	self:cancelAppearanceBySlotWithOccupy(self.customShow, slotId, force)
	self:cancelAppearanceBySlotWithOccupy(self.customShowPreview, slotId, force)
end

return ClientSimpleVirtualPlayer
