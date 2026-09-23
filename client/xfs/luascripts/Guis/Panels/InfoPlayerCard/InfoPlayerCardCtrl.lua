-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\InfoPlayerCard\\InfoPlayerCardCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local UICtrl = require("Guis.UICtrl")
local Class = require("Core.Framework.Class")
local CallbackHandler = require("Core.Common.CallbackHandler")
local InfoPlayerCardCtrl = Class.LightClass("InfoPlayerCardCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local Utils = require("Common.Utils.Utils")
local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local EntityManager = require("Core.Common.EntityManager")
local LuaUIUtils = require("Utils.LuaUIUtils")
local BadgeUtils = require("Guis.Utils.BadgeUtils")
local PlayerBadgeData = require("Data.player_badge_data")
local ClientConst = require("Const.ClientConst")
local GlobalData = require("Core.Client.GlobalData")
local AvatarPresetData = require("Data.avatar_preset_data")
local ClientUtils = require("Utils.ClientUtils")
local Const = require("Common.Const.Const")
local LevelData = require("Data.level_data")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local AddressDataConst = require("Const.AddressDataConst")
local CardBackgroundData = require("Data.card_background_data")
local MAX_TEAM_COUNT = 4
local PlayerCollectData = require("Data.player_collect_data")
local SysConfigData = require("Data.sys_config_data")
local RedDotConst = require("Const.RedDotConst")
local CommonSwitch = require("Common.CommonSwitch")
local NoticeDef = require("Common.NoticeDef")
local TeamUtils = require("Utils.TeamUtils")
local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")
local PlatformSocialService = require("SDK.Platform.PlatformSocialService")
local RAINBOW_COLLECTION_ID = 4
local ICON_TYPE_BY_RESPONSE_FUNC = {
	openFriendTree = 1,
	profilePage = 1,
	addFriend = 1
}
local TEAM_FOLLOW_ICON_CONFIG_KEY_BY_RESPONSE_FUNC = {
	inviteTeamFollow = "INVITE_TEAM_FOLLOW",
	joinTeamFollow = "JOIN_TEAM_FOLLOW"
}

InfoPlayerCardCtrl.messages = {
	[MessageName.PLAYER_SPARK_CHANGE] = {
		"refreshPlayerSpark",
		true
	}
}
InfoPlayerCardCtrl.FACE_TO_FACE_DISTANCE = 2

function InfoPlayerCardCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.info = info

	self.model:setPlayerInfo(info.playerInfo)

	self.playerInfo = self.model:getPlayerInfo()

	self:updatePetHandbookCount()

	if pg.me.space then
		self.myLeader = pg.me.space:getSpaceFollowLeader(pg.me.uid)
		self.friendLeader = pg.me.space:getSpaceFollowLeader(self.playerInfo.uid)

		self.model:setSpaceFollowLeader(self.myLeader, self.friendLeader)
	end

	self:setPlayerCardInfo()
	self:sendBaseCustomLog()
	pg.global.refreshRedDotState(RedDotConst.RedDotPath.FRIEND_INTIMACY)

	if self.info.openType == ClientConst.PlayerInfoOpenType.FaceToFace then
		CS.XGUI.Navigation.NavManager.Instance:FocusGroupByName("ListTogether")
	else
		CS.XGUI.Navigation.NavManager.Instance:FocusGroupByName("ListBtnCard")
	end
end

function InfoPlayerCardCtrl:updatePetHandbookCount()
	if self.playerInfo.uid == pg.me.uid then
		local caughtNum = pg.me.petHandbookMap:getFormCountByIdAndStateMask(0, Const.PET_HBMSK_CATCHED) - 1

		self.playerInfo.caughtNum = math.max(caughtNum, 0)
		self.playerInfo.shinyCaughtNum = pg.me.petHandbookMap:getFormCountByIdAndStateMask(0, Const.PET_HBMSK_SHINY_CATCHED)
		self.playerInfo.rainbowCaughtNum = pg.me.petHandbookMap:getFormCountByIdAndStateMask(0, Const.PET_HBMSK_RAINBOW_CATCHED)

		return
	end

	local countMap = Utils.getStableAttributesValue(pg.game.chat.playerDatas[self.playerInfo.uid], "countryPetFormCountMap")

	self.playerInfo.caughtNum = self:getAllCountryPetFormCount(countMap, Const.PET_HBMSK_CATCHED)
	self.playerInfo.shinyCaughtNum = self:getAllCountryPetFormCount(countMap, Const.PET_HBMSK_SHINY_CATCHED)
	self.playerInfo.rainbowCaughtNum = self:getAllCountryPetFormCount(countMap, Const.PET_HBMSK_RAINBOW_CATCHED)
end

function InfoPlayerCardCtrl:getAllCountryPetFormCount(countMap, stateMask)
	if countMap == nil then
		return 0
	end

	local count = 0

	for _, stateCountMap in pairs(countMap) do
		count = count + (stateCountMap[stateMask] or 0)
	end

	return count
end

function InfoPlayerCardCtrl:addListener()
	function self.view.btnCloseFullScreenButton.luaClick()
		self.view.rootUComponent:InvokeCallbackWithCallback(CS.XGUI.EInvokeTime.User1, function()
			self:close()

			if self.info.callBack then
				self.info.callBack()
			end
		end)
	end

	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "closeCommonBind")

	closeBind.actionPath = "Common/ClosePanelCommon"
	closeBind.isVirtual = true
	closeBind.priority = 100

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			local navMgr = pg.global.navMgr
			local isBadgeFocused = navMgr:IsFocusInNavGroupOf(self.view.listBadgeUList)

			if isBadgeFocused and navMgr:PopFocusGroup() then
				return false
			end

			self.view.rootUComponent:InvokeCallbackWithCallback(CS.XGUI.EInvokeTime.User1, function()
				self:close()

				if self.info.callBack then
					self.info.callBack()
				end
			end)
		end

		return false
	end

	function self.view.copyBtn.luaClick()
		local text = self.playerInfo.uid or ""

		UIUtils.ClipboardWriter(text)
		pg.global.ui.tips:showTextTip(pg.getGameString("GM_TIPS_COPY_SUCCESS"))
	end

	function self.view.interactBtnList.luaRenderItem(button, index, data)
		self:renderInteractItem(button, index, data)
	end

	function self.view.listTogetherUList.luaRenderItem(button, index, data)
		self:renderInteractItem(button, index, data)
	end

	function self.view.teamBtn.luaClick()
		self:onTeamBtnClick()
	end

	self:bindCollectionTooltip(self.view.btnGatherUButton, self.getCollectionData)
	self:bindCollectionTooltip(self.view.hongGatherUButton, self.getRainbowCollectionData)

	function self.view.listBadgeUList.luaRenderItem(button, index, data)
		self:renderBadgeItem(button, index, data)
	end

	function self.view.btnVoiceUButton.luaClick()
		local voiceInfo = string.split(self.playerInfo.voiceSignature, "|")

		pg.global.gmeManager:PlayRecordedFile(voiceInfo[2], function(code, filePath)
			pg.game.speech:onPlayFileComplete(filePath)
		end)
	end
end

function InfoPlayerCardCtrl:bindCollectionTooltip(button, collectionDataProvider)
	function button.luaRenderTooltip(_, popup)
		local objectReference = popup:GetComponent("ObjectReference")
		local collectionListUList = objectReference:GetRefValue("collectionListUList")

		function collectionListUList.luaRenderItem(collectionBtn, collectionIndex, collectionData)
			local collectionObjRef = collectionBtn:GetComponent("ObjectReference")
			local txtNameUSDFText = collectionObjRef:GetRefValue("txtNameUSDFText")
			local textValueUSDFText = collectionObjRef:GetRefValue("textValueUSDFText")
			local iconUImage = collectionObjRef:GetRefValue("iconUImage")

			ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(collectionData.name))
			ClientTextUtils.setText(textValueUSDFText, collectionData.value)

			iconUImage.url = collectionData.res

			collectionBtn:TryChangePage("Colour", collectionData.isRare)
		end

		collectionListUList:SetList(collectionDataProvider(self))
	end
end

function InfoPlayerCardCtrl:getCollectionData()
	local collectionData = {}

	for collectId, collectData in ipairs(PlayerCollectData) do
		if collectId ~= RAINBOW_COLLECTION_ID then
			collectionData[#collectionData + 1] = self:createCollectionItem(collectData)
		end
	end

	return collectionData
end

function InfoPlayerCardCtrl:createCollectionItem(collectData)
	return {
		name = collectData.name,
		value = self.playerInfo[collectData.variable] or 0,
		res = collectData.res,
		isRare = collectData.isRare or 0
	}
end

function InfoPlayerCardCtrl:getRainbowCollectionData()
	return {
		self:createCollectionItem(PlayerCollectData[RAINBOW_COLLECTION_ID])
	}
end

function InfoPlayerCardCtrl:renderBadgeItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local badgeIconUImage = objectReference:GetRefValue("badgeIconUImage")
	local cfgData = PlayerBadgeData[data.badgeId]

	badgeIconUImage.url = cfgData.icon

	BadgeUtils.setBadgeQuality(data.badgeId, badgeIconUImage)

	function button.luaClick()
		local focusSnapshot

		if pg.game.input:isUsingGamepad() then
			focusSnapshot = pg.global.navMgr:SaveFocusStackSnapshot()
		end

		self:setUIHide(UIConst.UI_ID_PLAYER_BADGE_DETAIL, true)
		pg.global.ui.badgeDetail:open({
			badgeId = data.badgeId,
			playerId = self.playerInfo.uid,
			playerName = self.playerInfo.playerName
		}, nil, function()
			self:setUIHide(UIConst.UI_ID_PLAYER_BADGE_DETAIL, false)

			if focusSnapshot ~= nil then
				pg.global.navMgr:RestoreFocusStackSnapshot(focusSnapshot)
			end
		end)
	end
end

function InfoPlayerCardCtrl:sendBaseCustomLog()
	local isRemoteSource = self.info.openType == ClientConst.PlayerInfoOpenType.Chat or self.info.openType == ClientConst.PlayerInfoOpenType.Rank

	if isRemoteSource then
		LuaUIUtils.sendCustomLog(Const.BILogName.EVENT_PLAYER_CARD, {
			openIdcardSource = 1
		})
	elseif self.info.openType == ClientConst.PlayerInfoOpenType.FaceToFace or self.info.openType == ClientConst.PlayerInfoOpenType.MobFaceToFace then
		LuaUIUtils.sendCustomLog(Const.BILogName.EVENT_PLAYER_CARD, {
			openIdcardSource = 2
		})
	end

	LuaUIUtils.sendCustomLog(Const.BILogName.EVENT_PLAYER_CARD, {
		IdcardUid = self.playerInfo.uid
	})
	LuaUIUtils.sendCustomLog(Const.BILogName.EVENT_PLAYER_CARD, {
		Idcardfriendstate = self.playerInfo.isFriend
	})

	if pg.game.chat:checkFriendList(self.playerInfo.uid) then
		LuaUIUtils.sendCustomLog(Const.BILogName.EVENT_PLAYER_CARD, {
			Idcardfriendlevel = pg.game.chat:getFriendship(self.playerInfo.uid)
		})
	end

	LuaUIUtils.sendCustomLog(Const.BILogName.EVENT_PLAYER_CARD, {
		openIdcardNum = 1
	})
end

function InfoPlayerCardCtrl:sendCustomLog(responseFunc)
	local param = {}

	if responseFunc == "profilePage" then
		param.clickprofilePage = 1
	elseif responseFunc == "createNewChat" then
		param.clickcreateNewChat = 1
	elseif responseFunc == "teamHandle" then
		param.clickteamHandle = 1
	elseif responseFunc == "addFriend" then
		param.clickaddFriend = 1
	elseif responseFunc == "meetFriend" then
		param.clickmeetFriend = 1
	elseif responseFunc == "giveGift" then
		param.clickgiveGift = 1
	elseif responseFunc == "petExchange" then
		param.clickpetExchange = 1
	elseif responseFunc == "enterWorld" then
		param.clickenterWorld = 1
	elseif responseFunc == "leaveLeaderWorld" then
		-- block empty
	elseif responseFunc == "visitHome" then
		param.clickvisitHome = 1
	elseif responseFunc == "pvpBattle" then
		param.clickpvpBattle = 1
	elseif responseFunc == "removeFriend" then
		param.clickremoveFriend = 1
	elseif responseFunc == "delBlacklist" then
		-- block empty
	elseif responseFunc == "addBlacklist" then
		-- block empty
	elseif responseFunc == "reportChat" then
		-- block empty
	elseif responseFunc == "platformProfile" then
		param.clickplatformProfile = 1
	end

	LuaUIUtils.sendCustomLog(Const.BILogName.EVENT_PLAYER_CARD, {
		param
	})
end

function InfoPlayerCardCtrl:setPlayerCardInfo()
	self:setPlayerBaseInfo()
	self:setInteractList()
	self:setPlayerClassInfo()
	self:setBottomBtn()
end

function InfoPlayerCardCtrl:setPlayerBaseInfo()
	local data = {
		isLock = false,
		showAvatarFrame = true,
		showAvatar = true,
		isEquip = false,
		avatarIconId = self.playerInfo.headIcon,
		avatarFrameIconId = self.playerInfo.headFrame
	}

	LuaUIUtils.renderPlayerAvatar(self.view.headBtn, data)
	self:renderPlayerSparkButton(false)

	local playerName = LuaUIUtils.getPlayerDisplayName(self.playerInfo.uid, self.playerInfo.playerName, true)
	local _h = InfoPlayerCardCtrl._platformHooks

	playerName = _h and _h.setPlayerBaseInfoName and _h.setPlayerBaseInfoName(self, playerName) or playerName
	playerName = self.setDiscordPlayerBaseInfoName and self:setDiscordPlayerBaseInfoName(playerName) or playerName
	self.currentDisplayPlayerName = playerName

	ClientTextUtils.setText(self.view.playerNameText, playerName)

	if _h and _h.setPlayerBaseInfoOnlineID then
		_h.setPlayerBaseInfoOnlineID(self)
	end

	ClientTextUtils.setText(self.view.levelText, self.playerInfo.level or "")

	self.view.emblemImage.url = LuaUIUtils.getStarIcon(self.playerInfo.starTitle)

	if self.playerInfo.templateId == 3 then
		self.view.infoPlayerCardWidget:TryChangePage("Gender", 1)
	elseif self.playerInfo.templateId == 4 then
		self.view.infoPlayerCardWidget:TryChangePage("Gender", 0)
	else
		self.view.infoPlayerCardWidget:TryChangePage("Gender", 2)
	end

	local playerSignText = self.playerInfo.showSignature == "" and pg.getGameString("NO_PLAYER_SIGNATURE") or self.playerInfo.showSignature

	playerSignText = _h and _h.setPlayerBaseInfoSign and _h.setPlayerBaseInfoSign(self, playerSignText) or playerSignText

	ClientTextUtils.setText(self.view.playerSignText, playerSignText)

	if CardBackgroundData[self.playerInfo.cardBackground] then
		self.view.playerBgImage.url = CardBackgroundData[self.playerInfo.cardBackground].res or AddressDataConst.DEFAULT_CARD_BACKGROUND
	else
		self.view.playerBgImage.url = AddressDataConst.DEFAULT_CARD_BACKGROUND
	end

	self:refreshBadgeList()
	ClientTextUtils.setText(self.view.collectNumUSDFText, self.playerInfo.caughtNum)
	ClientTextUtils.setText(self.view.hongGatherTxtNameUSDFText, self.playerInfo.rainbowCaughtNum)
	self.view.btnVoiceUButton:SetActive(not string.isNilOrEmpty(self.playerInfo.voiceSignature))

	if _h and _h.setPlayerBaseInfo then
		_h.setPlayerBaseInfo(self)
	end

	if self.setDiscordPlayerBaseInfo then
		self:setDiscordPlayerBaseInfo()
	end
end

function InfoPlayerCardCtrl:refreshBadgeList()
	local badgeData = {}
	local isMe = self.playerInfo.uid == pg.me.uid
	local badgeShowMap = isMe and pg.me.badgeShowMap or self.playerInfo.badgeShowMap

	if badgeShowMap == nil then
		badgeShowMap = EMPTY_TABLE
	end

	for i = 1, Const.BADGE_SHOW_COUNT do
		local badgeId = badgeShowMap[i] or badgeShowMap[tostring(i)]

		if badgeId and badgeId > 0 and PlayerBadgeData[badgeId] then
			badgeData[#badgeData + 1] = {
				tIndex = 0,
				badgeId = badgeId
			}
		end
	end

	self.view.listBadgeUList:SetList(badgeData)
end

function InfoPlayerCardCtrl:renderPlayerSparkButton(playSparkAnimation)
	LuaUIUtils.renderPlayerSparkButton(self.view.infoPlayerPanelObjectReference, self.playerInfo.uid, LuaUIUtils.PLAYER_AVATAR_TYPE.CHAT, playSparkAnimation, CallbackHandler(self, "close"))
end

function InfoPlayerCardCtrl:refreshPlayerSpark(playerUid)
	if playerUid ~= self.playerInfo.uid then
		return
	end

	self:renderPlayerSparkButton(true)
end

function InfoPlayerCardCtrl:setInteractList()
	local interactData = self.model:getBtnList(self.info.openType)
	local togetherData = self.model:getBtnList(self.info.openType, true)

	if self.addDiscordFriendInviteButton then
		self:addDiscordFriendInviteButton(interactData)
	end

	self.view.interactBtnList:SetList(interactData)
	self.view.listTogetherUList:SetList(togetherData)

	local showTogether = self.playerInfo.uid ~= pg.me.uid and next(togetherData) ~= nil

	self.view.togetherUWidget:SetActive(showTogether)

	if self:tryFocusInteractItem(self.view.interactBtnList, interactData) then
		return
	end

	self:tryFocusInteractItem(self.view.listTogetherUList, togetherData)
end

function InfoPlayerCardCtrl:tryFocusInteractItem(interactList, interactData)
	local focusResponseFuncs = self.info.focusResponseFuncs

	if not focusResponseFuncs then
		return false
	end

	for _, responseFunc in ipairs(focusResponseFuncs) do
		for index, data in ipairs(interactData) do
			if data.responseFunc == responseFunc then
				interactList:GoToIndex(index - 1, true)

				return true
			end
		end
	end

	return false
end

function InfoPlayerCardCtrl:setPlayerClassInfo()
	ClientTextUtils.setText(self.view.uidText, string.format("UID: %s", self.playerInfo.uid))
	ClientTextUtils.setText(self.view.classNumText, pg.getFormatText(pg.getGameString("PLAYER_SESSION_CLASS_INFO"), Utils.getClass(pg.me.uid), 1))
end

function InfoPlayerCardCtrl:setBottomBtn()
	self.view.btnFollow:SetActive(false)

	if self.playerInfo.teamId == nil or self.playerInfo.teamId == "" then
		self.view.teamBtn:SetActive(false)
	else
		self.view.teamBtn:SetActive(true)
	end

	self:setTeamInfo()
end

function InfoPlayerCardCtrl:checkFollowBtnVisible()
	if self.info and (self.info.openType == ClientConst.PlayerInfoOpenType.FaceToFace or self.info.openType == ClientConst.PlayerInfoOpenType.MobFaceToFace) then
		if not string.isNilOrEmpty(self.myLeader) and (not string.isNilOrEmpty(self.friendLeader) or self.myLeader ~= pg.me.uid) then
			return false
		end

		return true
	else
		return false
	end
end

function InfoPlayerCardCtrl:setTeamInfo()
	if self.playerInfo.teamId == "" or self.playerInfo.teamId == nil then
		self.view.teamBtn:SetActive(false)

		return
	end

	self.view.teamBtn:SetActive(true)

	local maxCount = MAX_TEAM_COUNT
	local teamName = pg.getGameString("TEAMMATE_RECRUITING")

	if self.playerInfo.teamDungeonSceneId then
		local dungeonConfig = LevelData[self.playerInfo.teamDungeonSceneId]

		if dungeonConfig then
			maxCount = dungeonConfig.playerNumMax
			teamName = pg.getLocalizationText(dungeonConfig.name)
		end
	end

	ClientTextUtils.setText(self.view.teamNumText, self.playerInfo.teamMembers .. "/" .. maxCount)

	if maxCount > self.playerInfo.teamMembers then
		self.view.teamNameText:SetActive(true)
		ClientTextUtils.setText(self.view.teamNameText, teamName)
	else
		self.view.teamNameText:SetActive(false)
	end
end

function InfoPlayerCardCtrl:onFollowBtnClick()
	local targetEntity = EntityManager.getEntityByUid(self.playerInfo.uid)

	if targetEntity and pg.pawn:followTarget(targetEntity.actorId) then
		ClientUtils.showBubbleMessage(10616)
		self:dismiss()
	end

	LuaUIUtils.sendCustomLog(Const.BILogName.EVENT_PLAYER_CARD, {
		clickFollow = 1
	})
end

function InfoPlayerCardCtrl:onTeamBtnClick()
	if self.info.openType == ClientConst.PlayerInfoOpenType.Edit then
		pg.global.ui:open(UIConst.UI_ID_TEAM_ROOM)
		self.view.rootUComponent:InvokeCallbackWithCallback(CS.XGUI.EInvokeTime.User1, function()
			self:close()

			if self.info.callBack then
				self.info.callBack()
			end
		end)
	elseif pg.me:isInTeam(true) then
		ClientUtils.showBubbleMessageRaw(pg.getGameString("TEAMMATE_RECRUITING_TEAMED"))
	else
		pg.game.chat:teamHandle(self.playerInfo.uid)
	end

	LuaUIUtils.sendCustomLog(Const.BILogName.EVENT_PLAYER_CARD, {
		clickTeamup = 1
	})
end

function InfoPlayerCardCtrl:isTargetInFaceToFaceRange()
	if self.info.openType == ClientConst.PlayerInfoOpenType.FaceToFace then
		return true
	end

	local targetEntity = EntityManager.getEntityByUid(self.playerInfo.uid)

	return targetEntity ~= nil and Utils.distanceEntity(pg.me, targetEntity) <= InfoPlayerCardCtrl.FACE_TO_FACE_DISTANCE
end

function InfoPlayerCardCtrl:refreshOnlyFaceToFaceState(button, data)
	local isActive = self:isTargetInFaceToFaceRange()
	local state = isActive and 1 or 0

	state = isActive and data.overrideState or state

	button:TryChangePage("State", state)

	return isActive
end

function InfoPlayerCardCtrl:renderInteractItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local nameText = objectReference:GetRefValue("name")
	local icon = objectReference:GetRefValue("icon")

	if data.name then
		ClientTextUtils.setText(nameText, pg.getLocalizationText(data.name))
	elseif data.label then
		ClientTextUtils.setText(nameText, pg.getGameString(data.label))
	end

	icon.url = self:getInteractIcon(data)

	button:TryChangePage("IconType", ICON_TYPE_BY_RESPONSE_FUNC[data.responseFunc] or 0)
	button:TryChangePage("Ischange", data.isVariantFriend and 1 or 0)
	button:TryChangePage("Home", data.homelandHasTillableFacility == true and 1 or 0)
	self:bindInteractRedDot(button, data)

	local _h = InfoPlayerCardCtrl._platformHooks

	if _h and _h.setInteractIconColor then
		_h.setInteractIconColor(self, button, data)
	end

	if data.onlyFaceToFace then
		self:refreshOnlyFaceToFaceState(button, data)
	end

	function button.luaClick()
		if data.checkCommonSwitch and not CommonSwitch[data.checkCommonSwitch] then
			pg.global.showBubbleMessage(NoticeDef.COMMON_SWITCH_CLOSE_TIP)

			return
		end

		if data.responseFunc then
			local shouldClose = self[data.responseFunc](self, tostring(self.playerInfo.uid))

			self:sendCustomLog(data.responseFunc)

			if shouldClose ~= false then
				self:dismiss()
			end
		end
	end
end

function InfoPlayerCardCtrl:getInteractIcon(data)
	local configKey = TEAM_FOLLOW_ICON_CONFIG_KEY_BY_RESPONSE_FUNC[data.responseFunc]

	if not configKey then
		return data.icon
	end

	local iconIndex = EntityManager.getEntityByUid(self.playerInfo.uid) and 2 or 1

	return SysConfigData[configKey][iconIndex]
end

function InfoPlayerCardCtrl:bindInteractRedDot(button, data)
	button:ClearRedDot()

	if data.responseFunc ~= "openFriendTree" then
		return
	end

	pg.global.setPreViewRedDot(RedDotConst.RedDotPath.FRIEND_INTIMACY, button, function()
		return self.model:redDot_getFriendIntimacyState()
	end)
end

function InfoPlayerCardCtrl:profilePage(playerId)
	local param = {
		openType = self.info.openType,
		playerId = playerId,
		playerInfo = self.playerInfo,
		callBack = self.info.callBack or CallbackHandler(self, "reopenPlayerCard")
	}

	pg.global.ui:open(UIConst.UI_ID_INFO_PLAYER_MAIN, param)
end

function InfoPlayerCardCtrl:reopenPlayerCard()
	local param = {
		openType = self.info.openType,
		playerId = self.playerInfo.uid,
		callBack = self.info.callBack,
		openSource = pg.game.chat.AddFriendSource.PlayerCard
	}

	LuaUIUtils.openInfoPlayerCard(param)
end

function InfoPlayerCardCtrl:createNewChat(playerId)
	pg.global.ui.chat:createNewChat(nil, playerId)
end

function InfoPlayerCardCtrl:comeToPlayer(playerId)
	local ent = pg.getEntityByUid(playerId)

	if ent and TeamUtils.isPlayerWithinMeetRange(playerId) then
		pg.global.ui.tips:showTextTip(pg.getGameString("PLAYER_WITHIN_RANGE"))

		return
	end

	pg.me:requestEnterWorld(playerId)
end

function InfoPlayerCardCtrl:teamHandle(playerId)
	pg.game.chat:teamHandle(playerId)
end

function InfoPlayerCardCtrl:addFriend(playerId)
	pg.game.chat:applyFriend(playerId, self.info.openSource or pg.game.chat.AddFriendSource.PlayerCard, self.info.sourceName or nil)
end

function InfoPlayerCardCtrl:meetFriend(playerId)
	pg.me:handleRemoteInviteSinglePlayer(playerId, Const.InviteWorldType.MEET_FRIEND)
end

function InfoPlayerCardCtrl:giveGift(playerId)
	pg.global.ui:open(UIConst.UI_ID_FRIEND_GIFT, {
		playerId = playerId
	})

	return false
end

function InfoPlayerCardCtrl:openFriendTree(playerId)
	local playerInfo = self.playerInfo
	local openType = self.info.openType

	Utils.queryFriendship(pg.me, playerId, function(friendshipValue)
		pg.global.ui:hide(UIConst.UI_ID_HUD_V2)
		pg.global.ui:hide(UIConst.UI_ID_TOPLOGO)
		pg.global.ui:hide(UIConst.UI_ID_INTERACT)
		pg.global.ui:open(UIConst.UI_ID_FRIEND_INTIMACY, {
			playerInfo = playerInfo,
			friendshipValue = friendshipValue,
			openType = openType
		})
	end)
end

function InfoPlayerCardCtrl:petExchange(playerId)
	if not pg.game.chat:checkFriendList(playerId) then
		pg.global.ui.tips:showTextTip(pg.getGameString("NOT_FRIEND_EXCHAGEPET_TIP"))

		return
	end

	local targetPlayer = EntityManager.getEntityByUid(playerId)

	if targetPlayer and Utils.distanceEntity(pg.me, targetPlayer) < Const.EXCHANGE_DISTANCE then
		pg.me:invitePetExchange(playerId)
	else
		pg.me:handleRemoteInviteSinglePlayer(playerId, Const.InviteWorldType.EXCHANGE_PET)
	end
end

function InfoPlayerCardCtrl:petVariantInteract(playerId)
	local variantFriendUid = pg.game.chat:getSpecialFriendUId()

	if variantFriendUid ~= playerId then
		pg.global.ui.tips:showTextTip(pg.getGameString("PET_VARIANT_ONLY_SPECIAL_FRIEND"))

		return false
	end

	pg.me:invitePetVariantInteract(playerId)

	return false
end

function InfoPlayerCardCtrl:enterWorld(playerId)
	pg.me:requestEnterWorld(playerId)
end

function InfoPlayerCardCtrl:leaveLeaderWorld()
	pg.me:leaveLeaderWorld()
end

function InfoPlayerCardCtrl:visitHome(playerId)
	local _h = InfoPlayerCardCtrl._platformHooks

	if _h and _h.visitHome then
		return _h.visitHome(self, playerId)
	end

	self:_visitHomeImpl(playerId)
end

function InfoPlayerCardCtrl:_visitHomeImpl(playerId)
	pg.game.chat:visitHome(playerId, self.playerInfo)
end

function InfoPlayerCardCtrl:pvpBattle(playerId)
	pg.game.chat:tryCreatePrivateChat(playerId)
	pg.me:pvpBattleInvite(playerId)
end

function InfoPlayerCardCtrl:removeFriend(playerId)
	pg.global.showConfirmMsgRaw(pg.getGameString("REMOVE_FRIEND_WARNING_TITLE"), pg.getGameString("REMOVE_FRIEND_WARNING_DESC"), function()
		pg.me:removeFriend(playerId)
	end, nil)
end

function InfoPlayerCardCtrl:setRemark(playerId)
	local initialInputText = tostring(self.currentDisplayPlayerName or "")

	pg.global.ui:open(UIConst.UI_ID_CHANGE_NAME, {
		editType = 1,
		initialInputText = initialInputText,
		playerId = playerId
	})
end

function InfoPlayerCardCtrl:changeFriendGroup(playerId)
	local friendGroupList = pg.game.chat:getFriendGroupList()

	if #friendGroupList <= 2 then
		pg.global.showBubbleMessageRaw(pg.getGameString("NO_EXTRA_FRIEND_GROUP"))

		return
	end

	pg.global.ui:open(UIConst.UI_ID_FRIEND_SETUP, {
		playerId = playerId,
		setupType = pg.global.ui.friendSetup.model.FriendSetupType.ChangeGroup
	})
end

function InfoPlayerCardCtrl:delBlacklist(playerId)
	pg.me:delBlacklist(playerId)
end

function InfoPlayerCardCtrl:addBlacklist(playerId)
	pg.global.showConfirmMsgRaw(pg.getGameString("ADD_BLACK_LIST_WARNING_TITLE"), pg.getGameString("ADD_BLACK_LIST_WARNING_DESC"), function()
		pg.me:addBlacklist(playerId)
	end, nil)
end

function InfoPlayerCardCtrl:reportChat(playerId)
	local reportInfo = {}

	if Utils.isTable(self.info) and Utils.isTable(self.info.reportInfo) then
		for key, value in pairs(self.info.reportInfo) do
			reportInfo[key] = value
		end
	end

	reportInfo.uid = reportInfo.uid or playerId
	reportInfo.name = reportInfo.name or self.playerInfo and self.playerInfo.playerName or LuaUIUtils.getPlayerDisplayName(playerId)
	reportInfo.character = reportInfo.character or reportInfo.name
	reportInfo.msgId = reportInfo.msgId or self.info and self.info.msgId

	pg.global.ui:open(UIConst.UI_ID_ACCUSATION, {
		playerName = LuaUIUtils.getPlayerDisplayName(playerId, self.playerInfo.playerName),
		playerId = playerId,
		reportInfo = reportInfo,
		reportText = self.info and self.info.reportText
	})
end

function InfoPlayerCardCtrl:openEmoticonPanel(playerId)
	local ent = pg.game.chat:getChatEntityByUid(playerId)

	if self.info.openType == ClientConst.PlayerInfoOpenType.PlayerGhost or Utils.isPlayerGhost(ent) then
		pg.global.showBubbleMessageRaw(pg.getGameString("PLAYER_MIRROR_FACE_TO_FACE"))

		return
	end

	if not self:isTargetInFaceToFaceRange() then
		pg.global.showBubbleMessageById(NoticeDef.ONLY_FACE_TO_FACE_FUNC)

		return
	end

	if PlatformSocialService:peekPlatformUserBlockedByLocalUser(self.playerInfo) == true then
		pg.global.showBubbleMessage(NoticeDef.PRIVACY_SETTING_MISSMATCH)

		return
	end

	if pg.global.ui.hudV2 and pg.global.ui.hudV2.LD then
		pg.global.ui.hudV2.LD:openEmoticonPanel({
			interactAction = Const.APPEARANCE_ACTION_TYPE.Double,
			playerId = playerId
		})
	end
end

function InfoPlayerCardCtrl:platformProfile(playerId)
	local platformBridgeLuaFacade = CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade
	local platformUserId = PlatformIdentityUtils.resolvePlatformUserId(self.playerInfo)

	if not string.isNilOrEmpty(platformUserId) then
		platformBridgeLuaFacade.ShowPlayerProfileCard(tostring(platformUserId))
	end
end

function InfoPlayerCardCtrl:tryConfirmEnterTeamLeaderWorld(playerId)
	if self:isTargetInFaceToFaceRange() or not pg.me:isUidTeamMember(playerId) or pg.me:isTeamLeader() or pg.me:isUidTeamLeader(playerId) then
		return false
	end

	local leaderUid = pg.me:getCurTeamInfo().leaderUid

	pg.global.showConfirmMsgRaw(pg.getGameString("SPACE_FOLLOW_ENTER_LEADER_WORLD_TITLE"), pg.getGameString("SPACE_FOLLOW_ENTER_LEADER_WORLD_DESC"), function()
		pg.me:requestEnterWorld(leaderUid)
	end, nil)

	return true
end

function InfoPlayerCardCtrl:joinTeamFollow(playerId)
	if self:tryConfirmEnterTeamLeaderWorld(playerId) then
		return
	end

	pg.me:reqSpaceFollow(playerId)
end

function InfoPlayerCardCtrl:inviteTeamFollow(playerId)
	if self:tryConfirmEnterTeamLeaderWorld(playerId) then
		return
	end

	pg.me:inviteSpaceFollow(playerId)
end

function InfoPlayerCardCtrl:kickTeamFollow(playerId)
	pg.me:kickSpaceFollow(playerId)
end

function InfoPlayerCardCtrl:quitTeamFollow(playerId)
	pg.me:exitSpaceFollow()
end

function InfoPlayerCardCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.info = info
end

function InfoPlayerCardCtrl:onDestroy()
	pg.game.speech:stopPlayAudioFile()
end

return InfoPlayerCardCtrl
