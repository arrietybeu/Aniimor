-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\SpaceComponent\\ClientSpaceAreaComponent.lua

local Class = require("Core.Framework.Class")
local SceneUtils = require("Common.Utils.SceneUtils")
local LuaCondition = require("Common.Utils.LuaCondition")
local ClientSpaceAreaComponent = Class.Component("ClientSpaceAreaComponent")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("ClientSpaceAreaComponent")
local areaManager = appFacade.areaManager
local Const = require("Common.Const.Const")

function ClientSpaceAreaComponent:ctor()
	self.runtimeAreas = {}
	self.levelItemAreaData = {}
end

function ClientSpaceAreaComponent:start()
	self:initSceneLoadArea()
end

function ClientSpaceAreaComponent:initSceneLoadArea()
	local sceneGlobalAreaData = SceneUtils.getSceneGlobalAreaData(self.sceneId, self.id)

	if sceneGlobalAreaData then
		for _, areaId in pairs(sceneGlobalAreaData) do
			self:addArea(areaId)
		end
	end

	local sceneId = SceneUtils.getMainSceneId(self.sceneId)

	sceneGlobalAreaData = SceneUtils.getSceneGlobalAreaData(sceneId, self.id)

	if sceneGlobalAreaData then
		for _, areaId in pairs(sceneGlobalAreaData) do
			self:addArea(areaId)
		end
	end
end

function ClientSpaceAreaComponent:addArea(areaId)
	if self.runtimeAreas[areaId] then
		return
	end

	local areaData = self:getAreaData(areaId)

	if areaData then
		self:addAreaByData(areaData)
	elseif LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:log2Tag("Area", "SpaceArea do not have data!", areaId)
	end
end

function ClientSpaceAreaComponent:addAreaByData(areaData)
	local areaId = areaData.id
	local areaShapeType = areaData.areaShapeType
	local entityTypeList = areaData.entityTypeList

	if not entityTypeList then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			logger:log2Tag("Area", "SpaceArea do not have EntityType!", areaId)
		end

		return
	end

	local areaLayers = self:getAreaLayers(entityTypeList)

	for i = 1, #areaLayers do
		local layer = areaLayers[i]
		local enable = areaData.enable

		if enable == nil then
			enable = true
		end

		if areaShapeType == 0 then
			areaManager:AddCylinder(layer, areaId, areaData.position, areaData.height, areaData.radius, enable)
		elseif areaShapeType == 1 then
			areaManager:AddSphere(layer, areaId, areaData.position, areaData.radius, enable)
		elseif areaShapeType == 2 then
			areaManager:AddPolygon(layer, areaId, areaData.position, areaData.height, areaData.areaPoints, enable)
		end
	end

	self.runtimeAreas[areaId] = areaData
end

function ClientSpaceAreaComponent:registerLevelItemAreaData(areaId, areaData)
	self.levelItemAreaData[areaId] = areaData
end

function ClientSpaceAreaComponent:unregisterLevelItemAreaData(areaId)
	self.levelItemAreaData[areaId] = nil
end

function ClientSpaceAreaComponent:getAreaData(areaId)
	if self.levelItemAreaData[areaId] then
		return self.levelItemAreaData[areaId]
	end

	if self.runtimeAreas[areaId] then
		return self.runtimeAreas[areaId]
	end

	local sceneId = SceneUtils.getMainSceneId(self.sceneId)

	if not self.sceneAreaData then
		self.sceneAreaData = SceneUtils.getSceneAreaData(sceneId, self.id)
	end

	local areaData = self.sceneAreaData[areaId]

	if areaData then
		return areaData
	else
		local sd = SceneUtils.getSceneAreaData(self.sceneId, self.id)

		return sd[areaId]
	end
end

function ClientSpaceAreaComponent:getAreaLayers(entityTypeList)
	local layers = {}

	for i = 1, #entityTypeList do
		local entityType = entityTypeList[i]
		local layer = Const.ENTITY_TYPE_2_AREA_LAYER[entityType]

		if layer and not table.contains(layers, layer) then
			table.insert(layers, layer)
		end
	end

	return layers
end

function ClientSpaceAreaComponent:removeArea(areaId)
	self.runtimeAreas[areaId] = nil

	for i = Const.AREA_LAYER.DEFAULT, Const.AREA_LAYER.MAX - 1 do
		areaManager:RemoveArea(i, areaId)
	end
end

function ClientSpaceAreaComponent:destroy()
	self:clearSceneLoadArea()
end

function ClientSpaceAreaComponent:clearSceneLoadArea()
	for areaId, areaData in pairs(self.runtimeAreas) do
		if areaData.areaLoadType and areaData.areaLoadType == Const.AREA_LOAD_TYPE.SCENE_LOAD then
			self:removeArea(areaId)
		end
	end
end

return ClientSpaceAreaComponent
