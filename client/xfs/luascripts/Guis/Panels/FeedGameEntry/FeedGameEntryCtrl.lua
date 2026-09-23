-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FeedGameEntry\\FeedGameEntryCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local GlobalData = require("Core.Client.GlobalData")
local RedDotConst = require("Const.RedDotConst")
local FEED_GAME_WIKI_URL = "https://wiki.yimo.com/"
local FEED_GAME_ENTRY_RED_DOT = "feedGameEntry"
local FeedGameEntryCtrl = Class.LightClass("FeedGameEntryCtrl", UICtrl)

function FeedGameEntryCtrl:addListener()
	function self.view.entryUButton.luaClick()
		local offlinePlayer = GlobalData.Player

		if offlinePlayer and offlinePlayer.isOfflineMainPlayer then
			offlinePlayer.feedGameEntryUnread = false
		end

		self:refreshRedDot()
		pg.global.sdkManager:showWebView({
			url = FEED_GAME_WIKI_URL,
			parameters = {
				navigationType = 0
			}
		})
	end
end

function FeedGameEntryCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:refreshRedDot()
end

function FeedGameEntryCtrl:refreshRedDot()
	local offlinePlayer = GlobalData.Player
	local showRedDot = offlinePlayer and offlinePlayer.isOfflineMainPlayer and offlinePlayer.feedGameEntryUnread == true

	pg.global.setRedDot(FEED_GAME_ENTRY_RED_DOT, self.view.entryUButton, showRedDot, RedDotConst.RedDotStyle.POINT)
end

return FeedGameEntryCtrl
