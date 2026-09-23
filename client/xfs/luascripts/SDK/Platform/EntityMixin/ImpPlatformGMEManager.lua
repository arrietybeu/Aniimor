-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\EntityMixin\\ImpPlatformGMEManager.lua

local M = {}
local PlatformCommunicationService = require("SDK.Platform.PlatformCommunicationService")

function M:StartRecording()
	if PlatformCommunicationService:isLocalCommunicationBlocked(PlatformCommunicationService.Channel.Voice) then
		PlatformCommunicationService:notifyOutgoingCommunicationDenied(PlatformCommunicationService.Channel.Voice, "voice_record_start", {
			notifyUser = true,
			deniedTipKey = "PLATFORM_SOCIAL_VOICE_PRIVILEGE_DENIED"
		})

		return true
	end

	return false
end

function M:UploadRecordedFile(filePath)
	if PlatformCommunicationService:isLocalCommunicationBlocked(PlatformCommunicationService.Channel.Voice) then
		PlatformCommunicationService:notifyOutgoingCommunicationDenied(PlatformCommunicationService.Channel.Voice, "voice_upload", {
			notifyUser = true,
			deniedTipKey = "PLATFORM_SOCIAL_VOICE_PRIVILEGE_DENIED"
		})

		return true
	end

	return false
end

return M
