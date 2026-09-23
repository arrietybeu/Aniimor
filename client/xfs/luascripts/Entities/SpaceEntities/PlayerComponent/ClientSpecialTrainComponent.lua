-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientSpecialTrainComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local logger = LoggerManager.getLogger("SpecialTrain")
local ClientSpecialTrainComponent = Class.Component("ClientSpecialTrainComponent")
local MessageName = require("Const.MessageName")
local QuestUtils = require("GameApp.Quest.QuestUtils")
local CallbackHandler = require("Core.Common.CallbackHandler")

function ClientSpecialTrainComponent:ctor()
	return
end

function ClientSpecialTrainComponent:getSpecialTrainEntryReward(questList, srcType, callback)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("getSpecialTrainEntryReward")
	end

	self:serverMsg("RPC_CS_GetSpecialTrainEntryReward", questList, srcType, CallbackHandler(self, "getSpecialTrainEntryRewardCallback", callback))
end

function ClientSpecialTrainComponent:getSpecialTrainEntryRewardCallback(callback, retStatus)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("getSpecialTrainEntryRewardCallback")
	end

	if callback ~= nil then
		callback(retStatus)
		facade:sendMsgToUI(MessageName.RED_DOT_SPECIAL_TRAIN_TREE)
	end
end

function ClientSpecialTrainComponent:getSpecialTrainBadgeReward(isFinal, callback)
	self:serverMsg("RPC_CS_GetSpecialTrainBadgeReward", isFinal, CallbackHandler(self, "getSpecialTrainBadgeRewardCallback", callback))
end

function ClientSpecialTrainComponent:getSpecialTrainBadgeRewardCallback(callback, retStatus)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("getSpecialTrainBadgeRewardCallback")
	end

	if callback ~= nil then
		callback(retStatus)
		facade:sendMsgToUI(MessageName.RED_DOT_SPECIAL_TRAIN_TREE)
	end
end

function ClientSpecialTrainComponent:firstOpenSpecialTrainInterface()
	if pg.me.isOpenedTrainInterface == false then
		self:serverMsg("RPC_CS_FirstOpenSpecialTrainInterface")
	end
end

function ClientSpecialTrainComponent:RPC_SC_StartSpecialTrainSystem()
	QuestUtils.manualTrackSecondTracingQuest()
end

function ClientSpecialTrainComponent:firstViewSpeicalTrainChapter(chapterId)
	self:serverMsg("RPC_CS_FirstViewSpeicalTrainChapter", chapterId)
end

function ClientSpecialTrainComponent:getSpecialTrainChapterReward(chapterId, callback)
	self:serverMsg("RPC_CS_GetSpecialTrainChapterReward", chapterId, CallbackHandler(self, "getSpecialTrainChapterRewardCallback", callback))
end

function ClientSpecialTrainComponent:getSpecialTrainChapterRewardCallback(callback, retStatus)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("getSpecialTrainChapterRewardCallback")
	end

	if callback ~= nil then
		callback(retStatus)
		facade:sendMsgToUI(MessageName.RED_DOT_SPECIAL_TRAIN_TREE)
	end
end

function ClientSpecialTrainComponent:getSpecialTrainBadgeContinuousReward(callback)
	self:serverMsg("RPC_CS_GetSpecialTrainBadgeContinuousReward", CallbackHandler(self, "getSpecialTrainBadgeContinuousRewardCallback", callback))
end

function ClientSpecialTrainComponent:getSpecialTrainBadgeContinuousRewardCallback(callback, retStatus)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("getSpecialTrainBadgeContinuousRewardCallback")
	end

	if callback ~= nil then
		callback(retStatus)
		facade:sendMsgToUI(MessageName.RED_DOT_SPECIAL_TRAIN_TREE)
	end
end

function ClientSpecialTrainComponent:RPC_SC_UnlockSpecialTrainType(trainType)
	return
end

function ClientSpecialTrainComponent:RPC_SC_UnlockSpecialTrainChapter(chapterId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("RPC_SC_UnlockSpecialTrainChapter", chapterId)
	end

	facade:sendMsgToUI(MessageName.SPECIAL_TRAIN_CHAPTER_UNLOCK, chapterId)
end

function ClientSpecialTrainComponent:viewSpecialTrainStarTitleQuest(chapterId)
	self:serverMsg("RPC_CS_ViewSpecialTrainStarTitleQuest", chapterId)
end

return ClientSpecialTrainComponent
