-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Homeland\\ServerOrnamentBuildAttachManager.lua

local Class = require("Core.Framework.Class")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local HomeObjectData = require("Data.home_object_data")
local OrnamentBuildAttachManager = require("Common.Homeland.OrnamentBuildAttachManager")
local ServerOrnamentBuildAttachManager = Class.LightClass("ServerOrnamentBuildAttachManager", OrnamentBuildAttachManager)

function ServerOrnamentBuildAttachManager:ctor()
	ServerOrnamentBuildAttachManager.super.ctor(self)
end

function ServerOrnamentBuildAttachManager:onOrnamentRemove(ornamentId)
	if self.attachData[ornamentId] then
		self.attachData[ornamentId] = nil
	end

	for childOrnamentId, attachInfo in pairs(self.attachData) do
		if attachInfo.parentId == ornamentId then
			self.attachData[childOrnamentId] = nil
		end
	end
end

function ServerOrnamentBuildAttachManager:getRealOrnamentId(ornamentId, clientIdMap)
	if ornamentId >= 0 then
		return ornamentId
	end

	return clientIdMap[ornamentId]
end

function ServerOrnamentBuildAttachManager:applyBuildExtraData(buildExtraData, clientIdMap)
	local changed = false
	local attachData = buildExtraData.attachData

	if attachData then
		for childOrnamentId, attachInfo in pairs(attachData) do
			local realChildId = self:getRealOrnamentId(childOrnamentId, clientIdMap)
			local realParentId = self:getRealOrnamentId(attachInfo.parentId, clientIdMap)

			if not realParentId or realParentId == 0 then
				changed = changed or self:clearAttachData(realChildId)
			end
		end

		for childOrnamentId, attachInfo in pairs(attachData) do
			local realChildId = self:getRealOrnamentId(childOrnamentId, clientIdMap)
			local realParentId = self:getRealOrnamentId(attachInfo.parentId, clientIdMap)

			if not realParentId or realParentId == 0 then
				-- block empty
			else
				local valid = self:addAttachData(realChildId, realParentId, attachInfo.slotId)

				if not valid then
					changed = changed or self:clearAttachData(realChildId)
				else
					changed = true
				end
			end
		end
	end

	return changed
end

function ServerOrnamentBuildAttachManager:clearAttachData(ornamentId)
	if self.attachData[ornamentId] then
		self.attachData[ornamentId] = nil

		return true
	end

	return false
end

function ServerOrnamentBuildAttachManager:addAttachData(ornamentId, parentOrnamentId, slotId)
	slotId = slotId or 0

	if not self:checkAttachValid(ornamentId, parentOrnamentId, slotId) then
		return false
	end

	self.attachData[ornamentId] = {
		parentId = parentOrnamentId,
		slotId = slotId
	}

	return true
end

return ServerOrnamentBuildAttachManager
