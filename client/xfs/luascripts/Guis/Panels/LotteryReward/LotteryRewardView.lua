-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\LotteryReward\\LotteryRewardView.lua

local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local RedDotConst = require("Const.RedDotConst")
local LotteryRewardView = Class.LightClass("LotteryRewardView", UIView)

function LotteryRewardView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.itemList = objectReference:GetRefValue("itemList")
	self.closeBtn = objectReference:GetRefValue("closeBtn")
	self.root = objectReference:GetRefValue("root")
	self.txtTitle = objectReference:GetRefValue("txtTitle")
	self.txtTips = objectReference:GetRefValue("txtTips")
	self.doubleRewardUWidget = objectReference:GetRefValue("doubleRewardUWidget")
	self.btnShare = objectReference:GetRefValue("btnShare")
	self.btnConfirm = objectReference:GetRefValue("btnConfirm")
	self.discountUWidget = objectReference:GetRefValue("discountUWidget")
	self.txtDiscount = objectReference:GetRefValue("txtDiscount")
	self.imgConsume = objectReference:GetRefValue("imgConsume")
	self.txtConsume = objectReference:GetRefValue("txtConsume")
	self.txtBtnConfirm = objectReference:GetRefValue("txtBtnConfirm")
end

function LotteryRewardView:registerObjects()
	function self.itemList.luaRenderItem(button, index, data)
		LuaUIUtils.renderRewardItem(button, data, tostring(data.num or 1))
	end
end

function LotteryRewardView:initView()
	self.itemList:SetList({})
	self.btnShare:SetActive(false)
	self.discountUWidget:SetActive(false)
end

function LotteryRewardView:setInfo(viewData)
	viewData = viewData or {}

	local canShare = viewData.canShare == true
	local curCanShareCount = tonumber(viewData.curCanShareCount) or 0

	ClientTextUtils.setText(self.txtTitle, viewData.title or "")
	ClientTextUtils.setText(self.txtTips, viewData.tips or "")
	self.itemList:SetList(viewData.itemList or {})
	self.btnShare:SetActive(canShare)
	pg.global.setRedDot(RedDotConst.RedDotPath.LOTTERY_REWARD_SHARE_COUNT, self.btnShare, canShare and curCanShareCount > 1, RedDotConst.RedDotStyle.NUM, curCanShareCount)
	self.discountUWidget:SetActive(viewData.hasDiscount == true)
	ClientTextUtils.setText(self.txtDiscount, viewData.discountText or "")

	self.imgConsume.url = viewData.consumeItemId and LuaUIUtils.getIconByItemId(viewData.consumeItemId) or ""

	ClientTextUtils.setText(self.txtConsume, viewData.consumeNum or 0)
end

return LotteryRewardView
