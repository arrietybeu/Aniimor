-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomePetAppearanceAbility\\HomePetAppearanceAbilityCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local HomePetAppearanceAbilityCtrl = Class.LightClass("HomePetAppearanceAbilityCtrl", UICtrl)

function HomePetAppearanceAbilityCtrl.sortAppearanceInfo(left, right)
	local leftSort = left.sortKey or 0
	local rightSort = right.sortKey or 0

	if leftSort == rightSort then
		return left.id < right.id
	end

	return leftSort < rightSort
end

function HomePetAppearanceAbilityCtrl:getAppearanceName(data)
	if data.name then
		return data.name
	end

	if data.nameTextId then
		return pg.getLocalizationText(data.nameTextId)
	end

	if data.nameKey then
		return pg.getGameString(data.nameKey)
	end

	local tagData = data.tagData or {}
	local tagInfoList = LuaUIUtils.getPetTagInfo(tagData.templateId, tagData.label, tagData.bodySizeType, tagData.shinyStyle)

	for _, tagInfo in ipairs(tagInfoList) do
		if tagInfo.labelUrl == data.labelUrl then
			return tagInfo.name or ""
		end
	end

	return ""
end

function HomePetAppearanceAbilityCtrl:getMultiplierText(data)
	if data.multiplierText then
		return data.multiplierText
	end

	if data.multiplier ~= nil then
		return "×" .. tostring(data.multiplier)
	end

	return "--"
end

function HomePetAppearanceAbilityCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:closePanel()
	end

	function self.view.listAppearanceUList.luaRenderItem(button, _, data)
		self:renderAppearanceItem(button, data)
	end

	self.view.scrollRectUScrollRect:SetRightStickScrollConsoleBar("CONSOLE_BAR_SCROLL_VIEW", -3)
end

function HomePetAppearanceAbilityCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	info = info or {}

	local appearanceAbilityList = info.appearanceAbilityList or {}

	table.sort(appearanceAbilityList, HomePetAppearanceAbilityCtrl.sortAppearanceInfo)

	local displayList = {}

	for _, appearanceInfo in ipairs(appearanceAbilityList) do
		displayList[#displayList + 1] = {
			tIndex = 0,
			appearanceInfo = appearanceInfo
		}
	end

	ClientTextUtils.setText(self.view.txtTitleUSDFText, pg.getGameString("HOME_PET_APPEARANCE_TIPS_TITLE"))
	ClientTextUtils.setText(self.view.txtDetailsUSDFText, pg.getGameString("HOME_PET_APPEARANCE_TIPS"))
	self.view.listAppearanceUList:SetList(displayList)
end

function HomePetAppearanceAbilityCtrl:renderAppearanceItem(button, data)
	local appearanceInfo = data.appearanceInfo

	if not appearanceInfo then
		return
	end

	local objectReference = button:GetComponent("ObjectReference")
	local formUContainer = objectReference:GetRefValue("formUContainer")
	local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
	local txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")

	ClientTextUtils.setText(txtNameUSDFText, self:getAppearanceName(appearanceInfo))
	ClientTextUtils.setText(txtNumUSDFText, self:getMultiplierText(appearanceInfo))
	formUContainer:SetUrlWithCallback(appearanceInfo.labelUrl, function(content)
		if not content or button.dataFromUList ~= data then
			return
		end

		content.enabledTooltip = false

		LuaUIUtils.renderPetTagList(content, appearanceInfo.tagData)
	end)

	button.luaClick = nil
end

function HomePetAppearanceAbilityCtrl:onDestroy()
	self.view.btnCloseUButton.luaClick = nil
	self.view.listAppearanceUList.luaRenderItem = nil

	UICtrl.onDestroy(self)
end

return HomePetAppearanceAbilityCtrl
