-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Chat\\ChatSystem.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local SystemBase = require("GameApp.Core.SystemBase")
local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local ClientConst = require("Const.ClientConst")
local Time = require("Core.Common.Time")
local Const = require("Common.Const.Const")
local MessageName = require("Const.MessageName")
local PlayerHeadIconData = require("Data.player_head_icon_data")
local PlayerHeadFrameData = require("Data.player_head_frame_data")
local RedDotConst = require("Const.RedDotConst")
local ChatSettingData = require("Data.chat_setting_data")
local Utils = require("Common.Utils.Utils")
local EntityManager = require("Core.Common.EntityManager")
local EventConst = require("Const.EventConst")
local json = require("json")
local SceneUtils = require("Common.Utils.SceneUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local AppearanceAction = require("Data.appearance_action_data")
local ChatBubbleData = require("Data.chat_bubble_data")
local ChatQuickSendData = require("Data.chat_quick_send_data")
local LanguageAssociateData = require("Data.language_associate_data")
local CommonSwitch = require("Common.CommonSwitch")
local SysConfigData = require("Data.sys_config_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientRepo = require("Core.Client.ClientRepo")
local logger = require("Core.Log.LoggerManager").getLogger("ChatSystem")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local ChatSystem = Class.LightClass("ChatSystem", SystemBase)
local WORLD_CHANNEL_LINE_PATTERN = "^" .. Const.CHAT_ATTR_WORLD.group_base .. "_([%d]+)$"
local LANGUAGE_CHANNEL_LANGUAGE_PATTERN = "^" .. Const.CHAT_ATTR_LANGUAGE.group_base .. "_(.+)_[%d]+$"
local CHAT_CHANNEL_GROUP_NO_PATTERN = "([%d]+)$"
local OTHER_DEFAULT_CHAT_BUBBLE_RES = "$UI_Img_Chat_Bubble_Bg_You.png"
local OTHER_DEFAULT_WORLD_BUBBLE_RES = "$UI_Img_InfoPlayer_BubbleFrame1.png"
local BASIC_PLAYER_OVERWRITE_FIELDS = {
	playerName = true
}
local PLAYER_DYNAMIC_STATE_FIELDS = {
	"teamId",
	"teamMembers",
	"matchStatus",
	"teamDungeonSceneId"
}

ChatSystem.settingType = {
	BulletSetSize = 4,
	BulletSetSpeed = 3,
	Bullet = 2,
	Word = 1,
	Mute = 99,
	AudioPlay = 6,
	MessageInform = 5
}
ChatSystem.tabType = {
	Notice = 4,
	Public = 3,
	Team = 2,
	Chat = 1,
	Mail = 6,
	Friend = 5
}
ChatSystem.subTabType = {
	Team = 2
}
ChatSystem.channelType = {
	Friend = "7",
	Home = "9",
	Team = "3",
	Interact = "6",
	System = "4",
	Near = "2",
	World = "1",
	Player = "0",
	Vehicle = "13",
	Group = "12"
}
ChatSystem.chatMessageKeepCountMap = {
	[ChatSystem.channelType.Player] = SysConfigData.CHAT_FRIENDS_STORAGE_MAX,
	[ChatSystem.channelType.Team] = SysConfigData.CHAT_FRIENDS_STORAGE_MAX,
	[ChatSystem.channelType.Group] = SysConfigData.CHAT_FRIENDS_STORAGE_MAX,
	[ChatSystem.channelType.Friend] = SysConfigData.CHAT_FRIENDS_STORAGE_MAX,
	[ChatSystem.channelType.World] = SysConfigData.CHAT_WORLD_STORAGE_MAX,
	[ChatSystem.channelType.Near] = SysConfigData.CHAT_WORLD_STORAGE_MAX,
	[ChatSystem.channelType.Home] = SysConfigData.CHAT_WORLD_STORAGE_MAX,
	[ChatSystem.channelType.Vehicle] = SysConfigData.CHAT_WORLD_STORAGE_MAX
}
ChatSystem.channelTypeInfo = {
	[ChatSystem.channelType.Player] = {
		str = "Player",
		widgetTxt = 46,
		cate = ChatSystem.tabType.Chat,
		settings = {}
	},
	[ChatSystem.channelType.World] = {
		widgetTxt = 36,
		str = "World",
		cate = ChatSystem.tabType.Public,
		groupWidgetTxtList = {
			{
				widgetTxt = 95,
				groupBase = Const.CHAT_ATTR_CLASS.group_base
			},
			{
				widgetTxt = 96,
				groupBase = Const.CHAT_ATTR_LANGUAGE.group_base
			}
		},
		settings = {}
	},
	[ChatSystem.channelType.Near] = {
		str = "Near",
		widgetTxt = 37,
		cate = ChatSystem.tabType.Notice,
		settings = {}
	},
	[ChatSystem.channelType.Team] = {
		str = "Team",
		widgetTxt = 40,
		cate = ChatSystem.tabType.Notice,
		settings = {}
	},
	[ChatSystem.channelType.System] = {
		str = "System",
		cate = ChatSystem.tabType.Chat,
		settings = {}
	},
	[ChatSystem.channelType.Friend] = {
		str = "Friend",
		widgetTxt = 39,
		cate = ChatSystem.tabType.Notice,
		settings = {}
	},
	[ChatSystem.channelType.Home] = {
		str = "Home",
		widgetTxt = 38,
		cate = ChatSystem.tabType.Notice,
		settings = {}
	},
	[ChatSystem.channelType.Group] = {
		str = "Group",
		widgetTxt = 41,
		cate = ChatSystem.tabType.Chat,
		settings = {}
	},
	[ChatSystem.channelType.Vehicle] = {
		str = "Vehicle",
		widgetTxt = 37,
		cate = ChatSystem.tabType.Public,
		settings = {}
	},
	[ChatSystem.channelType.Interact] = {
		str = "Interact",
		cate = ChatSystem.tabType.Chat,
		settings = {}
	}
}
ChatSystem.messageType = {
	BlankItem = 5,
	Tips = 4,
	SystemNotice = 3,
	TimeStamp = 2,
	SelfPlayer = 1,
	OtherPlayer = 0,
	Interact = 7,
	Marquee = 6
}
ChatSystem.subMessageType = {
	EnterWorld = 16,
	PVPInvite = 15,
	Team = 17,
	Emoji = 13,
	Audio = 12,
	Text = 11,
	DungeonInvite = 14,
	Gift = 25,
	HomeSeasonCelebrationInvite = 24,
	HomeSeasonMutationGift = 23,
	PhotographyStudioInvite = 22,
	JumpShared = 21,
	FriendCard = 20,
	Picture = 19,
	HomeCampInvite = 18
}
ChatSystem.jumpType = {
	ShareHome = 1
}
ChatSystem.giftType = {
	Lottery = 1
}
ChatSystem.handleMassageType = {
	Follow = 3,
	Copy = 2,
	Reply = 1,
	Translate = 5,
	Report = 4
}
ChatSystem.queryPlayerInfoType = {
	ShowVisitorInfo = 9,
	ApplyTeam = 8,
	RecvTeamInvite = 7,
	ShowPlayerInfo = 6,
	FriendApply = 5,
	RequestList = 4,
	FriendList = 3,
	ChatRecord = 2,
	FriendAddSearch = 1
}

function ChatSystem:onCtor()
	self.isLogin = true
	self.sendWorldMessageCD = 0
	self.sendWorldMessageCDEndTime = 0

	self:resetData()
	self:initChatSettingInfo()
end

function ChatSystem:backToHome()
	self.isLogin = true
end

function ChatSystem:onInit()
	function self.m_onLanguageChanged()
		self:markMailsLanguageDirty()
	end

	pg.global.eventEmitter:addEventListener(EventConst.ON_LANGUAGE_CHANGED, self.m_onLanguageChanged)
end

function ChatSystem:onClear()
	return
end

function ChatSystem:onDestroy()
	if self.m_onLanguageChanged then
		pg.global.eventEmitter:removeEventListener(EventConst.ON_LANGUAGE_CHANGED, self.m_onLanguageChanged)

		self.m_onLanguageChanged = nil
	end
end

function ChatSystem:onTick()
	self:getWorldMessageCD()
	self:clearChannelListDataByTime()
end

function ChatSystem:onPlayerInit(player)
	return
end

function ChatSystem:onPlayerDestroy(player)
	return
end

function ChatSystem:resetData()
	if self.channelHistoryPreloadTimerId then
		self:killTimer(self.channelHistoryPreloadTimerId)
	end

	self.hasInitChatData = false
	self.channelHistoryPreloadTimerId = nil
	self.pendingChannelHistoryIds = {}
	self.preloadedChannelHistoryIds = {}
	self.sendWorldMessageCD = 0
	self.sendWorldMessageCDEndTime = 0
	self.nextCleanChatMessageTime = nil

	self:resetTextTranslationData()

	self.lastSendTeamInvite = {}
	self.showFirstEnterTeam = true
	self.messageId2MessageInfo = {}
	self.interactionSourceMsgId2MessageData = {}
	self.interactionMessageSequence = 0
	self.interactionMessageIdSet = {}
	self.pendingChatSendMessages = {}
	self.messageExtraInfo = {}
	self.playerDatas = {}
	self.playerId2LatestChatBubbleId = {}
	self.playerQueryHistory = {}
	self.friendShowTitleNameQueries = {}
	self.teamInviteHistory = {}
	self.friendships = {}
	self.friendIdSet = {}
	self.friendIntimacies = {}
	self.friendIntimacyLimits = {}
	self.friendIntimacyTodayLimits = {}
	self.friendSendGiftLimitCounts = {}
	self.friendshipPermissions = {}
	self.worldChannelListData = {
		{
			state = 1,
			shortLabel = "CHAT_CHANNEL_WORLD_SHORT",
			label = "CHAT_CHANNEL_WORLD",
			tIndex = 0,
			type = ChatSystem.channelType.World,
			channelId = ChatSystem.channelType.World,
			groupBase = Const.CHAT_ATTR_WORLD.group_base
		},
		{
			state = 1,
			shortLabel = "CHAT_CHANNEL_CLASS_FORMAT_SHORT",
			label = "CHAT_CHANNEL_CLASS_FORMAT",
			tIndex = 0,
			type = ChatSystem.channelType.World,
			groupBase = Const.CHAT_ATTR_CLASS.group_base
		},
		{
			state = 1,
			shortLabel = "CHAT_CHANNEL_COUNTRY_FORMAT_SHORT",
			label = "CHAT_CHANNEL_COUNTRY_FORMAT",
			tIndex = 0,
			type = ChatSystem.channelType.World,
			groupBase = Const.CHAT_ATTR_LANGUAGE.group_base
		},
		{
			state = 1,
			shortLabel = "CHAT_CHANNEL_TEAM_SHORT",
			groupId = "",
			label = "CHAT_CHANNEL_TEAM",
			tIndex = 0,
			type = ChatSystem.channelType.Team,
			channelId = ChatSystem.channelType.Team
		},
		{
			state = 1,
			shortLabel = "CHAT_CHANNEL_HOME_SHORT",
			label = "CHAT_CHANNEL_HOME",
			tIndex = 0,
			type = ChatSystem.channelType.Home
		},
		{
			state = 1,
			shortLabel = "CHAT_CHANNEL_NEAR_SHORT",
			label = "CHAT_CHANNEL_NEAR",
			tIndex = 0,
			type = ChatSystem.channelType.Near,
			channelId = ChatSystem.channelType.Near
		},
		{
			state = 1,
			shortLabel = "CHAT_CHANNEL_FRIEND_SHORT",
			label = "CHAT_CHANNEL_FRIEND",
			tIndex = 0,
			type = ChatSystem.channelType.Friend,
			channelId = ChatSystem.channelType.Friend
		}
	}
	self.systemChannelListData = {
		{
			state = 1,
			shortLabel = "CHAT_CHANNEL_SYSTEM_SHORT",
			label = "CHAT_CHANNEL_SYSTEM",
			tIndex = 0,
			type = ChatSystem.channelType.System,
			channelId = ChatSystem.channelType.System
		},
		{
			state = 1,
			shortLabel = "CHAT_CHANNEL_INTERACT_SHORT",
			label = "CHAT_CHANNEL_INTERACT",
			tIndex = 0,
			type = ChatSystem.channelType.Interact,
			channelId = ChatSystem.channelType.Interact
		}
	}
	self.channelListData = {}
	self.chatMessageListData = {
		[self.channelType.World] = {},
		[self.channelType.Near] = {},
		[self.channelType.Team] = {},
		[self.channelType.System] = {},
		[self.channelType.Friend] = {},
		[self.channelType.Interact] = {}
	}
	self.friendList = {
		{
			tIndex = 0,
			label = ""
		},
		{
			state = 0,
			tIndex = 1,
			subItems = {}
		},
		{
			hidden = true,
			label = "CHAT_FRIEND_ARK",
			tIndex = 0
		},
		{
			hidden = true,
			state = 0,
			tIndex = 2,
			subItems = {}
		}
	}
	self.friendCustomList = {}
	self.friendGroupList = {}
	self.friendGroupId2Index = {}
	self.friendChatGroupList = {}
	self.friendChatGroupId2Index = {}
	self.chatGroupHeadIconAvailableKeys = {
		1,
		2,
		3,
		4,
		5,
		6,
		7,
		8,
		9,
		10
	}
	self.messageFuncList = {
		{
			label = "CHAT_MESSAGE_REPLY",
			type = ChatSystem.handleMassageType.Reply
		},
		{
			label = "CHAT_MESSAGE_COPY",
			type = ChatSystem.handleMassageType.Copy
		},
		{
			label = "CHAT_MESSAGE_FOLLOW",
			type = ChatSystem.handleMassageType.Follow
		},
		{
			label = "CHAT_REPORT_CHAT",
			type = ChatSystem.handleMassageType.Report
		},
		{
			label = "AI_TRANSLATE",
			type = ChatSystem.handleMassageType.Translate
		}
	}
	self.friendRequestList = {}
	self.blackList = {}
	self.mailList = {}
	self.rawMailList = {}
	self.rawMailById = {}
	self.mailContent = {}
	self.mailLanguageDirty = false
	self.mailLanguageVersion = 0
	self.mailListRequestVersion = nil
	self.mailListRequestPending = false

	local discordHooks = ChatSystem._discordHooks

	if discordHooks and discordHooks.resetData then
		discordHooks.resetData(self)
	end
end

function ChatSystem:checkBlack(uid)
	if table.contains(self.blackList, uid) then
		return true
	end

	return false
end

function ChatSystem:onBackToLogin()
	self.curUid = nil

	self:resetData()
end

function ChatSystem:initPlayerData(force)
	local me = pg.me

	if self.hasInit and not force or me == nil or me.uid == nil or me.uid == self.curUid then
		return
	end

	self:resetData()
	me:fetchFriends(0)
	me:fetchBlacklist()
	me:fetchApplicants()

	self.mailListRequestPending = true

	me:getUserMailList(0, true)

	local text, _ = string.gsub(pg.getGameString("FIRST_JOIN_WORLD_CHANNEL"), "{0}", pg.me.playerName)

	self:recvWorldSystemNotice(text)

	self.curUid = me.uid

	local playerData = {
		playerTitle = "",
		online = true,
		headIcon = me.headIcon,
		headFrame = me.headFrame,
		playerName = me.playerName,
		level = me.level
	}
	local _h = ChatSystem._platformHooks

	playerData = _h and _h.buildSelfPlayerData and _h.buildSelfPlayerData(self, me, playerData) or playerData
	self.playerDatas[me.uid] = playerData

	local topChannelStr = pg.global.prefsCacheUtils:getString(pg.me.uid .. ClientConst.PrefKey.ChatPrivateTopChannel, "")

	if EnableBotTest then
		self.topChannels = {}
	elseif string.isNilOrEmpty(topChannelStr) then
		self.topChannels = {}
	else
		self.topChannels = string.split(topChannelStr, "|")

		for i = #self.topChannels, 1, -1 do
			if string.isNilOrEmpty(self.topChannels[i]) then
				table.remove(self.topChannels, i)
			end
		end
	end

	self.hasInit = true

	self:tryInitChatData()

	local discordHooks = ChatSystem._discordHooks

	if discordHooks and discordHooks.onChatSystemInitialized then
		discordHooks.onChatSystemInitialized(self, me)
	end
end

function ChatSystem:tryInitChatData()
	local me = pg.me

	if self.hasInitChatData or me == nil or me.uid == nil or me.uid ~= self.curUid or me.functionUnlocks[Const.FUNCTION_NAME.CHAT] ~= Const.FUNCTION_UNLOCK_STATE.UNLOCK then
		return false
	end

	self.hasInitChatData = true

	me:chatRecord()
	self:queueChannelHistoryPreload(me.worldChatGroupId)
	self:queueChannelHistoryPreload(me.classChatGroupId)
	self:queueChannelHistoryPreload(me.languageChatGroupId)

	return true
end

function ChatSystem:queueChannelHistoryPreload(groupId)
	if string.isNilOrEmpty(groupId) or not self:isWorldChatGroupId(groupId) or self.preloadedChannelHistoryIds[groupId] or self.pendingChannelHistoryIds[groupId] then
		return
	end

	self.pendingChannelHistoryIds[groupId] = true

	if self.channelHistoryPreloadTimerId then
		return
	end

	self.channelHistoryPreloadTimerId = self:startTimer(function()
		self.channelHistoryPreloadTimerId = nil

		local pending = self.pendingChannelHistoryIds

		self.pendingChannelHistoryIds = {}

		if not pg.me then
			return
		end

		local historyItems = {}

		for pendingGroupId in pairs(pending) do
			if not self.preloadedChannelHistoryIds[pendingGroupId] then
				self.preloadedChannelHistoryIds[pendingGroupId] = true
				historyItems = pg.me:fillChatHistoryItems(historyItems, pg.me.uid, pendingGroupId, Const.CHAT_TYPE.GROUP, 0, 50)
			end
		end

		if #historyItems > 0 then
			pg.me:chatBatchHistory(historyItems)
		end
	end, 0)
end

function ChatSystem:markChannelHistoryPreloaded(groupId)
	if not self:isWorldChatGroupId(groupId) then
		return true
	end

	self.pendingChannelHistoryIds[groupId] = nil

	if self.preloadedChannelHistoryIds[groupId] then
		return false
	end

	self.preloadedChannelHistoryIds[groupId] = true

	return true
end

function ChatSystem:refreshSelfPlayerData()
	local me = pg.me

	if me == nil or me.uid == nil then
		return nil
	end

	local playerData = {
		online = true,
		headIcon = me.headIcon,
		headFrame = me.headFrame,
		playerName = me.playerName,
		level = me.level
	}
	local cachedPlayerData = self:setPlayerData(me.uid, playerData)

	return cachedPlayerData
end

function ChatSystem:onSelfPlayerDataChanged()
	if not self:refreshSelfPlayerData() then
		return
	end

	facade:SendMessageCommand(MessageName.CHAT_MESSAGE_UPDATE, {})
	facade:SendMessageCommand(MessageName.CHAT_RED_DOT_UPDATE)
end

function ChatSystem:setPlayerData(uid, playerData, onlyFillMissing, overwriteFields)
	if string.isNilOrEmpty(uid) or type(playerData) ~= "table" then
		return self.playerDatas[uid]
	end

	local cachedPlayerData = self.playerDatas[uid]

	if not cachedPlayerData then
		self.playerDatas[uid] = playerData

		return playerData
	end

	if cachedPlayerData == playerData then
		return cachedPlayerData
	end

	local cachedIsFullData = cachedPlayerData.stableAttributesDict ~= nil or pg.me and tostring(uid) == tostring(pg.me.uid)

	for key, value in pairs(playerData) do
		local canOverwrite = overwriteFields and overwriteFields[key]

		if value ~= nil and (canOverwrite or not onlyFillMissing or not cachedIsFullData or cachedPlayerData[key] == nil) then
			cachedPlayerData[key] = value
		end
	end

	return cachedPlayerData
end

function ChatSystem:setQueriedPlayerData(uid, playerData)
	self:setDungeonInvitePlayerState(uid, playerData)

	return self:setPlayerData(uid, playerData)
end

function ChatSystem:setDungeonInvitePlayerState(uid, playerData)
	local cachedPlayerData = self.playerDatas[uid]

	if not cachedPlayerData then
		cachedPlayerData = {
			uid = uid
		}
		self.playerDatas[uid] = cachedPlayerData
	end

	for _, fieldName in ipairs(PLAYER_DYNAMIC_STATE_FIELDS) do
		cachedPlayerData[fieldName] = playerData[fieldName]
	end

	return cachedPlayerData
end

function ChatSystem:checkChatSettingState(channelType, settingType, channelId)
	local settingData = ChatSettingData[settingType]
	local info = self.channelTypeInfo[channelType]

	if not info.settings[settingData.tab] then
		return false
	end

	if self:checkChannelMuteSettingByType(channelType, settingType, channelId) then
		return false
	end

	local keyId = pg.me.uid .. settingData.tab .. settingType
	local defaultValue = Utils.concatTableOrUserdata(settingData.widgetDefaultValue, "|")
	local checkBoxStateStr = pg.global.prefsCacheUtils:getString(keyId, defaultValue)
	local checkBoxState = string.split(checkBoxStateStr, "|")
	local widgetTxt = self:getChatSettingWidgetTxt(channelType, channelId)

	return table.contains(checkBoxState, tostring(widgetTxt))
end

function ChatSystem:getChatSettingWidgetTxt(channelType, channelId)
	local info = self.channelTypeInfo[channelType]

	if info.groupWidgetTxtList then
		for _, groupWidgetTxt in ipairs(info.groupWidgetTxtList) do
			if self:isChatGroupBase(channelId, groupWidgetTxt.groupBase) then
				return groupWidgetTxt.widgetTxt
			end
		end
	end

	return info.widgetTxt
end

function ChatSystem:setChatSettingState(channelType, settingType, isOn, channelId)
	local settingData = ChatSettingData[settingType]
	local info = self.channelTypeInfo[channelType]

	if not info.settings[settingData.tab] then
		return false
	end

	local keyId = pg.me.uid .. settingData.tab .. settingType
	local defaultValue = Utils.concatTableOrUserdata(settingData.widgetDefaultValue, "|")
	local checkBoxStateStr = pg.global.prefsCacheUtils:getString(keyId, defaultValue)
	local checkBoxState = string.split(checkBoxStateStr, "|")
	local widgetTxt = tostring(self:getChatSettingWidgetTxt(channelType, channelId))

	if isOn then
		checkBoxState[#checkBoxState + 1] = widgetTxt
	else
		for idx, state in ipairs(checkBoxState) do
			if state == widgetTxt then
				table.remove(checkBoxState, idx)

				break
			end
		end
	end

	local checkBoxStateValue = Utils.concatTableOrUserdata(checkBoxState, "|")

	pg.global.prefsCacheUtils:setString(keyId, checkBoxStateValue)
end

function ChatSystem:getChatSettingState(settingType)
	local settingData = ChatSettingData[settingType]
	local keyId = pg.me.uid .. settingData.tab .. settingType
	local defaultVal = settingData.widgetDefaultValue
	local optionValue = tonumber(pg.global.prefsCacheUtils:getString(keyId, defaultVal))

	return optionValue
end

function ChatSystem:getMuteSettingChannelIdByType(channelType, channelId)
	if channelType == self.channelType.World then
		return channelId or pg.me.worldChatGroupId
	elseif channelType == self.channelType.Home then
		return self:getHomeCampGroupId()
	elseif channelType == self.channelType.Near then
		return self.channelType.Near
	end

	return nil
end

function ChatSystem:checkChannelMuteSettingByType(channelType, settingType, channelId)
	if settingType ~= self.settingType.MessageInform and settingType ~= self.settingType.Bullet then
		return false
	end

	local muteChannelId = self:getMuteSettingChannelIdByType(channelType, channelId)

	if string.isNilOrEmpty(muteChannelId) then
		return false
	end

	return self:checkChannelSettingStateById(muteChannelId, self.settingType.Mute)
end

function ChatSystem:setChannelSettingStateById(id, isOn, settingType)
	local keyId = pg.me.uid .. ClientConst.PrefKey.ChatChannelSetting .. settingType .. id
	local newValue = isOn and 1 or 0

	pg.global.prefsCacheUtils:setInt(keyId, newValue)
end

function ChatSystem:checkChannelSettingStateById(id, settingType)
	if id == nil or settingType == nil then
		return false
	end

	local keyId = pg.me.uid .. ClientConst.PrefKey.ChatChannelSetting .. settingType .. id
	local savedValue = pg.global.prefsCacheUtils:getInt(keyId, 0)

	return savedValue == 1
end

function ChatSystem:initChatSettingInfo()
	local channelRelatedWidgetType = 6

	for _, channel in pairs(self.channelTypeInfo) do
		channel.settings = {}

		for _, data in pairs(ChatSettingData) do
			local isChannelSetting = data.widgetType == channelRelatedWidgetType

			if isChannelSetting and self:hasChatSettingWidgetTxt(channel, data.widgetTxt) then
				channel.settings[data.tab] = true
			end
		end
	end
end

function ChatSystem:hasChatSettingWidgetTxt(channelInfo, widgetTxtList)
	if table.contains(widgetTxtList, channelInfo.widgetTxt) then
		return true
	end

	if not channelInfo.groupWidgetTxtList then
		return false
	end

	for _, groupWidgetTxt in ipairs(channelInfo.groupWidgetTxtList) do
		if table.contains(widgetTxtList, groupWidgetTxt.widgetTxt) then
			return true
		end
	end

	return false
end

function ChatSystem:sortTimeDESC(res)
	local originalIndexes = {}

	for index, channelData in ipairs(res) do
		originalIndexes[channelData] = index
	end

	local function compareChannelTime(a, b)
		if a.sortTimeStamp == b.sortTimeStamp then
			return originalIndexes[a] < originalIndexes[b]
		end

		return a.sortTimeStamp > b.sortTimeStamp
	end

	table.sort(res, compareChannelTime)

	return res
end

function ChatSystem:getPrivateChannelListData()
	return self.channelListData
end

function ChatSystem:getWorldChannelListData()
	local data = {}
	local isCn = ClientConfigAppCountry == "cn"
	local isWorldChannelOpen = self:isWorldChannelOpen()

	for _, channel in ipairs(self.worldChannelListData) do
		if channel.type == ChatSystem.channelType.Home then
			channel.channelId = self:getHomeCampGroupId()
		elseif channel.groupBase == Const.CHAT_ATTR_CLASS.group_base then
			channel.channelId = pg.me.classChatGroupId
		elseif channel.groupBase == Const.CHAT_ATTR_LANGUAGE.group_base then
			channel.channelId = pg.me.languageChatGroupId
		elseif channel.type == ChatSystem.channelType.World then
			channel.channelId = pg.me.worldChatGroupId
		elseif channel.type == ChatSystem.channelType.Team then
			channel.channelId = pg.me:getCurTeamInfo().teamId or ChatSystem.channelType.Team
		end

		local isLanguageChannel = channel.groupBase == Const.CHAT_ATTR_LANGUAGE.group_base
		local isDynamicGroupChannel = channel.groupBase == Const.CHAT_ATTR_CLASS.group_base or isLanguageChannel
		local isMainWorldChannel = channel.groupBase == Const.CHAT_ATTR_WORLD.group_base
		local isChannelAvailable = (not isCn or not isLanguageChannel) and (not isMainWorldChannel or isWorldChannelOpen) and (not isDynamicGroupChannel or not string.isNilOrEmpty(channel.channelId))

		if isChannelAvailable then
			data[#data + 1] = channel
		end
	end

	return data
end

function ChatSystem:getSystemChannelListData()
	return self.systemChannelListData
end

function ChatSystem:isWorldChannelOpen()
	return pg.me.level >= SysConfigData.CHAT_CHANNEL_WORLD_OPEN_LEVEL
end

function ChatSystem:isChatGroupBase(groupId, groupBase)
	if type(groupId) ~= "string" or type(groupBase) ~= "string" then
		return false
	end

	return groupId == groupBase or string.startsWith(groupId, groupBase .. "_")
end

function ChatSystem:isClassChatGroupId(groupId)
	return not string.isNilOrEmpty(groupId) and self:isChatGroupBase(groupId, Const.CHAT_ATTR_CLASS.group_base)
end

function ChatSystem:isLanguageChatGroupId(groupId)
	return not string.isNilOrEmpty(groupId) and self:isChatGroupBase(groupId, Const.CHAT_ATTR_LANGUAGE.group_base)
end

function ChatSystem:isWorldChatGroupId(groupId)
	if string.isNilOrEmpty(groupId) then
		return false
	end

	return groupId == pg.me.worldChatGroupId or self:isChatGroupBase(groupId, Const.CHAT_ATTR_WORLD.group_base) or self:isClassChatGroupId(groupId) or self:isLanguageChatGroupId(groupId)
end

function ChatSystem:getClassChatChannelName(groupId, label)
	local classNo = string.sub(pg.me.uid, 1, 7)
	local groupNo = string.match(groupId, CHAT_CHANNEL_GROUP_NO_PATTERN)
	local channelLabel = label or "CHAT_CHANNEL_CLASS_FORMAT"

	return pg.getFormatText(pg.getGameString(channelLabel), classNo, groupNo)
end

function ChatSystem:getLanguageChatChannelName(groupId, label)
	local languageCode = string.match(groupId, LANGUAGE_CHANNEL_LANGUAGE_PATTERN)
	local languageNo = ClientConst.LANGUAGE_TYPE_MAP[languageCode]
	local areaNo = Utils.parseClassId(pg.me.uid)
	local areaConfig = LanguageAssociateData[areaNo]
	local languageConfig = areaConfig and languageNo and areaConfig[languageNo]

	if not languageConfig then
		logger:error("Invalid language chat group, groupId=%s, areaNo=%s, languageCode=%s", tostring(groupId), tostring(areaNo), tostring(languageCode))

		return groupId
	end

	local languageName = languageConfig.chatChannelName
	local languageType = ClientConst.LANGUAGE_TYPE_MAP[languageConfig.language]
	local countryNo = string.match(groupId, CHAT_CHANNEL_GROUP_NO_PATTERN)
	local channelLabel = label or "CHAT_CHANNEL_COUNTRY_FORMAT"

	return pg.getFormatText(ClientTextUtils.getGameStringByLanguage(channelLabel, languageType), languageName, countryNo)
end

function ChatSystem:getWorldChatChannelName(groupId, groupBase, label)
	local isClassChannel = groupBase == Const.CHAT_ATTR_CLASS.group_base or self:isClassChatGroupId(groupId)

	if isClassChannel then
		return self:getClassChatChannelName(groupId, label)
	end

	local isCountryChannel = groupBase == Const.CHAT_ATTR_LANGUAGE.group_base or self:isLanguageChatGroupId(groupId)

	if isCountryChannel then
		return self:getLanguageChatChannelName(groupId, label)
	end

	local channelLabel = label or "CHAT_CHANNEL_WORLD"
	local channelName = pg.getGameString(channelLabel)
	local worldChannelLineId = self:getWorldChannelLineId(groupId)

	return pg.getFormatText(channelName, worldChannelLineId)
end

function ChatSystem:getMessageFuncList()
	return self.messageFuncList
end

function ChatSystem:getChannelInfo(channelId)
	return self.channelListData[channelId]
end

function ChatSystem:getChannelLastMessage(channelId)
	if self.chatMessageListData and self.chatMessageListData[channelId] then
		return self.chatMessageListData[channelId][#self.chatMessageListData[channelId]]
	end

	return nil
end

function ChatSystem:getGroupChannelLastMessageOrSystemNotice(groupId)
	local messageList = self.chatMessageListData and self.chatMessageListData[groupId]

	if not messageList then
		return nil
	end

	local lastNotice

	for i = #messageList, 1, -1 do
		local messageData = messageList[i]

		if messageData.tIndex == self.messageType.OtherPlayer or messageData.tIndex == self.messageType.SelfPlayer then
			return messageData
		elseif lastNotice == nil and (messageData.tIndex == self.messageType.SystemNotice or messageData.tIndex == self.messageType.Tips) then
			lastNotice = messageData
		end
	end

	return lastNotice
end

function ChatSystem:getChatMessageListData()
	return self.chatMessageListData
end

function ChatSystem:getChatMessageKeepCount(channelType)
	return self.chatMessageKeepCountMap[channelType]
end

function ChatSystem:getChannelTypeFromMessageList(channelId, messages)
	if type(messages) == "table" then
		for i = #messages, 1, -1 do
			if messages[i].channelType then
				return messages[i].channelType
			end
		end
	end

	return channelId
end

function ChatSystem:buildLimitedHistoryMessageList(messages, keepCount)
	if type(messages) == nil or not keepCount or keepCount >= #messages then
		return messages
	end

	local limitedMessages = {}
	local startIndex = #messages - keepCount + 1

	for i = startIndex, #messages do
		limitedMessages[#limitedMessages + 1] = messages[i]
	end

	return limitedMessages
end

function ChatSystem:getPlayerInfo(playerId)
	return self:getPlayerDatas()[playerId]
end

function ChatSystem:getPlayerLatestChatBubbleId(uid)
	local chatBubbleId = self.playerId2LatestChatBubbleId[uid]

	if chatBubbleId ~= nil then
		return chatBubbleId
	end

	local playerInfo = self:getPlayerInfo(uid)

	return playerInfo and playerInfo.chatBubble
end

function ChatSystem:getPlayerDatas()
	return self.playerDatas
end

function ChatSystem:rebuildChannelMessageIdIndex(channelId)
	if not self.messageId2MessageInfo then
		self.messageId2MessageInfo = {}
	end

	self.messageId2MessageInfo[channelId] = {}

	local messageList = self.chatMessageListData and self.chatMessageListData[channelId]

	if not messageList then
		return
	end

	for i, messageData in ipairs(messageList) do
		if messageData.messageId ~= nil then
			self.messageId2MessageInfo[channelId][messageData.messageId] = i
		end
	end
end

function ChatSystem:getMessageIndex(channelId, messageId)
	local channelMessageIndex = self.messageId2MessageInfo and self.messageId2MessageInfo[channelId]

	return channelMessageIndex and channelMessageIndex[messageId]
end

function ChatSystem:findMessageIndexInChannel(channelId, targetMessageData)
	local messageList = self.chatMessageListData and self.chatMessageListData[channelId]

	if not messageList then
		return nil
	end

	for i, messageData in ipairs(messageList) do
		if messageData == targetMessageData then
			return i
		end
	end

	return nil
end

function ChatSystem:getMessageInfo(channelId, messageId)
	local index = self:getMessageIndex(channelId, messageId)
	local messageList = self.chatMessageListData and self.chatMessageListData[channelId]

	return index and messageList and messageList[index] or nil
end

function ChatSystem:getFriendList(options)
	local friendList = self.friendList[2].subItems
	local _h = ChatSystem._platformHooks

	if _h and _h.getFriendList then
		return _h.getFriendList(self, friendList, options) or friendList
	end

	return friendList
end

function ChatSystem:getBlackList()
	return self.blackList
end

function ChatSystem:refreshBlackList(blackList)
	table.clear(self.blackList)

	for _, blackId in pairs(blackList) do
		table.insert(self.blackList, blackId.uid)
	end

	pg.me:queryPlayerInfoList(self.blackList, nil, true)
	self:setFriendGroup(Const.CHAT.CHAT_BLACK_LIST_GROUP_ID, pg.getGameString("BLACK_LIST"), true)
	facade:SendMessageCommand(MessageName.BLACK_LIST_UPDATE)
end

function ChatSystem:getFriendship(uid)
	if not self:checkFriendList(uid) then
		return -1
	end

	return self.friendships[uid]
end

function ChatSystem:getFriendIntimacyLimit(uid, intimacyType)
	if not self:checkFriendList(uid) then
		return 0
	end

	local intimacyLimits = self.friendIntimacyLimits[uid] or {}

	return intimacyLimits[intimacyType] or intimacyLimits[tostring(intimacyType)] or 0
end

function ChatSystem:getFriendIntimacy(uid)
	if not self:checkFriendList(uid) then
		return -1
	end

	return self.friendIntimacies[uid]
end

function ChatSystem:getFriendIntimacyLimit(uid, intimacyType)
	if not self:checkFriendList(uid) then
		return 0
	end

	local intimacyLimits = self.friendIntimacyLimits[uid] or {}

	return intimacyLimits[intimacyType] or intimacyLimits[tostring(intimacyType)] or 0
end

function ChatSystem:getFriendIntimacyTodayAcquired(uid)
	if not self:checkFriendList(uid) then
		return 0
	end

	local todayIntimacy = 0
	local intimacyLimits = self.friendIntimacyLimits[uid] or {}

	for _, intimacy in pairs(intimacyLimits) do
		todayIntimacy = todayIntimacy + intimacy
	end

	return todayIntimacy
end

function ChatSystem:getFriendIntimacyTodayLimit(uid)
	if not self:checkFriendList(uid) then
		return 0
	end

	return self.friendIntimacyTodayLimits[uid] or 0
end

function ChatSystem:getFriendSendGiftLimitCount(uid)
	return self.friendSendGiftLimitCounts[uid] or 0
end

function ChatSystem:getPlayerInfoFromServer(playerId, type, cb, extraInfo, force)
	force = force == true

	if not force and self.playerQueryHistory[playerId] and self.playerQueryHistory[playerId] + Const.Friend.QUERY_PLAYER_CD > Time.realSecondCache then
		return false
	end

	self.playerQueryHistory[playerId] = Time.realSecondCache

	pg.me:queryPlayerInfo(playerId, type, true, cb, extraInfo)

	return true
end

function ChatSystem:getBasicPlayerInfoListFromServer(playerIds, cb)
	local hasPlayerIds = type(playerIds) == "table" and #playerIds > 0
	local canQuery = hasPlayerIds and pg.me and type(pg.me.queryBasicPlayerInfoList) == "function"

	if not canQuery then
		return false
	end

	return pg.me:queryBasicPlayerInfoList(playerIds, cb) == true
end

function ChatSystem:recvBasicPlayerInfoList(result, resp, cb)
	local isSuccess = result ~= nil and result.status == true
	local basicInfoByUid = {}

	if isSuccess then
		for _, item in ipairs(resp and resp.Results or EMPTY_TABLE) do
			if item.AttributesMap and not string.isNilOrEmpty(item.Uid) then
				local playerData = item.AttributesMap

				playerData.uid = item.Uid
				basicInfoByUid[tostring(item.Uid)] = playerData

				self:setPlayerData(item.Uid, playerData, true, BASIC_PLAYER_OVERWRITE_FIELDS)
			end
		end
	end

	if cb then
		cb(isSuccess, basicInfoByUid)
	end
end

function ChatSystem:queryFriendShowTitleName(friendUid, cb)
	friendUid = tostring(friendUid or "")

	if string.isNilOrEmpty(friendUid) then
		cb(false, "")

		return false
	end

	local callbacks = self.friendShowTitleNameQueries[friendUid]

	if callbacks then
		callbacks[#callbacks + 1] = cb

		return true
	end

	self.friendShowTitleNameQueries[friendUid] = {
		cb
	}

	local querySent = self:getBasicPlayerInfoListFromServer({
		friendUid
	}, function(isSuccess, basicInfoByUid)
		local pendingCallbacks = self.friendShowTitleNameQueries[friendUid] or {}

		self.friendShowTitleNameQueries[friendUid] = nil

		local playerInfo = basicInfoByUid and basicInfoByUid[friendUid]
		local playerName = playerInfo and playerInfo.playerName or ""

		for _, callback in ipairs(pendingCallbacks) do
			callback(isSuccess and not string.isNilOrEmpty(playerName), playerName)
		end
	end)

	if not querySent then
		self.friendShowTitleNameQueries[friendUid] = nil

		cb(false, "")
	end

	return querySent
end

function ChatSystem:setMessageExtraInfo(key, subKey, channelId, extraInfo)
	if self.messageExtraInfo[key] == nil then
		self.messageExtraInfo[key] = {}
	end

	subKey = tostring(subKey)

	local newExtraInfo = self.messageExtraInfo[key][subKey] or {}

	for key, value in pairs(extraInfo) do
		newExtraInfo[key] = value
	end

	self.messageExtraInfo[key][subKey] = newExtraInfo

	facade:SendMessageCommand(MessageName.CHAT_MESSAGE_UPDATE, {
		channelId = channelId
	})
end

function ChatSystem:cleanChannelMessage(channelId)
	if self.chatMessageListData[channelId] then
		self.chatMessageListData[channelId] = nil
	end

	if self.messageId2MessageInfo then
		self.messageId2MessageInfo[channelId] = nil
	end
end

function ChatSystem:getChannelUnReadMsgCount(channelId)
	if channelId == self.channelType.System then
		return 0
	end

	if self:checkChannelSettingStateById(channelId, self.settingType.Mute) then
		return 0
	end

	local key = channelId .. ClientConst.PrefKey.ChatMessageReadMark
	local lastReadTimeStamp = pg.me:getRedDotRecord(Const.CLIENT_KEY.CHAT_RED_DOT, key, 0)
	local msgs = self.chatMessageListData[channelId]

	if msgs == nil then
		return 0
	end

	local count = 0
	local msgItem

	for i = 1, #msgs do
		msgItem = msgs[i]

		if msgItem.timeStamp and lastReadTimeStamp < msgItem.timeStamp and self:checkMsgShowRedDot(msgs[i]) then
			if msgItem.tIndex == self.messageType.OtherPlayer then
				count = count + 1
			end

			if msgItem.tIndex == self.messageType.Interact then
				count = count + 1
			end
		end
	end

	return count
end

function ChatSystem:checkMsgShowRedDot(msg)
	if msg.subType == self.subMessageType.DungeonInvite or msg.subType == self.subMessageType.PVPInvite or msg.subType == self.subMessageType.EnterWorld then
		return false
	end

	return true
end

function ChatSystem:getAllUnReadMsgCount()
	local count = 0

	for index, value in ipairs(self.channelListData) do
		if value.tIndex == 0 then
			count = count + self:getChannelUnReadMsgCount(value.channelId or value.playerId)
		end
	end

	return count
end

function ChatSystem:getAllWorldUnReadMsgCount()
	local count = 0
	local homeChannelId = self:getHomeCampGroupId()
	local teamId = pg.me:getCurTeamInfo().teamId

	for channelId in pairs(self.chatMessageListData) do
		local isPublicChannel = self:isWorldChatGroupId(channelId) or teamId and channelId == teamId or channelId == self.channelType.Near or channelId == self.channelType.Friend or channelId == homeChannelId

		if isPublicChannel then
			count = count + self:getChannelUnReadMsgCount(channelId)
		end
	end

	return count
end

function ChatSystem:setChannelReadMsgMark(channelId)
	local key = channelId .. ClientConst.PrefKey.ChatMessageReadMark

	pg.me:setRedDotRecord(Const.CLIENT_KEY.CHAT_RED_DOT, key, os.time())
end

function ChatSystem:redDot_GetFriendState()
	local messageNum = self:getFriendRequestCount()

	if messageNum > 0 then
		return RedDotConst.RedDotStyle.NUM
	end

	return RedDotConst.RedDotStyle.NONE
end

function ChatSystem:redDot_GetHudChatButtonState()
	if CommonSwitch.MAIL and self:checkHasRewardMail() then
		return RedDotConst.RedDotStyle.REWARD
	end

	if CommonSwitch.MAIL and self:checkHasNewMail() then
		return RedDotConst.RedDotStyle.NEW
	end

	if not CommonSwitch.CHAT then
		return RedDotConst.RedDotStyle.NONE
	end

	for index, value in ipairs(self.channelListData) do
		if value.tIndex == 0 and self:getChannelUnReadMsgCount(value.channelId) > 0 then
			if value.type == self.channelType.Player and self:checkChatSettingState(self.channelType.Player, pg.game.chat.settingType.MessageInform) then
				return RedDotConst.RedDotStyle.POINT
			elseif value.type == self.channelType.Group then
				return RedDotConst.RedDotStyle.POINT
			end
		end
	end

	local homeChannelId = self:getHomeCampGroupId()
	local teamId = pg.me:getCurTeamInfo().teamId

	for channelId, channel in pairs(self.chatMessageListData) do
		if (teamId and channelId == teamId and self:checkChatSettingState(self.channelType.Team, pg.game.chat.settingType.MessageInform) or channelId == self.channelType.Friend and self:checkChatSettingState(self.channelType.Friend, pg.game.chat.settingType.MessageInform) or channelId == homeChannelId and self:checkChatSettingState(self.channelType.Home, pg.game.chat.settingType.MessageInform)) and self:getChannelUnReadMsgCount(channelId) > 0 then
			return RedDotConst.RedDotStyle.POINT
		end
	end

	local friendRequestNum = self:getFriendRequestCount()

	if friendRequestNum > 0 then
		return RedDotConst.RedDotStyle.NUM
	end

	return RedDotConst.RedDotStyle.NONE
end

function ChatSystem:redDot_HudChatGetAllUnreadMessage()
	return self:getFriendRequestCount()
end

function ChatSystem:getFriendRequestCount()
	return #self.friendRequestList
end

function ChatSystem:getInteractUnreadCount()
	local channelId = self.channelType.Interact

	if self:checkChannelSettingStateById(channelId, self.settingType.Mute) then
		return 0
	end

	local key = channelId .. ClientConst.PrefKey.ChatMessageReadMark
	local lastReadTimeStamp = pg.me:getRedDotRecord(Const.CLIENT_KEY.CHAT_RED_DOT, key, 0)
	local msgs = self.chatMessageListData[channelId]

	if msgs == nil then
		return 0
	end

	local count = 0

	for i = 1, #msgs do
		local msgItem = msgs[i]
		local isUnread = msgItem.timeStamp and lastReadTimeStamp < msgItem.timeStamp
		local isInteract = msgItem.tIndex == self.messageType.Interact

		if isUnread and isInteract and self:checkMsgShowRedDot(msgItem) then
			count = count + 1
		end
	end

	return count
end

function ChatSystem:redDot_GetMailState()
	if self:checkHasRewardMail() then
		return RedDotConst.RedDotStyle.REWARD
	end

	if self:checkHasNewMail() then
		return RedDotConst.RedDotStyle.NEW
	end

	return RedDotConst.RedDotStyle.NONE
end

function ChatSystem:checkIsNewMail(mailId)
	for index, mail in ipairs(self.mailList) do
		if mail.MailId == mailId and mail.Params then
			return mail.Params.haveRead == false
		end
	end

	return false
end

local function hasMailGiftList(giftList)
	return type(giftList) == "table" and next(giftList) ~= nil
end

local function hasMailCustomDataGift(customData)
	if type(customData) ~= "table" then
		return false
	end

	if (tonumber(customData.itemId or customData.itemid) or 0) > 0 and (tonumber(customData.count) or 0) > 0 then
		return true
	end

	for _, data in ipairs(customData) do
		if type(data) == "table" and (tonumber(data.itemId or data.itemid) or 0) > 0 and (tonumber(data.count) or 0) > 0 then
			return true
		end
	end

	return false
end

function ChatSystem:getMailGiftInfo(mail)
	if not mail or not mail.Params or not mail.Params.giftInfo then
		return nil
	end

	local gifts = mail.Params.giftInfo

	if type(gifts) == "string" then
		gifts = ClientRepo.protoCodec:decode(gifts)
	end

	return gifts
end

function ChatSystem:checkMailHasRead(mail)
	if mail.Params.haveRead == false then
		return false
	end

	if self:checkMailHasGift(mail) == false then
		return true
	end

	return mail.Params.giftReceived
end

function ChatSystem:checkMailHasGift(mail)
	local gifts = self:getMailGiftInfo(mail)

	if Utils.isTable(gifts) == false then
		return false
	end

	return hasMailGiftList(gifts and gifts.items) or hasMailGiftList(gifts and gifts.pets) or hasMailGiftList(gifts and gifts.rewardIds) or hasMailCustomDataGift(gifts and gifts.customData)
end

function ChatSystem:checkIsRewardMail(mailId)
	for index, mail in ipairs(self.mailList) do
		if mail.MailId == mailId and mail.Params then
			return self:checkMailHasGift(mail) and mail.Params.giftReceived == false
		end
	end

	return false
end

function ChatSystem:checkHasRewardMail()
	local hasNewMail = false

	for _, mail in ipairs(self.mailList) do
		if mail.Params and self:checkMailHasGift(mail) and mail.Params.giftReceived == false then
			hasNewMail = true

			break
		end
	end

	return hasNewMail
end

function ChatSystem:checkHasNewMail()
	local hasNewMail = false

	for _, mail in ipairs(self.mailList) do
		if mail.Params and mail.Params.haveRead == false then
			hasNewMail = true

			break
		end
	end

	return hasNewMail
end

function ChatSystem:getPlayerIcon(playerInfo)
	local avatarIcon = ""

	if playerInfo.headIcon and PlayerHeadIconData[playerInfo.headIcon] then
		avatarIcon = PlayerHeadIconData[playerInfo.headIcon].res
	end

	return avatarIcon
end

function ChatSystem:getPlayerIconFrame(playerInfo)
	local avatarFrameIcon = ""

	if playerInfo.headFrame and PlayerHeadFrameData[playerInfo.headFrame] then
		avatarFrameIcon = PlayerHeadFrameData[playerInfo.headFrame].res
	end

	return avatarFrameIcon
end

function ChatSystem:getWorldMessageCD()
	local nowSec = Time.realSecondCache or os.time()

	if self.sendWorldMessageCDEndTime and self.sendWorldMessageCDEndTime > 0 then
		local remainCd = math.max(0, self.sendWorldMessageCDEndTime - nowSec)
		local remainCdInt = math.max(0, math.ceil(remainCd))

		self.sendWorldMessageCD = remainCdInt

		if remainCdInt == 0 then
			self.sendWorldMessageCDEndTime = 0
		end
	else
		self.sendWorldMessageCD = math.max(0, math.ceil(self.sendWorldMessageCD or 0))
	end

	return self.sendWorldMessageCD or 0
end

function ChatSystem:setWorldMessageCD(cd)
	local nowSec = Time.realSecondCache or os.time()

	cd = math.max(0, math.ceil(cd or 0))
	self.sendWorldMessageCD = cd

	if cd > 0 then
		self.sendWorldMessageCDEndTime = nowSec + cd
	else
		self.sendWorldMessageCDEndTime = 0
	end
end

function ChatSystem:getWorldChannelLineId(channelId)
	local targetChannelId = channelId

	if targetChannelId == nil or targetChannelId == self.channelType.World then
		targetChannelId = pg.me and pg.me.worldChatGroupId
	end

	if targetChannelId == nil then
		return nil
	end

	return string.match(targetChannelId, WORLD_CHANNEL_LINE_PATTERN)
end

function ChatSystem:isWorldMessageChannel(channelType, channelId)
	if channelType == self.channelType.World then
		return true
	end

	return self:isWorldChatGroupId(channelId)
end

function ChatSystem:isHomeCampGroupId(groupId)
	return not string.isNilOrEmpty(groupId) and Utils.isHomeCampKeyGroupId(groupId)
end

function ChatSystem:checkCanSendMessage(channelType, channelId, showTip)
	if self:isWorldMessageChannel(channelType, channelId) and self:getWorldMessageCD() > 0 then
		if showTip then
			pg.global.showBubbleMessageRaw(pg.getGameString("CHAT_SEND_CD"), 2)
		end

		return false
	end

	return true
end

function ChatSystem:onSendMessageSuccess(channelType, channelId)
	if self:isWorldMessageChannel(channelType, channelId) then
		self:setWorldMessageCD(SysConfigData.SEND_MESSAGE_CD or 5)
	end
end

function ChatSystem:getChatEntityByUid(uid)
	local entity = uid == pg.me.uid and pg.me or EntityManager.getEntityByUid(uid)

	if entity == nil then
		entity = EntityManager.getEntityByUid(Utils.getPlayerGhostUidBySourceUid(uid))
	end

	return entity
end

function ChatSystem:getChatDisplayEntity(entity)
	if Utils.isPlayerGhost(entity) and entity.mappingPetGhost and entity.mappingPetGhost.isInControl then
		return entity.mappingPetGhost
	end

	return entity.isControllingPet and entity:isControllingPet() and entity:getCurPetEntity() or entity
end

function ChatSystem:showEntityMessageBubbleByUid(uid, messageData)
	local entity = self:getChatEntityByUid(uid)

	if entity ~= nil then
		local targetEnt = self:getChatDisplayEntity(entity)

		if targetEnt ~= nil then
			targetEnt:ensureToplogoComponent(UIConst.TOPLOGO_COMPONENT.PLAYER_CHAT)
			targetEnt.eventEmitter:emit(EventConst.TOPLOGO_PLAYER_CHAT_BUBBLE, true, self:getTextContentFromExtraInfo(messageData.extraInfo) or messageData.textContent, messageData.isArkFont == true, messageData.chatBubble)
		end
	end
end

function ChatSystem:showEntityMessageTypingByUid(uid, type)
	local entity = self:getChatEntityByUid(uid)

	if entity then
		local targetEnt = self:getChatDisplayEntity(entity)

		if targetEnt then
			if type == ClientConst.PlayerTyping.Typing then
				targetEnt:ensureToplogoComponent(UIConst.TOPLOGO_COMPONENT.PLAYER_CHAT)
			end

			targetEnt.eventEmitter:emit(EventConst.TOPLOGO_PLAYER_CHAT_TYPING, type)
		end
	end
end

function ChatSystem:getTextContentFromExtraInfo(extraInfo)
	if not extraInfo then
		return nil
	end

	if extraInfo[Const.CHAT_EXTRA_TYPE.PositionCard] then
		return pg.game.chat:getLocationText(extraInfo[Const.CHAT_EXTRA_TYPE.PositionCard])
	elseif extraInfo[Const.CHAT_EXTRA_TYPE.Pet] then
		if string.isNilOrEmpty(decompress(extraInfo[Const.CHAT_EXTRA_TYPE.Pet])) then
			return ""
		end

		local decodedExtraInfo = json.decode(decompress(extraInfo[Const.CHAT_EXTRA_TYPE.Pet]))

		return pg.getFormatText(pg.getGameString("CHAT_SEND_PET"), pg.getLocalizationText(decodedExtraInfo.name))
	elseif extraInfo[Const.CHAT_EXTRA_TYPE.Item] then
		return pg.getFormatText(pg.getGameString("CHAT_SEND_PET"), pg.getLocalizationText(extraInfo[Const.CHAT_EXTRA_TYPE.Item].name))
	elseif extraInfo[Const.CHAT_EXTRA_TYPE.Picture] then
		return pg.getFormatText("[{0}]", pg.getGameString("PICTURE"))
	elseif extraInfo[Const.CHAT_EXTRA_TYPE.FriendCard] then
		return pg.getFormatText("[{0}]", pg.getGameString("FRIEND_CARD"))
	elseif extraInfo[Const.CHAT_EXTRA_TYPE.Emoji] then
		return pg.getGameString("CHAT_BUBBLE_EMOJI")
	end

	return nil
end

function ChatSystem:getHomeCampGroupId()
	return Utils.getHomeCampKeyGroupId(Utils.getSelfHomeCampKey(pg.me) or "")
end

function ChatSystem:fillVehicleChatExtraInfo(extraInfo, vehicleActorId)
	if extraInfo == nil then
		return
	end

	extraInfo.vehicleActorId = vehicleActorId
end

function ChatSystem:isSameVehicleChatScope(vehicleActorId, targetVehicleActorId, extraInfo)
	vehicleActorId = tonumber(vehicleActorId) or 0
	targetVehicleActorId = tonumber(targetVehicleActorId) or 0

	if vehicleActorId == 0 or targetVehicleActorId == 0 then
		return false
	end

	return vehicleActorId == targetVehicleActorId
end

function ChatSystem:getVehicleChatTargetIds(vehicleActorId, allowInactive)
	local targetIds = {}
	local targetIdMap = {}

	local function addTargetUid(uid)
		if uid == nil or uid == pg.me.uid or targetIdMap[uid] == true then
			return
		end

		targetIdMap[uid] = true

		table.insert(targetIds, uid)
	end

	vehicleActorId = tonumber(vehicleActorId) or 0

	if vehicleActorId == 0 or pg.me == nil then
		return targetIds
	end

	local onVehicleActorId = tonumber(pg.me.onVehicleActorId) or 0

	if allowInactive ~= true and onVehicleActorId ~= vehicleActorId then
		return targetIds
	end

	local vehicle = pg.getEntityByActorId(vehicleActorId)

	if vehicle ~= nil and vehicle.entityMap ~= nil then
		for actorId, _ in pairs(vehicle.entityMap) do
			local ent = pg.getEntityByActorId(tonumber(actorId) or 0)

			if ent ~= nil and Utils.isPlayer(ent) == true then
				addTargetUid(ent.uid)
			end
		end
	end

	for _, ent in pairs(EntityManager.getAllPlayers() or EMPTY_TABLE) do
		if ent ~= nil and Utils.isPlayer(ent) == true and self:isSameVehicleChatScope(tonumber(ent.onVehicleActorId), vehicleActorId) == true then
			addTargetUid(ent.uid)
		end
	end

	return targetIds
end

function ChatSystem:getVehicleChatChannelInfo()
	if pg.me == nil then
		return nil
	end

	local onVehicleActorId = tonumber(pg.me.onVehicleActorId) or 0

	if onVehicleActorId == 0 then
		return nil
	end

	local vehicleEnt = pg.getEntityByActorId(onVehicleActorId)

	if vehicleEnt == nil then
		return nil
	end

	local vehicleConfig = vehicleEnt:getVehicleConfig()

	if vehicleConfig == nil or vehicleConfig.isopenchat ~= 1 then
		return
	end

	local channelName = pg.getGameString("CHAT_CHANNEL_INTERACT")

	return {
		channelTabIndex = 0,
		channelName = channelName,
		channelType = pg.game.chat.channelType.Vehicle,
		channelId = onVehicleActorId
	}
end

function ChatSystem:hasNearbyPlayerGhost()
	if pg.me == nil or pg.me.space == nil then
		return false
	end

	local actorIds = pg.me:entitiesInRange(Const.CHAT.NEARBY_RADIUS, Const.SEARCH_USR_TYPE_PLAYER_GHOST)

	for _, actorId in ipairs(actorIds) do
		if Utils.isPlayerGhost(pg.getEntityByActorId(actorId)) then
			return true
		end
	end

	return false
end

function ChatSystem:getCurSimpleChatChannelInfo()
	local TabIndex = {
		Home = 3,
		Team = 2,
		Near = 4
	}

	if pg.me == nil or pg.me.space == nil then
		return nil
	end

	local vehicleChatChannel = self:getVehicleChatChannelInfo()

	if vehicleChatChannel ~= nil then
		return vehicleChatChannel
	end

	local membersInfo = pg.me:getShowTeamInfo().membersInfo

	if membersInfo then
		for uid, _ in pairs(membersInfo) do
			if uid ~= pg.me.uid and EntityManager.getEntityByUid(uid) then
				return {
					channelName = pg.getGameString("CHAT_CHANNEL_TEAM"),
					channelType = pg.game.chat.channelType.Team,
					channelId = pg.me:getCurTeamInfo().teamId,
					channelTabIndex = TabIndex.Team
				}
			end
		end
	end

	if pg.space and pg.space.demoMode == true or pg.me.space.demoMode == true then
		return {
			channelName = pg.getGameString("CHAT_CHANNEL_NEAR"),
			channelType = pg.game.chat.channelType.Near,
			channelId = pg.game.chat.channelType.Near,
			channelTabIndex = TabIndex.Near
		}
	end

	if pg.me.space.spaceKey and pg.me.space.isSelfHomeCamp and pg.me.space:isSelfHomeCamp(pg.me) then
		return {
			channelName = pg.getGameString("CHAT_CHANNEL_HOME"),
			channelType = pg.game.chat.channelType.Home,
			channelId = pg.game.chat:getHomeCampGroupId(),
			channelTabIndex = TabIndex.Home
		}
	end

	if pg.space and SceneUtils.isSeamlessScene(pg.space.sceneId) or Utils.isSpaceTown(pg.me.space.spaceType) or self:hasNearbyPlayerGhost() then
		return {
			channelName = pg.getGameString("CHAT_CHANNEL_NEAR"),
			channelType = pg.game.chat.channelType.Near,
			channelId = pg.game.chat.channelType.Near,
			channelTabIndex = TabIndex.Near
		}
	end

	return nil
end

function ChatSystem:onControlStateChange(info)
	if not info or info.old == nil or info.new == nil or info.old == info.new then
		return
	end

	local entity = info.playerId == pg.me.uid and pg.me or EntityManager.getEntityByUid(info.playerId)

	if entity then
		entity.eventEmitter:emit(EventConst.TOPLOGO_PLAYER_CHAT_BUBBLE, false, "")
		entity.eventEmitter:emit(EventConst.TOPLOGO_FRIEND_INTERACT, false, 0)
		entity.eventEmitter:emit(EventConst.PLAYER_ACTION_STATE_CHANGED, Const.PlayerActionState.None)
		entity.eventEmitter:emit(EventConst.TOPLOGO_TEAM_SPEECH, false)

		local pet = entity:getCurPetEntity()

		if pet then
			pet.eventEmitter:emit(EventConst.TOPLOGO_PLAYER_CHAT_BUBBLE, false, "")
			pet.eventEmitter:emit(EventConst.TOPLOGO_FRIEND_INTERACT, false, 0)
			pet.eventEmitter:emit(EventConst.PLAYER_ACTION_STATE_CHANGED, Const.PlayerActionState.None)
			pet.eventEmitter:emit(EventConst.TOPLOGO_TEAM_SPEECH, false)
		end
	end
end

function ChatSystem:getMessageBindMap()
	return {
		[MessageName.CONTROL_TYPE_CHANGE] = "spaceFollowCurLeader",
		[MessageName.SPACE_FOLLOW_UPDATE] = "spaceFollowCurLeader",
		[MessageName.PLAYER_ONTELEPORT] = "spaceFollowCurLeader",
		[MessageName.ON_PLAYER_ENTER_SCENE] = "spaceFollowCurLeader",
		[MessageName.SYNC_TEAM_INFO] = "spaceFollowCurLeader",
		[MessageName.CONTROL_STATE_CHANGE] = "onControlStateChange",
		[MessageName.ADD_NEW_CHAT_MESSAGE] = "onChatMessageUpdate",
		[MessageName.CHAT_MESSAGE_UPDATE] = "onChatMessageUpdate",
		[MessageName.PLAYER_NAME_CHANGE] = "onSelfPlayerDataChanged",
		[MessageName.PLAYER_ICON_CHANGE] = "onSelfPlayerDataChanged",
		[MessageName.PLAYER_FRAME_CHANGE] = "onSelfPlayerDataChanged",
		[MessageName.PLAYER_LEVEL_CHANGE] = "onSelfPlayerDataChanged",
		[MessageName.SDK_ACCOUNT_BIND_CHANGED] = "onSDKAccountBindChanged",
		[MessageName.DISCORD_STATUS_CHANGED] = "onDiscordStatusChanged",
		[MessageName.DISCORD_SOCIAL_INFO_UPDATED] = "onDiscordSocialInfoUpdated",
		[MessageName.DISCORD_FRIENDS_UPDATED] = "onDiscordSDKFriendsUpdated",
		[MessageName.DISCORD_RICH_PRESENCE_UPDATED] = "onDiscordRichPresenceUpdated",
		[MessageName.DISCORD_INVITE_SENT] = "onDiscordInviteSent"
	}
end

function ChatSystem:setTeamMiniChatWidget(chatWidget)
	local teamInfo = pg.me and pg.me:getCurTeamInfo() or nil
	local teamId = teamInfo and teamInfo.teamId
	local objectReference = chatWidget:GetComponent("ObjectReference")

	self.btnTeamChat = objectReference:GetRefValue("btnChat")
	self.txtMessageTeamChat = objectReference:GetRefValue("txtMessage")
	self.btnFastUButton = objectReference:GetRefValue("btnFastUButton")

	function self.btnTeamChat.luaClick()
		local openParam = {
			initTab = self.tabType.Notice,
			initChannelType = self.channelType.Team
		}
		local options = {
			ignoreDisableMainCamera = true,
			openAdditive = true
		}

		pg.global.ui:open(UIConst.UI_ID_CHAT, openParam, nil, nil, options)
	end

	if not pg.me or not teamId or teamId == "" then
		self.btnFastUButton:SetActive(false)

		self.btnFastUButton.luaRenderTooltip = nil

		ClientTextUtils.setText(self.txtMessageTeamChat, pg.getGameString("NO_TEAM_CHAT_HINT"))

		return
	end

	self.btnFastUButton:SetActive(true)

	function self.btnFastUButton.luaRenderTooltip(btn, popup)
		local objRef = popup:GetComponent("ObjectReference")
		local listUList = objRef:GetRefValue("listUList")

		function listUList.luaRenderItem(button, index, data)
			local listObjRef = button:GetComponent("ObjectReference")
			local txtNameUSDFText = listObjRef:GetRefValue("txtNameUSDFText")

			ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(data.label))

			function button.luaClick()
				self:sendMessage(pg.getLocalizationText(data.label), pg.game.chat.subMessageType.Text, pg.game.chat.channelType.Team, pg.me:getCurTeamInfo().teamId)
			end
		end

		local sendDatas = {}

		for _, data in ipairs(ChatQuickSendData) do
			sendDatas[#sendDatas + 1] = {
				label = data.cardName
			}
		end

		listUList:SetList(sendDatas)
	end

	local messageData = self:getChannelLastMessage(teamId)

	self:refreshTeamMiniChatMessage(messageData)
end

function ChatSystem:clearTeamMiniChatWidget()
	self.btnTeamChat = nil
	self.txtMessageTeamChat = nil
end

function ChatSystem:onChatMessageUpdate(info)
	local teamId = pg.me and pg.me:getCurTeamInfo().teamId

	if not pg.me or not teamId then
		return
	end

	if info.channelId == teamId then
		local messageData = self:getChannelLastMessage(teamId)

		self:refreshTeamMiniChatMessage(messageData)
	end
end

function ChatSystem:refreshTeamMiniChatMessage(messageData)
	if not self.btnTeamChat then
		return
	end

	if messageData == nil then
		if pg.global.ui:runPlatformByMobile() then
			ClientTextUtils.setText(self.txtMessageTeamChat, pg.getGameString("TEAM_ROOM_CHAT_EMPTY_MOBILE"))
		else
			ClientTextUtils.setText(self.txtMessageTeamChat, pg.getGameString("TEAM_ROOM_CHAT_EMPTY"))
		end

		return
	end

	local playerInfo = pg.game.chat:getPlayerInfo(messageData.playerId)
	local playerName = playerInfo and playerInfo.playerName
	local _h = ChatSystem._platformHooks

	if _h and _h.refreshTeamMiniChatMessage then
		playerName = _h.refreshTeamMiniChatMessage(self, messageData, playerInfo)
	end

	local prefix = playerName and playerName .. ": " or ""

	if messageData.subType == pg.game.chat.subMessageType.Text or messageData.subType == pg.game.chat.subMessageType.Audio then
		ClientTextUtils.setText(self.txtMessageTeamChat, prefix, messageData.textContent)
	elseif messageData.subType == pg.game.chat.subMessageType.Emoji then
		ClientTextUtils.setText(self.txtMessageTeamChat, prefix, pg.getGameString("CHAT_BUBBLE_EMOJI"))
	end
end

function ChatSystem:recvRequestFriendAction(uid, actionId)
	local function addNotice(playerInfo)
		if not playerInfo or not pg.global.ui or not pg.global.ui.hudV2 then
			return
		end

		local actionCfg = AppearanceAction[actionId]
		local actionName = actionCfg and pg.getLocalizationText(actionCfg.name) or ""
		local noticeMsg = ""

		if actionCfg.inviteText then
			noticeMsg = pg.getLocalizationText(actionCfg.inviteText)
		else
			logger:info("appearanceActionData inviteText config none")
		end

		pg.global.ui.tips:addHudNotice(uid, playerInfo, noticeMsg, 10, function()
			pg.me:confirmFriendAction(uid, actionId, true, function(result)
				if result then
					self:handleTopLogoFriendInteract(uid, false, ClientConst.FriendInteractType.FriendAction)
				end
			end)
		end, function()
			pg.me:confirmFriendAction(uid, actionId, false, function(result)
				if result then
					self:handleTopLogoFriendInteract(uid, false, ClientConst.FriendInteractType.FriendAction)
				end
			end)
		end, function()
			pg.me:confirmFriendAction(uid, actionId, false, function(result)
				if result then
					self:handleTopLogoFriendInteract(uid, false, ClientConst.FriendInteractType.FriendAction)
				end
			end)
		end, {
			funcName = Const.FUNCTION_NAME.FRIEND
		})
		self:handleTopLogoFriendInteract(uid, true, ClientConst.FriendInteractType.FriendAction, actionId)
	end

	local playerInfo = pg.game.chat:getPlayerInfo(uid)

	if playerInfo then
		addNotice(playerInfo)
	else
		self:queryPlayerInfo(uid, nil, true, function(info)
			addNotice(info)
		end)
	end
end

function ChatSystem:clearChannelListDataByTime()
	local now = Time.realSecondCache or os.time()

	if not self.nextCleanChatMessageTime then
		self.nextCleanChatMessageTime = now + 10

		return
	end

	if now < self.nextCleanChatMessageTime then
		return
	end

	self.nextCleanChatMessageTime = now + 10

	local isChatOpen = false
	local openChannelId = ""

	if pg.global and pg.global.ui and pg.global.ui:checkUIOpen(UIConst.UI_ID_CHAT) then
		isChatOpen = true

		local chatComponent = pg.global.ui.chat and pg.global.ui.chat.chatComponent

		openChannelId = chatComponent and chatComponent.curSelectedChannelId
	end

	local hasClean = false

	for channelId, messages in pairs(self.chatMessageListData) do
		if not isChatOpen or openChannelId and tostring(channelId) ~= tostring(openChannelId) then
			local channelType = self:getChannelTypeFromMessageList(channelId, messages)
			local keepCount = self:getChatMessageKeepCount(channelType)

			if keepCount and keepCount < #messages then
				local startIndex = #messages - keepCount + 1

				if startIndex > 1 then
					local oldCount = #messages

					for i = startIndex, oldCount do
						messages[i - startIndex + 1] = messages[i]
					end

					for i = oldCount - startIndex + 2, oldCount do
						messages[i] = nil
					end

					self:rebuildChannelMessageIdIndex(channelId)

					hasClean = true
				end
			end
		end
	end

	if hasClean then
		facade:SendMessageCommand(MessageName.CHAT_RED_DOT_UPDATE)
	end
end

function ChatSystem:GetChatBubbleRes(chatBubbleId, isOtherPlayer, isWorld)
	local defaultChatBubbleId = self:GetDefaultChatBubbleId()

	if chatBubbleId == nil or chatBubbleId == 0 then
		chatBubbleId = defaultChatBubbleId
	end

	local bubbleData = ChatBubbleData[chatBubbleId]

	if bubbleData == nil or chatBubbleId == defaultChatBubbleId then
		if isOtherPlayer == true then
			return OTHER_DEFAULT_CHAT_BUBBLE_RES
		elseif isWorld == true then
			return OTHER_DEFAULT_WORLD_BUBBLE_RES
		end
	end

	return bubbleData.res
end

function ChatSystem:GetDefaultChatBubbleId()
	return SysConfigData.CHAT_BUBBLE_DEFAULT
end

return ChatSystem
