-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\EntityMixin\\ImpPlatformClientPlayerHomelandComponent.lua

local PlatformNoticeUtils = require("SDK.Platform.PlatformNoticeUtils")
local NoticeDef = require("Common.NoticeDef")
local M = {}
local PlatformHomeCampEntryFilterService = require("SDK.Platform.PlatformHomeCampEntryFilterService")

function M.canEnterHomeland(_, uid, options)
	options = options or {}

	local allowed, _, context = PlatformHomeCampEntryFilterService:canEnterHomeCamp(uid)

	if not allowed then
		local input = pg and pg.game and pg.game.input
		local hudProcessor = input and input.getInputMapProcessor and input:getInputMapProcessor("Hud")

		if hudProcessor and hudProcessor.cancelNextGamepadMenuAction then
			hudProcessor:cancelNextGamepadMenuAction()
		end

		PlatformNoticeUtils.showTextTipById(NoticeDef.CANNOT_ENTER_HOMECAMP)

		return false
	end

	return true
end

return M
