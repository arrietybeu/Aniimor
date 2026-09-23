-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\HomeCar\\ClientHomeCar.lua

local Class = require("Core.Framework.Class")
local ClientModelEntity = require("Entities.ClientModelEntity")
local ClientModelComponent = require("Entities.SpaceEntities.CommonComponent.ClientModelComponent")
local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
local Const = require("Common.Const.Const")
local HomelandConfigData = require("Data.homeland_config_data")
local TimerManager = require("Core.Timer.TimerManager")
local HOME_CAR_PENETRATION_MIN_SEARCH_HEIGHT = 4
local HOME_CAR_PENETRATION_HEIGHT_MULTIPLIER = 4
local HOME_CAR_PENETRATION_MIN_SEARCH_STEP = 0.1
local HOME_CAR_PENETRATION_STEP_RADIUS_RATIO = 0.5
local HOME_CAR_PENETRATION_BINARY_SEARCH_COUNT = 8
local HOME_CAR_PENETRATION_HORIZONTAL_PADDING = 1
local HOME_CAR_PENETRATION_QUERY_OFFSET = 0.003
local ClientAoiComponent = require("Entities.SpaceEntities.CommonComponent.ClientAoiComponent")
local ClientInteractionComponent = require("Entities.SpaceEntities.CommonComponent.ClientInteractionComponent")
local ClientEffectComponent = require("Entities.SpaceEntities.PlayerComponent.ClientEffectComponent")
local ClientAnimationComponent = require("Entities.SpaceEntities.CommonComponent.ClientAnimationComponent")
local ClientAudioComponent = require("Entities.SpaceEntities.CommonComponent.ClientAudioComponent")
local ClientHomeCarAppearanceComponent = require("Entities.SpaceEntities.HomeCar.ClientHomeCarAppearanceComponent")
local ClientHomeCar = Class.Class("ClientHomeCar", ClientModelEntity)
local ClientHomeCarComponents = {
	ClientAoiComponent,
	ClientModelComponent,
	ClientEffectComponent,
	ClientAnimationComponent,
	ClientAudioComponent,
	ClientInteractionComponent,
	ClientHomeCarAppearanceComponent
}

Class.AddComponents(ClientHomeCar, ClientHomeCarComponents)

function ClientHomeCar:init(dict)
	self.actorId = VirtualEntUtils.getNewVirtualEntActorId()
	self.actorType = Const.ACTOR_TYPE_HOME_OBJECT
	self.clenUsrType = Const.CLEN_USE_TYPE_HOME
	self.playerUID = dict.playerUID
	self.carGroup = pg.game.homeCar:getHomeCarGroup(self.playerUID)

	ClientHomeCar.super.init(self, dict)

	self.forbiddenTopLogo = true

	if not self.isModelLoaded then
		self.waitModelMark = true

		pg.global.scene:markWaitEntity(self.id, true)

		self.waitTimeoutTimer = TimerManager.addTimer(10, function()
			if self.waitModelMark then
				pg.global.scene:markWaitEntity(self.id, false)

				self.waitModelMark = nil
			end

			self.waitTimeoutTimer = nil
		end)
	end

	return true
end

function ClientHomeCar:start()
	ClientHomeCar.super.start(self)
	self:initInteraction()
end

function ClientHomeCar:destroy()
	if self.homeCarPenetrationResolveFrameId then
		TimerManager.delFrameCb(self.homeCarPenetrationResolveFrameId)

		self.homeCarPenetrationResolveFrameId = nil
	end

	if self.waitTimeoutTimer then
		TimerManager.removeTimer(self.waitTimeoutTimer)

		self.waitTimeoutTimer = nil
	end

	if self.waitModelMark then
		pg.global.scene:markWaitEntity(self.id, false)

		self.waitModelMark = nil
	end

	ClientHomeCar.super.destroy(self)
end

function ClientHomeCar:isSelfHomeCar()
	return self.playerUID == pg.me.uid
end

function ClientHomeCar:getConfigData()
	local interactLocalOffset = HomelandConfigData.carInteractOffset or Const.HOME_CAMP_CAR_INTERACT_OFFSET

	return {
		actionName = 1,
		interactLocalOffset = interactLocalOffset
	}
end

function ClientHomeCar:setCarData(basicInfo)
	self.basicInfo = basicInfo

	self:setShapeInfo(basicInfo, self:isSelfHomeCar())
end

function ClientHomeCar:onBasicInfoChanged(basicInfo)
	self:setCarData(basicInfo)
end

function ClientHomeCar:_getNameImpl()
	if self.basicInfo then
		return self.basicInfo.name
	end

	return ""
end

function ClientHomeCar:getName()
	local rawName = self:_getNameImpl()
	local _h = ClientHomeCar._platformHooks

	if _h and _h.getName then
		return _h.getName(self, rawName)
	end

	return rawName
end

function ClientHomeCar:getInteractName()
	return self:getName()
end

function ClientHomeCar:refreshAppearance()
	ClientHomeCar.super.refreshAppearance(self)
	self:refreshCarAppearance()
end

function ClientHomeCar:onModelRefreshed()
	if self.waitTimeoutTimer then
		TimerManager.removeTimer(self.waitTimeoutTimer)

		self.waitTimeoutTimer = nil
	end

	if self.waitModelMark then
		pg.global.scene:markWaitEntity(self.id, false)

		self.waitModelMark = nil
	end

	self.isModelLoaded = true

	self:openHomeCarDoor()
	self:postComponentMethod("EVENT_onModelLoaded")
	self:setModelLoaded(true)

	local _, shouldRetry = self:resolveMainPlayerPenetration()

	if shouldRetry then
		self:scheduleResolveMainPlayerPenetration()
	end
end

function ClientHomeCar:getPenetrationResolveHorizontalDistance(player)
	local interactOffset = HomelandConfigData.carInteractOffset or Const.HOME_CAMP_CAR_INTERACT_OFFSET
	local offsetX = interactOffset[1] or 0
	local offsetZ = interactOffset[3] or 0

	return math.sqrt(offsetX * offsetX + offsetZ * offsetZ) + player.eModel.radius + HOME_CAR_PENETRATION_HORIZONTAL_PADDING
end

function ClientHomeCar:resolveMainPlayerPenetration()
	local player = pg.me

	if not player or not player.eModel then
		return false, true
	end

	local playerPosition = player:getPositionClone()
	local maxHorizontalDistance = self:getPenetrationResolveHorizontalDistance(player)

	if Vector3.HoriSqrDistance(playerPosition, self:getPosition()) > maxHorizontalDistance * maxHorizontalDistance then
		return false, false
	end

	Physics.SyncTransforms()

	local playerRotation = player:getRotation()
	local maxSearchHeight = math.max(player.eModel.height * HOME_CAR_PENETRATION_HEIGHT_MULTIPLIER, HOME_CAR_PENETRATION_MIN_SEARCH_HEIGHT)
	local searchStep = math.max(player.eModel.radius * HOME_CAR_PENETRATION_STEP_RADIUS_RATIO, HOME_CAR_PENETRATION_MIN_SEARCH_STEP)
	local resolved, originOverlapping, targetPosition = player.eModel:TryFindUpwardNonOverlappingPosition(Const.COMPONENT_MOTION, playerPosition, playerRotation, maxSearchHeight, searchStep, HOME_CAR_PENETRATION_QUERY_OFFSET, HOME_CAR_PENETRATION_BINARY_SEARCH_COUNT)

	if not resolved then
		return false, originOverlapping
	end

	player:resetMotorTempState()
	player:setPosition(targetPosition, Const.AgentTransformReasonConst.LogicFromLua)
	self.logger:info("home car resolved main player penetration, car=%s, from=%s, to=%s", self:repr(), tostring(playerPosition), tostring(targetPosition))

	return true, false
end

function ClientHomeCar:scheduleResolveMainPlayerPenetration()
	if self.homeCarPenetrationResolveFrameId then
		TimerManager.delFrameCb(self.homeCarPenetrationResolveFrameId)
	end

	self.homeCarPenetrationResolveFrameId = TimerManager.addNextFrameCb(function()
		self.homeCarPenetrationResolveFrameId = nil

		self:resolveMainPlayerPenetration()
	end)
end

function ClientHomeCar:openHomeCarDoor()
	if self.eModel then
		self.eModel.modelView:SetModelPartRotation(Quaternion.Euler(0, -90, 0), "HomeCarDoor")
	end
end

function ClientHomeCar:initInteraction()
	if self.eModel == nil then
		return
	end

	self.interactionListData = {}

	if self:isSelfHomeCar() then
		self.interactionListData[#self.interactionListData + 1] = {
			globalId = self:getGlobalId(),
			actionPrototypeId = Const.HOME_CAMP_GO_HOMELAND_INTERACT_ID,
			canInteractiveFunc = function()
				return self:canEnterHomeland()
			end,
			interactFunc = function()
				self:doEnterHomeland()
			end
		}
	else
		self.interactionListData[#self.interactionListData + 1] = {
			globalId = self:getGlobalId(),
			actionPrototypeId = Const.HOME_CAMP_GO_HOMELAND_INTERACT_ID,
			canInteractiveFunc = function()
				return self:canEnterHomeland()
			end,
			interactFunc = function()
				self:doEnterHomeland()
			end
		}
	end

	self:postComponentMethod("EVENT_InitInteractionList")
end

function ClientHomeCar:checkCarGroupValid()
	if not self.carGroup then
		return false
	end

	if self.carGroup:isVirtualCampCar() then
		return false
	end

	return true
end

function ClientHomeCar:canEnterHomeland()
	if not self:checkCarGroupValid() then
		return false
	end

	return true
end

function ClientHomeCar:_doEnterHomelandImpl()
	if self:isSelfHomeCar() then
		pg.me:enterSelfHomeland()
	else
		pg.me:enterHomelandByUid(self.playerUID)
	end
end

function ClientHomeCar:doEnterHomeland()
	local _h = ClientHomeCar._platformHooks

	if _h and _h.doEnterHomeland then
		return _h.doEnterHomeland(self)
	end

	self:_doEnterHomelandImpl()
end

function ClientHomeCar:canEditCar()
	if not self:checkCarGroupValid() then
		return false
	end

	return true
end

function ClientHomeCar:doEditCar()
	pg.global.ui.homeCarModify:open({
		isModify = true,
		basicInfo = self.basicInfo
	})
end

function ClientHomeCar:getInteractionListData()
	return self.interactionListData
end

return ClientHomeCar
