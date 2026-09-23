-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientPlayerActivityPlatformComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local json = require("json")
local logger = LoggerManager.getLogger("ClientPlayerActivityPlatformComponent")
local class = require("Core.Framework.Class")
local CallbackHandler = require("Core.Common.CallbackHandler")
local ServiceUtils = require("Common.Utils.ServiceUtils")
local Time = require("Core.Common.Time")
local TimeUtils = require("Common.Utils.TimeUtils")
local MessageName = require("Const.MessageName")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetResearchTrackData = require("Data.pet_research_track_data")
local ActivityPetVoteData = require("Data.activity_pet_vote_data")
local ActivityConst = require("Common.Const.ActivityConst")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local Utils = require("Common.Utils.Utils")
local PetPrototypeData = require("Data.pet_prototype_data")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local ClientPlayerActivityPlatformComponent = class.Component("ClientPlayerActivityPlatformComponent")

function ClientPlayerActivityPlatformComponent:ctor()
	return
end

function ClientPlayerActivityPlatformComponent:init(avtDict)
	return true
end

function ClientPlayerActivityPlatformComponent:destroy()
	return
end

function ClientPlayerActivityPlatformComponent:serverActivityMsg(eventId, msgName, ...)
	if not eventId then
		if pg.logError() then
			logger:error("@PlayerActivity serverActivityMsg error eventId is nil!!!")
		end

		return false
	end

	local isOpen = ActivityUtils.isOprActivityOpen(eventId)

	if not isOpen then
		if pg.logError() then
			local argsNum = select("#", ...)
			local param = {
				...
			}

			logger:error("@PlayerActivity serverActivityMsg error activity is not open!!! activityId:%s msgName:%s paramCount:%s param:%s", eventId, msgName, argsNum, inspect(dealMsgParameters(param)))
		end

		return false
	end

	if pg.logInfo() then
		local argsNum = select("#", ...)
		local param = {
			...
		}

		logger:info("@PlayerActivity serverActivityMsg !!! activityId:%s msgName:%s paramCount:%s param:%s", eventId, msgName, argsNum, inspect(dealMsgParameters(param)))
	end

	self:serverMsg(msgName, ...)

	return true
end

function ClientPlayerActivityPlatformComponent:RPC_SC_NotifyActivityDayUpdated()
	facade:sendMsgToUI(MessageName.EVENT_CUR_PAGE_REFRESH)
	facade:sendMsgToUI(MessageName.EVENT_REFRESH_REDDOT)
	facade:sendMsgToSystem(MessageName.NOTIFY_ACTIVITY_DAY_UPDATED)
	facade:sendMsgToUI(MessageName.NOTIFY_ACTIVITY_DAY_UPDATED)
end

function ClientPlayerActivityPlatformComponent:RPC_SC_TapTapStoreEvaluate()
	pg.global.ui:open(UIConst.UI_ID_TAPTAP_STORE_EVALUATE)
end

function ClientPlayerActivityPlatformComponent:on_cafeGatheringDailyAcquired_changed(oldV, newV, itemId)
	facade:sendMsgToUI(MessageName.EVENT_REFRESH_REDDOT)
	facade:sendMsgToUI(MessageName.CAFE_GATHERING_DAILY_CHANGED, {
		itemId = itemId,
		oldV = oldV,
		newV = newV
	})
end

function ClientPlayerActivityPlatformComponent:queryActivityVotePetInfo()
	local now = Time.getSecond()
	local voteStartDayTime, voteEndDayTime, eventStartDayTime, eventEndDayTime
	local activityInfo = {}

	for activityId, activityData in pairs(ActivityPetVoteData) do
		eventEndDayTime = Utils.getConfigTimeOfArea(activityData, "eventEndDayTime")

		if now < eventEndDayTime then
			voteStartDayTime = Utils.getConfigTimeOfArea(activityData, "voteStartDayTime")

			if voteStartDayTime <= now then
				voteEndDayTime = Utils.getConfigTimeOfArea(activityData, "voteEndDayTime")
				eventStartDayTime = Utils.getConfigTimeOfArea(activityData, "eventStartDayTime")
				activityInfo[activityId] = {
					now,
					voteStartDayTime,
					voteEndDayTime,
					eventStartDayTime,
					eventEndDayTime
				}
			end
		end
	end

	return activityInfo
end

function ClientPlayerActivityPlatformComponent:reqActivityVotePet(eventId, activityId, petId)
	self:serverActivityMsg(eventId, "RPC_CS_ReqActivityVotePet", activityId, petId, CallbackHandler(self, "onActivityVotePetCallback"))
end

function ClientPlayerActivityPlatformComponent:onActivityVotePetCallback(code)
	if code ~= 0 then
		return
	end

	pg.game.audio:playEvent("SFX_UI_Event_Prayers_Finish")
	facade:sendMsgToUI(MessageName.EVENT_CUR_PAGE_REFRESH)
end

function ClientPlayerActivityPlatformComponent:pullActivityVotePetData(activityId, eventType)
	local function cb(status, response)
		if not status.status then
			return
		end

		if eventType == ActivityConst.EventType.ArkCarn then
			pg.game.event:setArkPartyVoteInfo(response)
		end

		facade:sendMsgToUI(MessageName.EVENT_VOTE_INFO_PULL, {
			response = response,
			eventType = eventType
		})
	end

	ServiceUtils.callService("KvService", "findVotePet", {
		tostring(activityId)
	}, cb, {
		hint = tostring(activityId)
	})
end

function ClientPlayerActivityPlatformComponent:reqActivityVoteEggReward(eventId, activityId)
	self:serverActivityMsg(eventId, "RPC_CS_ReqActWeekPrayReceiveEgg", activityId, CallbackHandler(self, "onActivityVoteEggRewardCallback"))
end

function ClientPlayerActivityPlatformComponent:onActivityVoteEggRewardCallback(code)
	if code ~= 0 then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("ClientPlayerActivityPlatformComponent onActivityVoteEggRewardCallback error code:%s", code)
		end

		return
	end

	facade:sendMsgToUI(MessageName.EVENT_CUR_PAGE_REFRESH)
end

function ClientPlayerActivityPlatformComponent:reqActivityCatchScoreReward(eventId, clientIndex)
	local index = clientIndex or -1

	self:serverActivityMsg(eventId, "RPC_CS_LuckyPetGetReward", index, CallbackHandler(self, "onActivityCatchScoreCallback"))
end

function ClientPlayerActivityPlatformComponent:onActivityCatchScoreCallback(code)
	if code ~= 0 then
		return
	end

	facade:sendMsgToUI(MessageName.EVENT_CUR_PAGE_REFRESH)
	facade:sendMsgToUI(MessageName.EVENT_REFRESH_REDDOT)
end

function ClientPlayerActivityPlatformComponent:reqActivityCatchGetScore(eventId, clientIndex)
	local index = clientIndex or -1

	self:serverActivityMsg(eventId, "RPC_CS_LuckyPetSubmit", index, CallbackHandler(self, "onActivityCatchGetScoreCallback"))
end

function ClientPlayerActivityPlatformComponent:onActivityCatchGetScoreCallback(code)
	if code ~= 0 then
		return
	end

	facade:sendMsgToUI(MessageName.EVENT_CUR_PAGE_REFRESH)
	facade:sendMsgToUI(MessageName.EVENT_REFRESH_REDDOT)
end

function ClientPlayerActivityPlatformComponent:on_luckyPetIdFinish_changed(oldV, newV, idx)
	if newV then
		facade:sendMsgToUI(MessageName.EVENT_REFRESH_REDDOT)

		local templateId = self.luckyPetIdList and self.luckyPetIdList[idx]

		if not templateId then
			return
		end

		local _, activityId = ActivityUtils.getOprActivityConfig(ActivityConst.EventType.PuppetCatch)
		local pointNum = PetResearchTrackData[templateId].petScore
		local info = {
			templateId = templateId,
			eventId = activityId,
			pointNum = pointNum
		}

		pg.global.ui.tips:showCompletionPrompt(info)

		local markStaticId = PetResearchTrackData[templateId].petPoint
		local hasTrack = pg.game.map:checkTrackMarkExists(markStaticId)

		if hasTrack then
			pg.game.map:manualUnTraceQuestMark(markStaticId)
		end
	end
end

function ClientPlayerActivityPlatformComponent:on_luckyPetIdSubmit_changed(oldV, newV, idx)
	if newV then
		facade:sendMsgToUI(MessageName.EVENT_REFRESH_REDDOT)

		local templateId = self.luckyPetIdList and self.luckyPetIdList[idx]

		if not templateId then
			return
		end

		local _, activityId = ActivityUtils.getOprActivityConfig(ActivityConst.EventType.PuppetCatch)

		self.logger:debug("__luckyPetIdSubmit_changed true, activityId=%s, idx=%s, templateId=%s", activityId, idx, templateId)
		facade:sendMsgToUI(MessageName.EVENT_CUR_PAGE_REFRESH)
	end
end

function ClientPlayerActivityPlatformComponent:reqActivityPhotoReport(eventId, petProtoTypeId, unlockedClueMap)
	self:serverActivityMsg(eventId, "RPC_CS_FormResearchReport", petProtoTypeId, unlockedClueMap, CallbackHandler(self, "onActivityPhotoReportCallback"))
end

function ClientPlayerActivityPlatformComponent:onActivityPhotoReportCallback(code)
	if code ~= 0 then
		return
	end

	facade:sendMsgToUI(MessageName.EVENT_CUR_PAGE_REFRESH)
end

function ClientPlayerActivityPlatformComponent:on_formResearchClueMap_value_entryAdded(clueId, isUnlocked, petIdx)
	if pg.logDebug() then
		self.logger:debug("__formresearch on_formResearchClueMap_value_entryAdded, clueId=%s, isUnlocked=%s, petPrototypeId=%s", clueId, isUnlocked, petIdx)
	end

	if isUnlocked then
		local prefix = ClientConst.PrefKey.EventFormResearchClueUnlock

		pg.global.prefsCacheUtils:setBool(prefix .. clueId .. pg.me.uid, true)
	end
end

function ClientPlayerActivityPlatformComponent:reqActivityPhotoRewardGet(eventId)
	self:serverActivityMsg(eventId, "RPC_CS_FormResearchGetReward", CallbackHandler(self, "onActivityPhotoRewardGetCallback"))
end

function ClientPlayerActivityPlatformComponent:reqActivityPhotoExtraRewardGet(eventId)
	self:serverActivityMsg(eventId, "RPC_CS_FormResearchGetObReward", CallbackHandler(self, "onActivityPhotoRewardGetCallback"))
end

function ClientPlayerActivityPlatformComponent:onActivityPhotoRewardGetCallback(code)
	if code ~= 0 then
		return
	end

	facade:sendMsgToUI(MessageName.EVENT_CUR_PAGE_REFRESH)
end

function ClientPlayerActivityPlatformComponent:reqActivityPhotoStageRewardGet(eventId, stageIndex)
	self:serverActivityMsg(eventId, "RPC_CS_FormResearchGetStageReward", stageIndex, CallbackHandler(self, "onActivityPhotoStageRewardGetCallback"))
end

function ClientPlayerActivityPlatformComponent:onActivityPhotoStageRewardGetCallback(code)
	if code ~= 0 then
		return
	end

	facade:sendMsgToUI(MessageName.EVENT_CUR_PAGE_REFRESH)
end

function ClientPlayerActivityPlatformComponent:on_formResearchFinish_changed(oldV, newV, idx)
	if newV then
		pg.game.audio:playEvent("SFX_UI_Event_DailySurvey_Correct")
		pg.global.showBubbleMessageRaw(pg.getGameString("PET_RESEARCH_SHAPE_RIGHT"), 3)
		facade:sendMsgToUI(MessageName.EVENT_CUR_PAGE_REFRESH)
	end
end

function ClientPlayerActivityPlatformComponent:on_formResearchRewarded_changed(oldV, newV, idx)
	if newV then
		facade:sendMsgToUI(MessageName.EVENT_CUR_PAGE_REFRESH)
	end
end

function ClientPlayerActivityPlatformComponent:reqActivityPetSave(eventId, petInfo, callback)
	self:serverActivityMsg(eventId, "RPC_CS_ExportPetLegacy", petInfo, callback)
end

function ClientPlayerActivityPlatformComponent:reqActivityPetSaveWeekSumyReward(eventId, subActId, callback)
	self:serverActivityMsg(eventId, "RPC_CS_ReceivePetSaveWeekSumyReward", subActId, callback)
end

function ClientPlayerActivityPlatformComponent:reqOfficialGroupReward(eventId, areaNo, officialGroupId, callback)
	self:serverActivityMsg(eventId, "RPC_CS_GetCommunityGuideReward", areaNo, officialGroupId, callback)
end

function ClientPlayerActivityPlatformComponent:reqGetVitalityScore(eventId, petId, accessories)
	self:serverActivityMsg(eventId, "RPC_CS_GetTotalScore", petId, accessories)
end

function ClientPlayerActivityPlatformComponent:RPC_SC_EnergyMatchScore(totalScore)
	facade:SendMessageCommand(MessageName.EVENT_GET_VITALITY_SCORE, {
		totalScore = totalScore
	})
end

function ClientPlayerActivityPlatformComponent:on_energyMatchAwardFlag_changed(oldV, newV, idx)
	if newV then
		facade:sendMsgToUI(MessageName.EVENT_GET_VITALITY_REWARD)
	end
end

function ClientPlayerActivityPlatformComponent:on_energyMatchAwardFlag_entryAdded(k, v)
	facade:sendMsgToUI(MessageName.EVENT_GET_VITALITY_REWARD)
end

function ClientPlayerActivityPlatformComponent:reqSelectEcoTracePet(eventId, petId)
	self:serverActivityMsg(eventId, "RPC_CS_SelectEcoTracePet", petId, CallbackHandler(self, "onSelectEcoTracePetCallback"))
end

function ClientPlayerActivityPlatformComponent:onSelectEcoTracePetCallback(code)
	if code ~= true then
		return
	end

	facade:sendMsgToUI(MessageName.EVENT_CUR_PAGE_REFRESH)
end

function ClientPlayerActivityPlatformComponent:reqSearchEcoTracePet(eventId, callback)
	self:serverActivityMsg(eventId, "RPC_CS_EcoTraceSearchCreate", callback)
end

function ClientPlayerActivityPlatformComponent:onGetTraceSearchMarkIdCallback(old, new)
	facade:SendMessageCommand(MessageName.EVENT_ECO_TRACE_SEARCH_CHANGE)
end

function ClientPlayerActivityPlatformComponent:reqGetEcoTraceGetReward(eventId, questID)
	self:serverActivityMsg(eventId, "RPC_CS_EcoTraceGetReward", questID, CallbackHandler(self, "onGetEcoTraceGetRewardCallback"))
end

function ClientPlayerActivityPlatformComponent:onGetEcoTraceGetRewardCallback(code)
	if code ~= true then
		return
	end

	facade:sendMsgToUI(MessageName.EVENT_GET_VITALITY_REWARD)
end

function ClientPlayerActivityPlatformComponent:getEcoTracePro(callback)
	ServiceUtils.kvServiceEcoTracePro(ClientActivityUtils.getEcoTraceActivityPhase(), ClientActivityUtils.getEcoTracePetId() or 0, callback)
end

function ClientPlayerActivityPlatformComponent:reqGetEcoTraceFinishReward(eventId)
	self:serverActivityMsg(eventId, "RPC_CS_EcoTraceFinishReward")
end

function ClientPlayerActivityPlatformComponent:onEcoTraceFinishRewardFlagChange(old, new)
	facade:SendMessageCommand(MessageName.EVENT_GET_VITALITY_REWARD)
end

function ClientPlayerActivityPlatformComponent:reqActReceiveGroupTaskReward(taskGroupId, eventId)
	return self:serverActivityMsg(eventId, "RPC_CS_ReqActReceiveGroupTaskReward", taskGroupId, CallbackHandler(self, "onReqActReceiveGroupTaskRewardCallback", taskGroupId))
end

function ClientPlayerActivityPlatformComponent:onReqActReceiveGroupTaskRewardCallback(taskGroupId, code)
	if code ~= 0 then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("ClientPlayerActivityPlatformComponent onReqActReceiveGroupTaskRewardCallback error taskGroupId:%s code:%s", tostring(taskGroupId), tostring(code))
		end

		pg.global.showBubbleMessageById(code)
		facade:sendMsgToUI(MessageName.EVENT_TASK_STATE_CHANGE, {
			success = false,
			isTaskRewardResult = true,
			taskGroupId = taskGroupId,
			code = code
		})
		facade:sendMsgToUI(MessageName.EVENT_REFRESH_REDDOT)

		return
	end

	facade:sendMsgToUI(MessageName.EVENT_TASK_STATE_CHANGE, {
		success = true,
		isTaskRewardResult = true,
		taskGroupId = taskGroupId,
		code = code
	})
	facade:sendMsgToUI(MessageName.EVENT_REFRESH_REDDOT)
end

function ClientPlayerActivityPlatformComponent:reqActReceiveTaskReward(taskId, eventId)
	return self:serverActivityMsg(eventId, "RPC_CS_ReqActReceiveTaskReward", taskId, CallbackHandler(self, "onReqActReceiveTaskRewardCallback", taskId))
end

function ClientPlayerActivityPlatformComponent:onReqActReceiveTaskRewardCallback(requestTaskId, code, actTaskId, receiveAwards)
	local taskId = actTaskId or requestTaskId

	if code ~= 0 then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("ClientPlayerActivityPlatformComponent onReqActReceiveTaskRewardCallback error taskId:%s code:%s", tostring(taskId), tostring(code))
		end

		pg.global.showBubbleMessageById(code)
		facade:sendMsgToUI(MessageName.EVENT_TASK_STATE_CHANGE, {
			success = false,
			isTaskRewardResult = true,
			taskId = taskId,
			code = code
		})
		facade:sendMsgToUI(MessageName.EVENT_REFRESH_REDDOT)

		return
	end

	if actTaskId then
		local actType = ActivityUtils.getActTaskActivityType(actTaskId)

		if actType and actType == ActivityConst.EventType.PetDispatch then
			local taskData = ClientActivityUtils.getTaskInfoByTaskId(ActivityConst.EventType.PetDispatch, actTaskId)

			if taskData and taskData.taskType == ActivityConst.ActivityTaskType.PetDispatch_Dispatch then
				if pg.global.ui:checkUIOpen(UIConst.UI_ID_PET_DISPATCH_TASK) then
					pg.global.ui:close(UIConst.UI_ID_PET_DISPATCH_TASK)
				end

				pg.global.ui:open(UIConst.UI_ID_PET_DISPATCH_SURVEY_COMPLETED, {
					defaultState = 1,
					clueId = actTaskId
				})
			end
		end
	end

	facade:sendMsgToUI(MessageName.EVENT_TASK_STATE_CHANGE, {
		success = true,
		isTaskRewardResult = true,
		taskId = taskId,
		code = code
	})

	local growthGiftData = pg.me and pg.me.activityGrowthGift

	if ActivityUtils.getActTaskActivityType(taskId) == ActivityConst.EventType.GrowthGift and growthGiftData and growthGiftData.recvCollectAllWards == 1 then
		facade:sendMsgToUI(MessageName.EVENT_REFRESH_TAB_LIST)
	end

	facade:sendMsgToUI(MessageName.EVENT_REFRESH_REDDOT)
end

function ClientPlayerActivityPlatformComponent:RPC_SC_NotifyActivityTaskFinished(activityId, taskId)
	local isOpen = activityId and ActivityUtils.isOprActivityOpen(activityId) or nil

	if isOpen then
		facade:sendMsgToUI(MessageName.EVENT_TASK_STATE_CHANGE, {
			isTaskFinished = true,
			activityId = activityId,
			taskId = taskId
		})
		facade:sendMsgToUI(MessageName.EVENT_REFRESH_REDDOT)
	end
end

function ClientPlayerActivityPlatformComponent:on_arkCarnVotePet_entryAdded(k, v)
	facade:sendMsgToUI(MessageName.EVENT_VOTE_PET_REFRESH)
end

function ClientPlayerActivityPlatformComponent:onArkCarnVotePetChanged(oldVal, newVal)
	facade:sendMsgToUI(MessageName.EVENT_VOTE_PET_REFRESH)
	facade:sendMsgToUI(MessageName.EVENT_VOTE_PET_VOTED)
end

function ClientPlayerActivityPlatformComponent:onArkCarnTaskStateChanged(oldVal, newVal)
	facade:sendMsgToUI(MessageName.EVENT_VOTE_PET_REFRESH)

	if newVal == ActivityConst.TaskState.Received then
		facade:sendMsgToUI(MessageName.EVENT_REFRESH_REDDOT)
	end
end

function ClientPlayerActivityPlatformComponent:onArkCarnStageStateChanged(oldVal, newVal)
	if self.arkCarnStageState[3] and self.arkCarnStageState[3] == 1 then
		pg.global.ui.tips:refreshCarnCompletionPrompt()
		facade:sendMsgToUI(MessageName.EVENT_REFRESH_REDDOT)
		pg.game.event:refreshStagePets(pg.me.space.sceneId)
	end
end

function ClientPlayerActivityPlatformComponent:on_arkCarnStageState_entryAdded(k, v)
	if self.arkCarnStageState[3] and self.arkCarnStageState[3] == 1 then
		pg.global.ui.tips:refreshCarnCompletionPrompt()
		facade:sendMsgToUI(MessageName.EVENT_REFRESH_REDDOT)
		pg.game.event:refreshStagePets(pg.me.space.sceneId)
	end
end

function ClientPlayerActivityPlatformComponent:onAddPhotoTakedPet(index, petId)
	local petData = PetPrototypeData[petId]

	if petData then
		local tipsContent = pg.getFormatText(pg.getGameString("ARK_CARNIVAL_13"), pg.getLocalizationText(petData.name))

		pg.global.ui.tips:showTextTip(tipsContent)
	end
end

function ClientPlayerActivityPlatformComponent:onAreaActPetResearchOpenChanged(oldVal, newVal)
	if pg.global.ui.event:checkUIOpen() then
		facade:sendMsgToUI(MessageName.EVENT_REFRESH_TAB_LIST)
	else
		facade:sendMsgToUI(MessageName.EVENT_REFRESH_REDDOT)
	end
end

function ClientPlayerActivityPlatformComponent:on_rechargeSum_changed(oldV, newV)
	facade:sendMsgToUI(MessageName.EVENT_CUR_PAGE_REFRESH)
end

function ClientPlayerActivityPlatformComponent:on_totalAccelHatchTime_changed(oldV, newV)
	facade:sendMsgToUI(MessageName.EVENT_CUR_PAGE_REFRESH)
end

function ClientPlayerActivityPlatformComponent:reqExchangeCode(code)
	pg.me:serverMsg("RPC_CS_ExchangeGiftCode", code, CallbackHandler(self, "onExchangeCodeBack"))

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("@PlayerActivity reqExchangeCode resultCode:%s", code)
	end
end

function ClientPlayerActivityPlatformComponent:onExchangeCodeBack(code)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("@PlayerActivity onExchangeCodeBack resultCode:%s", code)
	end

	if code > 0 and pg.global.ui:checkUIOpen(UIConst.UI_ID_COMMON_TIP_INPUT) then
		local errorMsg = ClientPlayerActivityPlatformComponent._getExchangeGiftCodeErrorMsg(code)

		pg.global.ui.commonTipInput:showErrorMsg(errorMsg)
	end
end

function ClientPlayerActivityPlatformComponent:RPC_SC_ExchangeGiftCodeResult(giftCode, retCode, ret, msg)
	facade:sendMsgToUI(MessageName.ON_EXCHANGE_CODE_RESULT_RES, {
		result = ret,
		resultCode = retCode
	})

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_COMMON_TIP_INPUT) then
		if ret == 1 then
			pg.global.ui.commonTipInput:close()
		else
			local errorMsg = ClientPlayerActivityPlatformComponent._getExchangeGiftCodeErrorMsg(retCode)

			pg.global.ui.commonTipInput:showErrorMsg(errorMsg)
		end
	end

	if ret == 1 then
		pg.global.ui.tips:showTextTip(pg.getGameString("EXCHANGE_CODE_SUCCESS"))
	end

	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("ClientPlayerActivityPlatformComponent:RPC_SC_ExchangeGiftCodeResult giftCode:%s bodyCode:%s, ret:%s, msg:%s", giftCode, retCode, ret, msg)
	end
end

function ClientPlayerActivityPlatformComponent._getExchangeGiftCodeErrorMsg(errorCode)
	if errorCode == 6002 then
		return "EXCHANGE_CODE_ERROR"
	elseif errorCode == 6003 then
		return "EXCHANGE_CODE_EXPIRED"
	elseif errorCode == 6004 then
		return "EXCHANGE_CODE_NUM_LIMIT"
	elseif errorCode == 6005 then
		return "EXCHANGE_CODE_CHANNEL_LIMIT"
	elseif errorCode == 6006 then
		return "EXCHANGE_CODE_LV_LIMIT"
	elseif errorCode == 6007 then
		return "EXCHANGE_CODE_PLATFORM_LIMIT"
	elseif errorCode == 6008 then
		return "EXCHANGE_CODE_DAY_LIMIT"
	else
		return "EXCHANGE_CODE_ERROR"
	end
end

function ClientPlayerActivityPlatformComponent:reqPreHeatReward(eventId)
	self:serverActivityMsg(eventId, "RPC_CS_PreHeatGuideActivity", eventId, CallbackHandler(self, "onPreHeatRewardBack"))
end

function ClientPlayerActivityPlatformComponent:onPreHeatRewardBack(code)
	if code ~= 0 then
		return
	end

	facade:sendMsgToUI(MessageName.EVENT_CUR_PAGE_REFRESH)
end

function ClientPlayerActivityPlatformComponent:reqActivityPetDisPatchStart(eventId, taskId, petList)
	self:serverActivityMsg(eventId, "RPC_CS_ReqActPetDispatchStart", taskId, petList, CallbackHandler(self, "onActivityPetDisPatchStartCallback", petList))
end

function ClientPlayerActivityPlatformComponent:onActivityPetDisPatchStartCallback(petList, code)
	if code ~= 0 then
		return
	end

	pg.global.ui:open(UIConst.UI_ID_PET_DISPATCH_START_TIPS, {
		patchPetList = petList
	})
	facade:sendMsgToUI(MessageName.EVENT_CUR_PAGE_REFRESH)
end

function ClientPlayerActivityPlatformComponent:reqActivityPetDisPatchRecall(eventId, taskId)
	self:serverActivityMsg(eventId, "RPC_CS_ReqActPetDispatchRecall", taskId, CallbackHandler(self, "onActivityPetDisPatchRecallCallback"))
end

function ClientPlayerActivityPlatformComponent:onActivityPetDisPatchRecallCallback(code)
	if code ~= 0 then
		return
	end

	local tipDecs = pg.getGameString("DISPATCH_TASK_RECALL_TIP")

	pg.global.ui.tips:showTextTip(tipDecs)
	facade:sendMsgToUI(MessageName.EVENT_CUR_PAGE_REFRESH)
end

function ClientPlayerActivityPlatformComponent:reqGrowthGiftChooseEgg(eventId, dropId, callback)
	self:serverActivityMsg(eventId, "RPC_CS_GrowthGiftChooseEgg", dropId, function(code)
		if callback then
			callback(code)
		end

		facade:sendMsgToUI(MessageName.EVENT_CUR_PAGE_REFRESH)
	end)
end

function ClientPlayerActivityPlatformComponent:reqGrowthGiftReceiveEgg(eventId, callback)
	self:serverActivityMsg(eventId, "RPC_CS_GrowthGiftReceiveEgg", function(code)
		if callback then
			callback(code)
		end

		facade:sendMsgToUI(MessageName.EVENT_CUR_PAGE_REFRESH)
	end)
end

function ClientPlayerActivityPlatformComponent:RPC_SC_NtfShopCidList(data)
	local err = data[1]
	local shopCidList = data[2]

	if pg.logInfo() then
		logger:info("@PlayerActivity RPC_SC_NtfShopCidList err:%s idList:%s", tostring(err), inspect(shopCidList))
	end

	facade:sendMsgToUI(MessageName.EVENT_MYSTERIOUS_MERCHANT_REFRESH, {
		err = err,
		idList = shopCidList
	})
end

function ClientPlayerActivityPlatformComponent:reqBindAccountQRCode(eventId, typeName, callback)
	self:serverActivityMsg(eventId, "RPC_CS_GetGuideMiniProgramCode", "")
end

function ClientPlayerActivityPlatformComponent:RPC_SC_GetGuideMiniProgramCode(qrCode)
	if pg.logInfo() then
		logger:info("@ClientPlayerActivityPlatformComponent RPC_SC_GetGuideMiniProgramCode qrCode length:%s", qrCode and #qrCode or 0)
	end

	facade:SendMessageCommand(MessageName.SDK_QRCODE_RECEIVED, {
		qrCode = qrCode
	})
end

function ClientPlayerActivityPlatformComponent:reqBindAccountGetAward(eventId, societyID, callback)
	return self:serverActivityMsg(eventId, "RPC_CS_ReceiveBindAccountAward", societyID, callback)
end

function ClientPlayerActivityPlatformComponent:reqGetBindAccountAwardStatus(eventId, callback)
	self:serverActivityMsg(eventId, "RPC_CS_GetBindAccountAwardStatus", function(awardChannelIdList)
		if callback then
			callback(awardChannelIdList)
		end
	end)
end

function ClientPlayerActivityPlatformComponent:RPC_SC_ReportFirebaseLog(fbLogName, details)
	pg.global.sdkManager:reportAdFunnel(fbLogName, details)
end

function ClientPlayerActivityPlatformComponent:RPC_SC_ReportWeGameLog(action, details)
	if pg.logInfo() then
		logger:info("@ClientPlayerActivityPlatformComponent RPC_SC_ReportWeGameLog action:%s details:%s", action, details)
	end

	pg.global.sdkManager:trackWeGame(action, "success", json.encode(details))
end

return ClientPlayerActivityPlatformComponent
