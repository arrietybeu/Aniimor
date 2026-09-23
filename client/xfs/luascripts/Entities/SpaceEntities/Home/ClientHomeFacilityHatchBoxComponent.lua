-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\Home\\ClientHomeFacilityHatchBoxComponent.lua

local Class = require("Core.Framework.Class")
local Time = require("Core.Common.Time")
local Utils = require("Common.Utils.Utils")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local MessageName = require("Const.MessageName")
local ItemUtils = require("Common.Utils.ItemUtils")
local LoggerConst = require("Core.Log.LoggerConst")
local LoggerManager = require("Core.Log.LoggerManager")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local InteractionConst = require("Common.Const.InteractionConst")
local logger = LoggerManager.getLogger("ClientHomeFacilityHatchBoxComponent")
local TimerManager = require("Core.Timer.TimerManager")
local EffectConst = require("Const.EffectConst")
local GlobalData = require("Core.Client.GlobalData")
local HomelandOperateData = require("Data.homeland_operate_data")
local HomelandConfigData = require("Data.homeland_config_data")
local AddressDataConst = require("Const.AddressDataConst")
local ClientHomeFacilityHatchBoxComponent = Class.Component("ClientHomeFacilityHatchBoxComponent")

function ClientHomeFacilityHatchBoxComponent:init(dict)
	self:m_initCompInfo()

	return true
end

function ClientHomeFacilityHatchBoxComponent:start()
	self:m_initCompInfo()
	self:updateHatchBox()

	self.tickHatchBoxTimer = TimerManager.addRepeatTimer(0.1, function()
		self:m_tickHatchBox()
	end, true)
end

function ClientHomeFacilityHatchBoxComponent:destroy()
	if self.tickHatchBoxTimer then
		TimerManager.removeTimer(self.tickHatchBoxTimer)

		self.tickHatchBoxTimer = nil
	end

	HomeLandUtils.clearHatchBoxLoopEffect(self)
end

function ClientHomeFacilityHatchBoxComponent:m_tickHatchBox()
	self:tryPlayHatchBoxAnimancerAni()
end

function ClientHomeFacilityHatchBoxComponent:EVENT_InitInteractionList()
	self:initHatchBoxInteractionList()

	if #self.hatchBoxInteractListData > 0 then
		self.interactionListData = self.interactionListData or {}

		for _, data in ipairs(self.hatchBoxInteractListData) do
			self.interactionListData[#self.interactionListData + 1] = data
		end
	end
end

function ClientHomeFacilityHatchBoxComponent:m_initCompInfo()
	self.m_hatchBoxState = Const.PET_BALL.HATCH_STATUS_INIT
	self.m_hatchEndTime = 0
end

function ClientHomeFacilityHatchBoxComponent:checkCurState(stateId)
	return self.m_hatchBoxState == stateId
end

function ClientHomeFacilityHatchBoxComponent:initHatchBoxInteractionList()
	self.hatchBoxInteractListData = {}

	local isMeHomeland = GlobalData.Space:isSelfHomeland()
	local protoData = {}

	protoData[#protoData + 1] = InteractionConst.INTERACT_HOME_HATCHBOX_FONDLE

	if isMeHomeland then
		protoData[#protoData + 1] = InteractionConst.INTERACT_HOME_HATCHBOX_SPEEDUP
		protoData[#protoData + 1] = InteractionConst.INTERACT_HOME_HATCHBOX_VIEWDETAILS
		protoData[#protoData + 1] = InteractionConst.INTERACT_HOME_HATCHBOX_PLACE
		protoData[#protoData + 1] = InteractionConst.INTERACT_HOME_HATCHBOX_SUC
	end

	local configData = self:getConfigData()

	for i, v in ipairs(protoData) do
		self.hatchBoxInteractListData[i] = {
			skipHomelandCheck = true,
			globalId = self:getGlobalId(),
			interactionType = InteractionConst.INTERACTION_TYPE_ENT_FUNC,
			actionPrototypeId = v,
			overrideInteractDis = math.max(configData.interactDistance, 2),
			canInteractiveFunc = function()
				return self:isCanInteractiveFunc(v)
			end,
			interactFunc = function()
				self:doHatchBoxInteract(v)
			end
		}
	end

	self:parseInteractionName(self.hatchBoxInteractListData or {})
end

function ClientHomeFacilityHatchBoxComponent:parseInteractionName(ret)
	if not pg.me or not pg.me.space then
		return
	end

	local hatchBoxInfo = pg.me.space:getHatchBoxInfo(self.ornamentId)

	for _, v in ipairs(ret) do
		local actionPrototype = v and v.actionPrototypeId

		if actionPrototype then
			if actionPrototype == InteractionConst.INTERACT_HOME_HATCHBOX_FONDLE then
				local fondleInfo = HomeLandUtils.getHatchBoxFondleInfo(hatchBoxInfo)
				local fStr = pg.getGameString("HATCH_HOME_FONDLE_REMAIN_CNT")

				fStr = fStr == "HATCH_HOME_FONDLE_REMAIN_CNT" and "FONDLE(%s/%s)" or fStr
				v.name = string.format(fStr, fondleInfo and fondleInfo.showUIRemainCnt or 0, fondleInfo and fondleInfo.showUILimitCnt or 0)
			elseif actionPrototype == InteractionConst.INTERACT_HOME_HATCHBOX_SPEEDUP then
				local speedupInfo = HomeLandUtils.getHatchBoxSpeedupInfo(hatchBoxInfo)
				local fStr = pg.getGameString("HATCH_HOME_SPEEDUP_REMAIN_CNT")

				fStr = fStr == "HATCH_HOME_SPEEDUP_REMAIN_CNT" and "SPEEDUP(%s/%s)" or fStr
				v.name = string.format(fStr, speedupInfo and speedupInfo.remainCnt or 0, speedupInfo and speedupInfo.dailyLimitCnt or 0)
			end
		end
	end
end

function ClientHomeFacilityHatchBoxComponent:isCanInteractiveFunc(actionPrototypeId)
	if not pg.me or not pg.me.space then
		return false
	end

	local hatchOrnamentId = self.ornamentId

	if not hatchOrnamentId then
		return false
	end

	local isPlayingFondleAnis = pg.me.space:getIsPlayingFondleAnis(hatchOrnamentId)

	if isPlayingFondleAnis then
		return false
	end

	local isMeHomeland = GlobalData.Space:isSelfHomeland()
	local hatchBoxInfo = pg.me.space:getHatchBoxInfo(hatchOrnamentId)
	local hatchBoxStatus = HomeLandUtils.getHatchBoxStatus(hatchOrnamentId)

	if actionPrototypeId == InteractionConst.INTERACT_HOME_HATCHBOX_FONDLE then
		if hatchBoxInfo and hatchBoxStatus == Const.HOME_HATCHBOX_STATUS.HATCHING then
			local fondleInfo = HomeLandUtils.getHatchBoxFondleInfo(hatchBoxInfo)

			return fondleInfo and fondleInfo.isCanFondle
		end
	elseif actionPrototypeId == InteractionConst.INTERACT_HOME_HATCHBOX_SPEEDUP then
		return false
	elseif actionPrototypeId == InteractionConst.INTERACT_HOME_HATCHBOX_VIEWDETAILS then
		if isMeHomeland and hatchBoxInfo and hatchBoxStatus == Const.HOME_HATCHBOX_STATUS.HATCHING then
			return true
		end
	elseif actionPrototypeId == InteractionConst.INTERACT_HOME_HATCHBOX_PLACE then
		if isMeHomeland and hatchBoxStatus == Const.HOME_HATCHBOX_STATUS.CAN_PLACE then
			return true
		end
	elseif actionPrototypeId == InteractionConst.INTERACT_HOME_HATCHBOX_SUC and isMeHomeland and hatchBoxInfo and hatchBoxStatus == Const.HOME_HATCHBOX_STATUS.HATCHED then
		return true
	end

	return false
end

function ClientHomeFacilityHatchBoxComponent:doHatchBoxInteract(actionPrototypeId)
	local hatchOrnamentId = self.ornamentId

	if not hatchOrnamentId then
		return false
	end

	local isPlayingFondleAnis = pg.me.space:getIsPlayingFondleAnis(hatchOrnamentId)

	if isPlayingFondleAnis then
		return false
	end

	if actionPrototypeId == InteractionConst.INTERACT_HOME_HATCHBOX_FONDLE then
		local isSuc = HomeLandUtils.tryFondleHatchBox(hatchOrnamentId, true)

		if isSuc then
			pg.global.ui.interactSecond:close()
			facade:sendMsgToUI(MessageName.UPDATE_INTERACT_VIEW, {})
		end

		self:m_hideInteractUI()
	elseif actionPrototypeId == InteractionConst.INTERACT_HOME_HATCHBOX_SPEEDUP then
		local param = {
			ornamentId = self.ornamentId,
			actionPrototypeId = actionPrototypeId
		}

		pg.global.ui:open(UIConst.UI_ID_INCUBATOR, param)
		self:m_hideInteractUI()
	elseif actionPrototypeId == InteractionConst.INTERACT_HOME_HATCHBOX_VIEWDETAILS then
		pg.global.ui.homelandFacilityInfo:open({
			isHatchBox = true,
			ornamentId = self.ornamentId,
			entity = self,
			homeTemplateId = self.homeTemplateId
		})
		self:m_hideInteractUI()
	elseif actionPrototypeId == InteractionConst.INTERACT_HOME_HATCHBOX_PLACE then
		local param = {
			ornamentId = self.ornamentId,
			actionPrototypeId = actionPrototypeId
		}

		pg.global.ui:open(UIConst.UI_ID_INCUBATOR, param)
		self:m_hideInteractUI()
	elseif actionPrototypeId == InteractionConst.INTERACT_HOME_HATCHBOX_SUC then
		HomeLandUtils.tryOpenHatchBox(self.ornamentId)
		self:m_hideInteractUI()
	end
end

function ClientHomeFacilityHatchBoxComponent:m_hideInteractUI()
	pg.global.ui.interactSecond:close()
end

function ClientHomeFacilityHatchBoxComponent:updateHatchBox()
	self.m_hatchBoxInfo = pg.me.space and pg.me.space:getHatchBoxInfo(self.ornamentId) or {}

	local updateState = self.m_hatchBoxInfo.status or Const.PET_BALL.HATCH_STATUS_INIT

	self.m_hatchBoxState = updateState
	self.m_hatchEndTime = self.m_hatchBoxInfo.endTime or 0

	self:parseInteractionName(self.hatchBoxInteractListData or {})
	self:refreshInteractTriggerEvent()
end

function ClientHomeFacilityHatchBoxComponent:playHatchBoxEffect(effectName, offsetH)
	local vfxPos = self:getPosition() + Vector3.New(0, offsetH, 0)

	pg.game.effect:playEffectAt(nil, effectName, vfxPos, pg.me:getRotation():ToEulerAngles(), self)
end

function ClientHomeFacilityHatchBoxComponent:tryPlayHatchBoxAnimancerAni()
	if not self.eModel then
		return
	end

	if not self:hasEModelComponent(Const.COMPONENT_INDEX_ANIMATOR) then
		return
	end

	local status = HomeLandUtils.getHatchBoxStatus(self.ornamentId)

	if self.m_preStatus == status then
		return
	end

	self.m_preStatus = status

	local aniInfo = self:getAniInfoByStatu(status)

	if not aniInfo.aniName then
		return
	end

	self:playAnimancerAnim(aniInfo.aniName, aniInfo.aniSecond, aniInfo.restart)
	self:setLoopEffectInfo(aniInfo.effectName, aniInfo.effectPos, aniInfo.effectLifeTime, aniInfo.effectManulLoop)
end

function ClientHomeFacilityHatchBoxComponent:setLoopEffectInfo(effectName, pos, lifeTime, effectManulLoop)
	HomeLandUtils.setHatchBoxLoopEffect(self, effectName, pos, lifeTime, effectManulLoop)
end

function ClientHomeFacilityHatchBoxComponent:getAniInfoByStatu(status)
	local aniInfo = HomeLandUtils.getHatchBoxAniInfo(status)

	return aniInfo
end

return ClientHomeFacilityHatchBoxComponent
