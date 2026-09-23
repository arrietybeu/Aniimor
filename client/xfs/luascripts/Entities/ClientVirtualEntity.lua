-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\ClientVirtualEntity.lua

local Class = require("Core.Framework.Class")
local Entity = require("Core.Common.Entity")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local ClientConst = require("Const.ClientConst")
local ClientModelUtils = require("Utils.ClientModelUtils")
local ClientUtils = require("Utils.ClientUtils")
local Const = require("Common.Const.Const")
local AddressDataConst = require("Const.AddressDataConst")
local SysConfigData = require("Data.sys_config_data")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local EModelUtils = require("Entities.Utils.EModelUtils")
local ClientVirtualEntity = Class.Class("ClientVirtualEntity", Entity)
local ClientEffectComponent = require("Entities.SpaceEntities.PlayerComponent.ClientEffectComponent")
local ClientLODComponent = require("Entities.SpaceEntities.CommonComponent.ClientLODComponent")
local ClientDebugComponent = require("Entities.SpaceEntities.PlayerComponent.ClientDebugComponent")
local ClientAudioComponent = require("Entities.SpaceEntities.CommonComponent.ClientAudioComponent")
local ClientVisibleComponent = require("Entities.SpaceEntities.CommonComponent.ClientVisibleComponent")
local ClientAnimationComponent = require("Entities.SpaceEntities.CommonComponent.ClientAnimationComponent")
local ClientTimeControlComponent = require("Entities.SpaceEntities.CommonComponent.ClientTimeControlComponent")
local ClientPosRotComponent = require("Entities.SpaceEntities.CommonComponent.ClientPosRotComponent")
local ClientEModelComponent = require("Entities.SpaceEntities.CommonComponent.ClientEModelComponent")
local ClientVirtualComponents = {
	ClientPosRotComponent,
	ClientEModelComponent,
	ClientLODComponent,
	ClientVisibleComponent,
	ClientEffectComponent,
	ClientAnimationComponent,
	ClientAudioComponent,
	ClientTimeControlComponent,
	ClientDebugComponent
}

Class.AddComponents(ClientVirtualEntity, ClientVirtualComponents)

local entityManager = appFacade.entityManager

function ClientVirtualEntity:ctor(entityId)
	ClientVirtualEntity.super.ctor(self, entityId)

	self.actorType = Const.ACTOR_TYPE_VIRTUAL
	self.useSimpleTimeScale = true
	self.isClientEnt = true
end

function ClientVirtualEntity:init(dict)
	self.isInited = true

	return true
end

function ClientVirtualEntity:isPet()
	return false
end

function ClientVirtualEntity:postInit(dict)
	ClientVirtualEntity.super.postInit(self, dict)
	self:createEModel()
end

function ClientVirtualEntity:getLockPosition()
	return self:getPosition()
end

function ClientVirtualEntity:turnToRotation(rotation)
	AnimationUtils.playTurnAnimation(self, rotation)
end

function ClientVirtualEntity:getCsEntityType()
	return ClientConst.ENTITY_CS_TYPE.VIRTUAL
end

function ClientVirtualEntity:getEModelResId()
	return AddressDataConst.Ent_Entity
end

function ClientVirtualEntity:initializeComponents()
	self:postComponentMethod("EVENT_AddEComponent")
	self:addVirtualEntityComponent()
end

function ClientVirtualEntity:addVirtualEntityComponent()
	self:addEModelComponent(Const.COMPONENT_INDEX_MODEL)
end

function ClientVirtualEntity:setConfigData(configData)
	self.configData = configData
end

function ClientVirtualEntity:getConfigData()
	return self.configData or {}
end

function ClientVirtualEntity:csRequireConfigData(dataName, sysCfgName)
	local ret = self:getConfigData()[dataName]

	if ret == nil and sysCfgName then
		ret = SysConfigData[sysCfgName]
	end

	return ret
end

function ClientVirtualEntity:getHeight()
	return self:getConfigData().modelHeight or 1.65
end

function ClientVirtualEntity:isPartEnt()
	return false
end

function ClientVirtualEntity:onEnterSpace()
	self:postComponentMethod("onEnterSpace")
	self:postComponentMethod("EVENT_EnterScene")
	self:postComponentMethod("EVENT_RefreshPhysx")
end

function ClientVirtualEntity:postInitializeComponents()
	if self.eModel then
		self.eModel:PostInitialize()
	end

	local st, err = xpcall(function()
		self:refreshAppearance()
	end, debug.traceback)

	if not st and LoggerManager.checkLogger(LoggerConst.ERROR) then
		self.logger:error("%s postInitializeComponents failed, %s", self:repr(), err)
	end
end

function ClientVirtualEntity:onTriggerEnter(userData)
	self:postComponentMethod("onTriggerEnter", userData)
end

function ClientVirtualEntity:onTriggerExit(userData)
	self:postComponentMethod("onTriggerExit", userData)
end

function ClientVirtualEntity:refreshAppearance()
	self:setModelLayer()

	if self.eModel then
		self.eModel:SetClientReady(true)
	end
end

function ClientVirtualEntity:onModelRefreshed()
	ClientModelUtils.applyModelSwitchTag(self)
	self:postComponentMethod("EVENT_OnModelRefreshed")
end

function ClientVirtualEntity:setModelLayer(layer)
	if layer == nil then
		layer = self:getConfigData().layer or ClientConst.LayerDefine.LAYER_ENTITY
	end

	if self.eModel then
		self.eModel:SetModelLayer(layer)
	end
end

function ClientVirtualEntity:setModelLoaded(isLoaded)
	self.eModel.isModelLoaded = isLoaded
end

function ClientVirtualEntity:onActiveChange(active)
	self:postComponentMethod("EVENT_OnActiveChange", active)
	self:postComponentMethod("NPCINFO_OnAciveChange", active)
end

function ClientVirtualEntity:onModelVisibleChange(visible)
	self:postComponentMethod("EVENT_OnModelVisibleChange", visible)
end

function ClientVirtualEntity:getTopLogoFollowStrategy()
	return ClientUtils.getEntityTopLogoFollowStrategy(self)
end

function ClientVirtualEntity:getTopLogoHeight(strategy, entry)
	return ClientUtils.getEntityTopLogoHeight(self, strategy, entry)
end

function ClientVirtualEntity:getTopLogoHeightToRoot()
	local topLogoHeight = self:getTopLogoHeight()

	if self.topLogoData.strategy == 3 then
		local success, pos, _ = self.eModel:TryGetHead(Const.COMPONENT_INDEX_MODEL)

		if success then
			topLogoHeight = pos.y - self:getPosition().y
		end
	end

	return topLogoHeight
end

return ClientVirtualEntity
