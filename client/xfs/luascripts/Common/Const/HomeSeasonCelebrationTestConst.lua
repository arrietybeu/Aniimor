-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Const\\HomeSeasonCelebrationTestConst.lua

local TEST_FESTIVAL_ID = 1
local HomeSeasonCelebrationTestConst = {
	ENABLED = false,
	CHEST_SPAWN_INTERVAL = 2,
	GM_TIP_DURATION = 600,
	GM_TIP_UNIQUE_ID = "HomeSeasonCelebrationGM",
	INTERACTION_ACTION_PROTOTYPE_ID = 1,
	FESTIVAL_ID = TEST_FESTIVAL_ID,
	CHEST_ROW = {
		seasonId = 1,
		id = -72001,
		miniEggRate = 0,
		chestLifeSeconds = 120,
		refreshSelectCount = 2,
		chestConfigId = 11000,
		festivalId = TEST_FESTIVAL_ID,
		waveTimes = {
			30,
			90
		}
	}
}

return HomeSeasonCelebrationTestConst
