-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\Component\\CommonGuide\\StarPlanGuideHandler.lua

local Class = require("Core.Framework.Class")
local GuideHandlerBase = require("Guis.Panels.Event.Component.CommonGuide.GuideHandlerBase")
local ClientTextUtils = require("Utils.ClientTextUtils")
local EventCommonGuideData = require("Data.event_common_guide_data")
local RedDotConst = require("Const.RedDotConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local ItemSourceData = require("Data.item_source_data")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("EventCommonGuideComponent")
local StarPlanGuideHandler = Class.LightClass("StarPlanGuideHandler", GuideHandlerBase)

function StarPlanGuideHandler:getOwnedRefKeys()
	return {
		"starPlanGuideUContainer"
	}
end

function StarPlanGuideHandler:getOwnedContainers()
	return {
		"starPlanGuideUContainer"
	}
end

function StarPlanGuideHandler:onFindObjects(objectReference)
	self.starPlanGuideUContainer = objectReference:GetRefValue("starPlanGuideUContainer")
end

function StarPlanGuideHandler:onRefresh()
	self.comp.rewardContentUWidget:SetActive(false)
	self.comp.btnGotoUButton:SetActive(false)
	self.comp.btnNameUButton:SetActive(false)

	if self.starPlanGuideUContainer then
		self.starPlanGuideUContainer:SetActive(true)

		if self.starPlanGuideUContainer:CheckURLLoaded() then
			self:_refreshStarPlanGuide()
		else
			self.starPlanGuideUContainer:LoadDefaultUrlManually(function()
				self:_refreshStarPlanGuide()
			end)
		end
	end
end

function StarPlanGuideHandler:onExit()
	if self.starPlanGuideUContainer then
		self.starPlanGuideUContainer:SetActive(false)
	end
end

function StarPlanGuideHandler:_refreshStarPlanGuide()
	local commonGuideData = EventCommonGuideData[self.comp.commonGuideId]

	if not commonGuideData then
		if pg.logError() then
			logger:error("@EventCommonGuideComponent _refreshStarPlanGuide commonGuideData is nil, eventId: %d, commonGuideId: %d", self.comp.eventId, self.comp.commonGuideId)
		end

		return
	end

	if not self.starPlanGuideUContainer or not self.starPlanGuideUContainer.content then
		return
	end

	local objectReference = self.starPlanGuideUContainer.content:GetComponent("ObjectReference")

	if not objectReference then
		return
	end

	self.btnGuideUList = objectReference:GetRefValue("btnGuideUList")

	local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")

	if txtTitleUSDFText then
		ClientTextUtils.setText(txtTitleUSDFText, pg.getGameString("LEVELING_GUIDE_DESC"))
	end

	if not self.btnGuideUList then
		return
	end

	function self.btnGuideUList.luaRenderItem(button, index, data)
		self:_renderStarPlanGuideItem(button, index, data)
	end

	local dataList = self.comp.model:getStarPlanGuideItemDataList(self.comp.commonGuideId)

	self.btnGuideUList:SetList(dataList)
end

function StarPlanGuideHandler:_renderStarPlanGuideItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")

	if not objectReference then
		return
	end

	local txtGoNameUSDFText = objectReference:GetRefValue("txtGoNameUSDFText")
	local txtTitleNameUSDFText = objectReference:GetRefValue("txtTitleNameUSDFText")
	local txtTagUSDFText = objectReference:GetRefValue("txtTagUSDFText")
	local tagUComponent = objectReference:GetRefValue("tagUComponent")
	local iconUImage = objectReference:GetRefValue("iconUImage")

	if txtTagUSDFText and tagUComponent then
		local tagName = data.tagName and pg.getGameString(data.tagName) or ""

		ClientTextUtils.setText(txtTagUSDFText, tagName)
		tagUComponent:TryChangePage("colour", data.tagType or 0)
	end

	if txtTitleNameUSDFText then
		local txt = data.name and pg.getLocalizationText(data.name) or ""

		ClientTextUtils.setText(txtTitleNameUSDFText, txt)
	end

	if txtGoNameUSDFText then
		ClientTextUtils.setText(txtGoNameUSDFText, pg.getGameString("BUTTON_NAME_1"))
	end

	if iconUImage then
		iconUImage.url = data.iconPic or ""
	end

	local redDotPath = string.format(RedDotConst.RedDotPath.EVENT_STAR_PLAN_GUIDE_ITEM, data.index)
	local redDotStyle = data.redDotStyle
	local showRedDot = redDotStyle and redDotStyle ~= RedDotConst.RedDotStyle.NONE

	pg.global.setRedDot(redDotPath, button, showRedDot, redDotStyle or RedDotConst.RedDotStyle.POINT)

	function button.luaClick()
		local _, button = self.btnGuideUList:TryGetChildAt(0)

		if button then
			pg.global.navMgr:FocusItem(button)
		end

		if data.eventId then
			pg.me:doEvent(data.eventId)
		elseif data.sourceId then
			local sourceData = ItemSourceData[data.sourceId]

			if sourceData then
				LuaUIUtils.clueSeek(sourceData)
			end
		end

		LuaUIUtils.sendCustomLog(Const.BILogName.EVENT_COMMON_GUIDE, {
			event_id = self.comp.eventId
		})
	end
end

return StarPlanGuideHandler
