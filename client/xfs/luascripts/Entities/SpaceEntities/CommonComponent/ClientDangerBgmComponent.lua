-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientDangerBgmComponent.lua

local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local AttributeConst = require("Common.Const.AttributeConst")
local Utils = require("Common.Utils.Utils")
local AudioConst = require("Const.AudioConst")
local SceneData = require("Data.scene_data")
local SceneUtils = require("Common.Utils.SceneUtils")
local ClientDangerBgmComponent = Class.Component("ClientDangerBgmComponent")
local DANGER_RANGE = 20
local DEBUG_TAG = "[ClientDangerBgmComponent]"

local function appendDangerStage(stages, bgm, dangerValue, logger, stageName)
	if string.isNilOrEmpty(bgm) or #dangerValue < 2 then
		logger:error("%s appendDangerStage config error, stage=%s", DEBUG_TAG, stageName)

		return
	end

	stages[#stages + 1] = {
		bgm = bgm,
		enterValue = dangerValue[1],
		leaveValue = dangerValue[2]
	}
end

function ClientDangerBgmComponent:ctor()
	self.grabEggDangerRangeEvent = nil
	self.dangerEntities = nil
	self.grabEggDangerStages = nil
	self.grabEggDangerValue = 0
	self.grabEggDangerStage = 0
end

function ClientDangerBgmComponent:startDangerDetect()
	self.dangerEntities = {}
	self.grabEggDangerStages = {}
	self.grabEggDangerValue = 0
	self.grabEggDangerStage = 0

	self:setupGrabEggDangerBgm()

	self.grabEggDangerRangeEvent = self:addRangeEvent(Const.TRAP_EVENT_ID_GRAB_EGG_DANGER_BGM, DANGER_RANGE, DANGER_RANGE)
end

function ClientDangerBgmComponent:stopGrabEggDangerDetect()
	if not self.grabEggDangerRangeEvent and not self.grabEggDangerStages then
		return
	end

	local rangeEvent = self.grabEggDangerRangeEvent

	if rangeEvent then
		self.grabEggDangerRangeEvent = nil

		self:removeRangeEvent(rangeEvent, true)
	end

	self:clearGrabEggDangerEntities()
	self:stopGrabEggDangerBgm()

	self.dangerEntities = nil
	self.grabEggDangerStages = nil
end

function ClientDangerBgmComponent:setupGrabEggDangerBgm()
	local sceneInfo = self.sceneInfo
	local stages = self.grabEggDangerStages

	appendDangerStage(stages, sceneInfo.lowDangerBgm, sceneInfo.lowDangerValue, self.logger, "low")
	appendDangerStage(stages, sceneInfo.midDangerBgm, sceneInfo.midDangerValue, self.logger, "mid")
	appendDangerStage(stages, sceneInfo.highDangerBgm, sceneInfo.highDangerValue, self.logger, "high")
end

function ClientDangerBgmComponent:stopGrabEggDangerBgm()
	pg.game.audio:stopBgm(AudioConst.BgmPriority.GrabEggDanger)

	self.grabEggDangerValue = 0
	self.grabEggDangerStage = 0
end

function ClientDangerBgmComponent:setGrabEggDangerValue(value)
	local stages = self.grabEggDangerStages

	self.grabEggDangerValue = math.max(0, value or 0)

	local nextStage = self.grabEggDangerStage

	while nextStage < #stages and self.grabEggDangerValue >= stages[nextStage + 1].enterValue do
		nextStage = nextStage + 1
	end

	while nextStage > 0 and self.grabEggDangerValue <= stages[nextStage].leaveValue do
		nextStage = nextStage - 1
	end

	if nextStage == self.grabEggDangerStage then
		return
	end

	self.grabEggDangerStage = nextStage

	if nextStage > 0 then
		pg.game.audio:playBgm(stages[nextStage].bgm, AudioConst.BgmPriority.GrabEggDanger)
	else
		pg.game.audio:stopBgm(AudioConst.BgmPriority.GrabEggDanger)
	end
end

function ClientDangerBgmComponent:refreshGrabEggDangerValue()
	local totalDangerValue = 0

	for actorId, entity in pairs(self.dangerEntities or EMPTY_TABLE) do
		if not entity or entity.isDestroyed then
			self.dangerEntities[actorId] = nil
		else
			local configData = entity.getConfigData and entity:getConfigData()
			local baseDangerValue = configData and configData.dangerousValue or 0
			local extraDangerValue = entity.actorCombatAttribute and entity.actorCombatAttribute:getRawAttribValue(AttributeConst.rob_egg_danger_add_v) or 0
			local entityDangerValue = baseDangerValue + (extraDangerValue or 0)

			totalDangerValue = totalDangerValue + entityDangerValue
		end
	end

	self:setGrabEggDangerValue(totalDangerValue)
end

function ClientDangerBgmComponent:addGrabEggDangerEntity(entity)
	local actorId = entity and entity.actorId

	if not actorId or self.dangerEntities[actorId] or not Utils.isWildPuppet(entity) then
		return
	end

	self.dangerEntities[actorId] = entity

	self:refreshGrabEggDangerValue()
end

function ClientDangerBgmComponent:removeGrabEggDangerEntity(actorId)
	local info = self.dangerEntities[actorId]

	if not info then
		return
	end

	self.dangerEntities[actorId] = nil

	self:refreshGrabEggDangerValue()
end

function ClientDangerBgmComponent:clearGrabEggDangerEntities()
	if self.dangerEntities then
		table.clear(self.dangerEntities)
	end
end

function ClientDangerBgmComponent:onEnterSpace()
	if self.grabEggDangerRangeEvent or not self.isMainPlayer or not self.space or not self.space.isGrabEgg or not self.space:isGrabEgg() then
		return
	end

	local mainSceneId = SceneUtils.getMainSceneId(self.space.sceneId)

	self.sceneInfo = SceneData[mainSceneId] or EMPTY_TABLE

	if string.isNilOrEmpty(self.sceneInfo.lowDangerBgm) then
		return
	end

	self:startDangerDetect()
end

function ClientDangerBgmComponent:onLeaveSpace()
	self:stopGrabEggDangerDetect()
end

function ClientDangerBgmComponent:onEnterTrap(actorId, eventId)
	if self.grabEggDangerRangeEvent and eventId == Const.TRAP_EVENT_ID_GRAB_EGG_DANGER_BGM then
		self:addGrabEggDangerEntity(pg.getEntityByActorId(actorId))
	end
end

function ClientDangerBgmComponent:onLeaveTrap(actorId, eventId)
	if self.grabEggDangerRangeEvent and eventId == Const.TRAP_EVENT_ID_GRAB_EGG_DANGER_BGM then
		self:removeGrabEggDangerEntity(actorId)
	end
end

function ClientDangerBgmComponent:destroy()
	self:stopGrabEggDangerDetect()
end

return ClientDangerBgmComponent
