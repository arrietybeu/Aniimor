-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\HomeCampUtils.lua

local HomeCampConst = require("Common.Const.HomeCampConst")
local lume = require("Core.Common.lume")
local HomeCampUtils = {}

function HomeCampUtils.buildLineSummary(lineInfo, overrides)
	overrides = overrides or {}

	local loginUids = lineInfo.loginUids or {}
	local enterUids = lineInfo.enterUids or {}

	return {
		lineUid = overrides.lineUid or lineInfo.lineUid,
		lineId = overrides.lineId or lineInfo.lineId or 0,
		staticId = overrides.staticId or lineInfo.staticId or 0,
		areaId = overrides.areaId or lineInfo.areaId or 0,
		bucketId = overrides.bucketId or lineInfo.bucketId or -1,
		sceneId = overrides.sceneId or lineInfo.sceneId or 0,
		spaceKey = overrides.spaceKey or lineInfo.spaceKey or "",
		loginCount = lineInfo.loginCount or lume.count(loginUids),
		enterCount = lineInfo.enterCount or #enterUids,
		loginUids = loginUids,
		enterUids = enterUids,
		displayCode = lineInfo.displayCode or "",
		idStr = lineInfo.idStr or "",
		displaySeq = lineInfo.displaySeq or 0,
		band = lineInfo.band or "empty",
		ownerEpoch = overrides.ownerEpoch or lineInfo.ownerEpoch or 0,
		isPrivate = lineInfo.isPrivate or false,
		ownerUid = lineInfo.ownerUid or "",
		permissions = lineInfo.permissions or 0,
		pendingDestroyTs = lineInfo.pendingDestroyTs or 0,
		destroyAfterTs = lineInfo.destroyAfterTs or 0,
		destroyReason = lineInfo.destroyReason or "",
		markOfflineCount = overrides.markOfflineCount or lineInfo.markOfflineCount or 0
	}
end

local STATE_ACTIVE = HomeCampConst.LINE_STATUS_ACTIVE
local STATE_LOCKED = HomeCampConst.LINE_STATUS_LOCKED
local STATE_MIGRATING = HomeCampConst.LINE_STATUS_MIGRATING_OUT
local STATE_DEPRECATED = HomeCampConst.LINE_STATUS_DEPRECATED

local function _statusOf(lineInfo)
	return lineInfo and lineInfo.status or STATE_ACTIVE
end

function HomeCampUtils.isLineActive(lineInfo)
	return _statusOf(lineInfo) == STATE_ACTIVE
end

function HomeCampUtils.isLineLocked(lineInfo)
	return _statusOf(lineInfo) == STATE_LOCKED
end

function HomeCampUtils.isPublicLinePendingDestroy(lineInfo)
	return lineInfo ~= nil and not lineInfo.isPrivate and (lineInfo.destroyAfterTs or 0) > 0
end

function HomeCampUtils.isLineDiscoverable(lineInfo)
	return _statusOf(lineInfo) == STATE_ACTIVE and not HomeCampUtils.isPublicLinePendingDestroy(lineInfo)
end

function HomeCampUtils.isLineJoinable(lineInfo)
	return _statusOf(lineInfo) == STATE_ACTIVE and not HomeCampUtils.isPublicLinePendingDestroy(lineInfo)
end

function HomeCampUtils.canOwnerActivateLocked(lineInfo, uid)
	return lineInfo ~= nil and _statusOf(lineInfo) == STATE_LOCKED and lineInfo.ownerUid == uid
end

function HomeCampUtils.needResolvePrivateLine(lineInfo)
	local s = _statusOf(lineInfo)

	return s == STATE_MIGRATING or s == STATE_DEPRECATED
end

return HomeCampUtils
