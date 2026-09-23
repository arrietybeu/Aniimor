-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Common\\inspect.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("inpsect")
local AccessControl = require("Core.Framework.AccessControl")
local inspect = {}

inspect.KEY = setmetatable({}, {
	__tostring = function()
		return "inspect.KEY"
	end
})
inspect.METATABLE = setmetatable({}, {
	__tostring = function()
		return "inspect.METATABLE"
	end
})
inspect.nonAscIIReg = "[^\x01-\x7F]"

local function rawlen(t)
	return #t
end

local function smartQuote(str)
	if str:match("\"") and not str:match("'") then
		return "'" .. str .. "'"
	end

	return "\"" .. str:gsub("\"", "\\\"") .. "\""
end

local controlCharsTranslation = {
	["\r"] = "\\r",
	["\f"] = "\\f",
	["\n"] = "\\n",
	["\v"] = "\\v",
	["\b"] = "\\b",
	["\t"] = "\\t",
	["\a"] = "\\a"
}

local function escape(str)
	local result = str:gsub("\\", "\\\\"):gsub("(%c)", controlCharsTranslation)

	return result
end

local function changeNoASCII(str)
	local result = str:gsub("\\", "\\\\")

	return result
end

local function isIdentifier(str)
	return type(str) == "string" and str:match("^[_%a][_%a%d]*$")
end

local function isSequenceKey(k, length)
	return type(k) == "number" and k >= 1 and k <= length and math.floor(k) == k
end

local defaultTypeOrders = {
	["function"] = 5,
	boolean = 2,
	string = 3,
	number = 1,
	table = 4,
	userdata = 6,
	thread = 7
}

local function sortKeys(a, b)
	local ta, tb = type(a), type(b)

	if ta == tb and (ta == "string" or ta == "number") then
		return a < b
	end

	local dta, dtb = defaultTypeOrders[ta], defaultTypeOrders[tb]

	if dta and dtb then
		return defaultTypeOrders[ta] < defaultTypeOrders[tb]
	elseif dta then
		return true
	elseif dtb then
		return false
	end

	return ta < tb
end

local function getNonSequentialKeys(t)
	local keys, length = {}, rawlen(t)

	for k, _ in pairs(t) do
		if not isSequenceKey(k, length) then
			table.insert(keys, k)
		end
	end

	table.sort(keys, sortKeys)

	return keys
end

local function getToStringResultSafely(t, mt)
	local __tostring = type(mt) == "table" and rawget(mt, "__tostring")
	local str, ok

	if type(__tostring) == "function" then
		ok, str = pcall(__tostring, t)
		str = ok and str or "error: " .. tostring(str)
	end

	if type(str) == "string" and #str > 0 then
		return str
	end
end

local maxIdsMetaTable = {
	__index = function(self, typeName)
		rawset(self, typeName, 0)

		return 0
	end
}
local idsMetaTable = {
	__index = function(self, typeName)
		local col = {}

		rawset(self, typeName, col)

		return col
	end
}

local function countTableAppearances(t, tableAppearances, depth, maxdepth)
	if type(t) == "table" and rawget(t, "__index") == _G then
		return tableAppearances
	end

	tableAppearances = tableAppearances or {}

	if maxdepth < depth then
		return tableAppearances
	end

	if type(t) == "table" then
		if not tableAppearances[t] then
			tableAppearances[t] = 1

			for k, v in pairs(t) do
				countTableAppearances(k, tableAppearances, depth + 1, maxdepth)
				countTableAppearances(v, tableAppearances, depth + 1, maxdepth)
			end

			countTableAppearances(getmetatable(t), tableAppearances, depth + 1, maxdepth)
		else
			tableAppearances[t] = tableAppearances[t] + 1
		end
	end

	return tableAppearances
end

local function copySequence(s)
	local copy, len = {}, #s

	for i = 1, len do
		copy[i] = s[i]
	end

	return copy, len
end

local function makePath(path, ...)
	local newPath, len = copySequence(path)
	local nargs = select("#", ...)

	for i = 1, nargs do
		newPath[len + i] = select(i, ...)
	end

	return newPath
end

local function processRecursive(process, item, path)
	if item == nil then
		return nil
	end

	local processed = process(item, path)

	if type(processed) == "table" then
		local processedCopy = {}
		local processedKey

		for k, v in pairs(processed) do
			processedKey = processRecursive(process, k, makePath(path, k, inspect.KEY))

			if processedKey ~= nil then
				processedCopy[processedKey] = processRecursive(process, v, makePath(path, processedKey))
			end
		end

		local mt = processRecursive(process, getmetatable(processed), makePath(path, inspect.METATABLE))

		setmetatable(processedCopy, mt)

		processed = processedCopy
	end

	return processed
end

local Inspector = {}
local Inspector_mt = {
	__index = Inspector
}

function Inspector:puts(...)
	local buffer = self.buffer
	local len = #buffer
	local nargs = select("#", ...)

	for i = 1, nargs do
		len = len + 1
		buffer[len] = tostring(select(i, ...))
	end
end

function Inspector:down(toStringResult, length, nonSequentialKeys, t, mt)
	self.level = self.level + 1

	if toStringResult then
		self:puts(" -- ", escape(toStringResult))

		if length >= 1 then
			self:tabify()
		end
	end

	local count = 0

	for i = 1, length do
		if count > 0 then
			self:puts(",")
		end

		self:puts(" ")
		self:putValue(t[i])

		count = count + 1
	end

	for _, k in ipairs(nonSequentialKeys) do
		if count > 0 then
			self:puts(",")
		end

		self:tabify()
		self:putKey(k)
		self:puts(" = ")
		self:putValue(t[k])

		count = count + 1
	end

	if mt and mt.__index ~= _G and not mt.banInspect and not self.nometa then
		if count > 0 then
			self:puts(",")
		end

		self:tabify()
		self:puts("<metatable> = ")
		self:putValue(mt)
	end

	self.level = self.level - 1
end

function Inspector:tabify()
	self:puts(self.newline, string.rep(self.indent, self.level))
end

function Inspector:alreadyVisited(v)
	return self.ids[type(v)][v] ~= nil
end

function Inspector:getId(v)
	local tv = type(v)
	local id = self.ids[tv][v]

	if not id then
		id = self.maxIds[tv] + 1
		self.maxIds[tv] = id
		self.ids[tv][v] = id
	end

	return id
end

function Inspector:putKey(k)
	if isIdentifier(k) then
		return self:puts(k)
	end

	self:puts("[")
	self:putValue(k)
	self:puts("]")
end

function Inspector:putTable(t)
	if t == inspect.KEY or t == inspect.METATABLE then
		self:puts(tostring(t))
	elseif self:alreadyVisited(t) then
		self:puts("<table ", self:getId(t), ">")
	elseif self.level >= self.depth then
		self:puts("{...}")
	else
		if (self.tableAppearances[t] or 0) > 1 then
			self:puts("<", self:getId(t), ">")
		end

		local nonSequentialKeys = getNonSequentialKeys(t)
		local length = rawlen(t)
		local mt = getmetatable(t)
		local toStringResult = getToStringResultSafely(t, mt)

		self:puts("{")
		self:down(toStringResult, length, nonSequentialKeys, t, mt)

		if #nonSequentialKeys > 0 or mt then
			self:tabify()
		elseif length > 0 then
			self:puts(" ")
		end

		self:puts("}")
	end
end

local function replaceNoAscII(v)
	local result = string.gsub(v, inspect.nonAscIIReg, "*")

	return result
end

function Inspector:putValue(v)
	local tv = type(v)

	if tv == "string" then
		if self.replace then
			self:puts(replaceNoAscII(smartQuote(escape(v))))
		else
			self:puts(smartQuote(escape(v)))
		end
	elseif tv == "boolean" or tv == "nil" then
		self:puts(tostring(v))
	elseif tv == "number" then
		self:puts(string.format("%.16g", v))
	elseif tv == "table" then
		self:putTable(v)
	elseif tv == "userdata" then
		self:puts("<", tostring(v), " ", self:getId(v), ">")
	else
		self:puts("<", tv, " ", self:getId(v), ">")
	end
end

local function _inspect(root, options, ignoreDebugEnv)
	if not _G_IsDebugMode and not ignoreDebugEnv then
		return root
	end

	options = options or {}

	local metatable = getmetatable(root)

	if metatable and root._AccessControl_ then
		root = AccessControl:getRawTable(root)
	elseif metatable and root._BddData_ then
		root = bdd2DeepTable(root)
	end

	local depth = options.depth or 3
	local newline = options.newline or os.getenv("OS") == "Windows_NT" and "\n" or " "
	local indent = options.indent or "  "
	local maxlen = options.maxlen or 1000
	local nometa = options.nometa
	local process = options.process
	local replace = not options.noReplace

	if process then
		root = processRecursive(process, root, {})
	end

	local inspector = setmetatable({
		level = 0,
		depth = depth,
		buffer = {},
		ids = setmetatable({}, idsMetaTable),
		maxIds = setmetatable({}, maxIdsMetaTable),
		newline = newline,
		indent = indent,
		replace = replace,
		maxlen = maxlen,
		nometa = nometa,
		tableAppearances = countTableAppearances(root, {}, 1, depth)
	}, Inspector_mt)

	inspector:putValue(root)

	if _G_IsDebugMode or ignoreDebugEnv then
		local result = table.concat(inspector.buffer)

		return result
	else
		return table.concat(inspector.buffer)
	end
end

setmetatable(inspect, {
	__call = function(_, ...)
		return _inspect(...)
	end
})

return inspect
