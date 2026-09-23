-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CoreReward\\CoreRewardCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("CoreRewardCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local BattlePassData = require("Data.event_battlepass_data")
local ClientCashShopUtils = require("Utils.ClientCashShopUtils")
local CoreRewardCtrl = Class.LightClass("CoreRewardCtrl", UICtrl)
local RechargeUtils = require("GameApp.Recharge.RechargeUtils")
local PlatformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade

CoreRewardCtrl.messages = {}

function CoreRewardCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function CoreRewardCtrl:addListener()
	function self.view.btnClose.luaClick()
		self:dismiss()
	end

	function self.view.btnGo.luaClick()
		if not ClientCashShopUtils.canOpenBattlePass() then
			return
		end

		if pg.global.platform:isPS() and RechargeUtils.isEmptyStore() then
			PlatformBridgeLuaFacade.ShowCommonMessageDialogEmptyStore()

			return
		end

		self:dismiss()
		pg.global.ui:open(UIConst.UI_ID_BP_PURCHASE)
	end

	function self.view.btnPetEgg.luaClick()
		local actData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.BattlePass)

		if not actData then
			return
		end

		local phase = actData.activityBase and actData.activityBase.activityPhase
		local bpData = phase and BattlePassData[phase]

		if not bpData then
			return
		end

		pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
			id = bpData.passPetEggId,
			targetRect = self.btnPetEgg,
			originData = {
				hideCount = true
			}
		})
	end
end

function CoreRewardCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function CoreRewardCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function CoreRewardCtrl:onShow()
	local actData = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.BattlePass)

	if not actData then
		return
	end

	local phase = actData.activityBase and actData.activityBase.activityPhase
	local bpData = phase and BattlePassData[phase]

	if not bpData then
		return
	end

	local view = self.view

	if view.txtTitle then
		ClientTextUtils.setText(view.txtTitle, pg.getGameString("BATTLEPASS_GREATDEALS_TAGS"))
	end

	if view.txtSpecialNum then
		ClientTextUtils.setText(view.txtSpecialNum, pg.getGameString("BATTLEPASS_SELLPAGE_RIGHTSUBTITLE"))
	end

	if view.txtRewardGet then
		ClientTextUtils.setText(view.txtRewardGet, pg.getGameString("BATTLEPASS_POPUP_DESCRIPTION"))
	end

	if view.textUBaseText then
		ClientTextUtils.setText(view.textUBaseText, pg.getGameString("BATTLEPASS_POPUP_BUFF"))
	end

	if view.txtGoBtnName then
		ClientTextUtils.setText(view.txtGoBtnName, pg.getGameString("BATTLEPASS_POPUP_BOTTLE"))
	end

	if view.txtName then
		ClientTextUtils.setText(view.txtName, pg.getGameString("BATTLEPASS_MAIN_TITLE"))
	end

	if view.txtPetName and bpData.passPetName then
		ClientTextUtils.setText(view.txtPetName, pg.getLocalizationText(bpData.passPetName))
	end

	if view.petQualityUComponent then
		view.petQualityUComponent:TryChangePage("Quality", 3)

		local objectReference1 = view.petQualityUComponent:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference1:GetRefValue("txtNameUSDFText")

		if txtNameUSDFText then
			local ratingStr = Const.STAGE_TO_RATING_STR[4] or ""

			ClientTextUtils.setText(txtNameUSDFText, pg.getGameString(ratingStr))
		end
	end

	if view.itemListUList and bpData.rewadPopup then
		local rewardList = {}

		for _, entry in ipairs(bpData.rewadPopup) do
			rewardList[#rewardList + 1] = {
				id = entry[1],
				num = entry[2]
			}
		end

		function view.itemListUList.luaRenderItem(btn, _, d)
			LuaUIUtils.renderRewardItem(btn, d)
		end

		view.itemListUList:SetList(rewardList)
	end
end

function CoreRewardCtrl:onHide()
	return
end

return CoreRewardCtrl
