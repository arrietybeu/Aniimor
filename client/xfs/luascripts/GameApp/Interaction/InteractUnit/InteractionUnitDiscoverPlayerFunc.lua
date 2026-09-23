-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Interaction\\InteractUnit\\InteractionUnitDiscoverPlayerFunc.lua

local Class = require("Core.Framework.Class")
local InteractionUnitBase = require("GameApp.Interaction.InteractionUnitBase")
local ConflictTypes = require("Common.ConflictTypes")
local Vector3 = Vector3
local InteractionUnitDiscoverPlayerFunc = Class.LightClass("InteractionUnitDiscoverPlayerFunc", InteractionUnitBase)

function InteractionUnitDiscoverPlayerFunc:ctor(info, interactId)
	InteractionUnitDiscoverPlayerFunc.super.ctor(self, info, interactId)

	self.interactFunc = info.interactFunc
	self.canInteractiveFunc = info.canInteractiveFunc
	self.needCheckDis = info.needCheckDis
	self.targetName = info.name or ""
	self.handlePetEthnicGroup = info.handlePetEthnicGroup
	self.checkEntity = info.checkEntity
end

function InteractionUnitDiscoverPlayerFunc:canInteractive()
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

	if not ent or not ent:NEAR_DEAD_ST() then
		return false
	end

	if not pg.me:checkStatus(ConflictTypes.CT_FIRST_AID, true, nil, true) then
		return false
	end

	if self.canInteractiveFunc then
		return self.canInteractiveFunc(self)
	end

	if self.checkEntity then
		return InteractionUnitDiscoverPlayerFunc.super.canInteractive(self)
	end

	return true
end

function InteractionUnitDiscoverPlayerFunc:interactive()
	pg.me:checkStatus_cancel(ConflictTypes.CT_FIRST_AID)

	if self.interactFunc then
		self.interactFunc(self)
	end
end

function InteractionUnitDiscoverPlayerFunc:getActionName()
	local interactData = self.interactData

	if interactData.actionName then
		return pg.getLocalizationText(interactData.actionName)
	end

	return ""
end

function InteractionUnitDiscoverPlayerFunc:getText()
	return self:getActionName()
end

return InteractionUnitDiscoverPlayerFunc
