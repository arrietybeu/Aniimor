-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Controller\\Utils\\NextSkillAction.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local Lume = require("Core.Common.lume")
local AbilityConst = require("Common.Const.AbilityConst")
local AbilitySettingGlobalConstData = require("Data.ability_setting_global_const_data")
local NextSkillAction = Class.LiteClass("NextSkillAction")
local ToBool = ToBool
local pg = pg

function NextSkillAction:ctor(owner)
	self.owner = owner
	self.interval = AbilitySettingGlobalConstData.keyCacheTime or 0.3
	self.maxLen = (AbilitySettingGlobalConstData.keyCacheNum or 1) + 1
	self.dashCacheInterval = AbilitySettingGlobalConstData.dashCacheTime or 0.1
	self.nextSkillId = 0
	self.startTime = 0
	self.keyQueue = {}
	self.holdSkillId = 0
	self.dashValidStamp = 0
	self.lastAbilityType = nil
end

function NextSkillAction:setOwner(owner)
	self.owner = owner
	self.nextSkillId = 0

	Lume.clear(self.keyQueue)

	self.holdSkillId = 0
end

function NextSkillAction:doDash()
	self.dashValidStamp = (pg.me and pg.me:getGameTime() or 0) + self.dashCacheInterval
	self.dashFromAutoCast = pg.game.controller.autoCastController.autoCastInfo.disableCancel
end

function NextSkillAction:setNextAction(skillId)
	if skillId ~= 0 then
		if skillId ~= self.nextSkillId then
			self.nextSkillId = skillId
			self.startTime = Time.realSecondCache
		else
			self.startTime = Time.realSecondCache
		end
	else
		self:clearNextSkill()
	end

	facade:SendMessageCommand(MessageName.SKILL_COMBO_UPDATE)
end

function NextSkillAction:setNextActionTimeline(timeline, timelineId, combatContext)
	if ToBool(timelineId) then
		if self.nextTimeline == nil or self.nextTimeline[2] ~= timelineId then
			self.nextTimeline = {
				timeline,
				timelineId,
				combatContext
			}
			self.nextTimelineSkillId = combatContext.abilityId
			self.startTime = Time.realSecondCache
		else
			self.startTime = Time.realSecondCache
		end
	else
		self:clearNextTimeline()
	end

	facade:SendMessageCommand(MessageName.SKILL_COMBO_UPDATE)
end

function NextSkillAction:getNextAction()
	return self.nextSkillId
end

function NextSkillAction:clearNextSkill()
	self.nextSkillId = 0
	self.startTime = 0
end

function NextSkillAction:clearNextTimeline()
	self.nextTimeline = nil
	self.startTime = 0
end

function NextSkillAction:clearNextSkillCache()
	self:clearNextSkill()
	self:clearNextTimeline()
	Lume.clear(self.keyQueue)

	self.holdSkillId = 0
end

function NextSkillAction:onNextSkillDone(skillId)
	return
end

function NextSkillAction:clear()
	self:clearNextTimeline()
	self:clearNextSkill()
end

function NextSkillAction:updateSkill(skillId, extraInfo)
	if self.nextSkillId ~= 0 then
		if pg.pawn:inCombo() and pg.game.controller:useSkill(self.nextSkillId, nil, true, extraInfo) then
			Lume.clear(self.keyQueue)
		elseif pg.game.controller:useSkill(skillId, nil, true, extraInfo) then
			Lume.clear(self.keyQueue)
		end
	elseif self.nextTimeline then
		if pg.pawn:inCombo() then
			local timeline = self.nextTimeline[1]
			local timelineId = self.nextTimeline[2]

			pg.pawn:serverMsg("RPC_CS_JumpToNextTimelineByCombo", timeline.layer, timeline.timelineId, timelineId)

			self.nextTimeline = nil

			timeline:continueTimeline(timelineId)
			Lume.clear(self.keyQueue)
		elseif pg.game.controller:useSkill(skillId, nil, true, extraInfo) then
			Lume.clear(self.keyQueue)
		end
	elseif pg.game.controller:useSkill(skillId, nil, true, extraInfo) then
		Lume.clear(self.keyQueue)
	end
end

function NextSkillAction:update()
	if not pg.pawn then
		return
	end

	if pg.me then
		local now = pg.me:getGameTime()

		if self.dashValidStamp ~= 0 then
			if pg.pawn:checkDash(false, self.dashFromAutoCast and AbilityConst.AUTO_CAST_IGNORE_STS) then
				pg.game.controller:onHandleDash(true, AbilityConst.AUTO_CAST_IGNORE_STS)

				self.nextTimeline = nil

				Lume.clear(self.keyQueue)

				self.nextSkillId = 0
				self.dashValidStamp = 0
				self.dashFromAutoCast = false

				return
			end

			if self.dashValidStamp - now < 0 then
				pg.pawn:checkDash(true)

				self.dashValidStamp = 0
				self.dashFromAutoCast = false
			end
		end
	end

	if self.nextTimeline and not self.nextTimeline[1].isPlaying then
		self:clearNextTimeline()
	end

	local nowTime = Time.realSecondCache
	local len = table.nums(self.keyQueue)

	for i = 1, len do
		local skillId, lastTime, _ = unpack(self.keyQueue[1])

		if nowTime - lastTime >= self.interval then
			table.remove(self.keyQueue, 1)
		end
	end

	len = table.nums(self.keyQueue)

	if len > 0 then
		local skillId, lastTime, extraInfo = unpack(self.keyQueue[1])

		self:updateSkill(skillId, extraInfo)
	elseif ToBool(self.holdSkillId) then
		self:updateSkill(self.holdSkillId)
	end
end

function NextSkillAction:pushSkill(skillId, extraInfo)
	local newAbilityType = AbilityUtils.getBpAbilityType(skillId)

	if self.lastAbilityType and newAbilityType ~= self.lastAbilityType then
		Lume.clear(self.keyQueue)

		self.nextSkillId = 0
	else
		local oldIndex

		for index, info in ipairs(self.keyQueue) do
			if info[1] == skillId then
				oldIndex = index

				break
			end
		end

		if oldIndex ~= nil then
			table.remove(self.keyQueue, oldIndex)
		end
	end

	self.lastAbilityType = newAbilityType

	table.insert(self.keyQueue, {
		skillId,
		Time.realSecondCache,
		extraInfo
	})

	if table.nums(self.keyQueue) > self.maxLen then
		table.remove(self.keyQueue, 1)
	end

	self:update()
end

return NextSkillAction
