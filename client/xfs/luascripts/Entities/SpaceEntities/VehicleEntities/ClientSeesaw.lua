-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\VehicleEntities\\ClientSeesaw.lua

local class = require("Core.Framework.Class")
local ClientVehicle = require("Entities.SpaceEntities.VehicleEntities.ClientVehicle")
local InteractionConst = require("Common.Const.InteractionConst")
local MessageName = require("Const.MessageName")
local Utils = require("Common.Utils.Utils")
local ark_game_interact_data = require("Data.ark_game_interact_data")
local UIConst = require("Const.UIConst")
local ClientSeesaw = class.Class("ClientSeesaw", ClientVehicle)
local Components = {}

class.AddComponents(ClientSeesaw, Components)

function ClientSeesaw:ctor(entityId)
	ClientSeesaw.super.ctor(self, entityId)
end

function ClientSeesaw:init(bdict)
	local result = ClientSeesaw.super.init(self, bdict)

	self.entityCanMove = false

	return result
end

function ClientSeesaw:onDoSkill1()
	local featureVehicle = self.featureVehicle

	if not featureVehicle then
		return
	end

	local playerSeatIndex = self.entityMap[pg.pawn.actorId]

	if playerSeatIndex then
		local ret = featureVehicle:Play(playerSeatIndex)
		local progressCtrl = pg.global.ui.gameplayProgress

		if ret then
			progressCtrl:setCount(progressCtrl.count + 1)
		else
			progressCtrl:setCount(progressCtrl.count - 1)
		end
	end
end

function ClientSeesaw:onEnterControl()
	ClientSeesaw.super.onEnterControl(self)

	local controllerData = self:getVehicleConfig().controllerData or {}
	local arkGameInteractId = controllerData.arkGameInteractId or 1
	local agiData = ark_game_interact_data[arkGameInteractId]

	if not agiData then
		return
	end

	pg.global.ui.gameplayProgress:initProgress(0, agiData.totalSegNum, pg.getLocalizationText(agiData.progressText), function()
		pg.me:onVehicleProgressFinished(self)
	end)
	pg.global.ui:open(UIConst.UI_ID_GAMEPLAY_PROGRESS)
end

function ClientSeesaw:onExitControl()
	ClientSeesaw.super.onExitControl(self)
	pg.global.ui:close(UIConst.UI_ID_GAMEPLAY_PROGRESS)
end

function ClientSeesaw:setIsOtherPlaying(otherPlaying)
	local featureVehicle = self.featureVehicle

	if not featureVehicle then
		return
	end

	featureVehicle.otherPlaying = otherPlaying
end

function ClientSeesaw:destroy()
	ClientSeesaw.super.destroy(self)
end

return ClientSeesaw
