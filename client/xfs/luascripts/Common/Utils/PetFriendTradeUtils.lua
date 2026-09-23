-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\PetFriendTradeUtils.lua

local BaseProperty = require("CustomTypes.BaseProperty")
local GivePetData = require("Data.send_pet_data")
local SysConfigData = require("Data.sys_config_data")
local PetFriendTradeUtils = {}
local CHANGE_LIMIT_KEY_FORMAT = "CHANGE_LIMIT_%d"
local GIVE_PETS_LIMIT_KEY_FORMAT = "GIVE_PETS_LIMIT_%d"

local function getCredentialTier(petInfo, pedd, friendshipLevel, isCredentialKnown)
	if not isCredentialKnown then
		return nil
	end

	local actualMaxCredential = 0

	for _, baseProperty in ipairs(petInfo.basePropertyList) do
		local credential = BaseProperty.getBaseIndividualLevel(baseProperty, true, true)

		actualMaxCredential = math.max(actualMaxCredential, credential)
	end

	for requiredFriendshipLevel = 1, friendshipLevel do
		local credential = pedd.credential[requiredFriendshipLevel]

		if actualMaxCredential == credential then
			return credential
		end
	end

	return nil
end

local function getLimitInfo(petInfo, pedd, friendshipLevel, isCredentialKnown, limitKeyFormat, fallbackLimitId)
	local credentialTier = getCredentialTier(petInfo, pedd, friendshipLevel, isCredentialKnown)

	if not credentialTier then
		return fallbackLimitId, nil, false
	end

	local limitConfigKey = string.format(limitKeyFormat, credentialTier)
	local credentialLimitId = SysConfigData[limitConfigKey]

	if not credentialLimitId then
		return fallbackLimitId, credentialTier, false
	end

	return credentialLimitId, credentialTier, true
end

local function getEffectiveLimitInfo(useLimitMap, petInfo, pedd, friendshipLevel, isCredentialKnown, limitKeyFormat, defaultLimitId)
	local limitId, credentialTier, isCredentialLimit = getLimitInfo(petInfo, pedd, friendshipLevel, isCredentialKnown, limitKeyFormat, defaultLimitId)

	if not isCredentialLimit then
		return limitId, credentialTier, false
	end

	local defaultTotalCount = useLimitMap:getTotalCount(defaultLimitId)
	local credentialTotalCount = useLimitMap:getTotalCount(limitId)

	if defaultTotalCount < credentialTotalCount then
		return defaultLimitId, credentialTier, false
	end

	return limitId, credentialTier, true
end

local function getDisplayLimitId(useLimitMap, petInfo, pedd, friendshipLevel, isCredentialKnown, limitKeyFormat, defaultLimitId)
	if not useLimitMap:testLimit(defaultLimitId) then
		return defaultLimitId
	end

	local limitId = getEffectiveLimitInfo(useLimitMap, petInfo, pedd, friendshipLevel, isCredentialKnown, limitKeyFormat, defaultLimitId)

	return limitId
end

local function checkLimit(useLimitMap, petInfo, pedd, friendshipLevel, isCredentialKnown, limitKeyFormat, defaultLimitId)
	if not useLimitMap:testLimit(defaultLimitId) then
		return false, defaultLimitId, nil, false
	end

	local limitId, credentialTier, isCredentialLimit = getEffectiveLimitInfo(useLimitMap, petInfo, pedd, friendshipLevel, isCredentialKnown, limitKeyFormat, defaultLimitId)

	if isCredentialLimit and not useLimitMap:testLimit(limitId) then
		return false, limitId, credentialTier, true
	end

	return true, limitId, credentialTier, isCredentialLimit
end

function PetFriendTradeUtils.getExchangeDefaultLimitId()
	return SysConfigData.CHANGE_PETS_DAILY_LIMIT
end

function PetFriendTradeUtils.getExchangeLimitId(useLimitMap, petInfo, pedd, friendshipLevel, isCredentialKnown)
	return getDisplayLimitId(useLimitMap, petInfo, pedd, friendshipLevel, isCredentialKnown, CHANGE_LIMIT_KEY_FORMAT, PetFriendTradeUtils.getExchangeDefaultLimitId())
end

function PetFriendTradeUtils.checkExchangeLimit(useLimitMap, petInfo, pedd, friendshipLevel, isCredentialKnown)
	return checkLimit(useLimitMap, petInfo, pedd, friendshipLevel, isCredentialKnown, CHANGE_LIMIT_KEY_FORMAT, PetFriendTradeUtils.getExchangeDefaultLimitId())
end

function PetFriendTradeUtils.getGiveDefaultLimitId()
	return GivePetData[1].limitId
end

function PetFriendTradeUtils.checkGiveLimit(useLimitMap, petInfo, pedd, friendshipLevel, isCredentialKnown)
	return checkLimit(useLimitMap, petInfo, pedd, friendshipLevel, isCredentialKnown, GIVE_PETS_LIMIT_KEY_FORMAT, pedd.limitId)
end

return PetFriendTradeUtils
