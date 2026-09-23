-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Home\\HomeCar\\HomeCarGroup.lua

local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
local ClientUtils = require("Utils.ClientUtils")
local HomeObjectData = require("Data.home_object_data")
local Utils = require("Common.Utils.Utils")
local HomelandFastFindMap = require("Common.Homeland.HomelandFastFindMap")
local HomeCampCarData = require("Data.home_camp_car_data")
local HomeCarGroup = Class.LightClass("HomeCarGroup")
local CallbackHandler = require("Core.Common.CallbackHandler")
local Time = require("Core.Common.Time")
local HomeCampData = require("Data.home_camp_data")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local SceneUtils = require("Common.Utils.SceneUtils")
local ADD_ORNAMENT_REQUEST_TIMEOUT = 5

function HomeCarGroup:ctor(playerUID, campId, carPlaceId)
	self.playerUID = playerUID
	self.placeId = carPlaceId
	self.campId = campId
	self.carEntity = nil
	self.boardEntity = nil
	self.isInEdit = false
	self.ornamentEntities = {}
	self.virtualHomeEntities = {}
	self.tempCollideResult = {}

	self:initBaseTransform()
end

function HomeCarGroup:destroy()
	local _h = HomeCarGroup._platformHooks

	if _h and _h.destroy then
		_h.destroy(self)
	end

	self:exitBuildMode()
	self:destroyGroupEntities()
end

function HomeCarGroup:updateHomeCarState()
	return
end

function HomeCarGroup:setCurState(state)
	self.curState = state
end

function HomeCarGroup:tickHomeCarGroup()
	local valid = true

	if self:isVirtualCampCar() then
		if pg.game.homeCar.curWorldCampId ~= self.campId then
			valid = false
		elseif not self.basicInfo then
			valid = false
		end

		if pg.space and Utils.isHomeCamp(pg.space.spaceType) then
			if not self.waitDestroyTime then
				self.waitDestroyTime = Time.realSecondCache + 3
			elseif Time.realSecondCache > self.waitDestroyTime then
				valid = false
			end
		else
			self.waitDestroyTime = nil
		end
	else
		self.waitDestroyTime = nil
	end

	return valid
end

function HomeCarGroup:isVirtualCampCar()
	return self.campCarEnt == nil
end

function HomeCarGroup:setLightCampData(basicInfo)
	if self.campCarEnt then
		return
	end

	self.basicInfo = basicInfo

	if not self.basicInfo then
		return
	end

	self:createGroupEntities()
end

function HomeCarGroup:loadFullCampData(campCarEnt, basicInfo)
	self.campCarEnt = campCarEnt
	self.basicInfo = basicInfo

	self:createGroupEntities()
end

function HomeCarGroup:unloadFullCampData()
	self.campCarEnt = nil

	self:destroyOrnamentEntities()
end

function HomeCarGroup:updateBasicInfo(basicInfo)
	self.basicInfo = basicInfo

	if self.carEntity then
		self.carEntity:onBasicInfoChanged(basicInfo)
	end

	if self.boardEntity then
		self.boardEntity:onBasicInfoChanged(basicInfo)
	end
end

function HomeCarGroup:onLikeCntChanged()
	if self.boardEntity then
		self.boardEntity:onLikeCntChanged()
	end
end

function HomeCarGroup:refreshPetInfos()
	if self.boardEntity then
		self.boardEntity:onPetInfoChanged()
	end
end

function HomeCarGroup:getHomePlaceConfig()
	return HomeCampCarData[self.placeId] or {}
end

function HomeCarGroup:startEdit()
	local editor = pg.game.homeCar.editor

	editor:setTargetCarGroup(self)
	pg.global.ui.homelandEditor:open({
		editor = editor,
		carGroup = self
	})
end

function HomeCarGroup:getOrnamentCurTemplateNum(templateId)
	return 0
end

function HomeCarGroup:getOrnamentCurPlaceNum(templateId)
	return 0
end

function HomeCarGroup:getCarPlacePosition(staticId)
	local campData = HomeCampData[self.campId]
	local sceneId = SceneUtils.getMainSceneId(campData.sceneId)
	local pos, rot = SceneUtils.getCommonBasicsPosition(sceneId, staticId)

	return pos, rot
end

function HomeCarGroup:initBaseTransform()
	local placeConfig = self:getHomePlaceConfig()
	local centerPos, centerRot = self:getCarPlacePosition(placeConfig.ornamentCenter)
	local baseTransMatrix = Matrix4x4.TRS(centerPos, centerRot, Vector3.constOne)

	self.baseTransMatrix = baseTransMatrix
	self.baseTransMatrixInv = baseTransMatrix.inverse
	self.baseRotation = baseTransMatrix.rotation
	self.baseRotationInv = self.baseRotation:Inverse()
end

function HomeCarGroup:getWorldPosition(position)
	if self.baseTransMatrix then
		return self.baseTransMatrix:MultiplyPoint(position)
	end

	return position
end

function HomeCarGroup:getWorldRotation(rotation)
	if self.baseRotation then
		return self.baseRotation * rotation
	end

	return rotation
end

function HomeCarGroup:enterSpaceEntities(space)
	if space == nil then
		return
	end

	self:enterEntitySpace(self.boardEntity, space)
	self:enterEntitySpace(self.carEntity, space)

	for _, homeEntity in pairs(self.ornamentEntities) do
		self:enterEntitySpace(homeEntity, space)
	end

	for _, homeEntity in pairs(self.virtualHomeEntities) do
		self:enterEntitySpace(homeEntity, space)
	end
end

function HomeCarGroup:leaveSpaceEntities(space)
	if space == nil then
		return
	end

	self:leaveEntitySpace(self.boardEntity, space)
	self:leaveEntitySpace(self.carEntity, space)

	for _, homeEntity in pairs(self.ornamentEntities) do
		self:leaveEntitySpace(homeEntity, space)
	end

	for _, homeEntity in pairs(self.virtualHomeEntities) do
		self:leaveEntitySpace(homeEntity, space)
	end
end

function HomeCarGroup:enterEntitySpace(homeEntity, space)
	if homeEntity and homeEntity.enterSpace and homeEntity.space == nil then
		homeEntity:enterSpace(space)
	end
end

function HomeCarGroup:leaveEntitySpace(homeEntity, space)
	if homeEntity and homeEntity.leaveSpace and homeEntity.space == space then
		homeEntity:leaveSpace()
	end
end

function HomeCarGroup:getLocalPosition(position)
	if self.baseTransMatrixInv then
		return self.baseTransMatrixInv:MultiplyPoint(position)
	end

	return position
end

function HomeCarGroup:getLocalRotation(rotation)
	if self.baseRotationInv then
		return self.baseRotationInv * rotation
	end

	return rotation
end

function HomeCarGroup:createGroupEntities()
	self:createOrUpdateCarEntity()
	self:createBoardEntity()
end

function HomeCarGroup:destroyGroupEntities()
	self:destroyCarEntity()
	self:destroyBoardEntity()
	self:destroyOrnamentEntities()
end

function HomeCarGroup:createOrUpdateCarEntity()
	if not self.carEntity then
		local placeConfig = self:getHomePlaceConfig()
		local carPosition, carRotation = self:getCarPlacePosition(placeConfig.carPosition)

		self.carEntity = ClientUtils.createClientEntity("ClientHomeCar", VirtualEntUtils.getNewVirtualEntityId(), {
			playerUID = self.playerUID,
			position = carPosition,
			rotation = carRotation
		})
	end

	self.carEntity:setCarData(self.basicInfo)
end

function HomeCarGroup:destroyCarEntity()
	if self.carEntity then
		ClientUtils.safeDestroy(self.carEntity)

		self.carEntity = nil
	end
end

function HomeCarGroup:createBoardEntity()
	if not self.boardEntity then
		local placeConfig = self:getHomePlaceConfig()
		local boardPosition, boardRotation = self:getCarPlacePosition(placeConfig.boardPosition)

		self.boardEntity = ClientUtils.createClientEntity("ClientHomeCarBoard", VirtualEntUtils.getNewVirtualEntityId(), {
			playerUID = self.playerUID,
			templateId = Const.HOME_CAR_BOARD_NPC_ID,
			position = boardPosition,
			rotation = boardRotation
		})
	else
		self.boardEntity:onBasicInfoChanged(self.basicInfo)
	end
end

function HomeCarGroup:destroyBoardEntity()
	if self.boardEntity then
		ClientUtils.safeDestroy(self.boardEntity)

		self.boardEntity = nil
	end
end

function HomeCarGroup:createHomeCarEntities(ornamentData)
	local _h = HomeCarGroup._platformHooks

	if _h and _h.createHomeCarEntities and _h.createHomeCarEntities(self, ornamentData) == true then
		return
	end

	self:destroyOrnamentEntities()

	for ornamentId, ornamentInfo in pairs(ornamentData) do
		self:createHomeCarEntity(ornamentId, ornamentInfo)
	end
end

function HomeCarGroup:destroyHomeCarEntityById(ornamentId)
	local homeEntity = self.ornamentEntities[ornamentId]

	if homeEntity and homeEntity.isClientEnt then
		ClientUtils.safeDestroy(homeEntity)
	end
end

function HomeCarGroup:destroyOrnamentEntities()
	self.isDestroyingAll = true

	for ornamentId, homeCarEntity in pairs(self.ornamentEntities) do
		self:destroyHomeCarEntity(homeCarEntity)
	end

	self.isDestroyingAll = false
end

function HomeCarGroup:registerHomeCarEnt(ornamentId, ent)
	self.ornamentEntities[ornamentId] = ent

	self:onOrnamentAdd(ornamentId, ent)
end

function HomeCarGroup:unregisterHomeCarEnt(ornamentId, ent)
	self:onOrnamentRemove(ornamentId, ent)

	if self.ornamentEntities[ornamentId] == ent then
		self.ornamentEntities[ornamentId] = nil
	end
end

function HomeCarGroup:getHomeEntity(ornamentId)
	if ornamentId < 0 then
		return self.virtualHomeEntities[ornamentId]
	end

	return self.ornamentEntities[ornamentId]
end

function HomeCarGroup:registerVirtualHomeEnt(ornamentId, homeEntity)
	self.virtualHomeEntities[ornamentId] = homeEntity

	self:onOrnamentAdd(ornamentId, homeEntity)
end

function HomeCarGroup:unregisterVirtualHomeEnt(ornamentId, homeEntity)
	self:onOrnamentRemove(ornamentId, homeEntity)

	self.virtualHomeEntities[ornamentId] = nil
end

function HomeCarGroup:createHomeCarEntity(ornamentId, ornamentInfo)
	local _h = HomeCarGroup._platformHooks

	if _h and _h.createHomeCarEntity then
		local handled, result = _h.createHomeCarEntity(self, ornamentId, ornamentInfo)

		if handled == true then
			return result
		end
	end

	local templateId = ornamentInfo.homeId
	local position = self:getWorldPosition(ornamentInfo:getPosition())
	local rotation = self:getWorldRotation(ornamentInfo:getRotation())
	local scale = ornamentInfo:getScale()
	local areaId = ornamentInfo.areaId
	local ent = self.ornamentEntities[ornamentId]

	if ent then
		return ent
	end

	return self:innerCreateHomeCarEntity(ornamentId, areaId, templateId, position, rotation, scale)
end

function HomeCarGroup:getClientEntityClassName(homeObjectData)
	return "ClientHomeCarOrnamentEntity"
end

function HomeCarGroup:innerCreateHomeCarEntity(ornamentId, areaId, homeTemplateId, position, rotation, scale)
	local configData = HomeObjectData[homeTemplateId] or {}

	if Utils.checkIsServerHomeObject(homeTemplateId) then
		return
	end

	local className = self:getClientEntityClassName(configData)

	rotation = rotation or Quaternion.identity

	local homeEntity = ClientUtils.createClientEntity(className, VirtualEntUtils.getNewVirtualEntityId(), {
		homeTemplateId = homeTemplateId,
		playerUID = self.playerUID,
		ornamentId = ornamentId,
		position = position,
		areaId = areaId,
		rotation = rotation
	})

	if homeEntity and scale and homeEntity.setScale then
		homeEntity:setScale(scale)
	end

	return homeEntity
end

function HomeCarGroup:destroyHomeCarEntity(homeEntity)
	if homeEntity.isClientEnt then
		ClientUtils.safeDestroy(homeEntity)
	end
end

function HomeCarGroup:updateHomeCarEntity(ornamentId, ornamentInfo)
	local _h = HomeCarGroup._platformHooks

	if _h and _h.updateHomeCarEntity and _h.updateHomeCarEntity(self, ornamentId, ornamentInfo) == true then
		return
	end

	local homeEntity = self.ornamentEntities[ornamentId]

	if homeEntity and homeEntity.isClientEnt then
		if ornamentInfo.homeId ~= homeEntity.homeTemplateId then
			self:destroyHomeCarEntityById(ornamentId)
			self:createHomeCarEntity(ornamentId, ornamentInfo)
		else
			local position = self:getWorldPosition(ornamentInfo:getPosition())
			local rotation = self:getWorldRotation(ornamentInfo:getRotation())
			local scale = ornamentInfo:getScale()

			homeEntity:forceSetPos(position)
			homeEntity:forceSetRot(rotation)

			if scale and homeEntity.setScale then
				homeEntity:setScale(scale)
			end

			if homeEntity.onEntityPositionChanged then
				homeEntity:onEntityPositionChanged()
			end
		end
	end
end

function HomeCarGroup:setInBuildMode(isInBuildMode)
	if self.isInBuildMode ~= isInBuildMode then
		self.isInBuildMode = isInBuildMode

		if isInBuildMode then
			self:enterBuildMode()
		else
			self:exitBuildMode()
		end
	end
end

function HomeCarGroup:enterBuildMode()
	if not self.fastFindMap then
		self.fastFindMap = HomelandFastFindMap.new(16)
	end

	for ornamentId, ent in pairs(self.ornamentEntities) do
		self.fastFindMap:addOrUpdateFastFindInfo(ornamentId, ent:getBoundSize(), self:getLocalPosition(ent:getPositionAgentPosition()), self:getLocalRotation(ent:getPositionAgentRotation()), self:getFastFindExtraInfo(ent))
	end
end

function HomeCarGroup:getFastFindExtraInfo(ent)
	local extraInfo = {}

	extraInfo.homeTemplateId = ent.homeTemplateId
	extraInfo.layer = ent:getOrnamentLayer()
	extraInfo.ent = ent

	HomeLandUtils.addFastFindAttachExtraInfo(ent, extraInfo)

	return extraInfo
end

function HomeCarGroup:exitBuildMode()
	if self.fastFindMap then
		self.fastFindMap:clearFastFindInfo()
	end
end

function HomeCarGroup:onOrnamentPositionChanged(ornamentId)
	if not self.fastFindMap then
		return
	end

	local ent = self:getHomeEntity(ornamentId)

	if not ent then
		return
	end

	self.fastFindMap:refreshFastFindInfo(ornamentId, self:getLocalPosition(ent:getPositionAgentPosition()), self:getLocalRotation(ent:getPositionAgentRotation()), ent:getBoundSize())
end

function HomeCarGroup:onOrnamentAdd(ornamentId, ent)
	if not self.fastFindMap then
		return
	end

	if not self.isInBuildMode then
		return
	end

	self.fastFindMap:addOrUpdateFastFindInfo(ornamentId, ent:getBoundSize(), self:getLocalPosition(ent:getPositionAgentPosition()), self:getLocalRotation(ent:getPositionAgentRotation()), self:getFastFindExtraInfo(ent))
end

function HomeCarGroup:onOrnamentRemove(ornamentId, ent)
	if not self.fastFindMap then
		return
	end

	self.fastFindMap:removeFastFindInfo(ornamentId)
end

function HomeCarGroup:getPositionOrnament(position)
	local localPosition = self:getLocalPosition(position)

	self.fastFindMap:getAreaRangeOrnamentIds(localPosition.x, localPosition.x, localPosition.z, localPosition.z, false, self.tempCollideResult)

	for collideOrnamentId, fastInfo in pairs(self.tempCollideResult) do
		if fastInfo.extraInfo.ent.visible then
			return fastInfo.extraInfo.ent
		end
	end
end

function HomeCarGroup:checkPosCollide(ornamentId, collideOrnaments, threshold)
	local fastFindInfo = self.fastFindMap:getFastFindInfo(ornamentId)

	if not fastFindInfo then
		return false
	end

	local hBoundX, hBoundZ = fastFindInfo:getHalfBoundWithRot()
	local minX = fastFindInfo.position.x - hBoundX
	local maxX = fastFindInfo.position.x + hBoundX
	local minZ = fastFindInfo.position.z - hBoundZ
	local maxZ = fastFindInfo.position.z + hBoundZ

	self.fastFindMap:getAreaRangeOrnamentIds(minX, maxX, minZ, maxZ, false, self.tempCollideResult, threshold)

	self.tempCollideResult[ornamentId] = nil

	local selfLayer = fastFindInfo.extraInfo.layer

	for collideOrnamentId, fastInfo in pairs(self.tempCollideResult) do
		if bit.band(selfLayer, fastInfo.extraInfo.layer) == 0 then
			self.tempCollideResult[collideOrnamentId] = nil
		elseif not fastInfo.extraInfo.ent.visible then
			self.tempCollideResult[collideOrnamentId] = nil
		end
	end

	if collideOrnaments then
		table.clear(collideOrnaments)

		for collideOrnamentId, _ in pairs(self.tempCollideResult) do
			collideOrnaments[collideOrnamentId] = true
		end
	end

	return next(self.tempCollideResult) ~= nil
end

function HomeCarGroup:getAreaOrnaments(minX, maxX, minZ, maxZ, ornaments, minHeight, maxHeight, filterFunc, slowFilterFunc)
	self.fastFindMap:getAreaRangeOrnamentIds(minX, maxX, minZ, maxZ, false, ornaments, nil, minHeight, maxHeight, filterFunc, slowFilterFunc)

	return true
end

function HomeCarGroup:_startAddOrnamentLock()
	self._isAddOrnamentRequesting = true

	self:_clearAddOrnamentTimeout()

	self._addOrnamentTimeoutTimer = pg.game.homeCar:startTimer(function()
		self._addOrnamentTimeoutTimer = nil
		self._isAddOrnamentRequesting = false
	end, ADD_ORNAMENT_REQUEST_TIMEOUT)
end

function HomeCarGroup:_endAddOrnamentLock()
	self._isAddOrnamentRequesting = false

	self:_clearAddOrnamentTimeout()
end

function HomeCarGroup:_clearAddOrnamentTimeout()
	if self._addOrnamentTimeoutTimer then
		pg.game.homeCar:killTimer(self._addOrnamentTimeoutTimer)

		self._addOrnamentTimeoutTimer = nil
	end
end

function HomeCarGroup:addOrnament(homeTemplateId, localPosition, localRotation, localScale)
	if self._isAddOrnamentRequesting then
		return
	end

	local ornamentInfo = HomeLandUtils.fillOrnamentTransform({
		homeId = homeTemplateId
	}, localPosition, localRotation, localScale or Vector3.constOne)

	self:_startAddOrnamentLock()
	pg.me:serverMsg("RPC_CS_AddCarOrnament", ornamentInfo, CallbackHandler(self, "onAddOrnamentCallback"))
end

function HomeCarGroup:onAddOrnamentCallback(code, ornamentId, homeId)
	self:_endAddOrnamentLock()
	pg.me:showOrnamentNotice(code)

	local isSucc = code == Const.HOMELAND_ORNAMENT_OP_RETURN_CODE.SUCCESS

	pg.game.homeCar.editor:onEditOrnamentResult(isSucc, Const.HOMELAND_ORNAMENT_OP_TYPE.ADD)
end

function HomeCarGroup:addOrnaments(ornamentsData)
	if self._isAddOrnamentRequesting then
		return
	end

	local ornamentsInfo = {}

	for _, ornamentData in ipairs(ornamentsData) do
		local ornamentInfo = HomeLandUtils.fillOrnamentTransform({
			homeId = ornamentData.homeTemplateId,
			clientOrnamentId = ornamentData.clientOrnamentId
		}, ornamentData.position, ornamentData.rotation, ornamentData.scale or Vector3.constOne)

		table.insert(ornamentsInfo, ornamentInfo)
	end

	self:_startAddOrnamentLock()
	pg.me:serverMsg("RPC_CS_AddCarOrnaments", ornamentsInfo, CallbackHandler(self, "onAddOrnamentsCallback"))
end

function HomeCarGroup:onAddOrnamentsCallback(code)
	self:_endAddOrnamentLock()
	pg.me:showOrnamentNotice(code)

	local isSucc = code == Const.HOMELAND_ORNAMENT_OP_RETURN_CODE.SUCCESS

	pg.game.homeCar.editor:onEditOrnamentResult(isSucc, Const.HOMELAND_ORNAMENT_OP_TYPE.ADD)
end

function HomeCarGroup:updateOrnament(ornamentId, localPosition, localRotation, localScale)
	local ornamentInfo = HomeLandUtils.fillOrnamentTransform({}, localPosition, localRotation, localScale)

	pg.me:serverMsg("RPC_CS_UpdateCarOrnament", ornamentId, ornamentInfo, CallbackHandler(self, "onUpdateOrnamentCallback"))
end

function HomeCarGroup:onUpdateOrnamentCallback(code, ornamentId)
	pg.me:showOrnamentNotice(code)

	local isSucc = code == Const.HOMELAND_ORNAMENT_OP_RETURN_CODE.SUCCESS

	pg.game.homeCar.editor:onEditOrnamentResult(isSucc, Const.HOMELAND_ORNAMENT_OP_TYPE.UPDATE)
end

function HomeCarGroup:updateOrnaments(updateDict, buildExtraData)
	local ornamentUpdateInfo = {}

	for ornamentId, ornamentInfo in pairs(updateDict) do
		local updateInfo = HomeLandUtils.fillOrnamentTransform({}, ornamentInfo.position, ornamentInfo.rotation, ornamentInfo.scale)

		updateInfo.clientOrnamentId = ornamentInfo.clientOrnamentId
		ornamentUpdateInfo[ornamentId] = updateInfo
	end

	pg.me:serverMsg("RPC_CS_UpdateCarOrnaments", ornamentUpdateInfo, buildExtraData or {}, CallbackHandler(self, "onUpdateOrnamentsCallback"))
end

function HomeCarGroup:onUpdateOrnamentsCallback(code)
	pg.me:showOrnamentNotice(code)

	local isSucc = code == Const.HOMELAND_ORNAMENT_OP_RETURN_CODE.SUCCESS

	pg.game.homeCar.editor:onEditOrnamentResult(isSucc, Const.HOMELAND_ORNAMENT_OP_TYPE.UPDATE)
end

function HomeCarGroup:removeOrnament(ornamentId)
	pg.me:serverMsg("RPC_CS_RemoveCarOrnament", ornamentId, CallbackHandler(self, "onRemoveOrnamentCallback"))
end

function HomeCarGroup:onRemoveOrnamentCallback(code, ornamentId)
	pg.me:showOrnamentNotice(code)

	local isSucc = code == Const.HOMELAND_ORNAMENT_OP_RETURN_CODE.SUCCESS

	pg.game.homeCar.editor:onEditOrnamentResult(isSucc, Const.HOMELAND_ORNAMENT_OP_TYPE.REMOVE)
end

function HomeCarGroup:removeOrnaments(ornamentIds)
	pg.me:serverMsg("RPC_CS_RemoveCarOrnaments", ornamentIds, CallbackHandler(self, "onRemoveOrnamentsCallback"))
end

function HomeCarGroup:onRemoveOrnamentsCallback(code, ornamentIds)
	pg.me:showOrnamentNotice(code)

	local isSucc = code == Const.HOMELAND_ORNAMENT_OP_RETURN_CODE.SUCCESS

	pg.game.homeCar.editor:onEditOrnamentResult(isSucc, Const.HOMELAND_ORNAMENT_OP_TYPE.REMOVE)
end

return HomeCarGroup
