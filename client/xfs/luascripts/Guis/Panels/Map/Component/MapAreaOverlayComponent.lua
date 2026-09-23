-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Map\\Component\\MapAreaOverlayComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local AddressDataConst = require("Const.AddressDataConst")
local MapBlockConfigData = require("Data.map_block_config_data")
local MapSmallAreaIdToIndex = require("Data.map_small_area_id_to_index")
local LuaUIUtils = require("Utils.LuaUIUtils")
local MapHelper = require("GameApp.Map.MapHelper")
local MapAreaOverlayComponent = Class.LightClass("MapAreaOverlayComponent", UIComponent)

MapAreaOverlayComponent.AreaState = {
	UnKnown = 0,
	Lock = 3,
	High = 2,
	Reach = 1
}

function MapAreaOverlayComponent:onCtor(info)
	self.renderer = self.ctrl.mapFogGenerator
	self.areaIndexTable = {}
	self.stateData = {}
	self.hoverAreaId = nil
	self.selectedAreaId = nil
	self.sceneId = pg.game.map:convertSceneId(info and info.selectedSceneId or self.ctrl.sceneId)
	self.simpleMode = AddressDataConst.MAP_SIMPLE_AREA_INFO[self.ctrl.sceneId] ~= nil
	self.enabled = self.simpleMode or AddressDataConst.MAP_AREA_INFO[self.sceneId] ~= nil or AddressDataConst.MAP_AREA_INFO[self.ctrl.sceneId] ~= nil

	if not self.enabled then
		self:resetRenderer()

		return
	end

	self:refreshStateData()
	self:setVisible(false)
	self:setSelected(nil)
	self:setHover(nil)
end

function MapAreaOverlayComponent:resetRenderer()
	if not self.renderer then
		return
	end

	self.renderer:SetAreaOverlayVisible(false)
	self.renderer:SetAreaSelectedIndex(0)
	self.renderer:SetAreaHoverIndex(0)
end

function MapAreaOverlayComponent:refreshStateData()
	if not self.enabled then
		return
	end

	local stateData = {}
	local indexOffset = 0

	for _, childSceneId in ipairs(MapHelper.getAllChildrenScene(self.sceneId)) do
		indexOffset = #stateData

		for _, smallAreaId in ipairs(pg.game.map:getBlockIds(childSceneId)) do
			local index = MapSmallAreaIdToIndex[smallAreaId]

			if index then
				index = index + indexOffset
				stateData[index] = self:calcAreaState(smallAreaId)
				self.areaIndexTable[smallAreaId] = index
			end
		end
	end

	self.stateData = stateData

	if self.renderer then
		self.renderer:SetAreaStateData(stateData)
	end
end

function MapAreaOverlayComponent:calcAreaState(smallAreaId)
	if self.simpleMode then
		local warningAreas = pg.game.map.desiredWarningSmallArea and pg.game.map.desiredWarningSmallArea[self.ctrl.sceneId]

		if warningAreas and LuaUIUtils.tableContains(warningAreas, smallAreaId) then
			return self.AreaState.UnKnown
		end

		return self.AreaState.Reach
	end

	local state = pg.me:getAreaFirstInData(smallAreaId) and self.AreaState.Reach or self.AreaState.UnKnown

	if not self:checkSmallAreaLockState(smallAreaId) then
		state = self.AreaState.Lock
	end

	return state
end

function MapAreaOverlayComponent:checkSmallAreaLockState(smallAreaId)
	local smallAreaCfg = MapBlockConfigData[smallAreaId]

	if not smallAreaCfg or not smallAreaCfg.mapAreaId then
		return false
	end

	return pg.game.map:checkBlockLeylineTreeUnlocked(smallAreaCfg.mapAreaId)
end

function MapAreaOverlayComponent:setVisible(visible)
	if not self.enabled or not self.renderer then
		return
	end

	self.renderer:SetAreaOverlayVisible(self.simpleMode or visible)
end

function MapAreaOverlayComponent:setSelected(smallAreaId)
	if not self.enabled or self.simpleMode or not self.renderer then
		return
	end

	self.selectedAreaId = smallAreaId

	self.renderer:SetAreaSelectedIndex(self.areaIndexTable[smallAreaId] or 0)
end

function MapAreaOverlayComponent:setHover(hoverAreaId)
	if not self.enabled or self.simpleMode or not self.renderer then
		return
	end

	if self.hoverAreaId == hoverAreaId then
		return
	end

	self.hoverAreaId = hoverAreaId

	self.renderer:SetAreaHoverIndex(self.areaIndexTable[hoverAreaId] or 0)
end

function MapAreaOverlayComponent:getAreaIndex(smallAreaId)
	return self.areaIndexTable and self.areaIndexTable[smallAreaId]
end

function MapAreaOverlayComponent:destroy()
	self:resetRenderer()

	self.renderer = nil
	self.areaIndexTable = nil
	self.stateData = nil
	self.hoverAreaId = nil
	self.selectedAreaId = nil
end

function MapAreaOverlayComponent:onDestroy()
	self:destroy()
	UIComponent.onDestroy(self)
end

return MapAreaOverlayComponent
