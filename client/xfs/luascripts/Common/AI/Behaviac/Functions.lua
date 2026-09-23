-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Functions.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("AIBehaviac")
local functions = {}

functions.string = {}
functions.io = {}
functions.math = {}
functions.table = {}

function functions.printLog(tag, fmt, ...)
	local t = {
		"[",
		string.upper(tostring(tag)),
		"] ",
		string.format(tostring(fmt), ...)
	}

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:debug(table.concat(t))
	end
end

function functions.printError(fmt, ...)
	functions.printLog("ERR", fmt, ...)

	if LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error(debug.traceback("", 2))
	end
end

function functions.printInfo(fmt, ...)
	if type(DEBUG) ~= "number" or DEBUG < 2 then
		return
	end

	functions.printLog("INFO", fmt, ...)
end

local function dump_value_(v)
	if type(v) == "string" then
		v = "\"" .. v .. "\""
	end

	return tostring(v)
end

local function dump(value, desciption, nesting)
	if type(nesting) ~= "number" then
		nesting = 3
	end

	local lookupTable = {}
	local result = {}
	local traceback = string.split(debug.traceback("", 2), "\n")

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:debug("dump from: " .. functions.string.trim(traceback[3]))
	end

	local function dump_(value, desciption, indent, nest, keylen)
		desciption = desciption or "<var>"

		local spc = ""

		if type(keylen) == "number" then
			spc = string.rep(" ", keylen - string.len(dump_value_(desciption)))
		end

		if type(value) ~= "table" then
			result[#result + 1] = string.format("%s%s%s = %s", indent, dump_value_(desciption), spc, dump_value_(value))
		elseif lookupTable[tostring(value)] then
			result[#result + 1] = string.format("%s%s%s = *REF*", indent, dump_value_(desciption), spc)
		else
			lookupTable[tostring(value)] = true

			if nest > nesting then
				result[#result + 1] = string.format("%s%s = *MAX NESTING*", indent, dump_value_(desciption))
			else
				result[#result + 1] = string.format("%s%s = {", indent, dump_value_(desciption))

				local indent2 = indent .. "    "
				local keys = {}
				local keylen = 0
				local values = {}

				for k, v in pairs(value) do
					keys[#keys + 1] = k

					local vk = dump_value_(k)
					local vkl = string.len(vk)

					if keylen < vkl then
						keylen = vkl
					end

					values[k] = v
				end

				table.sort(keys, function(a, b)
					if type(a) == "number" and type(b) == "number" then
						return a < b
					else
						return tostring(a) < tostring(b)
					end
				end)

				for i, k in ipairs(keys) do
					dump_(values[k], k, indent2, nest + 1, keylen)
				end

				result[#result + 1] = string.format("%s}", indent)
			end
		end
	end

	dump_(value, desciption, "- ", 1)

	for i, line in ipairs(result) do
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			logger:debug(line)
		end
	end
end

function functions.printf(fmt, ...)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:debug(string.format(tostring(fmt), ...))
	end
end

function functions.checknumber(value, base)
	return tonumber(value, base) or 0
end

function functions.checkint(value)
	return math.round(checknumber(value))
end

function functions.checkbool(value)
	return value ~= nil and value ~= false
end

function functions.checktable(value)
	if type(value) ~= "table" then
		value = {}
	end

	return value
end

function functions.isset(hashtable, key)
	local t = type(hashtable)

	return (t == "table" or t == "userdata") and hashtable[key] ~= nil
end

local setmetatableindex_

function setmetatableindex_(t, index)
	if type(t) == "userdata" then
		local peer = tolua.getpeer(t)

		if not peer then
			peer = {}

			tolua.setpeer(t, peer)
		end

		setmetatableindex_(peer, index)
	else
		local mt = getmetatable(t)

		mt = mt or {}

		if not mt.__index then
			mt.__index = index

			setmetatable(t, mt)
		elseif mt.__index ~= index then
			setmetatableindex_(mt, index)
		end
	end
end

functions.setmetatableindex = setmetatableindex_

function functions.clone(object)
	local lookup_table = {}

	local function _copy(object)
		if type(object) ~= "table" then
			return object
		elseif lookup_table[object] then
			return lookup_table[object]
		end

		local newObject = {}

		lookup_table[object] = newObject

		for key, value in pairs(object) do
			newObject[_copy(key)] = _copy(value)
		end

		return setmetatable(newObject, getmetatable(object))
	end

	return _copy(object)
end

function functions.class(classname, ...)
	local cls = {
		__cname = classname
	}
	local nargs = select("#", ...)

	for i = 1, nargs do
		local super = select(i, ...)
		local superType = type(super)

		assert(superType == "nil" or superType == "table" or superType == "function", string.format("class() - create class \"%s\" with invalid super class type \"%s\"", classname, superType))

		if superType == "function" then
			assert(cls.__create == nil, string.format("class() - create class \"%s\" with more than one creating function", classname))

			cls.__create = super
		elseif superType == "table" then
			if super[".isclass"] then
				assert(cls.__create == nil, string.format("class() - create class \"%s\" with more than one creating function or native class", classname))

				function cls.__create()
					return super:create()
				end
			else
				cls.__supers = cls.__supers or {}
				cls.__supers[#cls.__supers + 1] = super

				if not cls.super then
					cls.super = super
				end
			end
		elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error(string.format("class() - create class \"%s\" with invalid super type", classname), 0)
		end
	end

	cls.__index = cls

	if not cls.__supers or #cls.__supers == 1 then
		setmetatable(cls, {
			__index = cls.super
		})
	else
		setmetatable(cls, {
			__index = function(_, key)
				local supers = cls.__supers

				for i = 1, #supers do
					local super = supers[i]

					if super[key] then
						return super[key]
					end
				end
			end
		})
	end

	if not cls.ctor then
		function cls.ctor()
			return
		end
	end

	function cls.new(...)
		local instance

		if cls.__create then
			instance = cls.__create(...)
		else
			instance = {}
		end

		functions.setmetatableindex(instance, cls)

		instance.class = cls

		instance:ctor(...)

		return instance
	end

	function cls.create(_, ...)
		return cls.new(...)
	end

	return cls
end

local iskindof_

function iskindof_(cls, name)
	local __index = rawget(cls, "__index")

	if type(__index) == "table" and rawget(__index, "__cname") == name then
		return true
	end

	if rawget(cls, "__cname") == name then
		return true
	end

	local __supers = rawget(cls, "__supers")

	if not __supers then
		return false
	end

	for _, super in ipairs(__supers) do
		if iskindof_(super, name) then
			return true
		end
	end

	return false
end

function functions.iskindof(obj, classname)
	local t = type(obj)

	if t ~= "table" and t ~= "userdata" then
		return false
	end

	local mt

	if t == "userdata" then
		if tolua.iskindof(obj, classname) then
			return true
		end

		mt = tolua.getpeer(obj)
	else
		mt = getmetatable(obj)
	end

	if mt then
		return iskindof_(mt, classname)
	end

	return false
end

function functions.import(moduleName, currentModuleName)
	local currentModuleNameParts
	local moduleFullName = moduleName
	local offset = 1

	while true do
		if string.byte(moduleName, offset) ~= 46 then
			moduleFullName = string.sub(moduleName, offset)

			if currentModuleNameParts and #currentModuleNameParts > 0 then
				moduleFullName = table.concat(currentModuleNameParts, ".") .. "." .. moduleFullName
			end

			break
		end

		offset = offset + 1

		if not currentModuleNameParts then
			if not currentModuleName then
				local n, v = debug.getlocal(3, 1)

				currentModuleName = v
			end

			currentModuleNameParts = string.split(currentModuleName, ".")
		end

		table.remove(currentModuleNameParts, #currentModuleNameParts)
	end

	return functions.ModuleRequire(moduleFullName)
end

function functions.handler(obj, method)
	return function(...)
		return method(obj, ...)
	end
end

function functions.math.round(value)
	value = functions.checknumber(value)

	return math.floor(value + 0.5)
end

local pi_div_180 = math.pi / 180

function functions.math.angle2radian(angle)
	return angle * pi_div_180
end

local pi_mul_180 = math.pi * 180

function functions.math.radian2angle(radian)
	return radian / pi_mul_180
end

function functions.io.exists(path)
	local file = io.open(path, "r")

	if file then
		functions.io.close(file)

		return true
	end

	return false
end

function functions.io.readfile(path)
	local file = functions.io.open(path, "r")

	if file then
		local content = file:read("*a")

		functions.io.close(file)

		return content
	end

	return nil
end

function functions.io.writefile(path, content, mode)
	mode = mode or "w+b"

	local file = functions.io.open(path, mode)

	if file then
		if file:write(content) == nil then
			return false
		end

		io.close(file)

		return true
	else
		return false
	end
end

function functions.io.pathinfo(path)
	local pos = string.len(path)
	local extpos = pos + 1

	while pos > 0 do
		local b = string.byte(path, pos)

		if b == 46 then
			extpos = pos
		elseif b == 47 then
			break
		end

		pos = pos - 1
	end

	local dirname = string.sub(path, 1, pos)
	local filename = string.sub(path, pos + 1)

	extpos = extpos - pos

	local basename = string.sub(filename, 1, extpos - 1)
	local extname = string.sub(filename, extpos)

	return {
		dirname = dirname,
		filename = filename,
		basename = basename,
		extname = extname
	}
end

function functions.io.filesize(path)
	local size = false
	local file = functions.io.open(path, "r")

	if file then
		local current = file:seek()

		size = file:seek("end")

		file:seek("set", current)
		functions.io.close(file)
	end

	return size
end

function functions.table.nums(t)
	local count = 0

	for k, v in pairs(t) do
		count = count + 1
	end

	return count
end

function functions.table.keys(hashtable)
	local keys = {}

	for k, v in pairs(hashtable) do
		keys[#keys + 1] = k
	end

	return keys
end

function functions.table.values(hashtable)
	local values = {}

	for k, v in pairs(hashtable) do
		values[#values + 1] = v
	end

	return values
end

function functions.table.merge(dest, src)
	for k, v in pairs(src) do
		dest[k] = v
	end
end

function functions.table.insertto(dest, src, begin)
	begin = functions.checkint(begin)

	if begin <= 0 then
		begin = #dest + 1
	end

	local len = #src

	for i = 0, len - 1 do
		dest[i + begin] = src[i + 1]
	end
end

function functions.table.indexof(array, value, begin)
	for i = begin or 1, #array do
		if array[i] == value then
			return i
		end
	end

	return false
end

function functions.table.keyof(hashtable, value)
	for k, v in pairs(hashtable) do
		if v == value then
			return k
		end
	end

	return nil
end

function functions.table.removebyvalue(array, value, removeall)
	local c, i, max = 0, 1, #array

	while i <= max do
		if array[i] == value then
			table.remove(array, i)

			c = c + 1
			i = i - 1
			max = max - 1

			if not removeall then
				break
			end
		end

		i = i + 1
	end

	return c
end

function functions.table.map(t, fn)
	for k, v in pairs(t) do
		t[k] = fn(v, k)
	end
end

function functions.table.walk(t, fn)
	for k, v in pairs(t) do
		fn(v, k)
	end
end

function functions.table.foreach(t, fn)
	for i, v in ipairs(t) do
		fn(v, i)
	end
end

function functions.table.find(t, fn)
	for k, v in pairs(t) do
		if fn(v, k) then
			return k, v
		end
	end
end

function functions.table.ifind(t, fn)
	for i, v in ipairs(t) do
		if fn(v, i) then
			return i, v
		end
	end
end

function functions.table.findarray(t, fn)
	local g = {}

	for k, v in pairs(t) do
		if fn(v, k) then
			table.insert(g, v)
		end
	end

	return g
end

function functions.table.findhash(t, fn)
	local g = {}

	for k, v in pairs(t) do
		if fn(v, k) then
			g[k] = v
		end
	end

	return g
end

function functions.table.ifindarray(t, fn)
	local g = {}

	for i, v in ipairs(t) do
		if fn(v, i) then
			table.insert(g, v)
		end
	end

	return g
end

function functions.table.maparray(t, fn)
	local g = {}

	for k, v in pairs(t) do
		local _t = fn(v, k)

		table.insert(g, _t)
	end

	return g
end

function functions.table.maphash(t, fn)
	local g = {}

	for k, v in pairs(t) do
		g[k] = fn(v, k)
	end

	return g
end

function functions.table.mapfind(t, fn)
	for k, v in pairs(t) do
		local _t = fn(v, k)

		if _t then
			return _t
		end
	end
end

function functions.table.imapfind(t, fn)
	for i, v in ipairs(t) do
		local _t = fn(v, i)

		if _t then
			return _t
		end
	end
end

function functions.table.imaparray(t, fn)
	local g = {}

	for i, v in ipairs(t) do
		local _t = fn(v, i)

		functions.table.insert(g, _t)
	end

	return g
end

function functions.table.filter(t, fn)
	for k, v in pairs(t) do
		if not fn(v, k) then
			t[k] = nil
		end
	end
end

function functions.table.unique(t, bArray)
	local check = {}
	local n = {}
	local idx = 1

	for k, v in pairs(t) do
		if not check[v] then
			if bArray then
				n[idx] = v
				idx = idx + 1
			else
				n[k] = v
			end

			check[v] = true
		end
	end

	return n
end

functions.string._htmlspecialchars_set = {}
functions.string._htmlspecialchars_set["&"] = "&amp;"
functions.string._htmlspecialchars_set["\""] = "&quot;"
functions.string._htmlspecialchars_set["'"] = "&#039;"
functions.string._htmlspecialchars_set["<"] = "&lt;"
functions.string._htmlspecialchars_set[">"] = "&gt;"

function functions.string.htmlspecialchars(input)
	for k, v in pairs(string._htmlspecialchars_set) do
		input = string.gsub(input, k, v)
	end

	return input
end

function functions.string.restorehtmlspecialchars(input)
	for k, v in pairs(string._htmlspecialchars_set) do
		input = string.gsub(input, v, k)
	end

	return input
end

function functions.string.nl2br(input)
	return string.gsub(input, "\n", "<br />")
end

function functions.string.text2html(input)
	input = string.gsub(input, "\t", "    ")
	input = functions.string.htmlspecialchars(input)
	input = string.gsub(input, " ", "&nbsp;")
	input = functions.string.nl2br(input)

	return input
end

function functions.string.split(input, delimiter)
	input = tostring(input)
	delimiter = tostring(delimiter)

	if delimiter == "" then
		return false
	end

	local pos, arr = 0, {}

	for st, sp in function()
		return string.find(input, delimiter, pos, true)
	end do
		table.insert(arr, string.sub(input, pos, st - 1))

		pos = sp + 1
	end

	table.insert(arr, string.sub(input, pos))

	return arr
end

function functions.string.ltrim(input)
	return string.gsub(input, "^[ \t\n\r]+", "")
end

function functions.string.rtrim(input)
	return string.gsub(input, "[ \t\n\r]+$", "")
end

function functions.string.trim(input)
	input = string.gsub(input, "^[ \t\n\r]+", "")

	return string.gsub(input, "[ \t\n\r]+$", "")
end

function functions.string.ucfirst(input)
	return string.upper(string.sub(input, 1, 1)) .. string.sub(input, 2)
end

local function urlencodechar(char)
	return "%" .. string.format("%02X", string.byte(char))
end

function functions.string.urlencode(input)
	input = string.gsub(tostring(input), "\n", "\r\n")
	input = string.gsub(input, "([^%w%.%- ])", urlencodechar)

	return string.gsub(input, " ", "+")
end

function functions.string.urldecode(input)
	input = string.gsub(input, "+", " ")
	input = string.gsub(input, "%%(%x%x)", function(h)
		return string.char(functions.checknumber(h, 16))
	end)
	input = string.gsub(input, "\r\n", "\n")

	return input
end

function functions.string.utf8len(input)
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

function functions.string.formatnumberthousands(num)
	local formatted = tostring(functions.checknumber(num))
	local k

	repeat
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
	until k == 0

	return formatted
end

return functions
