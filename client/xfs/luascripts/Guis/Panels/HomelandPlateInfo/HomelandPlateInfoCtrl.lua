-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandPlateInfo\\HomelandPlateInfoCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local HomelandPlateInfoCtrl = Class.LightClass("HomelandPlateInfoCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local Utils = require("Common.Utils.Utils")
local ClientConst = require("Const.ClientConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local NoticeDef = require("Common.NoticeDef")
local ItemUtils = require("Common.Utils.ItemUtils")
local Const = require("Common.Const.Const")
local HomelandConfigData = require("Data.homeland_config_data")
local CustomTriggerData = require("Data.custom_trigger_data")
local AudioConst = require("Const.AudioConst")

HomelandPlateInfoCtrl.messages = {
	[MessageName.HOMELAND_ZONE_UNLOCK] = {
		"onZoneUnlock",
		true
	}
}

function HomelandPlateInfoCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.info = info
	self.zoneId = info.zoneId
	self.homeCoinId = HomelandConfigData.homeCurrencyId or 1010

	self:initUI()
end

function HomelandPlateInfoCtrl:showUnlockConditionNotMet(zoneData, zoneConfigData)
	local triggerData = CustomTriggerData[zoneData.unlockCondition]

	if triggerData then
		for _, condition in ipairs(triggerData.condition) do
			if condition[1] == "HOME_CAR_LEVEL" and pg.me:getHomeCarLevel() < condition[5] then
				pg.global.showBubbleMessage(NoticeDef.HOME_NOT_ENOUGH_CAR_LEVEL, condition[5])

				return
			end

			if condition[1] == "HOME_GROUND_UNLOCK" and not pg.game.home:isHomelandZoneUnlock(condition[2]) then
				local previousZoneData = zoneConfigData[condition[2]]

				if previousZoneData then
					pg.global.showBubbleMessage(NoticeDef.HOME_PRE_ZONE_NOT_UNLOCK, previousZoneData.showName or previousZoneData.name)

					return
				end
			end
		end
	end

	pg.global.showBubbleMessage(NoticeDef.HOME_NOT_ENOUGH_CAR_LEVEL)
end

function HomelandPlateInfoCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:close()
	end

	function self.view.btnOKUButton.luaClick()
		local HomelandZoneUnlockConfigData = HomeLandUtils.getHomelandZoneUnlockData()
		local zoneData = HomelandZoneUnlockConfigData[self.zoneId]

		if zoneData.canUnlock == nil or zoneData.canUnlock == 0 then
			pg.global.showBubbleMessage(NoticeDef.HOME_BLOCK_NOT_OPEN)

			return
		end

		if zoneData.unlockCondition and not pg.me.triggerMap:isCompleteOrMeetCondition(zoneData.unlockCondition) then
			self:showUnlockConditionNotMet(zoneData, HomelandZoneUnlockConfigData)

			return
		end

		for _, costInfo in pairs(zoneData.unlockCost) do
			local count = costInfo[2]
			local hasCount = ItemUtils.getItemCountById(pg.me, costInfo[1])

			if hasCount < count then
				local noticeId = zoneData.areaId == Const.HOMELAND_AREA_TYPE.BUILD and NoticeDef.HOMELAND_CANNOT_UNLOCK_AREA1 or NoticeDef.HOME_NOT_ENOUGH_PROPS

				pg.global.showBubbleMessage(noticeId)

				return
			end
		end

		pg.space:unlockHomelandZone(self.zoneId)
	end
end

function HomelandPlateInfoCtrl:initUI()
	local itemData = {}
	local HomelandZoneUnlockConfigData = HomeLandUtils.getHomelandZoneUnlockData()
	local zoneData = HomelandZoneUnlockConfigData[self.zoneId]
	local content = self.view.scrollRectUScrollRect.content:GetComponent("UBaseText")

	ClientTextUtils.setTextWithId(content, zoneData.desc)
	ClientTextUtils.setTextWithId(self.view.txtTitleTextPlus, zoneData.name)

	local enableUnlock = true

	if zoneData.unlockCondition then
		enableUnlock = pg.me.triggerMap:isCompleteOrMeetCondition(zoneData.unlockCondition)
	end

	self.view.btnOKUButton:TryChangePage("button", enableUnlock and 0 or 4)

	function self.view.listCurrencyUList.luaRenderItem(button, index, data)
		LuaUIUtils.setTopCurrencyItem(button, data.itemId)
	end

	if zoneData.unlockCost then
		local costData = {}
		local currencyItemIdSet = {}

		for _, costValue in pairs(zoneData.unlockCost) do
			local itemId = costValue[1]

			if itemId and not currencyItemIdSet[itemId] then
				currencyItemIdSet[itemId] = true

				table.insert(itemData, {
					itemId = itemId
				})
			end

			local costInfo = {
				itemId = costValue[1],
				count = costValue[2]
			}

			table.insert(costData, costInfo)
		end

		function self.view.listCoinUList.luaRenderItem(button, index, data)
			LuaUIUtils.setCostCurrencyItem(button, data.itemId, data.count, true)
		end

		self.view.listCoinUList:SetList(costData)
	end

	if #itemData == 0 then
		table.insert(itemData, {
			itemId = self.homeCoinId
		})
	end

	self.view.listCurrencyUList:SetList(itemData)
	self.view.itemListUList:SetActive(false)
	self.view.textUSDFText:SetActive(false)
end

function HomelandPlateInfoCtrl:onZoneUnlock()
	pg.game.audio:triggerEvent(AudioConst.EVENT_HOME_AREA_UNLOCK)
	pg.global.showBubbleMessage(NoticeDef.HOME_BLOCK_UNLOCK_SUCCESS)
	self:close()
end

function HomelandPlateInfoCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function HomelandPlateInfoCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function HomelandPlateInfoCtrl:onShow()
	return
end

function HomelandPlateInfoCtrl:onHide()
	return
end

return HomelandPlateInfoCtrl
