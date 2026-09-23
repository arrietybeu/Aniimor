-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\PlayerActivitySignVersion.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local PlayerActivitySignVersion = class.LiteClass("PlayerActivitySignVersion", CustomDict)

function PlayerActivitySignVersion:getContinueTotalSignNum()
	return self.continueTotalSignNum
end

return PlayerActivitySignVersion
