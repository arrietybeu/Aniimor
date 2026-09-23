-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\RobEggShowCase.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local RobEggBookCollectionData = require("Data.egg_book_Collection_data")
local RobEggShowCase = class.LiteClass("RobEggShowCase", CustomDict)

function RobEggShowCase:calcScore()
	local point = self.allPoint

	for pos, item in self:items() do
		if item and item:isValid() and item:isActive() == false then
			local cfg = RobEggBookCollectionData[pos]

			if cfg then
				point = point + (cfg.point or 0)
			end

			item.active = true
		end
	end

	if point >= self.allPoint then
		self.allPoint = point
	end
end

return RobEggShowCase
