-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Log\\LoggerLazyLoad.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("LazyLoad")
local Time = require("Core.Common.Time")
local Switch = require("Core.Common.Switch")
local LoggerLazyLoad = {}

function LoggerLazyLoad:init(player)
	if not Switch.LazyLoadDebug then
		return
	end

	self[player.id] = {}
	self[player.id].initTime = Time.getRealMillisecond()
end

function LoggerLazyLoad:start(player)
	if not Switch.LazyLoadDebug then
		return
	end

	self[player.id].startTime = Time.getRealMillisecond()

	local time = self[player.id].startTime - self[player.id].initTime

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("player init to start, cost time", time, player:repr())
	end
end

function LoggerLazyLoad:loadStart(player)
	if not Switch.LazyLoadDebug then
		return
	end

	if not self[player.id] then
		self[player.id] = {}
	end

	self[player.id].loadStartTime = Time.getRealMillisecond()
end

function LoggerLazyLoad:loadEnd(player, className, dict, funcName)
	if not Switch.LazyLoadDebug then
		return
	end

	self[player.id].loadEndTime = Time.getRealMillisecond()

	local time = self[player.id].loadEndTime - self[player.id].loadStartTime

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("%s %s unpack %s, cost time %d, \n%s, \n%s;", player:repr(), funcName, className, time, inspect(dict), debug.traceback())
	end
end

return LoggerLazyLoad
