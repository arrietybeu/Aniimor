-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Feed\\FeedWebView.lua

local json = require("json")
local Utils = require("Common.Utils.Utils")
local ServerListHelper = require("Utils.ServerListHelper")
local FeedLogin = require("GameApp.Feed.FeedLogin")
local FEED_WEB_VIEW_URL = "https://kg-web-cdn.kingsgroup.cn/official-website/worldx/ydx/aniimo-hatch-webview.html"
local FEED_REPORT_SCENE = 7001
local FeedWebView = {}

function FeedWebView.open()
	ServerListHelper.prefetchServerList()
	pg.global.sdkManager:reportScene(FEED_REPORT_SCENE)
	FeedWebView.showWebView()
end

function FeedWebView.showWebView()
	pg.global.sdkManager:showWebView({
		url = FEED_WEB_VIEW_URL,
		parameters = {
			navigationType = 0
		}
	}, FeedWebView.onClosed)
end

function FeedWebView.onClosed(result)
	local success, response = pcall(json.decode, result)
	local data = success and Utils.isTable(response) and response.data or nil

	if not Utils.isTable(data) or data.url ~= FEED_WEB_VIEW_URL then
		return
	end

	FeedLogin.showFinishConfirm(FeedWebView.login, FeedWebView.showWebView)
end

function FeedWebView.login()
	pg.global.ui.avatarLoading:open()

	if not FeedLogin.login(true) then
		pg.global.ui.avatarLoading:close()
	end
end

return FeedWebView
