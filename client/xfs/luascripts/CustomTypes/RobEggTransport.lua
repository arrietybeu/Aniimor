-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\RobEggTransport.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local Time = require("Core.Common.Time")
local RobEggTransport = class.LiteClass("RobEggTransport", CustomDict)

function RobEggTransport:startTransport(uid, uname, itemid, timerId, duration)
	self.ownerUid = uid
	self.ownerName = uname
	self.eggItemId = itemid
	self.startTime = Time.secondCache
	self.finishTime = Time.secondCache + duration
	self.timerId = timerId
	self.state = Const.ROB_EGG_TRANSPORT_STATE.TRANSPORTING
end

function RobEggTransport:setState(state)
	self.state = state
end

function RobEggTransport:reset()
	self.ownerUid = ""
	self.ownerName = ""
	self.eggItemId = 0
	self.eggPattern = 0
	self.eggPatternColor = 0
	self.timerId = -1
	self.robTimerId = -1
	self.robUid = ""
	self.startTime = 0
	self.finishTime = 0
	self.state = Const.ROB_EGG_TRANSPORT_STATE.NORMAL
end

function RobEggTransport:repr()
	return string.format("RobEggTransport (%s, %d, %s)", self.ownerUid, self.eggItemId, inspect(self.position))
end

return RobEggTransport
