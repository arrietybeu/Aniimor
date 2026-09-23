-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Common\\CallbackHandlerNoGC.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("CallbackHandlerNoGC")
local TablePool = require("Common.Container.TablePool")
local table = table
local select = select
local unpack = unpack
local type = type
local math_min = math.min
local setmetatable = setmetatable
local CallbackHandlerNoGC = {
	_cache = {},
	_csharpCache = {},
	_autoDisposeCache = {}
}
local cache = CallbackHandlerNoGC._cache
local autoDisposeCache = CallbackHandlerNoGC._autoDisposeCache
local csharpCache = CallbackHandlerNoGC._csharpCache
local poolMaxCount = {
	2048,
	256
}
local AutoDisposeStatePending = 1
local AutoDisposeStateQueued = 2
local autoDisposeHead = 1
local autoDisposeTail = 0
local autoDisposeCount = 0

function CallbackHandlerNoGC.new(obj, method, ...)
	local cb

	if #cache > 0 then
		cb = table.remove(cache)
	else
		cb = CallbackHandlerNoGC._innerNew()
	end

	cb:_innerInit(obj, method, ...)

	return cb
end

function CallbackHandlerNoGC.newOnceCSharpCb(obj, method, ...)
	local cb

	if #csharpCache > 0 then
		cb = table.remove(csharpCache)
	else
		cb = CallbackHandlerNoGC._innerNew()
	end

	cb:_innerInit(obj, method, ...)
	cb:_setAutoDispose()

	return cb:_getCSharpCallback()
end

function CallbackHandlerNoGC.newOnce(obj, method, ...)
	local cb = CallbackHandlerNoGC.new(obj, method, ...)

	cb:_setAutoDispose()

	return cb
end

function CallbackHandlerNoGC.checkAutoDisposeCache(clearNum)
	clearNum = math_min(clearNum or autoDisposeCount, autoDisposeCount)

	if clearNum <= 0 then
		return
	end

	for _ = 1, clearNum do
		autoDisposeCache[autoDisposeHead]:_innerDispose()

		autoDisposeCache[autoDisposeHead] = nil
		autoDisposeHead = autoDisposeHead + 1
		autoDisposeCount = autoDisposeCount - 1
	end

	if autoDisposeCount == 0 then
		autoDisposeHead = 1
		autoDisposeTail = 0
	elseif autoDisposeHead - 1 > autoDisposeCount then
		for index = 1, autoDisposeCount do
			autoDisposeCache[index] = autoDisposeCache[autoDisposeHead + index - 1]
		end

		for index = autoDisposeCount + 1, autoDisposeTail do
			autoDisposeCache[index] = nil
		end

		autoDisposeHead = 1
		autoDisposeTail = autoDisposeCount
	end
end

function CallbackHandlerNoGC.printCacheInfo()
	if LoggerManager.checkLogger(LoggerConst.INFO, "Pool") then
		logger:info("[CallbackHandlerNoGC Cache] reusableLua=%d reusableCSharp=%d dirty=%d capacity=%d/%d", #cache, #csharpCache, autoDisposeCount, poolMaxCount[1], poolMaxCount[2])
	end
end

function CallbackHandlerNoGC:getFunction()
	return self:_getCSharpCallback()
end

function CallbackHandlerNoGC:dispose()
	if self._autoDispose ~= nil then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			logger:debug("CallbackHandlerNoGC newOnce 不需要手动dispose")
		end

		return
	end

	self:_innerDispose()
end

function CallbackHandlerNoGC:_innerDispose()
	if self._isInPool then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			logger:debug("CallbackHandlerNoGC has disposed,dispose twice")
		end

		return
	end

	if self.args then
		TablePool.returnTable(self.args, 3)

		self.args = nil
	end

	self.n0 = nil
	self.obj = nil
	self.method = nil
	self._isInPool = true
	self._autoDispose = nil

	if self.csharpCallback then
		if #csharpCache < poolMaxCount[2] then
			csharpCache[#csharpCache + 1] = self
		end
	elseif #cache < poolMaxCount[1] then
		cache[#cache + 1] = self
	end
end

function CallbackHandlerNoGC:_innerInit(obj, method, ...)
	self.obj = obj
	self.method = method
	self.args = nil
	self.n0 = select("#", ...)

	if self.n0 ~= 0 then
		self.args = TablePool.getTable(3)

		for i = 1, self.n0 do
			self.args[i] = select(i, ...)
		end
	end

	self._isInPool = false
	self._autoDispose = nil
end

function CallbackHandlerNoGC:_innerCall(...)
	if self._isInPool then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("CallbackHandlerNoGC has disposed,cannot be called")
		end

		return
	end

	if self._autoDispose == AutoDisposeStateQueued then
		return
	end

	if self._autoDispose == AutoDisposeStatePending then
		self._autoDispose = AutoDisposeStateQueued
		autoDisposeTail = autoDisposeTail + 1
		autoDisposeCache[autoDisposeTail] = self
		autoDisposeCount = autoDisposeCount + 1
	end

	if self.obj ~= nil then
		local method = self.method

		if type(self.method) == "string" then
			method = self.obj[self.method]
		end

		if type(method) == "function" then
			if method ~= nil then
				local n1 = select("#", ...)

				if self.n0 + n1 == 0 then
					return method(self.obj)
				elseif self.n0 == 0 then
					return method(self.obj, ...)
				elseif n1 == 0 then
					return method(self.obj, unpack(self.args, 1, self.n0))
				else
					for i = 1, n1 do
						self.args[i + self.n0] = select(i, ...)
					end

					return method(self.obj, unpack(self.args, 1, self.n0 + n1))
				end
			end
		elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("CallbackHandlerNoGC 的method不是一个Function")
		end
	end
end

function CallbackHandlerNoGC:_setAutoDispose()
	self._autoDispose = AutoDisposeStatePending
end

function CallbackHandlerNoGC:_getCSharpCallback()
	if self.csharpCallback == nil then
		function self.csharpCallback(...)
			return self:_innerCall(...)
		end
	end

	return self.csharpCallback
end

local cls = {
	__call = function(self, ...)
		return self:_innerCall(...)
	end,
	__index = CallbackHandlerNoGC
}

function CallbackHandlerNoGC._innerNew()
	local instance = {}

	setmetatable(instance, cls)

	return instance
end

return CallbackHandlerNoGC
