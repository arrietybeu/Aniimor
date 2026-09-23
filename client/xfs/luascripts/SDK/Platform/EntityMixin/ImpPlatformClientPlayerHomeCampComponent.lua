-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\EntityMixin\\ImpPlatformClientPlayerHomeCampComponent.lua

local PlatformNoticeUtils = require("SDK.Platform.PlatformNoticeUtils")
local NoticeDef = require("Common.NoticeDef")
local M = {}
local PlatformHomeCampEntryFilterService = require("SDK.Platform.PlatformHomeCampEntryFilterService")

function M.canEnterHomeCamp(_, uid, options)
	options = options or {}

	local allowed, decision, context = PlatformHomeCampEntryFilterService:canEnterHomeCamp(uid)

	if decision == PlatformHomeCampEntryFilterService.Decision.Pending then
		return false
	end

	if not allowed then
		PlatformNoticeUtils.showTextTipById(NoticeDef.CANNOT_ENTER_HOMECAMP)

		return false
	end

	return true
end

return M
