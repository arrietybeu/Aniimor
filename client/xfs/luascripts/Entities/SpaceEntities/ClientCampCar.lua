-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientCampCar.lua

local class = require("Core.Framework.Class")
local ClientModelEntity = require("Entities.ClientModelEntity")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local MessageName = require("Const.MessageName")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local HomeCampCarData = require("Data.home_camp_car_data")
local ClientCampCar = class.Class("ClientCampCar", ClientModelEntity)
local ClientActorComponent = require("Entities.SpaceEntities.CommonComponent.ClientActorComponent")
local ClientAuthorityComponent = require("Entities.SpaceEntities.CommonComponent.ClientAuthorityComponent")
local ClientCampCarPetsComponent = require("Entities.SpaceEntities.HomeCampComponent.ClientCampCarPetsComponent")
local ClientCampCarOrnamentComponent = require("Entities.SpaceEntities.HomeCampComponent.ClientCampCarOrnamentComponent")
local ClientEffectComponent = require("Entities.SpaceEntities.PlayerComponent.ClientEffectComponent")
local InteractorComponents = {
	ClientActorComponent,
	ClientAuthorityComponent,
	ClientCampCarPetsComponent,
	ClientCampCarOrnamentComponent,
	ClientEffectComponent
}

class.AddComponents(ClientCampCar, InteractorComponents)

function ClientCampCar:ctor(entityId)
	ClientCampCar.super.ctor(self, entityId)

	self.actorType = Const.ACTOR_TYPE_CAMPCAR
end

function ClientCampCar:init(bdict)
	ClientCampCar.super.init(self, bdict)

	self.entityCanMove = false

	local campId = HomeLandUtils.getHomeCampStaticId(self.sceneId)

	self.campId = campId
	self.placeId = HomeLandUtils.getCampCarTmplId(campId, self.carIndex)
	self.carGroup = pg.game.homeCar:getOrCreateHomeCarGroup(campId, self.placeId, self.ownerUid, ClientConst.HomeCarGroupCreateType.Camp)

	self:loadCampData()

	return true
end

function ClientCampCar:start()
	ClientCampCar.super.start(self)
end

function ClientCampCar:destroy()
	self:resetCampData()
	ClientCampCar.super.destroy(self)
end

function ClientCampCar:repr()
	return string.format("ClientCampCar(id=%s, idx=%d, actorId=%d)", self.id, self.carIndex, self.actorId or 0)
end

function ClientCampCar:getConfigData()
	return HomeCampCarData[self.placeId] or {}
end

function ClientCampCar:loadCampData()
	self.carGroup:loadFullCampData(self, self.basicInfo)
end

function ClientCampCar:getHomePlaceConfig()
	return HomeCampCarData[self.placeId] or {}
end

function ClientCampCar:resetCampData()
	if self.carGroup then
		self.carGroup:unloadFullCampData()

		self.carGroup = nil
	end
end

function ClientCampCar:on_basicInfoChanged(ov, nv)
	if self.carGroup then
		self.carGroup:updateBasicInfo(self.basicInfo)
	end
end

function ClientCampCar:on_likeCntChanged(ov, nv)
	if self.carGroup then
		self.carGroup:onLikeCntChanged()
	end
end

function ClientCampCar:on_CampCarLoadValueChanged(ov, nv)
	facade:sendMsgToUI(MessageName.HOMELAND_EDITOR_LOAD_REFRESH, {
		campCarEntId = self.id
	})
end

return ClientCampCar
