-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GamepadMenuNew\\Component\\PetWheelComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local AudioConst = require("Const.AudioConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetWheelComponent = Class.LightClass("PetWheelComponent", UIComponent)
local PET_ITEM_NUM = 8

function PetWheelComponent:initView()
	self.petWheels = {}
	self.petPrepareBattleTeamList = nil
	self.petPrepareBattleTeamCount = 0
	self.selectedWheelIndex = nil
end

function PetWheelComponent:clearWheels()
	self.petWheels = {}
	self.selectedWheelIndex = nil
end

function PetWheelComponent:refreshPetPrepareBattleTeamList()
	self.petPrepareBattleTeamList = LuaUIUtils.getAllPetPrepareBattleTeamInfo()
	self.petPrepareBattleTeamCount = math.min(PET_ITEM_NUM, #self.petPrepareBattleTeamList)
end

function PetWheelComponent:initPetWheel(button)
	local petWheelTransform = button.transform

	petWheelTransform:GetComponent("UButton"):TryChangePage("Type", 1)

	local petWheelObjRef = petWheelTransform:GetComponent("ObjectReference")
	local petWheel = petWheelObjRef:GetRefValue("menu")
	local petListBtn = petWheelObjRef:GetRefValue("listPetButton")
	local petListName = petWheelObjRef:GetRefValue("name")
	local titleText = petWheelObjRef:GetRefValue("txtWheelUSDFText")

	if titleText then
		ClientTextUtils.setText(titleText, pg.getGameString("GAMEPADMENU_BATTLETEAMS"))
	end

	petWheel.areaNum = PET_ITEM_NUM

	local items = {}

	for i = 1, PET_ITEM_NUM do
		items[i] = petWheel.transform:GetChild(i - 1):GetComponent("UButton")
	end

	local entry = {
		transform = petWheelTransform,
		wheel = petWheel,
		listBtn = petListBtn,
		listName = petListName,
		items = items
	}

	table.insert(self.petWheels, entry)

	function petListBtn.luaRenderItem(b, idx, data)
		self:setupPetTeamEntry(b, idx, data)
	end

	function petWheel.onLuaWheelIndexChange(index)
		self:refreshPet()

		if index ~= -1 and index < self.petPrepareBattleTeamCount then
			self:refreshPetTeam(index, false)
		else
			self:_broadcastListName("")
			self:_broadcastListBtnList({})
		end

		pg.game.audio:triggerEvent(AudioConst.EVENT_GAMEPAD_MENU_SELECTED_CHANGED)
	end

	function petWheel.onLuaWheelSelect(selectIndex)
		selectIndex = self.selectedWheelIndex or selectIndex

		if not selectIndex or selectIndex < 0 then
			self.ctrl:setMenuOpen(false)

			return
		end

		if selectIndex < self.petPrepareBattleTeamCount then
			self:refreshPetTeam(selectIndex, true)
		else
			pg.global.ui.tips:showTextTip(pg.getGameString("WHEEL_EMPTY"))
		end

		self:_broadcastWheelIndex(-1)
		self.ctrl:setMenuOpen(false)
	end

	self:refreshPetPrepareBattleTeamList()
	self:refreshPet()

	if #self.petWheels == 1 and #self.petPrepareBattleTeamList > 0 then
		local target = 0

		for i, e in ipairs(self.petPrepareBattleTeamList) do
			if e.index == pg.me.curPetFormationIndex then
				target = i - 1

				break
			end
		end

		self:refreshPetTeam(target)
	end
end

function PetWheelComponent:setWheelOffset(offset)
	if #self.petWheels == 0 then
		return
	end

	self.petWheels[1].wheel:SetWheelOffset(offset)
end

function PetWheelComponent:resetWheel()
	for _, entry in ipairs(self.petWheels) do
		entry.wheel:ResetWheel()
	end
end

function PetWheelComponent:_broadcastWheelIndex(value)
	for _, entry in ipairs(self.petWheels) do
		entry.wheel.wheelIndex = value
	end
end

function PetWheelComponent:_broadcastListName(text)
	for _, entry in ipairs(self.petWheels) do
		ClientTextUtils.setText(entry.listName, text)
	end
end

function PetWheelComponent:_broadcastListBtnList(data)
	for _, entry in ipairs(self.petWheels) do
		entry.listBtn:SetList(data)
	end
end

function PetWheelComponent:refreshSelectedPetTeam()
	local selectIndex

	if #self.petWheels > 0 then
		selectIndex = self.petWheels[1].wheel.wheelIndex
	elseif self.selectedWheelIndex ~= nil then
		selectIndex = self.selectedWheelIndex
	end

	if selectIndex and selectIndex ~= -1 and selectIndex < self.petPrepareBattleTeamCount then
		self:refreshPetTeam(selectIndex, false)
	else
		self:_broadcastListName("")
		self:_broadcastListBtnList({})
	end
end

function PetWheelComponent:refreshPetTeam(selectIndex, selected)
	local team = (self.petPrepareBattleTeamList or EMPTY_TABLE)[selectIndex + 1]

	if not team then
		self:_broadcastListName("")
		self:_broadcastListBtnList({})

		return
	end

	if selected then
		if pg.me:isInTeam() then
			pg.global.ui.tips:showTextTip(pg.getGameString("SWITCH_TEAM_FAIL_IN_TEAM"))
		else
			pg.me:serverMsg("RPC_CS_SelectPrepareFormation", team.index)
		end
	end

	self:_broadcastListBtnList(team.petsData)

	if string.isNilOrEmpty(team.teamName) then
		self:_broadcastListName(string.format("%s %d", pg.getGameString("DEFAULT_TEAM_NAME"), team.index))
	else
		self:_broadcastListName(team.teamName)
	end
end

function PetWheelComponent:setupPetTeamEntry(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local iconUrl = LuaUIUtils.getPetIcon(data.iconName, LuaUIUtils.PET_ICON, data.label, data.gender)

	iconUImage.url = iconUrl

	local addOnUComponent = objectReference:GetRefValue("addOnUComponent")
	local singleElement = objectReference:GetRefValue("singleElement")
	local doubleElement1 = objectReference:GetRefValue("doubleElement1")
	local doubleElement2 = objectReference:GetRefValue("doubleElement2")
	local elementCount = #data.elementNames

	if elementCount == 0 then
		addOnUComponent:TryChangePage("DetailState", 0)
		LuaUIUtils.setUIViewVisible(singleElement, false)
	elseif elementCount == 1 then
		addOnUComponent:TryChangePage("DetailState", 1)
		LuaUIUtils.setUIViewVisible(singleElement, true)
		LuaUIUtils.setElementButtonNew(singleElement, data.elementNames[1].element)
	else
		addOnUComponent:TryChangePage("DetailState", 2)
		LuaUIUtils.setElementButtonNew(doubleElement1, data.elementNames[1].element)
		LuaUIUtils.setElementButtonNew(doubleElement2, data.elementNames[2].element)
	end
end

function PetWheelComponent:refreshPet()
	self.petPrepareBattleTeamCount = math.min(PET_ITEM_NUM, #(self.petPrepareBattleTeamList or {}))

	if #self.petWheels == 0 then
		return
	end

	local rawIndex = self.petWheels[1].wheel.wheelIndex

	if self.ctrl.isOpen and self.ctrl.curWheelListIndex == 0 and rawIndex ~= -1 then
		self.selectedWheelIndex = rawIndex
	end

	local wheelIndex = self.ctrl.curWheelListIndex == 0 and rawIndex + 1 or -1
	local rootEmpty = self.petPrepareBattleTeamCount == 0 and 0 or 1

	for _, entry in ipairs(self.petWheels) do
		entry.transform:GetComponent("UButton"):TryChangePage("Empty", rootEmpty)

		for i, petItem in ipairs(entry.items) do
			if i <= self.petPrepareBattleTeamCount then
				petItem:TryChangePage("Empty", 1)
			else
				petItem:TryChangePage("Empty", 0)
			end

			if i == wheelIndex then
				petItem:TryChangePage("button", 5)
			else
				petItem:TryChangePage("button", 0)
			end
		end
	end
end

return PetWheelComponent
