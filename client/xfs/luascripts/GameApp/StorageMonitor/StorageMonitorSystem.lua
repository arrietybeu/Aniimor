-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\StorageMonitor\\StorageMonitorSystem.lua

local Class = require("Core.Framework.Class")
local SystemBase = require("GameApp.Core.SystemBase")
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade
local StorageMonitorSystem = Class.LightClass("StorageMonitorSystem", SystemBase)

function StorageMonitorSystem:ctor(name)
	self.name = name or "StorageMonitorSystem"
	self.monitorIntervalSec = 60
	self.isInitialized = false
end

function StorageMonitorSystem:init()
	if self.isInitialized then
		return
	end

	self.isInitialized = true

	PlatformBridgeLuaFacade.ConfigureStorageMonitorInterval(self.monitorIntervalSec)
	pg.log(self.name, "Initialized platform storage monitor (interval: " .. self.monitorIntervalSec .. "s)")
end

function StorageMonitorSystem:tick(deltaTime)
	PlatformBridgeLuaFacade.GetStorageWriteStats(function(bytesWritten, budget)
		if budget == 0 then
			return
		end

		local ratio = bytesWritten / budget
		local bytesWrittenMB = bytesWritten / 1048576
		local budgetMB = budget / 1048576

		if ratio > 0.8 then
			pg.error(self.name, string.format("[STORAGE-CRITICAL] Write limit approaching! %.1f%% (%d / %d MB)", ratio * 100, bytesWrittenMB, budgetMB))
		elseif ratio > 0.5 then
			pg.warn(self.name, string.format("[STORAGE-WARN] Write usage: %.1f%% (%d / %d MB)", ratio * 100, bytesWrittenMB, budgetMB))
		else
			pg.log(self.name, string.format("[STORAGE] Write stats: %.1f%% (%d / %d MB)", ratio * 100, bytesWrittenMB, budgetMB))
		end
	end)
end

function StorageMonitorSystem:setMonitorInterval(intervalSec)
	self.monitorIntervalSec = intervalSec

	if self.isInitialized then
		PlatformBridgeLuaFacade.ConfigureStorageMonitorInterval(intervalSec)
	end
end

function StorageMonitorSystem:getMonitorInterval()
	return self.monitorIntervalSec
end

function StorageMonitorSystem:shutdown()
	self.isInitialized = false

	pg.log(self.name, "Shutdown platform storage monitor")
end

return StorageMonitorSystem
