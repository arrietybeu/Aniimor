-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Chat\\ChatModel.lua

local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local ChatSystem = require("GameApp.Chat.ChatSystem")
local UIModel = require("Guis.UIModel")
local MessageName = require("Const.MessageName")
local ChatModel = Class.LightClass("ChatModel", UIModel)
local RedDotConst = require("Const.RedDotConst")
local ChatQuickSetData = require("Data.chat_quick_set_data")
local SettingSelectorTextData = require("Data.setting_selector_text_data")
local ChatSettingData = require("Data.chat_setting_data")
local UIConst = require("Const.UIConst")
local ClientConst = require("Const.ClientConst")
local JUMP_FUNCTION_NAME_MAP = {
	[ChatSystem.jumpType.ShareHome] = "showShareHome"
}
local GIFT_FUNCTION_NAME_MAP = {
	[ChatSystem.giftType.Lottery] = "onLotteryGiftClick"
}

function ChatModel:ctor()
	UIModel.ctor(self)
end

function ChatModel:invokeJumpFunction(data)
	local jumpType = data.extraInfo.jumpType
	local jumpFunctionName = JUMP_FUNCTION_NAME_MAP[jumpType]

	self:invokeMappedFunction(data, jumpFunctionName)
end

function ChatModel:invokeGiftFunction(data)
	local giftType = data.extraInfo.giftType
	local giftFunctionName = GIFT_FUNCTION_NAME_MAP[giftType]

	self:invokeMappedFunction(data, giftFunctionName)
end

function ChatModel:invokeMappedFunction(data, functionName)
	if functionName == nil then
		return
	end

	self[functionName](self, data)
end

function ChatModel:showShareHome(data)
	return
end

function ChatModel:onLotteryGiftClick(data)
	print("helllooooo")
end

function ChatModel:getTabChannelListData(tabType)
	local channelList = {}

	if tabType == pg.game.chat.tabType.Chat then
		self:appendChannelByTypes(channelList, pg.game.chat:getSystemChannelListData(), {
			pg.game.chat.channelType.Interact,
			pg.game.chat.channelType.System
		})
		self:appendChannelList(channelList, pg.game.chat:getPrivateChannelListData())
	elseif tabType == pg.game.chat.tabType.Notice then
		self:appendChannelByTypes(channelList, pg.game.chat:getWorldChannelListData(), {
			pg.game.chat.channelType.Near,
			pg.game.chat.channelType.Team,
			pg.game.chat.channelType.Home,
			pg.game.chat.channelType.Friend
		})
	elseif tabType == pg.game.chat.tabType.Public then
		self:appendChannelByGroupBases(channelList, pg.game.chat:getWorldChannelListData(), {
			Const.CHAT_ATTR_CLASS.group_base,
			Const.CHAT_ATTR_LANGUAGE.group_base,
			Const.CHAT_ATTR_WORLD.group_base
		})
	end

	return channelList
end

function ChatModel:appendChannelByTypes(target, source, channelTypes)
	for _, channelType in ipairs(channelTypes) do
		for _, channelData in ipairs(source) do
			if channelData.type == channelType then
				target[#target + 1] = self:copyChannelData(channelData)

				break
			end
		end
	end
end

function ChatModel:appendChannelByGroupBases(target, source, groupBases)
	for _, groupBase in ipairs(groupBases) do
		for _, channelData in ipairs(source) do
			if channelData.groupBase == groupBase then
				target[#target + 1] = self:copyChannelData(channelData)

				break
			end
		end
	end
end

function ChatModel:appendChannelList(target, source)
	for _, channelData in ipairs(source) do
		target[#target + 1] = self:copyChannelData(channelData)
	end
end

function ChatModel:copyChannelData(channelData)
	local copy = {}

	for key, value in pairs(channelData) do
		copy[key] = value
	end

	return copy
end

function ChatModel:getChannelSelectionKey(channelData)
	if channelData == nil or channelData.type == nil then
		return nil
	end

	local isPrivateChannel = channelData.type == pg.game.chat.channelType.Player or channelData.type == pg.game.chat.channelType.Group

	if isPrivateChannel then
		local channelId = channelData.channelId or channelData.playerId

		return channelId and "id:" .. tostring(channelId) or nil
	end

	if channelData.type == pg.game.chat.channelType.World and channelData.groupBase then
		return "base:" .. channelData.groupBase
	end

	return "type:" .. tostring(channelData.type)
end

function ChatModel:findChannelIndex(channelList, selectionKey)
	if string.isNilOrEmpty(selectionKey) then
		return nil
	end

	for index, channelData in ipairs(channelList) do
		if self:getChannelSelectionKey(channelData) == selectionKey then
			return index
		end
	end
end

function ChatModel:getChannelTabType(channelData)
	local channelInfo = channelData and pg.game.chat.channelTypeInfo[channelData.type]

	return channelInfo and channelInfo.cate
end

function ChatModel:getTabUnreadCount(tabType)
	local count = 0
	local countedChannelIds = {}

	for _, channelData in ipairs(self:getTabChannelListData(tabType)) do
		local channelId = channelData.channelId or channelData.playerId

		if channelData.type == pg.game.chat.channelType.Interact then
			count = count + pg.game.chat:getInteractUnreadCount()
		else
			local shouldCountChannel = channelData.type ~= pg.game.chat.channelType.System and channelId ~= nil and not countedChannelIds[channelId]

			if shouldCountChannel then
				countedChannelIds[channelId] = true
				count = count + pg.game.chat:getChannelUnReadMsgCount(channelId)
			end
		end
	end

	return count
end

function ChatModel:redDot_GetMessageNumb(channelId)
	return pg.game.chat:getChannelUnReadMsgCount(channelId)
end

function ChatModel:redDot_SetMessageNumb(channelId)
	pg.game.chat:setChannelReadMsgMark(channelId)
end

function ChatModel:redDot_GetTabMessageNumb()
	return self:getTabUnreadCount(pg.game.chat.tabType.Chat)
end

function ChatModel:redDot_GetWorldMessageNumb()
	return self:getTabUnreadCount(pg.game.chat.tabType.Public)
end

function ChatModel:redDot_GetHudMessageNumb()
	self.messageNum = self:redDot_GetRequestFriendNumb() + self:redDot_GetTabMessageNumb()

	return self.messageNum
end

function ChatModel:redDot_GetRequestFriendNumb()
	return pg.game.chat:getFriendRequestCount()
end

function ChatModel:redDot_GetMailNewState(mailId)
	return pg.game.chat:checkIsNewMail(mailId)
end

function ChatModel:redDot_GetMailRewardState(mailId)
	return pg.game.chat:checkIsRewardMail(mailId)
end

function ChatModel:redDot_GetTabMailRewardState()
	return pg.game.chat:checkHasRewardMail()
end

function ChatModel:redDot_GetTabMailNewState()
	return pg.game.chat:checkHasNewMail()
end

function ChatModel:redDot_GetHudChatState()
	if self:redDot_GetTabMailRewardState() then
		return RedDotConst.RedDotStyle.REWARD
	end

	if self.messageNum and self.messageNum > 0 then
		return RedDotConst.RedDotStyle.NUM
	end

	return RedDotConst.RedDotStyle.NONE
end

function ChatModel:getExtensionFunctionList(channelType, channelId, isGroupSetting)
	local channelTypeInfo = pg.game.chat.channelTypeInfo[channelType]

	return self:getExtensionFunctionListByType(channelTypeInfo.str, channelId, isGroupSetting)
end

function ChatModel:getExtensionFunctionListByType(channelTypeName, channelId, isGroupSetting)
	local extensionFunctionList = {}
	local shouldShow

	for _, funcData in ipairs(ChatQuickSetData) do
		shouldShow = (not isGroupSetting or funcData.isChatGroupSetting) and funcData.channelType == channelTypeName and (not funcData.checkShowFunc or self[funcData.checkShowFunc](self, channelId))

		if shouldShow then
			extensionFunctionList[#extensionFunctionList + 1] = {
				label = funcData.label,
				func = funcData.func,
				checkFunc = funcData.checkFunc,
				settingType = funcData.settingType,
				tIndex = funcData.widgetType,
				widgetTxt = funcData.widgetTxt
			}
		end
	end

	return extensionFunctionList
end

function ChatModel:setChannelSettingStateById(id, isOn, settingType)
	pg.game.chat:setChannelSettingStateById(id, isOn, settingType)
end

function ChatModel:checkChannelSettingStateById(id, settingType)
	return pg.game.chat:checkChannelSettingStateById(id, settingType)
end

function ChatModel:openGroupChatManage(id)
	pg.global.ui:open(UIConst.UI_ID_FRIEND_GROUP_SETUP, {
		groupId = id
	})
end

function ChatModel:checkCanSetRemark(playerId)
	return pg.game.chat:checkFriendList(playerId)
end

function ChatModel:checkCanChangeFriendGroup(playerId)
	return pg.game.chat:checkFriendList(playerId) or pg.game.chat:checkBlackList(playerId)
end

function ChatModel:redDot_GetFriendRequestState()
	local messageNum = pg.game.chat:getFriendRequestCount()

	if messageNum > 0 then
		return RedDotConst.RedDotStyle.NUM
	end

	return RedDotConst.RedDotStyle.NONE
end

function ChatModel:redDot_GetTabState(tabType)
	local messageNum = self:getTabUnreadCount(tabType)

	if messageNum > 0 then
		return RedDotConst.RedDotStyle.NUM
	end

	return RedDotConst.RedDotStyle.NONE
end

return ChatModel
