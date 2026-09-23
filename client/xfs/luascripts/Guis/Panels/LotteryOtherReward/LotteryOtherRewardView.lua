-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\LotteryOtherReward\\LotteryOtherRewardView.lua

local logger = require("Core.Log.LoggerManager").getLogger("LotteryOtherRewardView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local LotteryOtherRewardView = Class.LightClass("LotteryOtherRewardView", UIView)

function LotteryOtherRewardView:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnClose = objectReference:GetRefValue("btnClose")
	self.btnClose2 = objectReference:GetRefValue("btnClose2")
	self.txtTitle = objectReference:GetRefValue("txtTitle")
	self.listCardUList = objectReference:GetRefValue("listCardUList")
end

function LotteryOtherRewardView:registerObjects()
	function self.listCardUList.luaRenderItem(button, index, data)
		self:renderItem(button, index, data)
	end
end

function LotteryOtherRewardView:initView()
	ClientTextUtils.setText(self.txtTitle, pg.getGameString("LOTTERY_OTHER_REWARD"))
	self.listCardUList:SetList({})
end

function LotteryOtherRewardView:setGroupList(groupList)
	self.listCardUList:SetList(groupList or {})
end

function LotteryOtherRewardView:renderItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")
	local listUList = objectReference:GetRefValue("listUList")

	ClientTextUtils.setText(txtNameUBaseText, pg.getGameString("LOTTERY_REWARD_RARITY_" .. tostring(data.rarity)))

	function listUList.luaRenderItem(itemButton, itemIndex, itemData)
		LuaUIUtils.renderRewardItem(itemButton, itemData)
	end

	listUList:SetList(data.itemList or {})
end

return LotteryOtherRewardView
