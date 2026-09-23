-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\InteractAction.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local TimerManager = require("Core.Timer.TimerManager")
local CallbackHandler = require("Core.Common.CallbackHandler")
local logger = LoggerManager.getLogger("InteractAction")
local InteractData = require("Data.interact_data")
local InteractAction = class.LiteClass("InteractAction", CustomDict)

function InteractAction:hasAction()
	return self.interactId ~= 0
end

function InteractAction:getTargetEntity()
	return pg.getEntity(self.entityId)
end

function InteractAction:startAction(interactId, entityId, interruptCallback)
	local actionTime = InteractData[interactId] and InteractData[interactId].actionTime or 0

	if self:hasAction() and LoggerManager.checkLogger(LoggerConst.WARN) then
		logger:warn("repeated start action", interactId)
	end

	self.end_ts = Time.secondCache + actionTime
	self.entityId = entityId
	self.interactId = interactId
	self.interrupt = false
	self.actionTimer = TimerManager.addTimer(actionTime, CallbackHandler(self, "finishAction"))

	rawset(self, "interruptCallback", interruptCallback)
end

function InteractAction:finishAction()
	self.end_ts = 0
	self.entityId = ""
	self.interactId = 0
	self.actionTimer = 0
	self.interrupt = false
end

function InteractAction:interruptAction()
	self.end_ts = 0
	self.interactId = 0
	self.interrupt = true

	if self.actionTimer ~= 0 then
		TimerManager.removeTimer(self.actionTimer)

		self.actionTimer = 0

		self.interruptCallback()
	end
end

function InteractAction:destroy()
	self:interruptAction()
end

return InteractAction
