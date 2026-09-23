-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Components\\PerceptibilityResponseComponent.lua

local Class = require("Core.Framework.Class")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local voxelUtils = require("Common.Utils.VoxelUtils")
local VoxelConst = require("Common.Const.VoxelConst")
local VectorPool = require("Common.Container.VectorPool")
local TablePool = require("Common.Container.TablePool")
local petData = require("Data.pet_data")
local Utils = require("Common.Utils.Utils")
local PerceptibilityResponseComponent = Class.Component("PerceptibilityResponseComponent")

function PerceptibilityResponseComponent:init()
	self.isPerceptibilityResponse = true
	self.isNoImpPerceptibilityResponse = true
	self.perceivedPosition = TablePool.getTable()

	return true
end

function PerceptibilityResponseComponent:destroy()
	if self.perceivedPosition then
		for _, pos in pairs(self.perceivedPosition) do
			VectorPool.returnVector(pos)
		end

		TablePool.returnTable(self.perceivedPosition)

		self.perceivedPosition = nil
	end
end

function PerceptibilityResponseComponent:onRemoveResponsePerceptibility(perceivedEntityActorId)
	if not self.perceivedPosition then
		return
	end

	local removePos = self.perceivedPosition[perceivedEntityActorId]

	if removePos then
		VectorPool.returnVector(removePos)

		self.perceivedPosition[perceivedEntityActorId] = nil
	end
end

function PerceptibilityResponseComponent:getPerceivedPosition(perceivedEntityActorId)
	if self.perceivedPosition[perceivedEntityActorId] ~= nil then
		return true, self.perceivedPosition[perceivedEntityActorId]
	else
		return false, self:getPosition()
	end
end

function PerceptibilityResponseComponent:updatePerceivedPosition(perceivedEntityActorId)
	local updatePos = self.perceivedPosition[perceivedEntityActorId]

	if updatePos then
		Vector3.Copy(updatePos, self:getPosition())
	else
		updatePos = VectorPool.getVector(3, self:getPosition())
	end

	self.perceivedPosition[perceivedEntityActorId] = updatePos
end

function PerceptibilityResponseComponent:EVENT_onControlPetSwitchToAnotherPet(oldPetTemplateId, newPetTemplateId)
	if Utils.IsPetSameEthnicGroupByTemplateId(oldPetTemplateId, newPetTemplateId) then
		return
	end

	for tActorId, v in pairs(self.perceivedPosition) do
		local targetEnt = pg.getEntityByActorId(tActorId)

		if targetEnt and targetEnt:getConfigData().petPrototypeId == petData[oldPetTemplateId].petPrototypeId then
			targetEnt:addDeformationTerrorPerceptibility(self.actorId)
		end
	end
end

function PerceptibilityResponseComponent:EVENT_onControlPetSwitchToPlayer(oldPetTemplateId)
	for tActorId, v in pairs(self.perceivedPosition) do
		local targetEnt = pg.getEntityByActorId(tActorId)

		if targetEnt and targetEnt:getConfigData().petPrototypeId == petData[oldPetTemplateId].petPrototypeId then
			targetEnt:addDeformationTerrorPerceptibility(self.actorId)
		end
	end
end

function PerceptibilityResponseComponent:checkPRSneak()
	if CharacterStateConst.isChildOfState(self.characterState, CharacterStateConst.CROUCHING) then
		return true
	end

	return false
end

function PerceptibilityResponseComponent:checkPRRun()
	if self.characterState == CharacterStateConst.RUN then
		return true
	end

	return false
end

function PerceptibilityResponseComponent:checkPRSprint()
	if self.characterState == CharacterStateConst.SPRINT or self.characterState == CharacterStateConst.SPRINTTURN or self.characterState == CharacterStateConst.DASH then
		return true
	end

	return false
end

function PerceptibilityResponseComponent:checkPRIdle()
	if self.characterState == CharacterStateConst.IDLE then
		return true
	end

	return false
end

function PerceptibilityResponseComponent:checkPREnvironment()
	local pos = self:getPosition()
	local material, state = voxelUtils.scanVoxelDataByPos(self.space.id, pos.x, pos.y, pos.z, 0.4)

	if bit.band(material, VoxelConst.VoxelMaterialDef.CustomGrass) ~= 0 then
		return VoxelConst.Perceptions.GRASS
	end

	if bit.band(material, VoxelConst.VoxelMaterialDef.Water) ~= 0 or bit.band(material, VoxelConst.VoxelMaterialDef.WaterBottom) ~= 0 or bit.band(state, VoxelConst.VoxelStateDef.WaterPool) ~= 0 then
		return VoxelConst.Perceptions.WATER
	end

	return VoxelConst.Perceptions.NONE
end

return PerceptibilityResponseComponent
