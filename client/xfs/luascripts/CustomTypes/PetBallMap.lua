-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\PetBallMap.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local PetBallMap = class.LiteClass("PetBallMap", CustomDict)

function PetBallMap:setCurIndex(ballIndex)
	if self[ballIndex] == nil then
		return
	end

	self.curIndex = ballIndex
end

return PetBallMap
