-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Framework\\BddDataMgr.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local class = require("Core.Framework.Class")
local globalDeclare = require("Core.Framework.Global")

globalDeclare("bdd")

bdd = require("bdd")

local getValueByStrAddr = bdd.get_value_by_str_addr_key
local getValueByNum = bdd.get_value_by_num_key
local getLen = bdd.len
local getHandle = bdd.get_handle_from_ud
local getStrByAddr = bdd.get_str_by_addr
local nextWithNil = bdd.next_nil_key
local nextWithNum = bdd.next_num_key
local nextWithStrAddr = bdd.next_str_addr_key
local getUdByAddr = bdd.get_ud_by_addr
local getStartHandle = bdd.get_start_handle
local addStr = bdd.add_str
local bddPatch = bdd.patch
local BddDataMgr = class.Class("BddDataMgr", nil, true)
local udCache = {}

local function udCacheIndex(tbl, key)
	local val = getUdByAddr(key)

	tbl[key] = val

	return val
end

setmetatable(udCache, {
	__mode = "v",
	__index = udCacheIndex
})
rawset(_G, "__BDD_udCache", udCache)

local metatable = {
	_BddData_ = true
}

rawset(_G, "__BDD_metatable", metatable)

local str2addr = {}

rawset(_G, "__BDD_str2addr", str2addr)

local addr2str = {}

local function addr2strIndex(tbl, key)
	local val = getStrByAddr(key)

	tbl[key] = val

	return val
end

setmetatable(addr2str, {
	__mode = "v",
	__index = addr2strIndex
})
rawset(_G, "__BDD_addr2str", addr2str)

local _refCaches = {
	addr2str,
	udCache
}
local _cacheEmpty = {}

local function refCachesIndex()
	return _cacheEmpty
end

setmetatable(_refCaches, {
	__index = refCachesIndex
})

local function ref2Val(addrOrVal, valType)
	if not valType then
		return addrOrVal
	end

	local val = _refCaches[valType][addrOrVal]

	return val
end

local function bddRawG()
	return ref2Val(getStartHandle(), 2)
end

local function bdd2Table(tbl)
	if getmetatable(tbl) ~= metatable then
		return tbl
	end

	local ret = {}

	for k, v in pairs(tbl) do
		ret[k] = v
	end

	return ret
end

function bdd2DeepTable(tbl)
	local ret = {}

	for k, v in pairs(tbl) do
		if type(v) == "table" or type(v) == "userdata" then
			ret[k] = bdd2DeepTable(v)
		else
			ret[k] = v
		end
	end

	return ret
end

local function _indexNumber(tbl, i)
	local v, vt = getValueByNum(tbl, i)

	return ref2Val(v, vt)
end

local LUA_TNONE = -1
local LUA_TNIL = 0
local LUA_TBOOLEAN = 1
local LUA_TLIGHTUSERDATA = 2
local LUA_TNUMBER = 3
local LUA_TSTRING = 4
local LUA_TTABLE = 5
local LUA_TFUNCTION = 6
local LUA_TUSERDATA = 7
local LUA_TTHREAD = 8
local LUA_NUMTAGS = 9
local _numTab = {
	number = LUA_TNUMBER,
	string = LUA_TSTRING,
	table = LUA_TTABLE,
	boolean = LUA_TBOOLEAN,
	["function"] = LUA_TFUNCTION,
	userdata = LUA_TUSERDATA,
	lightuserdata = LUA_TLIGHTUSERDATA
}

local function typeNumber(typeName)
	return _numTab[typeName] or LUA_TNIL
end

local Variable = {}

function Variable:ctor()
	self.children = {}
end

function Variable:addChild(child)
	self.children[#self.children + 1] = child
end

function Variable:tostring(pad)
	pad = pad or ""

	local val = self:_selfToString()
	local arr = {
		pad .. "\"" .. val .. "\""
	}

	if #self.children > 0 then
		arr[#arr + 1] = pad .. "{"

		for i, node in ipairs(self.children) do
			arr[#arr + 1] = node:tostring(pad .. "\t")
		end

		arr[#arr + 1] = pad .. "}"
	end

	return table.concat(arr, "\n")
end

function Variable:_selfToString()
	return string.format("%s=%s (%s)", self.name, self.value, self.valueTypeName)
end

local emmyHelper = {}

function emmyHelper.createNode()
	local val = {}

	setmetatable(val, {
		__index = Variable
	})
	val:ctor()

	return val
end

local function createNewNode(key, value)
	local newNode = emmyHelper.createNode()

	newNode.name = tostring(key)
	newNode.value = tostring(value)

	local valueType = type(value)

	newNode.valueTypeName = valueType
	newNode.valueType = typeNumber(valueType)

	return newNode, valueType
end

local function bdd2stringEx(variable, tbl, typeName, depth)
	local raw = tbl

	variable.value = tostring(raw) .. " bdd"
	variable.valueTypeName = typeName

	local maxCount = 128

	for i, v in pairs(raw) do
		local newNode, valueType = createNewNode(i, v)

		variable:addChild(newNode)

		if valueType == "table" or valueType == "userdata" then
			local metatable = getmetatable(v)

			if metatable and metatable._BddData_ == true then
				bdd2stringEx(newNode, v, "table", depth - 1)
			end
		end

		maxCount = maxCount - 1

		if maxCount <= 0 then
			break
		end
	end
end

local function bdd2string(tbl, name)
	name = name or ""

	local variable, valueType = createNewNode(name, tbl)

	bdd2stringEx(variable, tbl, "table", 10)

	return variable:tostring()
end

local function bddNextRaw(tbl, key)
	local _t = type(key)

	if _t == "nil" then
		local k, kt, v, vt = nextWithNil(tbl)

		return ref2Val(k, kt), ref2Val(v, vt)
	elseif _t == "number" then
		local k, kt, v, vt = nextWithNum(tbl, key)

		return ref2Val(k, kt), ref2Val(v, vt)
	elseif _t == "string" then
		local addr = str2addr[key]
		local k, kt, v, vt = nextWithStrAddr(tbl, addr)

		return ref2Val(k, kt), ref2Val(v, vt)
	else
		error("invalid key to bddnext!")
	end
end

function bddnext(tbl, key)
	if getmetatable(tbl) == metatable then
		local _t = type(key)

		if _t == "nil" then
			local k, kt, v, vt = nextWithNil(tbl)

			return ref2Val(k, kt), ref2Val(v, vt)
		elseif _t == "number" then
			local k, kt, v, vt = nextWithNum(tbl, key)

			return ref2Val(k, kt), ref2Val(v, vt)
		elseif _t == "string" then
			local addr = str2addr[key]
			local k, kt, v, vt = nextWithStrAddr(tbl, addr)

			return ref2Val(k, kt), ref2Val(v, vt)
		else
			error("invalid key to bddnext!")
		end

		return
	end

	return next(tbl, key, true)
end

local bddnext = bddnext

local function bddpairs(tbl)
	if getmetatable(tbl) == metatable then
		return bddNextRaw, tbl, nil
	end

	return pairs(tbl, true)
end

local function inext(tbl, i)
	i = i + 1

	local v = _indexNumber(tbl, i)

	if v ~= nil then
		return i, v
	end
end

local function bddipairs(tbl)
	return inext, tbl, 0
end

function bddunpack(tbl, startIndex)
	local ret = {}

	for _, v in bddipairs(tbl) do
		ret[#ret + 1] = v
	end

	return unpack(ret, startIndex)
end

function table.bddforeach(tbl, func)
	if getmetatable(tbl) == metatable then
		for k, v in bddpairs(tbl) do
			func(k, v)
		end

		return
	end

	return table.foreach(tbl, func, true)
end

function string.startsWith(str, start)
	return str:sub(1, #start) == start
end

local function bdddump(t, includefunc, depth)
	if t == nil then
		return ""
	end

	if depth == nil then
		depth = 0
	end

	if depth >= 10 then
		return "{too deep}"
	end

	local str = "{ "

	for k, v in bddpairs(t) do
		k = tostring(k)

		if string.startsWith(k, "__") then
			if includefunc then
				str = str .. k .. "=metatable, "
			end
		elseif type(v) == "string" then
			str = str .. k .. "=\"" .. v .. "\", "
		elseif type(v) == "number" then
			str = str .. k .. "=" .. v .. ", "
		elseif type(v) == "function" then
			if includefunc then
				str = str .. k .. "=function, "
			end
		elseif type(v) == "table" or type(v) == "userdata" then
			str = str .. k .. "=" .. bdddump(v, includefunc, depth + 1) .. ", "
		elseif type(v) == "boolean" then
			str = str .. k .. "=" .. (v and "true" or "false") .. ", "
		else
			str = str .. k .. "=" .. type(v) .. ", "
		end
	end

	str = str .. "}"

	return str
end

local function metaIndex(tbl, key)
	local _t = type(key)

	if _t == "number" then
		local v, vt = getValueByNum(tbl, key)

		return ref2Val(v, vt)
	elseif _t == "string" then
		local addr = str2addr[key]

		if addr then
			local v, vt = getValueByStrAddr(tbl, addr)

			return ref2Val(v, vt)
		end

		if key == "_BddData_" then
			return true
		end
	end
end

metatable.__index = metaIndex

local bddPatchEnabled = false

local function readonlyDataError()
	error("[error]    禁止修改data配表数据;" .. debug.traceback(), 3)
end

local clearBddLineCachedTables

local function patch(handle, key, val)
	local bStrKey, bStrVal = false, false

	if type(key) == "string" then
		local addr = str2addr[key]

		if not addr then
			addr = addStr(key)
			str2addr[key] = addr
			addr2str[addr] = key
		end

		bStrKey = true
		key = addr
	end

	if type(val) == "string" then
		local addr = str2addr[val]

		if not addr then
			addr = addStr(val)
			str2addr[val] = addr
			addr2str[addr] = val
		end

		bStrVal = true
		val = addr
	end

	bddPatch(handle, key, val, bStrKey, bStrVal)
end

local _patchTbl2Flag

local function checkpatch(t, key, val)
	if _patchTbl2Flag[t] then
		return true
	end

	_patchTbl2Flag[t] = true

	if type(key) ~= "string" and type(key) ~= "number" then
		print("Error:key must be string or number!")
		assert(false)

		return false
	end

	local valTy = type(val)

	if val ~= nil and valTy ~= "number" and valTy ~= "string" and valTy ~= "boolean" and valTy ~= "table" and (valTy ~= "userdata" or getmetatable(val) ~= metatable) then
		print("Error:value must be string or number or boolean or table!", val)
		assert(false)

		return false
	end

	if type(val) == "table" then
		for k, v in pairs(val) do
			if not checkpatch(val, k, v) then
				return false
			end
		end
	end

	return true, val
end

local function metaNewindex(t, key, val)
	if not bddPatchEnabled then
		readonlyDataError()

		return
	end

	_patchTbl2Flag = {}

	if not checkpatch(t, key, val) then
		return
	end

	for k, v in pairs(udCache) do
		udCache[k] = nil
	end

	if clearBddLineCachedTables then
		clearBddLineCachedTables()
	end

	_patchTbl2Flag = {}

	patch(t, key, val)

	_patchTbl2Flag = nil
end

metatable.__newindex = metaNewindex

local function metaEq(a, b)
	if type(a) ~= type(b) then
		return false
	end

	if type(a) == "userdata" then
		return getHandle(a) == getHandle(b)
	else
		return a == b
	end
end

metatable.__eq = metaEq

local function metaLen(tbl)
	return getLen(tbl)
end

metatable.__len = getLen

local function metaTostring(tbl)
	return "BIN DESIGN DATA TABLE:" .. getHandle(tbl)
end

metatable.__tostring = metaTostring

local function metaPairs(tbl, key)
	return bddNextRaw, tbl, nil
end

metatable.__pairs = metaPairs

local function ipairsIterator(t, i)
	i = i + 1

	local v = _indexNumber(t, i)

	if v ~= nil then
		return i, v
	end
end

local function metaIpairs(tbl)
	return ipairsIterator, tbl, 0
end

metatable.__ipairs = metaIpairs
metatable.__next = bddNextRaw

local data2table = {}
local lineCachedTables = {}

local function clearLineCachedTable(t)
	local nullSet = rawget(t, "__nullSet")

	if nullSet then
		for k in pairs(nullSet) do
			nullSet[k] = nil
		end
	end

	local ck = next(t)

	while ck do
		local nk = next(t, ck)

		if ck ~= "_BddData_" and ck ~= "__nullSet" and ck ~= "__value" then
			rawset(t, ck, nil)
		end

		ck = nk
	end
end

function clearBddLineCachedTables()
	for k in pairs(data2table) do
		data2table[k] = nil
	end

	for t in pairs(lineCachedTables) do
		clearLineCachedTable(t)
	end
end

local function convertBddToTable(val)
	local handle = getHandle(val)
	local cached = data2table[handle]

	if cached then
		return cached
	end

	local ret = {}

	data2table[handle] = ret

	for k, v in bddNextRaw, val do
		if type(v) == "userdata" then
			v = convertBddToTable(v)
		end

		ret[k] = v
	end

	return ret
end

function BddDataMgr:init()
	bdd.init()
	self:reload()

	return true
end

function BddDataMgr:setDataPathHook(func)
	self.getBinDataPath = func
end

function BddDataMgr:reload()
	if self.getBinDataPath == nil then
		return
	end

	local dataBinPath = self.getBinDataPath()

	if dataBinPath == "" then
		return
	end

	bdd.load_from_file(dataBinPath)

	self.bddRaw = bddRawG()

	for k in pairs(data2table) do
		data2table[k] = nil
	end

	for k, v in pairs(self.record or EMPTY_TABLE) do
		rawset(v, "__value", self.bddRaw[k])
		clearLineCachedTable(v)
	end
end

function BddDataMgr:dump(t, includefunc, depth)
	return bdddump(t, includefunc, depth)
end

function BddDataMgr:getTable(tableName)
	if self.bddRaw == nil then
		self:init()
	end

	if not self.bddRaw[tableName] then
		return nil
	end

	self.record = self.record or {}

	if not self.record[tableName] then
		local t = {
			_BddData_ = true,
			__nullSet = {}
		}
		local raw = self.bddRaw[tableName]
		local lineCached = pg.bddLineCached and pg.bddLineCached[tableName]
		local mt

		if lineCached then
			mt = {
				__index = function(tbl, k)
					if tbl.__nullSet[k] then
						return nil
					end

					local val = metaIndex(raw, k)

					if val == nil then
						tbl.__nullSet[k] = true

						return nil
					end

					if type(val) == "userdata" then
						val = convertBddToTable(val)
					end

					rawset(tbl, k, val)

					return val
				end,
				__newindex = function(tbl, k, v)
					tbl.__nullSet[k] = nil

					metaNewindex(raw, k, v)

					if v ~= nil then
						rawset(tbl, k, v)
					end
				end,
				__pairs = function(tbl)
					return bddNextRaw, raw, nil
				end,
				__ipairs = function(tbl)
					return inext, raw, 0
				end,
				__next = function(tbl, index)
					return bddNextRaw(raw, index)
				end,
				__len = function(tbl)
					return getLen(raw)
				end
			}
		else
			mt = {
				__index = function(tbl, k)
					return metaIndex(raw, k)
				end,
				__newindex = function(tbl, k, v)
					metaNewindex(raw, k, v)
				end,
				__pairs = function(tbl)
					return bddNextRaw, raw, nil
				end,
				__ipairs = function(tbl)
					return inext, raw, 0
				end,
				__next = function(tbl, index)
					return bddNextRaw(raw, index)
				end,
				__len = function(tbl)
					return getLen(raw)
				end
			}
		end

		setmetatable(t, mt)
		rawset(t, "__value", raw)

		if lineCached then
			lineCachedTables[t] = true
		end

		self.record[tableName] = t
	end

	return self.record[tableName]
end

function BddDataMgr:updateTable(tableName, tableValue)
	if self.bddRaw == nil then
		self:init()
	end

	if not self.bddRaw[tableName] then
		return
	end

	if self.record[tableName] then
		lineCachedTables[self.record[tableName]] = nil
		self.record[tableName] = nil
	end

	self.bddRaw[tableName] = tableValue
end

function BddDataMgr:clearPatchCache()
	if clearBddLineCachedTables then
		clearBddLineCachedTables()
	end
end

function BddDataMgr:beginPatch()
	bddPatchEnabled = true

	self:clearPatchCache()
end

function BddDataMgr:endPatch()
	bddPatchEnabled = false
end

function BddDataMgr.bdd2string(tbl, name)
	return bdd2string(tbl, name)
end

local _enableBddProfilerIgnore = false

if UNITY_EDITOR and _enableBddProfilerIgnore then
	local AppProfiler = require("Core.Profiler.AppProfiler")

	AppProfiler.addIgnore(metaIndex)
	AppProfiler.addIgnore(metaNewindex)
	AppProfiler.addIgnore(metaEq)
	AppProfiler.addIgnore(metaLen)
	AppProfiler.addIgnore(metaTostring)
	AppProfiler.addIgnore(metaPairs)
	AppProfiler.addIgnore(metaIpairs)
	AppProfiler.addIgnore(udCacheIndex)
	AppProfiler.addIgnore(addr2strIndex)
	AppProfiler.addIgnore(refCachesIndex)
	AppProfiler.addIgnore(ref2Val)
	AppProfiler.addIgnore(bddnext)
	AppProfiler.addIgnore(bddpairs)
	AppProfiler.addIgnore(bddipairs)
	AppProfiler.addIgnore(inext)
	AppProfiler.addIgnore(_indexNumber)
	AppProfiler.addIgnore(ipairsIterator)
end

return BddDataMgr
