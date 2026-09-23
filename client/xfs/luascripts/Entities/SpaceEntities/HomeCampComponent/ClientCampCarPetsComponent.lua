-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\HomeCampComponent\\ClientCampCarPetsComponent.lua

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
local ItemUtils = require("Common.Utils.ItemUtils")
local EventConst = require("Const.EventConst")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local UIConst = require("Const.UIConst")
local OpDef = require("Common.OpDef")
local HomeCampUtils = require("Utils.HomeCampUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientUtils = require("Utils.ClientUtils")
local PetDispatchData = require("Data.pet_dispatch_data")
local PetBallConfigData = require("Data.pet_ball_config_data")
local CustomTriggerData = require("Data.custom_trigger_data")
local TimerManager = require("Core.Timer.TimerManager")
local ClientCampCarPetsComponent = Class.Component("ClientCampCarPetsComponent", ClientHomeBasePetsComponent)

function ClientCampCarPetsComponent:postInit(dict)
	ClientCampCarPetsComponent.super.postInit(self, dict)
end

function ClientCampCarPetsComponent:getPetsDispatchInfo()
	return self.dispatchInfo
end

function ClientCampCarPetsComponent:onDispatchFinishedChanged(_, isFinished)
	if not pg.me or self.ownerUid ~= pg.me.uid then
		return
	end

	facade:sendMsgToUI(MessageName.HOME_CAR_CAMP_DISPATCH_STATE_CHANGED, isFinished)
end

function ClientCampCarPetsComponent:getCarPetCanSetCount()
	return HomeLandUtils.getCarPetMaxCount(self)
end

function ClientCampCarPetsComponent:getDispatchId()
	local dispatchInfo = self:getPetsDispatchInfo()

	if not dispatchInfo then
		return 0
	end

	return dispatchInfo.dispId
end

function ClientCampCarPetsComponent:getDispatchCampId()
	local dispatchInfo = self:getPetsDispatchInfo()

	return dispatchInfo and dispatchInfo.campId or 0
end

function ClientCampCarPetsComponent:isCanHoldToCmap(checkCnt)
	local maxPetCnt = self:getCarPetCanSetCount()

	if checkCnt < maxPetCnt then
		return true
	end

	return false
end

function ClientCampCarPetsComponent:tryAddCampPetIds(petId, isPreview)
	local copyPetIds = self:getCampCopyPetIds()

	if table.contains(copyPetIds, petId) then
		return NoticeDef.HOME_CAR_CAMP_PET_ALREADY_IN_CAMP
	end

	if not self:isCanHoldToCmap(#copyPetIds) then
		return NoticeDef.HOME_CAR_CAMP_PET_COUNT_MAX
	end

	if not isPreview then
		self:setCampPetIds(copyPetIds)
	end

	return NoticeDef.SUCCESS
end

function ClientCampCarPetsComponent:tryRemoveCampPetIds(petsMap, isPreview)
	local copyPetIds = self:getCampCopyPetIds()
	local isExist = false
	local removedPetIds = {}

	for i, v in ipairs(copyPetIds) do
		if petsMap and petsMap[v] then
			isExist = true
		else
			table.insert(removedPetIds, v)
		end
	end

	if not isExist then
		return NoticeDef.HOME_CAR_CAMP_PET_NOT_IN_CAMP
	end

	if not isPreview then
		self:setCampPetIds(removedPetIds)
	end

	return NoticeDef.SUCCESS
end

function ClientCampCarPetsComponent:setCampPetIds(petIds, sucCb, failCb)
	pg.me:requestHomeCampOp(OpDef.OP.CS_HC_ChangePets, {
		petIds = petIds
	}, function(noticeId, noticeArgs)
		if noticeId == NoticeDef.SUCCESS then
			facade:sendMsgToUI(MessageName.HOME_CAR_CAMP_CHANGE_PETS)

			if sucCb then
				sucCb()
			end
		else
			if LoggerManager.checkLogger(LoggerConst.WARN) then
				logger:warn("HomeCampUtils.setCampPets fail, noticeId: %s, noticeArgs: %s", noticeId or "nil", noticeArgs or "nil")
			end

			if failCb then
				failCb()
			end
		end
	end)
end

function ClientCampCarPetsComponent:getCampPetIds()
	return self.petIds or {}
end

function ClientCampCarPetsComponent:getCampPetInfo(petId)
	return self.pets and self.pets[petId]
end

function ClientCampCarPetsComponent:getCampPetDispatchState()
	local dispatchInfo = self:getPetsDispatchInfo()

	if dispatchInfo:checkIsFinished() then
		return UIConst.HOME_CAMP_DISPATCH_STATE.Finished
	end

	if dispatchInfo:isDispatching() then
		return UIConst.HOME_CAMP_DISPATCH_STATE.Dispatching
	end

	return UIConst.HOME_CAMP_DISPATCH_STATE.UnDispatch
end

function ClientCampCarPetsComponent:getCampCopyPetIds()
	local campPetIds = self:getCampPetIds()
	local retPetIds = {}

	for _, v in ipairs(campPetIds) do
		table.insert(retPetIds, v)
	end

	return retPetIds
end

function ClientCampCarPetsComponent:getCannotBringEggPetNames()
	local petNames = {}
	local cannotBreedList = PetBallConfigData.cannotBreedList or {}

	for _, petId in ipairs(self:getCampPetIds()) do
		local petInfo = self:getCampPetInfo(petId)
		local prototypeId = petInfo and petInfo.petPrototypeId or 0

		if petInfo and table.contains(cannotBreedList, prototypeId) then
			local petName = LuaUIUtils.getPetNameByPetInfo(petInfo)

			petNames[#petNames + 1] = string.format("<style=Hint_BgD>%s</style>", petName)
		end
	end

	return petNames
end

function ClientCampCarPetsComponent:requestDispatchPet(dispatchId, campId, requestSentCb)
	pg.me:requestHomeCampOp(OpDef.OP.CS_HC_Dispatch, {
		dispatchId = dispatchId,
		campId = campId
	}, function(noticeId, noticeArgs)
		if noticeId == NoticeDef.SUCCESS then
			pg.global.ui.blackScreen:open({
				id = UIConst.BLACK_SCREEN_ID,
				startCloseCb = function()
					return
				end
			})
			TimerManager.addTimer(0.5, function()
				pg.global.ui:close(UIConst.UI_ID_CAMP_MANAGER)
			end)
		else
			if LoggerManager.checkLogger(LoggerConst.WARN) then
				logger:warn("HomeCampUtils.setCampPets fail, noticeId: %s, noticeArgs: %s", noticeId or "nil", noticeArgs and noticeArgs[1] or "nil")
			end

			local args = noticeArgs and noticeArgs[1]

			if args and args == "no lock dispatchType" then
				local pdpdd = PetDispatchData[dispatchId]
				local triggerId = pdpdd and pdpdd.unlockCondition or 0
				local ctdd = CustomTriggerData[triggerId]
				local needLv = ctdd and ctdd.condition[1] and ctdd.condition[1][5] or 0

				if needLv > 0 then
					local fStr = pg.getGameString("HOME_CAMP_PET_DISPATCH_NEED_LV")

					fStr = (not fStr or fStr == "HOME_CAMP_PET_DISPATCH_NEED_LV") and "HOME_CAMP_PET_DISPATCH_NEED_LV %s" or fStr

					pg.global.showBubbleMessageRaw(string.format(fStr, needLv))
				end
			end
		end
	end)

	if requestSentCb then
		requestSentCb()
	end
end

function ClientCampCarPetsComponent:dispatchPet(dispatchId, campId, requestSentCb)
	if not campId or campId == 0 then
		campId = self.space.staticId
	end

	local cannotBringEggPetNames = self:getCannotBringEggPetNames()

	if #cannotBringEggPetNames > 0 then
		local desc = pg.getFormatText(pg.getGameString("PET_EXPLORE_CANT_BRING_EGG_INFO"), table.concat(cannotBringEggPetNames, ","))

		ClientUtils.showConfirmRaw(pg.getGameString("WARNING"), desc, function()
			self:requestDispatchPet(dispatchId, campId, requestSentCb)
		end, false)

		return
	end

	self:requestDispatchPet(dispatchId, campId, requestSentCb)
end

function ClientCampCarPetsComponent:stopDispatch()
	pg.me:requestHomeCampOp(OpDef.OP.CS_HC_DispatchStop, {}, function(noticeId, noticeArgs)
		if noticeId == NoticeDef.SUCCESS then
			facade:sendMsgToUI(MessageName.HOME_CAR_CAMP_DISPATCH_STOP)
		elseif LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("HomeCampUtils.dispatchStop fail, noticeId: %s, noticeArgs: %s", noticeId or "nil", noticeArgs or "nil")
		end
	end)
end

function ClientCampCarPetsComponent:finishDispatch()
	HomeCampUtils.setPreDispatchId(self:getDispatchId())
	HomeCampUtils.setPreDispatchCampId(self:getDispatchCampId())
	pg.me:requestHomeCampOp(OpDef.OP.CS_HC_DispatchFinish, {}, function(noticeId, noticeArgs)
		if noticeId == NoticeDef.SUCCESS then
			local idNumDict = noticeArgs and noticeArgs.resItems or {}
			local itemCountTable = ItemUtils.getItemCountTable(idNumDict)
			local resItemsList = noticeArgs and noticeArgs.resItemsList or {}
			local idNumsListDict = {}

			for _, v in ipairs(resItemsList) do
				idNumsListDict[#idNumsListDict + 1] = ItemUtils.getItemCountTable(v)
			end

			HomeCampUtils.setPreDispatchRewardItems(itemCountTable, idNumsListDict)
			facade:sendMsgToUI(MessageName.HOME_CAR_CAMP_DISPATCH_FINISH, noticeArgs)

			if pg.global.eventEmitter then
				pg.global.eventEmitter:emit(EventConst.PLATFORM_ACHIEVEMENT_HOME_CAMP_DISPATCH_FINISHED, {
					count = 1
				})
			end

			HomeCampUtils.tryOpenFinishDispatchDialog()
		elseif LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("HomeCampUtils.dispatchFinish fail, noticeId: %s, noticeArgs: %s", noticeId or "nil", noticeArgs or "nil")
		end
	end)
end

return ClientCampCarPetsComponent
