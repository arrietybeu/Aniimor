-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Functions.lua

local globalDeclare = require("Core.Framework.Global")
local Class = require("Core.Framework.Class")
local Functions = Class.LightClass("Functions")
local zlib = require("zlib")
local base64 = require("base64")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("Functions")
local AccessControl = require("Core.Framework.AccessControl")
local RAW_DATA_MAP = AccessControl.RawDataMap
local sub = string.sub
local find = string.find
local type = type
local pairs = pairs
local ipairs = ipairs

function Functions.init()
	globalDeclare("traceback")

	function traceback(msg)
		msg = debug.traceback(msg, 2)

		return msg
	end

	globalDeclare("raw_unpack")

	raw_unpack = raw_unpack or unpack

	function unpack(t, ...)
		if _G_IsDebugMode and select("#", ...) == 0 then
			local len = 0

			for k, v in pairs(t) do
				if type(k) == "number" then
					len = len + 1
				else
					ALARM("[error] unpack invalid key type, k=%s, type=%s", tostring(k), type(k))
				end
			end

			for i = 1, len do
				if t[i] == nil then
					ALARM("[error] unpack has nil value, i=%d", i)
				end
			end
		end

		if t._BddData_ then
			return bddunpack(t, ...)
		elseif type(t) == "userdata" then
			local metatable = getmetatable(t)

			if metatable and metatable._BddData_ then
				return bddunpack(t, ...)
			end
		end

		t = t._AccessControl_ and RAW_DATA_MAP[t] or t

		return raw_unpack(t, ...)
	end

	globalDeclare("raw_next")

	raw_next = raw_next or next

	local raw_next = raw_next

	function next(table, index)
		if table._AccessControl_ then
			table = RAW_DATA_MAP[table] or table
		elseif table._BddData_ then
			local metatable = getmetatable(table)

			return metatable.__next(table, index)
		elseif type(table) == "userdata" then
			local metatable = getmetatable(table)

			if metatable and metatable.__next then
				return metatable.__next(table, index)
			end
		end

		return raw_next(table, index)
	end

	globalDeclare("raw_rawset")

	raw_rawset = raw_rawset or rawset

	function rawset(obj, key, val)
		if type(obj) == "userdata" then
			obj:setCustomValue(key, val)
		else
			raw_rawset(obj, key, val)
		end
	end

	local function rawset_userdata(obj, key, val)
		obj:setCustomValue(key, val)
	end

	globalDeclare("getRawSetter")

	function getRawSetter(obj)
		if type(obj) == "userdata" then
			return rawset_userdata
		end

		return raw_rawset
	end

	globalDeclare("gLen")

	function gLen(table)
		return #table
	end

	globalDeclare("RemoveTableItem")

	function RemoveTableItem(list, item, removeAll)
		local rmCount = 0

		for i = 1, #list do
			if list[i - rmCount] == item then
				table.remove(list, i - rmCount)

				if removeAll then
					rmCount = rmCount + 1
				else
					break
				end
			end
		end
	end

	globalDeclare("RemoveTableItemNoOrder")

	function RemoveTableItemNoOrder(list, item, removeAll)
		local rmCount = 0
		local length = #list

		for i = length, 1, -1 do
			if list[i] == item then
				list[i] = list[length - rmCount]
				list[length - rmCount] = nil

				if removeAll then
					rmCount = rmCount + 1
				else
					break
				end
			end
		end
	end

	globalDeclare("RemoveTableByFunc")

	function RemoveTableByFunc(list, func)
		local count = list and #list or 0

		for i = count, 1, -1 do
			if func(list[i]) then
				table.remove(list, i)
			end
		end
	end

	globalDeclare("RemoveTableByFuncNoOrder")

	function RemoveTableByFuncNoOrder(list, func)
		local count = #list

		for i = count, 1, -1 do
			if func(list[i]) then
				list[i] = list[count]
				list[count] = nil
				count = count - 1
			end
		end
	end

	function table.contains(table, element)
		if table == nil then
			return false
		end

		for _, value in pairs(table) do
			if value == element then
				return true
			end
		end

		return false
	end

	function table.removeAll(table)
		if table == nil then
			return
		end

		for k, v in pairs(table) do
			table[k] = nil
		end
	end

	function table:getCount()
		local count = 0

		for k, v in pairs(self) do
			count = count + 1
		end

		return count
	end

	function table.merge(dest, src)
		if not src then
			return
		end

		for k, v in pairs(src) do
			dest[k] = v
		end
	end

	function table.clear(t)
		if t == nil then
			return
		end

		for k in pairs(t) do
			t[k] = nil
		end
	end

	function table.clearArray(t)
		local count = #t

		for i = count, 1, -1 do
			t[i] = nil
		end
	end

	function table.mergeList(dest, src)
		for i, v in ipairs(src) do
			table.insert(dest, v)
		end
	end

	function table.nums(t)
		local count = 0

		for k, v in pairs(t) do
			count = count + 1
		end

		return count
	end

	function table.maxn(t)
		local max = 0

		for k, v in pairs(t) do
			if type(k) == "number" and max < k then
				max = k
			end
		end

		return max
	end

	function table.keys(hashtable)
		local keys = {}

		for k, v in pairs(hashtable) do
			keys[#keys + 1] = k
		end

		return keys
	end

	function table.values(hashtable)
		local values = {}

		for k, v in pairs(hashtable) do
			values[#values + 1] = v
		end

		return values
	end

	function table.equal(a, b)
		if a == nil then
			return b == nil
		end

		if b == nil then
			return false
		end

		if #a ~= #b then
			return false
		end

		for i = 1, #a do
			if a[i] ~= b[i] then
				return false
			end
		end

		return true
	end

	function table.isTableEqual(t1, t2)
		if t1 == t2 then
			return true
		end

		if type(t1) ~= "table" or type(t2) ~= "table" then
			return false
		end

		for k, v in pairs(t1) do
			if t2[k] == nil or not table.isTableEqual(v, t2[k]) then
				return false
			end
		end

		for k, v in pairs(t2) do
			if t1[k] == nil then
				return false
			end
		end

		return true
	end

	function table.isTableEqual(t1, t2)
		if t1 == t2 then
			return true
		end

		if type(t1) ~= "table" or type(t2) ~= "table" then
			return false
		end

		for k, v in pairs(t1) do
			if t2[k] == nil or not table.isTableEqual(v, t2[k]) then
				return false
			end
		end

		for k, v in pairs(t2) do
			if t1[k] == nil then
				return false
			end
		end

		return true
	end

	function table.isTableEqual2(t1, t2)
		if t1 == t2 then
			return true
		end

		if type(t1) == "number" or type(t2) == "number" then
			return math.abs(t1 - t2) < 1e-05
		end

		if type(t1) ~= "table" or type(t2) ~= "table" then
			return false
		end

		for k, v in pairs(t1) do
			if t2[k] == nil or not table.isTableEqual2(v, t2[k]) then
				return false
			end
		end

		for k, v in pairs(t2) do
			if t1[k] == nil then
				return false
			end
		end

		return true
	end

	function table.findDifferences(t1, t2, path)
		path = path or "root"

		for k, v in pairs(t1) do
			local currentPath = type(k) == "string" and path .. "." .. k or path .. "[" .. k .. "]"

			if t2[k] == nil then
				return false, (string.format("[缺失] path: %s (在 t2 中不存在)", currentPath))
			elseif type(v) ~= type(t2[k]) then
				return false, string.format("[类型冲突] path: %s (t1:%s, t2:%s)", currentPath, type(v), type(t2[k]))
			elseif type(v) == "table" then
				local result, reason = table.findDifferences(v, t2[k], currentPath)

				if not result then
					return false, reason
				end
			elseif v ~= t2[k] then
				return false, string.format("[值不一致] path: %s (t1:%s, t2:%s)", currentPath, tostring(v), tostring(t2[k]))
			end
		end

		for k, _ in pairs(t2) do
			if t1[k] == nil then
				local currentPath = type(k) == "string" and path .. "." .. k or path .. "[" .. k .. "]"

				return false, string.format("[冗余] path: %s (在 t1 中不存在)", currentPath)
			end
		end

		return true
	end

	function table.findDifferences2(t1, t2, path)
		path = path or "root"

		for k, v in pairs(t1) do
			local currentPath = type(k) == "string" and path .. "." .. k or path .. "[" .. k .. "]"

			if t2[k] == nil then
				return false, (string.format("[缺失] path: %s (在 t2 中不存在)", currentPath))
			elseif type(v) ~= type(t2[k]) then
				return false, string.format("[类型冲突] path: %s (t1:%s, t2:%s)", currentPath, type(v), type(t2[k]))
			elseif type(v) == "table" then
				local result, reason = table.findDifferences2(v, t2[k], currentPath)

				if not result then
					return false, reason
				end
			elseif type(v) == "number" then
				if math.abs(v - t2[k]) > 1e-05 then
					return false, string.format("[值不一致] number path: %s (t1:%s, t2:%s)", currentPath, tostring(v), tostring(t2[k]))
				end
			elseif v ~= t2[k] then
				return false, string.format("[值不一致] path: %s (t1:%s, t2:%s)", currentPath, tostring(v), tostring(t2[k]))
			end
		end

		for k, _ in pairs(t2) do
			if t1[k] == nil then
				local currentPath = type(k) == "string" and path .. "." .. k or path .. "[" .. k .. "]"

				return false, string.format("[冗余] path: %s (在 t1 中不存在)", currentPath)
			end
		end

		return true
	end

	function table.firstOrDefault(tbl)
		for k, v in pairs(tbl) do
			return k, v
		end

		return nil, nil
	end

	function table.val_to_str(v)
		if type(v) == "string" then
			v = string.gsub(v, "\n", "\\n")

			if string.match(string.gsub(v, "[^'\"]", ""), "^\"+$") then
				return "'" .. v .. "'"
			end

			return "\"" .. string.gsub(v, "\"", "\\\"") .. "\""
		else
			return type(v) == "table" and table.tostring(v) or tostring(v)
		end
	end

	function table.key_to_str(k)
		if type(k) == "string" and string.match(k, "^[_%a][_%a%d]*$") then
			return k
		else
			return "[" .. table.val_to_str(k) .. "]"
		end
	end

	function table.tostring(tbl)
		local result, done = {}, {}

		for k, v in ipairs(tbl) do
			table.insert(result, table.val_to_str(v))

			done[k] = true
		end

		for k, v in pairs(tbl) do
			if not done[k] then
				table.insert(result, table.key_to_str(k) .. "=" .. table.val_to_str(v))
			end
		end

		return "{" .. table.concat(result, ",") .. "}"
	end

	function table.safe_get(tbl, ...)
		local current = tbl
		local key_count = select("#", ...)

		for i = 1, key_count do
			if type(current) ~= "table" and type(current) ~= "userdata" then
				return nil
			end

			current = current[select(i, ...)]
		end

		return current
	end

	function string.split(str, delimiter)
		if delimiter == "" then
			return false
		end

		local pos = 0
		local arr = {}
		local index = 1

		while true do
			local st, sp = find(str, delimiter, pos, true)

			if not st then
				break
			end

			arr[index] = sub(str, pos, st - 1)
			index = index + 1
			pos = sp + 1
		end

		arr[index] = sub(str, pos)

		return arr
	end

	function string.trim(str)
		str = string.gsub(str, "^[ \t\n\r]+", "")

		return string.gsub(str, "[ \t\n\r]+$", "")
	end

	function string.utf8len(input)
		local len = string.len(input)
		local left = len
		local cnt = 0
		local arr = {
			0,
			192,
			224,
			240,
			248,
			252
		}

		while left ~= 0 do
			local tmp = string.byte(input, -left)
			local i = #arr

			while arr[i] do
				if tmp >= arr[i] then
					left = left - i

					break
				end

				i = i - 1
			end

			cnt = cnt + 1
		end

		return cnt
	end

	function string.strlen(str)
		local len = 0
		local i = 1
		local charByte

		while i <= #str do
			charByte = string.byte(str, i)

			if charByte > 127 then
				len = len + 2
				i = i + 3
			else
				len = len + 1
				i = i + 1
			end
		end

		return len
	end

	local function chsize(char)
		local arr = {
			0,
			192,
			224,
			240,
			248,
			252
		}

		if not char then
			return 0
		else
			for i = #arr, 1, -1 do
				if char >= arr[i] then
					return i
				end
			end
		end
	end

	function string.toList(str)
		local list = {}
		local currentIndex = 1

		while currentIndex <= #str do
			local char = string.byte(str, currentIndex)
			local cLen = chsize(char)

			list[#list + 1] = str:sub(currentIndex, currentIndex + cLen - 1)
			currentIndex = currentIndex + cLen
		end

		return list
	end

	function string.utf8sub(str, startChar, numChars)
		local startIndex = 1

		while startChar > 1 do
			local char = string.byte(str, startIndex)

			startIndex = startIndex + chsize(char)
			startChar = startChar - 1
		end

		local currentIndex = startIndex

		while numChars > 0 and currentIndex <= #str do
			local char = string.byte(str, currentIndex)

			currentIndex = currentIndex + chsize(char)
			numChars = numChars - 1
		end

		return str:sub(startIndex, currentIndex - 1)
	end

	function string.notNilOrEmpty(str)
		if EnableBotTest and type(str) ~= "string" then
			return false
		end

		local result = str and string.len(str) > 0

		return result == true
	end

	function string.isNilOrEmpty(str)
		return str == nil or str == ""
	end

	function string.startsWith(str, start)
		if str == nil or start == nil then
			return false
		end

		return str:sub(1, #start) == start
	end

	function string.endsWith(str, ending)
		if str == nil or ending == nil then
			return false
		end

		return ending == "" or str:sub(-#ending) == ending
	end

	function string.toTable(str)
		if str == nil or type(str) ~= "string" then
			return
		end

		return loadstring("return " .. str)()
	end

	globalDeclare("GetDir")

	function GetDir(path)
		return string.match(path, ".*/")
	end

	globalDeclare("GetFileName")

	function GetFileName(path)
		return string.match(path, ".*/(.*)")
	end

	globalDeclare("IsNil")

	function IsNil(uobj)
		return uobj == nil or type(uobj) == "userdata" and xlua.isNullObject(uobj)
	end

	globalDeclare("IsNilModel")

	function IsNilModel(uobj)
		return uobj == nil
	end

	globalDeclare("NotNil")

	function NotNil(uobj)
		return not IsNil(uobj)
	end

	globalDeclare("IsNullUserData")

	function IsNullUserData(data)
		if not data or data == pg.cjson.null or data == "" then
			return true
		end

		return false
	end

	globalDeclare("isnan")

	function isnan(number)
		return number ~= number
	end

	globalDeclare("isinf")

	function isinf(number)
		return number == math.huge or number == -math.huge
	end

	function math.safe_floor(value)
		return math.floor(value + 1e-10)
	end

	function math.safe_ceil(value)
		return math.ceil(value - 1e-10)
	end

	function math.clamp(val, lower, upper)
		assert(val and lower and upper, "any parameter is nil")

		if upper < lower then
			lower, upper = upper, lower
		end

		return math.max(lower, math.min(upper, val))
	end

	function math.round(value)
		return value >= 0 and math.floor(value + 0.5) or math.ceil(value - 0.5)
	end

	function math.fixedFloat(value)
		return math.round(value * 100) * 0.01
	end

	function math.isFloatMultipleOf(number, multipleOf, epsilon)
		epsilon = epsilon or 1e-06

		if multipleOf == 0 then
			return false, "除数不能为0"
		end

		local remainder = math.abs(number % multipleOf)

		return remainder <= epsilon or epsilon >= multipleOf - remainder
	end

	local _listNodeMT = debug.getregistry()["phonestcore.ListNode"]
	local boolFunMaps = {
		number = function(a)
			return a ~= 0
		end,
		string = function(a)
			return a ~= ""
		end,
		boolean = function(a)
			return a
		end,
		["nil"] = function(a)
			return false
		end,
		table = function(a)
			local Utils = require("Common.Utils.Utils")

			return not Utils.isEmptyTable(a)
		end,
		userdata = function(a)
			if getmetatable(a) == _listNodeMT then
				return #a > 0
			end

			return bddnext(a) ~= nil
		end
	}

	globalDeclare("ToBool")

	function ToBool(object)
		return boolFunMaps[type(object)](object)
	end

	local intFunMaps = {
		number = function(a)
			return math.floor(a)
		end,
		string = function(a)
			local num = tonumber(a)

			return num and math.floor(num) or 0
		end,
		boolean = function(a)
			return a and 1 or 0
		end,
		["nil"] = function(a)
			return 0
		end,
		table = function(a)
			return 0
		end,
		userdata = function(a)
			return 0
		end
	}

	globalDeclare("ToInt")

	function ToInt(object)
		return intFunMaps[type(object)](object)
	end

	globalDeclare("tableMulti")

	function tableMulti(table, multiplier)
		local ret = {}

		for k, v in pairs(table) do
			ret[k] = v * multiplier
		end

		return ret
	end

	globalDeclare("compress")

	function compress(input)
		local deflated = zlib.deflate()(input, "full")

		return deflated
	end

	globalDeclare("decompress")

	function decompress(input)
		local out = zlib.inflate()(input)

		return out
	end

	globalDeclare("compressToStr")

	function compressToStr(input)
		if type(input) ~= "string" then
			return EnableBotTest and "" or input
		end

		if string.isNilOrEmpty(input) then
			return input
		end

		return base64.encode(zlib.deflate()(input, "full"))
	end

	globalDeclare("decompressFromStr")

	function decompressFromStr(input)
		if type(input) ~= "string" then
			return EnableBotTest and "" or input
		end

		if string.isNilOrEmpty(input) then
			return input
		end

		return zlib.inflate()(base64.decode(input))
	end

	globalDeclare("ALARM")

	function ALARM(fmt, ...)
		fmt = string.format("[ALARM] %s \n%s", fmt, debug.traceback())

		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error(fmt, ...)
		end
	end

	globalDeclare("dealMsgParameters")

	function dealMsgParameters(tbl)
		if type(tbl) == "table" then
			if tbl._AccessControl_ then
				return AccessControl:getRawTable(tbl)
			end

			if tbl._BddData_ then
				return bdd2DeepTable(tbl)
			end

			for k, v in pairs(tbl) do
				tbl[k] = dealMsgParameters(v)
			end

			return tbl
		elseif type(tbl) == "userdata" and tbl._BddData_ then
			return bdd2DeepTable(tbl)
		end

		return tbl
	end
end

return Functions
