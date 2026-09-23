-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\LeylineFlowerInfo.lua

local class = require("Core.Framework.Class")
local CustomDict = require("Core.PropertySync.CustomDict")
local LeylineFlowerUtils = require("Common.Utils.LeylineFlowerUtils")
local LeylineFlowerInfo = class.LiteClass("LeylineFlowerInfo", CustomDict)

function LeylineFlowerInfo:getRainbowEnergy()
	return self.rainbowEnergy
end

function LeylineFlowerInfo:getTotalRainbowEnergy()
	return LeylineFlowerUtils.getTotalRainbowEnergy(self)
end

return LeylineFlowerInfo
