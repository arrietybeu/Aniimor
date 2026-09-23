-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\SpecialTrainData.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local Bitset = require("Common.Bitset")
local SpecialTrainData = class.LiteClass("SpecialTrainData", CustomDict)
local getBit = Bitset.getBit
local setBit = Bitset.setBit

function SpecialTrainData:setCurQuestId(curQuestId)
	self.curQuestId = curQuestId
end

function SpecialTrainData:setEntryReward(taskProcess)
	if getBit(self.rewardFlags, taskProcess) then
		return false
	end

	setBit(self.rewardFlags, taskProcess)

	return true
end

function SpecialTrainData:isEntryRewarded(taskProcess)
	return getBit(self.rewardFlags, taskProcess)
end

return SpecialTrainData
