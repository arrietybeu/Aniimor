-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\QuickPayment\\QuickPaymentModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("QuickPaymentModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local QuickPaymentModel = Class.LightClass("QuickPaymentModel", UIModel)

function QuickPaymentModel:ctor()
	QuickPaymentModel.super.ctor(self)
end

return QuickPaymentModel
