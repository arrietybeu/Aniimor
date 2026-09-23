-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Inventory\\Component\\PetSlotComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local Class = require("Core.Framework.Class")
local PetSlotComponent = Class.LightClass("PetSlotComponent", UIComponent)
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")

function PetSlotComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.groupName = self.objectReference:GetRefValue("groupName")
	self.groupSelector = self.objectReference:GetRefValue("groupSelector")
	self.listUList = self.objectReference:GetRefValue("listUList")

	function self.listUList.luaRenderItem(button, idx, data)
		self:refreshPetItemView(button, idx, data)
	end

	function self.listUList.luaSelectedChanged(uList)
		local selectItem = uList.selectedItem

		self.model:setCurSelectPetInfo(selectItem)
		self.ctrl:onRefreshCurSelectProp()

		local btns = uList:GetAllButtons()

		for i = 0, btns.Length - 1 do
			btns[i]:TryChangePage("select", uList.selectedIndex == i and 1 or 0)
		end
	end

	function self.groupSelector.luaSelectedChanged(selector)
		self:switchGroupToIdx(selector.selectedIndex + 1)
	end
end

function PetSlotComponent:initView()
	self.listUList:SelectItem(-1)
	self:refreshPetList()
end

function PetSlotComponent:onSelected()
	self:setGroupSelectorOptions()
	self:refreshPetList()
end

function PetSlotComponent:setGroupSelectorOptions()
	local groupInfos = self.model:getGroupInfos()

	self.groupSelector:SetOptions(groupInfos)

	self.groupSelector.selectedIndex = self.model:getSelectGroupId() - 1
end

function PetSlotComponent:refreshPetList()
	local selectId = self.model:getSelectGroupId()
	local petInfos = pg.global.ui.petManagement.model:getGroupInfoById(selectId)

	self.listUList:SetList(petInfos)

	if #petInfos > 0 then
		self.listUList:SelectItem(0)
	end
end

function PetSlotComponent:getSelectPetId()
	local sData = self.listUList.selectedItem

	return sData and sData.id
end

function PetSlotComponent:switchGroupToIdx(selectIndex)
	self.model:setSelectGroupId(selectIndex)
	self:refreshPetList()
end

function PetSlotComponent:refreshPetItemView(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local btnDelUButton = objectReference:GetRefValue("btnDelUButton")
	local petName = objectReference:GetRefValue("nameUText")
	local hpBarUHealthbar = objectReference:GetRefValue("hpBarUHealthbar")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local numLevelUText = objectReference:GetRefValue("numLevelUText")
	local numCPUText = objectReference:GetRefValue("numCPUText")
	local elementsUList = objectReference:GetRefValue("elementsUList")
	local icon1UImage = objectReference:GetRefValue("icon1UImage")
	local icon2UImage = objectReference:GetRefValue("icon2UImage")
	local iconOrientationUImage = objectReference:GetRefValue("iconOrientationUImage")
	local pointOutUWidget = objectReference:GetRefValue("pointOutUWidget")

	iconOrientationUImage.url = data.petTypeUrl
	button.name = index + 1
	button.draggable = false

	btnDelUButton.gameObject:SetActiveEx(false)

	function elementsUList.luaRenderItem(btn, idx, eleData)
		LuaUIUtils.setElementButtonNew(btn, eleData.element)
	end

	if data.customName and data.customName ~= "" then
		ClientTextUtils.setText(petName, data.customName)
	else
		ClientTextUtils.setText(petName, pg.getLocalizationText(data.name))
	end

	if data.isShiny then
		button:TryChangePage("isFlash", 1)
	elseif data.isBoss then
		button:TryChangePage("isFlash", 2)
	else
		button:TryChangePage("isFlash", 0)
	end

	if data.gender == Const.GENDER_TYPE_MALE then
		button:TryChangePage("Gender", 0)
	elseif data.gender == Const.GENDER_TYPE_FEMALE then
		button:TryChangePage("Gender", 1)
	else
		button:TryChangePage("Gender", 2)
	end

	iconUImage.url = LuaUIUtils.getPetIcon(data.iconName, LuaUIUtils.PET_ICON, data.label)

	elementsUList:SetList(data.elementNames)
	hpBarUHealthbar:TryChangePage("BarColor", 1)

	hpBarUHealthbar.hp = data.expRate
	hpBarUHealthbar.maxHp = 1

	if data.cp then
		numCPUText:SetActiveFastest(true)

		numCPUText.text = "CP:" .. data.cp
	else
		numCPUText:SetActiveFastest(false)
	end

	ClientTextUtils.setText(numLevelUText, data.level)
	button:TryChangePage("pet_number", index)

	function button.luaClick()
		self:onPetSlotClick(button)
	end

	if self._dragging then
		local canChangeForm = Utils.petCanChangeForm(pg.me, data.templateId) ~= false

		pointOutUWidget:SetActive(not canChangeForm)
	else
		pointOutUWidget:SetActive(false)
	end
end

function PetSlotComponent:onPetSlotClick(btn)
	local btns = self.listUList:GetAllButtons()

	for i = 0, btns.Length - 1 do
		btns[i].isSelected = false

		if btns[i] == btn then
			btns[i].isSelected = true
		end
	end
end

function PetSlotComponent:checkHasPet()
	return self.listUList.itemCount > 0
end

function PetSlotComponent:onPropBeginDrag(itemId)
	self._dragging = true

	self.listUList:RefreshList()
end

function PetSlotComponent:onPropEndDrag(itemId)
	self._dragging = false

	self.listUList:RefreshList()
end

return PetSlotComponent
