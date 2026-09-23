-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\EntityMixin\\ImpPlatformMarkShareSystem.lua

local M = {}
local PlatformImageMaskService = require("SDK.Platform.PlatformImageMaskService")

function M:onCtor()
	self.pendingUgcRefreshByUid = {}
end

function M:onDestroy()
	self.pendingUgcRefreshByUid = nil
end

function M:checkInfoStampVisible(infoStampValue)
	local playerInfo = pg.game.chat and pg.game.chat.getPlayerInfo and pg.game.chat:getPlayerInfo(infoStampValue.uid) or nil
	local ugcDecision, ugcVisible = PlatformImageMaskService:checkImageVisibilityNow({
		action = "ugc_mark_share_marker",
		uid = infoStampValue.uid,
		playerInfo = playerInfo
	})

	if ugcDecision ~= "pending" then
		return ugcVisible ~= false
	end

	if not self.pendingUgcRefreshByUid[infoStampValue.uid] then
		self.pendingUgcRefreshByUid[infoStampValue.uid] = true

		PlatformImageMaskService:resolveImageVisibility({
			action = "ugc_mark_share_marker",
			uid = infoStampValue.uid,
			playerInfo = playerInfo
		}, function()
			if self.pendingUgcRefreshByUid then
				self.pendingUgcRefreshByUid[infoStampValue.uid] = nil
			end

			if pg and pg.game and pg.game.markShare == self then
				self:refreshAroundInfoStamp()
			end
		end)
	end

	return false
end

return M
