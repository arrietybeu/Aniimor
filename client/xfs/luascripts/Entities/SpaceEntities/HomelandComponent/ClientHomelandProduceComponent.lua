-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\HomelandComponent\\ClientHomelandProduceComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local CallbackHandler = require("Core.Common.CallbackHandler")
local NoticeDef = require("Common.NoticeDef")
local ConflictTypes = require("Common.ConflictTypes")
local MessageName = require("Const.MessageName")
local ClientUtils = require("Utils.ClientUtils")
local ClientSwitch = require("Common.ClientSwitch")
local EventConst = require("Const.EventConst")
local HomelandDemoCmdImplement = require("GameApp.CmdSocket.HomelandDemoCmdImplement")
local ClientHomelandProduceComponent = Class.Component("ClientHomelandProduceComponent")

function ClientHomelandProduceComponent:ctor()
	self.storeOrnaments = {}
	self.facilityAllocationInfo = {}
	self.oldPetToFacility = {}
end

function ClientHomelandProduceComponent:init(dict)
	self:initFacilityAllocationInfo(self.allocation)
	pg.game.home:initLastPlayerAllocation(self.playerAllocation)

	return true
end

function ClientHomelandProduceComponent:syncDemoModeGmSwitches(isDemoMode, refreshCollision)
	local enabled = isDemoMode == true
	local ok, GmToolUtils = pcall(require, "Utils.GmToolUtils")

	if ok and GmToolUtils and type(GmToolUtils.syncHomeDemoModeSwitches) == "function" then
		GmToolUtils.syncHomeDemoModeSwitches(enabled)

		if refreshCollision and type(GmToolUtils.refreshHomePetCollisionClientState) == "function" then
			GmToolUtils.refreshHomePetCollisionClientState()
		end
	else
		ClientSwitch.NvidiaVoiceTest = enabled
	end
end

function ClientHomelandProduceComponent:start()
	self:syncDemoModeGmSwitches(self.demoMode, true)
	self:initStoreOrnaments()

	if self.demoMode == true then
		HomelandDemoCmdImplement.setEnabled(pg.game and pg.game.cmdSocket or nil, nil, {
			enabled = true
		})

		if pg.me and pg.me.serverMsg then
			pg.me:serverMsg("RPC_CS_HomelandDemoResetTargetChain")
		end
	end
end

function ClientHomelandProduceComponent:EVENT_onOrnamentAdd(ornamentId)
	self:tryAddStoreOrnament(ornamentId)
end

function ClientHomelandProduceComponent:EVENT_onOrnamentRemove(ornamentId, ornamentInfo)
	self:tryRemoveStoreOrnament(ornamentId)
end

function ClientHomelandProduceComponent:EVENT_onOrnamentChanged(ornamentId)
	self:tryRemoveStoreOrnament(ornamentId)
	self:tryAddStoreOrnament(ornamentId)
end

function ClientHomelandProduceComponent:RPC_SC_HomelandProduceFinish(ornamentId)
	pg.game.home:onFacilityProduceFinish(ornamentId)
end

function ClientHomelandProduceComponent:RPC_SC_HomePettingLeisureFailed(petId)
	local petEnt = pg.getEntity(petId)

	if petEnt then
		petEnt:postComponentMethod("onHomePettingLeisureFailed")
	end
end

function ClientHomelandProduceComponent:destroy()
	self:syncDemoModeGmSwitches(false, false)

	self.pendingHarvestFeedback = nil
end

function ClientHomelandProduceComponent:on_demoMode_changed(ov, nv)
	self:syncDemoModeGmSwitches(nv, false)
	HomelandDemoCmdImplement.setEnabled(pg.game and pg.game.cmdSocket or nil, nil, {
		enabled = nv == true
	})

	if self.refreshHasFoodState then
		self:refreshHasFoodState()
	end

	if not self.pets then
		return
	end

	for petId in pairs(self.pets) do
		local ent = pg.getEntity(petId)

		if ent then
			ent:postComponentMethod("onHomelandAIPlanChanged")
			ent:postComponentMethod("onHomeEventChanged")
			ent.eventEmitter:emit(EventConst.HOMELAND_WORK_STATE_CHANGED, {})
			ent.eventEmitter:emit(EventConst.HOMELAND_ACTION_STATE_CHANGED, {})
		end
	end
end

function ClientHomelandProduceComponent:on_facility_changed(ov, nv, key)
	pg.game.home:onFacilityChanged(key, self.facility[key])
end

function ClientHomelandProduceComponent:on_facility_disable_changed(ov, nv, ornamentId)
	facade:sendMsgToUI(MessageName.HOMELAND_FACILITY_DISABLE_CHANGED, ornamentId)
end

function ClientHomelandProduceComponent:on_facility_added(k, v)
	pg.game.home:onFacilityAdded(k, v)
end

function ClientHomelandProduceComponent:on_facility_deleted(k, v)
	pg.game.home:onFacilityDeleted(k)
end

function ClientHomelandProduceComponent:on_allocation_changed(ov, nv, key)
	self:updateFacilityAllocationInfo(key, self.allocation[key])
	pg.game.home:onAllocationChanged(key, self.allocation[key])
end

function ClientHomelandProduceComponent:on_allocation_added(k, v)
	self:updateFacilityAllocationInfo(k, v)
	pg.game.home:onAllocationAdded(k, v)
end

function ClientHomelandProduceComponent:on_allocation_deleted(k, v)
	self:updateFacilityAllocationInfo(k, nil)
	pg.game.home:onAllocationDeleted(k)
end

function ClientHomelandProduceComponent:refreshHomelandLeisurePet(petId)
	local petEnt = pg.getEntity(petId)

	if petEnt then
		petEnt:postComponentMethod("onHomelandAIPlanChanged")
		petEnt.eventEmitter:emit(EventConst.HOMELAND_LEISURE_STATE_CHANGED, {})
	end
end

function ClientHomelandProduceComponent:on_leisureState_changed(ov, nv, key)
	self:refreshHomelandLeisurePet(key)
end

function ClientHomelandProduceComponent:on_leisureState_added(k, v)
	self:refreshHomelandLeisurePet(k)
end

function ClientHomelandProduceComponent:on_leisureState_deleted(k, v)
	self:refreshHomelandLeisurePet(k)
end

function ClientHomelandProduceComponent:on_transportData_changed(ov, nv, key)
	local ent = pg.getEntity(key)

	if ent and ent.onTransportChanged then
		ent:onTransportChanged()
	end
end

function ClientHomelandProduceComponent:on_transportData_added(k, v)
	local ent = pg.getEntity(k)

	if ent and ent.onTransportStart then
		ent:onTransportStart()
	end
end

function ClientHomelandProduceComponent:on_transportData_deleted(k, v)
	local ent = pg.getEntity(k)

	if ent and ent.onTransportEnd then
		ent:onTransportEnd()
	end
end

function ClientHomelandProduceComponent:on_playerAllocation_changed(ov, nv, key)
	pg.game.home:onPlayerAllocationChanged(key, self.playerAllocation[key])
end

function ClientHomelandProduceComponent:on_playerAllocation_added(k, v)
	pg.game.home:onPlayerAllocationAdded(k, v)
end

function ClientHomelandProduceComponent:on_playerAllocation_deleted(k, v)
	pg.game.home:onPlayerAllocationDeleted(k)
end

function ClientHomelandProduceComponent:setProduceDisable(ornamentId, isDisable)
	pg.me:serverMsg("RPC_CS_SetHomelandFacilityDisable", ornamentId, isDisable)
end

function ClientHomelandProduceComponent:setProduceEnvParam(ornamentId, envParam)
	pg.me:serverMsg("RPC_CS_SetHomelandFacilityEnvParam", ornamentId, envParam)
end

function ClientHomelandProduceComponent:setProduceElectricMode(ornamentId, enableElectricMode)
	if not pg.me:checkCanSetElectricMode(self.ornament[ornamentId]) then
		return false
	end

	pg.me:serverMsg("RPC_CS_SetHomelandFacilityElectricMode", ornamentId, enableElectricMode, CallbackHandler(self, "onSetProduceElectricModeCallback"))
end

function ClientHomelandProduceComponent:onSetProduceElectricModeCallback(code, ornamentId, enableElectricMode)
	if code == Const.HOMELAND_PRODUCE_OP_RETURN_CODE.SUCCESS then
		pg.global.showBubbleMessage(NoticeDef.HOME_ELECTRIC_MODE_CHANGE_SUCC)
	end
end

function ClientHomelandProduceComponent:setHomelandProduce(ornamentId, formulaId)
	pg.me:serverMsg("RPC_CS_SetHomelandProduce", ornamentId, formulaId, CallbackHandler(self, "onSetHomelandProduceCallback"))
end

function ClientHomelandProduceComponent:removeHomelandProduce(ornamentId, formulaId)
	pg.me:serverMsg("RPC_CS_RemoveHomelandProduce", ornamentId, formulaId, CallbackHandler(self, "onSetHomelandProduceCallback"))
end

function ClientHomelandProduceComponent:onSetHomelandProduceCallback(code, ornamentId, formulaId)
	local isSucc = code == Const.HOMELAND_PRODUCE_OP_RETURN_CODE.SUCCESS

	if not isSucc then
		return
	end

	facade:sendMsgToUI(MessageName.HOMELAND_FORMULA_CHANGED, ornamentId)
end

function ClientHomelandProduceComponent:accelerateHomelandPlant(ornamentId, callback)
	pg.me:serverMsg("RPC_CS_AccelerateHomelandPlant", ornamentId, callback)
end

function ClientHomelandProduceComponent:batchAccelerateHomelandPlant(ornamentIds, callback)
	pg.me:serverMsg("RPC_CS_BatchAccelerateHomelandPlant", ornamentIds, callback)
end

function ClientHomelandProduceComponent:allocateHomePetWork(petId, ornamentId, opId, forceSet)
	ornamentId = ornamentId or 0
	opId = opId or 0
	forceSet = forceSet or false

	pg.me:serverMsg("RPC_CS_AllocateHomePet", petId, ornamentId, opId, forceSet, CallbackHandler(self, "onAllocateHomePetWorkCallback"))
end

function ClientHomelandProduceComponent:deallocateHomePetWork(petId, checkOrnamentId, forceSet)
	checkOrnamentId = checkOrnamentId or 0
	forceSet = forceSet or false

	pg.me:serverMsg("RPC_CS_DeallocateHomePet", petId, checkOrnamentId, forceSet)
end

function ClientHomelandProduceComponent:resetAllHomePetWork(callback)
	pg.me:serverMsg("RPC_CS_ResetAllHomePetWork", callback)
end

function ClientHomelandProduceComponent:onAllocateHomePetWorkCallback(code, ornamentId)
	local isSucc = code == Const.HOMELAND_PRODUCE_OP_RETURN_CODE.SUCCESS
end

function ClientHomelandProduceComponent:allocatePlayerWork(ornamentId, opId)
	if pg.me:checkStatus(ConflictTypes.CT_HOME_INTERACT, true) then
		pg.me:serverMsg("RPC_CS_AllocatePlayerWork", ornamentId, opId)
	end
end

function ClientHomelandProduceComponent:playerHomeTransport(ornamentId, harvestSnapshot)
	if harvestSnapshot then
		self.pendingHarvestFeedback = self.pendingHarvestFeedback or {}
		self.pendingHarvestFeedback[ornamentId] = harvestSnapshot
	end

	pg.me:serverMsg("RPC_CS_HomelandPlayerTransport", ornamentId, CallbackHandler(self, "onPlayerHomeTransportCallback"))
end

function ClientHomelandProduceComponent:onPlayerHomeTransportCallback(code, ornamentId)
	local snapshot = self.pendingHarvestFeedback and self.pendingHarvestFeedback[ornamentId]

	if self.pendingHarvestFeedback then
		self.pendingHarvestFeedback[ornamentId] = nil
	end

	if code ~= Const.HOMELAND_PRODUCE_OP_RETURN_CODE.SUCCESS then
		return
	end

	if not snapshot or not snapshot.items or #snapshot.items == 0 then
		return
	end

	local hudV2 = pg.global.ui.hudV2
	local homeFunc = hudV2 and hudV2.MD and hudV2.MD.homeFunc

	if homeFunc and homeFunc.playHarvestFly then
		homeFunc:playHarvestFly({
			ornamentId = ornamentId,
			items = snapshot.items,
			toBag = snapshot.toBag
		})
	end
end

function ClientHomelandProduceComponent:initStoreOrnaments()
	for ornamentId, ornamentInfo in pairs(self.ornament) do
		self:tryAddStoreOrnament(ornamentId)
	end
end

function ClientHomelandProduceComponent:tryAddStoreOrnament(ornamentId)
	local ornamentInfo = self.ornament[ornamentId]

	if ornamentInfo.homeId == Const.STORE_ORNAMENT_ID then
		self.storeOrnaments[ornamentId] = true
	end
end

function ClientHomelandProduceComponent:tryRemoveStoreOrnament(ornamentId)
	self.storeOrnaments[ornamentId] = nil
end

function ClientHomelandProduceComponent:initFacilityAllocationInfo(allocationData)
	self.facilityAllocationInfo = {}
	self.oldPetToFacility = {}

	for petId, allocationInfo in pairs(allocationData) do
		if allocationInfo.ornamentId then
			local allocatePets = self.facilityAllocationInfo[allocationInfo.ornamentId]

			if not allocatePets then
				allocatePets = {}
				self.facilityAllocationInfo[allocationInfo.ornamentId] = allocatePets
			end

			self.oldPetToFacility[petId] = allocationInfo.ornamentId

			table.insert(allocatePets, petId)
		end
	end
end

function ClientHomelandProduceComponent:updateFacilityAllocationInfo(petId, allocationInfo)
	local oldAllocationOrnamentId = self.oldPetToFacility[petId]

	if allocationInfo and oldAllocationOrnamentId == allocationInfo.ornamentId then
		ClientUtils.tryWithLogError(function()
			facade:SendMessageCommand(MessageName.HOMELAND_FACILITY_ALLOCATE_CHANGED, allocationInfo.ornamentId)
		end)

		return
	end

	if oldAllocationOrnamentId then
		local allocatePets = self.facilityAllocationInfo[oldAllocationOrnamentId]

		for i, allPetId in ipairs(allocatePets) do
			if allPetId == petId then
				table.remove(allocatePets, i)

				break
			end
		end

		if #allocatePets == 0 then
			self.facilityAllocationInfo[oldAllocationOrnamentId] = nil
		end

		ClientUtils.tryWithLogError(function()
			facade:SendMessageCommand(MessageName.HOMELAND_FACILITY_ALLOCATE_CHANGED, oldAllocationOrnamentId)
		end)
	end

	if allocationInfo and allocationInfo.ornamentId then
		local allocatePets = self.facilityAllocationInfo[allocationInfo.ornamentId]

		if not allocatePets then
			allocatePets = {}
			self.facilityAllocationInfo[allocationInfo.ornamentId] = allocatePets
		end

		self.oldPetToFacility[petId] = allocationInfo.ornamentId

		table.insert(allocatePets, petId)
		ClientUtils.tryWithLogError(function()
			facade:SendMessageCommand(MessageName.HOMELAND_FACILITY_ALLOCATE_CHANGED, allocationInfo.ornamentId)
		end)
	else
		self.oldPetToFacility[petId] = nil
	end
end

return ClientHomelandProduceComponent
