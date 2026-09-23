-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\HomelandComponent\\ClientHomelandPetsComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local ClientHomeBasePetsComponent = require("Entities.SpaceEntities.HomeBaseComponent.ClientHomeBasePetsComponent")
local logger = LoggerManager.getLogger("ClientHomelandOrnamentComponent", "Sandbox", LoggerConst.ERROR)
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local CallbackHandler = require("Core.Common.CallbackHandler")
local MessageName = require("Const.MessageName")
local NoticeDef = require("Common.NoticeDef")
local EventConst = require("Const.EventConst")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local ClientHomelandPetsComponent = Class.Component("ClientHomelandPetsComponent", ClientHomeBasePetsComponent)

function ClientHomelandPetsComponent:postInit(dict)
	ClientHomelandPetsComponent.super.postInit(self, dict)
	self:refreshHasFoodState(true)
end

function ClientHomelandPetsComponent:on_pets_changed(ov, nv, key)
	facade:sendMsgToUI(MessageName.HOMELAND_PETS_CHANGE, {
		petId = key
	})
end

function ClientHomelandPetsComponent:on_pets_added(k, v)
	facade:sendMsgToUI(MessageName.HOMELAND_PETS_CHANGE, {
		petId = k
	})
end

function ClientHomelandPetsComponent:on_pets_delete(k, v)
	facade:sendMsgToUI(MessageName.HOMELAND_PETS_CHANGE, {
		petId = k
	})
end

function ClientHomelandPetsComponent:on_petBoxMap_area_changed(ov, nv, areaId)
	facade:sendMsgToUI(MessageName.HOMELAND_PETS_CHANGE, {
		petId = 0,
		areaId = areaId
	})
end

function ClientHomelandPetsComponent:on_petBoxMap_area_added(areaId, boxInfo)
	facade:sendMsgToUI(MessageName.HOMELAND_PETS_CHANGE, {
		petId = 0,
		areaId = areaId
	})
end

function ClientHomelandPetsComponent:on_petBoxMap_area_deleted(areaId, boxInfo)
	facade:sendMsgToUI(MessageName.HOMELAND_PETS_CHANGE, {
		petId = 0,
		areaId = areaId
	})
end

function ClientHomelandPetsComponent:on_petExtraNum_changed(ov, nv)
	if ov < nv then
		facade:sendMsgToUI(MessageName.HOMELAND_PET_BOX_CAPACITY_CHANGED)
	end
end

function ClientHomelandPetsComponent:on_homeEventInsId_changed(ov, nv, key)
	self.logger:debug("@cyj on_homeEventInsId_changed", nv, key)

	local ent = pg.getEntity(key)

	if ent then
		ent:postComponentMethod("onHomelandAIPlanChanged")
		ent:postComponentMethod("onHomeEventChanged")
		ent.eventEmitter:emit(EventConst.HOMELAND_ACTION_STATE_CHANGED, {})
	end
end

function ClientHomelandPetsComponent:event_foodSlotNextRefreshTs_changed(ov, nv)
	self:refreshHasFoodState()
end

function ClientHomelandPetsComponent:checkHomePetHasFood()
	if self.demoMode then
		return true
	end

	local ok, GmToolUtils = pcall(require, "Utils.GmToolUtils")

	if ok and GmToolUtils and GmToolUtils.homeDemoModeOn == true then
		return true
	end

	return self.foodSlotNextRefreshTs > 0
end

function ClientHomelandPetsComponent:refreshHasFoodState(isInit)
	local homePetHasFood = self:checkHomePetHasFood()

	if self.homePetHasFood ~= homePetHasFood then
		self.homePetHasFood = homePetHasFood

		if not isInit then
			self:onHasFoodStateChanged()
		end
	end
end

function ClientHomelandPetsComponent:onHasFoodStateChanged()
	for petId, petInfo in pairs(self.pets) do
		local pet = pg.getEntity(petId)

		if pet then
			pet.eventEmitter:emit(EventConst.HOMELAND_WORK_STATE_CHANGED, {})
		end
	end
end

function ClientHomelandPetsComponent:addHomelandPet(petId, slotIdx, areaId)
	areaId = areaId or Const.HOMELAND_AREA_TYPE.PRODUCE

	if not pg.me or not pg.me:checkHomelandAddPet(petId) then
		self:onAddHomelandPetCallback(Const.HOMELAND_PET_OP_RETURN_CODE.ERROR_CHECK_FAIL, petId)

		return
	end

	if not HomeLandUtils.isHomePetBoxAreaSupported(areaId) then
		self:onAddHomelandPetCallback(Const.HOMELAND_PET_OP_RETURN_CODE.ERROR_AREA_NOT_SUPPORTED, petId)

		return
	end

	local replacedPetId = slotIdx and slotIdx > 0 and self.petBoxMap:getPetId(areaId, slotIdx)

	if not replacedPetId and not self.petBoxMap:canHoldPetCount(1) then
		self:onAddHomelandPetCallback(Const.HOMELAND_PET_OP_RETURN_CODE.ERROR_PET_COUNT_MAX, petId)

		return
	end

	pg.me:serverMsg("RPC_CS_AddHomelandPet", petId, areaId, slotIdx or -1, CallbackHandler(self, "onAddHomelandPetCallback"))
end

function ClientHomelandPetsComponent:addHomelandPetBatch(petIds, areaId)
	areaId = areaId or Const.HOMELAND_AREA_TYPE.PRODUCE

	if not pg.me or not petIds or #petIds <= 0 then
		return
	end

	if not HomeLandUtils.isHomePetBoxAreaSupported(areaId) then
		self:onAddHomelandPetCallback(Const.HOMELAND_PET_OP_RETURN_CODE.ERROR_AREA_NOT_SUPPORTED)

		return
	end

	if not self.petBoxMap:canHoldPetCount(#petIds) then
		self:onAddHomelandPetCallback(Const.HOMELAND_PET_OP_RETURN_CODE.ERROR_PET_COUNT_MAX)

		return
	end

	pg.me:serverMsg("RPC_CS_BatchAddHomelandPet", petIds, areaId, CallbackHandler(self, "onAddHomelandPetCallback"))
end

function ClientHomelandPetsComponent:onAddHomelandPetCallback(code, petId)
	self:showHomePetNotice(code)

	local isSucc = code == Const.HOMELAND_PET_OP_RETURN_CODE.SUCCESS

	pg.game.home.editor:onEditPetResult(isSucc, petId)
	facade:sendMsgToUI(MessageName.HOMELAND_PETS_CHANGE, {
		petId = petId
	})
end

function ClientHomelandPetsComponent:updateHomelandPetIndex(petId, toSlotIndex, areaId)
	if not pg.me then
		return
	end

	areaId = areaId or Const.HOMELAND_AREA_TYPE.PRODUCE

	if not HomeLandUtils.isHomePetBoxAreaSupported(areaId) then
		self:onUpdateHomelandPetIndexCallback(Const.HOMELAND_PET_OP_RETURN_CODE.ERROR_AREA_NOT_SUPPORTED, petId)

		return
	end

	local fromAreaId, fromSlotIndex = self.petBoxMap:getPetIndex(petId)

	pg.me:serverMsg("RPC_CS_UpdateHomelandPetIndex", petId, fromAreaId or Const.HOMELAND_AREA_TYPE.PRODUCE, fromSlotIndex or -1, areaId, toSlotIndex or -1, CallbackHandler(self, "onUpdateHomelandPetIndexCallback"))
end

function ClientHomelandPetsComponent:onUpdateHomelandPetIndexCallback(code, petId)
	self:showHomePetNotice(code)

	local isSucc = code == Const.HOMELAND_PET_OP_RETURN_CODE.SUCCESS

	if isSucc then
		facade:sendMsgToUI(MessageName.HOMELAND_PETS_CHANGE, {
			petId = petId
		})
	end
end

function ClientHomelandPetsComponent:updateHomelandPetIndexBatch(petIndexList, areaId)
	if not pg.me or not petIndexList or #petIndexList <= 0 then
		return
	end

	areaId = areaId or Const.HOMELAND_AREA_TYPE.PRODUCE

	if not HomeLandUtils.isHomePetBoxAreaSupported(areaId) then
		self:onUpdateHomelandPetIndexCallback(Const.HOMELAND_PET_OP_RETURN_CODE.ERROR_AREA_NOT_SUPPORTED, 0)

		return
	end

	self._updateHomelandPetIndexBatchSeq = (self._updateHomelandPetIndexBatchSeq or 0) + 1

	local batchId = self._updateHomelandPetIndexBatchSeq

	self._updateHomelandPetIndexBatchMap = self._updateHomelandPetIndexBatchMap or {}
	self._updateHomelandPetIndexBatchMap[batchId] = {
		hasError = false,
		finishedCount = 0,
		totalCount = #petIndexList
	}

	for _, petIndexInfo in ipairs(petIndexList) do
		local fromAreaId, currentSlotIndex = self.petBoxMap:getPetIndex(petIndexInfo.petId)
		local toAreaId = petIndexInfo.toAreaId or areaId

		pg.me:serverMsg("RPC_CS_UpdateHomelandPetIndex", petIndexInfo.petId, fromAreaId or petIndexInfo.fromAreaId or Const.HOMELAND_AREA_TYPE.PRODUCE, petIndexInfo.fromSlotIndex or currentSlotIndex or -1, toAreaId, petIndexInfo.formatIdx, CallbackHandler(self, "onUpdateHomelandPetIndexBatchCallback", batchId))
	end
end

function ClientHomelandPetsComponent:onUpdateHomelandPetIndexBatchCallback(batchId, code, petId)
	local batchInfo = self._updateHomelandPetIndexBatchMap and self._updateHomelandPetIndexBatchMap[batchId]

	if not batchInfo then
		return
	end

	batchInfo.finishedCount = batchInfo.finishedCount + 1

	if code ~= Const.HOMELAND_PET_OP_RETURN_CODE.SUCCESS then
		batchInfo.hasError = true

		self:showHomePetNotice(code)
	end

	if batchInfo.finishedCount >= batchInfo.totalCount then
		self._updateHomelandPetIndexBatchMap[batchId] = nil

		if not batchInfo.hasError then
			self:onUpdateHomelandPetIndexCallback(Const.HOMELAND_PET_OP_RETURN_CODE.SUCCESS, 0)
		else
			facade:sendMsgToUI(MessageName.HOMELAND_PETS_CHANGE, {
				petId = 0
			})
		end
	end
end

function ClientHomelandPetsComponent:updateHomelandPet(petId, position, rotation)
	if not pg.me or not pg.me:checkHomelandAddPet(petId) then
		self:onAddHomelandPetCallback({
			code = Const.HOMELAND_PET_OP_RETURN_CODE.ERROR_CHECK_FAIL
		})

		return
	end

	local placeInfo = self:createPetPlaceInfo(position, rotation)

	pg.me:serverMsg("RPC_CS_UpdateHomelandPetPosition", petId, placeInfo, CallbackHandler(self, "onUpdateHomelandPetCallback"))
end

function ClientHomelandPetsComponent:createPetPlaceInfo(position, rotation)
	local petPlaceInfo = {
		pos3 = Utils.positionToPos3(position),
		yawAngle = Utils.quaternionToYawAngleInt(rotation)
	}

	return petPlaceInfo
end

function ClientHomelandPetsComponent:onUpdateHomelandPetCallback(code, petId)
	self:showHomePetNotice(code)

	local isSucc = code == Const.HOMELAND_PET_OP_RETURN_CODE.SUCCESS

	pg.game.home.editor:onEditPetResult(isSucc, petId)
end

function ClientHomelandPetsComponent:removeHomelandPet(petId, boxId, slotId, areaId)
	if not pg.me or not self.pets[petId] then
		self:onRemoveHomelandPetCallback(Const.HOMELAND_PET_OP_RETURN_CODE.ERROR_PET_NOT_EXIST, petId)

		return
	end

	local actualAreaId, homeSlotIndex = self.petBoxMap:getPetIndex(petId)

	if areaId ~= nil and actualAreaId ~= areaId then
		self:onRemoveHomelandPetCallback(Const.HOMELAND_PET_OP_RETURN_CODE.ERROR_PET_NOT_EXIST, petId)

		return
	end

	areaId = actualAreaId or areaId or Const.HOMELAND_AREA_TYPE.PRODUCE

	pg.me:serverMsg("RPC_CS_RemoveHomelandPet", petId, areaId, homeSlotIndex or -1, boxId or -1, slotId or -1, CallbackHandler(self, "onRemoveHomelandPetCallback"))
end

function ClientHomelandPetsComponent:removeHomelandPetBatch(petIds, boxId, areaId)
	if not pg.me or not petIds or #petIds <= 0 then
		return
	end

	areaId = areaId or Const.HOMELAND_AREA_TYPE.PRODUCE

	if not HomeLandUtils.isHomePetBoxAreaSupported(areaId) then
		self:onRemoveHomelandPetCallback(Const.HOMELAND_PET_OP_RETURN_CODE.ERROR_AREA_NOT_SUPPORTED)

		return
	end

	local currentAreaPetIds = {}
	local homeSlotIndexes = {}

	for _, petId in ipairs(petIds) do
		local actualAreaId, homeSlotIndex = self.petBoxMap:getPetIndex(petId)

		if actualAreaId == areaId then
			currentAreaPetIds[#currentAreaPetIds + 1] = petId
			homeSlotIndexes[#homeSlotIndexes + 1] = homeSlotIndex or -1
		end
	end

	if #currentAreaPetIds <= 0 then
		self:onRemoveHomelandPetCallback(Const.HOMELAND_PET_OP_RETURN_CODE.ERROR_PET_NOT_EXIST)

		return
	end

	pg.me:serverMsg("RPC_CS_BatchRemoveHomelandPet", currentAreaPetIds, areaId, homeSlotIndexes, boxId or -1, CallbackHandler(self, "onRemoveHomelandPetCallback"))
end

function ClientHomelandPetsComponent:onRemoveHomelandPetCallback(code, petId)
	self:showHomePetNotice(code)

	local isSucc = code == Const.HOMELAND_PET_OP_RETURN_CODE.SUCCESS

	pg.game.home.editor:onEditPetResult(isSucc, petId)
	facade:sendMsgToUI(MessageName.HOMELAND_PETS_CHANGE, {
		petId = petId
	})
end

function ClientHomelandPetsComponent:showHomePetNotice(returnCode)
	if returnCode == Const.HOMELAND_PET_OP_RETURN_CODE.SUCCESS then
		pg.global.showBubbleMessage(NoticeDef.HOME_EDIT_SUCCESS)
	elseif returnCode == Const.HOMELAND_PET_OP_RETURN_CODE.ERROR_CHECK_FAIL then
		pg.global.showBubbleMessage(NoticeDef.HOME_CHECK_FAILED)
	elseif returnCode == Const.HOMELAND_PET_OP_RETURN_CODE.ERROR_NOT_HOME then
		pg.global.showBubbleMessage(NoticeDef.HOME_NOT_HOME)
	elseif returnCode == Const.HOMELAND_PET_OP_RETURN_CODE.ERROR_PARAM then
		pg.global.showBubbleMessage(NoticeDef.HOME_ERROR_PARAM)
	elseif returnCode == Const.HOMELAND_PET_OP_RETURN_CODE.ERROR_PET_NOT_EXIST then
		pg.global.showBubbleMessage(NoticeDef.HOME_PET_NOT_EXIST)
	elseif returnCode == Const.HOMELAND_PET_OP_RETURN_CODE.ERROR_PET_COUNT_MAX then
		pg.global.showBubbleMessage(NoticeDef.HOME_ERROR_PET_COUNT_MAX)
	elseif returnCode == Const.HOMELAND_PET_OP_RETURN_CODE.ERROR_BOX_FULL then
		pg.global.showBubbleMessage(NoticeDef.HOME_ERROR_PET_UPPER_LIMIT)
	elseif returnCode == Const.HOMELAND_PET_OP_RETURN_CODE.ERROR_AREA_NOT_SUPPORTED then
		pg.global.showBubbleMessage(NoticeDef.HOME_ERROR_PARAM)
	elseif returnCode == Const.HOMELAND_PET_OP_RETURN_CODE.ERROR_AREA_LOCKED then
		pg.global.showBubbleMessage(NoticeDef.HOME_AREA_NOT_OPEN)
	end
end

function ClientHomelandPetsComponent:homeOperationFinished(petId, ornamentId)
	ornamentId = ornamentId or 0

	pg.me:serverMsg("RPC_CS_HomeOperationFinished", petId, ornamentId)
end

function ClientHomelandPetsComponent:homeLeisureFinished(petId, revision)
	pg.me:serverMsg("RPC_CS_HomeLeisureFinished", petId, revision)
end

function ClientHomelandPetsComponent:tryMountHomeLeisureRide(petId, vehicleActorId, seatIndex, revision)
	pg.me:serverMsg("RPC_CS_TryMountHomeLeisureRide", petId, vehicleActorId, seatIndex, revision)
end

function ClientHomelandPetsComponent:homeLeisureManualOperationFinished(petId)
	pg.me:serverMsg("RPC_CS_HomeLeisureManualOperationFinished", petId)
end

function ClientHomelandPetsComponent:doSpecialAIPetAction(petId, operId, extraIntParam)
	pg.me:serverMsg("RPC_CS_DoSpecialPetAIAction", petId, operId, extraIntParam)
end

function ClientHomelandPetsComponent:cancelSpecialAIPetAction(petId)
	pg.me:serverMsg("RPC_CS_CancelSpecialPetAIAction", petId)
end

return ClientHomelandPetsComponent
