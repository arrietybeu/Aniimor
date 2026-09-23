-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\OverlapCounter.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local SandboxConst = require("Common.Const.SandboxConst")
local OverlapCounter = Class.LightClass("OverlapCounter", LevelItem)

function OverlapCounter:ctor(sandbox, spawnInfo, syncInfo)
	OverlapCounter.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function OverlapCounter:onCountChange(count)
	if count > 0 then
		self:sendSandboxEvent(SandboxConst.EVENT_TYPE.OVERLAP_COUNTER_BUSY)
		self:syncSingleFieldValue("state", 1)
	else
		self:sendSandboxEvent(SandboxConst.EVENT_TYPE.OVERLAP_COUNTER_FREE)
		self:syncSingleFieldValue("state", 0)
	end
end

function OverlapCounter:destroy()
	OverlapCounter.super.destroy(self)
end

return OverlapCounter
