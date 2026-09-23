-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientAirWall.lua

local class = require("Core.Framework.Class")
local ClientEntity = require("Core.Client.ClientEntity")
local ClientConst = require("Const.ClientConst")
local AddressDataConst = require("Const.AddressDataConst")
local AirWallData = require("Data.airwall_obj_data")
local SceneUtils = require("Common.Utils.SceneUtils")
local entityManager = appFacade.entityManager
local ClientAirWall = class.Class("ClientAirWall", ClientEntity)
local ClientAoiComponent = require("Entities.SpaceEntities.CommonComponent.ClientAoiComponent")
local ClientAuthorityComponent = require("Entities.SpaceEntities.CommonComponent.ClientAuthorityComponent")
local ClientEffectComponent = require("Entities.SpaceEntities.PlayerComponent.ClientEffectComponent")
local ClientPosRotComponent = require("Entities.SpaceEntities.CommonComponent.ClientPosRotComponent")
local ClientEModelComponent = require("Entities.SpaceEntities.CommonComponent.ClientEModelComponent")
local ClientLODComponent = require("Entities.SpaceEntities.CommonComponent.ClientLODComponent")
local Components = {
	ClientPosRotComponent,
	ClientLODComponent,
	ClientEModelComponent,
	ClientAoiComponent,
	ClientAuthorityComponent,
	ClientEffectComponent
}

class.AddComponents(ClientAirWall, Components)

function ClientAirWall:ctor(entityId)
	ClientAirWall.super.ctor(self, entityId)
end

function ClientAirWall:init(bdict)
	ClientAirWall.super.init(self, bdict)

	self.templateId = bdict.templateId

	local pos = bdict.position or {
		0,
		1,
		0
	}

	self.position = Vector3.New(pos[1], pos[2] - 1.5, pos[3])
	self.rotation = bdict.rotation
	self.scale = bdict.scale

	return true
end

function ClientAirWall:postInit(dict)
	ClientAirWall.super.postInit(self, dict)
	self:createEModel()
end

function ClientAirWall:releaseWallPresentation()
	self.wallPresentationReleased = true

	local eModel = self.eModel

	if not eModel or eModel.destroyed then
		return
	end

	local cData = AirWallData[self.templateId]

	if cData and cData.resType ~= 1 then
		self:stopEffect(cData.resID, true)
	end

	local root = eModel.transform

	if IsNil(root) then
		return
	end

	local colliders = root:GetComponentsInChildren(typeof(CS.UnityEngine.Collider), true)

	for i = 0, colliders.Length - 1 do
		local collider = colliders[i]

		if not IsNil(collider) then
			collider.enabled = false
		end
	end
end

function ClientAirWall:dontCreateEModel()
	if self.eModel then
		return true
	end

	local cData = AirWallData[self.templateId]

	if cData == nil then
		return true
	end

	return false
end

function ClientAirWall:getCsEntityType()
	return ClientConst.ENTITY_CS_TYPE.ENTITY
end

function ClientAirWall:getEModelResId()
	local cData = AirWallData[self.templateId]

	if cData == nil or cData.resType ~= 1 then
		self.resId = AddressDataConst.Ent_AirWall
	else
		self.resId = cData.resID
	end

	return self.resId
end

function ClientAirWall:onEModelCreateEffect()
	if self.wallPresentationReleased then
		self:releaseWallPresentation()

		return
	end

	local _scale = self.scale or Vector3.constZero

	self:setPositionAgentScale(_scale.x, _scale.y, _scale.z)

	local _pos = self.position or Vector3.constZero

	self:setPositionAgentLocalPos(_pos.x, _pos.y, _pos.z)

	local _rot = self.rotation

	self:setPositionAgentLocalRotation(_rot.x, _rot.y, _rot.z, _rot.w)
	self:applyFixedScale()

	local cData = AirWallData[self.templateId]

	if cData == nil or cData.resType == 1 then
		return
	end

	self:playEffect(cData.resID)
end

function ClientAirWall:applyFixedScale()
	if not self.space or not self.staticId or self.staticId == 0 or not self.eModel then
		return
	end

	local sceneEntityData = SceneUtils.getSceneEntityData(self.space.sceneId, self.space.id)
	local data = sceneEntityData and sceneEntityData[self.staticId]

	if data and data.fixedScale and data.fixedScale ~= 0 then
		local s = data.fixedScale

		self:setPositionAgentScale(s)
	end
end

function ClientAirWall:initializeComponents()
	self:postComponentMethod("EVENT_AddEComponent")
end

function ClientAirWall:isConfigKinematic()
	return true
end

function ClientAirWall:playDestroyEffect()
	local cData = AirWallData[self.templateId]

	if cData and cData.resType ~= 1 and not string.isNilOrEmpty(cData.endResID) then
		pg.game.effect:playEffectAt(0, cData.endResID, self:getPosition(), self:getRotation():ToEulerAngles(), self, nil, true)
	end
end

function ClientAirWall:preDestroy()
	self:playDestroyEffect()
	ClientAirWall.super.preDestroy(self)
end

return ClientAirWall
