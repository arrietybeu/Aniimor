-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\PlatformPlayerInfoQueryService.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local PlatformPlayerInfoQueryService = {}

PlatformPlayerInfoQueryService.RequestPurpose = {
	ShellJoinUGCOwner = "shell_join_ugc_owner",
	TopLogoUGCOwner = "top_logo_ugc_owner",
	ShellJoinHomeCampOwner = "shell_join_home_camp_owner"
}
PlatformPlayerInfoQueryService.Reason = {
	Superseded = "superseded",
	Cache = "cache",
	QuerySkippedNoCache = "query_skipped_no_cache",
	RefreshedNoCache = "refreshed_no_cache",
	QueryUnavailable = "query_unavailable",
	Refreshed = "refreshed",
	Pending = "pending"
}
PlatformPlayerInfoQueryService.state = {
	pendingByUid = {}
}

function PlatformPlayerInfoQueryService:_buildPendingKey(playerUid)
	return tostring(playerUid or "")
end

function PlatformPlayerInfoQueryService:_getChat()
	return pg and pg.game and pg.game.chat or nil
end

function PlatformPlayerInfoQueryService:_readCachedPlayerInfo(chat, playerUid)
	if chat == nil or type(chat.getPlayerInfo) ~= "function" then
		return nil
	end

	return chat:getPlayerInfo(tostring(playerUid or ""))
end

function PlatformPlayerInfoQueryService:_invokeCallback(callback, ok, playerInfo, reason)
	if type(callback) == "function" then
		callback(ok == true, playerInfo, reason)
	end
end

function PlatformPlayerInfoQueryService:_appendPendingCallback(pending, purpose, requestKey, callback)
	pending.callbacks[#pending.callbacks + 1] = {
		purpose = purpose,
		requestKey = requestKey,
		callback = callback
	}
end

function PlatformPlayerInfoQueryService:_finishPending(key, ok, playerInfo, reason)
	local pending = PlatformPlayerInfoQueryService.state.pendingByUid[key]

	if pending == nil then
		return
	end

	PlatformPlayerInfoQueryService.state.pendingByUid[key] = nil

	for _, entry in ipairs(pending.callbacks or EMPTY_TABLE) do
		self:_invokeCallback(entry.callback, ok, playerInfo, reason)
	end
end

function PlatformPlayerInfoQueryService:Clear(playerUid, purpose, requestKey)
	local uid = tostring(playerUid or "")
	local requestPurpose = tostring(purpose or "")

	if string.isNilOrEmpty(uid) or string.isNilOrEmpty(requestPurpose) or requestKey == nil then
		return false
	end

	local pending = PlatformPlayerInfoQueryService.state.pendingByUid[self:_buildPendingKey(uid)]

	if pending == nil then
		return false
	end

	local cleared = false
	local callbacks = pending.callbacks or {}

	for index = #callbacks, 1, -1 do
		local entry = callbacks[index]

		if entry.purpose == requestPurpose and entry.requestKey == requestKey then
			table.remove(callbacks, index)

			cleared = true
		end
	end

	return cleared
end

function PlatformPlayerInfoQueryService:requestLatest(playerUid, purpose, options, callback)
	local uid = tostring(playerUid or "")
	local requestPurpose = tostring(purpose or "")

	if string.isNilOrEmpty(uid) or string.isNilOrEmpty(requestPurpose) then
		self:_invokeCallback(callback, false, nil, self.Reason.QueryUnavailable)

		return false
	end

	options = options or {}

	local key = self:_buildPendingKey(uid)
	local pending = PlatformPlayerInfoQueryService.state.pendingByUid[key]

	if pending ~= nil then
		self:_appendPendingCallback(pending, requestPurpose, options.requestKey, callback)

		return true
	end

	local chat = self:_getChat()

	if chat == nil or type(chat.getPlayerInfoFromServer) ~= "function" then
		self:_invokeCallback(callback, false, nil, self.Reason.QueryUnavailable)

		return false
	end

	local queryType = options.queryType

	pending = {
		callbacks = {}
	}

	self:_appendPendingCallback(pending, requestPurpose, options.requestKey, callback)

	PlatformPlayerInfoQueryService.state.pendingByUid[key] = pending

	local querySent = chat:getPlayerInfoFromServer(uid, queryType, function()
		local ownerPlayerInfo = PlatformPlayerInfoQueryService:_readCachedPlayerInfo(chat, uid)

		if ownerPlayerInfo ~= nil then
			PlatformPlayerInfoQueryService:_finishPending(key, true, ownerPlayerInfo, PlatformPlayerInfoQueryService.Reason.Refreshed)

			return
		end

		PlatformPlayerInfoQueryService:_finishPending(key, false, nil, PlatformPlayerInfoQueryService.Reason.RefreshedNoCache)
	end, options.extraInfo, options.force == true)

	if PlatformPlayerInfoQueryService.state.pendingByUid[key] == nil then
		return querySent == true
	end

	if querySent == true then
		return true
	end

	PlatformPlayerInfoQueryService.state.pendingByUid[key] = nil

	local cachedPlayerInfo = self:_readCachedPlayerInfo(chat, uid)

	if cachedPlayerInfo ~= nil then
		for _, entry in ipairs(pending.callbacks or EMPTY_TABLE) do
			self:_invokeCallback(entry.callback, true, cachedPlayerInfo, self.Reason.Cache)
		end

		return false
	end

	for _, entry in ipairs(pending.callbacks or EMPTY_TABLE) do
		self:_invokeCallback(entry.callback, false, nil, self.Reason.QuerySkippedNoCache)
	end

	return false
end

function PlatformPlayerInfoQueryService:_resetForTests()
	PlatformPlayerInfoQueryService.state.pendingByUid = {}
end

return PlatformPlayerInfoQueryService
