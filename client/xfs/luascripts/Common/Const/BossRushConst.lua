-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Const\\BossRushConst.lua

local BossRushConst = {}

BossRushConst.PersonRank = {
	tab2 = 1,
	tab1 = 1,
	rankId = 10001
}
BossRushConst.BossRankList = {
	{
		rankId = 10001,
		tab2 = 1,
		tab1 = 2,
		configKey = "bossLeft"
	},
	{
		rankId = 10001,
		tab2 = 2,
		tab1 = 2,
		configKey = "bossMid"
	},
	{
		rankId = 10001,
		tab2 = 3,
		tab1 = 2,
		configKey = "bossRight"
	}
}
BossRushConst.RankList = {
	BossRushConst.PersonRank,
	BossRushConst.BossRankList[1],
	BossRushConst.BossRankList[2],
	BossRushConst.BossRankList[3]
}

return BossRushConst
