-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\Interaction\\InteractUnit\\InteractionUnitOnlyFunc.lua

local Class = require("Core.Framework.Class")
local InteractionUnitBase = require("GameApp.Interaction.InteractionUnitBase")
local Vector3 = Vector3
local InteractionUnitOnlyFunc = Class.LightClass("InteractionUnitOnlyFunc", InteractionUnitBase)

function InteractionUnitOnlyFunc:ctor(info, interactId)
	InteractionUnitOnlyFunc.super.ctor(self, info, interactId)

	self.interactFunc = info.interactFunc
	self.canInteractiveFunc = info.canInteractiveFunc
	self.needCheckDis = info.needCheckDis
	self.handlePetEthnicGroup = info.handlePetEthnicGroup
	self.checkEntity = info.checkEntity
end

function InteractionUnitOnlyFunc:canInteractive()
	if self.checkEntity and not InteractionUnitOnlyFunc.super.canInteractive(self) then
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

	if self.canInteractiveFunc then
		return self.canInteractiveFunc(self)
	end

	return true
end

function InteractionUnitOnlyFunc:interactive()
	if self.interactFunc then
		self.interactFunc(self)
	end
end

return InteractionUnitOnlyFunc
