-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeGashaponRule\\HomeGashaponRuleCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local CallbackHandler = require("Core.Common.CallbackHandler")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local HomeGashaponRuleCtrl = Class.LightClass("HomeGashaponRuleCtrl", UICtrl)

local function setText(target, text)
	if target then
		ClientTextUtils.setText(target, text)
	end
end

function HomeGashaponRuleCtrl:addListener()
	UICtrl.addListener(self)

	if self.view.btnCloseUButton then
		self.view.btnCloseUButton.luaClick = CallbackHandler(self, "onClickClose")
	end

	if self.view.closeUButton then
		self.view.closeUButton.luaClick = CallbackHandler(self, "onClickClose")
	end

	self:bindGamepadScrollUList(self.view.scrollRectUScrollRect, nil, true)
end

function HomeGashaponRuleCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:refreshStaticTexts()
	self:refreshTierRules()
end

function HomeGashaponRuleCtrl:refreshStaticTexts()
	setText(self.view.txtTltleUSDFText, pg.getGameString("HOME_GACHA_TIPS_TITLE"))
end

function HomeGashaponRuleCtrl:refreshTierRules()
	local scrollRect = self.view.scrollRectUScrollRect

	self:renderScroll(scrollRect.content, self.model:getTierRules())
	scrollRect:GoToPos(Vector2.zero, true)
end

function HomeGashaponRuleCtrl:renderScroll(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtDetailsTextPlus = objectReference:GetRefValue("txtDetailsTextPlus")
	local listItemUList = objectReference:GetRefValue("listItemUList")

	listItemUList.luaRenderItem = CallbackHandler(self, "renderTierRuleItem")

	listItemUList:SetList(data)
	setText(txtDetailsTextPlus, pg.getGameString("HOME_GACHA_TIPS_DESC"))
end

function HomeGashaponRuleCtrl:renderTierRuleItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	local txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
	local listItemUList = objectReference:GetRefValue("listItemUList")

	setText(txtTitleUSDFText, pg.getLocalizationText(data.name))
	setText(txtNumUSDFText, self:formatPercent(data.percent))

	listItemUList.luaRenderItem = CallbackHandler(self, "renderRewardItem")

	listItemUList:SetList(data.rewards)
end

function HomeGashaponRuleCtrl:renderRewardItem(button, index, data)
	LuaUIUtils.renderRewardItem(button, data, tostring(LuaUIUtils.formatShortItemNum(data.num or 0)))
end

function HomeGashaponRuleCtrl:formatPercent(percent)
	if percent == math.floor(percent) then
		return string.format("%d%%", percent)
	end

	return string.format("%.2f%%", percent)
end

function HomeGashaponRuleCtrl:onClickClose()
	self:close()
end

return HomeGashaponRuleCtrl
