-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Feed\\FeedAvatar.lua

local ClientUtils = require("Utils.ClientUtils")
local ServerListHelper = require("Utils.ServerListHelper")
local UIConst = require("Const.UIConst")
local FEED_REPORT_SCENE = 7001
local FeedAvatar = {}

function FeedAvatar.open()
	ServerListHelper.prefetchServerList()
	pg.global.sdkManager:reportScene(FEED_REPORT_SCENE)
	ClientUtils.openAvatarProcess(false, nil, FeedAvatar.openAvatarMain)
end

function FeedAvatar.openAvatarMain()
	local createRoleTimeline = pg.global.ui:tryGetCtrlByUid(UIConst.UI_ID_CREATE_ROLE_TIMELINE)

	if createRoleTimeline and createRoleTimeline:checkUIOpen() then
		createRoleTimeline:showPreparedTimeline(nil, true)

		return
	end

	pg.global.ui:open(UIConst.UI_ID_CREATE_ROLE_TIMELINE, {
		isFeedTrial = true
	}, function()
		createRoleTimeline = pg.global.ui:tryGetCtrlByUid(UIConst.UI_ID_CREATE_ROLE_TIMELINE)

		if createRoleTimeline then
			createRoleTimeline:showPreparedTimeline(nil, true)
		end
	end)
end

return FeedAvatar
