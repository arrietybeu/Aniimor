-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Recharge\\RechargeConst.lua

local Const = require("Common.Const.Const")
local RechargeConst = {
	PAYMENT_TIMEOUT_SEC = 30,
	ORDER_TIMEOUT_SEC = 30,
	PENALTY_CURRENCY_ID = 3,
	ORDER_ERROR = {
		SERVER_ERROR = 2,
		TIMEOUT = 1,
		SUCCESS = 0,
		INVALID_PRODUCT = 3
	},
	STATE = {
		REQUESTING = 1,
		IDLE = 0,
		PAYING = 3
	},
	RECHARGE_TYPE = Const.RECHARGE_TYPE,
	RUSSIAN_THIRD_PARTY_PAY_CHANNELS = {
		["apple.official.Iwdfss"] = true,
		["rustore-pay.official.A5yuvm"] = true,
		["google.official.Aof9mf"] = true
	},
	RECHARGE_BP_TYPE = {
		NORMAL = 1,
		ADD = 3,
		ADVANCED = 2
	}
}

return RechargeConst
