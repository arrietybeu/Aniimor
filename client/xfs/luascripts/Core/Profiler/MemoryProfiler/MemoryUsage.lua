-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Profiler\\MemoryProfiler\\MemoryUsage.lua

local LoggerManager = require("Core.Log.LoggerManager")
local memprofile = require("memprofile")
local helper = require("Core.Profiler.MemoryProfiler.MemoryProfileHelper")
local MemoryUsage = {
	maxDeep = 10,
	totalByte = 0,
	countKV = false,
	logger = LoggerManager.getLogger("MemUsage"),
	visitedObj = {}
}

function MemoryUsage:clear()
	self.visitedObj = {}
	self.totalByte = 0
end

function MemoryUsage:instanceMemUsage(instance)
	self:clear()

	local objInfo = self:objMemUsage(instance:getClassType(), instance)

	return self:outputMemInfo(objInfo)
end

function MemoryUsage:objMemUsage(path, obj)
	if not helper:needVisitObj(path, obj) then
		return nil
	end

	if self.visitedObj[obj] ~= nil then
		return self.visitedObj[obj]
	end

	self.visitedObj[obj] = {
		size = 0,
		detail = {}
	}

	if type(obj) == "table" then
		self.visitedObj[obj] = self:tabMemUsage(path, obj)
	else
		self.visitedObj[obj].size = memprofile.getObjSize(obj)
		self.totalByte = self.totalByte + self.visitedObj[obj].size
	end

	return self.visitedObj[obj]
end

function MemoryUsage:tabMemUsage(path, obj)
	local tabInfo = {
		size = memprofile.getObjSize(obj),
		detail = {}
	}

	self.totalByte = self.totalByte + tabInfo.size

	local key, value

	while next(obj, key) do
		key = next(obj, key)
		value = obj[key]

		local keyInfo, valueInfo

		keyInfo = self:objMemUsage(helper:getNextPath(path, key), key)
		valueInfo = self:objMemUsage(helper:getNextPath(path, value), value)

		if self.countKV then
			self:countTableKV(tabInfo, keyInfo, valueInfo)
		end

		table.insert(tabInfo.detail, {
			helper:getKeyType(key),
			helper:getValueType(value),
			keyInfo,
			valueInfo
		})
	end

	return tabInfo
end

function MemoryUsage:countTableKV(tabInfo, keyInfo, valueInfo)
	if keyInfo ~= nil then
		tabInfo.size = tabInfo.size + keyInfo.size
	end

	if valueInfo ~= nil then
		tabInfo.size = tabInfo.size + valueInfo.size
	end
end

function MemoryUsage:outputMemInfo(objInfo)
	if objInfo == nil then
		return
	end

	local deep = 1
	local outputStr = ""

	outputStr = outputStr .. helper:preSpaceStr(deep, string.format("memory(%d): [\n", objInfo.size))

	for _, info in ipairs(objInfo.detail) do
		outputStr = outputStr .. self:getMemInfoStr(deep + 1, info)
	end

	outputStr = outputStr .. helper:preSpaceStr(deep, "]\n")
	outputStr = outputStr .. helper:preSpaceStr(deep, string.format("totalByte: %d\n", self.totalByte))

	return outputStr
end

function MemoryUsage:getMemInfoStr(deep, info)
	if type(info[4]) ~= "table" then
		return helper:preSpaceStr(deep, string.format("%s(%s): %s(nil)\n", info[1], tostring(info[3].size), info[2]))
	else
		return helper:preSpaceStr(deep, string.format("%s(%s): %s(%s)\n%s", info[1], tostring(info[3].size), info[2], info[4].size, self:getDetailStr(deep, info[4])))
	end
end

function MemoryUsage:getDetailStr(deep, objInfo)
	if deep >= self.maxDeep then
		return ""
	end

	local detailStr = ""

	for _, info in ipairs(objInfo.detail) do
		detailStr = detailStr .. self:getMemInfoStr(deep + 1, info)
	end

	if detailStr ~= "" then
		detailStr = helper:preSpaceStr(deep, "{\n") .. detailStr .. helper:preSpaceStr(deep, "}\n")
	end

	return detailStr
end

return MemoryUsage
