-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Utils\\GrabEggsRankUtils.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LuaUIUtils = require("Utils.LuaUIUtils")
local EggRankBaseData = require("Data.egg_rank_base_data")
local EggRankRewardData = require("Data.egg_rank_reward_data")
local SeasonStageData = require("Data.season_stage_data")
local Utils = require("Common.Utils.Utils")
local ClientConst = require("Const.ClientConst")
local SysConfigData = require("Data.sys_config_data")
local GrabEggsRankUtils = {}

GrabEggsRankUtils.LEVEL_STATE = {
	DONE = 2,
	LOCKED = 1,
	UNLOCK = 0
}

local ROMAN_NUMERALS = {
	"I",
	"II",
	"III",
	"IV",
	"V"
}
local ROMAN_SUFFIXES = {
	III = "Ⅲ",
	II = "Ⅱ",
	I = "Ⅰ",
	V = "Ⅴ",
	IV = "Ⅳ"
}

local function getSortedNumericKeys(data)
	local keys = {}

	for key in pairs(data or EMPTY_TABLE) do
		if type(key) == "number" then
			keys[#keys + 1] = key
		end
	end

	table.sort(keys)

	return keys
end

local function isFlagSet(value)
	return value == true or type(value) == "number" and value > 0
end

local function getPlayer()
	return pg and pg.me
end

function GrabEggsRankUtils.getRankScoreDoubleInfo()
	local totalTimes = math.max(0, tonumber(SysConfigData.GRABEGG_RANK_SCORE_DOUBLE_TIME) or 0)
	local multiple = tonumber(SysConfigData.GRABEGG_RANK_SCORE_DOUBLE_MULTIPLE) or 1
	local player = getPlayer()
	local dailySuccessTimes = player and tonumber(player.dailyRobEggSuccessTimes)
	local remainingTimes = dailySuccessTimes and math.max(0, totalTimes - dailySuccessTimes) or 0

	return {
		totalTimes = totalTimes,
		multiple = multiple,
		dailySuccessTimes = dailySuccessTimes,
		remainingTimes = remainingTimes,
		available = multiple > 1 and totalTimes > 0 and dailySuccessTimes ~= nil and remainingTimes > 0
	}
end

function GrabEggsRankUtils.isRankScoreDoubleAvailable()
	return GrabEggsRankUtils.getRankScoreDoubleInfo().available
end

function GrabEggsRankUtils.getCurrentRank()
	local player = getPlayer()

	return player and player.eggLv or 1, player and player.secEggLv or 1
end

function GrabEggsRankUtils.getRankIconBoardUrl(bigRank)
	if not bigRank or not EggRankBaseData[bigRank] then
		return
	end

	return string.format("$UI_Img_Season_Rank_Sub_Level%d.png", bigRank)
end

function GrabEggsRankUtils.getRankConfig(bigRank, smallRank)
	return EggRankBaseData[bigRank] and EggRankBaseData[bigRank][smallRank]
end

function GrabEggsRankUtils.getBigRankKeys()
	return getSortedNumericKeys(EggRankBaseData)
end

function GrabEggsRankUtils.getSmallRankKeys(bigRank)
	return getSortedNumericKeys(EggRankBaseData[bigRank])
end

function GrabEggsRankUtils.compareRank(leftBigRank, leftSmallRank, rightBigRank, rightSmallRank)
	if leftBigRank ~= rightBigRank then
		return leftBigRank < rightBigRank and -1 or 1
	end

	if leftSmallRank == rightSmallRank then
		return 0
	end

	return leftSmallRank < rightSmallRank and -1 or 1
end

function GrabEggsRankUtils.getNextRank(bigRank, smallRank)
	local smallRankKeys = GrabEggsRankUtils.getSmallRankKeys(bigRank)

	for _, rank in ipairs(smallRankKeys) do
		if smallRank < rank then
			return bigRank, rank
		end
	end

	for _, rank in ipairs(GrabEggsRankUtils.getBigRankKeys()) do
		if bigRank < rank then
			local nextSmallRankKeys = GrabEggsRankUtils.getSmallRankKeys(rank)

			if nextSmallRankKeys[1] then
				return rank, nextSmallRankKeys[1]
			end
		end
	end
end

function GrabEggsRankUtils.getDisplayRoman(bigRank, smallRank)
	local smallRankKeys = GrabEggsRankUtils.getSmallRankKeys(bigRank)
	local displayIndex

	for index, rank in ipairs(smallRankKeys) do
		if rank == smallRank then
			displayIndex = #smallRankKeys - index + 1

			break
		end
	end

	return ROMAN_NUMERALS[displayIndex] or ""
end

function GrabEggsRankUtils.getRomanNumeral(value)
	return ROMAN_NUMERALS[value] or tostring(value or "")
end

local RANK_DESC_FIELDS = {
	"desc1",
	"desc2",
	"desc3"
}

local function appendRankDescriptions(result, usedTextIds, config)
	for _, fieldName in ipairs(RANK_DESC_FIELDS) do
		local textId = config and config[fieldName]

		if textId and textId ~= 0 and not usedTextIds[textId] then
			usedTextIds[textId] = true
			result[#result + 1] = {
				text = pg.getLocalizationText(textId)
			}
		end
	end
end

function GrabEggsRankUtils.getBigRankDescriptions(bigRank)
	local result = {}
	local usedTextIds = {}

	for _, smallRank in ipairs(GrabEggsRankUtils.getSmallRankKeys(bigRank)) do
		appendRankDescriptions(result, usedTextIds, GrabEggsRankUtils.getRankConfig(bigRank, smallRank))
	end

	return result
end

local function getBaseRankName(fullName, roman)
	for _, suffix in ipairs({
		ROMAN_SUFFIXES[roman],
		roman
	}) do
		if suffix and suffix ~= "" and string.sub(fullName, -#suffix) == suffix then
			return string.gsub(string.sub(fullName, 1, #fullName - #suffix), "%s+$", ""), true
		end
	end

	return fullName, false
end

function GrabEggsRankUtils.getRankInfo(bigRank, smallRank)
	local config = GrabEggsRankUtils.getRankConfig(bigRank, smallRank)

	if not config then
		return
	end

	local fullName = pg.getLocalizationText(config.name) or ""
	local isTopRank = not config.upNumber
	local roman = isTopRank and "" or GrabEggsRankUtils.getDisplayRoman(bigRank, smallRank)
	local name, didStripRoman = getBaseRankName(fullName, roman)

	if not didStripRoman then
		roman = ""
	end

	return {
		bigRank = bigRank,
		smallRank = smallRank,
		name = name,
		fullName = fullName,
		icon = config.icon,
		point = config.point or 0,
		upNumber = config.upNumber or 0,
		roman = roman,
		isTopRank = isTopRank,
		config = config
	}
end

function GrabEggsRankUtils.getCurrentRankInfo()
	local bigRank, smallRank = GrabEggsRankUtils.getCurrentRank()

	return GrabEggsRankUtils.getRankInfo(bigRank, smallRank)
end

local function getSeasonDateText(timestamp)
	if not timestamp then
		return ""
	end

	local date = os.date("*t", timestamp)
	local useYearMonthDay = LuaUIUtils.isUseHour24() or pg.languageType == ClientConst.LANGUAGE_TYPE_MAP.zh_TW

	if useYearMonthDay then
		return string.format("%04d/%02d/%02d", date.year, date.month, date.day)
	end

	return string.format("%02d/%02d/%04d", date.month, date.day, date.year)
end

local function getSeasonTimeRange(seasonData)
	local startTime, endTime

	for _, config in pairs(seasonData or EMPTY_TABLE) do
		local stageStartTime = Utils.getConfigTimeOfArea(config, "startDayTime")
		local stageEndTime = Utils.getConfigTimeOfArea(config, "endDayTime")

		if stageStartTime and (not startTime or stageStartTime < startTime) then
			startTime = stageStartTime
		end

		if stageEndTime and (not endTime or endTime < stageEndTime) then
			endTime = stageEndTime
		end
	end

	return startTime, endTime
end

function GrabEggsRankUtils.getSeasonDisplayInfo()
	local seasonStage = Utils.getCurrentSeasonStage()

	if not seasonStage then
		return
	end

	local seasonData = SeasonStageData[seasonStage.seasonId]
	local config = seasonData and seasonData[seasonStage.stageId]

	if not config then
		return
	end

	local startTime, endTime = getSeasonTimeRange(seasonData)
	local timeText = ""

	if startTime and endTime then
		timeText = string.format("%s-%s", getSeasonDateText(startTime), getSeasonDateText(endTime))
	end

	return {
		seasonId = seasonStage.seasonId,
		stageId = seasonStage.stageId,
		numText = string.format("S%d", seasonStage.seasonId),
		name = pg.getGameString("GRAB_EGG_SEASON_NAME"),
		startTime = startTime,
		endTime = endTime,
		timeText = timeText
	}
end

local function getClaimKey(bigRank, smallRank, param)
	return string.format("%d_%d_%d", bigRank, smallRank, param or 0)
end

local function isRewardReached(bigRank, rewardLevel, param)
	local currentBigRank, currentSmallRank = GrabEggsRankUtils.getCurrentRank()
	local compareResult = GrabEggsRankUtils.compareRank(currentBigRank, currentSmallRank, bigRank, rewardLevel)

	if compareResult ~= 0 then
		return compareResult > 0
	end

	if param == 0 then
		return true
	end

	local player = getPlayer()

	return (player and player.eggStar or 0) >= (param or 0)
end

function GrabEggsRankUtils.getRewardNodes()
	local nodes = {}
	local rewardFlag = getPlayer() and getPlayer().rankRewardFlag or {}

	for _, bigRank in ipairs(getSortedNumericKeys(EggRankRewardData)) do
		local bigRankData = EggRankRewardData[bigRank]

		for _, rewardLevel in ipairs(getSortedNumericKeys(bigRankData)) do
			local rewardLevelData = bigRankData[rewardLevel]

			for _, param in ipairs(getSortedNumericKeys(rewardLevelData)) do
				local config = rewardLevelData[param]
				local claimKey = getClaimKey(bigRank, rewardLevel, param)
				local claimed = isFlagSet(rewardFlag and rewardFlag[claimKey])
				local reached = isRewardReached(bigRank, rewardLevel, param)

				nodes[#nodes + 1] = {
					key = claimKey,
					claimKey = claimKey,
					bigRank = bigRank,
					rewardLevel = rewardLevel,
					smallRank = rewardLevel,
					param = param,
					dropIds = config.Raward or config.Reward or {},
					reached = reached,
					claimed = claimed,
					levelState = claimed and GrabEggsRankUtils.LEVEL_STATE.DONE or reached and GrabEggsRankUtils.LEVEL_STATE.UNLOCK or GrabEggsRankUtils.LEVEL_STATE.LOCKED
				}
			end
		end
	end

	return nodes
end

function GrabEggsRankUtils.isRewardNodeClaimable(node)
	return node ~= nil and #(node.dropIds or {}) > 0 and node.reached == true and node.claimed ~= true
end

function GrabEggsRankUtils.isRewardItemClaimable(reward)
	return reward ~= nil and GrabEggsRankUtils.isRewardNodeClaimable(reward.rankRewardNode)
end

function GrabEggsRankUtils.hasClaimableReward(rewardNodes)
	for _, node in ipairs(rewardNodes or GrabEggsRankUtils.getRewardNodes()) do
		if GrabEggsRankUtils.isRewardNodeClaimable(node) then
			return true
		end
	end

	return false
end

function GrabEggsRankUtils.filterRewardNodes(nodes, bigRank, rewardLevel)
	local result = {}

	for _, node in ipairs(nodes or EMPTY_TABLE) do
		if (bigRank == nil or node.bigRank == bigRank) and (rewardLevel == nil or node.rewardLevel == rewardLevel) then
			result[#result + 1] = node
		end
	end

	return result
end

function GrabEggsRankUtils.expandRewardItems(nodes)
	local result = {}

	for _, node in ipairs(nodes or EMPTY_TABLE) do
		local canClaim = GrabEggsRankUtils.isRewardNodeClaimable(node)
		local rewardState = ClientConst.RewardState.NotAchieved

		if node.claimed then
			rewardState = ClientConst.RewardState.Claimed
		elseif canClaim then
			rewardState = ClientConst.RewardState.ReadyToClaim
		end

		for _, dropId in ipairs(node.dropIds or EMPTY_TABLE) do
			local rewards = LuaUIUtils.getRewardItemByDropId(dropId, node.claimed, canClaim) or {}

			for _, reward in ipairs(rewards) do
				reward.rankRewardNode = node
				reward.hasGet = node.claimed
				reward.canGet = canClaim
				reward.state = rewardState
				reward.showRedDot = canClaim
				result[#result + 1] = reward
			end
		end
	end

	return result
end

local function getGroupLevelState(rewardNodes, reached)
	for _, node in ipairs(rewardNodes) do
		if #(node.dropIds or {}) > 0 and node.reached and not node.claimed then
			return GrabEggsRankUtils.LEVEL_STATE.UNLOCK
		end
	end

	return reached and GrabEggsRankUtils.LEVEL_STATE.DONE or GrabEggsRankUtils.LEVEL_STATE.LOCKED
end

local function isBigRankRewardNode(node)
	return node ~= nil and node.rewardLevel == 1 and node.param == 0
end

local function splitRankRewardNodes(rewardNodes)
	local rankRewardNodes = {}
	local stageRewardNodes = {}

	for _, node in ipairs(rewardNodes or EMPTY_TABLE) do
		if isBigRankRewardNode(node) then
			rankRewardNodes[#rankRewardNodes + 1] = node
		else
			stageRewardNodes[#stageRewardNodes + 1] = node
		end
	end

	return rankRewardNodes, stageRewardNodes
end

function GrabEggsRankUtils.buildRankGroups()
	local rewardNodes = GrabEggsRankUtils.getRewardNodes()
	local currentBigRank, currentSmallRank = GrabEggsRankUtils.getCurrentRank()
	local result = {}

	for _, bigRank in ipairs(GrabEggsRankUtils.getBigRankKeys()) do
		local smallRanks = {}
		local firstInfo

		for _, smallRank in ipairs(GrabEggsRankUtils.getSmallRankKeys(bigRank)) do
			local rankInfo = GrabEggsRankUtils.getRankInfo(bigRank, smallRank)

			firstInfo = firstInfo or rankInfo
			smallRanks[#smallRanks + 1] = rankInfo
		end

		if firstInfo then
			local groupRewardNodes = GrabEggsRankUtils.filterRewardNodes(rewardNodes, bigRank)
			local rankRewardNodes, stageRewardNodes = splitRankRewardNodes(groupRewardNodes)
			local reached = bigRank <= currentBigRank
			local descriptions = GrabEggsRankUtils.getBigRankDescriptions(bigRank)

			result[#result + 1] = {
				bigRank = bigRank,
				name = firstInfo.name,
				icon = firstInfo.icon,
				reached = reached,
				isCurrent = currentBigRank == bigRank,
				currentSmallRank = currentBigRank == bigRank and currentSmallRank or nil,
				levelState = getGroupLevelState(groupRewardNodes, reached),
				rewardNodes = groupRewardNodes,
				rewards = GrabEggsRankUtils.expandRewardItems(groupRewardNodes),
				rankRewardNodes = rankRewardNodes,
				rankRewards = GrabEggsRankUtils.expandRewardItems(rankRewardNodes),
				stageRewardNodes = stageRewardNodes,
				stageRewards = GrabEggsRankUtils.expandRewardItems(stageRewardNodes),
				descriptions = descriptions,
				smallRanks = smallRanks
			}
		end
	end

	return result
end

function GrabEggsRankUtils.buildCurrentRankStageGroups()
	local currentInfo = GrabEggsRankUtils.getCurrentRankInfo()

	if not currentInfo then
		return {}
	end

	local rewardNodes = GrabEggsRankUtils.getRewardNodes()
	local result = {}

	for _, smallRank in ipairs(GrabEggsRankUtils.getSmallRankKeys(currentInfo.bigRank)) do
		local rankInfo = GrabEggsRankUtils.getRankInfo(currentInfo.bigRank, smallRank)
		local rewardLevelNodes = GrabEggsRankUtils.filterRewardNodes(rewardNodes, currentInfo.bigRank, smallRank)
		local stageRewardNodes = {}

		for _, node in ipairs(rewardLevelNodes) do
			if not isBigRankRewardNode(node) then
				stageRewardNodes[#stageRewardNodes + 1] = node
			end
		end

		if rankInfo and #stageRewardNodes > 0 then
			result[#result + 1] = {
				bigRank = currentInfo.bigRank,
				smallRank = smallRank,
				name = rankInfo.fullName,
				icon = rankInfo.icon,
				reached = smallRank <= currentInfo.smallRank,
				isCurrent = smallRank == currentInfo.smallRank,
				levelState = getGroupLevelState(stageRewardNodes, smallRank <= currentInfo.smallRank),
				rewardNodes = stageRewardNodes,
				rewards = GrabEggsRankUtils.expandRewardItems(stageRewardNodes)
			}
		end
	end

	return result
end

local function getTopRankRewardPair(rewardNodes, currentInfo)
	local rewardLevelNodes = GrabEggsRankUtils.filterRewardNodes(rewardNodes, currentInfo.bigRank, currentInfo.smallRank)
	local milestones = {}

	for _, node in ipairs(rewardLevelNodes) do
		if not isBigRankRewardNode(node) and #(node.dropIds or {}) > 0 then
			milestones[#milestones + 1] = node
		end
	end

	if #milestones == 0 then
		return {}, {}
	end

	local player = getPlayer()
	local eggStar = player and player.eggStar or 0
	local currentIndex

	for index, node in ipairs(milestones) do
		if GrabEggsRankUtils.isRewardNodeClaimable(node) then
			currentIndex = index
		end
	end

	if not currentIndex then
		currentIndex = 1

		for index, node in ipairs(milestones) do
			if eggStar < node.param then
				currentIndex = math.max(1, index - 1)

				break
			end

			currentIndex = index
		end
	end

	return {
		milestones[currentIndex]
	}, milestones[currentIndex + 1] and {
		milestones[currentIndex + 1]
	} or {}
end

local function getBigRankRewardNode(rewardNodes, currentInfo)
	for _, node in ipairs(GrabEggsRankUtils.filterRewardNodes(rewardNodes, currentInfo.bigRank)) do
		if isBigRankRewardNode(node) and GrabEggsRankUtils.isRewardNodeClaimable(node) then
			return node
		end
	end
end

local function getDisplayedUnclaimedStageNode(rewardNodes, currentInfo)
	local claimableNodes = {}

	for _, node in ipairs(GrabEggsRankUtils.filterRewardNodes(rewardNodes, currentInfo.bigRank)) do
		if not isBigRankRewardNode(node) and GrabEggsRankUtils.isRewardNodeClaimable(node) then
			claimableNodes[#claimableNodes + 1] = node
		end
	end

	table.sort(claimableNodes, function(left, right)
		if left.rewardLevel ~= right.rewardLevel then
			return left.rewardLevel < right.rewardLevel
		end

		return left.param < right.param
	end)

	local displayIndex = #claimableNodes > 1 and #claimableNodes - 1 or 1

	return claimableNodes[displayIndex]
end

local function getFollowingRankInfos(currentInfo, count)
	local result = {}
	local bigRank = currentInfo.bigRank
	local smallRank = currentInfo.smallRank

	for _ = 1, count do
		bigRank, smallRank = GrabEggsRankUtils.getNextRank(bigRank, smallRank)

		if not bigRank then
			break
		end

		result[#result + 1] = GrabEggsRankUtils.getRankInfo(bigRank, smallRank)
	end

	return result
end

local function getNextSmallRankInfo(currentInfo)
	for _, smallRank in ipairs(GrabEggsRankUtils.getSmallRankKeys(currentInfo.bigRank)) do
		if smallRank > currentInfo.smallRank then
			return GrabEggsRankUtils.getRankInfo(currentInfo.bigRank, smallRank)
		end
	end
end

local function getNextBigRankFirstInfo(currentInfo)
	for _, bigRank in ipairs(GrabEggsRankUtils.getBigRankKeys()) do
		if bigRank > currentInfo.bigRank then
			local smallRank = GrabEggsRankUtils.getSmallRankKeys(bigRank)[1]

			if smallRank then
				return GrabEggsRankUtils.getRankInfo(bigRank, smallRank)
			end
		end
	end
end

local function getBigRankScoreRange(targetBigRank)
	local bigRankKeys = GrabEggsRankUtils.getBigRankKeys()
	local firstBigRank = bigRankKeys[1]
	local firstSmallRank = GrabEggsRankUtils.getSmallRankKeys(firstBigRank)[1]
	local bigRankStartScore
	local smallRankStartScores = {}
	local score = 0

	for _, bigRank in ipairs(bigRankKeys) do
		for _, smallRank in ipairs(GrabEggsRankUtils.getSmallRankKeys(bigRank)) do
			if bigRank == targetBigRank then
				bigRankStartScore = bigRankStartScore or score
				smallRankStartScores[#smallRankStartScores + 1] = score
			end

			local config = GrabEggsRankUtils.getRankConfig(bigRank, smallRank)
			local nextBigRank, nextSmallRank = GrabEggsRankUtils.getNextRank(bigRank, smallRank)
			local nextConfig = GrabEggsRankUtils.getRankConfig(nextBigRank, nextSmallRank)

			if not nextConfig then
				return bigRankStartScore or 0, score, smallRankStartScores
			end

			local startEggStar = bigRank == firstBigRank and smallRank == firstSmallRank and 0 or 1

			score = score + math.max(0, (config.upNumber or 0) - startEggStar) * (config.point or 0) + (nextConfig.point or 0)

			if bigRank == targetBigRank and nextBigRank ~= targetBigRank then
				return bigRankStartScore or 0, score, smallRankStartScores
			end
		end
	end

	return bigRankStartScore or 0, score, smallRankStartScores
end

local function getBigRankProgressValue(eggAllScore, nextBigRankStartScore, smallRankStartScores, currentSmallRankIndex)
	local smallRankCount = #smallRankStartScores

	if smallRankCount == 0 then
		return 0
	end

	local smallRankIndex = math.max(1, math.min(currentSmallRankIndex or 1, smallRankCount))
	local smallRankStartScore = smallRankStartScores[smallRankIndex]
	local smallRankEndScore = smallRankStartScores[smallRankIndex + 1] or nextBigRankStartScore
	local smallRankScoreRange = math.max(1, smallRankEndScore - smallRankStartScore)
	local smallRankProgress = math.max(0, math.min(1, (eggAllScore - smallRankStartScore) / smallRankScoreRange))

	return (smallRankIndex - 1 + smallRankProgress) / smallRankCount
end

function GrabEggsRankUtils.buildMainPageData()
	local player = getPlayer()
	local currentInfo = GrabEggsRankUtils.getCurrentRankInfo()

	if not currentInfo then
		return
	end

	local followingInfos = getFollowingRankInfos(currentInfo, 1)
	local nextInfo = followingInfos[1]
	local rewardNodes = GrabEggsRankUtils.getRewardNodes()
	local bigRankRewardNode = getBigRankRewardNode(rewardNodes, currentInfo)
	local currentRewardNodes = bigRankRewardNode and {
		bigRankRewardNode
	} or {}
	local nextRewardNodes = {}
	local rewardPageState
	local rewardBlocks = {}

	if bigRankRewardNode then
		rewardPageState = 0
	elseif currentInfo.isTopRank then
		rewardPageState = 2

		local topRankRewardNodes

		topRankRewardNodes, nextRewardNodes = getTopRankRewardPair(rewardNodes, currentInfo)

		if topRankRewardNodes[1] then
			rewardBlocks[1] = {
				rankInfo = currentInfo,
				nodes = topRankRewardNodes,
				rewards = GrabEggsRankUtils.expandRewardItems(topRankRewardNodes)
			}
		end

		if nextRewardNodes[1] then
			rewardBlocks[2] = {
				rankInfo = currentInfo,
				nodes = nextRewardNodes,
				rewards = GrabEggsRankUtils.expandRewardItems(nextRewardNodes)
			}
		end
	else
		rewardPageState = 1

		local pendingStageNode = getDisplayedUnclaimedStageNode(rewardNodes, currentInfo)
		local stageRankInfo, stageRewardNodes

		if pendingStageNode then
			stageRankInfo = GrabEggsRankUtils.getRankInfo(pendingStageNode.bigRank, pendingStageNode.rewardLevel)
			stageRewardNodes = {
				pendingStageNode
			}
		else
			stageRankInfo = getNextSmallRankInfo(currentInfo)
			stageRewardNodes = stageRankInfo and GrabEggsRankUtils.filterRewardNodes(rewardNodes, stageRankInfo.bigRank, stageRankInfo.smallRank) or {}
		end

		if stageRankInfo then
			rewardBlocks[1] = {
				rankInfo = stageRankInfo,
				nodes = stageRewardNodes,
				rewards = GrabEggsRankUtils.expandRewardItems(stageRewardNodes)
			}
		end

		local nextBigRankInfo = getNextBigRankFirstInfo(currentInfo)

		if nextBigRankInfo then
			local bigRankRewardNodes = {}

			for _, node in ipairs(GrabEggsRankUtils.filterRewardNodes(rewardNodes, nextBigRankInfo.bigRank, nextBigRankInfo.smallRank)) do
				if isBigRankRewardNode(node) then
					bigRankRewardNodes[#bigRankRewardNodes + 1] = node
				end
			end

			rewardBlocks[2] = {
				rankInfo = nextBigRankInfo,
				nodes = bigRankRewardNodes,
				rewards = GrabEggsRankUtils.expandRewardItems(bigRankRewardNodes)
			}
		end

		nextRewardNodes = rewardBlocks[1] and rewardBlocks[1].nodes or {}
	end

	local eggStar = player and player.eggStar or 0
	local eggScore = player and player.eggScore or 0
	local eggAllScore = player and player.eggAllScore or 0
	local bigRankStartScore, nextBigRankStartScore, smallRankStartScores = getBigRankScoreRange(currentInfo.bigRank)
	local currentSmallRankIndex = 1

	for index, smallRank in ipairs(GrabEggsRankUtils.getSmallRankKeys(currentInfo.bigRank)) do
		if smallRank == currentInfo.smallRank then
			currentSmallRankIndex = index

			break
		end
	end

	local rankProgressValue = getBigRankProgressValue(eggAllScore, nextBigRankStartScore, smallRankStartScores, currentSmallRankIndex)

	return {
		current = currentInfo,
		next = nextInfo,
		eggStar = eggStar,
		eggScore = eggScore,
		eggAllScore = eggAllScore,
		bigRankStartScore = bigRankStartScore,
		nextBigRankStartScore = nextBigRankStartScore,
		smallRankStartScores = smallRankStartScores,
		rankProgressValue = rankProgressValue,
		rewardPageState = rewardPageState,
		hasClaimableReward = GrabEggsRankUtils.hasClaimableReward(rewardNodes),
		rewardBlocks = rewardBlocks,
		currentRewardNodes = currentRewardNodes,
		currentRewards = GrabEggsRankUtils.expandRewardItems(currentRewardNodes),
		nextRewardNodes = nextRewardNodes,
		nextRewards = GrabEggsRankUtils.expandRewardItems(nextRewardNodes),
		descriptions = GrabEggsRankUtils.getBigRankDescriptions(currentInfo.bigRank)
	}
end

return GrabEggsRankUtils
