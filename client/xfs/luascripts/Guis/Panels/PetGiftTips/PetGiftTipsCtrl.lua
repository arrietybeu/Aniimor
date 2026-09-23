-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetGiftTips\\PetGiftTipsCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local PetGiftTipsCtrl = Class.LightClass("PetGiftTipsCtrl", UICtrl)
local PuzzleData = require("Data.puzzle_data")
local Time = require("Core.Common.Time")
local ClientTextUtils = require("Utils.ClientTextUtils")
local Utils = require("Common.Utils.Utils")
local ClientConst = require("Const.ClientConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local UIConst = require("Const.UIConst")
local HomeAbilityData = require("Data.home_ability_data")
local HomeAbilityLevelData = require("Data.home_ability_level_data")
local NoticeDef = require("Common.NoticeDef")
local ItemConst = require("Common.Const.ItemConst")

PetGiftTipsCtrl.PERSONALITY_FRUIT_ITEM_ID = 510002

function PetGiftTipsCtrl:onCreate(data)
	UICtrl.onCreate(self, data)
end

function PetGiftTipsCtrl:onOpen(data)
	UICtrl.onOpen(self, data)

	self.iData = data

	if self.iData.extra and self.iData.extra.openFun then
		self.iData.extra.openFun()
	end
end

function PetGiftTipsCtrl:checkCanOpen(showNotice, data)
	if data == nil then
		return false
	end

	self.iData = data

	return true
end

function PetGiftTipsCtrl:addListener()
	function self.view.tabHomeUButton.luaClick()
		self:onHomeClick()
	end

	function self.view.tabBattleUButton.luaClick()
		self:onBattleClick()
	end

	function self.view.rootCmp.luaCloseAction()
		if self.iData.extra and self.iData.extra.closeFun then
			self.iData.extra.closeFun()
		end

		self:close()
	end

	local canUsePersonalityFruit = self:canUsePersonalityFruit()

	if canUsePersonalityFruit then
		ClientTextUtils.setText(self.view.txtNameUSDFText, pg.getGameString("PET_CHANGE_PERSONALITY"))

		function self.view.btnUseUButton.luaClick()
			self:onUsePersonalityFruitClick()
		end
	end
end

function PetGiftTipsCtrl:onHomeClick()
	self.tab = UIConst.GIFT_TYPE.HOME

	self:generalReplayRefrersh()

	if self.iData.showType == UIConst.GIFT_SHOW_TYPE.GIFT then
		ClientTextUtils.setText(self.view.txtTitleUSDFText, pg.getGameString("TALENT_HOME"))
	else
		ClientTextUtils.setText(self.view.txtTitleUSDFText, pg.getGameString("ABILITY_HOME"))
	end
end

function PetGiftTipsCtrl:canUsePersonalityFruit()
	local petId = self.iData and self.iData.petId

	if not petId or petId == 0 or not pg.me then
		return false
	end

	return pg.me:getPetInfo(petId) ~= nil
end

function PetGiftTipsCtrl:onBattleClick()
	self.tab = UIConst.GIFT_TYPE.BATTLE

	self:generalReplayRefrersh()
	ClientTextUtils.setText(self.view.txtTitleUSDFText, pg.getGameString("TALENT_BATTLE"))
end

function PetGiftTipsCtrl:onUsePersonalityFruitClick()
	if not self:canUsePersonalityFruit() then
		return
	end

	local itemId = PetGiftTipsCtrl.PERSONALITY_FRUIT_ITEM_ID
	local petId = self.iData.petId
	local props = LuaUIUtils.getInventoryProps(ItemConst.INV_TYPE_PET, nil, itemId)
	local propData = props and props[1]

	if not propData then
		pg.global.showBubbleMessageById(NoticeDef.ITEM_COUNT_LACK)

		return
	end

	if self.iData.extra and self.iData.extra.closeFun then
		self.iData.extra.closeFun()
	end

	self:close()
	pg.global.ui:open(UIConst.UI_ID_INVENTORY_PET_PROP_USE, {
		propData = propData,
		sType = ItemConst.USEITEM_TYPE_RANDOM_TO_TALENT,
		petId = petId
	})
end

function PetGiftTipsCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function PetGiftTipsCtrl:onShow()
	if self.iData == nil then
		return
	end

	local autoVer = self.iData.autoVer or false
	local autoHor = self.iData.autoHor or false

	self.view.rootCmp:SetAutoVertical(autoVer, autoHor)

	if self.iData.hierarchyMode ~= nil then
		self.view.rootCmp:SetHierarchy(self.iData.hierarchyMode, self.iData.sortingOrder or 1)
	end

	self.view.rootCmp:OpenPopup(self.iData.targetRect)

	if self.iData.type == nil or self.iData.type == UIConst.GIFT_TYPE.HOME then
		self:onHomeClick()
	else
		self:onBattleClick()
	end

	self:refreshGiftInfo()
end

function PetGiftTipsCtrl:refreshGiftInfo()
	local data = self.iData
	local listUList = self.view.listUList

	function listUList.luaRenderItem(button, index, itemData)
		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUSDFText = objectReference:GetRefValue("txtNameUSDFText")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local txtDetailsUSDFText = objectReference:GetRefValue("txtDetailUSDFText")

		if itemData.tIndex == 0 then
			local iconRootUButton = objectReference:GetRefValue("iconRootUButton")

			iconRootUButton:TryChangePage("Quality", itemData.data.quality)

			iconUImage.url = itemData.data.icon

			if self.tab == UIConst.GIFT_TYPE.HOME then
				ClientTextUtils.setText(txtDetailsUSDFText, pg.getLocalizationText(itemData.data.homeDesc))
			else
				ClientTextUtils.setText(txtDetailsUSDFText, pg.getLocalizationText(itemData.data.desc))
			end

			ClientTextUtils.setText(txtNameUSDFText, pg.getLocalizationText(itemData.data.name))
		else
			local numLevelUSDFText = objectReference:GetRefValue("numLevelUSDFText")
			local numUSDFText = objectReference:GetRefValue("numUSDFText")
			local txtExclusive = objectReference:GetRefValue("txtExclusiveUSDFText")
			local imgBgImagePro = objectReference:GetRefValue("imgBgImagePro")
			local txtAbilityUSDFText = objectReference:GetRefValue("txtAbilityUSDFText")
			local homeAbilityData = HomeAbilityData[itemData.data.id]

			if itemData.data.level then
				ClientTextUtils.setText(numLevelUSDFText, itemData.data.level)
				ClientTextUtils.setText(numUSDFText, HomeAbilityLevelData[itemData.data.level].workload)
				txtAbilityUSDFText.gameObject:SetActiveEx(true)

				local levelText = pg.getFormatText(pg.getGameString("ABILITY_HOME_LEVEL"), itemData.data.level)

				ClientTextUtils.setText(txtNameUSDFText, ClientTextUtils.getLocalizationText(homeAbilityData.name) .. " " .. levelText)
			else
				txtAbilityUSDFText.gameObject:SetActiveEx(false)
				ClientTextUtils.setText(txtNameUSDFText, ClientTextUtils.getLocalizationText(homeAbilityData.name))
			end

			ClientTextUtils.setText(txtDetailsUSDFText, ClientTextUtils.getLocalizationText(homeAbilityData.desc))
			ClientTextUtils.setText(txtExclusive, ClientTextUtils.getLocalizationText(homeAbilityData.specialDes))

			iconUImage.url = homeAbilityData.icon

			imgBgImagePro:SetColorWithHtmlString(homeAbilityData.iconColor)
		end
	end

	if data.showType == UIConst.GIFT_SHOW_TYPE.GIFT then
		local tempData = {}

		for i = 1, #data.breedTalent do
			tempData[#tempData + 1] = {
				tIndex = 0,
				data = data.breedTalent[i]
			}
		end

		listUList:SetList(tempData)
	else
		local tempData = {}

		for i = 1, #data.abilityData do
			tempData[#tempData + 1] = {
				tIndex = 1,
				data = data.abilityData[i]
			}
		end

		listUList:SetList(tempData)
	end

	self.view.tabPanelRectTransform.gameObject:SetActiveEx(data.showType == UIConst.GIFT_SHOW_TYPE.GIFT)
end

function PetGiftTipsCtrl:onHide()
	return
end

function PetGiftTipsCtrl:checkUIShowVirtualMouseCursor()
	return false
end

function PetGiftTipsCtrl:generalReplayRefrersh()
	local isBattle = self.tab == UIConst.GIFT_TYPE.BATTLE
	local showPersonalityFruit = isBattle and self:canUsePersonalityFruit()

	self.view.widgetBtnUWidget:SetActive(showPersonalityFruit)
	self.view.listUList:RefreshList()
	self.view.bgSelHomeUImage.gameObject:SetActiveEx(not isBattle)
	self.view.bgSelBattleUImage.gameObject:SetActiveEx(isBattle)
end

return PetGiftTipsCtrl
