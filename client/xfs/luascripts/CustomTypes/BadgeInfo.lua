-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\BadgeInfo.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local BadgeInfo = class.LiteClass("BadgeInfo", CustomDict)
local math_floor = math.floor

function BadgeInfo.genData()
	local dict = {}

	dict.curQuality = 0
	dict.isPlayAnim = false
	dict.isOpen = false
	dict.Revert = false
	dict.randomQuality = 0
	dict.upNums = 0

	return dict
end

return BadgeInfo
