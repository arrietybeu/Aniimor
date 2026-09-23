-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\PetTransmogInfo.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local PetTransmogInfo = class.LiteClass("PetTransmogInfo", CustomDict)

function PetTransmogInfo:getSelectedScheme()
	return self.selectTransmogScheme
end

function PetTransmogInfo:getSelectedSchemeRaw()
	local scheme = self:getSelectedScheme()

	return scheme and scheme.getRawTable and scheme:getRawTable() or scheme
end

return PetTransmogInfo
