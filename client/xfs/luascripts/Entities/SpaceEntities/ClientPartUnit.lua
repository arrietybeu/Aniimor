-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientPartUnit.lua

local class = require("Core.Framework.Class")
local IDManager = require("Core.Common.IDManager")
local ClientModelEntity = require("Entities.ClientModelEntity")
local EntityFactory = require("Core.Common.EntityFactory")
local TimerManager = require("Core.Timer.TimerManager")
local ClientConst = require("Const.ClientConst")
local ClientModelUtils = require("Utils.ClientModelUtils")
local Const = require("Common.Const.Const")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")
local RigidbodyData = require("Data.rigidbody_data")
local ActorData = require("Data.actor_data")
local ClientUtils = require("Utils.ClientUtils")
local ClientEntity = require("Core.Client.ClientEntity")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local Utils = require("Common.Utils.Utils")
local MessageName = require("Const.MessageName")
local InteractionConst = require("Common.Const.InteractionConst")
local AiConst = require("Common.Const.AiConst")
local ReplayUtils = require("Utils.ReplayUtils")
local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
local ActorManager = require("Core.Common.ActorManager")
local EBTRootState = BaseEnum.EBTRootState
local PuppetData = require("Data.puppet_data")
local ClientPartUnit = class.Class("ClientPartUnit", ClientModelEntity)
local ClientModelComponent = require("Entities.SpaceEntities.CommonComponent.ClientModelComponent")
local ClientPhysicsComponent = require("Entities.SpaceEntities.CommonComponent.ClientPhysicsComponent")
local ClientAoiComponent = require("Entities.SpaceEntities.CommonComponent.ClientAoiComponent")
local PartUnitComponents = {
	ClientModelComponent,
	ClientPhysicsComponent,
	ClientAoiComponent
}

class.AddComponents(ClientPartUnit, PartUnitComponents)

function ClientPartUnit:ctor(entityId)
	ClientPartUnit.super.ctor(self, entityId)

	self.actorType = Const.ACTOR_TYPE_PUPPET
end

function ClientPartUnit:init(bdict)
	ClientPartUnit.super.init(self, bdict)

	self.actorPartIdx = bdict.actorPartIdx
	self.actorId = bdict.actorId
	self.camp = bdict.camp

	self:refreshPartInfo(bdict.hittable, bdict.lockable, bdict.visible)

	self.fakeActorId = VirtualEntUtils.getNewVirtualEntActorId()

	ActorManager.addEntity(self.fakeActorId, self)

	return true
end

function ClientPartUnit:getConfigData()
	return {
		rigidbody = "Avatar"
	}
end

function ClientPartUnit:initializeComponents()
	ClientPartUnit.super.initializeComponents(self)
end

function ClientPartUnit:postInitializeComponents()
	ClientPartUnit.super.postInitializeComponents(self)
end

function ClientPartUnit:start()
	ClientPartUnit.super.start(self)
end

function ClientPartUnit:destroy()
	ClientPartUnit.super.destroy(self)
	ActorManager.removeEntity(self.fakeActorId, self)
end

function ClientPartUnit:refreshPartInfo(hittable, lockable, visible)
	self.hittable = hittable
	self.lockable = lockable
	self.visible = visible
end

function ClientPartUnit:canBeLocked()
	return self.lockable
end

return ClientPartUnit
