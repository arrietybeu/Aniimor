-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Const\\LeylineFlowerConst.lua

local Const = require("Common.Const.Const")
local LeylineFlowerConst = {}

LeylineFlowerConst.FLOWER_STATE = {
	Blooming = 3,
	Budding = 2,
	Growing = 1,
	Withering = 5,
	Fruiting = 4
}
LeylineFlowerConst.FLOWER_BLOOM_TYPE = {
	Normal = 0,
	Rainbow = 1
}
LeylineFlowerConst.FLOWER_AUDIO_EVENT = {
	RainbowEnergyLevelUp = "SFX_UI_RainbowEnergy_LevelUp",
	Grow = "SFX_SceneObject_DaLiangFaSheng_Sprout",
	RainbowEnergyIncrease = "SFX_UI_RainbowEnergy_Incre",
	RainbowPillar = "SFX_UI_RainbowPillar",
	RainbowEnergyGet = "SFX_UI_RainbowEnergy_Get",
	FlowersFade = "SFX_SceneObject_DaLiangFaSheng_FlowersFade",
	EnergyBallLoop = "SFX_SceneObject_DaLiangFaSheng_EnergyBall_Loop",
	BloomLoop = "SFX_SceneObject_DaLiangFaSheng_Bloom_Loop",
	Bloom = "SFX_SceneObject_DaLiangFaSheng_Bloom",
	BudLoop = "SFX_SceneObject_DaLiangFaSheng_Bud_Loop",
	RainbowPetAppear = "SFX_UI_RainbowPet_Appear",
	GrowLoop = "SFX_SceneObject_DaLiangFaSheng_Bud_Loop"
}
LeylineFlowerConst.RAINBOW_HUD_VX_CLIP = {
	PetResult = "VX_Pop_Map_Tips02",
	EnergyNormal = "VX_Pop_Map_Tips01",
	StageUpFeedback = "VX_Pop_Map_Tips_ProgressUp_Feedback",
	EnergyRushHandoff = "VX_Pop_Map_Tips04Lucky"
}
LeylineFlowerConst.FLOWER_RAINBOW_LEVEL = {
	LEVEL1 = 1,
	LEVEL6 = 6,
	LEVEL5 = 5,
	LEVEL4 = 4,
	LEVEL3 = 3,
	LEVEL2 = 2
}
LeylineFlowerConst.RUMBLE_NAME = {
	Bloom = "LeyLinesTree_Bloom",
	AnimoAppear = "LeyLinesTree_Animo_Appear"
}
LeylineFlowerConst.RAINBOW_RUSH_RUMBLE_BY_STAGE = {
	[LeylineFlowerConst.FLOWER_RAINBOW_LEVEL.LEVEL2] = "CommonLight",
	[LeylineFlowerConst.FLOWER_RAINBOW_LEVEL.LEVEL3] = "CommonMiddle",
	[LeylineFlowerConst.FLOWER_RAINBOW_LEVEL.LEVEL4] = "CommonMiddle",
	[LeylineFlowerConst.FLOWER_RAINBOW_LEVEL.LEVEL5] = "CommonHigh",
	[LeylineFlowerConst.FLOWER_RAINBOW_LEVEL.LEVEL6] = "CommonHigh"
}
LeylineFlowerConst.MAX_SET_STATE_DEPTH = 4
LeylineFlowerConst.STATE_ENTER_FUNC = {
	[LeylineFlowerConst.FLOWER_STATE.Growing] = "onEnterGrowing",
	[LeylineFlowerConst.FLOWER_STATE.Budding] = "onEnterBudding",
	[LeylineFlowerConst.FLOWER_STATE.Blooming] = "onEnterBlooming",
	[LeylineFlowerConst.FLOWER_STATE.Fruiting] = "onEnterFruiting",
	[LeylineFlowerConst.FLOWER_STATE.Withering] = "onEnterWithering"
}
LeylineFlowerConst.STATE_EXIT_FUNC = {
	[LeylineFlowerConst.FLOWER_STATE.Growing] = "onExitGrowing",
	[LeylineFlowerConst.FLOWER_STATE.Budding] = "onExitBudding",
	[LeylineFlowerConst.FLOWER_STATE.Blooming] = "onExitBlooming",
	[LeylineFlowerConst.FLOWER_STATE.Fruiting] = "onExitFruiting",
	[LeylineFlowerConst.FLOWER_STATE.Withering] = "onExitWithering"
}
LeylineFlowerConst.MAP_MARK_STATUS = {
	Blooming = 101,
	Budding = 100,
	Fruiting = 102,
	Growing = Const.MAP_MARK_STATUS_UNLOCKED
}
LeylineFlowerConst.FLOWER_STATE_TO_MARK_STATUS = {
	[LeylineFlowerConst.FLOWER_STATE.Growing] = LeylineFlowerConst.MAP_MARK_STATUS.Growing,
	[LeylineFlowerConst.FLOWER_STATE.Budding] = LeylineFlowerConst.MAP_MARK_STATUS.Budding,
	[LeylineFlowerConst.FLOWER_STATE.Blooming] = LeylineFlowerConst.MAP_MARK_STATUS.Blooming,
	[LeylineFlowerConst.FLOWER_STATE.Fruiting] = LeylineFlowerConst.MAP_MARK_STATUS.Fruiting
}
LeylineFlowerConst.RAINBOW_PET_POINT_CONFIG_ID = 10415
LeylineFlowerConst.LEYLINE_FLOWER_POINT_CONFIG_ID = 10410
LeylineFlowerConst.CULTIVATE_TIP_STATE = {
	LeylineFlower = 2,
	RainbowPet = 1,
	RainbowEnergy = 0
}
LeylineFlowerConst.DEFAULT_RAINBOW_METEOROLOGY_ID = 1
LeylineFlowerConst.DEFAULT_RAINBOW_METEOROLOGY_DURATION = 240
LeylineFlowerConst.METEOROLOGY_RENEW_ADVANCE = 5
LeylineFlowerConst.LUCKY_EVENT_RESULT = {
	SwitchClose = -2,
	SuperSucess = 2,
	Success = 1,
	Fail = 0,
	NoMeetCondition = -1
}
LeylineFlowerConst.RAINBOW_PRESENT_REASON = {
	AreaLucky = 3,
	Timeout = 2,
	Pick = 1,
	TreeMeteorology = 5,
	Share = 4
}
LeylineFlowerConst.RAINBOW_SNAPSHOT_FIELDS = {
	"oldStage",
	"oldEnergy",
	"grownStage",
	"grownEnergy",
	"newStage",
	"newEnergy"
}

return LeylineFlowerConst
