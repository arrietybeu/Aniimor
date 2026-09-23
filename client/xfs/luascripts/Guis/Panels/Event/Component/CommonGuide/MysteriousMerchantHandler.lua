-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\Component\\CommonGuide\\MysteriousMerchantHandler.lua

local Class = require("Core.Framework.Class")
local GuideHandlerBase = require("Guis.Panels.Event.Component.CommonGuide.GuideHandlerBase")
local EventCommonGuideData = require("Data.event_common_guide_data")
local NoticeDef = require("Common.NoticeDef")
local ShopCommodityData = require("Data.shop_commodity_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local ActivityConst = require("Common.Const.ActivityConst")
local logger = LoggerManager.getLogger("EventCommonGuideComponent")
local MysteriousMerchantHandler = Class.LightClass("MysteriousMerchantHandler", GuideHandlerBase)

function MysteriousMerchantHandler:getOwnedRefKeys()
	return {}
end

function MysteriousMerchantHandler:ctor(comp)
	GuideHandlerBase.ctor(self, comp)

	self._merchantRequestToken = 0
end

function MysteriousMerchantHandler:onFindObjects(objectReference)
	return
end

function MysteriousMerchantHandler:onRefresh()
	self.comp.rewardContentUWidget:SetActive(true)
	self.comp.listRewardUList:SetActive(true)

	self._merchantRequestToken = self._merchantRequestToken + 1

	local requestToken = self._merchantRequestToken
	local currentEventId = self.comp.eventId
	local currentSerial = self.comp.prepareEnterSerial

	pg.me:serverMsg("RPC_CS_GetShopRefreshList", 56, function(err, idList)
		if requestToken ~= self._merchantRequestToken or self.comp.isDestroyed or self.comp.prepareEnterSerial ~= currentSerial or self.comp.eventId ~= currentEventId then
			if LoggerManager.checkLogger(LoggerConst.INFO) then
				logger:info("RPC_CS_GetShopRefreshList response dropped: token=%s current=%s isDestroyed=%s serial=%s/%s eventId=%s/%s", tostring(requestToken), tostring(self._merchantRequestToken), tostring(self.comp.isDestroyed), tostring(currentSerial), tostring(self.comp.prepareEnterSerial), tostring(currentEventId), tostring(self.comp.eventId))
			end

			return
		end

		self:_renderMysteriousMerchantList(err, idList, false)
	end)
end

function MysteriousMerchantHandler:_renderMysteriousMerchantList(err, idList, isAsync)
	local commonGuideData = EventCommonGuideData[self.comp.commonGuideId]

	if err == NoticeDef.SUCCESS then
		if idList and #idList > 0 then
			local rewards = {}

			for _, shopItemId in ipairs(idList) do
				local shopItemCfg = ShopCommodityData[shopItemId]

				if shopItemCfg and shopItemCfg.itemId then
					table.insert(rewards, {
						tIndex = 0,
						type = 0,
						id = shopItemCfg.itemId,
						num = shopItemCfg.itemNum or 1
					})
				end
			end

			if #rewards > 0 then
				function self.comp.listRewardUList.luaRenderItem(button, index, data)
					LuaUIUtils.renderRewards(button, index, data)
				end

				self.comp.listRewardUList:SetList(rewards)
			elseif commonGuideData.showRewardId then
				LuaUIUtils.setRewardListByDropId(self.comp.listRewardUList, commonGuideData.showRewardId)
			else
				self.comp.rewardContentUWidget:SetActive(false)
			end
		elseif isAsync then
			if commonGuideData.showRewardId then
				LuaUIUtils.setRewardListByDropId(self.comp.listRewardUList, commonGuideData.showRewardId)
			end
		elseif LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("RPC_CS_GetShopRefreshList returned empty list, waiting for async notification")
		end
	else
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("_renderMysteriousMerchantList fail err=%s", err)
		end

		if commonGuideData.showRewardId then
			LuaUIUtils.setRewardListByDropId(self.comp.listRewardUList, commonGuideData.showRewardId)
		end
	end
end

function MysteriousMerchantHandler:onMysteriousMerchantRefresh(err, idList)
	if self.comp.isDestroyed or self.comp.eventType ~= ActivityConst.EventType.MysteriousMerchant then
		return
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("@EventCommonGuideComponent RPC_SC_NtfShopCidList refresh eventId=%s err=%s idList=%s", tostring(self.comp.eventId), tostring(err), inspect(idList))
	end

	self:_renderMysteriousMerchantList(err, idList, true)
end

function MysteriousMerchantHandler:onExit()
	return
end

function MysteriousMerchantHandler:onDestroy()
	self._merchantRequestToken = self._merchantRequestToken + 1
end

return MysteriousMerchantHandler
