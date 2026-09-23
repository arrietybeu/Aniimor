-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetResearchCountryPage\\PetResearchCountryPageCtrl.lua

local MessageName = require("Const.MessageName")
local HotkeyConst = require("Const.HotkeyConst")
local CountryAreaIndexData = require("Data.country_area_index_data")
local MapConfigData = require("Data.map_area_config_data")
local PetResearchCountryLevelData = require("Data.pet_research_country_level_data")
local LuaUIUtils = require("Utils.LuaUIUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PetResearchCountryPageCtrl = Class.LightClass("PetResearchCountryPageCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local RedDotConst = require("Const.RedDotConst")
local NoticeDef = require("Common.NoticeDef")

PetResearchCountryPageCtrl.messages = {
	[MessageName.PET_RESEARCH_AREA_ACTIVE_CHANGED] = {
		"onAreaActiveChanged",
		true
	}
}

function PetResearchCountryPageCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function PetResearchCountryPageCtrl:addListener()
	function self.view.cardListUList.luaRenderItem(button, idx, data)
		self:renderCountryList(button, idx, data)
	end

	function self.view.btnBackUButton.luaClick()
		self:dismiss()
	end

	function self.view.btnSwitchUButton.luaClick()
		self:switchPetShowTab()
	end

	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.btnBackUButton.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:dismiss()
		end
	end

	ClientTextUtils.setText(self.view.titleUSDFText, pg.getGameString("TITLE_PET_RESEARCH_SELECT"))
end

function PetResearchCountryPageCtrl:switchPetShowTab()
	self.showTab = self.showTab == PetResearchUtils.PET_SHOW_TAB.SPECIES and PetResearchUtils.PET_SHOW_TAB.FORM or PetResearchUtils.PET_SHOW_TAB.SPECIES

	PetResearchUtils.savePetShowTab(self.showTab)
	self:refreshCountryList()
end

function PetResearchCountryPageCtrl:refreshCountryList()
	self.tempUnlockNum = 0

	self.view.cardListUList:RefreshElement()
	self:refreshBtnSwitch()
end

function PetResearchCountryPageCtrl:refreshBtnSwitch()
	local isSpecies = self.showTab == PetResearchUtils.PET_SHOW_TAB.SPECIES
	local pageId = isSpecies and 0 or 1

	self.view.rootView:TryChangePage("Type", pageId)
	ClientTextUtils.setText(self.view.txtNameUSDFText, pg.getGameString(PetResearchUtils.ShowTabName[self.showTab]))
end

function PetResearchCountryPageCtrl:renderCountryList(button, idx, data)
	local objectReference = button:GetComponent("ObjectReference")
	local rootUWidget = objectReference:GetRefValue("rootUWidget")
	local textNotActive = objectReference:GetRefValue("txtInactiveUSDFText")

	ClientTextUtils.setText(textNotActive, pg.getGameString("AREA_NOT_ACTIVE"))

	if not data.isActive then
		rootUWidget:TryChangePage("State", 0)

		function button.luaClick()
			pg.global.showBubbleMessageById(NoticeDef.PET_AREA_NOT_ACTIVE)
		end

		return
	end

	local oldActiveState = PetResearchUtils.getAreaActiveStateInPrefs(data.areaId)

	if oldActiveState ~= data.isActive then
		PetResearchUtils.setAreaActiveStateInPrefs(data.areaId, data.isActive)
	end

	if oldActiveState == false and data.areaId ~= PetResearchUtils.DEFAULT_AREA_ID then
		rootUWidget:TryChangePage("State", 0)

		data._isInUnlocking = true

		self:startTimer(function()
			rootUWidget:InvokeCallbackWithCallback(CS.XGUI.EInvokeTime.Custom1, function()
				data._isInUnlocking = nil
			end)
		end, 0.5 + self.tempUnlockNum * 1.5)

		self.tempUnlockNum = self.tempUnlockNum + 1
	else
		local isSelect = data.areaId == self.selectAreaId and 2 or 1

		rootUWidget:TryChangePage("State", isSelect)
	end

	local pictureUImage = objectReference:GetRefValue("pictureUImage")
	local countryNameUBaseText = objectReference:GetRefValue("countryNameUBaseText")
	local txtCountryDescUSDFText = objectReference:GetRefValue("txtCountryDescUSDFText")
	local txtLvUSDFText = objectReference:GetRefValue("txtLvUSDFText")
	local levelUProgress = objectReference:GetRefValue("levelUProgress")
	local levelMaxUWidget = objectReference:GetRefValue("levelMaxUWidget")
	local numUList = objectReference:GetRefValue("numUList")
	local imgBadgeUImage = objectReference:GetRefValue("imgBadgeUImage")
	local badgeNumUSDFText = objectReference:GetRefValue("badgeNumUSDFText")
	local imgRoundUWidget = objectReference:GetRefValue("imgRoundUWidget")
	local imgFigureUImage = objectReference:GetRefValue("imgFigureUImage")
	local txtSelUSDFText = objectReference:GetRefValue("txtSelUSDFText")

	ClientTextUtils.setText(countryNameUBaseText, data.name)
	ClientTextUtils.setText(txtCountryDescUSDFText, data.arkName)
	ClientTextUtils.setText(txtSelUSDFText, pg.getGameString("CHOOSE_TXT"))

	pictureUImage.url = data.countryPic
	imgFigureUImage.url = data.bgImage

	function numUList.luaRenderItem(numBtn, numIdx, numData)
		PetResearchCountryPageCtrl._renderNumItem(numBtn, numIdx, numData)
	end

	numUList:SetList(data.numInfo[self.showTab])
	rootUWidget:TryChangePage("IsCollection", data.isCollection and 1 or 0)

	if not data.isCollection then
		ClientTextUtils.setText(txtLvUSDFText, data.level)
		levelMaxUWidget:SetActiveFastest(data.isMaxLevel)

		levelUProgress.minValue = 0
		levelUProgress.maxValue = data.maxExp
		levelUProgress.value = data.exp
	end

	function button.luaClick()
		if data._isInUnlocking then
			return
		end

		PetResearchUtils.savePetResearchAreaId(data.areaId)

		if data.areaId ~= self.selectAreaId then
			self.selectAreaId = data.areaId

			facade:sendMsgToUI(MessageName.PET_RESEARCH_AREA_SELECT_CHANGED, {
				areaId = data.areaId
			})
		end

		self:dismiss()

		local openInfo = {}

		for key, value in pairs(self.openInfo or {}) do
			openInfo[key] = value
		end

		openInfo.areaId = data.areaId
		openInfo.showTab = self.showTab

		PetResearchUtils.CountryPageUIGoToPetResearchUI(openInfo)
	end

	local redPath = string.format(RedDotConst.RedDotPath.PET_RESEARCH_COUNTRY_REWARD_PAGE, idx)

	pg.global.setPreViewRedDot(redPath, button, function()
		if PetResearchUtils.checkCountryReward(data.areaId, self.showTab, PetResearchUtils.REWARD_LEVEL) then
			return RedDotConst.RedDotStyle.REWARD
		end

		return RedDotConst.RedDotStyle.NONE
	end)
end

function PetResearchCountryPageCtrl._renderNumItem(numBtn, numIdx, numData)
	local objectReference = numBtn:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local textUText = objectReference:GetRefValue("textUText")

	iconUImage.url = numData.icon

	ClientTextUtils.setText(textUText, numData.num)

	numBtn.enabledTooltip = false
end

function PetResearchCountryPageCtrl:setCountryList()
	local countryDatas = self:getCountryInfos()

	self.tempUnlockNum = 0

	self.view.cardListUList:SetList(countryDatas)
end

function PetResearchCountryPageCtrl:getCountryInfos()
	local petHandbookMap = pg.me.petHandbookMap
	local ret = {}

	for _, areaId in ipairs(CountryAreaIndexData) do
		local info = MapConfigData[areaId]
		local canShow = info.belongNation ~= nil

		if canShow then
			local isCollection = info.belongNation >= PetResearchUtils.COLLECTION_NATION
			local item = {}

			if not isCollection then
				local collectLevel, remain, needExp, isMax = PetResearchUtils.getCountryLevelInfo(areaId)

				item.level = collectLevel
				item.isMaxLevel = isMax
				item.exp = remain
				item.maxExp = needExp
			end

			item.areaId = areaId
			item.isActive = petHandbookMap:getAreaIsActive(areaId)
			item.isCollection = isCollection
			item.name = pg.getLocalizationText(info.areaName)
			item.arkName = info.areaNameEn
			item.bgImage = info.areaImageWord
			item.countryPic = info.areaImageBig

			local starData = PetResearchUtils.getCountryStarData(areaId)

			item.starList = starData
			item.numInfo = {
				[PetResearchUtils.PET_SHOW_TAB.SPECIES] = PetResearchUtils.getAreaPetCollectInfo(areaId, PetResearchUtils.PET_SHOW_TAB.SPECIES),
				[PetResearchUtils.PET_SHOW_TAB.FORM] = PetResearchUtils.getAreaPetCollectInfo(areaId, PetResearchUtils.PET_SHOW_TAB.FORM)
			}
			item._sort = info.sort
			ret[#ret + 1] = item
		end
	end

	table.sort(ret, function(a, b)
		return a._sort < b._sort
	end)

	return ret
end

function PetResearchCountryPageCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function PetResearchCountryPageCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.openInfo = info
	self.areaId = PetResearchUtils.resolvePetResearchAreaId(info)
	self.showTab = info and info.showTab or PetResearchUtils.getLastPetShowTab()
	self.selectAreaId = self.areaId

	self:setCountryList()
	self:refreshBtnSwitch()
end

function PetResearchCountryPageCtrl:onShow()
	return
end

function PetResearchCountryPageCtrl:onHide()
	return
end

function PetResearchCountryPageCtrl:onAreaActiveChanged()
	self:setCountryList()
end

return PetResearchCountryPageCtrl
