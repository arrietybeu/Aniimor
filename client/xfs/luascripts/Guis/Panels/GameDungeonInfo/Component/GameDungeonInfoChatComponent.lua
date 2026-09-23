-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GameDungeonInfo\\Component\\GameDungeonInfoChatComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local LevelData = require("Data.level_data")
local MessageName = require("Const.MessageName")
local GameDungeonInfoChatComponent = Class.LightClass("GameDungeonInfoChatComponent", UIComponent)

GameDungeonInfoChatComponent.messages = {
	[MessageName.TEAM_MATCH_ENTRY_INTERACTABLE_CHANGE] = {
		"refreshConfirmState",
		true
	}
}

function GameDungeonInfoChatComponent:onCtor(info)
	self.dungeonSceneId = info.dungeonSceneId
	self.difficultLv = info.difficultLv or 0
end

function GameDungeonInfoChatComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnChat = objectReference:GetRefValue("btnChat")
	self.chatUComponent = objectReference:GetRefValue("chatUComponent")
	self.listUList = objectReference:GetRefValue("listUList")
	self.txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
	self.teamUButton = objectReference:GetRefValue("teamUButton")
end

function GameDungeonInfoChatComponent:registerObjects()
	function self.listUList.luaRenderItem(button, index, data)
		self:renderMemberItem(button, data)
	end

	function self.teamUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_TEAM_ROOM)
	end
end

function GameDungeonInfoChatComponent:initView()
	self.isConfirming = false

	self:refreshTeamInfo()
end

function GameDungeonInfoChatComponent:refreshTeamInfo()
	self:refreshTeamChatWidget()
	self:refreshTeamMemberCount()
	self:refreshTeamMemberList()
end

function GameDungeonInfoChatComponent:refreshTeamChatWidget()
	self.btnChat:SetActive(true)
	pg.game.chat:setTeamMiniChatWidget(self.btnChat)
end

function GameDungeonInfoChatComponent:getDungeonPlayerMax()
	local teamInfo = pg.me and pg.me:getShowTeamInfo() or nil
	local dungeonConfig = LevelData[self.dungeonSceneId] or nil

	if teamInfo and next(teamInfo) then
		return dungeonConfig and dungeonConfig.playerNumMax or 4
	else
		return dungeonConfig and dungeonConfig.playerNumMax
	end
end

function GameDungeonInfoChatComponent:refreshTeamMemberCount()
	local currentCount = pg.me and pg.me:isInTeam() and pg.me:getTeamMemberCount() or 1
	local maxCount = self:getDungeonPlayerMax()
	local countText = maxCount < currentCount and string.format("<style=Debuff>%d</style>", currentCount) or currentCount

	ClientTextUtils.setText(self.txtNumUSDFText, countText .. "/" .. maxCount)
end

function GameDungeonInfoChatComponent:getSelfMemberInfo()
	return {
		uid = pg.me.uid,
		playerName = pg.me.playerName,
		headIcon = pg.me.headIcon,
		headFrame = pg.me.headFrame,
		level = pg.me.level,
		starTitle = pg.me.starTitle
	}
end

function GameDungeonInfoChatComponent:refreshConfirmState(isConfirming)
	self.isConfirming = isConfirming ~= true

	self:refreshTeamInfo()
end

function GameDungeonInfoChatComponent:getTeamMemberData()
	local maxCount = self:getDungeonPlayerMax()
	local teamInfo = pg.me and pg.me:getShowTeamInfo() or nil
	local memberCount = pg.me and pg.me:isInTeam() and pg.me:getTeamMemberCount() or 1
	local showCount = self.isConfirming and memberCount or math.max(maxCount, memberCount)
	local data = {}

	for i = 1, showCount do
		data[i] = {
			empty = true,
			tIndex = 0
		}
	end

	if pg.me:isInTeam() then
		for index, uid in ipairs(teamInfo.sortList or EMPTY_TABLE) do
			if data[index] then
				data[index] = {
					tIndex = 0,
					uid = uid,
					playerInfo = teamInfo.membersInfo and teamInfo.membersInfo[uid]
				}
			end
		end
	elseif pg.me and data[1] then
		data[1] = {
			tIndex = 0,
			uid = pg.me.uid,
			playerInfo = self:getSelfMemberInfo()
		}
	end

	return data
end

function GameDungeonInfoChatComponent:refreshTeamMemberList()
	self.listUList:SetList(self:getTeamMemberData())
end

function GameDungeonInfoChatComponent:renderMemberItem(button, data)
	if not pg.me then
		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local playerHeadUContainer = objectReference:GetRefValue("playerHeadUContainer")
	local titleIconUImage = objectReference:GetRefValue("titleIconUImage")
	local textLvUSDFText = objectReference:GetRefValue("textLvUSDFText")
	local btnInviteUButton = objectReference:GetRefValue("btnInviteUButton")
	local playerInfo = data.playerInfo or pg.game.chat:getPlayerInfo(data.uid)
	local canInvite = pg.me.matchState == Const.PLAYER_MATCH_STATUS.IDLE and not self.isConfirming

	button:TryChangePage("Empty", data.empty and (canInvite and 2 or 1) or 0)
	button:TryChangePage("Captain", not data.empty and pg.me:isUidTeamLeader(data.uid) and 1 or 0)

	if data.empty then
		ClientTextUtils.setText(textLvUSDFText, "")

		btnInviteUButton.luaClick = canInvite and function()
			pg.global.ui:open(UIConst.UI_ID_DUNGEON_INVITE, {
				dungeonId = self.ctrl.dungeonId
			})
		end or nil

		return
	end

	btnInviteUButton.luaClick = nil

	titleIconUImage:SetActiveFastest(false)
	ClientTextUtils.setText(textLvUSDFText, playerInfo and playerInfo.level or "")
	self:renderPlayerHead(playerHeadUContainer, data.uid, playerInfo)
end

function GameDungeonInfoChatComponent:renderPlayerHead(playerHeadUContainer, uid, playerInfo)
	if playerHeadUContainer:CheckURLLoaded() then
		self:renderLoadedPlayerHead(playerHeadUContainer.content, uid, playerInfo)
	else
		playerHeadUContainer:LoadDefaultUrlManually(function(content)
			self:renderLoadedPlayerHead(content, uid, playerInfo)
		end)
	end
end

function GameDungeonInfoChatComponent:renderLoadedPlayerHead(content, uid, playerInfo)
	if not content or IsNil(content) then
		return
	end

	LuaUIUtils.renderPlayerAvatarImages(content, {
		avatarIconId = playerInfo.headIcon,
		avatarFrameIconId = playerInfo.headFrame
	})
end

function GameDungeonInfoChatComponent:onDestroy()
	pg.game.chat:clearTeamMiniChatWidget()
	UIComponent.onDestroy(self)
end

return GameDungeonInfoChatComponent
