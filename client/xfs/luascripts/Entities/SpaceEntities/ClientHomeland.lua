-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientHomeland.lua

local Class = require("Core.Framework.Class")
local ClientSpace = require("Entities.SpaceEntities.ClientSpace")
local CallbackHandler = require("Core.Common.CallbackHandler")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local ClientHomelandOrnamentComponent = require("Entities.SpaceEntities.HomelandComponent.ClientHomelandOrnamentComponent")
local ClientHomelandBgmComponent = require("Entities.SpaceEntities.HomelandComponent.ClientHomelandBgmComponent")
local ClientHomelandPetsComponent = require("Entities.SpaceEntities.HomelandComponent.ClientHomelandPetsComponent")
local ClientHomelandEnvComponent = require("Entities.SpaceEntities.HomelandComponent.ClientHomelandEnvComponent")
local ClientHomelandProduceComponent = require("Entities.SpaceEntities.HomelandComponent.ClientHomelandProduceComponent")
local ClientHomelandZoneComponent = require("Entities.SpaceEntities.HomelandComponent.ClientHomelandZoneComponent")
local ClientHomelandWarehouseComponent = require("Entities.SpaceEntities.HomelandComponent.ClientHomelandWarehouseComponent")
local ClientHomelandEventComponent = require("Entities.SpaceEntities.HomelandComponent.ClientHomelandEventComponent")
local ClientHomelandHatchBoxComponent = require("Entities.SpaceEntities.HomelandComponent.ClientHomelandHatchBoxComponent")
local ClientHomelandSeasonComponent = require("Entities.SpaceEntities.HomelandComponent.ClientHomelandSeasonComponent")
local MessageName = require("Const.MessageName")
local ClientConst = require("Const.ClientConst")
local HomelandConfigData = require("Data.homeland_config_data")
local SceneUtils = require("Common.Utils.SceneUtils")
local ClientUtils = require("Utils.ClientUtils")
local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local NoticeDef = require("Common.NoticeDef")
local ClientHomeland = Class.Class("ClientHomeland", ClientSpace)
local ClientHomelandComponents = {
	ClientHomelandOrnamentComponent,
	ClientHomelandBgmComponent,
	ClientHomelandPetsComponent,
	ClientHomelandEnvComponent,
	ClientHomelandProduceComponent,
	ClientHomelandZoneComponent,
	ClientHomelandWarehouseComponent,
	ClientHomelandEventComponent,
	ClientHomelandHatchBoxComponent,
	ClientHomelandSeasonComponent
}

Class.AddComponents(ClientHomeland, ClientHomelandComponents)

function ClientHomeland:ctor(entityId)
	ClientHomeland.super.ctor(self, entityId)
end

function ClientHomeland:init(dict)
	ClientHomeland.super.init(self, dict)

	return true
end

function ClientHomeland:start()
	ClientHomeland.super.start(self)
	self:_createOwnerDisplayCar()
end

function ClientHomeland:destroy()
	self:_destroyOwnerDisplayCar()
	ClientHomeland.super.destroy(self)
end

function ClientHomeland:_createOwnerDisplayCar()
	if self.ownerDisplayCar then
		return
	end

	local staticId = HomeLandUtils.getHomelandCarPosition()

	if not staticId then
		return
	end

	local pos, rot = SceneUtils.getCommonBasicsPosition(self.sceneId, staticId)

	if not pos then
		return
	end

	self.ownerDisplayCar = ClientUtils.createClientEntity("ClientHomelandDisplayCar", VirtualEntUtils.getNewVirtualEntityId(), {
		position = pos,
		rotation = rot
	})

	self:_applyOwnerBasicInfo()
end

function ClientHomeland:_applyOwnerBasicInfo()
	if self.ownerDisplayCar and self.basicInfo then
		self.ownerDisplayCar:setBasicInfo(self.basicInfo)
	end
end

function ClientHomeland:_destroyOwnerDisplayCar()
	if self.ownerDisplayCar then
		ClientUtils.safeDestroy(self.ownerDisplayCar)

		self.ownerDisplayCar = nil
	end
end

function ClientHomeland:on_basicInfoChanged(ov, nv)
	self:_applyOwnerBasicInfo()
end

function ClientHomeland:_notifyHomeAreaStatsChanged(areaId)
	facade:sendMsgToUI(MessageName.HOMELAND_EDITOR_LOAD_REFRESH, {
		areaId = areaId
	})
end

function ClientHomeland:on_homeAreaStats_changed(ov, nv)
	self:_notifyHomeAreaStatsChanged()
end

function ClientHomeland:getVoxelLoadType()
	return ClientConst.VoxelLoadType.MAP_LOAD_ALL
end

function ClientHomeland:getSelfHomelandKey(player)
	return Utils.getSelfHomelandKey(player)
end

function ClientHomeland:isSelfHomeland(player)
	player = player or pg.me

	return self:getSelfHomelandKey(player) == self.id
end

function ClientHomeland:onEntityJoin(entity)
	ClientHomeland.super.onEntityJoin(self, entity)

	if Utils.isPlayer(entity) and self:isSelfHomeland(entity) then
		self:ownerPlayerJoinHomeland(entity)

		self.homeLandOwnerPlayerId = entity.id
	end

	self:postComponentMethod("onHomelandEntityJoin", entity)
end

function ClientHomeland:ownerPlayerJoinHomeland(player)
	self:postComponentMethod("ownerPlayerJoinHomeland", player)
end

function ClientHomeland:onEntityLeave(entity)
	ClientHomeland.super.onEntityLeave(self, entity)

	if Utils.isPlayer(entity) and self:isSelfHomeland(entity) then
		self:ownerPlayerLeaveHomeland(entity)
	end

	self:postComponentMethod("onHomelandEntityLeave", entity)
end

function ClientHomeland:onLocalPlayerTeleportSpaceOut(player)
	if player ~= pg.me or not self:isSelfHomeland(player) then
		return
	end

	if self:consumeHomeSeasonPrepareCancelExitTip() then
		pg.global.ui.tips:queueBubbleMessageAfterSceneLoaded(NoticeDef.HOME_SEASON_PREPARE_CANCEL)
	end
end

function ClientHomeland:ownerPlayerLeaveHomeland(player)
	self:postComponentMethod("ownerPlayerLeaveHomeland", player)
end

function ClientHomeland:unlockHomelandZone(zoneId)
	if self:isHomelandZoneUnlock(zoneId) then
		return
	end

	pg.me:serverMsg("RPC_CS_UnlockHomelandZone", zoneId, CallbackHandler(self, "onUnlockHomelandZoneCallback"))
end

function ClientHomeland:onUnlockHomelandZoneCallback(code, zoneId)
	if code ~= Const.HOMELAND_ZONE_OP_RETURN_CODE.SUCCESS then
		return
	end
end

function ClientHomeland:isHomelandZoneUnlock(zoneId)
	return self.unlockZone[zoneId] or false
end

function ClientHomeland:setHatchBoxesInfo(fullHatchInfo)
	self:postComponentMethod("EVENT_SetHatchBoxesInfo", fullHatchInfo)
end

return ClientHomeland
