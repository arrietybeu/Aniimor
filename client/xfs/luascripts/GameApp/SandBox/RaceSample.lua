-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\RaceSample.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local logger = require("Core.Log.LoggerManager").getLogger("RaceSample")
local RaceSample = Class.LightClass("RaceSample", LevelItem)

function RaceSample:onInit()
	return
end

function RaceSample:onSandboxReady()
	RaceSample.super.onSandboxReady(self)

	self.sampleSB = self.shell.gameObject:GetComponent("RaceSampleSB")
end

function RaceSample:getSampleInfo()
	if self.sampleSB then
		local playerPos = pg.pawn:getPosition()
		local valid, sampleTime, samplePercent = self.sampleSB:GetSampleInfo(playerPos)

		return valid, sampleTime, samplePercent
	end

	return nil
end

return RaceSample
