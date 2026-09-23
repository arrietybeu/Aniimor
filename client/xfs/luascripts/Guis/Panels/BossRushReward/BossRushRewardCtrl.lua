-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\BossRushReward\\BossRushRewardCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("BossRushRewardCtrl")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local BossRushRewardCtrl = Class.LightClass("BossRushRewardCtrl", UICtrl)
local BossRushUtils = require("Utils.BossRushUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local BossRushBuffReward = require("Data.bossrush_reward_data")

function BossRushRewardCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.isOpen = BossRushUtils.checkIsOpen()
	self.cycleId = self.isOpen and pg.me.curBossRushCycleId or pg.me.nextBossRushCycleId
	self.minShowCount = 5

	self:initUI()
end

function BossRushRewardCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:close()
	end
end

function BossRushRewardCtrl:initUI()
	local score = 0
	local star = 0

	if self.isOpen then
		score, star = BossRushUtils.getCurCycleTotalScore()
	end

	function self.view.rewardUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local textUBaseText = objectReference:GetRefValue("textUBaseText")
		local listUList = objectReference:GetRefValue("listUList")

		textUBaseText.text = star .. "/" .. data.needStar

		local hasGet = star >= data.needStar

		LuaUIUtils.setRewardListByDropId(listUList, data.rewardDropId, self.minShowCount, hasGet, nil, nil, function()
			self:close()
		end)
	end

	local data = {}

	for index, rewardInfo in pairs(BossRushBuffReward) do
		local dropId = self:getDropId(rewardInfo)

		if dropId and dropId > 0 then
			table.insert(data, {
				needStar = index,
				rewardDropId = dropId
			})
		end
	end

	table.sort(data, function(a, b)
		return a.needStar < b.needStar
	end)
	self.view.rewardUList:SetList(data)
end

function BossRushRewardCtrl:getDropId(rewardInfo)
	for k, d in pairs(rewardInfo) do
		if k <= self.cycleId then
			for kk, dd in pairs(d) do
				if kk >= self.cycleId then
					return dd.awardId
				end
			end
		end
	end
end

function BossRushRewardCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function BossRushRewardCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function BossRushRewardCtrl:onShow()
	return
end

function BossRushRewardCtrl:onHide()
	return
end

return BossRushRewardCtrl
