-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomePetElementAbility\\HomePetElementAbilityCtrl.lua

local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local HomeAbilityData = require("Data.home_ability_data")
local HomePetElementAbilityCtrl = Class.LightClass("HomePetElementAbilityCtrl", UICtrl)

HomePetElementAbilityCtrl.TEMPLATE_TITLE = 0
HomePetElementAbilityCtrl.TEMPLATE_DETAILS = 1

function HomePetElementAbilityCtrl.sortAbilityInfo(left, right)
	return left.id < right.id
end

function HomePetElementAbilityCtrl:buildAbilityInfo(distribution, requirement)
	local result = {}

	for abilityId, abilityData in pairs(HomeAbilityData) do
		result[#result + 1] = {
			id = abilityId,
			abilityData = abilityData,
			distribution = distribution[abilityId] or 0,
			requirement = requirement[abilityId] or 0
		}
	end

	table.sort(result, HomePetElementAbilityCtrl.sortAbilityInfo)

	return result
end

function HomePetElementAbilityCtrl:addListener()
	function self.view.btnCloseUButton.luaClick()
		self:closePanel()
	end

	function self.view.listAbilityUList.luaRenderItem(button, _, data)
		if data.tIndex == HomePetElementAbilityCtrl.TEMPLATE_TITLE then
			self:renderTitle(button, data)
		else
			self:renderDetails(button, data)
		end
	end

	self.view.listAbilityUList:SetRightStickScrollConsoleBar("CONSOLE_BAR_SCROLL_VIEW", -3)
end

function HomePetElementAbilityCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	info = info or {}

	local distribution = info.abilityDistribution or {}
	local requirement = info.abilityRequirement or {}
	local abilityInfo = self:buildAbilityInfo(distribution, requirement)
	local listData = {
		{
			tIndex = HomePetElementAbilityCtrl.TEMPLATE_TITLE,
			abilityInfo = abilityInfo
		}
	}

	for _, data in ipairs(abilityInfo) do
		listData[#listData + 1] = {
			tIndex = HomePetElementAbilityCtrl.TEMPLATE_DETAILS,
			abilityId = data.id,
			abilityData = data.abilityData
		}
	end

	ClientTextUtils.setText(self.view.txtTitleUSDFText, pg.getGameString("HOME_PET_ABILITY_TIPS_TITLE"))
	self.view.listAbilityUList:SetList(listData)
	self.view.listAbilityUList:GoToIndex(0, true)
end

function HomePetElementAbilityCtrl:renderTitle(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtAbilityUSDFText = objectReference:GetRefValue("txtAbilityUSDFText")
	local txtDistributionUSDFText = objectReference:GetRefValue("txtDistributionUSDFText")
	local txtAllUSDFText = objectReference:GetRefValue("txtAllUSDFText")
	local listElementUList = objectReference:GetRefValue("listElementUList")

	ClientTextUtils.setText(txtAbilityUSDFText, pg.getGameString("HOME_PET_ABILITY_TIPS_DESC"))
	ClientTextUtils.setText(txtDistributionUSDFText, pg.getGameString("HOME_PET_ABILITY_TIPS_DISTRIBUTION"))
	ClientTextUtils.setText(txtAllUSDFText, pg.getGameString("HOME_PET_ABILITY_TIPS_REQUIREMENT"))

	function listElementUList.luaRenderItem(elementButton, _, elementData)
		self:renderAbilityColumn(elementButton, elementData)
	end

	listElementUList:SetList(data.abilityInfo)
end

function HomePetElementAbilityCtrl:renderAbilityColumn(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local imgBgImagePro = objectReference:GetRefValue("imgBgImagePro")
	local txtNumUSDFText = objectReference:GetRefValue("txtNumUSDFText")
	local txtTotalUSDFText = objectReference:GetRefValue("txtTotalUSDFText")

	iconUImage.url = data.abilityData.icon

	imgBgImagePro:SetColorWithHtmlString(data.abilityData.iconColor)

	local distributionStyle = data.requirement > 0 and data.distribution >= data.requirement and "Prg_G" or "NmlT_D"

	ClientTextUtils.setText(txtNumUSDFText, string.format("<style=%s>%s</style>", distributionStyle, data.distribution))
	ClientTextUtils.setText(txtTotalUSDFText, string.format("<style=NmlT_D>%s</style>", data.requirement))

	txtTotalUSDFText.renderOpacity = data.requirement > 0 and 1 or 0.4

	button:TryChangePage("Active", data.requirement > 0 and 1 or 0)

	button.luaClick = nil
end

function HomePetElementAbilityCtrl:renderDetails(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local txtDetailsUSDFText = objectReference:GetRefValue("txtDetailsUSDFText")
	local elementWordRectTransform = objectReference:GetRefValue("elementWordRectTransform")
	local elementWordUButton = elementWordRectTransform:GetComponent("UButton")
	local elementType = data.abilityData.elementType and data.abilityData.elementType[1]

	elementWordUButton:SetActive(true)

	if elementType then
		LuaUIUtils.setElementButtonNew(elementWordUButton, elementType, false)
	else
		LuaUIUtils.setHomeAbilityButton(elementWordUButton, data.abilityId)
	end

	elementWordUButton.luaClick = nil

	ClientTextUtils.setText(txtDetailsUSDFText, pg.getLocalizationText(data.abilityData.desc))

	button.luaClick = nil
end

function HomePetElementAbilityCtrl:onDestroy()
	self.view.btnCloseUButton.luaClick = nil
	self.view.listAbilityUList.luaRenderItem = nil

	UICtrl.onDestroy(self)
end

return HomePetElementAbilityCtrl
