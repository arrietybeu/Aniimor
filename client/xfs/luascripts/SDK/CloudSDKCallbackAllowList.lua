-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\CloudSDKCallbackAllowList.lua

local ALLOWED_CALLBACKS = {
	platform = {
		reconcilePayments = true,
		pay = true,
		getProductsInfo = true,
		feedStatusChange = true,
		getLaunchOptionsSync = true,
		focusInCallback = true,
		funtapCheckUser = true,
		refreshSocial = true,
		qrcodeLogin = true,
		getSocialInfo = true,
		unbind = true,
		bind = true,
		logout = true,
		createRole = true,
		enterGame = true
	},
	common = {
		webViewClosed = true,
		openFunStore = true,
		initFunStore = true,
		showAchievements = true,
		reportAchievement = true,
		login = true
	},
	tools = {
		loginGameCenter = true,
		getClientIPInfo = true
	},
	privacy = {
		open = true
	}
}

return function(module, func)
	local moduleCallbacks = ALLOWED_CALLBACKS[module]

	return moduleCallbacks ~= nil and moduleCallbacks[func] == true
end
