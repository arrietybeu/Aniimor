-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientAttachComponent.lua

local CommonConst = require("Common.Const.Const")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local castItemData = require("Data.cast_item_data")
local ClientConst = require("Const.ClientConst")
local itemAttachData = require("Data.item_attach_data")
local Utils = require("Common.Utils.Utils")
local ClientAttachComponent = Class.Component("ClientAttachComponent")

function ClientAttachComponent:start()
	return
end

function ClientAttachComponent:EVENT_AddEComponent()
	self:addEModelComponent(CommonConst.COMPONENT_ATTACH)

	self.attachTargetEntId = nil

	if self.attachToStaticId and self.attachToStaticId > 0 then
		self:attachTo(self.attachToStaticId, self.attachId)
	elseif self.attachTargetId and self.attachTargetId ~= "" then
		self:attach(self.attachTargetId, self.attachId)
	end
end

function ClientAttachComponent:attachCastItem(throwerId, castId)
	local ballData = castItemData[castId]

	self:attachByTable({
		isPhysics = false,
		staticId = 0,
		offset = ballData.offset,
		rotate = ballData.rotationOffset,
		entId = throwerId,
		targetHP = ballData.bone,
		selfHP = ballData.bone
	})
end

function ClientAttachComponent:attachTo(staticId, attachId)
	self:setWaitingAttach(true)

	local attachConfig = itemAttachData[attachId]

	if not attachConfig then
		self:detach()
	else
		attachConfig = Utils.deepCopyTable(attachConfig)
		attachConfig.staticId = staticId

		self:attachByTable(attachConfig)
	end
end

function ClientAttachComponent:attach(id, attachId)
	self:setWaitingAttach(true)

	local attachConfig = itemAttachData[attachId]

	if not attachConfig then
		self:detach()
	else
		attachConfig = Utils.deepCopyTable(attachConfig)
		attachConfig.entId = id

		self:attachByTable(attachConfig)

		self.attachTargetEntId = id
	end
end

function ClientAttachComponent:attachByTable(attachConfig)
	self.eModel:AttachByTable(CommonConst.COMPONENT_ATTACH, attachConfig)
end

function ClientAttachComponent:onAttachBreak()
	self:postComponentMethod("EVENT_OnAttachBreak")
	self:serverMsg("RPC_CS_OnAttachBreak")
end

function ClientAttachComponent:attaching()
	local attachConfig = itemAttachData[self.attachId]

	if attachConfig and attachConfig.noBreak then
		return false
	end

	return self.eModel.attachAttaching or false
end

function ClientAttachComponent:detach()
	self:setWaitingAttach(false)
	self.eModel:Detach(CommonConst.COMPONENT_ATTACH)

	self.attachTargetEntId = nil
end

function ClientAttachComponent:setWaitingAttach(waiting)
	if self.setIsKinematic then
		self:setIsKinematic(waiting, ClientConst.IsKinematicKey.WaitingAttach)
	end

	self:setVisible(ClientConst.MODEL_VISIBLE_KEY.WAITING_ATTACH, nil, not waiting)
end

function ClientAttachComponent:onAttach(isPhysics)
	self:setWaitingAttach(false)

	if self.setIsKinematic then
		self:setIsKinematic(not isPhysics, ClientConst.IsKinematicKey.Attach)
	end
end

function ClientAttachComponent:onDetach()
	if self.setIsKinematic then
		self:setIsKinematic(false, ClientConst.IsKinematicKey.Attach)
	end
end

function ClientAttachComponent:on_attachToStaticId_changed(oldv, newv)
	if newv ~= 0 then
		self:attachTo(self.attachToStaticId, self.attachId)
	else
		self:detach()
	end
end

function ClientAttachComponent:on_attachTargetId_changed(oldv, newv)
	if self.attachTargetId and self.attachTargetId ~= "" then
		self:attach(self.attachTargetId, self.attachId)
	else
		self:detach()
	end

	if self.onAttachTargetIdChanged then
		self:onAttachTargetIdChanged(oldv, newv)
	end
end

function ClientAttachComponent:RPC_SC_AttachByConfigId(attachToActorId, attachConfigId)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_AttachByConfigId", attachToActorId, attachConfigId)
	end

	local attachToTargetEntity = pg.getEntityByActorId(attachToActorId)

	if not attachToTargetEntity then
		return
	end

	attachToTargetEntity.carryId = self.id

	self:attach(attachToTargetEntity.id, attachConfigId)
	self:beAttached()
end

function ClientAttachComponent:RPC_SC_Detach()
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		self.logger:debug("RPC_SC_Detach")
	end

	local attachToEnt = pg.getEntity(self.attachTargetEntId)

	if attachToEnt then
		if attachToEnt.eModel then
			attachToEnt.eModel.carrayItemInt = 0
		end

		attachToEnt.carryId = nil
	end

	self:detach()
	self:beDetached()
end

return ClientAttachComponent
