-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PlayerEnhance\\Component\\PlayerSkillEquipComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local PlayerSkillEquipComponent = Class.LightClass("PlayerSkillEquipComponent", UIComponent)
local CallbackHandler = require("Core.Common.CallbackHandler")
local NoticeDef = require("Common.NoticeDef")
local UIConst = require("Const.UIConst")
local RedDotConst = require("Const.RedDotConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local ClientTextUtils = require("Utils.ClientTextUtils")

function PlayerSkillEquipComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.skillList = self.objectReference:GetRefValue("skillList")
	self.selector = self.objectReference:GetRefValue("selector")
	self.equipList = self.objectReference:GetRefValue("equipList")
	self.btnUpgrade = self.objectReference:GetRefValue("btnUpgrade")
	self.btnEquip = self.objectReference:GetRefValue("btnEquip")
	self.btnReplace = self.objectReference:GetRefValue("btnReplace")
	self.txtEquipBtn = self.objectReference:GetRefValue("txtEquipBtn")
	self.btnCombat = self.objectReference:GetRefValue("btnCombat")
	self.btnExplore = self.objectReference:GetRefValue("btnExplore")
	self.skillName = self.objectReference:GetRefValue("skillName")
	self.level = self.objectReference:GetRefValue("level")
	self.elementList = self.objectReference:GetRefValue("elementList")
	self.txtDesc = self.objectReference:GetRefValue("txtDesc")
	self.videoPlayer = self.objectReference:GetRefValue("videoPlayer")
	self.btnDownload = self.objectReference:GetRefValue("btnDownload")
	self.selectorFilter = self.objectReference:GetRefValue("selectorFilter")
	self.btnFilterOuter = self.objectReference:GetRefValue("btnFilterOuter")
	self.btnCleanFilter = self.objectReference:GetRefValue("btnCleanFilter")
	self.btnFilter = self.objectReference:GetRefValue("btnFilter")
	self.btnEditGroupName = self.objectReference:GetRefValue("btnEditGroupName")
	self.txtDesc.supportRichText = true
	self.rootComp = self.transform:GetComponent("UComponent")

	local btnEquipOC = self.btnEquip:GetComponent("ObjectReference")
	local btnEquipName = btnEquipOC:GetRefValue("txtNameUText")

	ClientTextUtils.setText(btnEquipName, pg.getGameString("BUTTON_EQUIP_NAME"))

	function self.skillList.luaRenderItem(button, index, data)
		self:onRenderSkillItem(button, index, data)
	end

	function self.equipList.luaRenderItem(button, index, data)
		self:onRenderEquipSkillItem(button, index, data)
	end

	function self.btnDownload.luaClick()
		return
	end

	function self.elementList.luaRenderItem(button, _, data)
		self:onRenderElementItem(button, data)
	end

	function self.btnUpgrade.luaClick()
		self:switchToSkillTree()
	end

	function self.btnCombat.luaClick()
		self.ctrl:switchToCombatEquip()
	end

	function self.btnExplore.luaClick()
		self.ctrl:switchToExploreEquip()
	end

	function self.btnEquip.luaClick()
		self:onSwitchSkill()
	end

	function self.btnReplace.luaClick()
		self:onSwitchSkill()
	end

	self.btnEquip:SetActive(false)
	self.btnReplace:SetActive(false)

	function self.selector.luaClick()
		self:onBtnSelector()
	end

	function self.selector.luaSelectedChanged(selector)
		self:onBtnSelectGroupOption(selector)
	end

	function self.btnEditGroupName.luaClick()
		self:onBtnRenameGroupName()
	end

	function self.selectorFilter.luaSelectedChanged(selector)
		self:onBtnSelectOrderOption(selector)
	end

	function self.btnFilterOuter.luaClick()
		self:onBtnFilterSkill()
	end

	function self.btnFilter.luaClick()
		self:onBtnFilterSkill()
	end

	function self.btnCleanFilter.luaClick()
		self:onBtnClearFilterSkill()
	end
end

function PlayerSkillEquipComponent:open(mode, defaultId, defaultSelectSkillId)
	self.tabIndex = mode or 1
	self.defaultId = defaultId
	self.defaultSelectSkillId = defaultSelectSkillId
	self.selectSkButton = nil
	self.selectEqButton = nil

	self:refreshSkillEquipPage()
	self.ctrl:addNavFocusListener(CallbackHandler(self, "onNavFocusChanged"), "SkillEquipConsoleBar")
end

function PlayerSkillEquipComponent:close()
	local navMgr = pg.global.navMgr

	if navMgr then
		navMgr:SetConsoleBarState("focusOnSkillList", false)
		navMgr:SetConsoleBarState("focusOnEquipList", false)
	end
end

function PlayerSkillEquipComponent:onNavFocusChanged()
	local navMgr = pg.global.navMgr

	if not navMgr then
		return
	end

	local group = navMgr.CurrentFocusedGroupName

	navMgr:SetConsoleBarState("focusOnSkillList", group == "ListSkill")
	navMgr:SetConsoleBarState("focusOnEquipList", group == "EquipList")
end

function PlayerSkillEquipComponent:refreshSkillEquipPage()
	self.model:clearFilter()
	self:switchTab()
end

function PlayerSkillEquipComponent:switchTab()
	local isCombat = self.tabIndex == 1

	self.rootComp:TryChangePage("SkillType", isCombat and 0 or 1)
	self.btnCombat:TryChangePage("Selecte", isCombat and 1 or 0)
	self.btnExplore:TryChangePage("Selecte", isCombat and 0 or 1)
	self:refreshEquipSkillList()
	self:refreshSelectView()
	self:focusSkillListDefault()
end

function PlayerSkillEquipComponent:focusSkillListDefault()
	if not pg.game.input:isUsingGamepad() then
		return
	end

	local navMgr = pg.global.navMgr

	if not navMgr then
		return
	end

	self.ctrl:startTimer(function()
		navMgr:FocusGroupByName("ListSkill")
	end, 0.05)
end

function PlayerSkillEquipComponent:tryGamepadBackToSkillList()
	if not pg.game.input:isUsingGamepad() then
		return false
	end

	local navMgr = pg.global.navMgr

	if not navMgr then
		return false
	end

	if navMgr.CurrentFocusedGroupName ~= "EquipList" then
		return false
	end

	self.gpEquipFlow = false

	navMgr:FocusGroupByName("ListSkill")

	return true
end

function PlayerSkillEquipComponent:refreshEquipSkillList()
	local isCombat = self.tabIndex == 1
	local dataList = self.model:getEquipSkillList(isCombat)

	self.skillList:SetList(dataList)

	local selectIndex = 0

	if self.defaultSelectSkillId then
		for k, v in ipairs(dataList) do
			if v.id == self.defaultSelectSkillId then
				selectIndex = k - 1

				break
			end
		end
	end

	local res, skBtn = self.skillList:TryGetChildAt(selectIndex)

	if res then
		self._suppressSkillFocusJump = true

		skBtn:OnClickSimulate()

		self._suppressSkillFocusJump = false
	end
end

function PlayerSkillEquipComponent:refreshSkillListView()
	local isCombat = self.tabIndex == 1
	local dataList = self.skillList.itemData

	self.model:refreshEquipSkillList(isCombat, dataList)
	self.skillList:RefreshList()

	dataList = self.equipList.itemData

	self.model:refreshEquippedSkillList(isCombat, dataList)
	self.equipList:RefreshList()
end

function PlayerSkillEquipComponent:onRenderSkillItem(button, index, data)
	local oc = button:GetComponent("ObjectReference")
	local tLevel = oc:GetRefValue("txtLevel")
	local tName = oc:GetRefValue("txtName")
	local iIcon = oc:GetRefValue("icon")

	button.name = index
	button.draggable = false

	if data.isEmpty then
		button:TryChangePage("SkillStage", 3)

		return
	end

	ClientTextUtils.setText(tName, data.name)

	local skillState = data.state

	if skillState == self.model.SKILL_STATE.CAN_UPGRADE then
		button:TryChangePage("Update", 1)
	else
		button:TryChangePage("Update", 0)
	end

	if data.keyBoard then
		local iPbKey = oc:GetRefValue("keyHotKey")
		local isMobile = pg.global.ui:runPlatformByMobile()

		iPbKey.gameObject:SetActiveEx(not isMobile)

		if not isMobile then
			iPbKey:SetHotKeyPaths(data.keyBoard)
		end

		button:TryChangePage("Equip", 1)
	else
		button:TryChangePage("Equip", 0)
	end

	if skillState == self.model.SKILL_STATE.CANT_UNLOCK_LEVEL_INSUFFICIENT or skillState == self.model.SKILL_STATE.CANT_UNLOCK_CONDITION_NOT_MEET then
		button:TryChangePage("SkillStage", 0)
		ClientTextUtils.setText(tLevel, "")
	elseif skillState == self.model.SKILL_STATE.CAN_UNLOCK then
		button:TryChangePage("SkillStage", 1)
		ClientTextUtils.setText(tLevel, string.format("0/%d", data.maxLv))
	else
		button:TryChangePage("SkillStage", 2)

		local nodeData = pg.me.skillNodeMap[data.id]

		ClientTextUtils.setText(tLevel, string.format("%d/%d", nodeData.lv, data.maxLv))

		button.draggable = true
	end

	iIcon.url = data.icon

	function button.luaBeginDrag()
		button:TryChangePage("SkillStage", 4)
		self:onClickSkillItem(button)

		local dragWidget = CS.XGUI.UComponent.draggingWidget

		if IsNil(dragWidget) then
			return
		end

		dragWidget:TryChangePage("HideText", 1)
		dragWidget:TryChangePage("Equip", 0)
		dragWidget:TryChangePage("Update", 0)
		dragWidget:TryChangePage("SkillLevel", 1)
	end

	function button.luaEndDrag(dropWidget)
		button:TryChangePage("SkillStage", 2)
		self:onDropSkillItem(button, dropWidget)
	end

	function button.luaClick(isFromNavigation)
		self:onClickSkillItem(button, isFromNavigation)
	end
end

function PlayerSkillEquipComponent:onClickSkillItem(button, isFromNavigation)
	self.selectSkButton = button

	self:refreshSkillView()
	self:refreshBtnState()

	if isFromNavigation == false and not self._suppressSkillFocusJump and pg.game.input:isUsingGamepad() then
		local targetIdx = self:pickEquipTargetSlotIndex(button.dataFromUList)

		if targetIdx ~= nil then
			self.gpEquipFlow = true

			self:focusEquipSlot(targetIdx)
		end
	elseif isFromNavigation == true then
		self.gpEquipFlow = false
	end
end

function PlayerSkillEquipComponent:pickEquipTargetSlotIndex(selectedData)
	local itemData = self.equipList.itemData

	if IsNil(itemData) or itemData.Count == 0 then
		return nil
	end

	local count = itemData.Count
	local realId = selectedData and selectedData.realId

	if realId then
		for i = 0, count - 1 do
			local d = itemData[i]

			if d and not d.isEmpty and d.realId == realId then
				for j = 0, count - 1 do
					local other = itemData[j]

					if j ~= i and other and not other.locked then
						return j
					end
				end
			end
		end
	end

	for i = 0, count - 1 do
		local d = itemData[i]

		if d and d.isEmpty and not d.locked then
			return i
		end
	end

	for i = 0, count - 1 do
		local d = itemData[i]

		if d and not d.locked then
			return i
		end
	end

	return nil
end

function PlayerSkillEquipComponent:focusEquipSlot(idx0)
	if idx0 == nil then
		return
	end

	local res, slotBtn = self.equipList:TryGetChildAt(idx0)

	if not res or IsNil(slotBtn) then
		return
	end

	local navMgr = pg.global.navMgr

	if not navMgr then
		return
	end

	navMgr:FocusItem(slotBtn)
end

function PlayerSkillEquipComponent:refreshSkillView()
	local data = self.selectSkButton.dataFromUList

	ClientTextUtils.setText(self.skillName, data.name)
	ClientTextUtils.setText(self.level, string.format("Lv.%d", data.level or 0))
	ClientTextUtils.setText(self.txtDesc, data.desc)

	self.videoPlayer.videoLoop = true
	self.videoPlayer.useAlpha = false
	self.videoPlayer.resID = data.video

	self.elementList:SetList(data.attrs)
end

function PlayerSkillEquipComponent:onRenderElementItem(button, data)
	local oc = button:GetComponent("ObjectReference")

	if IsNil(oc) then
		return
	end

	local iName = oc:GetRefValue("txtName")

	ClientTextUtils.setText(iName, data.name)
end

function PlayerSkillEquipComponent:onRenderEquipSkillItem(button, index, data)
	local oc = button:GetComponent("ObjectReference")
	local iIcon = oc:GetRefValue("icon")
	local iPbKey = oc:GetRefValue("hotKeyContent")
	local isMobile = pg.global.ui:runPlatformByMobile()

	if data.locked then
		button:TryChangePage("Lock", 0)

		return
	else
		button:TryChangePage("Lock", 1)
	end

	button.name = index

	function button.luaClick(isFromNavigation)
		self:onClickEquipSkillItem(button, isFromNavigation)
	end

	if not isMobile then
		iPbKey:SetHotKeyPaths(data.fixedKeyBoard)
	end

	button:TryChangePage("BgType", data.isCombat and 0 or 1)

	local treePath = string.format(RedDotConst.RedDotPath.PLAYER_EQUIP_SKILL_LIST_ITEM, tostring(data.isCombat), data.index)
	local showRedDot = self.model:redDot_GetPlayerMainEquipState(data)

	pg.global.setRedDot(treePath, button, showRedDot, RedDotConst.RedDotStyle.POINT)

	if data.isEmpty then
		button:TryChangePage("isEmpty", 1)

		return
	end

	iIcon.url = data.icon

	button:TryChangePage("isEmpty", 0)
end

function PlayerSkillEquipComponent:onClickEquipSkillItem(button, isFromNavigation)
	self.selectEqButton = button

	if self.gpEquipFlow and pg.game.input:isUsingGamepad() then
		if isFromNavigation == false then
			self.gpEquipFlow = false

			self:onEquipCombatClick()
		else
			self:refreshBtnState()
		end

		return
	end

	local dataList = self.skillList.itemData
	local idx = self.model:getEquipSkillItemIndex(dataList, button.dataFromUList.id)
	local res, skBtn = self.skillList:TryGetChildAt(idx)

	if res then
		self._suppressSkillFocusJump = true

		skBtn:OnClickSimulate()

		self._suppressSkillFocusJump = false
	end

	self:refreshBtnState()
end

function PlayerSkillEquipComponent:refreshBtnState()
	if IsNil(self.selectSkButton) or IsNil(self.selectEqButton) then
		return
	end

	local data1 = self.selectSkButton.dataFromUList
	local data2 = self.selectEqButton.dataFromUList

	self.rootComp:TryChangePage("SkillBtn", 0)
	self.btnEquip:TryChangePage("button", 0)
	self.btnReplace:TryChangePage("button", 0)

	self.btnEquip.interactable = true
	self.btnReplace.interactable = true

	if data1.state == self.model.SKILL_STATE.CANT_UNLOCK_LEVEL_INSUFFICIENT or data1.state == self.model.SKILL_STATE.CANT_UNLOCK_CONDITION_NOT_MEET or data1.state == self.model.SKILL_STATE.CAN_UNLOCK then
		if data2.realId and data1.realId ~= data2.realId then
			self.btnReplace.interactable = false

			self.rootComp:TryChangePage("SkillBtn", 1)
			self.btnReplace:TryChangePage("button", 4)
		else
			self.btnEquip:TryChangePage("button", 4)

			self.btnEquip.interactable = false
		end
	elseif not data1.isEmpty and not data2.isEmpty then
		if data1.realId == data2.realId then
			self.btnEquip:TryChangePage("button", 4)

			self.btnEquip.interactable = false
		else
			self.rootComp:TryChangePage("SkillBtn", 1)
		end
	end
end

function PlayerSkillEquipComponent:onSwitchSkill()
	self:onEquipCombatClick()
end

function PlayerSkillEquipComponent:refreshSelectView()
	self:refreshOrderSelector()

	local isCombat = self.tabIndex == 1

	self:refreshBoxSelector(isCombat)

	local curIndex = self.model:getCurSkillIndex(isCombat)

	self.selector:ForceSelect(curIndex - 1, false)
end

function PlayerSkillEquipComponent:switchToSkillTree()
	local data = self.selectSkButton.dataFromUList

	self.ctrl:openSkillTreePage(data.realId)
end

function PlayerSkillEquipComponent:onDropSkillItem(drag, drop)
	if IsNil(drop) then
		return
	end

	local dropData = drop.dataFromUList

	if not dropData.isEquippedData or dropData.locked then
		return
	end

	self.selectSkButton = drag
	self.selectEqButton = drop

	self:onEquipCombatClick()
end

function PlayerSkillEquipComponent:onBtnFilterSkill()
	pg.global.ui:open(UIConst.UI_ID_PLAYER_SKILL_FILTER, {
		filter = self.model:getFilter(),
		cancelCallback = function()
			return
		end,
		confirmCallback = function()
			self.rootComp:TryChangePage("State", self.model:parseFilter() and 1 or 0)
			self:switchTab()
		end
	})
end

function PlayerSkillEquipComponent:onBtnClearFilterSkill()
	self.model:clearFilter()
	self:switchTab()
	self.rootComp:TryChangePage("State", 0)
end

function PlayerSkillEquipComponent:refreshOrderSelector()
	local options = self.model:parseOrders()

	self.selectorFilter:SetOptions(options)

	self.selectorFilter.selectedIndex = self.model:getSelectOrderIndex()
end

function PlayerSkillEquipComponent:onBtnSelectOrderOption(selector)
	local selectedIndex = selector.selectedIndex

	self.model:selectOrder(selectedIndex)
	self:refreshEquipSkillList()
end

function PlayerSkillEquipComponent:onBtnSelector()
	local isCombat = self.tabIndex == 1

	self:refreshBoxSelector(isCombat)
	self:refreshSkillListView()
	self:refreshBtnState()
end

function PlayerSkillEquipComponent:refreshBoxSelector(isCombat)
	local options = self.model:getSkillGroupOptions(isCombat)

	function self.selector.luaRenderPopup(_, uList)
		self.popupGroupList = uList

		self:onRenderBoxPopup(uList, options)
	end

	self.selector:SetOptions(options)

	local id = self.defaultId

	if not IsNil(self.selectEqButton) then
		id = self.selectEqButton.dataFromUList.id
	end

	local equipDataList, index = self.model:getEquippedSkillList(isCombat, id)

	self.equipList:SetList(equipDataList)

	if not self.defaultSelectSkillId then
		local res, eqBtn = self.equipList:TryGetChildAt(index - 1)

		if res then
			eqBtn:OnClickSimulate()
		end
	end

	self.defaultId = nil
	self.defaultSelectSkillId = nil
end

function PlayerSkillEquipComponent:onRenderBoxPopup(uList, options)
	function uList.luaRenderItem(button, idx, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtUText = objectReference:GetRefValue("txtUText")
		local btnAdd = objectReference:GetRefValue("btnAdd")
		local btnDelete = objectReference:GetRefValue("btnDelete")

		ClientTextUtils.setText(txtUText, data.label)

		local isCombat = self.tabIndex == 1
		local curIndex = self.model:getCurSkillIndex(isCombat)
		local isSelected = curIndex == idx + 1

		button.isSelected = isSelected

		button:TryChangePage("Check", isSelected and 1 or 0)
		button:TryChangePage("AddGroup", data.add and 1 or 0)

		if data.canDelete then
			button:TryChangePage("HideDelete", isSelected and 1 or 2)
		else
			button:TryChangePage("HideDelete", 0)
		end

		local deleteUsable = data.canDelete and not isSelected and not data.add
		local addUsable = data.add

		btnAdd.luaClick = addUsable and function()
			self:onSelectAddGroup()
		end or nil
		btnDelete.luaClick = deleteUsable and function()
			self:onSelectDeleteGroup(data)
		end or nil
	end

	uList:SetList(options)
end

function PlayerSkillEquipComponent:onBtnSelectGroupOption(selector)
	local optionData = selector.selectedItem
	local isCombat = self.tabIndex == 1

	self.selector:ClosePopup()
	pg.me:serverMsg("RPC_CS_SelectCustomAbilityIds", isCombat, optionData.index, function(res)
		if not res then
			return
		end

		self:onBtnSelector()

		if not IsNil(self.popupGroupList) then
			self.popupGroupList.itemData = self.selector.options

			self.popupGroupList:RefreshList()
		end
	end)
end

function PlayerSkillEquipComponent:onSelectAddGroup()
	local isCombat = self.tabIndex == 1

	self.selector:ClosePopup()
	pg.global.showConfirmMsgRaw(pg.getGameString("SKILL_GROUP"), pg.getGameString("SKILL_GROUP_ADD"), function()
		pg.me:serverMsg("RPC_CS_AddCustomAbilityIds", isCombat, function(res)
			if not res then
				return
			end

			pg.global.showBubbleMessageRaw(pg.getGameString("SKILL_GROUP_ADD_SUCCESS"), 3)
			self:onBtnSelector()
		end)
	end, false, function()
		return
	end)
end

function PlayerSkillEquipComponent:onSelectDeleteGroup(data)
	local isCombat = self.tabIndex == 1

	self.selector:ClosePopup()
	pg.global.showConfirmMsgRaw(pg.getGameString("SKILL_GROUP"), pg.getGameString("SKILL_GROUP_DEL"), function()
		pg.me:serverMsg("RPC_CS_DeleteCustomAbilityIds", isCombat, data.index, function(res)
			if not res then
				return
			end

			pg.global.showBubbleMessageRaw(pg.getGameString("SKILL_GROUP_DEL_SUCCESS"), 3)
			self:onBtnSelector()
		end)
	end, false, function()
		return
	end)
end

function PlayerSkillEquipComponent:onBtnRenameGroupName()
	local isCombat = self.tabIndex == 1

	pg.global.ui:open(UIConst.UI_ID_PLAYER_RENAME, {
		placeholder = "",
		mode = "Rename",
		title = pg.getGameString("RENAME_TIPS_SKILL"),
		confirmCallback = function(newName)
			pg.me:serverMsg("RPC_CS_UpdateCustomAbilityIdsName", isCombat, newName, function(res)
				if not res then
					return
				end

				self:renameFinished(isCombat)
			end)
		end
	})
end

function PlayerSkillEquipComponent:renameFinished(isCombat)
	self:refreshBoxSelector(isCombat)

	local curIndex = self.model:getCurSkillIndex(isCombat)

	self.selector:ForceSelect(curIndex - 1)
end

function PlayerSkillEquipComponent:onEquipCombatClick()
	if IsNil(self.selectSkButton) or IsNil(self.selectEqButton) then
		return
	end

	local data1 = self.selectSkButton.dataFromUList
	local data2 = self.selectEqButton.dataFromUList

	if data1 == nil or data2 == nil then
		return
	end

	if data1.realId == data2.realId then
		return
	end

	if data1.realId == nil then
		return
	end

	local me = pg.me
	local serverOpcode = self.tabIndex == 1 and "RPC_CS_UpdateFightAbilityId" or "RPC_CS_UpdateExploreAbilityId"

	me:serverMsg(serverOpcode, data2.index, data1.realId, CallbackHandler(self, "switchCombatSkillCallback"))
end

function PlayerSkillEquipComponent:switchCombatSkillCallback(res)
	if not res then
		pg.global.showBubbleMessageRaw(pg.getGameString("FAILED"), 3)

		return
	end

	pg.global.showBubbleMessageRaw(pg.getGameString("SUCCEED"), 3)
	self:refreshSkillListView()
	self:refreshBtnState()

	if IsNil(self.selectEqButton) then
		return
	end

	local oc = self.selectEqButton:GetComponent("ObjectReference")
	local iAnim = oc:GetRefValue("vAnimation")

	self.selectEqButton:TryChangePage("Refresh", 1)
	UIUtils.PlayAnimation(iAnim, "VX_UI_Node_Skill_Refresh_01", function()
		self.selectEqButton:TryChangePage("Refresh", 0)
	end)
end

return PlayerSkillEquipComponent
