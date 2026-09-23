-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\Home\\ClientHomeEditorTopLogoComponent.lua

local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local HomeFacilityData = require("Data.homeland_facility_data")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local TopLogoHomeEditor = require("Guis.Panels.TopLogo.Node.TopLogoHomeEditor")
local HomelandFormulaData = require("Data.homeland_formula_data")
local PetData = require("Data.pet_data")
local AddressDataConst = require("Const.AddressDataConst")
local ClientHomeEditorTopLogoComponent = Class.Component("ClientHomeEditorTopLogoComponent")

function ClientHomeEditorTopLogoComponent:ctor()
	self.relatedEditorFacilityInfo = {}
	self.relatedEditorPetInfo = {}
	self.inRangeRelatedEntities = {}
end

function ClientHomeEditorTopLogoComponent:start()
	self:initHomeEditorTopLogoConfig()
end

function ClientHomeEditorTopLogoComponent:preDestroy()
	self:destroyHomeEditorTopLogoItem()
end

function ClientHomeEditorTopLogoComponent:initHomeEditorTopLogoConfig()
	local configData = self:getHomelandConfigData()

	if configData.facilityId then
		local homeFacilityData = HomeFacilityData[configData.facilityId] or {}

		if homeFacilityData then
			self.enableHomeEditorTopLogo = true
		end
	end

	self:createHomeEditorTopLogoItem()
end

function ClientHomeEditorTopLogoComponent:createHomeEditorTopLogoItem()
	if not self:checkUseHomeEditorTopLogo() then
		return
	end

	if not pg.global.ui.homelandEditorTopLogo:checkUIOpen() then
		return
	end

	if not self.homeEditorTopLogoItem then
		self.homeEditorTopLogoItem = pg.global.ui.homelandEditorTopLogo:createTopLogoItem(self.ornamentId, self)
	end
end

function ClientHomeEditorTopLogoComponent:destroyHomeEditorTopLogoItem()
	if self.homeEditorTopLogoItem then
		pg.global.ui.homelandEditorTopLogo:destroyTopLogoItem(self.ornamentId)

		self.homeEditorTopLogoItem = nil
	end

	self.editorTopLogoAlive = false

	self:updateEnvCoverEffect()
end

function ClientHomeEditorTopLogoComponent:checkHomeEditorTopLogoAlive(cameraPosition, range)
	if not self.visible then
		return false
	end

	local spx, _, spz = self.eModel:GetPositionAgentPosEx()
	local xDiff = math.abs(cameraPosition.x - spx)
	local zDiff = math.abs(cameraPosition.z - spz)
	local rangeValid

	if self.editorTopLogoAlive then
		rangeValid = xDiff < range + 5 and zDiff < range + 5
	else
		rangeValid = xDiff < range and zDiff < range
	end

	if not rangeValid then
		return false
	end

	return true
end

function ClientHomeEditorTopLogoComponent:updateHomeEditorTopLogo(cameraPosition, range)
	if not self.homeEditorTopLogoItem then
		return
	end

	local isInEditMode = pg.game.home.editor.isInEditMode
	local editorTopLogoAlive = self:checkHomeEditorTopLogoAlive(cameraPosition, range)

	if editorTopLogoAlive and isInEditMode then
		self:refreshRelatedEditorInfo()

		editorTopLogoAlive = self:checkRelatedToEditEntity()
	else
		self:clearRelatedEditorInfo()
	end

	if self.editorTopLogoAlive ~= editorTopLogoAlive then
		self.editorTopLogoAlive = editorTopLogoAlive

		if self.editorTopLogoAlive then
			self.homeEditorTopLogoItem:createTopLogo()
		else
			self.homeEditorTopLogoItem:destroyTopLogo()
		end
	end

	if editorTopLogoAlive then
		self:updateHomeEditorEnvState()
	end

	self:updateEnvCoverEffect()
end

function ClientHomeEditorTopLogoComponent:forceRefreshHomeEditorTopLogo()
	if not self.homeEditorTopLogoItem then
		return
	end

	self.homeEditorTopLogoItem:markDirty()
end

function ClientHomeEditorTopLogoComponent:refreshRelatedEditorInfo()
	table.clear(self.relatedEditorFacilityInfo)
	table.clear(self.relatedEditorPetInfo)

	if self.templateEntityType then
		return
	end

	local editEntity = pg.game.home.editor.templateEntity

	if editEntity.templateEntityType == Const.HomelandEntType.Ornament then
		if self.homeFacilityType and editEntity.getEditorEnvRelatedInfo then
			editEntity:getEditorEnvRelatedInfo(self, self.relatedEditorFacilityInfo)
		end
	elseif editEntity.templateEntityType == Const.HomelandEntType.Pet then
		local petInfo = pg.me:getPetInfo(editEntity.templateData.petId)

		if not petInfo then
			return
		end

		local petTemplateId = petInfo.templateId
		local petOperValid = false

		if self.facilityInfo and self.facilityInfo.facilityStateInfo.ptype ~= Const.HOMELAND_PRODUCE_TYPE.TIME then
			local requireOperId = self.facilityInfo.facilityState

			petOperValid = Utils.checkHomePetCanDoOperId(petTemplateId, requireOperId)
			self.relatedEditorPetInfo[requireOperId] = petOperValid
		end
	end
end

function ClientHomeEditorTopLogoComponent:clearRelatedEditorInfo()
	table.clear(self.relatedEditorFacilityInfo)
	table.clear(self.relatedEditorPetInfo)
	table.clear(self.inRangeRelatedEntities)

	self.inEditEntityEffectRange = false
end

function ClientHomeEditorTopLogoComponent:checkRelatedToEditEntity()
	if self.templateEntityType == Const.HomelandEntType.Ornament then
		return true
	end

	return not Utils.tableIsEmptyOrNil(self.relatedEditorFacilityInfo) or not Utils.tableIsEmptyOrNil(self.relatedEditorPetInfo)
end

function ClientHomeEditorTopLogoComponent:updateHomeEditorEnvState()
	if self.templateEntityType == Const.HomelandEntType.Pet then
		return
	end

	local electricLink = false
	local temperature = 0
	local light = 0

	self.inEditEntityEffectRange = false

	table.clear(self.inRangeRelatedEntities)

	local isInEditMode = pg.game.home.editor.isInEditMode
	local envRoot = pg.space

	if isInEditMode then
		envRoot = pg.game.home.editor.envEditor
	end

	if self.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.ElectricLink then
		local linkInfo = envRoot.homeLinkMap[self.ornamentId]

		if linkInfo then
			for ornamentId, _ in pairs(self.relatedEditorFacilityInfo) do
				if linkInfo.linkIds[ornamentId] then
					self.inEditEntityEffectRange = true
					self.inRangeRelatedEntities[ornamentId] = true
				end
			end

			if linkInfo.groupId and linkInfo.groupId ~= 0 then
				electricLink = true
			end
		end
	elseif self.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.ElectricReq then
		local ornamentEnvInfo = envRoot.ornamentEnvMap[self.ornamentId]

		if ornamentEnvInfo then
			local refEnvFacilityInfo = ornamentEnvInfo.refEnvFacilityInfo

			for refEnvOrnamentId, _ in pairs(refEnvFacilityInfo) do
				if self.relatedEditorFacilityInfo[refEnvOrnamentId] then
					self.inEditEntityEffectRange = true
					self.inRangeRelatedEntities[refEnvOrnamentId] = true
				end

				local linkInfo = envRoot.homeLinkMap[refEnvOrnamentId]

				if linkInfo and linkInfo.groupId ~= 0 then
					electricLink = true
				end
			end
		end
	elseif self.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.ElectricReqSwitch then
		local ornamentEnvInfo = envRoot.ornamentEnvMap[self.ornamentId]

		if ornamentEnvInfo then
			local refEnvFacilityInfo = ornamentEnvInfo.refEnvFacilityInfo

			for refEnvOrnamentId, _ in pairs(refEnvFacilityInfo) do
				if self.relatedEditorFacilityInfo[refEnvOrnamentId] then
					self.inEditEntityEffectRange = true
					self.inRangeRelatedEntities[refEnvOrnamentId] = true
				end

				local linkInfo = envRoot.homeLinkMap[refEnvOrnamentId]

				if linkInfo and linkInfo.groupId ~= 0 then
					electricLink = true
				end
			end
		end
	elseif self.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.EnvRequire then
		local ornamentEnvInfo = envRoot.ornamentEnvMap[self.ornamentId]

		if ornamentEnvInfo then
			local refEnvFacilityInfo = ornamentEnvInfo.refEnvFacilityInfo

			for refEnvOrnamentId, _ in pairs(refEnvFacilityInfo) do
				if self.relatedEditorFacilityInfo[refEnvOrnamentId] then
					self.inEditEntityEffectRange = true
					self.inRangeRelatedEntities[refEnvOrnamentId] = true
				end

				local ent = pg.game.home:getHomeEntity(refEnvOrnamentId)
				local otherEditorFacilityInfo = ent:getEditorFacilityInfo()

				if otherEditorFacilityInfo and otherEditorFacilityInfo.envParam then
					if ent.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.Light then
						light = light + otherEditorFacilityInfo.envParam
					elseif ent.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.LowTemperate then
						temperature = temperature - otherEditorFacilityInfo.envParam
					elseif ent.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.HighTemperate then
						temperature = temperature + otherEditorFacilityInfo.envParam
					end
				end
			end
		end
	end

	local editorFacilityInfo = self:getEditorFacilityInfo()
	local ornamentInfo = self:getEditorOrnamentInfo()

	self.editorHasEntDoOper, self.editorOperFit = self:editorCheckHasEntDoingOper(editorFacilityInfo.opId)
	self.editorElectricLink = electricLink
	self.editorTemperature = temperature
	self.editorFormulaId = editorFacilityInfo.formulaId
	self.editorOpId = editorFacilityInfo.opId
	self.editorLight = light

	self.homeEditorTopLogoItem:setTopLogoBaseInfo(self.homeTemplateId, self.editorFormulaId, self.editorOpId, ornamentInfo)
	self.homeEditorTopLogoItem:setEnvSimulateInfo(electricLink, temperature, light, self.editorHasEntDoOper, self.editorOperFit)
	self.homeEditorTopLogoItem:refreshInfoIfDirty()
end

function ClientHomeEditorTopLogoComponent:getEditorOrnamentInfo()
	if self.virtualOrnamentInfo then
		return self.virtualOrnamentInfo
	end

	return pg.space.ornament[self.ornamentId]
end

function ClientHomeEditorTopLogoComponent:editorCheckHasEntDoingOper(operId)
	if not operId or operId == 0 then
		return false, false
	end

	local ornamentId = self.ornamentId

	if self.originEntity then
		ornamentId = self.originEntity.ornamentId
	end

	local _, requireHomeAbility, requireLevel = Utils.getOperationRequireOpType(operId)

	if ornamentId > 0 then
		local relatedPets = pg.me.space.facilityAllocationInfo[ornamentId]
		local hasDoOper = false
		local operFit = false

		if relatedPets then
			for _, petId in ipairs(relatedPets) do
				local allocation = pg.me.space.allocation[petId]
				local petInfo = pg.me.space.pets[petId]

				if allocation and allocation.opId == operId then
					hasDoOper = true

					if not requireHomeAbility then
						return true, true
					end

					local pdd = PetData[petInfo.templateId] or {}

					if requireLevel <= pdd.homeAbility[requireHomeAbility] then
						operFit = true
					end

					if hasDoOper and operFit then
						return true, true
					end
				end
			end
		end

		if pg.game.home.editor.entityType == Const.HomelandEntType.Pet then
			local templateEntity = pg.game.home.editor.templateEntity

			if templateEntity.petOperValid and templateEntity.petRelateOrnamentId == ornamentId and templateEntity.petRelateOperationId == operId then
				hasDoOper = true

				if not requireHomeAbility then
					return true, true
				end

				local petInfo = pg.me:getPetInfo(templateEntity.templateData.petId)
				local pdd = PetData[petInfo.templateId] or {}

				if requireLevel <= pdd.homeAbility[requireHomeAbility] then
					operFit = true
				end
			end
		end

		return hasDoOper, operFit
	end

	return false, false
end

function ClientHomeEditorTopLogoComponent:showEditorFitRecommendEffect()
	if self:checkShowEditorFitRecommendEffect() then
		self:playEffect("Eff_Env_Home_ExpItemMaker_Success")
	end
end

function ClientHomeEditorTopLogoComponent:checkShowEditorFitRecommendEffect()
	if self.editorTopLogoAlive and self.inEditEntityEffectRange and not Utils.tableIsEmptyOrNil(self.relatedEditorFacilityInfo) then
		if self.editorElectricLink then
			return true
		end

		if self.editorFormulaId then
			local formulaData = HomelandFormulaData[self.editorFormulaId]
			local temperatureFit = false
			local lightFitFit = false

			if formulaData.temperatureRequire == self.editorTemperature then
				temperatureFit = true
			end

			if formulaData.lightRequire == self.editorLight then
				lightFitFit = true
			end

			return temperatureFit and lightFitFit
		end
	end

	return false
end

function ClientHomeEditorTopLogoComponent:updateEnvCoverEffect()
	if self.homeEditState == ClientConst.HomeEntEffectType.Edit then
		return
	end

	local outLineMaterialName, chargePresetName

	if self.editorTopLogoAlive and self.inEditEntityEffectRange then
		for ornamentId, _ in pairs(self.inRangeRelatedEntities) do
			local relatedEditorEnt = self.relatedEditorFacilityInfo[ornamentId]

			if relatedEditorEnt then
				if relatedEditorEnt.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.ElectricLink or relatedEditorEnt.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.Electric then
					if self.editorElectricLink then
						outLineMaterialName = AddressDataConst.HOMELAND_OUTLINE_ELECTRIC
						chargePresetName = "Home_Generator_Charge"

						break
					end
				elseif relatedEditorEnt.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.HighTemperate then
					outLineMaterialName = AddressDataConst.HOMELAND_OUTLINE_FIRE
					chargePresetName = "Home_Generator_Charge"
				elseif relatedEditorEnt.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.LowTemperate then
					outLineMaterialName = AddressDataConst.HOMELAND_OUTLINE_ICE
					chargePresetName = "Home_Generator_Charge"
				elseif relatedEditorEnt.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.Light then
					outLineMaterialName = AddressDataConst.HOMELAND_OUTLINE_LIGHT
					chargePresetName = "Home_Generator_Charge"
				end
			end
		end
	end

	if chargePresetName then
		self:setEnvCoverEffectEnable(true, chargePresetName)
	else
		self:setEnvCoverEffectEnable(false)
	end

	if outLineMaterialName then
		self:setHomeEditorExtraOutline(true, outLineMaterialName)
	else
		self:setHomeEditorExtraOutline(false)
	end
end

function ClientHomeEditorTopLogoComponent:checkUseHomeEditorTopLogo()
	return self.enableHomeEditorTopLogo
end

return ClientHomeEditorTopLogoComponent
