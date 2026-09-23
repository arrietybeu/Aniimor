-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Accusation\\AccusationModel.lua

local logger = require("Core.Log.LoggerManager").getLogger("AccusationModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local SysConfigData = require("Data.sys_config_data")
local AccusationModel = Class.LightClass("AccusationModel", UIModel)

function AccusationModel:getSendLimit()
	return tonumber(SysConfigData.ACCUSATION_DESC_LIMIT) or 0
end

return AccusationModel
