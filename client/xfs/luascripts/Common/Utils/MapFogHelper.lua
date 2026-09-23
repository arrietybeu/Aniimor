-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\MapFogHelper.lua

local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("MapFogHelper")
local DungeonFogData = require("Data.dungeon_fog_data")
local SceneData = require("Data.scene_data")
local MapFogHelper = {}
local _discOffsetsCache = {}

local function buildDiscOffsets(r)
	local cached = _discOffsetsCache[r]

	if cached then
		return cached
	end

	local offsets = {}
	local r2 = r * r
	local n = 0

	for dx = -r, r do
		for dy = -r, r do
			if r2 >= dx * dx + dy * dy then
				n = n + 1
				offsets[n] = {
					dx,
					dy
				}
			end
		end
	end

	_discOffsetsCache[r] = offsets

	return offsets
end

local function trySetBit(block, bitOffset)
	local intIndex = math.floor(bitOffset / 32) + 1
	local bitInInt = bitOffset % 32
	local mask = bit.lshift(1, bitInInt)
	local oldVal = block.bits[intIndex] or 0

	if bit.band(oldVal, mask) ~= 0 then
		return false
	end

	block.bits[intIndex] = bit.bor(oldVal, mask)

	return true
end

function MapFogHelper.buildEmptyFogData(sceneId)
	local g = DungeonFogData[sceneId]

	if not g then
		logger:error("buildEmptyFogData: no config for sceneId=%d", sceneId)

		return nil
	end

	local rows, cols = g.row, g.column
	local chunkRes = g.chunkResolution
	local unitPx = g.unitPixel
	local mapW, mapH = g.desiredMapSize[1], g.desiredMapSize[2]
	local fogData = {}

	for i = 0, cols - 1 do
		for j = 0, rows - 1 do
			local chunkUiW = math.min(chunkRes, mapW - i * chunkRes)
			local chunkUiH = math.min(chunkRes, mapH - j * chunkRes)
			local chunkPxW = math.floor(chunkUiW / unitPx)
			local chunkPxH = math.floor(chunkUiH / unitPx)
			local blockIndex = i * rows + j
			local intCount = math.ceil(chunkPxW * chunkPxH / 32)
			local bits = {}

			for k = 1, intCount do
				bits[k] = 0
			end

			fogData[blockIndex] = {
				width = chunkPxW,
				height = chunkPxH,
				bits = bits
			}
		end
	end

	return fogData
end

function MapFogHelper.posToCells(sceneId, mapX, mapY)
	local g = DungeonFogData[sceneId]

	if not g then
		return nil, nil
	end

	local sd = SceneData and SceneData[sceneId]
	local mapUIW = sd and sd.mapUISize and sd.mapUISize[1] or g.desiredMapSize[1]
	local mapUIH = sd and sd.mapUISize and sd.mapUISize[2] or g.desiredMapSize[2]
	local unitPx = g.unitPixel
	local dmsX = mapX - mapUIW / 2
	local dmsY = mapY + mapUIH / 2
	local gapX = math.floor((dmsX + g.desiredMapSize[1] / 2) / unitPx)
	local gapY = math.floor((dmsY + g.desiredMapSize[2] / 2) / unitPx)

	return gapX, gapY
end

function MapFogHelper.computeReveal(sceneId, gapX, gapY, fogData)
	local g = DungeonFogData[sceneId]

	if not g or not fogData then
		return {}
	end

	local rows = g.row
	local cols = g.column
	local chunkRes = g.chunkResolution
	local unitPx = g.unitPixel
	local r = g.explorePixelRadius
	local eachChunkPx = math.floor(chunkRes / unitPx)
	local xLimit = cols * eachChunkPx
	local yLimit = rows * eachChunkPx
	local offsets = buildDiscOffsets(r)
	local changedBlocks = {}

	for k = 1, #offsets do
		local off = offsets[k]
		local x = gapX + off[1]
		local y = gapY + off[2]

		if x >= 0 and x < xLimit and y >= 0 and y < yLimit then
			local firstIdx = math.floor(x / eachChunkPx)
			local secondIdx = rows - 1 - math.floor(y / eachChunkPx)
			local blockIndex = firstIdx * rows + secondIdx
			local block = fogData[blockIndex]

			if block then
				local chunkGapX = x % eachChunkPx
				local chunkGapY = y % eachChunkPx
				local bitOffset = chunkGapY * block.width + chunkGapX

				if trySetBit(block, bitOffset) then
					changedBlocks[blockIndex] = true
				end
			end
		end
	end

	return changedBlocks
end

function MapFogHelper.isDiffEmpty(changedBlocks)
	return not changedBlocks or next(changedBlocks) == nil
end

function MapFogHelper.blockToFogLighter(block)
	if not block then
		return nil
	end

	local bits = block.bits
	local n = #bits
	local lighter = {
		block.width,
		block.height
	}

	for i = 1, n do
		lighter[i + 2] = bits[i]
	end

	return lighter
end

function MapFogHelper.fogDataToFogLighterMap(fogData)
	local out = {}

	if not fogData then
		return out
	end

	for blockIndex, block in pairs(fogData) do
		out[blockIndex] = MapFogHelper.blockToFogLighter(block)
	end

	return out
end

return MapFogHelper
