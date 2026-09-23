-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\VirtualEntitiesContainer.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local ClientUtils = require("Utils.ClientUtils")
local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("VirtualEntitiesContainer", "Sandbox", LoggerConst.ERROR)
local VirtualEntitiesContainer = Class.LightClass("VirtualEntitiesContainer", LevelItem)

function VirtualEntitiesContainer:ctor(sandBox, spawnInfo, syncInfo)
	VirtualEntitiesContainer.super.ctor(self, sandBox, spawnInfo, syncInfo)

	self._entities = {}
end

function VirtualEntitiesContainer:onCreateVirtualEntity(refKey, extraInfo)
	extraInfo = extraInfo or {}

	local entity = ClientUtils.createClientEntity("ClientVirtualPuppet", VirtualEntUtils.getNewVirtualEntityId(), extraInfo)

	return entity
end

function VirtualEntitiesContainer:tryGetRefEntity(refKey)
	return self._entities[refKey]
end

function VirtualEntitiesContainer:createVirtualEntity(refKey, extraInfo)
	refKey = refKey or "Default"

	if self._entities[refKey] then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("VirtualEntitiesContainer createVirtualEntity failed refKey repeat", refKey)
		end

		return nil
	end

	local entity = self:onCreateVirtualEntity(refKey, extraInfo)

	if entity then
		entity.eModel:SetGameObjectName("VirtualEntity_" .. refKey)
	end

	entity.refLevelItemId = self.id
	self._entities[refKey] = entity

	return entity
end

function VirtualEntitiesContainer:destroy()
	for key, ent in pairs(self._entities) do
		ClientUtils.safeDestroy(ent)
	end

	self._entities = {}

	VirtualEntitiesContainer.super.destroy(self)
end

return VirtualEntitiesContainer
