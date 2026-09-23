-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Common\\Time.lua

local phonestcore = require("phonestcore")
local Time = {}

Time.serverDelta = 0

function Time.getTickSecond()
	return phonestcore.getMillisecond() * 0.001
end

function Time.getMillisecond()
	return Time.getMillisecondUTC()
end

function Time.getSecond()
	return Time.getSecondUTC()
end

function Time.getMinute()
	return Time.getSecondUTC() / 60
end

function Time.getMillisecondUTC()
	return phonestcore.getMillisecondUTC() + Time.serverDelta
end

function Time.getSecondUTC()
	return (phonestcore.getMillisecondUTC() + Time.serverDelta) * 0.001
end

function Time.setServerDelta(delta)
	Time.serverDelta = delta
end

function Time.getServerDelta()
	return Time.serverDelta
end

function Time.getCurrentFrameCount()
	return Time.frameCount
end

function Time.getMicrosecond()
	return phonestcore.getMicrosecond()
end

function Time.getNanosecond()
	return Time.getNanosecondUTC()
end

function Time.getNanosecondUTC()
	return phonestcore.getNanosecondUTC()
end

function Time.getRealSecond()
	return phonestcore.getMillisecondUTC() * 0.001
end

function Time.getRealMillisecond()
	return phonestcore.getMillisecondUTC()
end

Time.millisecondCache = Time.getMillisecondUTC()
Time.secondCache = Time.millisecondCache * 0.001
Time.realSecondCache = Time.getTickSecond()
Time.deltaTime = 0
Time.unscaledDeltaTime = 0
Time.time = 0
Time.unscaledTime = 0
Time.realtimeSinceStartup = 0
Time.frameCount = 0
Time.unityFrameCount = 0
Time.timeScale = 1
Time.luaFrameCount = 0

return Time
