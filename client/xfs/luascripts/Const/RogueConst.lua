-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Const\\RogueConst.lua

local RogueConst = {}

RogueConst.CURRENCY_ITEM_ID = 4000
RogueConst.MAX_PET_COUNT = 5
RogueConst.PropIndex = {
	IDX_REGEN = 6,
	IDX_MDEF = 5,
	IDX_DEF = 4,
	IDX_MATK = 3,
	IDX_ATK = 2,
	IDX_HP = 1
}
RogueConst.LevelType = {
	BONUS = 1,
	NORMAL = 0
}
RogueConst.LevelItemRenderType = {
	WATER = 2,
	GLASS = 1,
	FIRE = 0,
	BONUS = 3
}
RogueConst.Element2LevelItemRenderType = {
	[0] = 0,
	0,
	0,
	1,
	0,
	0,
	0,
	0,
	0,
	0,
	0,
	2,
	0
}
RogueConst.Num2RomanNum = {
	"I",
	"II",
	"III",
	"IV",
	"V",
	"VI",
	"VII",
	"VIII",
	"IX",
	"X",
	"XI",
	"XII"
}
RogueConst.GoNextDungeonNpcEffect = {
	[890001] = "Eff_Trigger_Rogue_Random_Dsiappear",
	[890046] = "Eff_Trigger_Rogue_Boss_Dsiappear_Purple",
	[890003] = "Eff_Trigger_Rogue_Rest_Dsiappear",
	[890004] = "Eff_Trigger_Rogue_Boss_Dsiappear",
	[890047] = "Eff_Trigger_Rogue_Boss_Dsiappear_Blue",
	[890000] = "Eff_Trigger_Rogue_Normal_Dsiappear",
	[890002] = "Eff_Trigger_Rogue_Hard_Dsiappear"
}
RogueConst.GoNextDungeonDelay = 0.35
RogueConst.VentureNormalStepTime = 2
RogueConst.VentureLastStepTime = 3

return RogueConst
