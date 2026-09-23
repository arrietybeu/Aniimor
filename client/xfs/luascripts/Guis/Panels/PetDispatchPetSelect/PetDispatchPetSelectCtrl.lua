-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetDispatchPetSelect\\PetDispatchPetSelectCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local AddressDataConst = require("Const.AddressDataConst")
local PetFormTypeData = require("Data.pet_form_type_data")
local MapBlockConfigData = require("Data.map_block_config_data")
local TriggerConst = require("Common.Const.TriggerConst")
local ActivityConst = require("Common.Const.ActivityConst")
local PetDispatchUtils = require("GameApp.PetDispatch.PetDispatchUtils")
local PetDispatchPetSelectCtrl = Class.LightClass("PetDispatchPetSelectCtrl", UICtrl)

function PetDispatchPetSelectCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function PetDispatchPetSelectCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	info = info or {}
	self.model.eventId = info.eventId
	self.model.clueId = info.clueId
	self.model.mode = info.mode or "leader"
	self.model.slotIndex = info.slotIndex
	self.model.excludePetIds = info.excludePetIds or {}
	self.onPicked = info.onPicked
	self.onClose = info.onClose
	self.model.filter = nil
	self.model.pageIndex = 1
	self.model.conditionsInfos = PetDispatchUtils.getExtraConditions(self.model.clueId) or {}

	self:buildConditionMeta()

	self.model.followerSelections = {}

	if self.model.mode == "follower" then
		for i = 2, ActivityConst.PetDispatchPetMaxNum do
			local petId = self.model.excludePetIds and self.model.excludePetIds[i]

			if petId then
				table.insert(self.model.followerSelections, petId)
			end
		end
	else
		self.model.leaderSelection = self.model.excludePetIds and self.model.excludePetIds[1] or nil
	end

	if self.view.rootComponent then
		self.view.rootComponent:TryChangePage("Caption", self.model.mode == "follower" and 1 or 0)
	end

	self:refreshTitle()
	self:_applyPageCapacity()
	self:refreshList()
end

function PetDispatchPetSelectCtrl:_applyPageCapacity()
	local capacity
	local list = self.view.listPetUList

	if list and list.GetPageCapacity then
		capacity = list:GetPageCapacity()
	end

	self.model:setPageSize(capacity)
end

function PetDispatchPetSelectCtrl:onDestroy()
	if self.onClose then
		self.onClose()
	end

	UICtrl.onDestroy(self)
end

function PetDispatchPetSelectCtrl:addListener()
	if self.view.btnClose then
		function self.view.btnClose.luaClick()
			self:dismiss()
		end
	end

	if self.view.btnCloseUButton then
		function self.view.btnCloseUButton.luaClick()
			self:dismiss()
		end
	end

	if self.view.btnFilter then
		function self.view.btnFilter.luaClick()
			pg.global.ui:open(UIConst.UI_ID_PET_MANAGEMENT_FILTER, {
				disableSessionCache = true,
				noTab = true,
				filter = self.model.filter,
				doFilterCallback = function(filter)
					self.model.filter = filter

					self:refreshList()
				end
			})
		end
	end

	if self.view.listPetUList then
		function self.view.listPetUList.luaRenderItem(button, index, data)
			self:onRenderPetItem(button, index, data)
		end
	end

	if self.view.numSelectorUNumSelector then
		function self.view.numSelectorUNumSelector.luaValueChanged(value)
			if self._lockNumSelector then
				return
			end

			self.model.pageIndex = value

			self:refreshPage()
		end
	end

	if self.view.btnConfirm then
		function self.view.btnConfirm.luaClick()
			self:onConfirm()
		end
	end
end

function PetDispatchPetSelectCtrl:refreshTitle()
	local titleKey = self.model.mode == "follower" and "DISPATCH_PET_MEMBER" or "DISPATCH_PET_LEADER"

	if self.view.textSelectTitle then
		ClientTextUtils.setText(self.view.textSelectTitle, pg.getLocalizationText(pg.getGameString(titleKey)))
	end

	if self.view.textCondition then
		ClientTextUtils.setText(self.view.textCondition, pg.getLocalizationText(pg.getGameString("DISPATCH_PET_LEADER_BUFF")))
	end

	if self.view.txtEmpty then
		ClientTextUtils.setText(self.view.txtEmpty, pg.getLocalizationText(pg.getGameString("DISPATCH_PET_NONE")))
	end

	if self.view.textForm then
		local clueCfg = self.model.clueId and PetDispatchUtils.getClueConfig(self.model.clueId)
		local blockConfig = clueCfg and clueCfg.mapBlockId and MapBlockConfigData[clueCfg.mapBlockId]

		if blockConfig then
			ClientTextUtils.setText(self.view.textForm, pg.getFormatText(pg.getGameString("DISPATCH_TASK_MAP"), pg.getLocalizationText(blockConfig.areaName)))
		end
	end
end

function PetDispatchPetSelectCtrl:refreshList()
	self.model:refresh()

	self.model.pageIndex = 1

	self:syncNumSelector()
	self:refreshPage()
end

function PetDispatchPetSelectCtrl:refreshPage()
	self.btnByPetId = {}

	if self.view.listPetUList then
		self.view.listPetUList:SetList(self.model:getPagedPets())
	end

	if self.view.emptyUWidget then
		self.view.emptyUWidget.gameObject:SetActiveEx(#(self.model.pets or {}) == 0)
	end
end

function PetDispatchPetSelectCtrl:syncNumSelector()
	if not self.view.numSelectorUNumSelector then
		return
	end

	local totalPages = self.model:getTotalPages()

	self._lockNumSelector = true

	self.view.numSelectorUNumSelector:SetAllValue(self.model.pageIndex, 1, totalPages, 1)

	self._lockNumSelector = false
end

function PetDispatchPetSelectCtrl:_showDisabledTip(data)
	if data.dispatching then
		pg.global.ui.tips:showTextTip(pg.getGameString("DISPATCH_TASK_FORBIDDEN"))
	elseif data.outOfBlock then
		local clueConfig = PetDispatchUtils.getClueConfig(self.model.clueId)
		local blockCfg = clueConfig and clueConfig.mapBlockId and MapBlockConfigData[clueConfig.mapBlockId]
		local areaName = blockCfg and pg.getLocalizationText(blockCfg.areaName) or ""

		pg.global.ui.tips:showTextTip(pg.getFormatText(pg.getGameString("DISPATCH_PET_AREAR_BAN_TIP"), areaName))
	end
end

function PetDispatchPetSelectCtrl:onRenderPetItem(button, index, data)
	if not button or not data then
		return
	end

	local petId = data.petId or data.id

	self.btnByPetId = self.btnByPetId or {}

	if petId then
		self.btnByPetId[petId] = button
	end

	local selectionIndex = self:getSelectionIndex(petId)
	local isSelected = selectionIndex > 0
	local locked

	if self.model.mode == "follower" then
		locked = selectionIndex == 1
	else
		locked = selectionIndex >= 2
	end

	local disabled = locked or data.dispatching or data.outOfBlock

	function button.luaClick()
		if disabled then
			self:_showDisabledTip(data)

			return
		end

		self:onPickPet(data, button)
	end

	local objectReference = button:GetComponent("ObjectReference")

	if not objectReference then
		return
	end

	local iconUImage = objectReference:GetRefValue("iconUImage")
	local iconHomeUImage = objectReference:GetRefValue("iconHomeUImage")
	local iconEvolveUImage = objectReference:GetRefValue("iconEvolveUImage")
	local txtBoxUImage = objectReference:GetRefValue("txtBoxUImage")
	local panelCPUContainer = objectReference:GetRefValue("panelCPUContainer")
	local listCharUContainer = objectReference:GetRefValue("listCharUContainer")
	local formItemUButton = objectReference:GetRefValue("formItemUButton")
	local txtName = objectReference:GetRefValue("txtName") or objectReference:GetRefValue("txtNameUSDFText")
	local beingDispatchedUContainer = objectReference:GetRefValue("beingDispatchedUContainer")
	local serialNumberUContainer = objectReference:GetRefValue("serialNumberUContainer")
	local captionUContainer = objectReference:GetRefValue("captionUContainer")
	local praiseUWidget = objectReference:GetRefValue("praiseUWidget")
	local resonanceUContainer = objectReference:GetRefValue("resonanceUContainer")

	if iconHomeUImage then
		iconHomeUImage.gameObject:SetActiveEx(false)
	end

	if iconEvolveUImage then
		iconEvolveUImage:SetActive(false)
	end

	if txtBoxUImage then
		txtBoxUImage:SetActive(false)
	end

	if formItemUButton then
		formItemUButton:SetActive(false)
	end

	if listCharUContainer and listCharUContainer.content then
		listCharUContainer.content.gameObject:SetActiveEx(false)
	end

	if panelCPUContainer and panelCPUContainer.content then
		panelCPUContainer.content.gameObject:SetActiveEx(false)
	end

	if beingDispatchedUContainer then
		beingDispatchedUContainer:SetActive(false)
	end

	if serialNumberUContainer then
		serialNumberUContainer:SetActive(false)
	end

	if captionUContainer then
		captionUContainer:SetActive(false)
	end

	if praiseUWidget then
		praiseUWidget:SetActive(false)
	end

	if resonanceUContainer then
		resonanceUContainer:SetActive(false)
	end

	button.draggable = false
	button.enabledLongPress = false

	if iconUImage then
		iconUImage.url = LuaUIUtils.getPetIcon(data.iconName, LuaUIUtils.PET_ICON, data.label, data.gender)
	end

	LuaUIUtils.renderPetHeadFlashBgAndFrame(objectReference, data.isShiny, data.shinyStyle or 0)

	if data.dispatching then
		if beingDispatchedUContainer then
			beingDispatchedUContainer:SetActive(true)
			beingDispatchedUContainer:LoadDefaultUrlManually()

			local subRef = beingDispatchedUContainer.content and beingDispatchedUContainer.content:GetComponent("ObjectReference")
			local textUSDFText = subRef and subRef:GetRefValue("textUSDFText")

			if textUSDFText then
				ClientTextUtils.setText(textUSDFText, pg.getGameString("DISPATCH_TASK_PET_ONGOING"))
			end
		end

		button:TryChangePage("state", 1)

		return
	end

	if data.outOfBlock then
		button:TryChangePage("state", 1)

		return
	end

	if button.TryChangePage then
		button:TryChangePage("state", 0)
	end

	button.isSelected = isSelected

	if selectionIndex == 1 and captionUContainer then
		captionUContainer:SetActive(true)
		captionUContainer:LoadDefaultUrlManually()
	elseif selectionIndex > 1 and serialNumberUContainer then
		serialNumberUContainer:SetActive(true)
		serialNumberUContainer:LoadDefaultUrlManually()

		local subRef = serialNumberUContainer.content and serialNumberUContainer.content:GetComponent("ObjectReference")
		local txtSelectIndex = subRef and subRef:GetRefValue("txtSelectIndex")

		if txtSelectIndex then
			ClientTextUtils.setText(txtSelectIndex, tostring(selectionIndex))
		end
	end

	if resonanceUContainer and self.model.mode == "leader" and data.isGoldAdveRewarded then
		resonanceUContainer:SetActive(true)
		resonanceUContainer:LoadDefaultUrlManually()
	end

	if praiseUWidget and not isSelected then
		local recommendCount = PetDispatchUtils.getRecommendCount(data)

		if recommendCount > 0 then
			praiseUWidget:SetActive(true)
		end
	end

	if txtName then
		ClientTextUtils.setText(txtName, data.name or "")
	end

	if iconHomeUImage and self:isNeedDisPlayInfo(data, TriggerConst.PET_TRIGGER_CHECK_SCORE_STAGE) and data.rating and data.rating >= 2 then
		iconHomeUImage.gameObject:SetActiveEx(true)

		iconHomeUImage.url = AddressDataConst["PET_RATING_ICON_" .. data.rating]
	end

	if listCharUContainer and self:isNeedDisPlayInfo(data, TriggerConst.PET_TRIGGER_TARGET_HAS_EXPLORE) then
		listCharUContainer:LoadDefaultUrlManually()

		local subList = listCharUContainer.content and listCharUContainer.content:GetComponent("UList")

		if subList then
			function subList.luaRenderItem(b, i, d)
				b:TryChangePage("Char", d.index - 1)
				b:TryChangePage("Quality", d.quality)
			end

			local exploreIndexes = {}
			local condValue = self:getConditionValue(TriggerConst.PET_TRIGGER_TARGET_HAS_EXPLORE)

			if condValue and data.exploreSkillIndexLevel and (data.exploreSkillIndexLevel[condValue] or 0) > 0 then
				exploreIndexes[#exploreIndexes + 1] = {
					index = condValue,
					quality = data.exploreSkillIndexLevel[condValue]
				}
			end

			if #exploreIndexes > 0 then
				listCharUContainer.content.gameObject:SetActiveEx(true)
				subList:SetList(exploreIndexes)
			end
		end
	end

	self:renderPetElements(panelCPUContainer, data)

	if formItemUButton and self:isNeedDisPlayInfo(data, TriggerConst.PET_TRIGGER_TARGET_IS_FORM) then
		self:renderPetForm(formItemUButton, data)
	end
end

function PetDispatchPetSelectCtrl:onPickPet(petData, button)
	local petId = petData.petId or petData.id

	if not petId then
		return
	end

	if self.model.mode ~= "follower" then
		local prev = self.model.leaderSelection

		if prev == petId then
			self.model.leaderSelection = nil
		else
			self.model.leaderSelection = petId
		end

		self:refreshItemSelection(button, petData)

		if prev and prev ~= petId then
			local b = self.btnByPetId and self.btnByPetId[prev]

			if b then
				local d = self:findPetDataById(prev)

				if d then
					self:refreshItemSelection(b, d)
				end
			end
		end

		if self.onPicked then
			self.onPicked(self.model.leaderSelection)
		end

		return
	end

	local affected = {
		[petId] = true
	}

	for _, id in ipairs(self.model.followerSelections or EMPTY_TABLE) do
		affected[id] = true
	end

	local idx = self:findFollowerSelection(petId)

	if idx > 0 then
		table.remove(self.model.followerSelections, idx)
	else
		if #self.model.followerSelections >= ActivityConst.PetDispatchPetMaxNum - 1 then
			pg.global.ui.tips:showTextTip(pg.getLocalizationText(pg.getGameString("DISPATCH_PET_ENOUGH")))

			return
		end

		table.insert(self.model.followerSelections, petId)
	end

	self:refreshItemSelection(button, petData)

	for id in pairs(affected) do
		if id ~= petId then
			local b = self.btnByPetId and self.btnByPetId[id]

			if b then
				local d = self:findPetDataById(id)

				if d then
					self:refreshItemSelection(b, d)
				end
			end
		end
	end

	if self.onPicked then
		self.onPicked(self.model.followerSelections)
	end
end

function PetDispatchPetSelectCtrl:refreshItemSelection(button, data)
	if not button or not data then
		return
	end

	local petId = data.petId or data.id
	local selectionIndex = self:getSelectionIndex(petId)
	local isSelected = selectionIndex > 0

	button.isSelected = isSelected

	local objectReference = button:GetComponent("ObjectReference")

	if not objectReference then
		return
	end

	local captionUContainer = objectReference:GetRefValue("captionUContainer")

	if captionUContainer then
		captionUContainer:SetActive(selectionIndex == 1)

		if selectionIndex == 1 then
			captionUContainer:LoadDefaultUrlManually()
		end
	end

	local serialNumberUContainer = objectReference:GetRefValue("serialNumberUContainer")

	if serialNumberUContainer then
		local showSerial = selectionIndex > 1

		serialNumberUContainer:SetActive(showSerial)

		if showSerial then
			serialNumberUContainer:LoadDefaultUrlManually()

			local subRef = serialNumberUContainer.content and serialNumberUContainer.content:GetComponent("ObjectReference")
			local txtSelectIndex = subRef and subRef:GetRefValue("txtSelectIndex")

			if txtSelectIndex then
				ClientTextUtils.setText(txtSelectIndex, tostring(selectionIndex))
			end
		end
	end

	local praiseUWidget = objectReference:GetRefValue("praiseUWidget")

	if praiseUWidget then
		local recommendCount = not isSelected and PetDispatchUtils.getRecommendCount(data) or 0

		if recommendCount > 0 then
			praiseUWidget:SetActive(true)
		else
			praiseUWidget:SetActive(false)
		end
	end
end

function PetDispatchPetSelectCtrl:onConfirm()
	self:dismiss()
end

function PetDispatchPetSelectCtrl:findFollowerSelection(petId)
	for i, id in ipairs(self.model.followerSelections or EMPTY_TABLE) do
		if id == petId then
			return i
		end
	end

	return 0
end

function PetDispatchPetSelectCtrl:findPetDataById(petId)
	for _, p in ipairs(self.model.pets or EMPTY_TABLE) do
		if p.id == petId then
			return p
		end
	end

	return nil
end

function PetDispatchPetSelectCtrl:getSelectionIndex(petId)
	if not petId then
		return 0
	end

	if self.model.mode == "follower" then
		if self.model.excludePetIds and self.model.excludePetIds[1] == petId then
			return 1
		end

		local idx = self:findFollowerSelection(petId)

		if idx > 0 then
			return idx + 1
		end

		return 0
	end

	if self.model.leaderSelection and self.model.leaderSelection == petId then
		return 1
	end

	for index, id in pairs(self.model.excludePetIds or EMPTY_TABLE) do
		if index ~= 1 and id == petId then
			return index
		end
	end

	return 0
end

function PetDispatchPetSelectCtrl:buildConditionMeta()
	self.model.conditionTypeMap = {}
	self.model.conditionValueMap = {}

	for _, condi in ipairs(self.model.conditionsInfos or EMPTY_TABLE) do
		self.model.conditionTypeMap[condi.type] = true

		if self.model.conditionValueMap[condi.type] == nil then
			self.model.conditionValueMap[condi.type] = {
				value = condi.value,
				condId = condi.condId
			}
		end
	end
end

function PetDispatchPetSelectCtrl:isNeedDisPlayInfo(data, triggerType)
	local petInfo = data

	petInfo = data and data.id and pg.me and pg.me:getPetInfo(data.id) or petInfo

	local condId = self:getConditionCondID(triggerType)

	if petInfo and petInfo.triggerMap and condId then
		return petInfo.triggerMap:isCompleteOrMeetCondition(condId)
	end

	return false
end

function PetDispatchPetSelectCtrl:getConditionValue(triggerType)
	local info = self.model.conditionValueMap and self.model.conditionValueMap[triggerType]

	return info and info.value
end

function PetDispatchPetSelectCtrl:getConditionCondID(triggerType)
	local info = self.model.conditionValueMap and self.model.conditionValueMap[triggerType]

	return info and info.condId
end

function PetDispatchPetSelectCtrl:renderPetElements(panelCPUContainer, data)
	if not panelCPUContainer then
		return
	end

	panelCPUContainer:LoadDefaultUrlManually()

	local content = panelCPUContainer.content

	if not content then
		return
	end

	local objectReference = content:GetComponent("ObjectReference")

	if not objectReference then
		return
	end

	local elementNames = data.elementNames or {}
	local singleElement = objectReference:GetRefValue("singleElement")
	local doubleElement1 = objectReference:GetRefValue("doubleElement1")
	local doubleElement2 = objectReference:GetRefValue("doubleElement2")
	local numCPUText = objectReference:GetRefValue("numCPUSDFText")
	local iconEvolveUImage = objectReference:GetRefValue("iconEvolveUImage")

	if numCPUText then
		local pet = data.id and pg.me and pg.me:getPetInfo(data.id)

		if pet and pet.isCatchReporting and pet:isCatchReporting() then
			ClientTextUtils.setText(numCPUText, "???")
		else
			ClientTextUtils.setText(numCPUText, tostring(data.cp or ""))
		end
	end

	if #elementNames <= 0 then
		content.gameObject:SetActiveEx(false)
	elseif #elementNames == 1 then
		content.gameObject:SetActiveEx(true)
		content:TryChangePage("DetailState", 0)

		if singleElement then
			LuaUIUtils.setElementButtonNew(singleElement, elementNames[1].element)
		end
	else
		content.gameObject:SetActiveEx(true)
		content:TryChangePage("DetailState", 1)

		if doubleElement1 then
			LuaUIUtils.setElementButtonNew(doubleElement1, elementNames[1].element)
		end

		if doubleElement2 then
			LuaUIUtils.setElementButtonNew(doubleElement2, elementNames[2].element)
		end
	end

	if iconEvolveUImage then
		LuaUIUtils.m_renderPetHeadEvolveArrow(iconEvolveUImage, data)
	end
end

function PetDispatchPetSelectCtrl:renderPetForm(formItemUButton, data)
	if not formItemUButton then
		return
	end

	local petFormId = data.formTypeId
	local formTypeData = petFormId and petFormId ~= 0 and PetFormTypeData[petFormId]

	formItemUButton:SetActive(formTypeData ~= nil)

	if not formTypeData then
		return
	end

	local objectReference = formItemUButton:GetComponent("ObjectReference")
	local formIcon = objectReference and objectReference:GetRefValue("formIcon")

	if formIcon then
		formIcon.url = formTypeData.iconSmall
	end
end

return PetDispatchPetSelectCtrl
