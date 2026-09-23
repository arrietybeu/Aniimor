-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\ItemBag\\ItemDefines.lua

local ItemDefine = {
	ItemEvent = {
		Remove = 2,
		Add = 1
	},
	BagOverFlowMode = {
		Default = 0,
		CustomHandleWhenOverflow = 3,
		Infinite = 2,
		AllowOverflowOnlyOnce = 1
	},
	PileupMode = {
		CustomHandleWhenOverPile = 2,
		DropWhenOverPile = 1,
		AllowMultiPile = 0
	}
}

return ItemDefine
