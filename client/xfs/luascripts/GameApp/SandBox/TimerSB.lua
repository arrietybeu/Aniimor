-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\TimerSB.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Time = require("Core.Common.Time")
local TimerSB = Class.LightClass("TimerSB", LevelItem)
local StateDef = {
	Finished = 2,
	Ticking = 1,
	Default = 0
}

function TimerSB:ctor(sandbox, spawnInfo, syncInfo)
	TimerSB.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function TimerSB:onInit()
	if self.syncInfo.state == StateDef.Ticking then
		self:play()
	end
end

function TimerSB:setSyncInfo(syncInfo, isInit)
	TimerSB.super.setSyncInfo(self, syncInfo, isInit)

	if syncInfo.state == StateDef.Default then
		self:stop()
	elseif syncInfo.state == StateDef.Ticking then
		self:play()
	elseif syncInfo.state == StateDef.Finished then
		self:stop()
	end
end

function TimerSB:play()
	local majorConfig = self:getMajorConfig()
	local text = pg.getGameString(majorConfig.titleKey)
	local startTime = self.syncInfo.startTime or 0
	local lastDuration = startTime + majorConfig.duration - Time.secondCache

	LuaUIUtils.commonShowCountDown(self.id, lastDuration, text)
end

function TimerSB:stop()
	LuaUIUtils.commonHideCountDown(self.id)
end

function TimerSB:destroy(fromSandbox)
	self:stop()
	TimerSB.super.destroy(self, fromSandbox)
end

return TimerSB
