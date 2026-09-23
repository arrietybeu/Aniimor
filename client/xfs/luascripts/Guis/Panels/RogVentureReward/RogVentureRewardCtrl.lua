-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\RogVentureReward\\RogVentureRewardCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local RogueUtils = require("Utils.RogueUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ItemConst = require("Common.Const.ItemConst")
local RogVentureRewardCtrl = Class.LightClass("RogVentureRewardCtrl", UICtrl)

function RogVentureRewardCtrl:onOpen(info)
	if not RogueUtils.isInRogueSpace() then
		self:close()

		return
	end

	function self.view.btnClose.luaClick()
		self:close()
	end

	self.buffIdList = info.buffIdList

	self:refreshListShow(info)
end

function RogVentureRewardCtrl:onDestroy()
	UICtrl.onDestroy(self)

	if not RogueUtils.isInRogueSpace() then
		return
	end

	if self.buffIdList and #self.buffIdList > 0 then
		pg.me.space:onGetBuff(self.buffIdList)
	end

	pg.me.space:resumeCacheInfo()
end

function RogVentureRewardCtrl:refreshListShow(info)
	local dataList = {}

	table.insert(dataList, {
		isSuper = false,
		tIndex = 1
	})

	if info.coinCount > 0 then
		table.insert(dataList, {
			type = 0,
			tIndex = 0,
			id = ItemConst.ITEM_SPECIAL_ROGUE_COIN,
			num = info.coinCount
		})
	end

	for _, buffId in ipairs(info.buffIdList) do
		table.insert(dataList, {
			type = 2,
			num = 1,
			tIndex = 0,
			id = buffId
		})
	end

	if info.superRewardDropId > 0 then
		table.insert(dataList, {
			isSuper = true,
			tIndex = 1
		})

		local superRewards = LuaUIUtils.getRewardItemByDropId(info.superRewardDropId)

		for _, reward in ipairs(superRewards) do
			table.insert(dataList, reward)
		end
	end

	function self.view.list.luaRenderItem(button, idx, data)
		if data.tIndex == 0 then
			LuaUIUtils.renderRewards(button, idx, data)
		elseif data.tIndex == 1 then
			local objectReference = button:GetComponent("ObjectReference")
			local txtName = objectReference:GetRefValue("txtName")

			ClientTextUtils.setText(txtName, pg.getGameString(data.isSuper and "ROGUE_DIEC_EASTER_EGG_REWARD" or "ROGUE_DIEC_REWARD"))
		end
	end

	self.view.list:SetList(dataList)
end

return RogVentureRewardCtrl
