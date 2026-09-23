-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\LuaUIUtils\\UIActivityUtils.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local ItemData = require("Data.item_data")
local AddressDataConst = require("Const.AddressDataConst")
local ActivityConst = require("Common.Const.ActivityConst")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local PvpRankData = require("Data.pvp_rank_data")
local RedDotConst = require("Const.RedDotConst")
local CommonSwitch = require("Common.CommonSwitch")
local ClientUtils = require("Utils.ClientUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local MonthCardUtils = require("GameApp.MonthCard.MonthCardUtils")
local CustomTriggerData = require("Data.custom_trigger_data")
local CashShopConst = require("Const.CashShopConst")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local SysConfigData = require("Data.sys_config_data")
local EventTaskData = require("Data.event_task_data")
local schoolGuideData = require("Data.college_guide_page_data")
local SchoolGuideConst = require("Common.Const.SchoolGuideConst")
local UIConst = require("Const.UIConst")
local RechargeUtils = require("GameApp.Recharge.RechargeUtils")
local TriggerConst = require("Common.Const.TriggerConst")
local TriggerUtils = require("Common.Utils.TriggerUtils")

return function(LuaUIUtils)
	function LuaUIUtils.openPVPMenu(param, uiOpenCb)
		if not LuaUIUtils.checkFuncUnlock(Const.FUNCTION_IDS.PVP) then
			pg.global.showBubbleMessageRaw(pg.getGameString("LEARN_SKILL_TIPS"), 3)

			return
		end

		pg.global.ui:open(UIConst.UI_ID_PVP_MENU, param, uiOpenCb, nil, {
			additionRes = {
				AddressDataConst.PVP_FB_STAGE
			}
		})
	end

	function LuaUIUtils.openPvpBpScene(enemyTeamInfo)
		pg.global.ui:open(UIConst.UI_ID_PVP_CHOSE, enemyTeamInfo, nil, nil, {
			additionRes = {
				AddressDataConst.PVP_FB_STAGE
			}
		})
	end

	function LuaUIUtils.getPVPRankInfo(score)
		local res = {
			score = score
		}
		local rankList = {}

		for k, v in pairs(PvpRankData) do
			local item = Utils.deepCopyTable(v)

			item.rankId = k
			rankList[#rankList + 1] = item
		end

		table.sort(rankList, function(a, b)
			return (a.needScore or 0) >= (b.needScore or 0)
		end)

		local rData

		for _, v in ipairs(rankList) do
			if res.score >= (v.needScore or 0) then
				rData = v

				break
			end
		end

		if rData == nil then
			rData = rankList[1]
		end

		res.rankId = rData.rankId
		res.icon = rData.icon
		res.preName = pg.getLocalizationText(rData.rankName)
		res.postName = pg.getLocalizationText(rData.levelName)

		return res
	end

	function LuaUIUtils.renderMonthCard(button, showFriendFuc)
		local objectReference = button:GetComponent("ObjectReference")
		local txtLabelNum = objectReference:GetRefValue("txtLabelNum")
		local txtLabelVxNum = objectReference:GetRefValue("txtLabelVxNum")
		local txtLabelName = objectReference:GetRefValue("txtLabelName")
		local btnStoredReward = objectReference:GetRefValue("btnStoredReward")
		local txtStoredDays = objectReference:GetRefValue("txtStoredDays")
		local txtCardName = objectReference:GetRefValue("txtCardName")
		local btnHelp = objectReference:GetRefValue("btnHelp")
		local txtExpireInfo = objectReference:GetRefValue("txtExpireInfo")
		local btnBuy = objectReference:GetRefValue("btnBuy")
		local txtBtnBuy = objectReference:GetRefValue("txtBtnBuy")
		local txtRenewal = objectReference:GetRefValue("txtRenewal")
		local iconRenewal = objectReference:GetRefValue("iconRenewal")
		local listImmediateReward = objectReference:GetRefValue("listImmediateReward")
		local listCumulativeReward = objectReference:GetRefValue("listCumulativeReward")
		local listPrivilegeUList = objectReference:GetRefValue("listPrivilegeUList")
		local btnGift = objectReference:GetRefValue("btnGift")
		local bgStoredDays = objectReference:GetRefValue("bgStoredDays")
		local txtStoredNum = objectReference:GetRefValue("txtStoredNum")
		local txtImmediateReward = objectReference:GetRefValue("txtImmediateReward")
		local txtCumulativeReward = objectReference:GetRefValue("txtCumulativeReward")
		local triangleUImage = objectReference:GetRefValue("triangleUImage")
		local txtRule = objectReference:GetRefValue("txtRule")
		local btnInfoConsoleUButton = objectReference:GetRefValue("btnInfoConsoleUButton")
		local rechargeType = MonthCardUtils.isPreorderGuideEnabled() and Const.RECHARGE_TYPE.PAYTEST or Const.RECHARGE_TYPE.MONTHCAR
		local rechargeInfo = RechargeUtils.getProductsInfo(rechargeType)
		local canPurchase = MonthCardUtils.canPurchase()

		btnBuy:SetActive(true)

		if btnBuy then
			function btnBuy.luaClick()
				if not canPurchase then
					pg.global.showBubbleMessageRaw(pg.getGameString("MONTH_CARD_LIMITS_WARNING"), 2)

					return
				end

				if not rechargeInfo then
					return
				end

				local isBuy = pg.me.PcFirstPayPassed and pg.me.PcFirstPayPassed[rechargeInfo.packageId]

				if rechargeType == Const.RECHARGE_TYPE.PAYTEST and isBuy then
					pg.global.showBubbleMessageRaw(pg.getGameString("MONTH_CARD_LIMITS_WARNING"), 2)

					return
				end

				pg.game.recharge:requestBuy(rechargeInfo.packageId, rechargeInfo.productId, rechargeInfo.cfgInfo and rechargeInfo.cfgInfo.des or "", CashShopConst.CategoryType.MONTHLY_CARD)
			end
		end

		if btnStoredReward then
			function btnStoredReward.luaClick()
				pg.global.ui:open(UIConst.UI_ID_MONTHLY_CARD_REWARD)
			end
		end

		if btnGift then
			function btnGift.luaClick()
				if showFriendFuc then
					showFriendFuc()
				end
			end
		end

		if btnHelp then
			function btnHelp.luaClick()
				pg.global.ui.tips:openEventRuleDesc(pg.getGameString("MONTH_CARD_INSTRUCTION"), "MONTH_CARD_INSTRUCTION_TITLE")
			end
		end

		if btnInfoConsoleUButton then
			function btnInfoConsoleUButton.luaClick()
				pg.global.ui.tips:openEventRuleDesc(pg.getGameString("MONTH_CARD_INSTRUCTION"), "MONTH_CARD_INSTRUCTION_TITLE")
			end

			btnInfoConsoleUButton:SetHotkeyConsoleBar("MONTH_CARD_INSTRUCTION_BUTTON", 0)
		end

		ClientTextUtils.setText(txtCardName, pg.getGameString("MONTH_CARD_TITLE"))
		ClientTextUtils.setText(txtStoredDays, pg.getGameString("MONTH_CARD_REWARD_STORAGE"))
		ClientTextUtils.setText(txtLabelNum, pg.getGameString("MONTH_CARD_PROMOTION_1"))

		if txtLabelVxNum then
			ClientTextUtils.setText(txtLabelVxNum, pg.getGameString("MONTH_CARD_PROMOTION_1"))
		end

		ClientTextUtils.setText(txtLabelName, pg.getGameString("MONTH_CARD_PROMOTION_2"))
		ClientTextUtils.setText(txtRenewal, pg.getGameString("MONTH_CARD_REWARD_RENEW"))
		ClientTextUtils.setText(txtImmediateReward, pg.getGameString("MONTH_CARD_REWARD_NOW"))
		ClientTextUtils.setText(txtCumulativeReward, pg.getGameString("MONTH_CARD_REWARD_DAILY"))

		if txtRule then
			ClientTextUtils.setText(txtRule, pg.getGameString("MONTH_CARD_INSTRUCTION_BUTTON"))
		end

		local isActivated = MonthCardUtils.isActivated()
		local remainDays = MonthCardUtils.getRemainingDays()

		triangleUImage:SetActive(isActivated)

		if txtExpireInfo then
			if isActivated then
				ClientTextUtils.setText(txtExpireInfo, string.format(pg.getGameString("MONTH_CARD_DAYS_LEFT"), remainDays))
			else
				ClientTextUtils.setText(txtExpireInfo, pg.getGameString("MONTH_CARD_UNAVAILABLE"))
			end
		end

		local storeState = isActivated and 1 or 0
		local storeNum = MonthCardUtils.getStoredRewardDays()

		if storeNum then
			if storeNum > 0 then
				storeState = storeNum < SysConfigData.MONTH_CARD_REWARD_STORAGE and 2 or 3
			end

			ClientTextUtils.setText(txtStoredNum, pg.getFormatText("{0}/{1}", pg.getLocalizationText(storeNum), pg.getLocalizationText(SysConfigData.MONTH_CARD_REWARD_STORAGE)))
		end

		btnStoredReward:TryChangePage("Status", storeState)

		local treePath = RedDotConst.RedDotPath.MONTH_MAIN_STORE_REWARD

		pg.global.setRedDot(treePath, btnStoredReward, storeNum > 0, RedDotConst.RedDotStyle.REWARD)

		if txtBtnBuy then
			if not canPurchase then
				ClientTextUtils.setText(txtBtnBuy, pg.getGameString("MONTH_CARD_MAX_BUTTON"))
			elseif rechargeInfo and rechargeInfo.sdkInfo then
				local sdkInfo = rechargeInfo.sdkInfo
				local strState = isActivated and pg.getGameString("MONTH_CARD_RENEW_BUTTON") or pg.getGameString("MONTH_CARD_BUTTON")
				local strPrice = pg.getFormatText("{0}{1}", RechargeUtils.getProductsPrice(rechargeInfo), strState)

				ClientTextUtils.setText(txtBtnBuy, strPrice)
			else
				ClientTextUtils.setText(txtBtnBuy, pg.getGameString("SHOP_PAY_SYSTEM"))
			end
		end

		function listImmediateReward.luaRenderItem(button, index, data)
			LuaUIUtils.renderRewardItem(button, data)
		end

		local immediateRewardList = {}

		for _, data in ipairs(SysConfigData.MONTH_CARD_REWARD_NOW) do
			table.insert(immediateRewardList, {
				id = data[1],
				num = data[2]
			})
		end

		listImmediateReward:SetList(immediateRewardList)

		function listCumulativeReward.luaRenderItem(button, index, data)
			LuaUIUtils.renderRewardItem(button, data)
		end

		local cumulativeRewardList = {}

		for _, data in ipairs(SysConfigData.MONTH_CARD_REWARD_DAILY) do
			table.insert(cumulativeRewardList, {
				id = data[1],
				num = data[2] * SysConfigData.MONTH_CARD_STATE_TIME
			})
		end

		listCumulativeReward:SetList(cumulativeRewardList)

		local continueInfo = SysConfigData.MONTH_CARD_REWARD_CONTINUE

		if continueInfo and continueInfo[1] then
			local itemData = ItemData[continueInfo[1][1]]

			if itemData then
				local data = {
					id = continueInfo[1][1],
					num = continueInfo[1][2]
				}

				LuaUIUtils.renderRewardItem(iconRenewal, data)
			end
		end

		function listPrivilegeUList.luaRenderItem(button, index, data)
			local objectReference1 = button:GetComponent("ObjectReference")
			local txtPrivilege = objectReference1:GetRefValue("textUSDFText")

			if txtPrivilege and data.desc then
				ClientTextUtils.setText(txtPrivilege, pg.getLocalizationText(data.desc))
			end

			button:TryChangePage("Status", 0)
		end

		local privilegeList = MonthCardUtils.getPrivilegeList()

		listPrivilegeUList:SetList(privilegeList)
	end

	function LuaUIUtils.getSchoolGuideRedDotStyle()
		local redDotStyle = RedDotConst.RedDotStyle.NONE
		local curPri = RedDotConst.RedDotStylePriority[redDotStyle]

		for k, v in ipairs(schoolGuideData) do
			if v.switch == 1 then
				local switchName = v.switchName and "SCHOOLGUIDE_" .. v.switchName or nil

				if switchName and CommonSwitch[switchName] == true and (LuaUIUtils._checkConfigCondition(v.conditions) == true or v.alwaysShow == true) then
					local eventType = LuaUIUtils._getSchoolGuideEventType(k)
					local func = LuaUIUtils["SchoolGuide_get" .. eventType .. "RedDotStyle"]

					if func then
						local curRedDotStyle = func(redDotStyle)

						if curPri < RedDotConst.RedDotStylePriority[curRedDotStyle] then
							curPri = RedDotConst.RedDotStylePriority[curRedDotStyle]
							redDotStyle = curRedDotStyle
						end
					end
				end
			end
		end

		return redDotStyle
	end

	function LuaUIUtils._checkConfigCondition(conditionId)
		if conditionId == nil then
			return true
		end

		return ClientUtils.checkCondition(conditionId)
	end

	function LuaUIUtils._getSchoolGuideEventType(cfgId)
		for k, v in pairs(SchoolGuideConst.EventType) do
			if v == cfgId then
				return k
			end
		end
	end

	function LuaUIUtils.SchoolGuide_getBadgeCollectionRedDotStyle(curStyle)
		if curStyle == RedDotConst.RedDotStyle.REWARD then
			return curStyle
		end

		return RedDotConst.RedDotStyle.NONE
	end

	function LuaUIUtils.isDailyActiveScoreFull(taskMap)
		if not pg.me or not ActivityUtils.isOprActivityOpenByType(ActivityConst.EventType.DailyActive) then
			return false
		end

		taskMap = taskMap or ActivityUtils.getActTaskMap(pg.me, ActivityConst.EventType.DailyActive)

		local maxTargetNum = 0

		for taskId, _ in pairs(taskMap or EMPTY_TABLE) do
			local config = EventTaskData and EventTaskData[taskId]

			if config and config.actTaskType == ActivityConst.ActivityTaskType.DailyActive_ScoreReward then
				local targetNum = LuaUIUtils.getActScoreCondition(config.taskCondition) or 0

				if maxTargetNum < targetNum then
					maxTargetNum = targetNum
				end
			end
		end

		if maxTargetNum <= 0 then
			return false
		end

		local playerActivityDailyActive = ActivityUtils.getActivityData(pg.me, ActivityConst.EventType.DailyActive)
		local curScore = playerActivityDailyActive and playerActivityDailyActive.dailyActiveScore or 0

		return maxTargetNum <= curScore
	end

	function LuaUIUtils.SchoolGuide_getDailyActiveRedDotStyle(curStyle)
		local allTaskData = ActivityUtils.getActTaskMap(pg.me, ActivityConst.EventType.DailyActive)
		local isScoreFull = LuaUIUtils.isDailyActiveScoreFull(allTaskData)
		local commonTaskFinish, rewardTaskFinish

		for taskId, taskData in pairs(allTaskData or EMPTY_TABLE) do
			if taskData.state == ActivityConst.TaskState.Finihed_CanRecv then
				local config = EventTaskData and EventTaskData[taskId]
				local taskType = config and config.actTaskType

				if taskType == ActivityConst.ActivityTaskType.DailyActive_GetScore then
					if not isScoreFull then
						commonTaskFinish = true
					end
				elseif taskType == ActivityConst.ActivityTaskType.DailyActive_ScoreReward then
					rewardTaskFinish = true
				end
			end
		end

		if rewardTaskFinish then
			return RedDotConst.RedDotStyle.REWARD
		elseif commonTaskFinish then
			return RedDotConst.RedDotStyle.POINT
		else
			return RedDotConst.RedDotStyle.NONE
		end
	end

	function LuaUIUtils.getActScoreCondition(conditionId)
		if not conditionId or conditionId == 0 then
			return nil
		end

		local ctdd = CustomTriggerData[conditionId]

		if not ctdd or not ctdd.condition then
			return nil
		end

		for pos, condition in ipairs(ctdd.condition) do
			if condition and TriggerUtils.getTriggerType(condition) == TriggerConst.TRIGGER_TARGET_ACT_SOCRE then
				local condition0Num = condition[TriggerConst.CUSTOM_TRIGGER_NUM_POS]

				return condition0Num
			end
		end

		return nil
	end
end
