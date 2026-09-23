-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Ability\\Timeline\\ActorTimeline.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local AbilityConst = require("Common.Const.AbilityConst")
local ActionTimeline = require("Common.Ability.Timeline.ActionTimeline")
local CombatLogger = require("Common.Ability.CombatLogger")
local ActionTimelineParams = require("Common.Ability.Timeline.ActionTimelineParams")
local ActorTimeline = Class.LiteClass("ActorTimeline")
local pg = pg
local ToBool = ToBool

function ActorTimeline:ctor(owner)
	self.owner = owner
	self.baseTimeline = ActionTimeline(owner, AbilityConst.ACTION_TIMELINE_LAYER_BASE)
	self.additiveTimeline = ActionTimeline(owner, AbilityConst.ACTION_TIMELINE_LAYER_ADDITIVE)
	self.parallelTimelines = {}
end

function ActorTimeline:init()
	self.baseTimeline:init()
	self.additiveTimeline:init()

	for _, timeline in ipairs(self.parallelTimelines) do
		timeline:init()
	end
end

function ActorTimeline:activate(deltaSeconds)
	self.baseTimeline:tick(deltaSeconds)
	self.additiveTimeline:tick(deltaSeconds)

	for pos = #self.parallelTimelines, 1, -1 do
		self.parallelTimelines[pos]:tick(deltaSeconds)

		if self.owner.isDestroyed then
			return
		end

		if self.parallelTimelines[pos] and not self.parallelTimelines[pos].isPlaying then
			table.remove(self.parallelTimelines, pos)
		end
	end
end

function ActorTimeline:setTimeline(timelineId, playRate, timelineParams, overrideLayer)
	local entity = self.owner

	if not entity then
		return false
	end

	local timelineTemplate = pg.global.abilityMgr:getTimelineTemplate(timelineId)

	if not timelineTemplate then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			CombatLogger.warn("@jqj timelineTemplate not found", timelineId)
		end

		return false
	end

	self:tryHandleAttackData(timelineParams)

	local layer = timelineTemplate.layer

	layer = overrideLayer or layer

	if layer == AbilityConst.ACTION_TIMELINE_LAYER_BASE then
		self.baseTimeline:setTimeline(timelineId, playRate, timelineParams)
	elseif layer == AbilityConst.ACTION_TIMELINE_LAYER_ADDITIVE then
		self.additiveTimeline:setTimeline(timelineId, playRate, timelineParams)
	elseif layer == AbilityConst.ACTION_TIMELINE_LAYER_PARALLEL then
		local actionTimeline = ActionTimeline.new(self.owner, layer)

		self.parallelTimelines[#self.parallelTimelines + 1] = actionTimeline

		actionTimeline:setTimeline(timelineId, playRate, timelineParams)
	else
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			CombatLogger.error("ActorTimeline:setCombatActionTimeline layer error", timelineId, layer)
		end

		return false
	end

	return true
end

function ActorTimeline:tryHandleAttackData(timelineParams)
	if timelineParams.srcCalcResultNodeId and timelineParams.getAttackDataByServerRef then
		local attackData = timelineParams:getAttackDataByServerRef(timelineParams.srcCtxType, timelineParams.srcTemplateId, timelineParams.srcCalcResultNodeId)

		if attackData then
			timelineParams.attackData = attackData
		else
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				CombatLogger.error("HitActionTimelineParam ref lookup failed", timelineParams.srcCtxType, timelineParams.srcTemplateId, timelineParams.srcCalcResultNodeId)
			end

			timelineParams.attackData = timelineParams.attackData or {}
		end
	end
end

function ActorTimeline:stopTimeline(layer, timelineId)
	local entity = self.owner

	if not entity then
		return false
	end

	if layer == AbilityConst.ACTION_TIMELINE_LAYER_BASE then
		if not ToBool(timelineId) or self.baseTimeline.timelineId == timelineId then
			if LoggerManager.checkLogger(LoggerConst.DEBUG) then
				CombatLogger.debug("stop base layer timeline", self.baseTimeline.timeline.id)
			end

			self.baseTimeline:stopTimeline()
		end
	elseif layer == AbilityConst.ACTION_TIMELINE_LAYER_ADDITIVE then
		if not ToBool(timelineId) or self.additiveTimeline.timelineId == timelineId then
			if LoggerManager.checkLogger(LoggerConst.DEBUG) then
				CombatLogger.debug("stop additive layer timeline", self.additiveTimeline.timeline.id)
			end

			self.additiveTimeline:stopTimeline()
		end
	else
		for idx, timeline in ipairs(self.parallelTimelines) do
			if not ToBool(timelineId) or timeline.timelineId == timelineId then
				timeline:stopTimeline()
			end
		end
	end

	return true
end

function ActorTimeline:resetTimeline(layer, timelineId)
	local entity = self.owner

	if not entity then
		return false
	end

	if layer == AbilityConst.ACTION_TIMELINE_LAYER_BASE then
		if not ToBool(timelineId) or self.baseTimeline.timelineId == timelineId then
			if LoggerManager.checkLogger(LoggerConst.DEBUG) then
				CombatLogger.debug("@hyj reset base layer timeline", self.baseTimeline.timeline.id)
			end

			self.baseTimeline:resetTimeline()
		end
	elseif layer == AbilityConst.ACTION_TIMELINE_LAYER_ADDITIVE then
		if not ToBool(timelineId) or self.additiveTimeline.timelineId == timelineId then
			if LoggerManager.checkLogger(LoggerConst.DEBUG) then
				CombatLogger.debug("@hyj reset additive layer timeline", self.additiveTimeline.timeline.id)
			end

			self.additiveTimeline:resetTimeline()
		end
	else
		for idx, timeline in ipairs(self.parallelTimelines) do
			if not ToBool(timelineId) or timeline.timelineId == timelineId then
				timeline:resetTimeline()
			end
		end
	end

	return true
end

function ActorTimeline:stopCombatActionTimeline()
	local timeline = self.baseTimeline

	if timeline.timelineParams.timelineKind == AbilityConst.TIMELINE_COMBAT then
		self:stopTimeline(AbilityConst.ACTION_TIMELINE_LAYER_BASE, timeline.timelineId)
	end

	timeline = self.additiveTimeline

	if timeline.timelineParams.timelineKind == AbilityConst.TIMELINE_COMBAT then
		self:stopTimeline(AbilityConst.ACTION_TIMELINE_LAYER_ADDITIVE, timeline.timelineId)
	end

	for idx, timeline in ipairs(self.parallelTimelines) do
		if timeline.timelineParams.timelineKind == AbilityConst.TIMELINE_COMBAT then
			self:stopTimeline(AbilityConst.ACTION_TIMELINE_LAYER_PARALLEL, timeline.timelineId)
		end
	end
end

function ActorTimeline:resetCombatActionTimeline()
	local timeline = self.baseTimeline

	if timeline.timelineParams.timelineKind == AbilityConst.TIMELINE_COMBAT then
		self:resetTimeline(AbilityConst.ACTION_TIMELINE_LAYER_BASE, timeline.timelineId)
	end

	timeline = self.additiveTimeline

	if timeline.timelineParams.timelineKind == AbilityConst.TIMELINE_COMBAT then
		self:resetTimeline(AbilityConst.ACTION_TIMELINE_LAYER_ADDITIVE, timeline.timelineId)
	end

	for idx, timeline in ipairs(self.parallelTimelines) do
		if timeline.timelineParams.timelineKind == AbilityConst.TIMELINE_COMBAT then
			self:resetTimeline(AbilityConst.ACTION_TIMELINE_LAYER_PARALLEL, timeline.timelineId)
		end
	end
end

function ActorTimeline:stopTimelineByTime(layer, timelineId)
	local timeline = self.baseTimeline

	if timeline.layer == layer and timeline.timelineId == timelineId then
		timeline:stopTimelineInternal(false)
	end

	timeline = self.additiveTimeline

	if timeline.layer == layer and timeline.timelineId == timelineId then
		timeline:stopTimelineInternal(false)
	end

	for idx, timeline in ipairs(self.parallelTimelines) do
		if timeline.layer == layer and timeline.timelineId == timelineId then
			timeline:stopTimelineInternal(false)
		end
	end
end

function ActorTimeline:stopAll()
	self.baseTimeline:stopTimeline()
	self.additiveTimeline:stopTimeline()

	for _, timeline in ipairs(self.parallelTimelines) do
		timeline:stopTimeline()
	end

	self.parallelTimelines = {}
end

function ActorTimeline:setFrameFreeze(timelineId, playRate, duration)
	if self.baseTimeline.timelineId == timelineId and self.baseTimeline.isPlaying then
		self.baseTimeline:setFrameFreeze(playRate, duration)
	elseif self.additiveTimeline.timelineId == timelineId and self.additiveTimeline.isPlaying then
		self.additiveTimeline:setFrameFreeze(playRate, duration)
	else
		for _, timeline in ipairs(self.parallelTimelines) do
			if timeline.isPlaying and timeline.timelineId == timelineId then
				timeline:setFrameFreeze(playRate, duration)
			end
		end
	end
end

function ActorTimeline:getTimelineInstance(timelineId)
	if self.baseTimeline.isPlaying and self.baseTimeline.timelineId == timelineId then
		return self.baseTimeline
	end

	if self.additiveTimeline.isPlaying and self.additiveTimeline.timelineId == timelineId then
		return self.additiveTimeline
	end

	for _, timeline in ipairs(self.parallelTimelines) do
		if timeline.isPlaying and timeline.timelineId == timelineId then
			return timeline
		end
	end
end

return ActorTimeline
