-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\LevelCurve.lua

local Class = require("Core.Framework.Class")
local LevelCurve = Class.LiteClass("LevelCurve")

function LevelCurve:ctor()
	self.levelKeys = {}
end

function LevelCurve:addKey(key, val, tangent)
	local pos = 0

	for idx, keyFrame in ipairs(self.levelKeys) do
		pos = idx

		if key < keyFrame.key then
			table.insert(self.levelKeys, idx, {
				key = key,
				value = val,
				tangent = tangent
			})

			return
		end
	end

	table.insert(self.levelKeys, pos + 1, {
		key = key,
		value = val,
		tangent = tangent
	})
end

function LevelCurve:getVal(level)
	local preKeyFrame

	for _, keyFrame in ipairs(self.levelKeys) do
		if level >= keyFrame.key then
			preKeyFrame = keyFrame
		end
	end

	if preKeyFrame == nil then
		return 0
	else
		return preKeyFrame.value + (level - preKeyFrame.key) * preKeyFrame.tangent
	end
end

return LevelCurve
