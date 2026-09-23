-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FriendGroupSetup\\FriendGroupSetupCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local FriendGroupSetupCtrl = Class.LightClass("FriendGroupSetupCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local FriendshipLevelData = require("Data.friendship_level_data")
local SysConfigData = require("Data.sys_config_data")
local Const = require("Common.Const.Const")
local UIConst = require("Const.UIConst")

FriendGroupSetupCtrl.messages = {
	[MessageName.FRIEND_CHAT_GROUP_UPDATE] = {
		"updateFriendGroupSetupPanel",
		true
	},
	[MessageName.PLAYER_SPARK_CHANGE] = {
		"refreshPlayerSpark",
		true
	}
}

function FriendGroupSetupCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.groupId = info.groupId
	self.groupData = pg.game.chat:getFriendChatGroup(self.groupId)
	self.isMaster = self.groupData.master == pg.me.uid

	self:refreshFriendGroupSetupPanel()
end

function FriendGroupSetupCtrl:addListener()
	function self.view.bgCloseUButton.luaClick()
		self:close()
	end

	function self.view.btnCloseUButton.luaClick()
		self:close()
	end

	function self.view.btnDismissUButton.luaClick()
		self:onDismissButtonClick()
		self:close()
	end

	function self.view.memberListUList.luaRenderItem(button, index, data)
		if data.tIndex < 2 then
			button.luaClick = data.btnFunc
		else
			LuaUIUtils.renderPlayerAvatarButton(button, {
				hideLevel = true,
				canOpenInfoPlayerCard = true,
				showOnlineState = true,
				playerId = data.playerId,
				playerInfo = data.playerInfo,
				avatarType = LuaUIUtils.PLAYER_AVATAR_TYPE.CHAT,
				playSparkAnimation = self.sparkAnimationPlayerUid == data.playerId
			})

			local isGroupOwner = data.playerId == self.groupData.master

			button:TryChangePage("GroupOwner", isGroupOwner and 1 or 0)
		end
	end

	function self.view.btnEditUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_CHANGE_NAME, {
			editType = 2,
			initialInputText = self.groupData.chatGroupName,
			groupId = self.groupId
		})
	end
end

function FriendGroupSetupCtrl:updateFriendGroupSetupPanel()
	self.groupData = pg.game.chat:getFriendChatGroup(self.groupId)

	self:refreshFriendGroupSetupPanel()
end

function FriendGroupSetupCtrl:refreshPlayerSpark(playerUid)
	self.sparkAnimationPlayerUid = playerUid

	self.view.memberListUList:RefreshList()

	self.sparkAnimationPlayerUid = nil
end

function FriendGroupSetupCtrl:sortMemberUidsByMaster(uids)
	local masterId = self.groupData.master
	local uidIndexMap = {}

	for index, uid in ipairs(uids) do
		uidIndexMap[uid] = index
	end

	local function compareUidByMaster(a, b)
		local aIsMaster = a == masterId
		local bIsMaster = b == masterId

		if aIsMaster ~= bIsMaster then
			return aIsMaster
		end

		return uidIndexMap[a] < uidIndexMap[b]
	end

	table.sort(uids, compareUidByMaster)
end

function FriendGroupSetupCtrl:refreshFriendGroupSetupPanel()
	self.view.widget:TryChangePage("GroupState", self.isMaster and 0 or 1)
	ClientTextUtils.setText(self.view.txtNameUSDFText, pg.game.chat:getChatGroupDisplayName(self.groupData))
	ClientTextUtils.setText(self.view.textSubTitleUSDFText, pg.getGameString("EDIT_CHAT_GROUP_NAME"))
	ClientTextUtils.setText(self.view.textMemberTitleUSDFText, pg.getGameString("CHATGROUP_MEMBER_LIST"))
	ClientTextUtils.setText(self.view.textTitleUSDFText, pg.getGameString("CHAT_GROUP_MANAGE"))
	ClientTextUtils.setText(self.view.btnDismissTextUSDFText, self.isMaster and pg.getGameString("DELETE_CHAT_GROUP_WARNING") or pg.getGameString("LEAVE_CHAT_GROUP_WARNING"))

	local memberDatas = {}

	memberDatas[#memberDatas + 1] = {
		tIndex = 0,
		btnFunc = function()
			pg.global.ui:open(UIConst.UI_ID_FRIEND_SETUP, {
				setupType = pg.global.ui.friendSetup.model.FriendSetupType.AddChatGroupMember,
				groupId = self.groupId
			})
			self:close()
		end
	}

	if self.isMaster then
		memberDatas[#memberDatas + 1] = {
			tIndex = 1,
			btnFunc = function()
				pg.global.ui:open(UIConst.UI_ID_FRIEND_SETUP, {
					setupType = pg.global.ui.friendSetup.model.FriendSetupType.RemoveChatGroupMember,
					groupId = self.groupId
				})
				self:close()
			end
		}
	end

	local uids = self.groupData.uids

	self:sortMemberUidsByMaster(uids)

	for _, uid in ipairs(uids) do
		memberDatas[#memberDatas + 1] = {
			tIndex = 2,
			playerId = uid,
			playerInfo = pg.game.chat:getPlayerInfo(uid)
		}
	end

	ClientTextUtils.setText(self.view.textGroupNumUSDFText, pg.getFormatText(pg.getGameString("COUNT_OF_TOTAL"), #self.groupData.uids, Const.CHAT.CHAT_GROUP_MAX_MEMBER_COUNT))
	self.view.memberListUList:SetList(memberDatas)
end

function FriendGroupSetupCtrl:onDismissButtonClick()
	if self.isMaster then
		pg.global.showConfirmMsgRaw(pg.getGameString("DELETE_CHAT_GROUP_WARNING"), pg.getGameString("DELETE_CHAT_GROUP_WARNING_DESC"), function()
			pg.me:deleteChatGroup(self.groupId)
		end, nil)
	else
		pg.global.showConfirmMsgRaw(pg.getGameString("LEAVE_CHAT_GROUP_WARNING"), pg.getGameString("LEAVE_CHAT_GROUP_WARNING_DESC"), function()
			pg.me:leaveChatGroup(self.groupId, {
				pg.me.uid
			})
		end, nil)
	end
end

return FriendGroupSetupCtrl
