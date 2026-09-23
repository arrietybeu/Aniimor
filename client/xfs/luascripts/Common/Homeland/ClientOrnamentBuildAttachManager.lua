-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Homeland\\ClientOrnamentBuildAttachManager.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local HomeBuildData = require("Data.home_build_data")
local OrnamentBuildAttachManager = require("Common.Homeland.OrnamentBuildAttachManager")
local Utils = require("Common.Utils.Utils")
local AttachHelper = require("Common.Homeland.OrnamentBuild.AttachHelper")
local LinkHelper = require("Common.Homeland.OrnamentBuild.LinkHelper")
local BuildConst = require("Common.Homeland.OrnamentBuild.BuildConst")
local HomeObjectData = require("Data.home_object_data")
local ClientConst = require("Const.ClientConst")
local ClientOrnamentBuildAttachManager = Class.LightClass("ClientOrnamentBuildAttachManager", OrnamentBuildAttachManager)

ClientOrnamentBuildAttachManager.ATTACH_GRID_ID_BASE = 1
ClientOrnamentBuildAttachManager.LINK_POINT_ADD_EFFECT_RES_ID = "$Eff_Env_Home_Point_Add.prefab"
ClientOrnamentBuildAttachManager.LINK_POINT_ALPHY_EFFECT_RES_ID = "$Eff_Env_Home_Point_Alphy.prefab"
ClientOrnamentBuildAttachManager.LINK_POINT_EFFECT_FORCE_LOD_LEVEL = 0
ClientOrnamentBuildAttachManager.LINK_POINT_POSITION_EPSILON_SQR = 1e-06
ClientOrnamentBuildAttachManager.LINK_POINT_DISPLAY_RANGE_SQR = 1.3

function ClientOrnamentBuildAttachManager:ctor()
	ClientOrnamentBuildAttachManager.super.ctor(self)

	self.isClient = true
	self.attachBoundCheckPositionCache = Vector3.ForceNew(0, 0, 0)
	self.tempAttachInfo = self:createBuildAttachInfo()
	self.bestAttachInfo = self:createBuildAttachInfo()
	self.tempLinkInfo = self:createBuildAttachInfo()
	self.bestLinkInfo = self:createBuildAttachInfo()
	self.defaultBuildConfig = {}
	self.virtualIdMap = {}
	self.enableEditorAttach = true
	self.attachGridShownCount = 0
	self.linkPointSourcePositions = {}
	self.linkPointTargetPositions = {}
	self.linkPointSourcePositionCount = 0
	self.linkPointTargetPositionCount = 0
	self.linkPointDisplayAddPositions = {}
	self.linkPointDisplayAlphyPositions = {}
	self.linkPointAddEffectState = self:createLinkPointEffectState()
	self.linkPointAlphyEffectState = self:createLinkPointEffectState()

	function self.linkPointPairCollectorFunc(sourcePosition, targetPosition)
		self:collectLinkPointPair(sourcePosition, targetPosition)
	end

	function self.ornamentQueryAttachFilterFunc(ornamentId, fastInfo)
		return self:innerOrnamentQueryAttachFilterFunc(ornamentId, fastInfo)
	end

	function self.ornamentQueryLinkFilterFunc(ornamentId, fastInfo)
		return self:innerOrnamentQueryLinkFilterFunc(ornamentId, fastInfo)
	end

	function self.ornamentQueryLinkSlowFilterFunc(ornamentId, fastInfo)
		return self:innerOrnamentQueryLinkSlowFilterFunc(ornamentId, fastInfo)
	end
end

function ClientOrnamentBuildAttachManager:createBuildAttachInfo()
	return {
		attachPosition = Vector3.ForceNew(0, 0, 0),
		moveDelta = Vector3.ForceNew(0, 0, 0)
	}
end

function ClientOrnamentBuildAttachManager:resetBuildAttachInfo(info)
	local position = info.attachPosition
	local moveDelta = info.moveDelta

	table.clear(info)

	info.attachPosition = position
	info.moveDelta = moveDelta
end

function ClientOrnamentBuildAttachManager:copyBuildAttachInfo(target, source)
	local targetPosition = target.attachPosition
	local targetMoveDelta = target.moveDelta

	table.clear(target)

	target.attachPosition = targetPosition
	target.moveDelta = targetMoveDelta

	targetPosition:Copy(source.attachPosition)
	targetMoveDelta:Copy(source.moveDelta)

	for key, value in pairs(source) do
		if key ~= "attachPosition" and key ~= "moveDelta" then
			target[key] = value
		end
	end
end

function ClientOrnamentBuildAttachManager:clearEditorInfo()
	self:clearLinkDebugInfo()
	self:clearAttachGrids()
	self:clearLinkPointEffects()
	table.clear(self.virtualIdMap)
	table.clear(self.tempBuildExtraData)
	table.clear(self.tempDynamicBuildExtraData)
	self:resetBuildAttachInfo(self.tempAttachInfo)
	self:resetBuildAttachInfo(self.bestAttachInfo)
	self:resetBuildAttachInfo(self.tempLinkInfo)
	self:resetBuildAttachInfo(self.bestLinkInfo)
end

function ClientOrnamentBuildAttachManager:setEnableBuildAttach(enable)
	self.enableEditorAttach = enable

	if not enable then
		self:clearLinkPointEffects()
	end
end

function ClientOrnamentBuildAttachManager:initBuildAttachEnable()
	self.enableEditorAttach = pg.game.home:getHomeEditorPlayerSetting(ClientConst.HomelandEditorSetting.AutoAttach, true)
end

function ClientOrnamentBuildAttachManager:getEditGroupMainEntity(entities)
	local selectedOrnamentIds = {}

	for _, entity in ipairs(entities or EMPTY_TABLE) do
		if entity and entity.ornamentId then
			selectedOrnamentIds[entity.ornamentId] = true
		end
	end

	local rootEntity

	for _, entity in ipairs(entities or EMPTY_TABLE) do
		if entity and entity.ornamentId then
			local attachInfo = self.attachData and self.attachData[entity.ornamentId]

			if not attachInfo or not selectedOrnamentIds[attachInfo.parentId] then
				if rootEntity then
					return nil
				end

				rootEntity = entity
			end
		end
	end

	return rootEntity
end

function ClientOrnamentBuildAttachManager:setEditVirtualEntities(entities)
	self:initBuildAttachEnable()
	self:clearEditorInfo()

	for _, entity in pairs(entities) do
		if entity.ornamentId and entity.originEntity then
			self.virtualIdMap[entity.originEntity.ornamentId] = entity.ornamentId
		end
	end

	self.tempBuildExtraData = {
		attachData = {},
		linkData = {}
	}
	self.tempDynamicBuildExtraData = {
		attachData = {},
		linkData = {}
	}

	for ornamentId, attachInfo in pairs(self.attachData) do
		local virtualId = self.virtualIdMap[ornamentId]
		local virtualParentId = self.virtualIdMap[attachInfo.parentId]

		if virtualId and virtualParentId then
			self.tempBuildExtraData.attachData[virtualId] = {
				parentId = virtualParentId,
				slotId = attachInfo.slotId
			}
		elseif virtualId then
			self.tempDynamicBuildExtraData.attachData[virtualId] = {
				parentId = attachInfo.parentId,
				slotId = attachInfo.slotId
			}
		end
	end
end

function ClientOrnamentBuildAttachManager:recordEditorExtraData(buildExtraData)
	buildExtraData.attachData = {}
	buildExtraData.linkData = {}

	if self.tempDynamicBuildExtraData then
		for ornamentId, attachInfo in pairs(self.tempDynamicBuildExtraData.attachData) do
			buildExtraData.attachData[ornamentId] = attachInfo
		end

		for ornamentId, linkInfo in pairs(self.tempDynamicBuildExtraData.linkData) do
			buildExtraData.linkData[ornamentId] = linkInfo
		end
	end
end

function ClientOrnamentBuildAttachManager:restoreEditorExtraData(buildExtraData)
	if not buildExtraData then
		return
	end

	if self.tempDynamicBuildExtraData then
		table.clear(self.tempDynamicBuildExtraData.attachData)
		table.clear(self.tempDynamicBuildExtraData.linkData)

		for ornamentId, attachInfo in pairs(buildExtraData.attachData) do
			self.tempDynamicBuildExtraData.attachData[ornamentId] = attachInfo
		end

		for ornamentId, linkInfo in pairs(buildExtraData.linkData) do
			self.tempDynamicBuildExtraData.linkData[ornamentId] = linkInfo
		end
	end
end

function ClientOrnamentBuildAttachManager:getEditorBuildExtraData()
	local buildExtraData = {
		attachData = {},
		linkData = {}
	}

	if self.tempBuildExtraData then
		for virtualId, attachInfo in pairs(self.tempBuildExtraData.attachData) do
			buildExtraData.attachData[virtualId] = attachInfo
		end

		for virtualId, linkInfo in pairs(self.tempBuildExtraData.linkData) do
			buildExtraData.linkData[virtualId] = linkInfo
		end
	end

	if self.tempDynamicBuildExtraData then
		for virtualId, attachInfo in pairs(self.tempDynamicBuildExtraData.attachData) do
			buildExtraData.attachData[virtualId] = attachInfo
		end

		for virtualId, linkInfo in pairs(self.tempDynamicBuildExtraData.linkData) do
			buildExtraData.linkData[virtualId] = linkInfo
		end
	end

	for ornamentId, attachInfo in pairs(self.attachData) do
		local virtualId = self.virtualIdMap[ornamentId]
		local virtualParentId = self.virtualIdMap[attachInfo.parentId]

		if virtualId and virtualParentId then
			-- block empty
		elseif virtualId and not buildExtraData.attachData[virtualId] then
			buildExtraData.attachData[virtualId] = {
				slotId = 0,
				parentId = 0
			}
		end
	end

	return buildExtraData
end

function ClientOrnamentBuildAttachManager:clearEditVirtualEntities()
	self.tempBuildExtraData = nil
	self.tempDynamicBuildExtraData = nil
end

function ClientOrnamentBuildAttachManager:calcAttachPlaneTransform(attachPlaneInfo, targetLocalPosition, targetLocalRotation, targetScale)
	local planeOffset = Vector3(0, 0, 0)

	if attachPlaneInfo.position then
		planeOffset.x = attachPlaneInfo.position[1]
		planeOffset.y = attachPlaneInfo.position[2]
		planeOffset.z = attachPlaneInfo.position[3]
	end

	planeOffset:MulVector3(targetScale)

	local planePosition = targetLocalPosition + targetLocalRotation * planeOffset
	local planeRotation = AttachHelper.getPlaneRotation(attachPlaneInfo.type, targetLocalRotation, attachPlaneInfo.normal)

	return planePosition, planeRotation
end

function ClientOrnamentBuildAttachManager:innerTryGetBestAttachInfo(editor, srcEnt, localPosition, localRotation, scale, targetEnt, targetLocalPosition, targetLocalRotation, targetScale, outAttachInfo, buildExtraConfig)
	local srcTemplateId = srcEnt.homeTemplateId
	local targetTemplateId = targetEnt.homeTemplateId
	local srcHomeBuildInfo = HomeBuildData[srcTemplateId]
	local targetHomeBuildInfo = HomeBuildData[targetTemplateId]

	if not srcHomeBuildInfo or not targetHomeBuildInfo then
		return false
	end

	if not srcHomeBuildInfo.attachRoots or not targetHomeBuildInfo.attachPlanes then
		return false
	end

	local bestAttachDistanceSqr

	Vector3.enableCreateFromCache()

	for slotId, attachRootInfo in ipairs(srcHomeBuildInfo.attachRoots) do
		local rootOffest = Vector3(0, 0, 0)

		if attachRootInfo.position then
			rootOffest.x = attachRootInfo.position[1]
			rootOffest.y = attachRootInfo.position[2]
			rootOffest.z = attachRootInfo.position[3]
		end

		rootOffest:MulVector3(scale)

		local attachRootPosition = localPosition + localRotation * rootOffest

		for _, attachPlaneInfo in ipairs(targetHomeBuildInfo.attachPlanes) do
			if AttachHelper.checkAttachTypeMatch(attachRootInfo.type, attachPlaneInfo.type) then
				local planePosition, planeRotation = self:calcAttachPlaneTransform(attachPlaneInfo, targetLocalPosition, targetLocalRotation, targetScale)
				local valid, attachPosition, attachRotation, moveDelta = AttachHelper.tryAttachPlane(attachPlaneInfo.type, planePosition, planeRotation, attachPlaneInfo.width, attachPlaneInfo.height, attachRootPosition, localRotation, buildExtraConfig)

				if valid then
					local curAttachDistanceSqr = moveDelta:SqrMagnitude()

					if not bestAttachDistanceSqr or curAttachDistanceSqr < bestAttachDistanceSqr then
						bestAttachDistanceSqr = curAttachDistanceSqr

						outAttachInfo.attachPosition:Copy(attachPosition)
						outAttachInfo.moveDelta:Copy(moveDelta)

						outAttachInfo.attachRotation = attachRotation
						outAttachInfo.attachSlotId = attachRootInfo.type
						outAttachInfo.parentId = targetEnt.ornamentId
						outAttachInfo.attachPriority = curAttachDistanceSqr
					end
				end
			end
		end
	end

	Vector3.disableCreateFromCache()

	return bestAttachDistanceSqr ~= nil
end

function ClientOrnamentBuildAttachManager:tryGetBestAttachInfo(editor, srcEnt, localPosition, localRotation, scale, targetFastFindInfo, outAttachInfo, buildExtraConfig)
	local targetEnt = targetFastFindInfo.extraInfo.ent

	if not targetEnt then
		return false
	end

	if not HomeLandUtils.checkHomeObjectCanBeAttach(targetEnt.homeTemplateId) then
		return false
	end

	buildExtraConfig = buildExtraConfig or self.defaultBuildConfig

	local targetScale = targetFastFindInfo.extraInfo.scale or Vector3.constOne
	local canAttach = self:innerTryGetBestAttachInfo(editor, srcEnt, localPosition, localRotation, scale, targetEnt, targetFastFindInfo.position, targetFastFindInfo.rotation, targetScale, outAttachInfo, buildExtraConfig)

	if canAttach then
		local ornamentAttachPosition = Vector3.AddByCache(outAttachInfo.moveDelta, localPosition, self.attachBoundCheckPositionCache)

		if not editor:checkBoundInArea(ornamentAttachPosition, outAttachInfo.attachRotation, srcEnt:getBoundSize()) then
			return false
		end
	end

	return canAttach
end

function ClientOrnamentBuildAttachManager:tryGetBestLinkInfo(editor, srcEnt, localPosition, localRotation, targetFastFindInfo, outlinkInfo, buildAttachCandidates, buildExtraConfig, linkPointCollector)
	local targetEnt = targetFastFindInfo.extraInfo.ent

	if not targetEnt then
		return false
	end

	buildExtraConfig = buildExtraConfig or self.defaultBuildConfig

	local canLink, _, _, linkSocketIndex, linkSlotDir = LinkHelper.tryLinkEntity(editor, srcEnt, localPosition, localRotation, targetEnt, targetFastFindInfo.position, targetFastFindInfo.rotation, buildAttachCandidates, buildExtraConfig, outlinkInfo.attachPosition, outlinkInfo.moveDelta, linkPointCollector)

	if not canLink then
		return false
	end

	outlinkInfo.attachRotation = localRotation
	outlinkInfo.parentId = targetEnt.ornamentId
	outlinkInfo.attachPriority = outlinkInfo.moveDelta:SqrMagnitude()
	outlinkInfo.linkSocketIndex = linkSocketIndex
	outlinkInfo.linkSlotDir = linkSlotDir

	return canLink
end

function ClientOrnamentBuildAttachManager:getLinkBuildExtraConfig(buildExtraConfig)
	local homeSystem = pg.game and pg.game.home
	local presetFilter = homeSystem and homeSystem:getSrcEntityLinkPresetFilter()
	local dirFilter = homeSystem and homeSystem:getSrcEntityLinkDirFilter()

	if presetFilter ~= nil or dirFilter ~= nil then
		buildExtraConfig = buildExtraConfig or {}
		buildExtraConfig.srcEntityLinkPresetFilter = presetFilter
		buildExtraConfig.srcEntityLinkDirFilter = dirFilter
	end

	return buildExtraConfig
end

function ClientOrnamentBuildAttachManager:findBestLinkInfo(editor, srcEntity, localPosition, localRotation, buildAttachCandidates, buildExtraConfig)
	self:resetLinkPointCandidates()
	self:resetBuildAttachInfo(self.bestLinkInfo)
	self:resetBuildAttachInfo(self.tempLinkInfo)

	local bestPriority

	for _, fastInfo in pairs(buildAttachCandidates) do
		if self:tryGetBestLinkInfo(editor, srcEntity, localPosition, localRotation, fastInfo, self.tempLinkInfo, buildAttachCandidates, buildExtraConfig, self.linkPointPairCollectorFunc) then
			local curPriority = self.tempLinkInfo.attachPriority

			if not bestPriority or curPriority < bestPriority then
				bestPriority = curPriority

				self:copyBuildAttachInfo(self.bestLinkInfo, self.tempLinkInfo)
			end
		end
	end

	return bestPriority ~= nil
end

function ClientOrnamentBuildAttachManager:innerOrnamentQueryAttachFilterFunc(ornamentId, fastInfo)
	if ornamentId <= 0 then
		return false
	end

	if self.virtualIdMap and self.virtualIdMap[ornamentId] ~= nil then
		return false
	end

	if fastInfo and fastInfo.extraInfo and fastInfo.extraInfo.canAttach and fastInfo.extraInfo.ent.visible ~= false then
		return true
	end

	return false
end

function ClientOrnamentBuildAttachManager:innerOrnamentQueryLinkFilterFunc(ornamentId, fastInfo)
	if ornamentId <= 0 then
		return false
	end

	if self.virtualIdMap and self.virtualIdMap[ornamentId] ~= nil then
		return false
	end

	if fastInfo and fastInfo.extraInfo then
		if not fastInfo.extraInfo.canLink or fastInfo.extraInfo.ent.visible == false then
			return false
		end

		return true
	end

	return false
end

function ClientOrnamentBuildAttachManager:innerOrnamentQueryLinkSlowFilterFunc(ornamentId, fastInfo)
	if fastInfo and fastInfo.extraInfo then
		if not HomeLandUtils.checkHomeObjectLinkPosValid(fastInfo.position, fastInfo.rotation, fastInfo.extraInfo.scale) then
			return false
		end

		return true
	end

	return false
end

function ClientOrnamentBuildAttachManager:calcAttachQueryArea(editor, srcEntity)
	local localPosition = editor:getLocalPosition(srcEntity:getPosition())
	local localRotation = editor:getLocalRotation(srcEntity:getRotation())
	local boundSize = srcEntity:getBoundSize()
	local scale = srcEntity:getScale()
	local boundX = boundSize[1]
	local boundZ = boundSize[2]

	if Utils.checkRotationIsVertical(localRotation) then
		boundX = boundSize[2]
		boundZ = boundSize[1]
	end

	local homeObjectInfo = HomeObjectData[srcEntity.homeTemplateId]
	local minX = localPosition.x - boundX * 0.5 - 1.5
	local maxX = localPosition.x + boundX * 0.5 + 1.5
	local minZ = localPosition.z - boundZ * 0.5 - 1.5
	local maxZ = localPosition.z + boundZ * 0.5 + 1.5
	local minY = localPosition.y - 1.5
	local maxY = localPosition.y + (homeObjectInfo and homeObjectInfo.modelHeight or 0) + 1.5

	return localPosition, localRotation, scale, minX, maxX, minZ, maxZ, minY, maxY
end

function ClientOrnamentBuildAttachManager:refreshBuildAttachDisplay(editor, editEntity, buildExtraConfig)
	if not editor or not editEntity then
		self:clearLinkPointEffects()

		return
	end

	if not self.enableEditorAttach then
		self:clearAttachGrids()
		self:clearLinkPointEffects()

		if editEntity.setEditorInAttach then
			editEntity:setEditorInAttach(nil)
		end

		return
	end

	local srcEntity

	if editEntity.getChildEntities then
		if editEntity.getGroupMainEntity then
			srcEntity = editEntity:getGroupMainEntity()
		end
	else
		srcEntity = editEntity
	end

	if not srcEntity then
		self:clearAttachGrids()
		self:clearLinkPointEffects()

		return
	end

	local canAttach = HomeLandUtils.checkHomeObjectCanAttach(srcEntity.homeTemplateId)
	local canLink = HomeLandUtils.checkHomeObjectCanLink(srcEntity.homeTemplateId)

	if not canAttach then
		self:clearAttachGrids()

		if editEntity == srcEntity and editEntity.setEditorInAttach then
			editEntity:setEditorInAttach(nil)
		end

		if not canLink then
			self:clearLinkPointEffects()

			return
		end

		local localPosition, localRotation, scale, minX, maxX, minZ, maxZ, minY, maxY = self:calcAttachQueryArea(editor, srcEntity)

		if not HomeLandUtils.checkHomeObjectLinkPosValid(localPosition, localRotation, scale) then
			self:clearLinkPointEffects()

			return
		end

		self.buildAttachCandidates = self.buildAttachCandidates or {}

		table.clear(self.buildAttachCandidates)
		editor:getAreaOrnaments(minX, maxX, minZ, maxZ, self.buildAttachCandidates, minY, maxY, self.ornamentQueryLinkFilterFunc, self.ornamentQueryLinkSlowFilterFunc)

		buildExtraConfig = self:getLinkBuildExtraConfig(buildExtraConfig)

		local linkValid = self:findBestLinkInfo(editor, srcEntity, localPosition, localRotation, self.buildAttachCandidates, buildExtraConfig)

		self:refreshLinkPointEffects(editor, linkValid)

		return
	end

	self:clearLinkPointEffects()

	buildExtraConfig = buildExtraConfig or self.defaultBuildConfig

	local localPosition, localRotation, scale, minX, maxX, minZ, maxZ, minY, maxY = self:calcAttachQueryArea(editor, srcEntity)

	self.buildAttachCandidates = self.buildAttachCandidates or {}

	table.clear(self.buildAttachCandidates)
	editor:getAreaOrnaments(minX, maxX, minZ, maxZ, self.buildAttachCandidates, minY, maxY, self.ornamentQueryAttachFilterFunc)
	self:refreshAttachGrids(editor, self.buildAttachCandidates, srcEntity)
	self:resetBuildAttachInfo(self.bestAttachInfo)
	self:resetBuildAttachInfo(self.tempAttachInfo)

	local bestPriority

	for ornamentId, fastInfo in pairs(self.buildAttachCandidates) do
		if self:tryGetBestAttachInfo(editor, srcEntity, localPosition, localRotation, scale, fastInfo, self.tempAttachInfo, buildExtraConfig) then
			local curPriority = self.tempAttachInfo.attachPriority

			if not bestPriority or curPriority < bestPriority then
				bestPriority = curPriority

				self:copyBuildAttachInfo(self.bestAttachInfo, self.tempAttachInfo)
			end
		end
	end

	if editEntity == srcEntity and editEntity.setEditorInAttach then
		if bestPriority and self.bestAttachInfo.attachPosition then
			editEntity:setEditorInAttach({
				attachType = self.bestAttachInfo.attachSlotId,
				worldPosition = editor:getWorldPosition(self.bestAttachInfo.attachPosition)
			})
		else
			editEntity:setEditorInAttach(nil)
		end
	end
end

function ClientOrnamentBuildAttachManager:tryApplyBuildAttach(editor, editEntity, buildExtraConfig)
	if not self.tempDynamicBuildExtraData then
		self:clearLinkPointEffects()

		return false
	end

	table.clear(self.tempDynamicBuildExtraData.attachData)
	table.clear(self.tempDynamicBuildExtraData.linkData)

	if not self.enableEditorAttach then
		self:clearLinkPointEffects()

		return false
	end

	local srcEntity

	if editEntity.getChildEntities then
		if editEntity.getGroupMainEntity then
			srcEntity = editEntity:getGroupMainEntity()
		end
	else
		srcEntity = editEntity
	end

	if not srcEntity then
		self:clearLinkPointEffects()

		return false
	end

	if editEntity == srcEntity and editEntity.setEditorInAttach then
		editEntity:setEditorInAttach(nil)
	end

	local canAttach = HomeLandUtils.checkHomeObjectCanAttach(srcEntity.homeTemplateId)
	local canLink = HomeLandUtils.checkHomeObjectCanLink(srcEntity.homeTemplateId)

	if not canAttach and not canLink then
		self:clearLinkPointEffects()

		return false
	end

	local localPosition, localRotation, scale, minX, maxX, minZ, maxZ, minY, maxY = self:calcAttachQueryArea(editor, srcEntity)

	if canLink and not HomeLandUtils.checkHomeObjectLinkPosValid(localPosition, localRotation, scale) then
		self:clearLinkPointEffects()

		return false
	end

	self.buildAttachCandidates = self.buildAttachCandidates or {}
	self.lastLinkDebugEditor = editor
	self.lastLinkDebugSrcEntity = srcEntity

	if canAttach then
		self:clearLinkPointEffects()
		table.clear(self.buildAttachCandidates)
		editor:getAreaOrnaments(minX, maxX, minZ, maxZ, self.buildAttachCandidates, minY, maxY, self.ornamentQueryAttachFilterFunc)
		self:refreshAttachGrids(editor, self.buildAttachCandidates, srcEntity)
		self:resetBuildAttachInfo(self.bestAttachInfo)
		self:resetBuildAttachInfo(self.tempAttachInfo)

		local bestPriority

		for ornamentId, fastInfo in pairs(self.buildAttachCandidates) do
			if self:tryGetBestAttachInfo(editor, srcEntity, localPosition, localRotation, scale, fastInfo, self.tempAttachInfo, buildExtraConfig) then
				local curPriority = self.tempAttachInfo.attachPriority

				if not bestPriority or curPriority < bestPriority then
					bestPriority = curPriority

					self:copyBuildAttachInfo(self.bestAttachInfo, self.tempAttachInfo)
				end
			end
		end

		if bestPriority then
			local moveDelta = self.bestAttachInfo.moveDelta

			if moveDelta then
				Vector3.enableCreateFromCache()

				local finalPosition = editor:getLocalPosition(editEntity:getPosition())

				finalPosition = editor:getWorldPosition(finalPosition + moveDelta)

				editEntity:setPosition(finalPosition)
				Vector3.disableCreateFromCache()
				editor:onEntityAttachChanged(editEntity)
			end

			self:applyDynamicAttachData(srcEntity, self.bestAttachInfo)

			if editEntity == srcEntity and editEntity.setEditorInAttach and self.bestAttachInfo.attachPosition then
				editEntity:setEditorInAttach({
					attachType = self.bestAttachInfo.attachSlotId,
					worldPosition = editor:getWorldPosition(self.bestAttachInfo.attachPosition)
				})
			end

			return true
		end

		self:clearLinkDebugInfo()
	else
		self:clearAttachGrids()

		buildExtraConfig = self:getLinkBuildExtraConfig(buildExtraConfig)

		table.clear(self.buildAttachCandidates)
		editor:getAreaOrnaments(minX, maxX, minZ, maxZ, self.buildAttachCandidates, minY, maxY, self.ornamentQueryLinkFilterFunc, self.ornamentQueryLinkSlowFilterFunc)

		local linkValid = self:findBestLinkInfo(editor, srcEntity, localPosition, localRotation, self.buildAttachCandidates, buildExtraConfig)

		if linkValid then
			local moveDelta = self.bestLinkInfo.moveDelta

			if moveDelta then
				Vector3.enableCreateFromCache()

				local finalPosition = editor:getLocalPosition(editEntity:getPosition())

				finalPosition = editor:getWorldPosition(finalPosition + moveDelta)

				editEntity:setPosition(finalPosition)
				Vector3.disableCreateFromCache()
				editor:onEntityLinkChanged(editEntity)
			end

			self:refreshLinkPointEffects(editor, true, moveDelta)
		else
			self:refreshLinkPointEffects(editor, false)
		end

		if pg.game.home.showLinkDebugInfo then
			self:showLinkDebugInfo(srcEntity, srcEntity:getPosition(), srcEntity:getRotation(), self.buildAttachCandidates)
		else
			self:clearLinkDebugInfo()
		end

		return linkValid
	end

	return false
end

function ClientOrnamentBuildAttachManager:applyDynamicAttachData(srcEntity, bestAttachInfo)
	if srcEntity.ornamentId then
		self.tempDynamicBuildExtraData.attachData[srcEntity.ornamentId] = {
			parentId = bestAttachInfo.parentId,
			slotId = bestAttachInfo.attachSlotId
		}
	end
end

function ClientOrnamentBuildAttachManager:applyDynamicLinkData(srcEntity, bestLinkInfo)
	if srcEntity.ornamentId then
		self.tempDynamicBuildExtraData.linkData[srcEntity.ornamentId] = {
			parentId = bestLinkInfo.parentId
		}
	end
end

function ClientOrnamentBuildAttachManager:collectEntityLinkLines(templateId, worldPosition, worldRotation, outLines, isCandidate, snapInfo)
	local linkData = LinkHelper.getLinkData(templateId)

	if not linkData or not linkData.linkSockets then
		return
	end

	local entityDirType = LinkHelper.getDirType(worldRotation)
	local srcPresetFilter = not isCandidate and pg.game.home and pg.game.home:getSrcEntityLinkPresetFilter()
	local srcDirFilter = not isCandidate and pg.game.home and pg.game.home:getSrcEntityLinkDirFilter()

	Vector3.enableCreateFromCache()

	for socketIndex, socketInfo in ipairs(linkData.linkSockets) do
		local socketFiltered = srcPresetFilter and socketInfo.presetType ~= srcPresetFilter or srcDirFilter and socketInfo.dirType ~= srcDirFilter
		local socketOffset = LinkHelper.getSocketOffset(socketInfo)
		local socketWorldPos = worldPosition + worldRotation * socketOffset
		local socketDirType = socketInfo.dirType or BuildConst.DirectionType.Front

		socketDirType = BuildConst.DirConvertInfo[entityDirType][socketDirType]

		local presetData = BuildConst.LinkPresetData[socketInfo.presetType]
		local dirConvert = socketDirType and BuildConst.DirConvertInfo[socketDirType]

		if presetData and dirConvert then
			for slotDir, slotInfo in pairs(presetData.dirData) do
				if slotInfo.socketData then
					local worldSlotDir = dirConvert[slotDir]
					local dirVec = worldSlotDir and BuildConst.DirVectorInfo[worldSlotDir]
					local hasPresetStrict = false

					for _, socketFitData in pairs(slotInfo.socketData) do
						if socketFitData.targetSocketPresetStrict then
							hasPresetStrict = true

							break
						end
					end

					local color

					if isCandidate then
						if LinkHelper.isSocketMainWorldDir(socketDirType, presetData, worldSlotDir) then
							color = BuildConst.LINK_DEBUG_CANDIDATE_MAIN_COLOR
						else
							color = BuildConst.LINK_DEBUG_CANDIDATE_OTHER_COLOR
						end
					elseif socketFiltered then
						color = BuildConst.LINK_DEBUG_SRC_FILTERED_COLOR
					elseif snapInfo and snapInfo.socketIndex == socketIndex and snapInfo.slotDir == slotDir then
						color = BuildConst.LINK_DEBUG_SRC_SNAP_COLOR
					elseif hasPresetStrict then
						color = BuildConst.LINK_DEBUG_SRC_PRESET_STRICT_COLOR
					else
						color = BuildConst.LINK_DEBUG_SRC_COLOR
					end

					if dirVec and color then
						outLines[#outLines + 1] = {
							socketWorldPos.x,
							socketWorldPos.y,
							socketWorldPos.z,
							socketWorldPos.x + dirVec[1] * BuildConst.LINK_DEBUG_LINE_LEN,
							socketWorldPos.y + dirVec[2] * BuildConst.LINK_DEBUG_LINE_LEN,
							socketWorldPos.z + dirVec[3] * BuildConst.LINK_DEBUG_LINE_LEN,
							color[1],
							color[2],
							color[3]
						}
					end
				end
			end
		end
	end

	Vector3.disableCreateFromCache()
end

function ClientOrnamentBuildAttachManager:showLinkDebugInfo(srcEntity, position, rotation, candidates)
	local homelandMgr = pg.global.homelandMgr

	if not homelandMgr then
		return
	end

	local lines = {}

	if srcEntity and srcEntity.homeTemplateId then
		local snapInfo

		if self.bestLinkInfo and self.bestLinkInfo.linkSocketIndex then
			snapInfo = {
				socketIndex = self.bestLinkInfo.linkSocketIndex,
				slotDir = self.bestLinkInfo.linkSlotDir
			}
		end

		self:collectEntityLinkLines(srcEntity.homeTemplateId, position, rotation, lines, false, snapInfo)
	end

	local editor = self.lastLinkDebugEditor

	if candidates and editor then
		for _, fastInfo in pairs(candidates) do
			local targetEnt = fastInfo.extraInfo and fastInfo.extraInfo.ent

			if targetEnt and targetEnt.homeTemplateId then
				local worldPos = editor:getWorldPosition(fastInfo.position)
				local worldRot = editor:getWorldRotation(fastInfo.rotation)

				self:collectEntityLinkLines(targetEnt.homeTemplateId, worldPos, worldRot, lines, true)
			end
		end
	end

	homelandMgr:DrawLinkDebugInfo(lines)
end

function ClientOrnamentBuildAttachManager:clearLinkDebugInfo()
	local homelandMgr = pg.global.homelandMgr

	if homelandMgr then
		homelandMgr:ClearLinkDebugInfo()
	end
end

function ClientOrnamentBuildAttachManager:createLinkPointEffectState()
	return {
		count = 0,
		effectIds = {},
		positions = {}
	}
end

function ClientOrnamentBuildAttachManager:isSameLinkPointEffectPosition(position, cachedPosition)
	local deltaX = position.x - cachedPosition.x
	local deltaY = position.y - cachedPosition.y
	local deltaZ = position.z - cachedPosition.z

	return deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ <= self.LINK_POINT_POSITION_EPSILON_SQR
end

function ClientOrnamentBuildAttachManager:appendUniqueLinkPointPosition(positions, positionCount, position)
	for index = 1, positionCount do
		if self:isSameLinkPointEffectPosition(position, positions[index]) then
			return positionCount
		end
	end

	positionCount = positionCount + 1

	local storedPosition = positions[positionCount]

	if not storedPosition then
		storedPosition = Vector3.ForceNew(0, 0, 0)
		positions[positionCount] = storedPosition
	end

	storedPosition:Copy(position)

	return positionCount
end

function ClientOrnamentBuildAttachManager:resetLinkPointCandidates()
	self.linkPointSourcePositions = self.linkPointSourcePositions or {}
	self.linkPointTargetPositions = self.linkPointTargetPositions or {}
	self.linkPointSourcePositionCount = 0
	self.linkPointTargetPositionCount = 0

	if not self.linkPointPairCollectorFunc then
		function self.linkPointPairCollectorFunc(sourcePosition, targetPosition)
			self:collectLinkPointPair(sourcePosition, targetPosition)
		end
	end
end

function ClientOrnamentBuildAttachManager:collectLinkPointPair(sourcePosition, targetPosition)
	local deltaX = targetPosition.x - sourcePosition.x
	local deltaY = targetPosition.y - sourcePosition.y
	local deltaZ = targetPosition.z - sourcePosition.z

	if deltaX * deltaX + deltaY * deltaY + deltaZ * deltaZ > self.LINK_POINT_DISPLAY_RANGE_SQR then
		return
	end

	self.linkPointSourcePositionCount = self:appendUniqueLinkPointPosition(self.linkPointSourcePositions, self.linkPointSourcePositionCount, sourcePosition)
	self.linkPointTargetPositionCount = self:appendUniqueLinkPointPosition(self.linkPointTargetPositions, self.linkPointTargetPositionCount, targetPosition)
end

function ClientOrnamentBuildAttachManager:copyLinkPointEffectPosition(positions, index, position)
	local storedPosition = positions[index]

	if not storedPosition then
		storedPosition = Vector3.ForceNew(0, 0, 0)
		positions[index] = storedPosition
	end

	storedPosition:Copy(position)
end

function ClientOrnamentBuildAttachManager:isLinkPointEffectStateUnchanged(state, positions, positionCount)
	if not state or state.count ~= positionCount or #state.effectIds ~= positionCount then
		return false
	end

	for index = 1, positionCount do
		if not self:isSameLinkPointEffectPosition(positions[index], state.positions[index]) then
			return false
		end
	end

	return true
end

function ClientOrnamentBuildAttachManager:stopLinkPointEffectState(effectSystem, state)
	if not state then
		return
	end

	if effectSystem then
		for _, effectId in ipairs(state.effectIds) do
			effectSystem:stopEffect(nil, effectId, true)
		end
	end

	table.clear(state.effectIds)

	state.count = 0
end

function ClientOrnamentBuildAttachManager:playLinkPointEffect(effectSystem, effectState, effectResId, worldPosition, extraInfo)
	local effectId = effectSystem:playRawEffectAt(nil, effectResId, worldPosition, extraInfo)

	if effectId and effectId ~= 0 then
		effectState.effectIds[#effectState.effectIds + 1] = effectId
	end
end

function ClientOrnamentBuildAttachManager:refreshLinkPointEffectState(effectSystem, effectState, effectResId, positions, positionCount, extraInfo)
	if self:isLinkPointEffectStateUnchanged(effectState, positions, positionCount) then
		return
	end

	self:stopLinkPointEffectState(effectSystem, effectState)

	effectState.count = positionCount

	for index = 1, positionCount do
		self:copyLinkPointEffectPosition(effectState.positions, index, positions[index])
		self:playLinkPointEffect(effectSystem, effectState, effectResId, effectState.positions[index], extraInfo)
	end
end

function ClientOrnamentBuildAttachManager:refreshLinkPointEffects(editor, linkValid, appliedMoveDelta)
	local effectSystem = pg.game and pg.game.effect

	if not editor or not effectSystem then
		self:clearLinkPointEffects()

		return
	end

	self.linkPointDisplayAddPositions = self.linkPointDisplayAddPositions or {}
	self.linkPointDisplayAlphyPositions = self.linkPointDisplayAlphyPositions or {}
	self.linkPointAddEffectState = self.linkPointAddEffectState or self:createLinkPointEffectState()
	self.linkPointAlphyEffectState = self.linkPointAlphyEffectState or self:createLinkPointEffectState()

	local addPositionCount = 0
	local alphyPositionCount = 0

	Vector3.enableCreateFromCache()

	local showAddPoint = linkValid and self.bestLinkInfo and self.bestLinkInfo.attachPosition

	if showAddPoint and not appliedMoveDelta then
		local moveDelta = self.bestLinkInfo.moveDelta

		showAddPoint = moveDelta and moveDelta:SqrMagnitude() <= self.LINK_POINT_POSITION_EPSILON_SQR
	end

	if showAddPoint then
		local addWorldPosition = editor:getWorldPosition(self.bestLinkInfo.attachPosition)

		addPositionCount = self:appendUniqueLinkPointPosition(self.linkPointDisplayAddPositions, addPositionCount, addWorldPosition)
	end

	for index = 1, self.linkPointSourcePositionCount or 0 do
		local sourceLocalPosition = self.linkPointSourcePositions[index]

		if appliedMoveDelta then
			sourceLocalPosition = sourceLocalPosition + appliedMoveDelta
		end

		local sourceWorldPosition = editor:getWorldPosition(sourceLocalPosition)

		if addPositionCount == 0 or not self:isSameLinkPointEffectPosition(sourceWorldPosition, self.linkPointDisplayAddPositions[1]) then
			alphyPositionCount = self:appendUniqueLinkPointPosition(self.linkPointDisplayAlphyPositions, alphyPositionCount, sourceWorldPosition)
		end
	end

	for index = 1, self.linkPointTargetPositionCount or 0 do
		local targetWorldPosition = editor:getWorldPosition(self.linkPointTargetPositions[index])

		if addPositionCount == 0 or not self:isSameLinkPointEffectPosition(targetWorldPosition, self.linkPointDisplayAddPositions[1]) then
			alphyPositionCount = self:appendUniqueLinkPointPosition(self.linkPointDisplayAlphyPositions, alphyPositionCount, targetWorldPosition)
		end
	end

	Vector3.disableCreateFromCache()

	local extraInfo = {
		enableMultipleLoop = true,
		duration = -1,
		forceLodLevel = self.LINK_POINT_EFFECT_FORCE_LOD_LEVEL
	}

	self:refreshLinkPointEffectState(effectSystem, self.linkPointAddEffectState, self.LINK_POINT_ADD_EFFECT_RES_ID, self.linkPointDisplayAddPositions, addPositionCount, extraInfo)
	self:refreshLinkPointEffectState(effectSystem, self.linkPointAlphyEffectState, self.LINK_POINT_ALPHY_EFFECT_RES_ID, self.linkPointDisplayAlphyPositions, alphyPositionCount, extraInfo)
end

function ClientOrnamentBuildAttachManager:clearLinkPointEffects()
	local effectSystem = pg.game and pg.game.effect

	if self.linkPointEffectIds then
		for _, effectId in ipairs(self.linkPointEffectIds) do
			if effectSystem then
				effectSystem:stopEffect(nil, effectId, true)
			end
		end

		table.clear(self.linkPointEffectIds)
	end

	self:stopLinkPointEffectState(effectSystem, self.linkPointAddEffectState)
	self:stopLinkPointEffectState(effectSystem, self.linkPointAlphyEffectState)
end

function ClientOrnamentBuildAttachManager:isAttachGridVisible()
	if not pg.game.home then
		return false
	end

	return pg.game.home:getHomeEditorPlayerSetting(ClientConst.HomelandEditorSetting.GridDisplay, true)
end

function ClientOrnamentBuildAttachManager:refreshAttachGrids(editor, candidates, srcEnt)
	local homelandMgr = pg.global.homelandMgr

	if not homelandMgr or not editor or not candidates then
		return
	end

	if not self:isAttachGridVisible() then
		self:clearAttachGrids()

		return
	end

	local srcHomeBuildInfo = srcEnt and HomeBuildData[srcEnt.homeTemplateId]

	if not srcHomeBuildInfo or not srcHomeBuildInfo.attachRoots then
		self:clearAttachGrids()

		return
	end

	local gridIndex = 0

	for _, fastInfo in pairs(candidates) do
		local targetEnt = fastInfo.extraInfo and fastInfo.extraInfo.ent
		local targetHomeBuildInfo = targetEnt and HomeBuildData[targetEnt.homeTemplateId]

		if targetHomeBuildInfo and targetHomeBuildInfo.attachPlanes then
			for _, attachPlaneInfo in ipairs(targetHomeBuildInfo.attachPlanes) do
				local matched = false

				for _, attachRootInfo in ipairs(srcHomeBuildInfo.attachRoots) do
					if AttachHelper.checkAttachTypeMatch(attachRootInfo.type, attachPlaneInfo.type) then
						matched = true

						break
					end
				end

				if matched then
					Vector3.enableCreateFromCache()

					local targetScale = fastInfo.extraInfo.scale or Vector3.constOne
					local planePosition, planeRotation = self:calcAttachPlaneTransform(attachPlaneInfo, fastInfo.position, fastInfo.rotation, targetScale)
					local worldCenter = editor:getWorldPosition(planePosition)
					local worldRotation = editor:getWorldRotation(planeRotation)
					local planeNormal = Quaternion.MulVec3(worldRotation, Vector3.constUp)

					worldCenter = worldCenter + planeNormal * BuildConst.AttachEffectOffsetY

					homelandMgr:ShowGridEffect(self.ATTACH_GRID_ID_BASE + gridIndex, worldCenter, worldRotation, attachPlaneInfo.width, attachPlaneInfo.height)
					Vector3.disableCreateFromCache()

					gridIndex = gridIndex + 1
				end
			end
		end
	end

	for i = gridIndex, self.attachGridShownCount - 1 do
		homelandMgr:HideGridEffect(self.ATTACH_GRID_ID_BASE + i)
	end

	self.attachGridShownCount = gridIndex
end

function ClientOrnamentBuildAttachManager:clearAttachGrids()
	local homelandMgr = pg.global.homelandMgr

	if homelandMgr then
		for i = 0, self.attachGridShownCount - 1 do
			homelandMgr:HideGridEffect(self.ATTACH_GRID_ID_BASE + i)
		end
	end

	self.attachGridShownCount = 0
end

return ClientOrnamentBuildAttachManager
