-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientSeatComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local class = require("Core.Framework.Class")
local vehicle_data = require("Data.vehicle_data")
local ClientSeatComponent = class.Component("ClientSeatComponent")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Vector3 = Vector3
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local VehicleUtils = require("Common.Utils.VehicleUtils")
local vehicle_seat_data = require("Data.vehicle_seat_data")
local vehicle_seat_attach_data = require("Data.vehicle_seat_attach_data")
local item_attach_data = require("Data.item_attach_data")
local MessageName = require("Const.MessageName")
local ConflictTypes = require("Common.ConflictTypes")
local InteractionConst = require("Common.Const.InteractionConst")
local ClientConst = require("Const.ClientConst")
local AddressDataConst = require("Const.AddressDataConst")
local NoticeDef = require("Common.NoticeDef")

local function getSeatAttachId(seatData, attachType)
	if attachType == "player" then
		return seatData.playerAttachId
	elseif attachType == "homePet" then
		return seatData.homePetAttachId or seatData.petAttachId
	end

	return seatData.petAttachId
end

function ClientSeatComponent:ctor()
	return
end

function ClientSeatComponent:init(dict)
	return true
end

function ClientSeatComponent:EVENT_onModelLoaded()
	if self.entityMap then
		for k, v in pairs(self.entityMap) do
			local entity = pg.getEntityByActorId(k)

			if entity and entity.refreshVehicle then
				entity:refreshVehicle()
			end
		end
	end

	self:refreshFullSeatEffect()
end

function ClientSeatComponent:EVENT_OnModelVisibleChange(visible)
	local effectIds = self.vehicleBodyEffectIds
	local eModel = self.eModel

	if effectIds and eModel then
		for _, effectId in ipairs(effectIds) do
			eModel:SetEffectVisibleById(Const.COMPONENT_INDEX_EFFECT, effectId, visible)
		end
	end

	for k, v in pairs(self.entityMap) do
		local entity = pg.getEntityByActorId(k)

		if entity and entity.refreshMountVisible then
			entity:refreshMountVisible()
		end
	end
end

function ClientSeatComponent:getSeatInteractionList()
	local enterInteractId = self:getVehicleConfig().enterInteractId

	if enterInteractId then
		return {
			{
				checkEntity = true,
				actionPrototypeId = enterInteractId,
				overrideType = InteractionConst.INTERACTION_TYPE_SWITCH,
				globalId = self:getGlobalId(),
				interactFunc = function()
					if VehicleUtils.isPetOnlyVehicle(self) and Utils.isPlayer(pg.pawn) then
						self:tryMountCurrentPet(pg.pawn)
					else
						self:tryMount(pg.pawn)
					end
				end,
				canInteractiveFunc = function()
					if not self:checkBodyAnimationAllowsMount() then
						return false
					end

					return pg.pawn:checkEnterVehicle(true, self:getVehicleConfig().enterConflictType)
				end
			}
		}
	end
end

function ClientSeatComponent:checkBodyAnimationAllowsMount()
	if self.canMountByBodyAnimation then
		return self:canMountByBodyAnimation()
	end

	return true
end

function ClientSeatComponent:tryMountCurrentPet(player)
	if not self:checkBodyAnimationAllowsMount() then
		return
	end

	if not player.isMainAuthority or not player.isMainPlayer then
		return
	end

	if (player.onVehicleActorId or 0) ~= 0 then
		return
	end

	if player.checkEnterVehicle and not player:checkEnterVehicle(nil, self:getVehicleConfig().enterConflictType) then
		return
	end

	local pet = player:getCurPetEntity()

	if not pet or not pet.checkSummon or not pet:checkSummon() then
		pg.global.showBubbleMessage(NoticeDef.VEHICLE_MOUNT_FAIL_PLAYER_NO_PET)

		return
	end

	if pet.isInControl then
		return
	end

	local playerPos = player:getPosition()
	local vehiclePos = self:getPosition()
	local dist = Vector3.Distance(playerPos, vehiclePos)

	if dist > 10 then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("ClientVehicle:tryMountCurrentPet too far playerPos %s vehiclePos %s dist %s", inspect(playerPos), inspect(vehiclePos), dist)
		end

		return
	end

	local seatIndex, failReason = self:getClosestSeat(pet)

	pet:mountVehicle(self.actorId, seatIndex)
end

function ClientSeatComponent:tryPetMount(pet, seatIndex)
	if not self:checkBodyAnimationAllowsMount() then
		return false, "vehicle body animation is stopping"
	end

	if not Utils.isHomePet(pet) or not self.getVehicleConfig then
		return false, "invalid home pet or furniture"
	end

	if not self.eModel or not self.eModel then
		return false, "pet or furniture model is not loaded"
	end

	local vehicleConfig = self:getVehicleConfig()
	local seatId = vehicleConfig.seats and vehicleConfig.seats[seatIndex]
	local seatData = seatId and vehicle_seat_data[seatId]
	local attachId = seatData and getSeatAttachId(seatData, "homePet")

	if not attachId then
		return false, "seat does not support pet attachment"
	end

	if self.getActorOnSeat and self:getActorOnSeat(seatIndex) then
		return false, "seat is occupied"
	end

	pet:mountVehicle(self.actorId, seatIndex)

	return true
end

function ClientSeatComponent:tryMount(ent)
	if not self:checkBodyAnimationAllowsMount() then
		return
	end

	if ent.onVehicleActorId and ent.onVehicleActorId ~= 0 then
		return
	end

	if ent.checkEnterVehicle and not ent:checkEnterVehicle(nil, self:getVehicleConfig().enterConflictType) then
		return
	end

	local playerPos = ent:getPosition()
	local vehiclePos = self:getPosition()
	local dist = Vector3.Distance(playerPos, vehiclePos)

	if dist > 10 then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("ClientVehicle:tryMount to far playerPos %s vehiclePos %s dist %s", inspect(playerPos), inspect(vehiclePos), dist)
		end

		return
	end

	if Utils.isPet(ent) then
		if ent.isMainAuthority and ent:getMasterEntity().isMainPlayer and ent.isInControl then
			self:tryMountInControl(ent)
		end
	elseif Utils.isPlayer(ent) then
		if self.canDirectMountRideVehicle and self:canDirectMountRideVehicle() then
			if ent.isMainAuthority and ent.isMainPlayer then
				ent:mainPlayerMountVehicle(self.actorId)
			else
				ent:otherPlayerMountVehicle(self.actorId, (self:getClosestSeat(ent)))
			end
		elseif ent.isMainAuthority and ent.isMainPlayer then
			ent:mountVehicle(self.actorId, (self:getClosestSeat(ent)))
		end
	else
		ent:mountVehicle(self.actorId, (self:getClosestSeat(ent)))
	end
end

function ClientSeatComponent:tryMountInControl(petEnt)
	local player = petEnt:getMasterEntity()
	local seatIndex, failReason = self:getClosestSeat(petEnt)
	local seatId = seatIndex ~= 0 and self:getVehicleConfig().seats[seatIndex] or nil
	local seatConf = seatId and vehicle_seat_data[seatId] or nil

	if not seatConf or not seatConf.petInControl then
		if failReason == NoticeDef.VEHICLE_EXCHANGE_SEAT_INVAILD_SEAT then
			pg.global.showBubbleMessage(failReason)
		end

		return
	end

	local needSwitchToPlayer = seatConf.autoSwitchToPlayer or player.inExploreState
	local actorFilter = seatConf.actorFilter or 0
	local canPlayerSit = bit.band(2^Const.ACTOR_TYPE_PLAYER, actorFilter) ~= 0
	local canPetSit = bit.band(2^Const.ACTOR_TYPE_PET, actorFilter) ~= 0

	if needSwitchToPlayer and canPlayerSit then
		local requestSent = player:requestSwitchToPlayer(Const.CLIENT_SWITCH_REASON.Vehicle, {
			[ConflictTypes.FALL_ST] = true
		}, function()
			if not self.eModel then
				player:setPendingVehicleMount(false)

				return
			end

			player:setPendingVehicleMount(true)
			player:mountVehicle(self.actorId, (self:getClosestSeat(player)))
		end)

		if requestSent then
			player:setPendingVehicleMount(true)
		end
	elseif canPetSit then
		petEnt:mountVehicle(self.actorId, seatIndex)
	else
		pg.global.showBubbleMessage(NoticeDef.VEHICLE_EXCHANGE_SEAT_INVAILD_SEAT)
	end
end

function ClientSeatComponent:entityMount(entity, seatId)
	if self.onEntityMount then
		self:onEntityMount(entity, seatId)
	end
end

function ClientSeatComponent:entityDismount(entity, seatId)
	if self.onEntityDismount then
		self:onEntityDismount(entity, seatId)
	end
end

function ClientSeatComponent:doSkill1()
	if self.onDoSkill1 then
		self:onDoSkill1()
	end
end

function ClientSeatComponent:doSkill2()
	if self.onDoSkill2 then
		self:onDoSkill2()
	end
end

local FixedCameraMode = require("GameApp.Camera.CameraMode.FixedCameraMode")
local CameraConst = require("GameApp.Camera.CameraConst")

function ClientSeatComponent:enterControl()
	if self.vehicleCam ~= nil then
		self.vehicleCam:onCanceled()

		self.vehicleCam.cameraMode.defaultBlendTime = 0.5

		pg.game.camera:removeCamera(self.vehicleCam)

		self.vehicleCam = nil
	end

	local camLocalPos = self:getVehicleConfig().fixCameraPos
	local camLocalDir = self:getVehicleConfig().fixCameraDir

	if camLocalPos then
		local _cpx, _cpy, _cpz = self.eModel:PositionAgentTransformPointEx(camLocalPos[1], camLocalPos[2], camLocalPos[3])
		local _cdx, _cdy, _cdz = self.eModel:PositionAgentTransformDirectionEx(camLocalDir[1], camLocalDir[2], camLocalDir[3])
		local camPos = Vector3.New(_cpx, _cpy, _cpz)
		local camDir = Vector3.New(_cdx, _cdy, _cdz)
		local cam = FixedCameraMode.new()

		self.vehicleCam = cam

		cam:setPosition(camPos)
		cam:setRotation(Quaternion.LookRotation(camDir, Vector3.up))
		cam:setCameraName("vehicleCam")

		cam.cameraMode.defaultBlendTime = 0.5

		cam:setFov(self:getVehicleConfig().fixCameraFov)
		pg.game.camera:addCamera(cam, CameraConst.PRIORITY_VEHICLE)
	end

	if self.onEnterControl then
		self:onEnterControl()
	end
end

function ClientSeatComponent:exitControl()
	if self.onExitControl then
		self:onExitControl()
	end

	if self.vehicleCam ~= nil then
		self.vehicleCam:onCanceled()

		self.vehicleCam.cameraMode.defaultBlendTime = 0.5

		pg.game.camera:removeCamera(self.vehicleCam)

		self.vehicleCam = nil
	end
end

function ClientSeatComponent:isFreeRotation()
	return self:getVehicleConfig().isFreeRotation or false
end

function ClientSeatComponent:getClosestSeat(ent)
	local closeDist = 999999
	local closeSeatIndex = 0
	local switchToPlayerDist = 999999
	local switchToPlayerSeatIndex = 0
	local failReason
	local isInControlPet = Utils.isPet(ent) and ent.isInControl
	local masterPlayer = isInControlPet and ent:getMasterEntity() or nil

	for seatIndex, seatId in ipairs(self:getVehicleConfig().seats) do
		local seatData = vehicle_seat_data[seatId]

		if seatData then
			local actorFilter = seatData.actorFilter or 0
			local canPlayerSit = bit.band(2^Const.ACTOR_TYPE_PLAYER, actorFilter) ~= 0
			local switchTriggered = isInControlPet and (seatData.autoSwitchToPlayer or masterPlayer and masterPlayer.inExploreState)
			local useAsPlayer = Utils.isPlayer(ent) or switchTriggered and canPlayerSit
			local isSwitchToPlayerSeat = switchTriggered and canPlayerSit
			local attachData = useAsPlayer and vehicle_seat_attach_data[seatData.playerAttachId] or vehicle_seat_attach_data[seatData.petAttachId]
			local canSit = true
			local actorCheck = bit.band(2^(ent.actorType or 0), actorFilter) ~= 0 or seatData.petInControl and ent.actorType == Const.ACTOR_TYPE_PET

			if not actorCheck then
				canSit = false
				failReason = failReason or NoticeDef.VEHICLE_EXCHANGE_SEAT_INVAILD_SEAT
			end

			if self:getActorOnSeat(seatIndex) then
				canSit = false

				if actorCheck and attachData then
					failReason = NoticeDef.VEHICLE_MOUNT_FAIL_SEAT_USED
				end
			end

			if canSit and attachData then
				local skeletonView = self.eModel and self.eModel.skeletonView

				if skeletonView then
					local valid, matrix = skeletonView:TryGetBoneMatrix(attachData.seatHP)

					if valid then
						local bonePos = matrix:MultiplyPoint(attachData.offset)
						local dist = Vector3.Distance(bonePos, pg.pawn:getPosition())

						if isSwitchToPlayerSeat and dist < switchToPlayerDist then
							switchToPlayerDist = dist
							switchToPlayerSeatIndex = seatIndex
						elseif not isSwitchToPlayerSeat and dist < closeDist then
							closeDist = dist
							closeSeatIndex = seatIndex
						end
					elseif isSwitchToPlayerSeat and switchToPlayerSeatIndex == 0 then
						switchToPlayerSeatIndex = seatIndex
					elseif not isSwitchToPlayerSeat and closeSeatIndex == 0 then
						closeSeatIndex = seatIndex
					end
				end
			end
		end
	end

	closeSeatIndex = switchToPlayerSeatIndex ~= 0 and switchToPlayerSeatIndex or closeSeatIndex

	if closeSeatIndex ~= 0 then
		failReason = nil
	end

	return closeSeatIndex, failReason
end

function ClientSeatComponent:getActorOnSeat(index)
	for k, v in pairs(self.entityMap) do
		if v == index then
			return k
		end
	end
end

function ClientSeatComponent:anyActor()
	for _, _ in pairs(self.entityMap or EMPTY_TABLE) do
		return true
	end

	return false
end

function ClientSeatComponent:anyMainActor()
	for k, _ in pairs(self.entityMap or EMPTY_TABLE) do
		local entity = pg.getEntityByActorId(k)

		if entity ~= nil and (entity.isMainPlayer == true or entity.isMainPet == true) then
			return true
		end
	end

	return false
end

function ClientSeatComponent:getVehicleConfig()
	if self.vehicleId == nil then
		return {}
	end

	return vehicle_data[self.vehicleId] or {}
end

function ClientSeatComponent:getSeatWorldPositionBySeatIndex(seatIndex, attachType)
	local skeletonView = self.eModel and self.eModel.skeletonView

	if not skeletonView then
		return nil
	end

	local seats = self:getVehicleConfig().seats or {}

	if seats[seatIndex] then
		local seatData = vehicle_seat_data[seats[seatIndex]]

		if seatData then
			local attachId = getSeatAttachId(seatData, attachType)

			if attachId then
				local attachData = vehicle_seat_attach_data[attachId]

				if attachData and attachData.seatHP then
					local valid, matrix = skeletonView:TryGetBoneMatrix(attachData.seatHP)

					if valid then
						return matrix:MultiplyPoint(attachData.offset or {
							0,
							0,
							0
						})
					end
				end
			end
		end
	end

	return nil
end

function ClientSeatComponent:getSeatWorldPositionMap(attachType)
	local skeletonView = self.eModel and self.eModel.skeletonView

	if not skeletonView then
		return {}, string.format("vehicle model is not loaded, vehicleId=%s", tostring(self.id))
	end

	local result = {}

	attachType = attachType or "pet"

	local seats = self:getVehicleConfig().seats or {}

	for _, seatId in ipairs(seats) do
		local seatData = vehicle_seat_data[seatId]

		if seatData then
			local attachId = getSeatAttachId(seatData, attachType)

			if attachId then
				local attachData = vehicle_seat_attach_data[attachId]

				if attachData and attachData.seatHP then
					local valid, matrix = skeletonView:TryGetBoneMatrix(attachData.seatHP)

					if valid then
						result[seatId] = matrix:MultiplyPoint(attachData.offset or {
							0,
							0,
							0
						})
					end
				end
			end
		end
	end

	return result
end

function ClientSeatComponent:on_entityMap_changed(oldv, newv)
	if self.setIsOtherPlaying then
		self:setIsOtherPlaying(self:anyActor() == true and self:anyMainActor() ~= true)
	end

	self:refreshFullSeatEffect()
	facade:SendMessageCommand(MessageName.ON_CEHICLE_SEAT_MAP_CHANGED)
end

function ClientSeatComponent:on_entityCount_changed(oldv, newv)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("entityCount changed from %s to %s", oldv, newv)
	end

	self:refreshFullSeatEffect()
end

function ClientSeatComponent:stopFullSeatEffect()
	if self.fullSeatEffectId ~= nil and self.fullSeatEffectId ~= 0 then
		pg.game.effect:stopEffect(0, self.fullSeatEffectId)

		self.fullSeatEffectId = nil
	end
end

function ClientSeatComponent:playFullSeatEffect(effectKey)
	if string.isNilOrEmpty(effectKey) == true then
		return nil
	end

	if string.startsWith(effectKey, "$") == true or string.endsWith(effectKey, ".prefab") == true then
		return pg.game.effect:playRawEffectAt(nil, effectKey, self:getPosition(), {
			duration = -1
		})
	end

	return pg.game.effect:playEffectAt(nil, effectKey, self:getPosition(), Quaternion.Euler(0, 0, 0):ToEulerAngles(), nil)
end

function ClientSeatComponent:getFullSeatPlayerCount()
	local count = 0

	for actorId, _ in pairs(self.entityMap or EMPTY_TABLE) do
		local ent = pg.getEntityByActorId(actorId)

		if ent ~= nil and Utils.isPlayer(ent) == true then
			count = count + 1
		end
	end

	return count
end

function ClientSeatComponent:getFullSeatCapacity(vehicleConfig)
	local playerSeatCount = 0

	for _, seatId in ipairs(vehicleConfig.seats or EMPTY_TABLE) do
		local seatData = vehicle_seat_data[seatId]

		if seatData ~= nil and bit.band(2^Const.ACTOR_TYPE_PLAYER, seatData.actorFilter or 0) ~= 0 then
			playerSeatCount = playerSeatCount + 1
		end
	end

	if playerSeatCount > 0 then
		return playerSeatCount, self:getFullSeatPlayerCount()
	end

	return vehicleConfig.capacityLimit or #(vehicleConfig.seats or {}), self.entityCount or 0
end

function ClientSeatComponent:refreshFullSeatEffect()
	local vehicleConfig = self:getVehicleConfig()
	local effectKey = vehicleConfig.fullSeatEffect

	if string.isNilOrEmpty(effectKey) == true then
		self:stopFullSeatEffect()

		return
	end

	local capacityLimit, entityCount = self:getFullSeatCapacity(vehicleConfig)

	if capacityLimit <= 0 then
		self:stopFullSeatEffect()

		return
	end

	if capacityLimit <= entityCount then
		if self.fullSeatEffectId == nil or self.fullSeatEffectId == 0 then
			self.fullSeatEffectId = self:playFullSeatEffect(effectKey)
		end
	else
		self:stopFullSeatEffect()
	end
end

function ClientSeatComponent:getSeatBoneName(actorId)
	local seatIndex = self.entityMap[actorId]

	if not seatIndex then
		return nil
	end

	local seatId = self:getVehicleConfig().seats[seatIndex]

	if not seatId then
		return nil
	end

	local seatData = vehicle_seat_data[seatId]

	if not seatData then
		return nil
	end

	local ent = pg.getEntityByActorId(actorId)

	if Utils.isPlayer(ent) then
		local attachData = vehicle_seat_attach_data[seatData.playerAttachId]

		if not attachData then
			return nil
		end

		return attachData.passengerHP
	elseif Utils.isPet(ent) or Utils.isPuppet(ent) then
		local attachData = vehicle_seat_attach_data[seatData.npcAttachId]

		if not attachData then
			return nil
		end

		return attachData.passengerHP
	elseif Utils.isChest(ent) or Utils.isEnvObj(ent) then
		local attachData = item_attach_data[seatData.itemAttachId]

		if not attachData then
			return nil
		end

		return attachData.selfHP
	end
end

function ClientSeatComponent:destroy()
	self:stopFullSeatEffect()
end

function ClientSeatComponent:checkEnableMountAnimState()
	if self:getVehicleConfig().disableSyncAnimState then
		return false
	end

	return true
end

function ClientSeatComponent:syncChildMountAnimState()
	if not self:checkEnableMountAnimState() then
		return false
	end

	local syncState

	if self.getMountAnimSyncState then
		syncState = self:getMountAnimSyncState()
	end

	for k, v in pairs(self.entityMap) do
		local entity = pg.getEntityByActorId(k)

		if entity and entity.syncMountAnimState then
			entity:syncMountAnimState(true, syncState)
		end
	end
end

return ClientSeatComponent
