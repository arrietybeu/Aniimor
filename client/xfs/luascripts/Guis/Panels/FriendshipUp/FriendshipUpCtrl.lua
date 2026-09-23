-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FriendshipUp\\FriendshipUpCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("FriendshipUpCtrl")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local FriendshipUpCtrl = Class.LightClass("FriendshipUpCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local FriendshipLevelData = require("Data.friendship_level_data")

FriendshipUpCtrl.messages = {}

function FriendshipUpCtrl:getManagedBlurEffect()
	if not self.view then
		return nil
	end

	return self.view.staticUIBlurEffect
end

function FriendshipUpCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self:initializeManagedBlur()

	if not info then
		return
	end

	self.param = info
	self.isVariant = info and info.isVariant

	if not info or not info.playerId then
		return
	end

	self.playerId = info.playerId
	self.playerInfo = info.playerInfo

	if self.playerInfo then
		if not self:normalizePlayerInfo() then
			return
		end

		self:initUI()
	else
		local function onQueryPlayerInfo(playerData)
			self.playerInfo = playerData

			if not self:normalizePlayerInfo() then
				return
			end

			self:initUI()
		end

		pg.me:queryPlayerInfo(self.playerId, nil, true, onQueryPlayerInfo)
	end
end

function FriendshipUpCtrl:addListener()
	function self.view.bgCloseUButton.luaClick()
		self:close()
		facade:sendMsgToUI(MessageName.SHOW_FRIENDSHIP_UP)
	end

	function self.view.btnOpenUButton.luaClick()
		self:close()
		LuaUIUtils.openInfoPlayerCard({
			openType = ClientConst.PlayerInfoOpenType.Chat,
			playerId = self.playerId,
			playerInfo = self.playerInfo,
			openSource = pg.game.chat.AddFriendSource.PlayerCard
		})
	end
end

function FriendshipUpCtrl:normalizePlayerInfo()
	if type(self.playerInfo) ~= "table" then
		return false
	end

	if type(self.playerInfo.curShow) == "string" then
		if string.isNilOrEmpty(self.playerInfo.curShow) then
			self.playerInfo.curShow = {}
		else
			local curShowStr = decompressFromStr(self.playerInfo.curShow)

			self.playerInfo.curShow = string.isNilOrEmpty(curShowStr) and {} or string.toTable(curShowStr) or {}
		end
	elseif not self.playerInfo.curShow then
		self.playerInfo.curShow = {}
	end

	return true
end

function FriendshipUpCtrl:initUI()
	local friendShipLevel = pg.game.chat:getFriendship(self.playerId)
	local isChange = self.isVariant == true and 1 or 0

	self.view.uIPopLikabilityUpUComponent:TryChangePage("isChange", isChange)

	local beforeLevel = self.param.formerLevel or friendShipLevel - 1

	self.friendshipCfg = FriendshipLevelData[friendShipLevel]
	self.beforeFriendshipCfg = FriendshipLevelData[beforeLevel]

	local beforeLevelIcon = self.beforeFriendshipCfg and self.beforeFriendshipCfg.levelIcon or ""
	local afterLevelIcon = self.friendshipCfg and self.friendshipCfg.levelIcon or ""

	self.view.iconLikabilityBeforeUImage.url = beforeLevelIcon
	self.view.iconLikabilityAfterUImage.url = afterLevelIcon

	ClientTextUtils.setText(self.view.txtMyNameUBaseText, pg.me.playerName)
	ClientTextUtils.setText(self.view.txtMyNameChangeUSDFText, pg.me.playerName)
	ClientTextUtils.setText(self.view.myNameCoverUSDFText, pg.me.playerName)

	local friendName = self.playerInfo.playerName or ""
	local _h = FriendshipUpCtrl._platformHooks

	friendName = _h and _h.initUI and _h.initUI(self, friendName) or friendName

	ClientTextUtils.setText(self.view.txtFriendNameUBaseText, friendName)
	ClientTextUtils.setText(self.view.txtFriendNameChangeUSDFText, friendName)
	ClientTextUtils.setText(self.view.friendNameCoverUSDFText, friendName)

	local tip = ""

	if self.friendshipCfg then
		tip = pg.getFormatText(pg.getLocalizationText(self.friendshipCfg.levelUpTip), friendName)
	end

	if self.isVariant then
		tip = pg.getFormatText(pg.getGameString("CHANGE_FRIEND_TIP"), friendName)

		self.view.uIPopLikabilityUpUComponent:TryChangePage("hideLevel", 1)
		ClientTextUtils.setText(self.view.openBtnTextUText, pg.getGameString("OPEN_FRIEND_CARD"))
	else
		self.view.uIPopLikabilityUpUComponent:TryChangePage("hideLevel", 0)
	end

	ClientTextUtils.setText(self.view.txtTipsUBaseText, tip)
	self:setModels()
end

function FriendshipUpCtrl:setModels()
	local entityInfo = {}
	local friendshipCfg = self.friendshipCfg or {}
	local selfPos = self.param.selfPos
	local friendPos = self.param.friendPos

	if selfPos == nil or friendPos == nil then
		local friendPresetKey = self.playerInfo.avatarPresetKey
		local cfgSelfPos, cfgFriendPos = self:getModelPosition(friendshipCfg, friendPresetKey)

		selfPos = selfPos or cfgSelfPos
		friendPos = friendPos or cfgFriendPos
	end

	entityInfo[pg.me.uid] = {
		pos = selfPos,
		ani = friendshipCfg.myAction,
		aniFrame = friendshipCfg.myActionFrame
	}
	entityInfo[self.playerId] = {
		pos = friendPos,
		ani = friendshipCfg.friendAction,
		aniFrame = friendshipCfg.friendActionFrame,
		avatarConfig = self.playerInfo.avatarConfig,
		curShow = self.playerInfo.curShow,
		avatarPresetKey = self.playerInfo.avatarPresetKey
	}

	self.uiScene:showPlayerEntity(entityInfo, true)
	self.uiScene:setRawImageProRef(self.view.rawImageURawImage)
end

function FriendshipUpCtrl:getModelPosition(cfgData, playerAvatarPresetKey)
	local animParams = cfgData.animParams
	local combinationType

	if animParams ~= nil then
		local selfGender = pg.me:getTemplateData().gender
		local selfGenderCode = selfGender == Const.GENDER_TYPE_FEMALE and 1 or 2
		local friendGender = pg.game.avatar:getGenderByPresetKey(playerAvatarPresetKey)
		local friendGenderCode = friendGender == Const.GENDER_TYPE_FEMALE and 1 or 2

		combinationType = selfGenderCode * 10 + friendGenderCode
	end

	if combinationType ~= nil then
		for _, animData in ipairs(animParams) do
			local selfAnim = animData[1]

			if selfAnim[4] == combinationType then
				return selfAnim, animData[2]
			end
		end
	end

	return cfgData.myActionLocal or {
		0.2,
		0,
		0
	}, cfgData.friendActionLocal or {
		-0.2,
		0,
		0
	}
end

function FriendshipUpCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function FriendshipUpCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function FriendshipUpCtrl:onShow()
	return
end

function FriendshipUpCtrl:onHide()
	return
end

return FriendshipUpCtrl
