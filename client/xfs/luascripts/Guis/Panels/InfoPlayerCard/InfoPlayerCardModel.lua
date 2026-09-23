-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\InfoPlayerCard\\InfoPlayerCardModel.lua

local UIModel = require("Guis.UIModel")
local Class = require("Core.Framework.Class")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local InfoPlayerCardModel = Class.LightClass("InfoPlayerCardModel", UIModel)
local logger = LoggerManager.getLogger("InfoPlayerCardModel")
local ClientConst = require("Const.ClientConst")
local InfoCardBtnData = require("Data.player_info_card_btn_data")
local InfoCardFunData = require("Data.player_info_card_fun_data")
local EntityManager = require("Core.Common.EntityManager")
local FriendshipLevelData = require("Data.friendship_level_data")
local AvatarPresetData = require("Data.avatar_preset_data")
local RedDotConst = require("Const.RedDotConst")
local CommonSwitch = require("Common.CommonSwitch")
local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")
local VARIANT_FRIEND_RANK = -2
local TILLABLE_HOME_RANK = -1
local BTN_CONFIG_ID_BY_OPEN_TYPE = {
	[ClientConst.PlayerInfoOpenType.Chat] = 1,
	[ClientConst.PlayerInfoOpenType.FaceToFace] = 2,
	[ClientConst.PlayerInfoOpenType.PlayerGhost] = 3,
	[ClientConst.PlayerInfoOpenType.Rank] = 4
}

function InfoPlayerCardModel:ctor()
	self:init()

	self.playerInfo = {}
end

function InfoPlayerCardModel:init()
	return
end

function InfoPlayerCardModel:setPlayerInfo(playerInfo)
	self.playerInfo = playerInfo
	self.playerInfo.isFriend = pg.game.chat:checkFriendList(self.playerInfo.uid)

	if type(self.playerInfo.curShow) == "string" then
		if string.isNilOrEmpty(self.playerInfo.curShow) then
			self.playerInfo.curShow = nil
		else
			self.playerInfo.curShow = string.toTable(decompressFromStr(self.playerInfo.curShow))
		end
	end

	local presetData = pg.game.avatar:getAvatarPresetData(self.playerInfo.avatarPresetKey) or {}

	self.playerInfo.templateId = presetData.templateId or 0
end

function InfoPlayerCardModel:getPlayerInfo()
	return self.playerInfo
end

function InfoPlayerCardModel:setSpaceFollowLeader(myLeader, friendLeader)
	self.myLeader = myLeader
	self.friendLeader = friendLeader
end

function InfoPlayerCardModel:getBtnList(openType, isFaceToFaceList)
	local index = BTN_CONFIG_ID_BY_OPEN_TYPE[openType] or 1
	local config = InfoCardBtnData[index]

	if not config then
		return {}
	end

	return self:getBtnListConfig(config.showFuncId, openType, isFaceToFaceList)
end

function InfoPlayerCardModel:_checkCanShowBtn(funConfig, openType, isFaceToFaceList)
	local openTypeShow = isFaceToFaceList and funConfig.onlyFaceToFace == 1 or not isFaceToFaceList and funConfig.onlyFaceToFace ~= 1

	if not openTypeShow then
		return false
	end

	local sceneTypeLimit = funConfig.sceneTypeLimit

	if sceneTypeLimit and next(sceneTypeLimit) then
		local spaceType = pg.me and pg.me.space and pg.me.space.spaceType

		if not table.contains(sceneTypeLimit, spaceType) then
			return false
		end
	end

	return funConfig.checkFunc == nil or self[funConfig.checkFunc](self, funConfig, openType)
end

function InfoPlayerCardModel:getBtnListConfig(ids, openType, isFaceToFaceList)
	local tempList = {}
	local validKeys = {
		name = true,
		checkCommonSwitch = true,
		checkFunc = true,
		icon = true,
		label = true,
		rank = true,
		responseFunc = true,
		onlyFaceToFace = false
	}
	local showFuncIds = string.toTable(ids) or {}

	for _, id in ipairs(showFuncIds) do
		local funConfig = InfoCardFunData[id]

		if not funConfig then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("PlayerInfoCardFunData is missing, functionId=%s, skipped", id)
			end
		elseif self:_checkCanShowBtn(funConfig, openType, isFaceToFaceList) then
			local temp = {}

			for k in pairs(validKeys) do
				if funConfig[k] ~= nil then
					temp[k] = funConfig[k]
				end
			end

			self:_applyInteractItemOverrides(temp)

			tempList[#tempList + 1] = temp

			if openType == ClientConst.PlayerInfoOpenType.Edit or self.playerInfo.uid == pg.me.uid then
				return tempList
			end
		end
	end

	table.sort(tempList, function(a, b)
		return a.rank < b.rank
	end)

	return tempList
end

function InfoPlayerCardModel:_applyInteractItemOverrides(data)
	if data.responseFunc == "openFriendTree" then
		local friendshipLevel = pg.game.chat:getFriendship(self.playerInfo.uid)

		data.icon = FriendshipLevelData[friendshipLevel].levelIconOnly
	elseif data.responseFunc == "platformProfile" then
		local icon, iconColor = self:_getPlatformProfileIcon()

		data.icon = icon

		if iconColor then
			data.iconColor = iconColor
		end
	elseif data.responseFunc == "inviteTeamFollow" then
		data.overrideState = 2
	elseif data.responseFunc == "joinTeamFollow" then
		data.overrideState = 3
	elseif data.responseFunc == "petVariantInteract" then
		local variantFriendUid = pg.game.chat:getSpecialFriendUId()

		data.isVariantFriend = tostring(variantFriendUid) == tostring(self.playerInfo.uid)

		if data.isVariantFriend then
			data.rank = VARIANT_FRIEND_RANK
		end
	elseif data.responseFunc == "visitHome" then
		data.homelandHasTillableFacility = self.playerInfo.homelandHasTillableFacility == true

		if data.homelandHasTillableFacility then
			data.rank = TILLABLE_HOME_RANK
		end
	end
end

function InfoPlayerCardModel:_getPlatformProfileIcon()
	local family = PlatformIdentityUtils.resolvePlayerInfoFamily(self.playerInfo) or PlatformIdentityUtils.getCurrentPlatformFamily()
	local normalized = PlatformIdentityUtils.normalizeFamily(family)

	if normalized == PlatformIdentityUtils.Family.Xbox then
		return "$UI_Img_PlayerInfoCard_IconXbox.png"
	elseif normalized == PlatformIdentityUtils.Family.PlayStation then
		return "$UI_CharID_PS.png", "#FFFFFFFF"
	end

	return ""
end

function InfoPlayerCardModel:checkPlatformProfileCard()
	if not CS.FunPlus.WorldX.SDK.Platform.PlatformBridgeLuaFacade.SupportsShowPlayerProfileCard() then
		return false
	end

	if not PlatformIdentityUtils.hasPlatformUserId(self.playerInfo) then
		return false
	end

	local targetFamily = PlatformIdentityUtils.resolvePlayerInfoFamily(self.playerInfo)

	if not PlatformIdentityUtils.isConsoleFamily(targetFamily) then
		return false
	end

	return targetFamily == PlatformIdentityUtils.getCurrentPlatformFamily()
end

function InfoPlayerCardModel:checkNoFriendState()
	return not pg.game.chat:checkFriendList(tostring(self.playerInfo.uid))
end

function InfoPlayerCardModel:checkCanChangeFriendGroup()
	return self:checkFriendState() or self:checkOutblacklist()
end

function InfoPlayerCardModel:checkTeamup()
	return pg.me:isUidTeamMember(tostring(self.playerInfo.uid)) and pg.me:isUidTeamLeader(tostring(self.playerInfo.uid)) and not pg.me.inLeaderWorld
end

function InfoPlayerCardModel:checkSameWorld()
	return pg.me:isInTeam() and pg.me.inLeaderWorld
end

function InfoPlayerCardModel:checkCanComeToPlayer()
	local playerId = self.playerInfo.uid

	if playerId == pg.me.uid then
		return false
	end

	local ent = pg.getEntityByUid(playerId)

	return ent ~= nil or pg.me:isUidTeamLeader(playerId)
end

function InfoPlayerCardModel:checkinsameworld(funConfig, openType)
	local isHasHome = false
	local isRemoteSource = openType == ClientConst.PlayerInfoOpenType.Chat or openType == ClientConst.PlayerInfoOpenType.Rank

	if isRemoteSource then
		isHasHome = self.playerInfo.homelandKey
	elseif openType == ClientConst.PlayerInfoOpenType.MobFaceToFace or openType == ClientConst.PlayerInfoOpenType.FaceToFace then
		local ent = EntityManager.getEntityByUid(self.playerInfo.uid)

		if ent then
			isHasHome = ent.isHomelandCreate
		end
	end

	return isHasHome
end

function InfoPlayerCardModel:checkFriendState()
	return pg.game.chat:checkFriendList(tostring(self.playerInfo.uid))
end

function InfoPlayerCardModel:checkOutblacklist()
	return pg.game.chat:checkBlackList(tostring(self.playerInfo.uid))
end

function InfoPlayerCardModel:checkInBlacklist()
	return not pg.game.chat:checkBlackList(tostring(self.playerInfo.uid))
end

function InfoPlayerCardModel:checkCanJoinTeamFollow()
	return not self.myLeader
end

function InfoPlayerCardModel:checkCanInviteTeamFollow()
	return not self.friendLeader and (not self.myLeader or self.myLeader == pg.me.uid) and pg.me.uid ~= self.playerInfo.uid
end

function InfoPlayerCardModel:checkCanOpenEmoticonPanel()
	return true
end

function InfoPlayerCardModel:checkCanKickTeamFollow()
	return self.friendLeader == pg.me.uid
end

function InfoPlayerCardModel:checkCanQuitTeamFollow()
	if not string.isNilOrEmpty(self.myLeader) and not string.isNilOrEmpty(self.friendLeader) and self.myLeader == self.friendLeader then
		return true
	end

	return false
end

function InfoPlayerCardModel:redDot_getFriendIntimacyState()
	local _levelCache = pg.global.prefsCacheUtils:getInt(pg.me.uid .. ClientConst.PrefKey.FriendshipLevel .. self.playerInfo.uid, 0)
	local curLevel = pg.game.chat:getFriendship(self.playerInfo.uid)

	if _levelCache < curLevel then
		return RedDotConst.RedDotStyle.UP_SIGN
	end

	return RedDotConst.RedDotStyle.NONE
end

return InfoPlayerCardModel
