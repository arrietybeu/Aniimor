-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientPetBallEntity.lua

local Class = require("Core.Framework.Class")
local ClientVirtualAIEntity = require("Entities.SpaceEntities.ClientVirtualAIEntity")
local PetBallAgent = require("Common.AI.BehaviacAgent.PetBallAgent")
local Time = require("Core.Common.Time")
local AIConst = require("Common.Const.AiConst")
local ClientConst = require("Const.ClientConst")
local ClientPetBallEntity = Class.Class("ClientPetBallEntity", ClientVirtualAIEntity)
local CharacterController = require("Common.Components.CharacterController")
local ClientStateCheckComponent = require("Entities.SpaceEntities.CommonComponent.ClientStateCheckComponent")
local ClientCombatEntityComponent = require("Entities.SpaceEntities.CommonComponent.ClientCombatEntityComponent")
local ClientPetBallComponents = {
	ClientStateCheckComponent,
	ClientCombatEntityComponent,
	CharacterController
}

Class.AddComponents(ClientPetBallEntity, ClientPetBallComponents)

function ClientPetBallEntity:init(dict)
	ClientPetBallEntity.super.init(self, dict)

	self.topLogoType = ClientConst.TopLogoType.PetBall
	self.gmMode = 1

	return true
end

function ClientPetBallEntity:start()
	ClientPetBallEntity.super.start(self)
	self:setIgnoreAILod(true, AIConst.IgnoreAILodReason.InPetBall)
end

function ClientPetBallEntity:getGameTimeScale()
	return 1
end

function ClientPetBallEntity:getGameTime()
	return Time.realSecondCache
end

function ClientPetBallEntity:getVirtualAIAgentName()
	return PetBallAgent.typeName
end

function ClientPetBallEntity:getVirtualBt()
	return "SM_Npc_Root"
end

return ClientPetBallEntity
