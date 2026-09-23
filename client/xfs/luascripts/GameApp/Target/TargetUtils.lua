-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Target\\TargetUtils.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local SceneUtils = require("Common.Utils.SceneUtils")
local Const = require("Common.Const.Const")
local TargetConfigData = require("Data.gameplay_target_data")
local TimerConfigData = require("Data.timer_config_data")
local CustomTriggerData = require("Data.custom_trigger_data")
local DefaultMapMarkData = require("Data.default_map_mark_data")
local SceneSeamlessData = require("Data.scene_seamless_data")
local CatchRogueBuffData = require("Data.catch_rogue_buff_data")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local MessageName = require("Const.MessageName")
local ClientUtils = require("Utils.ClientUtils")
local CommonSwitch = require("Common.CommonSwitch")
local BossRushUtils = require("Utils.BossRushUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Vector3 = Vector3
local TargetUtils = {}
local challengeId = 72507155

function TargetUtils.getTargetCurrentProgress(targetId)
	local targetID = targetId or pg.game.target:getTargetId()
	local groupID = TargetUtils.getTargetConfigGroup(targetID)

	if pg.me and pg.me.groupProcessMap and groupID and groupID > 0 then
		return pg.me.groupProcessMap[groupID]
	end
end

function TargetUtils.getTargetType()
	return pg.game.target:getTargetType()
end

function TargetUtils.isDelayTime()
	return false
end

function TargetUtils.isShowTimer(targetId)
	local targetID = targetId or pg.game.target:getTargetId()
	local targetConfig = TargetUtils.getTargetConfig(targetID)

	return targetConfig.timer ~= nil, targetConfig.timer
end

function TargetUtils.isShowResetBtn(targetId)
	local targetID = targetId or pg.game.target:getTargetId()
	local targetConfig = TargetUtils.getTargetConfig(targetID)

	return targetConfig.resettable and targetConfig.resettable > 0
end

function TargetUtils.isShowTraceBtn(targetId)
	local targetID = targetId or pg.game.target:getTargetId()
	local conditions = TargetUtils.getTargetConditions(targetID)

	if conditions then
		for i = 1, #conditions do
			if conditions[i].trace and conditions[i].trace > 0 and conditions[i].source == nil then
				return true, conditions[i].trace
			end
		end
	end

	return false, nil
end

function TargetUtils.isShowChest(targetId)
	local targetID = targetId or pg.game.target:getTargetId()
	local targetConfig = TargetUtils.getTargetConfig(targetID)

	return targetConfig and targetConfig.chestIcon ~= nil
end

function TargetUtils.isBossCatchInfo()
	return false
end

function TargetUtils.isTargetChange()
	return pg.game.target:getTargetChange()
end

function TargetUtils.isShowCurTargetSimple()
	if not CommonSwitch.TARGET then
		return false
	end

	local type = TargetUtils.getTargetConfigAddType()

	if type and type > 0 and type <= Const.HUD_TARGET_ADD_TYPE.TEMP then
		return true
	end

	local isShowTarget = TargetUtils.isReenterShowTarget()

	if isShowTarget and isShowTarget > 0 then
		return true
	end

	return false
end

function TargetUtils.isShowCurTarget()
	if not CommonSwitch.TARGET then
		return false
	end

	local type = TargetUtils.getTargetConfigAddType()

	if type and type > 0 and type <= Const.HUD_TARGET_ADD_TYPE.TEMP then
		return true
	end

	local isShowTarget = TargetUtils.isReenterShowTarget()

	if isShowTarget and isShowTarget > 0 then
		pg.game.target:onShowTarget(isShowTarget)
		facade:sendMsgToUI(MessageName.TARGET_ON_CHANGE, {
			targetId = isShowTarget,
			refreshType = Const.HUD_TARGET_CHANGE_TYPE.IN
		})

		return true
	end

	local count = TargetUtils.isLevelItemTargetCount()

	if count and count > 0 then
		pg.game.target:seTopTotalTargetVal(count)
	end

	return false
end

function TargetUtils.reenterShowTime()
	if TargetUtils.getReenterCurTimerId() and TargetUtils.getReenterCurTimerId() > 0 then
		self.targetTimerId = TargetUtils.getReenterCurTimerId()

		local timeValue = TargetUtils.getTargetTimerCountDown(TargetUtils.getReenterCurTimerId())
		local levelTime = timeValue - TargetUtils.getReenterCurTimerStartTime()

		if levelTime and levelTime > 0 then
			pg.game.target:onTimerUpdate(self.targetTimerId, TargetUtils.getReenterCurTimerStartTime())
			pg.global.ui.tips:refreshCountDownData(self.targetTimerId, {
				infoText = TargetUtils.getTargetTimerText(self.targetTimerId)
			})
		end
	end
end

function TargetUtils.isReenterShowTarget()
	return pg.me and pg.me.curGamePlayId
end

function TargetUtils.getReenterCurTimerId()
	return pg.me and pg.me.curTimerId
end

function TargetUtils.getReenterCurTimerStartTime()
	return pg.me and pg.me.curTimerStartTime
end

function TargetUtils.isLevelItemTargetCount()
	return pg.me and pg.me.levelItemTargetCount
end

function TargetUtils.isTargetStageChange(targetId)
	return pg.game.target:getTargetId() > 0 and pg.game.target:getTargetId() ~= targetId
end

function TargetUtils.getTargetChestData()
	local curNum = 0
	local totalNum = 0
	local sceneId = pg.me.space.sceneId
	local chestData = TargetConfigData[pg.game.target:getTargetId()]

	if chestData then
		for index, chestStaticId in ipairs(chestData.chest or EMPTY_TABLE) do
			local openCount = pg.me.interactRecord and pg.me.interactRecord[chestStaticId] or 0

			totalNum = totalNum + 1

			if openCount > 0 then
				curNum = curNum + 1
			end
		end
	end

	return curNum, totalNum, totalNum <= curNum
end

function TargetUtils.getTargetListData(oldTarget, newTarget)
	if newTarget == nil or newTarget == 0 then
		return nil
	end

	return TargetUtils.getTargetConditions(newTarget)
end

function TargetUtils.getTargetConfig(targetId)
	return TargetConfigData[targetId]
end

function TargetUtils.getTargetConfigType(targetId)
	return TargetConfigData[targetId].type
end

function TargetUtils.getTargetConfigAddType(targetId)
	local targetID = targetId or pg.game.target:getTargetId()

	if targetID < 1 then
		return nil
	end

	local groupId = TargetUtils.getTargetConfigGroup(targetId)

	if groupId then
		return TargetUtils.getAddTypeConfigByGroup(groupId) or 0
	end

	return TargetConfigData[targetID].addType
end

function TargetUtils.getTargetConfigGroup(targetId)
	local targetID = targetId or pg.game.target:getTargetId()

	if targetID < 1 then
		return nil
	end

	return TargetConfigData[targetID] and TargetConfigData[targetID].group
end

local cacheAddTypeByGroup = {}

function TargetUtils.getAddTypeConfigByGroup(groupId)
	if cacheAddTypeByGroup[groupId] then
		return cacheAddTypeByGroup[groupId]
	end

	for i, v in pairs(TargetConfigData) do
		if v.group and groupId == v.group and v.addType then
			cacheAddTypeByGroup[groupId] = v.addType

			return v.addType
		end
	end

	cacheAddTypeByGroup[groupId] = 0
end

function TargetUtils.getTargetIcon(targetId)
	local targetID = targetId or pg.game.target:getTargetId()
	local targetType = TargetConfigData[targetID] and TargetConfigData[targetID].type
	local markConf = DefaultMapMarkData[targetType]

	if markConf then
		return markConf.icon or ""
	end

	return ""
end

function TargetUtils.getTargetConfigTitle(targetId)
	local targetID = targetId or pg.game.target:getTargetId()

	if TargetConfigData[targetID] and TargetConfigData[targetID].addType == Const.HUD_TARGET_ADD_TYPE.COMMON_CHALLENGE then
		return pg.getGameString(TargetConfigData[targetID].name)
	end

	return pg.getLocalizationText(TargetConfigData[targetID].name)
end

function TargetUtils.handleConditionDesc(desc, conditionId)
	if string.find(desc, "<bossRush>") then
		local conditionCfg = CustomTriggerData[conditionId]

		if conditionCfg and conditionCfg.condition and conditionCfg.condition[1] then
			local bossRushTargetId = conditionCfg.condition[1][2]
			local bossCfg = BossRushUtils.getBossCfgByTargetId(bossRushTargetId)

			if bossCfg then
				return string.gsub(desc, "<bossRush>", pg.getLocalizationText(bossCfg.BossShowName or ""))
			end
		end
	end

	return desc
end

function TargetUtils.getTargetConditions(targetId, curTargetId, data)
	local targetID = targetId or pg.game.target:getTargetId()
	local targetConfig = TargetUtils.getTargetConfig(targetID)

	if not targetConfig then
		return nil
	end

	local conditions = {}
	local expression = targetConfig.conditionExpression

	for i = 1, #expression do
		local condition = {}

		condition.addType = targetConfig.addType
		condition.targetId = targetID
		condition.isFined = false
		condition.conditionId = targetConfig["conditionId" .. i]

		local desc = targetConfig.addType == Const.HUD_TARGET_ADD_TYPE.COMMON_CHALLENGE and pg.getGameString(targetConfig["conditionDesc" .. i]) or pg.getLocalizationText(targetConfig["conditionDesc" .. i])

		condition.desc = TargetUtils.handleConditionDesc(desc, condition.conditionId)
		condition.showCounting = targetConfig["conditionNum" .. i]
		condition.showCanSelect = targetConfig["optional" .. i]
		condition.trace = targetConfig["trace" .. i]
		condition.traceType = targetConfig["traceType" .. i]
		condition.source = targetConfig["source" .. i]
		condition.showFinishTip = targetConfig["showFinishTip" .. i]

		local targetVal, totalTargetVal = 0, 0

		if condition.conditionId and condition.conditionId > 0 and condition.conditionId ~= 8 then
			totalTargetVal = TargetUtils.getConditionTargetValue(condition.conditionId, 1)

			if ClientUtils.checkCondition(condition.conditionId) then
				targetVal = totalTargetVal
				condition.isFined = true
			else
				targetVal = pg.me.triggerMap:getConditionFinishCount(condition.conditionId, 1) or 0
			end
		end

		condition.curValue = targetVal
		condition.totalValue = totalTargetVal
		condition.seqid = i
		condition.isNew = data and data.isNew and data.isNew or false

		table.insert(conditions, condition)

		if curTargetId and curTargetId == i then
			return condition
		end
	end

	return conditions
end

function TargetUtils.getTargetBuffs(targetId, curBuffId)
	local targetID = targetId or pg.game.target:getTargetId()

	if not pg.me or not pg.me.catchRogueInfo then
		return
	end

	local buffs = {}
	local buffsData = pg.me.catchRogueInfo:getCurCanGetAddOnSet()

	for i = 1, #buffsData do
		local buffConfig = CatchRogueBuffData[buffsData[i]]

		if not buffConfig then
			return nil
		end

		local buff = {}

		buff.id = buffsData[i]
		buff.icon = buffConfig.buffUi
		buff.desc = buffConfig.buffDesc

		table.insert(buffs, buff)

		if curBuffId and curBuffId == i then
			return buff
		end
	end

	return buffs
end

function TargetUtils.getTargetCatchPetCount()
	if not pg.me or not pg.me.catchRogueInfo then
		return
	end

	return pg.me.catchRogueInfo:getCurPuppetFinishCount()
end

function TargetUtils.getTargetTimerConfig(timerId)
	return TimerConfigData[timerId]
end

function TargetUtils.getTargetTimerType(timerId)
	return TimerConfigData[timerId].type
end

function TargetUtils.getTargetTimerCountDown(timerId)
	return TimerConfigData[timerId].value
end

function TargetUtils.getTargetTimerText(timerId)
	local useHUDTarget = TimerConfigData[timerId] and TimerConfigData[timerId].useHUDTarget
	local desc = TimerConfigData[timerId] and pg.getLocalizationText(TimerConfigData[timerId].txt)

	if useHUDTarget and useHUDTarget > 0 then
		local desc1, targetVal, totalTargetVal = pg.game.target:getTopProgress()

		if desc1 and desc1 ~= "" and totalTargetVal then
			local countingStr = string.format("[%s/%s]", targetVal, totalTargetVal)

			desc = ClientTextUtils.concatByLanguage(desc1, countingStr)
		end
	end

	return desc
end

function TargetUtils.TriggerTargetTimerEvent(timerId, time)
	local timerEvents = TimerConfigData[timerId].event

	if timerEvents then
		for targetTime, eventList in pairs(timerEvents) do
			if time == targetTime then
				for i, eventId in ipairs(eventList) do
					pg.me:doEvent(eventId)
				end
			end
		end
	end
end

function TargetUtils.canTraceItemSource(targetId, subObjectItem)
	local targetID = targetId or pg.game.target:getTargetId()
	local subObjectIndex = subObjectItem or 1
	local flag, sourceId = false, 0
	local conditions = TargetUtils.getTargetConditions(targetID)

	if conditions then
		for j = 1, #conditions do
			if j == subObjectIndex then
				sourceId = conditions[j].source or 0

				return sourceId > 0, sourceId
			end
		end
	end

	return flag, sourceId
end

function TargetUtils.getConditionTargetValue(conditionId, objectId)
	if conditionId ~= nil and conditionId ~= 0 then
		local triggerConfig = CustomTriggerData[conditionId]

		if triggerConfig and triggerConfig.condition then
			for i, v in ipairs(triggerConfig.condition) do
				if i == objectId then
					return triggerConfig.condition[i][5] or 0
				end
			end
		end

		return 0
	end
end

function TargetUtils.canQuestShowPathfindingFlag(targetId)
	local targetID = targetId or pg.game.target:getTargetId()
	local curTargetMap = TargetUtils.getTargetCurrentProgress(targetID)
	local condition = TargetUtils.getTargetConditions(targetID, curTargetMap[1] or 1)

	return condition.trace and condition.trace > 0, condition.trace
end

function TargetUtils.getPathfindingIdTargetInfo(targetId)
	if pg.me == nil or pg.me.space == nil then
		return nil
	end

	local targetID = targetId or pg.game.target:getTargetId()
	local targetsInfo
	local targetConfig = TargetUtils.getTargetConfig(targetID)

	if not targetConfig then
		return nil
	end

	local sceneId = pg.me.space.sceneId
	local mainSceneId = pg.game.map:convertSceneId(sceneId)
	local expression = targetConfig.conditionExpression

	for i = 1, #expression do
		local objId = i
		local pathId = targetConfig["trace" .. i]

		if pathId ~= nil and pathId ~= 0 then
			local guideFlag = targetConfig["traceType" .. i]
			local curMarkSceneId = targetConfig["markSceneId" .. i]
			local serialId = targetID * 100 + objId
			local markSceneId = curMarkSceneId or mainSceneId
			local mainTargetPostionData = SceneUtils.getSceneTargetPositionData(markSceneId)
			local targetPosConfig = mainTargetPostionData[pathId]
			local pos, circleRadius, sceneId = QuestUtils.getTargetConfigPosition(targetPosConfig)

			if pos ~= nil then
				if targetsInfo == nil then
					targetsInfo = {
						targetID = targetID,
						scene = markSceneId,
						position = targetPosConfig.position,
						posInfo = {}
					}
				end

				local temp = {
					showPath = true,
					objId = objId,
					pos = pos,
					circleRadius = circleRadius,
					index = serialId,
					posConfig = targetPosConfig,
					pathId = pathId,
					guideFlag = guideFlag
				}

				table.insert(targetsInfo.posInfo, temp)
			end

			local allSceneSeamlessData = SceneSeamlessData[markSceneId]

			if allSceneSeamlessData ~= nil then
				for id, v in pairs(allSceneSeamlessData.seamlessGroup) do
					if type(id) == "number" then
						local seamlessTargetPostionData = SceneUtils.getSceneTargetPositionData(tonumber(id))

						if seamlessTargetPostionData then
							local seamlessTargetPosConfig = seamlessTargetPostionData[pathId]

							if seamlessTargetPosConfig then
								local seamlessPos, seamlessCircleRadius, sceneId = QuestUtils.getTargetConfigPosition(seamlessTargetPosConfig)

								if seamlessPos ~= nil then
									if targetsInfo == nil then
										targetsInfo = {
											targetID = targetID,
											posInfo = {},
											scene = markSceneId,
											position = seamlessTargetPosConfig.position
										}
									end

									local temp = {
										showPath = true,
										objId = objId,
										pos = seamlessPos,
										circleRadius = seamlessCircleRadius,
										index = serialId,
										posConfig = seamlessTargetPosConfig,
										pathId = pathId,
										guideFlag = guideFlag
									}

									table.insert(targetsInfo.posInfo, temp)
								end
							end
						end
					end
				end
			end
		end
	end

	return targetsInfo
end

function TargetUtils.addTargetPathingNavEffect(targetId)
	local targetID = targetId or pg.game.target:getTargetId()
	local targetInfo = TargetUtils.getPathfindingIdTargetInfo(targetID)

	if targetInfo == nil or targetInfo == 0 then
		return
	end

	if targetInfo.scene and targetInfo.scene > 0 and targetID and targetID > 0 then
		if not pg.game.map:checkValidScene(targetInfo.scene) then
			if pg.game and pg.game.navEffect then
				pg.game.navEffect:path(targetInfo.scene, targetInfo.position, targetID)
				pg.game.target:addNavPathfindingTarget({
					sceneId = targetInfo.scene,
					targetID = targetID
				})
			end

			pg.game.map:forceShowHudMarkTraceIfCurrentSceneNoMapRes(targetInfo.position, TargetUtils.getTargetIcon(targetID), targetID, true)
		elseif targetInfo.posInfo and targetInfo.posInfo[#targetInfo.posInfo] and targetInfo.posInfo[#targetInfo.posInfo].pathId then
			pg.game.map:manualTraceQuestMark(Const.MAP_MARK_TRACE, targetInfo.posInfo[#targetInfo.posInfo].pathId, true)
			pg.game.target:addNavPathfindingTarget({
				sceneId = targetInfo.scene,
				targetID = targetInfo.posInfo[#targetInfo.posInfo].pathId
			})
		end
	end
end

function TargetUtils.removeTargetPathingNavEffect(info, successCallback)
	local targetID = info.targetId or pg.game.target:getTargetId()

	if pg.game and pg.game.navEffect and targetID then
		pg.game.navEffect:unPath(targetID, successCallback)
	end

	pg.game.map:forceShowHudMarkTraceIfCurrentSceneNoMapRes(nil, nil, targetID, false)
end

function TargetUtils.getNeedFinishNum(targetId)
	local totalNum = 0
	local needFinishNum = 0
	local targetID = targetId or pg.game.target:getTargetId()
	local conditionExpression = TargetUtils.getTargetConfig(targetID).conditionExpression
	local temp = {}

	for _, tag in ipairs(conditionExpression) do
		totalNum = totalNum + 1
		temp[tag] = true
	end

	for _, tag in pairs(temp) do
		needFinishNum = needFinishNum + 1
	end

	return needFinishNum, totalNum
end

return TargetUtils
