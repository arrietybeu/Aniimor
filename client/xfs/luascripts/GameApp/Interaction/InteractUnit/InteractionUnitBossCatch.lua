-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Interaction\\InteractUnit\\InteractionUnitBossCatch.lua

local Class = require("Core.Framework.Class")
local InteractionUnitBase = require("GameApp.Interaction.InteractionUnitBase")
local ClientCaptureUtils = require("Utils.ClientCaptureUtils")
local InteractionConst = require("Common.Const.InteractionConst")
local CatchProbContext = require("Common.Utils.CatchProbContext")
local InteractData = require("Data.interact_data")
local lume = require("Core.Common.lume")
local ClientUtils = require("Utils.ClientUtils")
local SysConfigData = require("Data.sys_config_data")
local Time = require("Core.Common.Time")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local TriggerUtils = require("Common.Utils.TriggerUtils")
local TriggerConst = require("Common.Const.TriggerConst")
local Vector3 = Vector3
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("InteractionUnitBossCatch")
local InteractionUnitBossCatch = Class.LightClass("InteractionUnitBossCatch", InteractionUnitBase)

function InteractionUnitBossCatch:ctor(info, interactId)
	InteractionUnitBossCatch.super.ctor(self, info, interactId)

	self.noBallData = {
		conNotice = 2220
	}
	self.noEmptySlotData = {
		conNotice = 2234
	}
	self.controlPetData = {
		conNotice = 2235
	}
	self.illegalStateData = {
		conNotice = 2236
	}
	self.targetId = self:getEntity().id
end

function InteractionUnitBossCatch:cacheInteractData(protoId)
	local data = InteractData[protoId] and lume.clone(InteractData[protoId]) or {}

	data.styleId = protoId
	data.index = 1

	return data
end

function InteractionUnitBossCatch:interactive()
	local invalidData = self:getInvalidInteractData()

	if invalidData then
		if invalidData.conNotice then
			ClientUtils.showBubbleMessage(invalidData.conNotice)
		end

		return
	end

	local result = pg.game.controller:onHandleBossCapture(self.targetId)

	if not result then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("catch boss InteractionUnitBossCatch onHandleBossCapture failed!")
		end

		return
	end
end

function InteractionUnitBossCatch:canInteractive()
	local ent = self:getEntity()

	if not ent then
		return false
	end

	if not ent.needDoGroupReward then
		return false
	end

	local visible = ent.visible

	if visible == false then
		return false
	end

	if ent.checkCanInteract and not ent:checkCanInteract(self) then
		return false
	end

	if not self:checkInteractAngle() then
		return false
	end

	if not self:checkAirBlock() then
		return false
	end

	if not self:checkInteractBlock() then
		return false
	end

	if not self:checkDistanceValid(ent) then
		return false
	end

	if not self:checkCatchDistance() then
		return false
	end

	if pg.me:isInAir() or pg.me:CLIMB_ST() or pg.me:SWIM_ST() then
		return false
	end

	if pg.me:isInCatchMode() and not pg.me:isInBossCatch() then
		return false
	end

	if not self.interactData.showWhenCantAct and not self:checkConditionId() then
		return false
	end

	local entity = pg.getEntity(self.targetId)

	if entity and entity:isDead() then
		local tolerance = SysConfigData.deadCatchTimeTolerance or 1
		local resetTime = entity.destroyDuration - (pg.me:getGameTime() - entity.destroyStartTime) - tolerance

		if resetTime <= 0 then
			return false
		end
	end

	return true
end

function InteractionUnitBossCatch:getInvalidInteractData()
	local entity = self:getEntity()
	local itemId = ClientCaptureUtils.getItemBossCatchValid(entity)

	if not itemId then
		return self.noBallData
	end

	local emptySlotNum = TriggerUtils.getStatusTriggerCurValue(pg.me, TriggerConst.TRIGGER_PET_REMAINDER_NUM)
	local isFree = ClientCaptureUtils.isBossCatchFreeBall(itemId)

	if not isFree and not ClientCaptureUtils.checkBallItem(itemId, false) then
		return self.noBallData
	elseif not pg.me:checkEnterBossCapture(true) then
		return self.illegalStateData
	elseif pg.me:isControllingPet() then
		return self.controlPetData
	elseif emptySlotNum < 1 then
		return self.noEmptySlotData
	end

	return nil
end

function InteractionUnitBossCatch:getBallItemId()
	return pg.global.ui.hudV2:getCurSelectPropId()
end

function InteractionUnitBossCatch:getInteractBtnStyle()
	return {
		self.interactData
	}
end

function InteractionUnitBossCatch:checkCatchDistance()
	if not SysConfigData.BOSS_CATCH_START_DIST then
		return true
	end

	local ent = self:getEntity()

	if not ent or not pg.pawn then
		return
	end

	local entPos = ent:getPosition()
	local selfPos = pg.pawn:getPosition()
	local distance = Vector3.Distance(selfPos, entPos)

	if distance > SysConfigData.BOSS_CATCH_START_DIST then
		return
	end

	return true
end

return InteractionUnitBossCatch
