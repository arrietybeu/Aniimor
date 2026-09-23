-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\ShowTitleUtils.lua

local Const = require("Common.Const.Const")
local ShowTitleData = require("Data.show_title_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ShowTitleUtils = {}

function ShowTitleUtils.getTitleText(titleId)
	local titleData = titleId and ShowTitleData[titleId]

	return titleData and pg.getLocalizationText(titleData.titleText) or ""
end

function ShowTitleUtils.hasFriendPrefix(showTitleExtra)
	local friendUid = ShowTitleUtils.getFriendPrefixInfo(showTitleExtra)

	return not string.isNilOrEmpty(friendUid)
end

function ShowTitleUtils.getFriendPrefixInfo(showTitleExtra)
	if showTitleExtra == nil then
		return "", ""
	end

	local friendUid = showTitleExtra.friendUid
	local friendName = showTitleExtra.friendName

	return friendUid or "", friendName or ""
end

function ShowTitleUtils.makeFriendPrefixExtra(friendUid, friendName)
	return {
		friendUid = friendUid or "",
		friendName = friendName or ""
	}
end

function ShowTitleUtils.resolveFriendPrefixName(friendUid, rawName)
	local hooks = ShowTitleUtils._platformHooks

	if hooks and hooks.resolveFriendPrefixName then
		return hooks.resolveFriendPrefixName(friendUid, rawName) or rawName or ""
	end

	return rawName or ""
end

function ShowTitleUtils.getPrefixText(showTitles, showTitleExtra, resolvedFriendName)
	local friendUid, friendName = ShowTitleUtils.getFriendPrefixInfo(showTitleExtra)

	if not string.isNilOrEmpty(friendUid) then
		if not string.isNilOrEmpty(resolvedFriendName) then
			return ShowTitleUtils.resolveFriendPrefixName(friendUid, resolvedFriendName)
		end

		return ShowTitleUtils.resolveFriendPrefixName(friendUid, friendName)
	end

	local prefixTitleId = showTitles and showTitles[Const.SHOW_TITLE_TYPE.Prefix]

	return ShowTitleUtils.getTitleText(prefixTitleId)
end

function ShowTitleUtils.getShowTitleText(showTitles, showTitleExtra, isWholeTitle, resolvedFriendName)
	if isWholeTitle then
		local wholeTitleId = showTitles and showTitles[Const.SHOW_TITLE_TYPE.Whole]

		return ShowTitleUtils.getTitleText(wholeTitleId)
	end

	local prefixText = ShowTitleUtils.getPrefixText(showTitles, showTitleExtra, resolvedFriendName)
	local suffixTitleId = showTitles and showTitles[Const.SHOW_TITLE_TYPE.Suffix]
	local suffixText = ShowTitleUtils.getTitleText(suffixTitleId)

	if ShowTitleUtils.hasFriendPrefix(showTitleExtra) then
		return ShowTitleUtils.getPlayerNameTitleText(prefixText, suffixText)
	end

	if string.isNilOrEmpty(prefixText) then
		return suffixText
	end

	if string.isNilOrEmpty(suffixText) then
		return prefixText
	end

	return ClientTextUtils.concatByLanguage(prefixText, suffixText)
end

function ShowTitleUtils.getPlayerNameTitleText(playerName, suffixText)
	return pg.getFormatText(pg.getGameString("SHOW_TITLE_PLAYER_NAME_FORMAT"), playerName, suffixText)
end

return ShowTitleUtils
