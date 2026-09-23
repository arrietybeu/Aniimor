-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Const\\RandomShopConst.lua

local RandomShopConst = {}

RandomShopConst.ShopType = {
	NORMAL = 1,
	NONE = 0
}
RandomShopConst.RefreshType = {
	DAILY = 1,
	WEEKLY = 2,
	MONTHLY = 3,
	NONE = 0
}
RandomShopConst.TopTierLimitScope = {
	DAILY = 2,
	SHOP_PERIOD = 5,
	NONE = 0,
	PER_DRAW = 1,
	MONTHLY = 4,
	WEEKLY = 3
}
RandomShopConst.PityType = {
	REFRESH_TIMES = 2,
	COST = 1,
	NONE = 0
}
RandomShopConst.PrizeTier = {
	NORMAL = 0,
	TOP = 2,
	SECOND = 1
}
RandomShopConst.LimitType = {
	DAILY = 1,
	SHOP_PERIOD = 4,
	LIFETIME = 5,
	NONE = 0,
	MONTHLY = 3,
	WEEKLY = 2
}
RandomShopConst.GenderType = {
	MALE = 1,
	ALL = 0,
	FEMALE = 2
}
RandomShopConst.WeightAdjustType = {
	VALUE = 2,
	PERCENT = 1,
	NONE = 0
}
RandomShopConst.GenderType = {
	MALE = 1,
	ALL = 0,
	FEMALE = 2
}

return RandomShopConst
