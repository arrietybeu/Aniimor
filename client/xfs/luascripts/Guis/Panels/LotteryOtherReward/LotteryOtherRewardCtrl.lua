-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\LotteryOtherReward\\LotteryOtherRewardCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local Utils = require("Common.Utils.Utils")
local LotteryOtherRewardModel = require("Guis.Panels.LotteryOtherReward.LotteryOtherRewardModel")
local LotteryOtherRewardCtrl = Class.LightClass("LotteryOtherRewardCtrl", UICtrl)

LotteryOtherRewardCtrl.modelClz = LotteryOtherRewardModel
LotteryOtherRewardCtrl.messages = {}

function LotteryOtherRewardCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function LotteryOtherRewardCtrl:addListener()
	function self.view.btnClose.luaClick()
		self:dismiss()
	end

	function self.view.btnClose2.luaClick()
		self:dismiss()
	end
end

function LotteryOtherRewardCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function LotteryOtherRewardCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	local drawId = Utils.isTable(info) and info.drawId or nil

	self.view:setGroupList(self.model:getRewardGroupList(drawId))
end

function LotteryOtherRewardCtrl:onShow()
	return
end

function LotteryOtherRewardCtrl:onHide()
	return
end

return LotteryOtherRewardCtrl
