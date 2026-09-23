-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AppearanceV2\\Component\\PlayerComponent.lua

local Class = require("Core.Framework.Class")
local CallbackHandler = require("Core.Common.CallbackHandler")
local UIConst = require("Const.UIConst")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local UIComponent = require("Guis.Helper.UIComponent")
local AvatarUtils = require("Guis.Utils.AvatarUtils")
local PlayerAccessoryComponent = require("Guis.Panels.AppearanceV2.Component.PlayerAccessoryComponent")
local PlayerHandheldComponent = require("Guis.Panels.AppearanceV2.Component.PlayerHandheldComponent")
local PlayerClothesComponent = require("Guis.Panels.AppearanceV2.Component.PlayerClothesComponent")
local PlayerHairComponent = require("Guis.Panels.AppearanceV2.Component.PlayerHairComponent")
local SlotOptionComponent = require("Guis.Panels.AppearanceV2.Component.Common.SlotOptionComponent")
local SliderBubbleComponent = require("Guis.Panels.AppearanceV2.Component.Common.SliderBubbleComponent")
local HotkeyConst = require("Const.HotkeyConst")
local PlayerComponent = Class.LightClass("PlayerComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local FuncMenuListData = require("Data.func_menu_list_data")
local AppearanceSuitData = require("Data.appearance_suit_data")
local AvatarHairSuitData = require("Data.avatar_hair_suit_data")
local PhotographyStudioUtils = require("Utils.PhotographyStudioUtils")
local CommonSwitch = require("Common.CommonSwitch")

function PlayerComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.outfitUButton = self.objectReference:GetRefValue("outfitUButton")
	self.tabUList = self.objectReference:GetRefValue("tabUList")
	self.rootUComponent = self.objectReference:GetRefValue("rootUComponent")
	self.slotOptionTransform = self.objectReference:GetRefValue("slotOptionTransform")
	self.rightTransform = self.objectReference:GetRefValue("rightTransform")
	self.presetCloseUButton = self.objectReference:GetRefValue("presetCloseUButton")
	self.presetUButton = self.objectReference:GetRefValue("presetUButton")
	self.presetTitleUBaseText = self.objectReference:GetRefValue("presetTitleUBaseText")
	self.presetNumUBaseText = self.objectReference:GetRefValue("presetNumUBaseText")
	self.presetUList = self.objectReference:GetRefValue("presetUList")
	self.presetPartUList = self.objectReference:GetRefValue("presetPartUList")
	self.coverPresetUButton = self.objectReference:GetRefValue("coverPresetUButton")
	self.sourceUList = self.objectReference:GetRefValue("sourceUList")
	self.bubbleUComponent = self.objectReference:GetRefValue("bubbleUComponent")
	self.petBoxUButton = self.objectReference:GetRefValue("petBoxUButton")
	self.bottomTabUComponent = self.objectReference:GetRefValue("bottomTabUComponent")
	self.presetCloseUButtonConsole = self.objectReference:GetRefValue("presetCloseUButtonConsole")
	self.presetCloseShadowUSDFText = self.objectReference:GetRefValue("titleShadowUSDFTextConsole")
end

function PlayerComponent:initView()
	self.curPresetKey = self.ctrl.curPresetKey
	self.avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)
	self.needDestroyDownloadSprite = {}

	self:initComponents()
	ClientTextUtils.setText(self.presetCloseShadowUSDFText, pg.getLocalizationText(FuncMenuListData[151].name))
end

function PlayerComponent:initComponents()
	self.slotOptionComponent = SlotOptionComponent.new(self, self.slotOptionTransform)
	self.components = {}
	self.components.clothes = PlayerClothesComponent.new(self, self.rightTransform)
	self.components.accessory = PlayerAccessoryComponent.new(self, self.rightTransform)
	self.components.hair = PlayerHairComponent.new(self, self.rightTransform)
	self.components.handheld = PlayerHandheldComponent.new(self, self.rightTransform)
	self.bubbleComponent = SliderBubbleComponent.new(self, self.bubbleUComponent.transform, {
		type = 0
	})
end

function PlayerComponent:onEnterPage()
	self.slotOptionComponent:addListener()
	self.slotOptionComponent.hideUIUButton:SetActiveFastest(true)
	self.slotOptionComponent.roleHideUButton:SetActiveFastest(false)
	self:addListener()
	self.bottomTabUComponent:TryChangePage("Switch", "Role")
	self.avatarScene:showAvatar(self.curPresetKey, function()
		self.avatarScene:applyStudioPlayerPose(self.avatarScene:getCurEntityId(), nil)
	end)

	self.avatarScene.waitLoadEntity = false
	self.avatarScene.waitFreezeEntity = false

	self.ctrl:delayRefreshDecal()
	self:refreshTabList()
end

function PlayerComponent:onLeavePage()
	self.view.btnHairTieUButton.gameObject:SetActiveEx(true)
	self.slotOptionComponent:removeListener()
	self:removeListener()

	local accessory = self.components and self.components.accessory

	if accessory and accessory.enableTick then
		accessory:showLit(false)
	end

	local handheld = self.components and self.components.handheld

	if handheld then
		handheld:onPageClose()
	end

	self.avatarScene:hideEntityWithId(self.curPresetKey)

	if self.bubbleComponent then
		self.bubbleComponent:initHide()
	end
end

function PlayerComponent:prepareEnterPhotographyStudio()
	local entity = self.avatarScene and self.avatarScene:getCurEntity()

	if not PhotographyStudioUtils.clearUnownedAppearancePreview(entity) then
		return
	end

	self.avatarScene:beginStudioPlayerAppearanceRefresh(self.avatarScene:getCurEntityId())

	local clothesComponent = self.components and self.components.clothes

	if clothesComponent then
		clothesComponent:refreshClothes(false)
	end

	local hairComponent = self.components and self.components.hair

	if hairComponent then
		hairComponent:refreshHair(false)
	end

	local accessoryComponent = self.components and self.components.accessory

	if accessoryComponent then
		accessoryComponent:refreshAccessory()
	end

	if entity.refreshAppearanceFunction then
		entity:refreshAppearanceFunction()
	end
end

function PlayerComponent:addListener()
	function self.sourceUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local detailUText = objectReference:GetRefValue("detailUText")

		ClientTextUtils.setText(detailUText, pg.getLocalizationText(data.text))
	end

	function self.sourceUList.luaClick(button, data)
		if data.func then
			data.func()
		end
	end

	function self.outfitUButton.luaClick()
		local templateId = pg.game.avatar:getTemplateId(pg.me)

		pg.global.ui:open(UIConst.UI_ID_APPEARANCE_OUTFIT, {
			curPresetKey = self.curPresetKey,
			templateId = templateId
		})
	end

	function self.tabUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local normalUText = objectReference:GetRefValue("normalUText")
		local selectedUText = objectReference:GetRefValue("selectedUText")
		local tabText = data.tabNameText or pg.getGameString(data.tabName)

		ClientTextUtils.setText(normalUText, tabText)
		ClientTextUtils.setText(selectedUText, tabText)
	end

	function self.tabUList.luaClick(button, data)
		self.curComponent = self.components[data.name]

		for name, component in pairs(self.components) do
			if name ~= data.name then
				component:removeListener()
			end
		end

		self.curComponent:onEnterPage()
	end

	local function onClickClose()
		self.rootUComponent:TryChangePage("State", "Detail")

		if self.curComponent.onLeavePreset then
			self.curComponent:onLeavePreset()
		end

		self.ctrl:bindHotKeyPerform(HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel, function()
			return true
		end, self.rootUComponent.gameObject, "appearancePlayerPresetEscBind")
		self:passToRightInfoComponent(self.rootUComponent)
	end

	function self.presetUButton.luaClick()
		self:onPresetEntranceClicked()
		self.ctrl:bindHotKeyPerform(HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel, function()
			onClickClose()

			return false
		end, self.rootUComponent.gameObject, "appearancePlayerPresetEscBind")
	end

	self.presetCloseUButton.luaClick = onClickClose
	self.presetCloseUButtonConsole.luaClick = onClickClose

	function self.presetUList.luaRenderItem(button, index, data)
		AvatarUtils.renderPresetList(button, index, data, self.needDestroyDownloadSprite)
	end

	function self.presetUList.luaClick(button, data)
		if self.curComponent.onPresetClicked then
			self.curComponent:onPresetClicked(data)
		end
	end

	function self.presetPartUList.luaRenderItem(button, index, data)
		AvatarUtils.renderSlotList(button, index, data)
	end

	function self.presetPartUList.luaSelectedChanged(uList)
		if not uList.selectedItem then
			return
		end

		if self.curComponent.onPresetPartSelectedChanged then
			self.curComponent:onPresetPartSelectedChanged(uList.selectedItem)
		end
	end
end

function PlayerComponent:removeListener()
	self.sourceUList.luaRenderItem = nil
	self.sourceUList.luaClick = nil
	self.outfitUButton.luaClick = nil
	self.tabUList.luaRenderItem = nil
	self.tabUList.luaClick = nil
	self.presetUButton.luaClick = nil
	self.presetCloseUButton.luaClick = nil
	self.presetUList.luaRenderItem = nil
	self.presetUList.luaClick = nil
	self.presetPartUList.luaRenderItem = nil
	self.presetPartUList.luaSelectedChanged = nil
end

function PlayerComponent:onDestroy()
	for _, sprite in ipairs(self.needDestroyDownloadSprite) do
		pg.global.mobileCameraMgr:DestroySpriteTexture(sprite)
	end

	UIComponent.onDestroy(self)

	self.components = {}
end

function PlayerComponent:onShow()
	UIComponent.onShow(self)
end

function PlayerComponent:focusTab(tabName)
	self:refreshTabList(tabName)
end

function PlayerComponent:selectSuitOnOpen(suitInfo)
	if not suitInfo or not suitInfo.id then
		return
	end

	local suitId = suitInfo.id
	local suitType = suitInfo.type

	if not suitType then
		if AppearanceSuitData[suitId] then
			suitType = "clothes"
		elseif AvatarHairSuitData[suitId] then
			suitType = "hair"
		end
	end

	if suitType == "hair" then
		self:refreshTabList("APPEARANCE_HAIR")

		if self.components and self.components.hair and self.components.hair.selectSuitOnOpen then
			self.components.hair:selectSuitOnOpen(suitId)
		end
	elseif suitType == "clothes" then
		self:refreshTabList("APPEARANCE_CLOTHES")

		if self.components and self.components.clothes and self.components.clothes.selectSuitOnOpen then
			self.components.clothes:selectSuitOnOpen(suitId)
		end
	end
end

function PlayerComponent:refreshTabList(tabName)
	local tabList = {}

	table.insert(tabList, {
		name = "clothes",
		tabName = "APPEARANCE_CLOTHES"
	})
	table.insert(tabList, {
		name = "accessory",
		tabName = "APPEARANCE_ACCESSORY"
	})
	table.insert(tabList, {
		name = "hair",
		tabName = "APPEARANCE_HAIR"
	})

	if CommonSwitch.APPEARANCE_KIT then
		table.insert(tabList, {
			name = "handheld",
			tabName = "APPEARANCE_HANDHELD",
			tabNameText = pg.getGameString("APPEARANCE_KIT")
		})
	elseif tabName == "APPEARANCE_HANDHELD" then
		tabName = "APPEARANCE_CLOTHES"
	end

	self.tabUList:SetList(tabList)

	tabName = tabName or "APPEARANCE_CLOTHES"

	for index, tabInfo in ipairs(tabList) do
		if tabInfo.tabName == tabName then
			local res, btn = self.tabUList:TryGetChildAt(index - 1)

			if res then
				btn:OnClickSimulate()
			end

			break
		end
	end
end

function PlayerComponent:onPresetEntranceClicked(component)
	self.rootUComponent:TryChangePage("State", "Preset")

	component = component or self.curComponent

	if component.onEnterPreset then
		component:onEnterPreset()
	end

	self.coverPresetUButton:SetActiveFastest(false)
	self:passToRightInfoComponent(self.rootUComponent)
end

function PlayerComponent:onSlotSelectedChanged(data)
	if self.curComponent.onSlotSelectedChanged then
		self.curComponent:onSlotSelectedChanged(data)
	end
end

function PlayerComponent:onSlotClicked(oldData, data)
	if self.curComponent.onSlotClicked then
		self.curComponent:onSlotClicked(oldData, data)
	end
end

function PlayerComponent:onOptionSelectedChanged(data)
	if self.curComponent.onOptionSelectedChanged then
		self.curComponent:onOptionSelectedChanged(data)
	end
end

function PlayerComponent:onOptionClicked(slotData, oldData, data, button)
	if self.curComponent.onOptionClicked then
		self.curComponent:onOptionClicked(slotData, oldData, data, button)
	end
end

function PlayerComponent:onFilterSelectedChanged(slotData, filterFunc)
	if self.curComponent.onFilterSelectedChanged then
		self.curComponent:onFilterSelectedChanged(slotData, filterFunc)
	end
end

function PlayerComponent:onFilterClicked(slotData, isSelected)
	if self.curComponent.onFilterClicked then
		self.curComponent:onFilterClicked(slotData, isSelected)
	end
end

function PlayerComponent:onSearchChanged(slotData, filterFunc)
	if self.curComponent.onSearchChanged then
		self.curComponent:onSearchChanged(slotData, filterFunc)
	end
end

function PlayerComponent:postRenderOptionList(button, index, data)
	if self.curComponent and self.curComponent.postRenderOptionList then
		self.curComponent:postRenderOptionList(button, index, data)
	end
end

function PlayerComponent:onPartModelLoaded()
	local clothesComponent = self.components and self.components.clothes

	if clothesComponent and clothesComponent.onPartModelLoaded then
		clothesComponent:onPartModelLoaded()
	end
end

function PlayerComponent:refreshPreset(tabName)
	pg.global.showBubbleMessageRaw(pg.getGameString("APPEARANCE_SAVE_SUCCESS"), 3)

	for index = 0, self.tabUList.itemCount - 1 do
		local data = self.tabUList:GetData(index)

		if data.tabName == tabName then
			local res, btn = self.tabUList:TryGetChildAt(index)

			if res then
				btn:OnClickSimulate()
			end

			self:onPresetEntranceClicked(self.components[data.name])
		end
	end
end

function PlayerComponent:onBuyItems(data)
	if self.curComponent and self.curComponent.onBuyItems then
		self.curComponent:onBuyItems(data)
	end
end

function PlayerComponent:onAvatarFashionScoreChanged(info)
	if self.components then
		if self.components.accessory then
			self.components.accessory:onAvatarFashionScoreChanged(info)
		end

		if self.components.hair then
			self.components.hair:onAvatarFashionScoreChanged(info)
		end

		if self.components.clothes then
			self.components.clothes:onAvatarFashionScoreChanged(info)
		end
	end
end

function PlayerComponent:onVisibleChange(visible)
	if not self.avatarScene then
		return
	end

	local curEntity = self.avatarScene:getCurEntity()

	if not curEntity or not curEntity.cancelCustomShowPreview then
		return
	end

	if self.components.clothes then
		self.components.clothes:onVisibleChange(visible)
	end
end

function PlayerComponent:passToRightInfoComponent(originCmp, extra)
	return self.ctrl:passToRightInfoComponent(originCmp, extra)
end

function PlayerComponent:refreshPage(ignoreSelectFirst, itemId)
	if not self.curComponent then
		return
	end

	self.curComponent:refreshPage(ignoreSelectFirst, itemId)
end

return PlayerComponent
