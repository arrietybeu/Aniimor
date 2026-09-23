-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GamePreorderGuide\\GamePreorderGuideCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ShopConstantData = require("Data.shopmall_constant_data")
local GamePreorderGuideCtrl = Class.LightClass("GamePreorderGuideCtrl", UICtrl)

function GamePreorderGuideCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.view.txtTitleUSDFText.disabledLocalization = true
	self.view.txtDetailsUSDFText.disabledLocalization = true
	self.view.txtPreorderUText.disabledLocalization = true
	self.view.txtContinueUText.disabledLocalization = true

	self:refreshText()
end

function GamePreorderGuideCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	pg.game.monthCard:reportPreorderWindow("open", self.uid, info and info.isManual == true)
end

function GamePreorderGuideCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:close()
	end

	function self.view.btnViewUButton.luaClick()
		self:close()
		pg.game.monthCard:openPreorderMonthCard()
	end

	function self.view.btnGoUButton.luaClick()
		local sdkManager = pg.global and pg.global.sdkManager

		if not sdkManager then
			return
		end

		pcall(sdkManager.openUrl, sdkManager, "GamePreorderGuideCtrl", "ShopConstantData.special_paytest_website", ShopConstantData.special_paytest_website.number)
	end
end

function GamePreorderGuideCtrl:onDestroy()
	pg.game.monthCard:reportPreorderWindow("close", self.uid, true)
	UICtrl.onDestroy(self)
end

function GamePreorderGuideCtrl:refreshText()
	ClientTextUtils.setText(self.view.txtTitleUSDFText, pg.getGameString("OVERSEAS_PAYTEST_TITLE"))
	ClientTextUtils.setText(self.view.txtDetailsUSDFText, pg.getGameString("OVERSEAS_PAYTEST_DETAILS"))
	ClientTextUtils.setText(self.view.txtPreorderUText, pg.getGameString("OVERSEAS_PAYTEST_PREORDER"))
	ClientTextUtils.setText(self.view.txtContinueUText, pg.getGameString("OVERSEAS_PAYTEST_CONTINUE"))
end

return GamePreorderGuideCtrl
