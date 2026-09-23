-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\OriginMapCppWrapper.lua

local OriginMapValue = require("CustomTypes.OriginMapValue")
local json = require("json")
local FIXED_KEY = "ORIGIN_MAP_KEY"
local pairs = pairs
local next = next
local rawset = rawset
local rawget = rawget
local type = type
local OriginMapCppWrapper = {}
local mt = {}

function OriginMapCppWrapper.createCppWrapper(cppNode)
	local obj = {
		_propertiesCnt = 0,
		__isOriginMapCppWrapper = true,
		_cppNode = cppNode
	}

	return setmetatable(obj, mt)
end

function OriginMapCppWrapper:isCustomType()
	return true
end

function OriginMapCppWrapper:isCustomDict()
	return true
end

function OriginMapCppWrapper:isCustomList()
	return false
end

function OriginMapCppWrapper:customTypeName()
	return "OriginMap"
end

function OriginMapCppWrapper:_getBlob()
	local cppNode = rawget(self, "_cppNode")
	local blob = cppNode and cppNode[FIXED_KEY] or nil

	if blob == nil then
		blob = ""
	end

	return blob
end

function OriginMapCppWrapper:_wrapValue(v)
	if type(v) ~= "table" then
		return v, true
	end

	local raw = v

	if v.getRawTable then
		raw = v:getRawTable()
	end

	local wrapped = OriginMapValue(self)

	if wrapped:init(raw) then
		return wrapped, true
	end

	return nil, false
end

function OriginMapCppWrapper:_decodeBlob(blob)
	local decoded = {}

	if blob ~= nil and blob ~= "" then
		local ok, result = pcall(json.decode, blob)

		if ok and type(result) == "table" then
			decoded = result
		end
	end

	local realProperties = {}
	local cnt = 0

	for k, v in pairs(decoded) do
		if type(v) == "table" then
			realProperties[k] = self:_wrapValue(v)
		else
			realProperties[k] = v
		end

		cnt = cnt + 1
	end

	rawset(self, "_realProperties", realProperties)
	rawset(self, "_propertiesCnt", cnt)
	rawset(self, "_blob", blob)
end

function OriginMapCppWrapper:_ensureDecoded()
	local blob = self:_getBlob()

	if rawget(self, "_realProperties") == nil or rawget(self, "_blob") ~= blob then
		self:_decodeBlob(blob)
	end
end

function OriginMapCppWrapper:_toRawTable()
	self:_ensureDecoded()

	local raw = {}
	local realProperties = rawget(self, "_realProperties") or {}

	for k, v in pairs(realProperties) do
		if type(v) == "table" and v.getRawTable then
			raw[k] = v:getRawTable()
		else
			raw[k] = v
		end
	end

	return raw
end

function OriginMapCppWrapper:_originTableChanged()
	local blob = json.encode(self:_toRawTable())

	rawset(self, "_blob", blob)

	local cppNode = rawget(self, "_cppNode")

	cppNode[FIXED_KEY] = blob
end

function OriginMapCppWrapper:getRawTable()
	return self:_toRawTable()
end

function OriginMapCppWrapper:getPersistentValue()
	return {
		[FIXED_KEY] = self:_getBlob()
	}
end

function OriginMapCppWrapper:getOwnClientValue()
	return rawget(self, "_cppNode"):getOwnClientValue()
end

function OriginMapCppWrapper:getAllClientsValue()
	return rawget(self, "_cppNode"):getAllClientsValue()
end

function OriginMapCppWrapper:getOwnAndAllClientsValue(aoiscope)
	return rawget(self, "_cppNode"):getOwnAndAllClientsValue(aoiscope)
end

function OriginMapCppWrapper:_originPropertyChanged()
	rawset(self, "_realProperties", nil)
	rawset(self, "_propertiesCnt", 0)
	rawset(self, "_blob", nil)
end

function mt.__index(tbl, k)
	local method = OriginMapCppWrapper[k]

	if method ~= nil then
		return method
	end

	tbl:_ensureDecoded()

	local realProperties = rawget(tbl, "_realProperties")

	return realProperties and realProperties[k] or nil
end

function mt.__newindex(tbl, k, v)
	tbl:_ensureDecoded()

	local realProperties = rawget(tbl, "_realProperties")
	local oldv = realProperties[k]

	if oldv == v then
		return
	end

	if oldv ~= nil and type(oldv) == "table" and oldv.resetOwner then
		oldv:resetOwner()
	end

	if v == nil then
		realProperties[k] = nil
	elseif type(v) == "table" then
		local wrapped, ok = tbl:_wrapValue(v)

		if not ok then
			return
		end

		realProperties[k] = wrapped
	else
		realProperties[k] = v
	end

	local cnt = 0

	for _ in pairs(realProperties) do
		cnt = cnt + 1
	end

	rawset(tbl, "_propertiesCnt", cnt)
	tbl:_originTableChanged()
end

function mt.__pairs(tbl)
	tbl:_ensureDecoded()

	return next, rawget(tbl, "_realProperties") or {}, nil
end

function mt.__len(tbl)
	tbl:_ensureDecoded()

	return rawget(tbl, "_propertiesCnt") or 0
end

return OriginMapCppWrapper
