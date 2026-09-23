-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetPreview\\PetPreviewCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetPreviewCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetData = require("Data.pet_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetPreviewCtrl = Class.LightClass("PetPreviewCtrl", UICtrl)

PetPreviewCtrl.messages = {}

function PetPreviewCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function PetPreviewCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:dismiss()
	end

	function self.view.cornerCloseUButton.luaClick()
		self:dismiss()
	end

	function self.view.listUList.luaRenderItem(button, index, data)
		self:renderItem(button, index, data)
	end
end

function PetPreviewCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function PetPreviewCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.previewPetTemplateIds = info.templateIds

	ClientTextUtils.setText(self.view.txtTitleUBaseText, pg.getLocalizationText(info.title))
	self.view.listUList:SetList(self.model:getPreviewInfo(self.previewPetTemplateIds))

	self.previewPetBaseTemplateIds = self.model:getBaseTemplateIds(self.previewPetTemplateIds)
end

function PetPreviewCtrl:onShow()
	return
end

function PetPreviewCtrl:onHide()
	return
end

function PetPreviewCtrl:renderItem(button, index, data)
	local objectRef = button:GetComponent("ObjectReference")
	local uList = objectRef:GetRefValue("listUList")
	local txt = objectRef:GetRefValue("textUBaseText")

	ClientTextUtils.setText(txt, data.typeName)

	function uList.luaRenderItem(petBtn, petIdx, petData)
		function petBtn.luaClick()
			pg.global.ui:open(UIConst.UI_ID_PET_DETAIL, {
				needShowForm = true,
				templateId = petData.templateId,
				templateIdList = self.previewPetTemplateIds
			})
		end

		petBtn.draggable = false
		petBtn.enabledTooltip = false

		local petBtnObjectRef = petBtn:GetComponent("ObjectReference")
		local icon = petBtnObjectRef:GetRefValue("iconUImage")
		local cData = PetData[petData.templateId] or {}
		local petIcon = LuaUIUtils.getPetIcon(cData.iconName, LuaUIUtils.PET_ICON)

		icon.url = petIcon
	end

	uList:SetList(data.petData)
end

return PetPreviewCtrl
