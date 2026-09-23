-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\RobEggHatchPoint.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local Time = require("Core.Common.Time")
local RobEggHatchPoint = class.LiteClass("RobEggHatchPoint", CustomDict)

function RobEggHatchPoint:startHatch(uid, itemid, timerId, lasttime)
	self.status = Const.ROB_EGG_HATCH_STATUS.HATCHING
	self.ownerUid = uid
	self.eggItemId = itemid
	self.hatchFinishTime = Time.secondCache + lasttime
	self.timerId = timerId
end

function RobEggHatchPoint:endHatch()
	self.status = Const.ROB_EGG_HATCH_STATUS.HATCHED
	self.timerId = -1
	self.readBarUid = ""
	self.readBarTimerId = -1
end

function RobEggHatchPoint:taked()
	self.status = Const.ROB_EGG_HATCH_STATUS.IDLE
	self.ownerUid = ""
	self.eggItemId = 0
	self.hatchFinishTime = 0
	self.timerId = -1
	self.readBarUid = ""
	self.readBarTimerId = -1
end

return RobEggHatchPoint
