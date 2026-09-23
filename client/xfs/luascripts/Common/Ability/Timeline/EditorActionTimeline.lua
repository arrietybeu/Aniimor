-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\Timeline\\EditorActionTimeline.lua

local Class = require("Core.Framework.Class")
local ActionTimeline = require("Common.Ability.Timeline.ActionTimeline")
local SafeCallbackCoroutine = require("Common.Ability.SafeCallbackCoroutine")
local AbilityObject = require("Common.Ability.AbilityObject")
local AbilityDebugTool = require("Common.Ability.AbilityDebugTool")
local EditorActionTimeline = Class.LiteClass("EditorActionTimeline", ActionTimeline)

function EditorActionTimeline:ctor(owner, layer)
	ActionTimeline.ctor(self, owner, layer)
end

function EditorActionTimeline:setTimeline(timelineId, playRate, timelineParams)
	if Switch.EnableRuntimeDebug and AbilityDebugTool.checkRuntimeDebugTimeline(timelineId) then
		AbilityDebugTool.startMainDebugCoroutine(function()
			self.pendingTimelineCmdParams:pushCmdSet(timelineId, playRate, timelineParams)

			self.owner.jumpingTimelineRefCnt = self.owner.jumpingTimelineRefCnt + 1

			self:flush()

			self.owner.jumpingTimelineRefCnt = self.owner.jumpingTimelineRefCnt - 1

			self.owner:refreshAbilityMask(self.ability)
		end)
	else
		self.pendingTimelineCmdParams:pushCmdSet(timelineId, playRate, timelineParams)

		self.owner.jumpingTimelineRefCnt = self.owner.jumpingTimelineRefCnt + 1

		self:flush()

		self.owner.jumpingTimelineRefCnt = self.owner.jumpingTimelineRefCnt - 1

		self.owner:refreshAbilityMask(self.ability)
	end
end

function EditorActionTimeline:doLockGuard(fun, ...)
	self.lock = self.lock + 1

	local ret, innerCoroutine = SafeCallbackCoroutine(fun, self, ...)

	if type(ret) == "function" and innerCoroutine then
		coroutine.yield(ret, innerCoroutine)
	end

	self.lock = self.lock - 1
end

function EditorActionTimeline:stopTimelineInternal(interrupt)
	if not self.isPlaying then
		return
	end

	if self.timeline == nil then
		self:clear()

		return
	end

	self:doLockGuard(self.doStopTimelineEvents)

	self.isEnd = true

	AbilityObject.clearObject(self)
	self:resetData()

	self.activeNotifyStates = {}

	self.owner:refreshAbilityMask(self.ability)
end

return EditorActionTimeline
