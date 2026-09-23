-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\Component\\CommonGuide\\TeaPartyGuideHandler.lua

local Class = require("Core.Framework.Class")
local GuideHandlerBase = require("Guis.Panels.Event.Component.CommonGuide.GuideHandlerBase")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ItemData = require("Data.item_data")
local UIConst = require("Const.UIConst")
local TEA_PARTY_MAP_EVENT_ID = 1885
local TeaPartyGuideHandler = Class.LightClass("TeaPartyGuideHandler", GuideHandlerBase)

function TeaPartyGuideHandler:getOwnedRefKeys()
	return {
		"xyTeaPartyDetailsUWidget",
		"xYTeaBgUContainer"
	}
end

function TeaPartyGuideHandler:getOwnedContainers()
	return {
		"xYTeaBgUContainer"
	}
end

function TeaPartyGuideHandler:onFindObjects(objectReference)
	self.xyTeaPartyDetailsUWidget = objectReference:GetRefValue("xyTeaPartyDetailsUWidget")
	self.txtXyTeaTitle = objectReference:GetRefValue("txtXyTeaTitle")
	self.txtXyTeaNum1 = objectReference:GetRefValue("txtXyTeaNum1")
	self.imgXyTea1 = objectReference:GetRefValue("imgXyTea1")
	self.imgXyTea2 = objectReference:GetRefValue("imgXyTea2")
	self.txtXyTeaNum2 = objectReference:GetRefValue("txtXyTeaNum2")
	self.buttonXyTea1 = objectReference:GetRefValue("buttonXyTea1")
	self.buttonXyTea2 = objectReference:GetRefValue("buttonXyTea2")
	self.xYTeaBgUContainer = objectReference:GetRefValue("xYTeaBgUContainer")
end

function TeaPartyGuideHandler:onRefresh()
	if self.xYTeaBgUContainer then
		self.xYTeaBgUContainer:SetActive(true)

		if not self.xYTeaBgUContainer:CheckURLLoaded() then
			self.xYTeaBgUContainer:LoadDefaultUrlManually()
		end
	end

	local dailyAcquired = pg.me.cafeGatheringDailyAcquired or {}

	if self.xyTeaPartyDetailsUWidget then
		self.xyTeaPartyDetailsUWidget:SetActive(true)
	end

	if self.txtXyTeaTitle then
		ClientTextUtils.setText(self.txtXyTeaTitle, pg.getGameString("TEAPARTY_AVAILABLE_TODAY"))
	end

	local teaPartyItemCfg1 = self.comp.model:getTeaPartyDailyItemCfg(1)
	local teaPartyItemCfg2 = self.comp.model:getTeaPartyDailyItemCfg(2)

	if self.imgXyTea1 then
		local itemCfg1 = teaPartyItemCfg1 and ItemData[teaPartyItemCfg1[1]]

		self.imgXyTea1.url = itemCfg1 and itemCfg1.icon or ""
	end

	if self.imgXyTea2 then
		local itemCfg2 = teaPartyItemCfg2 and ItemData[teaPartyItemCfg2[1]]

		self.imgXyTea2.url = itemCfg2 and itemCfg2.icon or ""
	end

	self:_bindTeaPartyItemTip(self.buttonXyTea1, teaPartyItemCfg1)
	self:_bindTeaPartyItemTip(self.buttonXyTea2, teaPartyItemCfg2)

	if self.txtXyTeaNum1 then
		ClientTextUtils.setText(self.txtXyTeaNum1, teaPartyItemCfg1 and pg.getFormatText(pg.getGameString("TEAPARTY_TOKEN_SHOW"), dailyAcquired[teaPartyItemCfg1[1]] or 0, teaPartyItemCfg1[2] or 0) or "")
	end

	if self.txtXyTeaNum2 then
		ClientTextUtils.setText(self.txtXyTeaNum2, teaPartyItemCfg2 and pg.getFormatText(pg.getGameString("TEAPARTY_TOKEN_SHOW"), dailyAcquired[teaPartyItemCfg2[1]] or 0, teaPartyItemCfg2[2] or 0) or "")
	end
end

function TeaPartyGuideHandler:onExit()
	if self.xyTeaPartyDetailsUWidget then
		self.xyTeaPartyDetailsUWidget:SetActive(false)
	end

	if self.xYTeaBgUContainer then
		self.xYTeaBgUContainer:SetActive(false)
	end
end

function TeaPartyGuideHandler:onButton1()
	local EventCommonGuideData = require("Data.event_common_guide_data")
	local commonGuideData = EventCommonGuideData[self.comp.commonGuideId]
	local gotoEventId = commonGuideData.event1

	if gotoEventId == nil then
		gotoEventId = TEA_PARTY_MAP_EVENT_ID
	end

	if gotoEventId ~= nil then
		pg.me:doEvent(gotoEventId)
	end

	if commonGuideData.linkAddress1 ~= nil then
		pg.global.sdkManager:openUrl("EventCommonGuideComponent", self.comp.eventId, commonGuideData.linkAddress1)
	end

	return true
end

function TeaPartyGuideHandler:_bindTeaPartyItemTip(button, itemCfg)
	if not button then
		return
	end

	local itemId = itemCfg and itemCfg[1]

	button.interactable = itemId ~= nil

	function button.luaClick()
		if not itemId then
			return
		end

		pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
			id = itemId,
			targetRect = button,
			originData = {
				hideCount = true
			}
		})
	end
end

return TeaPartyGuideHandler
