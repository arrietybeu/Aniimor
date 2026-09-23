-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\PhotoUIComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local bit = bit
local lshift = bit.lshift
local bor = bit.bor
local EventConst = require("Const.EventConst")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local InteractionConst = require("Common.Const.InteractionConst")
local PhotoIdentifyData = require("Data.photo_identify_data")
local FrontCondition = require("Data.front_condition_data")
local PhotoConditionTrigger = require("Utils.PhotoConditionTrigger")
local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local PetData = require("Data.pet_data")
local ClientUtils = require("Utils.ClientUtils")
local logger = LoggerManager.getLogger("PhotoUIComponent")
local PetProtoTypeData = require("Data.pet_prototype_data")
local ResPointUtils = require("Common.Utils.ResPointUtils")
local lume = require("Core.Common.lume")
local ToBool = ToBool
local Quaternion = Quaternion
local Vector3 = Vector3
local PhotoUIComponent = Class.LightClass("PhotoUIComponent", UIComponent)

PhotoUIComponent.PhotoIdentifyType = {
	ConditionTrigger = 2,
	AI = 1
}
PhotoUIComponent.TraitPointState = {
	After = 3,
	Playing = 2,
	Before = 1
}

function PhotoUIComponent:initView()
	self.expectationEntIds = {}
	self.topLogoEntIds = {}
	self.capturedPhotoId = nil
	self.capturedPhotoEntId = nil
	self.pendingPhotoId = nil
	self.pendingPhotoEntId = nil
	self.curPlayingAiTrait = {}
	self.hasPetConditionIds = {}

	self:clearUpdateTimer()

	self.triggerQuickPhotoInteract = false
	self.minDist = 100000
	self.waitAITraitPhotoInfos = {}
	self.updateTimer = self.ctrl:startTimer(function()
		self:update()
	end, 1, true)

	pg.game.camera:setQuickPhotoFinishBlendCb(function()
		self:onBlendQuickPhotoFinished()
	end)
	self:startTimer(function()
		ResPointUtils.RefreshPhotoMessage()
	end, 1)
end

function PhotoUIComponent:update()
	self:tryConfirmPendingPhoto()

	if not self.inQuickPhoto and not self.curAITraitPhotoId then
		self:trySetQuickPhotoEnt()
	end
end

function PhotoUIComponent:onBlendQuickPhotoFinished()
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("onBlendQuickPhotoFinished")
	end

	local photo = pg.global.ui.photo

	photo:open({
		photoMode = photo.ModeType.QUICK_MODE,
		quickPhotoId = self.quickPhotoId,
		quickPhotoEnts = self.quickPhotoEntities
	})

	self.inQuickPhoto = false
end

function PhotoUIComponent:getCheckPos(ent)
	if ent == nil then
		return
	end

	local success, pos, size = ent.eModel:TryGetHead(Const.COMPONENT_INDEX_MODEL)

	if success then
		return pos
	end

	local nearHeight, _ = ent:getCameraHeightInfo()
	local entPos = ent:getPosition()

	return Vector3(entPos.x, entPos.y + nearHeight, entPos.z)
end

function PhotoUIComponent:checkExtraPos(photoEnt, curCameraPos, distance, layerMask)
	if self:needExtraCheck(photoEnt) then
		local nearHeight, _ = photoEnt:getCameraHeightInfo()
		local entPos = photoEnt:getPosition()

		if not pgUtils.IsBlocked(curCameraPos, Vector3(entPos.x, entPos.y + nearHeight, entPos.z), distance, layerMask) then
			return true
		end

		if not pgUtils.IsBlocked(curCameraPos, entPos, distance, layerMask) then
			return true
		end
	end

	return false
end

function PhotoUIComponent:needExtraCheck(photoEnt)
	local photoIds = photoEnt.photoIdentifyIds or {}

	for _, photoId in pairs(photoIds) do
		local photoCfg = PhotoIdentifyData[photoId]

		if photoCfg and photoCfg.laserToCapsule == 1 then
			return true
		end
	end

	return false
end

function PhotoUIComponent:tryCheckSelfPet(photoEntIds)
	local curPet = pg.me:getCurPetEntity()

	if curPet and not curPet.noPhotoIdentifyIds then
		curPet.noPhotoIdentifyIds = true

		local photoIdentifyIds = curPet:getConfigData().photoIdentifyIds

		if photoIdentifyIds and #photoIdentifyIds > 0 then
			local needIdentifyIds = {}

			for idx, pId in ipairs(photoIdentifyIds) do
				if not ClientUtils.checkPhotoTraitIsUnlock(pId) then
					table.insert(needIdentifyIds, pId)
				end
			end

			if #needIdentifyIds > 0 then
				curPet.photoIdentifyIds = needIdentifyIds
				photoEntIds[curPet.id] = 1
				curPet.noPhotoIdentifyIds = false
			end
		end
	end
end

function PhotoUIComponent:trySetQuickPhotoEnt()
	local player = pg.me

	if player == nil then
		return
	end

	local photoEntIds = player.photoEntInRange

	self:tryCheckSelfPet(photoEntIds)

	if lume.getMapLen(photoEntIds) == 0 then
		self:clearAllPhotoTopLogo()

		self.capturedPhotoId = nil
		self.capturedPhotoEntId = nil

		return
	end

	if self.capturedPhotoId and (self.capturedPhotoEntId == nil or not photoEntIds[self.capturedPhotoEntId]) then
		self.capturedPhotoId = nil
		self.capturedPhotoEntId = nil
	end

	local identifyTable = {}
	local baseFormPetIdToEnt = {}
	local layerMask = bor(lshift(1, ClientConst.LayerDefine.LAYER_GROUND), lshift(1, ClientConst.LayerDefine.LAYER_WALL), lshift(1, ClientConst.LayerDefine.LAYER_DEFAULT))

	Vector3.enableCreateFromCache()

	local curCameraPosX, curCameraPosY, curCameraPosZ = pg.global.cameraMgr:GetWorldCameraPositionEx()
	local curCameraPos = Vector3(curCameraPosX, curCameraPosY, curCameraPosZ)
	local needRemoveEntIds = {}

	for entId, _ in pairs(photoEntIds) do
		local photoEnt = pg.getEntity(entId)
		local checkPos = self:getCheckPos(photoEnt)

		if photoEnt and pg.game.camera:checkInViewport(checkPos) then
			local baseId = photoEnt:getConfigData().baseFormPet

			if not baseFormPetIdToEnt[baseId] then
				baseFormPetIdToEnt[baseId] = {}
			end

			local distance = Vector3.Distance(checkPos, curCameraPos)
			local isBlock = pgUtils.IsBlocked(curCameraPos, checkPos, distance, layerMask)

			if not isBlock or self:checkExtraPos(photoEnt, curCameraPos, distance, layerMask) then
				baseFormPetIdToEnt[baseId][#baseFormPetIdToEnt[baseId] + 1] = {
					ent = photoEnt,
					dist = distance
				}

				if photoEnt then
					self:trySetPhotoIdentifyIdByDistance(photoEnt, distance, identifyTable)
				end
			end
		elseif not photoEnt then
			needRemoveEntIds[#needRemoveEntIds + 1] = entId
		end
	end

	local curPet = player:getCurPetEntity()

	if curPet then
		photoEntIds[curPet.id] = nil
	end

	Vector3.disableCreateFromCache()

	for idx, entId in ipairs(needRemoveEntIds) do
		player:removePhotoDistance(entId)
	end

	self.expectationPhotoId = nil

	local hasQuickPhoto = false
	local curShowTopLogoEntIds = {}

	for photoId, _ in pairs(identifyTable) do
		local isStpDoing, isStpWait, satisfyEnt, expectedEnt = self:tryTriggerPhotoIdentifyCondition(photoId, baseFormPetIdToEnt)

		if isStpDoing then
			if self.capturedPhotoId ~= photoId then
				for idx, ent in pairs(satisfyEnt) do
					local checkPos = self:getCheckPos(ent)

					if pg.global.ui:checkUIOpen(UIConst.UI_ID_PHOTO) and pg.game.camera:checkInViewport(checkPos) then
						if ent.ensureTopLogoItem and ent:ensureTopLogoItem("photo") then
							ent.eventEmitter:emit(EventConst.TOPLOGO_PHOTO, UIConst.PHOTO_TYPE.TIP, true)
							ent.eventEmitter:emit(EventConst.TOPLOGO_PHOTO, UIConst.PHOTO_TYPE.DESC, true, self:tryGetPhotoIdentifyInfo(photoId))
						end
					else
						ent.eventEmitter:emit(EventConst.TOPLOGO_PHOTO, UIConst.PHOTO_TYPE.TIP, false)
						ent.eventEmitter:emit(EventConst.TOPLOGO_PHOTO, UIConst.PHOTO_TYPE.DESC, false, self:tryGetPhotoIdentifyInfo(photoId))
					end

					table.insert(self.topLogoEntIds, ent.id)
					table.insert(curShowTopLogoEntIds, ent.id)
				end

				self:setQuickPhotoInfo(photoId, satisfyEnt)

				hasQuickPhoto = true
			end

			break
		elseif self.capturedPhotoId == photoId then
			self.capturedPhotoId = nil
			self.capturedPhotoEntId = nil
		end
	end

	self:clearPhotoTopLogo(curShowTopLogoEntIds)

	if not hasQuickPhoto then
		self:clearQuickPhotoInfo()
	end
end

function PhotoUIComponent:checkExpectationCondition(ent, conditionIds)
	return false
end

function PhotoUIComponent:tryDoPhotoExpectation(entities)
	local player = pg.me
	local curPet = player:getCurPetEntity()

	if ToBool(entities) then
		player:showTopLogo()

		if curPet then
			curPet:showTopLogo()
		end

		for idx, ent in pairs(entities) do
			ent:showTopLogo()

			self.expectationEntIds[idx] = ent.id
		end
	end
end

function PhotoUIComponent:clearPhotoExpectation()
	return
end

function PhotoUIComponent:clearPhotoTopLogo(curShowTopLogoEntIds)
	if self.topLogoEntIds then
		for _, entId in pairs(self.topLogoEntIds) do
			local ent = pg.getEntity(entId)

			if ent and not table.contains(curShowTopLogoEntIds, entId) then
				ent.eventEmitter:emit(EventConst.TOPLOGO_PHOTO, UIConst.PHOTO_TYPE.TIP, false)
				ent.eventEmitter:emit(EventConst.TOPLOGO_PHOTO, UIConst.PHOTO_TYPE.DESC, false)
			end
		end

		self.topLogoEntIds = curShowTopLogoEntIds
	end
end

function PhotoUIComponent:clearAllPhotoTopLogo()
	for _, entId in pairs(self.topLogoEntIds) do
		local ent = pg.getEntity(entId)

		if ent then
			ent.eventEmitter:emit(EventConst.TOPLOGO_PHOTO, UIConst.PHOTO_TYPE.HIDDEN)
		end
	end

	table.clear(self.topLogoEntIds)
	self:clearQuickPhotoInfo()
end

function PhotoUIComponent:onQuickPhotoTaken(photoId)
	if photoId == nil or self.quickPhotoId ~= photoId then
		return
	end

	local photoEnt = self.quickPhotoEntities and self.quickPhotoEntities[1]

	self.pendingPhotoId = photoId
	self.pendingPhotoEntId = photoEnt and photoEnt.id
end

function PhotoUIComponent:tryConfirmPendingPhoto()
	if self.pendingPhotoId == nil or not ClientUtils.checkPhotoTraitIsUnlock(self.pendingPhotoId) then
		return
	end

	local photoId = self.pendingPhotoId

	self.capturedPhotoId = photoId
	self.capturedPhotoEntId = self.pendingPhotoEntId
	self.pendingPhotoId = nil
	self.pendingPhotoEntId = nil

	if self.quickPhotoId == photoId then
		self:clearAllPhotoTopLogo()
	end
end

function PhotoUIComponent:trySetPhotoIdentifyIdByDistance(ent, dist, identifyTable)
	local photoIds = ent.photoIdentifyIds or {}

	for _, photoId in pairs(photoIds) do
		local photoCfg = PhotoIdentifyData[photoId]

		if photoCfg and photoCfg.inspect == self.PhotoIdentifyType.ConditionTrigger then
			if ent.hasPetCondition then
				self.hasPetConditionIds[photoId] = true
			end

			if not identifyTable[photoId] then
				local configDis = photoCfg.takePhotoDistance

				if dist >= configDis[1] and dist <= configDis[2] then
					identifyTable[photoId] = true
				elseif ent.isEntityTagIdentify then
					identifyTable[photoId] = true
				end
			end
		end
	end
end

function PhotoUIComponent:tryTriggerPhotoIdentifyCondition(photoId, baseFormPetIdToEnt)
	local matchEntities = PhotoIdentifyData[photoId].matchEntities
	local satisfyEnt = {}
	local expectedEnt = {}

	if not ClientUtils.checkPhotoPetIsUnlock(photoId) and not self.hasPetConditionIds[photoId] then
		return false, false, satisfyEnt, expectedEnt
	end

	for _, matchEntInfo in pairs(matchEntities) do
		local isStpDoing, isStpWait = self:tryTriggerMatchEntCondition(matchEntInfo, baseFormPetIdToEnt, PhotoIdentifyData[photoId].takePhotoDistance, satisfyEnt, expectedEnt, PhotoIdentifyData[photoId].photoId)

		return isStpDoing, isStpWait, satisfyEnt, expectedEnt
	end

	return false, false, satisfyEnt, expectedEnt
end

function PhotoUIComponent:tryGetPhotoIdentifyInfo(photoId)
	local matchEntities = PhotoIdentifyData[photoId].matchEntities
	local petName = ""
	local conditionText = ""

	if matchEntities and matchEntities[1][2] then
		local matchInfo = matchEntities[1]
		local baseFormPetId = matchInfo[1]

		petName = pg.getLocalizationText(PetProtoTypeData[baseFormPetId].name)

		if matchInfo[2] then
			local conditionId = matchInfo[2][1]

			conditionText = pg.getLocalizationText(FrontCondition[conditionId].note)
		end
	end

	return string.gsub(conditionText, "<pet0>", petName)
end

function PhotoUIComponent:checkPhotoResearchIsUnlock(baseFormPetId, photoId)
	local playerHandBookMap = pg.me.petHandbookMap
	local playerData = playerHandBookMap[baseFormPetId]

	if playerData and playerData.photoIdMap and playerData.photoIdMap[photoId] then
		return true
	end

	return false
end

function PhotoUIComponent:setQuickPhotoInfo(photoId, ents)
	self.quickPhotoId = photoId
	self.quickPhotoEntities = ents
end

function PhotoUIComponent:clearQuickPhotoInfo()
	self.quickPhotoId = nil
	self.quickPhotoEntities = nil
end

function PhotoUIComponent:tryTriggerMatchEntCondition(matchInfo, baseFormPetIdToEnt, distanceCondition, satisfyEnts, expectedEnts, photoUnlockId)
	local baseFormPetId = matchInfo[1]
	local conditionIds = matchInfo[2]
	local puppetEnts = baseFormPetIdToEnt[baseFormPetId]

	if puppetEnts == nil then
		return false, false
	end

	if photoUnlockId and self:checkPhotoResearchIsUnlock(baseFormPetId, photoUnlockId[1]) then
		return false, false
	end

	local triggerCount = 0
	local expectedCount = 0
	local minDist = self.minDist

	for _, entInfo in pairs(puppetEnts) do
		local ent = entInfo.ent
		local dist = entInfo.dist

		if dist >= distanceCondition[1] and dist <= distanceCondition[2] or ent.isEntityTagIdentify then
			if self:checkExpectationCondition(ent, conditionIds) then
				expectedCount = expectedCount + 1
				expectedEnts[#expectedEnts + 1] = ent
			elseif self:checkConditionTrigger(ent, conditionIds) then
				triggerCount = triggerCount + 1

				if dist < minDist then
					minDist = dist
					satisfyEnts[1] = ent
				end
			end
		end
	end

	return triggerCount > 0, expectedCount > 0
end

function PhotoUIComponent:checkConditionTrigger(ent, conditionIds)
	return PhotoConditionTrigger.checkCondition(ent, conditionIds)
end

function PhotoUIComponent:tryDoQuickPhoto()
	if not self.quickPhotoEntities then
		return
	end

	local identifyData = PhotoIdentifyData[self.quickPhotoId]
	local fixCamera = identifyData.quickTakePhotoDistance == nil

	self.inQuickPhoto = true

	if not fixCamera then
		local mainTarget = self.quickPhotoEntities[1]

		if mainTarget then
			local len, rotation, pivotOffset = self:getMainTargetCameraOffset()

			pg.game.camera:startQuickPhotoFaceToByActorId(mainTarget.actorId, pivotOffset, rotation, len)
		end
	else
		pg.game.camera:startQuickPhotoCameraFix(Vector3(identifyData.cameraPosition[1], identifyData.cameraPosition[2], identifyData.cameraPosition[3]), Quaternion.Euler(identifyData.cameraRotation[1], identifyData.cameraRotation[2], identifyData.cameraRotation[3]), identifyData.cameraFov)
	end
end

function PhotoUIComponent:getTargetPos()
	if self.quickPhotoEntities then
		-- block empty
	end

	return nil, nil
end

function PhotoUIComponent:getMainTargetCameraOffset()
	if self.quickPhotoEntities then
		local entCenterPos = self.quickPhotoEntities[1]:getPosition()
		local height = self.quickPhotoEntities[1]:getTopLogoHeight()
		local playerCameraPos = pg.game.camera.playerCameraMode.cameraMode:GetCameraView().pivotLocation
		local identifyConfig = PhotoIdentifyData[self.quickPhotoId]
		local photoDist = identifyConfig.quickTakePhotoDistance
		local targetPos = entCenterPos - playerCameraPos
		local forward = targetPos:Normalize()
		local rotation = Quaternion.LookRotation(forward, Vector3.up)

		return photoDist, rotation, Vector3(0, height / 2, 0)
	end
end

function PhotoUIComponent:clearUpdateTimer()
	if self.updateTimer then
		self.ctrl:killTimer(self.updateTimer)

		self.updateTimer = nil
	end
end

function PhotoUIComponent:enterPhotoAITrait(data)
	if data.photoId == nil then
		return
	end

	if ClientUtils.checkPhotoTraitIsUnlock(data.photoId) or not ClientUtils.checkPhotoPetIsUnlock(data.photoId) then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			logger:debug("enterPhotoAITrait return:")
		end

		return
	end

	if self.curAITraitPhotoId ~= nil then
		table.insert(self.waitAITraitPhotoInfos, data)

		return
	end

	local photoCfg = PhotoIdentifyData[data.photoId]

	if photoCfg == nil then
		return
	end

	pg.me:tryRefreshAiIds(true, photoCfg.beforeText, false)

	self.curAITraitPhotoId = data.photoId
	self.curAITraitPointId = data.fixPointId
	self.curAITraitData = self.curPlayingAiTrait[data.photoId]
	self.curAITraitPointState = self.curAITraitData and self.TraitPointState.Playing or self.TraitPointState.Before
end

function PhotoUIComponent:leavePhotoAITrait(data)
	if data.photoId == nil then
		return
	end

	if self.curAITraitPhotoId ~= data.photoId then
		local index = -1

		for i, value in ipairs(self.waitAITraitPhotoInfos) do
			if value.photoId == data.photoId then
				index = i

				break
			end
		end

		if index ~= -1 then
			table.remove(self.waitAITraitPhotoInfos, index)
		end

		return
	end

	self:tryClearCurPhotoAiTrait()
end

function PhotoUIComponent:tryClearCurPhotoAiTrait()
	self.curAITraitPhotoId = nil
	self.curAITraitPointId = nil
	self.curAITraitData = nil

	if self.waitAITraitPhotoInfos[1] then
		self:enterPhotoAITrait(self.waitAITraitPhotoInfos[1])
		table.remove(self.waitAITraitPhotoInfos, 1)
	end
end

function PhotoUIComponent:onAITraitStart(data)
	if data.photoId == nil then
		return
	end

	self.curPlayingAiTrait[data.photoId] = data

	if self.curAITraitPhotoId ~= data.photoId then
		return
	end

	self.curAITraitPointState = self.TraitPointState.Playing
	self.curAITraitData = data

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_PHOTO) then
		pg.global.ui.photo:refreshAITraitPhoto(data)
	end
end

function PhotoUIComponent:onAITraitEnd(data)
	if data.photoId == nil then
		return
	end

	self.curPlayingAiTrait[data.photoId] = nil

	if self.curAITraitPhotoId ~= data.photoId then
		return
	end

	self.curAITraitPointState = self.TraitPointState.After

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_PHOTO) then
		pg.global.ui.photo:refreshAITraitPhoto()
	end

	self.curAITraitData = nil
end

function PhotoUIComponent:onDestroy()
	self:clearAllPhotoTopLogo()
	self:clearUpdateTimer()
	UIComponent.onDestroy(self)
end

return PhotoUIComponent
