-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Interact\\Component\\InteractUIComponent.lua

local TimerManager = require("Core.Timer.TimerManager")
local InteractionConst = require("Common.Const.InteractionConst")
local Lume = require("Core.Common.lume")
local LuaUIUtils = require("Utils.LuaUIUtils")
local HotkeyConst = require("Const.HotkeyConst")
local EventConst = require("Const.EventConst")
local UIConst = require("Const.UIConst")
local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local InteractUIComponent = Class.LightClass("InteractUIComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local ITEM_MAX_QUALIT = 6

function InteractUIComponent:isSameInteractData(a, b)
	if not a or not b or not a.unitRoot or not b.unitRoot then
		return false
	end

	return a.unitRoot:compareOtherRootNode(b.unitRoot)
end

function InteractUIComponent:findInteractDataIndex(targetData)
	if not targetData then
		return
	end

	local interactList = self.interactList

	for index = 0, interactList.itemCount - 1 do
		local data = interactList:GetData(index)

		if data == targetData or self:isSameInteractData(data, targetData) then
			return index
		end
	end
end

function InteractUIComponent:findObjects()
	self.interactList = self.view.interactionNewUWidget.transform:GetComponent("ObjectReference"):GetRefValue("listUList")
end

function InteractUIComponent:initView()
	self.interactData = nil

	function self.interactList.luaRenderItem(button, index, data)
		button.customData = data

		self:setupMultInteractBtn(button, index, data)

		if data.btnHierarchyName then
			button.gameObject.name = data.btnHierarchyName
		end
	end

	function self.interactList.luaSelectedChanged(uList, isSelected)
		local selectData = self.interactList.selectedItem

		if isSelected and selectData and self.selectData ~= selectData then
			local previousSelectData = self.selectData

			self:syncSelectData(selectData)

			local previousIndex = self:findInteractDataIndex(previousSelectData)
			local selectedIndex = self:findInteractDataIndex(selectData)

			if previousIndex then
				self.interactList:RefreshElement(previousIndex)
			end

			if selectedIndex and selectedIndex ~= previousIndex then
				self.interactList:RefreshElement(selectedIndex)
			end

			if not self.skipGotoIndex then
				self.interactList:GoToIndex(self.interactList.selectedIndex)
			end
		end
	end

	function self.interactList.luaClick(button, data)
		local unit = data.unitRoot

		unit:doInteract()
	end

	self:show()
end

function InteractUIComponent:refreshEntityFocus(selectData, isSelect)
	if not selectData then
		return
	end

	if not selectData.unitRoot then
		return
	end

	if not selectData.unitRoot.globalId then
		return
	end

	local entity = pg.getEntityByGlobalId(selectData.unitRoot.globalId)

	if entity and entity.eventEmitter then
		if isSelect and (not entity.ensureTopLogoItem or not entity:ensureTopLogoItem("focus")) then
			return
		end

		if isSelect and entity.ensureToplogoComponent and not entity:ensureToplogoComponent(UIConst.TOPLOGO_COMPONENT.FOCUS, "interact_focus") then
			return
		end

		entity.eventEmitter:emit(EventConst.TOPLOGO_FOCUS, isSelect)
	end
end

function InteractUIComponent:syncSelectData(selectData)
	local previousSelectData = self.selectData

	if previousSelectData == selectData then
		return
	end

	if selectData == nil and previousSelectData and previousSelectData.unitRoot == nil then
		return
	end

	if not self:isSameInteractData(previousSelectData, selectData) then
		self:refreshEntityFocus(previousSelectData, false)
		self:refreshEntityFocus(selectData, true)
	end

	self:setSelectData(selectData or {})

	if selectData then
		self:markShareProcess(selectData)
	end
end

function InteractUIComponent:onInteractChange(info)
	self:refreshInteractList(info and info.changedStartIndex)
end

function InteractUIComponent:refreshInteractList(changedStartIndex)
	local interactData = self:getCurrentInteractInfo()

	if #interactData <= 0 then
		self:syncSelectData(nil)

		self.selectedListId = nil
	end

	self.interactDataCount = #interactData

	self.ctrl:refreshCameraZoomInput()

	self.interactList.ScrollType = CS.XGUI.EScrollType.Vertical

	if not pg.global.ui.uiMgr:CheckIsMobileInteract() then
		self.interactList.EnableDrag = false
	end

	local selectIdx = self:getSelectIndex(interactData)

	for index, data in ipairs(interactData) do
		data.selected = selectIdx ~= nil and index - 1 == selectIdx
	end

	if changedStartIndex and self.interactData and not self.interactList.isVirtual then
		local oldEndIndex = #self.interactData
		local newEndIndex = #interactData

		while changedStartIndex <= oldEndIndex and changedStartIndex <= newEndIndex and self:isSameInteractData(self.interactData[oldEndIndex], interactData[newEndIndex]) do
			oldEndIndex = oldEndIndex - 1
			newEndIndex = newEndIndex - 1
		end

		for index = oldEndIndex, changedStartIndex, -1 do
			self.interactList:RemoveElement(index - 1)
		end

		local insertIndex = changedStartIndex - 1

		for index = changedStartIndex, newEndIndex do
			self.interactList:InsertElement(insertIndex, interactData[index])

			insertIndex = insertIndex + 1
		end
	else
		self.interactList:SetList(interactData)
	end

	LuaUIUtils.setUIViewVisible(self.interactList, self.interactList.itemCount > 0)

	self.interactData = interactData

	if selectIdx then
		self.interactList:SelectItem(selectIdx)

		local ret, btn = self.interactList:TryGetChildAt(selectIdx)

		if ret then
			self:refreshBtnSelectState(btn, selectIdx, interactData[selectIdx + 1])
		end
	end

	self:clearUnselectedBtnInputActive(selectIdx)

	local selectData = selectIdx and interactData[selectIdx + 1] or self.interactList.selectedItem

	self:syncSelectData(selectData)
	LuaUIUtils.setUIViewVisible(self.view.multiSelectHintUWidget, self.interactList.itemCount > 1)

	if self.view.multiSelectHintUContainer then
		local hotkeyContent = self.view.multiSelectHintUContainer:GetComponent("HotKeyContent")

		if hotkeyContent then
			hotkeyContent.useRawBindingPath = true

			hotkeyContent:SetHotKeyPaths("Hud/InteractScroll")
		end
	end

	if self.interactList.itemCount <= 0 then
		self:onEmptyInteraction()
	end
end

function InteractUIComponent:getSelectIndex(interactData)
	if pg.global.ui:runPlatformByMobile() then
		return
	end

	if self.selectedListId then
		for i, data in ipairs(interactData) do
			if data.listId == self.selectedListId then
				return i - 1
			end
		end
	end

	if #interactData > 0 then
		return 0
	end
end

function InteractUIComponent:setSelectData(data)
	self.selectData = data

	self.ctrl:onSelectItemChange()
end

function InteractUIComponent:getCurInteractItem()
	return self.selectData
end

function InteractUIComponent:refreshBtnSelectState(button, idx, data)
	if data.selected then
		button.enableInputActon = true
		button.interactable = true
		button.visualInteractable = true
	else
		button.enableInputActon = false
	end

	button.interactable = data.disableButton ~= true
end

function InteractUIComponent:clearUnselectedBtnInputActive(selectIdx)
	for index = 0, self.interactList.itemCount - 1 do
		if index ~= selectIdx then
			local ret, btn = self.interactList:TryGetChildAt(index)

			if ret then
				btn.enableInputActon = false
			end
		end
	end
end

function InteractUIComponent:onMouseScroll(delta)
	local curIdx = self.interactList.selectedIndex
	local itemCount = self.interactList.itemCount
	local nextIdx = curIdx

	if itemCount > 0 and curIdx then
		if delta > 0 then
			nextIdx = math.max(curIdx - 1, 0)
		else
			nextIdx = math.min(curIdx + 1, itemCount - 1)
		end

		if nextIdx ~= curIdx then
			self.interactList:SelectItem(nextIdx)
		end
	end

	return itemCount > 1
end

function InteractUIComponent:onGamepadSwitch(diff)
	local curIdx = self.interactList.selectedIndex
	local itemCount = self.interactList.itemCount
	local nextIdx = curIdx

	if itemCount > 0 and curIdx then
		nextIdx = math.clamp(curIdx + diff, 0, itemCount - 1)

		if nextIdx ~= curIdx then
			self.interactList:SelectItem(nextIdx)
		end
	end

	return itemCount > 1
end

function InteractUIComponent:getCurrentInteractInfo()
	local ret = {}
	local interactSys = pg.game.interaction

	for _, unitRootNode in ipairs(interactSys.currentInteractList) do
		local item = {}
		local btnName = unitRootNode:getInteractName()

		item.btnName = btnName
		item.btnIcon = unitRootNode:getInteractIcon()
		item.actionPath = unitRootNode:getActionPath()
		item.textColor = unitRootNode:getTextColor()
		item.unitRoot = unitRootNode
		item.isDisplayPriceDesc = unitRootNode:isDisplayCollectItemPriceDesc()
		item.displayPriceInfos = unitRootNode:getInteractItemSellPriceInfos()
		item.btnHierarchyName = self:getBtnHierarchyName(unitRootNode)

		local interactUnit = unitRootNode.interactUnits and unitRootNode.interactUnits[1]

		item.showLvUpIcon = interactUnit and interactUnit.info and interactUnit.info.showLvUpIcon == true
		ret[#ret + 1] = item
	end

	return ret
end

function InteractUIComponent:setupMultInteractBtn(button, idx, data)
	self:refreshBtnSelectState(button, idx, data)

	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local keyBinding = button:GetComponent("KeyBindingPro")
	local qualityBgItemRectTransform = objectReference:GetRefValue("qualityBgItemRectTransform")
	local lvUpUImage = objectReference:GetRefValue("lvUpUImage")

	if lvUpUImage ~= nil then
		lvUpUImage:SetActive(data.showLvUpIcon == true)
	end

	keyBinding.actionPath = data.actionPath

	local interactBtnIcon = data.btnIcon

	if data.isDisplayPriceDesc then
		ClientTextUtils.setText(txtNameUSDFText, data.displayPriceInfos.richText)

		interactBtnIcon = ToBool(data.displayPriceInfos.itemIcon) and data.displayPriceInfos.itemIcon or interactBtnIcon

		local quality = math.clamp(data.displayPriceInfos.quality or 0, 0, ITEM_MAX_QUALIT)

		button:TryChangePage("Quality", quality)

		self.delayShowIconBgTimers = self.delayShowIconBgTimers or {}

		if self.delayShowIconBgTimers[idx] then
			TimerManager.removeTimer(self.delayShowIconBgTimers[idx])

			self.delayShowIconBgTimers[idx] = nil
		end

		self.delayShowIconBgTimers[idx] = TimerManager.addTimer(0.1, function()
			if NotNil(qualityBgItemRectTransform) then
				qualityBgItemRectTransform:SetActive(true)
			end

			self.delayShowIconBgTimers[idx] = nil
		end)

		button:TryChangePage("stage", 3)
		iconUImage:SetActiveFastest(interactBtnIcon ~= nil)
		iconUImage:SetUrlWithCallback(interactBtnIcon, function()
			return
		end, nil, true)
	else
		qualityBgItemRectTransform:SetActive(false)

		local btnName = data.btnName
		local platformHooks = InteractUIComponent._platformHooks

		btnName = platformHooks and platformHooks.setupMultInteractBtnText and platformHooks.setupMultInteractBtnText(self, button, idx, data, btnName) or btnName

		local interactUnits = data.unitRoot and data.unitRoot.interactUnits or {}
		local interactUnit = interactUnits[1]

		for _, unit in ipairs(interactUnits) do
			if unit.eventType == "startNpcDuelDialogue" then
				interactUnit = unit

				break
			end
		end

		btnName = self:tryReplaceNpcDuelDialogueText(interactUnit, btnName)
		btnName = ClientTextUtils.applyTextColor(btnName, data.textColor)

		ClientTextUtils.setText(txtNameUSDFText, btnName)
		iconUImage:SetActiveFastest(interactBtnIcon ~= nil)
		iconUImage:SetUrlWithCallback(interactBtnIcon, function()
			if button.customData ~= data then
				return
			end

			local width = iconUImage:GetSpriteSize()[1]

			if width >= 100 then
				button:TryChangePage("stage", 1)
			elseif width <= 36 then
				button:TryChangePage("stage", 0)
			else
				button:TryChangePage("stage", 2)
			end
		end, nil, true)
	end

	function button.luaHover()
		self.skipGotoIndex = true

		self.interactList:SelectItem(idx)

		self.skipGotoIndex = nil
	end
end

function InteractUIComponent:onDestroy()
	self.delayShowIconBgTimers = nil

	UIComponent.onDestroy(self)
end

function InteractUIComponent:onInputDeviceChange()
	self.interactList:RefreshList()
end

function InteractUIComponent:onEmptyInteraction()
	pg.game.markShare:onFocusChanged(nil)
end

function InteractUIComponent:markShareProcess(selectData)
	if selectData.unitRoot and selectData.unitRoot.interactUnits and selectData.unitRoot.interactUnits[1] and selectData.unitRoot.interactUnits[1].interactionType == InteractionConst.INTERACTION_TYPE_MARK_SHARE then
		pg.game.markShare:onFocusChanged(selectData.unitRoot.interactUnits[1].globalId)
	else
		pg.game.markShare:onFocusChanged(nil)
	end
end

function InteractUIComponent:tryReplaceNpcDuelDialogueText(interactUnit, btnName)
	if not interactUnit then
		return btnName
	end

	local isNpcDuelDialogue = interactUnit.eventType == "startNpcDuelDialogue"

	if not isNpcDuelDialogue and interactUnit.funcMenuId then
		local NpcFuncConfigData = require("Data.npc_func_config_data")
		local SysEventData = require("Data.sys_event_data")
		local npcFuncConfigData = NpcFuncConfigData[interactUnit.funcMenuId]

		if npcFuncConfigData and npcFuncConfigData.npcFunc then
			for _, funcData in ipairs(npcFuncConfigData.npcFunc) do
				local eventIds = funcData[4] or {}

				for _, eventId in ipairs(eventIds) do
					local eventData = SysEventData[eventId]

					if eventData and eventData.eventType == "startNpcDuelDialogue" then
						isNpcDuelDialogue = true

						break
					end
				end

				if isNpcDuelDialogue then
					break
				end
			end
		end
	end

	if not isNpcDuelDialogue then
		return btnName
	end

	local globalId = interactUnit.globalId or interactUnit.info and interactUnit.info.globalId
	local level = pg.game.npcDuel and pg.game.npcDuel:getNpcDuelLevelByGlobalId(globalId)

	if not level or level <= 0 then
		return btnName
	end

	local CombatThreatLevelData = require("Data.combat_threat_level_data")
	local playerLevel = pg.me and pg.me.level or 1
	local color

	for index, levelConfig in ipairs(CombatThreatLevelData) do
		if playerLevel - level >= levelConfig.level then
			if levelConfig.color == "dangerous" then
				color = "#F8B04E"

				break
			end

			if levelConfig.color == "veryDangerous" then
				color = "#F56053"
			end

			break
		elseif index == #CombatThreatLevelData then
			if levelConfig.color == "dangerous" then
				color = "#F8B04E"
			elseif levelConfig.color == "veryDangerous" then
				color = "#F56053"
			end
		end
	end

	if color then
		return string.format("%s <color=%s>(Lv.%s)</color>", btnName, color, level)
	end

	return string.format("%s (Lv.%s)", btnName, level)
end

function InteractUIComponent:getBtnHierarchyName(unitRootNode)
	local ret = "UI_Node_Interaction_Root"
	local styleId = -1

	if unitRootNode.btnStylesCount == 1 then
		for _, unit in ipairs(unitRootNode.interactUnits) do
			local btnStyles = unit:getInteractBtnStyle()

			if #btnStyles == 1 then
				styleId = btnStyles[1].styleId

				break
			end
		end
	end

	local ent = pg.getEntityByGlobalId(unitRootNode.globalId)

	if ent and ent.staticId then
		ret = ret .. "_" .. ent.staticId
	end

	if styleId > -1 then
		ret = ret .. "_" .. styleId
	end

	return ret
end

return InteractUIComponent
