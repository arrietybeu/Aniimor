-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientPlayerCarryComponent.lua

local class = require("Core.Framework.Class")
local CallbackHandler = require("Core.Common.CallbackHandler")
local MessageName = require("Const.MessageName")
local Const = require("Common.Const.Const")
local AiConst = require("Common.Const.AiConst")
local OpDef = require("Common.OpDef")
local NoticeDef = require("Common.NoticeDef")
local ConflictTypes = require("Common.ConflictTypes")
local Utils = require("Common.Utils.Utils")
local AIUtils = require("Common.Utils.AIUtils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local HoldEntPanelConfig = require("Data.hold_ent_panel_config_data")
local HoldItemData = require("Data.hold_item_data")
local PlayableConst = require("Common.Const.PlayableConst")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local ClientPlayerCarryComponent = class.Component("ClientPlayerCarryComponent")

function ClientPlayerCarryComponent:destroy()
	self:clearCarryItemShowOffTimer()
end

function ClientPlayerCarryComponent:preDestroy()
	self:stopCarryItemShowOff(false)
end

function ClientPlayerCarryComponent:onLeaveSpace()
	self:clearCarryItemShowOffTimer()
	self:stopCarryItemShowOff(false)

	self.carryItemMoveInput = false
end

function ClientPlayerCarryComponent:isSocialGrabReady(ent)
	if ent == nil or ent.destroyed then
		return false
	end

	if not ent.isModelLoaded then
		return false
	end

	if not ent.eModel then
		return false
	end

	if self.carryType ~= Const.CARRY_TYPE.ITEM then
		local targetAnimator = ent.eModel.animator

		if targetAnimator == nil or IsNil(targetAnimator) then
			return false
		end
	end

	return true
end

function ClientPlayerCarryComponent:requestCarryOp(op, params, callback)
	if not self.isMainPlayer then
		self.logger:warn("only main player can request carry op=%s", OpDef.repr(op, params))

		return
	end

	local localCallback = callback or function(noticeId, noticeArgs)
		if pg.logDebug() then
			self.logger:debug("__carry op=%s, res=%s", OpDef.repr(op, params), NoticeDef.getRepr(noticeId, noticeArgs), self:repr())
		end
	end

	self:serverMsg("RPC_CS_CarryOp", op, params, localCallback)
end

function ClientPlayerCarryComponent:RPC_SC_CarryOp(op, params)
	if pg.logDebug() then
		self.logger:debug("__carry op=%s", OpDef.repr(op, params), self:repr())
	end

	if op == OpDef.OP.SC_PC_OnStartCarry then
		local ent = pg.getEntity(self.carryObjId)

		if ent then
			self:carryEntImp(ent)
		end
	elseif op == OpDef.OP.SC_PC_OnDropCarry then
		self:dropEntImp()
	elseif op == OpDef.OP.CS_PC_StrokePet then
		self:playCarryStrokePet(params)
	elseif op == OpDef.OP.CS_PC_InspectItem then
		self:playCarryInspectItem(params)
	end
end

function ClientPlayerCarryComponent:playCarryStrokePet(params)
	if not ToBool(params and params.actFlag) then
		return
	end

	local targetEntity = pg.getEntity(params.targetId)
	local interactGestureComponent = pg.game.social and pg.game.social.interactGestureComponent

	if targetEntity and interactGestureComponent then
		interactGestureComponent:playTouchPetInteraction(self, targetEntity)
	end
end

function ClientPlayerCarryComponent:playCarryInspectItem(params)
	if ToBool(params and params.actFlag) then
		self:clearCarryItemShowOffTimer()
		self:tryEnterCarryItemShowOff()
	else
		self:recoverCarryItemNormalGrab()

		if self.isMainPlayer then
			self:startCarryItemShowOffTimer()
		end
	end
end

function ClientPlayerCarryComponent:tryCarryEnt(entId, opId, fromType, callback)
	local ent = pg.getEntity(entId)

	if ent and not ent:checkStatus(ConflictTypes.CT_ENT_BE_HUG, true) then
		return
	end

	if self:checkStatus(ConflictTypes.CT_START_HUG_ENT) and not self:SOCIAL_ANIM_ST() and not self:SOCIAL_INTERACT_ACTION_ST() then
		self:requestCarryOp(opId, {
			petId = entId,
			fromType = fromType or 0
		}, callback)
	else
		pg.global.showBubbleMessageById(NoticeDef.HOME_CARRY_PET_ST)
	end
end

function ClientPlayerCarryComponent:tryTakeOutItem(invId, genId, callback)
	if self:checkStatus(ConflictTypes.CT_START_HUG_ENT) then
		self:requestCarryOp(OpDef.OP.CS_PC_ItemTakeOut, {
			invId = invId,
			genId = genId
		})
	else
		pg.global.showBubbleMessageById(NoticeDef.HOME_CARRY_PET_ST)
	end
end

function ClientPlayerCarryComponent:tryStrokeCarryPet(targetId, callback)
	self:requestCarryOp(OpDef.OP.CS_PC_StrokePet, {
		actFlag = true,
		targetId = targetId
	}, callback)
end

function ClientPlayerCarryComponent:getCarryItemShowOffDelay()
	return HoldEntPanelConfig.showOffActionTime or 0
end

function ClientPlayerCarryComponent:clearCarryItemShowOffTimer()
	if self.carryItemShowOffTimer then
		self:removeTimer(self.carryItemShowOffTimer)

		self.carryItemShowOffTimer = nil
	end
end

function ClientPlayerCarryComponent:canStartCarryItemShowOffTimer()
	if not self.isMainPlayer then
		return false
	end

	return self:canEnterCarryItemShowOff()
end

function ClientPlayerCarryComponent:canEnterCarryItemShowOff()
	if self.carryType ~= Const.CARRY_TYPE.ITEM then
		return false
	end

	if self.carryItemMoveInput or self.carryItemShowOff then
		return false
	end

	if not self.carryEnt or self.carryEnt.destroyed then
		return false
	end

	return self:getCarryItemShowOffDelay() > 0
end

function ClientPlayerCarryComponent:startCarryItemShowOffTimer()
	self:clearCarryItemShowOffTimer()

	if not self:canStartCarryItemShowOffTimer() then
		return
	end

	self.carryItemShowOffTimer = self:addTimer(self:getCarryItemShowOffDelay(), function()
		self.carryItemShowOffTimer = nil

		self:requestCarryOp(OpDef.OP.CS_PC_InspectItem, {
			actFlag = true
		})
	end)
end

function ClientPlayerCarryComponent:playNormalCarryGrab(ent)
	local ikOffset, offset, euler, ani, effectOn = ent:getHoldConfigDatas()

	AIUtils.PauseAI(ent, AiConst.PauseBtReason.BeCarry)

	self.carryEnt = ent

	self.eModel:StartSocialGrab(Const.COMPONENT_INDEX_IK, ent.eModel, ikOffset, offset, euler, ani, effectOn)
end

function ClientPlayerCarryComponent:EVENT_OnCharacterStateChange(oldState, newState)
	if not CharacterStateConst.isFirstEnterState(oldState, newState, CharacterStateConst.CARRY) then
		return
	end

	local ent = self.carryEnt

	if ent and ent.characterState ~= CharacterStateConst.BEGRAB and self:isSocialGrabReady(ent) then
		self:playNormalCarryGrab(ent)
	end
end

function ClientPlayerCarryComponent:attachCarryItemToShowOffBone()
	local ent = self.carryEnt

	if not ent or ent.destroyed then
		return
	end

	ent:attachByTable({
		targetHP = "Bip001 Prop2",
		ignoreEntityCollide = 1,
		selfHP = "",
		entId = self.id,
		offset = {
			0,
			0,
			0
		},
		rotate = {
			0,
			0,
			0
		}
	})
end

function ClientPlayerCarryComponent:playCarryItemShowOff(showOffAction)
	self.eModel.InSocialAnim = true

	self.eModel:EnableIK(Const.COMPONENT_INDEX_IK, 7, false)
	self:attachCarryItemToShowOffBone()

	self.carryItemShowOffAction = CS.UnityEngine.Animator.StringToHash(showOffAction)

	return self:playAnimation(self.carryItemShowOffAction, true, nil, true, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
end

function ClientPlayerCarryComponent:stopCarryItemShowOff(recoverState)
	if not self.carryItemShowOff then
		return
	end

	local showOffAction = self.carryItemShowOffAction

	self.carryItemShowOff = false
	self.carryItemShowOffAction = nil

	if showOffAction then
		self:stopAnimation(showOffAction, nil, PlayableConst.AnimationLayer.HUMAN_LAYER_FULLBODY)
	end

	self.eModel:EnableIK(Const.COMPONENT_INDEX_IK, 7, true)

	self.eModel.InSocialAnim = false

	if recoverState ~= false and self.carryEnt and self:isSocialGrabReady(self.carryEnt) then
		self:playNormalCarryGrab(self.carryEnt)
	end
end

function ClientPlayerCarryComponent:tryEnterCarryItemShowOff()
	if not self:canEnterCarryItemShowOff() then
		return
	end

	if not self:isSocialGrabReady(self.carryEnt) then
		return
	end

	local itemId = self.carryEnt and self.carryEnt.item and self.carryEnt.item.id
	local showOffAction = itemId and HoldItemData[itemId] and HoldItemData[itemId].showoffaction and HoldItemData[itemId].showoffaction[1]

	if not showOffAction then
		return
	end

	self.carryItemShowOff = true

	if not self:playCarryItemShowOff(showOffAction) then
		self:stopCarryItemShowOff()
	end
end

function ClientPlayerCarryComponent:recoverCarryItemNormalGrab()
	if not self.carryItemShowOff then
		return
	end

	self:stopCarryItemShowOff()
end

function ClientPlayerCarryComponent:EVENT_OnMoveInputStateChanged(nv)
	if not self.isMainPlayer then
		return
	end

	self.carryItemMoveInput = nv and true or false

	if self.carryType ~= Const.CARRY_TYPE.ITEM then
		return
	end

	if self.carryItemMoveInput then
		self:clearCarryItemShowOffTimer()

		if self.carryItemShowOff then
			self:requestCarryOp(OpDef.OP.CS_PC_InspectItem, {
				actFlag = false
			})
		end
	else
		self:startCarryItemShowOffTimer()
	end
end

function ClientPlayerCarryComponent:carryEntImp(ent)
	if not self:isSocialGrabReady(ent) then
		self.waitCarryTargetEnt = true

		return
	end

	self.waitCarryTargetEnt = false

	self:stopCarryItemShowOff(false)
	self:playNormalCarryGrab(ent)

	if self.isMainPlayer then
		self:startCarryItemShowOffTimer()
		facade:SendMessageCommand(MessageName.PLAYER_START_CARRY, {})
	end
end

function ClientPlayerCarryComponent:dropEntImp()
	self:clearCarryItemShowOffTimer()
	self:stopCarryItemShowOff(false)

	if self.carryEnt then
		AIUtils.ResumeAI(self.carryEnt, AiConst.PauseBtReason.BeCarry)
		self.eModel:StopSocialGrab(Const.COMPONENT_INDEX_IK, self.carryEnt.eModel)
	else
		self.eModel:StopSocialGrab(Const.COMPONENT_INDEX_IK)
	end

	self.carryEnt = nil

	if self.isMainPlayer then
		facade:SendMessageCommand(MessageName.PLAYER_STOP_CARRY, {})
	end
end

function ClientPlayerCarryComponent:tryPutInItem()
	self:requestCarryOp(OpDef.OP.CS_PC_ItemPutBack, {})
end

function ClientPlayerCarryComponent:releaseCarryIfGenID(genID)
	if self.carryEnt and self.carryEnt.item and self.carryEnt.item.genID == genID then
		self:tryPutInItem()
	end
end

function ClientPlayerCarryComponent:checkInCarry()
	return not string.isNilOrEmpty(self.carryObjId)
end

function ClientPlayerCarryComponent:putDownCarryEnt()
	self:requestCarryOp(OpDef.OP.CS_PC_PetPutDown, {
		petId = self.carryEnt.id
	})
end

function ClientPlayerCarryComponent:putBackPet()
	self:requestCarryOp(OpDef.OP.CS_PC_PetPutBack, {})
end

function ClientPlayerCarryComponent:tryAssignPet(ornamentId, opId)
	self:requestCarryOp(OpDef.OP.CS_PC_PetAssign, {
		ornamentId = ornamentId,
		opId = opId
	})
end

function ClientPlayerCarryComponent:getItemEntity()
	if self.carryEnt then
		return self.carryEnt.eModel
	end
end

return ClientPlayerCarryComponent
