-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomelandSeasonCelebrationPrepare\\HomelandSeasonCelebrationPrepareCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local TimerManager = require("Core.Timer.TimerManager")
local Time = require("Core.Common.Time")
local UIConst = require("Const.UIConst")
local MessageName = require("Const.MessageName")
local ClientTextUtils = require("Utils.ClientTextUtils")
local NoticeDef = require("Common.NoticeDef")
local LuaUIUtils = require("Utils.LuaUIUtils")
local FriendshipLevelData = require("Data.friendship_level_data")
local AvatarPresetData = require("Data.avatar_preset_data")
local logger = require("Core.Log.LoggerManager").getLogger("HomelandSeasonCelebrationPrepareCtrl")
local CELEBRATION_STATE_PREPARING = 1
local HomelandSeasonCelebrationPrepareCtrl = Class.LightClass("HomelandSeasonCelebrationPrepareCtrl", UICtrl)

HomelandSeasonCelebrationPrepareCtrl.messages = {
	[MessageName.HOME_SEASON_CELEBRATION_CHANGE] = {
		"refreshAll",
		true
	},
	[MessageName.HOME_SEASON_CELEBRATION_PLAYERS_CHANGE] = {
		"refreshPlayerList",
		true
	},
	[MessageName.ON_OTHER_PLAYER_ENTER_SCENE] = {
		"refreshPlayerList",
		true
	},
	[MessageName.ON_OTHER_PLAYER_LEAVE_SCENE] = {
		"refreshPlayerList",
		true
	}
}

function HomelandSeasonCelebrationPrepareCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.space = info and info.space or pg.space
end

function HomelandSeasonCelebrationPrepareCtrl:addListener()
	if self.view.listPlayerUList then
		function self.view.listPlayerUList.luaRenderItem(button, index, data)
			self:renderPlayerItem(button, index, data)
		end
	end

	if self.view.btnCancelUButton then
		function self.view.btnCancelUButton.luaClick()
			self:cancelCelebration()
		end
	end

	function self.view.btnCloseUButton.luaClick()
		self:close()
	end

	if self.view.btnInviteUButton then
		function self.view.btnInviteUButton.luaClick()
			if not self.space or not self.space:isCelebrationOwner() or self.space.homeSeasonCelebrationState ~= CELEBRATION_STATE_PREPARING then
				return
			end

			pg.global.ui:open(UIConst.UI_ID_HOME_SEASON_CELEBRATION_INVITE, {
				space = self.space
			})
		end
	end

	if self.view.btnConfirmUButton then
		function self.view.btnConfirmUButton.luaClick()
			self:confirmBeginCelebration()
		end
	end
end

function HomelandSeasonCelebrationPrepareCtrl:onOpen()
	UICtrl.onOpen(self)

	if not self.view.btnInviteUButton or not self.view.btnConfirmUButton then
		logger:error("harvest invite prefab requires BtnInvite and BtnConfirm nodes")
	end

	self:refreshAll()

	self.timerId = TimerManager.addRepeatTimer(1, function()
		self:refreshCountdown()
	end)
end

function HomelandSeasonCelebrationPrepareCtrl:onDestroy()
	if self.timerId then
		TimerManager.removeTimer(self.timerId)

		self.timerId = nil
	end

	UICtrl.onDestroy(self)
end

function HomelandSeasonCelebrationPrepareCtrl:refreshAll()
	if not self.space or (self.space.homeSeasonCelebrationState or 0) == 0 then
		self:close()

		return
	end

	local isPreparing = self.space.homeSeasonCelebrationState == CELEBRATION_STATE_PREPARING
	local isOwner = self.space.isCelebrationOwner and self.space:isCelebrationOwner()

	ClientTextUtils.setText(self.view.txtTitle, isPreparing and pg.getGameString("HOME_SEASON_CELEBRATION_PREPARING_TITLE") or pg.getGameString("HOME_SEASON_CELEBRATION_RUNNING_TITLE"))
	ClientTextUtils.setText(self.view.txtConfirm, pg.getGameString("HOME_SEASON_CELEBRATION_START_BUTTON"))

	if self.view.txtCancel then
		ClientTextUtils.setText(self.view.txtCancel, pg.getGameString("HOME_SEASON_CELEBRATION_STOP_BUTTON"))
	end

	if self.view.btnInviteUButton then
		self.view.btnInviteUButton:SetActive(isPreparing and isOwner)
	end

	if self.view.btnConfirmUButton then
		self.view.btnConfirmUButton:SetActive(isPreparing and isOwner)
	end

	self:refreshCountdown()
	self:refreshPlayerList()
end

function HomelandSeasonCelebrationPrepareCtrl:refreshCountdown()
	if not self.space then
		return
	end

	local remain = math.max(0, math.ceil((self.space.homeSeasonCelebrationEndTs or 0) - Time.secondCache))
	local minutes = math.floor(remain / 60)
	local seconds = remain % 60

	ClientTextUtils.setText(self.view.txtTips, string.format("%s %02d:%02d", pg.getGameString("HOME_SEASON_CELEBRATION_PREPARING_COUNTDOWN"), minutes, seconds))
end

function HomelandSeasonCelebrationPrepareCtrl:refreshPlayerList()
	if not self.view or not self.view.listPlayerUList then
		return
	end

	local players = self.model:getPlayerList()

	ClientTextUtils.setText(self.view.txtRole, tostring(#players))
	self.view.listPlayerUList:SetList(players)
end

function HomelandSeasonCelebrationPrepareCtrl:renderPlayerItem(button, index, data)
	button.enabledTooltip = true

	local playerInfo = pg.game.chat:getPlayerInfo(data.playerId) or data.entity or {}
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local imgFriendlyUImage = objectReference:GetRefValue("imgFriendlyUImage")
	local playerHeadUWidget = objectReference:GetRefValue("playerHeadUWidget")
	local playerName = playerInfo.playerName or tostring(data.playerId)

	ClientTextUtils.setText(txtNameUSDFText, playerName)
	LuaUIUtils.renderPlayerAvatarImages(playerHeadUWidget, {
		avatarIconId = playerInfo.headIcon,
		avatarFrameIconId = playerInfo.headFrame
	})

	local preset = playerInfo.avatarPresetKey and AvatarPresetData[playerInfo.avatarPresetKey] or {}
	local genderPage = preset.templateId == 4 and 0 or preset.templateId == 3 and 1 or 2

	button:TryChangePage("Gender", genderPage)

	local friendshipLevel = pg.game.chat:getFriendship(data.playerId)
	local friendship = friendshipLevel and FriendshipLevelData[friendshipLevel]

	imgFriendlyUImage.gameObject:SetActiveEx(friendship ~= nil)

	if friendship then
		imgFriendlyUImage.url = friendship.levelIcon
	end

	pg.global.ui.chat:handlePlayerTooltip(button, data)
end

function HomelandSeasonCelebrationPrepareCtrl:cancelCelebration()
	if not self.space or not self.space:isCelebrationOwner() or self.space.homeSeasonCelebrationState ~= CELEBRATION_STATE_PREPARING then
		return
	end

	pg.me:reqCancelHomeSeasonCelebration(function(result)
		if result == NoticeDef.SUCCESS then
			self:close()
		end
	end)
end

function HomelandSeasonCelebrationPrepareCtrl:confirmBeginCelebration()
	if not self.space or not self.space:isCelebrationOwner() or self.space.homeSeasonCelebrationState ~= CELEBRATION_STATE_PREPARING then
		return
	end

	pg.global.showConfirmMsgRaw(pg.getGameString("HOME_SEASON_CELEBRATION_START_CONFIRM_TITLE"), pg.getGameString("HOME_SEASON_CELEBRATION_START_CONFIRM_CONTENT"), function()
		pg.me:reqBeginHomeSeasonCelebration(function(result)
			if result == NoticeDef.SUCCESS then
				self:close()
			end
		end)
	end)
end

return HomelandSeasonCelebrationPrepareCtrl
