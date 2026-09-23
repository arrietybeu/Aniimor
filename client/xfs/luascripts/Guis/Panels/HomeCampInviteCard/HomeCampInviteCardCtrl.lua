-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeCampInviteCard\\HomeCampInviteCardCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomeCampInviteCardCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Utils = require("Common.Utils.Utils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local HomeCampInviteCardCtrl = Class.LightClass("HomeCampInviteCardCtrl", UICtrl)
local HomeCampData = require("Data.home_camp_data")
local NoticeDef = require("Common.NoticeDef")

HomeCampInviteCardCtrl.messages = {}

function HomeCampInviteCardCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function HomeCampInviteCardCtrl:addListener()
	function self.view.closeBtn.luaClick()
		self:close()
	end

	function self.view.acceptBtn.luaClick()
		self:onAcceptBtnClick(self.inviteInfo.inviteId)
		self:close()
	end
end

function HomeCampInviteCardCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function HomeCampInviteCardCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.inviteInfo = info or {}

	self:refreshInviteInfo()
end

function HomeCampInviteCardCtrl:onShow()
	return
end

function HomeCampInviteCardCtrl:onHide()
	return
end

function HomeCampInviteCardCtrl:onAcceptBtnClick(inviteId)
	local homeCampInfo = pg.me:getPlayerHomeCampInfo()
	local campLineInfo = homeCampInfo.lineInfo or {}

	if campLineInfo.isPrivate then
		pg.global.showBubbleMessage(NoticeDef.HOME_CAMP_INVITE_ALREADY_IN_CAMP)

		return false
	end

	local ownerUid = self.inviteInfo and self.inviteInfo.playerId

	if ownerUid then
		pg.me:queryPlayerInfoList({
			tostring(ownerUid)
		}, pg.game.chat.queryPlayerInfoType.ShowPlayerInfo, true, nil, function()
			pg.me:acceptCampInvite(inviteId, ownerUid)
		end)

		return true
	end

	return pg.me:acceptCampInvite(inviteId, ownerUid)
end

function HomeCampInviteCardCtrl:refreshInviteInfo()
	ClientTextUtils.setText(self.view.textName, pg.getFormatText(pg.getGameString("HOME_CAMP_INVITE_TITLE"), pg.me.playerName))

	local senderInfo = pg.game.chat:getPlayerInfo(tostring(self.inviteInfo.playerId))

	ClientTextUtils.setText(self.view.sendName, pg.getFormatText("<style=Hint_BgL>{0}</style>", LuaUIUtils.getPlayerDisplayName(tostring(self.inviteInfo.playerId), senderInfo.playerName, true)))
	ClientTextUtils.setText(self.view.textID, self.inviteInfo.campUid)

	local _, _, sceneId, lineId = Utils.parseSpaceInstanceServiceKey(self.inviteInfo.campKey)
	local staticId = HomeLandUtils.getHomeCampStaticId(sceneId)
	local campInfo = HomeCampData[staticId] or {}
	local desc = pg.getFormatText(pg.getGameString("HOME_CAMP_INVITE_DESC"), pg.getLocalizationText(campInfo.name))

	ClientTextUtils.setText(self.view.textDetails, desc)
	ClientTextUtils.setText(self.view.textTitle, pg.getGameString("CAMP_INVITATION"))
	ClientTextUtils.setText(self.view.inviteHint, pg.getGameString("CAMP_INVITE_TIP"))
	ClientTextUtils.setText(self.view.acceptBtnText, pg.getGameString("CAMP_INVITE_ACCEPT"))
end

function HomeCampInviteCardCtrl:showOwnerInviteMessage(info)
	self:open(info)
end

function HomeCampInviteCardCtrl:showNormalInviteMessage(info)
	local _, _, sceneId, lineId = Utils.parseSpaceInstanceServiceKey(info.campKey)
	local staticId = HomeLandUtils.getHomeCampStaticId(sceneId)
	local campInfo = HomeCampData[staticId] or {}
	local senderInfo = pg.game.chat:getPlayerInfo(tostring(info.playerId))
	local playerName = LuaUIUtils.getPlayerDisplayName(tostring(info.playerId), senderInfo.playerName, true)
	local desc = pg.getFormatText(pg.getGameString("HOME_CAMP_NORMAL_INVITE_DESC"), playerName or "", pg.getLocalizationText(campInfo.name) or "", info.campUid or "")

	pg.global.showConfirmMsgRaw(pg.getGameString("HOME_CAMP_NORMAL_INVITE_TITLE"), desc, function()
		self:onAcceptBtnClick(info.inviteId)
	end)
end

return HomeCampInviteCardCtrl
