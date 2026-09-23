-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\VehicleEntities\\ClientSwing.lua

local class = require("Core.Framework.Class")
local ClientVehicle = require("Entities.SpaceEntities.VehicleEntities.ClientVehicle")
local ClientVirtualEntityUtils = require("Utils.ClientVirtualEntityUtils")
local ClientConst = require("Const.ClientConst")
local ark_game_interact_data = require("Data.ark_game_interact_data")
local UIConst = require("Const.UIConst")
local pg = pg
local ClientSwing = class.Class("ClientSwing", ClientVehicle)
local Components = {}

class.AddComponents(ClientSwing, Components)

function ClientSwing:ctor(entityId)
	ClientSwing.super.ctor(self, entityId)

	self.turnCount = 0
	self.maxTurnCount = 3
	self.isSwing = true
end

function ClientSwing:init(bdict)
	local result = ClientSwing.super.init(self, bdict)

	self.entityCanMove = false

	return result
end

function ClientSwing:onDoSkill1()
	local featureVehicle = self.featureVehicle

	if not featureVehicle then
		return
	end

	featureVehicle:Play()
end

function ClientSwing:onEnterControl()
	ClientSwing.super.onEnterControl(self)

	local featureVehicle = self.featureVehicle

	if not featureVehicle then
		return
	end

	local controllerData = self:getVehicleConfig().controllerData or {}
	local arkGameInteractId = controllerData.arkGameInteractId or 1
	local agiData = ark_game_interact_data[arkGameInteractId]

	pg.global.ui.gameplayProgress:initProgress(0, agiData.totalSegNum, pg.getLocalizationText(agiData.progressText), function()
		pg.me:onVehicleProgressFinished(self)
	end, self)
	pg.global.ui:open(UIConst.UI_ID_GAMEPLAY_PROGRESS)
end

function ClientSwing:onExitControl()
	ClientSwing.super.onExitControl(self)
	pg.global.ui:close(UIConst.UI_ID_GAMEPLAY_PROGRESS)
	pg.game.camera.playerCameraMode:cancelFovCurveAnim()
end

function ClientSwing:onSwingEnd()
	pg.me:dismountVehicle(self.actorId)
end

function ClientSwing:playSwingTimeline(timelineRes, position, rotation)
	if self.swingCutscene then
		return
	end

	local petActorId = self:getActorOnSeat(1)
	local playerActorId = self:getActorOnSeat(2)

	if not petActorId or not playerActorId then
		self:onSwingEnd()

		return
	end

	local petEnt = pg.getEntityByActorId(petActorId)
	local playerEnt = pg.getEntityByActorId(playerActorId)

	if not petEnt or not playerEnt then
		self:onSwingEnd()

		return
	end

	local hasEnded = false
	local extraData = {
		createCallback = function(cutscene)
			cutscene:setRefEntity("srcPet", petEnt.eModel)
			cutscene:setRefEntity("srcPlayer", playerEnt.eModel)
			self:setModelVisible(ClientConst.MODEL_VISIBLE_KEY.CUTSCENE, false)
		end,
		bindCallback = function(cutscene, virtualEntity, bindKey, bindParam)
			local sourceEntity = bindParam == "pet" and petEnt or playerEnt

			ClientVirtualEntityUtils.copySimpleVirtualPlayerAppearance(virtualEntity, sourceEntity)

			return true
		end,
		endCallback = function()
			hasEnded = true
			self.swingCutscene = nil

			self:setModelVisible(ClientConst.MODEL_VISIBLE_KEY.CUTSCENE, true)
			self:onSwingEnd()
		end
	}
	local swingCutscene = pg.game.cutscene:playCutscene("vehicleSwing", timelineRes, position, rotation, nil, true, extraData)

	if not swingCutscene then
		self:onSwingEnd()
	elseif not hasEnded then
		self.swingCutscene = swingCutscene
	end
end

function ClientSwing:onEntityMount(entity, seatId)
	ClientSwing.super.onEntityMount(self, entity, seatId)

	local featureVehicle = self.featureVehicle

	if not featureVehicle then
		return
	end

	local controllerData = self:getVehicleConfig().controllerData or {}
	local arkGameInteractId = controllerData.arkGameInteractId or 1

	featureVehicle.maxTurn = ark_game_interact_data[arkGameInteractId].totalSegNum

	featureVehicle:Mount(entity.eModel)
end

function ClientSwing:onEntityDismount(entity, seatId)
	local featureVehicle = self.featureVehicle

	if featureVehicle then
		featureVehicle:Dismount(entity.eModel)
		featureVehicle:SetProgressUI(nil)
	end

	ClientSwing.super.onEntityDismount(self, entity, seatId)
end

function ClientSwing:onTurn(turnCount)
	pg.global.ui.gameplayProgress:setCount(turnCount)

	local controllerData = self:getVehicleConfig().controllerData or {}

	if turnCount > self.turnCount then
		if controllerData.turnFovCurveName then
			pg.game.camera.playerCameraMode:playFovCurveAnim(controllerData.turnFovCurveName, 1, 0, 1)
		end

		if turnCount == self.maxTurnCount then
			pg.game.audio:playEvent("SFX_UI_ProgressBar_End_01")
		else
			pg.game.audio:playEvent("SFX_UI_ProgressBar_01")
		end
	end

	self.turnCount = turnCount
end

function ClientSwing:playCameraEffect()
	local featureVehicle = self.featureVehicle

	if not featureVehicle then
		return
	end

	local controllerData = self:getVehicleConfig().controllerData or {}

	if not controllerData.fovCurveName then
		return
	end

	pg.game.camera.playerCameraMode:playFovCurveAnim(controllerData.fovCurveName, 1, 0, 1)
end

function ClientSwing:setIsOtherPlaying(otherPlaying)
	local featureVehicle = self.featureVehicle

	if not featureVehicle then
		return
	end

	featureVehicle.otherPlaying = otherPlaying
end

function ClientSwing:setProgressUI(progressUI)
	local featureVehicle = self.featureVehicle

	if not featureVehicle then
		return
	end

	featureVehicle:SetProgressUI(progressUI)
end

function ClientSwing:destroy()
	ClientSwing.super.destroy(self)
end

return ClientSwing
