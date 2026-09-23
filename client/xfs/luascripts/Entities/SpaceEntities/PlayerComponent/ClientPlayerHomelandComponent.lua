-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientPlayerHomelandComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local class = require("Core.Framework.Class")
local CallbackHandler = require("Core.Common.CallbackHandler")
local MessageName = require("Const.MessageName")
local Const = require("Common.Const.Const")
local OpDef = require("Common.OpDef")
local NoticeDef = require("Common.NoticeDef")
local HomeObjectData = require("Data.home_object_data")
local HomeObjectPlaceData = require("Data.home_object_place_data")
local HomelandAreaData = require("Data.homeland_area_data")
local Utils = require("Common.Utils.Utils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local HomelandWishStarData = require("Common.Homeland.HomelandWishStarData")
local HomeBlueprintConst = require("Common.Const.HomeBlueprintConst")
local HomelandFacilityData = require("Data.homeland_facility_data")
local HomelandDemoCmdImplement = require("GameApp.CmdSocket.HomelandDemoCmdImplement")
local ClientUtils = require("Utils.ClientUtils")
local ClientPlayerHomelandComponent = class.Component("ClientPlayerHomelandComponent")

function ClientPlayerHomelandComponent:ctor()
	self._isDeleteHomeBlueprintBuildGroupRequesting = false
	self._homeVoucherCollectRequestSerial = 0
end

function ClientPlayerHomelandComponent:init(avtDict)
	self.simulateOutputMap = {}
	self.simulateOutputDuration = 0
	self.simulateOutputMapReady = false
	self.homeBlueprintCache = {}
	self.homeBlueprintCoverImageCache = {}
	self.homeBlueprintCoverRequestSerial = 0

	return true
end

function ClientPlayerHomelandComponent:onEnterSpace()
	self._homeVoucherCollectRequestSerial = self._homeVoucherCollectRequestSerial + 1

	HomelandWishStarData.reset()

	self.simulateOutputMap = {}
	self.simulateOutputDuration = 0
	self.simulateOutputMapReady = false

	if self:isInSelfHomeland() then
		self:serverMsg("RPC_CS_GetSimulateOutputRecord", CallbackHandler(self, "onGetSimulateOutputRecord"))
	end
end

function ClientPlayerHomelandComponent:onGetSimulateOutputRecord(simulateOutputMap, simulateOutputDuration)
	self.simulateOutputMap = simulateOutputMap or {}
	self.simulateOutputDuration = math.max(simulateOutputDuration or 0, 0)
	self.simulateOutputMapReady = true

	if self.space and self.space.checkAndShowLoginEventList then
		self.space:checkAndShowLoginEventList()
	end
end

function ClientPlayerHomelandComponent:destroy()
	self._homeVoucherCollectRequestSerial = self._homeVoucherCollectRequestSerial + 1

	HomelandWishStarData.reset()
	self:clearHomeBlueprintCoverImageCache()
end

function ClientPlayerHomelandComponent:requestCollectHomeVoucher(ornamentId, sourceEntityId)
	self._homeVoucherCollectRequestSerial = self._homeVoucherCollectRequestSerial + 1

	local requestSerial = self._homeVoucherCollectRequestSerial

	self:serverMsg("RPC_CS_CollectHomeVoucher", ornamentId, CallbackHandler(self, "onCollectHomeVoucher", requestSerial, sourceEntityId))
end

function ClientPlayerHomelandComponent:onCollectHomeVoucher(requestSerial, sourceEntityId, success, noticeId, _ornamentId, collectNum)
	if requestSerial ~= self._homeVoucherCollectRequestSerial then
		return
	end

	if success then
		HomelandWishStarData.notifyServerCollected(collectNum, sourceEntityId)
	else
		HomelandWishStarData.clearCollectPending()
		pg.global.showBubbleMessage(noticeId or NoticeDef.FAIL)
	end
end

function ClientPlayerHomelandComponent:RPC_SC_HomeVoucherSnapshot(current, capacity, produceRatePerSecond, timestamp, isProducing, petOutputs)
	if not self:isInSelfHomeland() then
		return
	end

	HomelandWishStarData.setServerSnapshot(current, capacity, produceRatePerSecond, timestamp, isProducing, petOutputs)
end

function ClientPlayerHomelandComponent:isPetPutInHomeland(petInfo)
	if not petInfo or not petInfo.id then
		return false
	end

	return self.petPutInHomelandMap and self.petPutInHomelandMap[petInfo.id] == true or false
end

function ClientPlayerHomelandComponent:on_petPutInHomelandMap_entry_added(petId, value)
	facade:sendMsgToUI(MessageName.PET_IS_PUT_IN_HOME_CHANGED, {
		petId = petId
	})
end

function ClientPlayerHomelandComponent:on_petPutInHomelandMap_entry_deleted(petId, value)
	facade:sendMsgToUI(MessageName.PET_IS_PUT_IN_HOME_CHANGED, {
		petId = petId
	})
end

function ClientPlayerHomelandComponent:queryHomelandSyncInfo(uid, callback)
	uid = uid or self.uid
	callback = callback or function(syncInfo)
		self.logger:debug("homeQuery syncInfo=%s", inspect(syncInfo:getRawTable()))
	end

	self:callService("UserDataService", "getAttribute", {
		uid,
		{
			"homelandSyncInfo"
		}
	}, function(result, response)
		local syncData = result.status and response.AttributesMap and response.AttributesMap.homelandSyncInfo or {}
		local syncInfo = require("CustomTypes.HomelandSyncInfo")(syncData)

		callback(syncInfo)
	end, {
		callerId = uid
	})
end

function ClientPlayerHomelandComponent:isInHomeland()
	return Utils.isSceneHomeland(self.space.sceneId)
end

function ClientPlayerHomelandComponent:isInSelfHomeland()
	return self.space and self.space.isSelfHomeland and self.space:isSelfHomeland(self)
end

function ClientPlayerHomelandComponent:checkHomelandAddOrnament(ornamentId, position, rotation)
	return true
end

function ClientPlayerHomelandComponent:checkHomelandRemoveOrnament(ornamentId, ornamentInfo)
	return true
end

function ClientPlayerHomelandComponent:checkHomelandAddPet(petId)
	return true
end

function ClientPlayerHomelandComponent:on_unlockHomelandZone_added(k, v)
	facade:sendMsgToUI(MessageName.HOMELAND_ZONE_CONDITION_UNLOCK)
end

function ClientPlayerHomelandComponent:on_unlockedHomelandFormulaMap_entry_added(formulaId, value)
	facade:sendMsgToUI(MessageName.HOMELAND_DRAWING_UNLOCK_CHANGED, {
		formulaId = formulaId
	})
end

function ClientPlayerHomelandComponent:on_unlockedHomelandFormulaMap_entry_deleted(formulaId, value)
	facade:sendMsgToUI(MessageName.HOMELAND_DRAWING_UNLOCK_CHANGED, {
		formulaId = formulaId
	})
end

function ClientPlayerHomelandComponent:on_unlockedHomelandFurnitureMap_entry_added(itemId, value)
	facade:sendMsgToUI(MessageName.HOMELAND_DRAWING_UNLOCK_CHANGED, {
		itemId = itemId
	})
end

function ClientPlayerHomelandComponent:on_unlockedHomelandFurnitureMap_entry_deleted(itemId, value)
	facade:sendMsgToUI(MessageName.HOMELAND_DRAWING_UNLOCK_CHANGED, {
		itemId = itemId
	})
end

function ClientPlayerHomelandComponent:on_statHomelandOrnament_changed(ov, nv)
	facade:sendMsgToUI(MessageName.HOMELAND_STAT_HOMELAND_ORNAMENT_CHANGED)
end

function ClientPlayerHomelandComponent:getStatUnlockHomelandZone(zoneId)
	return self.statUnlockHomelandZone[zoneId] or 0
end

function ClientPlayerHomelandComponent:getUnlockHomelandZoneCount()
	if self.statUnlockHomelandZone[0] then
		return self.statUnlockHomelandZone[0]
	end

	local count = 0

	for zoneId, unlock in pairs(self.statUnlockHomelandZone) do
		if unlock then
			count = count + 1
		end
	end

	return count
end

function ClientPlayerHomelandComponent:getOrnamentMaxPlaceNum(templateId)
	local homeObjectInfo = HomeObjectData[templateId]

	if not homeObjectInfo then
		return 0
	end

	if not homeObjectInfo.placeId then
		return homeObjectInfo.maxNum or Const.HOMELAND_ORNAMENT_DEFAULT_MAX_PLACE_NUM
	end

	local placeData = HomeObjectPlaceData[homeObjectInfo.placeId] or {}
	local homeCarInfo = pg.me.homeBasicInfo:getRawTable() or {}
	local homeCarLevel = homeCarInfo.level or 0

	for i = homeCarLevel, 1, -1 do
		if placeData[i] then
			return placeData[i].getWay or 0
		end
	end

	return 0
end

function ClientPlayerHomelandComponent:countOrnamentPlaceNum(statTable, templateId)
	local placeHomeObjData = HomeObjectData[templateId]

	if not placeHomeObjData then
		return 0
	end

	local placeId = placeHomeObjData.placeId
	local count = 0

	for homeId, num in pairs(statTable) do
		if homeId ~= 0 then
			if placeId then
				local homeObjectInfo = HomeObjectData[homeId] or {}

				if homeObjectInfo.placeId == placeId then
					count = count + num
				end
			elseif homeId == templateId then
				count = count + num
			end
		end
	end

	return count
end

function ClientPlayerHomelandComponent:getOrnamentHomelandCurPlaceNum(templateId)
	return self:countOrnamentPlaceNum(self.statHomelandOrnament, templateId)
end

function ClientPlayerHomelandComponent:getOrnamentCurPlaceNum(templateId)
	return self:getOrnamentHomelandCurPlaceNum(templateId) + pg.me:getOrnamentCarCurPlaceNum(templateId)
end

function ClientPlayerHomelandComponent:getOrnamentAreaMaxPlaceNum(templateId, areaId)
	if not HomeLandUtils.isOrnamentAreaAllowed(templateId, areaId) then
		return 0
	end

	local baseMax = self:getOrnamentMaxPlaceNum(templateId)
	local areaData = HomelandAreaData[areaId]
	local ratio = areaData and areaData.placeNumRatio or 1

	return math.ceil(baseMax * ratio)
end

function ClientPlayerHomelandComponent:getOrnamentTotalMaxPlaceNum(templateId)
	local baseMax = self:getOrnamentMaxPlaceNum(templateId)
	local areaIds = HomeLandUtils.getOrnamentAreaIds(templateId)
	local total = 0

	for _, areaId in ipairs(areaIds) do
		local areaData = HomelandAreaData[areaId]
		local ratio = areaData and areaData.placeNumRatio or 1

		total = total + math.ceil(baseMax * ratio)
	end

	return total
end

function ClientPlayerHomelandComponent:buildOrnamentAreaSnapshot()
	local snapshot = {}

	if self.space and self.space.ornament then
		for _, ornamentInfo in pairs(self.space.ornament) do
			local aId = ornamentInfo.areaId or 0
			local homeId = ornamentInfo.homeId
			local areaStat = snapshot[aId]

			if areaStat == nil then
				areaStat = {}
				snapshot[aId] = areaStat
			end

			areaStat[homeId] = (areaStat[homeId] or 0) + 1
		end
	end

	self._ornamentAreaSnapshot = snapshot
end

function ClientPlayerHomelandComponent:clearOrnamentAreaSnapshot()
	self._ornamentAreaSnapshot = nil
end

function ClientPlayerHomelandComponent:getOrnamentAreaCurPlaceNum(templateId, areaId)
	local placeHomeObjData = HomeObjectData[templateId]

	if not placeHomeObjData then
		return 0
	end

	local placeId = placeHomeObjData.placeId

	if self._ornamentAreaSnapshot then
		local areaStat = self._ornamentAreaSnapshot[areaId or 0]

		if not areaStat then
			return 0
		end

		if not placeId then
			return areaStat[templateId] or 0
		end

		local snapCount = 0

		for homeId, num in pairs(areaStat) do
			local homeObjectInfo = HomeObjectData[homeId] or {}

			if homeObjectInfo.placeId == placeId then
				snapCount = snapCount + num
			end
		end

		return snapCount
	end

	if not self.space or not self.space.ornament then
		return 0
	end

	local count = 0

	for _, ornamentInfo in pairs(self.space.ornament) do
		local ornamentAreaId = ornamentInfo.areaId or 0

		if ornamentAreaId == areaId then
			local homeId = ornamentInfo.homeId

			if placeId then
				local homeObjectInfo = HomeObjectData[homeId] or {}

				if homeObjectInfo.placeId == placeId then
					count = count + 1
				end
			elseif homeId == templateId then
				count = count + 1
			end
		end
	end

	return count
end

function ClientPlayerHomelandComponent:checkCanSetElectricMode(ornamentInfo)
	if not ornamentInfo then
		return false
	end

	local facilityId = Utils.getHomeObjectFacilityId(ornamentInfo.homeId)
	local facilityData = HomelandFacilityData[facilityId]

	if facilityData.facilityType ~= Const.HOMELAND_FACILITY_TYPE.ElectricReqSwitch then
		return false
	end

	if not facilityData.electricModeUnlockLevel then
		return true
	end

	if not self.homeBasicInfo then
		return false
	end

	local curLevel = self.homeBasicInfo.level

	return curLevel >= facilityData.electricModeUnlockLevel
end

function ClientPlayerHomelandComponent:unlockHomeland()
	self:serverMsg("RPC_CS_UnlockHomeland")
end

function ClientPlayerHomelandComponent:enterSelfHomeland()
	self:serverMsg("RPC_CS_ReqEnterSelfHomeland")
end

function ClientPlayerHomelandComponent:enterHomeland(homelandKey)
	self:serverMsg("RPC_CS_ReqEnterHomeland", homelandKey)
end

function ClientPlayerHomelandComponent:enterHomelandByUid(uid)
	if not uid then
		return
	end

	local hook = ClientPlayerHomelandComponent._platformHooks and ClientPlayerHomelandComponent._platformHooks.canEnterHomeland

	if hook and hook(self, uid, {}) == false then
		return
	end

	local attributesList = {
		"uid",
		"homelandKey"
	}

	self:callService("UserDataService", "getAttribute", {
		uid,
		attributesList
	}, CallbackHandler(self, "_homelandQueryPlayerInfoCallback"), {
		callerId = uid
	})
end

function ClientPlayerHomelandComponent:_homelandQueryPlayerInfoCallback(result, resp)
	if result.status then
		local respMap = resp.AttributesMap

		if respMap and respMap.homelandKey then
			self:enterHomeland(respMap.homelandKey)

			return
		else
			pg.global.ui.tips:showTextTip(pg.getGameString("HOMELAND_UNCREATED_VISIT"))
		end
	end
end

function ClientPlayerHomelandComponent:homelandSellMaterial(version, storeId, materialId, num, saleFeedback)
	self:serverMsg("RPC_CS_HomelandSellMaterials", version, storeId, materialId, num, CallbackHandler(self, "onHomelandSellMaterialCallback", saleFeedback))
end

function ClientPlayerHomelandComponent:onHomelandSellMaterialCallback(saleFeedback, code, storeId)
	if code ~= Const.HOMELAND_ORDER_OP_RETURN_CODE.SUCCESS then
		return
	end

	facade:sendMsgToUI(MessageName.HOMELAND_ON_SELL_MATERIAL, saleFeedback)
end

function ClientPlayerHomelandComponent:RPC_SC_NotifyMutationUnlock(itemIds)
	if type(itemIds) ~= "table" then
		return
	end

	if not pg.global.ui or not pg.global.ui.tips then
		return
	end

	for _, itemId in ipairs(itemIds) do
		pg.global.ui.tips:showMutationUnlockTip(itemId)
	end
end

function ClientPlayerHomelandComponent:RPC_SC_SyncFullHomelandHatchInfo(fullHatchInfo)
	local me = pg and pg.me or nil

	if me == nil or me.space == nil then
		return
	end

	me.space:setHatchBoxesInfo(fullHatchInfo)
	facade:sendMsgToUI(MessageName.HOMELAND_HATCH_SYNC_FULLINFO)
end

function ClientPlayerHomelandComponent:requestHomelandFoodOp(op, params, callback)
	local localCallback = callback or function(noticeId, noticeArgs)
		if pg.logDebug() then
			self.logger:debug("homeFood op=%s, res=%s", OpDef.repr(op, params), NoticeDef.getRepr(noticeId, noticeArgs), self:repr())
		end
	end

	self:serverMsg("RPC_CS_HomelandFoodOp", op, params, localCallback)
end

function ClientPlayerHomelandComponent:RPC_SC_HomelandFoodOp(op, params)
	if op == OpDef.OP.SC_HF_Refresh then
		facade:sendMsgToUI(MessageName.HOMELAND_FOOD_INFO_REFRESH, {})
	end

	if pg.logDebug() then
		self.logger:debug("homeFood op=%s", OpDef.repr(op, params), self:repr())
	end
end

function ClientPlayerHomelandComponent:showOrnamentNotice(returnCode)
	if returnCode == Const.HOMELAND_ORNAMENT_OP_RETURN_CODE.SUCCESS then
		pg.global.showBubbleMessage(NoticeDef.HOME_EDIT_SUCCESS)
	elseif returnCode == Const.HOMELAND_ORNAMENT_OP_RETURN_CODE.ERROR_CHECK_FAIL then
		pg.global.showBubbleMessage(NoticeDef.HOME_CHECK_FAILED)
	elseif returnCode == Const.HOMELAND_ORNAMENT_OP_RETURN_CODE.ERROR_NOT_HOME then
		pg.global.showBubbleMessage(NoticeDef.HOME_NOT_HOME)
	elseif returnCode == Const.HOMELAND_ORNAMENT_OP_RETURN_CODE.ERROR_PARAM then
		pg.global.showBubbleMessage(NoticeDef.HOME_ERROR_PARAM)
	elseif returnCode == Const.HOMELAND_ORNAMENT_OP_RETURN_CODE.ERROR_ORNAMENT_COUNT_MAX then
		pg.global.showBubbleMessage(NoticeDef.HOME_ERROR_ORNAMENT_COUNT_MAX)
	elseif returnCode == Const.HOMELAND_ORNAMENT_OP_RETURN_CODE.ERROR_ORNAMENT_NOT_EXIST then
		pg.global.showBubbleMessage(NoticeDef.HOME_ORNAMENT_NOT_EXIST)
	elseif returnCode == Const.HOMELAND_ORNAMENT_OP_RETURN_CODE.ERROR_ITEM_NOT_VALID then
		pg.global.showBubbleMessage(NoticeDef.HOME_ERROR_ITEM_NOT_VALID)
	elseif returnCode == Const.HOMELAND_ORNAMENT_OP_RETURN_CODE.ERROR_NOT_EDITABLE then
		pg.global.showBubbleMessage(NoticeDef.HOME_ERROR_NOT_EDITABLE)
	elseif returnCode == Const.HOMELAND_ORNAMENT_OP_RETURN_CODE.ERROR_NOT_TRASH then
		pg.global.showBubbleMessage(NoticeDef.HOME_ERROR_NOT_TRASH)
	elseif returnCode == Const.HOMELAND_ORNAMENT_OP_RETURN_CODE.ERROR_NOT_HOME_CAR then
		pg.global.showBubbleMessage(NoticeDef.HOME_CAR_CAMP_NOT_IN_CAMP)
	elseif returnCode == Const.HOMELAND_ORNAMENT_OP_RETURN_CODE.ERROR_NOT_FIND_CAR then
		pg.global.showBubbleMessage(NoticeDef.HOME_CAR_CAMP_SELF_CAR_NOT_FIND)
	elseif returnCode == Const.HOMELAND_ORNAMENT_OP_RETURN_CODE.ERROR_HOMECAR_ORNAMENT_COUNT_MAX then
		pg.global.showBubbleMessage(NoticeDef.HOME_CAR_CAMP_ORNAMENT_COUNT_MAX)
	elseif returnCode == Const.HOMELAND_ORNAMENT_OP_RETURN_CODE.ERROR_ITEM_NOT_ENOUGH then
		pg.global.showBubbleMessage(NoticeDef.HOME_CAR_UPGRADE_ITEM_LACK_INHOME)
	end
end

function ClientPlayerHomelandComponent:reqGetPlantReward(formulaId)
	return
end

function ClientPlayerHomelandComponent:reqGetPlantProcessReward(processId)
	return
end

function ClientPlayerHomelandComponent:reqSendPlantToFriend(friendUid, itemDict)
	return
end

function ClientPlayerHomelandComponent:reqSetPlantAutoCollectSwitch(itemId, enabled)
	self:serverMsg("RPC_CS_SetPlantAutoCollectSwitch", itemId, enabled)
end

function ClientPlayerHomelandComponent:reqSolveMutationEvent(itemId)
	self:serverMsg("RPC_CS_SolveMutationEvent", itemId)
end

function ClientPlayerHomelandComponent:reqSolveTillHelpEvents()
	self:serverMsg("RPC_CS_SolveTillHelpEvents")
end

function ClientPlayerHomelandComponent:onHomePlantSinglePlantReward_changed(ov, nv)
	facade:sendMsgToUI(MessageName.ON_HOME_PLANT_SINGLE_REWARD_CHANGED)
end

function ClientPlayerHomelandComponent:onHomePlantProcessReward_changed(ov, nv)
	facade:sendMsgToUI(MessageName.ON_HOME_PLANT_PROCESS_REWARD_CHANGED)
end

function ClientPlayerHomelandComponent:onHomePlantCollection_changed(ov, nv)
	facade:sendMsgToUI(MessageName.ON_HOME_PLANT_COLLECTION_CHANGED)
end

function ClientPlayerHomelandComponent:onPinnedFormulaList_changed(ov, nv)
	facade:sendMsgToUI(MessageName.HOME_FORMULA_TRACKING_CHANGED)
end

function ClientPlayerHomelandComponent:requestSetPinnedFormulas(formulaIds, callback)
	local function localCallback(code)
		if code == Const.HOMELAND_ORNAMENT_OP_RETURN_CODE.SUCCESS and callback then
			callback()
		end
	end

	self:serverMsg("RPC_CS_SetPinnedFormulas", formulaIds, localCallback)
end

function ClientPlayerHomelandComponent:RPC_SC_HomelandDemoReset()
	HomelandDemoCmdImplement._resetDemoFlowState()
end

function ClientPlayerHomelandComponent:destroyHomeBlueprintCoverSprite(sprite)
	if sprite and NotNil(sprite) then
		pg.global.mobileCameraMgr:DestroySpriteTexture(sprite)
	end
end

function ClientPlayerHomelandComponent:loadHomeBlueprintCoverImage(imageKey, callback)
	if string.isNilOrEmpty(imageKey) then
		return false
	end

	local imageCache = self.homeBlueprintCoverImageCache

	if not imageCache then
		return false
	end

	local cachedSprite = imageCache[imageKey]

	if cachedSprite and NotNil(cachedSprite) then
		if callback then
			callback(cachedSprite, imageKey)
		end

		return true
	elseif cachedSprite then
		imageCache[imageKey] = nil
	end

	local requestSerial = self.homeBlueprintCoverRequestSerial

	ClientUtils.pullPicture(imageKey, function(resultKey, sprite)
		if requestSerial ~= self.homeBlueprintCoverRequestSerial then
			self:destroyHomeBlueprintCoverSprite(sprite)

			return
		end

		if resultKey ~= imageKey or not sprite or not NotNil(sprite) then
			self:destroyHomeBlueprintCoverSprite(sprite)

			return
		end

		local currentSprite = self.homeBlueprintCoverImageCache[imageKey]

		if currentSprite and NotNil(currentSprite) then
			if currentSprite ~= sprite then
				self:destroyHomeBlueprintCoverSprite(sprite)
			end

			sprite = currentSprite
		else
			self.homeBlueprintCoverImageCache[imageKey] = sprite
		end

		if callback then
			callback(sprite, imageKey)
		end
	end)

	return true
end

function ClientPlayerHomelandComponent:cacheHomeBlueprintCoverImage(imageKey, sprite)
	if string.isNilOrEmpty(imageKey) or not sprite or not NotNil(sprite) or not self.homeBlueprintCoverImageCache then
		return false
	end

	local oldSprite = self.homeBlueprintCoverImageCache[imageKey]

	self.homeBlueprintCoverImageCache[imageKey] = sprite

	if oldSprite and oldSprite ~= sprite then
		self:destroyHomeBlueprintCoverSprite(oldSprite)
	end

	return true
end

function ClientPlayerHomelandComponent:removeHomeBlueprintCoverImage(imageKey)
	if string.isNilOrEmpty(imageKey) or not self.homeBlueprintCoverImageCache then
		return false
	end

	local sprite = self.homeBlueprintCoverImageCache[imageKey]

	if not sprite then
		return false
	end

	self.homeBlueprintCoverImageCache[imageKey] = nil

	self:destroyHomeBlueprintCoverSprite(sprite)

	return true
end

function ClientPlayerHomelandComponent:clearHomeBlueprintCoverImageCache()
	self.homeBlueprintCoverRequestSerial = (self.homeBlueprintCoverRequestSerial or 0) + 1

	local destroyedSprites = {}

	for _, sprite in pairs(self.homeBlueprintCoverImageCache or EMPTY_TABLE) do
		if sprite and NotNil(sprite) and not destroyedSprites[sprite] then
			destroyedSprites[sprite] = true

			self:destroyHomeBlueprintCoverSprite(sprite)
		end
	end

	if self.homeBlueprintCoverImageCache then
		table.clear(self.homeBlueprintCoverImageCache)
	end
end

function ClientPlayerHomelandComponent:showBlueprintNotice(code)
	local RETURN_CODE = Const.HOME_BLUEPRINT_OP_RETURN_CODE

	if code == RETURN_CODE.SUCCESS then
		return
	elseif code == RETURN_CODE.ERROR_NOT_HOME then
		pg.global.showBubbleMessage(NoticeDef.HOME_NOT_HOME)
	elseif code == RETURN_CODE.ERROR_PARAM then
		pg.global.showBubbleMessage(NoticeDef.HOME_ERROR_PARAM)
	elseif code == RETURN_CODE.ERROR_ORNAMENT_NOT_EXIST then
		pg.global.showBubbleMessage(NoticeDef.HOME_ORNAMENT_NOT_EXIST)
	elseif code == RETURN_CODE.ERROR_NOT_EDITABLE then
		pg.global.showBubbleMessage(NoticeDef.HOME_ERROR_NOT_EDITABLE)
	elseif code == RETURN_CODE.ERROR_ORNAMENT_COUNT_MAX then
		pg.global.showBubbleMessage(NoticeDef.HOME_ERROR_ORNAMENT_COUNT_MAX)
	elseif code == RETURN_CODE.ERROR_ITEM_NOT_ENOUGH then
		pg.global.showBubbleMessage(NoticeDef.HOME_BLUEPRINT_ERROR_ITEM_NOT_ENOUGH)
	elseif code == RETURN_CODE.ERROR_TEXT_SENSITIVE then
		pg.global.showBubbleMessage(NoticeDef.HOME_BLUEPRINT_ERROR_TEXT_SENSITIVE)
	elseif code == RETURN_CODE.ERROR_LIMIT_REACHED then
		pg.global.showBubbleMessage(NoticeDef.HOME_BLUEPRINT_ERROR_LIMIT_REACHED)
	elseif code == RETURN_CODE.ERROR_CODE_INVALID then
		pg.global.showBubbleMessage(NoticeDef.HOME_BLUEPRINT_ERROR_CODE_INVALID)
	elseif code == RETURN_CODE.ERROR_EXTERNAL_LINK then
		pg.global.showBubbleMessage(NoticeDef.HOME_BLUEPRINT_ERROR_EXTERNAL_LINK)
	elseif code == RETURN_CODE.ERROR_SYSTEM_BLUEPRINT_INVALID then
		pg.global.showBubbleMessage(NoticeDef.HOME_BLUEPRINT_ERROR_SYSTEM_BLUEPRINT_INVALID)
	elseif code == RETURN_CODE.ERROR_SERVICE then
		pg.global.showBubbleMessage(NoticeDef.HOME_BLUEPRINT_ERROR_SERVICE)
	elseif code == RETURN_CODE.ERROR_AREA_LOAD_LIMIT then
		pg.global.showBubbleMessage(NoticeDef.HOME_BLUEPRINT_ERROR_AREA_LOAD_LIMIT)
	elseif code == RETURN_CODE.ERROR_SELF_BULEPRINT then
		pg.global.showBubbleMessage(NoticeDef.HOME_BLUEPRINT_ERROR_SELF_BULEPRINT)
	else
		pg.global.showBubbleMessage(NoticeDef.ERROR_SERVICE_CALLBACK)
	end
end

function ClientPlayerHomelandComponent:RPC_SC_HomeBlueprintOp(op, response)
	response = response or {}

	if op == "Upload" then
		if not response.flag then
			self:showBlueprintNotice(response.code)
		else
			pg.global.ui.tips:showTextTip(pg.getGameString("HOMELAND_COMPOSE_CREATE_SUCCESS"))

			local blueprint = response.blueprint
			local sourceType = HomeBlueprintConst.SOURCE_TYPE.UPLOADED

			if self.homeBlueprintCache and type(blueprint) == "table" then
				local list = self.homeBlueprintCache[sourceType]

				if list then
					local blueprintId = blueprint._id
					local hasSameBlueprint = false

					if blueprintId then
						for _, cacheBlueprint in ipairs(list) do
							if cacheBlueprint and cacheBlueprint._id == blueprintId then
								hasSameBlueprint = true

								break
							end
						end
					end

					blueprint.sourceType = sourceType

					if not hasSameBlueprint then
						table.insert(list, blueprint)
					end

					response.sourceType = sourceType

					facade:sendMsgToUI(MessageName.HOMELAND_BLUEPRINT_UPLOAD_RESULT, response)
				end
			end
		end
	elseif op == "UpdateUploaded" then
		if not response.flag then
			self:showBlueprintNotice(response.code)
		else
			pg.global.ui.tips:showTextTip(pg.getGameString("HOMELAND_COMPOSE_UPDATE_SUCCESS"))

			local blueprint = response.blueprint
			local sourceType = HomeBlueprintConst.SOURCE_TYPE.UPLOADED

			if type(blueprint) == "table" then
				blueprint.sourceType = sourceType

				local list = self.homeBlueprintCache and self.homeBlueprintCache[sourceType]
				local blueprintId = blueprint._id

				if list and blueprintId then
					for i, cacheBlueprint in ipairs(list) do
						if cacheBlueprint and cacheBlueprint._id == blueprintId then
							list[i] = blueprint

							break
						end
					end

					response.sourceType = sourceType

					facade:sendMsgToUI(MessageName.HOMELAND_BLUEPRINT_UPLOAD_RESULT, response)
				end
			end
		end
	elseif op == "DeleteUploaded" then
		if not response.flag then
			self:showBlueprintNotice(response.code)
		else
			pg.global.ui.tips:showTextTip(pg.getGameString("HOMELAND_COMPOSE_DELETE_SUCCESS"))

			local sourceType = HomeBlueprintConst.SOURCE_TYPE.UPLOADED
			local deletedCode = response.blueprintId

			response.sourceType = sourceType

			if deletedCode then
				local list = self.homeBlueprintCache[sourceType]

				if list then
					for i = #list, 1, -1 do
						local blueprint = list[i]

						if blueprint and blueprint._id == deletedCode then
							table.remove(list, i)
						end
					end
				end
			end

			facade:sendMsgToUI(MessageName.HOMELAND_BLUEPRINT_DELETE_UPLOADED_RESULT, response)
		end
	elseif op == "SaveOther" then
		if not response.flag then
			self:showBlueprintNotice(response.code)
		else
			pg.global.ui.tips:showTextTip(pg.getGameString("HOMELAND_COMPOSE_IMPORT_SUCCESS"))

			local blueprint = response.blueprint
			local sourceType = HomeBlueprintConst.SOURCE_TYPE.SAVED_OTHER

			if self.homeBlueprintCache and type(blueprint) == "table" then
				local list = self.homeBlueprintCache[sourceType]

				if list then
					local blueprintId = blueprint._id
					local hasSameBlueprint = false

					if blueprintId then
						for i, cacheBlueprint in ipairs(list) do
							if cacheBlueprint and cacheBlueprint._id == blueprintId then
								list[i] = blueprint
								hasSameBlueprint = true

								break
							end
						end
					end

					blueprint.sourceType = sourceType

					if not hasSameBlueprint then
						table.insert(list, blueprint)
					end

					response.sourceType = sourceType

					facade:sendMsgToUI(MessageName.HOMELAND_BLUEPRINT_UPLOAD_RESULT, response)
				end
			end
		end
	elseif op == "DeleteSavedOther" then
		if not response.flag then
			self:showBlueprintNotice(response.code)
		else
			pg.global.ui.tips:showTextTip(pg.getGameString("HOMELAND_COMPOSE_DELETE_SUCCESS"))

			local sourceType = HomeBlueprintConst.SOURCE_TYPE.SAVED_OTHER
			local deletedCode = response.blueprintId

			response.sourceType = sourceType

			if deletedCode then
				local list = self.homeBlueprintCache[sourceType]

				if list then
					for i = #list, 1, -1 do
						local blueprint = list[i]

						if blueprint and blueprint._id == deletedCode then
							table.remove(list, i)
						end
					end

					facade:sendMsgToUI(MessageName.HOMELAND_BLUEPRINT_DELETE_UPLOADED_RESULT, response)
				end
			end
		end
	elseif op == "Build" then
		if not response.flag then
			self:showBlueprintNotice(response.code)
		end

		facade:sendMsgToUI(MessageName.HOMELAND_BLUEPRINT_BUILD_RESULT, response)
	elseif op == "List" then
		if not response.flag then
			self:showBlueprintNotice(response.code)
		else
			local sourceType = response.sourceType
			local list = response.list or {}

			if sourceType then
				self.homeBlueprintCache[sourceType] = list
			end
		end

		facade:sendMsgToUI(MessageName.HOMELAND_BLUEPRINT_LIST_RESULT, response)
	end
end

function ClientPlayerHomelandComponent:uploadHomeBlueprint(ornamentIdList, name, desc, coverImageKeys, size, callback)
	local function localCallback(errorCode, detail)
		local isSucc = errorCode == Const.HOME_BLUEPRINT_OP_RETURN_CODE.SUCCESS

		if not isSucc then
			self:showBlueprintNotice(errorCode)
		end

		if callback then
			callback(isSucc)
		end
	end

	self:serverMsg("RPC_CS_UploadHomeBlueprint", ornamentIdList, name, desc or "", coverImageKeys or {}, size, localCallback)
end

function ClientPlayerHomelandComponent:updateUploadedHomeBlueprint(code, name, desc, coverImageKeys, callback)
	local function localCallback(errorCode, detail)
		local isSucc = errorCode == Const.HOME_BLUEPRINT_OP_RETURN_CODE.SUCCESS

		if not isSucc then
			self:showBlueprintNotice(errorCode)
		end

		if callback then
			callback(isSucc)
		end
	end

	self:serverMsg("RPC_CS_UpdateUploadedHomeBlueprint", code, name, desc, coverImageKeys or {}, localCallback)
end

function ClientPlayerHomelandComponent:deleteUploadedHomeBlueprint(code, callback)
	local function localCallback(errorCode, detail)
		local isSucc = errorCode == Const.HOME_BLUEPRINT_OP_RETURN_CODE.SUCCESS

		if not isSucc then
			self:showBlueprintNotice(errorCode)
		end

		if callback then
			callback(isSucc, code)
		end
	end

	self:serverMsg("RPC_CS_DeleteUploadedHomeBlueprint", code, localCallback)
end

function ClientPlayerHomelandComponent:saveOtherHomeBlueprint(code, callback)
	local function localCallback(errorCode, detail)
		local isSucc = errorCode == Const.HOME_BLUEPRINT_OP_RETURN_CODE.SUCCESS

		if not isSucc then
			self:showBlueprintNotice(errorCode)
		end

		if callback then
			callback(isSucc, code)
		end
	end

	self:serverMsg("RPC_CS_SaveOtherHomeBlueprint", code, localCallback)
end

function ClientPlayerHomelandComponent:deleteSavedOtherHomeBlueprint(savedId, callback)
	local function localCallback(errorCode, detail)
		local isSucc = errorCode == Const.HOME_BLUEPRINT_OP_RETURN_CODE.SUCCESS

		if not isSucc then
			self:showBlueprintNotice(errorCode)
		end

		if callback then
			callback(isSucc, savedId)
		end
	end

	self:serverMsg("RPC_CS_DeleteSavedOtherHomeBlueprint", savedId, localCallback)
end

function ClientPlayerHomelandComponent:buildHomeBlueprint(sourceType, blueprintId, targetPos3, targetYawAngle, areaId, callback)
	local function localCallback(errorCode, detail)
		local isSucc = errorCode == Const.HOME_BLUEPRINT_OP_RETURN_CODE.SUCCESS

		if not isSucc then
			self:showBlueprintNotice(errorCode)
		end

		if callback then
			callback(isSucc, errorCode, detail)
		end
	end

	self:serverMsg("RPC_CS_BuildHomeBlueprint", sourceType, blueprintId, targetPos3, targetYawAngle or 0, areaId, localCallback)
end

function ClientPlayerHomelandComponent:getHomeBlueprintTabList(sourceType, offset, limit, callback)
	if not sourceType then
		return
	end

	local function localCallback(errorCode, detail)
		local isSucc = errorCode == Const.HOME_BLUEPRINT_OP_RETURN_CODE.SUCCESS

		if not isSucc then
			self:showBlueprintNotice(errorCode)
		end

		if callback then
			callback(isSucc)
		end
	end

	offset = offset or 0
	limit = limit or 100

	self:serverMsg("RPC_CS_GetHomeBlueprintTabList", sourceType, offset, limit, localCallback)
end

function ClientPlayerHomelandComponent:isSystemHomeBlueprintVisible(blueprint)
	local showCondition = blueprint.showCondition

	if showCondition and showCondition ~= 0 and not self.triggerMap:isCompleteOrMeetCondition(showCondition) then
		return false
	end

	local hideCondition = blueprint.hideCondition

	if hideCondition and hideCondition ~= 0 and self.triggerMap:isCompleteOrMeetCondition(hideCondition) then
		return false
	end

	return true
end

function ClientPlayerHomelandComponent:getHomeBlueprintCachedList(sourceType, mode)
	local cacheInfo = self.homeBlueprintCache[sourceType]

	if not cacheInfo then
		pg.me:getHomeBlueprintTabList(sourceType, 0, 100)

		return
	end

	if sourceType ~= HomeBlueprintConst.SOURCE_TYPE.SYSTEM then
		return cacheInfo
	end

	local visibleList = {}

	for _, blueprint in ipairs(cacheInfo) do
		if self:isSystemHomeBlueprintVisible(blueprint) then
			table.insert(visibleList, blueprint)
		end
	end

	return visibleList
end

function ClientPlayerHomelandComponent:isDeleteHomeBlueprintBuildGroupRequesting()
	return self._isDeleteHomeBlueprintBuildGroupRequesting
end

function ClientPlayerHomelandComponent:deleteHomeBlueprintBuildGroup(groupIndex, callback)
	if self._isDeleteHomeBlueprintBuildGroupRequesting then
		return false
	end

	self._isDeleteHomeBlueprintBuildGroupRequesting = true

	local function localCallback(errorCode)
		self._isDeleteHomeBlueprintBuildGroupRequesting = false

		local isSucc = errorCode == Const.HOME_BLUEPRINT_OP_RETURN_CODE.SUCCESS

		if not isSucc then
			self:showBlueprintNotice(errorCode)
		end

		if callback then
			callback(isSucc, errorCode)
		end
	end

	self:serverMsg("RPC_CS_DeleteHomeBlueprintBuildGroup", groupIndex, localCallback)

	return true
end

function ClientPlayerHomelandComponent:clearAllHomeOrnaments(areaId, callback)
	local function localCallback(returnCode, ornamentIdList)
		self:showOrnamentNotice(returnCode)

		local isSucc = returnCode == Const.HOMELAND_ORNAMENT_OP_RETURN_CODE.SUCCESS

		if callback then
			callback(isSucc, returnCode, ornamentIdList or {})
		end
	end

	self:serverMsg("RPC_CS_ClearAllHomeOrnaments", areaId, localCallback)
end

return ClientPlayerHomelandComponent
