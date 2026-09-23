-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\LotteryRewardShare\\LotteryRewardShareView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LotteryRewardShareView = Class.LightClass("LotteryRewardShareView", UIView)

function LotteryRewardShareView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.closeBtn = objectReference:GetRefValue("closeBtn")
	self.root = objectReference:GetRefValue("root")
	self.txtDesc = objectReference:GetRefValue("txtDesc")
	self.btnShare = objectReference:GetRefValue("btnShare")
	self.txtBtnShare = objectReference:GetRefValue("txtBtnShare")
	self.txtTips = objectReference:GetRefValue("txtTips")
end

function LotteryRewardShareView:initView()
	ClientTextUtils.setText(self.txtDesc, pg.getGameString("LOTTERY_SHARE_TITLE"))
	ClientTextUtils.setText(self.txtBtnShare, pg.getGameString("LOTTERY_SHARE_CONFIRM"))
	ClientTextUtils.setText(self.txtTips, pg.getGameString("LOTTERY_SHARE_TIPS"))
end

function LotteryRewardShareView:setInfo(info)
	info = info or {}

	if info.tips ~= nil then
		ClientTextUtils.setText(self.txtTips, info.tips)
	end
end

return LotteryRewardShareView
