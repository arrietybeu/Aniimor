-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Map\\Component\\PetDistributionComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local PetData = require("Data.pet_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local MapPetAreaBlockHighlight = require("Guis.Utils.MapPetAreaBlockHighlight")
local PetResearchContentData = require("Data.pet_research_content_data")
local PetDistributionComponent = Class.LightClass("PetDistributionComponent", UIComponent)

PetDistributionComponent.DELAY_LOAD = 0.5

function PetDistributionComponent:findObjects()
	self.ctrl:startTimer(function()
		if pg.game.map.activeDistributionPetTemplateId then
			local distributionShowTab = self.ctrl.distributionShowTab
			local resetDistributionShowTab = self.ctrl.resetDistributionShowTab

			self.ctrl.distributionShowTab = nil
			self.ctrl.resetDistributionShowTab = nil

			self.ctrl:openDistributionMode(distributionShowTab, resetDistributionShowTab)
		end
	end, PetDistributionComponent.DELAY_LOAD)
end

function PetDistributionComponent:openDistributionMode()
	if not self.view.petDistributionUContainer:CheckURLLoaded() then
		self.view.petDistributionUContainer:LoadDefaultUrlManually(function(obj)
			self:renderDistributionTop(obj)
		end)
	else
		self:renderDistributionTop(self.view.petDistributionUContainer.content)
	end
end

function PetDistributionComponent:_refreshContent()
	self:renderDistributionTop(self.view.petDistributionUContainer.content)
end

function PetDistributionComponent:renderDistributionTop(content)
	local objectReference = content:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local txtNamePetUSDFText = objectReference:GetRefValue("txtNamePetUSDFText")
	local btnCloseUButton = objectReference:GetRefValue("btnCloseUButton")
	local txtFormUSDFText = objectReference:GetRefValue("txtFormUSDFText")
	local btnSwitchUButton = objectReference:GetRefValue("btnSwitchUButton")
	local cfgData = PetData[pg.game.map.activeDistributionPetTemplateId]

	iconUImage.url = LuaUIUtils.getPetIcon(cfgData.iconName, LuaUIUtils.PET_ICON, Const.PET_LABEL_MASK.NORMAL)

	function btnCloseUButton.luaClick()
		self:closeDistributionMode()
	end

	function btnSwitchUButton.luaClick()
		if PetResearchContentData[pg.game.map.activeDistributionPetTemplateId] and PetResearchContentData[pg.game.map.activeDistributionPetTemplateId].countryId then
			LuaUIUtils.openPetOverviewFromMap(PetResearchContentData[pg.game.map.activeDistributionPetTemplateId].countryId, self.model:getPetShowTab(), function(tab)
				self.model:refreshPetShowTab(tab)
			end, function()
				self:_refreshContent()
			end)
		end
	end

	local formName = LuaUIUtils.getPetFormName(pg.game.map.activeDistributionPetTemplateId)
	local isSpecies = self.model:getPetShowTab() == PetResearchUtils.PET_SHOW_TAB.SPECIES

	if isSpecies then
		formName = pg.getGameString("ALL_FORM_DISTRIBUTION")
	end

	ClientTextUtils.setText(txtFormUSDFText, formName)
	ClientTextUtils.setText(txtNamePetUSDFText, pg.getLocalizationText(cfgData.name))

	if self.view.petDistributionUImage then
		self.view.petDistributionUImage.gameObject:SetActiveEx(true)

		local distributionFormIds = pg.game.map.activeDistributionPetTemplateId

		if isSpecies then
			distributionFormIds = LuaUIUtils.getSpeciesKnownDistributionFormIds(pg.game.map.activeDistributionPetTemplateId)
		end

		MapPetAreaBlockHighlight.applyPetBlocks(self.view.petDistributionUImage, distributionFormIds, LuaUIUtils.checkAllUnlockedArea())
	end
end

function PetDistributionComponent:closeDistributionMode()
	pg.game.map.activeDistributionPetTemplateId = nil

	self:destroy()
end

function PetDistributionComponent:destroy()
	self.view.petDistributionUContainer:DestroyContent()

	if self.view.petDistributionUImage then
		MapPetAreaBlockHighlight.clear(self.view.petDistributionUImage)
		self.view.petDistributionUImage.gameObject:SetActiveEx(false)
	end
end

function PetDistributionComponent:onDestroy()
	self:destroy()
	UIComponent.onDestroy(self)
end

return PetDistributionComponent
