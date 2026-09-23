-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\Component\\CommonGuide\\MockBattleGuideHandler.lua

local Class = require("Core.Framework.Class")
local GuideHandlerBase = require("Guis.Panels.Event.Component.CommonGuide.GuideHandlerBase")
local UIConst = require("Const.UIConst")
local RedDotConst = require("Const.RedDotConst")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local MockBattleGuideHandler = Class.LightClass("MockBattleGuideHandler", GuideHandlerBase)

function MockBattleGuideHandler:getOwnedRefKeys()
	return {
		"rogueUpUWidget",
		"awardBtnUButton"
	}
end

function MockBattleGuideHandler:onFindObjects(objectReference)
	self.rogueUpUWidget = objectReference:GetRefValue("rogueUpUWidget")
	self.rogueUpTimesTxt = objectReference:GetRefValue("rogueUpTimesTxt")
	self.awardBtnUButton = objectReference:GetRefValue("awardBtnUButton")
	self.awardBtnNameUSDFText = objectReference:GetRefValue("awardBtnNameUSDFText")

	ClientTextUtils.setText(self.awardBtnNameUSDFText, pg.getGameString("GUIDE_WEEKLY_REWARD"))
end

function MockBattleGuideHandler:onRefresh()
	self.rogueUpUWidget:SetActive(true)
	ClientActivityUtils.initRogueRewardUpWidget(self.rogueUpUWidget, self.rogueUpTimesTxt)

	if self.awardBtnUButton then
		self.awardBtnUButton:SetActive(true)

		local eventId = self.comp.eventId
		local treePath = string.format(RedDotConst.RedDotPath.EVENT_TAB_LIST_ITEM, eventId)

		self.awardBtnUButton:ClearRedDot()
		pg.global.setPreViewRedDot(treePath, self.awardBtnUButton, function()
			return ClientActivityUtils.getEventRedDotStyle(nil, eventId)
		end)

		function self.awardBtnUButton.luaClick()
			pg.global.ui:open(UIConst.UI_ID_TOWER_SEASON_WEEKLY_REWARD, {
				showBgMask = true
			})
		end
	end
end

function MockBattleGuideHandler:onExit()
	if self.awardBtnUButton then
		self.awardBtnUButton:ClearRedDot()
		self.awardBtnUButton:SetActive(false)

		self.awardBtnUButton.luaClick = nil
	end

	self.rogueUpUWidget:SetActive(false)
end

return MockBattleGuideHandler
