-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientLiftComponent.lua

local Class = require("Core.Framework.Class")
local MessageName = require("Const.MessageName")
local InteractionConst = require("Common.Const.InteractionConst")
local InputCommand = require("GameApp.Input.InputCommand")
local ConflictTypes = require("Common.ConflictTypes")
local AbilityConst = require("Common.Const.AbilityConst")
local Time = require("Core.Common.Time")
local itemAttachData = require("Data.item_attach_data")
local AutoPathFindUtils = require("Common.Utils.AutoPathFindUtils")
local Const = require("Common.Const.Const")
local PlayableEventConst = require("Const.PlayableEventConst")
local ClientLiftComponent = Class.Component("ClientLiftComponent")

function ClientLiftComponent:start()
	self:refreshEntityAttach(nil, self.lifterId)
	self:refreshDropInteractState()
end

function ClientLiftComponent:EVENT_AddEComponent()
	self:addEModelComponent(Const.COMPONENT_ATTACH)
end

function ClientLiftComponent:getLiftEntity()
	if string.isNilOrEmpty(self.liftEntId) then
		return nil
	end

	local liftEntity = pg.getEntity(self.liftEntId)

	return liftEntity
end

function ClientLiftComponent:getLifterEntity()
	if string.isNilOrEmpty(self.lifterId) then
		return nil
	end

	local liftEntity = pg.getEntity(self.lifterId)

	return liftEntity
end

function ClientLiftComponent:getAttachData()
	return itemAttachData[self.liftAttachId or 0] or {}
end

function ClientLiftComponent:RPC_SC_OnStartLift(liftAttachId, targetEntId, reason)
	self:ResetVelocity()

	local targetEntity = pg.getEntity(targetEntId)

	if targetEntity then
		targetEntity:attach(self.id, liftAttachId)
		self:faceToEnt(targetEntity)
	end

	self.startLiftTime = Time.realSecondCache
end

function ClientLiftComponent:onLifterIdChange(old, new)
	self:refreshEntityAttach(old, new)
	self:postComponentMethod("EVENT_OnLifterIdChanged")
end

function ClientLiftComponent:onLiftEntIdChange(old, new)
	self.startUnliftTime = nil

	self:refreshDropInteractState()

	if self:isInLiftState() then
		if self.isMainPlayer and pg.me:isControllingPet() then
			self:unLiftEntity(true)
		elseif self.isMainPet and not pg.me:isControllingPet() then
			self:unLiftEntity(true)
		end
	end
end

function ClientLiftComponent:EVENT_LoseControlled()
	self:unLiftEntity(true)
end

function ClientLiftComponent:isInLiftState()
	return not string.isNilOrEmpty(self.liftEntId)
end

function ClientLiftComponent:refreshEntityAttach(old, new)
	if (old or "") == (new or "") then
		return
	end

	self:attach(new, self.liftAttachId)
end

function ClientLiftComponent:EVENT_OnAttachBreak()
	local ent = self:getLifterEntity()

	if ent then
		ent:unLiftEntity(true)
	end
end

function ClientLiftComponent:callLiftEntity(ent, attachId)
	if self:checkStatus(ConflictTypes.CT_LIFT, true) then
		self:faceToEnt(ent)
		self:serverMsg("RPC_CS_LiftEntity", ent.id, attachId)
	end
end

function ClientLiftComponent:canLift()
	return self:checkStatus(ConflictTypes.CT_LIFT, false, nil, true)
end

function ClientLiftComponent:canBeLift()
	if not string.isNilOrEmpty(self.lifterId) then
		return false
	end

	if self.startUnliftTime and Time.realSecondCache - self.startUnliftTime < 0.5 then
		return false
	end

	if self.features and self.LevelFruitFeature and not self.LevelFruitFeature:canBeLift() then
		return false
	end

	return true
end

function ClientLiftComponent:canUnLift()
	if string.isNilOrEmpty(self.liftEntId) then
		return false
	end

	if self.startLiftTime and Time.realSecondCache - self.startLiftTime < 0.5 then
		return false
	end

	return true
end

function ClientLiftComponent:unLiftEntity(isBreak, position, rotation, forceSetPos)
	if string.isNilOrEmpty(self.liftEntId) then
		return
	end

	if self.unliftTimer then
		self:removeTimer(self.unliftTimer)

		self.unliftTimer = nil
	end

	if isBreak then
		self:realUnLiftEntity(position, rotation, true, forceSetPos)
	elseif self.isMainPlayer then
		self:realUnLiftEntity()
	else
		self:realUnLiftEntity(position, rotation)
	end
end

function ClientLiftComponent:realUnLiftEntity(position, rotation, isBreak, forceSetPos)
	local liftEntity = self:getLiftEntity()

	forceSetPos = forceSetPos or false

	if liftEntity then
		local dropPosition = position or liftEntity:getPositionAgentPosition()
		local dropRotation = rotation or liftEntity:getPositionAgentRotation()

		dropPosition = self:findBestPlacePos(liftEntity, dropPosition)

		self:serverMsg("RPC_CS_UnLiftEntity", forceSetPos, dropPosition, dropRotation)
	elseif not string.isNilOrEmpty(self.liftEntId) then
		self:serverMsg("RPC_CS_UnLiftEntity", forceSetPos, position, rotation)
	end
end

function ClientLiftComponent:findBestPlacePos(liftEntity, dropPosition)
	local result, pos = AutoPathFindUtils.findPhysicsDisplacement(liftEntity, self, dropPosition, 0.1)

	return pos
end

function ClientLiftComponent:refreshDropInteractState()
	return
end

return ClientLiftComponent
