-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Net\\CallbackManager.lua

local class = require("Core.Framework.Class")
local globalDeclare = require("Core.Framework.Global")
local CommonRepo = require("Core.Common.CommonRepo")
local Switch = require("Core.Common.Switch")
local TimerManager = require("Core.Timer.TimerManager")
local CallbackManager = class.Class("CallbackManager")
local id2Handler = {}
local id2Trace = {}
local mapping2AoiWorld = {}

local function CallbackManagerHandler(id, ...)
	local handler = id2Handler[id]

	if handler then
		handler(...)
	end
end

local function InvokeEnterAOICallback(enterMap, mappingObj)
	local aoiWorld = mapping2AoiWorld[mappingObj]

	if aoiWorld then
		aoiWorld.enterCallback(enterMap)
	end
end

local function InvokeLeaveAOICallback(leaveMap, mappingObj)
	local aoiWorld = mapping2AoiWorld[mappingObj]

	if aoiWorld then
		aoiWorld.leaveCallback(leaveMap)
	end
end

local function CallbackStatsHandler(...)
	if pg.component == "game" then
		local GameServerRepo = require("Core.Server.GameServerRepo")

		GameServerRepo.gameStatsHandler(...)
	end
end

local function CallbackSignalHandler(signum)
	if CommonRepo.signalHandler then
		CommonRepo.signalHandler(signum)
	end
end

local function CallbackPullDelayHandler(delay)
	if pg.component == "game" then
		CommonRepo.logger:warn("PullDelayTime [microsecond]: %s", delay)

		local GameServerRepo = require("Core.Server.GameServerRepo")

		if GameServerRepo.gameEventCallback.serverStartSucc then
			local Globals = require("Globals")

			Globals.specificEntity:setDelayMetrics(delay)
		end
	end
end

function CallbackManager.init()
	globalDeclare("CallbackManagerHandler", CallbackManagerHandler)
	globalDeclare("InvokeEnterAOICallback", InvokeEnterAOICallback)
	globalDeclare("InvokeLeaveAOICallback", InvokeLeaveAOICallback)
	globalDeclare("CallbackStatsHandler", CallbackStatsHandler)
	globalDeclare("CallbackSignalHandler", CallbackSignalHandler)
	globalDeclare("CallbackPullDelayHandler", CallbackPullDelayHandler)

	return true
end

function CallbackManager.registerHandler(id, handler)
	assert(type(handler) == "function")

	id2Handler[id] = handler

	if Switch.CallbackDebug then
		id2Trace[id] = debug.traceback()
	end
end

function CallbackManager.unRegisterHandler(id)
	id2Handler[id] = nil
	id2Trace[id] = nil
end

function CallbackManager.registerAoiWorld(aoiWorld, mappingObj)
	mapping2AoiWorld[mappingObj] = aoiWorld
end

function CallbackManager.unRegisterAoiWorld(mappingObj)
	mapping2AoiWorld[mappingObj] = nil
end

function CallbackManager.printTrace()
	for _, trace in pairs(id2Trace) do
		CommonRepo.logger:info(trace)
	end
end

return CallbackManager
