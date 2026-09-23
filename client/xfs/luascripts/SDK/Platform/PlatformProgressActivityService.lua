-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\PlatformProgressActivityService.lua

local logger = require("SDK.Platform.PlatformLogger")
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade
local PlatformProgressActivityService = {}

function PlatformProgressActivityService.isFacadeReady()
	return PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.StartActivity and PlatformBridgeLuaFacade.UpdateActivityProgress and PlatformBridgeLuaFacade.CompleteActivity and PlatformBridgeLuaFacade.AbandonActivity
end

function PlatformProgressActivityService.fireFallback(callback)
	if type(callback) == "function" then
		callback(true, 0, "", "")
	end
end

function PlatformProgressActivityService:start(activityId, callback, timeoutMs)
	if not PlatformProgressActivityService.isFacadeReady() then
		PlatformProgressActivityService.fireFallback(callback)

		return
	end

	PlatformBridgeLuaFacade.StartActivity(tostring(activityId or ""), timeoutMs or 0, callback)
end

function PlatformProgressActivityService:updateProgress(activityId, currentValue, targetValue, callback, timeoutMs)
	if not PlatformProgressActivityService.isFacadeReady() then
		PlatformProgressActivityService.fireFallback(callback)

		return
	end

	PlatformBridgeLuaFacade.UpdateActivityProgress(tostring(activityId or ""), math.floor(currentValue or 0), math.floor(targetValue or 0), timeoutMs or 0, callback)
end

function PlatformProgressActivityService:complete(activityId, callback, timeoutMs)
	if not PlatformProgressActivityService.isFacadeReady() then
		PlatformProgressActivityService.fireFallback(callback)

		return
	end

	PlatformBridgeLuaFacade.CompleteActivity(tostring(activityId or ""), timeoutMs or 0, callback)
end

function PlatformProgressActivityService:abandon(activityId, callback, timeoutMs)
	if not PlatformProgressActivityService.isFacadeReady() then
		PlatformProgressActivityService.fireFallback(callback)

		return
	end

	PlatformBridgeLuaFacade.AbandonActivity(tostring(activityId or ""), timeoutMs or 0, callback)
end

function PlatformProgressActivityService:isSupported()
	return PlatformBridgeLuaFacade and PlatformBridgeLuaFacade.SupportsProgressActivities and PlatformBridgeLuaFacade.SupportsProgressActivities() == true
end

return PlatformProgressActivityService
