-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientPlayerHomeSeasonComponent.lua

local class = require("Core.Framework.Class")
local MessageName = require("Const.MessageName")
local NoticeDef = require("Common.NoticeDef")
local PropertyTypes = require("Core.PropertySync.PropertyTypes")
local ClientPlayerHomeSeasonComponent = class.Component("ClientPlayerHomeSeasonComponent")

function ClientPlayerHomeSeasonComponent:notifyHomeSeasonChanged(ov, nv)
	facade:sendMsgToUI(MessageName.HOME_SEASON_CHANGE, {
		oldV = ov,
		newV = nv
	})
end

function ClientPlayerHomeSeasonComponent:onHomeSeasonId_changed(ov, nv)
	self:notifyHomeSeasonChanged(ov, nv)
end

function ClientPlayerHomeSeasonComponent:onHomeSeasonUnlockTs_changed(ov, nv)
	self:notifyHomeSeasonChanged(ov, nv)
end

function ClientPlayerHomeSeasonComponent:onHomeSeasonStageId_changed(ov, nv)
	facade:sendMsgToUI(MessageName.HOME_SEASON_STAGE_CHANGE, {
		oldV = ov,
		newV = nv
	})
end

function ClientPlayerHomeSeasonComponent:onHomeSeasonOrderList_changed(ov, nv)
	facade:sendMsgToUI(MessageName.ON_HOME_ORDER_LIST_CHANGED)
end

function ClientPlayerHomeSeasonComponent:reqSubmitHomeSeasonOrder(insId, onSuccess)
	self:serverMsg("RPC_CS_SubmitHomeSeasonOrder", insId, function(res)
		if res == NoticeDef.SUCCESS then
			if onSuccess then
				onSuccess()
			end

			facade:sendMsgToUI(MessageName.ON_HOME_ORDER_LIST_CHANGED)
		else
			pg.global.showBubbleMessage(res)
		end
	end)
end

function ClientPlayerHomeSeasonComponent:notifyHomeSeasonProgressChanged()
	facade:sendMsgToUI(MessageName.HOME_SEASON_PROGRESS_CHANGE)
end

function ClientPlayerHomeSeasonComponent:onHomeSeasonCollectionScore_changed(ov, nv)
	self:notifyHomeSeasonProgressChanged()
end

function ClientPlayerHomeSeasonComponent:onHomeSeasonCollectionRewardStateMap_changed(ov, nv)
	self:notifyHomeSeasonProgressChanged()
end

function ClientPlayerHomeSeasonComponent:onHomeSeasonCollectionRewardState_added(rewardRowId, rewardState)
	self:notifyHomeSeasonProgressChanged()
end

function ClientPlayerHomeSeasonComponent:onHomeSeasonCollectionRewardState_deleted(rewardRowId, rewardState)
	self:notifyHomeSeasonProgressChanged()
end

function ClientPlayerHomeSeasonComponent:onHomeSeasonCollectionRewardState_changed(ov, nv, rewardRowId)
	self:notifyHomeSeasonProgressChanged()
end

function ClientPlayerHomeSeasonComponent:handleHomeSeasonCelebrationResponse(result, callback)
	if result ~= NoticeDef.SUCCESS then
		pg.global.showBubbleMessage(result)
	end

	if callback then
		callback(result)
	end
end

function ClientPlayerHomeSeasonComponent:reqStartHomeSeasonCelebration(festivalId, callback)
	self:serverMsg("RPC_CS_StartHomeSeasonCelebration", festivalId, function(result)
		self:handleHomeSeasonCelebrationResponse(result, callback)
	end)
end

function ClientPlayerHomeSeasonComponent:reqBeginHomeSeasonCelebration(callback)
	self:serverMsg("RPC_CS_BeginHomeSeasonCelebration", function(result)
		self:handleHomeSeasonCelebrationResponse(result, callback)
	end)
end

function ClientPlayerHomeSeasonComponent:reqCancelHomeSeasonCelebration(callback)
	self:serverMsg("RPC_CS_CancelHomeSeasonCelebration", function(result)
		self:handleHomeSeasonCelebrationResponse(result, callback)
	end)
end

function ClientPlayerHomeSeasonComponent:notifyHomeSeasonTaskChanged(taskId)
	facade:sendMsgToUI(MessageName.HOME_SEASON_TASK_CHANGED, taskId)
end

function ClientPlayerHomeSeasonComponent:onHomeSeasonTaskStateMap_changed(ov, nv)
	self:notifyHomeSeasonTaskChanged()
end

function ClientPlayerHomeSeasonComponent:onHomeSeasonTaskState_changed(ov, nv, taskId)
	self:notifyHomeSeasonTaskChanged(taskId)

	return PropertyTypes.CALLBACK_SWALLOW
end

function ClientPlayerHomeSeasonComponent:onHomeSeasonTaskState_added(taskId, taskState)
	self:notifyHomeSeasonTaskChanged(taskId)

	return PropertyTypes.CALLBACK_SWALLOW
end

function ClientPlayerHomeSeasonComponent:onHomeSeasonTaskState_deleted(taskId, taskState)
	self:notifyHomeSeasonTaskChanged(taskId)

	return PropertyTypes.CALLBACK_SWALLOW
end

function ClientPlayerHomeSeasonComponent:onHomeSeasonTaskPendingRewardMap_changed(ov, nv)
	self:notifyHomeSeasonTaskChanged()
end

function ClientPlayerHomeSeasonComponent:onHomeSeasonTaskPendingReward_changed(ov, nv, taskId)
	self:notifyHomeSeasonTaskChanged(taskId)

	return PropertyTypes.CALLBACK_SWALLOW
end

function ClientPlayerHomeSeasonComponent:onHomeSeasonTaskPendingReward_added(taskId, pendingRewardCount)
	self:notifyHomeSeasonTaskChanged(taskId)

	return PropertyTypes.CALLBACK_SWALLOW
end

function ClientPlayerHomeSeasonComponent:onHomeSeasonTaskPendingReward_deleted(taskId, pendingRewardCount)
	self:notifyHomeSeasonTaskChanged(taskId)

	return PropertyTypes.CALLBACK_SWALLOW
end

function ClientPlayerHomeSeasonComponent:reqReceiveHomeSeasonTaskReward(taskId, callback)
	self:serverMsg("RPC_CS_ReceiveHomeSeasonTaskReward", taskId, callback)
end

return ClientPlayerHomeSeasonComponent
