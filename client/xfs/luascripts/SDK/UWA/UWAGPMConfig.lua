-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\UWA\\UWAGPMConfig.lua

local UWAGPMConfig = {}

UWAGPMConfig.platformAppIDs = {
	openharmony = "9c6c19bd-a149-46bf-87a3-cee8438e0ed8",
	android = "3c02b34f-d32c-44c2-af67-7a6f71f24d91",
	standalone = "feed1b4c-b5d3-4f8a-aff2-41f1082682f2",
	ios = "75f366f4-111d-4ce7-a860-cc1b98ae01c8"
}
UWAGPMConfig.url = "https://worldx-gpm.kingsgroup.cn"
UWAGPMConfig.debugMode = false
UWAGPMConfig.enableCrashReport = true
UWAGPMConfig.enableInEditor = false
UWAGPMConfig.networkLatencyInterval = 10

return UWAGPMConfig
