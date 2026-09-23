-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\NpcDuelStart\\NpcDuelStartCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local AddressDataConst = require("Const.AddressDataConst")
local Const = require("Common.Const.Const")
local AudioConst = require("Const.AudioConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local lume = require("Core.Common.lume")
local LuaUIUtils = require("Utils.LuaUIUtils")
local MessageName = require("Const.MessageName")
local NpcDuelData = require("Data.npc_duel_data")
local NpcDuelStartCtrl = Class.LightClass("NpcDuelStartCtrl", UICtrl)
local PetData = require("Data.pet_data")
local PetManagementDataHelper = require("Utils.PetManagementDataHelper")
local ShowTitleData = require("Data.show_title_data")
local Utils = require("Common.Utils.Utils")
local PetPrototypeData = require("Data.pet_prototype_data")
local ElementNameToId = require("Data.element_name_to_id")
local PetResearchIdToNumber = require("Data.pet_research_id_to_number")
local PlayerBadgeData = require("Data.player_badge_data")
local NpcDuelStartPetDetail = require("Guis.Panels.NpcDuelStart.NpcDuelStartPetDetail")

NpcDuelStartCtrl.MAX_FIGHT_PETS_COUNT = PetManagementDataHelper.MAX_FIGHT_PETS_COUNT
NpcDuelStartCtrl.messages = {
	[MessageName.CUR_COMBAT_PET_CHANGED] = {
		"onPetFormationUpdate",
		true
	},
	[MessageName.FIGHT_GROUP_CHANGE] = {
		"onPetFormationUpdate",
		true
	},
	[MessageName.MODIFY_PET_FORMATION] = {
		"onPetFormationUpdate",
		true
	}
}

function NpcDuelStartCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:closePanel()
	end

	function self.view.btnInfoUButton.luaClick()
		pg.global.ui:open(UIConst.UI_ID_HELP, {
			helpId = self:getHelpId(),
			keepVisibleUIs = {
				[UIConst.UI_ID_NPC_DUEL_START] = true
			}
		})
	end

	function self.view.petManagementUButton.luaClick()
		self.petPreviewUISceneSuspended = true

		self:deactivatePetPreviewUIScene()
		pg.global.ui.petManagement:open({
			isNpcDuelMode = true,
			npcDuelId = self.curNpcDuelId,
			npcDuelVariantId = self.curNpcDuelVariantId
		}, nil, function()
			self.petPreviewUISceneSuspended = false

			self:activatePetPreviewUIScene()
		end, nil, nil, true)
	end

	function self.view.buttonStartUButton.luaClick()
		if not self.canChallenge then
			return
		end

		self:onClickStart()
	end
end

function NpcDuelStartCtrl:checkCommonQuit()
	return self.closePanelCommonDisabled ~= true
end

function NpcDuelStartCtrl:closePanel()
	if self.closing then
		return
	end

	self.closing = true

	if self.view.uIPbBattleRoomMain2UComponent and self.view.uIPbBattleRoomMain2UComponent:CheckHasEvent(CS.XGUI.EInvokeTime.Custom1) then
		self.view.uIPbBattleRoomMain2UComponent:InvokeCallbackWithCallback(CS.XGUI.EInvokeTime.Custom1, function()
			self:close()
		end)
	else
		self:close()
	end
end

function NpcDuelStartCtrl:onClickStart()
	pg.me:startNpcDuel(function()
		self.closePanelCommonDisabled = true

		self.uiScene:playSleAnimation_NPC("NPCDuel_BeforeBattle_R_PrepareToLoading", "NPCDuel_BeforeBattle_R_Loading")
		self.uiScene:playSleAnimation_Player("NPCDuel_BeforeBattle_L_PrepareToLoading", "NPCDuel_BeforeBattle_L_Loading")
		self.view.uIPbBattleRoomMain2UComponent:TryChangePage("Stage", 1)
		pg.game.audio:playEvent("SFX_UI_Npcduel_Battleroom_Start")
		self.uiScene:bgAnimToConfirm()
		self.uiScene:cameraAnimToConfirm()
		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("npcDuel_back", not self.closePanelCommonDisabled)
	end)
end

function NpcDuelStartCtrl:getNpcDuelCfg()
	return NpcDuelData[self.curNpcDuelId] and NpcDuelData[self.curNpcDuelId][self.curNpcDuelVariantId]
end

function NpcDuelStartCtrl:getHelpId()
	local npcDuelData = self:getNpcDuelCfg()

	return npcDuelData and npcDuelData.helpId
end

function NpcDuelStartCtrl:getBgMat()
	local npcDuelData = self:getNpcDuelCfg()

	return npcDuelData and npcDuelData.backgroundMat
end

function NpcDuelStartCtrl:getLoadingTitle()
	local npcDuelData = self:getNpcDuelCfg()

	return npcDuelData and npcDuelData.loadingTitle
end

function NpcDuelStartCtrl:getNpcTitle()
	local npcDuelData = self:getNpcDuelCfg()

	return npcDuelData and npcDuelData.npcTitle
end

function NpcDuelStartCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.firstIned = false
	self.closePanelCommonDisabled = false
	self.showConsoleBar_npcDuel_select = false
	self.closing = false
	self.petPreviewTipsOpenCount = 0
	self.canChallenge = false
	self.curNpcDuelId = pg.me.curNpcDuelId
	self.curNpcDuelVariantId = pg.me.curNpcDuelVariantId

	if self.curNpcDuelId == 0 or self.curNpcDuelVariantId == 0 then
		return
	end

	self.uiScene:previewModel_Left()
	self.uiScene:previewModel_Right()

	if self.playInTimer then
		self:killTimer(self.playInTimer)

		self.playInTimer = nil
	end

	self.uiScene:applyMaterialEffect(self:getBgMat())

	self.playInTimer = self:startTimer(function()
		if pg.game.npcDuel then
			pg.game.npcDuel:npcDuelMaskFadeInStage2()
		end

		self.playInTimer = nil
		self.firstIned = true

		self:playInAnim()
		pg.game.audio:playEvent("SFX_UI_Npcduel_Battleroom_Enter")
		pg.game.audio:playBgm("bgm_battle_pvp_prepare", AudioConst.BgmPriority.Loading)
	end, 1)

	ClientTextUtils.setText(self.view.buttonStartUSDFText, ClientTextUtils.getGameString("NPCDUEL_START"))
	ClientTextUtils.setText(self.view.titleUSDFText, ClientTextUtils.getGameString("NPCDUEL_PREPARE"))
	ClientTextUtils.setText(self.view.textTeamUSDFText, ClientTextUtils.getGameString("NPCDUEL_TEAM"))
	ClientTextUtils.setText(self.view.loadingVenueSubUSDFText, ClientTextUtils.getGameString("NPCDUEL_LOADING"))
	ClientTextUtils.setText(self.view.loadingVenueNameUSDFText, pg.getLocalizationText(self:getLoadingTitle()))

	local cfg = self:getNpcDuelCfg()
	local firstRewardId = cfg and cfg.firstRewardId

	self.view.rewardTransform.gameObject:SetActiveEx(ToBool(firstRewardId))
	LuaUIUtils.setRewardListByDropId(self.view.listRewardUList, firstRewardId, nil, false, false, true)
	self:refreshLeftPlayer()
	self:refreshRightPlayer()
	self:refreshTopRecommendPet()
	self:refreshGroupSelector()
	self:refreshBuff()
	self:refreshPanelTime()
end

function NpcDuelStartCtrl:refreshConsoleBarState()
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("npcDuel_back", not self.closePanelCommonDisabled)
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("npcDuel_select", ToBool(self.showConsoleBar_npcDuel_select))
end

function NpcDuelStartCtrl:setViewVisible(visible)
	NpcDuelStartCtrl.super.setViewVisible(self, visible)

	if not self.firstIned then
		return
	end

	if visible then
		self:refreshLeftPlayer()
		self:refreshTopRecommendPet()
		self.uiScene:bgAnimToClamp()
	end
end

function NpcDuelStartCtrl:onUISceneVisibleChange(visible)
	if visible then
		UICtrl.onUISceneVisibleChange(self, true)
		self:activatePetPreviewUIScene()
	else
		self:deactivatePetPreviewUIScene()
		UICtrl.onUISceneVisibleChange(self, false)
	end
end

function NpcDuelStartCtrl:playInAnim()
	self.uiScene:playSleAnimation_NPC("NPCDuel_BeforeBattle_R_PrepareStart", "NPCDuel_BeforeBattle_R_Prepare")
	self.uiScene:playSleAnimation_Player("NPCDuel_BeforeBattle_L_PrepareStart", "NPCDuel_BeforeBattle_L_Prepare")

	local battleRoomComp = self.view.uIPbBattleRoomMain2UComponent

	if battleRoomComp and battleRoomComp:CheckHasEvent(CS.XGUI.EInvokeTime.Custom2) then
		battleRoomComp:InvokeCallbackWithCallback(CS.XGUI.EInvokeTime.Custom2, function()
			self.canChallenge = true
		end)
	else
		self.canChallenge = true
	end

	self.uiScene:bgAnimToIn()
	self.uiScene:cameraAnimToIn()
end

function NpcDuelStartCtrl:onDestroy()
	if pg.me and pg.me.resetStartNpcDuelRequesting then
		pg.me:resetStartNpcDuelRequesting()
	end

	if pg.me and pg.me.clearNpcDuelPreviewPets then
		pg.me:clearNpcDuelPreviewPets()
	end

	self:destroyPetPreviewUIScene()

	if self.playInTimer then
		self:killTimer(self.playInTimer)

		self.playInTimer = nil
	end

	pg.game.audio:stopBgm(AudioConst.BgmPriority.Loading)
	UICtrl.onDestroy(self)
end

function NpcDuelStartCtrl:ensurePetPreviewUIScene(callback)
	if not self.petPreviewUIScene then
		self.petPreviewUIScene = pg.game.uiScene:getScene(UISceneConst.PET_MANAGEMENT_PREVIEW_SCENE)

		if not self.petPreviewUIScene then
			self.petPreviewUIScene = pg.game.uiScene:getUISceneInst(UISceneConst.PET_MANAGEMENT_PREVIEW_SCENE, AddressDataConst.PET_MANAGEMENT_PREVIEW_SCENE_Prefab)
		end

		self.petPreviewUIScene:bindUICtrlKey(self.module)
	end

	if callback then
		self.petPreviewUISceneCallbacks = self.petPreviewUISceneCallbacks or {}

		table.insert(self.petPreviewUISceneCallbacks, callback)
	end

	if self.petPreviewUIScene:checkLoaded() then
		local scene = self:isPetPreviewUISceneReady() and self.petPreviewUIScene or nil

		if scene then
			self:activatePetPreviewUIScene()
		end

		self:dispatchPetPreviewUISceneCallbacks(scene)

		return self.petPreviewUIScene
	end

	if self.inLoadPetPreviewUIScene then
		return self.petPreviewUIScene
	end

	self.inLoadPetPreviewUIScene = true

	self.petPreviewUIScene:startLoad(function(succeed)
		self.inLoadPetPreviewUIScene = false

		if not succeed or not self.view or not self.petPreviewUIScene then
			self:dispatchPetPreviewUISceneCallbacks(nil)

			return
		end

		local scene = self:isPetPreviewUISceneReady() and self.petPreviewUIScene or nil

		if scene then
			self:activatePetPreviewUIScene()
		end

		self:dispatchPetPreviewUISceneCallbacks(scene)
	end)

	return self.petPreviewUIScene
end

function NpcDuelStartCtrl:isPetPreviewUISceneReady()
	return self.petPreviewUIScene and self.petPreviewUIScene:checkLoaded() and not IsNil(self.petPreviewUIScene.scene)
end

function NpcDuelStartCtrl:activatePetPreviewUIScene()
	if self.petPreviewUISceneSuspended or not self:checkUIVisible() then
		return
	end

	if not self:isPetPreviewUISceneReady() then
		return
	end

	if not self:hasUISceneOwner(UISceneConst.PET_MANAGEMENT_PREVIEW_SCENE, self.module) then
		pg.game.uiScene:switchToScene(UISceneConst.PET_MANAGEMENT_PREVIEW_SCENE, true, true, true, self.module)
	end

	if self.petPreviewUIScene.setLocalEnv then
		self.petPreviewUIScene:setLocalEnv()
	end

	self:syncPetPreviewCameraState()
end

function NpcDuelStartCtrl:deactivatePetPreviewUIScene()
	if not self:isPetPreviewUISceneReady() then
		return
	end

	if not self:hasUISceneOwner(UISceneConst.PET_MANAGEMENT_PREVIEW_SCENE, self.module) then
		return
	end

	pg.game.uiScene:switchOutScene(UISceneConst.PET_MANAGEMENT_PREVIEW_SCENE, true, nil, self.module)
end

function NpcDuelStartCtrl:dispatchPetPreviewUISceneCallbacks(scene)
	local callbacks = self.petPreviewUISceneCallbacks

	self.petPreviewUISceneCallbacks = nil

	if not callbacks then
		return
	end

	for _, callback in ipairs(callbacks) do
		callback(scene)
	end
end

function NpcDuelStartCtrl:destroyPetPreviewUIScene()
	self.petPreviewUISceneCallbacks = nil
	self.inLoadPetPreviewUIScene = false

	if not self.petPreviewUIScene then
		return
	end

	self.petPreviewUIScene:removeUICtrlKey(self.module)
	pg.game.uiScene:switchOutScene(UISceneConst.PET_MANAGEMENT_PREVIEW_SCENE, self.petPreviewUIScene:checkHasUICtrlBind(), nil, self.module)

	self.petPreviewUIScene = nil
end

function NpcDuelStartCtrl:refreshTopRecommendPet()
	local objectReference = self.view.titleTowerObjectReference
	local textLvUBaseText = objectReference:GetRefValue("textLvUBaseText")
	local listRoundUList = objectReference:GetRefValue("listRoundUList")
	local titleTowerUComponent = objectReference:GetRefValue("titleTowerUComponent")
	local textRecommendUBaseText = objectReference:GetRefValue("textRecommendUBaseText")

	ClientTextUtils.setText(textRecommendUBaseText, ClientTextUtils.getGameString("NPCDUEL_RECOMMEND") .. ":")

	local npcDuelData = self:getNpcDuelCfg()

	if npcDuelData then
		local recommendedLevel = pg.game.npcDuel:getNpcDuelLevelByDuelId(self.curNpcDuelId, self.curNpcDuelVariantId)

		ClientTextUtils.setText(textLvUBaseText, string.format("lv.%s", recommendedLevel))

		function listRoundUList.luaRenderItem(button, index, data)
			self:renderElementButton(button, data)
		end

		local elements = {}

		for _, v in pairs(npcDuelData.recommendedElements or EMPTY_TABLE) do
			table.insert(elements, {
				element = v
			})
		end

		listRoundUList:SetList(elements)
		titleTowerUComponent:TryChangePage("TextState", self:getIsRecommendLv() and 0 or 1)
	end
end

function NpcDuelStartCtrl:getIsRecommendLv()
	local recommendedLevel = pg.game.npcDuel:getNpcDuelLevelByDuelId(self.curNpcDuelId, self.curNpcDuelVariantId)

	if not recommendedLevel then
		return true
	end

	local player = pg.me
	local prepare = player and player.prepareFormationList and player.prepareFormationList[player.curPetFormationIndex]

	if not prepare or not prepare.formation then
		return false
	end

	local totalLevel, petCount = 0, 0

	for _, petId in ipairs(prepare.formation) do
		local pet = player:getPetInfo(petId)

		if pet then
			petCount = petCount + 1
			totalLevel = totalLevel + (pet.level or 0)
		end
	end

	return petCount > 0 and recommendedLevel <= totalLevel / petCount or false
end

function NpcDuelStartCtrl:renderElementButton(button, data)
	button:TryChangePage("type", data.element)
end

function NpcDuelStartCtrl:IsRecommendElement(elementName)
	local npcDuelData = self:getNpcDuelCfg()

	if not npcDuelData then
		return false
	end

	return ToBool(lume.findInList(npcDuelData.recommendedElements, elementName))
end

function NpcDuelStartCtrl:refreshLeftPlayer()
	ClientTextUtils.setText(self.view.left.textPlayerNameUSDFText, pg.me.playerName)
	ClientTextUtils.setText(self.view.left.textPlayerNameSmallTextPlus, pg.me.playerName)

	local petFormation = self.model:getCurPetFormation()

	function self.view.listLeftUList.luaRenderItem(button, index, data)
		button.draggable = false

		if data.tIndex ~= 1 then
			self:renderPetItem(button, index, data, true)
		end
	end

	self.view.listLeftUList:SetList(petFormation.petsData)

	local objectReference = self.view.left.nationLevelObjectReference:GetComponent("ObjectReference")
	local bgUImage = objectReference:GetRefValue("bgUImage")
	local numUSDFText = objectReference:GetRefValue("numUSDFText")

	ClientTextUtils.setText(numUSDFText, LuaUIUtils.getStarTitleNameForIcon(pg.me.starTitle))

	bgUImage.url = LuaUIUtils.getStarIcon(pg.me.starTitle)

	local fullStarName = LuaUIUtils.getStarTitleName(pg.me.starTitle, true)

	ClientTextUtils.setText(self.view.left.textTagUSDFText, fullStarName)
end

function NpcDuelStartCtrl:refreshRightPlayer()
	local botName = pg.me:getCurNpcDuelBotName()

	ClientTextUtils.setText(self.view.right.textPlayerNameUSDFText, botName)
	ClientTextUtils.setText(self.view.right.textPlayerNameSmallTextPlus, botName)
	ClientTextUtils.setText(self.view.right.textTagUSDFText, pg.getLocalizationText(self:getNpcTitle()))

	local pets = pg.me.npcDuelBotInfo.petList
	local petsData = {}

	for i = 1, NpcDuelStartCtrl.MAX_FIGHT_PETS_COUNT do
		local pet = pets[i]

		if pet then
			local data = PetData[pet.templateId]

			table.insert(petsData, {
				tIndex = 0,
				petInfo = pet,
				petData = data
			})
		else
			table.insert(petsData, {
				tIndex = 1
			})
		end
	end

	function self.view.listRightUList.luaRenderItem(button, index, data)
		button.interactable = false
		button.draggable = false

		if data.tIndex == 0 then
			self:renderNpcPetItem(button, index, data)
		end
	end

	self.view.listRightUList:SetList(petsData)

	local objectReference = self.view.right.nationLevelObjectReference:GetComponent("ObjectReference")
	local bgUImage = objectReference:GetRefValue("bgUImage")
	local numUSDFText = objectReference:GetRefValue("numUSDFText")
	local npcDuelData = self:getNpcDuelCfg()

	if npcDuelData then
		local badgeId = npcDuelData.badgeId
		local badgeData = badgeId and PlayerBadgeData[badgeId]

		if badgeData then
			bgUImage.url = badgeData.icon

			ClientTextUtils.setText(numUSDFText, "")
		else
			local titleId = npcDuelData.titleId

			if titleId then
				bgUImage.url = LuaUIUtils.getStarIcon(titleId)

				ClientTextUtils.setText(numUSDFText, LuaUIUtils.getStarTitleNameForIcon(titleId))
			end
		end
	end
end

function NpcDuelStartCtrl:ensurePetInfoDefaults(petInfo)
	petInfo.pageIndex = petInfo.pageIndex or 0
	petInfo.ratingString = petInfo.ratingString or "INTERFACE_DISPLAY_RATING_1"
	petInfo.controlFeatureId = petInfo.controlFeatureId or 0
	petInfo.breedTalent = petInfo.breedTalent or {}
	petInfo.bookNum = petInfo.bookNum or 0
	petInfo.time = petInfo.time or 0

	if not petInfo.basePropertyList then
		petInfo.basePropertyList = {}

		for i = 1, Const.BASE_PROPERTY_CNT do
			petInfo.basePropertyList[i] = {
				iLvLn = 0,
				indLv = 0
			}
		end
	end

	return petInfo
end

function NpcDuelStartCtrl:setPetPreviewTipsOpen(open)
	local count = self.petPreviewTipsOpenCount or 0

	if open then
		count = count + 1
	else
		count = count - 1
	end

	if count < 0 then
		count = 0
	end

	self.petPreviewTipsOpenCount = count

	self:syncPetPreviewCameraState()
end

function NpcDuelStartCtrl:syncPetPreviewCameraState()
	if not self:isPetPreviewUISceneReady() then
		return
	end

	if not self.petPreviewUIScene.enableCamera then
		return
	end

	local enable = (self.petPreviewTipsOpenCount or 0) > 0

	self.petPreviewUIScene:enableCamera(enable)
end

function NpcDuelStartCtrl:setPetInfoTooltip(button, getPetInfoFunc, isPlayer)
	button.tooltipTemplateUrl = "$UI_Pop_PetInfo_Tips.prefab"

	button:SetPopupValidateTouch(function()
		local petGiftTips = pg.global.ui.petGiftTips

		return not petGiftTips or not petGiftTips:checkUIVisible()
	end)

	if isPlayer then
		button:SetVerticalAlignment(CS.XGUI.EVerticalAlignment.Bottom)
		button:SetPopupDirection(CS.XGUI.EPopupDirection.Right)
	else
		button:SetVerticalAlignment(CS.XGUI.EVerticalAlignment.Bottom)
		button:SetPopupDirection(CS.XGUI.EPopupDirection.Left)
	end

	function button.luaRenderTooltip(_, popup)
		self:renderPetInfoCard(self:ensurePetInfoDefaults(getPetInfoFunc()), popup)
	end

	function button.luaTooltipPopup(_, flag)
		self:setPetPreviewTipsOpen(ToBool(flag))

		if not flag and pg.global.ui:checkUIOpen(UIConst.UI_ID_PET_GIFT_TIPS) then
			pg.global.ui:close(UIConst.UI_ID_PET_GIFT_TIPS)
		end
	end
end

function NpcDuelStartCtrl:renderNpcPetItem(button, index, data)
	local petData = data.petData
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local panelCPUContainer = objectReference:GetRefValue("panelCPUContainer")
	local previewPetInfo = pg.me:getNpcDuelPreviewBotPetInfo(index + 1)
	local label = previewPetInfo and previewPetInfo.label or data.petInfo.label
	local gender = previewPetInfo and previewPetInfo.gender or data.petInfo.gender
	local level = previewPetInfo and previewPetInfo.level or data.petInfo.level

	iconUImage.url = LuaUIUtils.getPetIcon(petData.iconName, LuaUIUtils.PET_ICON, label, gender)

	button:TryChangePage("Type", Utils.isLabelShiny(label) and 1 or 0)

	local prototypeData = PetPrototypeData[data.petInfo.templateId]
	local elementType = prototypeData.elementType or {}
	local _, elementNames = LuaUIUtils.getElementInfo(petData.elementType, ElementNameToId[elementType[1]])

	self:setElements(panelCPUContainer, level, elementNames)
	self:setPetInfoTooltip(button, function()
		return PetManagementDataHelper.setUpPetInfo(previewPetInfo)
	end, false)
end

function NpcDuelStartCtrl:renderPetItem(button, index, data, isPlayer)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local panelCPUContainer = objectReference:GetRefValue("panelCPUContainer")
	local recommendTransform = objectReference:GetRefValue("recommendTransform")

	iconUImage.url = LuaUIUtils.getPetIcon(data.iconName, LuaUIUtils.PET_ICON, data.label, data.gender)

	local pet = pg.me:getPetInfo(data.id)
	local level = pet and pet.level or 0

	self:setElements(panelCPUContainer, level, data.elementNames)
	self:refreshHeadRecommendElement(recommendTransform, data.elementNames)
	button:TryChangePage("Type", Utils.isLabelShiny(data.label) and 1 or 0)
	self:setPetInfoTooltip(button, function()
		local petInfo = PetManagementDataHelper.setUpPetInfo(pet)

		return petInfo
	end, isPlayer)
end

function NpcDuelStartCtrl:setElements(panelCPUContainer, level, elementNames)
	panelCPUContainer:LoadDefaultUrlManually()

	local objectReference1 = panelCPUContainer.content:GetComponent("ObjectReference")
	local numCPUText = objectReference1:GetRefValue("numCPUSDFText")
	local singleElement = objectReference1:GetRefValue("singleElement")
	local doubleElement1 = objectReference1:GetRefValue("doubleElement1")
	local doubleElement2 = objectReference1:GetRefValue("doubleElement2")

	ClientTextUtils.setText(numCPUText, string.format("Lv.%s", level))

	if #elementNames <= 0 then
		panelCPUContainer.content.gameObject:SetActiveEx(false)
	elseif #elementNames == 1 then
		panelCPUContainer.content.gameObject:SetActiveEx(true)
		panelCPUContainer.content:TryChangePage("DetailState", 0)

		local element1 = elementNames[1].element

		LuaUIUtils.setElementButtonNew(singleElement, element1)
	else
		panelCPUContainer.content.gameObject:SetActiveEx(true)
		panelCPUContainer.content:TryChangePage("DetailState", 1)

		local element1 = elementNames[1].element
		local element2 = elementNames[2].element

		LuaUIUtils.setElementButtonNew(doubleElement1, element1)
		LuaUIUtils.setElementButtonNew(doubleElement2, element2)
	end
end

function NpcDuelStartCtrl:renderPetInfoCard(petData, component)
	NpcDuelStartPetDetail.new(component, petData, self)
end

function NpcDuelStartCtrl:refreshHeadRecommendElement(recommendTransform, elementNames)
	if #elementNames <= 0 then
		recommendTransform.gameObject:SetActiveEx(false)
	elseif #elementNames == 1 then
		local element1 = elementNames[1].element

		recommendTransform.gameObject:SetActiveEx(self:IsRecommendElement(element1))
	else
		local element1 = elementNames[1].element
		local element2 = elementNames[2].element
		local showRec = self:IsRecommendElement(element1) and self:IsRecommendElement(element2)

		recommendTransform.gameObject:SetActiveEx(showRec)
	end
end

function NpcDuelStartCtrl:onPetFormationUpdate()
	self:refreshLeftPlayer()
	self:refreshGroupSelector()
	self:refreshTopRecommendPet()
end

function NpcDuelStartCtrl:getCurGroupNameContent()
	local groupData = self.model:getGroupNameInfo(pg.me.curPetFormationIndex)

	if groupData.customName and groupData.customName ~= "" then
		return groupData.customName
	end

	return pg.getGameString("DEFAULT_GROUP_NAME") .. " " .. groupData.idx
end

function NpcDuelStartCtrl:refreshCurGroupName()
	local objectReference = self.view.btnSwitchUSelector:GetComponent("ObjectReference")

	if IsNil(objectReference) then
		return
	end

	local groupNameContent = self:getCurGroupNameContent()
	local groupName = objectReference:GetRefValue("groupName")
	local txtNameUText = objectReference:GetRefValue("txtNameUText")

	if not IsNil(groupName) then
		ClientTextUtils.setText(groupName, groupNameContent)
	end

	if not IsNil(txtNameUText) then
		ClientTextUtils.setText(txtNameUText, groupNameContent)
	end
end

function NpcDuelStartCtrl:refreshGroupSelector()
	self:refreshCurGroupName()

	function self.view.btnSwitchUSelector.luaRenderPopup(_, list)
		local groupInfos = self.model:getGroupInfos()

		lume.reverseInPlace(groupInfos)

		local groupId = pg.me.curPetFormationIndex
		local selectGroupId = pg.me.curPetFormationIndex

		function list.luaRenderItem(button, _, data)
			local formationIndex = data.idx

			button.name = formationIndex

			local objRef = button:GetComponent("ObjectReference")
			local nameUText = objRef:GetRefValue("nameUText")
			local numCPUText = objRef:GetRefValue("numCPUText")
			local btnRenameUButton = objRef:GetRefValue("btnRenameUButton")
			local listUList = objRef:GetRefValue("listUList")

			if not IsNil(btnRenameUButton) then
				btnRenameUButton.gameObject:SetActiveEx(false)
			end

			local groupData = self.model:getGroupNameInfo(formationIndex)

			if groupData.customName and groupData.customName ~= "" then
				ClientTextUtils.setText(nameUText, groupData.customName)
			else
				ClientTextUtils.setText(nameUText, pg.getGameString("DEFAULT_GROUP_NAME"), " ", groupData.idx)
			end

			local totalCp = 0

			for i = 1, #groupData.pets do
				totalCp = totalCp + groupData.pets[i].cp
			end

			ClientTextUtils.setText(numCPUText, "CP: ", totalCp)

			local tCount = lume.count(groupData.pets)

			if tCount < self.MAX_FIGHT_PETS_COUNT then
				for _ = 1, self.MAX_FIGHT_PETS_COUNT - tCount do
					local t = {}

					t.empty = true
					groupData.pets[#groupData.pets + 1] = t
				end
			end

			function listUList.luaRenderItem(button1, index1, data)
				local objectReference = button1:GetComponent("ObjectReference")
				local iconUImage = objectReference:GetRefValue("iconUImage")
				local recommendRectTransform = objectReference:GetRefValue("recommendRectTransform")
				local pet = pg.me:getPetInfo(data.id)

				button1.draggable = false
				button1.navForceNonInteractable = true

				if data.empty then
					button1:TryChangePage("state", 2)
					LuaUIUtils.renderPetHeadFlashBgAndFrame(objectReference, false)
				else
					button1:TryChangePage("state", 0)

					local shinyStyle = data.shinyStyle or pet and pet.shinyStyle or 0

					LuaUIUtils.renderPetHeadFlashBgAndFrame(objectReference, data.isShiny, shinyStyle)

					local pData = PetData[pet.templateId] or {}
					local _, elementNames = LuaUIUtils.getElementInfo(pData.elementType)

					self:refreshHeadRecommendElement(recommendRectTransform, elementNames)
					iconUImage:SetUrlWithCallback(LuaUIUtils.getPetIcon(data.iconName, LuaUIUtils.PET_ICON, data.label, data.gender), function()
						return
					end)
				end
			end

			listUList:SetList(groupData.pets)

			function button.luaClick()
				self:switchGroupToIdx(formationIndex)
			end
		end

		function list.luaFinishRender(subList)
			local btns = subList:GetAllButtons()

			for i = 0, btns.Length - 1 do
				local btn = btns[i]
				local selectBtnName = tostring(selectGroupId)

				btn:TryChangePage("select", btn.name == selectBtnName and 1 or 0)
				btn:TryChangePage("inUse", btn.name == selectBtnName and 1 or 0)

				local groupData = self.model:getGroupNameInfo(ToInt(btn.name))

				btn:TryChangePage("State", #groupData.pets <= 0 and 1 or 0)

				if btn.name == selectBtnName then
					subList:SelectItem(i)

					local gotoIndex = i - 2

					if gotoIndex < 0 then
						gotoIndex = 0
					end

					subList:GoToItem(btns[gotoIndex], true)

					if pg.game.input:isUsingGamepad() then
						CS.XGUI.Navigation.NavManager.Instance:FocusItem(btns[i])
					end
				end
			end
		end

		list:SetList(groupInfos)
	end

	function self.view.btnSwitchUSelector.luaOnPopupChanged(bol)
		if bol then
			local popup = self.view.btnSwitchUSelector:GetPopupInstance()
			local objRef = popup:GetComponent("ObjectReference")
			local mainUComponent = objRef:GetRefValue("mainUComponent")

			mainUComponent:TryChangePage("UnfoldSet", "Down")
		end

		self.view.blackMaskTransform.gameObject:SetActiveEx(bol)

		self.showConsoleBar_npcDuel_select = bol

		CS.XGUI.Navigation.ConsoleBar.SetStateForAll("npcDuel_select", bol)
	end
end

function NpcDuelStartCtrl:switchGroupToIdx(formationIndex)
	pg.me:serverMsg("RPC_CS_SelectPrepareFormation", formationIndex)
end

function NpcDuelStartCtrl:refreshBuff()
	local buffInfo = pg.me:getCurBuffInfo()

	if next(buffInfo) then
		self.view.spaceBuffObjectReference.gameObject:SetActiveEx(true)

		self.view.buffIconUImage.url = buffInfo.buffIcon
		self.view.buffNameUSDFText.text = buffInfo.buffName

		ClientTextUtils.setText(self.view.buffNameUSDFText, buffInfo.buffName)

		function self.view.buffSkillUButton.luaRenderTooltip(button, toolTip)
			self:RenderBuffPopup(toolTip)
		end
	else
		self.view.spaceBuffObjectReference.gameObject:SetActiveEx(false)
	end
end

function NpcDuelStartCtrl:RenderBuffPopup(toolTip)
	local objectReference = toolTip:GetComponent("ObjectReference")
	local rootCmp = objectReference:GetRefValue("rootCmp")
	local buffNameUText = objectReference:GetRefValue("buffNameUText")
	local buffDetailUText = objectReference:GetRefValue("buffDetailUText")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local buffInfo = pg.me:getCurBuffInfo()

	if next(buffInfo) then
		rootCmp:TryChangePage("InfoState", "Icon")
		ClientTextUtils.setText(buffNameUText, buffInfo.buffName)
		ClientTextUtils.setText(buffDetailUText, buffInfo.buffDesc)

		iconUImage.url = buffInfo.buffIcon
	end
end

function NpcDuelStartCtrl:refreshPanelTime()
	local npcDuelData = self:getNpcDuelCfg()

	if not npcDuelData then
		return
	end

	local time = npcDuelData.maxDuration

	if time then
		ClientTextUtils.setText(self.view.txtTimeUSDFText, LuaUIUtils.getCountDownFormateText(time, false))
		ClientTextUtils.setText(self.view.txtTitle1USDFText, pg.getGameString("NPCDUEL_BATTLE_MAX_DURATION"))
	else
		ClientTextUtils.setText(self.view.txtTimeUSDFText, "")
		ClientTextUtils.setText(self.view.txtTitle1USDFText, "")
	end

	local winConditionDesc = pg.me:getNpcDuelWinCondDesc()

	if not string.isNilOrEmpty(winConditionDesc) then
		ClientTextUtils.setText(self.view.txtSubUSDFText, pg.getLocalizationText(winConditionDesc))
		ClientTextUtils.setText(self.view.txtTitle2USDFText, pg.getGameString("NPCDUEL_BATTLE_WIN_CONDITION"))
	else
		self.txtTitle2USDFText = ""
		self.txtSubUSDFText = ""

		ClientTextUtils.setText(self.view.txtSubUSDFText, "")
		ClientTextUtils.setText(self.view.txtTitle2USDFText, "")
	end
end

return NpcDuelStartCtrl
