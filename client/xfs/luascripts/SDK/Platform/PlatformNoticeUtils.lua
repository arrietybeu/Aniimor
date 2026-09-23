-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\PlatformNoticeUtils.lua

local NoticeDef = require("Common.NoticeDef")
local SysNoticeData = require("Data.sys_notice_data")
local PlatformNoticeUtils = {}

PlatformNoticeUtils.NOTICE_KEY_ALIAS = {
	PLATFORM_SOCIAL_PUBLIC_CHAT_PRIVILEGE_DENIED = "PRIVACY_SETTING_MISSMATCH",
	PLATFORM_SOCIAL_VOICE_PRIVILEGE_DENIED = "PRIVACY_SETTING_MISSMATCH"
}

function PlatformNoticeUtils.getNoticeId(keyOrId)
	if type(keyOrId) == "number" then
		return keyOrId
	end

	if string.isNilOrEmpty(keyOrId) then
		return nil
	end

	keyOrId = PlatformNoticeUtils.NOTICE_KEY_ALIAS[keyOrId] or keyOrId

	return NoticeDef[keyOrId]
end

function PlatformNoticeUtils.getTextById(noticeId)
	noticeId = PlatformNoticeUtils.getNoticeId(noticeId)

	if noticeId == nil then
		return nil
	end

	local noticeCfg = SysNoticeData and SysNoticeData[noticeId] or nil

	if noticeCfg == nil or string.isNilOrEmpty(noticeCfg.text) then
		return nil
	end

	if pg and pg.getLocalizationText then
		return pg.getLocalizationText(noticeCfg.text)
	end

	return noticeCfg.text
end

function PlatformNoticeUtils.getText(keyOrId)
	return PlatformNoticeUtils.getTextById(PlatformNoticeUtils.getNoticeId(keyOrId))
end

function PlatformNoticeUtils.showTextTipById(noticeId)
	local text = PlatformNoticeUtils.getTextById(noticeId)

	if string.isNilOrEmpty(text) then
		return
	end

	if pg and pg.global and pg.global.ui and pg.global.ui.tips then
		pg.global.ui.tips:showTextTip(text)
	end
end

function PlatformNoticeUtils.showTextTip(keyOrId)
	PlatformNoticeUtils.showTextTipById(PlatformNoticeUtils.getNoticeId(keyOrId))
end

function PlatformNoticeUtils.showBubbleMessageById(noticeId)
	noticeId = PlatformNoticeUtils.getNoticeId(noticeId)

	if noticeId == nil then
		return
	end

	if pg and pg.global and pg.global.showBubbleMessageById then
		pg.global.showBubbleMessageById(noticeId)

		return
	end

	if pg and pg.global and pg.global.showBubbleMessage then
		pg.global.showBubbleMessage(noticeId)

		return
	end

	PlatformNoticeUtils.showTextTipById(noticeId)
end

function PlatformNoticeUtils.showBubbleMessage(keyOrId)
	PlatformNoticeUtils.showBubbleMessageById(PlatformNoticeUtils.getNoticeId(keyOrId))
end

return PlatformNoticeUtils
