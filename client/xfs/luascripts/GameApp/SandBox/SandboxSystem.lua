-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\SandboxSystem.lua

local Class = require("Core.Framework.Class")
local SystemBase = require("GameApp.Core.SystemBase")
local SandboxLevelItemPoolConfig = require("GameApp.Sandbox.SandboxLevelItemPoolConfig")
local SandboxSystem = Class.LightClass("SandboxSystem", SystemBase)

function SandboxSystem:onInit()
	SystemBase.onInit(self)
	self:registerLevelItemPoolConfig()
end

function SandboxSystem:registerLevelItemPoolConfig()
	local config = SandboxLevelItemPoolConfig
	local manager = appFacade and appFacade.sandboxManager

	assert(manager, "SandboxSystem: C# SandboxManager is not initialized")
	assert(type(config.maxTotalIdleCount) == "number", "SandboxSystem: maxTotalIdleCount must be a number")
	assert(type(config.capacityByRes) == "table", "SandboxSystem: capacityByRes must be a table")
	manager:RegisterLevelItemPoolConfig(config.maxTotalIdleCount, config.capacityByRes)
end

return SandboxSystem
