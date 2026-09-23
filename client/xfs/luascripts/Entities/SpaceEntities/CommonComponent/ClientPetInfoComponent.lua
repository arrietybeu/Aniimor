-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientPetInfoComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local logger = LoggerManager.getLogger("ClientPetInfoComponent")
local ClientModelUtils = require("Utils.ClientModelUtils")
local Utils = require("Common.Utils.Utils")
local PetIndividuationData = require("Data.pet_individuation_data")
local ClientPetInfoComponent = Class.Component("ClientPetInfoComponent")

function ClientPetInfoComponent:start()
	self.petPrototypeId = self:getConfigData().petPrototypeId
	self.basePetPrototypeId = Utils.getBasePetPrototypeId(self.petPrototypeId)
end

function ClientPetInfoComponent:on_individuationIds_changed(oldIndividuationId, newIndividuationId, typeId)
	ClientModelUtils.applyIndividuationTrans(self, oldIndividuationId, newIndividuationId)
end

function ClientPetInfoComponent:on_individuationIds_add(typeId, individuationId)
	local newData = PetIndividuationData[individuationId] or {}

	if newData.animState then
		local animName = "Appearance_" .. newData.animState

		self:playAnimation(animName)
	end
end

function ClientPetInfoComponent:on_individuationIds_delete(typeId, individuationId)
	return
end

function ClientPetInfoComponent:on_selectTransmogScheme_changed(ov, nv)
	if self.applyTransmogScheme and self.setTransmogData then
		self:applyTransmogScheme(nv)
	end
end

return ClientPetInfoComponent
