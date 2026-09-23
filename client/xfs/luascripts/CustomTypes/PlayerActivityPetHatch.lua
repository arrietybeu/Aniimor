-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\PlayerActivityPetHatch.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local SysConfigData = require("Data.sys_config_data")
local PlayerActivityPetHatch = class.LiteClass("PlayerActivityPetHatch", CustomDict)

function PlayerActivityPetHatch:getSpeedUpTimeRate()
	return SysConfigData.ACTIVITY_PET_HATCH_SPEED or 0
end

return PlayerActivityPetHatch
