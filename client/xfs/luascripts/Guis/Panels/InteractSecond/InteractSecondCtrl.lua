-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\InteractSecond\\InteractSecondCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("InteractSecondCtrl")
local MessageName = require("Const.MessageName")
local LuaUIUtils = require("Utils.LuaUIUtils")
local InteractData = require("Data.interact_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local NpcDialogueData = require("Data.npc_dialogue_data")
local AddressDataConst = require("Const.AddressDataConst")
local Class = require("Core.Framework.Class")
local InteractionConst = require("Common.Const.InteractionConst")
local HotkeyConst = require("Const.HotkeyConst")
local UICtrl = require("Guis.UICtrl")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local InteractSecondCtrl = Class.LightClass("InteractSecondCtrl", UICtrl)

InteractSecondCtrl.messages = {
	[MessageName.UPDATE_INTERACT_VIEW] = {
		"onInteractChange",
		true
	}
}

function InteractSecondCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.unitRoot = info.unitRoot
end

function InteractSecondCtrl:addListener()
	function self.view.listUList.luaRenderItem(button, idx, data)
		self:setupMultInteractBtn(button, idx, data)

		if data.btnHierarchyName then
			button.gameObject.name = data.btnHierarchyName
		end
	end

	function self.view.listUList.luaClick(button, data)
		if data.interactUnit then
			data.interactUnit:tryInteractive(data.interactIdx)
		elseif data.customClick then
			data.customClick()
		end

		self:dismiss()
	end

	function self.view.listUList.luaSelectedChanged(uList)
		local selectData = uList.selectedItem

		if selectData and self.selectData ~= selectData then
			self.selectData = selectData

			self.view.listUList:RefreshList()

			if not self.skipGotoIndex then
				self.view.listUList:GoToIndex(self.view.listUList.selectedIndex)
			end
		end
	end

	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:dismiss()
		end
	end

	local closeRight = KeyBindingPro.GetOrAddKeyBindingByName(self.view.gameObject, "closeRight")

	closeRight.isVirtual = true
	closeRight.priority = -1
	closeRight.actionPath = "Raw/MouseRight"

	function closeRight.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:dismiss()
		end
	end

	local scrollBinding = KeyBindingPro.GetOrAddKeyBindingByName(self.view.gameObject, "interactScroll")

	scrollBinding.actionPath = "Hud/InteractScroll"
	scrollBinding.isVirtual = true

	function scrollBinding.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			local deltaZoom = inputInfo.valueVec2.y

			if self:onMouseScroll(deltaZoom) then
				return false
			end
		end

		return true
	end

	local scrollUpGamepadBinding = KeyBindingPro.GetOrAddKeyBindingByName(self.view.gameObject, "interactScrollUp")

	scrollUpGamepadBinding.actionPath = "Hud/DPadMoveUp"
	scrollUpGamepadBinding.isVirtual = true

	function scrollUpGamepadBinding.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" and self:onMouseScroll(1) then
			return false
		end

		return true
	end

	local scrollDownGamepadBinding = KeyBindingPro.GetOrAddKeyBindingByName(self.view.gameObject, "interactScrollDown")

	scrollDownGamepadBinding.actionPath = "Hud/DPadMoveDown"
	scrollDownGamepadBinding.isVirtual = true

	function scrollDownGamepadBinding.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" and self:onMouseScroll(-1) then
			return false
		end

		return true
	end

	if self.view.multiSelectHintUContainer then
		local hotkeyContent = self.view.multiSelectHintUContainer:GetComponent("HotKeyContent")

		if hotkeyContent then
			hotkeyContent.useRawBindingPath = true

			hotkeyContent:SetHotKeyPaths("Hud/InteractScroll")
		end
	end
end

function InteractSecondCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function InteractSecondCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:tryShowBottomDialogue()

	local interactDatas = self:getCurrentInteractInfo()

	self.view.listUList.ScrollType = CS.XGUI.EScrollType.Vertical

	if not pg.global.ui.uiMgr:CheckIsMobileInteract() then
		self.view.listUList.EnableDrag = false
	end

	self.view.listUList:SetList(interactDatas)
	self.view.listUList:SelectItem(0)

	local ret, btn = self.view.listUList:TryGetChildAt(0)

	if ret then
		self:refreshBtnSelectState(btn, 0, interactDatas[1])
	end
end

function InteractSecondCtrl:tryShowBottomDialogue()
	local ent = self.unitRoot:getEnt()

	if ent then
		local dialogueId = ent:getConfigData().defaultDialogue

		if dialogueId then
			local dialogueData = NpcDialogueData[dialogueId]

			if dialogueData then
				ClientTextUtils.setText(self.view.textInfoUSDFText, pg.getLocalizationText(dialogueData.chat))
				ClientTextUtils.setText(self.view.txtNameUSDFText, pg.getLocalizationText(dialogueData.npcName))
				self.view.dialogueUWidget:SetActive(true)

				return
			end
		end
	end

	self.view.dialogueUWidget:SetActive(false)
end

function InteractSecondCtrl:onInteractChange()
	local interactSys = pg.game.interaction
	local inCurList = false

	for _, rootNode in pairs(interactSys.currentInteractList) do
		if rootNode == self.unitRoot then
			inCurList = true

			break
		end
	end

	if not inCurList then
		self:dismiss()
	end
end

function InteractSecondCtrl:onShow()
	return
end

function InteractSecondCtrl:onHide()
	return
end

function InteractSecondCtrl:getCurrentInteractInfo()
	local ret = {}

	for _, unit in ipairs(self.unitRoot.interactUnits) do
		local btnStyleIds = unit:getInteractBtnStyle()
		local isMultiStyle = #btnStyleIds > 1

		for idx, btnStyleIdInfo in pairs(btnStyleIds) do
			local temp = {}

			if btnStyleIdInfo.styleId == InteractionConst.DEFAULT_INTERACTION_CUSTOM_ID then
				if isMultiStyle then
					temp.btnIcon = btnStyleIdInfo.iconId
				else
					temp.btnIcon = unit:getIcon()
				end

				temp.btnTitle = btnStyleIdInfo.actionName
				temp.hotkeyType = btnStyleIdInfo.hotkeyType
			else
				local configInfo = InteractData[btnStyleIdInfo.styleId]

				if isMultiStyle then
					temp.btnIcon = configInfo.iconId
				else
					temp.btnIcon = unit:getIcon()
				end

				temp.hotkeyType = configInfo.hotkeyType
				temp.styleId = btnStyleIdInfo.styleId
				temp.rate = btnStyleIdInfo.rate

				local btnName = unit:getText(btnStyleIdInfo)

				btnName = pg.getFormatText(btnName, idx)
				temp.btnTitle = btnName
			end

			if temp.hotkeyType then
				temp.actionPath = temp.hotkeyType
			else
				temp.actionPath = "Hud/Interact"
			end

			temp.interactIdx = btnStyleIdInfo.index or idx
			temp.interactId = unit.interactId
			temp.listId = tostring(unit.interactId) .. idx
			temp.interactUnit = unit
			temp.disableButton = btnStyleIdInfo.disableButton
			temp.textColor = btnStyleIdInfo.textColor
			temp.btnHierarchyName = self:getBtnHierarchyName(unit, btnStyleIdInfo.styleId)
			temp.btnIcon = temp.btnIcon or AddressDataConst.UI_INTERACT_COMMON_ICON
			ret[#ret + 1] = temp
		end
	end

	ret[#ret + 1] = {
		isExit = true,
		actionPath = "Hud/Interact",
		btnHierarchyName = "UI_Node_Interaction_Second_Exit",
		btnTitle = pg.getGameString("exitNpcMenu"),
		customClick = function()
			self:dismiss()
		end,
		btnIcon = AddressDataConst.UI_EXIT_INTERACT_ICON
	}

	return ret
end

function InteractSecondCtrl:setupMultInteractBtn(button, idx, data)
	local keybind = button:GetComponent("KeyBindingPro")

	keybind.actionPath = data.actionPath or "Hud/Interact"
	keybind.isVirtual = true

	function keybind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			button:GetComponent("UButton"):OnClickSimulate()
		end
	end

	self:refreshBtnSelectState(button, idx, data)

	local objectReference = button:GetComponent("ObjectReference")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local btnTitle = ClientTextUtils.applyTextColor(pg.getLocalizationText(data.btnTitle), data.textColor)

	ClientTextUtils.setText(txtNameUSDFText, btnTitle)
	iconUImage:SetUrlWithCallback(data.btnIcon, function()
		local width = iconUImage:GetSpriteSize()[1]

		if width >= 100 then
			button:TryChangePage("stage", 1)
		elseif width <= 36 then
			button:TryChangePage("stage", 0)
		else
			button:TryChangePage("stage", 2)
		end
	end, nil, true)

	function button.luaHover()
		self.skipGotoIndex = true

		self.view.listUList:SelectItem(idx)

		self.skipGotoIndex = nil
	end
end

function InteractSecondCtrl:refreshBtnSelectState(button, idx, data)
	if data.selected then
		button.enableInputActon = true
		button.interactable = true
		button.visualInteractable = true
	else
		button.enableInputActon = false
	end

	button.interactable = data.disableButton ~= true
end

function InteractSecondCtrl:onMouseScroll(delta)
	local curIdx = self.view.listUList.selectedIndex
	local itemCount = self.view.listUList.itemCount
	local nextIdx = curIdx

	if itemCount > 0 and curIdx then
		if delta > 0 then
			nextIdx = math.max(curIdx - 1, 0)
		else
			nextIdx = math.min(curIdx + 1, itemCount - 1)
		end

		if nextIdx ~= curIdx then
			self.view.listUList:SelectItem(nextIdx)
		end
	end

	return itemCount > 1
end

function InteractSecondCtrl:checkUIShowVirtualMouseCursor()
	return false
end

function InteractSecondCtrl:getBtnHierarchyName(interactUnit, styleId)
	local btnHierarchyName = "UI_Node_Interaction_Second"
	local ent = interactUnit:getEntity()

	if ent and ent.staticId then
		btnHierarchyName = string.format("%s_%s", btnHierarchyName, ent.staticId)
	end

	if styleId ~= nil and styleId > -1 then
		btnHierarchyName = string.format("%s_%s", btnHierarchyName, styleId)
	end

	return btnHierarchyName
end

return InteractSecondCtrl
