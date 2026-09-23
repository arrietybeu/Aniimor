-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientFloorHeightCheckComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local SceneData = require("Data.scene_data")
local Const = require("Common.Const.Const")
local PhysicsUtils = require("Common.Utils.PhysicsUtils")
local ClientFloorHeightCheckComponent = Class.Component("ClientFloorHeightCheckComponent")

function ClientFloorHeightCheckComponent:start()
	if not self.floorCheckTimer then
		self.floorCheckTimer = self:addRepeatTimer(5, function()
			self:checkFloorHeight()
		end)
	end
end

function ClientFloorHeightCheckComponent:destroy()
	if self.floorCheckTimer then
		self:removeTimer(self.floorCheckTimer)

		self.floorCheckTimer = nil
	end
end

function ClientFloorHeightCheckComponent:checkFloorHeight()
	if not self.space then
		return
	end

	if self.authority ~= Const.AUTHORITY_MASTER then
		return
	end

	local sceneData = SceneData[self.space.sceneId] or {}

	if not sceneData.floorHeightToTeleport then
		return
	end

	local floorHeightToTeleport = sceneData.floorHeightToTeleport - 20

	if floorHeightToTeleport > self:getPosition().y then
		local targetY = sceneData.floorHeightToTeleport
		local startPosition = self:getPosition():Clone()

		if self.overrideGroundHeight then
			targetY = self.overrideGroundHeight
		else
			startPosition.y = targetY

			local succ, heightGround = PhysicsUtils.getGroundHeight(startPosition, 200)

			if succ then
				targetY = heightGround
			else
				targetY = targetY + 100
			end
		end

		self:serverMsg("RPC_CS_OnFloorHeightCheckInvalid", targetY)
		self.logger:info("ClientFloorHeightCheckComponent space out of floorHeight;", self:repr(), self:getPosition().y, targetY)
	end
end

return ClientFloorHeightCheckComponent
