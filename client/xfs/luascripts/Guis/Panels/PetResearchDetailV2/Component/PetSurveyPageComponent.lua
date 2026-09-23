-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetResearchDetailV2\\Component\\PetSurveyPageComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Lume = require("Core.Common.lume")
local PetTraitData = require("Data.pet_trait_data")
local UIUtils = UIUtils
local HotkeyConst = require("Const.HotkeyConst")
local sort = table.sort
local Const = require("Const.Const")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local AbilityParamData = require("Data.ability_param_data")
local PetAvatarData = require("Data.pet_avatar_data")
local ItemSourceData = require("Data.item_source_data")
local PetFormTextData = require("Data.pet_form_text_data")
local PetFeatureData = require("Data.pet_character_data")
local PetConfigData = require("Data.pet_config_data")
local PetResearchResultData = require("Data.pet_research_result_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local Mathf = require("Common.Math.Mathf")
local PetData = require("Data.pet_data")
local PetSurveyPageComponent = Class.LightClass("PetSurveyPageComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local LABEL_STYLE_TYPE_1 = 1
local LABEL_STYLE_TYPE_2 = 2
local LABEL_STYLE_TYPE_3 = 3
local FORM_UNLOCK_ID = 0
local FORM_LOCK_ID = 1
local TraitType_2_Page_idx = {
	3,
	3,
	2
}

function PetSurveyPageComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.txtNameUText = self.objectReference:GetRefValue("txtNameUText")
	self.listElementUList = self.objectReference:GetRefValue("listElementUList")
	self.numUText = self.objectReference:GetRefValue("numUText")
	self.txtDetailUText = self.objectReference:GetRefValue("txtDetailUText")
	self.prePos1 = self.objectReference:GetRefValue("prePos1")
	self.prePos2 = self.objectReference:GetRefValue("prePos2")
	self.prePos3 = self.objectReference:GetRefValue("prePos3")
	self.prePos4 = self.objectReference:GetRefValue("prePos4")
	self.prePos5 = self.objectReference:GetRefValue("prePos5")
	self.prePos6 = self.objectReference:GetRefValue("prePos6")
	self.prePos7 = self.objectReference:GetRefValue("prePos7")
	self.prePos8 = self.objectReference:GetRefValue("prePos8")
	self.traitItem1 = self.objectReference:GetRefValue("traitItem1")
	self.traitItem2 = self.objectReference:GetRefValue("traitItem2")
	self.traitItem3 = self.objectReference:GetRefValue("traitItem3")
	self.traitItem4 = self.objectReference:GetRefValue("traitItem4")
	self.traitItem5 = self.objectReference:GetRefValue("traitItem5")
	self.traitItem6 = self.objectReference:GetRefValue("traitItem6")
	self.traitItem7 = self.objectReference:GetRefValue("traitItem7")
	self.traitItem8 = self.objectReference:GetRefValue("traitItem8")
	self.labelRoot = self.objectReference:GetRefValue("labelRootUWidget")
	self.formName = self.objectReference:GetRefValue("formName")
	self.formBtnUButton = self.objectReference:GetRefValue("formBtnUButton")
	self.formWidget = self.objectReference:GetRefValue("formWidget")
	self.formTxtName = self.objectReference:GetRefValue("formTxtName")
	self.qualityUButton = self.objectReference:GetRefValue("qualityUButton")
	self.formIconUImage = self.objectReference:GetRefValue("formIconUImage")
	self.widgetIconUImage = self.objectReference:GetRefValue("widgetIconUImage")
	self.dragRotationDragUpdateListener = self.objectReference:GetRefValue("buttonDragUpdateListener")
end

function PetSurveyPageComponent:getPetLabelByFormSelect(templateId)
	if templateId == self.templateId then
		return self.curFormIdx
	end
end

function PetSurveyPageComponent:initView()
	self.lineVisible = true

	function self.listElementUList.luaRenderItem(button, idx, data)
		LuaUIUtils.setElementButtonNew(button, data.element)
	end

	self.tabIdx = self.model.TAB_IDX.SURVEY
	self.ctrl.tabMap[self.tabIdx] = self

	function self.formBtnUButton.luaClick()
		self.ctrl:showFormTip()
	end

	self.traitItemNodes = {}
	self.traitTimers = {}
	self.screenWidthHalf = Screen.width * 0.5
	self.screenHeightHalf = Screen.height * 0.5

	self:setSurveyDragEnabled(false)
	self:initSurveyDragRotation()
end

function PetSurveyPageComponent:initSurveyDragRotation()
	if not self.dragRotationDragUpdateListener then
		return
	end

	function self.dragRotationDragUpdateListener.luaDragUpdate(x, y)
		if not self.surveyDragEnabled or self.isPlayingSurveyAction then
			return
		end

		if not self.isSurveyRotating then
			self.isSurveyRotating = true

			self:visibleAllLineOnRotation(false)
		end

		self.ctrl.petScene:rotateSurveyPet(x)
	end

	function self.dragRotationDragUpdateListener.luaEndDrag()
		if self.isPlayingSurveyAction then
			return
		end

		self.isSurveyRotating = false

		self:lineToSkeleton()
		self:visibleAllLineOnRotation(true)
	end
end

function PetSurveyPageComponent:setSurveyDragEnabled(enabled)
	self.surveyDragEnabled = enabled

	if not enabled then
		self.isSurveyRotating = false
	end
end

function PetSurveyPageComponent:switchLabelVisible(visible)
	if not visible then
		self.labelRoot:SetActiveFastest(false)

		return
	end

	self.labelRoot:SetActiveFastest(true)

	if self.templateId ~= self.model.curPetTemplateId then
		self.templateId = self.model.curPetTemplateId

		local baseInfo = self.ctrl:getSelectedPetInfo()

		self:setPetBaseInfo(baseInfo)
		self:clearShowTraitTimer()
		self:clearAllTraitTimer()
		self:hideAllTraitLabel()
	elseif not self.inSequence then
		self:visibleAllLineOnRotation(true)
	end

	self:refreshTraitLabel()
end

function PetSurveyPageComponent:onSelectThisPage(cb)
	self.ctrl.petScene:clearPetPageAction()
	self.ctrl:setPageTitle("TITLE_SURVEY")

	self.isSelectedPage = true
	self.isPlayingSurveyAction = false

	self:setSurveyDragEnabled(false)
	self:switchLabelVisible(false)
	self.ctrl.petScene:trySwitchView(self.model.TAB_IDX.SURVEY, function()
		if cb then
			cb()
		end

		self:switchLabelVisible(true)
	end)
	self.ctrl.petScene:playPetPageAction(self.model.curPetTemplateId, self.model.TAB_IDX.SURVEY, function()
		self:lineToSkeleton()
		self:visibleLineInPlayable(true)
		self:setSurveyDragEnabled(self.isSelectedPage)
	end)
end

function PetSurveyPageComponent:refreshFormName()
	ClientTextUtils.setText(self.formName, LuaUIUtils.getPetFormNameByPrototypeId(self.model.formPetTemplateId))
	ClientTextUtils.setText(self.formTxtName, LuaUIUtils.getPetFormNameByPrototypeId(self.model.formPetTemplateId))

	local iconUrl = PetResearchUtils.getPetFormIconSmall(self.model.formPetTemplateId)

	if iconUrl then
		self.formIconUImage.url = iconUrl
		self.widgetIconUImage.url = iconUrl
	end
end

function PetSurveyPageComponent:onDeselectThisTab()
	self.isSelectedPage = false
	self.isPlayingSurveyAction = false

	self:setSurveyDragEnabled(false)
	self.ctrl.petScene:clearPetPageAction()

	if self.ctrl.surveyForm then
		self.ctrl.surveyForm:hideSurveyTip()
	end
end

function PetSurveyPageComponent:refreshPageResearchPoint()
	return
end

function PetSurveyPageComponent:renderFormList(button, idx, data)
	local objectReference = button:GetComponent("ObjectReference")
	local textUText = objectReference:GetRefValue("textUText")

	ClientTextUtils.setText(textUText, data.formName)
	button:TryChangePage("Type", data.type)
	button:TryChangePage("Searching", data.searchState)

	button.enabledTooltip = data.searchState ~= FORM_UNLOCK_ID

	function button.luaRenderTooltip(button, component)
		local title = component:Find("TxtTitle"):GetComponent("UBaseText")
		local desc = component:Find("TxtName"):GetComponent("UBaseText")

		ClientTextUtils.setText(title, pg.getGameString("SHINY"))
		ClientTextUtils.setText(desc, pg.getLocalizationText(PetResearchResultData.avatar.unlockTips))
	end

	function button.luaSelectChanged(isSelected)
		if not button.enabledTooltip or isSelected then
			-- block empty
		else
			button:ClosePopup()
		end

		button:TryChangePage("GamePadFocus", isSelected and 1 or 0)
	end

	function button.luaClick()
		if button.enabledTooltip then
			button:OpenTooltip()
		end
	end
end

function PetSurveyPageComponent:setPetBaseInfo(baseInfo)
	ClientTextUtils.setText(self.txtNameUText, baseInfo.name)

	local elements = PetResearchUtils.getElementsInfo(self.model.formPetTemplateId)

	self.listElementUList:SetList(elements)
	ClientTextUtils.setText(self.numUText, baseInfo.number)
	ClientTextUtils.setText(self.txtDetailUText, baseInfo.desc)
	PetResearchUtils.setEvolveQuality(self.qualityUButton, self.templateId)
	self:refreshFormName()
end

function PetSurveyPageComponent:onDestroy()
	self.isSelectedPage = false
	self.isPlayingSurveyAction = false

	if self.dragRotationDragUpdateListener then
		self.dragRotationDragUpdateListener.luaDragUpdate = nil
		self.dragRotationDragUpdateListener.luaEndDrag = nil
	end

	self:clearDelayShowTimer()
	self:clearShowTraitTimer()
	self:clearAllTraitTimer()
	UIComponent.onDestroy(self)
end

function PetSurveyPageComponent:refreshTraitLabel()
	self:hideAllTraitLabel()

	local handbookInfo = pg.me.petHandbookMap:getInfo(self.model.baseTemplateId)

	self.traitDatas = self:getPetTraitData(handbookInfo)

	self:clearDelayShowTimer()
	self:clearShowTraitTimer()

	self.traitItemNodes = {}
	self.inSequence = true

	self:refreshPageResearchPoint()

	self.delayShowTimer = self.ctrl:startTimer(function()
		for idx, data in ipairs(self.traitDatas) do
			self:setTraitLabel(data)
		end

		self:showTraitLabelSequence(1)
	end, 0.3)
end

function PetSurveyPageComponent:lineToSkeleton()
	for idx, traitData in ipairs(self.traitDatas) do
		local labelIdx = traitData.positionDefault

		if labelIdx then
			local labelNode = self["traitItem" .. labelIdx]

			if traitData.type == LABEL_STYLE_TYPE_1 then
				if traitData.unlock then
					local button = labelNode:Find("SkeletonUnlock")
					local objectReference = button:GetComponent("ObjectReference")
					local pointTransform = objectReference:GetRefValue("pointTransform")
					local lineStartPoint = objectReference:GetRefValue("lineStartPoint")
					local lineTransform = objectReference:GetRefValue("lineTransform")

					self:setLabelLinePoint(lineStartPoint, traitData.skeleton, pointTransform, lineTransform)
				else
					local button = labelNode:Find("Lock")
					local objectReference = button:GetComponent("ObjectReference")
					local pointTransform = objectReference:GetRefValue("pointTransform")
					local lineTransform = objectReference:GetRefValue("lineTransform")
					local detailObjectReference = self:getLockDetailReferences(objectReference, traitData.isMirror)
					local iconViewUImage = detailObjectReference:GetRefValue("iconViewUImage")

					self:setLabelLinePoint(iconViewUImage, traitData.skeleton, pointTransform, lineTransform)
				end
			end
		end
	end
end

function PetSurveyPageComponent:visibleAllLineOnRotation(visible)
	for idx = 1, 8 do
		local node = self["traitItem" .. idx]
		local lock = node:Find("Lock")
		local unlock = node:Find("SkeletonUnlock")

		self:visibleLineAlpha(lock, visible)
		self:visibleLineAlpha(unlock, visible)
	end
end

function PetSurveyPageComponent:visibleLineAlpha(node, visible)
	local objectReference = node:GetComponent("ObjectReference")
	local pointTransform = objectReference:GetRefValue("pointTransform")

	pointTransform:GetComponent("UWidget"):SetActiveFastest(visible)
end

function PetSurveyPageComponent:clearDelayShowTimer()
	if self.delayShowTimer then
		self.ctrl:killTimer(self.delayShowTimer)
	end

	self.delayShowTimer = nil
end

function PetSurveyPageComponent:clearShowTraitTimer()
	if self.showTraitTimer then
		self:killTimer(self.showTraitTimer)
	end

	self.showTraitTimer = nil
end

function PetSurveyPageComponent:showTraitLabelSequence(idx)
	if idx > #self.traitItemNodes then
		self.inSequence = false

		return
	end

	self.traitItemNodes[idx]:GetComponent("UWidget"):SetActive(true)
	self:invokeVxEvent(self.traitItemNodes[idx])

	self.showTraitTimer = self:startTimer(function()
		self:showTraitLabelSequence(idx + 1)
	end, PetConfigData.traitItemInterval or 0.2)
end

function PetSurveyPageComponent:invokeVxEvent(node)
	local screenPos = UIUtils.WorldToScreenPoint(node.transform.position)

	if screenPos.x < self.screenWidthHalf and screenPos.y > self.screenHeightHalf then
		node:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
	elseif screenPos.x < self.screenWidthHalf and screenPos.y < self.screenHeightHalf then
		node:InvokeCallback(CS.XGUI.EInvokeTime.Custom2)
	elseif screenPos.x > self.screenWidthHalf and screenPos.y > self.screenHeightHalf then
		node:InvokeCallback(CS.XGUI.EInvokeTime.Custom3)
	elseif screenPos.x > self.screenWidthHalf and screenPos.y < self.screenHeightHalf then
		node:InvokeCallback(CS.XGUI.EInvokeTime.Custom4)
	end
end

function PetSurveyPageComponent:hideAllTraitLabel()
	for idx = 1, 8 do
		self["traitItem" .. idx]:GetComponent("UWidget"):SetActive(false)
	end
end

function PetSurveyPageComponent:setTraitLabel(traitData)
	local labelIdx = traitData.positionDefault

	if not labelIdx then
		return
	end

	local labelNode = self["traitItem" .. labelIdx]

	self.traitItemNodes[#self.traitItemNodes + 1] = labelNode

	if traitData.positionCustomer then
		local anchoredPos = traitData.positionCustomer

		labelNode.transform.anchoredPosition = Vector2.New(anchoredPos[1], anchoredPos[2])
	else
		local prePosTrans = self["prePos" .. traitData.positionDefault].transform

		labelNode.transform.localPosition = prePosTrans.localPosition
		labelNode.transform.localRotation = prePosTrans.localRotation
	end

	local rotationCustome = traitData.rotationCustome

	if rotationCustome then
		labelNode.transform.localRotation = Quaternion.Euler(rotationCustome[1], rotationCustome[2], rotationCustome[3])
	end

	if traitData.unlock then
		if traitData.type == LABEL_STYLE_TYPE_1 or traitData.type == LABEL_STYLE_TYPE_3 then
			self:setUnlockSkeletonItem(labelNode, traitData)
		elseif traitData.type == LABEL_STYLE_TYPE_2 then
			self:setUnlockImgItem(labelNode, traitData)
		end
	else
		self:setLockItem(labelNode, traitData)
	end
end

function PetSurveyPageComponent:getLockDetailReferences(objectReference, isMirror)
	if isMirror then
		return objectReference:GetRefValue("detailLObjectReference")
	end

	return objectReference:GetRefValue("detailRObjectReference")
end

function PetSurveyPageComponent:setLockItem(labelNode, traitData)
	labelNode:TryChangePage("State", "lock")

	local button = labelNode:Find("Lock")
	local objectReference = button:GetComponent("ObjectReference")
	local pointTransform = objectReference:GetRefValue("pointTransform")
	local lineTransform = objectReference:GetRefValue("lineTransform")
	local detailObjectReference = self:getLockDetailReferences(objectReference, traitData.isMirror)
	local detailUButton = objectReference:GetRefValue(traitData.isMirror and "detailLUWidget" or "detailRUWidget")
	local otherDetailUWidget = objectReference:GetRefValue(traitData.isMirror and "detailRUWidget" or "detailLUWidget")
	local txtWhyUSDFText = detailObjectReference:GetRefValue("txtWhyUSDFText")
	local txtHowUSDFText = detailObjectReference:GetRefValue("txtHowUSDFText")
	local iconViewUImage = detailObjectReference:GetRefValue("iconViewUImage")
	local pointNumberUSDFText = detailObjectReference:GetRefValue("pointNumberUSDFText")
	local btnTooltipsUButton = detailObjectReference:GetRefValue("btnTooltipsUButton")

	otherDetailUWidget:SetActive(false)
	detailUButton:SetActive(true)
	lineTransform:GetComponent("UWidget"):SetActiveFastest(false)
	ClientTextUtils.setText(pointNumberUSDFText, "+", PetResearchUtils.getRewardResearchPoint(traitData.reward or 0))
	pointTransform:GetComponent("UWidget"):SetActive(self.lineVisible)
	ClientTextUtils.setText(txtWhyUSDFText, pg.getLocalizationText(traitData.clueDesc))
	ClientTextUtils.setText(txtHowUSDFText, pg.getLocalizationText(traitData.text))

	iconViewUImage.url = traitData.clueIcon

	if not traitData.type == LABEL_STYLE_TYPE_1 then
		LuaUIUtils.setUIViewVisible(pointTransform, false)
	end

	detailUButton:TryChangePage("SwitchText", 0)
	detailUButton:TryChangePage("ShowJumpIcon", 0)

	function detailUButton.luaClick(isFromNavigation)
		if traitData.text then
			self:switchClue(detailUButton, traitData.positionDefault, btnTooltipsUButton, traitData.clueSeek, isFromNavigation)
		end
	end
end

function PetSurveyPageComponent:switchClue(button, traitPosId, sourceBtn, sourceId, isFromNavigation)
	local _, page = button:TryGetCurrentPage("SwitchText")

	page = page == 0 and 1 or 0

	button:TryChangePage("SwitchText", page)

	if page == 1 then
		self:autoSwitchClue(traitPosId, button)

		if sourceId then
			button:TryChangePage("ShowJumpIcon", 1)
			LuaUIUtils.itemSourceTrigger(sourceBtn, ItemSourceData[sourceId])
		end
	elseif isFromNavigation then
		local clickFunc = LuaUIUtils.getItemSourceClickFunc(sourceBtn, ItemSourceData[sourceId])

		clickFunc()
	else
		button:TryChangePage("ShowJumpIcon", 0)
	end
end

function PetSurveyPageComponent:autoSwitchClue(traitId, button)
	local timerId = self.traitTimers[traitId]

	if timerId then
		self:killTimer(timerId)
	end

	timerId = self:startTimer(function()
		button:TryChangePage("SwitchText", 0)
		button:TryChangePage("ShowJumpIcon", 0)
	end, 10)
	self.traitTimers[traitId] = timerId
end

function PetSurveyPageComponent:clearAllTraitTimer()
	for traitId, timerId in pairs(self.traitTimers or EMPTY_TABLE) do
		self:killTimer(timerId)
	end

	self.traitTimers = {}
end

function PetSurveyPageComponent:setLabelMirror(button, isMirror)
	if isMirror then
		button:TryChangePage("Direction", "right")
	else
		button:TryChangePage("Direction", "left")
	end
end

function PetSurveyPageComponent:setUnlockSkeletonItem(labelNode, traitData)
	local button = labelNode:Find("SkeletonUnlock"):GetComponent("UButton")
	local nodeWidget = button:GetComponent("UWidget")
	local objectReference = button:GetComponent("ObjectReference")
	local descScrollRect = objectReference:GetRefValue("descScrollRect")
	local titleUText = objectReference:GetRefValue("titleUText")
	local pointTransform = objectReference:GetRefValue("pointTransform")
	local lineTransform = objectReference:GetRefValue("lineTransform")
	local traitImg = objectReference:GetRefValue("iconUImage")
	local detailBtn = objectReference:GetRefValue("detailUButton")
	local lineStartPoint = objectReference:GetRefValue("lineStartPoint")
	local exploreSkillBtn = objectReference:GetRefValue("exploreSkillBtn")
	local exploreSkillIcon = objectReference:GetRefValue("exploreSkillIcon")
	local exploreSkillLevel = objectReference:GetRefValue("exploreSkillLevel")
	local exploreBtn = objectReference:GetRefValue("exploreBtn")
	local skillNormal = objectReference:GetRefValue("skillNormal")
	local skillNormalIcon = objectReference:GetRefValue("skillNormalIcon")
	local reportPoint = objectReference:GetRefValue("reportPoint")

	lineTransform:GetComponent("UWidget"):SetActiveFastest(false)

	if traitData.hadReport then
		button:TryChangePage("Upload", 1)
		ClientTextUtils.setText(reportPoint, "+", PetResearchUtils.getRewardResearchPoint(traitData.reward or 0))
	else
		button:TryChangePage("Upload", 0)
	end

	ClientTextUtils.setText(titleUText, pg.getLocalizationText(traitData.traitsName))
	ClientTextUtils.setText(descScrollRect.content, pg.getLocalizationText(traitData.traitsDesc))

	traitImg.url = traitData.traitsImg

	labelNode:TryChangePage("State", "unlockSkeleton")
	self:setLabelMirror(button, traitData.isMirror)

	if not traitData.type == LABEL_STYLE_TYPE_1 then
		pointTransform:GetComponent("UWidget"):SetActiveFastest(false)
	end

	local traitsContentType = traitData.traitsContentType
	local pageIdx = TraitType_2_Page_idx[traitsContentType] or 0

	detailBtn:TryChangePage("Type", pageIdx)

	if traitsContentType then
		if traitsContentType == 1 then
			local skillId = traitData.traitsContentParam[1]
			local skillInfo = AbilityParamData[skillId]
			local skillData = self.ctrl:getSkillItemById(skillId, skillInfo)

			skillNormalIcon.url = LuaUIUtils.getSkillIcon(skillInfo.icon)

			function skillNormal.luaRenderTooltip(b, component)
				self.ctrl:renderSkillToolTips(component, skillData, b)
			end
		elseif traitsContentType == 2 then
			local featureId = traitData.traitsContentParam[1]
			local featureInfo = PetFeatureData[featureId]

			skillNormalIcon.url = featureInfo.icon

			function skillNormal.luaRenderTooltip(b, component)
				self.ctrl:renderSkillToolTips(component, featureInfo, b)
			end
		elseif traitsContentType == 3 then
			local param = traitData.traitsContentParam
			local exploreId = param[self.model.EXPLORE_PARAM_IDX.exploreId]
			local level = param[self.model.EXPLORE_PARAM_IDX.level]
			local exploreInfo = PetResearchUtils.getPetExploreSkillData(exploreId, level)
			local maxLevel = param[self.model.EXPLORE_PARAM_IDX.maxLevel] or 3
			local levelData = {}

			for idx = 1, maxLevel do
				local data = {}

				data.reachedIdx = idx <= level and 1 or 0
				levelData[#levelData + 1] = data
			end

			function exploreSkillLevel.luaRenderItem(button, idx, data)
				button:TryChangePage("Have", data.reachedIdx)
			end

			exploreSkillLevel:SetList(levelData)

			exploreSkillIcon.url = exploreInfo.icon

			exploreBtn:TryChangePage("quality", maxLevel)

			function exploreSkillBtn.luaRenderTooltip(b, component)
				self.ctrl:renderSkillToolTips(component, exploreInfo, exploreSkillBtn)
			end
		end
	end

	pointTransform:GetComponent("UWidget"):SetActive(self.lineVisible)

	if traitData.traitsAnimation then
		function detailBtn.luaClick()
			if not self.surveyDragEnabled or self.isPlayingSurveyAction then
				return
			end

			self.isPlayingSurveyAction = true

			self:setSurveyDragEnabled(false)
			self:switchTraitNodeVisible(false, labelNode)
			pointTransform:GetComponent("UWidget"):SetActiveFastest(false)
			self.ctrl.petScene:resetSurveyPetRotation(function()
				if not self.isSelectedPage then
					self.isPlayingSurveyAction = false

					return
				end

				self.ctrl.petScene:playSurveyAction(nil, traitData.traitsAnimation, function()
					self.isPlayingSurveyAction = false

					self:switchTraitNodeVisible(true, labelNode)
					self.ctrl.petScene:enableSurveyCameraMove(false)
					self.ctrl.petScene:moveCameraPosToOrigin()
					self:lineToSkeleton()
					pointTransform:GetComponent("UWidget"):SetActiveFastest(true)
					self:setSurveyDragEnabled(self.isSelectedPage)
				end)
				self.ctrl.petScene:enableSurveyCameraMove(true, traitData.cameraOffsetCondition, traitData.cameraOffset, traitData.cameraOffsetTime)
			end)
		end
	end
end

function PetSurveyPageComponent:visibleLineInPlayable(visible)
	self.lineVisible = visible

	for _, labelNode in pairs(self.traitItemNodes) do
		local button = labelNode:Find("SkeletonUnlock")
		local objectReference = button:GetComponent("ObjectReference")
		local pointTransform = objectReference:GetRefValue("pointTransform")

		pointTransform:GetComponent("UWidget"):SetActive(self.lineVisible)

		local button = labelNode:Find("Lock")
		local objectReference = button:GetComponent("ObjectReference")
		local pointTransform = objectReference:GetRefValue("pointTransform")

		pointTransform:GetComponent("UWidget"):SetActive(self.lineVisible)
	end
end

function PetSurveyPageComponent:switchTraitNodeVisible(visible, filterNode)
	for idx, node in pairs(self.traitItemNodes or EMPTY_TABLE) do
		if filterNode then
			if node ~= filterNode then
				node:GetComponent("UWidget"):SetActive(visible)

				if visible then
					self:invokeVxEvent(node)
				end
			end
		else
			node:GetComponent("UWidget"):SetActive(visible)

			if visible then
				self:invokeVxEvent(node)
			end
		end
	end
end

function PetSurveyPageComponent:setUnlockImgItem(labelNode, traitData)
	local button = labelNode:Find("ImageUnlock")
	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUText = objectReference:GetRefValue("txtNameUText")
	local imageUImage = objectReference:GetRefValue("imageUImage")

	ClientTextUtils.setText(txtNameUText, pg.getLocalizationText(traitData.traitsName))

	imageUImage.url = traitData.traitsImg

	labelNode:TryChangePage("State", "unlockImg")

	labelNode.transform.anchoredPosition = Vector2.New(traitData.positionCustomer[1], traitData.positionCustomer[2])
end

function PetSurveyPageComponent:setLabelLinePoint(iconView, skeletonName, pointTransform, lineTransform)
	if skeletonName then
		local skeletonPos = self.ctrl.petScene:getModelSkeletonPos(skeletonName)

		if skeletonPos then
			UIUtils.SetRectLocalPosByWorldPos(skeletonPos, pointTransform.transform)

			local labelPos = iconView.transform.position
			local pointPos = pointTransform.transform.position
			local direction = labelPos - pointPos
			local angle = math.atan2(direction.y, direction.x) * Mathf.Rad2Deg

			lineTransform.transform.localRotation = Quaternion.Euler(0, 0, angle - 90)

			local lineBg = lineTransform:Find("Bg")
			local lineBgSize = lineBg.transform.sizeDelta
			local pointY = pointTransform.anchoredPosition.y
			local pointX = pointTransform.anchoredPosition.x
			local length = math.sqrt(pointX * pointX, pointY * pointY)

			lineBg.transform.sizeDelta = Vector2.New(lineBgSize.x, length)

			pointTransform:GetComponent("UWidget"):SetActiveFastest(true)
			lineTransform:GetComponent("UWidget"):SetActiveFastest(true)
		else
			pointTransform:GetComponent("UWidget"):SetActiveFastest(false)
			lineTransform:GetComponent("UWidget"):SetActiveFastest(false)
		end
	else
		pointTransform:GetComponent("UWidget"):SetActiveFastest(false)
		lineTransform:GetComponent("UWidget"):SetActiveFastest(false)
	end
end

function PetSurveyPageComponent:getSurveyResearchPoint()
	return PetResearchUtils.getPetSurveyPoint(self.model.baseTemplateId)
end

function PetSurveyPageComponent:getPetTraitData(handbookInfo)
	local curPetTemplateId = self.model.baseTemplateId
	local traitData = PetTraitData[curPetTemplateId] or {}
	local researchPointReportMap = pg.me.petHandbookMap[curPetTemplateId].researchPointMap
	local ret = {}

	for traitId, info in pairs(traitData) do
		local item = Lume.clone(info)

		item.traitId = traitId

		local traitState = handbookInfo:getTraitResearchInfoWithDefault(traitId).status

		if traitState ~= Const.PET_RESEARCH.STATUS_HIDE then
			item.unlock = traitState == Const.PET_RESEARCH.STATUS_SHOW

			if item.unlock then
				item.hadReport = researchPointReportMap:hasParams(Const.PET_RESEARCH.BI_SOURCE_TRAIT, {
					traitId
				})
			end

			ret[#ret + 1] = item
		end
	end

	sort(ret, function(a, b)
		if a.displaySequence and b.displaySequence then
			return a.displaySequence < b.displaySequence
		end

		return false
	end)

	return ret
end

return PetSurveyPageComponent
