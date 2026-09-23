-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\MonthlyCardSelfie\\MonthlyCardSelfieCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("MonthlyCardSelfieCtrl")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local CashShopConst = require("Const.CashShopConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local SysConfigData = require("Data.sys_config_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local MonthCardUtils = require("GameApp.MonthCard.MonthCardUtils")
local MessageName = require("Const.MessageName")
local EventConst = require("Const.EventConst")
local MonthlyCardSelfieCtrl = Class.LightClass("MonthlyCardSelfieCtrl", UICtrl)

function MonthlyCardSelfieCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self:addListener()
	self:refreshUI()
end

function MonthlyCardSelfieCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function MonthlyCardSelfieCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function MonthlyCardSelfieCtrl:onShow()
	pg.game.audio:triggerEvent("SFX_UI_Common_GetItem")
end

function MonthlyCardSelfieCtrl:addListener()
	if self.view.btnClose then
		function self.view.btnClose.luaClick()
			self:closePanel()
		end
	end

	if self.view.listReward then
		function self.view.listReward.luaRenderItem(button, index, data)
			LuaUIUtils.renderRewardItem(button, data)
		end
	end
end

function MonthlyCardSelfieCtrl:refreshUI()
	local view = self.view
	local strMonth, strDay = MonthCardUtils.getCurrentMonthDay()

	if view.txtDay then
		ClientTextUtils.setText(view.txtDay, tostring(strDay))
	end

	local remainDays = MonthCardUtils.getRemainingDays()

	if view.txtRemainDays then
		local limitDay = SysConfigData.MONTH_CARD_DAYS_LEFT_HIGHLIGHT
		local txtRemain = pg.getGameString("MONTH_CARD_DAYS_LEFT")

		if remainDays <= limitDay then
			txtRemain = pg.getGameString("MONTH_CARD_DAYS_LEFT_HIGHLIGHT")
		end

		local text = string.format(txtRemain, remainDays)

		ClientTextUtils.setText(view.txtRemainDays, text)
	end

	if view.txtMonth then
		ClientTextUtils.setText(view.txtMonth, tostring(strMonth))
	end

	local cumulativeRewardList = {}

	for _, data in ipairs(SysConfigData.MONTH_CARD_REWARD_DAILY) do
		table.insert(cumulativeRewardList, {
			id = data[1],
			num = data[2]
		})
	end

	view.listReward:SetList(cumulativeRewardList)

	local bg = MonthCardUtils.getMonthCardBg()

	if bg and view.roleUImage then
		view.roleUImage.url = bg
	end
end

function MonthlyCardSelfieCtrl:closePanel()
	if self._closing then
		self:close()

		return
	end

	self._closing = true

	self.view.rootUComponent:InvokeCallbackWithCallback(CS.XGUI.EInvokeTime.Custom1, function()
		self:close()
		facade:sendMsgToUI(MessageName.MONTH_CARD_ACTIVATE)
		pg.global.eventEmitter:emit(EventConst.ON_ITEM_OBTAIN_CLOSE_PANEL, {})
	end)
end

return MonthlyCardSelfieCtrl
