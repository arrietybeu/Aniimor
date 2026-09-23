-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CatchRoguePetBag\\CatchRoguePetBagCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("CatchRoguePetBagCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetData = require("Data.pet_data")
local PetManagementUtils = require("Utils.PetManagementUtils")
local CatchRoguePetBagCtrl = Class.LightClass("CatchRoguePetBagCtrl", UICtrl)
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")

CatchRoguePetBagCtrl.messages = {}

function CatchRoguePetBagCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self:initUI()
end

function CatchRoguePetBagCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:dismiss()
	end

	function self.view.listPetUList.luaRenderItem(button, index, data)
		self:renderPetItem(button, index, data)
	end
end

function CatchRoguePetBagCtrl:onDestroy()
	PetManagementUtils.destroyTemplate()
	UICtrl.onDestroy(self)
end

function CatchRoguePetBagCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function CatchRoguePetBagCtrl:onShow()
	return
end

function CatchRoguePetBagCtrl:onHide()
	return
end

function CatchRoguePetBagCtrl:initUI()
	PetManagementUtils.initSimpleInfoTemplate(self.view.petInfoPanelUWidget.transform, {
		noNeedTabIndex = true,
		extraLogic = function()
			if PetManagementUtils.btnRenameUButton then
				PetManagementUtils.btnRenameUButton.gameObject:SetActiveEx(false)
			end

			if PetManagementUtils.btnFavoriteUButton then
				PetManagementUtils.btnFavoriteUButton.gameObject:SetActiveEx(false)
			end

			if PetManagementUtils.btnSkillPresetsUButton then
				PetManagementUtils.btnSkillPresetsUButton.gameObject:SetActiveEx(false)
			end

			if PetManagementUtils.btnPetManualUButton then
				PetManagementUtils.btnPetManualUButton.gameObject:SetActiveEx(false)
			end
		end
	})

	local petList = self.model:getPetListInfo()

	self.view.rootWidget:TryChangePage("Empty", #petList > 0 and 0 or 1)
	self.view.listPetUList:SetList(petList)
end

function CatchRoguePetBagCtrl:renderPetItem(button, index, data)
	function button.luaPress()
		self.view.listPetUList:SelectItem(index)
		PetManagementUtils.showPetInfo(data)
	end

	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local pData = PetData[data.templateId]

	iconUImage.url = LuaUIUtils.getPetIcon(pData.iconName, LuaUIUtils.PET_ICON)
	button.draggable = false
	button.enabledTooltip = false

	LuaUIUtils.renderPetHeadFlashBgAndFrame(objectReference, data.isShiny, data.shinyStyle or 0)
	PetManagementDataHelper.tryChangePetHeadBossTagPage(button, data.label)
end

return CatchRoguePetBagCtrl
