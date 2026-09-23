-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggSettlementRank\\GrabEggSettlementRankModel.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("GrabEggSettlementRankModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local Const = require("Common.Const.Const")
local RobEggConst = require("Common.Const.RobEggConst")
local EggRankBaseData = require("Data.egg_rank_base_data")
local EggRankEvaluationData = require("Data.egg_rank_evaluation_data")
local SysConfigData = require("Data.sys_config_data")
local GrabEggsRankUtils = require("Guis.Utils.GrabEggsRankUtils")
local GrabEggSettlementRankModel = Class.LightClass("GrabEggSettlementRankModel", UIModel)
local MAX_STEP_GUARD = 200
local PERFORMANCE_ICON_FORMAT = "$UI_Img_Season_Rank_Tag_Skill_%02d.png"
local ROMAN_NUMERALS = {
	"I",
	"II",
	"III",
	"IV",
	"V",
	"VI",
	"VII",
	"VIII",
	"IX",
	"X"
}

local function getFirstNumericKey(data)
	local result

	for key in pairs(data or EMPTY_TABLE) do
		if type(key) == "number" and (not result or key < result) then
			result = key
		end
	end

	return result
end

local function convertSettleInfo(settleInfo)
	if not settleInfo then
		return nil
	end

	local eggLv = settleInfo.eggLv
	local secEggLv = settleInfo.secEggLv
	local eggStar = settleInfo.eggStar
	local eggScore = settleInfo.eggScore
	local baseScore = tonumber(settleInfo.score) or 0
	local scoreFactor = math.max(1, tonumber(settleInfo.scoreFactor) or 1)
	local totalScore = baseScore > 0 and math.floor(baseScore * scoreFactor) or baseScore

	return {
		preBigRank = eggLv and eggLv[1],
		curBigRank = eggLv and eggLv[2],
		preSmallRank = secEggLv and secEggLv[1],
		curSmallRank = secEggLv and secEggLv[2],
		preEggNum = eggStar and eggStar[1],
		curEggNum = eggStar and eggStar[2],
		preScore = eggScore and eggScore[1],
		curScore = eggScore and eggScore[2],
		performance = settleInfo.performance,
		baseScore = baseScore,
		scoreFactor = scoreFactor,
		totalScore = totalScore,
		negative = settleInfo.negative,
		hardLv = tonumber(settleInfo.hardLv),
		protectReason = tonumber(settleInfo.protectReason) or 0
	}
end

function GrabEggSettlementRankModel:setRankInfo(rankInfo, difficulty)
	self.rankInfo = convertSettleInfo(rankInfo)

	local hardLv = self.rankInfo and self.rankInfo.hardLv

	if not hardLv or hardLv <= 0 then
		hardLv = tonumber(difficulty)
	end

	self.difficulty = hardLv
	self.preAllScore = nil
	self.curAllScore = nil
end

function GrabEggSettlementRankModel:getRankInfo()
	return self.rankInfo
end

function GrabEggSettlementRankModel:makePerformanceTag(performanceId, performanceInfo)
	if not performanceInfo then
		return nil
	end

	performanceId = tonumber(performanceInfo.id) or tonumber(performanceId)

	local quality = tonumber(performanceInfo.quality)
	local evaluationCfg = EggRankEvaluationData[performanceId]

	if not evaluationCfg or not quality or quality < Const.RobEggPerformanceQuality.Level1 or quality > Const.RobEggPerformanceQuality.Level4 then
		logger:warn("invalid performance tag, id:%s quality:%s", tostring(performanceId), tostring(performanceInfo.quality))

		return nil
	end

	return {
		id = performanceId,
		quality = quality,
		score = performanceInfo.score,
		name = evaluationCfg.name,
		icon = evaluationCfg.icon or string.format(PERFORMANCE_ICON_FORMAT, performanceId)
	}
end

function GrabEggSettlementRankModel:getPerformanceTagLists()
	local info = self:getRankInfo()
	local leftTags = {}
	local rightTags = {}
	local performanceKeys = {}

	for performanceId in pairs(info and info.performance or EMPTY_TABLE) do
		performanceKeys[#performanceKeys + 1] = performanceId
	end

	table.sort(performanceKeys, function(left, right)
		local leftNumber = tonumber(left)
		local rightNumber = tonumber(right)

		if leftNumber and rightNumber then
			return leftNumber < rightNumber
		end

		return tostring(left) < tostring(right)
	end)

	for _, performanceId in ipairs(performanceKeys) do
		local performanceInfo = info.performance[performanceId]
		local tag = self:makePerformanceTag(performanceId, performanceInfo)

		if tag then
			leftTags[#leftTags + 1] = tag
		end
	end

	return leftTags, rightTags
end

function GrabEggSettlementRankModel:getTotalScore()
	local info = self:getRankInfo()

	return info and info.totalScore or 0
end

function GrabEggSettlementRankModel:isRankScoreDoubled()
	local info = self:getRankInfo()

	return info ~= nil and (tonumber(info.scoreFactor) or 1) > 1
end

function GrabEggSettlementRankModel:isNoviceScoreProtected()
	local info = self:getRankInfo()

	return info ~= nil and info.protectReason == RobEggConst.ROBEGG_LEVEL_SCORE_PROTECT_REASON.Newer
end

function GrabEggSettlementRankModel:getRankScoreDoubleRemainingTimes()
	return GrabEggsRankUtils.getRankScoreDoubleInfo().remainingTimes
end

function GrabEggSettlementRankModel:isScoreNegative()
	local info = self:getRankInfo()

	return info and (info.negative or (tonumber(info.totalScore) or 0) < 0) or false
end

local function getDifficultyMaxScoreBigRank(difficulty)
	difficulty = tonumber(difficulty)

	if not difficulty then
		return nil
	end

	for _, limitItem in pairs(SysConfigData.GRABEGG_RANK_SCORE_LIMIT or EMPTY_TABLE) do
		if tonumber(limitItem[1]) == difficulty then
			return tonumber(limitItem[2])
		end
	end

	return nil
end

function GrabEggSettlementRankModel:isRankScoreLimited()
	local info = self:getRankInfo()

	if not info or tonumber(info.totalScore) ~= 0 or self:isScoreNegative() or info.preBigRank ~= info.curBigRank or info.preSmallRank ~= info.curSmallRank or info.preEggNum ~= info.curEggNum or info.preScore ~= info.curScore then
		return false
	end

	local maxScoreBigRank = getDifficultyMaxScoreBigRank(self.difficulty)
	local preBigRank = tonumber(info.preBigRank)

	if not maxScoreBigRank or not preBigRank then
		return false
	end

	return maxScoreBigRank < preBigRank
end

function GrabEggSettlementRankModel:getEvaluationLevel()
	local info = self:getRankInfo()
	local cfg = info and self:getRankConfig(info.preBigRank, info.preSmallRank)
	local thresholds = cfg and cfg.evaluation
	local evaluationScore = tonumber(info and info.baseScore) or 0
	local level = 0

	for index, threshold in ipairs(thresholds or EMPTY_TABLE) do
		if evaluationScore < (tonumber(threshold) or math.huge) then
			break
		end

		level = index
	end

	return math.max(0, math.min(level, 3))
end

function GrabEggSettlementRankModel:isRankInfoValid()
	local info = self.rankInfo

	if not info then
		return false
	end

	return info.preBigRank and info.preSmallRank and info.preEggNum and info.preScore and info.curBigRank and info.curSmallRank and info.curEggNum and info.curScore
end

function GrabEggSettlementRankModel:getRankConfig(bigRank, smallRank)
	return EggRankBaseData[bigRank] and EggRankBaseData[bigRank][smallRank]
end

function GrabEggSettlementRankModel:getRankIconBoardUrl(bigRank)
	return GrabEggsRankUtils.getRankIconBoardUrl(bigRank)
end

function GrabEggSettlementRankModel:getNextRank(bigRank, smallRank)
	if self:getRankConfig(bigRank, smallRank + 1) then
		return bigRank, smallRank + 1
	end

	if EggRankBaseData[bigRank + 1] and EggRankBaseData[bigRank + 1][1] then
		return bigRank + 1, 1
	end

	return bigRank, smallRank
end

function GrabEggSettlementRankModel:getPrevRank(bigRank, smallRank)
	if smallRank > 1 and self:getRankConfig(bigRank, smallRank - 1) then
		return bigRank, smallRank - 1
	end

	local prevBig = bigRank - 1

	if EggRankBaseData[prevBig] then
		local last = 1

		while self:getRankConfig(prevBig, last + 1) do
			last = last + 1
		end

		return prevBig, last
	end

	return bigRank, smallRank
end

function GrabEggSettlementRankModel:isFinalRank(bigRank, smallRank)
	local nextBigRank, nextSmallRank = self:getNextRank(bigRank, smallRank)

	return nextBigRank == bigRank and nextSmallRank == smallRank
end

function GrabEggSettlementRankModel:isFirstRank(bigRank, smallRank)
	local prevBigRank, prevSmallRank = self:getPrevRank(bigRank, smallRank)

	return prevBigRank == bigRank and prevSmallRank == smallRank
end

function GrabEggSettlementRankModel:isTopBigRank(bigRank)
	return bigRank ~= nil and EggRankBaseData[bigRank + 1] == nil
end

function GrabEggSettlementRankModel:getRankPointRange(targetBigRank, targetSmallRank)
	local bigRank = getFirstNumericKey(EggRankBaseData)
	local smallRank = bigRank and getFirstNumericKey(EggRankBaseData[bigRank])
	local startPoint = 0
	local isFirstRank = true

	for _ = 1, MAX_STEP_GUARD do
		local cfg = self:getRankConfig(bigRank, smallRank)

		if not cfg then
			return
		end

		local entryEggNum = isFirstRank and 0 or 1
		local nextBigRank, nextSmallRank = self:getNextRank(bigRank, smallRank)
		local isFinalRank = nextBigRank == bigRank and nextSmallRank == smallRank
		local endPoint

		if not isFinalRank then
			local nextCfg = self:getRankConfig(nextBigRank, nextSmallRank)

			if not nextCfg then
				return
			end

			endPoint = startPoint + math.max(0, (cfg.upNumber or 0) - entryEggNum) * (cfg.point or 0) + (nextCfg.point or 0)
		end

		if bigRank == targetBigRank and smallRank == targetSmallRank then
			return startPoint, endPoint, entryEggNum
		end

		if not endPoint then
			return
		end

		startPoint = endPoint
		bigRank = nextBigRank
		smallRank = nextSmallRank
		isFirstRank = false
	end
end

function GrabEggSettlementRankModel:getStatePointDisplay(bigRank, smallRank, eggNum, score, allScore)
	local cfg = self:getRankConfig(bigRank, smallRank)
	local startPoint, _, entryEggNum = self:getRankPointRange(bigRank, smallRank)

	if not cfg or startPoint == nil then
		local currentPoint = tonumber(allScore) or 0

		return currentPoint, currentPoint
	end

	eggNum = tonumber(eggNum) or 0
	score = tonumber(score) or 0

	local structuralPoint = startPoint + math.max(0, eggNum - (entryEggNum or 0)) * (cfg.point or 0) + score
	local currentPoint = tonumber(allScore)

	if currentPoint == nil then
		currentPoint = structuralPoint
	end

	local fullPoint = currentPoint - score + (cfg.point or 0)

	return currentPoint, math.max(currentPoint, fullPoint)
end

local function playerMatchesRankState(player, bigRank, smallRank, eggNum, score)
	return player and tonumber(player.eggLv) == tonumber(bigRank) and tonumber(player.secEggLv) == tonumber(smallRank) and tonumber(player.eggStar) == tonumber(eggNum) and tonumber(player.eggScore) == tonumber(score)
end

function GrabEggSettlementRankModel:getSettlementAllScores()
	if self.preAllScore ~= nil and self.curAllScore ~= nil then
		return self.preAllScore, self.curAllScore
	end

	local info = self:getRankInfo()

	if not info then
		return 0, 0
	end

	local structuralPre = self:getStatePointDisplay(info.preBigRank, info.preSmallRank, info.preEggNum, info.preScore)
	local structuralCur = self:getStatePointDisplay(info.curBigRank, info.curSmallRank, info.curEggNum, info.curScore)
	local totalScore = tonumber(info.totalScore)
	local preAllScore = structuralPre
	local curAllScore = structuralCur
	local player = pg and pg.me
	local playerAllScore = player and tonumber(player.eggAllScore)

	if playerAllScore ~= nil and playerMatchesRankState(player, info.curBigRank, info.curSmallRank, info.curEggNum, info.curScore) then
		curAllScore = playerAllScore
		preAllScore = totalScore and curAllScore - totalScore or structuralPre
	elseif playerAllScore ~= nil and playerMatchesRankState(player, info.preBigRank, info.preSmallRank, info.preEggNum, info.preScore) then
		preAllScore = playerAllScore
		curAllScore = totalScore and preAllScore + totalScore or structuralCur
	elseif totalScore ~= nil then
		if playerAllScore ~= nil and math.abs((structuralCur or 0) - (structuralPre or 0) - totalScore) > 0 then
			curAllScore = playerAllScore
			preAllScore = curAllScore - totalScore
		else
			preAllScore = structuralPre
			curAllScore = preAllScore + totalScore
		end
	end

	self.preAllScore = math.max(0, tonumber(preAllScore) or 0)
	self.curAllScore = math.max(0, tonumber(curAllScore) or 0)

	return self.preAllScore, self.curAllScore
end

function GrabEggSettlementRankModel:getStepPointDelta(step)
	if step.isLevelDownPop then
		return -1
	end

	local fromScore = step.fromScore or 0
	local toScore = step.toScore or 0

	if step.bigRank ~= step.nextBigRank or step.smallRank ~= step.nextSmallRank then
		return toScore - fromScore
	end

	local cfg = self:getRankConfig(step.bigRank, step.smallRank)

	if not cfg then
		return toScore - fromScore
	end

	local fromEggNum = step.fromEggNum or 0
	local nextEggNum = step.nextEggNum or fromEggNum
	local nextScore = step.nextScore

	if nextScore == nil then
		nextScore = toScore
	end

	return (nextEggNum - fromEggNum) * (cfg.point or 0) + nextScore - fromScore
end

function GrabEggSettlementRankModel:preparePointDisplaySteps(steps)
	local preAllScore, curAllScore = self:getSettlementAllScores()
	local runningPoint = preAllScore

	for _, step in ipairs(steps or EMPTY_TABLE) do
		step.fromPoint, step.fromPointTotal = self:getStatePointDisplay(step.bigRank, step.smallRank, step.fromEggNum, step.fromScore, runningPoint)

		local cfg = self:getRankConfig(step.bigRank, step.smallRank)
		local maxScore = step.maxScore or cfg and cfg.point or 0

		step.fromPointTotal = math.max(step.fromPoint, step.fromPoint - (step.fromScore or 0) + maxScore)
		runningPoint = math.max(0, runningPoint + self:getStepPointDelta(step))
		step.toPoint, step.toPointTotal = self:getStatePointDisplay(step.nextBigRank, step.nextSmallRank, step.nextEggNum, step.nextScore, runningPoint)
	end

	local lastStep = steps and steps[#steps]

	if lastStep and runningPoint ~= curAllScore then
		logger:warn("rank point step mismatch, stepPoint:%s curAllScore:%s", tostring(runningPoint), tostring(curAllScore))

		lastStep.toPoint, lastStep.toPointTotal = self:getStatePointDisplay(lastStep.nextBigRank, lastStep.nextSmallRank, lastStep.nextEggNum, lastStep.nextScore, curAllScore)
	end
end

local function rankLess(aBig, aSmall, bBig, bSmall)
	if aBig ~= bBig then
		return aBig < bBig
	end

	return aSmall < bSmall
end

function GrabEggSettlementRankModel:getOverallDirection()
	local info = self:getRankInfo()

	if not info then
		return "none"
	end

	if rankLess(info.preBigRank, info.preSmallRank, info.curBigRank, info.curSmallRank) then
		return "up"
	end

	if rankLess(info.curBigRank, info.curSmallRank, info.preBigRank, info.preSmallRank) then
		return "down"
	end

	return "none"
end

function GrabEggSettlementRankModel:getInitialState()
	local info = self:getRankInfo()

	if not info then
		return nil
	end

	local cfg = self:getRankConfig(info.preBigRank, info.preSmallRank)

	if not cfg then
		return nil
	end

	local preAllScore = self:getSettlementAllScores()
	local pointScore, pointTotal = self:getStatePointDisplay(info.preBigRank, info.preSmallRank, info.preEggNum, info.preScore, preAllScore)

	return {
		bigRank = info.preBigRank,
		smallRank = info.preSmallRank,
		score = info.preScore,
		eggNum = info.preEggNum,
		cfg = cfg,
		pointScore = pointScore,
		pointTotal = pointTotal
	}
end

function GrabEggSettlementRankModel:getFinalState()
	local info = self:getRankInfo()

	if not info then
		return nil
	end

	local bigRank = info.curBigRank or info.preBigRank
	local smallRank = info.curSmallRank or info.preSmallRank
	local cfg = self:getRankConfig(bigRank, smallRank) or self:getRankConfig(info.preBigRank, info.preSmallRank)
	local _, curAllScore = self:getSettlementAllScores()
	local pointScore, pointTotal = self:getStatePointDisplay(bigRank, smallRank, info.curEggNum, info.curScore, curAllScore)

	return {
		bigRank = bigRank,
		smallRank = smallRank,
		score = info.curScore or 0,
		eggNum = info.curEggNum or 0,
		cfg = cfg,
		pointScore = pointScore,
		pointTotal = pointTotal
	}
end

local function classifyLevelChange(fromBig, nextBig)
	if fromBig ~= nextBig then
		return false, true
	end

	return true, false
end

function GrabEggSettlementRankModel:buildForwardStep(info, bigRank, smallRank, eggNum, score)
	local cfg = self:getRankConfig(bigRank, smallRank)

	if not cfg then
		return nil
	end

	local upNumber = cfg.upNumber or 0
	local isTop = self:isFinalRank(bigRank, smallRank)
	local reachedTargetEgg = bigRank == info.curBigRank and smallRank == info.curSmallRank and eggNum == info.curEggNum

	if not isTop and upNumber <= eggNum and not reachedTargetEgg then
		local nextBigRank, nextSmallRank = self:getNextRank(bigRank, smallRank)
		local nextCfg = self:getRankConfig(nextBigRank, nextSmallRank)

		if not nextCfg then
			return nil
		end

		local isSmallLevelChange, isBigLevelChange = classifyLevelChange(bigRank, nextBigRank)

		return {
			nextEggNum = 1,
			nextScore = 0,
			isLevelUpClear = true,
			newEggIndex = 1,
			bigRank = bigRank,
			smallRank = smallRank,
			fromScore = score,
			toScore = nextCfg.point,
			maxScore = nextCfg.point,
			fromEggNum = eggNum,
			eggNum = eggNum,
			isSmallLevelChange = isSmallLevelChange,
			isBigLevelChange = isBigLevelChange,
			nextBigRank = nextBigRank,
			nextSmallRank = nextSmallRank
		}
	end

	local targetScore = cfg.point
	local targetEggNum = eggNum + 1
	local newEggIndex = targetEggNum
	local nextEggNum = targetEggNum
	local nextScore = 0

	if bigRank == info.curBigRank and smallRank == info.curSmallRank and targetEggNum > info.curEggNum then
		targetEggNum = info.curEggNum
		nextEggNum = info.curEggNum
		targetScore = info.curScore
		nextScore = info.curScore
		newEggIndex = nil
	end

	return {
		isSmallLevelChange = false,
		isBigLevelChange = false,
		bigRank = bigRank,
		smallRank = smallRank,
		fromScore = score,
		toScore = targetScore,
		fromEggNum = eggNum,
		eggNum = targetEggNum,
		newEggIndex = newEggIndex,
		nextBigRank = bigRank,
		nextSmallRank = smallRank,
		nextEggNum = nextEggNum,
		nextScore = nextScore
	}
end

function GrabEggSettlementRankModel:buildBackwardStep(info, bigRank, smallRank, eggNum, score)
	local cfg = self:getRankConfig(bigRank, smallRank)

	if not cfg then
		return nil
	end

	local isSmallLevelChange = false
	local isBigLevelChange = false
	local isLevelDownPop = false
	local nextBigRank = bigRank
	local nextSmallRank = smallRank
	local targetScore, targetEggNum, removeEggIndex, nextEggNum, nextScore

	if bigRank == info.curBigRank and smallRank == info.curSmallRank and eggNum <= info.curEggNum then
		targetScore = info.curScore
		targetEggNum = info.curEggNum
		removeEggIndex = nil
		nextEggNum = info.curEggNum
		nextScore = info.curScore
	elseif eggNum > 0 then
		targetScore = 0
		targetEggNum = eggNum
		removeEggIndex = eggNum
		nextEggNum = eggNum - 1
		nextScore = cfg.point
	else
		if self:isFirstRank(bigRank, smallRank) then
			return nil
		end

		nextBigRank, nextSmallRank = self:getPrevRank(bigRank, smallRank)

		local prevCfg = self:getRankConfig(nextBigRank, nextSmallRank)

		if not prevCfg then
			return nil
		end

		targetScore = 0
		targetEggNum = 0
		removeEggIndex = nil
		nextEggNum = (prevCfg.upNumber or 0) - 1
		nextScore = (prevCfg.point or 0) - 1

		if nextEggNum < 0 then
			nextEggNum = 0
		end

		if nextScore < 0 then
			nextScore = 0
		end

		isSmallLevelChange, isBigLevelChange = classifyLevelChange(bigRank, nextBigRank)
		isLevelDownPop = true
	end

	return {
		bigRank = bigRank,
		smallRank = smallRank,
		fromScore = score,
		toScore = targetScore,
		fromEggNum = eggNum,
		eggNum = targetEggNum,
		removeEggIndex = removeEggIndex,
		isSmallLevelChange = isSmallLevelChange,
		isBigLevelChange = isBigLevelChange,
		isLevelDownPop = isLevelDownPop,
		nextBigRank = nextBigRank,
		nextSmallRank = nextSmallRank,
		nextEggNum = nextEggNum,
		nextScore = nextScore
	}
end

function GrabEggSettlementRankModel:mergeTopRankSteps(steps)
	local merged = {}
	local i = 1

	local function canMerge(step)
		return self:isTopBigRank(step.bigRank) and not step.isSmallLevelChange and not step.isBigLevelChange and (step.newEggIndex ~= nil or step.removeEggIndex ~= nil)
	end

	while i <= #steps do
		local step = steps[i]

		if not canMerge(step) then
			merged[#merged + 1] = step
			i = i + 1
		else
			local isAdd = step.newEggIndex ~= nil
			local j = i

			while j + 1 <= #steps do
				local next = steps[j + 1]

				if not canMerge(next) or next.bigRank ~= step.bigRank or next.smallRank ~= step.smallRank or next.newEggIndex ~= nil ~= isAdd then
					break
				end

				j = j + 1
			end

			if j == i then
				merged[#merged + 1] = step
			else
				local last = steps[j]

				merged[#merged + 1] = {
					isSmallLevelChange = false,
					isBigLevelChange = false,
					bigRank = step.bigRank,
					smallRank = step.smallRank,
					fromScore = step.fromScore,
					toScore = last.toScore,
					fromEggNum = step.fromEggNum,
					eggNum = last.eggNum,
					newEggIndex = isAdd and 1 or nil,
					removeEggIndex = not isAdd and 1 or nil,
					nextBigRank = last.nextBigRank,
					nextSmallRank = last.nextSmallRank,
					nextEggNum = last.nextEggNum,
					nextScore = last.nextScore
				}
			end

			i = j + 1
		end
	end

	return merged
end

function GrabEggSettlementRankModel:buildPlaySteps()
	if not self:isRankInfoValid() then
		return {}
	end

	local info = self:getRankInfo()
	local steps = {}
	local bigRank = info.preBigRank
	local smallRank = info.preSmallRank
	local eggNum = info.preEggNum
	local score = info.preScore
	local isForward = rankLess(info.preBigRank, info.preSmallRank, info.curBigRank, info.curSmallRank) or info.preBigRank == info.curBigRank and info.preSmallRank == info.curSmallRank and (info.preEggNum < info.curEggNum or info.preEggNum == info.curEggNum and info.preScore <= info.curScore)

	for _ = 1, MAX_STEP_GUARD do
		if bigRank == info.curBigRank and smallRank == info.curSmallRank and eggNum == info.curEggNum and score == info.curScore then
			return self:mergeTopRankSteps(steps)
		end

		local step

		if isForward then
			step = self:buildForwardStep(info, bigRank, smallRank, eggNum, score)
		else
			step = self:buildBackwardStep(info, bigRank, smallRank, eggNum, score)
		end

		if not step then
			logger:error("build rank step failed, bigRank:%s smallRank:%s eggNum:%s score:%s", bigRank, smallRank, eggNum, score)

			return {}
		end

		steps[#steps + 1] = step
		bigRank = step.nextBigRank
		smallRank = step.nextSmallRank
		eggNum = step.nextEggNum
		score = step.nextScore
	end

	logger:error("build rank steps overflow")

	return {}
end

function GrabEggSettlementRankModel:getSmallRankCount(bigRank)
	local big = EggRankBaseData[bigRank]

	if not big then
		return 0
	end

	local count = 0

	while big[count + 1] do
		count = count + 1
	end

	return count
end

function GrabEggSettlementRankModel:getDisplayRoman(bigRank, smallRank)
	if not bigRank or not smallRank then
		return ""
	end

	local count = self:getSmallRankCount(bigRank)

	if count == 0 or count < smallRank then
		return ""
	end

	return ROMAN_NUMERALS[count - smallRank + 1] or ""
end

function GrabEggSettlementRankModel:buildEggStageList(upNumber, eggNum, newEggIndex)
	upNumber = upNumber or eggNum or 0
	eggNum = eggNum or 0

	local eggs = {}

	for index = 1, upNumber do
		local stage = 0

		if index <= eggNum then
			stage = index == newEggIndex and 2 or 1
		end

		eggs[#eggs + 1] = {
			stage = stage
		}
	end

	return eggs
end

return GrabEggSettlementRankModel
