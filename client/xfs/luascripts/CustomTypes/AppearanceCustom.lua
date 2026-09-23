-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\AppearanceCustom.lua

local class = require("Core.Framework.Class")
local CustomDict = require("Core.PropertySync.CustomDict")
local AppearanceCustomOne = require("CustomTypes.AppearanceCustomOne")
local AppearanceData = require("Data.appearance_data")
local AppearanceCustom = class.LiteClass("AppearanceCustom", CustomDict)

function AppearanceCustom:getCount()
	local count = 0

	for index, _ in pairs(self) do
		if type(index) == "number" then
			count = count + 1
		end
	end

	return count
end

function AppearanceCustom:unlock(customShow)
	local newIndex = self:getCount() + 1

	self[newIndex] = AppearanceCustomOne({})

	for point, configId in pairs(customShow) do
		self[newIndex].customShow[point] = 0
	end
end

function AppearanceCustom:unlockPoint(point)
	for index, appearanceDic in pairs(self) do
		if type(index) == "number" then
			appearanceDic.customShow[point] = 0
		end
	end
end

function AppearanceCustom:delAppearance(configId)
	local data = AppearanceData[configId]

	if not data then
		return
	end

	local points = data.points or data.optionalPoints

	for index, appearanceDic in pairs(self) do
		if type(index) == "number" then
			for _, point in ipairs(points) do
				if appearanceDic.customShow[point] == configId then
					appearanceDic.customShow[point] = 0
					appearanceDic[point] = nil
					appearanceDic.clothesDesigns[point] = nil
					appearanceDic.hairInfo[point] = nil
					appearanceDic.makeUpInfo[point] = nil
				end
			end
		end
	end
end

return AppearanceCustom
