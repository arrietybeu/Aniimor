-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\HomelandComponent\\ClientHomelandHatchBoxComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local logger = LoggerManager.getLogger("ClientHomelandHatchBoxComponent", "Sandbox", LoggerConst.ERROR)
local MessageName = require("Const.MessageName")
local TimerManager = require("Core.Timer.TimerManager")
local Time = require("Core.Common.Time")
local Const = require("Common.Const.Const")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local PlayableConst = require("Common.Const.PlayableConst")
local CallbackHandlerNoGC = require("Core.Common.CallbackHandlerNoGC")
local NoticeDef = require("Common.NoticeDef")
local HomelandConfigData = require("Data.homeland_config_data")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local ClientHomelandHatchBoxComponent = Class.Component("ClientHomelandHatchBoxComponent")
local FONDLE_ANI_START_DURATION_M_SECOND = 2000
local FONDLE_ANI_LOOP_DURATION_M_SECOND = 3000
local FONDLE_ANI_END_DURATION_M_SECOND = 2500
local FONDLE_ANI_DURATION_SECOND = 3000

function ClientHomelandHatchBoxComponent:ctor()
	self.hatchBoxesInfo = {}
	self.tickHatchBoxesTimer = TimerManager.addRepeatTimer(0.1, function()
		self:m_tickHatchBoxesUpdate()
	end, true)
end

function ClientHomelandHatchBoxComponent:destroy()
	if self.tickHatchBoxesTimer then
		TimerManager.removeTimer(self.tickHatchBoxesTimer)

		self.tickHatchBoxesTimer = nil
	end

	if self.updateTimer then
		TimerManager.removeTimer(self.updateTimer)
	end

	self.updateTimer = nil
end

function ClientHomelandHatchBoxComponent:postInit(dict)
	return
end

function ClientHomelandHatchBoxComponent:EVENT_SetHatchBoxesInfo(fullHatchInfo)
	self:m_setHatchBoxesInfo(fullHatchInfo)
end

function ClientHomelandHatchBoxComponent:m_setHatchBoxesInfo(dict)
	self.hatchBoxesInfo = dict or {}

	self:m_setClientHatchBoxesInfo(dict)

	for ornamentId, _ in pairs(self.hatchBoxesInfo) do
		pg.game.home:updateHatchBox(ornamentId)
	end
end

function ClientHomelandHatchBoxComponent:m_setSingleHatchBoxesInfo(hatchBoxOrnamentId, singleInfo)
	self.hatchBoxesInfo = self.hatchBoxesInfo or {}

	local preIsEmty = not self.hatchBoxesInfo[hatchBoxOrnamentId]

	self.hatchBoxesInfo[hatchBoxOrnamentId] = singleInfo

	if singleInfo and preIsEmty then
		facade:sendMsgToUI(MessageName.HOMELAND_HATCH_UPDATE_ADD_SINGLEINFO, {
			ornamentId = hatchBoxOrnamentId
		})
		self:resetPlayFondleModelVFX(hatchBoxOrnamentId)
	elseif not singleInfo and preIsEmty then
		facade:sendMsgToUI(MessageName.HOMELAND_HATCH_UPDATE_REMOVE_SINGLEINFO, {
			ornamentId = hatchBoxOrnamentId
		})
		self:resetPlayFondleModelVFX(hatchBoxOrnamentId)
	end

	self:m_setClientSingleHatchBoxesInfo(hatchBoxOrnamentId, singleInfo)
end

function ClientHomelandHatchBoxComponent:getHatchBoxInfo(hatchBoxOrnamentId)
	return self.hatchBoxesInfo and self.hatchBoxesInfo[hatchBoxOrnamentId]
end

function ClientHomelandHatchBoxComponent:m_tickHatchBoxesUpdate()
	local nowTime = Time.secondCache

	self.client_hatchBoxesInfo = self.client_hatchBoxesInfo or {}

	for k, v in pairs(self.hatchBoxesInfo) do
		local realHatchBoxInfo = self:getHatchBoxInfo(k)
		local isRealStatusSucc = realHatchBoxInfo and realHatchBoxInfo.status == Const.PET_BALL.HATCH_STATUS_SUCC

		if self.client_hatchBoxesInfo[k] then
			local clientCacheStatus = self.client_hatchBoxesInfo[k] and self.client_hatchBoxesInfo[k].status

			if not isRealStatusSucc and clientCacheStatus ~= Const.PET_BALL.HATCH_STATUS_SUCC and v.endTime and nowTime >= v.endTime then
				facade:sendMsgToUI(MessageName.HOMELAND_HATCH_UPDATE_SINGLEINFO, {
					ornamentId = k
				})
				facade:sendMsgToUI(MessageName.UPDATE_INTERACT_VIEW, {})

				if self.client_hatchBoxesInfo[k] then
					self.client_hatchBoxesInfo[k].status = Const.PET_BALL.HATCH_STATUS_SUCC
				end
			end
		end

		if realHatchBoxInfo then
			self:tryResetPlayFondleModelVFX(k)
		end
	end
end

function ClientHomelandHatchBoxComponent:m_setClientHatchBoxesInfo(fullHatchInfo)
	self.client_hatchBoxesInfo = self.client_hatchBoxesInfo or {}

	for k, v in ipairs(fullHatchInfo) do
		if v then
			self.client_hatchBoxesInfo[k] = {
				endTime = v.endTime,
				status = v.status
			}
		end
	end
end

function ClientHomelandHatchBoxComponent:m_setClientSingleHatchBoxesInfo(hatchBoxOrnamentId, singleInfo)
	self.client_hatchBoxesInfo = self.client_hatchBoxesInfo or {}

	if singleInfo then
		self.client_hatchBoxesInfo[hatchBoxOrnamentId] = self.hatchBoxesInfo[hatchBoxOrnamentId] or {}
		self.client_hatchBoxesInfo[hatchBoxOrnamentId].endTime = singleInfo.endTime
		self.client_hatchBoxesInfo[hatchBoxOrnamentId].status = singleInfo.status
	else
		self.client_hatchBoxesInfo[hatchBoxOrnamentId] = nil
	end
end

function ClientHomelandHatchBoxComponent:getClientHatchBoxInfo(hatchBoxOrnamentId)
	return self.client_hatchBoxesInfo and self.client_hatchBoxesInfo[hatchBoxOrnamentId]
end

function ClientHomelandHatchBoxComponent:RPC_SC_UpdateHatchPetEggInfo(updateHatchInfo)
	self.logger:debug("@homeland|hatch RPC_SC_UpdateHatchPetEggInfo hatchInfo=%s ", inspect(updateHatchInfo))

	for ornamentId, changeInfo in pairs(updateHatchInfo or EMPTY_TABLE) do
		self:m_setSingleHatchBoxesInfo(ornamentId, changeInfo)
		pg.game.home:updateHatchBox(ornamentId)
		facade:sendMsgToUI(MessageName.HOMELAND_HATCH_UPDATE_SINGLEINFO, {
			ornamentId = ornamentId
		})
	end

	facade:sendMsgToUI(MessageName.UPDATE_INTERACT_VIEW, {})
end

function ClientHomelandHatchBoxComponent:RPC_SC_DeleteHatchPetEggInfo(ornamentId)
	self.logger:debug("@homeland|hatch RPC_SC_DeleteHatchPetEggInfo hatchOrnamentId=%s ", ornamentId)

	if self.hatchBoxesInfo == nil then
		return
	end

	if self.hatchBoxesInfo[ornamentId] == nil then
		return
	end

	self:m_setSingleHatchBoxesInfo(ornamentId, nil)
	pg.game.home:updateHatchBox(ornamentId)
	facade:sendMsgToUI(MessageName.HOMELAND_HATCH_UPDATE_SINGLEINFO, {
		ornamentId = ornamentId
	})
	facade:sendMsgToUI(MessageName.UPDATE_INTERACT_VIEW, {})
end

function ClientHomelandHatchBoxComponent:reqStartHatchPetEgg(hatchOrnamentId, itemId, itemGenId)
	pg.me:serverMsg("RPC_CS_HomelandStartHatchPetEgg", hatchOrnamentId, itemId, itemGenId)
end

function ClientHomelandHatchBoxComponent:reqQuitHatchPetEgg(hatchOrnamentId)
	pg.me:serverMsg("RPC_CS_HomelandQuitHatchPetEgg", hatchOrnamentId)
end

function ClientHomelandHatchBoxComponent:reqHatchFondlePetEgg(hatchOrnamentId)
	pg.me:serverMsg("RPC_CS_HomelandHatchFondlePetEgg", hatchOrnamentId, function(noticeId)
		if noticeId == NoticeDef.SUCCESS then
			self:startPlayFondleModelVFX(hatchOrnamentId)
		elseif LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("请求抚摸失败ClientHomelandHatchBoxComponent reqHatchFondlePetEgg noticeId = %s", noticeId)
		end
	end)
end

function ClientHomelandHatchBoxComponent:reqItemSpeedUp(hatchOrnamentId, itemId, itemGenId)
	pg.me:serverMsg("RPC_CS_HomelandItemSpeedUp", hatchOrnamentId, itemId, itemGenId, function(noticeId)
		if noticeId == NoticeDef.SUCCESS then
			local vfxTopOffsetH = HomelandConfigData.hatchBoxLoveBubbleVfxOffset or Const.HatchBoxLoveBubbleVfxOffset

			pg.game.home:driveHatchBoxPlayEffect(hatchOrnamentId, "Eff_Common_Behav_LoveBubble", vfxTopOffsetH)
		elseif LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("请求使用道具加速失败ClientHomelandHatchBoxComponent reqItemSpeedUp noticeId = %s", noticeId)
		end
	end)
end

function ClientHomelandHatchBoxComponent:reqGetHatchPetEgg(hatchOrnamentId)
	local cubeChooseInfo = {
		isHome = true,
		onConfirm = function(cubeItemId)
			local chooseEpoch = pg.game.soulEggEvolution and pg.game.soulEggEvolution:getChooseEpoch() or 0

			pg.me:serverMsg("RPC_CS_HomelandGetHatchPetEgg", hatchOrnamentId, cubeItemId, function(noticeId)
				if noticeId == NoticeDef.SUCCESS then
					return
				end

				if pg.game.soulEggEvolution then
					pg.game.soulEggEvolution:discardPendingHatchRequest(chooseEpoch)
				end

				pg.global.showBubbleMessage(noticeId)

				if pg.game.soulEggEvolution and pg.game.soulEggEvolution:getChooseEpoch() == chooseEpoch then
					pg.game.soulEggEvolution:cancelChooseCube()
				end
			end)
		end,
		onCancel = function()
			return
		end
	}
	local hatchBoxItemInfo = HomeLandUtils.getHatchBoxChooseCubeItemInfo(hatchOrnamentId)

	if not hatchBoxItemInfo then
		return
	end

	local eggInfo = {
		templateId = hatchBoxItemInfo.envObjTemplateId,
		eggItemId = hatchBoxItemInfo.itemId,
		prefabResID = hatchBoxItemInfo.prefabResID
	}

	pg.game.soulEggEvolution:startSoulEggChooseCube(eggInfo, cubeChooseInfo)
end

function ClientHomelandHatchBoxComponent:startPlayFondleModelVFX(hatchOrnamentId)
	self.m_unlockInteractTickSeconds = self.m_unlockInteractTickSeconds or {}
	self.m_unlockInteractTickSeconds[hatchOrnamentId] = Time.realSecondCache * 1000

	self:playFondlePetEggAnimation(hatchOrnamentId)

	local vfxTopOffsetH = HomelandConfigData.hatchBoxLoveVfxOffset or Const.HatchBoxLoveVfxOffset

	pg.game.home:driveHatchBoxPlayEffect(hatchOrnamentId, "Eff_Common_Behav_Love", vfxTopOffsetH)
end

function ClientHomelandHatchBoxComponent:tryResetPlayFondleModelVFX(hatchOrnamentId)
	if self.m_unlockInteractTickSeconds and self.m_unlockInteractTickSeconds[hatchOrnamentId] and Time.realSecondCache * 1000 - self.m_unlockInteractTickSeconds[hatchOrnamentId] >= self:getTotalFondleTime() then
		self:resetPlayFondleModelVFX(hatchOrnamentId)
	end
end

function ClientHomelandHatchBoxComponent:resetPlayFondleModelVFX(hatchOrnamentId)
	if self.m_unlockInteractTickSeconds and self.m_unlockInteractTickSeconds[hatchOrnamentId] and Time.realSecondCache * 1000 - self.m_unlockInteractTickSeconds[hatchOrnamentId] >= self:getTotalFondleTime() then
		self.m_unlockInteractTickSeconds[hatchOrnamentId] = nil
	end
end

function ClientHomelandHatchBoxComponent:getTotalFondleTime()
	return FONDLE_ANI_DURATION_SECOND
end

function ClientHomelandHatchBoxComponent:getIsPlayingFondleAnis(hatchOrnamentId)
	return self.m_unlockInteractTickSeconds and self.m_unlockInteractTickSeconds[hatchOrnamentId] ~= nil
end

function ClientHomelandHatchBoxComponent:playFondlePetEggAnimation(hatchOrnamentId)
	if pg.me and pg.me.eModel then
		pg.me.eModel:DisableSteering(Const.COMPONENT_MOTION)
	end

	self._onSleAnimationEndCb = CallbackHandlerNoGC.newOnceCSharpCb(self, "onSleAnimationEnd", hatchOrnamentId)

	AnimationUtils.playSleAnimation(pg.me, AnimationUtils.getID("Story_TouchMiddle_Start"), AnimationUtils.getID("Story_TouchMiddle_Loop"), AnimationUtils.getID("Story_TouchMiddle_End"), true, self:getTotalFondleTime(), nil, PlayableConst.AnimationLayer.HUMAN_LAYER_BASE, self._onSleAnimationEndCb)
end

function ClientHomelandHatchBoxComponent:onSleAnimationEnd(hatchOrnamentId)
	local vfxTopOffsetH = HomelandConfigData.hatchBoxLoveVfxOffset or Const.HatchBoxLoveVfxOffset

	pg.game.home:driveHatchBoxPlayEffect(hatchOrnamentId, "Eff_Common_Behav_Love", vfxTopOffsetH)

	if not pg.me:isInCatchMode() then
		pg.me:playDefaultAnimation()
	else
		pg.me:playAnimation(PlayableConst.HoldBall_Idle)
	end

	self:resetPlayFondleModelVFX(hatchOrnamentId)
	pg.game.home:updateHatchBox(hatchOrnamentId)

	if pg.me and pg.me.eModel then
		pg.me.eModel:DefaultSteeringMode(Const.COMPONENT_MOTION)
	end
end

return ClientHomelandHatchBoxComponent
