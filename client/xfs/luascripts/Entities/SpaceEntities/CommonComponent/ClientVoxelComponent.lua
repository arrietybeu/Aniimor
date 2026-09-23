-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientVoxelComponent.lua

local CommonConst = require("Common.Const.Const")
local Class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local AbilityConst = require("Common.Const.AbilityConst")
local ClientConst = require("Const.ClientConst")
local Utils = require("Common.Utils.Utils")
local VoxelUtils = require("Common.Utils.VoxelUtils")
local ClientVoxelComponent = Class.Component("ClientVoxelComponent")

function ClientVoxelComponent:ctor()
	self.voxelCustomData = 0
	self.surfaceVoxelCustomData = 0
	self.voxelState = 0
end

function ClientVoxelComponent:EVENT_AddEComponent()
	self:addEModelComponent(CommonConst.COMPONENT_VOXEL)
end

function ClientVoxelComponent:onEnterSpace()
	self:initVoxelComponent()
	self:refreshVoxelRegionLoadedState()
end

function ClientVoxelComponent:voxelRegionChanged()
	self:refreshVoxelRegionLoadedState()
end

function ClientVoxelComponent:checkVoxelRegionLoaded()
	if self.space == nil then
		return false
	end

	local myPos = self:getPosition()
	local isSameSpace, entRegionId, useDefaultRegion = pg.world.getVoxelRegionIdByPos(self.space.id, myPos.x, myPos.z)

	if useDefaultRegion then
		return true
	end

	if not isSameSpace then
		return false
	end

	if pg.game.voxel.loadedRegionIdMap.loadType == ClientConst.VoxelLoadType.MAP_LOAD_ALL then
		return true
	end

	if pg.game.voxel.loadedRegionIdMap[entRegionId] then
		return true
	else
		return false
	end
end

function ClientVoxelComponent:refreshVoxelRegionLoadedState()
	local voxelRegionLoaded = self:checkVoxelRegionLoaded()

	if self.voxelRegionLoaded ~= voxelRegionLoaded then
		self.voxelRegionLoaded = voxelRegionLoaded

		self:postComponentMethod("EVENT_OnVoxelRegionChanged")
	end
end

function ClientVoxelComponent:EVENT_OnVoxelRegionChanged()
	if self.voxelRegionLoaded then
		self:setEnableVoxelUpdate(true)
	else
		self:setEnableVoxelUpdate(false)
	end
end

function ClientVoxelComponent:initVoxelComponent()
	if Utils.isEnvObj(self) then
		local range = (self:getConfigData().BodyHeight or 0.5) * 0.6 + 0.1

		self.eModel.checkVoxelUpRange = range
		self.eModel.checkVoxelDownRange = range
	end

	if self.isMainPlayer or self.isMainPet then
		self.eModel.betterWaterCheck = true
	end
end

function ClientVoxelComponent:setEnableVoxelUpdate(enable)
	if enable and self.checkEnableVoxelUpdate then
		enable = self:checkEnableVoxelUpdate()
	end

	self.eModel:SetEnableVoxelUpdate(CommonConst.COMPONENT_VOXEL, enable)

	if not enable then
		self:onVoxelChanged(0, 0, 0)
	end
end

function ClientVoxelComponent:onVoxelChanged(customData, state, surfaceVoxelCustomData)
	if self.voxelCustomData ~= customData or self.voxelState ~= state then
		self.voxelCustomData = customData
		self.voxelState = state

		self:postComponentMethod("EVENT_ContactVoxelChanged", customData, state)
	end

	if self.surfaceVoxelCustomData ~= surfaceVoxelCustomData then
		self.surfaceVoxelCustomData = surfaceVoxelCustomData

		self:postComponentMethod("EVENT_ContactSurfaceVoxelChanged", surfaceVoxelCustomData)
	end
end

return ClientVoxelComponent
