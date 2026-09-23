-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientPlayerTargetComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("ClientPlayerTargetComponent")
local class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local MessageName = require("Const.MessageName")
local TargetUtils = require("GameApp.Target.TargetUtils")
local CallbackHandler = require("Core.Common.CallbackHandler")
local HomelandDemoCmdImplement = require("GameApp.CmdSocket.HomelandDemoCmdImplement")
local ClientPlayerTargetComponent = class.Component("ClientPlayerTargetComponent")

function ClientPlayerTargetComponent:ctor()
	return
end

function ClientPlayerTargetComponent:start()
	return
end

function ClientPlayerTargetComponent:RPC_SC_ShowTarget(targetId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:log2Tag("ClientPlayerTargetComponent", "@wkq RPC_SC_ShowTarget: ", targetId)
	end

	local isTargetStageChange = TargetUtils.isTargetStageChange(targetId)

	pg.game.target:onShowTarget(targetId)

	if isTargetStageChange then
		facade:sendMsgToUI(MessageName.TARGET_ON_CHANGE, {
			targetId = targetId,
			refreshType = Const.HUD_TARGET_CHANGE_TYPE.STAGE
		})
	else
		facade:sendMsgToUI(MessageName.TARGET_ON_CHANGE, {
			targetId = targetId,
			refreshType = Const.HUD_TARGET_CHANGE_TYPE.IN
		})
	end

	pg.game.target:setTopProgress()
end

function ClientPlayerTargetComponent:RPC_SC_UpdateTarget(oldTarget, newTarget)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:log2Tag("ClientPlayerTargetComponent", "@wkq RPC_SC_UpdateTarget: ", oldTarget, newTarget)
	end

	facade:sendMsgToUI(MessageName.TARGET_ON_CHANGE, {
		targetId = newTarget,
		refreshType = Const.HUD_TARGET_CHANGE_TYPE.STAGE
	})
end

function ClientPlayerTargetComponent:RPC_SC_CompleteSubTarget(targetId, subTargetList)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:log2Tag("ClientPlayerTargetComponent", "@wkq RPC_SC_CompleteSubTarget: ", targetId, subTargetList)
	end

	local needPlayFinishAnim = pg.game.target:getNeedPlayFinishAnim(targetId, subTargetList)

	facade:sendMsgToUI(MessageName.TARGET_ON_CHANGE, {
		targetId = targetId,
		subTargetList = subTargetList,
		needPlayFinishAnim = needPlayFinishAnim,
		refreshType = Const.HUD_TARGET_CHANGE_TYPE.OBJECT
	})

	local isDemoMode = pg.space ~= nil and pg.space.demoMode == true or pg.me ~= nil and pg.me.space ~= nil and pg.me.space.demoMode == true

	if isDemoMode then
		HomelandDemoCmdImplement._onTargetSubTargetsCompleted(targetId, subTargetList)
	end
end

function ClientPlayerTargetComponent:RPC_SC_FlushSubTarget(targetId, seqid, curValue, dstValue)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:log2Tag("ClientPlayerTargetComponent", "@wkq RPC_SC_FlushSubTarget: ", targetId, seqid, curValue, dstValue)
	end

	pg.game.target:setTopProgress(curValue, dstValue, seqid)
	facade:sendMsgToUI(MessageName.TARGET_ON_CHANGE, {
		targetId = targetId,
		seqid = seqid,
		curValue = curValue,
		dstValue = dstValue,
		refreshType = Const.HUD_TARGET_CHANGE_TYPE.OBJECT_PROGRESS
	})
end

function ClientPlayerTargetComponent:RPC_SC_DelTarget(targetId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:log2Tag("ClientPlayerTargetComponent", "@wkq RPC_SC_DelTarget: ", targetId)
	end

	pg.game.target:onDelTarget(targetId)
	facade:sendMsgToUI(MessageName.TARGET_ON_CHANGE, {
		targetId = targetId,
		refreshType = Const.HUD_TARGET_CHANGE_TYPE.CLOSE
	})
end

function ClientPlayerTargetComponent:resetTarget(targetId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:log2Tag("ClientPlayerTargetComponent", "@wkq RPC_CS_ResetTarget: ", targetId)
	end

	self:serverMsg("RPC_CS_ResetTarget", targetId)
end

function ClientPlayerTargetComponent:RPC_SC_timerStart(timerId)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:log2Tag("ClientPlayerTargetComponent", "@wkq RPC_SC_timerStart: ", timerId)
	end

	pg.game.target:onTimerStart(timerId)
end

function ClientPlayerTargetComponent:RPC_SC_timerClose(timerId, state)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:log2Tag("ClientPlayerTargetComponent", "@wkq RPC_SC_timerClose: ", timerId, state)
	end

	pg.game.target:onTimerClose(timerId, state)
end

function ClientPlayerTargetComponent:RPC_SC_setTimerTxt(gameStringKey)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:log2Tag("ClientPlayerTargetComponent", "@wkq RPC_SC_setTimerTxt: ", gameStringKey)
	end

	pg.game.target:onTimerTxt(gameStringKey)
end

function ClientPlayerTargetComponent:RPC_SC_resetTimerTxt()
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:log2Tag("ClientPlayerTargetComponent", "@wkq RPC_SC_resetTimerTxt: ")
	end

	pg.game.target:onTimerClose("")
end

function ClientPlayerTargetComponent:RPC_SC_SynTimer(timerId, startTimer)
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:log2Tag("ClientPlayerTargetComponent", "@wkq RPC_SC_SynTimer: ", timerId, startTimer)
	end

	pg.game.target:onTimerUpdate(timerId, startTimer)
end

return ClientPlayerTargetComponent
