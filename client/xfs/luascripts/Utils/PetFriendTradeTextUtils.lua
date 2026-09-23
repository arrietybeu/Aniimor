-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\PetFriendTradeTextUtils.lua

local Const = require("Common.Const.Const")
local PetFriendTradeUtils = require("Common.Utils.PetFriendTradeUtils")
local LimitData = require("Data.limit_data")
local PetFriendTradeTextUtils = {}

function PetFriendTradeTextUtils.getExchangeLimitExceededTip(useLimitMap, petInfo, pedd, friendshipLevel, isCredentialKnown)
	local _, limitId, credentialTier, isCredentialLimit = PetFriendTradeUtils.checkExchangeLimit(useLimitMap, petInfo, pedd, friendshipLevel, isCredentialKnown)

	if not isCredentialLimit then
		return pg.getGameString("NO_CHANGE_ATTEMPTS")
	end

	return PetFriendTradeTextUtils.getExchangeLimitExceededText(limitId, credentialTier)
end

function PetFriendTradeTextUtils.getExchangeLimitExceededText(limitId, credentialTier)
	local limitType = LimitData[limitId].type
	local limitTypeText = pg.getGameString(Const.LimitType2TextKeyMap[limitType])

	return pg.getFormatText(pg.getGameString("FRIEND_PET_EXCHANGE_LIMIT_EXCEEDED"), credentialTier, limitTypeText)
end

function PetFriendTradeTextUtils.getGiveLimitExceededTip(useLimitMap, petInfo, pedd, friendshipLevel, isCredentialKnown)
	local _, limitId, credentialTier, isCredentialLimit = PetFriendTradeUtils.checkGiveLimit(useLimitMap, petInfo, pedd, friendshipLevel, isCredentialKnown)

	if not isCredentialLimit then
		local textKey = Const.FollowGivePetNotify[Const.FollowGivePetError.EPRR_LIMIT_EXCEED]

		return pg.getGameString(textKey), false
	end

	return PetFriendTradeTextUtils.getGiveLimitExceededText(limitId, credentialTier), true
end

function PetFriendTradeTextUtils.getGiveLimitExceededText(limitId, credentialTier)
	local limitType = LimitData[limitId].type
	local limitTypeText = pg.getGameString(Const.LimitType2TextKeyMap[limitType])

	return pg.getFormatText(pg.getGameString("FRIEND_PET_GIVE_LIMIT_EXCEEDED"), credentialTier, limitTypeText)
end

return PetFriendTradeTextUtils
