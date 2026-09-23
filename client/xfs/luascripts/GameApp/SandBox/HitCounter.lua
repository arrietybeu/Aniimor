-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\HitCounter.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local HitCounter = Class.LightClass("HitCounter", LevelItem)

function HitCounter:ctor(sandbox, spawnInfo, syncInfo)
	HitCounter.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function HitCounter:onHit()
	self:serverMsg("RPC_CS_OnSkillHit")
end

function HitCounter:destroy()
	HitCounter.super.destroy(self)
end

return HitCounter
