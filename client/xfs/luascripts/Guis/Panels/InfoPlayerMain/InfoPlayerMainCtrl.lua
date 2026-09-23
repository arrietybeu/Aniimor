-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\InfoPlayerMain\\InfoPlayerMainCtrl.lua

local ClientUtils = require("Utils.ClientUtils")
local UICtrl = require("Guis.UICtrl")
local Class = require("Core.Framework.Class")
local InfoPlayerMainCtrl = Class.LightClass("InfoPlayerMainCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local Utils = require("Common.Utils.Utils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientConst = require("Const.ClientConst")
local FriendshipLevelData = require("Data.friendship_level_data")
local AvatarPresetData = require("Data.avatar_preset_data")
local Const = require("Common.Const.Const")
local EditComponent = require("Guis.Panels.InfoPlayerMain.Component.EditComponent")
local MessageName = require("Const.MessageName")
local ShowTitleData = require("Data.show_title_data")
local AddressDataConst = require("Const.AddressDataConst")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local PlayerCollectData = require("Data.player_collect_data")
local UIConst = require("Const.UIConst")
local PlayerBadgeData = require("Data.player_badge_data")
local PhotographyStudioUtils = require("Utils.PhotographyStudioUtils")
local ShowTitleUtils = require("Utils.ShowTitleUtils")

InfoPlayerMainCtrl.DEFAULT_PROFILE_PHOTOGRAPHY_STUDIO_UID = "__profile_default_photography_studio__"
InfoPlayerMainCtrl.messages = {
	[MessageName.PLAYER_NAME_CHANGE] = {
		"refreshPlayerName",
		true
	},
	[MessageName.PLAYER_ICON_CHANGE] = {
		"refreshPlayerIconSelected",
		true
	},
	[MessageName.PLAYER_FRAME_CHANGE] = {
		"refreshPlayerIconSelected",
		true
	},
	[MessageName.PLAYER_TITLE_CHANGE] = {
		"refreshPlayerTitle",
		true
	},
	[MessageName.PLAYER_SHOW_SIGNATURE_CHANGE] = {
		"refreshShowSignature",
		true
	},
	[MessageName.PLAYER_CARD_BACKGROUND_CHANGE] = {
		"refreshPlayerCardBackground",
		true
	},
	[MessageName.PLAYER_BADGE_SHOW_MAP_CHANGED] = {
		"onBadgeShowMapChanged",
		true
	},
	[MessageName.ON_PROFILE_PHOTOGRAPHY_STUDIO_CHANGED] = {
		"onProfilePhotographyStudioUidChanged",
		true
	}
}

function InfoPlayerMainCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.view.widget.visibility = CS.XGUI.EVisibility.Visible
	self.isDestroyed = false
	self.isClosing = false
	self.info = info
	self.defaultEditTabIndex = info.defaultEditTabIndex or nil
	self.defaultTitleType = info.defaultTitleType
	self.friendTitleInfo = info.friendTitleInfo
	self.friendTitleQueryToken = nil
	self.resolvedFriendTitleName = nil

	if info.playerId == pg.me.uid then
		self.info.openType = ClientConst.PlayerInfoOpenType.Edit
	end

	if self.info.openType == ClientConst.PlayerInfoOpenType.Edit then
		local presetData = pg.game.avatar:getAvatarPresetData(pg.me.avatarPresetKey) or {}
		local templateId = presetData.templateId or 0

		self:setSelfPlayerInfo(info.playerId, pg.me.headIcon, pg.me.headFrame, pg.me.playerName, pg.me.userName, pg.me.homelandKey, true, pg.me.starTitle, pg.me.level, templateId, pg.me:isInTeam() and pg.me:getCurTeamInfo().teamId or "", pg.me.showSignature, pg.me.teamMembers or 1, pg.me.teamDungeonSceneId, pg.me.isWholeTitle, pg.me.showTitles, pg.me.showTitleExtra, pg.me.cardBackground, pg.me.avatarPresetKey, pg.me.avatarConfig, pg.me.curShow, pg.me.fashionScore, pg.me.badgeShowMap)

		local caughtNum = pg.me.petHandbookMap:getFormCountByIdAndStateMask(0, Const.PET_HBMSK_CATCHED) - 1

		self.playerInfo.caughtNum = math.max(caughtNum, 0)
		self.playerInfo.shinyCaughtNum = pg.me.petHandbookMap:getFormCountByIdAndStateMask(0, Const.PET_HBMSK_SHINY_CATCHED)
		self.playerInfo.rainbowCaughtNum = pg.me.petHandbookMap:getFormCountByIdAndStateMask(0, Const.PET_HBMSK_RAINBOW_CATCHED)
		self.playerInfo.profilePhotographyStudioUid = pg.me.profilePhotographyStudioUid

		self.view.rootUComponent:TryChangePage("Type", 1)
	else
		self.playerInfo = self.info.playerInfo

		self.view.rootUComponent:TryChangePage("Type", 0)
		LuaUIUtils.sendCustomLog(Const.BILogName.EVENT_PROFILE_PAGE, {
			openprofilepageNum = 1
		})
		LuaUIUtils.sendCustomLog(Const.BILogName.EVENT_PROFILE_PAGE, {
			profilepageUid = self.playerInfo.uid
		})
		LuaUIUtils.sendCustomLog(Const.BILogName.EVENT_PROFILE_PAGE, {
			profilepagefriendstate = self.playerInfo.isFriend
		})
		LuaUIUtils.sendCustomLog(Const.BILogName.EVENT_PROFILE_PAGE, {
			profilepagefriendlevel = pg.game.chat:getFriendship(self.playerInfo.uid)
		})
	end

	self.playerInfo.badgeShowMap = self.playerInfo.badgeShowMap or {}

	self:setPlayerInfo()

	self.avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)

	self:applyPhotographyStudioPreview()

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_FRIEND_GROUP_SETUP) then
		pg.global.ui.friendGroupSetup:hide()
	end

	if self.defaultEditTabIndex and self.info.openType == ClientConst.PlayerInfoOpenType.Edit then
		self:onEditButtonClick(self.defaultEditTabIndex)
	end

	local _h = InfoPlayerMainCtrl._platformHooks

	if _h and _h.onCreate then
		_h.onCreate(self)
	end
end

function InfoPlayerMainCtrl:onShow()
	if self.editComponent then
		self.editComponent:onShow()

		self.defaultEditTabIndex = nil
	end
end

function InfoPlayerMainCtrl:getConfiguredProfilePhotographyStudioUid()
	local studioUid = self.playerInfo and self.playerInfo.profilePhotographyStudioUid

	studioUid = self:isSelfProfileEditMode() and pg.me and pg.me.profilePhotographyStudioUid or studioUid

	if studioUid == nil or tostring(studioUid) == "" then
		return nil
	end

	return tostring(studioUid)
end

function InfoPlayerMainCtrl:getEffectiveProfilePhotographyStudioUid()
	local studioUid = self:getConfiguredProfilePhotographyStudioUid()

	if studioUid ~= nil then
		return studioUid
	end

	if self:isSelfProfileEditMode() then
		return PhotographyStudioUtils.getDefaultPhotographyStudioUid() or InfoPlayerMainCtrl.DEFAULT_PROFILE_PHOTOGRAPHY_STUDIO_UID
	end

	return InfoPlayerMainCtrl.DEFAULT_PROFILE_PHOTOGRAPHY_STUDIO_UID
end

function InfoPlayerMainCtrl:applyDefaultProfilePhotographyStudioPreview()
	if not self.avatarScene then
		return
	end

	self.previewStudioUid = InfoPlayerMainCtrl.DEFAULT_PROFILE_PHOTOGRAPHY_STUDIO_UID

	self:applyPhotographyStudioPreviewContent(InfoPlayerMainCtrl.DEFAULT_PROFILE_PHOTOGRAPHY_STUDIO_UID, {})
end

function InfoPlayerMainCtrl:restoreProfileAvatarScene()
	if self.isDestroyed or self.isClosing then
		return
	end

	pg.global.ui:restoreAllUIByCustomKey(UIConst.UI_HIDE_KEY.APPEARANCE)

	self.avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)

	if not self.avatarScene or self.avatarScene.expire then
		return
	end

	if self:isSelfProfileEditMode() then
		self.playerInfo.profilePhotographyStudioUid = pg.me and pg.me.profilePhotographyStudioUid or self.playerInfo.profilePhotographyStudioUid
	end

	self.previewStudioUid = self:getEffectiveProfilePhotographyStudioUid()

	local appearanceEntity = self.avatarScene:getCurEntity()

	if appearanceEntity and appearanceEntity ~= self.entity and appearanceEntity.eModel then
		appearanceEntity.eModel:SetActive(false)
	end

	PhotographyStudioUtils.clearReadonlyDIY(self.view, self.previewDIYObjs)

	self.previewDIYObjs = nil

	self:applyPhotographyStudioPreview(self.previewStudioUid)
end

function InfoPlayerMainCtrl:prepareAppearanceScene()
	if self.isDestroyed or not self.avatarScene or self.avatarScene.expire then
		return
	end

	local appearanceEntity = self.avatarScene:getCurEntity()

	self.previewStudioUid = nil

	self.avatarScene:disableStudioFreeCamera()
	self.avatarScene:clearPhotographyStudioDisplayPreset()

	if appearanceEntity and appearanceEntity.eModel then
		appearanceEntity.eModel:SetActive(false)
	end

	PhotographyStudioUtils.clearReadonlyDIY(self.view, self.previewDIYObjs)

	self.previewDIYObjs = nil

	if self.entityManagedByAvatarScene then
		self.entity = nil
		self.entityManagedByAvatarScene = nil
	elseif self.entity and self.entity.eModel then
		self.entity.eModel:SetActive(false)
	end
end

function InfoPlayerMainCtrl:isSelfProfileEditMode()
	return self.info.openType == ClientConst.PlayerInfoOpenType.Edit and tostring(self.playerInfo.uid) == tostring(pg.me.uid)
end

function InfoPlayerMainCtrl:selectPhotographyStudioBackground(studioUid)
	studioUid = studioUid and tostring(studioUid) or ""

	if not self:isSelfProfileEditMode() or studioUid ~= "" and not pg.me:getStudioInfo(studioUid) then
		return false
	end

	pg.me:reqChangeProfilePhotographyStudioUid(studioUid)

	return true
end

function InfoPlayerMainCtrl:buildProfilePhotographyStudioContent(content)
	local previewContent = Utils.deepCopyTable(content or {})

	previewContent.players = previewContent.players or {}

	local playerUid = tostring(self.playerInfo.uid)
	local mainData

	for uid, data in pairs(previewContent.players) do
		if tostring(uid) == playerUid then
			mainData = data

			break
		end
	end

	if type(mainData) ~= "table" then
		mainData = {}
		previewContent.players[playerUid] = mainData
	end

	mainData.templateId = self.playerInfo.templateId
	mainData.avatarPresetKey = self.playerInfo.avatarPresetKey
	mainData.avatarConfig = self.playerInfo.avatarConfig

	local curShow = Utils.deepCopyTable(PhotographyStudioUtils.toRawTable(self.playerInfo.curShow) or {})

	mainData.curShow = curShow
	mainData.appearance = PhotographyStudioUtils.serializeAppearanceFromCustomShow(curShow and curShow.customShow)

	return previewContent
end

function InfoPlayerMainCtrl:applyPhotographyStudioPreview(studioUid)
	if studioUid == nil then
		studioUid = self:getEffectiveProfilePhotographyStudioUid()
	end

	if studioUid == nil or tostring(studioUid) == "" then
		self:applyDefaultProfilePhotographyStudioPreview()

		return
	end

	studioUid = tostring(studioUid)

	if studioUid == InfoPlayerMainCtrl.DEFAULT_PROFILE_PHOTOGRAPHY_STUDIO_UID then
		self:applyDefaultProfilePhotographyStudioPreview()

		return
	end

	self.previewStudioUid = studioUid

	local content = pg.me:getCachedPhotographyStudioContent(studioUid)

	if content then
		self:applyPhotographyStudioPreviewContent(studioUid, content)

		return
	end

	pg.me:fetchStudioContent(studioUid, function(fetched, ok)
		if self.isDestroyed or self.isClosing or self.previewStudioUid ~= studioUid then
			return
		end

		if ok and type(fetched) == "table" then
			self:applyPhotographyStudioPreviewContent(studioUid, fetched)
		end
	end)
end

function InfoPlayerMainCtrl:applyPhotographyStudioPreviewContent(studioUid, content)
	if self.isDestroyed or self.isClosing or self.previewStudioUid ~= studioUid or not self.avatarScene then
		return
	end

	content = self:buildProfilePhotographyStudioContent(content)

	local common, _, mainEntity = self.avatarScene:applyPhotographyStudioFullPreview(studioUid, content, {
		ignoreUnlock = true,
		useMainPlayerAsCurrent = true,
		mainPlayerUid = self.playerInfo.uid,
		showAllPlayers = pg.me:getStudioInfo(studioUid) == nil
	})

	if mainEntity then
		if self.entity and not self.entityManagedByAvatarScene then
			ClientUtils.safeDestroy(self.entity)
		end

		self.entity = mainEntity
		self.entityManagedByAvatarScene = true
	end

	if NotNil(self.view.dIYPreviewRootRectTransform) then
		self.previewDIYObjs = PhotographyStudioUtils.renderReadonlyDIY(self.view, self.view.dIYPreviewRootRectTransform, common.diyInfo, self.previewDIYObjs, true)
	end
end

function InfoPlayerMainCtrl:onProfilePhotographyStudioUidChanged(studioUid)
	if not self:isSelfProfileEditMode() then
		return
	end

	self.playerInfo.profilePhotographyStudioUid = studioUid

	if self.editComponent and self.editComponent.circumstancesComponent then
		self.editComponent.circumstancesComponent:refreshPanel()
	end

	self:applyPhotographyStudioPreview(studioUid)
end

function InfoPlayerMainCtrl:addListener()
	function self.view.btnClose.luaClick()
		pg.game.speech:stopPlayAudioFile()

		local _, page = self.view.rootUComponent:TryGetCurrentPage("State")

		if page == 1 then
			self:restoreProfileAvatarScene()
			self.view.rootUComponent:TryChangePage("State", 0)

			if self.editComponent and self.editComponent.titleBarComponent then
				self.editComponent.titleBarComponent:clearTitlePreview(pg.me.isWholeTitle)
			end

			self.view.topTitleUWidget.gameObject:SetActiveEx(true)
			self:refreshPlayerTitle(true)
			self:sendCustomLogAfterEdit()
		else
			if pg.global.ui:checkUIOpen(UIConst.UI_ID_FRIEND_GROUP_SETUP) then
				pg.global.ui.friendGroupSetup:show()
			end

			self.isClosing = true

			if self.avatarScene and not self.avatarScene.expire and self.previewStudioUid then
				self.avatarScene:disableStudioFreeCamera()
			end

			self:close()

			if self.info.callBack then
				self.info.callBack()
			end
		end
	end

	self:bindHotKeyPerform("Common/Cancel", function()
		self.view.btnClose.luaClick()
	end, self.view.btnClose.gameObject)

	function self.view.panelInfoCopyButton.luaClick()
		local text = self.playerInfo.uid or ""

		UIUtils.ClipboardWriter(text)
		pg.global.ui.tips:showTextTip(pg.getGameString("GM_TIPS_COPY_SUCCESS"))
	end

	function self.view.btnAdd.luaClick()
		self:onAddButtonClick()
	end

	function self.view.btnEdit.luaClick()
		self:onEditButtonClick()
	end

	function self.view.btnChat.luaClick()
		self:onChatButtonClick()
	end

	function self.view.panelInfoCollectList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
		local txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
		local iconUImage = objectReference:GetRefValue("iconUImage")

		ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(data.name))
		ClientTextUtils.setText(txtNumUSDFText, data.value)

		iconUImage.url = data.res
	end

	function self.view.panelInfoBadgeUList.luaRenderItem(button, index, data)
		if data.badgeId > 0 then
			button:TryChangePage("Badge", 0)
			self:renderBadgeItem(button, index, data)
		else
			button.luaClick = nil

			button:TryChangePage("Badge", 1)
		end
	end
end

function InfoPlayerMainCtrl:renderBadgeItem(button, index, data)
	if data.badgeId > 0 then
		button:TryChangePage("Badge", 0)

		local objectReference = button:GetComponent("ObjectReference")
		local imageBadgeIconUImage = objectReference:GetRefValue("imageBadgeIconUImage")
		local cfgData = PlayerBadgeData[data.badgeId]

		imageBadgeIconUImage.url = cfgData.icon

		function button.luaClick()
			pg.global.ui.badgeDetail:open({
				badgeId = data.badgeId,
				playerId = self.playerInfo.uid,
				playerName = self.playerInfo.playerName
			})
		end
	else
		button:TryChangePage("Badge", 1)
	end
end

function InfoPlayerMainCtrl:sendCustomLogAfterEdit()
	local profilepagetitletype

	if self.playerInfo.isWholeTitle then
		profilepagetitletype = 4
	else
		local hasPrefix = self.playerInfo.showTitles[Const.SHOW_TITLE_TYPE.Prefix] or ShowTitleUtils.hasFriendPrefix(self.playerInfo.showTitleExtra)

		profilepagetitletype = hasPrefix and self.playerInfo.showTitles[Const.SHOW_TITLE_TYPE.Suffix] and 3 or not hasPrefix and 2 or (self.playerInfo.showTitles[Const.SHOW_TITLE_TYPE.Suffix] == nil or self.playerInfo.showTitles[Const.SHOW_TITLE_TYPE.Suffix] == "") and 1 or 0
	end

	LuaUIUtils.sendCustomLog(Const.BILogName.EVENT_PROFILE_PAGE, {
		profilepagetitletype = profilepagetitletype or 0
	})
	LuaUIUtils.sendCustomLog(Const.BILogName.EVENT_PROFILE_PAGE, {
		profilepagesigntype = self.playerInfo.showSignature and self.playerInfo.showSignature ~= "" and 1 or 0
	})
end

function InfoPlayerMainCtrl:setPlayerInfo()
	self:setPlayerBaseInfo()
	self:setPlayerClassInfo()
	self:refreshBottomButtons()
	self:refreshPlayerTitle(true)
	self:queryFriendShowTitleName()
end

function InfoPlayerMainCtrl:setPlayerBaseInfo()
	self:refreshPlayHead()

	local playerName = LuaUIUtils.getPlayerDisplayName(self.playerInfo.uid, self.playerInfo.playerName, true)
	local _h = InfoPlayerMainCtrl._platformHooks

	playerName = _h and _h.setPlayerBaseInfoName and _h.setPlayerBaseInfoName(self, playerName) or playerName

	ClientTextUtils.setText(self.view.panelInfoPlayerNameText, playerName)
	ClientTextUtils.setText(self.view.panelInfoLevelText, self.playerInfo.level or "")

	self.view.panelInfoEmblemImage.url = LuaUIUtils.getStarIcon(self.playerInfo.starTitle)

	if pg.game.chat:checkFriendList(self.playerInfo.uid) then
		local friendshipLevel = pg.game.chat:getFriendship(self.playerInfo.uid)

		self.view.panelInfoLikabilityImage:SetActive(true)

		self.view.panelInfoLikabilityImage.url = FriendshipLevelData[friendshipLevel] and FriendshipLevelData[friendshipLevel].levelIcon or ""
	else
		self.view.panelInfoLikabilityImage:SetActive(false)
	end

	if self.playerInfo.templateId == 3 then
		self.view.rootUComponent:TryChangePage("Gender", 1)
	elseif self.playerInfo.templateId == 4 then
		self.view.rootUComponent:TryChangePage("Gender", 0)
	else
		self.view.rootUComponent:TryChangePage("Gender", 2)
	end

	self.view.widget:TryChangePage("UIDState", string.isNilOrEmpty(self.playerInfo.uid) and 0 or 1)
	ClientTextUtils.setText(self.view.panelInfoUidText, string.format("UID: %s", self.playerInfo.uid))

	local playerSignText = self.playerInfo.showSignature == "" and pg.getGameString("NO_PLAYER_SIGNATURE") or self.playerInfo.showSignature

	playerSignText = _h and _h.setPlayerBaseInfoSign and _h.setPlayerBaseInfoSign(self, playerSignText) or playerSignText

	ClientTextUtils.setText(self.view.panelInfoPlayerSignText, playerSignText)

	if _h and _h.setPlayerBaseInfoOnlineID then
		_h.setPlayerBaseInfoOnlineID(self)
	end

	self.view.panelInfoCollectList:SetList(self:getCollectionData())

	if _h and _h.setPlayerBaseInfo then
		_h.setPlayerBaseInfo(self)
	end

	self:refreshBadgeList()
end

function InfoPlayerMainCtrl:getCollectionData()
	local collectionData = {}

	for _, collectData in ipairs(PlayerCollectData) do
		collectionData[#collectionData + 1] = {
			name = collectData.name,
			value = self.playerInfo[collectData.variable] or 0,
			res = collectData.res,
			isRare = collectData.isRare or 0
		}
	end

	return collectionData
end

function InfoPlayerMainCtrl:onBadgeShowMapChanged()
	if self.info.openType == ClientConst.PlayerInfoOpenType.Edit then
		self.playerInfo.badgeShowMap = pg.me.badgeShowMap or {}

		self:refreshBadgeList()
	end
end

function InfoPlayerMainCtrl:refreshBadgeList()
	local badgeData = {}
	local badgeShowMap = self.playerInfo.badgeShowMap

	for i = 1, Const.BADGE_SHOW_COUNT do
		local badgeId = badgeShowMap[i] or badgeShowMap[tostring(i)] or 0

		badgeData[#badgeData + 1] = {
			badgeId = badgeId
		}
	end

	self.view.panelInfoBadgeUList:SetList(badgeData)
end

function InfoPlayerMainCtrl:setPlayerClassInfo()
	self.view.rootUComponent:TryChangePage("ClassInfo", 0)
	ClientTextUtils.setText(self.view.panelInfoClassNumText, self.playerInfo.uid)
	ClientTextUtils.setText(self.view.panelInfoClassInfoText, pg.getFormatText(pg.getGameString("PLAYER_SESSION_CLASS_INFO"), Utils.getClass(pg.me.uid)))
end

function InfoPlayerMainCtrl:refreshShowSignature()
	self.playerInfo.showSignature = pg.me.showSignature

	local playerSignText = self.playerInfo.showSignature == "" and pg.getGameString("NO_PLAYER_SIGNATURE") or self.playerInfo.showSignature
	local _h = InfoPlayerMainCtrl._platformHooks

	playerSignText = _h and _h.setPlayerBaseInfoSign and _h.setPlayerBaseInfoSign(self, playerSignText) or playerSignText

	ClientTextUtils.setText(self.view.panelInfoPlayerSignText, playerSignText)

	if self.editComponent then
		self.editComponent:refreshPlayerCard()
		self.editComponent.baseBarComponent:refreshEditBasicBarPanel()
	end
end

function InfoPlayerMainCtrl:refreshPlayerCardBackground()
	self.playerInfo.cardBackground = pg.me.cardBackground

	if self.editComponent then
		self.editComponent.cardBgBarComponent:onCardBackgroundChange()
	end
end

function InfoPlayerMainCtrl:refreshPlayHead()
	local data = {
		isLock = false,
		showAvatarFrame = true,
		showAvatar = true,
		isEquip = false,
		avatarIconId = self.playerInfo.headIcon,
		avatarFrameIconId = self.playerInfo.headFrame
	}

	LuaUIUtils.renderPlayerAvatar(self.view.panelInfoHeadButton, data)
end

function InfoPlayerMainCtrl:refreshBottomButtons()
	local objectReference = self.view.btnEdit:GetComponent("ObjectReference")
	local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")

	ClientTextUtils.setText(txtNameUBaseText, pg.getGameString("EDIT"))

	local addObjRef = self.view.btnAdd:GetComponent("ObjectReference")
	local txtAddUBaseText = addObjRef:GetRefValue("txtNameUBaseText")

	ClientTextUtils.setText(txtAddUBaseText, pg.getGameString("ADD_FRIEND"))

	if pg.game.chat:checkFriendList(self.playerInfo.uid) then
		self.view.btnAdd:SetActive(false)
	else
		self.view.btnChat:SetActive(false)
	end
end

function InfoPlayerMainCtrl:onAddButtonClick()
	pg.game.chat:applyFriend(self.playerInfo.uid, pg.game.chat.AddFriendSource.PlayerCard)
	LuaUIUtils.sendCustomLog(Const.BILogName.EVENT_PROFILE_PAGE, {
		profilepageclickaddFriend = 1
	})
end

function InfoPlayerMainCtrl:onChatButtonClick()
	pg.global.ui.chat:createNewChat(nil, self.playerInfo.uid)
end

function InfoPlayerMainCtrl:onEditButtonClick(defaultEditTabIndex)
	self.view.rootUComponent:TryChangePage("State", 1)

	if self.editComponent == nil then
		self.editComponent = EditComponent.new(self, self.view.panelEditWidget, {
			playerInfo = self.playerInfo,
			defaultTabIndex = defaultEditTabIndex,
			defaultTitleType = self.defaultTitleType,
			friendTitleInfo = self.friendTitleInfo
		})
	else
		self.editComponent:setTabList()
		self.editComponent:setDefaultTabIndex(defaultEditTabIndex, self.defaultTitleType)
	end
end

function InfoPlayerMainCtrl:refreshPlayerName()
	self.playerInfo.playerName = pg.me.playerName

	local playerName = self.playerInfo.playerName or ""
	local _h = InfoPlayerMainCtrl._platformHooks

	playerName = _h and _h.refreshPlayerName and _h.refreshPlayerName(self, playerName) or playerName

	ClientTextUtils.setText(self.view.panelInfoPlayerNameText, playerName)

	if self.editComponent then
		self.editComponent:refreshPlayerCard()
		self.editComponent.baseBarComponent:refreshEditBasicBarPanel()
	end
end

function InfoPlayerMainCtrl:refreshPlayerIconSelected()
	self.playerInfo.headIcon = pg.me.headIcon
	self.playerInfo.headFrame = pg.me.headFrame

	self:refreshPlayHead()

	if self.editComponent then
		self.editComponent:refreshPlayCardHead()
		self.editComponent.headBarComponent:onPlayerIconChange()
	end
end

function InfoPlayerMainCtrl:checkShowTitlesValid()
	return true
end

function InfoPlayerMainCtrl:refreshPlayerTitle(isOriginal)
	if not isOriginal and self:isSelfProfileEditMode() then
		self.playerInfo.isWholeTitle = pg.me.isWholeTitle
		self.playerInfo.showTitles = pg.me.showTitles
		self.playerInfo.showTitleExtra = pg.me.showTitleExtra
		self.resolvedFriendTitleName = nil
	end

	self:renderPlayerTitle()
end

function InfoPlayerMainCtrl:renderPlayerTitle()
	local showTitles = self.playerInfo.showTitles or {}
	local titleText = ShowTitleUtils.getShowTitleText(showTitles, self.playerInfo.showTitleExtra, self.playerInfo.isWholeTitle, self.resolvedFriendTitleName)

	ClientTextUtils.setText(self.view.panelDesignationText, titleText)

	if self.view.panelInfoTitleUSDFText then
		ClientTextUtils.setText(self.view.panelInfoTitleUSDFText, titleText)
	end

	if self.view.panelInfoTitleBackgroundUImage then
		local backgroundId = showTitles[Const.SHOW_TITLE_TYPE.Background]
		local wholeTitleId = showTitles[Const.SHOW_TITLE_TYPE.Whole]
		local backgroundData = backgroundId and ShowTitleData[backgroundId]
		local wholeTitleData = wholeTitleId and ShowTitleData[wholeTitleId]
		local backgroundUrl = backgroundData and backgroundData.bgRes

		if self.playerInfo.isWholeTitle and wholeTitleData and not string.isNilOrEmpty(wholeTitleData.bgRes) then
			backgroundUrl = wholeTitleData.bgRes
		end

		self.view.panelInfoTitleBackgroundUImage:SetActive(not string.isNilOrEmpty(backgroundUrl))

		if not string.isNilOrEmpty(backgroundUrl) then
			self.view.panelInfoTitleBackgroundUImage.url = backgroundUrl
		end
	end

	if self.editComponent and self.editComponent.titleBarComponent then
		self.editComponent.titleBarComponent:onShowTitlesChange()
	end
end

function InfoPlayerMainCtrl:queryFriendShowTitleName()
	local showTitleExtra = self.playerInfo.showTitleExtra
	local friendUid = ShowTitleUtils.getFriendPrefixInfo(showTitleExtra)

	self.friendTitleQueryToken = nil
	self.resolvedFriendTitleName = nil

	if string.isNilOrEmpty(friendUid) then
		return
	end

	local token = {}
	local ownerView = self.view
	local playerUid = tostring(self.playerInfo.uid)

	self.friendTitleQueryToken = token

	pg.game.chat:queryFriendShowTitleName(friendUid, function(isSuccess, playerName)
		if not self:isFriendShowTitleQueryValid(token, ownerView, playerUid, friendUid) then
			return
		end

		if isSuccess then
			self.resolvedFriendTitleName = playerName

			self:renderPlayerTitle()
		end
	end)
end

function InfoPlayerMainCtrl:isFriendShowTitleQueryValid(token, ownerView, playerUid, friendUid)
	local currentExtra = self.playerInfo and self.playerInfo.showTitleExtra
	local currentFriendUid = ShowTitleUtils.getFriendPrefixInfo(currentExtra)

	return not self.isDestroyed and not self.isClosing and self.friendTitleQueryToken == token and self.view == ownerView and tostring(self.playerInfo and self.playerInfo.uid or "") == playerUid and currentFriendUid == friendUid
end

function InfoPlayerMainCtrl:setSelfPlayerInfo(uid, icon, headFrame, name, userName, homelandKey, online, starTitle, level, templateId, teamId, showSignature, teamMembers, teamDungeonSceneId, isWholeTitle, showTitles, showTitleExtra, cardBackground, avatarPresetKey, avatarConfig, curShow, fashionScore, badgeShowMap)
	self.playerInfo = {}
	self.playerInfo.uid = uid
	self.playerInfo.headIcon = icon > 0 and icon or 1
	self.playerInfo.headFrame = headFrame > 0 and headFrame or 1
	self.playerInfo.playerName = name
	self.playerInfo.userName = userName
	self.playerInfo.homelandKey = homelandKey
	self.playerInfo.starTitle = starTitle
	self.playerInfo.online = online
	self.playerInfo.isFriend = pg.game.chat:checkFriendList(uid)
	self.playerInfo.level = level
	self.playerInfo.templateId = templateId
	self.playerInfo.teamId = teamId
	self.playerInfo.showSignature = showSignature
	self.playerInfo.teamMembers = teamMembers
	self.playerInfo.teamDungeonSceneId = teamDungeonSceneId
	self.playerInfo.isWholeTitle = isWholeTitle
	self.playerInfo.showTitles = showTitles
	self.playerInfo.showTitleExtra = showTitleExtra
	self.playerInfo.cardBackground = cardBackground
	self.playerInfo.avatarPresetKey = avatarPresetKey
	self.playerInfo.avatarConfig = avatarConfig
	self.playerInfo.curShow = curShow
	self.playerInfo.fashionScore = fashionScore
	self.playerInfo.badgeShowMap = badgeShowMap
end

function InfoPlayerMainCtrl:onDestroy()
	self.isDestroyed = true
	self.friendTitleQueryToken = nil
	self.resolvedFriendTitleName = nil

	local _h = InfoPlayerMainCtrl._platformHooks

	if _h and _h.onDestroy then
		_h.onDestroy(self)
	end

	PhotographyStudioUtils.clearReadonlyDIY(self.view, self.previewDIYObjs)

	self.previewDIYObjs = nil

	if self.entity and not self.entityManagedByAvatarScene then
		ClientUtils.safeDestroy(self.entity)
	end

	self.entity = nil
	self.entityManagedByAvatarScene = nil
	self.avatarScene = nil
	self.editComponent = nil

	UICtrl.onDestroy(self)
end

function InfoPlayerMainCtrl:refreshConsoleBarState()
	if CS.XGUI.Navigation.NavManager.Instance then
		local showEdit = self.tabIndex == 1

		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("UI_Pb_InfoPlayer_MainEdit", showEdit)
	end
end

return InfoPlayerMainCtrl
