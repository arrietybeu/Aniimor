-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Interaction\\InteractUnit\\InteractionQuickCatch.lua

local Class = require("Core.Framework.Class")
local InteractionUnitBase = require("GameApp.Interaction.InteractionUnitBase")
local ClientCaptureUtils = require("Utils.ClientCaptureUtils")
local InteractionConst = require("Common.Const.InteractionConst")
local CatchProbContext = require("Common.Utils.CatchProbContext")
local InteractData = require("Data.interact_data")
local lume = require("Core.Common.lume")
local ClientUtils = require("Utils.ClientUtils")
local castItemData = require("Data.cast_item_data")
local Utils = require("Common.Utils.Utils")
local SysConfigData = require("Data.sys_config_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local TriggerUtils = require("Common.Utils.TriggerUtils")
local TriggerConst = require("Common.Const.TriggerConst")
local InteractionQuickCatch = Class.LightClass("InteractionQuickCatch", InteractionUnitBase)

function InteractionQuickCatch:ctor(info, interactId)
	InteractionQuickCatch.super.ctor(self, info, interactId)

	self.noLoginData = self:cacheInteractData(InteractionConst.INTERACTION_TYPE_QUICK_CAPTURE_NOT_BIND)
	self.noBallData = self:cacheInteractData(InteractionConst.INTERACTION_TYPE_QUICK_CAPTURE_NO_BALL)
	self.illegalData = self:cacheInteractData(InteractionConst.INTERACTION_TYPE_QUICK_CAPTURE_ILLEGAL_BALL)
	self.noEmptySlotData = self:cacheInteractData(InteractionConst.INTERACTION_TYPE_QUICK_CAPTURE_NO_EMPTY_SLOT)
end

function InteractionQuickCatch:cacheInteractData(protoId)
	local data = InteractData[protoId] and lume.clone(InteractData[protoId]) or {}

	data.styleId = protoId
	data.index = 1

	return data
end

function InteractionQuickCatch:getBallItemId()
	return pg.global.ui.hudV2:getCurSelectPropId()
end

function InteractionQuickCatch:interactive()
	local invalidData = self:getInvalidInteractData()

	if invalidData then
		if invalidData.conNotice then
			ClientUtils.showBubbleMessage(invalidData.conNotice)
		end

		return
	end

	if not pg.me:checkQuickCatch() then
		return
	end

	if pg.me.beControlled and not pg.me:checkEnterCatchMode(true) then
		return
	end

	local result = pg.game.controller:onHandleQuickCapture(self.targetId)

	if not result then
		return
	end
end

function InteractionQuickCatch:setTargetId(entId)
	self.targetId = entId
end

function InteractionQuickCatch:canInteractive()
	if pg.me:isInCatchMode() then
		return false
	end

	if not pg.me:checkQuickCatch(true) then
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

	return self.enableInteract
end

function InteractionQuickCatch:setEnableInteractive(enabled)
	if not self.enableInteract and enabled then
		self.firstShowInteract = true
	end

	self.enableInteract = enabled
end

function InteractionQuickCatch:getInteractBtnStyle()
	if not self.targetId then
		return
	end

	local invalidData = self:getInvalidInteractData()
	local entity = pg.getEntity(self.targetId)

	if invalidData then
		invalidData.rate = 0
		invalidData.tIndex = 2
		invalidData.entity = entity
		invalidData.firstShow = self.firstShowInteract
		invalidData.ballState = 1
		self.firstShowInteract = false

		return {
			invalidData
		}
	else
		local itemId = self:getBallItemId()

		self.interactData.rate = CatchProbContext.clientGet(entity, itemId).finalProb
		self.interactData.tIndex = 2
		self.interactData.entity = entity
		self.interactData.firstShow = self.firstShowInteract

		local configInfo = InteractData[self.interactData.styleId]

		self.interactData.btnIcon = configInfo.iconId
		self.interactData.hotkeyType = configInfo.hotkeyType

		local btnName = self:getText(self.interactData)

		self.interactData.btnTitle = btnName
		self.interactData.actionPath = "Hud/Interact"
		self.firstShowInteract = false

		return {
			self.interactData
		}
	end
end

function InteractionQuickCatch:getInvalidInteractData()
	local itemId = self:getBallItemId()

	if not itemId then
		return self.noBallData
	end

	local castItemId = Utils.itemId2CastItemId(itemId)
	local ballData = castItemData[castItemId]

	if not ballData then
		return self.noBallData
	end

	local emptySlotNum = TriggerUtils.getStatusTriggerCurValue(pg.me, TriggerConst.TRIGGER_PET_REMAINDER_NUM)
	local emptySlot = ballData.proxy == "BigBall" and emptySlotNum < 10 or ballData.proxy == "CatchBall" and emptySlotNum < 1

	if false then
		return self.noLoginData
	elseif not ballData.canQuickCaptureInHand then
		return self.illegalData
	elseif not ClientCaptureUtils.checkBallCanThrow(itemId) then
		return self.illegalData
	elseif not ClientCaptureUtils.checkBallItem(itemId, false) then
		return self.noBallData
	elseif emptySlot then
		return self.noEmptySlotData
	end

	return nil
end

function InteractionQuickCatch:checkChanged()
	local itemId = self:getBallItemId()

	if self.lastCheckItemId ~= itemId then
		self.lastCheckItemId = itemId

		return true
	end

	local invalidData = self:getInvalidInteractData()

	if self.lastCheckInvalidData ~= invalidData then
		self.lastCheckInvalidData = invalidData

		return true
	end

	return false
end

function InteractionQuickCatch:getIcon()
	local invalidData = self:getInvalidInteractData()

	if invalidData then
		return invalidData.iconId
	else
		local itemId = self:getBallItemId()

		return LuaUIUtils.getIconByItemId(itemId)
	end
end

function InteractionQuickCatch:getBtnStyleData()
	local temp = {}
	local configInfo = InteractData[self.interactData.styleId]

	temp.btnIcon = configInfo.iconId
	temp.hotkeyType = configInfo.hotkeyType
	temp.styleId = self.interactData.styleId
	temp.rate = self.interactData.rate

	local btnName = self:getText(self.interactData)

	temp.btnTitle = btnName
	temp.actionPath = "Hud/Interact"

	return temp
end

return InteractionQuickCatch
