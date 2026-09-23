-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\OriginMapValue.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local LoggerConst = require("Core.Log.LoggerConst")
local PropertyTypes = require("Core.PropertySync.PropertyTypes")
local LoggerManager = require("Core.Log.LoggerManager")
local class = require("Core.Framework.Class")
local logger = LoggerManager.getLogger("OriginMapValue")
local OriginMapValue = class.LiteClass("OriginMapValue")
local string_format = string.format

local function pairsIterator(t, k)
	local v

	k, v = next(t, k)

	if v ~= nil then
		if k == "_" then
			return pairsIterator(t, k)
		end

		return k, v
	end
end

local mt = {
	__index = function(tbl, k)
		local classType = tbl.__ClassType
		local v = classType[k]

		if v ~= nil then
			return v
		end

		v = tbl._properties[k]

		return v
	end,
	__newindex = function(tbl, k, v)
		if _G_IsDebugMode and type(k) ~= "string" then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("%s is invalid, key is not string", tbl.__ClassType.typeName, debug.traceback())
			end

			return
		end

		if _G_IsDebugMode and type(v) == "table" then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("%s is invalid, just support simple type", tbl.__ClassType.typeName, debug.traceback())
			end

			return
		end

		local oldv = tbl._properties[k]
		local changed = false

		if oldv ~= nil then
			if v ~= nil then
				if oldv == v then
					return
				end

				tbl._properties[k] = v
				changed = true
			else
				tbl._properties[k] = nil
				changed = true
				tbl._propertiesCnt = tbl._propertiesCnt - 1
			end
		elseif v ~= nil then
			tbl._properties[k] = v
			tbl._propertiesCnt = tbl._propertiesCnt + 1
			changed = true
		end

		if changed then
			tbl.owner:_originTableChanged()
		end
	end,
	__pairs = function(tbl)
		return pairsIterator, tbl._properties, nil
	end,
	__ipairs = function(tbl)
		error(string_format("ipairs operation not supported for %s!", tbl.__ClassType.typeName))
	end,
	__len = function(tbl)
		return tbl._propertiesCnt
	end
}

function OriginMapValue:ctor(owner)
	self.owner = owner
	self.__ClassType = self:getClass()
end

function OriginMapValue:resetOwner()
	self.owner = nil
end

function OriginMapValue:getRawTable()
	return self._properties
end

function OriginMapValue:init(dict)
	local _properties = {}
	local _propertiesCnt = 0

	for k, v in pairs(dict) do
		if type(k) ~= "string" then
			logger:error("%s is invalid, key is not string", self.__ClassType.typeName, debug.traceback())
			self:resetOwner()

			return false
		end

		if type(v) == "table" then
			logger:error("%s is invalid, just support simple type", self.__ClassType.typeName, debug.traceback())
			self:resetOwner()

			return false
		end

		_properties[k] = v
		_propertiesCnt = _propertiesCnt + 1
	end

	rawset(self, "_properties", _properties)
	rawset(self, "_propertiesCnt", _propertiesCnt)
	setmetatable(self, mt)

	return true
end

return OriginMapValue
