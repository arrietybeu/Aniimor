-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\LotteryRewardShare\\LotteryRewardShareCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local Utils = require("Common.Utils.Utils")
local ChatSystem = require("GameApp.Chat.ChatSystem")
local LotteryRewardShareModel = require("Guis.Panels.LotteryRewardShare.LotteryRewardShareModel")
local LotteryRewardShareCtrl = Class.LightClass("LotteryRewardShareCtrl", UICtrl)

LotteryRewardShareCtrl.modelClz = LotteryRewardShareModel
LotteryRewardShareCtrl.messages = {}

function LotteryRewardShareCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function LotteryRewardShareCtrl:addListener()
	function self.view.closeBtn.luaClick()
		self:dismiss()
	end

	function self.view.btnShare.luaClick()
		self:shareReward()
	end
end

function LotteryRewardShareCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self._openInfo = Utils.isTable(info) and info or {}

	self.view:setInfo(self._openInfo)
end

function LotteryRewardShareCtrl:shareReward()
	local bgUrl = self.model:getGiftUrl(self._openInfo and self._openInfo.drawId or nil)
	local sent = pg.game.chat:sendGiftMessage(pg.game.chat.channelType.Friend, pg.game.chat.channelType.Friend, ChatSystem.giftType.Lottery, bgUrl, nil, false)

	if sent ~= true then
		return
	end

	pg.global.ui.tips:showTextTip(pg.getGameString("LOTTERY_SHARE_DONE_TIPS"))

	local shareInfo = self._openInfo
	local shareCallback = self._openInfo and self._openInfo.shareCallback or nil

	self:dismiss()

	if type(shareCallback) == "function" then
		shareCallback(shareInfo)
	end
end

function LotteryRewardShareCtrl:onDestroy()
	self._openInfo = nil

	UICtrl.onDestroy(self)
end

return LotteryRewardShareCtrl
