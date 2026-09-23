-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HatredArrowTip\\HatredArrowTipModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local HatredArrowTipModel = Class.LightClass("HatredArrowTipModel", UIModel)
local SysConfigData = require("Data.sys_config_data")

HatredArrowTipModel.LAYER_GAP = 2

function HatredArrowTipModel:ctor()
	self.LAYER_GAP = SysConfigData.TOPLOGO_SHOW_UP_DOWN and SysConfigData.TOPLOGO_SHOW_UP_DOWN[2] or 2
	self.LAYER_DISTANCE = SysConfigData.TOPLOGO_SHOW_UP_DOWN and SysConfigData.TOPLOGO_SHOW_UP_DOWN[1] or 10
	self.LAYER_SQR_DISTANCE = self.LAYER_DISTANCE^2
end

return HatredArrowTipModel
