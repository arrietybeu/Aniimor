-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\ClientInteractTriggerProxy.lua

local Class = require("Core.Framework.Class")
local ClientModelEntity = require("Entities.ClientModelEntity")
local ClientModelComponent = require("Entities.SpaceEntities.CommonComponent.ClientModelComponent")
local ClientAoiComponent = require("Entities.SpaceEntities.CommonComponent.ClientAoiComponent")
local ClientInteractionComponent = require("Entities.SpaceEntities.CommonComponent.ClientInteractionComponent")
local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
local Const = require("Common.Const.Const")
local ClientInteractTriggerProxy = Class.Class("ClientInteractTriggerProxy", ClientModelEntity)
local ProxyComponents = {
	ClientAoiComponent,
	ClientModelComponent,
	ClientInteractionComponent
}

Class.AddComponents(ClientInteractTriggerProxy, ProxyComponents)

function ClientInteractTriggerProxy:init(dict)
	self.actorId = VirtualEntUtils.getNewVirtualEntActorId()
	self.actorType = dict.actorType or Const.ACTOR_TYPE_HOME_OBJECT
	self.clenUsrType = dict.clenUsrType or Const.CLEN_USE_TYPE_HOME
	self._interactLocalOffset = dict.interactLocalOffset or {
		0,
		0,
		0
	}
	self._interactiveDist = dict.interactiveDist
	self._interactionListData = nil
	self.entityCanMove = false

	ClientInteractTriggerProxy.super.init(self, dict)

	return true
end

function ClientInteractTriggerProxy:start()
	ClientInteractTriggerProxy.super.start(self)
	self:initInteraction()
end

function ClientInteractTriggerProxy:destroy()
	ClientInteractTriggerProxy.super.destroy(self)
end

function ClientInteractTriggerProxy:getConfigData()
	local config = {
		actionName = 1,
		interactLocalOffset = self._interactLocalOffset
	}

	if self._interactiveDist then
		config.interactiveDist = self._interactiveDist
	end

	return config
end

function ClientInteractTriggerProxy:getInteractName()
	return ""
end

function ClientInteractTriggerProxy:initInteraction()
	if self.eModel == nil then
		return
	end

	self:postComponentMethod("EVENT_InitInteractionList")
end

function ClientInteractTriggerProxy:setInteractionListData(listData)
	if listData then
		for _, item in ipairs(listData) do
			if not item.globalId then
				item.globalId = self:getGlobalId()
			end
		end
	end

	self._interactionListData = listData

	if self.eModel then
		self:refreshInteractTriggerEvent()
	end
end

function ClientInteractTriggerProxy:getInteractionListData()
	return self._interactionListData
end

return ClientInteractTriggerProxy
