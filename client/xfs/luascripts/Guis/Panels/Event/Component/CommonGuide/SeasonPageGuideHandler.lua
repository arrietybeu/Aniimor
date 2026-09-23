-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\Component\\CommonGuide\\SeasonPageGuideHandler.lua

local Class = require("Core.Framework.Class")
local GuideHandlerBase = require("Guis.Panels.Event.Component.CommonGuide.GuideHandlerBase")
local ClientTextUtils = require("Utils.ClientTextUtils")
local EventCommonGuideData = require("Data.event_common_guide_data")
local RedDotConst = require("Const.RedDotConst")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local ItemUtils = require("Common.Utils.ItemUtils")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("EventCommonGuideComponent")
local SeasonPageGuideHandler = Class.LightClass("SeasonPageGuideHandler", GuideHandlerBase)

function SeasonPageGuideHandler:getOwnedRefKeys()
	return {
		"seasonCollectionUContainer"
	}
end

function SeasonPageGuideHandler:getOwnedContainers()
	return {
		"seasonHubUContainer"
	}
end

function SeasonPageGuideHandler:onFindObjects(objectReference)
	self.seasonHubUContainer = objectReference:GetRefValue("seasonCollectionUContainer")
end

function SeasonPageGuideHandler:onRefresh()
	self.comp.rewardContentUWidget:SetActive(false)
	self.comp.btnGotoUButton:SetActive(false)
	self.comp.btnNameUButton:SetActive(false)

	if self.seasonHubUContainer then
		self.seasonHubUContainer:SetActive(true)

		if self.seasonHubUContainer:CheckURLLoaded() then
			self:_refreshSeasonHub()
		else
			self.seasonHubUContainer:LoadDefaultUrlManually(function()
				self:_refreshSeasonHub()
			end)
		end
	end
end

function SeasonPageGuideHandler:onExit()
	if self.seasonHubUContainer then
		self.seasonHubUContainer:SetActive(false)
	end
end

function SeasonPageGuideHandler:onMoneyChanged()
	if self.seasonHubUContainer and self.seasonHubUContainer:CheckURLLoaded() then
		self:_refreshSeasonHub()
	end
end

function SeasonPageGuideHandler:_refreshSeasonHub()
	local commonGuideData = EventCommonGuideData[self.comp.commonGuideId]

	if not commonGuideData then
		if pg.logError() then
			logger:error("@EventCommonGuideComponent _refreshSeasonHub commonGuideData is nil, eventId: %d, commonGuideId: %d", self.comp.eventId, self.comp.commonGuideId)
		end

		return
	end

	if not self.seasonHubUContainer or not self.seasonHubUContainer.content then
		return
	end

	local objectReference = self.seasonHubUContainer.content:GetComponent("ObjectReference")

	if not objectReference then
		return
	end

	local pageOrder = self.comp.model:getSeasonHubPageOrder() or {}

	for i, funcKey in ipairs(pageOrder) do
		local btn = objectReference:GetRefValue("btn" .. i)

		if btn then
			local btnObjRef = btn:GetComponent("ObjectReference")
			local txtNameUBaseText = btnObjRef and btnObjRef:GetRefValue("txtNameUBaseText") or nil
			local lockTxt = btnObjRef and btnObjRef:GetRefValue("lockTxt") or nil
			local eventField = "event" .. i
			local nameField = "btnName" .. i
			local active = commonGuideData[eventField] ~= nil

			btn:SetActive(active)

			if active then
				local info = self.comp.model:getSeasonHubFuncInfo(funcKey)
				local isLock = not info.isOpen or self.comp.isLock

				btn.interactable = not isLock

				btn:TryChangePage("State", isLock and 0 or 1)

				if txtNameUBaseText then
					local txt = commonGuideData[nameField] and pg.getLocalizationText(commonGuideData[nameField]) or ""

					ClientTextUtils.setText(txtNameUBaseText, txt)
				end

				if lockTxt and isLock and info.lockedDesc and info.lockedDesc ~= "" then
					ClientTextUtils.setText(lockTxt, info.lockedDesc)
				end

				local redDotPath = string.format(RedDotConst.RedDotPath.EVENT_SEASON_HUB_ITEM, funcKey)
				local showRedDot = info.isOpen and info.redDotStyle and info.redDotStyle ~= RedDotConst.RedDotStyle.NONE

				pg.global.setRedDot(redDotPath, btn, showRedDot, info.redDotStyle or RedDotConst.RedDotStyle.POINT)

				function btn.luaClick()
					if isLock then
						return
					end

					local data = EventCommonGuideData[self.comp.commonGuideId]

					if not data then
						return
					end

					if data[eventField] then
						pg.me:doEvent(data[eventField])
					end

					LuaUIUtils.sendCustomLog(Const.BILogName.EVENT_COMMON_GUIDE, {
						event_id = self.comp.eventId
					})
				end
			end
		end
	end

	local btnShopUButton = objectReference:GetRefValue("btnStoreUButton")
	local storeNameTxt = objectReference:GetRefValue("storeNameTxt")
	local txtItemCount = objectReference:GetRefValue("itemNumTxt")

	if btnShopUButton then
		if txtItemCount then
			local itemCount = ItemUtils.getItemCountById(pg.me, 1013) or 0

			ClientTextUtils.setText(txtItemCount, tostring(itemCount))
		end

		if storeNameTxt then
			ClientTextUtils.setText(storeNameTxt, pg.getGameString("EVENT_SEASON_HUB_STORE_NAME"))
		end

		local hasShop = commonGuideData.shopId ~= nil

		btnShopUButton.interactable = hasShop and not self.comp.isLock

		function btnShopUButton.luaClick()
			if self.comp.isLock then
				return
			end

			local data = EventCommonGuideData[self.comp.commonGuideId]

			if not data or not data.shopId then
				return
			end

			pg.global.ui:open(UIConst.UI_ID_SHOP_MAIN, {
				shopTags = {
					data.shopId
				}
			})
			LuaUIUtils.sendCustomLog(Const.BILogName.EVENT_COMMON_GUIDE, {
				event_id = self.comp.eventId
			})
		end
	end
end

return SeasonPageGuideHandler
