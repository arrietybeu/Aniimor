-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\LevelArray.lua

local Class = require("Core.Framework.Class")
local LevelArray = Class.LiteClass("LevelArray")

function LevelArray:ctor()
	self.levelKeys = {}
end

function LevelArray:addKey(level, idArray)
	for idx, keyFrame in ipairs(self.levelKeys) do
		if level < keyFrame.key then
			table.insert(self.levelKeys, idx, {
				key = level,
				value = idArray
			})

			return
		end
	end

	table.insert(self.levelKeys, #self.levelKeys + 1, {
		key = level,
		value = idArray
	})
end

function LevelArray:getVal(level)
	local curIdArray

	for _, idArray in ipairs(self.levelKeys) do
		if level >= idArray.key then
			curIdArray = idArray
		else
			break
		end
	end

	return curIdArray ~= nil and curIdArray.value or nil
end

return LevelArray
