-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Interaction\\InteractUnit\\InteractionUnitFallenAidFunc.lua

local Class = require("Core.Framework.Class")
local InteractionUnitBase = require("GameApp.Interaction.InteractionUnitBase")
local ConflictTypes = require("Common.ConflictTypes")
local NoticeDef = require("Common.NoticeDef")
local Vector3 = Vector3
local InteractionUnitFallenAidFunc = Class.LightClass("InteractionUnitFallenAidFunc", InteractionUnitBase)

function InteractionUnitFallenAidFunc:ctor(info, interactId)
	InteractionUnitFallenAidFunc.super.ctor(self, info, interactId)

	self.interactFunc = info.interactFunc
	self.canInteractiveFunc = info.canInteractiveFunc
	self.needCheckDis = info.needCheckDis
	self.targetName = info.name or ""
	self.handlePetEthnicGroup = info.handlePetEthnicGroup
	self.checkEntity = info.checkEntity
end

function InteractionUnitFallenAidFunc:canInteractive()
	if pg.me:isDead() then
		return false
	end

	if not self:checkInteractBlock() then
		return false
	end

	if self.needCheckDis and self.targetPos then
		local configDis = self:getConfigDis()
		local curDis = Vector3.Distance(pg.pawn:getPosition(), self.targetPos)

		if configDis ~= 0 and configDis < curDis then
			return false
		end
	end

	if pg.me:isInCatchMode() then
		return false
	end

	local ent = self:getEntity()

	if not ent or not ent:FALLEN_ST() and not ent:NEAR_DEAD_ST() then
		return false
	end

	if self.canInteractiveFunc then
		return self.canInteractiveFunc(self)
	end

	if self.checkEntity then
		return InteractionUnitFallenAidFunc.super.canInteractive(self)
	end

	return true
end

function InteractionUnitFallenAidFunc:tryInteractive(param)
	local canActualInteract = true

	if pg.me:isControllingEgg() then
		canActualInteract = false
	end

	if not pg.me:checkStatus(ConflictTypes.CT_FIRST_AID, true, nil, true) then
		canActualInteract = false
	end

	if not canActualInteract then
		pg.global.showBubbleMessageById(NoticeDef.ROB_EGG_FORBID_CUR_ACTION)

		return false
	end

	return InteractionUnitFallenAidFunc.super.tryInteractive(self, param)
end

function InteractionUnitFallenAidFunc:interactive()
	pg.me:checkStatus_cancel(ConflictTypes.CT_FIRST_AID)

	if self.interactFunc then
		self.interactFunc(self)
	end
end

function InteractionUnitFallenAidFunc:getActionName()
	local interactData = self.interactData

	if interactData.actionName then
		return pg.getLocalizationText(interactData.actionName)
	end

	return ""
end

function InteractionUnitFallenAidFunc:getText()
	return self:getActionName()
end

return InteractionUnitFallenAidFunc
