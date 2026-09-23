-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Interact\\Component\\InteractClassicUIComponent.lua

local InteractionConst = require("Common.Const.InteractionConst")
local Lume = require("Core.Common.lume")
local LuaUIUtils = require("Utils.LuaUIUtils")
local HotkeyConst = require("Const.HotkeyConst")
local InteractData = require("Data.interact_data")
local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local InteractClassicUIComponent = Class.LightClass("InteractClassicUIComponent", UIComponent)
local SafeCallback = require("Core.Framework.SafeCallback")
local ClientTextUtils = require("Utils.ClientTextUtils")
local EventConst = require("Const.EventConst")
local UIConst = require("Const.UIConst")
local pg = pg
local CS_XGUI_EScrollType_Vertical = CS.XGUI.EScrollType.Vertical
local Pg_Global_UI = pg.global.ui
local Pg_Global_UI_UIMgr = Pg_Global_UI.uiMgr
local ITEM_MAX_QUALITY = 6

local function getInteractListId(interactUnit, styleIndex)
	if interactUnit.globalId then
		return string.format("%s_%s_%s", interactUnit.globalId, interactUnit.actionPrototypeId, styleIndex)
	end

	return string.format("%s_%s", interactUnit.interactId, styleIndex)
end

function InteractClassicUIComponent:findObjects()
	self.interactList = self.view.interactionNewUWidget.transform:GetComponent("ObjectReference"):GetRefValue("listUList")
end

function InteractClassicUIComponent:initView()
	function self.interactList.luaRenderItem(button, index, data)
		button.customData = data

		self:setupMultInteractBtn(button, index, data)

		if data.btnHierarchyName then
			button.gameObject.name = data.btnHierarchyName
		end
	end

	function self.interactList.luaSelectedChanged(uList)
		local selectData = self.interactList.selectedItem

		if selectData and self.selectedListId ~= selectData.listId then
			self:refreshEntityFocus(self.selectData, false)
			self:refreshEntityFocus(selectData, true)

			self.selectedListId = selectData.listId

			self:setSelectData(selectData or {})

			if not self.isRebuildingInteractList then
				self.interactList:RefreshList()

				if not self.skipGotoIndex then
					self.interactList:GoToIndex(self.interactList.selectedIndex)
				end
			end
		end
	end

	function self.interactList.luaClick(button, data)
		if data.interactUnit then
			data.interactUnit:tryInteractive(data.interactIdx)
		end
	end

	self.interactTypeList = {}

	Lume.append(self.interactTypeList, InteractionConst.NO_TARGET_POS_LIST, InteractionConst.INTERACTION_PRIORITY_LIST)
end

function InteractClassicUIComponent:onInteractChange()
	self:refreshInteractList()
	self:refreshEquipmentName()
end

function InteractClassicUIComponent:refreshEquipmentName()
	local currentUnitMap = pg.game.interaction.currentUnitMap
	local equipmentName

	for tp, unitList in pairs(currentUnitMap) do
		for _, unit in ipairs(unitList) do
			local ent = unit:getEntity()

			if ent and Utils.isClientHomeOrnament(ent) then
				equipmentName = ent:getConfigData().name

				break
			elseif ent and Utils.isVehicle(ent) and ent.getHomelandConfigData then
				equipmentName = ent:getHomelandConfigData().name

				break
			end
		end

		if equipmentName then
			break
		end
	end

	if equipmentName then
		self.view.equipmentWidget:SetActive(true)
		ClientTextUtils.setText(self.view.equipmentName, pg.getLocalizationText(equipmentName))
	else
		self.view.equipmentWidget:SetActive(false)
	end
end

function InteractClassicUIComponent:refreshEntityFocus(selectData, isSelect)
	if not selectData then
		return
	end

	if not selectData.interactUnit then
		return
	end

	if not selectData.interactUnit.globalId then
		return
	end

	local entity = pg.getEntityByGlobalId(selectData.interactUnit.globalId)

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

function InteractClassicUIComponent:refreshInteractList()
	local interactData, quickCaptureData = self:getCurrentInteractInfo()

	if #interactData <= 0 then
		self:refreshEntityFocus(self.selectData, false)

		self.selectedListId = nil

		self:setSelectData({})
	end

	self.interactDataCount = #interactData

	self.ctrl:refreshCameraZoomInput()

	self.interactList.ScrollType = CS_XGUI_EScrollType_Vertical

	if not Pg_Global_UI_UIMgr:CheckIsMobileInteract() then
		self.interactList.EnableDrag = false
	end

	local selectIdx = self:getSelectIndex(interactData)

	for index, data in ipairs(interactData) do
		data.selected = selectIdx ~= nil and index - 1 == selectIdx
	end

	self.isRebuildingInteractList = true

	self.interactList:SetList(interactData)

	self.isRebuildingInteractList = false

	LuaUIUtils.setUIViewVisible(self.interactList, self.interactList.itemCount > 0)

	if selectIdx then
		self.interactList:SelectItem(selectIdx)

		local ret, btn = self.interactList:TryGetChildAt(selectIdx)

		if ret then
			self:refreshBtnSelectState(btn, selectIdx, interactData[selectIdx + 1])
		end
	elseif #interactData > 0 then
		self:refreshEntityFocus(self.selectData, false)
		self:refreshEntityFocus(interactData[1], true)
		self:setSelectData(interactData[1])
	end

	LuaUIUtils.setUIViewVisible(self.view.multiSelectHintUWidget, self.interactList.itemCount > 1)

	if self.view.multiSelectHintUContainer then
		local hotkeyContent = self.view.multiSelectHintUContainer:GetComponent("HotKeyContent")

		if hotkeyContent then
			hotkeyContent.useRawBindingPath = true

			hotkeyContent:SetHotKeyPaths("Hud/InteractScroll")
		end
	end
end

function InteractClassicUIComponent:getSelectIndex(interactData)
	if Pg_Global_UI:runPlatformByMobile() then
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

function InteractClassicUIComponent:setSelectData(data)
	self.selectData = data

	self.ctrl:onSelectItemChange()
end

function InteractClassicUIComponent:getCurInteractItem()
	return self.selectData
end

function InteractClassicUIComponent:refreshBtnSelectState(button, idx, data)
	if data.selected then
		button.enableInputActon = true
		button.interactable = true
		button.visualInteractable = true
	else
		button.enableInputActon = false
	end

	button.interactable = data.disableButton ~= true
end

function InteractClassicUIComponent:onMouseScroll(delta)
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

function InteractClassicUIComponent:onGamepadSwitch(diff)
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

function InteractClassicUIComponent:refreshInteractEntBubble()
	self:clearInteractEntBubble()

	local interactSys = pg.game.interaction
	local curUnitMap = interactSys.currentUnitMap
	local res = {}

	for tp, unitList in pairs(curUnitMap) do
		for _, unit in ipairs(unitList) do
			local func = string.format("enterTriggerBubble_%d", tp)

			if self.preBubbleMap[tp] == nil and self[func] then
				SafeCallback(self[func], self, unit)

				if not res[tp] then
					res[tp] = {}
				end

				res[tp][#res[tp] + 1] = unit
			end
		end
	end

	self.preBubbleMap = res
end

function InteractClassicUIComponent:clearInteractEntBubble()
	return
end

function InteractClassicUIComponent:enterTriggerBubble_10(unit)
	if unit.funcMenuId == 2 then
		local ent = pg.getEntity(unit.globalId)

		if self.model:checkHasReportAward() then
			ent:showSimpleDialogue(3, {
				1,
				81000102,
				1
			})
		end
	end
end

function InteractClassicUIComponent:exitTriggerBubble_10(unit)
	if unit.funcMenuId == 2 then
		local ent = pg.getEntity(unit.globalId)

		ent:showSimpleDialogue(3, {
			1,
			81000103,
			1
		})
	end
end

function InteractClassicUIComponent:getCurrentInteractInfo()
	local ret = {}
	local quickCaptureData
	local interactSys = pg.game.interaction

	for _, unitType in ipairs(self.interactTypeList) do
		local interactUnitList = interactSys.currentUnitMap[unitType] or {}

		for _, interactUnit in ipairs(interactUnitList) do
			if interactUnit then
				local btnStyleIds = interactUnit:getInteractBtnStyle()
				local hasSingleStyle = #btnStyleIds == 1

				for idx, btnStyleIdInfo in pairs(btnStyleIds) do
					local temp = {}

					if btnStyleIdInfo.styleId == InteractionConst.DEFAULT_INTERACTION_CUSTOM_ID then
						temp.btnIcon = btnStyleIdInfo.iconId
						temp.btnTitle = btnStyleIdInfo.actionName
						temp.hotkeyType = btnStyleIdInfo.hotkeyType
						temp.isColorIcon = btnStyleIdInfo.isColorIcon
					else
						local configInfo = InteractData[btnStyleIdInfo.styleId]

						temp.btnIcon = hasSingleStyle and interactUnit:getIcon() or configInfo.iconId
						temp.hotkeyType = configInfo.hotkeyType
						temp.styleId = btnStyleIdInfo.styleId
						temp.rate = btnStyleIdInfo.rate

						local btnName = interactUnit:getText(btnStyleIdInfo)

						btnName = pg.getFormatText(btnName, idx)
						temp.btnTitle = btnName
					end

					if btnStyleIdInfo.tIndex == 2 then
						temp.btnIcon = interactUnit:getIcon()
						temp.isQuickTemp = true
						temp.rate = btnStyleIdInfo.rate
						temp.entity = btnStyleIdInfo.entity
						temp.firstShow = btnStyleIdInfo.firstShow
						temp.ballState = btnStyleIdInfo.ballState
					end

					if temp.hotkeyType then
						temp.actionPath = temp.hotkeyType
					else
						temp.actionPath = "Hud/Interact"
					end

					temp.state = self.model:getInteractItemState(unitType, btnStyleIdInfo)
					temp.unitType = unitType
					temp.interactIdx = btnStyleIdInfo.index or idx
					temp.index = #ret
					temp.interactId = interactUnit.interactId
					temp.listId = getInteractListId(interactUnit, idx)
					temp.tIndex = btnStyleIdInfo.tIndex or 0
					temp.interactUnit = interactUnit
					temp.disableButton = btnStyleIdInfo.disableButton
					temp.textColor = btnStyleIdInfo.textColor
					temp.btnHierarchyName = self:getBtnHierarchyName(interactUnit, btnStyleIdInfo.styleId)

					if interactUnit.info.getItemDisplayInfo then
						temp.itemDisplayInfo = interactUnit.info.getItemDisplayInfo()
					end

					if btnStyleIdInfo.tIndex == 2 then
						quickCaptureData = temp
					else
						ret[#ret + 1] = temp
					end
				end
			end
		end
	end

	return ret, quickCaptureData
end

function InteractClassicUIComponent:refreshInteractIconStage(button, icon, data)
	if button.customData ~= data then
		return false
	end

	local width = icon:GetSpriteSize()[1]

	if width <= 0 then
		return false
	end

	if width >= 100 then
		button:TryChangePage("stage", 1)
	elseif width <= 36 then
		button:TryChangePage("stage", 0)
	else
		button:TryChangePage("stage", 2)
	end

	return true
end

function InteractClassicUIComponent:setupMultInteractBtn(button, idx, data)
	button.enableInputActon = false

	self:refreshBtnSelectState(button, idx, data)

	local objectReference = button:GetComponent("ObjectReference")
	local txtName = objectReference:GetRefValue("txtNameUSDFText")
	local icon = objectReference:GetRefValue("iconUImage")
	local qualityBgItemRectTransform = objectReference:GetRefValue("qualityBgItemRectTransform")
	local keybind = button:GetComponent("KeyBindingPro")

	keybind.actionPath = data.actionPath

	if data.itemDisplayInfo then
		local displayInfo = data.itemDisplayInfo
		local itemName = pg.getFormatText(pg.getGameString("HOME_ACCELERATE_INTERATION_ITEM_NAME"), displayInfo.itemName)
		local itemNum = pg.getFormatText(pg.getGameString("HOME_ACCELERATE_INTERATION_ITEM_NUM"), tostring(displayInfo.ownedCount))

		ClientTextUtils.setText(txtName, itemName .. "\n" .. itemNum)
		button:TryChangePage("Quality", math.clamp(displayInfo.quality, 0, ITEM_MAX_QUALITY))
		button:TryChangePage("stage", 3)
		qualityBgItemRectTransform:SetActive(true)
		icon:SetActiveFastest(true)
		icon:SetUrlWithCallback(displayInfo.icon, function()
			return
		end, nil, true)

		function button.luaHover()
			self.skipGotoIndex = true

			self.interactList:SelectItem(idx)

			self.skipGotoIndex = nil
		end

		return
	end

	qualityBgItemRectTransform:SetActive(false)

	if data.btnIcon == nil then
		LuaUIUtils.setUIViewVisible(icon, false)
	else
		LuaUIUtils.setUIViewVisible(icon, true)
	end

	local btnTitle = ClientTextUtils.applyTextColor(pg.getLocalizationText(data.btnTitle), data.textColor)

	ClientTextUtils.setText(txtName, btnTitle)

	if data.btnIcon == nil then
		button:TryChangePage("stage", 0)

		icon.url = nil
	elseif icon.url == data.btnIcon and self:refreshInteractIconStage(button, icon, data) then
		-- block empty
	else
		button:TryChangePage("stage", 0)

		if icon.url == data.btnIcon then
			icon.url = nil
		end

		icon:SetUrlWithCallback(data.btnIcon, function()
			self:refreshInteractIconStage(button, icon, data)
		end, nil, true)
	end

	function button.luaHover()
		self.skipGotoIndex = true

		self.interactList:SelectItem(idx)

		self.skipGotoIndex = nil
	end
end

function InteractClassicUIComponent:onDestroy()
	UIComponent.onDestroy(self)
end

function InteractClassicUIComponent:onInputDeviceChange()
	self.interactList:RefreshList()
end

function InteractClassicUIComponent:getBtnHierarchyName(interactUnit, styleId)
	local btnHierarchyName = "UI_Node_Interaction"
	local ent = interactUnit:getEntity()

	if ent and ent.staticId then
		btnHierarchyName = string.format("%s_%s", btnHierarchyName, ent.staticId)
	end

	if styleId > -1 then
		btnHierarchyName = string.format("%s_%s", btnHierarchyName, styleId)
	end

	return btnHierarchyName
end

return InteractClassicUIComponent
