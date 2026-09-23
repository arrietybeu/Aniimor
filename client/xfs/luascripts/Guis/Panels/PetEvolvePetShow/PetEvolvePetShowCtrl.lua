-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetEvolvePetShow\\PetEvolvePetShowCtrl.lua

local MessageName = require("Const.MessageName")
local PetData = require("Data.pet_data")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local PetFirstShowData = require("Data.pet_first_show_data")
local PetConfigData = require("Data.pet_config_data")
local HotkeyConst = require("Const.HotkeyConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PetEvolvePetShowCtrl = Class.LightClass("PetEvolvePetShowCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")

PetEvolvePetShowCtrl.messages = {}

function PetEvolvePetShowCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.petInfo = info.petInfo
	self.templateId = self.petInfo.templateId
end

function PetEvolvePetShowCtrl:addListener()
	function self.view.listUList.luaRenderItem(button, idx, data)
		if data.elementName then
			LuaUIUtils.setElementButtonNew(button, data.elementName, false, self.templateId)
		end
	end

	function self.view.listTagUList.luaRenderItem(button, idx, data)
		LuaUIUtils.renderPetTagList(button, data)
		LuaUIUtils.setPetTagLabelToolTip(button, LuaUIUtils.getPetTagInfo(self.templateId, self.petInfo.label, self.petInfo.bodySizeType, self.petInfo.shinyStyle), function()
			self.m_isShowTagToolTip = true
		end)
	end
end

function PetEvolvePetShowCtrl:onDestroy()
	self.resultViewShown = false

	local context = self.presentationContext

	if context then
		context.refresh = nil
		self.presentationContext = nil

		if context.onViewDestroyed then
			context.onViewDestroyed()
		end
	end

	UICtrl.onDestroy(self)
end

function PetEvolvePetShowCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.presentationContext = info.presentationContext
	self._presentationCloseHandled = false
	self.resultViewShown = false
	self.resultAnimationPlayed = false

	self:_initCloseBtnClick(info)

	local pData = PetData[self.templateId]
	local displayNumber = PetResearchUtils.getDisplayNumberByTemplateId(self.templateId)

	ClientTextUtils.setText(self.view.numberUText, displayNumber ~= "" and displayNumber or "001")

	local name = pg.getLocalizationText(pData.name)

	ClientTextUtils.setText(self.view.petNameUText, name)
	ClientTextUtils.setText(self.view.variantName1, name)
	ClientTextUtils.setText(self.view.variantName2, name)

	local petType = PetData[self.templateId].functionId

	self.view.battleTypeIcon.url = PetConfigData.petFunctionIcon[petType]

	local petFunctionText = pg.getLocalizationText(PetConfigData[string.format("petFunctionText%s", petType)])

	ClientTextUtils.setText(self.view.battleTypeUSDFText, petFunctionText)

	local t = LuaUIUtils.getTargetElementsInfos(pData.elementType)

	self.view.listUList:SetList(t)

	local firstShowData = PetFirstShowData[self.templateId]
	local level = firstShowData.featureIv
	local element = firstShowData.element

	ClientTextUtils.setText(self.view.formName, LuaUIUtils.getPetFormName(self.templateId))
	PetResearchUtils.setEvolveQuality(self.view.btnPetQualityUButton, self.templateId)

	if firstShowData and firstShowData.featureDescription then
		LuaUIUtils.setUIViewVisible(self.view.txtDetailUText, true)
		ClientTextUtils.setText(self.view.detailUText, pg.getLocalizationText(firstShowData.featureDescription))
	else
		LuaUIUtils.setUIViewVisible(self.view.detailUText, false)
	end

	if level then
		LuaUIUtils.setUIViewVisible(self.view.petCharUButton, true)

		if element and level > 3 then
			self.view.petCharUButton:TryChangePage("SkillType", 1)
			self.view.petCharUButton:TryChangePage("type", element)

			self.view.attributeIconUImage.url = firstShowData.featureIcon
		else
			self.view.petCharUButton:TryChangePage("SkillType", 0)

			self.view.exploreSkillIconUImage.url = firstShowData.featureIcon

			ClientTextUtils.setText(self.view.exploreText, pg.getLocalizationText(firstShowData.featureName))
		end
	else
		LuaUIUtils.setUIViewVisible(self.view.petCharUButton, false)
	end

	local tagDatas = LuaUIUtils.getPetTagList(self.petInfo)

	self.view.listTagUList:SetList(tagDatas)
	self.view.widget:TryChangePage("isChange", self.petInfo.isVariant and 1 or 0)
	ClientTextUtils.setText(self.view.btnTipsUSDFText, pg.getGameString("CONSOLE_BAR_RETURN"))

	if self.presentationContext then
		local anim = self.view.uIPbManualEvolvePetShowNewAnimation

		anim.clip:SampleAnimation(anim.gameObject, 0)

		function self.presentationContext.refresh()
			self:refreshPresentation()
		end

		self:refreshPresentation()
	end
end

function PetEvolvePetShowCtrl:refreshPresentation()
	local context = self.presentationContext

	if context.active and context.resultReady and self.resultViewShown and not self.resultAnimationPlayed then
		self.resultAnimationPlayed = true

		self.view.uIPbManualEvolvePetShowNewAnimation:Play()
	end

	local skip = context.active and context.canSkip
	local close = context.active and context.canClose
	local text = skip and pg.getGameString("CLICK_TO_SKIP") or pg.getGameString("Left_Click_Close")

	ClientTextUtils.setText(self.view.textCloseUText, text)

	if skip then
		self.view.buttonCloseUButton:SetActiveQuickly(true)
	elseif not close then
		self.view.buttonCloseUButton:SetActiveQuickly(false)
	end

	self:refreshConsoleBarState()
end

function PetEvolvePetShowCtrl:refreshConsoleBarState()
	local context = self.presentationContext
	local skip = false
	local close = true

	if context then
		skip = context.active and context.canSkip
		close = context.active and context.canClose
	end

	self.view.keyListConsoleBar:SetState("PET_EVOLVE_SHOW_SKIP", skip, true)
	self.view.keyListConsoleBar:SetState("PET_EVOLVE_SHOW_CLOSE", close, true)
end

function PetEvolvePetShowCtrl:checkCommonQuit()
	local context = self.presentationContext

	if context and context.active then
		return false
	end

	return UICtrl.checkCommonQuit(self)
end

function PetEvolvePetShowCtrl:consumePresentationInput()
	local context = self.presentationContext

	if not context then
		return false
	end

	if context.closing or not context.active then
		return true
	end

	if context.canSkip then
		context.skip()

		return true
	end

	if not context.canClose then
		return true
	end

	context.closing = true

	return false
end

function PetEvolvePetShowCtrl:closePresentation(info)
	if self._presentationCloseHandled then
		return
	end

	if self:consumePresentationInput() then
		return
	end

	self._presentationCloseHandled = true

	if info and info.closeCallback then
		info.closeCallback(self.petInfo)
	else
		self:dismiss()
	end
end

function PetEvolvePetShowCtrl:_initCloseBtnClick(info)
	function self.view.buttonCloseUButton.luaClick()
		if self.m_isShowTagToolTip then
			self.m_isShowTagToolTip = false

			return
		end

		self:closePresentation(info)
	end

	function self.view.keyBUButton.luaClick()
		self:closePresentation(info)
	end

	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.buttonCloseUButton.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:closePresentation(info)
		end

		return false
	end
end

function PetEvolvePetShowCtrl:onShow()
	self.resultViewShown = true

	if self.presentationContext then
		self:refreshPresentation()
	elseif not self.resultAnimationPlayed then
		self.resultAnimationPlayed = true

		self.view.uIPbManualEvolvePetShowNewAnimation:Play()
	end
end

function PetEvolvePetShowCtrl:onHide()
	self.resultViewShown = false
end

return PetEvolvePetShowCtrl
