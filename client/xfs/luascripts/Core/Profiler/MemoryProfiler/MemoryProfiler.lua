-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Profiler\\MemoryProfiler\\MemoryProfiler.lua

local LoggerConst = require("Core.Log.LoggerConst")
local LoggerManager = require("Core.Log.LoggerManager")
local MemoryUsage = require("Core.Profiler.MemoryProfiler.MemoryUsage")
local helper = require("Core.Profiler.MemoryProfiler.MemoryProfileHelper")
local MemoryProfiler = {
	profileTime = 0,
	logger = LoggerManager.getLogger("MemRef"),
	visitedObj = {},
	waitingObj = {},
	instanceInfo = {}
}

function MemoryProfiler:clearInfo()
	self.visitedObj = {}
	self.instanceInfo = {}
	self.waitingObj = {}
end

function MemoryProfiler:collectFunc(path, obj)
	local funcInfo = debug.getinfo(obj, "u")

	for i = 1, funcInfo.nups do
		local upName, upValue = debug.getupvalue(obj, i)

		table.insert(self.waitingObj, {
			helper:getNextValuePath(path, upName, upValue),
			upValue
		})
	end
end

function MemoryProfiler:collectTable(path, obj)
	local key, value

	while next(obj, key) do
		key = next(obj, key)
		value = obj[key]

		table.insert(self.waitingObj, {
			helper:getNextValuePath(path, key, value),
			value
		})
	end
end

function MemoryProfiler:visitObj(path, obj)
	if not helper:needVisitObj(path, obj) then
		return
	end

	if helper:isInstance(obj) then
		if self.instanceInfo[obj] == nil then
			self.instanceInfo[obj] = {}
		end

		table.insert(self.instanceInfo[obj], path)
	end

	if obj == nil or self.visitedObj[obj] then
		return
	end

	self.visitedObj[obj] = true

	if type(obj) == "table" then
		self:collectTable(path, obj)
	elseif type(obj) == "function" then
		self:collectFunc(path, obj)
	end
end

function MemoryProfiler:dumpInstanceMem(rootPath, rootObject)
	self.profileTime = self.profileTime + 1

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("dumpInstanceMem: %d", self.profileTime)
	end

	collectgarbage("collect")

	rootPath = rootPath or "register"
	rootObject = rootObject or debug.getregistry()

	table.insert(self.waitingObj, {
		rootPath,
		rootObject
	})

	while next(self.waitingObj) do
		local visitInfo = self.waitingObj[1]

		self:visitObj(visitInfo[1], visitInfo[2])
		table.remove(self.waitingObj, 1)
	end

	helper:outputRefInfo(self.instanceInfo, self.profileTime)
	self:clearInfo()
end

return MemoryProfiler
