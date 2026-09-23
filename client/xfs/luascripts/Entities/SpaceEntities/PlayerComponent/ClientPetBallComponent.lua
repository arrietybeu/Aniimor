-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientPetBallComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local MessageName = require("Const.MessageName")
local Utils = require("Common.Utils.Utils")
local PetResearchContentData = require("Data.pet_research_content_data")
local EventConst = require("Const.EventConst")
local ClientPetBallComponent = class.Component("ClientPetBallComponent")

function ClientPetBallComponent:onActionPoint_changed(ov, nv)
	facade:sendMsgToUI(MessageName.PET_BALL_ACTION_POINT_CHANGE, {})
end

function ClientPetBallComponent:onPetBallSlotCount_changed(ov, nv)
	return
end

function ClientPetBallComponent:onPetBallCurIndex_changed(ov, nv)
	return
end

function ClientPetBallComponent:onPetBallMap_entryAdded(petBallId, petBallInfo)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onPetBallMap_entryAdded", petBallId)
	end

	pg.global.ui.hudV2:checkPetBallValidState()
end

function ClientPetBallComponent:onPetBallMap_entryDeleted(petBallId, petBallInfo)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onPetBallMap_entryDeleted", petBallId)
	end

	pg.global.ui.hudV2:checkPetBallValidState()
end

function ClientPetBallComponent:onPetBallMapActions_entryAdded(actionType, actionInfo, petBallId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onPetBallMapActions_entryAdded", petBallId, actionType, inspect(actionInfo))
	end

	facade:SendMessageCommand(MessageName.PET_BALL_MAP_ACTION_ADDED, {
		petBallId = petBallId
	})
end

function ClientPetBallComponent:onPetBallMapActions_entryDeleted(actionType, actionInfo, petBallId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onPetBallMapActions_entryDeleted", petBallId, actionType, inspect(actionInfo))
	end

	facade:SendMessageCommand(MessageName.PET_BALL_MAP_ACTION_DELETED, {
		petBallId = petBallId
	})
end

function ClientPetBallComponent:onPetBallMapAction_changed(ov, nv, petBallId, actionType)
	return
end

function ClientPetBallComponent:onPetBallMapProductions_entryAdded(productionType, productionInfo, petBallId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onPetBallMapProductions_entryAdded", petBallId, productionType, inspect(productionInfo))
	end

	facade:SendMessageCommand(MessageName.PET_BALL_MAP_PRODUCTION_ADDED, {
		entryDeleted = false,
		petBallId = petBallId
	})
end

function ClientPetBallComponent:onPetBallMapProductions_entryDeleted(productionType, productionInfo, petBallId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onPetBallMapProductions_entryDeleted", petBallId, productionType, inspect(productionInfo))
	end

	facade:SendMessageCommand(MessageName.PET_BALL_MAP_PRODUCTION_DELETED, {
		entryDeleted = true,
		petBallId = petBallId,
		productionType = productionType,
		productionInfoValue = productionInfo.value,
		productionInfoTargetId = productionInfo.targetId
	})
end

function ClientPetBallComponent:onPetBallMapProduction_changed(ov, nv, petBallId, productionType)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onPetBallMapProduction_changed", petBallId, productionType, inspect(ov), inspect(nv))
	end

	facade:SendMessageCommand(MessageName.PET_BALL_MAP_PRODUCTION_CHANGED, {
		entryDeleted = false,
		petBallId = petBallId
	})
end

function ClientPetBallComponent:onPetBallMapPetId_changed(ov, nv, petBallId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onPetBallMapPetId_changed", petBallId, ov, nv)
	end

	facade:SendMessageCommand(MessageName.PET_BALL_MAP_MAIN_PET_CHANGED, {
		petBallId = petBallId,
		oldValue = ov,
		newValue = nv
	})
end

function ClientPetBallComponent:onPetBallMapSubPetId_changed(ov, nv, petBallId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onPetBallMapSubPetId_changed", petBallId, ov, nv)
	end

	facade:SendMessageCommand(MessageName.PET_BALL_MAP_SUB_PET_CHANGED, {
		petBallId = petBallId
	})
end

function ClientPetBallComponent:onPetBallMapCustomName_changed(ov, nv, petBallId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onPetBallMapCustomName_changed", petBallId, ov, nv)
	end

	facade:SendMessageCommand(MessageName.PET_BALL_MAP_CUSTOM_NAME_CHANGED, {
		petBallId = petBallId,
		newName = nv
	})
end

function ClientPetBallComponent:onPetBallHatchSlotMapStatus_changed(ov, nv, hatchSlotId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onPetBallHatchSlotMapStatus_changed", hatchSlotId, ov, nv)
	end

	facade:SendMessageCommand(MessageName.PET_BALL_MAP_HATCH_SLOT_STATUS_CHANGED, {
		hatchSlotId = hatchSlotId,
		oldValue = ov,
		newValue = nv
	})
	pg.global.eventEmitter:emit(EventConst.PET_BALL_MAP_HATCH_SLOT_STATUS_CHANGED, hatchSlotId, ov, nv)
end

function ClientPetBallComponent:onPetBallExpActionStatus_changed(ov, nv, petBallId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("onPetBallExpActionStatus_changed", petBallId, ov, nv)
	end

	facade:SendMessageCommand(MessageName.PET_BALL_MAP_EXP_ACTION_STATUS, {
		petBallId = petBallId,
		oldValue = ov,
		newValue = nv
	})
end

return ClientPetBallComponent
