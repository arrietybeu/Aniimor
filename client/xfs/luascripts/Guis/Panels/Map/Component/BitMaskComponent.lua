-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Map\\Component\\BitMaskComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local MapSmallAreaIdToIndex = require("Data.map_small_area_id_to_index")
local LuaUIUtils = require("Utils.LuaUIUtils")
local MapHelper = require("GameApp.Map.MapHelper")
local AudioConst = require("Const.AudioConst")
local AREA_FOG_UNLOCK_ANIMATION_NAME = "VX_MapFogChunk_Unlock"
local BitMaskComponent = Class.LightClass("BitMaskComponent", UIComponent)

BitMaskComponent.SmallAreaState = {
	Clean = 1,
	Fog = 0
}

function BitMaskComponent:findObjects()
	return
end

function BitMaskComponent:init()
	if pg.game.map.desiredCleanSmallArea and pg.game.map.desiredCleanSmallArea[self.ctrl.sceneId] then
		self.fogTrans = self.view.mapScrollContent:Find("Fog")

		if not self.fogTrans then
			return
		end

		local mapFogGenerator = self.fogTrans:GetComponent("MapFogGenerator")

		if not mapFogGenerator then
			return
		end

		mapFogGenerator:OverlaidFootprintAll()
		self:setMapFogBitMask(self.ctrl.sceneId, pg.game.map.desiredCleanSmallArea[self.ctrl.sceneId])
	else
		self:areaFogUnlock()
	end
end

function BitMaskComponent:setMapFogBitMask(sceneId, desiredCleanSmallArea)
	local smallAreaInfos = pg.game.map:getBlockIds(sceneId)
	local stateData = {}

	for _, smallAreaId in ipairs(smallAreaInfos) do
		if MapSmallAreaIdToIndex[smallAreaId] then
			if LuaUIUtils.tableContains(desiredCleanSmallArea, smallAreaId) then
				stateData[MapSmallAreaIdToIndex[smallAreaId]] = self.SmallAreaState.Clean
			else
				stateData[MapSmallAreaIdToIndex[smallAreaId]] = self.SmallAreaState.Fog
			end
		end
	end

	if self.fogTrans then
		local mapFogGenerator = self.fogTrans:GetComponent("MapFogGenerator")

		if mapFogGenerator then
			mapFogGenerator:SetMapMaterialInfoForFog(stateData)
		end
	end
end

function BitMaskComponent:getAllFogUImages()
	local ret = {}
	local fogChunkGroup = self.fogTrans:Find("FogChunkGroup")
	local childCount = fogChunkGroup.childCount

	for i = 0, childCount - 1 do
		local chunkTrans = fogChunkGroup:GetChild(i)
		local uImage = chunkTrans:GetComponent("UImage")

		if uImage then
			table.insert(ret, uImage)
		end
	end

	return ret
end

function BitMaskComponent:destroy()
	if self.unlockTimer then
		self.ctrl:killTimer(self.unlockTimer)

		self.unlockTimer = nil
	end
end

function BitMaskComponent:isAreaFogUnlocking()
	if self.unlockTimer then
		return true
	end

	if IsNil(self.fogTrans) then
		return false
	end

	local fogChunkGroup = self.fogTrans:Find("FogChunkGroup")

	if IsNil(fogChunkGroup) then
		return false
	end

	for i = 0, fogChunkGroup.childCount - 1 do
		local animation = fogChunkGroup:GetChild(i):GetComponent("Animation")

		if not IsNil(animation) and animation:IsPlaying(AREA_FOG_UNLOCK_ANIMATION_NAME) then
			return true
		end
	end

	return false
end

function BitMaskComponent:onDestroy()
	self:destroy()
	UIComponent.onDestroy(self)
end

function BitMaskComponent:areaFogUnlock()
	local fogTrans = self.view.mapScrollContent:Find("Fog")

	self.fogTrans = fogTrans

	if not fogTrans then
		return
	end

	local mapFogGenerator = fogTrans:GetComponent("MapFogGenerator")

	if not mapFogGenerator then
		return
	end

	local desiredCleanSmallArea = {}
	local allChildrenScenes = MapHelper.getAllChildrenScene(self.ctrl.sceneId)

	for _, sceneId in ipairs(allChildrenScenes) do
		local smallAreaInfos = pg.game.map:getBlockIds(sceneId)

		for _, smallAreaId in ipairs(smallAreaInfos) do
			if MapSmallAreaIdToIndex[smallAreaId] and pg.me:getAreaFirstInData(smallAreaId) then
				table.insert(desiredCleanSmallArea, smallAreaId)
			end
		end
	end

	if #desiredCleanSmallArea <= 0 then
		return
	end

	mapFogGenerator:OverlaidFootprintAll()

	local stateData = {}
	local smallAreaIdIndexTable = {}
	local indexOffset = 0
	local cachedIndex

	for _, sceneId in ipairs(allChildrenScenes) do
		local smallAreaInfos = pg.game.map:getBlockIds(sceneId)

		indexOffset = #stateData

		for _, smallAreaId in ipairs(smallAreaInfos) do
			if MapSmallAreaIdToIndex[smallAreaId] then
				local index = MapSmallAreaIdToIndex[smallAreaId] + indexOffset

				if LuaUIUtils.tableContains(desiredCleanSmallArea, smallAreaId) then
					if pg.game.map.curUnlockedLargeAreaId and pg.game.map.curUnlockedLargeAreaId == smallAreaId then
						stateData[index] = 0
						cachedIndex = index
					else
						stateData[index] = 1
					end
				else
					stateData[index] = 0
				end

				smallAreaIdIndexTable[smallAreaId] = index
			end
		end
	end

	mapFogGenerator:SetMapMaterialInfoForFog(stateData)

	if pg.game.map.curUnlockedLargeAreaId then
		local unlockIndex = smallAreaIdIndexTable[pg.game.map.curUnlockedLargeAreaId]

		if unlockIndex then
			self.unlockTimer = self.ctrl:startTimer(function()
				self.unlockTimer = nil

				if cachedIndex then
					stateData[cachedIndex] = 1

					mapFogGenerator:SetMapMaterialInfoForFog(stateData)
				end

				mapFogGenerator:SetFogUnlockIndex(unlockIndex)
				pg.game.audio:triggerEvent(AudioConst.MAP_ClEAR_FOG)
			end, 3)
		end

		pg.game.map.curUnlockedLargeAreaId = nil
	end
end

return BitMaskComponent
