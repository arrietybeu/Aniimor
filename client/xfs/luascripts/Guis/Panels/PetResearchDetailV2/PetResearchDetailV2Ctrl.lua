-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetResearchDetailV2\\PetResearchDetailV2Ctrl.lua

local MessageName = require("Const.MessageName")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local AbilityConst = require("Common.Const.AbilityConst")
local Const = require("Const.Const")
local AbilityParamData = require("Data.ability_param_data")
local PetData = require("Data.pet_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PetSkillData = require("Data.pet_skill_data")
local PetResearchContentData = require("Data.pet_research_content_data")
local PetProtoTypeData = require("Data.pet_prototype_data")
local PetFormTextData = require("Data.pet_form_text_data")
local ClientConst = require("Const.ClientConst")
local PetAvatarData = require("Data.pet_avatar_data")
local PetEvolveData = require("Data.pet_evolve_data")
local RedDotConst = require("Const.RedDotConst")
local PetResearchDetailV2Ctrl = Class.LightClass("PetResearchDetailV2Ctrl", UICtrl)
local PetSurveyPageComponent = require("Guis.Panels.PetResearchDetailV2.Component.PetSurveyPageComponent")
local PetResearchProgressComponent = require("Guis.Panels.PetResearchDetailV2.Component.PetResearchProgressComponent")
local PetEvolutionGraphComponent = require("Guis.Panels.PetResearchDetailV2.Component.PetEvolutionGraphComponent")
local PetSkillComponent = require("Guis.Panels.PetResearchDetailV2.Component.PetSkillComponent")
local PetTopicComponent = require("Guis.Panels.PetResearchDetailV2.Component.PetTopicComponent")
local PetSurveyFormComponent = require("Guis.Panels.PetResearchDetailV2.Component.PetSurveyFormComponent")
local PetAlbumComponent = require("Guis.Panels.PetResearchDetailV2.Component.PetAlbumComponent")
local PetFormComponent = require("Guis.Panels.PetResearchDetailV2.Component.PetFormComponent")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local GamePadNavigation = require("Utils.GamePadNavigation")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Utils = require("Common.Utils.Utils")
local SkillTagData = require("Data.skill_tag_data")
local PetShinyStyleData = require("Data.pet_shiny_style_data")

PetResearchDetailV2Ctrl.messages = {
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	},
	[MessageName.PET_RESEARCH_LEVEL_REWARD_STATUS_CHANGE] = {
		"onPetRewardStatusChanged",
		true
	},
	[MessageName.PHOTO_DELETE] = {
		"refreshPetAlbum",
		true
	},
	[MessageName.PET_RESEARCH_FORM_DISPLAY_CHANGE] = {
		"onPetDisplayChanged",
		true
	},
	[MessageName.PET_RESEARCH_FORM_LABEL_DISPLAY_CHANGE] = {
		"onPetLabelDisplayChanged",
		true
	}
}

function PetResearchDetailV2Ctrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.info = info
	self.petScene = self.uiScene

	self.petScene:preLoadSubScene(info.templateId)

	self.petProgress = PetResearchProgressComponent.new(self, self.view.panelResearchUWidget)
	self.tabMap = {}
	self.detailVisible = true
end

function PetResearchDetailV2Ctrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:dismiss()
	end

	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.btnBackUButton.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:dismiss()
		end
	end

	function self.view.listUList.luaRenderItem(button, idx, data)
		self:renderTitleIconList(button, idx, data)
	end

	function self.view.listUList.luaResetItem(button)
		local objectReference = button:GetComponent("ObjectReference")
		local petIcon = objectReference:GetRefValue("iconUImage")

		petIcon.url = nil
	end

	function self.view.listUList.luaSelectedChanged(uList, isSelect)
		local data = uList.selectedItem

		if data and data.templateId ~= self.model.curPetTemplateId then
			local selectIdx = self.view.listUList.selectedIndex
			local _, min, max = uList:TryGetVisualRange()

			if selectIdx and (selectIdx - min < 2 or max - selectIdx < 2) then
				uList:GoToIndex(math.max(0, selectIdx - 3))
			end

			self:tryShowPet(data.templateId)
			self:refreshConsoleBarState()
		end
	end

	function self.view.rootComponent.luaTryChangePage(name, pageIdx, lastPageIdx)
		self:onTabChange(name, pageIdx, lastPageIdx)
	end

	function self.view.panelResearchUWidget.luaRenderTooltip(button, tooltip)
		local objectReference = tooltip:GetComponent("ObjectReference")
		local txtTitle = objectReference:GetRefValue("txtTitle")
		local txtDesc = objectReference:GetRefValue("txtDesc")
		local needExpMax = PetResearchUtils.getTotalNeedResearchPoint(self.model.curPetTemplateId)

		ClientTextUtils.setText(txtTitle, pg.getGameString("PET_RESEARCH_PROGRESS_REWARD_TITLE"))
		ClientTextUtils.setText(txtDesc, string.format(pg.getGameString("PET_RESEARCH_PROGRESS_REWARD_DESC"), needExpMax))
	end

	function self.view.btnAbilityUButton.luaClick()
		if not self.hasAbility then
			pg.global.showBubbleMessageRaw(pg.getGameString("PET_RESEARCH_LOCKED"))
		end
	end

	function self.view.btnGeneUButton.luaClick()
		if not self.hasEvolve then
			pg.global.showBubbleMessageRaw(pg.getGameString("PET_RESEARCH_EVOLUTION_LOCKED"))
		end
	end

	function self.view.btnPieUButton.luaClick()
		pg.global.showBubbleMessageRaw(pg.getGameString("FUNC_NOT_AVAILABLE"))
	end

	local nextPet = KeyBindingPro.GetOrAddKeyBindingByName(self.view.transform.gameObject, "nextPet")

	nextPet.isVirtual = true
	nextPet.priority = -1
	nextPet.actionPath = "Hud/PetResearchNext"

	function nextPet.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:gotoNextPet(true)
		end
	end

	local prePet = KeyBindingPro.GetOrAddKeyBindingByName(self.view.transform.gameObject, "prePet")

	prePet.isVirtual = true
	prePet.priority = -1
	prePet.actionPath = "Hud/PetResearchPre"

	function prePet.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:gotoNextPet()
		end
	end
end

function PetResearchDetailV2Ctrl:onPetRewardStatusChanged()
	self.view.listUList:RefreshList()
end

function PetResearchDetailV2Ctrl:checkSkipMenuAttenuation()
	return true
end

function PetResearchDetailV2Ctrl:checkSkipBgmAttenuation()
	return true
end

function PetResearchDetailV2Ctrl:getPetExploreSkillData(exploreId, level)
	if exploreId == AbilityConst.SPECIFIC_ABILITY_INDEX_CLIMB then
		local skillInfo = AbilityParamData[9001006]

		return {
			paramId = 9001006,
			level = level,
			icon = LuaUIUtils.getSkillIcon(skillInfo.icon),
			name = skillInfo.name,
			desc = LuaUIUtils.getSkillDesc(skillInfo)
		}
	elseif exploreId == AbilityConst.SPECIFIC_ABILITY_INDEX_FLY then
		local skillInfo = AbilityParamData[9001007]

		return {
			paramId = 9001007,
			level = level,
			icon = LuaUIUtils.getSkillIcon(skillInfo.icon),
			name = skillInfo.name,
			desc = LuaUIUtils.getSkillDesc(skillInfo)
		}
	elseif exploreId == AbilityConst.SPECIFIC_ABILITY_INDEX_SWIM then
		local skillInfo = AbilityParamData[9001008]

		return {
			paramId = 9001008,
			level = level,
			icon = LuaUIUtils.getSkillIcon(skillInfo.icon),
			name = skillInfo.name,
			desc = LuaUIUtils.getSkillDesc(skillInfo)
		}
	end
end

function PetResearchDetailV2Ctrl:onDestroy()
	UICtrl.onDestroy(self)

	self.surveyPage = nil
	self.evolutionPage = nil
	self.skillPage = nil
	self.petTopic = nil
	self.petDistributedComponent = nil
	self.petAlbum = nil
	self.petProgress = nil
	self.formPage = nil
	self.surveyForm = nil
	self.tabMap = {}

	pg.game.uiScene:switchOutScene(UISceneConst.PET_RESEARCH_DETAIL_V3)
	facade:sendMsgToUI(MessageName.PET_RESEARCH_PET_NEW_LABEL_STATUS_CHANGE, {})

	if self.info.closeCb then
		self.info.closeCb()
	end
end

function PetResearchDetailV2Ctrl:gotoNextPet(forward)
	local cur = self.view.listUList.selectedIndex
	local itemCount = self.view.listUList.itemCount
	local selectedIdx = forward and cur + 1 or cur - 1

	selectedIdx = math.clamp(selectedIdx, 0, itemCount - 1)

	self.view.listUList:SelectItem(selectedIdx or 0)
	self.view.listUList:GoToIndex(selectedIdx or 0)
end

function PetResearchDetailV2Ctrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.formTargetTemplateId = info.formTargetTemplateId
	self.formTargetLabel = info.formTargetLabel
	self.formTargetShinyStyle = info.formTargetShinyStyle

	local subPageIdx = info.subPageIdx or self.model.TAB_IDX.SURVEY

	self.customBlackChange = true
	self.curTabIdx = subPageIdx

	self.view.rootComponent:TryChangePage("Tab", subPageIdx)

	local enterCb
	local hideEnterAction = false

	if self.curTabIdx == self.model.TAB_IDX.ABILITY then
		function enterCb()
			self.skillPage:playAbilityNewLockVx(info.abilityParamId)
		end

		hideEnterAction = true
	end

	if self.curTabIdx == self.model.TAB_IDX.EVOLUTION and info.branchId then
		self:startTimer(function()
			if info.templateId == self.model.curPetTemplateId and self.evolutionPage then
				self.evolutionPage:showBranchDetail(info.templateId, info.branchId)
			end
		end, 0.5)
	end

	self.model:setCurPetTemplateId(info.templateId, info.countryId)
	self:initTitleList()
	self:refreshTitlePetRedDot()
	self:playEnterAction(enterCb)

	self.showPanelResearch = self:_getCanShowPanelResearch()

	self.view.panelResearchUWidget:SetActiveFastest(self.showPanelResearch)
	self:refreshRedDot()
end

function PetResearchDetailV2Ctrl:_getCanShowPanelResearch()
	return PetResearchContentData[self.model.baseTemplateId].researchLvSet ~= nil
end

function PetResearchDetailV2Ctrl:refreshConsoleBarState()
	if self.curTabIdx == self.model.TAB_IDX.EVOLUTION and self.evolutionPage then
		self.evolutionPage:refreshConsoleSelectList()
	end

	if CS.XGUI.Navigation then
		local showChoose = true

		if self.curTabIdx == self.model.TAB_IDX.TOPIC then
			showChoose = false
		end

		if self.curTabIdx == self.model.TAB_IDX.ALBUM then
			showChoose = self.petAlbum and #self.petAlbum:getAlbumSprite() > 1 or false
		end

		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("UI_PetManual_Explore_Choose", showChoose)
	end
end

function PetResearchDetailV2Ctrl:onPetResearchRewardChange(isShow)
	self:setResearchDetailVisible(not isShow)

	if not isShow and self:checkUIOpen() then
		self:restorePageTimeLine()
	end
end

function PetResearchDetailV2Ctrl:gotoPage(subPageIdx, templateId)
	self.view.rootComponent:TryChangePage("Tab", subPageIdx)

	templateId = templateId or self.model.curPetTemplateId

	if templateId ~= self.model.curPetTemplateId then
		self.view.rootComponent:TryChangePage("Tab", subPageIdx)

		local petIdx = 0

		for idx, info in ipairs(self.petListDatas) do
			if info.templateId == templateId then
				petIdx = idx

				break
			end
		end

		self:selectPet(petIdx - 1)
	end
end

function PetResearchDetailV2Ctrl:setResearchDetailVisible(visible)
	self.detailVisible = visible

	self:refreshUIVisible()
end

function PetResearchDetailV2Ctrl:refreshPetAlbum()
	self.petAlbum:refreshPhotoList()
end

function PetResearchDetailV2Ctrl:getUIVisible()
	if not self.detailVisible then
		return false
	end

	return UICtrl.getUIVisible(self)
end

function PetResearchDetailV2Ctrl:playEnterAction(cb)
	self:tryShowPet(self.view.listUList.selectedItem.templateId, function()
		self.view.windowsUWidget:SetActiveQuickly(true)

		if cb then
			cb()
		end

		if self.customBlackChange then
			self.customBlackChange = false

			UICtrl.blackClose(self)
		end
	end)
end

function PetResearchDetailV2Ctrl:onTabChange(name, pageIdx, lastPageIdx)
	if name == "Tab" and pageIdx ~= self.curTabIdx then
		self:onDeselectTab(lastPageIdx)

		self.curTabIdx = pageIdx

		self:refreshCurTab()

		if self.curTabIdx == self.model.TAB_IDX.SURVEY then
			self:refreshPanelResearchOpacity()
		end

		if self.curTabIdx ~= self.model.TAB_IDX.EVOLUTION and self.evolutionPage then
			self.evolutionPage:hideConsoleSelectList()
		end
	end
end

function PetResearchDetailV2Ctrl:refreshPanelResearchOpacity()
	local panelResearch = self.view.panelResearchUWidget
	local opacity = panelResearch.renderOpacity

	panelResearch.renderOpacity = opacity == 0 and 1 or 0
	panelResearch.renderOpacity = opacity
end

function PetResearchDetailV2Ctrl:initTitleList()
	self.petListDatas = PetResearchUtils.tryGetPetInfos(nil, nil, {
		PetResearchUtils.PET_STATE_IS_CATCH,
		PetResearchUtils.PET_STATE_IS_AllSTAR
	}, self.model.countryId, self.model.showTab)

	self.view.arrowUWidget:SetActiveFastest(#self.petListDatas > 7)
	self.view.listUList:SetList(self.petListDatas)

	local selectedIdx = 0
	local selectedTemplateId = self.model.curPetTemplateId

	if self.model.showTab == PetResearchUtils.PET_SHOW_TAB.FORM and self.formTargetTemplateId then
		selectedTemplateId = self.formTargetTemplateId
	end

	for idx, data in ipairs(self.petListDatas) do
		if data.templateId == selectedTemplateId then
			selectedIdx = idx - 1

			break
		end
	end

	self.view.listUList:SelectItem(selectedIdx or 0, false)
	self.view.listUList:GoToIndex(math.max(0, (selectedIdx or 0) - 4), true)
end

function PetResearchDetailV2Ctrl:openPetProgress()
	pg.global.ui.petResearchPetReward:open({
		templateId = self.model.curPetTemplateId
	})
end

function PetResearchDetailV2Ctrl:getSelectedPetInfo()
	local ret = {}
	local selectedData = self.view.listUList.selectedItem

	ret.templateId = selectedData.templateId

	local displayTemplateId = self.model.formPetTemplateId

	ret.name = pg.getLocalizationText(PetData[displayTemplateId].name)
	ret.elements = selectedData.elements
	ret.number = selectedData.displayNumber or PetResearchUtils.getResearchDisplayNumber(selectedData.templateId, self.model.countryId, self.model.showTab)

	local contentData = PetResearchContentData[displayTemplateId]

	if contentData then
		ret.desc = pg.getLocalizationText(contentData.desc)
	end

	return ret
end

function PetResearchDetailV2Ctrl:onShow()
	return
end

function PetResearchDetailV2Ctrl:onHide()
	return
end

function PetResearchDetailV2Ctrl:onVisibleChange(visible)
	pg.global.ui.petResearch:refreshBgmState()
end

function PetResearchDetailV2Ctrl:renderTitleIconList(button, idx, data)
	local objectReference = button:GetComponent("ObjectReference")
	local petIcon = objectReference:GetRefValue("iconUImage")
	local label = data.displayLabel == Const.PET_LABEL_MASK.SHINY and 1 or 0

	petIcon.url = LuaUIUtils.getPetIcon(data.iconName, LuaUIUtils.PET_ICON, label)

	button:TryChangePage("Flash", label)

	local redDotTreePath = string.format(RedDotConst.RedDotPath.PET_RESEARCH_PET_DETAIL_TITLE_ITEM, data.templateId)
	local baseTemplateId = self.model:getBasePetTemplateId(data.templateId)
	local rewardReddot = PetResearchUtils.checkHasTopicRewardByTemplateId(baseTemplateId)

	if rewardReddot then
		pg.global.setRedDot(redDotTreePath, button, true, RedDotConst.RedDotStyle.REWARD)
	else
		pg.global.setRedDot(redDotTreePath, button, false, RedDotConst.RedDotStyle.NONE)
	end
end

function PetResearchDetailV2Ctrl:tryShowPet(templateId, cb)
	self.model:setCurPetTemplateId(templateId, self.model.countryId)
	self.view.listUList:RefreshList()

	local baseInfo = self:getSelectedPetInfo()
	local label = self.model:getPriorityLabel()

	self:tryLockTab()

	local scenePageIdx = self.curTabIdx

	if scenePageIdx == self.model.TAB_IDX.EVOLUTION and not self.hasEvolve then
		scenePageIdx = self.model.TAB_IDX.SURVEY
	elseif scenePageIdx == self.model.TAB_IDX.ABILITY and not self.hasAbility then
		scenePageIdx = self.model.TAB_IDX.SURVEY
	end

	self.petScene:onSwitchPet(baseInfo.templateId, label, scenePageIdx, self.model.countryId)
	self:refreshCurTab(cb)

	if self.surveyForm then
		self.surveyForm:refreshFormTip()
	end

	if self:_getCanShowPanelResearch() then
		self.petProgress:setPetResearchPoint()
	end

	self:refreshRedDot()
end

function PetResearchDetailV2Ctrl:refreshTitlePetRedDot()
	for _, data in ipairs(self.petListDatas) do
		local hasReward = PetResearchUtils.checkHasTopicRewardByTemplateId(data.templateId)

		data.isShowRedDot = hasReward
		data.redDotTmpKey = hasReward and RedDotConst.RedDotStyle.REWARD or RedDotConst.RedDotStyle.NONE
	end

	pg.global.setPreViewRedDot(RedDotConst.RedDotPath.PET_RESEARCH_PET_DETAIL_TITLE_List, self.view.listUList, function()
		if PetResearchUtils.checkHasTopicReward(self.petListDatas) then
			return RedDotConst.RedDotStyle.REWARD
		end

		return RedDotConst.RedDotStyle.NONE
	end)
end

function PetResearchDetailV2Ctrl:onDeselectTab(pageIdx)
	if self.tabMap[pageIdx] then
		self.tabMap[pageIdx]:onDeselectThisTab()
	end
end

function PetResearchDetailV2Ctrl:refreshCurTab(cb)
	self:refreshConsoleBarState()

	local view = self.view

	if self.curTabIdx == self.model.TAB_IDX.SURVEY then
		if self.surveyPage then
			self.surveyPage:onSelectThisPage(cb)
		else
			view.tabDetailBookUWidget:LoadDefaultUrlManually(function(content)
				if self.view ~= view or not self:checkUIOpen() then
					return
				end

				self.surveyPage = PetSurveyPageComponent.new(self, content)

				self.surveyPage:onSelectThisPage(cb)
			end)
		end
	elseif self.curTabIdx == self.model.TAB_IDX.EVOLUTION then
		if self.hasEvolve then
			if self.evolutionPage then
				self.evolutionPage:onSelectThisPage()
			else
				view.tabDetailGeneUWidget:LoadDefaultUrlManually(function(content)
					if self.view ~= view or not self:checkUIOpen() then
						return
					end

					self.evolutionPage = PetEvolutionGraphComponent.new(self, content)

					self.evolutionPage:onSelectThisPage(cb)
				end)
			end
		else
			self:selectDefaultPage()
		end
	elseif self.curTabIdx == self.model.TAB_IDX.ABILITY then
		if self.hasAbility then
			if self.skillPage then
				self.skillPage:onSelectThisPage(cb)
			else
				view.tabDetailAbility:LoadDefaultUrlManually(function(content)
					if self.view ~= view or not self:checkUIOpen() then
						return
					end

					self.skillPage = PetSkillComponent.new(self, content)

					self.skillPage:onSelectThisPage(cb)
				end)
			end
		else
			self:selectDefaultPage()
		end
	elseif self.curTabIdx == self.model.TAB_IDX.TOPIC then
		if self.petTopic then
			self.petTopic:onSelectThisPage(cb)
		else
			view.tabDetailLocationUWidget:LoadDefaultUrlManually(function(content)
				if self.view ~= view or not self:checkUIOpen() then
					return
				end

				self.petTopic = PetTopicComponent.new(self, content)

				self.petTopic:onSelectThisPage(cb)
			end)
		end
	elseif self.curTabIdx == self.model.TAB_IDX.ALBUM then
		if self.petAlbum then
			self.petAlbum:onSelectThisPage(cb)
		else
			view.tabPhotoUWidget:LoadDefaultUrlManually(function(content)
				if self.view ~= view or not self:checkUIOpen() then
					return
				end

				self.petAlbum = PetAlbumComponent.new(self, content)

				self.petAlbum:onSelectThisPage(cb)
			end)
		end
	elseif self.curTabIdx == self.model.TAB_IDX.FORM then
		view.tabFormPageUContainer:LoadDefaultUrlManually(function(content)
			if self.view ~= view or not self:checkUIOpen() then
				return
			end

			self.formPage = PetFormComponent.new(self, content)

			self.formPage:onSelectThisPage(cb)
		end)
	end
end

function PetResearchDetailV2Ctrl:setPageTitle(title)
	ClientTextUtils.setText(self.view.tMPUSDFText, pg.getGameString(title))
end

function PetResearchDetailV2Ctrl:tryLockTab()
	self.hasAbility = self:checkHasAbilityData(self.model.curPetTemplateId)
	self.hasEvolve = self:checkHasEvolveData(self.model.curPetTemplateId)
	self.view.btnAbilityUButton.visualInteractable = self.hasAbility
	self.view.btnGeneUButton.visualInteractable = self.hasEvolve
end

function PetResearchDetailV2Ctrl:checkHasAbilityData(templateId)
	templateId = Utils.getBasePetPrototypeId(templateId)

	local skillDatas = PetSkillData[templateId]

	if not skillDatas then
		return false
	end

	for _, info in pairs(skillDatas) do
		if info.showInManual then
			return true
		end
	end

	return false
end

function PetResearchDetailV2Ctrl:checkHasEvolveData(templateId)
	local evolveData = PetEvolveData[templateId]

	if not evolveData then
		return false
	end

	if evolveData[1].individual == 1 then
		return false
	end

	return true
end

function PetResearchDetailV2Ctrl:selectDefaultPage()
	self.view.btnResearchUButton:OnClickSimulate()
end

function PetResearchDetailV2Ctrl:showFormTip()
	if self.surveyForm then
		self.surveyForm:showFormTip()
	else
		self.view.tabSurveyFormUContainer:LoadDefaultUrlManually(function(content)
			self.surveyForm = PetSurveyFormComponent.new(self, content)

			self.surveyForm:showFormTip()
		end)
	end
end

function PetResearchDetailV2Ctrl:restorePageTimeLine()
	if self.curTabIdx == self.model.TAB_IDX.EVOLUTION then
		-- block empty
	elseif self.curTabIdx == self.model.TAB_IDX.SURVEY then
		self.surveyPage:switchTraitNodeVisible(true)
	elseif self.curTabIdx == self.model.TAB_IDX.ABILITY then
		-- block empty
	end
end

function PetResearchDetailV2Ctrl:playSceneTimeline(tid, callback)
	self.petScene:trySwitchView(tid, callback)
end

function PetResearchDetailV2Ctrl:setPageResearchPoint(cur, sum)
	ClientTextUtils.setText(self.view.researchPointPageUText, string.format("%s/%s", cur, sum))
end

function PetResearchDetailV2Ctrl:initGamepadNav()
	self:initMainFocus()
	self:initGamepadTab()
	LuaUIUtils.bindHotKey(self.view.transform.gameObject, HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadLB, function()
		local index = self.view.listUList.selectedIndex - 1

		self:selectPet(index)
	end)
	LuaUIUtils.bindHotKey(self.view.transform.gameObject, HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadRB, function()
		local index = self.view.listUList.selectedIndex + 1

		self:selectPet(index)
	end)
	LuaUIUtils.bindHotKey(self.view.transform.gameObject, HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadDUp, function()
		self.tabCurNavIndex = math.clamp(self.tabCurNavIndex - 1, 1, #self.tabList)

		self:selectTab()
	end)
	LuaUIUtils.bindHotKey(self.view.transform.gameObject, HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadDDown, function()
		self.tabCurNavIndex = math.clamp(self.tabCurNavIndex + 1, 1, #self.tabList)

		self:selectTab()
	end)
	LuaUIUtils.bindHotKey(self.view.transform.gameObject, HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadRS, function()
		self.view.panelResearchUWidget:OnClickSimulate()
	end)
end

function PetResearchDetailV2Ctrl:selectPet(index)
	if index < 0 then
		index = self.view.listUList.itemCount - 1
	elseif index >= self.view.listUList.itemCount then
		index = 0
	end

	self.view.listUList:GoToIndex(index)
	self.view.listUList:SelectItem(index)
end

function PetResearchDetailV2Ctrl:initGamepadTab()
	self.tabList = {
		self.view.btnResearchUButton,
		self.view.btnAbilityUButton,
		self.view.btnGeneUButton,
		self.view.btnBarChartUButton
	}
	self.tabCurNavIndex = 1
end

function PetResearchDetailV2Ctrl:selectTab()
	self.tabList[self.tabCurNavIndex]:CheckPressController()

	if self.tabList[self.tabCurNavIndex].luaClick then
		self.tabList[self.tabCurNavIndex]:OnClickSimulate()
	end

	if self.curTabIdx ~= self.model.TAB_IDX.EVOLUTION then
		-- block empty
	end
end

function PetResearchDetailV2Ctrl:initMainFocus()
	self.navigation = GamePadNavigation.new(self)
	self.navigation.AREAS = {
		PET_INFO_RIGHT = 2,
		PET_INFO_LEFT = 1,
		PET_TOPIC = 8,
		PET_SKILL = 7,
		PET_MOVE = 6,
		PET_EXPLORE = 5,
		PET_TRAIT = 4,
		PET_EVOLUTION = 3
	}
	self.navigation.PET_INFO_LEFT = {
		index = self.navigation.AREAS.PET_INFO_LEFT,
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.PET_INFO_LEFT,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.PET_INFO_LEFT,
		[self.navigation.MOVE_DIRECTION.LEFT] = self.navigation.AREAS.PET_INFO_LEFT,
		[self.navigation.MOVE_DIRECTION.RIGHT] = self.navigation.AREAS.PET_INFO_RIGHT,
		matchType = self.navigation.MATCH_MODE.MATCH_DIRECTION
	}
	self.navigation.PET_INFO_RIGHT = {
		index = self.navigation.AREAS.PET_INFO_RIGHT,
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.PET_INFO_RIGHT,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.PET_INFO_RIGHT,
		[self.navigation.MOVE_DIRECTION.LEFT] = self.navigation.AREAS.PET_INFO_LEFT,
		[self.navigation.MOVE_DIRECTION.RIGHT] = self.navigation.AREAS.PET_INFO_RIGHT,
		matchType = self.navigation.MATCH_MODE.MATCH_DIRECTION
	}
	self.navigation.PET_EVOLUTION = {
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.PET_EVOLUTION,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.PET_EVOLUTION,
		[self.navigation.MOVE_DIRECTION.LEFT] = self.navigation.AREAS.PET_EVOLUTION,
		[self.navigation.MOVE_DIRECTION.RIGHT] = self.navigation.AREAS.PET_EVOLUTION
	}
	self.navigation.PET_TRAIT = {
		index = self.navigation.AREAS.PET_TRAIT,
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.PET_TRAIT,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.PET_TRAIT,
		[self.navigation.MOVE_DIRECTION.LEFT] = self.navigation.AREAS.PET_TRAIT,
		[self.navigation.MOVE_DIRECTION.RIGHT] = self.navigation.AREAS.PET_EXPLORE
	}
	self.navigation.PET_TOPIC = {
		index = self.navigation.AREAS.PET_TOPIC,
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.PET_TOPIC,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.PET_TOPIC
	}
	self.navigation.PET_EXPLORE = {
		index = self.navigation.AREAS.PET_EXPLORE,
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.PET_EXPLORE,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.PET_MOVE,
		[self.navigation.MOVE_DIRECTION.LEFT] = self.navigation.AREAS.PET_TRAIT,
		[self.navigation.MOVE_DIRECTION.RIGHT] = self.navigation.AREAS.PET_SKILL
	}
	self.navigation.PET_MOVE = {
		index = self.navigation.AREAS.PET_MOVE,
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.PET_EXPLORE,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.PET_MOVE,
		[self.navigation.MOVE_DIRECTION.LEFT] = self.navigation.AREAS.PET_TRAIT,
		[self.navigation.MOVE_DIRECTION.RIGHT] = self.navigation.AREAS.PET_SKILL
	}
	self.navigation.PET_SKILL = {
		index = self.navigation.AREAS.PET_SKILL,
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.PET_SKILL,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.PET_MOVE,
		[self.navigation.MOVE_DIRECTION.LEFT] = self.navigation.AREAS.PET_EXPLORE,
		[self.navigation.MOVE_DIRECTION.RIGHT] = self.navigation.AREAS.PET_SKILL
	}
	self.navigation.AREA_TABLES = {
		self.navigation.PET_INFO_LEFT,
		self.navigation.PET_INFO_RIGHT,
		self.navigation.PET_EVOLUTION,
		self.navigation.PET_TRAIT,
		self.navigation.PET_EXPLORE,
		self.navigation.PET_MOVE,
		self.navigation.PET_SKILL,
		self.navigation.PET_TOPIC
	}
end

local function traitNodeSort(a, b)
	return a.transform.anchoredPosition.y > b.transform.anchoredPosition.y
end

function PetResearchDetailV2Ctrl:setMainFocusNav(traitItemNodes)
	local leftNode = {}
	local rightNode = {}

	for _, item in ipairs(traitItemNodes) do
		if item.transform.anchoredPosition.x < 0 then
			table.insert(leftNode, item)
		else
			table.insert(rightNode, item)
		end
	end

	table.sort(leftNode, traitNodeSort)
	table.sort(rightNode, traitNodeSort)

	local navMapLeft = {}

	for x, item in ipairs(leftNode) do
		if navMapLeft[x] == nil then
			navMapLeft[x] = {}
		end

		navMapLeft[x][1] = {}

		local element = self:getCurActiveEle(item)

		navMapLeft[x][1].DisFocus = function()
			self:petInfoDisFocus(element)
		end
		navMapLeft[x][1].element = element
	end

	local navMapRight = {}

	for x, item in ipairs(rightNode) do
		if navMapRight[x] == nil then
			navMapRight[x] = {}
		end

		navMapRight[x][1] = {}

		local element = self:getCurActiveEle(item)

		navMapRight[x][1].DisFocus = function()
			self:petInfoDisFocus(element)
		end
		navMapRight[x][1].element = element
	end
end

function PetResearchDetailV2Ctrl:petInfoDisFocus(element)
	if element.DoUnHover then
		element:DoUnHover()
	else
		element:TryChangePage("button", 0)
	end

	self.navigation:setButtonFocus(element, 0)
end

function PetResearchDetailV2Ctrl:setPetInfoArea(area, navMap)
	self.navigation:setCustomArea(area, navMap, self.view.bottomKeyListUList, function(item)
		local objectReference = item.element:GetComponent("ObjectReference")

		if objectReference:GetRefValue("detailUButton") then
			local detailBtn = objectReference:GetRefValue("detailUButton")

			if detailBtn.luaClick then
				detailBtn:OnClickSimulate()
			end
		end

		if item.element.luaClick then
			item.element:OnClickSimulate()
		end
	end, function(item)
		self:dismiss()
	end, pg.getGameString("CHECK_OUT"))
end

function PetResearchDetailV2Ctrl:getCurActiveEle(parent)
	local lock = parent.transform:Find("Lock")

	if lock and lock.gameObject.activeSelf then
		return lock:GetComponent("UButton")
	end

	local skeletonUnlock = parent.transform:Find("SkeletonUnlock")

	if skeletonUnlock and skeletonUnlock.gameObject.activeSelf then
		return skeletonUnlock:GetComponent("UButton")
	end
end

function PetResearchDetailV2Ctrl:setAbilityTraitNav(uList, data)
	self.navigation:setListArea(self.navigation.PET_TRAIT, uList, data, self.view.bottomKeyListUList, function(uList, curIndex, data)
		local _, button = uList:TryGetChildAt(curIndex - 1)

		if button then
			button:OnClickSimulate()
		end
	end, function(uList, curIndex)
		self:dismiss()
	end, true, pg.getGameString("CHECK_OUT"))
end

function PetResearchDetailV2Ctrl:setTopicNav(uList, data)
	local navMap = {}

	for index, value in ipairs(data) do
		local y = 1

		if navMap[index] == nil then
			navMap[index] = {}
		end

		navMap[index][y] = {
			rewardId = data.rewardId
		}
		navMap[index][y].Fun6 = function()
			return
		end
		navMap[index][y].Fun6Name = pg.getGameString("CHECK_OUT")
	end

	self.navigation:setListArea(self.navigation.PET_TOPIC, uList, data, self.view.bottomKeyListUList, function(uList, curIndex, data)
		if pg.global.ui.commonItemTip:checkUIOpen() then
			pg.global.ui.commonItemTip:close()

			return
		end

		local ret, button = uList:TryGetChildAt(curIndex - 1)

		if ret then
			local objectReference = button:GetComponent("ObjectReference")
			local curProgressInfo = data.curProgressInfo

			if curProgressInfo.rewardId then
				local rewardItemUButton = objectReference:GetRefValue("rewardItemUButton")

				rewardItemUButton:OnClickSimulate()
			end
		end
	end, function(uList, curIndex)
		self:dismiss()
	end, false, pg.getGameString("CHECK_OUT"))
end

function PetResearchDetailV2Ctrl:setAbilityExploreNav(uList, data)
	self.navigation:setListArea(self.navigation.PET_EXPLORE, uList, data, self.view.bottomKeyListUList, function(uList, curIndex, data)
		local _, button = uList:TryGetChildAt(curIndex - 1)

		if not button.isTooltipOpen then
			button:OpenTooltip()
		end
	end, function(uList, curIndex)
		self:dismiss()
	end, true, pg.getGameString("CHECK_OUT"))
end

function PetResearchDetailV2Ctrl:setAbilityMoveNav(uList, data)
	self.navigation:setListArea(self.navigation.PET_MOVE, uList, data, self.view.bottomKeyListUList, function(uList, curIndex, data)
		local _, button = uList:TryGetChildAt(curIndex - 1)

		if not button.isTooltipOpen then
			button:OpenTooltip()
		end
	end, function(uList, curIndex)
		self:dismiss()
	end, false, pg.getGameString("CHECK_OUT"))
end

function PetResearchDetailV2Ctrl:setAbilitySkillNav(uList, data)
	local navMap = {}

	for index, value in ipairs(data) do
		local x = math.floor((index + 2) / 3)
		local y = (index + 2) % 3 + 1

		if navMap[x] == nil then
			navMap[x] = {}
		end

		navMap[x][y] = {}
	end

	self.navigation:setListArea(self.navigation.PET_SKILL, uList, data, self.view.bottomKeyListUList, function(uList, curIndex, data)
		local _, button = uList:TryGetChildAt(curIndex - 1)

		if data.unLock and not button.isTooltipOpen then
			button:OpenTooltip()
		end
	end, function(uList, curIndex)
		self:dismiss()
	end, false, pg.getGameString("CHECK_OUT"), navMap)
end

function PetResearchDetailV2Ctrl:refreshAbilityNav(hasExplore)
	self.navigation.PET_TRAIT[self.navigation.MOVE_DIRECTION.RIGHT] = hasExplore and self.navigation.AREAS.PET_EXPLORE or self.navigation.AREAS.PET_MOVE
	self.navigation.PET_MOVE[self.navigation.MOVE_DIRECTION.UP] = hasExplore and self.navigation.AREAS.PET_EXPLORE or self.navigation.AREAS.PET_SKILL
	self.navigation.PET_SKILL[self.navigation.MOVE_DIRECTION.LEFT] = hasExplore and self.navigation.AREAS.PET_EXPLORE or self.navigation.AREAS.PET_MOVE
end

function PetResearchDetailV2Ctrl:setEvolutionFocusNav()
	return
end

function PetResearchDetailV2Ctrl:onInputDeviceChanged(deviceType)
	return
end

function PetResearchDetailV2Ctrl:gamepadFocusDefault()
	if not pg.game.input:isUsingGamepad() then
		return
	end

	if self.curTabIdx == self.model.TAB_IDX.EVOLUTION then
		if self.navigation.PET_EVOLUTION == nil or self.navigation.PET_EVOLUTION[1] == nil then
			return
		end

		self.navigation:specificSet(self.navigation.AREAS.PET_EVOLUTION, 1, #self.navigation.PET_EVOLUTION[1])
		self.navigation:reFocus()
	elseif self.curTabIdx == self.model.TAB_IDX.ABILITY then
		self.navigation:specificSet(self.navigation.AREAS.PET_TRAIT, 1, 1)
		self.navigation:reFocus()
	elseif self.curTabIdx == self.model.TAB_IDX.TOPIC then
		self.navigation:specificSet(self.navigation.AREAS.PET_TOPIC, 1, 1)
		self.navigation:reFocus()
	else
		self.navigation:specificSet(self.navigation.AREAS.PET_INFO_LEFT, 1, 1)
		self.navigation:reFocus()
		self:startTimer(function()
			if self.focusDefault then
				self.focusDefault:TryChangePage("button", 3)
				self.focusDefault:TryChangePage("GamePadFocus", 1)

				local console = self.focusDefault.transform:Find("ConsoleSelected")

				if console then
					console:GetComponent("UComponent"):TryChangePage("GamePadFocus", 1)
				end
			end
		end, 2)
	end
end

function PetResearchDetailV2Ctrl:getSkillItemById(abParm, researchPoint)
	local item = {
		icon = LuaUIUtils.getSkillIcon(abParm.icon),
		point = researchPoint or 0,
		desc = LuaUIUtils.getSkillDesc(abParm),
		elementType = abParm.elementType,
		name = abParm.name,
		epCost = abParm.epCost,
		power = abParm.power,
		attackType = abParm.attackType
	}

	if abParm.tags then
		local tagList = {}

		for _, tagId in pairs(abParm.tags) do
			tagList[#tagList + 1] = {
				tagName = SkillTagData[tagId].tagName
			}
		end

		item.tagList = tagList
	end

	return item
end

function PetResearchDetailV2Ctrl:setSkillAttrList(button, idx, data)
	local name = button:Find("TxtName"):GetComponent("UBaseText")
	local num = button:Find("Num"):GetComponent("UBaseText")

	if data.attrType == 0 then
		ClientTextUtils.setText(name, pg.getGameString(data.name))
		ClientTextUtils.setText(num, data.num)
		LuaUIUtils.setUIViewVisible(num, true)
		button:TryChangePage("IconType", data.iconIdx)
	elseif data.attrType == 1 then
		ClientTextUtils.setText(name, pg.getLocalizationText(data.name))
		LuaUIUtils.setUIViewVisible(num, false)
	end
end

function PetResearchDetailV2Ctrl:renderSkillBtn(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconSkillUImage = objectReference:GetRefValue("iconSkillUImage")
	local elementUButton = objectReference:GetRefValue("elementUButton")

	iconSkillUImage.url = data.icon

	LuaUIUtils.setElementButtonNew(elementUButton, data.elementType)

	button.enabledTooltip = true

	LuaUIUtils.setRenderSKillTooTip(button, data)

	if data.isRare then
		button:TryChangePage("IsRare", 1)
	else
		button:TryChangePage("IsRare", 0)
	end
end

function PetResearchDetailV2Ctrl:setPetFormAppearance(formTemplateId, label, shinyStyleId)
	shinyStyleId = label == Const.PET_LABEL_MASK.SHINY and (shinyStyleId or 0) or 0
	self.model.formPetTemplateId = formTemplateId
	self.model.formPetLabel = label
	self.model.formPetShinyStyle = shinyStyleId

	self.petScene:setMainEntForm(formTemplateId, label, shinyStyleId)
end

function PetResearchDetailV2Ctrl:isShinyStyleOwned(formTemplateId, shinyStyleId)
	local handbookInfo = pg.me.petHandbookMap:getInfo(formTemplateId)

	return handbookInfo ~= nil and Utils.hasShinyCollectStyle(handbookInfo.shinyCollectMask, shinyStyleId)
end

function PetResearchDetailV2Ctrl:onPetDisplayChanged(info)
	if info.countryId ~= self.model.countryId then
		return
	end

	if self.curTabIdx == self.model.TAB_IDX.FORM then
		if self.formPage then
			self.formPage:refreshApplyBtn()
		end
	elseif self.curTabIdx == self.model.TAB_IDX.SURVEY and self.surveyForm then
		self.surveyForm:refreshApplyBtn()
	end

	local templateId = info.templateId
	local formTemplateId = info.formTemplateId
	local label = info.label
	local shinyStyle = info.shinyStyle or 0

	for idx, data in pairs(self.petListDatas) do
		if data.templateId == templateId then
			local newData = {}

			newData.displayLabel = label
			newData.displayShinyStyle = shinyStyle
			newData.templateId = templateId
			newData.countryId = info.countryId

			local pData = PetProtoTypeData[formTemplateId]

			newData.iconName = pData.iconName
			newData.selected = data.selected
			newData.number = data.number
			newData.displayNumber = data.displayNumber

			self.view.listUList:SetElement(idx - 1, newData)
			self.view.listUList:SelectItem(idx - 1)

			break
		end
	end
end

function PetResearchDetailV2Ctrl:onPetLabelDisplayChanged(info)
	if info.countryId ~= self.model.countryId then
		return
	end

	if self.curTabIdx == self.model.TAB_IDX.FORM then
		if self.formPage then
			self.formPage:refreshApplyBtn()
		end
	elseif self.curTabIdx == self.model.TAB_IDX.SURVEY and self.surveyForm then
		self.surveyForm:refreshApplyBtn()
	end

	local formTemplateId = info.formTemplateId
	local label = info.label
	local shinyStyle = info.shinyStyle or 0

	for idx, data in pairs(self.petListDatas) do
		if data.templateId == formTemplateId then
			local newData = {}

			newData.displayLabel = label
			newData.displayShinyStyle = shinyStyle
			newData.templateId = formTemplateId
			newData.countryId = info.countryId

			local pData = PetProtoTypeData[formTemplateId]

			newData.iconName = pData.iconName
			newData.selected = data.selected
			newData.number = data.number
			newData.displayNumber = data.displayNumber

			self.view.listUList:SetElement(idx - 1, newData)
			self.view.listUList:SelectItem(idx - 1)

			break
		end
	end
end

function PetResearchDetailV2Ctrl:applyForm(formTemplateId, labelId, shinyStyleId)
	shinyStyleId = labelId == Const.PET_LABEL_MASK.SHINY and (shinyStyleId or 0) or 0

	local tipTime = pg.global.prefsCacheUtils:getInt("applyFormTip", 0, ClientConst.CACHE_TYPE_FLAG.USER)
	local isSpecies = self.model.showTab == PetResearchUtils.PET_SHOW_TAB.SPECIES

	if tipTime == 0 or os.time() - tipTime > 604800 then
		pg.global.showConfirmMsgRaw(nil, pg.getFormatText(pg.getGameString("SET_FIRST_PAGE"), pg.getLocalizationText(PetData[formTemplateId].name)), function()
			if isSpecies then
				pg.me:changeDisplayPetForm(self.model.curPetTemplateId, self.model.countryId, formTemplateId, labelId, shinyStyleId)
			else
				pg.me:changeDisplayPetLabel(formTemplateId, self.model.countryId, labelId, shinyStyleId)
			end
		end, false, nil, false, nil, {
			hint = true,
			hintCb = function(isSelect)
				if isSelect then
					pg.global.prefsCacheUtils:setInt("applyFormTip", os.time(), ClientConst.CACHE_TYPE_FLAG.USER)
				else
					pg.global.prefsCacheUtils:setInt("applyFormTip", 0, ClientConst.CACHE_TYPE_FLAG.USER)
				end
			end,
			hintDesc = pg.getGameString("SHUTDOWN_ATTENTION")
		})
	elseif isSpecies then
		pg.me:changeDisplayPetForm(self.model.curPetTemplateId, self.model.countryId, formTemplateId, labelId, shinyStyleId)
	else
		pg.me:changeDisplayPetLabel(formTemplateId, self.model.countryId, labelId, shinyStyleId)
	end
end

function PetResearchDetailV2Ctrl:refreshApplyBtn()
	return
end

function PetResearchDetailV2Ctrl:getLabelDatas(templateId)
	local ret = {}
	local formPetTemplateId = templateId or self.model.formPetTemplateId
	local petAvatarData = PetAvatarData[formPetTemplateId] or {}

	for labelId, info in pairs(petAvatarData) do
		if labelId == Const.PET_LABEL_MASK.SHINY then
			self:_setShinyStyleData(info, ret, formPetTemplateId)
		else
			ret[#ret + 1] = self:_getNormalLabelData(info, labelId, formPetTemplateId)
		end
	end

	return ret
end

function PetResearchDetailV2Ctrl:_getNormalLabelData(info, labelId, formPetTemplateId)
	local labelItem = {}

	labelItem.name = PetFormTextData[labelId].name
	labelItem.icon = PetFormTextData[labelId].icon
	labelItem.labelId = labelId
	labelItem.shinyStyleId = 0

	if labelId == self.model.formPetLabel then
		labelItem.selected = true
	end

	local dropId = info.reward
	local point = PetResearchUtils.getRewardResearchPoint(dropId or 0)

	labelItem.point = point
	labelItem.templateId = formPetTemplateId

	return labelItem
end

function PetResearchDetailV2Ctrl:_setShinyStyleData(info, ret, formPetTemplateId)
	for i = 1, 12 do
		local shinyId = info["shinyStyle" .. i]

		if shinyId and PetShinyStyleData[shinyId] then
			local shinyData = PetShinyStyleData[shinyId]
			local labelItem = {}

			labelItem.icon = shinyData.iconResearchBook
			labelItem.name = shinyData.name
			labelItem.shinyStyleId = shinyId
			labelItem.isRare = shinyData.isRare
			labelItem.templateId = formPetTemplateId
			labelItem.selected = self.model.formPetLabel == Const.PET_LABEL_MASK.SHINY and self.model.formPetShinyStyle == shinyId
			labelItem.point = 0
			labelItem.labelId = Const.PET_LABEL_MASK.SHINY
			ret[#ret + 1] = labelItem
		end
	end
end

function PetResearchDetailV2Ctrl:closePanel()
	if self.surveyForm and self.surveyForm.isShow then
		self.surveyForm:hideSurveyTip()
	else
		self:close()
	end
end

function PetResearchDetailV2Ctrl:refreshRedDot()
	pg.global.setPreViewRedDot(RedDotConst.RedDotPath.PET_RESEARCH_TOPIC, self.view.btnBarChartUButton, function()
		local topicCanGet = PetResearchUtils.checkHasTopicRewardByTemplateId(self.model.curPetTemplateId)

		if topicCanGet then
			return RedDotConst.RedDotStyle.REWARD
		else
			return RedDotConst.RedDotStyle.NONE
		end
	end)
	self:refreshTitlePetRedDot()
	self.view.listUList:RefreshList()
end

return PetResearchDetailV2Ctrl
