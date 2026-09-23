-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeCarName\\HomeCarNameModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local ClientTextUtils = require("Utils.ClientTextUtils")
local SysConfigData = require("Data.sys_config_data")
local HomelandConfigData = require("Data.homeland_config_data")
local HomeCarNameModel = Class.LightClass("HomeCarNameModel", UIModel)

function HomeCarNameModel:getValidName(name)
	if string.isNilOrEmpty(name) then
		return name
	end

	name = ClientTextUtils.getValidName(name, HomelandConfigData.carNameMaxLen or 10)

	return name
end

return HomeCarNameModel
