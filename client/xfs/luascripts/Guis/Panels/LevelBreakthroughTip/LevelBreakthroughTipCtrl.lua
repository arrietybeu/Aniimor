-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\LevelBreakthroughTip\\LevelBreakthroughTipCtrl.lua

local UIConst = require("Const.UIConst")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local NoticeDef = require("Common.NoticeDef")
local LevelBreakthroughTipCtrl = Class.LightClass("LevelBreakthroughTipCtrl", UICtrl)

LevelBreakthroughTipCtrl.messages = {}

function LevelBreakthroughTipCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.leftItem = info.leftItem
	self.rightItem = info.rightItem
	self.ensureCb = info.ensureCb
end

function LevelBreakthroughTipCtrl:onShow()
	self.view.rewardItemList1UList:SetList(self.leftItem)
	self.view.rewardItemList2UList:SetList(self.rightItem)
end

local function isItemCountNotEnough(data)
	return data and data.ownNum and data.replaceNum and data.ownNum < data.replaceNum
end

function LevelBreakthroughTipCtrl:renderItem(button, data, checkCount)
	local objectReference = button:GetComponent("ObjectReference")
	local itemIconUImage = objectReference:GetRefValue("itemIconUImage")
	local txtNumUText = objectReference:GetRefValue("txtNumUBaseText")

	txtNumUText.disabledLocalization = true

	function button.luaClick()
		if pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_ITEM_TIP) then
			pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)
		else
			pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
				id = data.id,
				num = data.ownNum,
				targetRect = button,
				closeOnJumpToSource = function()
					self:closePanel()
				end
			})
		end
	end

	function button.luaTooltipPopup(_, open)
		button.isSelected = open
	end

	button:TryChangePage("Quality", data.quality)

	itemIconUImage.url = data.iconName

	local replaceNumText = tostring(data.replaceNum or 0)

	if checkCount and isItemCountNotEnough(data) then
		replaceNumText = string.format("<color=#ff5959>%s</color>", replaceNumText)
	end

	ClientTextUtils.setText(txtNumUText, replaceNumText)
end

function LevelBreakthroughTipCtrl:hasLeftItemCountNotEnough()
	if not self.leftItem then
		return false
	end

	if self.leftItem.id then
		return isItemCountNotEnough(self.leftItem)
	end

	for _, item in pairs(self.leftItem) do
		if isItemCountNotEnough(item) then
			return true
		end
	end

	return false
end

function LevelBreakthroughTipCtrl:destroy()
	return
end

function LevelBreakthroughTipCtrl:addListener()
	function self.view.rewardItemList1UList.luaRenderItem(button, index, data)
		self:renderItem(button, data, true)
	end

	function self.view.rewardItemList2UList.luaRenderItem(button, index, data)
		self:renderItem(button, data, false)
	end

	function self.view.btnCancelUButton.luaClick()
		self:closePanel()
	end

	function self.view.btnConfirmUButton.luaClick()
		if self:hasLeftItemCountNotEnough() then
			pg.global.showBubbleMessageById(NoticeDef.ITEM_COUNT_LACK)

			return
		end

		self.ensureCb()
		self:closePanel()
	end

	function self.view.btnCloseUButton.luaClick()
		self:closePanel()
	end
end

function LevelBreakthroughTipCtrl:closePanel()
	pg.global.ui:close(UIConst.UI_ID_LEVEL_BREAKTHROUGH_TIP)
end

function LevelBreakthroughTipCtrl:onDestroy()
	self:destroy()
	UICtrl.onDestroy(self)
end

return LevelBreakthroughTipCtrl
