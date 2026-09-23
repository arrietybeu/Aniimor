-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\LuaUIUtils\\UIPlayerSparkUtils.lua

local ActivityConst = require("Common.Const.ActivityConst")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PLAYER_SPARK_ADVANCED_DAYS = 5
local PLAYER_SPARK_ACTIVE_PAGE = 0
local PLAYER_SPARK_STRONG_PAGE = 1
local PLAYER_SPARK_NOT_RENEWED_PAGE = 2

return function(LuaUIUtils)
	function LuaUIUtils.renderPlayerSparkButton(objectReference, playerId, avatarType, playSparkAnimation, beforeOpenActivity)
		local isChatAvatar = avatarType == LuaUIUtils.PLAYER_AVATAR_TYPE.CHAT
		local isOpen = false
		local activityId

		if isChatAvatar then
			isOpen, activityId = ActivityUtils.isOprActivityOpenByType(ActivityConst.EventType.LittleFirePerson, pg.me)
		end

		local btnSparkUButton = objectReference:GetRefValue("btnsparkUButton")
		local btnSparkObjectReference = btnSparkUButton:GetComponent("ObjectReference")
		local sparkUWidget = btnSparkObjectReference:GetRefValue("sparkUWidget")
		local showSpark = isOpen and LuaUIUtils.getPlayerSparkInfo(playerId) > 0

		btnSparkUButton.gameObject:SetActiveEx(showSpark)

		btnSparkUButton.luaClick = nil
		btnSparkUButton.luaRenderTooltip = nil

		if not showSpark then
			return
		end

		LuaUIUtils.renderPlayerSpark(sparkUWidget, playerId, playSparkAnimation)

		function btnSparkUButton.luaRenderTooltip(triggerButton, tooltip)
			LuaUIUtils.renderPlayerSparkTooltip(triggerButton, tooltip, playerId, activityId, beforeOpenActivity)
		end
	end

	function LuaUIUtils.playPlayerSparkAnimation(sparkUWidget)
		sparkUWidget:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
	end

	function LuaUIUtils.getPlayerSparkInfo(playerId)
		local streakDaysMap = pg.me.sparkStreakDaysMap
		local lastLightDayMap = pg.me.sparkLastLightDayMap
		local uid = tostring(playerId)
		local streakDays = streakDaysMap and streakDaysMap[uid] or 0
		local lastLightDay = lastLightDayMap and lastLightDayMap[uid] or 0
		local sparkedToday = lastLightDay == pg.me.lastDayUpdateTs
		local sparkPage = PLAYER_SPARK_NOT_RENEWED_PAGE

		if streakDays > 0 and sparkedToday then
			sparkPage = streakDays >= PLAYER_SPARK_ADVANCED_DAYS and PLAYER_SPARK_STRONG_PAGE or PLAYER_SPARK_ACTIVE_PAGE
		end

		return streakDays, sparkedToday, sparkPage
	end

	function LuaUIUtils.renderPlayerSpark(sparkUWidget, playerId, playSparkAnimation)
		local objectReference = sparkUWidget:GetComponent("ObjectReference")
		local textDayUSDFText = objectReference:GetRefValue("textDayUSDFText")
		local fxUWidget = objectReference:GetRefValue("fxUWidget")
		local streakDays, sparkedToday, sparkPage = LuaUIUtils.getPlayerSparkInfo(playerId)

		ClientTextUtils.setText(textDayUSDFText, streakDays)
		sparkUWidget:TryChangePage("Spark", sparkPage)
		fxUWidget:SetActive(playSparkAnimation == true)

		if playSparkAnimation then
			LuaUIUtils.playPlayerSparkAnimation(sparkUWidget)
		end

		return streakDays, sparkedToday
	end

	function LuaUIUtils.renderPlayerSparkTooltip(triggerButton, tooltip, playerId, activityId, beforeOpenActivity)
		local objectReference = tooltip.transform:GetComponent("ObjectReference")
		local textTtileUSDFText = objectReference:GetRefValue("textTtileUSDFText")
		local textUSDFText = objectReference:GetRefValue("textUSDFText")
		local text1USDFText = objectReference:GetRefValue("text1USDFText")
		local btnSponsorUButton = objectReference:GetRefValue("btnSponsorUButton")
		local sparkUWidget = objectReference:GetRefValue("sparkUWidget")

		tooltip:TryChangePage("Type", 0)
		tooltip:TryChangePage("Ttile", 1)

		local streakDays, sparkedToday = LuaUIUtils.renderPlayerSpark(sparkUWidget, playerId, false)

		ClientTextUtils.setText(textTtileUSDFText, pg.getGameString("CHAT_SPARK_TITLE"))
		ClientTextUtils.setText(textUSDFText, pg.getFormatText(pg.getGameString("CHAT_SPARK_STREAK_DAYS"), streakDays))
		ClientTextUtils.setText(text1USDFText, pg.getGameString("CHAT_SPARK_NOT_RENEWED_TODAY"))
		text1USDFText.gameObject:SetActiveEx(not sparkedToday)
		LuaUIUtils.renderPlayerSparkSponsorButton(btnSponsorUButton, triggerButton, activityId, beforeOpenActivity)
	end

	function LuaUIUtils.renderPlayerSparkSponsorButton(btnSponsorUButton, triggerButton, activityId, beforeOpenActivity)
		local objectReference = btnSponsorUButton.transform:GetComponent("ObjectReference")
		local uIBtn1stConfirmUButton = objectReference:GetRefValue("uIBtn1stConfirmUButton")
		local txtNameUText = objectReference:GetRefValue("txtNameUText")
		local keyHotKeyContent = objectReference:GetRefValue("keyHotKeyContent")

		ClientTextUtils.setText(txtNameUText, pg.getGameString("CHAT_SPARK_VIEW_ACTIVITY"))
		keyHotKeyContent:SetHotKeyPaths("Hud/TipEnter")

		function uIBtn1stConfirmUButton.luaClick()
			triggerButton:ClosePopup()

			if beforeOpenActivity then
				beforeOpenActivity()
			end

			pg.global.ui:open(UIConst.UI_ID_EVENT, {
				tabType = UIConst.EVENT_TAB_TYPE.ACTIVITY,
				id = activityId
			})
		end
	end
end
