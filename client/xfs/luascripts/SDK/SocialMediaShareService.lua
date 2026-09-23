-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\SocialMediaShareService.lua

local Utils = require("Common.Utils.Utils")
local SocialMediaShareData = require("Data.social_media_share_data")
local CONFIG_TYPE = {
	Image = 1
}
local CONFIG_PLATFORM = {
	Xbox = 4,
	PlayStation = 3,
	PC = 2,
	Mobile = 1
}
local configCache = {}
local SocialMediaShareService = {
	ConfigType = CONFIG_TYPE
}

function SocialMediaShareService.getCurrentConfig(configType)
	return SocialMediaShareService.getConfig(configType, SocialMediaShareService.getCurrentConfigPlatform(), Utils.getServerArea())
end

function SocialMediaShareService.getConfig(configType, configPlatform, area)
	local cachedConfigId = configCache[configType]
	local cachedConfig, isSameShareType, isSamePlatform, isSameArea

	if cachedConfigId then
		cachedConfig = SocialMediaShareData[cachedConfigId]
		isSameShareType = cachedConfig.shareType == configType
		isSamePlatform = cachedConfig.platform == configPlatform
		isSameArea = cachedConfig.area == area

		if isSameShareType and isSamePlatform and isSameArea then
			return cachedConfig
		end
	end

	for configId, shareConfig in pairs(SocialMediaShareData) do
		isSameShareType = shareConfig.shareType == configType
		isSamePlatform = shareConfig.platform == configPlatform
		isSameArea = shareConfig.area == area

		if isSameShareType and isSamePlatform and isSameArea then
			configCache[configType] = configId

			return shareConfig
		end
	end

	configCache[configType] = nil
end

function SocialMediaShareService.getCurrentConfigPlatform()
	local platform = pg.global.platform

	if platform:isMobile() then
		return CONFIG_PLATFORM.Mobile
	end

	if platform:isPC() then
		return CONFIG_PLATFORM.PC
	end

	if platform:isPS() then
		return CONFIG_PLATFORM.PlayStation
	end

	if platform:isXbox() or platform:isXboxPC() then
		return CONFIG_PLATFORM.Xbox
	end
end

return SocialMediaShareService
