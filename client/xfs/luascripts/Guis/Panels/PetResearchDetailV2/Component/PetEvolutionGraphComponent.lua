-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetResearchDetailV2\\Component\\PetEvolutionGraphComponent.lua

local UIUtils = UIUtils
local Time = require("Core.Common.Time")
local bit = bit
local lshift = bit.lshift
local Const = require("Common.Const.Const")
local PetProtoTypeData = require("Data.pet_prototype_data")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local PetData = require("Data.pet_data")
local NoticeDef = require("Common.NoticeDef")
local PetResearchUtilsCommon = require("Common.Utils.PetResearchUtils")
local PetBasePrototypeToPrototypeMap = require("Data.pet_base_prototype_to_prototype_map")
local PetEvolveData = require("Data.pet_evolve_data")
local PetEthnicData = require("Data.pet_ethnic_group_data")
local ItemSourceData = require("Data.item_source_data")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local Utils = require("Common.Utils.Utils")
local PetEvolutionGraphComponent = Class.LightClass("PetEvolutionGraphComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local AddressDataConst = require("Const.AddressDataConst")

function PetEvolutionGraphComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.petDescText = self.objectReference:GetRefValue("petDescText")
	self.clickObject = self.objectReference:GetRefValue("clickObject")
	self.selectedUWidget = self.objectReference:GetRefValue("selectedUWidget")
	self.curQuality = self.objectReference:GetRefValue("curQuality")
	self.petName = self.objectReference:GetRefValue("petName")
	self.listPetHeadUList = self.objectReference:GetRefValue("listPetHeadUList")
	self.listElementUList = self.objectReference:GetRefValue("listElementUList")
	self.formName = self.objectReference:GetRefValue("formName")
	self.formIcon = self.objectReference:GetRefValue("formIconUImage")
	self.consoleSelectedAnchor = self.objectReference:GetRefValue("consoleselectedAnchorTransform")
	self.consoleSelectedUWidget = self.objectReference:GetRefValue("consoleselectedUWidget")
	self.virtualBtnUButton = self.objectReference:GetRefValue("virtualBtnUButton")
end

function PetEvolutionGraphComponent:initView()
	function self.listElementUList.luaRenderItem(button, idx, data)
		LuaUIUtils.setElementButtonNew(button, data.element)
	end

	self.tabIdx = self.model.TAB_IDX.EVOLUTION
	self.ctrl.tabMap[self.tabIdx] = self
	self.clickObject.camera = pg.global.cameraMgr.uiSceneCameraInst
	self.clickObject.layerMask = lshift(1, ClientConst.LayerDefine.LAYER_UI_SCENE)

	function self.clickObject.luaClick(go)
		self:onClickScreen(go)
	end

	self.selectedUWidget:SetPopupValidateTouch(function()
		return self.tooltipOpenFrame ~= Time.frameCount
	end)
	self:hideEvolveCondition()

	function self.listPetHeadUList.luaRenderItem(button, idx, data)
		self:renderFormList(button, idx, data)
	end

	function self.listPetHeadUList.luaSelectedChanged(uList, isSelect)
		local slotItem = uList.selectedItem

		if slotItem and slotItem.isGot and isSelect then
			self.ctrl:setPetFormAppearance(slotItem.petTemplateId, 0)
			self.ctrl.petScene:refreshEvolutionGraph()
			ClientTextUtils.setText(self.formName, LuaUIUtils.getPetFormNameByPrototypeId(slotItem.petTemplateId))

			local formIconSmall = PetResearchUtils.getPetFormIconSmall(slotItem.petTemplateId)

			if formIconSmall then
				self.formIcon.url = formIconSmall
			end

			self:refreshConsoleSelectList()
		end
	end
end

function PetEvolutionGraphComponent:renderFormList(button, idx, data)
	local objectReference = button:GetComponent("ObjectReference")
	local icon = objectReference:GetRefValue("icon")
	local formItemUWidget = objectReference:GetRefValue("formItemUWidget")

	button.enabledTooltip = false
	icon.url = data.icon

	if data.isGot then
		button:TryChangePage("state", 0)
	else
		button:TryChangePage("state", 4)
	end

	function button.luaClick()
		if not data.isGot then
			pg.global.showBubbleMessageById(NoticeDef.PET_FORM_LOCK)
		end
	end

	if data.isGot then
		formItemUWidget:SetActiveFastest(true)
		PetResearchUtils.renderFormItem(formItemUWidget, data.petTemplateId)
	else
		formItemUWidget:SetActiveFastest(false)
	end
end

function PetEvolutionGraphComponent:getFormDatas()
	local baseTemplateId = Utils.getBasePetPrototypeId(self.templateId)
	local formDatas = PetBasePrototypeToPrototypeMap[baseTemplateId] or {}
	local playerHandBookMap = pg.me.petHandbookMap
	local ret = {}

	for _, petTemplateId in pairs(formDatas) do
		if PetEvolveData[petTemplateId] then
			local item = {}
			local petHandBookInfo = playerHandBookMap[petTemplateId]

			if petHandBookInfo then
				if petHandBookInfo:isCatched() then
					item.isGot = true
				elseif petHandBookInfo:isKnown() then
					item.isKnown = true
				end
			end

			local pData = PetData[petTemplateId]

			item.icon = LuaUIUtils.getPetIcon(pData.iconName, LuaUIUtils.PET_ICON)
			item.petTemplateId = petTemplateId
			item.selected = petTemplateId == self.model.formPetTemplateId
			ret[#ret + 1] = item
		end
	end

	if #ret == 1 then
		return {}
	end

	return ret
end

function PetEvolutionGraphComponent:renderEvolveDetail(component, templateId, subStage)
	local objectReference = component:GetComponent("ObjectReference")
	local textUBaseText = objectReference:GetRefValue("textUBaseText")
	local titleUSDFText = objectReference:GetRefValue("titleUSDFText")
	local conditionList = objectReference:GetRefValue("listUList")
	local qualityUComponent = objectReference:GetRefValue("qualityUComponent")
	local consumeUWidget = objectReference:GetRefValue("consumeUWidget")
	local itemList = objectReference:GetRefValue("itemList")
	local listCharUList = objectReference:GetRefValue("listCharUList")
	local unlockTitleUWidget = objectReference:GetRefValue("unlockTitleUWidget")
	local unlockListUList = objectReference:GetRefValue("unlockListUList")
	local manualPetSkillUButton = objectReference:GetRefValue("manualPetSkillUButton")
	local elementListUList = objectReference:GetRefValue("elementListUList")
	local formWidget = objectReference:GetRefValue("formWidget")
	local formName = objectReference:GetRefValue("formName")
	local btnEvolveUButton = objectReference:GetRefValue("btnEvolveUButton")

	btnEvolveUButton:SetActive(false)

	templateId = templateId or self.model.curPetTemplateId

	local evolveData = PetEvolveData[templateId]
	local subStageEvolveData = evolveData[subStage]
	local normalConditions = subStageEvolveData.normalConditions
	local handbookMap = pg.me.petHandbookMap
	local handbookInfo = handbookMap:getInfo(templateId)
	local conditionState

	if not handbookInfo then
		conditionState = PetResearchUtilsCommon.genEvolveResearchInfoInitDict(templateId, subStage)
	else
		conditionState = handbookInfo:getEvolveResearchInfoWithDefault(subStage):getRawTable() or {}
	end

	function unlockListUList.luaRenderItem(button, idx, data)
		self:renderEvolveConditionList(button, idx, data)
	end

	if subStageEvolveData.normalCondition0 then
		local normalConditionData = self:getEvolutionNormalConditionData(conditionState.normalConditionStatus or {}, {
			[0] = subStageEvolveData.normalCondition0
		}, true)

		unlockListUList:SetList(normalConditionData)
		unlockTitleUWidget:SetActive(true)
		unlockListUList:SetActive(true)
	else
		unlockTitleUWidget:SetActive(false)
		unlockListUList:SetActive(false)
	end

	local targetId = subStageEvolveData.targetPetId
	local petInfo = handbookMap[targetId]

	self.targetPetIsGot = petInfo and petInfo:isCatched()

	local normalConditionData = self:getEvolutionNormalConditionData(conditionState.normalConditionStatus or {}, normalConditions)
	local petProtoData = PetProtoTypeData[targetId]

	if self.targetPetIsGot then
		ClientTextUtils.setText(titleUSDFText, pg.getLocalizationText(petProtoData.name))
		ClientTextUtils.setText(formName, LuaUIUtils.getPetFormNameByPrototypeId(targetId))
		formWidget:SetActive(true)
	else
		ClientTextUtils.setText(titleUSDFText, "???")
		formWidget:SetActive(false)
	end

	if NotNil(manualPetSkillUButton) then
		manualPetSkillUButton:SetActive(false)
	end

	elementListUList:SetActive(true)

	function elementListUList.luaRenderItem(button, idx, data)
		LuaUIUtils.setElementButtonNew(button, data.element, true, data.petId)
	end

	local targetPetData = PetData[targetId] or {}
	local _, elementListData = LuaUIUtils.getElementInfo(targetPetData.elementType, targetPetData.mainElementType)

	for _, elementData in ipairs(elementListData) do
		elementData.petId = targetId
	end

	elementListUList:SetList(elementListData)
	LuaUIUtils.renderExploreList(listCharUList, templateId)

	function conditionList.luaRenderItem(button, idx, data)
		self:renderEvolveConditionList(button, idx, data)
	end

	function itemList.luaRenderItem(button, idx, data)
		self:renderEvolveItemList(button, idx, data)
	end

	conditionList:SetList(normalConditionData)

	local itemConditions = subStageEvolveData.itemConditions

	if itemConditions then
		local itemConditionStatus = conditionState.itemConditionStatus or {}
		local itemConditionData = PetResearchUtils.getEvolutionItemConditionData(itemConditionStatus, itemConditions)
		local finalItem = {}

		for idx, state in pairs(itemConditionStatus) do
			if state ~= Const.PET_RESEARCH.STATUS_HIDE then
				finalItem[#finalItem + 1] = itemConditionData[idx]
			end
		end

		if #finalItem > 0 then
			consumeUWidget:SetActive(true)
			itemList:SetList(finalItem)
		else
			consumeUWidget:SetActive(false)
		end
	else
		consumeUWidget:SetActive(false)
	end

	PetResearchUtils.setEvolveQuality(qualityUComponent, subStageEvolveData.targetPetId)
	ClientTextUtils.setText(textUBaseText, pg.getLocalizationText(subStageEvolveData.simpleDesc))
end

function PetEvolutionGraphComponent:renderEvolveConditionList(button, idx, data)
	local objectReference = button:GetComponent("ObjectReference")
	local textUBaseText = objectReference:GetRefValue("textUBaseText")

	ClientTextUtils.setText(textUBaseText, data.desc or "")
	button:TryChangePage("Condition", 0)
	button:TryChangePage("TextColor", data.textColorIndex)
	button:TryChangePage("Reached", data.reachedIdx)

	button.enabledTooltip = false

	if data.sourceParam and ItemSourceData[data.sourceParam[1]] then
		button:TryChangePage("Arrow", 0)
		LuaUIUtils.itemSourceTrigger(button, ItemSourceData[data.sourceParam[1]])
	else
		button.luaClick = nil

		button:TryChangePage("Arrow", 1)
	end
end

function PetEvolutionGraphComponent:getEvolutionNormalConditionData(normalState, normalData, isPlayerTrigger)
	local ret = {}
	local player = pg.me

	for idx, info in pairs(normalData) do
		local state = normalState[idx]
		local item = self:getEvolutionConditionItem(state, info)

		item.reachedIdx = 0

		if isPlayerTrigger then
			local needCond = info[Const.PET_EVOLVE_NORMAL_COND_POS_COND]
			local reached = player.triggerMap:isCompleteOrMeetCondition(needCond)

			if reached then
				item.reachedIdx = 1
			end
		end

		ret[#ret + 1] = item
	end

	return ret
end

function PetEvolutionGraphComponent:getEvolutionConditionItem(state, info)
	local item = {}

	item.state = state

	local textColorIndex = 0

	if state == Const.PET_RESEARCH.STATUS_CLUE then
		item.desc = pg.getLocalizationText(info[2])
	elseif state == Const.PET_RESEARCH.STATUS_SHOW then
		item.desc = pg.getLocalizationText(info[3])
		textColorIndex = 1
	elseif state == Const.PET_RESEARCH.STATUS_HIDE then
		item.desc = "????"
	else
		item.desc = ""
	end

	item.sourceParam = info[5]
	item.textColorIndex = textColorIndex

	return item
end

function PetEvolutionGraphComponent:renderEvolveItemList(button, idx, data)
	local realItem = data.realItem
	local ownNum
	local preferredState = UIConst.ITEM_STATE.FULL

	if realItem.checked then
		if realItem.altItem then
			ownNum = data.num
			preferredState = UIConst.ITEM_STATE.EXCHANGE
		else
			ownNum = realItem.ownCount
		end
	else
		ownNum = realItem.itemCount
	end

	local itemText = LuaUIUtils.renderConsumeText(nil, ownNum, data.num, preferredState)

	LuaUIUtils.renderRewardItem(button, data, itemText)
end

function PetEvolutionGraphComponent:refreshFormList()
	local formDatas = self:getFormDatas()

	if #formDatas == 0 then
		self.listPetHeadUList:SetActive(false)

		return
	end

	self.listPetHeadUList:SetActive(true)
	self.listPetHeadUList:SetList(formDatas)
end

function PetEvolutionGraphComponent:showEvolveCondition(templateId, subStage)
	local evolveData = PetEvolveData[templateId]
	local subStageEvolveData = evolveData[subStage]

	if subStageEvolveData then
		local targetPos = self.ctrl.petScene:getEvolveEntPos(subStageEvolveData.targetPetId)
		local playerHeight = PetProtoTypeData[templateId].modelHeight
		local scale = self.ctrl.petScene:getPetTargetScale(subStageEvolveData.targetPetId, self.tabIdx)

		targetPos = Vector3(targetPos[1], targetPos[2] + playerHeight / 2 * scale, targetPos[3])

		UIUtils.SetRectLocalPosByWorldPos(targetPos, self.selectedUWidget.transform)

		local anchoredPosition = self.selectedUWidget.transform.anchoredPosition

		self.selectedUWidget.transform.anchoredPosition = Vector2.New(anchoredPosition.x, anchoredPosition.y + 100)

		function self.selectedUWidget.luaRenderTooltip(button, component)
			self:renderEvolveDetail(component, templateId, subStage)
		end
	end

	self.selectedUWidget:SetActiveFastest(true)
	self.selectedUWidget:ClosePopup()

	self.tooltipOpenFrame = Time.frameCount

	self.selectedUWidget:OpenTooltip()
end

function PetEvolutionGraphComponent:hideEvolveCondition()
	self.branch = nil
	self.evolveTemplateId = nil
	self.tooltipOpenFrame = nil

	self.selectedUWidget:ClosePopup()
	self.selectedUWidget:SetActiveFastest(false)
end

function PetEvolutionGraphComponent:getEvolutionResearchPoint()
	self.sumResearchPoint = 0
	self.curResearchPoint = 0

	local templateId = self.model.curPetTemplateId
	local evolveData = PetEvolveData[templateId] or {}
	local handbookMap = pg.me.petHandbookMap

	for branchId, info in pairs(evolveData) do
		local targetPetId = info.targetPetId
		local reward = info.reward

		if reward then
			local point = PetResearchUtils.getRewardResearchPoint(reward)

			self.sumResearchPoint = self.sumResearchPoint + point

			if targetPetId then
				local petInfo = handbookMap[targetPetId]
				local isGot = petInfo and petInfo:isCatched()

				if isGot then
					self.curResearchPoint = self.curResearchPoint + point
				end
			end
		end
	end

	return {
		self.curResearchPoint,
		self.sumResearchPoint
	}
end

function PetEvolutionGraphComponent:isGamepadNavigationMode()
	local navMgr = pg.global.navMgr

	return pg.game.input:isUsingGamepad() and (not navMgr or not navMgr.IsVirtualMouseMode)
end

function PetEvolutionGraphComponent:onClickScreen(go)
	if self:isGamepadNavigationMode() then
		return
	end

	if not go then
		self:hideEvolveCondition()
		self.ctrl.petScene:clearSelectPetEvolve()

		return
	end

	local name = go.name

	if name == "PlayerBody" then
		name = go.transform.parent.gameObject.name
	end

	if string.sub(name, 1, 12) == "evolveGraph_" then
		local infos = string.split(name, "_")
		local templateId = tonumber(infos[2])
		local branch = tonumber(infos[3])

		self:showBranchDetail(templateId, branch)
	else
		self:hideEvolveCondition()

		local templateId = tonumber(name)

		if templateId then
			self.ctrl.petScene:playPetEvolveAction(templateId)
			self.ctrl.petScene:selectPetEvolve(templateId)
		end
	end
end

function PetEvolutionGraphComponent:showBranchDetail(templateId, branch)
	if branch == 0 then
		self:hideEvolveCondition()
		self.ctrl.petScene:playPetEvolveAction(templateId)
		self.ctrl.petScene:selectPetEvolve(templateId)

		return
	end

	local evolveData = PetEvolveData[templateId]
	local subStageEvolveData = evolveData[branch]

	if subStageEvolveData and (self.branch ~= branch or self.evolveTemplateId ~= templateId) then
		self.branch = branch
		self.evolveTemplateId = templateId

		self:showEvolveCondition(templateId, branch)

		local targetPetId = subStageEvolveData.targetPetId

		self.ctrl.petScene:playPetEvolveAction(targetPetId)
		self.ctrl.petScene:selectPetEvolve(targetPetId)
	else
		if self:isGamepadNavigationMode() then
			self.selectedUWidget:ClosePopup()

			return
		end

		self.selectedUWidget:ClosePopup()

		self.tooltipOpenFrame = Time.frameCount

		self.selectedUWidget:OpenTooltip()
	end
end

function PetEvolutionGraphComponent:showPetEvolutionInfo(cb, defaultSelectId)
	local baseInfo = self.ctrl:getSelectedPetInfo()

	self.needRestore = false

	if not PetEvolveData[self.model.formPetTemplateId] then
		self.ctrl.petScene:showPet(baseInfo.templateId)

		self.needRestore = true
	end

	self.ctrl.petScene:trySwitchView(self.tabIdx, function()
		if cb then
			cb()
		end

		self:refreshConsoleSelectList()
	end)

	if self.templateId and self.templateId == baseInfo.templateId then
		return
	end

	self.templateId = baseInfo.templateId

	self.ctrl.petScene:refreshEvolutionGraph()
	ClientTextUtils.setText(self.petName, baseInfo.name)
	ClientTextUtils.setText(self.petDescText, baseInfo.desc or "")
	self.listElementUList:SetList(baseInfo.elements)
	PetResearchUtils.setEvolveQuality(self.curQuality, self.templateId)
	ClientTextUtils.setText(self.formName, LuaUIUtils.getPetFormNameByPrototypeId(self.templateId))
	self:hideEvolveCondition()
	self.ctrl.petScene:playPetPageAction(self.templateId, self.tabIdx)
end

function PetEvolutionGraphComponent:onSelectThisPage(cb, defaultSelectId)
	self.ctrl:setPageTitle("EVOLVE")
	self.ctrl.petScene:switchEvolveGraph(true)
	self:showPetEvolutionInfo(cb, defaultSelectId)

	local pointInfo = self:getEvolutionResearchPoint()

	self.ctrl:setPageResearchPoint(pointInfo[1], pointInfo[2])
	self:refreshFormList()
end

function PetEvolutionGraphComponent:hideConsoleSelectList()
	if not pg.game.input:isUsingGamepad() then
		return
	end

	self.consoleSelectedHasFocused = false

	for i = 1, #self.consoleSelectedItems do
		local item = self.consoleSelectedItems[i]

		if item and NotNil(item.gameObject) then
			item.gameObject:SetActiveEx(false)
		end
	end

	self.virtualBtnUButton.gameObject:SetActiveEx(true)
	pg.global.navMgr:FocusItem(self.virtualBtnUButton)
end

function PetEvolutionGraphComponent:refreshConsoleSelectList()
	if not pg.game.input:isUsingGamepad() then
		return
	end

	local listData = self:getConsoleSelectListData()

	self.consoleSelectedItems = self.consoleSelectedItems or {}
	self._consoleSelectedVersion = (self._consoleSelectedVersion or 0) + 1

	local version = self._consoleSelectedVersion

	self.consoleSelectedListData = listData
	self.consoleSelectedFocusTargetPetId = self:getDefaultConsoleSelectTargetPetId()

	self:hideConsoleSelectList()

	for idx, data in ipairs(listData) do
		local item = self.consoleSelectedItems[idx]

		if item and NotNil(item.gameObject) then
			self:renderConsoleSelectItem(item.gameObject, data)
		else
			self.view:addPrefabWithPathAsync(self.consoleSelectedUWidget, AddressDataConst.UI_CONSOLE_TAB_DETAIL_GENE, function(objInfo)
				if version ~= self._consoleSelectedVersion then
					if objInfo and NotNil(objInfo.gameObject) then
						pg.global.uiMgr:DestroyItem(objInfo.gameObject)
					end

					return
				end

				local curData = listData[idx]

				if not curData then
					if objInfo and NotNil(objInfo.gameObject) then
						pg.global.uiMgr:DestroyItem(objInfo.gameObject)
					end

					return
				end

				self.consoleSelectedItems[idx] = objInfo

				self:renderConsoleSelectItem(objInfo.gameObject, curData)
			end)
		end
	end
end

function PetEvolutionGraphComponent:getDefaultConsoleSelectTargetPetId()
	return self.model.formPetTemplateId or self.ctrl.petScene and self.ctrl.petScene.curShowPetTemplateId or self.templateId
end

function PetEvolutionGraphComponent:getConsoleSelectListData()
	local listData = {}
	local centerTemplateId = self.ctrl.petScene and self.ctrl.petScene.curShowPetTemplateId or self.templateId
	local rootEvolveData = PetEvolveData[centerTemplateId] and PetEvolveData[centerTemplateId][1]

	if rootEvolveData and not rootEvolveData.individual then
		local petData = PetProtoTypeData[centerTemplateId]
		local groupId = rootEvolveData.groupId
		local ethnicGroup = petData and petData.ethnicGroup
		local ethnicTemplateIds = ethnicGroup and PetEthnicData[ethnicGroup] and PetEthnicData[ethnicGroup][groupId] or {}
		local targetToBranch = {}

		for petTemplateId, _ in pairs(ethnicTemplateIds) do
			local graphData = PetEvolveData[petTemplateId] or {}

			for branchId, branchInfo in pairs(graphData) do
				if branchInfo.targetPetId then
					targetToBranch[branchInfo.targetPetId] = {
						sourceTemplateId = petTemplateId,
						branchId = branchId
					}
				end
			end
		end

		for petTemplateId, _ in pairs(ethnicTemplateIds) do
			if petTemplateId == centerTemplateId then
				listData[#listData + 1] = {
					isPlayerBody = true,
					sourceTemplateId = petTemplateId,
					targetPetId = petTemplateId
				}
			else
				local sourceTemplateId, branchId
				local stage = Utils.getPetPrototypeStage(petTemplateId)

				if stage == 1 then
					sourceTemplateId = petTemplateId
					branchId = 0
				else
					local branch = targetToBranch[petTemplateId]

					if branch then
						sourceTemplateId = branch.sourceTemplateId
						branchId = branch.branchId
					end
				end

				if sourceTemplateId and branchId then
					listData[#listData + 1] = {
						sourceTemplateId = sourceTemplateId,
						branchId = branchId,
						targetPetId = petTemplateId
					}
				end
			end
		end
	end

	return listData
end

function PetEvolutionGraphComponent:renderConsoleSelectItem(itemGameObject, data)
	if IsNil(itemGameObject) then
		return
	end

	if not data or not data.targetPetId or not data.sourceTemplateId then
		itemGameObject:SetActiveEx(false)

		return
	end

	if data.isPlayerBody then
		itemGameObject.name = data.sourceTemplateId
	else
		itemGameObject.name = "evolveGraph_" .. data.sourceTemplateId .. "_" .. data.branchId
	end

	local button = itemGameObject:GetComponent("UButton")

	function button.luaClick(fromNav)
		if data.isPlayerBody then
			self:hideEvolveCondition()
			self.ctrl.petScene:playPetEvolveAction(data.targetPetId)
			self.ctrl.petScene:selectPetEvolve(data.targetPetId)
		else
			self:showBranchDetail(data.sourceTemplateId, data.branchId)
		end
	end

	local petScene = self.ctrl.petScene

	if petScene and petScene.registerEntLoadedCallback then
		local targetPetId = data.targetPetId

		petScene:registerEntLoadedCallback(targetPetId, function()
			self:refreshConsoleSelectItemPos(targetPetId)
		end)
	end
end

function PetEvolutionGraphComponent:refreshConsoleSelectItemPos(targetPetId)
	if not pg.game.input:isUsingGamepad() then
		return
	end

	if not self.consoleSelectedItems or not self.consoleSelectedListData then
		return
	end

	for idx, data in ipairs(self.consoleSelectedListData) do
		if data.targetPetId == targetPetId then
			local objInfo = self.consoleSelectedItems[idx]

			if objInfo and NotNil(objInfo.gameObject) then
				objInfo.gameObject:SetActiveEx(true)
				self:SetConsoleSelectItemPos(targetPetId, objInfo.gameObject)
				self:tryFocusConsoleSelectItem(targetPetId, objInfo.gameObject)
			end

			return
		end
	end
end

function PetEvolutionGraphComponent:tryFocusConsoleSelectItem(targetPetId, itemGameObject)
	if self.consoleSelectedHasFocused or not pg.game.input:isUsingGamepad() then
		return
	end

	if targetPetId ~= self.consoleSelectedFocusTargetPetId or IsNil(itemGameObject) then
		return
	end

	local navManager = pg.global.navMgr

	if navManager then
		navManager:FocusItem(itemGameObject:GetComponent("UButton"))
		self.virtualBtnUButton.gameObject:SetActiveEx(false)

		self.consoleSelectedHasFocused = true
	end
end

function PetEvolutionGraphComponent:SetConsoleSelectItemPos(targetPetId, itemGameObject)
	local petScene = self.ctrl.petScene
	local anchor = self.consoleSelectedAnchor

	if not petScene or not petScene.getEvolveEntTopWorldPos or not anchor or IsNil(anchor) or IsNil(itemGameObject) then
		return
	end

	local topWorldPos = petScene:getEvolveEntTopWorldPos(targetPetId, self.tabIdx)

	UIUtils.SetRectLocalPosByWorldPos(topWorldPos, anchor.transform)

	local anchorPosition = anchor.transform.anchoredPosition

	itemGameObject.transform.anchoredPosition = anchorPosition
end

function PetEvolutionGraphComponent:onDeselectThisTab()
	self.ctrl.petScene:switchEvolveGraph(false)
	self.ctrl.petScene:clearSelectPetEvolve()

	if self.needRestore then
		self.ctrl.petScene:showPet(self.model.formPetTemplateId, self.model.formPetLabel, nil, self.model.formPetShinyStyle)
	end
end

function PetEvolutionGraphComponent:onDestroy()
	UIComponent.onDestroy(self)
end

return PetEvolutionGraphComponent
