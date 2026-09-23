-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\PlatformUtils.lua

local PlatformUtils = {}

PlatformUtils.Family = {
	Steam = "steam",
	PlayStation = "playstation",
	Xbox = "xbox",
	Other = "other",
	Ios = "ios",
	Android = "android",
	Pc = "pc",
	XHH = "xiaoheihe",
	Epic = "epic"
}
PlatformUtils.UnknownFamily = "unknown"

local FAMILY = PlatformUtils.Family

function PlatformUtils.isNilOrEmpty(value)
	if string.isNilOrEmpty then
		return string.isNilOrEmpty(value)
	end

	return value == nil or value == ""
end

function PlatformUtils.isMissingIdentityField(fieldName, value)
	if fieldName == "isAllowedCrossPlatform" then
		return value == nil
	end

	return PlatformUtils.isNilOrEmpty(value)
end

function PlatformUtils.getIdentityField(source, fieldName)
	if source == nil then
		return nil
	end

	local success, value = pcall(function()
		return source[fieldName]
	end)

	if not success then
		return nil
	end

	return value
end

function PlatformUtils.setIdentityField(target, fieldName, value)
	if target == nil then
		return false
	end

	local success = pcall(function()
		target[fieldName] = value
	end)

	return success == true
end

function PlatformUtils.normalizeStringFamily(value)
	if type(value) ~= "string" then
		return nil
	end

	local lowered = string.lower(value)

	if lowered == FAMILY.Xbox then
		return FAMILY.Xbox
	end

	if lowered == FAMILY.PlayStation then
		return FAMILY.PlayStation
	end

	if lowered == FAMILY.Pc then
		return FAMILY.Pc
	end

	if lowered == FAMILY.Android then
		return FAMILY.Android
	end

	if lowered == FAMILY.Ios then
		return FAMILY.Ios
	end

	if lowered == FAMILY.Other then
		return FAMILY.Other
	end

	return nil
end

function PlatformUtils.normalizeFamily(value)
	return PlatformUtils.normalizeStringFamily(value)
end

function PlatformUtils.resolveRawPlatformFamily(platform)
	platform = tostring(platform or "")

	local canonicalFamily = PlatformUtils.normalizeFamily(platform)

	if canonicalFamily then
		return canonicalFamily
	end

	if platform == "GameCoreXboxOne" or platform == "GameCoreXboxSeries" or platform == "XboxOne" then
		return FAMILY.Xbox
	end

	if platform == "PS4" or platform == "PS5" then
		return FAMILY.PlayStation
	end

	if platform == "WindowsPlayer" or platform == "WindowsEditor" or platform == "OSXPlayer" or platform == "OSXEditor" or platform == "LinuxPlayer" or platform == "LinuxEditor" then
		return FAMILY.Pc
	end

	if platform == "Android" then
		return FAMILY.Android
	end

	if platform == "IPhonePlayer" then
		return FAMILY.Ios
	end

	return FAMILY.Other
end

function PlatformUtils.isConsoleFamily(family)
	return family == FAMILY.Xbox or family == FAMILY.PlayStation
end

function PlatformUtils.resolvePlayerIdentity(playerInfo)
	if playerInfo == nil then
		return {}
	end

	local legacyInfo = PlatformUtils.getIdentityField(playerInfo, "platformInfo")
	local isAllowedCrossPlatform = PlatformUtils.getIdentityField(playerInfo, "isAllowedCrossPlatform")

	if isAllowedCrossPlatform == nil then
		isAllowedCrossPlatform = PlatformUtils.getIdentityField(legacyInfo, "isAllowedCrossPlatform")
	end

	local isPlatformFriend = PlatformUtils.getIdentityField(playerInfo, "isPlatformFriend")

	if isPlatformFriend == nil then
		isPlatformFriend = PlatformUtils.getIdentityField(legacyInfo, "isPlatformFriend")
	end

	local platformUserId = PlatformUtils.getIdentityField(playerInfo, "platformUserId")

	if platformUserId == nil then
		platformUserId = PlatformUtils.getIdentityField(legacyInfo, "platformUserId")
	end

	local platformFamily = PlatformUtils.getIdentityField(playerInfo, "platformFamily")

	if platformFamily == nil then
		platformFamily = PlatformUtils.getIdentityField(legacyInfo, "platformFamily")
	end

	local platformDisplayName = PlatformUtils.getIdentityField(playerInfo, "platformDisplayName")

	if platformDisplayName == nil then
		platformDisplayName = PlatformUtils.getIdentityField(legacyInfo, "platformDisplayName")
	end

	local platform = PlatformUtils.getIdentityField(playerInfo, "platform")

	if platform == nil then
		platform = PlatformUtils.getIdentityField(legacyInfo, "platform")
	end

	local os = PlatformUtils.getIdentityField(playerInfo, "os")

	if os == nil then
		os = PlatformUtils.getIdentityField(legacyInfo, "os")
	end

	local platformUGCSwitch = PlatformUtils.getIdentityField(playerInfo, "platformUGCSwitch")

	if platformUGCSwitch == nil then
		platformUGCSwitch = PlatformUtils.getIdentityField(legacyInfo, "platformUGCSwitch")
	end

	return {
		platformUserId = platformUserId,
		platformFamily = platformFamily,
		platformDisplayName = platformDisplayName,
		platform = platform,
		os = os,
		isPlatformFriend = isPlatformFriend,
		isAllowedCrossPlatform = isAllowedCrossPlatform,
		platformUGCSwitch = platformUGCSwitch
	}
end

PlatformUtils.PlatformIdentityAttributes = {
	"platformUserId",
	"platformFamily",
	"platformDisplayName",
	"platform",
	"os",
	"isAllowedCrossPlatform",
	"platformUGCSwitch"
}

function PlatformUtils.appendPlatformIdentityAttributes(attributes)
	if type(attributes) ~= "table" then
		attributes = {}
	end

	for _, attributeName in ipairs(PlatformUtils.PlatformIdentityAttributes) do
		attributes[#attributes + 1] = attributeName
	end

	return attributes
end

function PlatformUtils.buildPlayerInfoFromAttributes(attr)
	if attr == nil then
		return {}
	end

	return {
		platformUserId = PlatformUtils.getIdentityField(attr, "platformUserId"),
		platformFamily = PlatformUtils.getIdentityField(attr, "platformFamily"),
		platformDisplayName = PlatformUtils.getIdentityField(attr, "platformDisplayName"),
		platform = PlatformUtils.getIdentityField(attr, "platform"),
		os = PlatformUtils.getIdentityField(attr, "os"),
		isAllowedCrossPlatform = PlatformUtils.getIdentityField(attr, "isAllowedCrossPlatform"),
		platformUGCSwitch = PlatformUtils.getIdentityField(attr, "platformUGCSwitch")
	}
end

function PlatformUtils.fillMissingFlatIdentityFields(target, fallback)
	if target == nil or fallback == nil then
		return target
	end

	local identity = PlatformUtils.resolvePlayerIdentity(fallback)

	for _, fieldName in ipairs(PlatformUtils.PlatformIdentityAttributes) do
		if PlatformUtils.isMissingIdentityField(fieldName, PlatformUtils.getIdentityField(target, fieldName)) and not PlatformUtils.isMissingIdentityField(fieldName, identity[fieldName]) then
			PlatformUtils.setIdentityField(target, fieldName, identity[fieldName])
		end
	end

	return target
end

function PlatformUtils.normalizeAllowCrossNetwork(playerInfo)
	if playerInfo == nil then
		return true
	end

	local identity = PlatformUtils.resolvePlayerIdentity(playerInfo)

	return identity.isAllowedCrossPlatform ~= false
end

function PlatformUtils.normalizePlatformFamily(playerInfo)
	if playerInfo == nil then
		return ""
	end

	local identity = PlatformUtils.resolvePlayerIdentity(playerInfo)

	return tostring(PlatformUtils.normalizeFamily(identity.platformFamily) or "")
end

function PlatformUtils.isCrossNetworkCompatible(leftInfo, rightInfo)
	local leftAllow = PlatformUtils.normalizeAllowCrossNetwork(leftInfo)
	local rightAllow = PlatformUtils.normalizeAllowCrossNetwork(rightInfo)

	if leftAllow ~= rightAllow then
		return false
	end

	if leftAllow == false then
		return PlatformUtils.normalizePlatformFamily(leftInfo) == PlatformUtils.normalizePlatformFamily(rightInfo)
	end

	return true
end

function PlatformUtils.resolvePlayerInfoFamily(playerInfo)
	if playerInfo == nil then
		return nil
	end

	local identity = PlatformUtils.resolvePlayerIdentity(playerInfo)

	return PlatformUtils.normalizeFamily(identity.platformFamily)
end

function PlatformUtils.resolvePlatformUserId(playerInfo)
	if playerInfo == nil then
		return nil
	end

	local identity = PlatformUtils.resolvePlayerIdentity(playerInfo)
	local platformUserId = identity.platformUserId

	if PlatformUtils.isNilOrEmpty(platformUserId) then
		return nil
	end

	return tostring(platformUserId)
end

function PlatformUtils.hasPlatformUserId(playerInfo)
	return PlatformUtils.resolvePlatformUserId(playerInfo) ~= nil
end

function PlatformUtils.isPlatformFriend(playerInfo)
	if playerInfo == nil then
		return false
	end

	local identity = PlatformUtils.resolvePlayerIdentity(playerInfo)

	return identity.isPlatformFriend == true
end

function PlatformUtils.getCurrentRawPlatform()
	if not pg or not pg.global or not pg.global.platform then
		return ""
	end

	local platform = pg.global.platform

	if type(platform.getRaw) ~= "function" then
		return ""
	end

	local raw = platform:getRaw()

	if PlatformUtils.isNilOrEmpty(raw) then
		return ""
	end

	return raw
end

function PlatformUtils.resolvePlayerPlatform(playerInfo)
	local identity = PlatformUtils.resolvePlayerIdentity(playerInfo)

	if not PlatformUtils.isNilOrEmpty(identity.platform) then
		return tostring(identity.platform)
	end

	if not PlatformUtils.isNilOrEmpty(identity.os) then
		return tostring(identity.os)
	end

	local rawPlatform = PlatformUtils.getCurrentRawPlatform()

	if PlatformUtils.isNilOrEmpty(rawPlatform) then
		return ""
	end

	return tostring(rawPlatform)
end

function PlatformUtils.resolvePlayerOs(playerInfo)
	local identity = PlatformUtils.resolvePlayerIdentity(playerInfo)

	if not PlatformUtils.isNilOrEmpty(identity.os) then
		return tostring(identity.os)
	end

	return PlatformUtils.resolvePlayerPlatform(playerInfo)
end

return PlatformUtils
