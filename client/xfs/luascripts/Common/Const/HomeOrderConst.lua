-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Const\\HomeOrderConst.lua

local HomeOrderConst = {}

HomeOrderConst.TYPE = {
	Season = 3,
	HighPriority = 2,
	Normal = 1
}
HomeOrderConst.STATUS = {
	Incomplete = 1,
	Finish = 2
}
HomeOrderConst.QUALITY = {
	"green",
	"blue",
	"purple",
	"orange",
	"rainbow"
}
HomeOrderConst.RefreshResult = {
	LOCKED = 5,
	OVERLIMIT = 4,
	NOREFRESHCOUNT = 3,
	NOORDER = 2,
	FAIL = 1,
	SUCCESS = 0,
	NOTUNLOCK = 6
}
HomeOrderConst.SOURCE = {
	Daily = 2,
	Default = 1,
	Manual = 4,
	CarUpgrade = 3
}

return HomeOrderConst
