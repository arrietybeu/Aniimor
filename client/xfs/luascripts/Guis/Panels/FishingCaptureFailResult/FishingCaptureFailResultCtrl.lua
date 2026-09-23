-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FishingCaptureFailResult\\FishingCaptureFailResultCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local FishingCaptureConst = require("Common.Const.FishingCaptureConst")
local ItemData = require("Data.item_data")
local FishingCaptureFailResultCtrl = Class.LightClass("FishingCaptureFailResultCtrl", UICtrl)

FishingCaptureFailResultCtrl.messages = {}

function FishingCaptureFailResultCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function FishingCaptureFailResultCtrl:addListener()
	function self.view.backGroundCloseUButton.luaClick()
		self:onConfirmClick()
	end

	function self.view.rewardList.luaRenderItem(button, index, data)
		LuaUIUtils.setPropCard(button, index, data, UIConst.INVENTORY_CARD.CARD_IDX)

		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUText = objectReference:GetRefValue("txtNameUText")

		if data.num and data.num > 0 then
			ClientTextUtils.setText(txtNameUText, data.num)
		else
			ClientTextUtils.setText(txtNameUText, "")
		end

		function button.luaClick()
			pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
				addSibling = 1,
				checkTouchBegin = false,
				id = data.itemId,
				num = data.num,
				targetRect = button,
				rayCastParent = self.view.rootWidget
			})
		end
	end
end

function FishingCaptureFailResultCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self.model:setSettlementData(info)
	self:_refresh()
	pg.game.audio:playEvent("SFX_BossCatch_fail")
end

function FishingCaptureFailResultCtrl:_refresh()
	local settlementData = self.model:getSettlementData()

	ClientTextUtils.setText(self.view.textUBaseText, pg.getGameString("FC_RESULT_REWARD_TITLE"))

	if not settlementData then
		return
	end

	self.view.rootWidget:TryChangePage("Type", 0)
	ClientTextUtils.setText(self.view.titleTxt, pg.getGameString("CHALLENGE_FAIL"))
	self:refreshRewards()
end

function FishingCaptureFailResultCtrl:onConfirmClick()
	self:dismiss()
end

function FishingCaptureFailResultCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function FishingCaptureFailResultCtrl:refreshRewards()
	local rewardList = self.model:getRewardList()

	self.view.panelRewardUWidget:TryChangePage("Empty", #rewardList > 0 and "Normal" or "Empty")

	if #rewardList > 0 then
		self.view.rewardList:SetList(rewardList)
	end

	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("itemDetail", #rewardList > 0)
end

return FishingCaptureFailResultCtrl
