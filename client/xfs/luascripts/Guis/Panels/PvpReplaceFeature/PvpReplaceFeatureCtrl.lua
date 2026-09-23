-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PvpReplaceFeature\\PvpReplaceFeatureCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PvpReplaceFeatureCtrl = Class.LightClass("PvpReplaceFeatureCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")

function PvpReplaceFeatureCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	self:refreshList(info.templateId)
end

function PvpReplaceFeatureCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:closePanel()
	end

	function self.view.listUList.luaRenderItem(button, index, data)
		self:instantiateFeatures(button, index, data)
	end
end

function PvpReplaceFeatureCtrl:closePanel()
	self:dismiss()
end

function PvpReplaceFeatureCtrl:refreshList(templateId)
	self.view.listUList:SetList(self.model:getAllFeatures(templateId))

	self.curTemplateId = templateId
end

function PvpReplaceFeatureCtrl:instantiateFeatures(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local root = objectReference:GetRefValue("root")
	local nameUText = objectReference:GetRefValue("nameUText")
	local txtDetailUText = objectReference:GetRefValue("txtDetailUText")
	local iconUImage = objectReference:GetRefValue("iconUImage")

	ClientTextUtils.setText(txtDetailUText, pg.getLocalizationText(data.featureData.desc))
	ClientTextUtils.setText(nameUText, pg.getLocalizationText(data.featureData.name))

	iconUImage.url = data.featureData.icon

	function button.luaClick()
		if self.curTemplateId == nil then
			return
		end

		local pvpPetSet = pg.global.ui.pvpPetSet

		if pvpPetSet == nil then
			return
		end

		pvpPetSet.model.petsMap[self.curTemplateId].serverData.curCharacter = data.featureId

		pvpPetSet:sendSavePetInfoMsg(self.curTemplateId, 1)
		self:closePanel()
	end
end

function PvpReplaceFeatureCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function PvpReplaceFeatureCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

return PvpReplaceFeatureCtrl
