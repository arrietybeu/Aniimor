-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetEvolution\\Component\\EvolutionComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local EvolutionComponent = Class.LightClass("EvolutionComponent", UIComponent)
local PetEvolveData = require("Data.pet_evolve_data")
local TriggerConst = require("Common.Const.TriggerConst")
local ClientConst = require("Const.ClientConst")
local CustomTriggerData = require("Data.custom_trigger_data")
local Const = require("Common.Const.Const")
local ItemSourceData = require("Data.item_source_data")
local UIUtils = UIUtils
local bit = bit
local PetManagementUtils = require("Utils.PetManagementUtils")
local TimerManager = require("Core.Timer.TimerManager")
local PetData = require("Data.pet_data")
local lshift = bit.lshift
local LuaUIUtils = require("Utils.LuaUIUtils")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local Utils = require("Common.Utils.Utils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local UIConst = require("Const.UIConst")
local AddressDataConst = require("Const.AddressDataConst")

function EvolutionComponent:findObjects()
	self.objectReference = self.view.evolutionUComponent.transform:GetComponent("ObjectReference")
	self.qualityUButton = self.objectReference:GetRefValue("qualityUButton")
	self.conditionList = self.objectReference:GetRefValue("conditionList")
	self.itemList = self.objectReference:GetRefValue("itemList")
	self.btnEvolveUButton = self.objectReference:GetRefValue("btnEvolveUButton")
	self.titleUText = self.objectReference:GetRefValue("titleUText")
	self.nameChangeUSDFText = self.objectReference:GetRefValue("nameChangeUSDFText")
	self.nameChange1USDFText = self.objectReference:GetRefValue("nameChange1USDFText")
	self.descText = self.objectReference:GetRefValue("descText")
	self.clickObject = self.objectReference:GetRefValue("clickObject")
	self.selected = self.objectReference:GetRefValue("selected")
	self.branchInfoUWidget = self.objectReference:GetRefValue("branchInfoUWidget")
	self.detailInfoListChar = self.objectReference:GetRefValue("detailInfoListChar")
	self.unlockTitleUWidget = self.objectReference:GetRefValue("unlockTitleUWidget")
	self.unlockListUList = self.objectReference:GetRefValue("unlockListUList")
	self.manualPetSkillUButton = self.objectReference:GetRefValue("manualPetSkillUButton")
	self.consumeUWidget = self.objectReference:GetRefValue("consumeUWidget")
	self.branchInfoUComponent = self.objectReference:GetRefValue("branchInfoUComponent")

	local branchInfoObjectReference = self.branchInfoUComponent:GetComponent("ObjectReference")

	self.elementListUList = branchInfoObjectReference:GetRefValue("elementListUList")
	self.listTagUList = branchInfoObjectReference:GetRefValue("listTagUList")

	function self.listTagUList.luaRenderItem(button, idx, data)
		LuaUIUtils.renderPetTagList(button, data)
		LuaUIUtils.setPetTagLabelToolTip(button, LuaUIUtils.getPetTagInfo(self.templateId, self.petInfo.label, self.petInfo.bodySizeType, self.petInfo.shinyStyle))
	end

	self.formName = branchInfoObjectReference:GetRefValue("formName")
	self.evolveBtnName = self.btnEvolveUButton.transform:GetComponent("ObjectReference"):GetRefValue("txtNameUText")
	self.timers = {}
	self.consoleSelectedAnchor = self.objectReference:GetRefValue("consoleselectedAnchorTransform")
	self.consoleSelectedUWidget = self.objectReference:GetRefValue("consoleselectedUWidget")
	self.virtualBtnUButton = self.objectReference:GetRefValue("virtualBtnUButton")
end

function EvolutionComponent:initView()
	self.tabIdx = UIConst.HANDBOOK_PAGE_IDX.EVOLUTION
	self.clickObject.camera = pg.global.cameraMgr.uiSceneCameraInst
	self.clickObject.layerMask = lshift(1, ClientConst.LayerDefine.LAYER_UI_SCENE)

	function self.clickObject.luaClick(go)
		self:onClickScreen(go)
	end

	function self.conditionList.luaRenderItem(button, idx, data)
		self:renderEvolveConditionList(button, idx, data)
	end

	function self.conditionList.luaFinishRender(list)
		return
	end

	function self.unlockListUList.luaRenderItem(button, idx, data)
		self:renderEvolveConditionList(button, idx, data)
	end

	function self.itemList.luaRenderItem(button, idx, data)
		self:renderEvolveItemList(button, idx, data)
	end

	function self.elementListUList.luaRenderItem(button, idx, data)
		LuaUIUtils.setElementButtonNew(button, data.element, true, data.petId)
	end
end

function EvolutionComponent:onPetSelectChange(petId)
	self.petScene = self.ctrl.uiScene
	self.petId = petId
	self.petInfo = pg.me:getPetInfo(self.petId)
	self.petInfoDetails = self.model:setUpPetInfo(self.petId)
	self.templateId = self.petInfo.templateId

	LuaUIUtils.setUIViewVisible(self.branchInfoUWidget, false)
	LuaUIUtils.setUIViewVisible(self.selected, false)
	self:tryDefaultSelect()

	local tagDatas = LuaUIUtils.getPetTagList(self.petInfo)
	local ret = {}

	for idx = 2, #tagDatas do
		ret[#ret + 1] = tagDatas[idx]
	end

	self.listTagUList:SetList(ret)
	self.branchInfoUComponent:TryChangePage("isChange", self.petInfoDetails.isVariant and 1 or 0)
end

function EvolutionComponent:getRealCostItem()
	return pg.game.petManage:getRealCostItem(pg.me, self.itemConditions)
end

function EvolutionComponent:renderEvolveConditionList(button, idx, data)
	local objectReference = button:GetComponent("ObjectReference")
	local vxGlowUWidget = objectReference:GetRefValue("vxGlowUWidget")
	local desc = objectReference:GetRefValue("textUBaseText")

	LuaUIUtils.setUIViewVisible(vxGlowUWidget, false)
	ClientTextUtils.setText(desc, data.desc)

	if data.reached then
		button:TryChangePage("Reached", 1)

		local timer = TimerManager.addTimer((data.count - 1) * 0.2, function()
			LuaUIUtils.setUIViewVisible(vxGlowUWidget, true)
		end)

		self.timers[timer] = timer
	else
		button:TryChangePage("Reached", 0)
	end

	button:TryChangePage("Condition", 0)

	button.enabledTooltip = false

	if data.sourceParam and ItemSourceData[data.sourceParam[2]] then
		button:TryChangePage("Arrow", 0)
		LuaUIUtils.itemSourceTrigger(button, ItemSourceData[data.sourceParam[2]])
	else
		button.luaClick = nil

		button:TryChangePage("Arrow", 1)
	end
end

function EvolutionComponent:renderEvolveItemList(button, idx, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("itemIconUImage")
	local txtNumUText = objectReference:GetRefValue("txtNumUText")

	txtNumUText.disabledLocalization = true

	local beReplaced = false
	local replacedNum = 0

	for _, v in pairs(self.replacedInfo) do
		if v.oriItemId == data.id then
			beReplaced = true
			replacedNum = v.oriNum

			break
		end
	end

	if beReplaced then
		button:TryChangePage("Exchange", 1)
	else
		button:TryChangePage("Exchange", 0)
	end

	function button.luaClick()
		if pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_ITEM_TIP) then
			pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)
		else
			pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
				id = data.id,
				num = data.ownNum,
				targetRect = button
			})
		end
	end

	function button.luaTooltipPopup(_, open)
		button.isSelected = open
	end

	button:TryChangePage("Quality", data.quality)

	iconUImage.url = data.icon

	if beReplaced then
		LuaUIUtils.renderConsumeText(txtNumUText, data.ownNum + replacedNum, data.requiredNum, 2)
	else
		LuaUIUtils.renderConsumeText(txtNumUText, data.ownNum, data.requiredNum, 1)
	end
end

function EvolutionComponent:onClickScreen(go)
	if not go then
		return
	end

	local name = go.name

	if IsNil(go.transform.parent) then
		return
	end

	name = go.transform.parent.name

	if string.sub(name, 1, 12) == "evolveGraph_" then
		local infos = string.split(name, "_")

		self.branchId = tonumber(infos[2])

		self:showEvolveCondition()

		local evolveData = PetEvolveData[self.templateId]
		local subStageEvolveData = evolveData[self.branchId]

		self.petScene:playPetEvolveAction(subStageEvolveData.targetPetId)
	end
end

function EvolutionComponent:getConsoleSelectListData()
	local listData = {}
	local templateId = self.templateId

	if not templateId then
		return listData
	end

	for branchId, branchInfo in pairs(PetEvolveData[templateId] or EMPTY_TABLE) do
		if branchInfo.targetPetId then
			listData[#listData + 1] = {
				branchId = branchId,
				targetPetId = branchInfo.targetPetId
			}
		end
	end

	return listData
end

function EvolutionComponent:getDefaultConsoleSelectTargetPetId()
	for branchId, branchInfo in pairs(PetEvolveData[self.templateId] or EMPTY_TABLE) do
		if branchInfo.targetPetId and self.branchId == branchId then
			return branchInfo.targetPetId
		end
	end

	return self.templateId
end

function EvolutionComponent:getSelectedEvolveTargetPetId()
	local evolveData = self.templateId and PetEvolveData[self.templateId]
	local branchInfo = evolveData and self.branchId and evolveData[self.branchId]

	return branchInfo and branchInfo.targetPetId
end

function EvolutionComponent:refreshSelectedPetEvolve()
	local targetPetId = self:getSelectedEvolveTargetPetId()
	local petScene = self.petScene or self.ctrl and self.ctrl.uiScene

	if not targetPetId or not petScene or not petScene.selectPetEvolve then
		return
	end

	local function selectTargetPet()
		if self:getSelectedEvolveTargetPetId() == targetPetId then
			petScene:selectPetEvolve(targetPetId)
		end
	end

	selectTargetPet()

	if petScene.registerEntLoadedCallback then
		petScene:registerEntLoadedCallback(targetPetId, selectTargetPet)
	end
end

function EvolutionComponent:refreshConsoleSelectList()
	self:hideConsoleSelectList()

	if not pg.game.input:isUsingGamepad() then
		return
	end

	local listData = self:getConsoleSelectListData()

	self.consoleSelectedItems = self.consoleSelectedItems or {}
	self._consoleSelectedVersion = (self._consoleSelectedVersion or 0) + 1

	local version = self._consoleSelectedVersion

	self.consoleSelectedListData = listData
	self.consoleSelectedFocusTargetPetId = self:getDefaultConsoleSelectTargetPetId()

	self.virtualBtnUButton.gameObject:SetActiveEx(true)
	pg.global.navMgr:FocusItem(self.virtualBtnUButton)

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

function EvolutionComponent:hideConsoleSelectList()
	if self.consoleSelectedItems then
		for i = 1, #self.consoleSelectedItems do
			local item = self.consoleSelectedItems[i]

			if item and NotNil(item.gameObject) then
				item.gameObject:SetActiveEx(false)
			end
		end
	end

	if self.virtualBtnUButton and NotNil(self.virtualBtnUButton.gameObject) then
		self.virtualBtnUButton.gameObject:SetActiveEx(false)
	end

	self.consoleSelectedHasFocused = false
end

function EvolutionComponent:renderConsoleSelectItem(itemGameObject, data)
	if IsNil(itemGameObject) then
		return
	end

	if not data or not data.targetPetId then
		itemGameObject:SetActiveEx(false)

		return
	end

	if data.isPlayerBody then
		itemGameObject.name = data.targetPetId
	else
		itemGameObject.name = "evolveGraph_" .. data.branchId
	end

	local button = itemGameObject:GetComponent("UButton")

	function button.luaClick()
		if not data.isPlayerBody then
			self.branchId = data.branchId

			self:showEvolveCondition()

			if self.petScene and self.petScene.playPetEvolveAction then
				self.petScene:playPetEvolveAction(data.targetPetId)
			end
		end
	end

	local petScene = self.petScene

	if petScene and petScene.registerEntLoadedCallback then
		local targetPetId = data.targetPetId

		petScene:registerEntLoadedCallback(targetPetId, function()
			self:refreshConsoleSelectItemPos(targetPetId)
		end)
	else
		self:SetConsoleSelectItemPos(data.targetPetId, itemGameObject)
	end
end

function EvolutionComponent:refreshConsoleSelectItemPos(targetPetId)
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

function EvolutionComponent:tryFocusConsoleSelectItem(targetPetId, itemGameObject)
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

function EvolutionComponent:SetConsoleSelectItemPos(targetPetId, itemGameObject)
	local petScene = self.petScene
	local anchor = self.consoleSelectedAnchor

	if not petScene or not petScene.getEvolveEntTopWorldPos or not anchor or IsNil(anchor) or IsNil(itemGameObject) then
		return
	end

	local topWorldPos = petScene:getEvolveEntTopWorldPos(targetPetId, self.tabIdx)

	UIUtils.SetRectLocalPosByWorldPos(topWorldPos, anchor.transform)

	local anchorPosition = anchor.transform.anchoredPosition

	itemGameObject.transform.anchoredPosition = anchorPosition
end

function EvolutionComponent:tryEvolve()
	local function requestEvolve()
		pg.me:serverMsg("RPC_CS_StartEvolve", self.petId, self.branchId)
	end

	local function confirmDarkPetEvolve()
		local pet = pg.me:getPetInfo(self.petId)

		if pet and Utils.isLabelDark(pet.label) then
			pg.global.showConfirmMsgRaw(pg.getGameString("IMPORTANT_NOTICE_TITLE"), pg.getGameString("PET_DARK_DISAPPEAR_EVOLUTION_DESC"), requestEvolve)
		else
			requestEvolve()
		end
	end

	local costData, _, replacedInfo = self:getRealCostItem()

	if Utils.tableIsEmptyOrNil(costData) then
		confirmDarkPetEvolve()
	elseif replacedInfo and next(replacedInfo) then
		pg.game.petManage:openUniversalItemConvertTip(replacedInfo, function()
			confirmDarkPetEvolve()
		end)
	else
		confirmDarkPetEvolve()
	end
end

function EvolutionComponent:showEvolveCondition()
	for timerId, _ in pairs(self.timers) do
		TimerManager.removeTimer(timerId)
	end

	self.timers = {}

	local branchInfo = PetEvolveData[self.templateId][self.branchId]
	local targetPos = self.petScene:getEvolveEntPos(branchInfo.targetPetId)

	UIUtils.SetRectLocalPosByWorldPos(targetPos, self.selected.transform)

	local evolveData = PetEvolveData[self.templateId]
	local subStageEvolveData = evolveData[self.branchId]
	local handBookInfo = pg.me.petHandbookMap:getInfo(self.templateId)
	local conditionState = handBookInfo:getEvolveResearchInfoWithDefault(self.branchId):getRawTable()
	local handBookConditionState = conditionState.normalConditionStatus

	self.otherConditionSaf = true

	if subStageEvolveData.normalCondition0 then
		local normalConditionData, validConditionCount = self:getEvolutionNormalConditionData(handBookConditionState, {
			[0] = subStageEvolveData.normalCondition0
		}, true)

		self.unlockListUList:SetList(normalConditionData)
		self.unlockListUList:SetActive(true)
		self.unlockTitleUWidget:SetActive(true)

		self.validConditionCount = validConditionCount
	else
		self.normalConditionData = {}
		self.validConditionCount = 0

		self.unlockListUList:SetActive(false)
		self.unlockTitleUWidget:SetActive(false)
	end

	local normalConditionData, validConditionCount = self:getEvolutionNormalConditionData(handBookConditionState, subStageEvolveData.normalConditions)

	self.normalConditionData = normalConditionData
	self.validConditionCount = self.validConditionCount + validConditionCount

	self.conditionList:SetList(self.normalConditionData)

	self.itemConditions = subStageEvolveData.itemConditions
	self.itemRealCostDict = {}

	if self.itemConditions then
		local items = {}
		local success = true

		items, success, self.replacedInfo = self.model:getRequiredItems(self.itemConditions)

		if not success then
			self.otherConditionSaf = false
		end

		self.itemList:SetList(items)
		LuaUIUtils.setUIViewVisible(self.itemList, true)
		LuaUIUtils.setUIViewVisible(self.consumeUWidget, true)
	else
		LuaUIUtils.setUIViewVisible(self.itemList, false)
		LuaUIUtils.setUIViewVisible(self.consumeUWidget, false)
	end

	if branchInfo.targetPetId then
		PetResearchUtils.setEvolveQuality(self.qualityUButton, branchInfo.targetPetId)
		self:refreshSelectedPetEvolve()

		if NotNil(self.manualPetSkillUButton) then
			self.manualPetSkillUButton:SetActive(false)
		end

		self.elementListUList:SetActive(true)

		local targetPetData = PetData[branchInfo.targetPetId] or {}
		local _, elementListData = LuaUIUtils.getElementInfo(targetPetData.elementType, targetPetData.mainElementType)

		for _, elementData in ipairs(elementListData) do
			elementData.petId = branchInfo.targetPetId
		end

		self.elementListUList:SetList(elementListData)
	end

	ClientTextUtils.setText(self.formName, LuaUIUtils.getPetFormName(self.templateId))
	ClientTextUtils.setText(self.descText, pg.getLocalizationText(subStageEvolveData.simpleDesc))

	local canEvolveBranch = self.petInfo:canEvolveBranch(self.branchId)

	self.btnEvolveUButton:TryChangePage("canEvolve", canEvolveBranch and 1 or 0)
	ClientTextUtils.setText(self.evolveBtnName, pg.getGameString("EVOLVE"))

	if not canEvolveBranch then
		if not self.otherConditionSaf then
			self.btnEvolveUButton.interactable = false
		else
			ClientTextUtils.setText(self.evolveBtnName, pg.getGameString("UPGRADE"))

			self.btnEvolveUButton.interactable = true

			function self.btnEvolveUButton.luaClick()
				PetManagementUtils.onPetLvUpClick(self.petId, PetData[self.templateId].iconName, self.label, Utils.canLevelBreakthrough(self.petId))
			end
		end
	else
		function self.btnEvolveUButton.luaClick()
			self:tryEvolve()
		end

		self.btnEvolveUButton.interactable = true
	end

	LuaUIUtils.setUIViewVisible(self.branchInfoUWidget, true)

	if not canEvolveBranch and branchInfo.targetPetId then
		local targetBook = pg.me.petHandbookMap[branchInfo.targetPetId]
		local isGot = targetBook and targetBook:isCatched()

		if not isGot then
			local nameStr = "???"

			ClientTextUtils.setText(self.titleUText, nameStr)
			ClientTextUtils.setText(self.nameChangeUSDFText, nameStr)
			ClientTextUtils.setText(self.nameChange1USDFText, nameStr)
		else
			local nameStr = pg.getLocalizationText(PetData[branchInfo.targetPetId].name)

			ClientTextUtils.setText(self.titleUText, nameStr)
			ClientTextUtils.setText(self.nameChangeUSDFText, nameStr)
			ClientTextUtils.setText(self.nameChange1USDFText, nameStr)
		end
	else
		ClientTextUtils.setText(self.titleUText, branchInfo.targetPetId and pg.getLocalizationText(PetData[branchInfo.targetPetId].name) or "")
	end
end

function EvolutionComponent:getEvolutionNormalConditionData(handbookState, normalConditions, isPlayerCondition)
	local ret = {}
	local count = 0
	local triggerMap = isPlayerCondition and pg.me.triggerMap or self.petInfo.triggerMap

	for idx, info in pairs(normalConditions or EMPTY_TABLE) do
		local item = {}
		local needCond = info[Const.PET_EVOLVE_NORMAL_COND_POS_COND]
		local conditionInfo = CustomTriggerData[needCond]

		item.reached = triggerMap:isCompleteOrMeetCondition(needCond)

		local triggerType, _ = TriggerConst.getTriggerInfo(conditionInfo.condition[1])

		if triggerType == TriggerConst.PET_TRIGGER_TARGET_LEVEL then
			self.targetLevel = conditionInfo.condition[1][5]
			self.targetLevelReached = item.reached
		elseif not item.reached then
			self.otherConditionSaf = false
		end

		local state = handbookState[idx]

		if state == nil then
			state = info[Const.PET_EVOLVE_NORMAL_COND_POS_STATE]
		end

		if state == Const.PET_RESEARCH.STATUS_CLUE then
			item.desc = pg.getLocalizationText(info[2])
		elseif state == Const.PET_RESEARCH.STATUS_SHOW then
			item.desc = pg.getLocalizationText(info[3])
		elseif state == Const.PET_RESEARCH.STATUS_HIDE then
			item.desc = "????"
		else
			item.desc = ""
		end

		if item.reached then
			count = count + 1
		end

		item.sourceParam = info[5]
		item.count = count
		ret[#ret + 1] = item
	end

	return ret, count
end

function EvolutionComponent:tryDefaultSelect()
	local evolveInfo = PetEvolveData[self.templateId]

	self.branchId = 1

	for idx, branchInfo in pairs(evolveInfo) do
		if branchInfo.targetPetId and self.petInfo:canEvolveBranch(idx) then
			self.branchId = idx

			break
		end
	end

	if self.branchId then
		self:showEvolveCondition()
	end
end

function EvolutionComponent:onDestroy()
	for timerId, _ in pairs(self.timers) do
		TimerManager.removeTimer(timerId)
	end

	self.timers = nil

	UIComponent.onDestroy(self)
end

return EvolutionComponent
