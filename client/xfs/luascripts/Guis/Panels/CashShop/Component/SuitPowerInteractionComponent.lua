-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\CashShop\\Component\\SuitPowerInteractionComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Utils = require("Common.Utils.Utils")
local CashShopConst = require("Const.CashShopConst")
local ShopConstantData = require("Data.shopmall_constant_data")
local AttributeEntryData = require("Data.attribute_entry_data")
local PetData = require("Data.pet_data")
local PetFamilyData = require("Data.pet_family_data")
local SuitPowerInteractionComponent = Class.LightClass("SuitPowerInteractionComponent", UIComponent)

SuitPowerInteractionComponent.TOOLTIP_TEXT_KEYS = {
	[CashShopConst.SuitPowerType.FASHION_SWITCH] = "SHOP_PLAYER_PET_TIPS_1",
	[CashShopConst.SuitPowerType.PET_IDLE] = "SHOP_PLAYER_PET_TIPS_2",
	[CashShopConst.SuitPowerType.PLAYER_PET_INTERACTION] = "SHOP_PLAYER_PET_TIPS_3",
	[CashShopConst.SuitPowerType.PLAYER_PET_TIPS] = "SHOP_PLAYER_PET_TIPS"
}

function SuitPowerInteractionComponent:onCtor(info)
	info = Utils.isTable(info) and info or {}
	self.listInteraction = info.listInteraction
	self.txtInteraction = info.txtInteraction
	self.rootInteraction = info.rootInteraction
	self.titleTextKey = info.titleTextKey
	self.getAvatarComponentCallback = info.getAvatarComponent
	self.isShowingPetCallback = info.isShowingPet
	self.switchToPlayerCallback = info.switchToPlayer
	self.switchToPetCallback = info.switchToPet
	self.beforePreviewCallback = info.beforePreview
	self.isInteractionBlockedCallback = info.isInteractionBlocked
	self.waitPlayerModelLoadedAfterSwitch = info.waitPlayerModelLoadedAfterSwitch == true
	self._interactionList = {}
	self._previewToken = 0
	self._destroyed = false
end

function SuitPowerInteractionComponent:findObjects()
	return
end

function SuitPowerInteractionComponent:registerObjects()
	if not self.listInteraction then
		return
	end

	function self._renderItemCallback(button, index, data)
		self:renderInteractionItem(button, index, data)
	end

	function self._checkCanSelectedCallback(data)
		return self:canSelectInteraction(data)
	end

	self.listInteraction.luaRenderItem = self._renderItemCallback
	self.listInteraction.luaCheckCanSelected = self._checkCanSelectedCallback
end

function SuitPowerInteractionComponent:initView()
	if self.txtInteraction and self.titleTextKey then
		ClientTextUtils.setText(self.txtInteraction, pg.getGameString(self.titleTextKey))
	end

	self:setInteractionList({})
end

function SuitPowerInteractionComponent:onDestroy()
	self._destroyed = true

	self:clearPreviewState(false)

	if self.listInteraction then
		self.listInteraction.luaRenderItem = nil
		self.listInteraction.luaCheckCanSelected = nil
	end

	self._interactionList = nil
	self._renderItemCallback = nil
	self._checkCanSelectedCallback = nil
	self.getAvatarComponentCallback = nil
	self.isShowingPetCallback = nil
	self.switchToPlayerCallback = nil
	self.switchToPetCallback = nil
	self.beforePreviewCallback = nil
	self.isInteractionBlockedCallback = nil
end

function SuitPowerInteractionComponent:isInteractionBlocked()
	return type(self.isInteractionBlockedCallback) == "function" and self.isInteractionBlockedCallback() == true
end

function SuitPowerInteractionComponent:canSelectInteraction(interactionData)
	return not Utils.isTable(interactionData) or tonumber(interactionData.powerType) ~= CashShopConst.SuitPowerType.PLAYER_PET_TIPS
end

function SuitPowerInteractionComponent:getAvatarComponent()
	if type(self.getAvatarComponentCallback) ~= "function" then
		return nil
	end

	return self.getAvatarComponentCallback()
end

function SuitPowerInteractionComponent:isShowingPet()
	return type(self.isShowingPetCallback) == "function" and self.isShowingPetCallback() == true
end

function SuitPowerInteractionComponent:invalidatePreview()
	self._previewToken = (self._previewToken or 0) + 1
end

function SuitPowerInteractionComponent:isPreviewValid(token)
	return not self._destroyed and token == self._previewToken and self:getAvatarComponent() ~= nil
end

function SuitPowerInteractionComponent:clearPreviewState(resetSelection)
	self:invalidatePreview()

	local avatarComponent = self:getAvatarComponent()

	if avatarComponent and avatarComponent.clearSuitPowerPreviewState then
		avatarComponent:clearSuitPowerPreviewState()
	end

	if resetSelection == true then
		for _, data in ipairs(self._interactionList or {}) do
			data.selected = false
		end

		if self.listInteraction then
			self.listInteraction:RefreshList()
		end
	end
end

function SuitPowerInteractionComponent:stopSelectedInteraction()
	for _, interactionData in ipairs(self._interactionList or {}) do
		if interactionData.selected == true then
			self:selectInteraction(interactionData)

			return
		end
	end

	self:clearPreviewState(true)
end

function SuitPowerInteractionComponent:setInteractionVisible(visible)
	if self.rootInteraction then
		self.rootInteraction:SetActive(visible)
	end

	if self.listInteraction then
		self.listInteraction:SetActive(visible)
	end

	if self.txtInteraction then
		self.txtInteraction.gameObject:SetActiveEx(visible)
	end
end

function SuitPowerInteractionComponent:setInteractionList(interactionList)
	self:clearPreviewState(false)

	self._interactionList = Utils.isTable(interactionList) and interactionList or {}

	self:setInteractionVisible(#self._interactionList > 0)

	if self.listInteraction then
		self.listInteraction:SetList(self._interactionList)
	end
end

function SuitPowerInteractionComponent:renderInteractionItem(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = LuaUIUtils.safeGetRefValue(objectReference, "iconUImage")
	local powerType = Utils.isTable(data) and tonumber(data.powerType) or 0
	local iconConfig = ShopConstantData["Intera_" .. tostring(powerType)]

	if iconUImage then
		iconUImage.url = data.icon or iconConfig and iconConfig.number or ""
	end

	local suitPowerType = CashShopConst.SuitPowerType

	button:TryChangePage("Play", powerType >= suitPowerType.FASHION_SWITCH and powerType <= suitPowerType.PLAYER_PET_INTERACTION and 1 or 0)
	button:SetSelected(data.selected == true)

	local tooltipTextKey = SuitPowerInteractionComponent.TOOLTIP_TEXT_KEYS[powerType]

	button.enabledTooltip = tooltipTextKey ~= nil
	button.tooltipMode = 0

	button:EnableAutoClose(true)

	button.PopupTool.includeSelf = true
	button.forceOneTooltip = true
	button.luaRenderTooltip = nil

	if tooltipTextKey then
		function button.luaRenderTooltip(_, tooltip)
			self:renderInteractionTooltip(tooltip, tooltipTextKey, data)
		end
	end

	function button.luaClick()
		if self:isInteractionBlocked() then
			return
		end

		if powerType == CashShopConst.SuitPowerType.PLAYER_PET_TIPS then
			self:stopSelectedInteraction()

			if tooltipTextKey then
				button:OpenTooltip()
			end

			return
		end

		local wasSelected = data.selected == true

		self:selectInteraction(data)

		if wasSelected then
			button:CloseTooltip()
		elseif tooltipTextKey and data.selected == true then
			button:OpenTooltip()
		end
	end
end

function SuitPowerInteractionComponent:appendInteractionPetName(names, nameMap, nameId)
	if nameId == nil then
		return
	end

	local name = pg.getLocalizationText(nameId)

	if string.isNilOrEmpty(name) or nameMap[name] then
		return
	end

	nameMap[name] = true
	names[#names + 1] = name
end

function SuitPowerInteractionComponent:getInteractionPetNameText(interactionData)
	local functionData = Utils.isTable(interactionData) and interactionData.functionData or nil

	if not Utils.isTable(functionData) then
		return ""
	end

	local names = {}
	local nameMap = {}

	if Utils.isTable(functionData.petId) then
		for _, petTemplateId in ipairs(functionData.petId) do
			local petConfig = PetData[tonumber(petTemplateId)]

			if Utils.isTable(petConfig) then
				self:appendInteractionPetName(names, nameMap, petConfig.name)
			end
		end
	end

	if Utils.isTable(functionData.Affinity) then
		for _, attributeEntryId in ipairs(functionData.Affinity) do
			local attributeEntry = AttributeEntryData[tonumber(attributeEntryId)]

			if Utils.isTable(attributeEntry) and Utils.isTable(attributeEntry.attrComplexValue) then
				for _, petConfigId in ipairs(attributeEntry.attrComplexValue) do
					local petConfig = attributeEntry.attrType == "close_pet_by_prototype" and PetData[tonumber(petConfigId)] or nil
					local petFamilyConfig = attributeEntry.attrType == "close_pet" and PetFamilyData[tonumber(petConfigId)] or nil
					local nameId = Utils.isTable(petConfig) and petConfig.name or Utils.isTable(petFamilyConfig) and petFamilyConfig.name or nil

					self:appendInteractionPetName(names, nameMap, nameId)
				end
			end
		end
	end

	return table.concat(names, "、")
end

function SuitPowerInteractionComponent:renderInteractionTooltip(tooltip, textKey, interactionData)
	if not tooltip then
		return
	end

	local objectReference = tooltip:GetComponent("ObjectReference")
	local txtNameUSDFText = LuaUIUtils.safeGetRefValue(objectReference, "txtNameUSDFText")

	if txtNameUSDFText then
		ClientTextUtils.setText(txtNameUSDFText, ClientTextUtils.getFormatText(pg.getGameString(textKey), self:getInteractionPetNameText(interactionData)))
	end
end

function SuitPowerInteractionComponent:selectInteraction(interactionData)
	if not Utils.isTable(interactionData) or self:isInteractionBlocked() then
		return
	end

	local wasSelected = interactionData.selected == true

	for _, data in ipairs(self._interactionList or {}) do
		data.selected = false
	end

	self:clearPreviewState(false)

	if not wasSelected then
		interactionData.selected = true
	end

	if self.listInteraction then
		self.listInteraction:RefreshList()
	end

	local success = true
	local powerType = tonumber(interactionData.powerType)

	if wasSelected then
		if powerType == CashShopConst.SuitPowerType.FASHION_SWITCH then
			success = self:executeInteraction(interactionData)
		elseif powerType == CashShopConst.SuitPowerType.PLAYER_PET_INTERACTION then
			success = self:switchToPlayer()
		end
	else
		success = self:executeInteraction(interactionData)
	end

	if success == false and interactionData.selected == true then
		interactionData.selected = false

		if self.listInteraction then
			self.listInteraction:RefreshList()
		end
	end
end

function SuitPowerInteractionComponent:beforePreview()
	if type(self.beforePreviewCallback) == "function" then
		self.beforePreviewCallback()
	end
end

function SuitPowerInteractionComponent:switchToPlayer(onLoaded)
	if type(self.switchToPlayerCallback) ~= "function" then
		return false
	end

	return self.switchToPlayerCallback(onLoaded) ~= false
end

function SuitPowerInteractionComponent:switchToPet(petTemplateId, onLoaded)
	if type(self.switchToPetCallback) ~= "function" then
		return false
	end

	return self.switchToPetCallback(petTemplateId, onLoaded) ~= false
end

function SuitPowerInteractionComponent:executeInteraction(interactionData)
	if not Utils.isTable(interactionData) or not Utils.isTable(interactionData.functionData) then
		return false
	end

	self:beforePreview()

	local powerType = tonumber(interactionData.powerType)
	local suitPowerType = CashShopConst.SuitPowerType

	if powerType == suitPowerType.FASHION_SWITCH then
		return self:previewFashionSwitch(interactionData.functionData)
	elseif powerType == suitPowerType.PET_IDLE then
		return self:previewPetIdle(interactionData.functionData)
	elseif powerType == suitPowerType.PLAYER_PET_INTERACTION then
		return self:previewPlayerPetInteraction(interactionData.functionData)
	elseif powerType == suitPowerType.PLAYER_PET_TIPS then
		return true
	end

	return false
end

function SuitPowerInteractionComponent:previewFashionSwitch(functionData)
	local avatarComponent = self:getAvatarComponent()

	if not avatarComponent then
		return false
	end

	local token = self._previewToken

	if self:isShowingPet() then
		return self:switchToPlayer(function()
			if self:isPreviewValid(token) then
				self:getAvatarComponent():previewFashionSwitchEffect(functionData, false)
			end
		end)
	end

	local petTemplateId = avatarComponent:getSuitPowerPetTemplateId(functionData)

	if not petTemplateId then
		return false
	end

	return self:switchToPet(petTemplateId, function()
		if self:isPreviewValid(token) then
			self:getAvatarComponent():previewFashionSwitchEffect(functionData, true)
		end
	end)
end

function SuitPowerInteractionComponent:previewPetIdle(functionData)
	local avatarComponent = self:getAvatarComponent()

	if not avatarComponent then
		return false
	end

	local petTemplateId = avatarComponent:getSuitPowerPetTemplateId(functionData)

	if not petTemplateId then
		return false
	end

	local token = self._previewToken

	return self:switchToPet(petTemplateId, function()
		if self:isPreviewValid(token) then
			self:getAvatarComponent():previewPetIdle(functionData)
		end
	end)
end

function SuitPowerInteractionComponent:previewPlayerPetInteraction(functionData)
	local avatarComponent = self:getAvatarComponent()

	if not avatarComponent then
		return false
	end

	if not self:isShowingPet() then
		return avatarComponent:previewPlayerPetInteraction(functionData, false)
	end

	local token = self._previewToken

	return self:switchToPlayer(function()
		if self:isPreviewValid(token) then
			self:getAvatarComponent():previewPlayerPetInteraction(functionData, self.waitPlayerModelLoadedAfterSwitch)
		end
	end)
end

return SuitPowerInteractionComponent
