-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Target\\TargetSystem.lua

local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local UIConst = require("Const.UIConst")
local MessageName = require("Const.MessageName")
local SystemBase = require("GameApp.Core.SystemBase")
local LoggerConst = require("Core.Log.LoggerConst")
local ClientUtils = require("Utils.ClientUtils")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("TargetSystem")
local TargetUtils = require("GameApp.Target.TargetUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local CommonSwitch = require("Common.CommonSwitch")
local GamePlayTargetConst = require("Common.Const.GamePlayTargetConst")
local lume = require("Core.Common.lume")
local TargetSystem = Class.LightClass("TargetSystem", SystemBase)

function TargetSystem:onCtor()
	return
end

function TargetSystem:onInit()
	self.targetType = 0
	self.targetId = 0
	self.targetTimerId = 0
	self.isChange = true
	self.finishTimer = false
	self.topCurValue = nil
	self.topTotalTargetVal = nil
	self.racingStatus = 0
	self.addTargetPathInfo = {}
	self.playedFinishAnims = {}
	self.lastShownTargetId = nil
end

function TargetSystem:getFinishTimer()
	return self.finishTimer
end

function TargetSystem:getTargetId()
	return self.targetId
end

function TargetSystem:getTargetType()
	return self.targetType
end

function TargetSystem:setTargetType(targetType)
	self.targetType = targetType
end

function TargetSystem:getTargetChange()
	return self.isChange
end

function TargetSystem:setTargetChange(flag)
	self.isChange = flag
end

function TargetSystem:getRacingStatus()
	return self.racingStatus
end

function TargetSystem:setRacingStatus(racingStatus)
	self.racingStatus = racingStatus
end

function TargetSystem:onShowTarget(targetId)
	if self.lastShownTargetId and self.lastShownTargetId ~= targetId then
		self:clearPlayedFinishAnims(self.lastShownTargetId)
	end

	self.lastShownTargetId = targetId

	local curGamePlayId = TargetUtils.isReenterShowTarget()

	if curGamePlayId and curGamePlayId == targetId then
		self.targetId = targetId
		self.targetType = TargetUtils.getTargetConfigGroup(targetId)

		if pg.global.ui and pg.global.ui.tips then
			pg.global.ui.tips:setTargetRootVisible(true)
		end
	end
end

function TargetSystem:getNeedPlayFinishAnim(targetId, subTargetList)
	local needPlayFinishAnim = {}

	if subTargetList then
		for _, v in ipairs(subTargetList) do
			needPlayFinishAnim[v] = true
		end
	end

	return needPlayFinishAnim
end

function TargetSystem:tryConsumeFinishAnim(targetId, seqid)
	if not targetId or seqid == nil then
		return false
	end

	if not self.playedFinishAnims[targetId] then
		self.playedFinishAnims[targetId] = {}
	end

	local playedSet = self.playedFinishAnims[targetId]

	if playedSet[seqid] then
		return false
	end

	playedSet[seqid] = true

	return true
end

function TargetSystem:clearPlayedFinishAnims(targetId)
	if self.playedFinishAnims then
		self.playedFinishAnims[targetId] = nil
	end
end

function TargetSystem:onDelTarget(targetId)
	local curGamePlayId = TargetUtils.isReenterShowTarget()

	if curGamePlayId == nil or curGamePlayId == -1 or curGamePlayId == targetId then
		self.targetId = 0
		self.targetType = 0

		self:resetTopCurValue()

		if pg.global.ui and pg.global.ui.tips then
			pg.global.ui.tips:setTargetRootVisible(false)
		end
	end
end

function TargetSystem:resetTarget(targetId)
	local currentTargetMap = TargetUtils.getTargetCurrentProgress(targetId)

	if pg.me and currentTargetMap and currentTargetMap[1] then
		pg.me:resetTarget(currentTargetMap[1])
	end
end

function TargetSystem:seTopTotalTargetVal(topTotalTargetVal)
	if not self.topTotalTargetVal then
		self.topTotalTargetVal = {}
	end

	self.topTotalTargetVal[1] = topTotalTargetVal or 0
end

function TargetSystem:setTopProgress(topCurValue, topTotalTargetVal, seqid1)
	local seqid = seqid1 or 1
	local targetConfig = TargetUtils.getTargetConditions(nil, seqid)

	if targetConfig == nil then
		return
	end

	if not self.topCurValue then
		self.topCurValue = {}
	end

	self.topCurValue[seqid] = topCurValue or targetConfig.curValue

	if not self.topTotalTargetVal then
		self.topTotalTargetVal = {}
	end

	if topTotalTargetVal and topTotalTargetVal > 0 then
		self.topTotalTargetVal[seqid] = topTotalTargetVal
	elseif pg.me and pg.me.levelItemTargetCount and pg.me.levelItemTargetCount > 0 then
		self.topTotalTargetVal[seqid] = pg.me.levelItemTargetCount
	elseif targetConfig.conditionId and targetConfig.conditionId > 0 and not lume.findInList(GamePlayTargetConst.INVALUETRIGGER, targetConfig.conditionId) then
		self.topTotalTargetVal[seqid] = TargetUtils.getConditionTargetValue(targetConfig.conditionId, seqid)
	else
		self.topTotalTargetVal[seqid] = 1
	end

	if not self.desc then
		self.desc = {}
	end

	self.desc[seqid] = targetConfig.desc

	if self.targetTimerId ~= nil and self.targetTimerId > 0 and pg.global.ui and pg.global.ui.tips then
		pg.global.ui.tips:refreshCountDownData(self.targetTimerId, {
			infoText = TargetUtils.getTargetTimerText(self.targetTimerId)
		})
	end
end

function TargetSystem:getTopProgress(seqid)
	local seqid1 = seqid or 1

	if self.topCurValue == nil or self.topTotalTargetVal == nil then
		return
	end

	return self.desc[seqid1], self.topCurValue[seqid1], self.topTotalTargetVal[seqid1]
end

function TargetSystem:resetTopCurValue()
	self.topCurValue = nil
end

function TargetSystem:getTargetTimerId()
	return self.targetTimerId
end

function TargetSystem:onTimerStart(timerId)
	if not CommonSwitch.TARGET then
		return
	end

	self.targetTimerId = timerId

	local timerConfig = TargetUtils.getTargetTimerConfig(timerId)
	local infoText = TargetUtils.getTargetTimerText(timerId)

	if timerConfig then
		local function finishCb()
			self.finishTimer = true

			LuaUIUtils.commonHideCountDown(timerId)
		end

		LuaUIUtils.commonShowCountDown(timerId, timerConfig.value, {
			positiveTiming = timerConfig.type == Const.TARGET_TIMER_TYPE,
			infoText = pg.getLocalizationText(infoText),
			finishCb = finishCb
		})
	end
end

function TargetSystem:onTimerClose(timerId, state)
	LuaUIUtils.commonHideCountDown(self.targetTimerId)
end

function TargetSystem:onTimerTxt(gameStringKey)
	if not CommonSwitch.TARGET then
		return
	end

	if pg.global.ui and pg.global.ui.tips then
		pg.global.ui.tips:refreshCountDownData(self.targetTimerId, {
			infoText = pg.getGameString(gameStringKey) or ""
		})
	end
end

function TargetSystem:onResetTimerTxt()
	if not CommonSwitch.TARGET then
		return
	end

	if pg.global.ui and pg.global.ui.tips then
		pg.global.ui.tips:onResetTimerTxt(self.targetTimerId)
	end
end

function TargetSystem:onTimerUpdate(timerId, startTimer)
	if not CommonSwitch.TARGET then
		return
	end

	self.targetTimerId = timerId

	local timerConfig = TargetUtils.getTargetTimerConfig(timerId)
	local infoText = TargetUtils.getTargetTimerText(timerId)

	if timerConfig then
		local function finishCb()
			self.finishTimer = true

			LuaUIUtils.commonHideCountDown(timerId)
		end

		LuaUIUtils.commonShowCountDown(timerId, timerConfig.value - startTimer, {
			positiveTiming = timerConfig.type == Const.TARGET_TIMER_TYPE,
			infoText = pg.getLocalizationText(infoText),
			finishCb = finishCb
		})
	end
end

function TargetSystem:onClear()
	self.targetType = nil
	self.isChange = nil

	if self.targetTimerId and self.targetTimerId > 0 then
		LuaUIUtils.commonHideCountDown(self.targetTimerId)
	end

	self.targetTimerId = nil
	self.topCurValue = nil
	self.targetId = 0
	self.topTotalTargetVal = nil
	self.desc = nil

	table.clear(self.addTargetPathInfo)

	self.playedFinishAnims = {}
	self.lastShownTargetId = nil
end

function TargetSystem:onDestroy()
	self:onClear()
end

function TargetSystem:onSceneLoaded(sceneId, sceneName)
	return
end

function TargetSystem:onDisconnected()
	if not CommonSwitch.TARGET then
		return
	end

	if pg.global.ui and pg.global.ui.tips and pg.global.ui.tips.target then
		pg.global.ui.tips.target:tryShowReenterTarget()
	end
end

function TargetSystem:addNavPathfindingTarget(info)
	table.insert(self.addTargetPathInfo, info)
end

function TargetSystem:removeAllTargetPathfinding()
	for k, v in pairs(self.addTargetPathInfo) do
		TargetUtils.removeTargetPathingNavEffect(v)
	end

	table.clear(self.addTargetPathInfo)
end

return TargetSystem
