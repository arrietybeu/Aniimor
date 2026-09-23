-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Homeland\\HomelandFastFindMap.lua

local Class = require("Core.Framework.Class")
local HomelandFastFindInfo = require("Common.Homeland.HomelandFastFindInfo")
local Utils = require("Common.Utils.Utils")
local HomeObjectData = require("Data.home_object_data")
local Const = require("Common.Const.Const")
local HomelandFastFindMap = Class.LightClass("HomelandFastFindMap")

function HomelandFastFindMap:ctor(chunkSize)
	self.chunkSize = chunkSize or 16
	self.chunkFastFindMap = {}
	self.ornamentDict = {}
	self.tempCheckedIds = {}
end

function HomelandFastFindMap:getChunkValue(value)
	return math.ceil(value / self.chunkSize)
end

function HomelandFastFindMap:getChunkId(x, z)
	return Utils.getTileKey(x, z)
end

function HomelandFastFindMap:getFastFindInfo(ornamentId)
	return self.ornamentDict[ornamentId]
end

function HomelandFastFindMap:refreshFastFindInfo(ornamentId, position, rotation, bounds)
	local fastFindInfo = self.ornamentDict[ornamentId]

	if fastFindInfo then
		fastFindInfo:setTrans(position, rotation)

		if bounds then
			fastFindInfo:setBounds(bounds)
		end

		self:innerRefreshFastFindInfo(ornamentId, fastFindInfo)
	end
end

function HomelandFastFindMap:refreshExtraInfo(ornamentId, extraInfo)
	local fastFindInfo = self.ornamentDict[ornamentId]

	if not fastFindInfo then
		return
	end

	fastFindInfo:setExtraInfo(extraInfo)
end

function HomelandFastFindMap:addOrUpdateFastFindInfo(ornamentId, bounds, position, rotation, extraInfo)
	local fastFindInfo = self.ornamentDict[ornamentId]

	if not fastFindInfo then
		fastFindInfo = HomelandFastFindInfo.new(ornamentId)
		self.ornamentDict[ornamentId] = fastFindInfo
	end

	fastFindInfo:setBounds(bounds)
	fastFindInfo:setTrans(position, rotation)
	fastFindInfo:setExtraInfo(extraInfo)
	self:innerRefreshFastFindInfo(ornamentId, fastFindInfo)
end

function HomelandFastFindMap:innerRefreshFastFindInfo(ornamentId, fastFindInfo)
	if not fastFindInfo then
		return
	end

	local position = fastFindInfo.position
	local boundX, boundZ = fastFindInfo:getHalfBoundWithRot()
	local minX = self:getChunkValue(position.x - boundX)
	local minZ = self:getChunkValue(position.z - boundZ)
	local maxX = self:getChunkValue(position.x + boundX)
	local maxZ = self:getChunkValue(position.z + boundZ)

	if fastFindInfo.lastMinX == minX and fastFindInfo.lastMinZ == minZ and fastFindInfo.lastMaxX == maxX and fastFindInfo.lastMaxZ == maxZ then
		return
	end

	for _, chunkId in ipairs(fastFindInfo.chunkIds) do
		local chunkMap = self.chunkFastFindMap[chunkId]

		if chunkMap then
			chunkMap[ornamentId] = nil
		end
	end

	table.clear(fastFindInfo.chunkIds)

	for x = minX, maxX do
		for z = minZ, maxZ do
			local chunkId = self:getChunkId(x, z)

			table.insert(fastFindInfo.chunkIds, chunkId)

			local entList = self.chunkFastFindMap[chunkId]

			if not entList then
				entList = {}
				self.chunkFastFindMap[chunkId] = entList
			end

			entList[ornamentId] = fastFindInfo
		end
	end

	fastFindInfo.lastMinX = minX
	fastFindInfo.lastMinZ = minZ
	fastFindInfo.lastMaxX = maxX
	fastFindInfo.lastMaxZ = maxZ
end

function HomelandFastFindMap:removeFastFindInfo(ornamentId)
	local fastFindInfo = self.ornamentDict[ornamentId]

	if fastFindInfo then
		for _, chunkId in ipairs(fastFindInfo.chunkIds) do
			self.chunkFastFindMap[chunkId][ornamentId] = nil
		end

		self.ornamentDict[ornamentId] = nil
	end
end

function HomelandFastFindMap:clearFastFindInfo()
	self.chunkFastFindMap = {}
	self.ornamentDict = {}
end

function HomelandFastFindMap:getAreaRangeOrnamentIds(minPosX, maxPosX, minPosZ, maxPosZ, includeContact, result, threshold, minHeight, maxHeight, fastFilterFunc, slowFilterFunc)
	table.clear(result)
	table.clear(self.tempCheckedIds)

	local minX = self:getChunkValue(minPosX)
	local minZ = self:getChunkValue(minPosZ)
	local maxX = self:getChunkValue(maxPosX)
	local maxZ = self:getChunkValue(maxPosZ)

	for chunkX = minX, maxX do
		for chunkZ = minZ, maxZ do
			local chunkId = self:getChunkId(chunkX, chunkZ)
			local chunkInfo = self.chunkFastFindMap[chunkId]

			if chunkInfo then
				for ornamentId, fastInfo in pairs(chunkInfo) do
					if fastFilterFunc and not fastFilterFunc(ornamentId, fastInfo) then
						-- block empty
					elseif not self.tempCheckedIds[ornamentId] then
						self.tempCheckedIds[ornamentId] = true

						local passHeight = true

						if minHeight and maxHeight and fastInfo.extraInfo and fastInfo.extraInfo.height then
							local entMinY = fastInfo.position.y
							local entMaxY = entMinY + fastInfo.extraInfo.height

							if entMaxY < minHeight or maxHeight < entMinY then
								passHeight = false
							end
						end

						if not passHeight or not fastInfo:checkInRange(minPosX, maxPosX, minPosZ, maxPosZ, includeContact, threshold) or slowFilterFunc and not slowFilterFunc(ornamentId, fastInfo) then
							-- block empty
						else
							result[ornamentId] = fastInfo
						end
					end
				end
			end
		end
	end
end

return HomelandFastFindMap
