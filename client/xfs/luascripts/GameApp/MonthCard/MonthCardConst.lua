-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\MonthCard\\MonthCardConst.lua

local MonthCardConst = {}

MonthCardConst.STATE = {
	NOT_ACTIVATED = 0,
	ACTIVATED = 1
}
MonthCardConst.REWARD_TYPE = {
	RENEWAL = 4,
	CUMULATIVE = 3,
	DAILY = 2,
	IMMEDIATE = 1
}
MonthCardConst.CUMULATIVE_DAYS = {
	7,
	15,
	25
}
MonthCardConst.DAILY_REWARD_STATE = {
	AVAILABLE = 1,
	NOT_AVAILABLE = 0,
	CLAIMED = 2
}
MonthCardConst.CUMULATIVE_REWARD_STATE = {
	AVAILABLE = 1,
	LOCKED = 0,
	CLAIMED = 2
}
MonthCardConst.MAX_STORED_DAYS = 5
MonthCardConst.SINGLE_CARD_DURATION = 30
MonthCardConst.MAX_STACK_COUNT = 6
MonthCardConst.GET_TYPE = {
	RENEWAL = 2,
	PURCHASE = 1,
	GIFT = 3
}

return MonthCardConst
