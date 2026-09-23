-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientHatchBoxComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local PlayableConst = require("Common.Const.PlayableConst")
local Utils = require("Common.Utils.Utils")
local AnimationUtils = require("Common.Utils.AnimationUtils")
local UIConst = require("Const.UIConst")
local ClientConst = require("Const.ClientConst")
local PetCharacterData = require("Data.pet_character_data")
local PetTalentData = require("Data.pet_talent_data")
local ItemData = require("Data.item_data")
local PetData = require("Data.pet_data")
local Time = require("Core.Common.Time")
local EventConst = require("Const.EventConst")
local CallbackHandler = require("Core.Common.CallbackHandler")
local PetBallConfigData = require("Data.pet_ball_config_data")
local SysConfigData = require("Data.sys_config_data")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local ClientHatchBoxComponent = class.Component("ClientHatchBoxComponent")

function ClientHatchBoxComponent:start()
	self:initHatchBox()
end

function ClientHatchBoxComponent:initHatchBox()
	local configData = self:getConfigData()

	if self.templateId == ClientConst.HATCH_BOX_ID then
		self.onHatchSLotStatusChanged = self.onHatchSLotStatusChanged or CallbackHandler(self, "refreshHatchBox")

		pg.global.eventEmitter:addEventListener(EventConst.PET_BALL_MAP_HATCH_SLOT_STATUS_CHANGED, self.onHatchSLotStatusChanged)
		self:refreshHatchBox()
	end
end

function ClientHatchBoxComponent:onSkeletonLoaded()
	if self.templateId == ClientConst.HATCH_BOX_ID then
		self:refreshHatchBox()
	end
end

function ClientHatchBoxComponent:refreshHatchBox()
	self.hatchSlotIndex = Utils.getHatchBoxShowSlotIndex()

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		-- block empty
	end

	if not self.hatchSlotIndex then
		self.hatchSlotStatus = Const.PET_BALL.HATCH_STATUS_INIT
	else
		local status = pg.me.hatchSlotMap[self.hatchSlotIndex].status

		self.hatchSlotStatus = status
	end

	local status = Const.HOME_HATCHBOX_STATUS.INIT

	self:stopAllAnimation()

	if self.hatchingTimer then
		self:removeTimer(self.hatchingTimer)

		self.hatchingTimer = nil
	end

	local aniName

	if self.hatchSlotStatus == Const.PET_BALL.HATCH_STATUS_INIT then
		aniName = nil
	elseif self.hatchSlotStatus == Const.PET_BALL.HATCH_STATUS_START then
		local slotData = Utils.getHatchSlotEggInfoByIndex(self.hatchSlotIndex)
		local totalTime = Utils.getHatchTime(slotData.id)
		local ts = pg.me.hatchSlotMap[self.hatchSlotIndex].endTs
		local remainTime = ts - Time.secondCache
		local curPercent = 1 - remainTime / totalTime
		local PERCENT = PetBallConfigData.hatchingChangeRatio

		aniName = curPercent <= PERCENT and "Idle" or "Hatching"
		status = Const.HOME_HATCHBOX_STATUS.HATCHING

		if curPercent <= PERCENT then
			local seperateTime = totalTime * (1 - PERCENT)
			local delayTime = remainTime - seperateTime

			self.hatchingTimer = self:addTimer(math.max(0, delayTime), CallbackHandler(self, "refreshHatchBox"))
		end
	elseif self.hatchSlotStatus == Const.PET_BALL.HATCH_STATUS_SUCC then
		aniName = "Hatched"
		status = Const.HOME_HATCHBOX_STATUS.HATCHED
	end

	if self.m_status ~= status then
		self.m_status = status

		local aniInfo = HomeLandUtils.getHatchBoxAniInfo(status)

		self:playAnimancerAnim(aniInfo.aniName, aniInfo.aniSecond, aniInfo.restart)
		HomeLandUtils.setHatchBoxLoopEffect(self, aniInfo.effectName, aniInfo.effectPos, aniInfo.effectLifeTime, aniInfo.effectManulLoop)
	end

	self:refreshHatchBoxTopLogo()
end

function ClientHatchBoxComponent:refreshHatchBoxTopLogo()
	self.eventEmitter:emit(EventConst.TOPLOGO_PETFERTILITY)
end

function ClientHatchBoxComponent:destroy()
	if self.templateId == ClientConst.HATCH_BOX_ID then
		pg.global.eventEmitter:removeEventListener(EventConst.PET_BALL_MAP_HATCH_SLOT_STATUS_CHANGED, self.onHatchSLotStatusChanged)

		if self.hatchingTimer then
			self:removeTimer(self.hatchingTimer)

			self.hatchingTimer = nil
		end

		HomeLandUtils.clearHatchBoxLoopEffect(self)
	end
end

return ClientHatchBoxComponent
