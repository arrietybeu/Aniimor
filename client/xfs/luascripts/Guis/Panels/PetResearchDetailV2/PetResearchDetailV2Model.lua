-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetResearchDetailV2\\PetResearchDetailV2Model.lua

local Const = require("Const.Const")
local UIConst = require("Const.UIConst")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local Utils = require("Common.Utils.Utils")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local PetResearchDetailV2Model = Class.LightClass("PetResearchDetailV2Model", UIModel)

PetResearchDetailV2Model.TAB_IDX = UIConst.HANDBOOK_PAGE_IDX
PetResearchDetailV2Model.EXPLORE_PARAM_IDX = {
	maxLevel = 3,
	level = 2,
	exploreId = 1
}

function PetResearchDetailV2Model:ctor()
	self.curPetTemplateId = nil
	self.curPetLabel = nil
	self.formPetTemplateId = nil
	self.formPetLabel = nil
	self.formPetShinyStyle = 0
	self.countryId = 300001
	self.isCollection = false
end

function PetResearchDetailV2Model:setCurPetTemplateId(curPetTemplateId, countryId)
	self.curPetTemplateId = curPetTemplateId
	self.baseTemplateId = Utils.getBasePetPrototypeId(curPetTemplateId)
	self.showTab = PetResearchUtils.getLastPetShowTab()
	self.countryId = countryId or Utils.getPetCountryId(curPetTemplateId)
	self.formPetTemplateId, self.formPetLabel, self.formPetShinyStyle = PetResearchUtils.getPetDisplayFormLabelTemplateId(self.curPetTemplateId, self.showTab, self.countryId)
	self.isCollection = PetResearchUtils.checkAreaIsCollection(self.countryId)
end

function PetResearchDetailV2Model:getPriorityLabel()
	local handbookInfo = pg.me.petHandbookMap:getInfo(self.curPetTemplateId)

	if handbookInfo:isShinyCatched() then
		return Const.PET_LABEL_MASK.SHINY
	end

	return Const.PET_LABEL_MASK.NORMAL
end

function PetResearchDetailV2Model:getEvolutionInfo()
	return
end

function PetResearchDetailV2Model:getBasePetTemplateId(templateId)
	return Utils.getBasePetPrototypeId(templateId)
end

return PetResearchDetailV2Model
