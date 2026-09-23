-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CashShopPenaltyTip\\CashShopPenaltyTipCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local CashShopPenaltyTipModel = require("Guis.Panels.CashShopPenaltyTip.CashShopPenaltyTipModel")
local CashShopPenaltyTipView = require("Guis.Panels.CashShopPenaltyTip.CashShopPenaltyTipView")
local EMPTY_TABLE = require("Core.Common.EmptyTable")
local ItemData = require("Data.item_data")
local ItemSourceData = require("Data.item_source_data")
local ItemUtils = require("Common.Utils.ItemUtils")
local CashShopPenaltyTipCtrl = Class.LightClass("CashShopPenaltyTipCtrl", UICtrl)

CashShopPenaltyTipCtrl.modelClz = CashShopPenaltyTipModel
CashShopPenaltyTipCtrl.viewClz = CashShopPenaltyTipView

function CashShopPenaltyTipCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self:addListener()
end

function CashShopPenaltyTipCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	local title, rows = self:_buildContent()

	self.view:setContent(title, rows)
end

function CashShopPenaltyTipCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:dismiss()
	end
end

function CashShopPenaltyTipCtrl:_buildContent()
	local negativeMoneyList = ItemUtils.getNegativeMoneyList(pg.me)
	local itemNames = {}
	local debtItems = {}
	local sourceGroups = {}

	for _, item in ipairs(negativeMoneyList) do
		local itemConfig = ItemData[item.itemId]
		local itemName = pg.getLocalizationText(itemConfig.itemName)

		itemNames[#itemNames + 1] = itemName
		debtItems[#debtItems + 1] = pg.getFormatText("<style=Debuff>{0}{1}</style>", math.abs(item.count), itemName)

		local sourceTexts = {}

		for _, sourceId in ipairs(itemConfig.source or EMPTY_TABLE) do
			local sourceConfig = ItemSourceData[sourceId]

			if sourceConfig and sourceConfig.desc then
				sourceTexts[#sourceTexts + 1] = pg.getLocalizationText(sourceConfig.desc)
			end
		end

		sourceGroups[#sourceGroups + 1] = {
			itemName = itemName,
			sourceTexts = sourceTexts
		}
	end

	local rows = {
		{
			titleState = 1,
			titleType = 2,
			tIndex = 0,
			text = pg.getFormatText(pg.getGameString("CASH_SHOP_PENALTY_STATUS"), #negativeMoneyList, table.concat(itemNames, "、"))
		},
		{
			tIndex = 2,
			text = pg.getFormatText(pg.getGameString("CASH_SHOP_PENALTY_DEBT"), table.concat(debtItems, "、"), "")
		},
		{
			tIndex = 0,
			haveBlank = true,
			text = pg.getFormatText(pg.getGameString("CASH_SHOP_PENALTY_SOURCE_TITLE"), table.concat(itemNames, "、"))
		}
	}

	for _, sourceGroup in ipairs(sourceGroups) do
		rows[#rows + 1] = {
			tIndex = 1,
			text = string.format("%s：%s", pg.getFormatText(pg.getGameString("CASH_SHOP_PENALTY_SOURCE_TITLE"), sourceGroup.itemName), table.concat(sourceGroup.sourceTexts, "、"))
		}
	end

	return pg.getGameString("CASH_SHOP_PENALTY_TIP_TITLE"), rows
end

return CashShopPenaltyTipCtrl
