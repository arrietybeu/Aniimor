-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\SDKLoginConfig.lua

local SDKLoginConfig = {}

function SDKLoginConfig.isEnabled()
	return not UNITY_EDITOR and ClientConfigEnableSDKLogin == "true"
end

return SDKLoginConfig
