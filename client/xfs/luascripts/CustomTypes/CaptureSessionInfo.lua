-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\CustomTypes\\CaptureSessionInfo.lua

local CustomDict = require("Core.PropertySync.CustomDict")
local class = require("Core.Framework.Class")
local logger = require("Core.Log.LoggerManager").getLogger("CaptureSessionInfo")
local CaptureConst = require("Common.Const.CaptureConst")
local CaptureSessionInfo = class.LiteClass("CaptureSessionInfo", CustomDict)

function CaptureSessionInfo:ctor(dict)
	CaptureSessionInfo.super.ctor(self, dict)
	rawset(self, "splitCaptureResult", nil)
	rawset(self, "catchThrowInfo", nil)
end

function CaptureSessionInfo:getCaptureRuntimeTarget(entId)
	local targets = rawget(self, "captureRuntimeTargets")

	return targets and targets[entId]
end

function CaptureSessionInfo:addCaptureRuntimeTarget(entId, runtimeTarget)
	local targets = rawget(self, "captureRuntimeTargets")

	if not targets then
		targets = {}

		rawset(self, "captureRuntimeTargets", targets)
	elseif targets[entId] then
		return false
	end

	targets[entId] = runtimeTarget

	return true
end

function CaptureSessionInfo:checkStateInAndAlarm(...)
	for i = 1, select("#", ...) do
		if self.state == select(i, ...) then
			return true
		end
	end

	ALARM("@capture CaptureSessionInfo:checkStateInAndAlarm failed, invalid state %d, expected states %s, %s", self.state, table.concat({
		...
	}, ","), self:repr())

	return false
end

function CaptureSessionInfo:updateBallInfo(ballUid, ballCfgId, ballItemId)
	if not self:checkStateInAndAlarm(CaptureConst.SESSION_STATE_INIT) then
		return
	end

	self.ballUid = ballUid
	self.ballCfgId = ballCfgId
	self.ballItemId = ballItemId
end

function CaptureSessionInfo:updateBallCatchType(catchType)
	if not self:checkStateInAndAlarm(CaptureConst.SESSION_STATE_INIT) then
		return
	end

	self.catchType = catchType
end

function CaptureSessionInfo:updateBallEntInfo(ballEntId)
	if not self:checkStateInAndAlarm(CaptureConst.SESSION_STATE_INIT) then
		return
	end

	self.ballEntId = ballEntId
end

function CaptureSessionInfo:updatePuppetInfo(onePuppetInfo)
	if not self:checkStateInAndAlarm(CaptureConst.SESSION_STATE_FIRED, CaptureConst.SESSION_STATE_HIT) then
		return
	end

	self.puppetInfos:insert(#self.puppetInfos + 1, onePuppetInfo)
end

local STATE_TRANSITIONS = {
	[CaptureConst.SESSION_STATE_INIT] = {
		[CaptureConst.SESSION_STATE_FIRED] = true,
		[CaptureConst.SESSION_STATE_SETTLED] = true
	},
	[CaptureConst.SESSION_STATE_FIRED] = {
		[CaptureConst.SESSION_STATE_HIT] = true,
		[CaptureConst.SESSION_STATE_SETTLED] = true
	},
	[CaptureConst.SESSION_STATE_HIT] = {
		[CaptureConst.SESSION_STATE_HIT] = true,
		[CaptureConst.SESSION_STATE_SETTLED] = true
	}
}

function CaptureSessionInfo:transferStateTo(newState)
	if self.state == newState then
		return
	end

	local allowedStates = STATE_TRANSITIONS[self.state]

	if not allowedStates or not allowedStates[newState] then
		ALARM("@capture CaptureSessionInfo:transferStateTo failed, invalid state transfer %d->%d, %s", self.state, newState, self:repr())

		return
	end

	self.state = newState

	logger:debug("@capture transferStateTo success, newState=%d, %s", newState, self:repr())
end

function CaptureSessionInfo:repr()
	return string.format("CaptureSessionInfo{id=%s, state=%d, createTime=%d}", self.id, self.state, self.createTime)
end

return CaptureSessionInfo
