-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Const\\GhostEyeConst.lua

local GhostEyeConst = {}

GhostEyeConst.DETECT_TAG_KEY = "GHOST_EYE_DETECT_TAG_KEY"
GhostEyeConst.DETECT_CAMOUFLAGE_KEY = "GHOST_EYE_DETECT_CAMOUFLAGE_KEY"
GhostEyeConst.DETECT_ALL_KEY = "GHOST_EYE_DETECT_ALL_KEY"
GhostEyeConst.BOTH_SIDE_KEY = "GHOST_EYE_BOTH_SIDE_KEY"
GhostEyeConst.NIGHT_VISION_KEY = "GHOST_EYE_NIGHT_VISION_KEY"
GhostEyeConst.BOTH_SIDE_CAMERA_ENTER_TIME = 0.4
GhostEyeConst.BOTH_SIDE_CAMERA_WAIT_EXIT_TIME = 0.4
GhostEyeConst.BOTH_SIDE_CAMERA_EXIT_TIME = 1
GhostEyeConst.BOTH_SIDE_EFFECT_EXIT_TIME = 1
GhostEyeConst.BOTH_SIDE_EFFECT_SLOW = "Eff_Parmon_BilateralVision_FirstTime"
GhostEyeConst.BOTH_SIDE_EFFECT_FAST = "Eff_Parmon_BilateralVision"
GhostEyeConst.DETECT_RANGE = 50
GhostEyeConst.DETECT_SPREAD_SPEED = 20
GhostEyeConst.DETECT_SPREAD_DELAY_SLOW = 2.7
GhostEyeConst.DETECT_SPREAD_DELAY_FAST = 0.4
GhostEyeConst.DETECT_CAMERA_ENTER_TIME = 0.4
GhostEyeConst.DETECT_CAMERA_EXIT_TIME = 0.5
GhostEyeConst.DETECT_SPREAD_EFFECT_SLOW = "Eff_Parmon_Detect_SceneScan"
GhostEyeConst.DETECT_SPREAD_EFFECT_FAST = "Eff_Parmon_Detect_SceneScan_01"
GhostEyeConst.DETECT_MASK_EFFECT = "$Level_FB_HelmonBox_VolumeProfile_01.asset"
GhostEyeConst.DETECT_ENTITY_EFFECT_TYPE = {
	CONGENER = 3,
	CAMOUFLAGE = 2,
	CHEST = 1,
	NONE = 0
}
GhostEyeConst.COMMON_BLINK_EFFECT_SLOW = "Eff_Parmon_Blink_First"
GhostEyeConst.COMMON_BLINK_EFFECT_FAST = "Eff_Parmon_Blink"
GhostEyeConst.NIGHT_VISION_EFFECT = "Eff_Parmon_NightVision"
GhostEyeConst.NIGHT_VISION_DELAY_SLOW = 2.7
GhostEyeConst.NIGHT_VISION_DELAY_FAST = 0.4
GhostEyeConst.NIGHT_VISION_CAMERA_ENTER_TIME = 0.4
GhostEyeConst.NIGHT_VISION_CAMERA_EXIT_TIME = 0.5

return GhostEyeConst
