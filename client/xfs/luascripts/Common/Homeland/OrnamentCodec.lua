-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Homeland\\OrnamentCodec.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local logger = LoggerManager.getLogger("OrnamentCodec")
local bit = bit
local band = bit.band
local bor = bit.bor
local lshift = bit.lshift
local rshift = bit.rshift
local string_char = string.char
local string_byte = string.byte
local math_floor = math.floor
local unpack = unpack
local OrnamentCodec = {}

OrnamentCodec.FLAG_HAS_YAW = 1
OrnamentCodec.FLAG_HAS_PITCH_ROLL = 2
OrnamentCodec.FLAG_SCALE_UNIFORM = 4
OrnamentCodec.FLAG_SCALE_XYZ = 8
OrnamentCodec.FLAG_HAS_TRASH = 16
OrnamentCodec.FLAG_ELECTRIC_MODE = 32
OrnamentCodec.FLAG_HAS_AREA_EXT = 1024
OrnamentCodec.AREA_SHIFT = 6
OrnamentCodec.AREA_MASK = 960
OrnamentCodec.AREA_INLINE_MAX = 15
OrnamentCodec.FIXED_SIZE = 12
OrnamentCodec.ROTATION_MOD = 36000
OrnamentCodec.UINT16_MAX = 65535
OrnamentCodec.POSITION_AXIS_MIN = -32768
OrnamentCodec.POSITION_AXIS_MAX = 32767
OrnamentCodec.SCALE_BASE = HomeLandUtils.ORNAMENT_SCALE_INT_BASE
OrnamentCodec.VERSION = 1

function OrnamentCodec.encodePositionAxis(value)
	value = math_floor(tonumber(value) or 0)

	if value < OrnamentCodec.POSITION_AXIS_MIN then
		value = OrnamentCodec.POSITION_AXIS_MIN
	elseif value > OrnamentCodec.POSITION_AXIS_MAX then
		value = OrnamentCodec.POSITION_AXIS_MAX
	end

	return value % 65536
end

function OrnamentCodec.decodeInt16(lo, hi)
	local value = lo + hi * 256

	if value >= 32768 then
		return value - 65536
	end

	return value
end

function OrnamentCodec.encodeUInt16(value)
	value = math_floor(tonumber(value) or 0)

	if value < 0 then
		return 0
	elseif value > OrnamentCodec.UINT16_MAX then
		return OrnamentCodec.UINT16_MAX
	end

	return value
end

function OrnamentCodec.pushUInt16(bytes, value)
	local count = #bytes

	bytes[count + 1] = value % 256
	bytes[count + 2] = math_floor(value / 256) % 256
end

function OrnamentCodec.pushUInt32(bytes, value)
	value = math_floor(tonumber(value) or 0)

	if value < 0 then
		value = 0
	end

	local count = #bytes

	bytes[count + 1] = value % 256
	bytes[count + 2] = math_floor(value / 256) % 256
	bytes[count + 3] = math_floor(value / 65536) % 256
	bytes[count + 4] = math_floor(value / 16777216) % 256
end

function OrnamentCodec.getExpectedSize(flags)
	local size = OrnamentCodec.FIXED_SIZE

	if band(flags, OrnamentCodec.FLAG_HAS_YAW) ~= 0 then
		size = size + 2
	end

	if band(flags, OrnamentCodec.FLAG_HAS_PITCH_ROLL) ~= 0 then
		size = size + 4
	end

	if band(flags, OrnamentCodec.FLAG_SCALE_UNIFORM) ~= 0 then
		size = size + 2
	end

	if band(flags, OrnamentCodec.FLAG_SCALE_XYZ) ~= 0 then
		size = size + 6
	end

	if band(flags, OrnamentCodec.FLAG_HAS_TRASH) ~= 0 then
		size = size + 2
	end

	if band(flags, OrnamentCodec.FLAG_HAS_AREA_EXT) ~= 0 then
		size = size + 1
	end

	return size
end

function OrnamentCodec.encode(info)
	local rotationMod = OrnamentCodec.ROTATION_MOD
	local scaleBase = OrnamentCodec.SCALE_BASE
	local rotX = math_floor(tonumber(info.rotX) or 0) % rotationMod
	local rotY = math_floor(tonumber(info.rotY) or 0) % rotationMod
	local rotZ = math_floor(tonumber(info.rotZ) or 0) % rotationMod
	local scaleX = OrnamentCodec.encodeUInt16(info.scaleX or scaleBase)
	local scaleY = OrnamentCodec.encodeUInt16(info.scaleY or scaleBase)
	local scaleZ = OrnamentCodec.encodeUInt16(info.scaleZ or scaleBase)
	local trashId = OrnamentCodec.encodeUInt16(info.trashId or 0)
	local areaId = math_floor(tonumber(info.areaId) or 0)

	if areaId < 0 then
		areaId = 0
	end

	local flags = 0
	local tail = {}

	if rotY ~= 0 then
		flags = bor(flags, OrnamentCodec.FLAG_HAS_YAW)

		OrnamentCodec.pushUInt16(tail, rotY)
	end

	if rotX ~= 0 or rotZ ~= 0 then
		flags = bor(flags, OrnamentCodec.FLAG_HAS_PITCH_ROLL)

		OrnamentCodec.pushUInt16(tail, rotX)
		OrnamentCodec.pushUInt16(tail, rotZ)
	end

	if scaleX == scaleBase and scaleY == scaleBase and scaleZ == scaleBase then
		-- block empty
	elseif scaleX == scaleY and scaleY == scaleZ then
		flags = bor(flags, OrnamentCodec.FLAG_SCALE_UNIFORM)

		OrnamentCodec.pushUInt16(tail, scaleX)
	else
		flags = bor(flags, OrnamentCodec.FLAG_SCALE_XYZ)

		OrnamentCodec.pushUInt16(tail, scaleX)
		OrnamentCodec.pushUInt16(tail, scaleY)
		OrnamentCodec.pushUInt16(tail, scaleZ)
	end

	if trashId ~= 0 then
		flags = bor(flags, OrnamentCodec.FLAG_HAS_TRASH)

		OrnamentCodec.pushUInt16(tail, trashId)
	end

	if info.electricMode == true then
		flags = bor(flags, OrnamentCodec.FLAG_ELECTRIC_MODE)
	end

	if areaId <= OrnamentCodec.AREA_INLINE_MAX then
		flags = bor(flags, lshift(areaId, OrnamentCodec.AREA_SHIFT))
	else
		if areaId > 255 then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("OrnamentCodec.encode areaId out of range, areaId=%s homeId=%s", tostring(areaId), tostring(info.homeId))
			end

			areaId = 255
		end

		flags = bor(flags, OrnamentCodec.FLAG_HAS_AREA_EXT)
		tail[#tail + 1] = areaId
	end

	local bytes = {}

	OrnamentCodec.pushUInt16(bytes, flags)
	OrnamentCodec.pushUInt32(bytes, info.homeId)
	OrnamentCodec.pushUInt16(bytes, OrnamentCodec.encodePositionAxis(info.posX))
	OrnamentCodec.pushUInt16(bytes, OrnamentCodec.encodePositionAxis(info.posY))
	OrnamentCodec.pushUInt16(bytes, OrnamentCodec.encodePositionAxis(info.posZ))

	local tailCount = #tail

	for index = 1, tailCount do
		bytes[OrnamentCodec.FIXED_SIZE + index] = tail[index]
	end

	return phonestcore.base64Encode(string_char(unpack(bytes, 1, OrnamentCodec.FIXED_SIZE + tailCount)))
end

function OrnamentCodec.decode(text)
	if type(text) ~= "string" or text == "" then
		return nil, "empty"
	end

	local bin = phonestcore.base64Decode(text)

	if type(bin) ~= "string" or #bin < OrnamentCodec.FIXED_SIZE then
		return nil, "too short"
	end

	local f1, f2, h1, h2, h3, h4, x1, x2, y1, y2, z1, z2 = string_byte(bin, 1, OrnamentCodec.FIXED_SIZE)
	local flags = f1 + f2 * 256
	local expectedSize = OrnamentCodec.getExpectedSize(flags)

	if #bin ~= expectedSize then
		return nil, string.format("size mismatch, expect %d got %d", expectedSize, #bin)
	end

	local scaleBase = OrnamentCodec.SCALE_BASE
	local info = {
		rotX = 0,
		trashId = 0,
		rotZ = 0,
		rotY = 0,
		homeId = h1 + h2 * 256 + h3 * 65536 + h4 * 16777216,
		posX = OrnamentCodec.decodeInt16(x1, x2),
		posY = OrnamentCodec.decodeInt16(y1, y2),
		posZ = OrnamentCodec.decodeInt16(z1, z2),
		scaleX = scaleBase,
		scaleY = scaleBase,
		scaleZ = scaleBase,
		electricMode = band(flags, OrnamentCodec.FLAG_ELECTRIC_MODE) ~= 0,
		areaId = band(rshift(flags, OrnamentCodec.AREA_SHIFT), 15)
	}
	local offset = OrnamentCodec.FIXED_SIZE + 1
	local lo, hi

	if band(flags, OrnamentCodec.FLAG_HAS_YAW) ~= 0 then
		lo, hi = string_byte(bin, offset, offset + 1)
		info.rotY = lo + hi * 256
		offset = offset + 2
	end

	if band(flags, OrnamentCodec.FLAG_HAS_PITCH_ROLL) ~= 0 then
		lo, hi = string_byte(bin, offset, offset + 1)
		info.rotX = lo + hi * 256
		lo, hi = string_byte(bin, offset + 2, offset + 3)
		info.rotZ = lo + hi * 256
		offset = offset + 4
	end

	if band(flags, OrnamentCodec.FLAG_SCALE_UNIFORM) ~= 0 then
		lo, hi = string_byte(bin, offset, offset + 1)

		local scale = lo + hi * 256

		info.scaleX = scale
		info.scaleY = scale
		info.scaleZ = scale
		offset = offset + 2
	elseif band(flags, OrnamentCodec.FLAG_SCALE_XYZ) ~= 0 then
		lo, hi = string_byte(bin, offset, offset + 1)
		info.scaleX = lo + hi * 256
		lo, hi = string_byte(bin, offset + 2, offset + 3)
		info.scaleY = lo + hi * 256
		lo, hi = string_byte(bin, offset + 4, offset + 5)
		info.scaleZ = lo + hi * 256
		offset = offset + 6
	end

	if band(flags, OrnamentCodec.FLAG_HAS_TRASH) ~= 0 then
		lo, hi = string_byte(bin, offset, offset + 1)
		info.trashId = lo + hi * 256
		offset = offset + 2
	end

	if band(flags, OrnamentCodec.FLAG_HAS_AREA_EXT) ~= 0 then
		info.areaId = string_byte(bin, offset)
		offset = offset + 1
	end

	return info
end

return OrnamentCodec
