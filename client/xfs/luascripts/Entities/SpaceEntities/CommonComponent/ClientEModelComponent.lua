-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientEModelComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
local ActorManager = require("Core.Common.ActorManager")
local ClientConst = require("Const.ClientConst")
local entityManager = appFacade.entityManager
local pg = pg
local table = table
local ClientEModelComponent = class.Component("ClientEModelComponent")

function ClientEModelComponent:ctor()
	self.eModelComponentCacheMap = {}
end

function ClientEModelComponent:createEModel()
	if self.dontCreateEModel and self:dontCreateEModel() then
		return
	end

	local csEntityType = self:getCsEntityType()
	local resId = self:getEModelResId()
	local showName = self:getShowName()
	local luaFunctionCacheClassType = ClientConst.LUA_FUNCTION_CACHE_CLASS_TYPE[self.className] or 0

	self.actorId = self.actorId or VirtualEntUtils.getNewVirtualEntActorId()

	ActorManager.addEntity(self.actorId, self)

	local selfActorId = self.actorId

	if self.eModel then
		if self.replaceNeedRebindEModel then
			entityManager:ReBindEModel(self.eModel, self.id, selfActorId, self, showName, luaFunctionCacheClassType)

			self.replaceNeedRebindEModel = nil
		else
			entityManager:ResetEModel(self.eModel, self.id, selfActorId, showName)
		end

		if self.setTopLogoEModelAlive then
			self:setTopLogoEModelAlive(true)
		end
	else
		if Utils.isEnvObj(self) and LoggerManager.checkLogger(LoggerConst.ERROR) then
			local envId = self:getGlobalId()
			local existEntity = pg.getEntityByGlobalId(envId)

			if existEntity then
				self.logger:error("different envObj with same globalId detect:", envId, self.id, existEntity.id)
			end
		end

		local oldEModel = pg.game.seamless:useRecordTempNpcEModel(self.staticId)

		if oldEModel then
			self.eModel = oldEModel

			if self.eModel then
				self.eModel.staticNoTick = false
			end
		end

		if self.eModel then
			if oldEModel then
				pg.game.seamless:markTempNpc(self)
			end

			entityManager:ReBindEModel(self.eModel, self.id, selfActorId, self, showName, luaFunctionCacheClassType)

			if self.setTopLogoEModelAlive then
				self:setTopLogoEModelAlive(true)
			end

			if oldEModel then
				if self.onModelRefreshed then
					self:onModelRefreshed()
				end

				if self.onItemModelLoaded then
					self:onItemModelLoaded()
				end
			end
		else
			entityManager:CreateEModel(self.id, selfActorId, csEntityType, resId, self, showName, luaFunctionCacheClassType)
		end
	end
end

function ClientEModelComponent:getShowName()
	if not UNITY_EDITOR then
		return self.id
	end

	if self.ornamentId then
		return string.format("%s-%s-%s-%s", self.className, self.ornamentId, tostring(self.id), tostring(self.homeTemplateId))
	elseif self.staticId then
		return string.format("%s-%s-%s-%s", self.className, self.id, tostring(self.templateId), tostring(self.staticId))
	else
		return string.format("%s-%s-%s", self.className, self.id, tostring(self.templateId))
	end
end

function ClientEModelComponent:onEModelCreate(eModel)
	self.eModel = eModel

	self.eModel:SetStaticId(self.staticId)
	self:initializeComponents()

	if self.setTopLogoEModelAlive then
		self:setTopLogoEModelAlive(true)
	end

	self:postComponentMethod("EVENT_EModelCreate")

	if self.postInitializeComponents then
		self:postInitializeComponents()
	end

	self:postComponentMethod("EVENT_PostInitialized")

	if self.onEModelCreateEffect then
		self:onEModelCreateEffect()
	end
end

function ClientEModelComponent:addEModelComponent(index)
	if self:hasEModelComponent(index) then
		return
	end

	if self.eModel then
		self.eModel:AddEModelComponent(index)
	end
end

function ClientEModelComponent:addEModelMonoComponent(index)
	if self:hasEModelComponent(index) then
		return
	end

	if self.eModel then
		self.eModel:AddEModelMonoComponent(index)
	end
end

function ClientEModelComponent:dynamicAddEModelComponent(index)
	if self:hasEModelComponent(index) then
		return
	end

	if self.eModel then
		self.eModel:DynamicAddComponent(index)
	end
end

function ClientEModelComponent:delEModelComponent(index)
	if self:hasEModelComponent(index) and self.eModel then
		self.eModel:DelComponent(index)
	end
end

function ClientEModelComponent:hasEModelComponent(index)
	return self.eModelComponentCacheMap[index] ~= nil
end

function ClientEModelComponent:onAddEModelComponent(index)
	if self:hasEModelComponent(index) then
		return
	end

	self.eModelComponentCacheMap[index] = true
end

function ClientEModelComponent:onSyncEModelComponentCache(indexList, count)
	table.clear(self.eModelComponentCacheMap)

	if not indexList then
		return
	end

	for i = 1, count do
		local index = indexList[i]

		self.eModelComponentCacheMap[index] = true
	end
end

function ClientEModelComponent:onDelEModelComponent(index)
	self.eModelComponentCacheMap[index] = nil
end

function ClientEModelComponent:getEModelComponent(index)
	if not self.eModel then
		return nil
	end

	local component = self.eModelComponentCacheMap[index]

	if component == true then
		component = self.eModel:GetComponent(index)
		self.eModelComponentCacheMap[index] = component
	end

	return component
end

function ClientEModelComponent:getEModelMonoComponent(index)
	if not self.eModel then
		return nil
	end

	local component = self.eModelComponentCacheMap[index]

	if component == true then
		component = self.eModel:GetMonoComponent(index)
		self.eModelComponentCacheMap[index] = component
	end

	return component
end

function ClientEModelComponent:destroy()
	ActorManager.removeEntity(self.actorId, self)

	if self.setTopLogoEModelAlive then
		self:setTopLogoEModelAlive(false)
	end

	local eModel = self.eModel

	if not eModel then
		return
	end

	if pg.game.seamless:needRecordTempNpcEModel(self) then
		pg.game.seamless:recordTempNpcEModel(self)
	else
		entityManager:DestroyEModel(eModel)

		self.eModel = nil

		table.clear(self.eModelComponentCacheMap)
	end
end

return ClientEModelComponent
