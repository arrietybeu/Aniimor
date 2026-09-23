-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Chat\\Component\\PetShareComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local CallbackHandler = require("Core.Common.CallbackHandler")
local Class = require("Core.Framework.Class")
local PetShareComponent = Class.LightClass("PetShareComponent", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local LuaUIUtils = require("Utils.LuaUIUtils")
local HotkeyConst = require("Const.HotkeyConst")
local AddressDataConst = require("Const.AddressDataConst")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local Utils = require("Common.Utils.Utils")
local json = require("json")
local Const = require("Common.Const.Const")
local PetData = require("Data.pet_data")
local SysConfigData = require("Data.sys_config_data")
local PetManagementUtils = require("Utils.PetManagementUtils")
local AbilityConst = require("Common.Const.AbilityConst")
local AttributeConst = require("Common.Const.AttributeConst")
local PetAttributeCalcUtils = require("Common.Utils.PetAttributeCalcUtils")
local PetTransmogUtils = require("GameApp.PetTransmog.PetTransmogUtils")

local function hasSearchText(text)
	return not string.isNilOrEmpty(text)
end

local function isPetTipsOpen(uWidget)
	local _, page = uWidget:TryGetCurrentPage("ShowPetInfo")

	return page == 1
end

local function getShareAbilityId(ability)
	return ability and ability.abilityId or nil
end

local function buildShareSkillAbilityMap(petInfo)
	local curAbilityMap = petInfo.curAbilityMap or {}
	local exploreAbilityMap = petInfo.exploreAbilityList and petInfo.exploreAbilityList:getRawTable() or {}
	local _, exploreAbilityId = next(exploreAbilityMap)

	return {
		ultimate = getShareAbilityId(curAbilityMap[AbilityConst.ULTIMATE_ABILITY]),
		q = getShareAbilityId(curAbilityMap[AbilityConst.WEAPON_SKILL_ABILITY]),
		e = getShareAbilityId(curAbilityMap[AbilityConst.WEAPON_SKILL_ABILITY2]),
		explore = exploreAbilityId
	}
end

local function buildShareCarryData(petId)
	local petTrainingModel = pg.global.ui.petTrainingNew and pg.global.ui.petTrainingNew.model
	local carryData = petTrainingModel and petTrainingModel:getPetEquipCarry(petId)

	if not carryData then
		return nil
	end

	return {
		itemId = carryData.itemId,
		icon = carryData.icon,
		name = carryData.name,
		cLevel = carryData.cLevel,
		quality = carryData.quality,
		isRecommend = LuaUIUtils.checkCarryIsRecommend(petId, carryData.itemId),
		assistCarryPosList = Utils.deepCopyTable(carryData.assistCarryPosList),
		assistCarryTypeList = Utils.deepCopyTable(carryData.assistCarryTypeList),
		assistUnlock = Utils.deepCopyTable(carryData.assistUnlock),
		slotUnlockLv = Utils.deepCopyTable(carryData.slotUnlockLv)
	}
end

local function getShareSkillPresetName(petInfo)
	if not petInfo then
		return ""
	end

	local abilityPresetMap = petInfo.abilityPresetMap and petInfo.abilityPresetMap[petInfo.curAbilityPreset]

	if abilityPresetMap and abilityPresetMap.name and abilityPresetMap.name ~= "" then
		return abilityPresetMap.name
	end

	return ClientTextUtils.concatByLanguage(pg.getGameString("ABILITY_PLAN"), petInfo.curAbilityPreset)
end

local function buildShareCalculatedAttributeMap(petInfo)
	local calculatedAttributeMap, extraSrcMap = PetAttributeCalcUtils.getAttributeMapByPetInfo(pg.me, petInfo)
	local shareAttributeMap = {}

	for i = Const.BASE_PROPERTY_HP_IDX, Const.BASE_PROPERTY_ATK_MAG_IDX do
		local attrName = PetManagementUtils.getPetOldPropAttrConstName(i)
		local attrId = AttributeConst[attrName] or PetManagementDataHelper.CUR_PROP[i]

		shareAttributeMap[tostring(attrId)] = calculatedAttributeMap[attrId] or calculatedAttributeMap[PetManagementDataHelper.CUR_PROP[i]]
	end

	return shareAttributeMap, extraSrcMap
end

local function buildShareSourceDesc(data)
	local source = PetManagementDataHelper.getPetSource(data.id)

	if string.isNilOrEmpty(source) then
		return ""
	end

	local playerInfo = pg.game.chat:getPlayerInfo(source)
	local playerName = playerInfo and playerInfo.playerName or ""
	local _h = PetManagementUtils._platformHooks

	playerName = _h and _h.refreshSourcePlayerName and _h.refreshSourcePlayerName(PetManagementUtils, data, source, playerName, playerInfo) or playerName

	return string.gsub(pg.getGameString("PET_EXCHANGE_SOURCE"), "{0}", playerName)
end

function PetShareComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.selectorUSelector = objectReference:GetRefValue("selectorUSelector")
	self.selectorNameUSDFText = objectReference:GetRefValue("selectorNameUSDFText")
	self.bgCloseUButton = objectReference:GetRefValue("bgCloseUButton")
	self.btnConfirmUButton = objectReference:GetRefValue("btnConfirmUButton")
	self.btnLeftUButton = objectReference:GetRefValue("btnLeftUButton")
	self.btnRightUButton = objectReference:GetRefValue("btnRightUButton")
	self.buttonSearchUButton = objectReference:GetRefValue("buttonSearchUButton")
	self.petListUWidget = objectReference:GetRefValue("petListUWidget")
	self.inputFieldUTMPInputField = objectReference:GetRefValue("inputFieldUTMPInputField")
	self.petDetailsUContainer = objectReference:GetRefValue("petDetailsUContainer")
	self.btnAllSelectedUButton = objectReference:GetRefValue("btnAllSelectedUButton")
	self.titleUSDFText = objectReference:GetRefValue("titleUSDFText")
	self.shouldSelectUWidget = objectReference:GetRefValue("shouldSelectUWidget")
	self.btnScreenUButton = objectReference:GetRefValue("btnScreenUButton")
	self.listFilterUList = objectReference:GetRefValue("listFilterUList")
	self.mainPetListUwidget = objectReference:GetRefValue("mainPetListUwidget")

	local inputObjectReference = self.inputFieldUTMPInputField:GetComponent("ObjectReference")

	self.placeHolderUSDFText = inputObjectReference:GetRefValue("placeHolderUSDFText")
	self.btnDeleteUButton = inputObjectReference:GetRefValue("btnDeleteUButton")
	self.keyHotKeyContent = inputObjectReference:GetRefValue("keyHotKeyContent")
end

function PetShareComponent:initView()
	self.btnAllSelectedUButton:SetActive(false)
	ClientTextUtils.setText(self.placeHolderUSDFText, pg.getGameString("CHAT_TIP_INPUT_PET"))

	self.isSearching = false

	self.btnDeleteUButton:SetActive(hasSearchText(self.inputFieldUTMPInputField.text))
	self.mainPetListUwidget:TryChangePage("State", 0)
	LuaUIUtils.bindHotKey(self.gameObject, HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadRightStickPress, CallbackHandler(self, "focusPetDetails"), nil, -1)

	function self.bgCloseUButton.luaClick()
		self:onClose()
	end

	local closeCommonBind = KeyBindingPro.GetOrAddKeyBindingByName(self.bgCloseUButton.gameObject, "closeCommonBind")

	closeCommonBind.isVirtual = true
	closeCommonBind.priority = 1
	closeCommonBind.actionPath = "Common/ClosePanelCommon"

	function closeCommonBind.luaTrigger(inputInfo)
		self.bgCloseUButton.luaClick()
	end

	function self.btnConfirmUButton.luaClick()
		if not self.selectedPetData then
			return
		end

		local channelId = self.view.channelListUList.selectedItem.channelId

		if pg.game.chat:getWorldMessageCD() > 0 and pg.game.chat:isWorldChatGroupId(channelId) then
			pg.global.showBubbleMessageRaw(pg.getGameString("CHAT_SEND_CD"), 2)

			return
		end

		local text = pg.getGameString("PET")
		local curSelectedChannelData = self.view.channelListUList.selectedItem

		pg.game.chat:sendMessage(text, pg.game.chat.subMessageType.Text, curSelectedChannelData.type, curSelectedChannelData.channelId or curSelectedChannelData.playerId, {
			[Const.CHAT_EXTRA_TYPE.Pet] = self.inputStr
		})
		self.ctrl.chatComponent:checkSendButtonState()
		self:onClose(true)
	end

	function self.btnLeftUButton.luaClick()
		if self.isSearching and hasSearchText(self.inputFieldUTMPInputField.text) then
			return
		end

		self.curBoxIndex = self.curBoxIndex == 1 and self.maxBoxIndex or self.curBoxIndex - 1

		self:refreshPetList(self.curBoxIndex)
	end

	function self.btnRightUButton.luaClick()
		if self.isSearching and hasSearchText(self.inputFieldUTMPInputField.text) then
			return
		end

		self.curBoxIndex = self.curBoxIndex == self.maxBoxIndex and 1 or self.curBoxIndex + 1

		self:refreshPetList(self.curBoxIndex)
	end

	function self.buttonSearchUButton.luaClick()
		self.isSearching = true

		self.uWidget:TryChangePage("Search", 1)
		self:refreshSearchState(self.inputFieldUTMPInputField.text)
	end

	function self.btnScreenUButton.luaClick()
		self.isSearching = false

		self.uWidget:TryChangePage("Search", 0)
		self.mainPetListUwidget:TryChangePage("State", 0)

		self.inputFieldUTMPInputField.text = ""

		self.listFilterUList:SetList({})

		if self.selectedPetBtn then
			self.selectedPetBtn.isSelected = false
		end

		self.selectedPetBtn = nil

		self:refreshPetList(self.curBoxIndex)
		self.btnLeftUButton:SetActive(true)
		self.btnRightUButton:SetActive(true)
	end

	LuaUIUtils.bindInputFieldGamepad(self.inputFieldUTMPInputField, self.keyHotKeyContent, self.btnDeleteUButton)

	function self.inputFieldUTMPInputField.luaValueChanged(text)
		self.btnDeleteUButton:SetActive(hasSearchText(text))

		if not self.isSearching then
			return
		end

		self:refreshSearchState(text)

		if not hasSearchText(text) then
			return
		end

		self:refreshFilterPetList(text)
	end

	function self.listFilterUList.luaRenderItem(button, index, data)
		button.dataFromUList = data

		if data.isEmpty then
			self:setEmptyButton(button)

			return
		end

		self:setBoxPetListData(button, index, data, true)
	end

	function self.listFilterUList.luaSelectedChanged(list, selected)
		if selected == false then
			return
		end

		local data = list.selectedItem

		if not data then
			return
		end

		if self.selectedPetBtn and self.selectedPetBtn.dataFromUList == data then
			return
		end

		local button

		if list.selectedIndex and list.selectedIndex >= 0 then
			local _

			_, button = list:TryGetChildAt(list.selectedIndex)
		end

		if data.isEmpty then
			self:selectEmptyPetSlot(button)

			return
		end

		self:selectPet(button, data)
	end

	self.boxPetNewListContainers = {}

	for i = 0, 23 do
		self.boxPetNewListContainers[i] = self.petListUWidget.transform:GetChild(i).transform:GetComponent("UContainer")
	end

	self.curBoxIndex = 1
	self.maxBoxIndex = #pg.me.petBoxMap
	self.boxInfos = PetManagementDataHelper.getBoxInfos()

	self.uWidget:TryChangePage("Selected", 0)

	function self.selectorUSelector.luaRenderPopup(popup, list)
		function list.luaRenderItem(button, _, data)
			local objectReference = button:GetComponent("ObjectReference")
			local txtUText = objectReference:GetRefValue("txtUText")

			if data.customName and data.customName ~= "" then
				ClientTextUtils.setText(txtUText, data.customName)
			else
				ClientTextUtils.setText(txtUText, pg.getGameString("DEFAULT_PET_BOX_NAME") .. " " .. data.idx)
			end
		end

		function list.luaSelectedChanged(selectorList)
			self.curBoxIndex = selectorList.selectedItem and selectorList.selectedItem.idx or 1

			self:refreshPetList(self.curBoxIndex)
			self.selectorUSelector:ClosePopup()
		end

		list:SetList(self.boxInfos)
		list:SelectItem(self.curBoxIndex - 1 or 0)
	end
end

function PetShareComponent:focusPetDetails()
	if not pg.game.input:isUsingGamepad() then
		return true
	end

	if not isPetTipsOpen(self.uWidget) then
		return true
	end

	local content = self.petDetailsUContainer.content

	if IsNil(content) or pg.global.navMgr:IsFocusInNavGroupOf(content) then
		return true
	end

	pg.global.navMgr:PushFocusNavGroupOf(content)

	return false
end

function PetShareComponent:refreshSearchState(text)
	local isFiltering = hasSearchText(text)

	self.mainPetListUwidget:TryChangePage("State", isFiltering and 1 or 0)
	self.btnLeftUButton:SetActive(not isFiltering)
	self.btnRightUButton:SetActive(not isFiltering)

	if not isFiltering then
		self.listFilterUList:SetList({})
	end
end

function PetShareComponent:refreshFilterPetList(text)
	local petList = {}

	for _, pet in pairs(pg.me.pets) do
		local isMatched = string.isNilOrEmpty(text)

		if not isMatched then
			local customName = pet.customName or ""
			local petConfig = PetData[pet.templateId]
			local templateName = petConfig and pg.getLocalizationText(petConfig.name) or ""

			isMatched = string.find(customName, text) or string.find(templateName, text)
		end

		if isMatched then
			local petInfo = PetManagementDataHelper.setUpPetInfo(pet)

			petInfo.tIndex = 0
			petList[#petList + 1] = petInfo
		end
	end

	local fullPageSlotCount = PetManagementDataHelper.FULL_PAGE_SLOT_COUNT or 30
	local fullRowSlotCount = PetManagementDataHelper.FULL_ROW_SLOT_COUNT or 6
	local targetCount = fullPageSlotCount > #petList and fullPageSlotCount or #petList
	local mod = targetCount % fullRowSlotCount

	if mod ~= 0 then
		targetCount = targetCount + fullRowSlotCount - mod
	end

	for _ = #petList + 1, targetCount do
		petList[#petList + 1] = {
			isEmpty = true,
			tIndex = 1
		}
	end

	self.selectedPetBtn = nil

	self.listFilterUList:SetList(petList)
end

function PetShareComponent:refreshPetList(index)
	for idx, info in pairs(self.boxInfos) do
		info.selected = idx == index
	end

	self.view.panelUComponent:TryChangePage("ShowPopup", 4)

	local isTipsOpen = isPetTipsOpen(self.uWidget)

	self.uWidget:TryChangePage("Selected", isTipsOpen and 1 or 0)

	self.selectedPetBtn = nil

	local boxId = pg.me.petBoxMap.sequence[index]
	local extraPetInfo = PetManagementDataHelper.getBoxInfoById(boxId)

	for i = 0, #self.boxPetNewListContainers do
		local data = extraPetInfo[i + 1]

		if not data or data.isEmpty then
			self.boxPetNewListContainers[i].url = AddressDataConst.PET_EMPTY_SLOT
		else
			self.boxPetNewListContainers[i].url = AddressDataConst.PET_NORMAL_SLOT
		end

		if data and not data.isEmpty then
			local uBtn = self.boxPetNewListContainers[i].content:GetComponent("UButton")

			self:setBoxPetListData(uBtn, i, data, isTipsOpen)

			uBtn.dataFromUList = data
		else
			self:setEmptyButton(self.boxPetNewListContainers[i].content)
		end
	end

	if self.boxInfos[index].customName and self.boxInfos[index].customName ~= "" then
		ClientTextUtils.setText(self.selectorNameUSDFText, self.boxInfos[index].customName)
	else
		ClientTextUtils.setText(self.selectorNameUSDFText, pg.getGameString("DEFAULT_PET_BOX_NAME") .. " " .. self.boxInfos[index].idx)
	end
end

function PetShareComponent:selectPet(button, data)
	if self.selectedPetBtn then
		self.selectedPetBtn.isSelected = false
	end

	if button then
		button.isSelected = true
		self.selectedPetBtn = button
	else
		self.selectedPetBtn = nil
	end

	local petInfo = pg.me:getPetInfo(data.id)
	local pageIndex, ratingString = petInfo:getPropRatingResult()
	local calculatedAttributeMap, extraSrcMap = buildShareCalculatedAttributeMap(petInfo)
	local featureInfo, controlFeatureId = PetManagementDataHelper.getCurCharacter(data.id)
	local selectTransmogScheme = PetTransmogUtils.getSelectedScheme(petInfo)

	selectTransmogScheme = selectTransmogScheme and (selectTransmogScheme.getRawTable and selectTransmogScheme:getRawTable() or selectTransmogScheme)
	self.selectedPetData = {
		id = data.id,
		name = petInfo.customName and petInfo.customName ~= "" and petInfo.customName or PetData[data.templateId].name,
		isCatchReporting = petInfo:isCatchReporting(),
		iconName = data.iconName,
		label = data.label,
		templateId = data.templateId,
		cubeItemId = petInfo.cubeItemId,
		elementNames = data.elementNames,
		cp = data.cp,
		gender = data.gender,
		level = data.level,
		isShiny = data.isShiny,
		shinyStyle = data.shinyStyle,
		shinyEffectReplace = petInfo.shinyEffectReplace,
		isBoss = data.isBoss,
		isVariant = data.isVariant,
		isVariantInteractPet = data.isVariantInteractPet,
		variantFriendUid = pg.me:getPetVariantFriendUid(data.id),
		variantTime = pg.me:getPetVariantTime(data.id),
		isDark = data.isDark,
		breedTalent = Utils.deepCopyTable(data.breedTalent),
		exp = data.exp,
		basePropertyList = Utils.deepCopyTable(petInfo.basePropertyList),
		propertyEnhanced = Utils.isPetPropertyEnhanced(petInfo),
		calculatedAttributeMap = calculatedAttributeMap,
		extraSrcMap = extraSrcMap,
		featureInfo = featureInfo,
		controlFeatureId = controlFeatureId,
		skillAbilityMap = buildShareSkillAbilityMap(petInfo),
		skillPresetName = getShareSkillPresetName(petInfo),
		carryData = buildShareCarryData(data.id),
		pageIndex = pageIndex,
		ratingString = ratingString,
		ratingStribng = ratingString,
		sourceDesc = buildShareSourceDesc(data),
		time = data.time,
		bookNum = data.bookNum,
		resonanceInfo = Utils.deepCopyTable(petInfo.resonanceInfo),
		selectTransmogScheme = selectTransmogScheme
	}
	self.encodedPetData = json.encode(self.selectedPetData)
	self.inputStr = compress(self.encodedPetData)
	self.petData = PetManagementDataHelper.setUpPetInfo(petInfo)

	self.uWidget:TryChangePage("Selected", 1)
	self.uWidget:TryChangePage("ShowPetInfo", 1)
	self:showPetDetail()
end

function PetShareComponent:showPetDetail()
	self.isPetPreviewActive = true
	self.petPreviewSceneOwnerKey = self.petPreviewSceneOwnerKey or self.ctrl.module .. "_PetShare"

	if not self.petPreviewUIScene then
		self.petPreviewUIScene = pg.game.uiScene:getScene(UISceneConst.PET_MANAGEMENT_PREVIEW_SCENE)

		if not self.petPreviewUIScene then
			self.petPreviewUIScene = pg.game.uiScene:getUISceneInst(UISceneConst.PET_MANAGEMENT_PREVIEW_SCENE, AddressDataConst.PET_MANAGEMENT_PREVIEW_SCENE_Prefab)
		end
	end

	self.petPreviewUIScene:bindUICtrlKey(self.petPreviewSceneOwnerKey)

	if self.petPreviewUIScene:checkLoaded() then
		self:onPetPreviewUISceneLoaded()
	elseif not self.inLoadPetPreviewUIScene then
		self.inLoadPetPreviewUIScene = true

		self.petPreviewUIScene:startLoad(function(succeed)
			self.inLoadPetPreviewUIScene = false

			if succeed and self.petPreviewUIScene then
				self:onPetPreviewUISceneLoaded()
			end
		end)
	end
end

function PetShareComponent:onPetPreviewUISceneLoaded()
	if not self.isPetPreviewActive or not self.selectedPetData then
		return
	end

	pg.game.uiScene:switchToScene(UISceneConst.PET_MANAGEMENT_PREVIEW_SCENE, true, true, true, self.petPreviewSceneOwnerKey)
	self.petPreviewUIScene:setLocalEnv()

	if not self.petDetailsUContainer:CheckURLLoaded() then
		self.petDetailsUContainer:LoadDefaultUrlManually(function()
			if not self.isPetPreviewActive or not self.petPreviewUIScene then
				return
			end

			self.petDetailsUContainer.content:TryChangePage("BgState", 1)
			PetManagementUtils.clearAbilityUContainerObjects()
			PetManagementUtils.initSimpleInfoTemplate(self.petDetailsUContainer.content, {
				defaultSelectTabIndex = 0,
				uiScene = self.petPreviewUIScene,
				owner = self,
				extraLogic = function()
					if PetManagementUtils.btnRenameUButton then
						PetManagementUtils.btnRenameUButton.gameObject:SetActiveEx(false)
					end

					if PetManagementUtils.btnFavoriteUButton then
						PetManagementUtils.btnFavoriteUButton.gameObject:SetActiveEx(false)
					end

					if PetManagementUtils.btnSkillPresetsUButton then
						PetManagementUtils.btnSkillPresetsUButton.gameObject:SetActiveEx(false)
					end

					if PetManagementUtils.btnPetManualUButton then
						PetManagementUtils.btnPetManualUButton.gameObject:SetActiveEx(false)
					end

					if PetManagementUtils.skillBtn then
						PetManagementUtils.skillBtn.interactable = true
					end
				end
			})
			PetManagementUtils.showPetInfo(self.petData)
		end)
	else
		PetManagementUtils.showPetInfo(self.petData)
	end
end

function PetShareComponent:hidePetPreviewUIScene(destroy)
	self.isPetPreviewActive = false

	if not self.petPreviewUIScene then
		return
	end

	if not self.petPreviewUIScene.uiCtrlKeys then
		self.petPreviewUIScene = nil
		self.inLoadPetPreviewUIScene = nil

		return
	end

	self.petPreviewUIScene:removeUICtrlKey(self.petPreviewSceneOwnerKey)
	pg.game.uiScene:switchOutScene(UISceneConst.PET_MANAGEMENT_PREVIEW_SCENE, destroy and self.petPreviewUIScene:checkHasUICtrlBind() or true, nil, self.petPreviewSceneOwnerKey)

	if destroy then
		self.petPreviewUIScene = nil
		self.inLoadPetPreviewUIScene = nil
	end
end

function PetShareComponent:setBoxPetListData(button, index, data, keepSelected)
	local objectReference = button:GetComponent("ObjectReference")
	local txtBoxUImage = objectReference:GetRefValue("txtBoxUImage")

	txtBoxUImage:SetActive(false)

	local battleNum = 0
	local inFightPetInfos = pg.global.ui.petManagement.model:getGroupInfoById(pg.global.ui.petManagement.model:getSelectGroupId())

	if #inFightPetInfos > 0 then
		for i, v in pairs(inFightPetInfos) do
			if v.id == data.id then
				battleNum = i

				break
			end
		end

		local battleNumUContainer = objectReference:GetRefValue("battleNumUContainer")

		if battleNum > 0 then
			if battleNumUContainer:CheckURLLoaded() then
				battleNumUContainer.content:TryChangePage("number", battleNum - 1)
			else
				battleNumUContainer:LoadDefaultUrlManually(function(widget)
					widget:TryChangePage("number", battleNum - 1)
				end)
			end
		else
			battleNumUContainer:DestroyContent()
		end
	end

	LuaUIUtils.renderPetHead(button, data)
	button:TryChangePage("isBoss", 0)

	local isSelected = keepSelected and isPetTipsOpen(self.uWidget) and self.selectedPetData and self.selectedPetData.id == data.id

	button.isSelected = isSelected == true

	if isSelected then
		self.selectedPetBtn = button
	end

	button.draggable = false

	function button.luaClick()
		self:selectPet(button, data)
	end
end

function PetShareComponent:selectEmptyPetSlot(button)
	if self.selectedPetBtn then
		self.selectedPetBtn.isSelected = false
	end

	if button then
		button.isSelected = false
	end

	self.selectedPetBtn = nil
	self.selectedPetData = nil

	self:hidePetPreviewUIScene()
	self.uWidget:TryChangePage("Selected", 0)
	self.uWidget:TryChangePage("ShowPetInfo", 0)
end

function PetShareComponent:setEmptyButton(button)
	button.isSelected = false

	function button.luaClick()
		self:selectEmptyPetSlot(button)
	end
end

function PetShareComponent:onClose(force)
	local _, page = self.uWidget:TryGetCurrentPage("ShowPetInfo")

	if page == 1 then
		self:hidePetPreviewUIScene()
		self.uWidget:TryChangePage("ShowPetInfo", 0)
		self.uWidget:TryChangePage("Selected", 0)

		if self.selectedPetBtn then
			self.selectedPetBtn.isSelected = false
		end

		self.selectedPetBtn = nil

		if not force then
			return
		end
	end

	self.isSearching = false

	self.uWidget:TryChangePage("Search", 0)
	self.mainPetListUwidget:TryChangePage("State", 0)

	self.inputFieldUTMPInputField.text = ""

	self.listFilterUList:SetList({})
	self.btnLeftUButton:SetActive(true)
	self.btnRightUButton:SetActive(true)

	self.selectedPetData = nil
	self.encodedPetData = nil
	self.inputStr = nil
	self.petData = nil

	self.view.panelUComponent:TryChangePage("ShowPopup", 0)
end

function PetShareComponent:onDestroy()
	self:hidePetPreviewUIScene(true)
	PetManagementUtils.destroyTemplate(self)
end

return PetShareComponent
