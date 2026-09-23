-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\FirstPetShow\\FirstPetShowCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local UICtrl = require("Guis.UICtrl")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Utils = require("Common.Utils.Utils")
local PetConfigData = require("Data.pet_config_data")
local PetData = require("Data.pet_data")
local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local ClientConst = require("Const.ClientConst")
local CommonSwitch = require("Common.CommonSwitch")
local MessageName = require("Const.MessageName")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local ElementPropData = require("Data.element_prop_data")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local PetResearchContentData = require("Data.pet_research_content_data")
local ExploreAbilityData = require("Data.explore_ability_data")
local PetProtoTypeData = require("Data.pet_prototype_data")
local Const = require("Common.Const.Const")
local remove = table.remove
local PetFirstShowData = require("Data.pet_first_show_data")
local JoyStickDragRelay = require("Guis.Helper.JoyStickDragRelay")
local FirstPetShowCtrl = Class.LightClass("FirstPetShowCtrl", UICtrl)
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientUtils = require("Utils.ClientUtils")
local AddressDataConst = require("Const.AddressDataConst")

FirstPetShowCtrl.messages = {
	[MessageName.UI_ON_OPEN] = {
		"onOtherUIOpen",
		true
	}
}

local DOUYIN_DURATION = 5
local NORMAL_DURATION = 5
local OPEN_HANDBOOK_ACTION_PATH = "Hud/PetFirstOpenPetHandBook"
local CLOSE_ACTION_PATH = "Common/Cancel"

function FirstPetShowCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.joyStickDragListener = JoyStickDragRelay.attach(self.view.gameObject)
end

function FirstPetShowCtrl:onOpen(info)
	local inOfflineScene = ClientUtils.isInDouYinOfflineScene()

	self.isLowMode = info.lowMode or inOfflineScene

	UICtrl.onOpen(self)
	self:showFirstGetPet(info)
end

function FirstPetShowCtrl:onOtherUIOpen(uid)
	if uid == UIConst.UI_ID_NPC_CALL or uid == UIConst.UI_ID_BOTTOM_DIALOGUE then
		return
	end

	if uid and uid ~= self.uid then
		self:onClosePanel()
	end
end

function FirstPetShowCtrl:addListener()
	self:initDynamicContainers()

	function self.view.elementListUList.luaRenderItem(button, idx, data)
		if data.elementName then
			LuaUIUtils.setElementButtonNew(button, data.elementName)
		end
	end

	function self.view.btnCloseUButton.luaClick()
		self:closePanel()
	end

	self.openHandBookBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.gameObject, "openHandBook")
	self.openHandBookBind.isVirtual = true
	self.openHandBookBind.priority = 10
	self.openHandBookBind.actionPath = OPEN_HANDBOOK_ACTION_PATH

	function self.openHandBookBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" and self:_checkPetResearchCanOpen() then
			pg.global.ui.hudV2:openPetResearch({
				templateId = self.templateId
			})
			self:onClosePanel()
		end
	end

	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.gameObject, "closePanel")

	closeBind.isVirtual = true
	closeBind.priority = 10
	closeBind.actionPath = CLOSE_ACTION_PATH

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:closePanel()
		end
	end

	self:refreshKeyList()

	self.newPetQueue = {}
	self.aniInDuration = self.view.animation:GetClip("VX_Pb_Hud_PetFirst_In").length

	if pg.global.ui:runPlatformByMobile() then
		self.view.rayBoxDragEventListener.enabled = false
	end

	if not self.isLowMode then
		self.petFirstMeetScene = pg.game.uiScene:getScene(UISceneConst.PET_FIRST_MEET)
	end

	ClientTextUtils.setText(self.view.textCloseUSDFText, pg.getGameString("CLOSE"))
end

function FirstPetShowCtrl:getNewPetInfo()
	if #self.newPetQueue > 0 then
		local petInfo = remove(self.newPetQueue)
		local researchInfo = PetResearchContentData[petInfo.templateId] or {}

		petInfo.numberId = researchInfo.number
		petInfo.desc = researchInfo.firstShowDesc

		local pData = PetData[petInfo.templateId]
		local mainElementType = pData.mainElementType
		local mainElementName = ElementPropData[mainElementType].name

		petInfo.mainElementName = mainElementName
		petInfo.elementTypes = pData.elementType
		petInfo.iconName = pData.iconName

		return petInfo
	end
end

function FirstPetShowCtrl:showFirstGetPet(info, keepShow)
	table.mergeList(self.newPetQueue, info.newPets)
	self:refreshKeyList()
	self:tryShowPet(keepShow)
end

function FirstPetShowCtrl:_checkPetResearchCanOpen()
	return not ClientUtils.isInDouYinOfflineScene() and self:_checkPetResearchHasUnlock()
end

function FirstPetShowCtrl:_checkPetResearchHasUnlock()
	return pg.me:checkFunctionUnlock("PETRESEARCH") and CommonSwitch.PETRESEARCH and pg.me.isUIOpened[UIConst.UI_ID_PET_RESEARCH]
end

function FirstPetShowCtrl:refreshKeyList()
	local hasOpenResearch = self:_checkPetResearchCanOpen()

	if self.openHandBookBind then
		self.openHandBookBind.enabled = hasOpenResearch
	end

	local keyList = {}

	if not pg.global.ui:runPlatformByMobile() then
		if hasOpenResearch then
			keyList[#keyList + 1] = {
				path = OPEN_HANDBOOK_ACTION_PATH,
				label = pg.getGameString("OPEN_PET_RESEARCH")
			}
		end

		keyList[#keyList + 1] = {
			path = CLOSE_ACTION_PATH,
			label = pg.getGameString("CLOSE")
		}
	end

	LuaUIUtils.setKeyList(self.view.listKeyUList, keyList)
	self.view.listKeyUList:SetActiveFastest(#keyList > 0)
end

function FirstPetShowCtrl:initDynamicContainers()
	self.dynamicContainerStates = {
		{
			useCustomUrl = true,
			container = self.view.shineCardUContainer
		},
		{
			container = self.view.vXPbHudPetFirstPar03UContainer
		},
		{
			container = self.view.vXPbHudPetFirstPar04UContainer
		},
		{
			container = self.view.vXPbHudPetFirstBlackFlashUContainer
		}
	}
end

function FirstPetShowCtrl:refreshShineCardContainer(isShiny, shinyStyle)
	local container = self.view.shineCardUContainer

	container:SetActiveFastest(isShiny)

	if not isShiny then
		return
	end

	local bgIndex = 3

	if shinyStyle == Const.PET_SHINY_STYLE.BLACK then
		bgIndex = 2
	elseif shinyStyle == Const.PET_SHINY_STYLE.WHITE then
		bgIndex = 1
	end

	container:SetUrlWithCallback(AddressDataConst.UI_VX_PET_FIRST_CARD_BG[bgIndex])
end

function FirstPetShowCtrl:refreshDynamicContainers()
	for _, state in ipairs(self.dynamicContainerStates or EMPTY_TABLE) do
		local container = state.container

		if NotNil(container) then
			local active = container.gameObject.activeSelf

			if active then
				if state.active == false and not state.useCustomUrl then
					container:LoadDefaultUrlManually()
				end
			else
				container:DestroyContent()
			end

			state.active = active
		end
	end
end

function FirstPetShowCtrl:destroyDynamicContainers()
	for _, state in ipairs(self.dynamicContainerStates or EMPTY_TABLE) do
		local container = state.container

		if NotNil(container) then
			container:DestroyContent()
		end
	end

	self.dynamicContainerStates = nil
end

function FirstPetShowCtrl:tryShowPet(keepShow)
	local petInfo = self:getNewPetInfo()

	if petInfo then
		facade:SendMessageCommand(MessageName.PET_FIRST_SHOW, {
			templateId = petInfo.templateId
		})
		self:showPetInfo(petInfo, keepShow)
	else
		UIUtils.PlayAnimation(self.view.animation, "VX_Pb_Hud_PetFirst_Out", function()
			self:onClosePanel()
		end)
	end
end

function FirstPetShowCtrl:onClosePanel()
	self:dismiss()
end

function FirstPetShowCtrl:clearAniTimer()
	if self.aniTimer then
		self:killTimer(self.aniTimer)

		self.aniTimer = nil
	end
end

function FirstPetShowCtrl:playAndAutoCLose()
	self.view.animation:Stop()
	self.view.animation:Play("VX_Pb_Hud_PetFirst_In")
	self:clearAniTimer()

	local duration = ClientUtils.isInDouYinOfflineScene() and DOUYIN_DURATION or NORMAL_DURATION

	self.aniTimer = self:startTimer(function()
		self:tryShowPet()
	end, duration)
end

function FirstPetShowCtrl:showPetInfo(petInfo, keepShow)
	petInfo = petInfo or {}

	self.view.rawImageURawImage:SetActive(false)
	self.view.petImage:SetActive(false)

	local t = LuaUIUtils.getTargetElementsInfos(petInfo.elementTypes)

	self.view.elementListUList:SetList(t)

	local name = pg.getLocalizationText(petInfo.name or "")

	ClientTextUtils.setText(self.view.name1, name)
	ClientTextUtils.setText(self.view.name2, name)
	ClientTextUtils.setText(self.view.variantName1, name)
	ClientTextUtils.setText(self.view.variantName2, name)

	self.templateId = petInfo.templateId

	local firstShowData = PetFirstShowData[petInfo.templateId]

	PetResearchUtils.setEvolveQuality(self.view.btnPetQualityUButton, self.templateId)

	if firstShowData and firstShowData.featureDescription then
		LuaUIUtils.setUIViewVisible(self.view.txtDetailUText, true)
		ClientTextUtils.setText(self.view.txtDetailUText, pg.getLocalizationText(firstShowData.featureDescription))
	else
		LuaUIUtils.setUIViewVisible(self.view.txtDetailUText, false)
	end

	local petType = PetData[self.templateId].functionId

	self.view.battleTypeIcon.url = PetConfigData.petFunctionIcon[petType]

	ClientTextUtils.setText(self.view.battleTypeName, pg.getLocalizationText(PetConfigData[string.format("petFunctionText%s", petType)]))

	local petId = petInfo.id
	local curAbilityMap
	local petInfoTemp = not ClientUtils.isInDouYinOfflineScene() and pg.me:getPetInfo(petId) or nil

	if petId and petInfoTemp then
		curAbilityMap = petInfoTemp.exploreAbilityList:getRawTable()
	end

	if curAbilityMap and next(curAbilityMap) then
		local abilityId = curAbilityMap[next(curAbilityMap)]
		local abilityParamData = pg.global.abilityMgr:getAbilityParamData(abilityId)

		ClientTextUtils.setText(self.view.skillNameUSDFText, pg.getLocalizationText(abilityParamData.name))

		self.view.exploreSkillIconUImage.url = abilityParamData.icon

		self.view.manualPetSkillUButton:TryChangePage("SkillType", 0)
		LuaUIUtils.setUIViewVisible(self.view.manualPetSkillUButton, true)
	else
		local actionAbility = self:getActionAbilitySortedList()
		local protoData = PetProtoTypeData[self.templateId]
		local hasActionAbility = false

		for _, actionName in ipairs(actionAbility) do
			local level = protoData[actionName]

			if level then
				self.view.manualPetSkillUButton:TryChangePage("SkillType", 2)

				local actionInfo = ExploreAbilityData[actionName]

				self.view.qualityIconUImage.url = actionInfo.icon[1]

				ClientTextUtils.setText(self.view.levelText, level)
				ClientTextUtils.setText(self.view.skillNameUSDFText, pg.getLocalizationText(actionInfo.name))
				self.view.manualPetSkillUButton:TryChangePage("Quality", level)

				hasActionAbility = true

				break
			end
		end

		LuaUIUtils.setUIViewVisible(self.view.manualPetSkillUButton, hasActionAbility)
	end

	self.view.formWidget:SetActive(true)
	ClientTextUtils.setText(self.view.formName, LuaUIUtils.getPetFormName(self.templateId))

	local displayNumber, isCustom = PetResearchUtils.getDisplayNumberByTemplateId(self.templateId)

	ClientTextUtils.setText(self.view.textUSDFText, isCustom and "" or "No.")
	ClientTextUtils.setText(self.view.txtNumUText, displayNumber)

	local label = petInfo.label
	local shinyStyle = petInfo.shinyStyle or petInfoTemp and petInfoTemp.shinyStyle or 0

	self:clearShowPetTimer()

	if self.isLowMode then
		local petIcon = LuaUIUtils.getPetIcon(petInfo.iconName, LuaUIUtils.PET_FIRST_SHOW, label)

		if self.view.petImage.url == petIcon then
			self.view.petImage:SetActive(true)
		else
			self.view.petImage:SetUrlWithCallback(petIcon, function()
				self.view.petImage:SetActive(true)
			end)
		end
	else
		self.view.rawImageURawImage:SetActive(true)
		self.petFirstMeetScene:showPet(self.templateId, label, firstShowData, shinyStyle)
	end

	local isShiny = Utils.isLabelShiny(label)

	if isShiny then
		if shinyStyle == Const.PET_SHINY_STYLE.BLACK then
			self.view.widget:TryChangePage("ShineCard", 2)
		elseif shinyStyle == Const.PET_SHINY_STYLE.WHITE then
			self.view.widget:TryChangePage("ShineCard", 3)
		else
			self.view.widget:TryChangePage("ShineCard", 0)
		end
	else
		self.view.widget:TryChangePage("ShineCard", 1)
	end

	self:refreshShineCardContainer(isShiny, shinyStyle)
	self.view.widget:TryChangePage("isBoss", petInfo.isBoss and 1 or 0)
	self.view.widget:TryChangePage("isChange", petInfo.isVariant and 1 or 0)
	self:refreshDynamicContainers()
	pg.game.input:playRumbleByName(ClientConst.RumbleLayer.DEFAULT, "CommonHigh")
	self:playAndAutoCLose()
end

function FirstPetShowCtrl:getActionAbilitySortedList()
	if not self.sortedActionAbility then
		self.sortedActionAbility = {}

		local temp = {}

		for name, info in pairs(ExploreAbilityData) do
			temp[#temp + 1] = {
				priority = info.priority or 999,
				name = name
			}
		end

		table.sort(temp, function(a, b)
			return a.priority < b.priority
		end)

		for _, info in pairs(temp) do
			self.sortedActionAbility[#self.sortedActionAbility + 1] = info.name
		end
	end

	return self.sortedActionAbility
end

function FirstPetShowCtrl:clearShowPetTimer()
	if self.showPetTimer then
		self:killTimer(self.showPetTimer)
	end

	self.showPetTimer = nil
end

function FirstPetShowCtrl:onDestroy()
	JoyStickDragRelay.detach(self.joyStickDragListener)

	self.joyStickDragListener = nil

	self:destroyDynamicContainers()
	UICtrl.onDestroy(self)

	self.templateId = nil
end

function FirstPetShowCtrl:closePanel()
	self:tryShowPet()
end

return FirstPetShowCtrl
