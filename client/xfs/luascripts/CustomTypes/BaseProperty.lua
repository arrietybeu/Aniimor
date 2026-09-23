-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\BaseProperty.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local BaseProperty = class.LiteClass("BaseProperty", CustomDict)
local math_max = math.max

function BaseProperty.getBaseAndLearnIndividualLevel(selfInfo)
	local baseAndLearn = (selfInfo.indLv or 0) - (selfInfo.iLvEv or 0) - (selfInfo.enhancedCount or 0)

	return baseAndLearn
end

function BaseProperty.getBaseIndividualLevel(selfInfo, excludeEnhanced, excludeEvent)
	local baseLevel = selfInfo.indLv - (selfInfo.iLvLn or 0)

	if excludeEnhanced then
		baseLevel = baseLevel - (selfInfo.enhancedCount or 0)
		baseLevel = math_max(baseLevel, 0)
	end

	if excludeEvent then
		baseLevel = baseLevel - (selfInfo.iLvEv or 0)
		baseLevel = math_max(baseLevel, 0)
	end

	return baseLevel
end

function BaseProperty:modifyLevelByLearn(totalToLevel)
	local offsetLevel = totalToLevel - self.indLv

	self.indLv = totalToLevel
	self.iLvLn = self.iLvLn + offsetLevel
end

function BaseProperty:modifyLevelByExtra(changeValue)
	self.iLvEx = self.iLvEx + changeValue
end

function BaseProperty:modifyLevelByBase(totalToLevel)
	self.indLv = totalToLevel
end

function BaseProperty:modifyLevelByEvent(totalToLevel)
	local offsetLevel = totalToLevel - self.indLv

	self.indLv = totalToLevel
	self.iLvEv = self.iLvEv + offsetLevel
end

function BaseProperty:getBaseAndLearnIndividual()
	return self.indLv
end

function BaseProperty.getAllIndividualLevel(selfInfo)
	return selfInfo.indLv + (selfInfo.iLvEx or 0)
end

return BaseProperty
