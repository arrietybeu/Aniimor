-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Avatar\\Component\\MakeupComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local lume = require("Core.Common.lume")
local Class = require("Core.Framework.Class")
local AddressDataConst = require("Const.AddressDataConst")
local Utils = require("Common.Utils.Utils")
local AvatarPresetData = require("Data.avatar_preset_data")
local AppearanceVariableData = require("Data.appearance_variable_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local MakeupComponent = Class.LightClass("MakeupComponent", UIComponent)
local avatarMakeup = pg.global.avatarMgr.avatarMakeup
local GameConst = CS.FunPlus.WorldX.Const.GameConst

MakeupComponent.MAKEUP_SKIN_GROUP_KEY = "-922667152"
MakeupComponent.MAKEUP_ROUGHNESS_ID = 39362067

function MakeupComponent:findObjects()
	return
end

function MakeupComponent:initView()
	self.presetKey = self.ctrl.presetKey

	local avatarPreset = pg.game.avatar:getAvatarPresetData(self.presetKey) or {}

	self.body = avatarPreset.body
	self.avatarScene = self.ctrl.avatarScene
	self.sortedGroup = {}

	self:loadCurrentMakeupSuitId()
	self:sortConfig()
end

function MakeupComponent:addListener()
	function self.view.squareSelectUList.luaRenderItem(button, index, data)
		self.view:renderMakeUpSelectList(button, data)
	end

	function self.view.squareSelectUList.luaClick(button, data)
		if self.selectedGroupKey == "makeup_suit" and data.makeupList then
			self:onMakeupSuitClicked(data)

			return
		end

		self:onSelectClicked(data)

		local params = self:parseOperation()

		for _, param in ipairs(params) do
			self:onSelectMakeup(data, param.reactionKey, param.kindKey)
		end

		self.ctrl:refreshButtonState()
	end

	function self.view.listPartsUList.luaRenderItem(button, index, data)
		self.view:renderMakeUpSkinSelectList(button, index, data)
	end

	function self.view.listPartsUList.luaClick(button, data)
		self:onSelectClicked(data)

		local params = self:parseOperation()

		for _, param in ipairs(params) do
			self:onSelectMakeup(data, param.reactionKey, param.kindKey)
		end

		self.ctrl:refreshButtonState()
	end

	function self.view.switchUButton.luaClick()
		self.adjustType = (self.adjustType + 1) % 3

		self:switchAdjustType(self.adjustType)
	end

	function self.view.makeupPresetUList.luaRenderItem(button, index, data)
		self.view:renderMakeUpSelectList(button, data)

		if data.makeupList then
			button:TryChangePage("IsWear", data.isSelected and "Yes" or "No")
		end
	end

	function self.view.makeupPresetUList.luaClick(button, data)
		if data.makeupList then
			self:onMakeupSuitClicked(data)
		elseif data.res then
			avatarMakeup:ApplyMakeupPreset(data.res)
		end
	end

	function self.view.decalSelectUList.luaRenderItem(button, index, data)
		button:TryChangePage("IsWear", data.isSelected and "Yes" or "No")
		self.view:renderMakeUpSelectList(button, data)
	end

	function self.view.decalSelectUList.luaClick(button, data)
		self.view.rootUComponent:TryChangePage("AppliqueChoose", "Yes")

		self.selectedReactionKey = data.key

		local isSelected = avatarMakeup:IsReactionSelected(self.selectedGroupKey, self.selectedReactionKey)

		self.view.applyUButton:SetActiveFastest(not isSelected)
		self.view.deleteUButton:SetActiveFastest(isSelected)

		if not isSelected then
			avatarMakeup:PreviewDecal(data.key)
		end
	end

	function self.view.applyUButton.luaClick()
		avatarMakeup:AddMakeupSelectCommand(self.selectedReactionKey, false)
		avatarMakeup:SelectMakeup(self.selectedReactionKey, true, false, function(success)
			if success then
				avatarMakeup:UpdateMakeupSelectCommand(self.selectedReactionKey)
				self:clearCurrentMakeupSuitSelection()
				avatarMakeup:UpdateMakeupSelectCommand(self.selectedReactionKey)
				self.ctrl:refreshButtonState()
				self:refreshDecalSelectList()
			else
				pg.global.showBubbleMessageRaw(pg.getGameString("CREATE_PLAYER_COUNT_REACH"), 3)
			end
		end)
		self.view.rootUComponent:TryChangePage("AppliqueChoose", "No")
	end

	function self.view.deleteUButton.luaClick()
		avatarMakeup:SelectMakeup(self.selectedReactionKey, false, false)
		self.ctrl:refreshButtonState()
		self:refreshDecalSelectList()
		self:clearCurrentMakeupSuitSelection()
		self.view.rootUComponent:TryChangePage("AppliqueChoose", "No")
	end

	function self.view.editUButton.luaClick()
		self.view.rootUComponent:TryChangePage("Info", "AppliqueEdit")
		avatarMakeup:AddMakeupSelectCommand(self.selectedReactionKey, false)
		avatarMakeup:SelectMakeup(self.selectedReactionKey, true, false, function(success)
			if success then
				avatarMakeup:UpdateMakeupSelectCommand(self.selectedReactionKey)
				self:clearCurrentMakeupSuitSelection()
				avatarMakeup:UpdateMakeupSelectCommand(self.selectedReactionKey)
				self.ctrl:refreshButtonState()

				local operations = self:getCurOperations()

				self.view.operationUList:SetList(operations)
			else
				pg.global.showBubbleMessageRaw(pg.getGameString("CREATE_PLAYER_COUNT_REACH"), 3)
			end
		end)
		self:refreshDecalSelectList()
		self.view.rootUComponent:TryChangePage("AppliqueChoose", "No")
		self:refreshDecalEditState(true)
	end

	local function onClose()
		self.view.rootUComponent:TryChangePage("Info", "Applique")
		avatarMakeup:ResetToPreset(self.selectedReactionKey)
		self:refreshDecalEditState(false)
	end

	self.view.closeUButton.luaClick = onClose

	self.view.closeUButtonConsole:SetGamepadAction("Raw/GamepadButtonEast", nil, onClose)

	function self.view.conformUButton.luaClick()
		self.view.rootUComponent:TryChangePage("Info", "Applique")
		self:refreshDecalEditState(false)
	end

	function self.view.shortOperationUList.luaRenderItem(button, index, data)
		self:renderOperationList(button, data)
	end

	function self.view.operationUList.luaRenderItem(button, index, data)
		self:renderOperationList(button, data)
	end

	function self.view.globalEffectList.luaRenderItem(button, index, data)
		local curValue = avatarMakeup:GetEmissiveIntensity(data.opName)

		AvatarUtils.renderSlider(button, data, curValue, function(value)
			avatarMakeup:EditSkin(value)
			self.ctrl.bubbleComponent:setNormalValue(value, data.displayName)
			self.ctrl.bubbleComponent:show()
		end, function()
			self:clearCurrentMakeupSuitSelection()
			avatarMakeup:FinishEditSkin()
			self.ctrl.bubbleComponent:hide()
		end, function()
			avatarMakeup:StartEditSkin(data.opName)
		end)
	end
end

function MakeupComponent:parseOperation()
	local params = {}

	if not self.selectedReactionKey then
		table.insert(params, {
			reactionKey = self.selectedReactionKey
		})

		return params
	end

	local isEyeball = self.model:isEyeball(self.originConfig, self.selectedGroupKey)
	local isDynamicEyeball = self.model:isDynamicEyeball(self.originConfig, self.selectedGroupKey)

	if isEyeball or isDynamicEyeball then
		local reactionKeyL = 10 * self.selectedReactionKey + 1
		local reactionKeyR = 10 * self.selectedReactionKey + 2

		if self.adjustType == self.model.ADJUST_TYPE.LEFT then
			table.insert(params, {
				reactionKey = reactionKeyL,
				kindKey = self.model.EYE_KIND.L
			})
		elseif self.adjustType == self.model.ADJUST_TYPE.BOTH then
			table.insert(params, {
				reactionKey = reactionKeyL,
				kindKey = self.model.EYE_KIND.L
			})
			table.insert(params, {
				reactionKey = reactionKeyR,
				kindKey = self.model.EYE_KIND.R
			})
		elseif self.adjustType == self.model.ADJUST_TYPE.RIGHT then
			table.insert(params, {
				reactionKey = reactionKeyR,
				kindKey = self.model.EYE_KIND.R
			})
		end
	else
		table.insert(params, {
			reactionKey = self.selectedReactionKey,
			kindKey = self.selectedKindKey
		})
	end

	return params
end

function MakeupComponent:renderOperationList(button, data)
	local isEyeball = self.model:isEyeball(self.originConfig, self.selectedGroupKey)
	local isDynamicEyeball = self.model:isDynamicEyeball(self.originConfig, self.selectedGroupKey)
	local isSkin = self.selectedGroupKey == MakeupComponent.MAKEUP_SKIN_GROUP_KEY
	local eyeballKey = self.adjustType == self.model.ADJUST_TYPE.LEFT and data.key_L or data.key_R

	if data.tIndex == 0 then
		local curValue = avatarMakeup:GetReactionDataValue(data.key, data.opName)

		if isEyeball or isDynamicEyeball then
			curValue = avatarMakeup:GetReactionDataValue(eyeballKey, data.opName)
		end

		AvatarUtils.renderSlider(button, data, curValue, function(value)
			for _, param in ipairs(self.sliderParams) do
				avatarMakeup:EditReactionData(param.reactionKey, value)
			end

			self.ctrl.bubbleComponent:setNormalValue(value, data.displayName)
			self.ctrl.bubbleComponent:show()
		end, function()
			self:clearCurrentMakeupSuitSelection()

			for _, param in ipairs(self.sliderParams) do
				avatarMakeup:FinishEditReactionData(param.reactionKey)
			end

			self.sliderParams = {}

			self.ctrl.bubbleComponent:hide()
		end, function()
			self.sliderParams = self:parseOperation()

			for _, param in ipairs(self.sliderParams) do
				avatarMakeup:StartEditReactionData(param.reactionKey, data.opName)
			end
		end)

		if not isSkin and data.displayName == MakeupComponent.MAKEUP_ROUGHNESS_ID then
			local objectReference = button:GetComponent("ObjectReference")
			local nameUText = objectReference:GetRefValue("nameUText")

			ClientTextUtils.setText(nameUText, pg.getGameString("CREATE_GLOSS"))
		end
	elseif data.tIndex == 2 then
		local color = avatarMakeup:GetColor(data.key, data.opName)

		if isEyeball or isDynamicEyeball then
			color = avatarMakeup:GetColor(eyeballKey, data.opName)
		end

		AvatarUtils.renderColor(button, {
			color = color,
			displayName = data.displayName
		}, function()
			self.selectedColorOperation = data.opName
			self.colorParams = self:parseOperation()

			for _, param in ipairs(self.colorParams) do
				avatarMakeup:AddColorCommand(param.reactionKey, data.opName, color)
			end

			self._pendingColorPickerRefresh = true

			pg.global.ui.colorPicker:open({
				color = color,
				colorValueChangedCb = function(_, colorCode)
					self:onColorPickerValueChanged(colorCode)
				end,
				cancelCb = function()
					self:cancelColor()
				end,
				confirmCb = function(_, colorCode)
					self:confirmColor(colorCode)
				end,
				closeCb = function()
					self._pendingColorPickerRefresh = false

					self.ctrl:refreshButtonState()
				end,
				colorAreas = AvatarUtils.getColorAreas(AvatarUtils.COLOR_PANEL.MAKEUP_COLOR)
			})
		end)
	elseif data.tIndex == 4 then
		local transformLocked = avatarMakeup:GetDecalReactionTransformLockStatus(self.selectedReactionKey)

		AvatarUtils.renderOperationCollection(button, data, function(btn, idx, subData, parentDisplayName)
			if subData.tIndex == 0 then
				local curValue = avatarMakeup:GetReactionDataValue(self.selectedReactionKey, subData.opName)

				AvatarUtils.renderSlider(btn, subData, curValue, function(value)
					avatarMakeup:EditReactionData(self.selectedReactionKey, value)
					self.ctrl.bubbleComponent:setNormalValue(value, subData.displayName)
					self.ctrl.bubbleComponent:show()
				end, function()
					self:clearCurrentMakeupSuitSelection()
					avatarMakeup:FinishEditReactionData(self.selectedReactionKey)
					self.ctrl.bubbleComponent:hide()
				end, function()
					avatarMakeup:StartEditReactionData(self.selectedReactionKey, subData.opName)
				end, parentDisplayName)
			end
		end, transformLocked)
	end
end

function MakeupComponent:onDestroy()
	self.presetKey = nil
	self.avatarScene = nil
	self.sortedGroup = {}
	self.selectedKindKey = nil
	self.currentMakeupSuitId = nil
end

function MakeupComponent:sortConfig()
	local makeupPresetKey = AvatarUtils.getCurrentPartAssetId(self.avatarScene, self.presetKey, "makeup")
	local AvatarMakeupData = require(string.format("Data.Avatar.makeup.makeup_%s_data", makeupPresetKey))

	self.originConfig = Utils.deepCopyTable(AvatarMakeupData)
	self.sortedGroup = AvatarUtils.getSortedGroup(self.originConfig)

	if not pg.me then
		return
	end

	table.insert(self.sortedGroup, 1, {
		key = "makeup_suit",
		displayName = pg.getGameString("MAKEUP_SUIT_TAB"),
		icon = AppearanceVariableData.MAKEUP_SET_ICON
	})
end

function MakeupComponent:onEnterPage()
	self:addListener()
	self:loadCurrentMakeupSuitId()
	ClientTextUtils.setText(self.view.titleShadowUSDFText, pg.getGameString("CREATE_PLAYER_MAKEUP"))
	self.view.firstSortUList:SetList(self.sortedGroup)

	local res, btn = self.view.firstSortUList:TryGetChildAt(0)

	if res then
		btn:OnClickSimulate()
	end

	self.view.firstSortUList:GoToIndex(0, true)
	self.avatarScene:setAvatarCameraModeCloseHead()
end

function MakeupComponent:onExitPage()
	return
end

function MakeupComponent:onFirstSortSelected(groupKey)
	self.selectedGroupKey = groupKey
	self.selectedKindKey = nil

	if groupKey == "makeup_suit" then
		self.view.rootUComponent:TryChangePage("Info", "Makeup")
		self.view.rightPanelUComponent:TryChangePage("MakeUp", 0)
		self.view.secondSortUList:SetList({})
		self.view.switchUButton:SetActiveFastest(false)
		self.view.shortOperationUList:SetList({})
		self:refreshMakeupSuitSelectList()
	elseif groupKey == "preset" then
		self.view.rootUComponent:TryChangePage("Info", "MakeupTemplate")
		self.view.secondSortUList:SetList({})

		local presetList = self.model:getMakeUpPresetList(self.body)

		self.view.makeupPresetUList:SetList(presetList)
	else
		local groupData = self.originConfig[groupKey] or {}

		self.view.secondSortUList:SetList({})
		self.view.switchUButton:SetActiveFastest(false)

		local realizeType = groupData.realizeType

		if realizeType == GameConst.MAKE_UP_DECAL then
			self.view.rootUComponent:TryChangePage("Info", "Applique")
			self:refreshDecalSelectList()
			self.view.decalSelectUList:GoToIndex(0)

			local emissionReaction = {
				displayName = pg.getGameString("CREATE_PLAYER_EMISSION"),
				opName = AvatarUtils.OP_NAME.emission
			}

			self.view.globalEffectList:SetList({
				emissionReaction
			})
		else
			self.view.rootUComponent:TryChangePage("Info", "Makeup")

			local kindList = self.model:getMakeupKindList(self.originConfig, groupKey)

			if kindList then
				self.view.secondSortUList:SetList(kindList)

				local res, btn = self.view.secondSortUList:TryGetChildAt(0)

				if res then
					btn:OnClickSimulate()
				end

				self.view.secondSortUList:GoToIndex(0, true)
			else
				self.selectedKindKey = nil

				self:refreshMakeupSquareList(groupKey, nil)
			end
		end

		self:refreshMakeupPageConsoleBarState()
	end
end

function MakeupComponent:onSecondSortSelected(groupKey, kindKey)
	if groupKey ~= self.selectedGroupKey then
		return
	end

	self.selectedKindKey = kindKey

	self:refreshMakeupSquareList(groupKey, kindKey)
end

function MakeupComponent:refreshMakeupSquareList(groupKey, kindKey)
	local isEyeball = self.model:isEyeball(self.originConfig, groupKey)
	local isDynamicEyeball = self.model:isDynamicEyeball(self.originConfig, groupKey)
	local isSkin = groupKey == MakeupComponent.MAKEUP_SKIN_GROUP_KEY

	if isSkin then
		self.view.rightPanelUComponent:TryChangePage("MakeUp", 1)
	else
		self.view.rightPanelUComponent:TryChangePage("MakeUp", 0)
	end

	if isEyeball or isDynamicEyeball then
		self.view.switchUButton:SetActiveFastest(true)

		self.adjustType = self.adjustType or self.model.ADJUST_TYPE.BOTH

		self:switchAdjustType(self.adjustType)
	end

	local reactionList = self.model:getMakeUpList(self.originConfig, groupKey, self.body, kindKey)
	local index = self:getSelectItemIndex(groupKey, reactionList, kindKey)

	if isSkin then
		for _, v in pairs(reactionList) do
			v.tIndex = 0
		end

		self.view.listPartsUList:SetList(reactionList)
	else
		local colCount = (isEyeball or isDynamicEyeball) and 3 or 2

		self.view.squareSelectUList.colCount = colCount

		self.view.squareSelectUList:SetList(reactionList)
	end

	if index and #reactionList >= index + 1 then
		self.selectedReactionKey = reactionList[index + 1].key

		if isSkin then
			self.view.listPartsUList:SelectItem(index)
			self:onSelectClicked(self.view.listPartsUList.selectedItem)
			self.view.listPartsUList:GoToIndex(index)
		else
			self.view.squareSelectUList:SelectItem(index)
			self:onSelectClicked(self.view.squareSelectUList.selectedItem)
			self.view.squareSelectUList:GoToIndex(index)
		end
	else
		self.view.shortOperationUList:SetList({})
	end
end

function MakeupComponent:refreshDecalEditState(active)
	self.InDecalEditState = active

	self:refreshMakeupPageConsoleBarState()
end

function MakeupComponent:refreshMakeupPageConsoleBarState()
	local groupData = self.originConfig[self.selectedGroupKey] or {}
	local realizeType = groupData.realizeType
	local showHotkeyChoose = realizeType ~= GameConst.MAKE_UP_DECAL or self.InDecalEditState == true

	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("ConsoleBar_PinchFace_Choose", showHotkeyChoose)
end

function MakeupComponent:getSelectItemIndex(groupKey, reactionList, kindKey)
	local isEyeball = self.model:isEyeball(self.originConfig, groupKey)
	local isDynamicEyeball = self.model:isDynamicEyeball(self.originConfig, groupKey)

	if isEyeball or isDynamicEyeball then
		if self.adjustType == self.model.ADJUST_TYPE.LEFT then
			local reactionKey = avatarMakeup:GetSelectedReactionKey(groupKey, self.model.EYE_KIND.L)

			for index, reaction in ipairs(reactionList) do
				if reaction.key_L == reactionKey then
					return index - 1
				end
			end
		else
			local reactionKey = avatarMakeup:GetSelectedReactionKey(groupKey, self.model.EYE_KIND.R)

			for index, reaction in ipairs(reactionList) do
				if reaction.key_R == reactionKey then
					return index - 1
				end
			end
		end
	else
		local reactionKey = avatarMakeup:GetSelectedReactionKey(groupKey, kindKey)

		for index, reaction in ipairs(reactionList) do
			if reaction.key == reactionKey then
				return index - 1
			end
		end
	end
end

function MakeupComponent:getCurOperations()
	local sourceData = self.model:getMakeupKindData(self.originConfig, self.selectedGroupKey, self.selectedKindKey)
	local reactionList = sourceData.reactionList or {}

	for _, reaction in ipairs(reactionList) do
		if reaction.key == self.selectedReactionKey then
			local operations = reaction.operations or {}
			local res = {}

			for _, operation in pairs(operations) do
				local op = Utils.deepCopyTable(operation)

				op.key = reaction.key
				op.key_L = reaction.key_L
				op.key_R = reaction.key_R

				table.insert(res, op)
			end

			if reaction.opCollections then
				for _, opCollection in pairs(reaction.opCollections) do
					local info = Utils.deepCopyTable(opCollection)

					info.tIndex = 4

					table.insert(res, info)
				end
			end

			return res
		end
	end

	return {}
end

function MakeupComponent:onColorPickerValueChanged(colorCode)
	local r, g, b, a = lume.color(colorCode)
	local color = Color(r, g, b, a)

	for _, param in ipairs(self.colorParams) do
		avatarMakeup:PreviewColorChange(param.reactionKey, self.selectedColorOperation, color)
	end
end

function MakeupComponent:cancelColor()
	for _, param in ipairs(self.colorParams) do
		avatarMakeup:RemoveColorCommand()
	end

	self.colorParams = {}
end

function MakeupComponent:confirmColor(colorCode)
	local r, g, b, a = lume.color(colorCode)
	local color = Color(r, g, b, a)

	self:clearCurrentMakeupSuitSelection()

	for _, param in ipairs(self.colorParams) do
		avatarMakeup:ApplyColor(param.reactionKey, self.selectedColorOperation, color)
		avatarMakeup:UpdateColorCommand(param.reactionKey, color)
	end

	self.view.shortOperationUList:RefreshList()
	self.view.operationUList:RefreshList()
end

function MakeupComponent:switchAdjustType(type)
	if self.model.ADJUST_TYPE.LEFT == type then
		self.view.switchUButton:TryChangePage("Switch", "Right")
	elseif self.model.ADJUST_TYPE.BOTH == type then
		self.view.switchUButton:TryChangePage("Switch", "Both")
	elseif self.model.ADJUST_TYPE.RIGHT == type then
		self.view.switchUButton:TryChangePage("Switch", "Left")
	end
end

function MakeupComponent:onSelectClicked(data)
	self.selectedReactionKey = data.key

	local operations = self:getCurOperations() or {}

	self.view.shortOperationUList:SetList(operations)
end

function MakeupComponent:onSelectMakeup(data, reactionKey, kindKey)
	avatarMakeup:AddMakeupSelectCommand(reactionKey, true)

	if data.state == "Null" then
		avatarMakeup:ClearMakeup(self.selectedGroupKey, kindKey)
		self:clearCurrentMakeupSuitSelection()
		avatarMakeup:UpdateMakeupSelectCommand(reactionKey)

		return
	end

	local groupData = self.originConfig[self.selectedGroupKey] or {}
	local allowMulti = groupData.allowedMultiSelect

	if allowMulti then
		local isSelected = avatarMakeup:IsReactionSelected(self.selectedGroupKey, reactionKey)

		avatarMakeup:SelectMakeup(reactionKey, not isSelected, false)
	else
		avatarMakeup:SelectMakeup(reactionKey, true, true)
	end

	self:clearCurrentMakeupSuitSelection()
	avatarMakeup:UpdateMakeupSelectCommand(reactionKey)
end

function MakeupComponent:refreshDecalSelectList()
	local reactionList = self.model:getMakeUpList(self.originConfig, self.selectedGroupKey, self.body)

	self.view.decalSelectUList:SetList(reactionList)
end

function MakeupComponent:skipRefreshOnVisible()
	return self._pendingColorPickerRefresh == true
end

function MakeupComponent:refreshComponent()
	local restoreDecalEdit = self.InDecalEditState == true
	local reactionKey = self.selectedReactionKey

	self:onFirstSortSelected(self.selectedGroupKey)

	if restoreDecalEdit and reactionKey then
		self.selectedReactionKey = reactionKey

		self.view.rootUComponent:TryChangePage("Info", "AppliqueEdit")

		local operations = self:getCurOperations()

		self.view.operationUList:SetList(operations)
		self:refreshDecalEditState(true)
	end
end

function MakeupComponent:onMakeupSuitClicked(data)
	local suitId = tonumber(data.id) or data.id

	if suitId == tonumber(self.currentMakeupSuitId) then
		return
	end

	if not data.owned then
		pg.global.showBubbleMessageRaw(pg.getGameString("MAKEUP_SUIT_NOT_OWNED"))

		return
	end

	local function doApply()
		self:applyMakeupSuit(data)
	end

	if self.currentMakeupSuitId ~= nil then
		doApply()
	else
		local hasCustomMakeup = self:hasAnyMakeupSelected()

		if hasCustomMakeup then
			pg.global.showConfirmMsgRaw(pg.getGameString("MAKEUP_SUIT_CONFIRM_TITLE"), pg.getGameString("MAKEUP_SUIT_CONFIRM_DESC"), function()
				doApply()
			end)
		else
			doApply()
		end
	end
end

function MakeupComponent:applyMakeupSuit(data)
	avatarMakeup:BeginMakeupSuitCommand()

	local preservedSelections = self:collectPreservedMakeupSelections()
	local coveredSlotKeys = self:getSuitCoveredSlotKeys(data.makeupList)

	avatarMakeup:ResetMakeupVisualStateBeforeImport()

	for _, configId in ipairs(data.makeupList) do
		local groupKey, groupData, reaction = self:findReactionEntryByConfigId(configId)

		if groupKey and reaction then
			self:applyMakeupReactionKeys(groupKey, groupData, reaction)
		end
	end

	for _, selection in ipairs(preservedSelections) do
		if not coveredSlotKeys[selection.slotKey] then
			local allowMulti = selection.groupData.allowedMultiSelect

			avatarMakeup:SelectMakeup(selection.reactionKey, true, not allowMulti)
		end
	end

	self:storeCurrentMakeupSuitId(data.id)
	avatarMakeup:EndMakeupSuitCommand(data.id)
	self.ctrl:refreshButtonState()
	self:refreshMakeupSuitSelectList()
end

function MakeupComponent:refreshMakeupSuitSelectList()
	self:loadCurrentMakeupSuitId()

	local suitList = self.model:getMakeupSuitList(self.body)
	local currentSuitId = tonumber(self.currentMakeupSuitId) or tonumber(avatarMakeup:GetMakeupSuitId())
	local selectIndex

	for index, suitData in ipairs(suitList) do
		local suitId = tonumber(suitData.id)
		local isSelected = currentSuitId and suitId and suitId == currentSuitId

		suitData.isSelected = isSelected
		suitData.tIndex = 0

		if isSelected then
			selectIndex = index - 1
		end
	end

	self.view.squareSelectUList.colCount = 3

	self.view.squareSelectUList:SetList(suitList)

	if selectIndex ~= nil then
		self.view.squareSelectUList:SelectItem(selectIndex)
		self.view.squareSelectUList:GoToIndex(selectIndex, true)
	else
		self.view.squareSelectUList:DeselectAll()
	end
end

function MakeupComponent:loadCurrentMakeupSuitId()
	local suitId = avatarMakeup:GetMakeupSuitId()

	if suitId and suitId > 0 then
		self.currentMakeupSuitId = suitId
	else
		self.currentMakeupSuitId = nil
	end
end

function MakeupComponent:storeCurrentMakeupSuitId(suitId)
	local normalizedSuitId = tonumber(suitId)

	if normalizedSuitId and normalizedSuitId > 0 then
		self.currentMakeupSuitId = normalizedSuitId

		avatarMakeup:StoreMakeupSuitId(normalizedSuitId)
	else
		self.currentMakeupSuitId = nil

		avatarMakeup:StoreMakeupSuitId(-1)
	end
end

function MakeupComponent:clearCurrentMakeupSuitSelection()
	if self.selectedGroupKey == "makeup_suit" then
		return
	end

	self:storeCurrentMakeupSuitId(nil)
end

function MakeupComponent:isRemovableMakeupKind(groupKey, kindKey)
	local sourceData = self.model:getMakeupKindData(self.originConfig, groupKey, kindKey)
	local realizeType = sourceData.realizeType

	if realizeType == GameConst.MAKE_UP_DECAL then
		return true
	end

	if realizeType == GameConst.MAKE_UP_FIXED_DECAL then
		return true
	end

	if self.model:isDynamicEyeball(self.originConfig, groupKey) then
		return true
	end

	return false
end

function MakeupComponent:getMakeupSelectionSlotKey(groupKey, kindKey)
	return groupKey .. ":" .. (kindKey or "")
end

function MakeupComponent:collectPreservedMakeupSelections()
	local preserved = {}

	for groupKey, groupData in pairs(self.originConfig) do
		if groupData.kindList then
			for kindKey, _ in pairs(groupData.kindList) do
				self:appendPreservedMakeupSelections(preserved, groupKey, groupData, kindKey)
			end
		else
			self:appendPreservedMakeupSelections(preserved, groupKey, groupData, nil)
		end
	end

	return preserved
end

function MakeupComponent:isRegularEyeballGroup(groupKey)
	return self.model:isEyeball(self.originConfig, groupKey) and not self.model:isDynamicEyeball(self.originConfig, groupKey)
end

function MakeupComponent:getMakeupApplyReactionKeys(groupKey, reaction)
	if self:isRegularEyeballGroup(groupKey) and reaction.key_L and reaction.key_R then
		return {
			reaction.key_L,
			reaction.key_R
		}
	end

	return {
		reaction.key
	}
end

function MakeupComponent:applyMakeupReactionKeys(groupKey, groupData, reaction)
	local allowMulti = groupData.allowedMultiSelect
	local isRatio = not allowMulti

	for _, reactionKey in ipairs(self:getMakeupApplyReactionKeys(groupKey, reaction)) do
		avatarMakeup:SelectMakeup(reactionKey, true, isRatio)
	end
end

function MakeupComponent:appendPreservedMakeupSelections(preserved, groupKey, groupData, kindKey)
	if self:isRemovableMakeupKind(groupKey, kindKey) then
		return
	end

	if self:isRegularEyeballGroup(groupKey) then
		local sourceData = self.model:getMakeupKindData(self.originConfig, groupKey, kindKey)
		local reactionList = sourceData.reactionList or {}
		local preservedL, preservedR

		for _, reaction in ipairs(reactionList) do
			if reaction.key_L and avatarMakeup:IsReactionSelected(groupKey, reaction.key_L) then
				preservedL = reaction.key_L
			end

			if reaction.key_R and avatarMakeup:IsReactionSelected(groupKey, reaction.key_R) then
				preservedR = reaction.key_R
			end
		end

		if preservedL then
			table.insert(preserved, {
				slotKey = self:getMakeupSelectionSlotKey(groupKey, self.model.EYE_KIND.L),
				groupKey = groupKey,
				groupData = groupData,
				reactionKey = preservedL
			})
		end

		if preservedR then
			table.insert(preserved, {
				slotKey = self:getMakeupSelectionSlotKey(groupKey, self.model.EYE_KIND.R),
				groupKey = groupKey,
				groupData = groupData,
				reactionKey = preservedR
			})
		end

		return
	end

	local reactionKey = avatarMakeup:GetSelectedReactionKey(groupKey, kindKey)

	if reactionKey and reactionKey ~= 0 then
		table.insert(preserved, {
			slotKey = self:getMakeupSelectionSlotKey(groupKey, kindKey),
			groupKey = groupKey,
			groupData = groupData,
			reactionKey = reactionKey
		})
	end
end

function MakeupComponent:getSuitCoveredSlotKeys(makeupList)
	local coveredSlotKeys = {}

	for _, configId in ipairs(makeupList) do
		local groupKey, _, reaction, kindKey = self:findReactionEntryByConfigId(configId)

		if groupKey and reaction then
			if self:isRegularEyeballGroup(groupKey) then
				coveredSlotKeys[self:getMakeupSelectionSlotKey(groupKey, self.model.EYE_KIND.L)] = true
				coveredSlotKeys[self:getMakeupSelectionSlotKey(groupKey, self.model.EYE_KIND.R)] = true
			else
				coveredSlotKeys[self:getMakeupSelectionSlotKey(groupKey, kindKey)] = true
			end
		end
	end

	return coveredSlotKeys
end

function MakeupComponent:findReactionEntryByConfigId(configId)
	for groupKey, groupData in pairs(self.originConfig) do
		if groupData.reactionList then
			for _, reaction in ipairs(groupData.reactionList) do
				if reaction.configId == configId then
					return groupKey, groupData, reaction, nil
				end
			end
		end

		if groupData.kindList then
			for kindKey, kindData in pairs(groupData.kindList) do
				if kindData.reactionList then
					for _, reaction in ipairs(kindData.reactionList) do
						if reaction.configId == configId then
							return groupKey, groupData, reaction, kindKey
						end
					end
				end
			end
		end
	end

	return nil, nil, nil, nil
end

function MakeupComponent:findReactionByConfigId(configId)
	local groupKey, groupData, reaction, kindKey = self:findReactionEntryByConfigId(configId)

	if not reaction then
		return nil, nil, nil, kindKey
	end

	return groupKey, groupData, reaction.key, kindKey
end

function MakeupComponent:hasAnyMakeupSelected()
	for groupKey, groupData in pairs(self.originConfig) do
		if groupData.kindList then
			for kindKey, _ in pairs(groupData.kindList) do
				local reactionKey = avatarMakeup:GetSelectedReactionKey(groupKey, kindKey)

				if reactionKey and reactionKey ~= 0 then
					return true
				end
			end
		else
			local reactionKey = avatarMakeup:GetSelectedReactionKey(groupKey, nil)

			if reactionKey and reactionKey ~= 0 then
				return true
			end
		end
	end

	return false
end

return MakeupComponent
