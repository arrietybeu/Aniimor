-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientVehicleOpComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local GlobalData = require("Core.Client.GlobalData")
local class = require("Core.Framework.Class")
local vehicle_seat_data = require("Data.vehicle_seat_data")
local vehicle_seat_attach_data = require("Data.vehicle_seat_attach_data")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local VehicleUtils = require("Common.Utils.VehicleUtils")
local SceneUtils = require("Common.Utils.SceneUtils")
local AiConst = require("Common.Const.AiConst")
local ClientConst = require("Const.ClientConst")
local NoticeDef = require("Common.NoticeDef")
local SceneData = require("Data.scene_data")
local MessageName = require("Const.MessageName")
local ClientVehicleOpComponent = class.Component("ClientVehicleOpComponent")

function ClientVehicleOpComponent:ctor()
	self.onVehicleActorId = 0
	self.seatId = 0
	self.rideEndTime = 0
	self.vehicleDestroyTime = 0
	self.pendingVehicleMount = false
	self.vehicleBodyMountSessionId = 0
	self.isIndependentPetVehiclePassenger = false
end

function ClientVehicleOpComponent:init(dict)
	self.onVehicleActorId = dict.onVehicleActorId
	self.seatId = dict.seatId
	self.rideEndTime = dict.rideEndTime
	self.vehicleDestroyTime = dict.vehicleDestroyTime
	self.vehicleBodyMountSessionId = dict.vehicleBodyMountSessionId or 0

	return true
end

function ClientVehicleOpComponent:checkVehicleBodyAnimationAllowsMount(vehicleId)
	local vehicle = pg.getEntityByActorId(vehicleId)

	if vehicle and vehicle.canMountByBodyAnimation then
		return vehicle:canMountByBodyAnimation()
	end

	return true
end

function ClientVehicleOpComponent:EVENT_PostInitialized()
	self.postInitialized = true

	self:refreshVehicle()
end

function ClientVehicleOpComponent:mountVehicle(vehicleId, seatId)
	if not self:checkVehicleBodyAnimationAllowsMount(vehicleId) then
		return
	end

	self:serverMsg("RPC_CS_MountVehicle", vehicleId, seatId)
end

function ClientVehicleOpComponent:mainPlayerMountVehicle(vehicleId)
	if not self:checkVehicleBodyAnimationAllowsMount(vehicleId) then
		return
	end

	self:serverMsg("RPC_CS_StartDriveVehicle", vehicleId)
end

function ClientVehicleOpComponent:otherPlayerMountVehicle(vehicleId, seatId)
	return
end

function ClientVehicleOpComponent:setPendingVehicleMount(isPending)
	if self.pendingVehicleMountTimerId then
		self:removeTimer(self.pendingVehicleMountTimerId)

		self.pendingVehicleMountTimerId = nil
	end

	self.pendingVehicleMount = isPending == true

	if self.updateStateCache then
		self:updateStateCache("RIDING_ST")
	end

	if self.pendingVehicleMount then
		self.pendingVehicleMountTimerId = self:addTimer(5, function()
			self.pendingVehicleMount = false
			self.pendingVehicleMountTimerId = nil

			if self.updateStateCache then
				self:updateStateCache("RIDING_ST")
			end
		end)
	end
end

function ClientVehicleOpComponent:canMountVehicle(vehicleId)
	local entity = pg.getEntityByActorId(vehicleId)

	if entity and entity.getClosestSeat then
		local seatId = entity:getClosestSeat(self)

		if seatId and seatId > 0 then
			return true
		end
	end

	return false
end

function ClientVehicleOpComponent:refreshMountVisible()
	local vehicleVisible = true

	if self.curVehicle and self.curVehicle.visible ~= nil then
		vehicleVisible = self.curVehicle.visible
	end

	self:setModelVisible(ClientConst.MODEL_VISIBLE_KEY.VEHICLE_PARENT, vehicleVisible)
end

function ClientVehicleOpComponent:RPC_SC_UpdateVehicleOp(vehicleInfo)
	self:setPendingVehicleMount(false)

	self.onVehicleActorId = vehicleInfo.onVehicleActorId
	self.seatId = vehicleInfo.seatId
	self.rideEndTime = vehicleInfo.rideEndTime
	self.vehicleDestroyTime = vehicleInfo.vehicleDestroyTime
	self.vehicleBodyMountSessionId = vehicleInfo.vehicleBodyMountSessionId or 0

	if self.updateStateCache then
		self:updateStateCache("RIDING_ST")
	end

	self:refreshVehicle()
end

function ClientVehicleOpComponent:reportVehicleBodyAnimationPhase(vehicleActorId, sessionId, entered)
	if not self.isMainAuthority or self.isClientEnt or sessionId == 0 then
		return
	end

	self:serverMsg("RPC_CS_ReportVehicleBodyAnimationPhase", vehicleActorId, sessionId, entered)
end

function ClientVehicleOpComponent:dismountVehicle(vehicleId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientVehicleOpComponent dismountVehicle vehicleId %s", vehicleId)
	end

	self:serverMsg("RPC_CS_DismountVehicle", vehicleId)
	facade:SendMessageCommand(MessageName.DISMOUNT_SELF)
end

function ClientVehicleOpComponent:dismountSelf()
	local vehicleId = self.onVehicleActorId

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientVehicleOpComponent dismountVehicle vehicleId %s", vehicleId)
	end

	self:serverMsg("RPC_CS_DismountVehicle", vehicleId)
	facade:SendMessageCommand(MessageName.DISMOUNT_SELF)
end

function ClientVehicleOpComponent:RPC_CS_DismountVehicleSeat(vehicleActorId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientVehicleOpComponent RPC_CS_DismountVehicleSeat vehicleActorId %s", vehicleActorId)
	end

	self:serverMsg("RPC_CS_DismountVehicleSeat", vehicleActorId)
end

function ClientVehicleOpComponent:exchangeSeatVehicle(vehicleActorId, srcSeatId, dstSeatId)
	self:serverMsg("RPC_CS_ExchangeSeat", vehicleActorId, srcSeatId, dstSeatId)
end

function ClientVehicleOpComponent:onVehicleProgressFinished(vehicle)
	self:serverMsg("RPC_CS_ProgressFull", vehicle.actorId, self.actorId)
end

function ClientVehicleOpComponent:openVehicleSimpleChat()
	if self.isMainPlayer ~= true then
		return
	end

	local vehicleConfig = self.curVehicle and self.curVehicle.getVehicleConfig and self.curVehicle:getVehicleConfig()

	if vehicleConfig == nil or vehicleConfig.isopenchat ~= 1 then
		return
	end

	pg.global.ui.hudV2:openChat()
end

function ClientVehicleOpComponent:closeVehicleSimpleChat()
	if self.isMainPlayer ~= true then
		return
	end

	local hudV2 = pg.global.ui.hudV2
	local quickChat

	if hudV2 ~= nil and hudV2.LD ~= nil then
		quickChat = hudV2.LD.quickChat
	end

	if quickChat ~= nil then
		quickChat:leaveSimpleChatMode()
	end
end

function ClientVehicleOpComponent:syncVehicleChatTypingToMe(uid, vehicleActorId, typingType)
	if self.isMainPlayer == true or pg.me == nil or tonumber(pg.me.onVehicleActorId) ~= tonumber(vehicleActorId) then
		return
	end

	if typingType ~= nil then
		pg.me:notifyPlayerTyping({
			uid
		}, typingType)

		return
	end

	local quickChat = pg.global.ui.hudV2 and pg.global.ui.hudV2.LD and pg.global.ui.hudV2.LD.quickChat

	if quickChat ~= nil then
		quickChat:syncVehicleTypingToUid(uid, vehicleActorId)
	else
		pg.me:notifyPlayerTyping({
			uid
		}, ClientConst.PlayerTyping.None)
	end
end

function ClientVehicleOpComponent:refreshVehicle()
	if self.postInitialized ~= true then
		return
	end

	local vehicleId = self.onVehicleActorId
	local seatId = self.seatId
	local vehicle = pg.getEntityByActorId(vehicleId)

	if vehicle == self.curVehicle and self.curSeatId == seatId then
		return
	end

	if vehicleId == 0 then
		self:onDismount()

		return
	end

	if vehicle == nil then
		return
	end

	self:onMount(vehicle, seatId)
end

function ClientVehicleOpComponent:onMount(vehicle, seatId)
	self.curVehicle = vehicle
	self.curSeatId = seatId

	vehicle:entityMount(self, seatId)

	self.isIndependentPetVehiclePassenger = Utils.isPet(self) and not self.isInControl and VehicleUtils.isPetOnlyVehicle(vehicle)

	if not Utils.isHomePet(self) and not self.isIndependentPetVehiclePassenger then
		pg.me:registerInRiding(self, vehicle)
	end

	self:postComponentMethod("EVENT_OnEnterVehicle", vehicle, seatId)

	if self.authority == Const.AUTHORITY_MASTER and (self.isMainPlayer or self.isInControl) and pg.me and pg.me.setKeepAwayState then
		pg.me:setKeepAwayState(ClientConst.SpaceFollowKeepAwayReason.Vehicle, true)
	end

	self:refreshMountVisible()
	self:openVehicleSimpleChat()
	self:syncVehicleChatTypingToMe(self.uid, vehicle.actorId)
end

function ClientVehicleOpComponent:onDismount()
	if self.curVehicle == nil then
		return
	end

	if self.curVehicle.isDestroyed then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			self.logger:warn("onDismount curVehicle already destroyed, entityDismount first, vehicleId %s seatId %s", self.curVehicle.actorId, self.curSeatId)
		end

		self.curVehicle:entityDismount(self, self.curSeatId)
	end

	if self.isMainPlayer ~= true then
		self:syncVehicleChatTypingToMe(self.uid, self.curVehicle.actorId, ClientConst.PlayerTyping.None)
		pg.game.chat:showEntityMessageTypingByUid(self.uid, ClientConst.PlayerTyping.None)
	end

	self:closeVehicleSimpleChat()

	if not Utils.isHomePet(self) and not self.isIndependentPetVehiclePassenger then
		pg.me:unregisterInRiding(self)
	end

	self:postComponentMethod("EVENT_OnExitVehicle", self.curVehicle, self.curSeatId)

	if self.authority == Const.AUTHORITY_MASTER and (self.isMainPlayer or self.isInControl) and pg.me and pg.me.setKeepAwayState then
		pg.me:setKeepAwayState(ClientConst.SpaceFollowKeepAwayReason.Vehicle, false)
	end

	if self.curVehicle ~= nil and not self.curVehicle.isDestroyed then
		self.curVehicle:entityDismount(self, self.curSeatId)
	end

	self.curVehicle = nil
	self.curSeatId = 0
	self.isIndependentPetVehiclePassenger = false

	self:refreshMountVisible()
end

function ClientVehicleOpComponent:tryAutoMountBonfire(tryCount)
	tryCount = tryCount or 10

	if not GlobalData.RespawnBonfirePointId then
		return
	end

	if self.autoMountBonfireTimerId then
		self:removeTimer(self.autoMountBonfireTimerId)

		self.autoMountBonfireTimerId = nil
	end

	self.autoMountBonfireTimerId = self:addRepeatTimer(1, function()
		tryCount = tryCount - 1

		local ok, err = self:autoMountBonfire()

		if ok or tryCount <= 0 then
			self:removeTimer(self.autoMountBonfireTimerId)

			self.autoMountBonfireTimerId = nil
			GlobalData.RespawnBonfirePointId = nil
		end

		self.logger:debug("tryAutoMountBonfire, ok=%s, err=%s, remainTryCount=%s", ok, NoticeDef.getRepr(err), tryCount)
	end)
end

function ClientVehicleOpComponent:autoMountBonfire()
	local CHECK_DISTANCE_POINT = 10
	local CHECK_DISTANCE_ACTOR = 10
	local sdd = SceneData[self.space and self.space.sceneId]

	if sdd == nil or not ToBool(sdd.isBonfire) then
		return false, NoticeDef.ERROR_SCENE_VALID
	end

	local pointId = GlobalData.RespawnBonfirePointId

	if pointId == nil then
		return false, NoticeDef.ERROR_INVALID_STATUS
	end

	local mainSceneId = SceneUtils.getMainSceneId(self.space.sceneId)
	local position = SceneUtils.getMapMarkPositionById(mainSceneId, pointId)

	if position == nil then
		return false, NoticeDef.ERROR_POSITION_VALID
	end

	local distance = Vector3.Distance(self:getPosition(), position)

	if CHECK_DISTANCE_POINT < distance then
		return false, NoticeDef.ERROR_INVALID_DISTANCE
	end

	local ClientBonfire = require("Entities.SpaceEntities.VehicleEntities.ClientBonfire")
	local actorIds = self:entitiesInRange(CHECK_DISTANCE_ACTOR, Const.SEARCH_USR_TYPE_OTHER)

	if #actorIds > 0 then
		for _, actorId in ipairs(actorIds) do
			local ent = pg.getEntityByActorId(actorId)

			if ent and class.isInstanceOf(ent, ClientBonfire) and self:checkEnterVehicle(nil, ent.getVehicleConfig and ent:getVehicleConfig().enterConflictType) then
				ent:tryMount(self)
				self.logger:debug("autoMountBonfire %s tryMount %s", self:repr(), ent:repr())

				return true, NoticeDef.SUCCESS
			end
		end
	end

	return false, NoticeDef.ERROR_INVALID_TARGET
end

return ClientVehicleOpComponent
