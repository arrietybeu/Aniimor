-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FriendIntimacyExplain\\FriendIntimacyExplainCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local Const = require("Common.Const.Const")
local NoticeDef = require("Common.NoticeDef")
local UIConst = require("Const.UIConst")
local FriendshipEnumData = require("Data.friendship_enum_data")
local FriendshipLevelUpData = require("Data.friendship_level_up_data")
local PlayerInfoCardFunData = require("Data.player_info_card_fun_data")
local SysConfigData = require("Data.sys_config_data")
local PlatformSocialService = require("SDK.Platform.PlatformSocialService")
local ClientTextUtils = require("Utils.ClientTextUtils")
local FriendIntimacyExplainCtrl = Class.LightClass("FriendIntimacyExplainCtrl", UICtrl)
local GIFT_FUNCTION_ID = 7
local PET_EXCHANGE_FUNCTION_ID = 8
local VISIT_HOME_FUNCTION_ID = 10
local DAILY_INTIMACY_LIST_DATA = {
	{
		actionHandler = "openFriendChat",
		bg = "$UI_Img_Likability_Explain_ChatModule.png",
		nameText = "CONSOLE_BAR_CHAT",
		buttonType = 0,
		tIndex = 0,
		intimacyIndex = FriendshipEnumData.CHAT
	},
	{
		actionHandler = "openDoubleActionPanel",
		bg = "$UI_Img_Likability_Explain_InteractionModule.png",
		nameText = "FRIEND_INTIMACY_EXPLAIN_DAILY_ACTION",
		buttonType = 0,
		tIndex = 0,
		intimacyIndex = FriendshipEnumData.ACTION
	},
	{
		actionHandler = "visitFriendHome",
		bg = "$UI_Img_Likability_Explain_HomeModule.png",
		nameText = "FRIEND_INTIMACY_EXPLAIN_DAILY_VISIT_HOME",
		buttonType = 0,
		tIndex = 0,
		intimacyIndex = FriendshipEnumData.VIST_HOMELAND
	},
	{
		bg = "$UI_Img_Likability_Explain_TeamModule.png",
		tipText = "FRIEND_INTIMACY_EXPLAIN_DAILY_TEAM_DUNGEON_TIP",
		nameText = "FRIEND_INTIMACY_EXPLAIN_DAILY_TEAM_DUNGEON",
		buttonType = 1,
		tIndex = 0,
		intimacyIndex = FriendshipEnumData.TEAM_DUNGEON
	},
	{
		bg = "$UI_Img_Likability_Explain_BossModule.png",
		tipText = "FRIEND_INTIMACY_EXPLAIN_DAILY_TEAM_BOSS_TIP",
		nameText = "FRIEND_INTIMACY_EXPLAIN_DAILY_TEAM_BOSS",
		buttonType = 1,
		tIndex = 0,
		intimacyIndex = FriendshipEnumData.TEAM_BOSS
	}
}

local function getPlayerCardFunctionName(functionId)
	return pg.getLocalizationText(PlayerInfoCardFunData[functionId].name)
end

function FriendIntimacyExplainCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self:initUI()
end

function FriendIntimacyExplainCtrl:initUI()
	ClientTextUtils.setText(self.view.titleUSDFText, pg.getGameString("FRIEND_INTIMACY_EXPLAIN_TITLE"))

	local objectReference = self.view.scrollRectUScrollRect.content:GetComponent("ObjectReference")

	self:initDailyIntimacyTitleText(objectReference)
	self:initGainText(objectReference)
	self:initActivityText(objectReference)
end

function FriendIntimacyExplainCtrl:initDailyIntimacyTitleText(objectReference)
	local titleTextIntimacyUSDFText = objectReference:GetRefValue("titleTextIntimacyUSDFText")

	ClientTextUtils.setText(titleTextIntimacyUSDFText, pg.getGameString("FRIEND_INTIMACY_EXPLAIN_DAILY_TITLE"))
end

function FriendIntimacyExplainCtrl:initGainText(objectReference)
	local textIntimacyUSDFText = objectReference:GetRefValue("textIntimacyUSDFText")

	ClientTextUtils.setText(textIntimacyUSDFText, pg.getGameString("FRIEND_INTIMACY_EXPLAIN_GAIN_TITLE"))

	local image2TextUSDFText = objectReference:GetRefValue("image2TextUSDFText")

	ClientTextUtils.setText(image2TextUSDFText, pg.getGameString("FRIEND_INTIMACY_EXPLAIN_DAILY_TITLE"))

	local image2Text1USDFText = objectReference:GetRefValue("image2Text1USDFText")

	ClientTextUtils.setText(image2Text1USDFText, pg.getGameString("FRIEND_INTIMACY_EXPLAIN_FRIEND_INTIMACY"))

	local image2Text2USDFText = objectReference:GetRefValue("image2Text2USDFText")

	ClientTextUtils.setText(image2Text2USDFText, pg.getGameString("CHAT_GIFT_SEND_TITLE"))

	local image2Text3USDFText = objectReference:GetRefValue("image2Text3USDFText")

	ClientTextUtils.setText(image2Text3USDFText, pg.getGameString("FRIEND_INTIMACY_EXPLAIN_FRIEND_INTIMACY"))
end

function FriendIntimacyExplainCtrl:initActivityText(objectReference)
	local title2TextIntimacyUSDFText = objectReference:GetRefValue("title2TextIntimacyUSDFText")

	ClientTextUtils.setText(title2TextIntimacyUSDFText, pg.getGameString("FRIEND_INTIMACY_EXPLAIN_ACTIVITY_TITLE"))
	self:initActivityFirstRowText(objectReference)
	self:initActivitySecondRowText(objectReference)
end

function FriendIntimacyExplainCtrl:initActivityFirstRowText(objectReference)
	local chatTextUSDFText = objectReference:GetRefValue("chatTextUSDFText")

	ClientTextUtils.setText(chatTextUSDFText, pg.getGameString("CONSOLE_BAR_CHAT"))

	local chatText1USDFText = objectReference:GetRefValue("chatText1USDFText")

	ClientTextUtils.setText(chatText1USDFText, pg.getGameString("FRIEND_INTIMACY_EXPLAIN_ACTIVITY_SEND_MESSAGE"))

	local groupTextUSDFText = objectReference:GetRefValue("groupTextUSDFText")

	ClientTextUtils.setText(groupTextUSDFText, pg.getGameString("TEAN_HANDLE"))

	local groupText1USDFText = objectReference:GetRefValue("groupText1USDFText")

	ClientTextUtils.setText(groupText1USDFText, pg.getGameString("FRIEND_INTIMACY_EXPLAIN_ACTIVITY_CHALLENGE_BOSS"))

	local groupPlayTextUSDFText = objectReference:GetRefValue("groupPlayTextUSDFText")

	ClientTextUtils.setText(groupPlayTextUSDFText, pg.getGameString("TEAN_HANDLE"))

	local groupPlayText1USDFText = objectReference:GetRefValue("groupPlayText1USDFText")

	ClientTextUtils.setText(groupPlayText1USDFText, pg.getGameString("FRIEND_INTIMACY_EXPLAIN_ACTIVITY_COMPLETE_MULTIPLAYER"))

	local sendPetTextUSDFText = objectReference:GetRefValue("sendPetTextUSDFText")

	ClientTextUtils.setText(sendPetTextUSDFText, pg.getGameString("ENTER_FOLLOW_TEXT"))

	local sendPetText1USDFText = objectReference:GetRefValue("sendPetText1USDFText")

	ClientTextUtils.setText(sendPetText1USDFText, pg.getFormatText(pg.getGameString("FRIEND_INTIMACY_EXPLAIN_ACTIVITY_SEND_PET"), pg.getGameString("PET")))
end

function FriendIntimacyExplainCtrl:initActivitySecondRowText(objectReference)
	local giftTextUSDFText = objectReference:GetRefValue("giftTextUSDFText")

	ClientTextUtils.setText(giftTextUSDFText, getPlayerCardFunctionName(GIFT_FUNCTION_ID))

	local giftText1USDFText = objectReference:GetRefValue("giftText1USDFText")

	ClientTextUtils.setText(giftText1USDFText, pg.getGameString("FRIEND_INTIMACY_EXPLAIN_ACTIVITY_ADD_INTIMACY"))

	local exchangePetTextUSDFText = objectReference:GetRefValue("exchangePetTextUSDFText")

	ClientTextUtils.setText(exchangePetTextUSDFText, pg.getGameString("PET"))

	local exchangePetText1USDFText = objectReference:GetRefValue("exchangePetText1USDFText")

	ClientTextUtils.setText(exchangePetText1USDFText, getPlayerCardFunctionName(PET_EXCHANGE_FUNCTION_ID))

	local homeTextUSDFText = objectReference:GetRefValue("homeTextUSDFText")

	ClientTextUtils.setText(homeTextUSDFText, pg.getGameString("FILTER_HOMELAND"))

	local homeText1USDFText = objectReference:GetRefValue("homeText1USDFText")

	ClientTextUtils.setText(homeText1USDFText, getPlayerCardFunctionName(VISIT_HOME_FUNCTION_ID))

	local followTextUSDFText = objectReference:GetRefValue("followTextUSDFText")

	ClientTextUtils.setText(followTextUSDFText, pg.getGameString("FRIEND_INTIMACY_EXPLAIN_INTERACTION"))

	local followText1USDFText = objectReference:GetRefValue("followText1USDFText")

	ClientTextUtils.setText(followText1USDFText, pg.getGameString("FRIEND_INTIMACY_EXPLAIN_ACTIVITY_USE_INTERACTION"))
end

function FriendIntimacyExplainCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:close()
	end

	local objectReference = self.view.scrollRectUScrollRect.content:GetComponent("ObjectReference")

	self.contentReference = objectReference

	local btnInteractionUButton = objectReference:GetRefValue("btnInteractionUButton")
	local btnGiveUButton = objectReference:GetRefValue("btnGiveUButton")

	function btnInteractionUButton.luaClick()
		self:scrollToInteractionDescription(self.contentReference)
	end

	function btnGiveUButton.luaClick()
		self:openFriendGift()
	end

	local dailyListUList = objectReference:GetRefValue("dailylistUList")

	function dailyListUList.luaRenderItem(button, _, itemData)
		self:renderDailyIntimacyItem(button, itemData)
	end

	self:bindGamepadScrollUList(self.view.scrollRectUScrollRect, nil, true)
end

function FriendIntimacyExplainCtrl:scrollToInteractionDescription(objectReference)
	local titleTextIntimacyUSDFText = objectReference:GetRefValue("titleTextIntimacyUSDFText")

	self.view.scrollRectUScrollRect:GoToPos(titleTextIntimacyUSDFText.rectTransform, false)
end

function FriendIntimacyExplainCtrl:openFriendGift()
	local friendUid = self.friendUid

	pg.global.ui:open(UIConst.UI_ID_FRIEND_GIFT, {
		playerId = friendUid
	})
end

function FriendIntimacyExplainCtrl:renderDailyIntimacyItem(button, itemData)
	local objectReference = button:GetComponent("ObjectReference")
	local bgUImage = objectReference:GetRefValue("bgUImage")
	local infoUButton = objectReference:GetRefValue("infoUButton")
	local onceUSDFText = objectReference:GetRefValue("onceUSDFText")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local totalUSDFText = objectReference:GetRefValue("totalUSDFText")
	local intimacyIndex = itemData.intimacyIndex
	local intimacyData = FriendshipLevelUpData[intimacyIndex]
	local acquiredIntimacy = pg.game.chat:getFriendIntimacyLimit(self.friendUid, intimacyIndex)

	ClientTextUtils.setText(txtNameUSDFText, pg.getGameString(itemData.nameText))
	ClientTextUtils.setText(onceUSDFText, pg.getFormatText("+{0}", intimacyData.friendshipRange))
	ClientTextUtils.setText(totalUSDFText, pg.getFormatText(pg.getGameString("FRIEND_INTIMACY_EXPLAIN_DAILY_PROGRESS"), acquiredIntimacy, intimacyData.dayMax))

	bgUImage.url = itemData.bg

	button:TryChangePage("Type", itemData.buttonType)
	self:bindDailyIntimacyItemAction(button, infoUButton, itemData)
end

function FriendIntimacyExplainCtrl:bindDailyIntimacyItemAction(button, infoUButton, itemData)
	button.luaClick = nil
	button.luaRenderTooltip = nil
	button.enabledTooltip = false
	infoUButton.luaRenderTooltip = nil

	local actionHandler = itemData.actionHandler

	if actionHandler then
		function button.luaClick()
			self[actionHandler](self)
		end

		return
	end

	function button.luaClick(isFromNavigation)
		infoUButton:OnClickSimulate(isFromNavigation)
	end

	function infoUButton.luaRenderTooltip(_, popup)
		self:renderDailyIntimacyDetailTooltip(popup, itemData.tipText)
	end
end

function FriendIntimacyExplainCtrl:renderDailyIntimacyDetailTooltip(popup, tipTextKey)
	local objectReference = popup:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

	ClientTextUtils.setText(txtNameUSDFText, pg.getGameString(tipTextKey))
end

function FriendIntimacyExplainCtrl:openFriendChat()
	local friendUid = self.friendUid

	self:closeForNavigation()
	pg.global.ui.chat:createNewChat(nil, friendUid)
end

function FriendIntimacyExplainCtrl:openDoubleActionPanel()
	local playerInfo = pg.game.chat:getPlayerInfo(self.friendUid)

	if PlatformSocialService:peekPlatformUserBlockedByLocalUser(playerInfo) == true then
		pg.global.showBubbleMessage(NoticeDef.PRIVACY_SETTING_MISSMATCH)

		return
	end

	local friendUid = self.friendUid

	self:closeForNavigation()
	pg.global.ui:closeAllNormalPanel()
	pg.global.ui:show(UIConst.UI_ID_HUD_V2)
	pg.global.ui:show(UIConst.UI_ID_TOPLOGO)
	pg.global.ui:show(UIConst.UI_ID_INTERACT)

	if pg.global.ui.hudV2 and pg.global.ui.hudV2.LD then
		pg.global.ui.hudV2.LD:openEmoticonPanel({
			interactAction = Const.APPEARANCE_ACTION_TYPE.Double,
			playerId = friendUid
		})
	end
end

function FriendIntimacyExplainCtrl:visitFriendHome()
	local friendUid = self.friendUid
	local playerInfo = pg.game.chat:getPlayerInfo(friendUid)

	pg.game.chat:visitHome(friendUid, playerInfo, function()
		self:closeForNavigation()
	end)
end

function FriendIntimacyExplainCtrl:closeForNavigation()
	local friendIntimacyCtrl = pg.global.ui.friendIntimacy

	friendIntimacyCtrl:saveFriendshipCache()
	friendIntimacyCtrl:close()
end

function FriendIntimacyExplainCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.friendUid = info.friendUid

	self:refreshGainLimitText()
	self:refreshDailyIntimacyList()
end

function FriendIntimacyExplainCtrl:refreshGainLimitText()
	local objectReference = self.view.scrollRectUScrollRect.content:GetComponent("ObjectReference")
	local image2Text4USDFText = objectReference:GetRefValue("image2Text4USDFText")
	local image2Text5USDFText = objectReference:GetRefValue("image2Text5USDFText")
	local chatSystem = pg.game.chat
	local dailyLimitTypeText = pg.getGameString(Const.LimitType2TextKeyMap[Const.LIMIT_DAY])

	ClientTextUtils.setText(image2Text4USDFText, pg.getFormatText(pg.getGameString("FRIEND_INTIMACY_EXPLAIN_GAIN_LIMIT"), dailyLimitTypeText, chatSystem:getFriendIntimacyTodayAcquired(self.friendUid), chatSystem:getFriendIntimacyTodayLimit(self.friendUid)))

	local giftLimitTypeText = pg.getGameString(Const.LimitType2TextKeyMap[SysConfigData.SendGiftLimitType])

	ClientTextUtils.setText(image2Text5USDFText, pg.getFormatText(pg.getGameString("FRIEND_INTIMACY_EXPLAIN_GAIN_GIFT_COUNT"), giftLimitTypeText, chatSystem:getFriendSendGiftLimitCount(self.friendUid), SysConfigData.SendGiftLimitParam))
end

function FriendIntimacyExplainCtrl:refreshDailyIntimacyList()
	local objectReference = self.view.scrollRectUScrollRect.content:GetComponent("ObjectReference")
	local tipsUSDFText = objectReference:GetRefValue("TipsUSDFText")
	local dailyListUList = objectReference:GetRefValue("dailylistUList")
	local chatSystem = pg.game.chat

	ClientTextUtils.setText(tipsUSDFText, pg.getFormatText(pg.getGameString("FRIEND_INTIMACY_EXPLAIN_DAILY_TOTAL"), chatSystem:getFriendIntimacyTodayAcquired(self.friendUid), chatSystem:getFriendIntimacyTodayLimit(self.friendUid)))
	dailyListUList:SetList(DAILY_INTIMACY_LIST_DATA)
end

return FriendIntimacyExplainCtrl
