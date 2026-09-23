-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\GamePlayClass\\ClientGamePlayRacingTemple.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local ClientGamePlayEntity = require("Entities.SpaceEntities.GamePlayClass.ClientGamePlayEntity")
local Time = require("Core.Common.Time")
local SandboxConst = require("Common.Const.SandboxConst")
local MessageName = require("Const.MessageName")
local ClientUtils = require("Utils.ClientUtils")
local ClientGamePlayRacingTemple = class.Class("ClientGamePlayRacingTemple", ClientGamePlayEntity)

function ClientGamePlayRacingTemple:init(dict)
	ClientGamePlayRacingTemple.super.init(self, dict)

	self.targetList = dict.targetList
	self.switchId = dict.switchId
	self.racingId = dict.racingId
	self.countdown = dict.countdown

	return true
end

function ClientGamePlayRacingTemple:destroy()
	self.raceSampleLevelItem = nil

	pg.global.ui.racingDungeon:close()
	ClientGamePlayRacingTemple.super.destroy(self)
end

function ClientGamePlayRacingTemple:enterSpace(space)
	local context = {
		refRacingPlay = self
	}

	pg.global.ui.racingDungeon:open(context)

	self.space = space
	self.sandbox = space:getSandbox(self.sandboxId)

	if self.sandbox then
		self.sandbox:addGameplay(self)
	end

	facade:sendMsgToUI(MessageName.RACESAMPLE_STAGE_CHANGE, {
		stage = self.status
	})
end

function ClientGamePlayRacingTemple:onSandboxReady()
	facade:sendLuaEvent("RacingTempleReady" .. tostring(self.sandboxId), self)
end

function ClientGamePlayRacingTemple:bindListenNode(shellNode)
	self.shellNode = shellNode

	if self.shellNode then
		self.raceSampleId = self.shellNode:GetRaceSampleId()

		self.shellNode:SetInitData(self.status, self.curStage, self.startTime, self.recordTime, self.targetList or {})
		self:initRaceSampleItem()
	end
end

function ClientGamePlayRacingTemple:initRaceSampleItem()
	if self.raceSampleId and self.raceSampleId ~= 0 then
		self.raceSampleLevelItem = self.sandbox.levelItems[self.raceSampleId]
	end
end

function ClientGamePlayRacingTemple:getRacingSampleInfo()
	if self.raceSampleLevelItem and self.raceSampleLevelItem.getSampleInfo then
		local valid, sampleTime, samplePercent = self.raceSampleLevelItem:getSampleInfo()

		return valid, sampleTime, samplePercent
	end

	return nil
end

function ClientGamePlayRacingTemple:calcScoreAndRatio(sampleTime, samplePercent)
	local curTime = Time.secondCache - self.startTime
	local diffTime = curTime - sampleTime

	samplePercent = math.clamp(samplePercent, 0, 1)

	if #self.targetList >= 2 then
		local ARange = self.targetList[2] - self.targetList[1]
		local halfARange = ARange * 0.5

		halfARange = halfARange * (2 * samplePercent^2 - samplePercent^3 + (1 - samplePercent)^2 * math.sqrt(samplePercent))

		local halfBRange = halfARange

		if diffTime < -halfARange then
			return SandboxConst.RaceScore.S, 1
		elseif halfARange < diffTime then
			local bDiffTime = diffTime - halfARange
			local percent = 0

			if halfARange > 0 then
				percent = (2 * halfBRange - bDiffTime) / (2 * halfBRange)
			end

			percent = math.clamp(percent, 0, 1)

			return SandboxConst.RaceScore.B, percent
		else
			local percent = 0.5

			if halfARange > 0 then
				percent = (halfARange - diffTime) / (2 * halfARange)
			end

			return SandboxConst.RaceScore.A, percent
		end
	end

	return nil
end

function ClientGamePlayRacingTemple:getPlayTime()
	return Time.secondCache - self.startTime
end

function ClientGamePlayRacingTemple:restartRacing()
	if self.shellNode then
		pg.me.inRestartRacing = true

		self.shellNode:OnGamePlayRestart()
	end
end

function ClientGamePlayRacingTemple:finishRacing()
	self:serverMsg("RPC_CS_FinishRacing", pg.me.id)
end

function ClientGamePlayRacingTemple:RPC_SC_StartCountDown()
	pg.me.inRestartRacing = false

	pg.global.ui.racingDungeon:startCountDown()
end

function ClientGamePlayRacingTemple:RPC_SC_FinishRacing(playerId, castTime, lastRecord)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientGamePlayRacingTemple:RPC_SC_FinishRacing", playerId, castTime, lastRecord)
	end

	pg.global.ui.racingDungeon:onFinishRacing(castTime)
end

function ClientGamePlayRacingTemple:onStatusChange()
	if self.shellNode then
		self.shellNode:OnGamePlayStatusChange(self.status)
	end

	self.lastStatus = self.status

	facade:sendMsgToUI(MessageName.RACESAMPLE_STAGE_CHANGE, {
		stage = self.status
	})
end

function ClientGamePlayRacingTemple:onStartTimeChange(oldv, newv)
	if self.shellNode then
		self.shellNode.startTime = self.startTime
	end
end

function ClientGamePlayRacingTemple:isPlaying()
	return self.status == SandboxConst.RacingDungeonState.RACING
end

function ClientGamePlayRacingTemple:onRecordChange(oldv, newv)
	if self.shellNode then
		self.shellNode.recordTime = self.recordTime
	end
end

function ClientGamePlayRacingTemple:RPC_SC_OnStageChange(curStage)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("ClientGamePlayRacingTemple:RPC_SC_OnStageChange", curStage, self.curStage)
	end

	pg.global.ui.racingDungeon:onStageChange(self.curStage)

	if self.shellNode then
		self.shellNode:OnGamePlayStageChange(self.curStage)
	end
end

return ClientGamePlayRacingTemple
