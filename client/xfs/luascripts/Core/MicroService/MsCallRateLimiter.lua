-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\MicroService\\MsCallRateLimiter.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Time = require("Core.Common.Time")
local ClientSwitch = require("Common.ClientSwitch")
local logger = LoggerManager.getLogger("MsCallRateLimiter")
local MsCallRateLimiter = {}
local RATE_LIMITED_ERRMSG = "client ms call rate limited"
local availableTokens
local lastRefillMs = 0
local activeWindowMs, activeMaxCount, activeBurstCapacity

local function resetBucket()
	availableTokens = nil
	lastRefillMs = 0
	activeWindowMs = nil
	activeMaxCount = nil
	activeBurstCapacity = nil
end

local function getLimitConfig()
	if not ClientSwitch.ClientMsCallRateLimitEnable then
		return false
	end

	local windowMs = tonumber(ClientSwitch.ClientMsCallRateLimitWindowMs) or 1000
	local maxCount = tonumber(ClientSwitch.ClientMsCallRateLimitMaxCount) or 20
	local burstCapacity = tonumber(ClientSwitch.ClientMsCallRateLimitBurstCapacity) or maxCount

	if windowMs <= 0 or maxCount <= 0 or burstCapacity <= 0 then
		return false
	end

	return true, windowMs, maxCount, burstCapacity
end

local function refillTokens(nowMs, windowMs, maxCount, burstCapacity)
	local configChanged = activeWindowMs ~= windowMs or activeMaxCount ~= maxCount or activeBurstCapacity ~= burstCapacity

	if availableTokens == nil or configChanged or nowMs < lastRefillMs then
		availableTokens = burstCapacity
	else
		local elapsedMs = nowMs - lastRefillMs

		if elapsedMs > 0 then
			availableTokens = math.min(burstCapacity, availableTokens + elapsedMs * maxCount / windowMs)
		end
	end

	lastRefillMs = nowMs
	activeWindowMs = windowMs
	activeMaxCount = maxCount
	activeBurstCapacity = burstCapacity
end

function MsCallRateLimiter.tryAcquire(serviceName, methodName, options)
	local enabled, windowMs, maxCount, burstCapacity = getLimitConfig()

	if not enabled then
		resetBucket()

		return true
	end

	local nowMs = Time.getTickSecond() * 1000

	refillTokens(nowMs, windowMs, maxCount, burstCapacity)

	if availableTokens < 1 then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("%s: %s.%s available=%.2f rate=%s/%sms burst=%s hint=%s callerId=%s\n%s", RATE_LIMITED_ERRMSG, serviceName, methodName, availableTokens, maxCount, windowMs, burstCapacity, options and options.hint or nil, options and options.callerId or nil, debug.traceback("", 3))
		end

		return false, {
			status = false,
			errmsg = RATE_LIMITED_ERRMSG
		}
	end

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:debug("call rate limit pass: %s.%s", serviceName, methodName)
	end

	availableTokens = availableTokens - 1

	return true
end

return MsCallRateLimiter
