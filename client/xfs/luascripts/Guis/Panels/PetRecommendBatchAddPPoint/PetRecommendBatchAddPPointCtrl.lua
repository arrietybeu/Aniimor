-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetRecommendBatchAddPPoint\\PetRecommendBatchAddPPointCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("PetRecommendBatchAddPPointCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PetRecommendBatchAddPPointCtrl = Class.LightClass("PetRecommendBatchAddPPointCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local RecommendData = require("Data.pet_strength_recommend_data")
local PetManagementUtils = require("Utils.PetManagementUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientUtils = require("Utils.ClientUtils")
local Const = require("Common.Const.Const")
local string_format = string.format

PetRecommendBatchAddPPointCtrl.messages = {
	[MessageName.PET_NEW_PROP_CHANGE] = {
		"onPetNewPropChange",
		true
	}
}

function PetRecommendBatchAddPPointCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.petId = info.petId

	function self.view.btnCloseUButton.luaClick()
		self:close()
	end

	function self.view.btnCloseUButton2.luaClick()
		self:close()
	end

	function self.view.listUList.luaRenderItem(button, index, data)
		self:m_refreshItem(button, index, data)
	end

	self:refreshPanel()
end

function PetRecommendBatchAddPPointCtrl:addListener()
	return
end

function PetRecommendBatchAddPPointCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function PetRecommendBatchAddPPointCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function PetRecommendBatchAddPPointCtrl:onShow()
	return
end

function PetRecommendBatchAddPPointCtrl:onHide()
	return
end

function PetRecommendBatchAddPPointCtrl:refreshPanel()
	local data = self.model:getPetRecommendList(self.petId)

	self.view.listUList:SetList(data or {})
end

function PetRecommendBatchAddPPointCtrl:m_refreshItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtTitleUSDFText = objectReference:GetRefValue("txtTitleUSDFText")
	local textDashen = objectReference:GetRefValue("textDashen")
	local textBini = objectReference:GetRefValue("textBini")
	local txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local txtNameSubUSDFText = objectReference:GetRefValue("txtNameSubUSDFText")
	local btnReadyUWidget = objectReference:GetRefValue("btnReadyUWidget")
	local btnApplyUButton = objectReference:GetRefValue("btnApplyUButton")
	local binniUWidget = objectReference:GetRefValue("binniUWidget")
	local btnAppliedUSDFText = objectReference:GetRefValue("btnAppliedUSDFText")

	function btnApplyUButton.luaClick()
		self:m_onClickApply(button, index, data)
	end

	ClientTextUtils.setText(btnAppliedUSDFText, pg.getGameString("PET_NEW_PROP_APPLIED"))

	local isApplied = self.model:isPetNewPropApplied(self.petId, data)

	btnApplyUButton:SetActive(not isApplied)

	if not isApplied then
		LuaUIUtils.generalSetBtnTextL10NCont(btnApplyUButton, "txtNameUText", "PET_NEW_PROP_APPLY")
	end

	local recommendCfg = RecommendData[data.recommendId]

	ClientTextUtils.setText(txtTitleUSDFText, pg.getLocalizationText(recommendCfg.title or ""))
	ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(recommendCfg.propdesc or ""))
	ClientTextUtils.setText(txtNameSubUSDFText, pg.getLocalizationText(recommendCfg.desc or ""))
	binniUWidget:SetActive(index == 0)

	if index == 0 then
		ClientTextUtils.setText(textDashen, "")
	else
		ClientTextUtils.setText(textBini, "")
	end

	ClientTextUtils.setText(txtNumUSDFText, data.recommendRatio .. "%")
end

function PetRecommendBatchAddPPointCtrl:m_onClickApply(button, index, data)
	local fStr = pg.getGameString("PET_NEW_ATTR_APLLY_TIPS3")
	local resetCostInfo = PetManagementUtils.getResetEffortCostInfo()

	fStr = (not fStr or fStr == "PET_NEW_ATTR_APLLY_TIPS3") and "BatchAddPPoint%s" or fStr

	local usedPPointSum = self.model:getUsedPPointSum(data)

	pg.global.showCommonTipUse(pg.getGameString("RELEASE_WARN"), string_format(fStr, usedPPointSum or 0), resetCostInfo, function()
		local batchPropInfos = {}

		for i, v in ipairs(data and data.detailPropInfos or EMPTY_TABLE) do
			local newPropAttrName = PetManagementUtils.getPetNewPropAttrNameByNewId(v.propId)

			table.insert(batchPropInfos, {
				propAttrName = newPropAttrName,
				propLv = v.propertyStrengPoint
			})
		end

		PetManagementUtils.tryReqBatchAllocateEffort(self.petId, batchPropInfos, true, true)
	end)
	self:close()
end

function PetRecommendBatchAddPPointCtrl:onPetNewPropChange(msg)
	if msg and msg.petId and msg.petId ~= self.petId then
		return
	end

	self:refreshPanel()
end

return PetRecommendBatchAddPPointCtrl
