-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetTrainingNew\\PetTrainingNewCtrl.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local MessageName = require("Const.MessageName")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("PetTrainingNewCtrl")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local NewSkillComponent = require("Guis.Panels.PetTrainingNew.Component.NewSkillComponent")
local TrainingComponent = require("Guis.Panels.PetTrainingNew.Component.TrainingComponent")
local NewTrainingComponent2 = require("Guis.Panels.PetTrainingNew.Component.NewTrainingComponent2")
local StarUpComponent = require("Guis.Panels.PetTrainingNew.Component.StarUpComponent")
local CarryComponent = require("Guis.Panels.PetTrainingNew.Component.CarryComponent")
local NoticeDef = require("Common.NoticeDef")
local PetEvolveData = require("Data.pet_evolve_data")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local Lume = require("Core.Common.lume")
local SysConfigData = require("Data.sys_config_data")
local HotkeyConst = require("Const.HotkeyConst")
local AddressDataConst = require("Const.AddressDataConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientConst = require("Const.ClientConst")
local Const = require("Const.Const")
local TimerManager = require("Core.Timer.TimerManager")
local PetTrainingNewCtrl = Class.LightClass("PetTrainingNewCtrl", UICtrl)
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientUtils = require("Utils.ClientUtils")
local RogueUtils = require("Utils.RogueUtils")
local PetManagementUtils = require("Utils.PetManagementUtils")
local CallbackHandler = require("Core.Common.CallbackHandler")
local UI_SELECT_MODEL = AddressDataConst.UI_SELECT_MODEL
local UI_SELECT_MODEL_2 = AddressDataConst.UI_SELECT_MODEL_2

PetTrainingNewCtrl.messages = {
	[MessageName.PET_CUSTOM_NAME_CHANGED] = {
		"onPetCustomNameChanged",
		true
	},
	[MessageName.PET_FAVORITE_CHANGE] = {
		"onPetFavoriteChanged",
		true
	},
	[MessageName.PET_FAVORITE_TYPE_CHANGE] = {
		"onPetFavoriteTypeChanged",
		true
	},
	[MessageName.PLAYER_PET_CUR_ABILITY_CHANGED] = {
		"onPetCurAbilityChanged",
		true
	},
	[MessageName.PET_LEVEL_CHANGED] = {
		"onPetLevelChanged",
		true
	},
	[MessageName.CARRY_EQUIP] = {
		"event_CarryEquipped",
		true
	},
	[MessageName.CARRY_UNLOAD] = {
		"event_CarryUnload",
		true
	},
	[MessageName.CARRY_ASSIST_CHANGE] = {
		"event_CarryAssistChanged",
		true
	},
	[MessageName.ITEM_GEN_COUNT_CHANGE] = {
		"event_ItemGenCountChange",
		true
	},
	[MessageName.PET_NEW_PROP_CHANGE] = {
		"onPetNewPropChange",
		true
	},
	[MessageName.PET_RESONANCE_CHANGE] = {
		"onPetResonanceChange",
		true
	},
	[MessageName.PET_RESONANCE_CHANGE_DEBUG] = {
		"onPetResonanceChangeDebug",
		true
	},
	[MessageName.PET_SKILL_GLAZE_SUCCESS] = {
		"onPetSkillGlazeSuccess",
		true
	},
	[MessageName.PET_PROP_LEARN_CHANGE] = {
		"onPetPropLearnChange",
		true
	},
	[MessageName.CARRY_UPGRADE] = {
		"event_CarryUpgrade",
		true
	},
	[MessageName.CARRY_CERTIFY] = {
		"event_CarryCertify",
		true
	},
	[MessageName.CARRY_CERTIFY_ANIMATION] = {
		"event_CarryCertifyAnimation",
		true
	},
	[MessageName.PET_CARRY_BATCH_EQUIP_SUCCESS] = {
		"onPetCarryBatchEquipSuccess",
		true
	}
}

function PetTrainingNewCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
	pg.game.camera:setWorldCameraEnable(false, ClientConst.CameraDisableReason.Evolution)
	self:loadNewSkillComp()
	self:loadNewTrainCmp()

	self.carryComponent = CarryComponent.new(self, self.view.carryUComponent)

	if self.view.starUpUComponent:CheckURLLoaded() then
		self.starUpComponent = StarUpComponent.new(self, self.view.starUpUComponent)
	else
		self.view.starUpUComponent:LoadDefaultUrlManually(function(content)
			self.starUpComponent = StarUpComponent.new(self, self.view.starUpUComponent)
		end)
	end

	self.CMP_ARRAY = {
		[Const.PetCulPages.SKILL] = self.newSkillComponent,
		[Const.PetCulPages.TALENT] = self.newTrainingComponent,
		[Const.PetCulPages.CARRY] = self.carryComponent,
		[Const.PetCulPages.STARUP] = self.starUpComponent
	}
	self.SELECTED_CMP = {}
	self.oldUISceneName = UISceneConst.PET_MANAGEMENT_TRAINING_SCENE
	self.newUISceneName = UISceneConst.PET_MANAGEMENT_TRAINING_SCENE2
end

function PetTrainingNewCtrl:setPetModelActive(bool)
	if self.uiScene and self.uiScene.setPetRootActive then
		self.uiScene:setPetRootActive(bool)
	end
end

function PetTrainingNewCtrl:loadNewTrainCmp(callback)
	local function registerNewTrainCmp(mCallback)
		self.newTrainingComponent = NewTrainingComponent2.new(self, self.view.newTalentUComponent)

		if mCallback then
			mCallback()
		end
	end

	if self.view.newTalentUComponent:CheckURLLoaded() then
		registerNewTrainCmp(callback)
	else
		self.view.newTalentUComponent:LoadDefaultUrlManually(function(content)
			registerNewTrainCmp(callback)
		end)
	end
end

function PetTrainingNewCtrl:loadNewSkillComp(callback)
	local function registerNewSkillComp(mCallback)
		self.newSkillComponent = NewSkillComponent.new(self, self.view.newSkillPanelUComponent.content, {
			imgPetUImage = self.view.imgPetUImage
		})

		if self.pendingCarryCertifyMsg then
			local msg = self.pendingCarryCertifyMsg

			self.pendingCarryCertifyMsg = nil

			self:refreshCoreCarryCertifySkillInfo(msg)
		end

		if mCallback then
			mCallback()
		end
	end

	if self.view.newSkillPanelUComponent:CheckURLLoaded() then
		registerNewSkillComp(callback)
	else
		self.view.newSkillPanelUComponent:LoadDefaultUrlManually(function(content)
			registerNewSkillComp(callback)
		end)
	end
end

function PetTrainingNewCtrl:onDestroy()
	pg.global.navMgr:RemoveLuaBeforeDragBeginListener("PetTrainingNewCtrl")
	pg.global.navMgr:RemoveLuaDragEndListener("PetTrainingNewCtrl")
	pg.global.navMgr:RemoveLuaDragBeginListener("PetTrainingNewCtrl")
	pg.game.camera:setWorldCameraEnable(true, ClientConst.CameraDisableReason.Evolution)
	UICtrl.onDestroy(self)

	if NotNil(self.talentCamera) then
		GameObject.Destroy(self.talentCamera)

		self.talentCamera = nil
	end

	if NotNil(self.finalCamera) then
		GameObject.Destroy(self.finalCamera)

		self.finalCamera = nil
	end

	if self.openInfo.pvpFailMode or self.openInfo.onlyShowSkillPage then
		return
	end

	pg.game.uiScene:switchOutScene(UISceneConst.PET_MANAGEMENT_TRAINING_SCENE)
end

function PetTrainingNewCtrl:addListener()
	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.root.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:closePanel()
		end
	end

	function self.view.btnBackUButton.luaClick()
		self:closePanel()
	end

	function self.view.tabList.luaRenderItem(button, index, data)
		self:onRenderTabItem(button, data)
	end

	function self.view.tabList.luaSelectedChanged(uList, select)
		if not select then
			return
		end

		self:onTabSelectChanged(uList)
	end

	function self.view.petManage.luaClick()
		self:onSelectSingle()
	end

	function self.view.tabPetList.luaRenderItem(button, index, data)
		self:onRenderTabPetItem(button, data)
	end

	function self.view.tabPetList.luaCheckCanSelected(data)
		return self:onTabCheckCanSelect(data)
	end

	function self.view.tabPetList.luaSelectedChanged(uList, select)
		if not select then
			return
		end

		self:onTabPetSelectChanged(uList)
		pg.global.navMgr:RefreshFocus(true, CS.XGUI.Navigation.FocusEntryMode.Default)
	end

	function self.view.btnPetBox.luaClick()
		self:onBtnTabPetBox()
	end

	self:bindHotKeyPerform("Raw/GamepadButtonSouth", function()
		if pg.global.navMgr.CurrentFocusedGroupName == "JewelList" then
			local focused = pg.global.navMgr:FocusGroupByName("ListProps", false)

			if not focused then
				return true
			end
		else
			return true
		end
	end, self.view.gameObject)
	self:bindHotKeyPerform("Raw/GamepadButtonEast", function()
		if self.oldTab == Const.PetCulPages.CARRY and self.carryComponent and self.carryComponent:isCompareOpen() then
			self.carryComponent:onBtnCompare()

			return false
		end

		if pg.global.navMgr.CurrentFocusedGroupName == "ListProps" and self.carryComponent and self.carryComponent:isAssistTabSelected() then
			local focused = pg.global.navMgr:FocusGroupByName("JewelList", false)

			if not focused then
				return true
			end
		else
			return true
		end
	end, self.view.gameObject)
	self:addNavFocusListener(CallbackHandler(self, "onNavFocusChange"))
	pg.global.navMgr:AddLuaBeforeDragBeginListener("PetTrainingNewCtrl", function()
		pg.global.navMgr.IsOffsetOverride = true
		pg.global.navMgr.OffsetOverrideValue = Vector2(-0.7, 0.7)
	end)
	pg.global.navMgr:AddLuaDragBeginListener("PetTrainingNewCtrl", function()
		pg.global.inputMgr:OnGamepadLeftStickMoveSimulate(2)
	end)
	pg.global.navMgr:AddLuaDragEndListener("PetTrainingNewCtrl", function()
		pg.global.navMgr.IsOffsetOverride = false

		self:refreshConsoleBarState()
	end)
end

function PetTrainingNewCtrl:onBtnTabPetBox()
	pg.global.ui:open(UIConst.UI_ID_PET_SELECT_BOX, {
		confirmCallback = function(petId)
			self.openInfo.petId = petId

			self:onOpen(self.openInfo)
			self:selectPetTabView()
		end
	})
end

function PetTrainingNewCtrl:onNavFocusChange()
	self:refreshCenterExchangeState()
	self:refreshConsoleBarState()
end

function PetTrainingNewCtrl:refreshConsoleBarState()
	if pg.global.navMgr then
		local groupName = pg.global.navMgr.CurrentFocusedGroupName
		local ItemName = pg.global.navMgr.CurrentFocusedUContent and pg.global.navMgr.CurrentFocusedUContent.name
		local inLeftBottomItem = groupName == "Requirement" or groupName == "Consume"
		local inCenter = groupName == "Center"
		local inDropdownBar = groupName == "DropdownBar"
		local inJewelList = groupName == "JewelList"
		local inRightPanel = groupName == "RightPanel" or groupName == "Panel"
		local inListSkill = groupName == "ListSkill"
		local inSkillChange = groupName == "SkillChange"
		local inDragging = pg.global.navMgr.IsDragging
		local rootComponent = self.carryComponent and self.carryComponent.rootComponent
		local page = 0
		local _

		if rootComponent ~= nil then
			_, page = rootComponent:TryGetCurrentPage("Empty")
		end

		local inLeftAndCanSelect = groupName == "ListProps" and not self.carryComponent:isAssistTabSelected() and page == 2

		pg.global.navMgr:SetConsoleBarState("Cultivate_InLeftBottomItem", inLeftBottomItem)
		pg.global.navMgr:SetConsoleBarState("Cultivate_InCenter", inCenter)
		pg.global.navMgr:SetConsoleBarState("Cultivate_InDropdownBar", inDropdownBar)
		pg.global.navMgr:SetConsoleBarState("Cultivate_InLeftAndCanSelect", inLeftAndCanSelect)
		pg.global.navMgr:SetConsoleBarState("Cultivate_InJewelList", inJewelList)
		pg.global.navMgr:SetConsoleBarState("Cultivate_InRightPanel", inRightPanel)
		pg.global.navMgr:SetConsoleBarState("Cultivate_InListSkill", inListSkill)
		pg.global.navMgr:SetConsoleBarState("Cultivate_InSkillChange", inSkillChange)
		pg.global.navMgr:SetConsoleBarState("Cultivate_InDragging", inDragging)
		pg.global.navMgr:SetConsoleBarState("Cultivate_NotInDragging", not inDragging)
	end
end

function PetTrainingNewCtrl:onSkillCompDragStateChanged()
	self:refreshConsoleBarState()
end

function PetTrainingNewCtrl:refreshCenterExchangeState()
	if pg.global.navMgr.CurrentFocusedGroupName == "ListProps" and self.carryComponent and self.carryComponent:isAssistTabSelected() then
		if self.view and self.view.centerTabUWidget then
			self.view.centerTabUWidget:SetSimulateBtnSwitchForceHidden(true)
		end
	elseif self.view and self.view.centerTabUWidget then
		self.view.centerTabUWidget:SetSimulateBtnSwitchForceHidden(false)
	end
end

function PetTrainingNewCtrl:onPetLevelChanged(info)
	local cmp = self:getCmpByTab(self.oldTab)

	if cmp and cmp.refreshOnLevelChanged then
		cmp:refreshOnLevelChanged(info)
	end
end

function PetTrainingNewCtrl:onOpen(info)
	self:resetOpenInfo(info)
	self:resetTabListView()
	self:initTabLeftPetInfo(info)
end

function PetTrainingNewCtrl:resetOpenInfo(info)
	self.model.IS_PVP_FAIL_MODE = info.pvpFailMode
	self.openInfo = info
	self.petId = info and info.petId

	if not self.petId then
		local preparePetLsit = pg.me and pg.me.petPrepareList or {}

		for _, mPetId in pairs(preparePetLsit or EMPTY_TABLE) do
			if mPetId then
				self.petId = mPetId
				info.petId = mPetId

				break
			end
		end

		if not self.petId then
			if LoggerManager.checkLogger(LoggerConst.WARN) then
				logger:warn("PetTrainingNewCtrl: 宠物养成子界面组件[%s]由于没有准备好的宠物无法打开")
			end

			self:closePanel()

			return
		end
	end

	self.model:setCurPetId(self.petId)

	self.petInfo = pg.me:getPetInfo(self.petId) or {}
	self.canEvolve = nil
	self.notPetManagement = info.notPetManagement

	self:checkPageStatus(info.onlyShowSkillPage)
	self:getTabListData()

	local safeIndex, safeTabName = self:safeGetDisplayTabIndexAndName(info.toPage)

	self.openInfo.toPage = safeTabName
end

function PetTrainingNewCtrl:getTabListData()
	local sLimitTabs

	if self.openInfo.onlyShowSkillPage then
		sLimitTabs = {
			[Const.PetCulPages.SKILL] = true
		}
	end

	local tabList = self.model:getTabList(sLimitTabs, self.canEvolve)

	return tabList
end

function PetTrainingNewCtrl:resetTabListView()
	local tabList = self:getTabListData()

	self.view.tabList:DeselectAll()
	self.view.tabList:SetList(tabList)

	local defPage = self.openInfo.toPage
	local showTabIndex = self:safeGetDisplayTabIndexAndName(defPage)

	if showTabIndex >= 0 then
		self.view.tabList:SelectItem(showTabIndex)
	else
		self:switchDefaultPanel()
	end

	TimerManager.addNextFrameCb(function()
		if NotNil(self.view.tabList) then
			if #tabList <= 1 then
				self.view.tabList:SetActiveFastestAndMarkIgnoreLayout(false)
			else
				self.view.tabList:SetActiveFastest(true)
			end
		end
	end)
end

function PetTrainingNewCtrl:switchDefaultPanel()
	local defPage = self.openInfo.toPage
	local defIndex = self.oldTab and self.model:getTabIndex(self.oldTab) or 0

	if defPage then
		local tab = Const.PetCulPageName2Index[defPage] or 0

		defIndex = self.model:getTabIndex(tab)
	end

	defIndex = self:safeGetDisplayTabIndexAndName(defPage)

	self.view.tabList:SelectItem(defIndex)

	self.openInfo.toPage = nil
end

function PetTrainingNewCtrl:safeGetDisplayTabIndexAndName(pageName)
	local showTabIndex, safeTabName = self.model:getSelectTabIndexByName(pageName)

	return showTabIndex, safeTabName
end

function PetTrainingNewCtrl:onRenderTabItem(button, data)
	local objectReference = button:GetComponent("ObjectReference")
	local name1 = objectReference:GetRefValue("name1")
	local name2 = objectReference:GetRefValue("name2")

	ClientTextUtils.setText(name1, data.name)
	ClientTextUtils.setText(name2, data.name)

	button.name = data.tab
end

function PetTrainingNewCtrl:refreshPetTitle()
	local petName = pg.getLocalizationText(LuaUIUtils.getPetNameWithIdOrTmpId(self.petId))

	ClientTextUtils.setText(self.view.tMPUSDFText, petName)
end

function PetTrainingNewCtrl:onTabSelectChanged(uList)
	local sData = uList.selectedItem

	self:refreshPetTitle()
	self.view.root:TryChangePage("Tab", sData.tab)

	if sData.tab == Const.PetCulPages.CARRY then
		self:setPetModelActive(false)
	elseif self.oldTab == Const.PetCulPages.CARRY then
		self:setPetModelActive(true)
	end

	self.oldTab = sData.tab

	self:setSceneTabId()

	local cmp = self:getCmpByTab(self.oldTab)

	if cmp then
		cmp:init(self.openInfo)
	end

	if cmp and cmp.onSelected then
		cmp:onSelected()
	end
end

function PetTrainingNewCtrl:initCurGamePad(uList)
	return
end

function PetTrainingNewCtrl:getCmpByTab(tab)
	local cmp = self.SELECTED_CMP[tab]

	if cmp == nil then
		cmp = self.CMP_ARRAY[tab]

		cmp:init(self.openInfo)

		self.SELECTED_CMP[tab] = cmp
	end

	return cmp
end

function PetTrainingNewCtrl:onRenderTabPetItem(button, data, single)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local imgBgBattle = objectReference:GetRefValue("imgBgBattle")
	local txtNum = objectReference:GetRefValue("txtNum")
	local umbralUContainer = objectReference:GetRefValue("umbralUContainer")

	iconUImage.url = LuaUIUtils.getPetIcon(data.iconName, LuaUIUtils.PET_ICON, data.label, data.gender)

	if data.isShiny then
		if data.shinyStyle == Const.PET_SHINY_STYLE.BLACK then
			button:TryChangePage("isFlash", 2)
		elseif data.shinyStyle == Const.PET_SHINY_STYLE.WHITE then
			button:TryChangePage("isFlash", 3)
		else
			button:TryChangePage("isFlash", 1)
		end
	else
		button:TryChangePage("isFlash", 0)
	end

	if data.isDark then
		umbralUContainer:SetActive(true)
		umbralUContainer:LoadDefaultUrlManually()
	else
		umbralUContainer:SetActive(false)
	end

	if not single then
		imgBgBattle:SetActive(true)
		ClientTextUtils.setText(txtNum, data.index)
	else
		imgBgBattle:SetActive(false)
	end
end

function PetTrainingNewCtrl:onTabCheckCanSelect(data)
	return self:checkPetTabCanSwitch(data.id)
end

function PetTrainingNewCtrl:onTabPetSelectChanged(uList)
	self.view.petManage.isSelected = false

	local sData = uList.selectedItem

	self.openInfo.petId = sData.id

	self:selectPetTabView()
end

function PetTrainingNewCtrl:onSelectSingle()
	if not self:checkPetTabCanSwitch(self.singlePet.id) then
		return
	end

	if self.model.IS_PVP_FAIL_MODE then
		return
	end

	self.view.petManage.isSelected = true

	self.view.tabPetList:DeselectAll()

	self.openInfo.petId = self.singlePet.id

	self:selectPetTabView()
end

function PetTrainingNewCtrl:checkPetTabCanSwitch(petId)
	if self.oldTab == Const.PetCulPages.STARUP then
		return LuaUIUtils.getIsCultivateSubCompUnLocked(Const.PetCulPageIndex2Name[Const.PetCulPages.STARUP])
	end

	if self.oldTab == Const.PetCulPages.TALENT then
		return LuaUIUtils.getIsCultivateSubCompUnLocked(Const.PetCulPageIndex2Name[Const.PetCulPages.TALENT])
	end

	return true
end

function PetTrainingNewCtrl:selectPetTabView()
	local curTab = self.oldTab

	self.openInfo.toPage = Const.PetCulPageIndex2Name[curTab]

	self:resetOpenInfo(self.openInfo)
	self:refreshPetTitle()

	local safeTab = Const.PetCulPageName2Index[self.openInfo.toPage]

	if not curTab or safeTab ~= curTab then
		self:resetTabListView()
		self:setSceneDisplayPet(self.petId)

		return
	end

	self:setSceneDisplayPet(self.petId)

	local cmp = self:getCmpByTab(self.oldTab)

	if cmp then
		cmp:init(self.openInfo)
	end

	if cmp and cmp.onSelected then
		cmp:onSelected()
	end
end

function PetTrainingNewCtrl:getSelectPetListInfo(petIds)
	local ret = {}

	for idx, petId in pairs(petIds) do
		local pet = pg.me:getPetInfo(petId)
		local petInfo = LuaUIUtils.generatePetInfo(pet)

		petInfo.index = idx
		petInfo.empty = false
		ret[#ret + 1] = petInfo
	end

	return ret
end

function PetTrainingNewCtrl:initTabLeftPetInfo(info)
	local dataList = {}

	if not self.model.IS_PVP_FAIL_MODE then
		if info.selectPetList then
			dataList = self:getSelectPetListInfo(info.selectPetList)
		else
			dataList = pg.global.ui.petManagement.model:getCurrentGroupInfo()
		end

		self.view.tabPetList:SetList(dataList)
	end

	local inCombat = pg.global.ui.petManagement.model:checkPetInCurGroup(self.petId)

	if info.selectPetList then
		inCombat = table.contains(info.selectPetList, self.petId)
	end

	if inCombat then
		self.view.tabLeft:TryChangePage("TeamIn", 1)
	else
		self.view.tabLeft:TryChangePage("TeamIn", 0)

		self.singlePet = self.model:getSinglePetInfo(self.petId)

		self:onRenderTabPetItem(self.view.petManage, self.singlePet, true)
	end

	local selectIdx = self:getPetTabIndex(dataList)

	if selectIdx == -1 then
		self:onSelectSingle()
	else
		self.view.tabPetList:SelectItem(selectIdx)
	end
end

function PetTrainingNewCtrl:setTabLeftActive(isShow)
	self.view.tabLeft.gameObject:SetActiveEx(isShow)
end

function PetTrainingNewCtrl:getPetTabIndex(dataList)
	if self.singlePet and self.petId == self.singlePet.id then
		return -1
	end

	local index = 1

	for i, v in ipairs(dataList) do
		if v.id == self.petId then
			index = i

			break
		end
	end

	return index - 1
end

function PetTrainingNewCtrl:event_CarryEquipped(msg)
	if not msg or msg.petId ~= self.petId then
		return
	end

	self.carryComponent:resetCarryView(true)
	self.carryComponent:playCarryEquipAnimation()
end

function PetTrainingNewCtrl:event_CarryAssistChanged()
	self.carryComponent:resetCarryView(true)
end

function PetTrainingNewCtrl:event_CarryUnload(msg)
	if not msg or msg.petId ~= self.petId then
		return
	end

	self.carryComponent:resetCarryView(false, msg)
end

function PetTrainingNewCtrl:event_CarryCertify(msg)
	if not msg or msg.petId ~= self.petId then
		return
	end

	self.pendingCoreCarryCertifyAnimationPetId = msg.petId

	if self.carryComponent then
		self.carryComponent:onCoreCarryCertifySuccess()
	end

	self:refreshCoreCarryCertifySkillInfo(msg)
end

function PetTrainingNewCtrl:event_CarryCertifyAnimation(msg)
	if not msg or msg.petId ~= self.petId or self.pendingCoreCarryCertifyAnimationPetId ~= msg.petId then
		return
	end

	self.pendingCoreCarryCertifyAnimationPetId = nil

	if self.carryComponent then
		self.carryComponent:playCoreCarryCertifySuccessAnimation()
	end
end

function PetTrainingNewCtrl:refreshCoreCarryCertifySkillInfo(msg)
	if not msg or msg.petId ~= self.petId then
		return
	end

	local newSkillComponent = self.newSkillComponent

	if not newSkillComponent then
		self.pendingCarryCertifyMsg = msg

		return
	end

	if not newSkillComponent.petInfo then
		return
	end

	newSkillComponent:setFeature(self.petId)
	newSkillComponent:refreshSkillList(self.petId)
	newSkillComponent:refreshAllSkills(self.petId)

	if msg.retAbilityId then
		TimerManager.addTimer(0.01, function()
			if self.petId == msg.petId and self.newSkillComponent == newSkillComponent then
				newSkillComponent:refreshSkillInfoByAbilityId(self.petId, msg.retAbilityId)
			end
		end)
	end
end

function PetTrainingNewCtrl:event_ItemGenCountChange()
	if self.carryComponent then
		self.carryComponent:refreshAssistRedDot()
		self.carryComponent:refreshStrengthRedDot()
	end

	local cmp = self:getCmpByTab(self.oldTab)

	if cmp and cmp.refreshOnItemsChanged then
		cmp:refreshOnItemsChanged()
	end
end

function PetTrainingNewCtrl:onHide()
	return
end

function PetTrainingNewCtrl:checkEvolveValid(petId)
	local pet = pg.me:getPetInfo(petId)
	local canEvolve = PetEvolveData[pet.templateId] and PetEvolveData[pet.templateId][1] and PetEvolveData[pet.templateId][1].targetPetId

	self.view.root:TryChangePage("Type", not canEvolve and 1 or 0)

	return canEvolve
end

function PetTrainingNewCtrl:checkPageStatus(onlyShowSkillPage)
	if onlyShowSkillPage then
		self.view.root:TryChangePage("Type", 2)
	else
		self.canEvolve = self:checkEvolveValid(self.petId)
	end
end

function PetTrainingNewCtrl:isInRogueDungeon()
	return RogueUtils.isInRogueSpace()
end

function PetTrainingNewCtrl:closePanel()
	pg.global.ui:close(UIConst.UI_ID_PET_TRAINING_NEW)
end

function PetTrainingNewCtrl:onPetCustomNameChanged(info)
	local petId = info.petId
	local name = pg.getLocalizationText(self.model:getPetName(petId))
	local cmp = self:getCmpByTab(self.oldTab)

	if cmp and cmp.refreshPetName then
		cmp:refreshPetName(name)
	end
end

function PetTrainingNewCtrl:onPetFavoriteChanged(info)
	return
end

function PetTrainingNewCtrl:onPetFavoriteTypeChanged(info)
	local cmp = self:getCmpByTab(self.oldTab)

	if cmp and cmp.resetFavouriteBtnState then
		cmp:resetFavouriteBtnState(self.model:setUpPetInfo(info[1]).favoriteType)
	end
end

function PetTrainingNewCtrl:resetPetPropLevel(petId, cb)
	pg.me:serverMsg("RPC_CS_ResetPetPropLevel", petId, function(noticeId)
		if noticeId == NoticeDef.SUCCESS then
			self:startTimer(function()
				if cb then
					cb()
				end
			end, 0.1)
		end
	end)
end

function PetTrainingNewCtrl:learnPetPropLevel(petId, propIndex, toLevel, cb)
	PetManagementUtils.learnPetPropLevel(petId, propIndex, toLevel, cb)
end

function PetTrainingNewCtrl:onPetCurAbilityChanged(info)
	local petId = info.petId

	if petId == self.petId then
		self.newSkillComponent:refreshSkillList(self.petId)
		self.newSkillComponent:refreshAllSkillsBtnState()
		self.newSkillComponent:playRefreshAnim(info.index)
	end
end

function PetTrainingNewCtrl:onPetSkillGlazeSuccess(msg)
	if msg.petId == self.petId then
		self.newSkillComponent:setFeature(self.petId)
		self.newSkillComponent:refreshSkillList(self.petId)
		self.newSkillComponent:refreshAllSkills(self.petId)

		local retAbilityId = msg.retAbilityId

		TimerManager.addTimer(0.01, function()
			self.newSkillComponent:refreshSkillInfoByAbilityId(self.petId, retAbilityId)
		end)
	end
end

function PetTrainingNewCtrl:onPetNewPropChange(msg)
	local cmp = self:getCmpByTab(self.oldTab)

	if cmp and cmp.refreshNewPropUI then
		cmp:refreshNewPropUI(true)
	end
end

function PetTrainingNewCtrl:onPetResonanceChange(msg)
	local cmp = self:getCmpByTab(self.oldTab)

	if cmp and cmp.refreshStarUp then
		cmp:refreshStarUp(msg)
		self:refreshSceneByStarUp(msg)
	end
end

function PetTrainingNewCtrl:onPetResonanceChangeDebug(msg)
	local cmp = self:getCmpByTab(self.oldTab)

	if cmp and cmp.debugShowBreakPop then
		cmp:debugShowBreakPop(msg)
	end
end

function PetTrainingNewCtrl:setSceneTabId()
	local scene = pg.game.uiScene:getScene(self.newUISceneName)

	if not scene or not scene:isCreated() then
		return
	end

	scene:setSceneTabId(self.oldTab)
end

function PetTrainingNewCtrl:setSceneDisplayPet()
	local scene = pg.game.uiScene:getScene(self.newUISceneName)

	if not scene or not scene:isCreated() then
		return
	end

	scene:setSceneDisplayPet(self.petId, self.oldTab)
end

function PetTrainingNewCtrl:refreshSceneByStarUp(msg)
	local scene = pg.game.uiScene:getScene(self.newUISceneName)

	if not scene or not scene:isCreated() then
		return
	end

	self:playPetEvolveAction()
	scene:refreshFlowersByStarUp(self.petId, msg)
end

function PetTrainingNewCtrl:playPetEvolveAction()
	local scene = pg.game.uiScene:getScene(self.newUISceneName)

	if not scene or not scene:isCreated() then
		return
	end

	scene:playPetEvolveAction()
end

function PetTrainingNewCtrl:onPetPropLearnChange()
	if self.newTrainingComponent then
		self.newTrainingComponent:refreshOnPropLearnLevel()
	end
end

function PetTrainingNewCtrl:event_CarryUpgrade()
	local cmp = self:getCmpByTab(self.oldTab)

	if cmp and cmp.refreshCarryInfo then
		cmp:refreshCarryInfo()
	end
end

function PetTrainingNewCtrl:onPetCarryBatchEquipSuccess()
	local cmp = self:getCmpByTab(self.oldTab)

	if cmp and cmp.refreshBatchCarryEquiped then
		cmp:refreshBatchCarryEquiped()
		cmp:playCarryEquipAnimation()
	end
end

return PetTrainingNewCtrl
