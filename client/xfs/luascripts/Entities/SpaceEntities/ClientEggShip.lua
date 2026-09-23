-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientEggShip.lua

local class = require("Core.Framework.Class")
local ClientPawnEntity = require("Entities.ClientPawnEntity")
local Const = require("Common.Const.Const")
local ClientTopLogoComponent = require("Entities.SpaceEntities.CommonComponent.ClientTopLogoComponent")
local ClientConst = require("Const.ClientConst")
local ClientModelUtils = require("Utils.ClientModelUtils")
local PuppetData = require("Data.puppet_data")
local RobEggBorn = require("Data.rob_egg_born_data")
local ClientEggShip = class.Class("ClientEggShip", ClientPawnEntity)
local ClientInanimateNpcInteractComponent = require("Entities.SpaceEntities.CommonComponent.ClientInanimateNpcInteractComponent")
local Components = {
	ClientInanimateNpcInteractComponent,
	ClientTopLogoComponent
}

class.AddComponents(ClientEggShip, Components)

function ClientEggShip:ctor(entityId)
	ClientEggShip.super.ctor(self, entityId)

	self.isEggShip = true
	self.actorType = Const.ACTOR_TYPE_INTERACTOR
end

function ClientEggShip:init(bdict)
	ClientEggShip.super.init(self, bdict)

	self.templateId = bdict.templateId
	self.forbiddenTopLogo = false
	self.topLogoType = ClientConst.TopLogoType.Pet
	self.entityCanMove = false
end

function ClientEggShip:onEnterSpace()
	ClientEggShip.super.onEnterSpace(self)
	self:bindMapTag()
end

function ClientEggShip:bindMapTag()
	if not pg.me:grabEgg_IsSelfEggShip(self.ownerUid) then
		return
	end

	local cData = RobEggBorn[pg.space.sceneId]

	if cData and cData.markID then
		pg.game.grabEgg:bindDynamicMapStatus(self.id, cData.markID)
	end
end

function ClientEggShip:unbindMapTag()
	local cData = RobEggBorn[pg.space.sceneId]

	if cData and cData.markID then
		pg.game.map:unbindEntityPosFromMapMark(cData.markID)
	end
end

function ClientEggShip:on_finishEggTask_changed(oldv, newv)
	self:refreshInteractTrigger()
end

function ClientEggShip:refreshModel(configData, extraData)
	local modelView = self.eModel.modelModelView

	ClientModelUtils.applyModelAppearance(modelView.modelInfo, configData, extraData)
	modelView:RefreshModels()

	if self.ownerUid == pg.me.uid then
		self:playEffect("Eff_Env_GrabEgg_Indication_RVArrow")
	end
end

function ClientEggShip:checkShowEntityInteract()
	return pg.me:grabEgg_IsSelfEggShip(self.ownerUid)
end

function ClientEggShip:getConfigData()
	if not self.templateId then
		return {}
	end

	return PuppetData[self.templateId] or {}
end

function ClientEggShip:getSubName()
	return self.ownerName
end

function ClientEggShip:retreat(force)
	pg.me:serverMsg("RPC_CS_EggShipInteract", Const.EGG_SHIP_MSG_TYPE.RETREAT, {
		force
	})
end

function ClientEggShip:transEgg()
	pg.me:serverMsg("RPC_CS_EggShipInteract", Const.EGG_SHIP_MSG_TYPE.TRANS_EGG, {})
end

function ClientEggShip:teleport()
	pg.me:serverMsg("RPC_CS_EggShipInteract", Const.EGG_SHIP_MSG_TYPE.TELEPORT, {})
end

function ClientEggShip:destroy()
	ClientEggShip.super.destroy(self)
end

return ClientEggShip
