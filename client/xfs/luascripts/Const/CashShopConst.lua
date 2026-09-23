-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Const\\CashShopConst.lua

local CashShopConst = {}

CashShopConst.CategoryType = {
	ITEM = 5,
	AVATAR = 4,
	GIFTPACK = 3,
	MONTHLYCARD = 2,
	RECOMMEND = 1,
	TRADE_MARKET = 8,
	RECHARGE = 7,
	EXCHANGE = 6
}
CashShopConst.BtnState = {
	LOCKED = 3,
	OBTAIN = 2,
	DIRECT_PURCHASED = 1,
	BUY = 0,
	SOLD_OUT = 5,
	PURCHASED = 4
}
CashShopConst.ShowModle = {
	FirstTopup = 5,
	BattlePass = 4,
	MonthCard = 3,
	PIC = 2,
	MODLE = 1,
	Lottery = 6
}
CashShopConst.BgType = {
	MODLE = 1,
	IMAGE = 2,
	SPECIAL_SCENE = 3
}
CashShopConst.DEFAULT_SPECIAL_SCENE_TIMELINE = "$P_TL_UIScene_Avatar_Girl_Set_G10035_Entrance.prefab"
CashShopConst.SceneBgType = {
	IMG_2D = 1,
	SPECIAL_3D = 3,
	SCENE_3D = 2
}
CashShopConst.GiftPackTabType = {
	Optional = 301,
	Weekly = 303,
	Fix = 302
}
CashShopConst.ExchangeShopTabType = {
	Random = 601,
	Exchange = 602
}
CashShopConst.ShopShowType = {
	TRACK = 1,
	OPEN = 0
}
CashShopConst.ShopAvatarType = {
	PROMINENT = 1,
	NORMAL = 2
}
CashShopConst.CommodityAvatarType = {
	ACCESSORY_PACKAGE = 4000,
	SUIT = 3000
}
CashShopConst.AccessoryPreviewTarget = {
	PET = 1,
	PLAYER = 0,
	FURNITURE = 2
}
CashShopConst.SuitPowerType = {
	PET_IDLE = 2,
	FASHION_SWITCH = 1,
	PLAYER_PET_TIPS = 4,
	PLAYER_PET_INTERACTION = 3
}
CashShopConst.ShopItemType = {
	DETAILS = 1,
	NO_DETAILS = 2
}
CashShopConst.CommodityItemType = {
	CHAT_BUBBLE = 3,
	AVATAR_FRAME = 1,
	AVATAR = 2,
	PANEL = 4
}
CashShopConst.AppearanceModelType = {
	PET = 2,
	PLAYER = 1
}
CashShopConst.CardShopType = {
	MonthCard = 0,
	BattlePass = 1
}
CashShopConst.PetActionType = {
	BattlePass = 2,
	CashShop = 3,
	BattlePassPurchase = 1
}

return CashShopConst
