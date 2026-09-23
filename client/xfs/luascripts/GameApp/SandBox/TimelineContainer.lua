-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\TimelineContainer.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local ClientUtils = require("Utils.ClientUtils")
local TimelineContainer = Class.LightClass("TimelineContainer", LevelItem)
local StateDef = {
	STATE_PLAYING = 1,
	STATE_IDLE = 0,
	STATE_FINISHED = 2
}

function TimelineContainer:ctor(sandbox, spawnInfo, syncInfo)
	TimelineContainer.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function TimelineContainer:onSandboxReady()
	local majorConfig = self:getMajorConfig()

	if not majorConfig.noReconnectPlay then
		self:onLevelItemValueChange("state", StateDef.STATE_IDLE, self.syncInfo.state)
	elseif self.syncInfo.state == StateDef.STATE_PLAYING then
		self:serverMsg("RPC_CS_Finished")
	end
end

function TimelineContainer:onLevelItemValueChange(key, oldValue, value)
	if key == "state" then
		if oldValue == value then
			return
		end

		if value == StateDef.STATE_PLAYING then
			self:play()
		else
			self:stop()
		end
	end
end

function TimelineContainer:play()
	self:stop()

	local majorConfig = self:getMajorConfig()

	if not majorConfig or not majorConfig.resId then
		self.logger:error("TimelineContainer:play() - majorConfig or resId is nil")

		return
	end

	self.cutScene = pg.game.cutscene:playCutscene(majorConfig.resId, majorConfig.resId, self:getPosition(), self:getRotation(), nil, nil, {
		endCallback = function()
			self:serverMsg("RPC_CS_Finished")
		end,
		playSequence = majorConfig.playSequence or false
	})

	self:setIsActive(false)
end

function TimelineContainer:stop()
	if self.cutScene then
		self.cutScene:destroy()

		self.cutScene = nil

		self:setIsActive(true)
	end
end

function TimelineContainer:destroy()
	self:stop()
	TimelineContainer.super.destroy(self)
end

return TimelineContainer
