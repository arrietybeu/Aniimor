-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Profiler\\MemoryProfiler\\MemoryProfileHelper.lua

local LoggerManager = require("Core.Log.LoggerManager")
local Helper = {
	separator = ".",
	logger = LoggerManager.getLogger("MemHelper")
}

function Helper:isClass(obj)
	if type(obj) ~= "table" then
		return false
	end

	if rawget(obj, "__IsClass") or rawget(obj, "__IsComponent") then
		return true
	end

	return false
end

function Helper:isInstance(obj)
	if type(obj) ~= "table" then
		return false
	end

	if rawget(obj, "__IsInstance") then
		return true
	end

	return false
end

function Helper:isReadable(str)
	if string.len(str) == 12 then
		for i = 1, #str do
			local c = string.byte(str:sub(i, i))

			if c <= 32 or c >= 126 then
				return false
			end
		end
	end

	return true
end

function Helper:isSpecificModule(obj)
	if obj == self then
		return true
	end

	local class = require("Core.Framework.Class")

	if obj == class then
		return true
	end

	local memProfier = require("Core.Profiler.MemoryProfiler.MemoryProfiler")

	if obj == memProfier then
		return true
	end

	local memoryUsage = require("Core.Profiler.MemoryProfiler.MemoryUsage")

	if obj == memoryUsage then
		return true
	end

	local GameServerRepo = require("Core.Server.GameServerRepo")

	if obj == GameServerRepo.globalMsProxy then
		return true
	end

	if self:isInstance(obj) and (obj:getClassType() == "GateProxy" or obj:getClassType() == "ClientProxy") then
		return true
	end

	return false
end

function Helper:getNextValuePath(path, key, value)
	if type(value) == "function" then
		local funcInfo = debug.getinfo(value, "S")
		local fileName = funcInfo.short_src

		for word in string.gmatch(funcInfo.short_src, "(%a*).lua") do
			fileName = word
		end

		return path .. self.separator .. string.format("%s(line:%s)", fileName, funcInfo.linedefined)
	end

	if type(key) == "string" then
		if self:isReadable(key) then
			return path .. self.separator .. key
		elseif self:isInstance(value) then
			return path .. self.separator .. value:getClassType()
		else
			return path .. self.separator .. key
		end
	end

	if self:isInstance(key) then
		return path .. self.separator .. key:getClassType()
	end

	if self:isClass(key) then
		return path .. self.separator .. key.typeName
	end

	return path .. self.separator .. tostring(key)
end

function Helper:getNextPath(path, key)
	if type(key) == "table" and self:isInstance(key) then
		return path .. self.separator .. key:getClassType()
	end

	if type(key) == "table" and self:isClass(key) then
		return path .. self.separator .. key.typeName
	end

	return path .. self.separator .. tostring(key)
end

function Helper:getKeyType(key)
	if type(key) == "table" and self:isInstance(key) then
		return key:getClassType()
	end

	if type(key) ~= "string" then
		return type(key)
	end

	return key
end

function Helper:getValueType(value)
	if type(value) == "table" and self:isInstance(value) then
		return value:getClassType()
	end

	return type(value)
end

function Helper:needVisitObj(path, obj)
	if self:isClass(obj) then
		return false
	end

	if self:isSpecificModule(obj) then
		return false
	end

	return true
end

function Helper:preSpaceStr(deep, str)
	local preSpace = "\t"

	for idx = 1, deep - 1 do
		preSpace = preSpace .. "\t"
	end

	return string.format("%s %s", preSpace, str)
end

function Helper:outputRefInfo(instanceInfo, profileTime)
	local file = io.open(string.format("info-%s.log", profileTime), "w")

	for obj, paths in pairs(instanceInfo) do
		if obj:getClassType() == "Avatar" then
			local outputStr = self:getInstanceInfo(obj, paths)

			file:write(outputStr)
		end
	end

	file:close()
end

function Helper:getInstanceInfo(obj, paths)
	local MemoryUsage = require("Core.Profiler.MemoryProfiler.MemoryUsage")
	local outputStr = "{\n"

	outputStr = outputStr .. string.format("\t instance:\t %s\n", obj:getClassType())
	outputStr = outputStr .. string.format("\t identifer:\t %s\n", tostring(obj))
	outputStr = outputStr .. MemoryUsage:instanceMemUsage(obj)
	outputStr = outputStr .. "\t path: [\n"

	for _, path in ipairs(paths) do
		outputStr = outputStr .. string.format("\t\t %s \n", path)
	end

	outputStr = outputStr .. "\t ]\n"
	outputStr = outputStr .. "}\n\n"

	return outputStr
end

return Helper
