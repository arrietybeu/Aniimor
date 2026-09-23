-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\SpaceComponent\\ClientSpaceTileComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local ClientSpaceTileComponent = Class.Component("ClientSpaceTileComponent")
local pairs = pairs
local NOT_VISITED = 1
local VISITED = 2
local NEW_LOAD = 3
local WAIT_UNLOAD = 2
local getTileKey = Utils.getTileKey
local getOffsetTileKey = Utils.getOffsetTileKey
local getTileXZByKey = Utils.getTileXZByKey
local math_abs = math.abs

function ClientSpaceTileComponent:ctor()
	self.loaded = {}
	self.waitUnload = {}
	self.keyToVec2 = {}
	self.lastTile = nil
end

function ClientSpaceTileComponent:getTileIndex(tileX, tileZ)
	return Vector2(tileX, tileZ)
end

function ClientSpaceTileComponent:move(tileX, tileZ)
	local curTile = getTileKey(tileX, tileZ)

	if self.lastTile ~= nil and self.lastTile == curTile then
		return
	end

	for k, _ in pairs(self.loaded) do
		self.loaded[k] = NOT_VISITED
	end

	local key

	for i = -1, 1 do
		for j = -1, 1 do
			key = getOffsetTileKey(curTile, i, j)

			if self.keyToVec2[key] == nil then
				self.keyToVec2[key] = key
			end

			if self.waitUnload[key] then
				self.waitUnload[key] = nil
				self.loaded[key] = VISITED
			elseif self.loaded[key] then
				self.loaded[key] = VISITED
			else
				self.loaded[key] = NEW_LOAD

				self:postComponentMethod("onChunkLoadEvent", key, true)
			end
		end
	end

	for k, v in pairs(self.loaded) do
		if v == NOT_VISITED then
			self.loaded[k] = nil
			self.waitUnload[k] = WAIT_UNLOAD
		end
	end

	for k, _ in pairs(self.waitUnload) do
		local tempTile = self.keyToVec2[k]
		local x, z = getTileXZByKey(tempTile)

		if math_abs(x - tileX) > 2 or math_abs(z - tileZ) > 2 then
			self.waitUnload[k] = nil

			self:postComponentMethod("onChunkLoadEvent", k, false)
		end
	end

	self.lastTile = curTile
end

return ClientSpaceTileComponent
