-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\FishingCaptureInfo.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local Class = require("Core.Framework.Class")
local FishingCaptureInfo = Class.LiteClass("FishingCaptureInfo", CustomDict)

function FishingCaptureInfo:onActivityReset()
	self.progressValue = 0
	self.layerCount = 0
	self.bestBattleGrade = 0
	self.bestBattleTime = 0
	self.totalThrowCount = 0
	self.levelRewardCount = 0
	self.captureSuccess = false
	self.energyConvertRewardSent = false
end

function FishingCaptureInfo:onSessionReset()
	self.sessionBattleGrade = 0
	self.sessionCaptureBonus = 0
	self.sessionBallUsedMap = {}
	self.totalThrowCount = 0
	self.levelRewardCount = 0
	self.captureSuccess = false
	self.settleRewardSent = false
	self.energyConvertRewardSent = false
end

return FishingCaptureInfo
