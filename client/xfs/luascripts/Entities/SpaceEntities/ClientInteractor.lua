-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientInteractor.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local ClientModelEntity = require("Entities.ClientModelEntity")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local InteractionConst = require("Common.Const.InteractionConst")
local ClientInteractor = class.Class("ClientInteractor", ClientModelEntity)
local ClientActorComponent = require("Entities.SpaceEntities.CommonComponent.ClientActorComponent")
local ClientAuthorityComponent = require("Entities.SpaceEntities.CommonComponent.ClientAuthorityComponent")
local ClientEffectComponent = require("Entities.SpaceEntities.PlayerComponent.ClientEffectComponent")
local ClientAudioComponent = require("Entities.SpaceEntities.CommonComponent.ClientAudioComponent")
local ClientInteractionComponent = require("Entities.SpaceEntities.CommonComponent.ClientInteractionComponent")
local ClientTopLogoComponent = require("Entities.SpaceEntities.CommonComponent.ClientTopLogoComponent")
local ClientAnimatorComponent = require("Entities.SpaceEntities.CommonComponent.ClientAnimatorComponent")
local ClientEcsComponent = require("Entities.SpaceEntities.CommonComponent.ClientEcsComponent")
local InteractorComponents = {
	ClientActorComponent,
	ClientEffectComponent,
	ClientAnimatorComponent,
	ClientAuthorityComponent,
	ClientAudioComponent,
	ClientInteractionComponent,
	ClientTopLogoComponent,
	ClientEcsComponent
}

if EnableBotTest then
	InteractorComponents = {
		ClientActorComponent
	}
end

class.AddComponents(ClientInteractor, InteractorComponents)

function ClientInteractor:ctor(entityId)
	ClientInteractor.super.ctor(self, entityId)

	self.entityCanMove = false
	self.actorType = Const.ACTOR_TYPE_INTERACTOR
end

function ClientInteractor:init(bdict)
	ClientInteractor.super.init(self, bdict)

	self.templateId = bdict.templateId
	self.sceneId = bdict.sceneId
	self.forbiddenTopLogo = false
	self.topLogoType = ClientConst.TopLogoType.EnvObj

	return true
end

function ClientInteractor:start()
	ClientInteractor.super.start(self)
end

function ClientInteractor:getInteractionListData()
	return {
		{
			interactionType = InteractionConst.INTERACTION_TYPE_ENT_FUNC,
			globalId = self:getGlobalId(),
			needItem = self.needItem,
			name = self:getConfigData().name or ""
		}
	}
end

function ClientInteractor:initializeComponents()
	ClientInteractor.super.initializeComponents(self)
	self:addEModelMonoComponent(Const.COMPONENT_IDX_PHYSX)
end

function ClientInteractor:onEnterScene()
	ClientInteractor.super.onEnterScene(self)
end

function ClientInteractor:checkCanInteract(unit)
	if self.levelCondition == Const.LEVEL_CONDITION_OFF then
		return false
	end

	return true
end

function ClientInteractor:interact(interactUnit)
	return
end

function ClientInteractor:repr()
	return string.format("clientEntity (%s, %s)", self:getClassType(), self.id)
end

function ClientInteractor:destroy()
	ClientInteractor.super.destroy(self)
end

return ClientInteractor
