-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Homeland\\OrnamentBuildAttachManager.lua

local Class = require("Core.Framework.Class")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local HomeObjectData = require("Data.home_object_data")
local Utils = require("Common.Utils.Utils")
local OrnamentBuildAttachManager = Class.LightClass("OrnamentBuildAttachManager")

function OrnamentBuildAttachManager:ctor()
	self.tempLoopDetectDict = {}
end

function OrnamentBuildAttachManager:destroy()
	return
end

function OrnamentBuildAttachManager:init(ornaments, ornamentBuildExtraData)
	self.ornament = ornaments
	self.ornamentBuildExtraData = ornamentBuildExtraData
	self.attachData = ornamentBuildExtraData.attachData
	self.linkData = ornamentBuildExtraData.linkData
end

function OrnamentBuildAttachManager:getAttachChildEntitiesId(parentEntId, result)
	for childOrnamentId, attachInfo in pairs(self.attachData) do
		if parentEntId ~= childOrnamentId and self:checkIsChildOf(childOrnamentId, parentEntId) then
			result[childOrnamentId] = true
		end
	end
end

function OrnamentBuildAttachManager:checkIsChildOf(ornamentId, parentOrnamentId)
	if ornamentId == parentOrnamentId then
		return false
	end

	table.clear(self.tempLoopDetectDict)

	local curOrnamentId = ornamentId

	while curOrnamentId and curOrnamentId ~= 0 do
		if curOrnamentId == parentOrnamentId then
			table.clear(self.tempLoopDetectDict)

			return true
		end

		self.tempLoopDetectDict[curOrnamentId] = true
		curOrnamentId = self.attachData[curOrnamentId] and self.attachData[curOrnamentId].parentId

		if self.tempLoopDetectDict[curOrnamentId] then
			table.clear(self.tempLoopDetectDict)

			return false
		end
	end

	table.clear(self.tempLoopDetectDict)

	return false
end

function OrnamentBuildAttachManager:checkAttachValid(ornamentId, parentOrnamentId, slotId)
	local ornamentInfo = self.ornament[ornamentId]

	if not ornamentInfo then
		return false
	end

	if ornamentId == parentOrnamentId then
		return false
	end

	if not HomeLandUtils.checkHomeObjectCanAttach(ornamentInfo.homeId) then
		return false
	end

	local parentOrnamentInfo = self.ornament[parentOrnamentId]

	if not parentOrnamentInfo then
		return false
	end

	if not HomeLandUtils.checkHomeObjectCanBeAttach(parentOrnamentInfo.homeId) then
		return false
	end

	if self:checkIsChildOf(parentOrnamentId, ornamentId) then
		return false
	end

	return true
end

return OrnamentBuildAttachManager
