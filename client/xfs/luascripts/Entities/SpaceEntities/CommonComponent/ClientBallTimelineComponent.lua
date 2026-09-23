-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientBallTimelineComponent.lua

local Class = require("Core.Framework.Class")
local LightActionTimeline = require("Common.Ability.Timeline.LightActionTimeline")
local AbilityConst = require("Common.Const.AbilityConst")
local TimerManager = require("Core.Timer.TimerManager")
local CallbackHandler = require("Core.Common.CallbackHandler")
local CombatCasterInfo = require("Common.Ability.CombatCasterInfo")
local ClientBallTimelineComponent = Class.Component("ClientBallTimelineComponent")

function ClientBallTimelineComponent:init(bdict)
	self.ballTimeline = LightActionTimeline(self, AbilityConst.ACTION_TIMELINE_LAYER_BASE)

	self.ballTimeline:init()

	self.jumpingTimelineRefCnt = 0
	self.combatAction = pg.global.abilityMgr.combatAction
	self.timelineId = nil
end

function ClientBallTimelineComponent:destroy()
	self:stopBallTimelineTick()

	if self.ballTimeline then
		self.ballTimeline:stopTimeline()
		self.ballTimeline:clearObject()
	end

	self.ballTimeline = nil
	self.combatAction = nil
	self.timelineId = nil
end

function ClientBallTimelineComponent:getTimelineInstance(timelineInsId)
	return self.ballTimeline
end

function ClientBallTimelineComponent:stopBallTimelineTick()
	if self.timelineTickTimer then
		TimerManager.delFrameCb(self.timelineTickTimer)

		self.timelineTickTimer = nil
	end
end

function ClientBallTimelineComponent:startBallTimelineTick()
	self:stopBallTimelineTick()

	self.tickTimelineSecond = self:getGameTime()
	self.timelineTickTimer = TimerManager.addRepeatNextFrameCb(function()
		local curTime = self:getGameTime()
		local deltaTime = curTime - self.tickTimelineSecond

		self.tickTimelineSecond = curTime

		if deltaTime < 0 then
			return
		end

		local timeScale = self.getSelfTimeScale and self:getSelfTimeScale() or 1
		local baseTimeRatio = pg.game and pg.game.baseTimeScale or 1

		deltaTime = deltaTime * timeScale * baseTimeRatio

		if self.ballTimeline then
			local tl = self.ballTimeline
			local wasEnd = tl.isEnd

			tl:tick(deltaTime)

			if self.onTimelineEnd and not wasEnd and self.ballTimeline and self.ballTimeline.isEnd then
				local endedId = self.timelineId

				self.onTimelineEnd(self, endedId)
			end
		end
	end)
end

function ClientBallTimelineComponent:playTimeline(timelineId, puppetEnt, callbackName)
	if not pg.global.abilityMgr:getTimelineTemplate(timelineId) then
		return false
	end

	local combatActionTimelineParam = pg.global.abilityMgr.combatParamsPool:get(true)

	combatActionTimelineParam.srcActorId = self.actorId
	combatActionTimelineParam.srcAbilityId = 0
	combatActionTimelineParam.constCasterInfo = CombatCasterInfo(self.actorId)
	combatActionTimelineParam.targetActorId = puppetEnt and puppetEnt.actorId or 0
	combatActionTimelineParam.constCasterInfo.srcActorId = self.actorId
	combatActionTimelineParam.srcType = AbilityConst.SRC_TYPE_NONE
	self.timelineId = timelineId

	if not self.ballTimeline:setTimeline(timelineId, 1, combatActionTimelineParam) then
		self.timelineId = nil

		pg.global.abilityMgr.combatParamsPool:returnObject(combatActionTimelineParam)

		return false
	end

	self.ballTimeline:clearExitCallback()
	self:startBallTimelineTick()
	self.ballTimeline:addExitCallback(function()
		self:stopBallTimelineTick()
	end)

	if callbackName then
		self.ballTimeline:addExitCallback(CallbackHandler(self, callbackName))
	end

	return true
end

return ClientBallTimelineComponent
