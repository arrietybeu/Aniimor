-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\HomeCampLineUid.lua

local HomeCampConst = require("Common.Const.HomeCampConst")
local HomeCampLineUid = {}
local SEQ_BITS = HomeCampConst.LINEUID_SEQ_BITS
local BUCKET_BITS = HomeCampConst.LINEUID_BUCKET_BITS
local AREA_BITS = HomeCampConst.LINEUID_AREA_BITS
local VER_BITS = HomeCampConst.LINEUID_VER_BITS
local SEQ_SHIFT = HomeCampConst.LINEUID_SEQ_SHIFT
local BUCKET_SHIFT = HomeCampConst.LINEUID_BUCKET_SHIFT
local AREA_SHIFT = HomeCampConst.LINEUID_AREA_SHIFT
local VER_SHIFT = HomeCampConst.LINEUID_VER_SHIFT
local SEQ_MASK = HomeCampConst.LINEUID_SEQ_MASK
local BUCKET_MASK = HomeCampConst.LINEUID_BUCKET_MASK
local AREA_MASK = HomeCampConst.LINEUID_AREA_MASK
local VER_MASK = HomeCampConst.LINEUID_VER_MASK
local math_floor = math.floor
local math_fmod = math.fmod
local MAX_LINE_ID_SEQ = HomeCampConst.MAX_LINE_ID_SEQ
local SOFT_LIMIT_LINE_ID_SEQ = HomeCampConst.SOFT_LIMIT_LINE_ID_SEQ

function HomeCampLineUid.isLineIdSeqEncodable(seq)
	return seq >= 0 and seq < MAX_LINE_ID_SEQ
end

function HomeCampLineUid.isLineIdSeqWithinSoftLimit(seq)
	return seq < SOFT_LIMIT_LINE_ID_SEQ
end

function HomeCampLineUid.encode(ver, areaId, bucketId, seq)
	return ver * 2^VER_SHIFT + areaId * 2^AREA_SHIFT + bucketId * 2^BUCKET_SHIFT + seq
end

function HomeCampLineUid.decode(lineUid)
	local seq = math_fmod(lineUid, 2^BUCKET_SHIFT)
	local remainder = math_floor(lineUid / 2^BUCKET_SHIFT)
	local bucketId = math_fmod(remainder, 2^BUCKET_BITS)

	remainder = math_floor(remainder / 2^BUCKET_BITS)

	local areaId = math_fmod(remainder, 2^AREA_BITS)

	remainder = math_floor(remainder / 2^AREA_BITS)

	local ver = math_fmod(remainder, 2^VER_BITS)

	return ver, areaId, bucketId, seq
end

function HomeCampLineUid.getBucketId(lineUid)
	return math_fmod(math_floor(lineUid / 2^BUCKET_SHIFT), 2^BUCKET_BITS)
end

function HomeCampLineUid.getAreaId(lineUid)
	return math_fmod(math_floor(lineUid / 2^AREA_SHIFT), 2^AREA_BITS)
end

function HomeCampLineUid.getVer(lineUid)
	return math_fmod(math_floor(lineUid / 2^VER_SHIFT), 2^VER_BITS)
end

function HomeCampLineUid.getSeq(lineUid)
	return math_fmod(lineUid, 2^BUCKET_SHIFT)
end

function HomeCampLineUid.getRouteKey(tenantKey, lineUid)
	local areaId = HomeCampLineUid.getAreaId(lineUid)
	local bucketId = HomeCampLineUid.getBucketId(lineUid)

	return string.format("%s:%d:%d", tenantKey, areaId, bucketId)
end

function HomeCampLineUid.create(areaId, bucketId, seq)
	return HomeCampLineUid.encode(HomeCampConst.LINEUID_VERSION, areaId, bucketId, seq)
end

function HomeCampLineUid.toStr(lineUid)
	return string.format("%.0f", lineUid)
end

return HomeCampLineUid
