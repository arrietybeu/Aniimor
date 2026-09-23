-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\HomelandComponent\\ClientHomelandEnvComponent.lua

local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local ClientHomelandEnvComponent = Class.Component("ClientHomelandEnvComponent")

function ClientHomelandEnvComponent:init(dict)
	return true
end

function ClientHomelandEnvComponent:start()
	return
end

function ClientHomelandEnvComponent:on_homeLinkMap_groupId_changed(oldv, newv, ornamentId)
	self:_refreshLinkFacilityWorkState(ornamentId)
end

function ClientHomelandEnvComponent:on_homeLinkGroupMap_totalProduce_changed(oldv, newv, groupId)
	if (oldv or 0) > 0 == ((newv or 0) > 0) then
		return
	end

	local groupInfo = self.homeLinkGroupMap[groupId]

	if not groupInfo then
		return
	end

	for _, ornamentId in pairs(groupInfo.mainOrnaments) do
		self:_refreshLinkFacilityWorkState(ornamentId)
	end

	for _, ornamentId in pairs(groupInfo.subOrnaments) do
		self:_refreshLinkFacilityWorkState(ornamentId)
	end
end

function ClientHomelandEnvComponent:_refreshLinkFacilityWorkState(ornamentId)
	local ent = pg.game.home:getHomeEntity(ornamentId)

	if not ent or not ent.refreshFacilityWorkState then
		return
	end

	if ent.homeFacilityType ~= Const.HOMELAND_FACILITY_TYPE.ElectricLink then
		return
	end

	ent:refreshFacilityWorkState()
end

return ClientHomelandEnvComponent
