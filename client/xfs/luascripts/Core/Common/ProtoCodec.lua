-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Common\\ProtoCodec.lua

local try = require("Core.Framework.Exception")
local class = require("Core.Framework.Class")
local msgpack = require("cmsgpack")
local CommonRepo = require("Core.Common.CommonRepo")
local IDManager = require("Core.Common.IDManager")
local ProtoCodec = class.Class("ProtoCodec")
local base64 = require("base64")
local decodeBase64 = base64.decode
local isValidBase64 = base64.isvalid
local protectedCall = pcall
local valueType = type
local packZstd = msgpack.pack_zstd
local unpackMsgpack = msgpack.unpack
local unpackZstd = msgpack.unpack_zstd

local function tryDecodeMsgpack(payload)
	local success, result = protectedCall(unpackMsgpack, payload)

	if not success or result == nil then
		return nil
	end

	return result
end

local function tryDecodeZstd(payload)
	local success, result = protectedCall(unpackZstd, payload)

	if not success or result == nil then
		return nil, false
	end

	return result, true
end

function ProtoCodec:ctor()
	self.codec = msgpack
end

function ProtoCodec:encode(...)
	local args = {
		...
	}

	if #args == 0 then
		return ""
	end

	local ret, errmsg = self.codec.pack(...)

	if errmsg and errmsg ~= "" then
		CommonRepo.exceptionFunc(debug.traceback(errmsg))

		ret = ""
	end

	return ret
end

function ProtoCodec:safeEncode(p)
	local ret, errmsg = "", ""
	local status, err = xpcall(function()
		ret, errmsg = self.codec.pack(p)
	end, debug.traceback)

	if not status then
		local ex = err or "unknown error occurred"

		CommonRepo.exceptionFunc(ex)

		ret = ""
	elseif errmsg and errmsg ~= "" then
		CommonRepo.exceptionFunc(debug.traceback(errmsg))

		ret = ""
	elseif valueType(ret) ~= "string" or ret == "" then
		CommonRepo.exceptionFunc(debug.traceback("msgpack encode returned an invalid payload"))

		ret = ""
	end

	return ret
end

function ProtoCodec:safeEncodeZstd(p)
	local status, ret = protectedCall(packZstd, p)

	if not status then
		return self:safeEncode(p), false
	end

	return ret, true
end

ProtoCodec.safeEncodeClientInfo = ProtoCodec.safeEncodeZstd

function ProtoCodec:encodeToStr(p)
	return base64.encode(self:encode(p))
end

function ProtoCodec:safeEncodeToStr(p)
	local str = self:safeEncode(p)
	local ret = ""

	xpcall(function()
		ret = base64.encode(str)
	end, debug.traceback)

	return ret
end

function ProtoCodec:decode(p)
	return self.codec.unpack(p)
end

function ProtoCodec:safeDecode(p)
	local ret = ""
	local status, err = xpcall(function()
		ret = self.codec.unpack(p)
	end, debug.traceback)

	if not status then
		local ex = err or "unknown error occurred"

		CommonRepo.exceptionFunc(ex)

		ret = ""
	end

	return ret
end

function ProtoCodec:safeDecodeZstd(p)
	local result, success = tryDecodeZstd(p)

	if success then
		return result
	end

	return self:safeDecode(p)
end

function ProtoCodec:safeDecodeClientInfo(payload)
	if payload == nil or payload == "" then
		return {}
	end

	local result

	if isValidBase64(payload) then
		result = tryDecodeMsgpack(decodeBase64(payload))
	end

	if valueType(result) == "table" then
		return result
	end

	result = tryDecodeZstd(payload)

	if valueType(result) == "table" then
		return result
	end

	result = tryDecodeMsgpack(payload)

	return valueType(result) == "table" and result or {}
end

function ProtoCodec:decodeFromStr(p)
	return self:decode(base64.decode(p))
end

function ProtoCodec:safeDecodeFromStr(p)
	local str = ""

	xpcall(function()
		str = base64.decode(p)
	end, debug.traceback)

	local ret = self:safeDecode(str)

	return ret
end

return ProtoCodec
