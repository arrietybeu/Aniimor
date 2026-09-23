-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetBatchStrengthPoint\\PetBatchStrengthPointCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("PetBatchStrengthPointCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PetBatchStrengthPointCtrl = Class.LightClass("PetBatchStrengthPointCtrl", UICtrl)
local PetManagementUtils = require("Utils.PetManagementUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local AttributeGroupData = require("Data.attribute_group_data")
local NoticeDef = require("Common.NoticeDef")
local ClientUtils = require("Utils.ClientUtils")
local UIConst = require("Const.UIConst")
local Const = require("Common.Const.Const")
local TimerManager = require("Core.Timer.TimerManager")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local string_format = string.format

PetBatchStrengthPointCtrl.messages = {
	[MessageName.PET_NEW_PROP_CHANGE] = {
		"onPetNewPropChange",
		true
	}
}

function PetBatchStrengthPointCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.petId = info.petId

	function self.view.btnCloseUButton.luaClick()
		self:close()
	end

	function self.view.btnClose1UButton.luaClick()
		self:close()
	end

	function self.view.btnInfoUButton.luaClick()
		self:onClickPointInfo()
	end

	function self.view.btnResetUButton.luaClick()
		self:onClickResetAllPoints()
	end

	function self.view.btnRecommendUButton.luaClick()
		self:onClickRecommend()
	end

	function self.view.btnConfirmUButton.luaClick()
		self:onClickConfirm()
	end

	function self.view.btnRulesUButton.luaClick()
		self:onClickRules()
	end

	local btnConfirmObjectReference = self.view.btnConfirmUButton:GetComponent("ObjectReference")
	local txtNameUText = btnConfirmObjectReference:GetRefValue("txtNameUText")

	ClientTextUtils.setText(txtNameUText, pg.getGameString("COMMON_CONFIRM"))
	self.model:syncModelInfo(self.petId)
	self:refreshBatchAddPointPanel()
end

function PetBatchStrengthPointCtrl:addListener()
	return
end

function PetBatchStrengthPointCtrl:onDestroy()
	UICtrl.onDestroy(self)

	if self.tickTimer then
		self:killTimer(self.tickTimer)

		self.tickTimer = nil
	end
end

function PetBatchStrengthPointCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
end

function PetBatchStrengthPointCtrl:onShow()
	return
end

function PetBatchStrengthPointCtrl:onHide()
	return
end

function PetBatchStrengthPointCtrl:onPetNewPropChange(msg)
	if msg.petId and msg.petId ~= self.petId then
		return
	end

	self.model:syncModelInfo(self.petId, true)
	self:refreshBatchAddPointPanel()
end

function PetBatchStrengthPointCtrl:refreshBatchAddPointPanel(newPropId)
	ClientTextUtils.setText(self.view.txtNowUSDFText, self.model.remainCanAddPointNum or 0)
	ClientTextUtils.setText(self.view.txtTotalUSDFText, self.model.potentialPointSum or 0)

	function self.view.listUList.luaRenderItem(button, index, data)
		self:initAndRefreshBatchAddPointItem(button, index, data)
	end

	self:refreshCurAttrsPanel()

	if not newPropId then
		local data = self.model:getDisplayPointDatas()

		self.view.listUList:SetList(data)
	else
		self.cacheItems = self.cacheItems or {}

		local data = self.model:getDisplayPointDatas()

		for propId, _ in ipairs(Const.NEW_BASE_PROP_IDX2ATTR_MAP) do
			local renderItem = self.cacheItems[propId]
			local renderItemData = data and data[propId]

			if renderItem and renderItemData then
				self:onlyRefreshBatchAddPointItem(renderItem, renderItemData)
			end
		end
	end
end

function PetBatchStrengthPointCtrl:initAndRefreshBatchAddPointItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local btnDecUButton = objectReference:GetRefValue("btnDecUButton")
	local btnAddUButton = objectReference:GetRefValue("btnAddUButton")
	local sliderUSlider = objectReference:GetRefValue("sliderUSlider")

	function btnDecUButton.luaClick()
		self:m_onClickDecPoint(data.propId)
	end

	function btnAddUButton.luaClick()
		self:m_onClickAddPoint(data.propId)
	end

	self:onlyRefreshBatchAddPointItem(button, data)

	function sliderUSlider.luaValueChanged(value)
		self:m_onSliderValueChanged(data.propId, math.floor(value))
	end

	function sliderUSlider.luaPress()
		self:m_onSliderPress(data.propId)
	end

	function sliderUSlider.luaRelease()
		self:m_onSliderRelease(data.propId)
	end

	self.cacheItems = self.cacheItems or {}
	self.cacheItems[data.propId] = button
end

function PetBatchStrengthPointCtrl:onlyRefreshBatchAddPointItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local rootUComp = objectReference:GetRefValue("rootUComp")
	local imgAttributeUImage = objectReference:GetRefValue("imgAttributeUImage")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local sliderUSlider = objectReference:GetRefValue("sliderUSlider")
	local fillAddUImage = objectReference:GetRefValue("fillAddUImage")
	local fillBaseUImage = objectReference:GetRefValue("fillBaseUImage")
	local progressAddUProgress = objectReference:GetRefValue("progressAddUProgress")
	local numPointUSDFText = objectReference:GetRefValue("numPointUSDFText")
	local numLevelUSDFText = objectReference:GetRefValue("numLevelUSDFText")
	local numAddUSDFText = objectReference:GetRefValue("numAddUSDFText")
	local newPropAtomAttrCfg = PetManagementUtils.getPetNewSixPropAtomAttrCfg(data.propId)

	imgAttributeUImage.url = newPropAtomAttrCfg and newPropAtomAttrCfg.icon or ""

	local l10nNameKey = newPropAtomAttrCfg and newPropAtomAttrCfg.name or pg.getGameString(PetManagementDataHelper.NEW_PROP_NAMES[data.propId])

	ClientTextUtils.setText(txtNameUSDFText, ClientTextUtils.getLocalizationText(l10nNameKey))

	local manualMaxLv = self.model:getManualMaxSLv(data.propId)
	local manualSLvPro, extraLvPro, specialSLvPro = PetManagementUtils.getPPointBatchManuProgressRatios(data.curSelectedSLv, manualMaxLv, data.extraStrengthLv)

	fillBaseUImage.fillAmount = specialSLvPro
	fillAddUImage.fillAmount = manualSLvPro
	progressAddUProgress.value = extraLvPro

	local curDisplaySLv = self.model:getDisplayStrengthLv(data.propId)
	local nextStrengehLvNeedPoint = PetManagementUtils.getNewPropReachNextLvNeedPotentialPoint(self.petId, curDisplaySLv + 1)

	ClientTextUtils.setText(numPointUSDFText, nextStrengehLvNeedPoint > 0 and nextStrengehLvNeedPoint or "")
	ClientTextUtils.setText(numLevelUSDFText, curDisplaySLv)

	local curDisplaySpecialLv = data.extraStrengthLv

	numAddUSDFText:SetActive(curDisplaySpecialLv > 0)

	if curDisplaySpecialLv > 0 then
		ClientTextUtils.setText(numAddUSDFText, "+" .. curDisplaySpecialLv)
	end

	local maxLv = PetManagementUtils.getNewPropMaxStrengthLv(self.petId)

	rootUComp:TryChangePage("State", maxLv <= curDisplaySLv and 1 or 0)

	sliderUSlider.value = tonumber(curDisplaySLv)

	if not self.m_isOnSliderPressing then
		self.model:syncUpateAllPropCanReachedMaxLv()

		local canReachedLv = self.model:getCanReachedMaxStrengthLv(data.propId)

		sliderUSlider:SetDynamicMaxRestriction(canReachedLv, true)
	end
end

function PetBatchStrengthPointCtrl:m_onClickDecPoint(propId)
	local retNotice = self.model:tryDecStrengthLv(propId, 1)

	if retNotice ~= nil then
		pg.global.showBubbleMessageById(retNotice)

		return
	end

	self:refreshBatchAddPointPanel(propId)
end

function PetBatchStrengthPointCtrl:m_onClickAddPoint(propId)
	local retNotice = self.model:tryAddStrengthLv(propId, 1)

	if retNotice ~= nil then
		pg.global.showBubbleMessageById(retNotice)

		return
	end

	self:refreshBatchAddPointPanel(propId)
end

function PetBatchStrengthPointCtrl:m_onSliderValueChanged(propId, value)
	local retNotice = self.model:trySliderStrengthLv(propId, value)

	if retNotice ~= nil then
		return
	end

	self:refreshBatchAddPointPanel(propId)
end

function PetBatchStrengthPointCtrl:m_onSliderPress(propId, value)
	self.m_isOnSliderPressing = true
end

function PetBatchStrengthPointCtrl:m_onSliderRelease(propId, value)
	self.m_isOnSliderPressing = false

	self:refreshBatchAddPointPanel(propId)
end

function PetBatchStrengthPointCtrl:refreshCurAttrsPanel()
	local data = self.model:getBatchAddPreviewAttrs()

	function self.view.listPreviewUList.luaRenderItem(button, index, data)
		self:m_refreshCurAttrsItem(button, index, data)
	end

	self.view.listPreviewUList:SetList(data)
end

function PetBatchStrengthPointCtrl:m_refreshCurAttrsItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
	local nameStr, numStr = PetManagementUtils.getPetNewPropConvertGainDesc2(data)

	ClientTextUtils.setText(txtNameUSDFText, nameStr)
	ClientTextUtils.setText(txtNumUSDFText, numStr)
end

function PetBatchStrengthPointCtrl:onClickResetAllPoints()
	PetManagementUtils.popupResetAllocatePoint(self.petId, self.m_totalUsedPPoint)
end

function PetBatchStrengthPointCtrl:onClickRecommend()
	pg.global.ui:open(UIConst.UI_ID_PET_RECOMMEND_STRENGTH_POINT, {
		petId = self.petId
	})
end

function PetBatchStrengthPointCtrl:onClickConfirm()
	local resetCostInfo = PetManagementUtils.getResetEffortCostInfo()
	local fStr = pg.getGameString("PET_NEW_ATTR_APLLY_TIPS2")

	fStr = (not fStr or fStr == "PET_NEW_ATTR_APLLY_TIPS2") and "ApplyRecommendPPoint%s" or fStr

	local usedPPointSum = self.model:getDisplayUsedPPointSum()

	pg.global.showCommonTipUse(pg.getGameString("RELEASE_WARN"), string_format(fStr, usedPPointSum or 0), resetCostInfo, function()
		local batchDatas = self.model:getDisplayPointDatas()
		local batchPropInfos = {}

		for k, v in pairs(batchDatas or EMPTY_TABLE) do
			local attrName = PetManagementUtils.getPetNewPropAttrNameByNewId(v.propId)

			if attrName then
				batchPropInfos[#batchPropInfos + 1] = {
					propAttrName = attrName,
					propLv = v.curSelectedSLv
				}
			end
		end

		if #batchPropInfos > 0 then
			PetManagementUtils.tryReqBatchAllocateEffort(self.petId, batchPropInfos, true)
		end
	end)
end

function PetBatchStrengthPointCtrl:onClickRules()
	pg.global.ui:open(UIConst.UI_ID_PET_BATCH_STRENGTH_RULE, {
		petId = self.petId
	})
end

function PetBatchStrengthPointCtrl:onClickPointInfo()
	function self.view.btnInfoUButton.luaRenderTooltip(_, component)
		local objectReference = component:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")

		ClientTextUtils.setText(txtNameUSDFText, pg.getGameString("PET_STRENGTH_TIP"))
	end
end

return PetBatchStrengthPointCtrl
