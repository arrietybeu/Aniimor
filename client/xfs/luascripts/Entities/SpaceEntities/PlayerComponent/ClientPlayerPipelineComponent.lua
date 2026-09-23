-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientPlayerPipelineComponent.lua

local class = require("Core.Framework.Class")
local LoggerConst = require("Core.Log.LoggerConst")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("ClientSpaceVegetationComponent")
local ClientPlayerPipelineComponent = class.Component("ClientPlayerPipelineComponent")
local pipelineMgr = appFacade.pipelineManager

function ClientPlayerPipelineComponent:ctor()
	return
end

function ClientPlayerPipelineComponent:start()
	return
end

function ClientPlayerPipelineComponent:initPlayerPipeline()
	local curSceneId = pg.space and pg.space.sceneId or 0
	local hideVegetationMap = pg.me.hideVegetationMap[curSceneId]

	if hideVegetationMap then
		self:refreshVegetationTypeVisible(curSceneId, hideVegetationMap, false)
	end
end

function ClientPlayerPipelineComponent:on_hideVegetationMapentry_added(sceneId, vegTypes)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("on_hideVegetationMap_entry_added>>", sceneId)
	end

	self:refreshVegetationTypeVisible(sceneId, vegTypes, true)
end

function ClientPlayerPipelineComponent:on_hideVegetationMapentry_deleted(sceneId, vegTypes)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("on_hideVegetationMap_entry_deleted>>", sceneId)
	end

	self:refreshVegetationTypeVisible(sceneId, vegTypes, false)
end

function ClientPlayerPipelineComponent:on_hideVegetationMap_item_changed(oldVal, newVal, sceneId)
	if not self:isTargetScene(sceneId) then
		return
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("on_hideVegetationMap_item_changed>>", oldVal, newVal, sceneId)
	end

	local addedItems = {}
	local removedItems = {}
	local oldSet = {}

	for _, item in ipairs(oldVal) do
		oldSet[item] = true
	end

	local newSet = {}

	for _, item in ipairs(newVal) do
		newSet[item] = true
	end

	for _, item in ipairs(oldVal) do
		if not newSet[item] then
			table.insert(addedItems, item)
		end
	end

	for _, item in ipairs(newVal) do
		if not oldSet[item] then
			table.insert(removedItems, item)
		end
	end

	if #addedItems > 0 then
		self:refreshVegetationTypeVisible(sceneId, addedItems, true)
	end

	if #removedItems > 0 then
		self:refreshVegetationTypeVisible(sceneId, removedItems, false)
	end
end

function ClientPlayerPipelineComponent:refreshVegetationTypeVisible(sceneId, vegTypes, visible)
	if not self:isTargetScene(sceneId) then
		return
	end

	pipelineMgr:SetVegetationVisible(vegTypes, visible)
end

function ClientPlayerPipelineComponent:isTargetScene(sceneId)
	local curSceneId = pg.space and pg.space.sceneId or 0

	return sceneId == curSceneId
end

return ClientPlayerPipelineComponent
