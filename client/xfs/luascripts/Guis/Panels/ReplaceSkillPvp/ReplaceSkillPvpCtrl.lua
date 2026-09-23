-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ReplaceSkillPvp\\ReplaceSkillPvpCtrl.lua

local MessageName = require("Const.MessageName")
local Const = require("Common.Const.Const")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ReplaceSkillPvpCtrl = Class.LightClass("ReplaceSkillPvpCtrl", UICtrl)
local ReplaceSkillPvpGamePadComponent = require("Guis.Panels.ReplaceSkillPvp.Component.ReplaceSkillPvpGamePadComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")

ReplaceSkillPvpCtrl.messages = {
	[MessageName.PET_ABILITY_PRESET_CHANGE] = {
		"onPetPresetChange",
		true
	},
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

function ReplaceSkillPvpCtrl:onCreate(info)
	self.model:setCurSelectPetTemplateId(info.templateId)
	UICtrl.onCreate(self, info)
end

function ReplaceSkillPvpCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:dismiss()
	end

	function self.view.listEquipmentUList.luaRenderItem(button, index, data)
		self:setupEquippedSkill(button, index, data)
	end

	function self.view.listLearnUList.luaRenderItem(button, index, data)
		self:setupAllSKills(button, index, data)
	end

	for idx = 1, Const.PET_ABILITY_PRESET_COUNT do
		local btn = self.view.planBtns[idx]
		local planName = self:getShowName(self.model:getPetsAbilityPlanInfo(idx).name, idx)

		ClientTextUtils.setText(btn.title, pg.getLocalizationText(planName))

		local objectReference = btn:GetComponent("ObjectReference")
		local buttonUButton = objectReference:GetRefValue("buttonUButton")

		buttonUButton.gameObject:SetActiveEx(false)

		function btn.luaClick()
			if idx == self.model.curShowPlanIdx then
				return
			end

			self:switchToPlanByIdx(idx)
			self:enterSelectingSkillsMode(false)
		end
	end
end

function ReplaceSkillPvpCtrl:getShowName(name, idx)
	if not name or name == "" then
		return ClientTextUtils.concatByLanguage(pg.getGameString("ABILITY_PLAN"), idx)
	else
		return name
	end
end

function ReplaceSkillPvpCtrl:onShow()
	local idx = self.model:getCurFightIdx()

	self.view.root:TryChangePage("Tab", idx - 1)
	self:switchToPlanByIdx(idx)
end

function ReplaceSkillPvpCtrl:refreshEquippedSkill(idx)
	local curSkillData = self.model:getCurrentSkillByGroup(idx)

	self.curSkillData = curSkillData

	self:initEquipSkillArea(curSkillData)
	self.view.listEquipmentUList:SetList(curSkillData)
end

function ReplaceSkillPvpCtrl:refreshUnlockSkill(idx)
	local unlockSkillData = self.model:getPetUnlockSkill()

	self:initUnlockSkillArea(unlockSkillData)
	self.view.listLearnUList:SetList(unlockSkillData)
end

function ReplaceSkillPvpCtrl:setupEquippedSkill(button, index, data)
	button.name = data.abilityType

	if data.tIndex == 1 then
		button.draggable = false

		local objectReference = button:GetComponent("ObjectReference")
		local keyHotKeyContent = objectReference:GetRefValue("keyHotKeyContent")
		local root = objectReference:GetRefValue("root")

		keyHotKeyContent:SetHotKeyPaths(index == 0 and {
			"Hud/SkillQ"
		} or {
			"Hud/SkillE"
		})

		function button.luaPress()
			self:selectEquipmentSlot(index)

			self.recordSelectingSkillSlotIndex = index + 1

			self:enterSelectingSkillsMode(true, self.model.EMPTY_ABILITY_ID)
		end
	else
		button.draggable = true

		local objectReference = button:GetComponent("ObjectReference")
		local skillName = objectReference:GetRefValue("skillName")
		local powerNum = objectReference:GetRefValue("powerNum")
		local costNum = objectReference:GetRefValue("costNum")
		local skillIcon = objectReference:GetRefValue("skillIcon")
		local elementButton = objectReference:GetRefValue("elementButton")
		local featureList = objectReference:GetRefValue("featureList")
		local keyHotKeyContent = objectReference:GetRefValue("keyHotKeyContent")
		local exchangeUButton = objectReference:GetRefValue("exchangeUButton")

		keyHotKeyContent:SetHotKeyPaths(index == 0 and {
			"Hud/SkillQ"
		} or {
			"Hud/SkillE"
		})
		ClientTextUtils.setText(skillName, pg.getLocalizationText(data.name))
		ClientTextUtils.setText(powerNum, data.numberList[1].number)
		ClientTextUtils.setText(costNum, data.numberList[2].number)

		skillIcon.url = LuaUIUtils.getSkillIcon(data.icon)

		button:TryChangePage("isS", data.rare or 0)
		LuaUIUtils.setElementButtonNew(elementButton, data.elementType)

		function featureList.luaRenderItem(b, i, d)
			local objectReference1 = b:GetComponent("ObjectReference")
			local txtNameUText = objectReference1:GetRefValue("txtNameUText")

			ClientTextUtils.setText(txtNameUText, pg.getLocalizationText(d.tagName))
		end

		featureList:SetList(data.tagList)

		function button.luaRenderTooltip(btn, component)
			local objectRef = component:GetComponent("ObjectReference")
			local txtName = objectRef:GetRefValue("txtName")
			local listUList = objectRef:GetRefValue("listUList")
			local descText = objectRef:GetRefValue("descText")
			local icon = objectRef:GetRefValue("icon")
			local mainElement = objectRef:GetRefValue("mainElement")

			component:TryChangePage("IsRare", data.rare or 0)
			ClientTextUtils.setText(txtName, pg.getLocalizationText(data.name))

			icon.url = LuaUIUtils.getSkillIcon(data.icon)

			LuaUIUtils.setElementButtonNew(mainElement, data.elementType)
			ClientTextUtils.setText(descText, pg.getLocalizationText(data.desc))

			function listUList.luaRenderItem(b, i, d)
				local objectReference1 = b:GetComponent("ObjectReference")
				local txtNameUText = objectReference1:GetRefValue("txtNameUText")
				local numUText = objectReference1:GetRefValue("numUText")

				ClientTextUtils.setText(txtNameUText, d.title)
				ClientTextUtils.setText(numUText, d.value)
				b:TryChangePage("ShowIcon", d.icon == 0 and 1 or 0)
				b:TryChangePage("IconType", d.icon - 1)
			end

			listUList:SetList({
				{
					icon = 0,
					title = pg.getGameString("SKILL_CARD_TYPE"),
					value = pg.getLocalizationText(data.typeName)
				},
				{
					icon = 0,
					title = pg.getGameString("SKILL_CARD_TAG"),
					value = pg.getLocalizationText(data.tagList[1].tagName)
				},
				{
					icon = 1,
					title = pg.getGameString("SKILL_CARD_POWER"),
					value = data.numberList[1].number
				},
				{
					icon = 2,
					title = pg.getGameString("SKILL_CARD_ENERGY"),
					value = data.numberList[2].number
				}
			})
		end

		function button.luaHover()
			if self.isDraggingCard then
				local _, page = button:TryGetCurrentPage("DragState")

				self.recordLastPage = page

				button:TryChangePage("DragState", 4)
			end
		end

		function button.luaUnhover()
			if self.isDraggingCard then
				button:TryChangePage("DragState", self.recordLastPage or 0)
			end
		end

		function button.luaPress()
			self:selectEquipmentSlot(index)
			self:enterSelectingSkillsMode(false)
		end

		function exchangeUButton.luaClick()
			self.recordSelectingSkillSlotIndex = index + 1

			self:enterSelectingSkillsMode(true, data.abilityId)
		end

		function button.luaEndDrag(dropWidget)
			self:equipSkillLuaEndDrag(data, dropWidget, button)
			button:TryChangePage("DragState", 0)

			self.isDraggingCard = false
		end

		function button.luaBeginDrag()
			local objectReference1 = button.replicaWidget:GetComponent("ObjectReference")
			local skillName1 = objectReference1:GetRefValue("skillName")
			local powerNum1 = objectReference1:GetRefValue("powerNum")
			local costNum1 = objectReference1:GetRefValue("costNum")
			local featureList1 = objectReference1:GetRefValue("featureList")

			ClientTextUtils.setText(skillName1, pg.getLocalizationText(data.name))
			ClientTextUtils.setText(powerNum1, data.numberList[1].number)
			ClientTextUtils.setText(costNum1, data.numberList[2].number)

			function featureList1.luaRenderItem(b, i, d)
				local objectReference2 = b:GetComponent("ObjectReference")
				local txtNameUText = objectReference2:GetRefValue("txtNameUText")

				ClientTextUtils.setText(txtNameUText, pg.getLocalizationText(d.tagName))
			end

			featureList1:SetList(data.tagList)
			self:enterSelectingSkillsMode(false)
			button.replicaWidget:TryChangePage("DragState", 1)
			button:TryChangePage("DragState", 2)

			self.isDraggingCard = true
		end
	end
end

function ReplaceSkillPvpCtrl:selectEquipmentSlot(index)
	local equipmentSkillBtns = self:getAllEquipmentSkillBtns()

	for i = 0, equipmentSkillBtns.Length - 1 do
		equipmentSkillBtns[i]:TryChangePage("select", 0)
	end

	equipmentSkillBtns[index]:TryChangePage("select", 1)
end

function ReplaceSkillPvpCtrl:selectUnlockedSkillSlot(index)
	local unLockedSkillBtns = self:getAllUnlockedSkillBtns()

	for i = 0, unLockedSkillBtns.Length - 1 do
		unLockedSkillBtns[i]:TryChangePage("select", 0)
	end

	unLockedSkillBtns[index]:TryChangePage("select", 1)
end

function ReplaceSkillPvpCtrl:enterSelectingSkillsMode(enable, curAbilityId)
	self.inSelectingSkillsMode = enable

	local unLockedSkillBtns = self:getAllUnlockedSkillBtns()

	if enable then
		for i = 0, unLockedSkillBtns.Length - 1 do
			if unLockedSkillBtns[i].name ~= tostring(curAbilityId) then
				unLockedSkillBtns[i]:TryChangePage("Changing", 1)
			end
		end
	else
		for i = 0, unLockedSkillBtns.Length - 1 do
			unLockedSkillBtns[i]:TryChangePage("Changing", 0)
		end
	end
end

function ReplaceSkillPvpCtrl:equipSkillLuaEndDrag(data, dropWidget, oriButton)
	if dropWidget and oriButton then
		self.model:tryModifyAbility(dropWidget.dataFromUList.abilityType, oriButton.dataFromUList.abilityId, data.abilityType, dropWidget.dataFromUList.abilityId)
	else
		self.model:tryModifyAbility(data.abilityType, self.model.EMPTY_ABILITY_ID)
	end
end

function ReplaceSkillPvpCtrl:setupAllSKills(button, index, data)
	button.name = data.abilityId

	local objectReference = button:GetComponent("ObjectReference")
	local skillName = objectReference:GetRefValue("skillName")
	local powerNum = objectReference:GetRefValue("powerNum")
	local costNum = objectReference:GetRefValue("costNum")
	local skillIcon = objectReference:GetRefValue("skillIcon")
	local elementButton = objectReference:GetRefValue("elementButton")
	local featureList = objectReference:GetRefValue("featureList")
	local keyHotKeyContent = objectReference:GetRefValue("keyHotKeyContent")
	local root = objectReference:GetRefValue("root")

	ClientTextUtils.setText(skillName, pg.getLocalizationText(data.name))
	ClientTextUtils.setText(powerNum, data.numberList[1].number)
	ClientTextUtils.setText(costNum, data.numberList[2].number)

	skillIcon.url = LuaUIUtils.getSkillIcon(data.icon)

	button:TryChangePage("isS", data.rare or 0)
	button:TryChangePage("Equipment", 0)
	LuaUIUtils.setElementButtonNew(elementButton, data.elementType)

	function featureList.luaRenderItem(b, i, d)
		local objectReference1 = b:GetComponent("ObjectReference")
		local txtNameUText = objectReference1:GetRefValue("txtNameUText")

		ClientTextUtils.setText(txtNameUText, pg.getLocalizationText(d.tagName))
	end

	featureList:SetList(data.tagList)

	if self.curSkillData then
		if data.abilityId == self.curSkillData[1].abilityId then
			button:TryChangePage("Equipment", 1)
			keyHotKeyContent:SetHotKeyPaths("Hud/SkillQ")
		elseif data.abilityId == self.curSkillData[2].abilityId then
			button:TryChangePage("Equipment", 1)
			keyHotKeyContent:SetHotKeyPaths("Hud/SkillE")
		else
			button:TryChangePage("Equipment", 0)
		end
	end

	function button.luaRenderTooltip(btn, component)
		local objectRef = component:GetComponent("ObjectReference")
		local txtName = objectRef:GetRefValue("txtName")
		local listUList = objectRef:GetRefValue("listUList")
		local descText = objectRef:GetRefValue("descText")
		local icon = objectRef:GetRefValue("icon")
		local mainElement = objectRef:GetRefValue("mainElement")

		component:TryChangePage("IsRare", data.rare or 0)
		ClientTextUtils.setText(txtName, pg.getLocalizationText(data.name))

		icon.url = LuaUIUtils.getSkillIcon(data.icon)

		LuaUIUtils.setElementButtonNew(mainElement, data.elementType)
		ClientTextUtils.setText(descText, pg.getLocalizationText(data.desc))

		function listUList.luaRenderItem(b, i, d)
			local objectReference1 = b:GetComponent("ObjectReference")
			local txtNameUText = objectReference1:GetRefValue("txtNameUText")
			local numUText = objectReference1:GetRefValue("numUText")

			ClientTextUtils.setText(txtNameUText, d.title)
			ClientTextUtils.setText(numUText, d.value)
			b:TryChangePage("ShowIcon", d.icon == 0 and 1 or 0)
			b:TryChangePage("IconType", d.icon - 1)
		end

		listUList:SetList({
			{
				icon = 0,
				title = pg.getGameString("SKILL_CARD_TYPE"),
				value = pg.getLocalizationText(data.typeName)
			},
			{
				icon = 0,
				title = pg.getGameString("SKILL_CARD_TAG"),
				value = pg.getLocalizationText(data.tagList[1].tagName)
			},
			{
				icon = 1,
				title = pg.getGameString("SKILL_CARD_POWER"),
				value = data.numberList[1].number
			},
			{
				icon = 2,
				title = pg.getGameString("SKILL_CARD_ENERGY"),
				value = data.numberList[2].number
			}
		})
	end

	function button.luaEndDrag(dropWidget, rayBox)
		self:unlockSkillLuaEndDrag(data, dropWidget, rayBox)
		button:TryChangePage("DragState", 0)

		self.isDraggingCard = false
	end

	function button.luaBeginDrag()
		local objectReference1 = button.replicaWidget:GetComponent("ObjectReference")
		local skillName1 = objectReference1:GetRefValue("skillName")
		local powerNum1 = objectReference1:GetRefValue("powerNum")
		local costNum1 = objectReference1:GetRefValue("costNum")
		local featureList1 = objectReference1:GetRefValue("featureList")

		ClientTextUtils.setText(skillName1, pg.getLocalizationText(data.name))
		ClientTextUtils.setText(powerNum1, data.numberList[1].number)
		ClientTextUtils.setText(costNum1, data.numberList[2].number)

		function featureList1.luaRenderItem(b, i, d)
			local objectReference2 = b:GetComponent("ObjectReference")
			local txtNameUText = objectReference2:GetRefValue("txtNameUText")

			ClientTextUtils.setText(txtNameUText, pg.getLocalizationText(d.tagName))
		end

		featureList1:SetList(data.tagList)
		self:enterSelectingSkillsMode(false)
		button.replicaWidget:TryChangePage("DragState", 1)
		button:TryChangePage("DragState", 2)

		self.isDraggingCard = true
	end

	function button.luaPress()
		self:selectUnlockedSkillSlot(index)

		if not self.inSelectingSkillsMode then
			return
		end

		local _, page = root:TryGetCurrentPage("Changing")

		if page ~= 1 then
			return
		end

		if not self.recordSelectingSkillSlotIndex then
			return
		end

		self.model:tryModifyAbility(self.recordSelectingSkillSlotIndex, data.abilityId)
		self:enterSelectingSkillsMode(false)
	end
end

function ReplaceSkillPvpCtrl:unlockSkillLuaEndDrag(data, dropWidget, rayBox)
	if dropWidget and rayBox and rayBox.gameObject.name == "EquipmentRayBox" then
		self.model:tryModifyAbility(tonumber(dropWidget.name), data.abilityId)
	end
end

function ReplaceSkillPvpCtrl:getAllEquipmentSkillBtns()
	return self.view.listEquipmentUList:GetAllButtons()
end

function ReplaceSkillPvpCtrl:getAllUnlockedSkillBtns()
	return self.view.listLearnUList:GetAllButtons()
end

function ReplaceSkillPvpCtrl:switchToPlanByIdx(idx)
	self.model:setCurShowPlanIdx(idx)
	self:refreshWholeListByPresetId(idx)
end

function ReplaceSkillPvpCtrl:refreshWholeListByPresetId(idx)
	self:refreshEquippedSkill(idx)
	self:refreshUnlockSkill(idx)
end

function ReplaceSkillPvpCtrl:onPetPresetChange(info)
	local presetId = info
	local presetName = self:getShowName(nil, presetId)

	if presetId == self.model.curShowPlanIdx then
		self:refreshWholeListByPresetId(presetId)
	end

	local btn = self.view.planBtns[presetId]

	ClientTextUtils.setText(btn.title, pg.getLocalizationText(presetName))
end

function ReplaceSkillPvpCtrl:continueSwitchPlanPages(isRight)
	if isRight == true then
		if self.model.curShowPlanIdx == Const.PET_ABILITY_PRESET_COUNT then
			self.view.planBtns[1]:OnClickSimulate()
		else
			self.view.planBtns[self.model.curShowPlanIdx + 1]:OnClickSimulate()
		end
	elseif self.model.curShowPlanIdx == 1 then
		self.view.planBtns[Const.PET_ABILITY_PRESET_COUNT]:OnClickSimulate()
	else
		self.view.planBtns[self.model.curShowPlanIdx - 1]:OnClickSimulate()
	end
end

function ReplaceSkillPvpCtrl:deSelectAllGamePadFocus()
	local btns = self.view.listEquipmentUList:GetAllButtons()

	for i = 0, btns.Length - 1 do
		btns[i]:TryChangePage("select", 0)
		btns[i]:ClosePopup()
	end

	btns = self.view.listLearnUList:GetAllButtons()

	for i = 0, btns.Length - 1 do
		btns[i]:TryChangePage("select", 0)
		btns[i]:ClosePopup()
	end
end

function ReplaceSkillPvpCtrl:initEquipSkillArea(data)
	local t = {}

	for i = 1, #data do
		local x = math.floor((i - 1) / 2) + 1
		local y = (i - 1) % 2 + 1

		if y == 1 then
			t[x] = {}
		end

		t[x][y] = {}

		if data[i].abilityId == self.model.EMPTY_ABILITY_ID or data[i].abilityId == nil then
			t[x][y].ValidSlot = false
		else
			t[x][y].ValidSlot = true
		end

		t[x][y].Focus = function(x1, y1)
			self.gamePadComponent.navigation:baseFocus(t, x1, y1, self.view.consoleKeyUList)
			self:deSelectAllGamePadFocus()

			local btns = self.view.listEquipmentUList:GetAllButtons()

			btns[i - 1]:TryChangePage("select", 1)
		end

		if t[x][y].ValidSlot then
			t[x][y].Fun1 = function(x1, y1)
				local btns = self.view.listEquipmentUList:GetAllButtons()
				local objectReference = btns[i - 1]:GetComponent("ObjectReference")
				local exchangeUButton = objectReference:GetRefValue("exchangeUButton")

				exchangeUButton.luaClick()
			end
			t[x][y].Fun1Name = pg.getGameString("EXCHANGE_SKILL")
		end

		t[x][y].Fun4 = function(x1, y1)
			local btns = self.view.listEquipmentUList:GetAllButtons()

			btns[i - 1].luaPress()

			if data[i].abilityId == self.model.EMPTY_ABILITY_ID or data[i].abilityId == nil then
				-- block empty
			else
				btns[i - 1]:InteractPopup()
			end
		end
		t[x][y].Fun4Name = pg.getGameString("GAMEPAD_CHOOSE")
		t[x][y].Fun3 = function(x1, y1)
			local btns = self.view.listEquipmentUList:GetAllButtons()

			if btns[i - 1] and btns[i - 1].isTooltipOpen then
				btns[i - 1]:ClosePopup()

				return
			end

			self.view.btnCloseUButton.luaClick()
		end
		t[x][y].Fun3Name = pg.getGameString("BACK_TO_PRE")
		t[x][y].Fun9 = function(x1, y1)
			self:continueSwitchPlanPages(false)
			self.gamePadComponent.navigation:reFocus()
		end
		t[x][y].Fun10 = function(x1, y1)
			self:continueSwitchPlanPages(true)
			self.gamePadComponent.navigation:reFocus()
		end
	end

	self.gamePadComponent.navigation:initAreaTableSlots(self.gamePadComponent.navigation.EQUIP_SKILL_AREA, t)
end

function ReplaceSkillPvpCtrl:initUnlockSkillArea(data)
	local t = {}

	for i = 1, #data do
		local x = math.floor((i - 1) / 2) + 1
		local y = (i - 1) % 2 + 1

		if y == 1 then
			t[x] = {}
		end

		t[x][y] = {}

		if data[i].abilityId == self.model.EMPTY_ABILITY_ID or data[i].abilityId == nil then
			t[x][y].ValidSlot = false
		else
			t[x][y].ValidSlot = true
		end

		t[x][y].Focus = function(x1, y1)
			self.gamePadComponent.navigation:baseFocus(t, x1, y1, self.view.consoleKeyUList)
			self:deSelectAllGamePadFocus()

			local btns = self.view.listLearnUList:GetAllButtons()

			btns[i - 1]:TryChangePage("select", 1)
		end
		t[x][y].Fun4 = function(x1, y1)
			local btns = self.view.listLearnUList:GetAllButtons()

			btns[i - 1].luaPress()

			if data[i].abilityId == self.model.EMPTY_ABILITY_ID or data[i].abilityId == nil then
				-- block empty
			else
				btns[i - 1]:InteractPopup()
			end
		end
		t[x][y].Fun4Name = pg.getGameString("GAMEPAD_CHOOSE")
		t[x][y].Fun3 = function(x1, y1)
			local btns = self.view.listLearnUList:GetAllButtons()

			if btns[i - 1] and btns[i - 1].isTooltipOpen then
				btns[i - 1]:ClosePopup()

				return
			end

			self.view.btnCloseUButton.luaClick()
		end
		t[x][y].Fun3Name = pg.getGameString("BACK_TO_PRE")
		t[x][y].Fun9 = function(x1, y1)
			self:continueSwitchPlanPages(false)
			self.gamePadComponent.navigation:reFocus()
		end
		t[x][y].Fun10 = function(x1, y1)
			self:continueSwitchPlanPages(true)
			self.gamePadComponent.navigation:reFocus()
		end
	end

	self.gamePadComponent.navigation:initAreaTableSlots(self.gamePadComponent.navigation.UNLOCK_SKILL_AREA, t)
end

function ReplaceSkillPvpCtrl:equipSkillGamePadBeginDrag(button, data, cloneButton)
	local objectReference1 = cloneButton:GetComponent("ObjectReference")
	local skillName1 = objectReference1:GetRefValue("skillName")
	local powerNum1 = objectReference1:GetRefValue("powerNum")
	local costNum1 = objectReference1:GetRefValue("costNum")
	local featureList1 = objectReference1:GetRefValue("featureList")

	ClientTextUtils.setText(skillName1, pg.getLocalizationText(data.name))
	ClientTextUtils.setText(powerNum1, data.numberList[1].number)
	ClientTextUtils.setText(costNum1, data.numberList[2].number)

	function featureList1.luaRenderItem(b, i, d)
		local objectReference2 = b:GetComponent("ObjectReference")
		local txtNameUText = objectReference2:GetRefValue("txtNameUText")

		ClientTextUtils.setText(txtNameUText, pg.getLocalizationText(d.tagName))
	end

	featureList1:SetList(data.tagList)
	self:enterSelectingSkillsMode(false)
	cloneButton:TryChangePage("DragState", 1)
	button:TryChangePage("DragState", 2)
end

function ReplaceSkillPvpCtrl:unlockSkillGamePadBeginDrag(button, data, cloneButton)
	local objectReference1 = cloneButton:GetComponent("ObjectReference")
	local skillName1 = objectReference1:GetRefValue("skillName")
	local powerNum1 = objectReference1:GetRefValue("powerNum")
	local costNum1 = objectReference1:GetRefValue("costNum")
	local featureList1 = objectReference1:GetRefValue("featureList")

	ClientTextUtils.setText(skillName1, pg.getLocalizationText(data.name))
	ClientTextUtils.setText(powerNum1, data.numberList[1].number)
	ClientTextUtils.setText(costNum1, data.numberList[2].number)

	function featureList1.luaRenderItem(b, i, d)
		local objectReference2 = b:GetComponent("ObjectReference")
		local txtNameUText = objectReference2:GetRefValue("txtNameUText")

		ClientTextUtils.setText(txtNameUText, pg.getLocalizationText(d.tagName))
	end

	featureList1:SetList(data.tagList)
	self:enterSelectingSkillsMode(false)
	cloneButton:TryChangePage("DragState", 1)
	button:TryChangePage("DragState", 2)
end

function ReplaceSkillPvpCtrl:onInputDeviceChanged(deviceType)
	self.gamePadComponent:onInputDeviceChanged(deviceType)
end

function ReplaceSkillPvpCtrl:getEquipListItemByCursorIndex(x, y)
	local btns = self.view.listEquipmentUList:GetAllButtons()
	local index = (x - 1) * 2 + y - 1

	if btns[index] ~= nil then
		return btns[index].gameObject
	end

	return nil
end

function ReplaceSkillPvpCtrl:getUnlockListItemByCursorIndex(x, y)
	local btns = self.view.listLearnUList:GetAllButtons()
	local index = (x - 1) * 2 + y - 1

	if btns[index] ~= nil then
		return btns[index].gameObject
	end

	return nil
end

function ReplaceSkillPvpCtrl:resetDragState()
	local btns = self.view.listEquipmentUList:GetAllButtons()

	for i = 0, btns.Length - 1 do
		btns[i]:TryChangePage("DragState", 0)
	end

	btns = self.view.listLearnUList:GetAllButtons()

	for i = 0, btns.Length - 1 do
		btns[i]:TryChangePage("DragState", 0)
	end
end

return ReplaceSkillPvpCtrl
