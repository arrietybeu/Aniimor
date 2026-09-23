-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\Home\\ClientHomeProduceComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local HomeObjectData = require("Data.home_object_data")
local HomelandFacilityData = require("Data.homeland_facility_data")
local HomelandFormulaData = require("Data.homeland_formula_data")
local InteractionConst = require("Common.Const.InteractionConst")
local InteractData = require("Data.interact_data")
local HomelandOperateData = require("Data.homeland_operate_data")
local ClientConst = require("Const.ClientConst")
local HotkeyConst = require("Const.HotkeyConst")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local GlobalData = require("Core.Client.GlobalData")
local EffectConst = require("Const.EffectConst")
local EventConst = require("Const.EventConst")
local Time = require("Core.Common.Time")
local NoticeDef = require("Common.NoticeDef")
local AddressDataConst = require("Const.AddressDataConst")
local HomeFacilityData = require("Data.homeland_facility_data")
local HomelandFormulaRandomData = require("Data.homeland_formula_random_data")
local HomelandFormulaReverseData = require("Data.homeland_formula_random_reverse_data")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local CallbackHandler = require("Core.Common.CallbackHandler")
local ClientHomelandUtils = require("Utils.ClientHomelandUtils")
local ClientHomeProduceComponent = Class.Component("ClientHomeProduceComponent")

function ClientHomeProduceComponent:init(dict)
	self.facilityRequireOperIds = {}
	self.curFormulaId = nil
	self.facilityWorkEffects = {}
	self.facilityChangeVersion = 0
	self.transitionAnimTimer = nil
	self.isInTransitionAnim = false

	self:initFacilityConfig()
	self:initFacilityData()

	return true
end

function ClientHomeProduceComponent:start()
	self:setFacilityInfo(self.facilityInfo)

	local configData = self:getConfigData()

	self.syncWorkEffect = configData.syncWorkEffect

	if self.syncWorkEffect and self.ornamentId then
		pg.game.home:registerSynWorkEffectFacility(self.ornamentId, self)
	end

	self:refreshEnvRangeEffect()
end

function ClientHomeProduceComponent:preDestroy()
	self:cancelMutationPickup(true)
end

function ClientHomeProduceComponent:destroy()
	if self.syncWorkEffect and self.ornamentId then
		pg.game.home:unRegisterSynWorkEffectFacility(self.ornamentId, self)
	end

	self:cancelTransitionAnim()
end

function ClientHomeProduceComponent:cancelTransitionAnim()
	if self.transitionAnimTimer then
		self:removeTimer(self.transitionAnimTimer)

		self.transitionAnimTimer = nil
	end

	self.isInTransitionAnim = false
end

function ClientHomeProduceComponent:getFacilityConfigData()
	local facilityId = self:getFacilityId()

	if not facilityId then
		return {}
	end

	return HomelandFacilityData[facilityId] or {}
end

function ClientHomeProduceComponent:getFacilityId()
	return Utils.getHomeObjectFacilityId(self.homeTemplateId)
end

function ClientHomeProduceComponent:EVENT_OnModelVisibleChange()
	self:syncWorkEffectTime()
end

function ClientHomeProduceComponent:getRelatedOperationIds()
	if not self.curFormulaId or self.curFormulaId == 0 then
		return nil
	end

	local relatedOperationIds = {}
	local formulaId = self.facilityInfo.formulaId
	local formulaData = HomelandFormulaData[formulaId] or {}

	for _, operationId in ipairs(formulaData.preOperateList or EMPTY_TABLE) do
		if not table.contains(relatedOperationIds, operationId) then
			relatedOperationIds[#relatedOperationIds + 1] = operationId
		end
	end

	for _, operationId in ipairs(formulaData.postOperateList or EMPTY_TABLE) do
		if not table.contains(relatedOperationIds, operationId) then
			relatedOperationIds[#relatedOperationIds + 1] = operationId
		end
	end

	if formulaData.timerState and not table.contains(relatedOperationIds, formulaData.timerState) then
		relatedOperationIds[#relatedOperationIds + 1] = formulaData.timerState
	end

	return relatedOperationIds
end

function ClientHomeProduceComponent:initProducerInteractListData()
	self.producerInteractListData = {}

	local facilityData = self:getFacilityConfigData()
	local configData = self:getConfigData()

	if not GlobalData.Space:isSelfHomeland() then
		local tillOpId = facilityData.tillState
		local tillOperData = tillOpId and HomelandOperateData[tillOpId]

		if tillOperData and tillOperData.interactionId then
			self.producerInteractListData[#self.producerInteractListData + 1] = {
				skipHomelandCheck = true,
				globalId = self:getGlobalId(),
				actionPrototypeId = tillOperData.interactionId,
				canInteractiveFunc = function()
					return self:canLoosenSoilInteract()
				end,
				interactFunc = function()
					self:doLoosenSoilInteract()
				end
			}
		end
	end

	if not facilityData.formulaList or Utils.isHomeVehicle(self.homeTemplateId) then
		-- block empty
	else
		local relatedOperIds = self:getRelatedOperationIds()

		if relatedOperIds then
			for _, operationId in ipairs(relatedOperIds) do
				local operationData = HomelandOperateData[operationId] or {}

				if operationData.playerCanDo then
					self.producerInteractListData[#self.producerInteractListData + 1] = {
						skipHomelandCheck = true,
						globalId = self:getGlobalId(),
						actionPrototypeId = operationData.interactionId,
						overrideInteractDis = configData.interactDistance,
						canInteractiveFunc = function()
							return self:canProduceInteract(operationId)
						end,
						interactFunc = function()
							self:doProduceInteract(operationId)
						end
					}
				end
			end
		end
	end

	if not GlobalData.Space:isSelfHomeland() then
		return
	end

	if Utils.isClientHomeTrash(self) then
		return
	end

	if facilityData.formulaList and #facilityData.formulaList > 0 then
		local deliverActionId = self:hasMutationOutput() and InteractionConst.INTERACT_HOME_MUTATION_DELIVER_ACTION_ID or InteractionConst.INTERACT_HOME_DELIVER_ACTION_ID

		self.producerInteractListData[#self.producerInteractListData + 1] = {
			globalId = self:getGlobalId(),
			actionPrototypeId = deliverActionId,
			overrideInteractDis = configData.interactDistance,
			canInteractiveFunc = function()
				return self.mutationPickupTimer == nil and self:canProduceDeliver()
			end,
			interactFunc = function()
				self:doProduceDeliver()
			end
		}
		self.producerInteractListData[#self.producerInteractListData + 1] = {
			globalId = self:getGlobalId(),
			actionPrototypeId = InteractionConst.INTERACT_CANCEL_MULTI_INTERACT_ACTION_ID,
			overrideInteractDis = configData.interactDistance,
			canInteractiveFunc = function()
				return self.mutationPickupTimer ~= nil
			end,
			interactFunc = function()
				pg.global.ui.interactSecond:close()
				self:cancelMutationPickup()
			end
		}
		self.producerInteractListData[#self.producerInteractListData + 1] = {
			globalId = self:getGlobalId(),
			actionPrototypeId = InteractionConst.INTERACT_HOME_CALL_PET_WORK_ID,
			overrideInteractDis = configData.interactDistance,
			canInteractiveFunc = function()
				return self:canProduceCallPetWork()
			end,
			interactFunc = function()
				self:doProduceCallPetWork()
			end
		}

		local formulaData = self.facilityInfo and HomelandFormulaData[self.facilityInfo.formulaId]

		if formulaData and formulaData.accelerateStageList and formulaData.accelerateItemId and InteractData[InteractionConst.INTERACT_HOME_PRODUCE_ACCELERATE] then
			self.producerInteractListData[#self.producerInteractListData + 1] = {
				globalId = self:getGlobalId(),
				interactionType = InteractionConst.INTERACTION_TYPE_ENT_FUNC,
				actionPrototypeId = InteractionConst.INTERACT_HOME_PRODUCE_ACCELERATE,
				overrideInteractDis = configData.interactDistance,
				canInteractiveFunc = function()
					local accelerateInfo = ClientHomelandUtils.getProduceAccelerateInfo(self.ornamentId, self.facilityInfo)

					return accelerateInfo and accelerateInfo.ownedCount >= accelerateInfo.costNum
				end,
				getItemDisplayInfo = function()
					return ClientHomelandUtils.getProduceAccelerateInfo(self.ornamentId, self.facilityInfo)
				end,
				interactFunc = function()
					self:doProduceAccelerate()
				end
			}
		end

		self.producerInteractListData[#self.producerInteractListData + 1] = {
			globalId = self:getGlobalId(),
			actionPrototypeId = InteractionConst.INTERACT_HOME_DETAIL_ACTION_ID,
			overrideInteractDis = configData.interactDistance,
			canInteractiveFunc = function()
				return self:canProduceDetail()
			end,
			interactFunc = function()
				self:doProduceDetail()
			end
		}

		if facilityData.facilityType == Const.HOMELAND_FACILITY_TYPE.ElectricReqSwitch then
			self.producerInteractListData[#self.producerInteractListData + 1] = {
				globalId = self:getGlobalId(),
				actionPrototypeId = InteractionConst.INTERACT_HOME_ENABLE_ELECTRIC_MODE,
				overrideInteractDis = configData.interactDistance,
				canInteractiveFunc = function()
					return self:canEnableElectricMode()
				end,
				interactFunc = function()
					self:setEnableElectricMode(true)
				end
			}
			self.producerInteractListData[#self.producerInteractListData + 1] = {
				globalId = self:getGlobalId(),
				actionPrototypeId = InteractionConst.INTERACT_HOME_DISABLE_ELECTRIC_MODE,
				overrideInteractDis = configData.interactDistance,
				canInteractiveFunc = function()
					return self:canDisableElectricMode()
				end,
				interactFunc = function()
					self:setEnableElectricMode(false)
				end
			}
		end

		self.producerInteractListData[#self.producerInteractListData + 1] = {
			globalId = self:getGlobalId(),
			actionPrototypeId = InteractionConst.INTERACT_HOME_SETTING_ACTION_ID,
			overrideInteractDis = configData.interactDistance,
			canInteractiveFunc = function()
				return self:canProduceSetting()
			end,
			interactFunc = function()
				self:doProduceSetting()
			end
		}
	elseif Utils.isHomeEnvFacility(self.homeTemplateId) then
		self.producerInteractListData[#self.producerInteractListData + 1] = {
			globalId = self:getGlobalId(),
			actionPrototypeId = InteractionConst.INTERACT_HOME_DETAIL_ACTION_ID,
			overrideInteractDis = configData.interactDistance,
			canInteractiveFunc = function()
				return self:canProduceDetail()
			end,
			interactFunc = function()
				self:doProduceDetail()
			end
		}
		self.producerInteractListData[#self.producerInteractListData + 1] = {
			globalId = self:getGlobalId(),
			actionPrototypeId = InteractionConst.INTERACT_HOME_CALL_PET_WORK_ID,
			overrideInteractDis = configData.interactDistance,
			canInteractiveFunc = function()
				return self:canProduceCallPetWork()
			end,
			interactFunc = function()
				self:doProduceCallPetWork()
			end
		}
	end
end

function ClientHomeProduceComponent:canProduceInteract(opState)
	if Utils.isClientHomeTrash(self) and not GlobalData.Space:isSelfHomeland() then
		return false
	end

	if pg.me:isInHomeInteractState() then
		return false
	end

	if pg.me:RIDING_ST() then
		return false
	end

	local requireOps = self:getRequireOperIds()

	if table.contains(requireOps, opState) then
		return true
	end

	return false
end

function ClientHomeProduceComponent:doProduceInteract(opState)
	if self.facilityInfo.envWorkRatio <= 0 then
		pg.global.showBubbleMessageById(NoticeDef.HOME_ENV_NOT_VALID)

		return
	end

	pg.global.ui.interactSecond:close()
	pg.me.space:allocatePlayerWork(self.ornamentId, opState)
end

function ClientHomeProduceComponent:canLoosenSoilInteract()
	if pg.space and pg.space.demoMode == true then
		return false
	end

	if not self.facilityInfo then
		return false
	end

	if GlobalData.Space:isSelfHomeland() then
		return false
	end

	if pg.me:isInHomeInteractState() then
		return false
	end

	if pg.me:RIDING_ST() then
		return false
	end

	if not pg.game.controller:isInControlMainPlayer() then
		return false
	end

	if self.facilityInfo.tilled then
		return false
	end

	if HomeLandUtils.canTill(pg.me.space, self.ornamentId, pg.me.uid) ~= NoticeDef.SUCCESS then
		return false
	end

	if HomeLandUtils.isFacilityLoosening(pg.me and pg.me.space, self.ornamentId) then
		return false
	end

	return true
end

function ClientHomeProduceComponent:doLoosenSoilInteract()
	pg.global.ui.interactSecond:close()

	local tillOpId = HomeLandUtils.getFacilityTillOpId(pg.me.space, self.ornamentId)

	if not tillOpId then
		return
	end

	pg.me.space:allocatePlayerWork(self.ornamentId, tillOpId)
end

function ClientHomeProduceComponent:canProduceDeliver()
	if pg.me:isInHomeInteractState() then
		return false
	end

	if pg.me:RIDING_ST() then
		return false
	end

	if not pg.game.controller:isInControlMainPlayer() then
		return false
	end

	if Utils.isClientHomeTrash(self) then
		return false
	end

	if not self:checkHasOutput() then
		return false
	end

	return true
end

function ClientHomeProduceComponent:doProduceDeliver()
	pg.global.ui.interactSecond:close()

	if self:hasMutationOutput() then
		self:startMutationPickup()

		return
	end

	self:executeProduceDeliver()
end

function ClientHomeProduceComponent:doProduceAccelerate()
	local accelerateInfo = ClientHomelandUtils.getProduceAccelerateInfo(self.ornamentId, self.facilityInfo)

	if not accelerateInfo or self.acceleratePending then
		return
	end

	if accelerateInfo.ownedCount < accelerateInfo.costNum then
		pg.global.showBubbleMessage(NoticeDef.ITEM_USE_OUT)

		return
	end

	pg.global.ui.interactSecond:close()
	ClientHomelandUtils.showProduceAccelerateConfirm(accelerateInfo.itemName, function()
		self:requestProduceAccelerate()
	end)
end

function ClientHomeProduceComponent:requestProduceAccelerate()
	self.acceleratePending = true

	local requestFacilityChangeVersion = self.facilityChangeVersion

	pg.me.space:accelerateHomelandPlant(self.ornamentId, function(code)
		if code ~= Const.HOMELAND_PRODUCE_OP_RETURN_CODE.SUCCESS then
			self.acceleratePending = false

			if code == Const.HOMELAND_PRODUCE_OP_RETURN_CODE.ERROR_PRODUCE_MATERIAL_NOT_ENOUGH then
				pg.global.showBubbleMessage(NoticeDef.ITEM_USE_OUT)
			end

			return
		end

		local facilityChanged = self.facilityChangeVersion ~= requestFacilityChangeVersion

		self.acceleratePending = not facilityChanged and ClientHomelandUtils.getProduceAccelerateInfo(self.ornamentId, self.facilityInfo) ~= nil

		pg.global.showBubbleMessage(NoticeDef.HOMELAND_SPEED_SUCCESS)
		self:initInteraction()
		self:refreshInteractTriggerEvent()
	end)
end

function ClientHomeProduceComponent:executeProduceDeliver()
	local snapshot = {
		items = self:getHarvestOutputItems(),
		toBag = self:resolveProduceToBag()
	}

	pg.me.space:playerHomeTransport(self.ornamentId, snapshot)
end

function ClientHomeProduceComponent:hasMutationOutput()
	if not self.facilityInfo or not self.facilityInfo.specialOutputMap then
		return false
	end

	for _, info in pairs(self.facilityInfo.specialOutputMap) do
		if info.num and info.num > 0 then
			return true
		end
	end

	return false
end

function ClientHomeProduceComponent:startMutationPickup()
	if self.mutationPickupTimer then
		return
	end

	local interactData = InteractData[InteractionConst.INTERACT_HOME_MUTATION_DELIVER_ACTION_ID]
	local duration = interactData and interactData.actionTime or 0

	if duration <= 0 then
		self:executeProduceDeliver()

		return
	end

	self.mutationPickupDuration = duration
	self.mutationPickupStartTime = Time.realSecondCache
	self.mutationPickupItemId = self:getDisplayMutationItemId()
	self.mutationPickupText = interactData.actionName or ""

	if type(self.mutationPickupText) == "number" then
		self.mutationPickupText = pg.getLocalizationText(self.mutationPickupText)
	end

	self.mutationPickupTimer = self:addTimer(duration, CallbackHandler(self, "finishMutationPickup"))
	self.mutationPickupAnimation = interactData.loopAnim
	self.mutationPickupPlayer = pg.me

	if pg.game.controller then
		pg.game.controller:onHandleMove(0, 0, 0)
	end

	pg.game.input:enablePlayerInput(false, HotkeyConst.INPUT_BLOCK_FLAG.HOME_MUTATION_PICKUP)

	self.mutationPickupMoveLocked = true

	if self.mutationPickupAnimation and self.mutationPickupPlayer then
		self.mutationPickupPlayer:playAnimation(self.mutationPickupAnimation, true)
	end

	self:refreshFacilityTopLogoState()
	self:refreshInteractTriggerEvent()
end

function ClientHomeProduceComponent:clearMutationPickupState(removeTimer)
	if removeTimer and self.mutationPickupTimer then
		self:removeTimer(self.mutationPickupTimer)
	end

	self.mutationPickupTimer = nil
	self.mutationPickupStartTime = nil
	self.mutationPickupDuration = nil
	self.mutationPickupItemId = nil
	self.mutationPickupText = nil

	if self.mutationPickupAnimation and self.mutationPickupPlayer and not self.mutationPickupPlayer.isDestroyed then
		self.mutationPickupPlayer:stopAnimation(self.mutationPickupAnimation)
	end

	self.mutationPickupAnimation = nil
	self.mutationPickupPlayer = nil

	if self.mutationPickupMoveLocked then
		if pg.game and pg.game.input then
			pg.game.input:enablePlayerInput(true, HotkeyConst.INPUT_BLOCK_FLAG.HOME_MUTATION_PICKUP)
		end

		self.mutationPickupMoveLocked = nil
	end
end

function ClientHomeProduceComponent:cancelMutationPickup(skipRefresh)
	self:clearMutationPickupState(true)

	if not skipRefresh then
		self:refreshFacilityTopLogoState()
		self:refreshInteractTriggerEvent()
	end
end

function ClientHomeProduceComponent:finishMutationPickup()
	local canDeliver = self:hasMutationOutput() and self:canProduceDeliver()

	self:clearMutationPickupState(false)
	self:refreshFacilityTopLogoState()
	self:refreshInteractTriggerEvent()

	if canDeliver then
		self:executeProduceDeliver()
	end
end

function ClientHomeProduceComponent:getMutationPickupProgress()
	if not self.mutationPickupTimer then
		return nil
	end

	local duration = self.mutationPickupDuration
	local startTime = self.mutationPickupStartTime

	if not duration or duration <= 0 or not startTime then
		return nil
	end

	local elapsed = math.clamp(Time.realSecondCache - startTime, 0, duration)
	local displayElapsed = math.floor(elapsed)

	return displayElapsed, duration, self.mutationPickupItemId, self.mutationPickupText
end

function ClientHomeProduceComponent:getHarvestOutputItems()
	local facilityInfo = self.facilityInfo

	if not facilityInfo then
		return {}
	end

	local countMap = {}
	local order = {}

	local function addOne(itemId, num)
		if not itemId or not num or num <= 0 then
			return
		end

		if not countMap[itemId] then
			countMap[itemId] = 0

			table.insert(order, itemId)
		end

		countMap[itemId] = countMap[itemId] + num
	end

	if facilityInfo.outputMap then
		for itemId, itemNum in pairs(facilityInfo.outputMap) do
			addOne(itemId, itemNum)
		end
	end

	if facilityInfo.specialOutputMap then
		for itemId, info in pairs(facilityInfo.specialOutputMap) do
			addOne(itemId, info.num)
		end
	end

	local items = {}

	for _, itemId in ipairs(order) do
		table.insert(items, {
			itemId = itemId,
			count = countMap[itemId]
		})
	end

	return items
end

function ClientHomeProduceComponent:resolveProduceToBag()
	local ornamentInfo = pg.me.space and pg.me.space.ornament and pg.me.space.ornament[self.ornamentId]
	local homeObjData = ornamentInfo and HomeObjectData[ornamentInfo.homeId]
	local facilityData = homeObjData and HomelandFacilityData[homeObjData.facilityId]

	return facilityData ~= nil and facilityData.produceToBag == 1
end

function ClientHomeProduceComponent:canEnableElectricMode()
	if pg.space and pg.space.demoMode == true then
		return false
	end

	if pg.me:isInHomeInteractState() then
		return false
	end

	if pg.me:RIDING_ST() then
		return false
	end

	local ornamentInfo = pg.me.space.ornament[self.ornamentId]

	if ornamentInfo then
		if ornamentInfo.electricMode then
			return false
		end

		return pg.me:checkCanSetElectricMode(ornamentInfo)
	end

	return false
end

function ClientHomeProduceComponent:canDisableElectricMode()
	if pg.space and pg.space.demoMode == true then
		return false
	end

	if not pg.space or not pg.me.space then
		return false
	end

	if pg.me:isInHomeInteractState() then
		return false
	end

	if pg.me:RIDING_ST() then
		return false
	end

	local ornamentInfo = pg.me.space.ornament[self.ornamentId]

	if ornamentInfo then
		if not ornamentInfo.electricMode then
			return false
		end

		return pg.me:checkCanSetElectricMode(ornamentInfo)
	end

	return false
end

function ClientHomeProduceComponent:setEnableElectricMode(enable)
	if not self.facilityInfo or self.facilityInfo.formulaId == 0 then
		pg.space:setProduceElectricMode(self.ornamentId, enable)
	elseif not pg.game.home.curLoginShowElectricModeHint then
		pg.space:setProduceElectricMode(self.ornamentId, enable)
	else
		local extraInfo = {
			hint = true,
			hintCb = function(isSelected)
				pg.game.home.curLoginShowElectricModeHint = not isSelected
			end
		}

		pg.global.showConfirmMsgRaw(pg.getGameString("WARNING"), pg.getGameString("HOME_FACILITY_SET_ELECTRIC_MODE_DESC"), function()
			pg.space:setProduceElectricMode(self.ornamentId, enable)
		end, false, nil, nil, nil, extraInfo)
	end
end

function ClientHomeProduceComponent:canProduceSetting()
	if pg.space and pg.space.demoMode == true then
		return false
	end

	if pg.me:isInHomeInteractState() then
		return false
	end

	if Utils.isClientHomeTrash(self) then
		return false
	end

	if pg.me:RIDING_ST() then
		return false
	end

	if not pg.game.controller:isInControlMainPlayer() then
		return false
	end

	return true
end

function ClientHomeProduceComponent:doProduceSetting()
	pg.global.ui.interactSecond:close()
	pg.global.ui.homelandSetFormula:open({
		ornamentId = self.ornamentId,
		homeTemplateId = self.homeTemplateId
	})
end

function ClientHomeProduceComponent:canProduceDetail()
	if pg.space and pg.space.demoMode == true then
		return false
	end

	if pg.me:isInHomeInteractState() then
		return false
	end

	if pg.me:RIDING_ST() then
		return false
	end

	if not pg.game.controller:isInControlMainPlayer() then
		return false
	end

	if Utils.getHomeFacilityType(self.homeTemplateId) == Const.HOMELAND_FACILITY_TYPE.ElectricLink then
		return true
	end

	if not pg.game.home:checkEnableHomePet() then
		return false
	end

	return self.facilityInfo and self.facilityInfo.formulaId ~= 0
end

function ClientHomeProduceComponent:doProduceDetail()
	pg.global.ui.interactSecond:close()
	pg.global.ui.homelandFacilityInfo:open({
		ornamentId = self.ornamentId,
		entity = self,
		homeTemplateId = self.homeTemplateId
	})
end

function ClientHomeProduceComponent:canProduceCallPetWork()
	if pg.space and pg.space.demoMode == true then
		return false
	end

	if pg.me:isInHomeInteractState() then
		return false
	end

	if pg.me:RIDING_ST() then
		return false
	end

	if not self.facilityInfo then
		return false
	end

	if not Utils.checkHomeFacilityStateValid(self.facilityInfo) then
		return false
	end

	if self.facilityInfo.facilityStateInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.TIME then
		return false
	end

	if not pg.game.home:checkEnableHomePet() then
		return false
	end

	local petList = pg.space.facilityAllocationInfo[self.ornamentId]
	local config = self:getHomelandConfigData()

	if petList then
		local allocatePetCount = 0
		local facilityOper = self.facilityInfo.facilityState

		if facilityOper > 0 then
			for _, petId in ipairs(petList) do
				local allocationInfo = pg.space.allocation[petId]

				if allocationInfo.opId == facilityOper then
					allocatePetCount = allocatePetCount + 1
				end
			end
		end

		if allocatePetCount >= (config.maxPetCount or 0) then
			return false
		end
	end

	return true
end

function ClientHomeProduceComponent:doProduceCallPetWork()
	if not self.facilityInfo then
		return
	end

	if self.facilityInfo.facilityStateInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.TIME then
		return
	end

	local operId = self.facilityInfo.facilityState
	local bestPetId
	local bestWorkload = 0
	local hasMovingPet = false
	local facilityId = self:getFacilityId()

	for petId, petInfo in pairs(pg.space.pets) do
		local allocationInfo = pg.space.allocation[petId]
		local isProduceAreaPet = HomeLandUtils.isHomePetInProduceArea(pg.space, petId)

		if isProduceAreaPet and allocationInfo and allocationInfo.ornamentId == self.ornamentId then
			if allocationInfo.opId == Const.HOMELAND_FACILITY_OP_TYPE.MOVING then
				hasMovingPet = true
			end
		elseif isProduceAreaPet then
			local templateId = petInfo.templateId

			if Utils.checkHomePetStateValid(petInfo, self.space) and Utils.checkHomePetCanDoOperId(templateId, operId) then
				local workload = Utils.calcHomePetTimeWorkload(petInfo, operId, facilityId, self.space:checkHomePetHasFood())

				if bestWorkload < workload then
					bestPetId = petId
					bestWorkload = workload
				end
			end
		end
	end

	local isSlotFull = Utils.checkOverHomePetWorkMaxCount(pg.space.allocation, self.ornamentId, self.homeTemplateId)

	if bestPetId and not isSlotFull then
		pg.space:allocateHomePetWork(bestPetId, self.ornamentId, Const.HOMELAND_FACILITY_OP_TYPE.MOVING)

		return
	end

	if hasMovingPet then
		pg.global.showBubbleMessage(NoticeDef.HOME_CALL_PET_ALREADY_MOVING)

		return
	end

	pg.global.showBubbleMessage(NoticeDef.HOME_CALL_PET_NO_VALID_PET)
end

function ClientHomeProduceComponent:EVENT_InitInteractionList()
	self:initProducerInteractListData()

	if #self.producerInteractListData > 0 then
		self.interactionListData = self.interactionListData or {}

		for _, data in ipairs(self.producerInteractListData) do
			self.interactionListData[#self.interactionListData + 1] = data
		end
	end
end

function ClientHomeProduceComponent:getCurFormulaProgressPercent()
	local facilityStateInfo = self.facilityInfo.facilityStateInfo

	if facilityStateInfo.totalValue <= 0 then
		return 0
	end

	if facilityStateInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.WORKLOAD then
		return facilityStateInfo.curValue / facilityStateInfo.totalValue
	elseif facilityStateInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.TIME then
		if facilityStateInfo.startTs ~= 0 then
			return (facilityStateInfo.curValue + (Time.getSecond() - facilityStateInfo.startTs)) / facilityStateInfo.totalValue
		end

		return facilityStateInfo.curValue / facilityStateInfo.totalValue
	end

	return 0
end

function ClientHomeProduceComponent:getCurFormulaProgress()
	local facilityStateInfo = self.facilityInfo.facilityStateInfo

	if facilityStateInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.WORKLOAD then
		return facilityStateInfo.curValue
	elseif facilityStateInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.TIME then
		if facilityStateInfo.startTs ~= 0 then
			return facilityStateInfo.curValue + (Time.getSecond() - facilityStateInfo.startTs)
		end

		return facilityStateInfo.curValue
	end

	return 0
end

function ClientHomeProduceComponent:getDisplayMutationItemId()
	if not self.facilityInfo or not self.facilityInfo.specialOutputMap then
		return nil
	end

	local bestItemId, bestMode

	for itemId, info in pairs(self.facilityInfo.specialOutputMap) do
		if info.num and info.num > 0 then
			local mode = info.mode or Const.HOME_MUTATION_MODE.AUTO

			if bestItemId == nil or mode < bestMode or mode == bestMode and itemId < bestItemId then
				bestItemId, bestMode = itemId, mode
			end
		end
	end

	return bestItemId
end

function ClientHomeProduceComponent:getFormulaModel()
	local mutItemId = self:getDisplayMutationItemId()

	if mutItemId then
		local reverseInfo = HomelandFormulaReverseData[mutItemId]
		local randomInfo = reverseInfo and HomelandFormulaRandomData[reverseInfo.formulaId] and HomelandFormulaRandomData[reverseInfo.formulaId][reverseInfo.rType]

		if randomInfo and randomInfo.modelPrefab then
			return "mutation_" .. mutItemId, randomInfo.modelPrefab, false, randomInfo
		end
	end

	if self.curFormulaId then
		local formulaData = HomelandFormulaData[self.curFormulaId] or {}

		if formulaData.modelType == ClientConst.HomeModelType.Plant then
			local postOperateList = formulaData.postOperateList or {}

			for index, operateId in ipairs(postOperateList) do
				if operateId == self.facilityInfo.facilityState then
					if index == 1 then
						local curPercent = self:getCurFormulaProgressPercent()

						if curPercent > formulaData.modelChangeTime / formulaData.time then
							return 2, formulaData.modelPrefab2, false
						else
							return 1, formulaData.modelPrefab1, true
						end
					else
						local randomType = self.facilityInfo.randomType or 0

						if randomType == 0 then
							return 3, formulaData.modelPrefab3, false
						end

						local randomInfo = HomelandFormulaRandomData[self.curFormulaId][randomType]

						return 3, randomInfo.modelPrefab, true, randomInfo
					end
				end
			end
		end
	end

	return nil, nil, nil
end

function ClientHomeProduceComponent:clearFormulaAttachEffects()
	if self.formulaAttachEffects then
		for _, effectId in ipairs(self.formulaAttachEffects) do
			self:stopEffectById(effectId)
		end
	end

	self.formulaAttachEffects = nil
end

function ClientHomeProduceComponent:refreshFormulaAttachEffects(randomExtraInfo)
	randomExtraInfo = randomExtraInfo or {}

	local attachEffects = randomExtraInfo.effects
	local offset = self:getConfigData().modelOffset or {
		0,
		0,
		0,
		0
	}
	local positionOffset = {
		offset[1],
		offset[2],
		offset[3]
	}
	local effectOffset = randomExtraInfo.effectOffset

	if effectOffset then
		positionOffset[1] = positionOffset[1] + effectOffset[1]
		positionOffset[2] = positionOffset[2] + effectOffset[2]
		positionOffset[3] = positionOffset[3] + effectOffset[3]
	end

	local extraInfo = {
		position = positionOffset,
		rotation = {
			0,
			offset[4] or 0,
			0
		}
	}

	self:clearFormulaAttachEffects()

	self.formulaAttachEffects = {}

	for _, effectId in ipairs(attachEffects or EMPTY_TABLE) do
		if not self.formulaAttachEffects[effectId] then
			self.formulaAttachEffects[effectId] = self:playEffect(effectId, extraInfo)
		end
	end
end

function ClientHomeProduceComponent:refreshFormulaModel()
	local modelState, resultModelResId, needTick, extraInfo = self:getFormulaModel()

	if self.curModelState ~= modelState then
		if self.curFacilityModelEffectId then
			self:stopEffectById(self.curFacilityModelEffectId)

			self.curFacilityModelEffectId = nil
		end

		local offset = self:getConfigData().modelOffset or {
			0,
			0,
			0,
			0
		}

		self.curModelState = modelState

		if resultModelResId then
			local expectedModelState = modelState

			self.curFacilityModelEffectId = self:playEffectRaw(resultModelResId, {
				disableCollider = true,
				vanishTime = 0.5,
				mountType = EffectConst.MountType.Model,
				position = offset,
				rotation = {
					0,
					offset[4] or 0,
					0
				},
				loadCallback = function()
					if not self.isDestroyed and pg.game and pg.game.home and self.curModelState == expectedModelState then
						pg.game.home:refreshOrnamentShadow(self:getPosition(), self:getBoundSize())
					end
				end
			})
		end

		self:refreshFormulaAttachEffects(extraInfo)
		pg.game.home:refreshOrnamentShadow(self:getPosition(), self:getBoundSize())
	end

	if needTick then
		if not self.updateFormulaModelTimer then
			self.updateFormulaModelTimer = self:addRepeatTimer(1, function()
				self:refreshFormulaModel()
			end)
		end
	elseif self.updateFormulaModelTimer then
		self:removeTimer(self.updateFormulaModelTimer)

		self.updateFormulaModelTimer = nil
	end
end

function ClientHomeProduceComponent:initFacilityConfig()
	local configData = self:getConfigData()
	local needCheckWorkState = false

	if configData.hasAnimator or configData.workAnimName or configData.workSound or configData.workEffects then
		needCheckWorkState = true
	end

	local homeFacilityData = HomeFacilityData[configData.facilityId] or {}
	local facilityType = homeFacilityData.facilityType

	if not needCheckWorkState and facilityType ~= Const.HOMELAND_FACILITY_TYPE.EnvRequire and facilityType ~= Const.HOMELAND_FACILITY_TYPE.ElectricReqSwitch and facilityType ~= Const.HOMELAND_FACILITY_TYPE.ElectricReq then
		needCheckWorkState = true
	end

	self.needCheckWorkState = needCheckWorkState
end

function ClientHomeProduceComponent:initFacilityData()
	local facilityInfo = GlobalData.Space.facility[self.ornamentId]

	self:setFacilityInfo(facilityInfo, true)
end

function ClientHomeProduceComponent:setFacilityInfo(facilityInfo, isInit)
	local oldHasMutationOutput = self.hasMutationOutputCache
	local oldCanAccelerate = ClientHomelandUtils.getProduceAccelerateInfo(self.ornamentId, self.facilityInfo) ~= nil
	local oldAcceleratePending = self.acceleratePending == true

	if not isInit then
		self.facilityChangeVersion = self.facilityChangeVersion + 1
	end

	self.facilityInfo = facilityInfo

	local hasMutationOutput = self:hasMutationOutput()

	self.hasMutationOutputCache = hasMutationOutput

	if self.mutationPickupTimer and not hasMutationOutput then
		self:cancelMutationPickup(true)
	end

	local formulaId

	if facilityInfo then
		formulaId = self.facilityInfo.formulaId
	end

	local formulaChanged = self.curFormulaId ~= formulaId
	local canAccelerate = ClientHomelandUtils.getProduceAccelerateInfo(self.ornamentId, self.facilityInfo) ~= nil
	local pendingChanged = false

	if oldAcceleratePending then
		self.acceleratePending = false
		pendingChanged = true
	elseif not canAccelerate then
		self.acceleratePending = false
	end

	if formulaChanged then
		self.curFormulaId = formulaId

		self:onFormulaIdChanged(isInit)
	end

	if not isInit and not formulaChanged and (oldHasMutationOutput ~= nil and oldHasMutationOutput ~= hasMutationOutput or oldCanAccelerate ~= canAccelerate or pendingChanged) then
		self:initInteraction()
		self:refreshInteractTriggerEvent()
	end

	if not isInit then
		self:refreshFormulaModel()
		self:refreshFacilityWorkState()
		self:refreshFacilityTopLogoState()
	end
end

function ClientHomeProduceComponent:getOrnamentEnvInfo()
	if not pg.space then
		return nil
	end

	return pg.space.ornamentEnvMap[self.ornamentId]
end

function ClientHomeProduceComponent:getEnvFacilityInfo()
	if not pg.space then
		return nil
	end

	return pg.space.homeEnvMap[self.ornamentId]
end

function ClientHomeProduceComponent:getHomeLinkInfo()
	if not pg.space then
		return nil
	end

	return pg.space.homeLinkMap[self.ornamentId]
end

function ClientHomeProduceComponent:getHomeLinkGroupInfo(groupId)
	if not pg.space then
		return nil
	end

	return pg.space.homeLinkGroupMap[groupId]
end

function ClientHomeProduceComponent:onFacilityAllocateChanged()
	self:refreshFacilityWorkState()
end

function ClientHomeProduceComponent:onFacilityProduceFinish()
	self.facilityChangeVersion = self.facilityChangeVersion + 1

	if self.acceleratePending then
		self.acceleratePending = false

		self:initInteraction()
		self:refreshInteractTriggerEvent()
	end

	self:cancelTransitionAnim()

	local configData = self:getConfigData()

	if configData.produceEffect then
		self:playEffect(configData.produceEffect)
	end

	if configData.produceSound then
		self:playSoundEvent(configData.produceSound)
	end

	if configData.produceAnim then
		local animanerAnim = self:playAnimancerAnim(configData.produceAnim, nil, true)

		if animanerAnim then
			local animLength = animanerAnim.Length

			self.isInProduceAnim = true

			self:addTimer(animLength, function()
				self.isInProduceAnim = false

				self:refreshFacilityAnimation()
			end)
		end
	end
end

function ClientHomeProduceComponent:getFacilityWorkState()
	if not pg.space then
		return false
	end

	if Utils.getHomeFacilityType(self.homeTemplateId) == Const.HOMELAND_FACILITY_TYPE.ElectricLink then
		local linkInfo = self:getHomeLinkInfo()

		if linkInfo and linkInfo.groupId ~= 0 then
			local linkGroupInfo = self:getHomeLinkGroupInfo(linkInfo.groupId)

			if linkGroupInfo and linkGroupInfo.totalProduce > 0 then
				return true
			end
		end

		return false
	end

	if not Utils.checkHomeFacilityStateValid(self.facilityInfo) then
		return false
	end

	local hasPlayerDoOper = false
	local hasPetDoOper = false

	if self.facilityInfo.facilityStateInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.WORKLOAD or self.facilityInfo.facilityStateInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.ENV then
		local facilityOper = self.facilityInfo.facilityState

		if facilityOper > 0 then
			for playerId, playerOperInfo in pairs(pg.space.playerAllocation) do
				if playerOperInfo.ornamentId == self.ornamentId and playerOperInfo.opId == facilityOper then
					hasPlayerDoOper = true

					break
				end
			end

			local petList = pg.space.facilityAllocationInfo[self.ornamentId]

			if petList then
				for _, petId in ipairs(petList) do
					local allocationInfo = pg.space.allocation[petId]

					if allocationInfo.opId == facilityOper then
						hasPetDoOper = true

						break
					end
				end
			end

			return hasPlayerDoOper or hasPetDoOper, hasPlayerDoOper, hasPetDoOper
		end
	else
		return true
	end

	return false
end

function ClientHomeProduceComponent:refreshFacilityWorkState()
	if not self.needCheckWorkState then
		return
	end

	local workState, hasPlayerDoOper, hasPetDoOper = self:getFacilityWorkState()

	if self.facilityWorkState ~= workState then
		self.facilityWorkState = workState

		self:onFacilityWorkStateChanged()
	end

	if self.hasPlayerDoOper ~= hasPlayerDoOper then
		self.hasPlayerDoOper = hasPlayerDoOper

		self:onPlayerHasDoOperChanged()
	end

	if self.hasPetDoOper ~= hasPetDoOper then
		self.hasPetDoOper = hasPetDoOper

		self:onPetHasDoOperChanged()
	end
end

function ClientHomeProduceComponent:refreshFacilityTopLogoState()
	local enableTopLogo = true

	if Utils.isClientHomeTrash(self) and not self.facilityInfo then
		enableTopLogo = false
	end

	self:setEnableTopLogo(enableTopLogo)
end

function ClientHomeProduceComponent:onFacilityWorkStateChanged()
	self:playFacilityTransitionAnim()

	local configData = self:getConfigData()

	if configData.workSound then
		if self.facilityWorkState then
			self:playSoundEvent(configData.workSound)
		else
			self:stopSoundEvent(configData.workSound, 0.5)
		end
	end

	if configData.workEffects then
		if self.facilityWorkState then
			self:playHomeWorkEffects()
		else
			self:stopHomeWorkEffects()
		end
	end

	self:refreshEnvRangeEffect()
	self:refreshRunningLightIntensity()
	self:postComponentMethod("EVENT_onFacilityWorkStateChanged")
end

function ClientHomeProduceComponent:refreshRunningLightIntensity()
	local configData = self:getConfigData()

	if not configData.runningLightIntensity then
		return
	end

	if not self.eModel or not self.eModel.shaderView then
		return
	end

	local intensity = self.facilityWorkState and configData.runningLightIntensity or 0

	self.eModel.shaderView:ApplyMaterialGlobalFloat("_Intensity", intensity)
end

function ClientHomeProduceComponent:onPlayerHasDoOperChanged()
	return
end

function ClientHomeProduceComponent:onPetHasDoOperChanged()
	local configData = self:getConfigData()

	if configData.petWorkEffect then
		if self.hasPetDoOper then
			self:playEffect(configData.petWorkEffect)
		else
			self:stopEffect(configData.petWorkEffect)
		end
	end
end

function ClientHomeProduceComponent:playHomeWorkEffects()
	local configData = self:getConfigData()

	for _, effectKey in ipairs(configData.workEffects) do
		if not self.facilityWorkEffects[effectKey] then
			local extraInfo

			if self.syncWorkEffect then
				extraInfo = {
					loadCallback = function(effectItem)
						local valid, time, duration = self:getCurAnimPlayedTime()

						if valid then
							effectItem:SetEffectPlayTime(time % duration)
						end
					end
				}
			end

			self.facilityWorkEffects[effectKey] = self:playEffect(effectKey, extraInfo)
		end
	end
end

function ClientHomeProduceComponent:syncWorkEffectTime()
	if self.syncWorkEffect and self.facilityWorkState then
		local valid, time, duration = self:getCurAnimPlayedTime()

		if valid then
			for _, effectId in pairs(self.facilityWorkEffects) do
				self.eModel:SetEffectPlayTimeById(Const.COMPONENT_INDEX_EFFECT, effectId, time % duration + duration)
			end
		end
	end
end

function ClientHomeProduceComponent:stopHomeWorkEffects()
	for effectKey, effectId in pairs(self.facilityWorkEffects) do
		self:stopEffectById(effectId)
	end

	table.clear(self.facilityWorkEffects)
end

function ClientHomeProduceComponent:EVENT_onModelLoaded()
	if self.needCheckWorkState then
		self:cancelTransitionAnim()
		self:refreshFacilityAnimation()
		self:syncWorkEffectTime()
		self:refreshRunningLightIntensity()
	end
end

function ClientHomeProduceComponent:playFacilityTransitionAnim()
	self:cancelTransitionAnim()

	local configData = self:getConfigData()
	local animName = self.facilityWorkState and configData.startAnimName or configData.endAnimName

	if not animName then
		self:refreshFacilityAnimation()

		return
	end

	local anim = self:playAnimancerAnim(animName, nil, true)

	if not anim then
		self:refreshFacilityAnimation()

		return
	end

	self.isInTransitionAnim = true
	self.transitionAnimTimer = self:addTimer(anim.Length, function()
		self.transitionAnimTimer = nil
		self.isInTransitionAnim = false

		self:refreshFacilityAnimation()
	end)
end

function ClientHomeProduceComponent:refreshFacilityAnimation()
	if self.facilityWorkState == nil then
		return
	end

	if self.eModel then
		if self.isInProduceAnim then
			return
		end

		if self.isInTransitionAnim then
			return
		end

		local configData = self:getConfigData()

		if self.facilityWorkState then
			if configData.workAnimName then
				self:playAnimancerAnim(configData.workAnimName)
			end
		elseif configData.noworkAnimName then
			self:playAnimancerAnim(configData.noworkAnimName)
		else
			local resetWorkAnim = false

			if configData.resetWorkAnim then
				resetWorkAnim = true
			end

			self:stopAnimancerAnim(resetWorkAnim)
		end
	end
end

function ClientHomeProduceComponent:onFormulaIdChanged(isInit)
	if not isInit then
		self:initInteraction()
		self:refreshInteractTriggerEvent()
	end
end

function ClientHomeProduceComponent:checkHasOutput()
	if not self.facilityInfo then
		return false
	end

	if Utils.checkHasOutput(self.facilityInfo) then
		return true
	end

	if self.facilityInfo.specialOutputMap then
		for _, info in pairs(self.facilityInfo.specialOutputMap) do
			if info.num > 0 then
				return true
			end
		end
	end

	return false
end

function ClientHomeProduceComponent:getRequireOperIds()
	self:innerUpdateRequireOperIds()

	return self.facilityRequireOperIds
end

function ClientHomeProduceComponent:getNextOperId()
	if not self.facilityInfo then
		return
	end

	if (self.facilityInfo.facilityStateInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.WORKLOAD or self.facilityInfo.facilityStateInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.ENV) and self.facilityInfo.facilityState > 0 then
		return self.facilityInfo.facilityState
	end
end

function ClientHomeProduceComponent:innerUpdateRequireOperIds()
	table.clear(self.facilityRequireOperIds)

	if not self.facilityInfo then
		return
	end

	if self.facilityInfo.extraStateMap[Const.HOMELAND_EXTRA_STATES.OUTPUT_LIMIT] then
		table.insert(self.facilityRequireOperIds, Const.HOMELAND_FACILITY_OP_TYPE.TRANSPORT)

		return
	end

	local stateValid = true

	if stateValid then
		for timerStateOp, _ in pairs(self.facilityInfo.timerStateMap) do
			table.insert(self.facilityRequireOperIds, timerStateOp)
		end
	end

	if self.facilityInfo.disable then
		stateValid = false
	end

	for _, state in pairs(Const.HOMELAND_CHECK_VALID_STATES) do
		if self.facilityInfo.extraStateMap[state] then
			stateValid = false

			break
		end
	end

	if stateValid and (self.facilityInfo.facilityStateInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.WORKLOAD or self.facilityInfo.facilityStateInfo.ptype == Const.HOMELAND_PRODUCE_TYPE.ENV) and self.facilityInfo.facilityState > 0 then
		table.insert(self.facilityRequireOperIds, self.facilityInfo.facilityState)
	end
end

function ClientHomeProduceComponent:getEnvRequireWorkRatio(envRequireType)
	if not self.facilityInfo then
		return nil
	end

	local facilityType = Utils.getHomeFacilityType(self.homeTemplateId)

	if envRequireType == ClientConst.HOMELAND_ENV_REQUIRE_TYPE.Electric then
		if facilityType == Const.HOMELAND_FACILITY_TYPE.ElectricReq or facilityType == Const.HOMELAND_FACILITY_TYPE.ElectricReqSwitch then
			return self.facilityInfo.envWorkRatio
		end
	elseif envRequireType == ClientConst.HOMELAND_ENV_REQUIRE_TYPE.Light then
		if facilityType == Const.HOMELAND_FACILITY_TYPE.EnvRequire and self.facilityInfo.formulaId ~= 0 then
			local formulaData = HomelandFormulaData[self.facilityInfo.formulaId]

			if formulaData.lightRequire then
				local ornamentEnvInfo = self:getOrnamentEnvInfo()

				if ornamentEnvInfo then
					local lightDiff = math.abs(ornamentEnvInfo.light - formulaData.lightRequire)

					if formulaData.forceEnvRequire then
						if lightDiff ~= 0 then
							return 0, formulaData.lightRequire
						else
							return 1, formulaData.lightRequire
						end
					else
						return Utils.calcLightDiffWorkRatio(lightDiff), formulaData.lightRequire
					end
				end
			end
		end
	elseif envRequireType == ClientConst.HOMELAND_ENV_REQUIRE_TYPE.Temperature and facilityType == Const.HOMELAND_FACILITY_TYPE.EnvRequire and self.facilityInfo.formulaId ~= 0 then
		local formulaData = HomelandFormulaData[self.facilityInfo.formulaId]

		if formulaData.temperatureRequire then
			local ornamentEnvInfo = self:getOrnamentEnvInfo()

			if ornamentEnvInfo then
				local tempDiff = math.abs(ornamentEnvInfo.temperature - formulaData.temperatureRequire)

				if formulaData.forceEnvRequire then
					if tempDiff ~= 0 then
						return 0, formulaData.temperatureRequire
					else
						return 1, formulaData.temperatureRequire
					end
				else
					return Utils.calcTemperatureDiffWorkRatio(tempDiff), formulaData.temperatureRequire
				end
			end
		end
	end

	return nil
end

function ClientHomeProduceComponent:EVENT_onEntityPositionChanged()
	self:refreshEnvRangeEffect()
end

function ClientHomeProduceComponent:refreshEnvRangeEffect()
	local configData = self:getHomelandConfigData()

	if not configData.facilityId then
		return
	end

	local rangeEffectResId, resultYaw
	local homeFacilityData = HomeFacilityData[configData.facilityId] or {}

	if self.facilityWorkState then
		local facilityType = homeFacilityData.facilityType

		if facilityType == Const.HOMELAND_FACILITY_TYPE.Electric or facilityType == Const.HOMELAND_FACILITY_TYPE.ElectricLink then
			rangeEffectResId = AddressDataConst.HOMELAND_RANGE_EFFECT_ELECTRIC
		elseif facilityType == Const.HOMELAND_FACILITY_TYPE.HighTemperate then
			rangeEffectResId = AddressDataConst.HOMELAND_RANGE_EFFECT_HOT
		elseif facilityType == Const.HOMELAND_FACILITY_TYPE.LowTemperate then
			rangeEffectResId = AddressDataConst.HOMELAND_RANGE_EFFECT_ICE
		elseif facilityType == Const.HOMELAND_FACILITY_TYPE.Light then
			rangeEffectResId = AddressDataConst.HOMELAND_RANGE_EFFECT_LIGHT
		end

		if rangeEffectResId then
			local curYaw = self:getRotation().eulerAngles.y
			local baseYaw = self:getBasePlaceYaw()

			resultYaw = Utils.calcBoundsYaw(curYaw - baseYaw) + baseYaw
		end
	end

	if self.rangeEffectResId ~= rangeEffectResId or self.rangeEffectYaw ~= resultYaw then
		self:stopEnvRangeEffect()

		self.rangeEffectResId = rangeEffectResId
		self.rangeEffectYaw = resultYaw

		if self.rangeEffectResId then
			local envBounds = homeFacilityData.envBounds or {
				1,
				1
			}
			local finalScale = {}

			for i = 1, 2 do
				finalScale[i] = envBounds[i] / ClientConst.DefaultHomeEnvRangeSize
			end

			self.envRangeEffectId = self:playEffectRaw(self.rangeEffectResId, {
				mountType = EffectConst.MountType.World,
				followType = EffectConst.FollowType.FollowPos,
				rotation = {
					0,
					self.rangeEffectYaw,
					0
				},
				scale = {
					finalScale[1],
					finalScale[1],
					finalScale[2]
				}
			})
		end
	end
end

function ClientHomeProduceComponent:stopEnvRangeEffect()
	if self.envRangeEffectId then
		self:stopEffectById(self.envRangeEffectId)

		self.envRangeEffectId = nil
	end

	self.rangeEffectResId = nil
	self.rangeEffectYaw = nil
end

function ClientHomeProduceComponent:EVENT_OnAddExtraDebugInfo(extraInfo)
	if pg.game.home:getEnableDebugInfo(ClientConst.HomelandDebugType.Base) then
		if self.facilityInfo then
			table.insert(extraInfo, "homeTempId:" .. self.homeTemplateId)
			table.insert(extraInfo, "formula:" .. self.facilityInfo.formulaId)
			table.insert(extraInfo, "facilityState:" .. self.facilityInfo.facilityState)
			table.insert(extraInfo, "randomType:" .. self.facilityInfo.randomType)
			table.insert(extraInfo, "-ptype:" .. self.facilityInfo.facilityStateInfo.ptype)
			table.insert(extraInfo, "-totalValue:" .. self.facilityInfo.facilityStateInfo.totalValue)
			table.insert(extraInfo, "-curValue:" .. self.facilityInfo.facilityStateInfo.curValue)
			table.insert(extraInfo, "-startTs:" .. self.facilityInfo.facilityStateInfo.startTs)
			table.insert(extraInfo, "-extraStates:")

			for extraState, info in pairs(self.facilityInfo.extraStateMap) do
				table.insert(extraInfo, "-" .. extraState)
			end
		else
			table.insert(extraInfo, "not setting")
		end
	end

	if pg.game.home:getEnableDebugInfo(ClientConst.HomelandDebugType.Env) then
		local facilityType = Utils.getHomeFacilityType(self.homeTemplateId)

		if facilityType == Const.HOMELAND_FACILITY_TYPE.ElectricReq or facilityType == Const.HOMELAND_FACILITY_TYPE.ElectricReqSwitch then
			if self.facilityInfo then
				table.insert(extraInfo, "envWorkRatio:" .. self.facilityInfo.envWorkRatio)
			end

			local envOrnamentInfo = self:getOrnamentEnvInfo()

			if envOrnamentInfo then
				table.insert(extraInfo, "electricCost:" .. envOrnamentInfo.electricCost)
			end
		elseif facilityType == Const.HOMELAND_FACILITY_TYPE.Electric or facilityType == Const.HOMELAND_FACILITY_TYPE.ElectricLink then
			if facilityType == Const.HOMELAND_FACILITY_TYPE.Electric then
				local envFacilityInfo = self:getEnvFacilityInfo()

				if envFacilityInfo then
					table.insert(extraInfo, "envProduce:" .. envFacilityInfo.envProduce)
				end
			end

			local linkInfo = self:getHomeLinkInfo()

			if linkInfo then
				table.insert(extraInfo, "groupId:" .. linkInfo.groupId)

				local groupInfo = self:getHomeLinkGroupInfo(linkInfo.groupId)

				if groupInfo then
					table.insert(extraInfo, "groupInfo:")
					table.insert(extraInfo, "totalCost:" .. groupInfo.totalCost)
					table.insert(extraInfo, "totalProduce:" .. groupInfo.totalProduce)
				end
			end
		elseif facilityType == Const.HOMELAND_FACILITY_TYPE.EnvRequire then
			if self.facilityInfo then
				table.insert(extraInfo, "envWorkRatio:" .. self.facilityInfo.envWorkRatio)
			end

			local envOrnamentInfo = self:getOrnamentEnvInfo()

			if envOrnamentInfo then
				table.insert(extraInfo, "light:" .. envOrnamentInfo.light)
				table.insert(extraInfo, "temperature:" .. envOrnamentInfo.temperature)
			end
		elseif facilityType == Const.HOMELAND_FACILITY_TYPE.HighTemperate or facilityType == Const.HOMELAND_FACILITY_TYPE.LowTemperate or facilityType == Const.HOMELAND_FACILITY_TYPE.Light then
			local envFacilityInfo = self:getEnvFacilityInfo()

			if envFacilityInfo then
				table.insert(extraInfo, "envProduce:" .. envFacilityInfo.envProduce)
			end
		end
	end
end

return ClientHomeProduceComponent
