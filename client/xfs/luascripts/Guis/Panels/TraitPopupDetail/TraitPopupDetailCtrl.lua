-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TraitPopupDetail\\TraitPopupDetailCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local TraitPopupDetailCtrl = Class.LightClass("TraitPopupDetailCtrl", UICtrl)
local PetTraitData = require("Data.pet_trait_data")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")

TraitPopupDetailCtrl.messages = {}

function TraitPopupDetailCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.info = info
	self.view.petUImage.url = info.traitInfo.iconId

	ClientTextUtils.setText(self.view.numberUText, info.traitInfo.researchPoint)

	local traitCfg = PetTraitData[info.templateId]

	if traitCfg and traitCfg[info.traitId] then
		local cfg = traitCfg[info.traitId]

		self.view.iconUImage.url = cfg.traitsImg

		ClientTextUtils.setText(self.view.title1UText, pg.getLocalizationText(cfg.text))
		ClientTextUtils.setText(self.view.title2UText, pg.getLocalizationText(cfg.traitsName))
		ClientTextUtils.setText(self.view.detailUText, pg.getLocalizationText(cfg.traitsDesc))
	end
end

function TraitPopupDetailCtrl:openResearchDetail(templateId)
	if self.inLoading then
		return
	end

	self:close()

	self.inLoading = true

	PetResearchUtils.openPetResearchDetail({
		templateId = templateId
	}, function()
		self.inLoading = false
	end)
end

function TraitPopupDetailCtrl:addListener()
	function self.view.bgBtnUButton.luaClick()
		self:close()
	end

	function self.view.btnViewUButton.luaClick()
		self:openResearchDetail(self.info.templateId)
	end
end

function TraitPopupDetailCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function TraitPopupDetailCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function TraitPopupDetailCtrl:onShow()
	return
end

function TraitPopupDetailCtrl:onHide()
	return
end

return TraitPopupDetailCtrl
