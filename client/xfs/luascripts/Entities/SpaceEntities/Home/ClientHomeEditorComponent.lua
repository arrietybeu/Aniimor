-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\Home\\ClientHomeEditorComponent.lua

local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local HomeFacilityData = require("Data.homeland_facility_data")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local HomelandFormulaData = require("Data.homeland_formula_data")
local AddressDataConst = require("Const.AddressDataConst")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local HomeEditorOutline = require("GameApp.Home.HomeEditorOutline")
local ClientHomeEditorComponent = Class.Component("ClientHomeEditorComponent")

function ClientHomeEditorComponent:start()
	self:initHomeEditorEffect()

	self.editorFacilityInfo = {}
end

function ClientHomeEditorComponent:destroy()
	return
end

function ClientHomeEditorComponent:getBasePositionY()
	if not self.areaId then
		return 0
	end

	local basePos = pg.game.home:getAreaBasePosition(self.areaId)

	if basePos then
		return basePos.y
	end

	return 0
end

function ClientHomeEditorComponent:setHomeOutEffectInfo(outGridMode, outBoundX, outBoundZ)
	self.editorOutGridMode = outGridMode

	if outGridMode and outGridMode ~= 0 then
		self.editorOutGridBounds = {
			outBoundX,
			outBoundZ
		}

		self:playEditorBoundEffect(ClientConst.EntityEditorBoundType.Outline, outGridMode, self.editorOutGridBounds, ClientConst.HomelandEffectBaseOffset - 0.01, self:getBasePositionY())
	else
		self:stopEditorBoundEffect(ClientConst.EntityEditorBoundType.Outline)
	end
end

function ClientHomeEditorComponent:getBasePlaceYaw()
	return 0
end

function ClientHomeEditorComponent:initHomeEditorEffect()
	if not self.ornamentId then
		return
	end

	if self.isPreview then
		self:playEditorBoundEffect(ClientConst.EntityEditorBoundType.Preview, 8, self:getBaseBoundSize(), ClientConst.HomelandEffectBaseOffset, self:getBasePositionY())

		return
	end

	self.homeFacilityType = nil

	if self.templateEntityType == Const.HomelandEntType.Pet then
		-- block empty
	else
		local configData = self:getHomelandConfigData()

		if configData.facilityId then
			local homeFacilityData = HomeFacilityData[configData.facilityId] or {}

			self.homeFacilityType = homeFacilityData.facilityType

			if homeFacilityData.envBounds then
				local outGridMode = 0

				if self.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.Electric or self.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.ElectricLink then
					outGridMode = 2
				elseif self.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.Light then
					outGridMode = 5
				elseif self.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.HighTemperate then
					outGridMode = 6
				elseif self.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.LowTemperate then
					outGridMode = 7
				end

				self:setEditorBoundEffectVisible(ClientConst.EntityEditorBoundType.Outline, ClientConst.EditorEffectVisibleReason.Default, false)
				self:setHomeOutEffectInfo(outGridMode, homeFacilityData.envBounds[1], homeFacilityData.envBounds[2])
			end
		end
	end

	self:updateEditorEffect()
end

function ClientHomeEditorComponent:onEditorEnvLinkChange()
	return
end

function ClientHomeEditorComponent:getEditorFacilityInfo()
	if self.templateEntityType == Const.HomelandEntType.Pet then
		return
	end

	if self.originEntity and self.originEntity.facilityInfo then
		local facilityInfo = self.originEntity.facilityInfo

		self.editorFacilityInfo.formulaId = facilityInfo.formulaId
		self.editorFacilityInfo.opId = facilityInfo.facilityState
		self.editorFacilityInfo.envParam = facilityInfo.envParam
	elseif self.facilityInfo then
		local facilityInfo = self.facilityInfo

		self.editorFacilityInfo.formulaId = facilityInfo.formulaId
		self.editorFacilityInfo.opId = facilityInfo.facilityState
		self.editorFacilityInfo.envParam = facilityInfo.envParam
	else
		local defaultFormulaId, defaultOpId = self:getDefaultEnvFormulaIdAndOpId()

		self.editorFacilityInfo.formulaId = defaultFormulaId
		self.editorFacilityInfo.opId = defaultOpId
		self.editorFacilityInfo.envParam = 1
	end

	return self.editorFacilityInfo
end

function ClientHomeEditorComponent:getDefaultEnvFormulaIdAndOpId()
	local configData = self:getHomelandConfigData()

	if configData.facilityId then
		local homeFacilityData = HomeFacilityData[configData.facilityId] or {}

		if homeFacilityData.envFormulaList then
			local formulaId = homeFacilityData.envFormulaList[1]
			local formulaData = HomelandFormulaData[formulaId] or {}
			local opId = formulaData.postOperateList[1]

			return formulaId, opId
		end
	end
end

function ClientHomeEditorComponent:onHomeEditorFilterChange(filterType)
	if not self.homeFacilityType or not self.editorOutGridMode then
		return
	end

	if not filterType then
		self:updateEditorEffect()

		return
	end

	if filterType == ClientConst.OrnamentFilterType.Electric then
		if self.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.Electric or self.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.ElectricLink then
			self:updateEditorEffect()
		end
	elseif filterType == ClientConst.OrnamentFilterType.Light then
		if self.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.Light then
			self:updateEditorEffect()
		end
	elseif filterType == ClientConst.OrnamentFilterType.Heat then
		if self.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.HighTemperate then
			self:updateEditorEffect()
		end
	elseif filterType == ClientConst.OrnamentFilterType.Cool and self.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.LowTemperate then
		self:updateEditorEffect()
	end
end

function ClientHomeEditorComponent:checkHomeEditorShowFilter()
	if self.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.Electric or self.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.ElectricLink then
		return not pg.game.home:getHomeEditorOrnamentFilter(ClientConst.OrnamentFilterType.Electric)
	end

	if self.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.Light then
		return not pg.game.home:getHomeEditorOrnamentFilter(ClientConst.OrnamentFilterType.Light)
	end

	if self.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.HighTemperate then
		return not pg.game.home:getHomeEditorOrnamentFilter(ClientConst.OrnamentFilterType.Heat)
	end

	if self.homeFacilityType == Const.HOMELAND_FACILITY_TYPE.LowTemperate then
		return not pg.game.home:getHomeEditorOrnamentFilter(ClientConst.OrnamentFilterType.Cool)
	end
end

function ClientHomeEditorComponent:refreshHomeInteractEffect()
	if self.isInHomeInteract then
		self:playEditorBoundEffect(ClientConst.EntityEditorBoundType.Interact, 1, self:getBaseBoundSize(), ClientConst.HomelandEffectBaseOffset, self:getBasePositionY())
	else
		self:stopEditorBoundEffect(ClientConst.EntityEditorBoundType.Interact)
	end
end

function ClientHomeEditorComponent:updateEditorEffect()
	if not self.ornamentId then
		return
	end

	if pg.game.home.editor.isInBuildMode then
		self:setEditorBoundEffectVisible(ClientConst.EntityEditorBoundType.Interact, ClientConst.EditorEffectVisibleReason.Default, false)
	else
		self:setEditorBoundEffectVisible(ClientConst.EntityEditorBoundType.Interact, ClientConst.EditorEffectVisibleReason.Default, true)
	end

	if pg.game.home.editor.isInEditMode and self:checkHomeEditorShowFilter() then
		self:setEditorBoundEffectVisible(ClientConst.EntityEditorBoundType.Outline, ClientConst.EditorEffectVisibleReason.Default, true)
	else
		self:setEditorBoundEffectVisible(ClientConst.EntityEditorBoundType.Outline, ClientConst.EditorEffectVisibleReason.Default, false)
	end

	if pg.game.home.editor.isInEditMode then
		self:setEditorBoundEffectVisible(ClientConst.EntityEditorBoundType.Default, ClientConst.EditorEffectVisibleReason.Default, true)
	else
		self:setEditorBoundEffectVisible(ClientConst.EntityEditorBoundType.Default, ClientConst.EditorEffectVisibleReason.Default, false)
	end
end

function ClientHomeEditorComponent:getOrnamentLayer()
	if self.templateEntityType == Const.HomelandEntType.Pet then
		return Const.HOMELAND_ORNAMENT_LAYER.Default
	end

	local configData = self:getHomelandConfigData()

	if configData.canEditYAxis or configData.overlapAllowed then
		return Const.HOMELAND_ORNAMENT_LAYER.None
	end

	return Const.HOMELAND_ORNAMENT_LAYER.Default
end

function ClientHomeEditorComponent:getValidHomePetPosition()
	local tempCollideOrnaments
	local position = self:getPosition()

	return position
end

function ClientHomeEditorComponent:setHomeEditState(homeEditState)
	self.homeEditState = homeEditState

	self:updateEditorEffect()
end

function ClientHomeEditorComponent:setInHomeInteract(isInInteract)
	if self.isInHomeInteract ~= isInInteract then
		self.isInHomeInteract = isInInteract

		self:refreshHomeInteractEffect()
	end
end

function ClientHomeEditorComponent:setHomeEditorExtraOutline(enable, materialId)
	if self.templateEntityType == Const.HomelandEntType.Pet then
		return
	end

	if HomeEditorOutline.checkMobileMode() then
		return
	end

	self:setEditorOutline(ClientConst.EntityEditorOutlinePriority.Env, enable, materialId)
end

return ClientHomeEditorComponent
