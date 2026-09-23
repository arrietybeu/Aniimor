-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\EchoStone.lua

local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local EchoStone = Class.LightClass("EchoStone", LevelItem)

function EchoStone:ctor(sandbox, spawnInfo, syncInfo)
	EchoStone.super.ctor(self, sandbox, spawnInfo, syncInfo)
end

function EchoStone:echo()
	self:serverMsg("RPC_CS_HitEchoStone")
end

function EchoStone:destroy()
	EchoStone.super.destroy(self)
end

return EchoStone
