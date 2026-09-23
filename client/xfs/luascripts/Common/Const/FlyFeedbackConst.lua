-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Const\\FlyFeedbackConst.lua

local FlyFeedbackConst = {}

FlyFeedbackConst.SFX_GENERAL = "SFX_UI_SubmitCoins_01"
FlyFeedbackConst.SFX_START_FLY = "SFX_UI_SubmitCoins_02"
FlyFeedbackConst.SFX_END_FLY = "SFX_UI_SubmitCoins_03"
FlyFeedbackConst.HARVEST = {
	ICON_COUNT_RATIO = 5,
	MAX_ICON_COUNT = 20,
	FALLBACK_SCREEN_ANCHOR = {
		x = 0.5,
		y = 0.12
	}
}
FlyFeedbackConst.ORDER = {
	ICON_COUNT_RATIO = 100,
	MAX_ICON_COUNT = 5
}
FlyFeedbackConst.WISH_STAR = {
	ICON_COUNT_RATIO = 100,
	MAX_ICON_COUNT = 5,
	FALLBACK_SOURCE_SCREEN_ANCHOR = {
		x = 0.5,
		y = 0.5
	},
	FALLBACK_TARGET_SCREEN_ANCHOR = {
		x = 0.85,
		y = 0.9
	}
}

return FlyFeedbackConst
