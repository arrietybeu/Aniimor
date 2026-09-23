-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\PetListUIComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("PetListUIComponent")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local ClientUtils = require("Utils.ClientUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local BuffUIUtils = require("Utils.BuffUIUtils")
local PetListUIUtils = require("Utils.PetListUIUtils")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientAbilityUtils = require("Utils.ClientAbilityUtils")
local AbilityUIUtils = require("Utils.AbilityUIUtils")
local Const = require("Common.Const.Const")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local AbilityConst = require("Common.Const.AbilityConst")
local AddressDataConst = require("Const.AddressDataConst")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local SysConfigData = require("Data.sys_config_data")
local TimerManager = require("Core.Timer.TimerManager")
local Time = require("Core.Common.Time")
local NoticeDef = require("Common.NoticeDef")
local MessageName = require("Const.MessageName")
local UIStringPool = require("Guis.Utils.UIStringPool")
local lume = require("Core.Common.lume")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local ToBool = ToBool
local NotNil = NotNil
local pg = pg
local MAX_PET_COUNT = 4
local INVALID_ITEM = -1
local PetListUIComponent = Class.LightClass("PetListUIComponent", HudBaseComponent)

PetListUIComponent.messages = {
	[MessageName.SCENE_LOADED] = {
		"refreshQuickSwitchPetTeamVisible",
		true
	},
	[MessageName.MODULE_ENABLE_CHANGED] = {
		"onModuleEnableChanged",
		true
	},
	[MessageName.ROGUE_EXTRA_TEMP_PET_STATE_CHANGE] = {
		"onExtraTempPetStateChange",
		true
	},
	[MessageName.MAIN_PLAYER_EP_CHANGE] = {
		"onPlayerEpChange",
		true
	},
	[MessageName.SPECIAL_ATTACK_MODE_CHANGE] = {
		"onPlayerEpChange",
		true
	},
	[MessageName.ON_ABILITY_EP_COST_CHANGED] = {
		"onPlayerEpChange",
		true
	},
	[MessageName.PET_HP_CHANGE] = {
		"refreshPossessHp",
		true
	},
	[MessageName.SWITCH_PET_CD_UPDATE] = {
		"onSwitchPetCDUpdate",
		true
	},
	[MessageName.PET_ALIVE_CHANGE] = {
		"refreshPetAlive",
		true
	},
	[MessageName.LOCKED_TARGET_CHANGE] = {
		"refreshPetListOnLockedTgtChange",
		true
	},
	[MessageName.PLAYER_COMBAT_STATUS_UPDATE] = {
		"onPlayerCombatStatusUpdate",
		true
	},
	[MessageName.SKILL_SWITCH_UPDATE] = {
		"refreshChangeState",
		true
	},
	[MessageName.ON_CONTROL_ENT] = {
		"refreshPetListOnControlEntChange",
		true
	},
	[MessageName.COMBAT_PET_CHANGED] = {
		"refreshPetListOnCombatPetChange",
		true
	},
	[MessageName.COMBAT_PET_TEMPLATE_CHANGE] = {
		"refreshHudPetListByEnt",
		true
	},
	[MessageName.ON_SPACE_BATTLE_MODE_CHANGE] = {
		"refreshPetListOnBattleModeChange",
		true
	},
	[MessageName.BUFF_CHANGE] = {
		"onBuffChange",
		true
	},
	[MessageName.ON_BUFF_ADD] = {
		"onBuffAdd",
		true
	},
	[MessageName.ON_BUFF_REMOVE] = {
		"onBuffRemove",
		true
	},
	[MessageName.ON_BUFF_EXPIRED_TIME_CHANGE] = {
		"onBuffExpiredTimeChange",
		true
	},
	[MessageName.BUFF_LAYER_CHANGE] = {
		"onBuffLayerChange",
		true
	},
	[MessageName.PLAYER_PET_CUR_ABILITY_CHANGED] = {
		"onPetCurEquipAbilityChange",
		true
	},
	[MessageName.PET_LEVEL_CHANGED] = {
		"onPetLevel",
		true
	},
	[MessageName.PET_ADD_EXP] = {
		"onPetLevel",
		true
	},
	[MessageName.PLAYER_PET_CUR_PROPERTY_CHANGED] = {
		"onPetCrownStateChange",
		true
	},
	[MessageName.PET_NEW_PROP_CHANGE] = {
		"onPetCrownStateChange",
		true
	},
	[MessageName.PET_PROP_LEARN_CHANGE] = {
		"onPetCrownStateChange",
		true
	},
	[MessageName.SKILL_CD_END_TIME_UPDATE] = {
		"onSupportSkillCdUpdate",
		true
	},
	[MessageName.PREPARE_PETS_UPDATE] = {
		"refreshHudPetList",
		true
	},
	[MessageName.PET_SHOW_HEAL_EFFECT] = {
		"onShowPetHealEffect",
		true
	},
	[MessageName.SHIELD_CHANGE] = {
		"refreshPetShieldByPetEnt",
		true
	},
	[MessageName.SHIELD_BREAK] = {
		"refreshPetShieldBreakByPetEnt",
		true
	},
	[MessageName.FIRST_ENTER_TEAM] = {
		"refreshQuickSwitchPetTeamVisible",
		true
	},
	[MessageName.LEAVE_TEAM] = {
		"refreshQuickSwitchPetTeamVisible",
		true
	},
	[MessageName.LEAVE_CATCH_MODE_ST] = {
		"leaveLevelUpInCatch",
		true
	},
	[MessageName.ENTER_EXIT_DELAY_EXPLORE_STATE] = {
		"refreshPetListOnDelayExploreChange",
		true
	},
	[MessageName.EXIT_EXIT_DELAY_EXPLORE_STATE] = {
		"refreshPetListOnDelayExploreChange",
		true
	},
	[MessageName.MODIFY_PET_FORMATION] = {
		"onPetFormationModified",
		true
	},
	[MessageName.SWITCH_PET_BLOCK_BY_EXPLORE_ST] = {
		"onSwitchPetBlockByExploreST",
		true
	},
	[MessageName.CHARACTER_STATE_CHANGED] = {
		"onCharacterStateChanged",
		true
	},
	[MessageName.ON_BUFF_CONTROL_ST_CHANGED] = {
		"onCharacterStateChanged",
		true
	},
	[MessageName.MAIN_PET_ENTER_SPACE] = {
		"refreshHudPetListByEnt",
		true
	},
	[MessageName.DUNGEON_TEAMMATEVIEW_CHANGE] = {
		"onTeammateViewChange",
		true
	}
}

function PetListUIComponent:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.petUList = self.objectReference:GetRefValue("listPetUList")
	self.keyHintUWidget = self.objectReference:GetRefValue("keyHintUWidget")
	self.keyUButton = self.objectReference:GetRefValue("keyUButton")

	local keyBtnObjectReference = self.keyUButton:GetComponent("ObjectReference")

	self.switchPetTeamHotKeyContent = keyBtnObjectReference:GetRefValue("keyHotKeyContent")
	self.panelUComponent = self.objectReference:GetRefValue("panelUComponent")
	self.quickSwitchTeamPanelTransform = self.objectReference:GetRefValue("quickSwitchTeamPanelTransform")
	self.panelTeamSelUContainer = self.objectReference:GetRefValue("panelTeamSelUContainer")

	self.panelTeamSelUContainer:LoadDefaultUrlManually(function(content)
		self.panelTeamComponent = content

		local objectReference = content:GetComponent("ObjectReference")

		self.quickSwitchPetTeamUList = objectReference:GetRefValue("quickSwitchPetTeamUList")
		self.confirmUButton = objectReference:GetRefValue("confirmUButton")
		self.exitUButton = objectReference:GetRefValue("exitUButton")
		self.keyHotKeyContent = objectReference:GetRefValue("keyHotKeyContent")

		self:setQuickSwitchPetTeamList()
	end)

	self.showAnim = self.objectReference:GetRefValue("showAnim")
end

function PetListUIComponent:initView()
	self:initViewState()
	self:initPetListNecessaryTable()
	self:initCustomKeyBinding()

	function self.petUList.luaRenderItem(button, index, data)
		local petIdx = index + 1

		if data.tIndex == 0 then
			self:_cachePetBtnComponent(button, petIdx)
			self:_initPetBtnListener(button, petIdx)
			self:refreshPet(button, petIdx, data)
		elseif data.tIndex == 1 then
			button.enabledLongPress = true
			button.longPressDelay = 0.1

			self:_cacheSupportPetBtnComponent(button, petIdx)
			self:refreshSupportPet(button, petIdx)
		end
	end

	function self.petUList.luaClick(button, data)
		if data.index == nil or data.index == -1 then
			return
		end

		if data.tIndex == 0 then
			self:clickPet(data.index)
		end
	end

	self:initQuickSwitchPetTeamView()
	self:refreshPetListVisible()
	self:refreshHudPetList(true)
end

function PetListUIComponent:initViewState()
	self.showPetList = true
	self.showQuickSwitchPetTeam = true
	self.spaceBattleModeDirty = true
	self.isListInit = false

	local player = pg.me

	self.curSelectedPetIndex = player.curIndex
	self.curPlayerInFuse = not player:isControllingMaster()
	self.curPetMaxCnt = #player.petPrepareList
end

function PetListUIComponent:initPetListNecessaryTable()
	self.buffDisappearHintTimer = {}

	if jit then
		local table_new = require("table.new")

		self.petInfoList = table_new(4, 0)
		self.petBtnRefList = table_new(4, 0)
		self.petLevelUpCmdList = table_new(4, 0)
		self.petLevelUpTimer = table_new(4, 0)
		self.recommendTimer = table_new(4, 0)
		self.lastShowHealEffectTimeMap = table_new(4, 0)
		self.petSheildActiveRecords = table_new(4, 0)
		self.petSheildIsInBreakRecords = table_new(4, 0)
		self.delayHideBarShieldTimers = table_new(4, 0)
		self.petLevelUpContents = table_new(4, 0)
		self.petLevelUpObjRefs = table_new(4, 0)
		self.curPetBuffLists = table_new(4, 0)
	else
		self.petInfoList = {}
		self.petBtnRefList = {}
		self.petLevelUpCmdList = {}
		self.petLevelUpTimer = {}
		self.recommendTimer = {}
		self.lastShowHealEffectTimeMap = {}
		self.petSheildActiveRecords = {}
		self.petSheildIsInBreakRecords = {}
		self.delayHideBarShieldTimers = {}
		self.petLevelUpContents = {}
		self.petLevelUpObjRefs = {}
		self.curPetBuffLists = {}
	end

	for i = 1, MAX_PET_COUNT do
		self.petInfoList[i] = {
			id = false
		}
		self.petBtnRefList[i] = {
			supportSkillSceneValid = true,
			supportSkillVisible = true,
			imgTryVisible = false,
			resistState = UIConst.RESIST_STATE.NONE,
			petState = UIConst.PET_LIST_PET_STATE.NORMAL
		}
	end

	PetListUIUtils.fillFollowPetInfos(self.petInfoList)
end

function PetListUIComponent:initCustomKeyBinding()
	local ctrlKeyBind = KeyBindingPro.GetOrAddKeyBindingByName(self.transform.gameObject, "ctrlKey")

	ctrlKeyBind.isVirtual = true
	ctrlKeyBind.actionPath = "Skill/SupportSkillHint"

	function ctrlKeyBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:setSupportSkillActionPathEnable(true)
		elseif inputInfo.phase == "Canceled" then
			self:setSupportSkillActionPathEnable(false)
		end
	end
end

function PetListUIComponent:onDestroy()
	if self.buffDisappearHintTimer ~= nil then
		for _, timerId in pairs(self.buffDisappearHintTimer) do
			TimerManager.removeTimer(timerId)
		end

		self.buffDisappearHintTimer = nil
	end

	if self.delayHideBarShieldTimers ~= nil then
		for _, timerId in pairs(self.delayHideBarShieldTimers) do
			if timerId then
				TimerManager.removeTimer(timerId)
			end
		end

		self.delayHideBarShieldTimers = nil
	end

	if self.petLevelUpTimer ~= nil then
		for _, timerId in pairs(self.petLevelUpTimer) do
			TimerManager.removeTimer(timerId)
		end

		self.petLevelUpTimer = nil
	end

	if self.recommendTimer ~= nil then
		for _, timerId in pairs(self.recommendTimer) do
			TimerManager.removeTimer(timerId)
		end

		self.recommendTimer = nil
	end

	if self.lastShowHealEffectTimeMap then
		for _, timerId in pairs(self.lastShowHealEffectTimeMap) do
			TimerManager.removeTimer(timerId)
		end

		self.lastShowHealEffectTimeMap = nil
	end

	self.petInfoList = nil
	self.petBtnRefList = nil
	self.petLevelUpCmdList = nil
	self.petSheildActiveRecords = nil
	self.petSheildIsInBreakRecords = nil
	self.petLevelUpContents = nil
	self.petLevelUpObjRefs = nil
	self.curPetBuffLists = nil

	HudBaseComponent.onDestroy(self)
end

function PetListUIComponent:refreshPetListVisible()
	if not self.petUList then
		return
	end

	local visible = pg.game:checkModuleEnable(ClientConst.ModuleKey.PetList)

	if pg.me and pg.me.isUsingExtraTempPet then
		visible = false
	end

	if self.showPetList ~= visible then
		self.showPetList = visible

		self.petUList:SetActiveByOutOfView(visible, true)
		self:refreshQuickSwitchPetTeamVisible()
	end
end

function PetListUIComponent:refreshHudPetList(isInit)
	if self.isListInit and pg.game.seamless:seam_sys_isSwitchSeamless() then
		return
	end

	if not isInit then
		PetListUIUtils.fillFollowPetInfos(self.petInfoList)
	end

	if self.spaceBattleModeDirty then
		if not self.isListInit then
			self.petUList:SetList(self.petInfoList)

			self.isListInit = true
		else
			self.petUList:RefreshList()
		end

		self.spaceBattleModeDirty = false
	end

	self.curPetMaxCnt = #pg.me.petPrepareList

	for idx = 1, MAX_PET_COUNT do
		local data = self.petInfoList[idx]
		local button = self.petBtnRefList[idx].button

		if data.tIndex == 1 then
			self:refreshSupportPet(button, idx)
		else
			self:refreshPet(button, idx, data)
		end
	end
end

function PetListUIComponent:refreshPet(button, petIdx, data)
	local valid = data.index ~= INVALID_ITEM

	self:refreshPetBtnVisible(button, data, valid)

	if not valid then
		return
	end

	local btnRefInfo = self.petBtnRefList[petIdx]
	local objectReference = btnRefInfo.objRef

	self:refreshPetCrown(objectReference, data)
	self:refreshPetBtnState(petIdx)
	self:refreshPetState(button, petIdx)
	self:showBtnResist(button, petIdx)
	self:showBtnRecommend(button, petIdx)

	local curPlayerSpace = pg.me and pg.me.space

	if self:checkSupportSkillBtnNeedLoad(curPlayerSpace) then
		btnRefInfo.supportSkillSceneValid = true

		local skillUContainer = btnRefInfo.skillUContainer

		if not skillUContainer:CheckURLLoaded() then
			skillUContainer:LoadDefaultUrlManually(function(content)
				self:_cachePetSupportSkillComponent(content, petIdx)
				self:setPetSupportSkillBtn(skillUContainer, petIdx)
			end)
		else
			if self.spaceBattleModeDirty then
				self:_cachePetSupportSkillComponent(skillUContainer.content, petIdx)
			end

			self:refreshPetSupportSkillBtnState(skillUContainer, petIdx)
			self:refreshSupportSkillCD(skillUContainer.content, nil, Utils.getPlayerPetByTeamIndex(pg.me, petIdx), petIdx, nil)
		end
	else
		btnRefInfo.supportSkillSceneValid = false

		btnRefInfo.skillUContainer:SetActiveByOutOfView(false)
	end

	local isDittoDungeon = curPlayerSpace and curPlayerSpace:isDittoSpace()
	local curImgTryVisible = data.isTrial and not isDittoDungeon

	if btnRefInfo.imgTryVisible ~= curImgTryVisible then
		local imgTryingUContainer = btnRefInfo.itemTryingUContainer

		LuaUIUtils.setUIViewVisible(imgTryingUContainer, curImgTryVisible)

		btnRefInfo.imgTryVisible = curImgTryVisible

		if curImgTryVisible and not imgTryingUContainer:CheckURLLoaded() then
			imgTryingUContainer:LoadDefaultUrlManually(function(context)
				local imgTryObjRef = context:GetComponent("ObjectReference")
				local imgTryText = imgTryObjRef:GetRefValue("textUSDFText")

				ClientTextUtils.setText(imgTryText, pg.getGameString("GLAMOUR_EVENT_TRIAL"))
			end)
		end
	end

	if data.petFunctionTypeIconDirty then
		local functionTypeIcon = btnRefInfo.functionTypeIcon

		functionTypeIcon.url = data.petFunctionTypeIcon
	end

	local cmdList = self.petLevelUpCmdList[petIdx]

	if cmdList ~= nil then
		local nextCmd = cmdList[1]
		local petInfo = self.petInfoList[petIdx]

		if nextCmd == nil or petInfo == nil or nextCmd.petId ~= petInfo.id then
			self:clearLevelUpCmdList(petIdx)

			cmdList = nil
		end
	end

	if not ToBool(cmdList) then
		self:refreshPetLevel(petIdx)
	end

	self:refreshElement(objectReference, petIdx, data)
	self:refreshPetHp(objectReference, petIdx)

	if data.iconDirty then
		local icon = btnRefInfo.icon

		icon.url = data.iconUrl
	end

	self:refreshBuffList(objectReference, petIdx)
end

function PetListUIComponent:refreshPetCrown(objectReference, data, forceRefresh)
	if not objectReference or not data then
		return
	end

	local crownUComponent = objectReference:GetRefValue("crownUComponent")

	if not crownUComponent then
		return
	end

	local crownState = data.petCrownState

	if forceRefresh or data.crownPetId ~= data.id or crownState == nil then
		crownState = UIConst.PET_CROWN_STATE.NONE

		local petInfo = data.id and pg.me and not pg.me.inTeammateView and pg.me:getPetInfo(data.id) or nil

		if petInfo and not petInfo:isCatchReporting() then
			local propLevels = pg.game.petManage:getPetPropLevels(petInfo)

			crownState = LuaUIUtils.getPetCrownState(propLevels)
		end

		data.crownPetId = data.id
		data.petCrownState = crownState
	end

	crownUComponent:TryChangePage("Crown", crownState)
end

function PetListUIComponent:refreshPetBtnVisible(button, data, valid)
	local needRefreshVisible = data.btnValidDirty

	if needRefreshVisible then
		button:SetActiveByOutOfView(valid)
	end
end

function PetListUIComponent:refreshSupportPet(petButton, petIdx)
	local btnRefInfo = self.petBtnRefList[petIdx]
	local objectReference = btnRefInfo.objRef
	local petIcon = btnRefInfo.icon
	local data = self.petInfoList[petIdx]

	self:refreshPetCrown(objectReference, data)

	local petEntity = Utils.getPlayerPetByTeamIndex(pg.me, petIdx)

	if not petEntity then
		petIcon.url = nil

		petButton:TryChangePage("Empty", 1)

		return
	end

	local supportSkillBtn = btnRefInfo.supportSkillBtn

	petIcon.url = data.iconUrl

	local petCoreAbilityId = petEntity.coreAbilityId

	if not ToBool(petCoreAbilityId) then
		petButton:TryChangePage("Empty", 1)

		local btnObjRef = supportSkillBtn:GetComponent("ObjectReference")
		local keyBindingPro = btnObjRef:GetRefValue("keyBindingPro")

		keyBindingPro.actionPath = UIStringPool.getHudPetActionPath(petIdx)
	else
		petButton:TryChangePage("Empty", 0)

		local abilityInfo = LuaUIUtils.getSkillInfByAbilityId(petCoreAbilityId, petEntity)

		abilityInfo.actionPath = UIStringPool.getHudPetActionPath(petIdx)
		abilityInfo.pawn = petEntity

		local btnRefInfo = AbilityUIUtils.getSkillBtnRefInfo(supportSkillBtn)

		AbilityUIUtils.setSkillBtnBasicInfo(btnRefInfo, abilityInfo)
		AbilityUIUtils.refreshSkillState(btnRefInfo, abilityInfo)

		if data.id == pg.me.curCombatPetId then
			petButton:TryChangePage("State", 1)
		else
			petButton:TryChangePage("State", 0)
		end
	end

	self:registerSupportPetSkillBtn(supportSkillBtn, petButton, petIdx)
	self:refreshBuffList(objectReference, petIdx)
end

function PetListUIComponent:setPetSupportSkillBtn(supportSkillUContainer, petIdx)
	self:refreshPetSupportSkillBtnState(supportSkillUContainer, petIdx)

	local btnSkillUButton = supportSkillUContainer.content
	local btnObjRef = btnSkillUButton:GetComponent("ObjectReference")
	local keyHotKeyContent = btnObjRef:GetRefValue("keyHotKeyContent")

	keyHotKeyContent:SetHotKeyPaths(UIStringPool.getHudPetActionPath(petIdx))
	keyHotKeyContent.gameObject:SetActiveEx(false)

	local keyBinding = btnSkillUButton:GetComponent("KeyBindingPro")

	keyBinding.actionPath = UIStringPool.getHudSupportPetActionPath(petIdx)
	keyBinding.isVirtual = true

	function keyBinding.luaTrigger(inputInfo)
		if pg.game.input:isUsingGamepad() then
			local hudV2 = pg.global.ui.hudV2

			if hudV2 and hudV2.RD and hudV2.RD.skill and hudV2.RD.skill.blockEvents then
				return true
			end
		end

		if inputInfo.phase == "Performed" then
			btnSkillUButton:OnClickSimulate()
		end
	end

	function btnSkillUButton.luaClick()
		if not self.showPetList then
			return
		end

		local petEntId = petIdx and pg.me.petPrepareList[petIdx]
		local petEntity = petEntId and pg.getEntity(petEntId)

		if not petEntity then
			return
		end

		local lockedActorId = pg.me.lockedActorId ~= 0 and pg.me.lockedActorId or nil
		local curPetCoreAbilityId = petEntity.coreAbilityId
		local result, reason = petEntity:checkCanCastAbility(curPetCoreAbilityId, lockedActorId)

		if not result then
			local noticeId = Utils.abilityReason2noticeId(reason)

			if NoticeDef.FAIL ~= noticeId then
				pg.global.showBubbleMessageById(noticeId)
			end

			return
		end

		pg.me:switchToPetByIndex(petIdx, true, curPetCoreAbilityId)
	end
end

function PetListUIComponent:refreshPetSupportSkillBtnState(supportSkillUContainer, petIdx)
	local petInfo = self.petInfoList[petIdx]
	local petEntity = pg.getEntity(petInfo.id)

	if not petEntity or not supportSkillUContainer then
		return
	end

	local btnRefInfo = self.petBtnRefList[petIdx]
	local btnSkillUButton = btnRefInfo.petSupportSkillBtn

	if not btnSkillUButton then
		return
	end

	local petCoreAbilityId = petEntity.coreAbilityId
	local hasEquipSupportSkill = LuaUIUtils.checkHasEquipCoreAbility(petEntity)
	local isNormalBattleMode = not petEntity.space or petEntity.space.battleMode == 0
	local canShowSupportSkillBtn = isNormalBattleMode and hasEquipSupportSkill and btnRefInfo.supportSkillSceneValid

	if btnRefInfo.supportSkillVisible ~= canShowSupportSkillBtn then
		btnRefInfo.supportSkillVisible = canShowSupportSkillBtn

		if not btnRefInfo.isSelected then
			supportSkillUContainer:SetActiveByOutOfView(canShowSupportSkillBtn)
		end
	end

	if not canShowSupportSkillBtn then
		if not hasEquipSupportSkill then
			btnRefInfo.petCoreAbilityId = nil
			btnRefInfo.supportSkillEpCost = nil
		end

		return
	end

	if btnRefInfo.petCoreAbilityId ~= petCoreAbilityId then
		btnRefInfo.petCoreAbilityId = petCoreAbilityId

		local iconSkillUImage = btnRefInfo.iconSkillUImage
		local skillCostUSDFText = btnRefInfo.skillCostUSDFText
		local skillInfo = LuaUIUtils.getSkillInfByAbilityId(petCoreAbilityId, petEntity)

		iconSkillUImage.url = skillInfo.skillIcon

		local skillCost, epCostValid = LuaUIUtils.getRealSkillCost(skillInfo, petEntity, petCoreAbilityId)

		skillCost = skillCost or 0
		btnRefInfo.supportSkillEpCost = skillCost

		ClientTextUtils.setText(skillCostUSDFText, UIStringPool.getTwoDigitText(skillCost))

		if not epCostValid or not petEntity:checkAbilityCd(petCoreAbilityId) then
			btnSkillUButton:TryChangePage("Ready", 0)
		else
			btnSkillUButton:TryChangePage("Ready", 1)
		end
	end
end

function PetListUIComponent:refreshPetSupportSkillBtnReady(petIdx, ignoreCdCheck)
	local petInfo = self.petInfoList[petIdx]
	local petEntity = pg.getEntity(petInfo.id)

	if not petEntity then
		return
	end

	local btnRefInfo = self.petBtnRefList[petIdx]
	local btnSkillUButton = btnRefInfo.petSupportSkillBtn

	if not btnSkillUButton then
		return
	end

	local petCoreAbilityId = petEntity.coreAbilityId
	local skillInfo = LuaUIUtils.getSkillInfByAbilityId(petCoreAbilityId, petEntity)
	local skillCost, epCostValid = LuaUIUtils.getRealSkillCost(skillInfo, petEntity, petCoreAbilityId)

	if not epCostValid or not ignoreCdCheck and not petEntity:checkAbilityCd(petCoreAbilityId) then
		btnSkillUButton:TryChangePage("Ready", 0)
	else
		btnSkillUButton:TryChangePage("Ready", 1)
	end
end

function PetListUIComponent:refreshPetSupportSkillEpCost(petIdx)
	local petInfo = self.petInfoList[petIdx]
	local petEntity = pg.getEntity(petInfo.id)

	if not petEntity then
		return
	end

	local btnRefInfo = self.petBtnRefList[petIdx]
	local btnSkillUButton = btnRefInfo.petSupportSkillBtn

	if not btnSkillUButton then
		return
	end

	if not LuaUIUtils.checkHasEquipCoreAbility(petEntity) then
		btnRefInfo.petCoreAbilityId = nil
		btnRefInfo.supportSkillEpCost = nil

		return
	end

	local petCoreAbilityId = petEntity.coreAbilityId
	local skillInfo = LuaUIUtils.getSkillInfByAbilityId(petCoreAbilityId, petEntity)
	local skillCost, epCostValid = LuaUIUtils.getRealSkillCost(skillInfo, petEntity, petCoreAbilityId)

	skillCost = skillCost or 0

	local skillCostUSDFText = btnRefInfo.skillCostUSDFText

	if btnRefInfo.supportSkillEpCost ~= skillCost then
		btnRefInfo.supportSkillEpCost = skillCost

		ClientTextUtils.setText(skillCostUSDFText, UIStringPool.getTwoDigitText(skillCost))
	end

	if not epCostValid or not petEntity:checkAbilityCd(petCoreAbilityId) then
		btnSkillUButton:TryChangePage("Ready", 0)
	else
		btnSkillUButton:TryChangePage("Ready", 1)
	end
end

function PetListUIComponent:checkSupportSkillBtnNeedLoad(curPlayerSpace)
	if curPlayerSpace then
		if curPlayerSpace:isHomeland() then
			return false
		end

		if curPlayerSpace.sceneId == Const.SCENE_ID.ARK then
			return false
		end
	end

	return true
end

function PetListUIComponent:onTeammateViewChange()
	self:refreshHudPetList()
end

function PetListUIComponent:setSupportSkillActionPathEnable(enable)
	local player = pg.me

	if not player then
		return
	end

	local curPlayerSpace = player.space

	if curPlayerSpace and curPlayerSpace:isSupportPetMode() then
		return
	end

	if not self:checkSupportSkillBtnNeedLoad(curPlayerSpace) then
		return
	end

	for i = 1, self.curPetMaxCnt do
		local hasEquipSupportSkill = false
		local petEntity = Utils.getPlayerPetByTeamIndex(player, i)

		if petEntity then
			local petCoreAbilityId = petEntity.coreAbilityId

			hasEquipSupportSkill = LuaUIUtils.checkHasEquipCoreAbility(petEntity)
		end

		local btnRefInfo = self.petBtnRefList and self.petBtnRefList[i]
		local supportSkillVisible = btnRefInfo and btnRefInfo.supportSkillVisible and not btnRefInfo.isSelected

		if hasEquipSupportSkill and supportSkillVisible then
			local button = self:getButtonByIdx(i)

			if button then
				button:TryChangePage("HaveSkillKey", enable and 1 or 0)
			end
		end
	end
end

function PetListUIComponent:onSupportSkillCdUpdate(info)
	if not info or not info.abilityId then
		return
	end

	for i = 1, self.curPetMaxCnt do
		local petEntity = Utils.getPlayerPetByTeamIndex(pg.me, i)

		if petEntity and petEntity.coreAbilityId == info.abilityId then
			local coreAbilityId = petEntity.coreAbilityId
			local button = self:getButtonByIdx(i)

			if button then
				local data = self.petInfoList[i]

				if data.tIndex == 0 then
					local skillUContainer = self.petBtnRefList[i].skillUContainer
					local skillComponent = skillUContainer.content

					if skillComponent then
						self:refreshSupportSkillCD(skillComponent, skillUContainer, petEntity, i, self.refreshPetSupportSkillBtnReady)
					end
				elseif data.tIndex == 1 then
					self:refreshSupportPet(button, i)
				end
			end
		end
	end
end

function PetListUIComponent:refreshSupportSkillCD(button, refreshTarget, petEntity, index, refreshBtnFunc)
	if not petEntity then
		return
	end

	local btnRefInfo = self.petBtnRefList[index]
	local countDown = btnRefInfo.petSupportSkillCountDown
	local countDownVisible = false
	local coreAbilityId = petEntity.coreAbilityId
	local ability = petEntity:getAbility(coreAbilityId)

	if ability and ability.cdEndTime then
		local endTime = ability.cdEndTime
		local timeNow = petEntity:getGameTime()
		local freezeDuration = petEntity.abilityFreezeMap[coreAbilityId]
		local duration = freezeDuration or endTime - timeNow
		local cd = AbilityUtils.getAbilityParamCdForUI(coreAbilityId, petEntity)
		local totalDuration = math.max(duration, cd)

		if duration > UIConst.CD_LIMIT or freezeDuration then
			countDownVisible = true

			countDown:Play(duration, totalDuration, true)

			if freezeDuration then
				countDown:Stop()
			end
		end

		if refreshBtnFunc ~= nil and countDown.luaFinished == nil then
			function countDown.luaFinished()
				countDown.gameObject:SetActiveEx(false)
				refreshBtnFunc(self, index, true)
			end
		end
	end

	if countDown then
		countDown.gameObject:SetActiveEx(countDownVisible)
	end

	if refreshBtnFunc ~= nil then
		refreshBtnFunc(self, index)
	end
end

function PetListUIComponent:onPlayerEpChange()
	for i = 1, self.curPetMaxCnt do
		local button = self:getButtonByIdx(i)

		if button then
			local data = self.petInfoList[i]

			if data.tIndex == 0 then
				self:refreshPetSupportSkillEpCost(i)
			elseif data.tIndex == 1 then
				self:refreshSupportPet(button, i)
			end
		end
	end
end

function PetListUIComponent:onPetCurEquipAbilityChange()
	for i = 1, self.curPetMaxCnt do
		local skillUContainer = self.petBtnRefList[i].skillUContainer

		if skillUContainer then
			local data = self.petInfoList[i]

			if data.tIndex == 0 then
				self:refreshPetSupportSkillBtnState(skillUContainer, i)
			end
		end
	end
end

function PetListUIComponent:refreshElement(btnObjectReference, petIdx, data)
	if not data.elementDirty then
		return
	end

	data.elementDirty = false

	local elementNames = data.elementNames
	local element1 = btnObjectReference:GetRefValue("element1UButton")
	local element2 = btnObjectReference:GetRefValue("element2UButton")

	if #elementNames == 0 then
		LuaUIUtils.setUIViewVisible(element1, false)
		LuaUIUtils.setUIViewVisible(element2, false)
	elseif #elementNames == 1 then
		LuaUIUtils.setUIViewVisible(element1, true)
		LuaUIUtils.setUIViewVisible(element2, false)
		LuaUIUtils.setElementButtonNew(element1, elementNames[1].element)
	else
		LuaUIUtils.setUIViewVisible(element1, true)
		LuaUIUtils.setUIViewVisible(element2, true)
		LuaUIUtils.setElementButtonNew(element1, elementNames[1].element)
		LuaUIUtils.setElementButtonNew(element2, elementNames[2].element)
	end
end

function PetListUIComponent:refreshPetBtnState(petIdx, isMobile)
	if petIdx <= 0 then
		return
	end

	local btnRefInfo = self.petBtnRefList[petIdx]
	local button = btnRefInfo.button

	if not button then
		return
	end

	local player = pg.me
	local curIndex = player.curIndex
	local isCurPetSelected = curIndex == petIdx
	local isControlState = player.controlState == Const.CONTROL_STATE_CONTROL

	if pg.game.controller:isInDelayExit() then
		button:TryChangePage("State", "Normal")
	elseif pg.pawn.isInBuffControlST then
		button:TryChangePage("State", "Disable")
	elseif player.clientExploreEntId or CharacterStateConst.isExploreState(pg.pawn.characterState) or CharacterStateConst.isChildOfState(pg.pawn.characterState, CharacterStateConst.FLYING) or CharacterStateConst.isChildOfState(pg.pawn.characterState, CharacterStateConst.FALL) then
		if isCurPetSelected and isControlState then
			if not isMobile then
				button:TryChangePage("State", "Fusion")
			end
		else
			button:TryChangePage("State", "Disable")
		end
	elseif isCurPetSelected then
		if not isMobile then
			if isControlState then
				button:TryChangePage("State", "Fusion")
			else
				button:TryChangePage("State", "Select")
			end
		end
	else
		button:TryChangePage("State", "Normal")
	end

	if isCurPetSelected ~= btnRefInfo.isSelected then
		btnRefInfo.isSelected = isCurPetSelected

		if btnRefInfo.supportSkillVisible and btnRefInfo.skillUContainer then
			btnRefInfo.skillUContainer:SetActiveByOutOfView(not isCurPetSelected and btnRefInfo.supportSkillSceneValid)
		end
	end
end

function PetListUIComponent:refreshBuffList(btnObjectReference, petIdx)
	if btnObjectReference == nil then
		btnObjectReference = self:getButtonObjRef(petIdx)
	end

	if btnObjectReference == nil then
		return
	end

	local listBuff = btnObjectReference:GetRefValue("listBuffUList")

	if not listBuff then
		return
	end

	function listBuff.luaRenderItem(b, i, d)
		BuffUIUtils.setBuffInfo(b, d)
	end

	function listBuff.luaClick(button, data)
		local info = data

		info.targetRect = button
		info.autoHor = true

		pg.global.ui:open(UIConst.UI_ID_COMMON_BUFF_INFO_TIP, info)
	end

	local petEnt = self.ctrl.model:getFollowPetEnt(petIdx)
	local buffs = petEnt and BuffUIUtils.getUIBuffList(petEnt, SysConfigData.teammateBuffCount or 4) or nil
	local visible = ToBool(buffs)

	if visible then
		listBuff:SetList(buffs)
	else
		listBuff:SetList({})
	end

	self.curPetBuffLists[petIdx] = buffs

	LuaUIUtils.setUIViewVisible(listBuff, visible)
end

function PetListUIComponent:refreshPetHp(btnObjectReference, petIdx)
	if btnObjectReference == nil then
		btnObjectReference = self:getButtonObjRef(petIdx)
	end

	if not btnObjectReference then
		return
	end

	local partnerInfo = pg.me.partnerList[petIdx]
	local barHPSlider = btnObjectReference:GetRefValue("barHPSlider")

	if barHPSlider then
		barHPSlider:ProgressHp(partnerInfo.curHp / partnerInfo.maxHp)
	end
end

function PetListUIComponent:refreshPetAlive(petIdx)
	local petBtn = self:getButtonByIdx(petIdx)

	self:refreshPetState(petBtn, petIdx)
end

function PetListUIComponent:refreshPetState(button, petIdx, ignoreCdCheck)
	if not button then
		return
	end

	local player = pg.me
	local pet = player.partnerList[petIdx]
	local curPetState = UIConst.PET_LIST_PET_STATE.NORMAL

	if pet.isAlive == false then
		curPetState = UIConst.PET_LIST_PET_STATE.DEAD
	elseif not ignoreCdCheck then
		local now = Time.secondCache
		local duration = (player.switchPetEndCDs[petIdx] or 0) - now

		if duration > 0 then
			curPetState = UIConst.PET_LIST_PET_STATE.CD
		end
	end

	local btnRefInfo = self.petBtnRefList[petIdx]

	if curPetState ~= btnRefInfo.petState then
		btnRefInfo.petState = curPetState

		button:TryChangePage("petState", curPetState)
	end
end

function PetListUIComponent:onSwitchPetCDUpdate(info)
	local player = pg.me
	local now = Time.secondCache

	for idx = 1, self.curPetMaxCnt do
		if info.petIdx == idx then
			local duration = player.switchPetEndCDs[idx] - now
			local button = self:getButtonByIdx(idx)
			local objectReference = self:getButtonObjRef(idx)
			local cd = objectReference:GetRefValue("cDUCountDown")
			local refreshUWidget = objectReference:GetRefValue("refreshUWidget")

			if duration > 0 and player.switchPetCD > 0 then
				if cd.luaFinished == nil then
					function cd.luaFinished()
						cd.gameObject:SetActiveEx(false)
						self:refreshPetState(button, idx, true)

						button.interactable = true

						if refreshUWidget then
							refreshUWidget:InvokeCallback(CS.XGUI.EInvokeTime.User1)
						end
					end
				end

				cd.gameObject:SetActiveEx(true)

				self.petBtnRefList[idx].petState = UIConst.PET_LIST_PET_STATE.CD

				button:TryChangePage("petState", "cd")
				cd:Stop()
				cd:Play(duration, player.switchPetCD, true)
			else
				cd.gameObject:SetActiveEx(false)
				self:refreshPetState(button, idx)

				button.interactable = true
			end
		end
	end
end

function PetListUIComponent:_initPetBtnListener(button, index)
	local btnObjRef = self.petBtnRefList[index].objRef
	local keyBinding = btnObjRef:GetRefValue("petBtnKeyBindingPro")

	keyBinding.actionPath = UIStringPool.getHudPetActionPath(index)

	if keyBinding.luaTrigger ~= nil then
		return
	end

	keyBinding.isVirtual = true

	function keyBinding.luaTrigger(inputInfo)
		if pg.game.input:isUsingGamepad() then
			local hudV2 = pg.global.ui.hudV2

			if hudV2 and hudV2.RD and hudV2.RD.skill and hudV2.RD.skill.blockEvents then
				return true
			end

			if pg.global.ui:checkUIOpen(UIConst.UI_ID_INTERACT_GESTURE) then
				return true
			end
		end

		if inputInfo.phase == "Performed" then
			button:OnClickSimulate()
		end
	end
end

function PetListUIComponent:onPlayerCombatStatusUpdate(status)
	self:refreshRecommendOnCombatChanged(status)

	if status == Const.COMBAT_STATUS_NORMAL then
		pg.global.ui.hatredArrowTip:enableDangerTips(false)
		pg.game.markShare:muteInfoStampSystem(false)
	elseif status == Const.COMBAT_STATUS_IN_COMBAT then
		pg.global.ui.hatredArrowTip:enableDangerTips(true)
		self:onTriggerCloseQuickSwitchPanel(false)
		pg.game.markShare:muteInfoStampSystem(true)
	end
end

function PetListUIComponent:showBtnRecommend(button, idx)
	local visible = LuaUIUtils.isResistInfoVisible()

	if not visible then
		self:hideBtnRecommend(button, idx)

		return
	end

	local lockedActorId = pg.me.lockedActorId or 0
	local lockedEnt = pg.getEntityByActorId(lockedActorId)
	local isLock = Utils.getLockState(pg.me) == AbilityConst.LockState.Lock
	local petData = self.petInfoList[idx]

	if not lockedEnt or not petData then
		self:hideBtnRecommend(button, idx)

		return
	end

	local factor = Utils.getElementAgainstValue(petData.mainElementType, lockedEnt.elementTypes)

	if (isLock or pg.me:isInCombat()) and factor > 1 then
		if self.recommendTimer[idx] then
			TimerManager.removeTimer(self.recommendTimer[idx])

			self.recommendTimer[idx] = nil
		end

		button:TryChangePage("ResistWarn", 1)

		self.recommendTimer[idx] = TimerManager.addTimer(UIConst.DISPLAY_RESIST_TIME, function()
			self:hideBtnRecommend(button, idx)
		end)
	else
		self:hideBtnRecommend(button, idx)
	end
end

function PetListUIComponent:hideBtnRecommend(button, idx)
	if self.recommendTimer[idx] then
		TimerManager.removeTimer(self.recommendTimer[idx])

		self.recommendTimer[idx] = nil
	end

	button:TryChangePage("ResistWarn", 0)
end

function PetListUIComponent:refreshRecommendOnCombatChanged(status)
	for idx = 1, self.curPetMaxCnt do
		local button = self:getButtonByIdx(idx)
		local visible = LuaUIUtils.isResistInfoVisible()

		if button then
			if visible and status == Const.COMBAT_STATUS_IN_COMBAT then
				self:showBtnRecommend(button, idx)
			else
				self:hideBtnRecommend(button, idx)
			end
		end
	end
end

function PetListUIComponent:getResistFactor(button, idx, lockedEnt)
	if not lockedEnt then
		return 1
	end

	local petData = self.petInfoList[idx]
	local factor = 1

	if petData.tIndex == 1 then
		local petEnt = pg.getEntity(petData.id)
		local coreAbilityElementType = 0

		if petEnt and petEnt.coreAbilityId ~= 0 then
			coreAbilityElementType = pg.global.abilityMgr:getAbilityParamData(petEnt.coreAbilityId).elementType or 0
		end

		factor = Utils.getElementAgainstValue(coreAbilityElementType, lockedEnt.elementTypes)
	else
		factor = Utils.getElementAgainstValue(petData.mainElementType, lockedEnt.elementTypes)
	end

	return factor
end

function PetListUIComponent:showBtnResist(button, idx)
	local visible = LuaUIUtils.isResistInfoVisible()
	local curResistState = UIConst.RESIST_STATE.NONE

	if visible then
		local lockedActorId = pg.me.lockedActorId or 0
		local lockedEnt = pg.getEntityByActorId(lockedActorId)
		local factor = self:getResistFactor(button, idx, lockedEnt)

		if factor > 1 then
			curResistState = UIConst.RESIST_STATE.HEAVY
		elseif factor < 1 then
			curResistState = UIConst.RESIST_STATE.LIGHT
		end
	end

	local btnRefInfo = self.petBtnRefList[idx]

	if btnRefInfo.resistState ~= curResistState then
		btnRefInfo.resistState = curResistState

		button:TryChangePage("Resist", curResistState)
	end
end

function PetListUIComponent:clickPet(index)
	if not self.showPetList then
		return
	end

	if pg.pawn.isInBuffControlST then
		self:onSwitchPetBlockByExploreST()

		return
	end

	pg.me:switchToPetByIndex(index, true)
end

function PetListUIComponent:refreshPetLevel(petIdx, level)
	local data = self.petInfoList[petIdx]

	if data.tIndex == 1 then
		return
	end

	if level == nil and not data.levelDirty then
		return
	end

	local levelNumText = self.petBtnRefList[petIdx].levelNum

	level = level or data.level
	data.level = level
	data.levelDirty = false

	ClientTextUtils.setText(levelNumText, level)
end

function PetListUIComponent:clearLevelUpCmdList(petIdx)
	local timer = self.petLevelUpTimer[petIdx]

	if ToBool(timer) then
		TimerManager.removeTimer(timer)
	end

	self.petLevelUpTimer[petIdx] = nil
	self.petLevelUpCmdList[petIdx] = nil
end

function PetListUIComponent:enterLevelUpInCatch(info)
	self.transform.parent.gameObject:SetActiveEx(true)
	self.transform.gameObject:SetActiveEx(true)
	self.panelUComponent:TryChangePage("Synopsis", 0)
	self.keyHintUWidget.gameObject:SetActiveEx(false)
	self.petUList.gameObject:SetActiveEx(true)

	for idx, entityId in ipairs(pg.me.petPrepareList) do
		local button = self:getButtonByIdx(idx)

		if button then
			local visible = true

			if info.petId == entityId then
				button.gameObject:SetActiveEx(visible)
			elseif not self.petLevelUpCmdList[idx] then
				button.gameObject:SetActiveEx(false)
			else
				button.gameObject:SetActiveEx(visible)
			end
		end
	end
end

function PetListUIComponent:isShowkeyHintUWidget()
	return self.showPetList and not pg.game.input:isUsingGamepad() and not pg.global.ui:runPlatformByMobile() and (not pg.space or not pg.space.isGrabEgg or not pg.space:isGrabEgg()) and not Utils.isSelfInSpaceDungeon()
end

function PetListUIComponent:leaveLevelUpInCatch()
	self.keyHintUWidget.gameObject:SetActiveEx(self:isShowkeyHintUWidget())

	for idx, id in ipairs(pg.me.petPrepareList) do
		local button = self:getButtonByIdx(idx)
		local visible = true

		if button then
			button.gameObject:SetActiveEx(visible)
		end
	end

	self.petUList.gameObject:SetActiveEx(not pg.me:CATCH_MODE_ST())
end

function PetListUIComponent:onPetLevel(info)
	if pg.me:CATCH_MODE_ST() then
		self:enterLevelUpInCatch(info)
	end

	local petId = info.petId
	local petIdx

	for idx, petInfo in ipairs(self.petInfoList) do
		if petInfo.id == petId then
			petIdx = idx

			break
		end
	end

	if petIdx == nil then
		return
	end

	local newLevel = info.newLevel
	local oldLevel = info.oldLevel
	local isLevelUp = oldLevel < newLevel

	if pg.global.ui:checkUIOpen(UIConst.UI_ID_PET_MANAGEMENT) then
		self:refreshPetLevel(petIdx, isLevelUp and newLevel or nil)

		return
	end

	if self.petLevelUpCmdList[petIdx] == nil then
		self.petLevelUpCmdList[petIdx] = {}
	end

	local cmdList = self.petLevelUpCmdList[petIdx]

	if oldLevel == newLevel then
		cmdList[#cmdList + 1] = {
			isLevelUp = false,
			addExp = info.addExp,
			petId = petId
		}
	elseif isLevelUp then
		cmdList[#cmdList + 1] = {
			addExpInLevelUp = true,
			isLevelUp = false,
			addExp = info.addExp,
			petId = petId
		}
		cmdList[#cmdList + 1] = {
			isLevelUp = true,
			petId = petId,
			toLevel = newLevel
		}
	end

	if ToBool(self.petLevelUpTimer[petIdx]) == false then
		self:consumeLevelUpCmd(petIdx)
	end
end

function PetListUIComponent:consumeLevelUpCmd(petIdx)
	local cmdList = self.petLevelUpCmdList[petIdx]
	local button = self:getButtonByIdx(petIdx)
	local petInfo = self.petInfoList[petIdx]
	local isSupportPetBtn = petInfo and petInfo.tIndex == 1

	if not button or isSupportPetBtn then
		self:clearLevelUpCmdList(petIdx)

		return
	end

	if not self:checkLevelUpFxReadyAndPlay(petIdx) then
		return
	end

	local petLevelUpContent = self.petLevelUpContents[petIdx]

	LuaUIUtils.setUIViewVisible(petLevelUpContent, false)

	if not ToBool(cmdList) then
		petLevelUpContent:TryChangePage("Level", 0)

		return
	end

	local nextCmd = cmdList[1]

	if nextCmd == nil or petInfo == nil or nextCmd.petId ~= petInfo.id then
		self:clearLevelUpCmdList(petIdx)

		cmdList = nil

		self:refreshPetLevel(petIdx)

		return
	end

	local cmd = cmdList[1]

	if self.petLevelUpTimer[petIdx] then
		TimerManager.removeTimer(self.petLevelUpTimer[petIdx])

		self.petLevelUpTimer[petIdx] = nil
	end

	local objectReference = self:getButtonObjRef(petIdx)

	button:TryChangePage("Hint", 1)
	LuaUIUtils.setUIViewVisible(petLevelUpContent, true)

	local anim = self.petLevelUpObjRefs[petIdx]:GetRefValue("levelUpAnimation")
	local isLevelUp = cmd.isLevelUp
	local toLevel = cmd.toLevel
	local appearDuration = anim:GetClip(isLevelUp and "VX_Node_HUD_HP_Pet_LevelUp" or "VX_Node_HUD_HP_Pet_EXP_Get").length

	self.petLevelUpTimer[petIdx] = TimerManager.addTimer(appearDuration, function()
		table.remove(cmdList, 1)

		self.petLevelUpTimer[petIdx] = nil

		if #self.petLevelUpCmdList[petIdx] == 0 and pg.me:CATCH_MODE_ST() then
			button.gameObject:SetActiveEx(false)
		end

		button:TryChangePage("Hint", 0)

		if isLevelUp then
			self:refreshPetLevel(petIdx, toLevel)
		end

		self:consumeLevelUpCmd(petIdx)
	end)

	if not isLevelUp then
		petLevelUpContent:TryChangePage("Level", 0)
		petLevelUpContent:TryChangePage("Level", 1)
		pg.game.audio:triggerEvent("SFX_UI_Battle_GetExp")

		local txtExp = self.petLevelUpObjRefs[petIdx]:GetRefValue("textNumUSDFText")

		if cmd.addExp then
			ClientTextUtils.setText(txtExp, cmd.addExp)
		else
			ClientTextUtils.setText(txtExp, "")
		end
	else
		petLevelUpContent:TryChangePage("Level", 2)

		local txtLevel = self.petLevelUpObjRefs[petIdx]:GetRefValue("textLevelUSDFText")
		local player = pg.me
		local petId = player.petPrepareList[petIdx]
		local level = toLevel or player:getPetInfo(petId).level

		ClientTextUtils.setText(txtLevel, string.format("Lv.%s", level))
		pg.game.audio:triggerEvent("SFX_UI_ParmonUpgrade")

		local petEnt = pg.getEntity(pg.me.petPrepareList[petIdx])

		if petEnt then
			petEnt:playEffect("Eff_Parmon_LevelUp")

			if pg.global.ui:runPlatformByMobile() then
				self:playLevelUpMobile(petEnt, level)
			end
		end
	end
end

function PetListUIComponent:playLevelUpMobile(petEnt, level)
	local petLevelUpComp = petEnt.ensureToplogoComponent and petEnt:ensureToplogoComponent(UIConst.TOPLOGO_COMPONENT.PET_LEVEL_UP)

	if petLevelUpComp then
		petLevelUpComp:playPetLevelUp(level)
	end

	facade:sendMsgToUI(MessageName.PET_LEVEL_UP_ARROW, level)
end

function PetListUIComponent:showHealEffect(button, idx)
	button = button or self:getButtonByIdx(idx)

	if button == nil then
		return
	end

	if self.lastShowHealEffectTimeMap[idx] then
		return
	end

	button:TryChangePage("recover", "none")
	button:TryChangePage("recover", "recover")

	self.lastShowHealEffectTimeMap[idx] = TimerManager.addTimer(1.5, function()
		self.lastShowHealEffectTimeMap[idx] = nil

		if NotNil(button) then
			button:TryChangePage("recover", "none")
		end
	end)
end

function PetListUIComponent:refreshQuickSwitchPetTeamVisible(formCntDirty)
	local visible = self:getQuickSwitchPetTeamVisible(formCntDirty)

	if visible ~= self.showQuickSwitchPetTeam then
		self.showQuickSwitchPetTeam = visible

		LuaUIUtils.setUIViewVisible(self.keyHintUWidget, visible)
	end
end

function PetListUIComponent:getQuickSwitchPetTeamVisible(formCntDirty)
	local player = pg.me
	local isInRogue = player and player.space and player.space:isRogueEnv()
	local isGrabEgg = pg.space and pg.space:isGrabEgg()
	local isNpcDuel = pg.space and pg.space:isNpcDuel()

	if formCntDirty then
		self.prepareFormationCnt = Utils.getPetPrepareFormationCnt(player)
	end

	return self.showPetList and player.petTeamType == Const.PET_TEAM_TYPE_DEFAULT and self.prepareFormationCnt > 1 and not isInRogue and not isGrabEgg and not isNpcDuel and not Utils.isSelfInSpaceDungeon()
end

function PetListUIComponent:initQuickSwitchPetTeamView()
	self:refreshQuickSwitchPetTeamVisible(true)

	local switchPetKey = "Hud/SwitchPetTeam"

	self.switchPetTeamHotKeyContent:SetHotKeyPaths(switchPetKey)

	function self.keyUButton.luaClick()
		if pg.game.input:isUsingGamepad() then
			-- block empty
		else
			self:openQuickSwitchPetTeamPanel()
		end
	end

	local keyBinding = KeyBindingPro.GetOrAddKeyBindingByName(self.keyUButton.gameObject, "quickSwitchPetTeamBtn")

	keyBinding.actionPath = switchPetKey
	keyBinding.isVirtual = true

	function keyBinding.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			if pg.game.input:isUsingGamepad() then
				-- block empty
			else
				self:openQuickSwitchPetTeamPanel()
			end

			return false
		end

		return true
	end

	if self.quickSwitchPetTeamUList ~= nil then
		self:setQuickSwitchPetTeamList()
	end

	self:addExitPanelTrigger("ExitByESC", "Common/Cancel", false)
	self:addExitPanelTrigger("ExitByV", switchPetKey, true)
	self:addExitPanelTrigger("ExitByLeftButton", "Common/MouseLeftButton", true)
end

function PetListUIComponent:setQuickSwitchPetTeamList()
	self.keyHotKeyContent:SetHotKeyPaths("Hud/InteractScroll")

	local scrollBinding = KeyBindingPro.GetOrAddKeyBindingByName(self.quickSwitchTeamPanelTransform.gameObject, "quickSwitchPetTeamScroll")

	scrollBinding.actionPath = "Hud/InteractScroll"
	scrollBinding.isVirtual = true

	function scrollBinding.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			local deltaZoom = inputInfo.valueVec2.y

			if self:triggerOnMouseScroll(deltaZoom) then
				return false
			end
		end

		return true
	end

	function self.quickSwitchPetTeamUList.luaRenderItem(button, index, data)
		self:setupPetTeamEntry(button, index, data)
	end

	function self.quickSwitchPetTeamUList.luaSelectedChanged(uList)
		if self.lastQuickSwitchSelectIndex == self.curQuickSwitchSelectIndex then
			return
		end

		if self.lastQuickSwitchSelectIndex then
			local ret, lastSelectedBtn = uList:TryGetChildAt(self.lastQuickSwitchSelectIndex)

			if ret then
				self:refreshPetCellSelected(lastSelectedBtn)
			end
		end

		if self.curQuickSwitchSelectIndex then
			local ret, curSelectedBtn = uList:TryGetChildAt(self.curQuickSwitchSelectIndex)

			if ret then
				self:refreshPetCellSelected(curSelectedBtn)
			end
		end
	end

	function self.quickSwitchPetTeamUList.luaClick(button, data)
		self.lastQuickSwitchSelectIndex = self.curQuickSwitchSelectIndex
		self.curQuickSwitchSelectIndex = data.index - 1

		self.quickSwitchPetTeamUList:GoToIndexMinCost(self.curQuickSwitchSelectIndex)
		self:onTriggerCloseQuickSwitchPanel(true)
	end

	function self.confirmUButton.luaClick()
		self:onTriggerCloseQuickSwitchPanel(true)
	end

	function self.exitUButton.luaClick()
		self:onTriggerCloseQuickSwitchPanel(false)
	end
end

function PetListUIComponent:setupPetTeamEntry(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local cellUComponent = objectReference:GetRefValue("cellUComponent")
	local teamNameText = objectReference:GetRefValue("teamNameText")
	local teamUList = objectReference:GetRefValue("teamUList")
	local keyHotKeyContent = objectReference:GetRefValue("keyHotKeyContent")
	local actionPath = string.format("Raw/KeyNum%d", index + 1 == 10 and 0 or index + 1)

	keyHotKeyContent:SetHotKeyPaths(actionPath)

	local keyBinding = KeyBindingPro.GetOrAddKeyBindingByName(self.quickSwitchTeamPanelTransform.gameObject, index + 1)

	keyBinding.actionPath = actionPath
	keyBinding.isVirtual = true

	function keyBinding.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self.lastQuickSwitchSelectIndex = self.curQuickSwitchSelectIndex
			self.curQuickSwitchSelectIndex = index

			self.quickSwitchPetTeamUList:GoToIndexMinCost(self.curQuickSwitchSelectIndex)
			self:onTriggerCloseQuickSwitchPanel(true)
		end

		return true
	end

	function teamUList.luaRenderItem(button, index, data)
		if data.tIndex ~= 1 then
			self:setupPetCellInfo(button, index, data)
		end
	end

	if button.isSelected then
		cellUComponent:TryChangePage("Select", 1)
	else
		cellUComponent:TryChangePage("Select", 0)
	end

	if string.isNilOrEmpty(data.teamName) then
		ClientTextUtils.setText(teamNameText, string.format("%s %d", pg.getGameString("DEFAULT_TEAM_NAME"), index + 1))
	else
		ClientTextUtils.setText(teamNameText, data.teamName)
	end

	teamUList:SetList(data.petsData)
end

function PetListUIComponent:refreshPetCellSelected(button)
	local objectReference = button:GetComponent("ObjectReference")
	local cellUComponent = objectReference:GetRefValue("cellUComponent")

	if button.isSelected then
		cellUComponent:TryChangePage("Select", 1)
	else
		cellUComponent:TryChangePage("Select", 0)
	end
end

function PetListUIComponent:setupPetCellInfo(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local iconUrl = LuaUIUtils.getPetIcon(data.iconName, LuaUIUtils.PET_ICON, data.label, data.gender)

	iconUImage.url = iconUrl

	LuaUIUtils.showPetCellElements(objectReference, data.elementNames)
end

function PetListUIComponent:addExitPanelTrigger(name, actionPath, isSelect)
	local keyBinding = KeyBindingPro.GetOrAddKeyBindingByName(self.quickSwitchTeamPanelTransform.gameObject, name)

	keyBinding.actionPath = actionPath
	keyBinding.isVirtual = true
	keyBinding.priority = 1

	function keyBinding.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:onTriggerCloseQuickSwitchPanel(isSelect)

			return false
		end

		return true
	end
end

function PetListUIComponent:onTriggerCloseQuickSwitchPanel(isSelect)
	if isSelect and pg.me then
		if pg.me:isInCombat() then
			pg.global.showBubbleMessage(NoticeDef.SWITCH_PET_IN_COMBAT)
		elseif pg.me:isControllingExploreEnt() then
			pg.global.showBubbleMessage(NoticeDef.CANNOT_SWITCH_PET_IN_STATE)
		else
			local curSelectedIndex = self.curQuickSwitchSelectIndex + 1

			if curSelectedIndex <= #self.curPetTeamFormationData then
				local selectedFormationIndex = self.curPetTeamFormationData[curSelectedIndex].index

				if selectedFormationIndex ~= pg.me.curPetFormationIndex and pg.pawn and Utils.isPet(pg.pawn) and pg.pawn.stopFly then
					pg.pawn:stopFly()
				end

				pg.me:serverMsg("RPC_CS_SelectPrepareFormation", selectedFormationIndex)
			end
		end
	end

	if self.panelUComponent then
		self.panelUComponent:TryChangePage("TeamSel", 0)
	end

	if pg.me then
		pg.me.forbidCameraZoom = false
	end

	pg.global.ui.interact:setUIHide(UIConst.UI_HIDE_KEY.PET_TEAM_QUICK_SWITCH, false)
end

function PetListUIComponent:triggerOnMouseScroll(deltaZoom)
	self.lastQuickSwitchSelectIndex = self.curQuickSwitchSelectIndex

	if deltaZoom > 0 then
		self.curQuickSwitchSelectIndex = math.max(0, self.curQuickSwitchSelectIndex - 1)
	else
		self.curQuickSwitchSelectIndex = math.min(self.curQuickSwitchMaxIndex, self.curQuickSwitchSelectIndex + 1)
	end

	self.quickSwitchPetTeamUList:GoToIndexMinCost(self.curQuickSwitchSelectIndex)
end

function PetListUIComponent.canOpenQuickSwitchPetTeamPanel()
	if not pg.me or pg.me:isInCombat() then
		return false
	end

	if pg.space and pg.space.isGrabEgg and pg.space:isGrabEgg() then
		return false
	end

	return true
end

function PetListUIComponent:openQuickSwitchPetTeamPanel()
	if not PetListUIComponent.canOpenQuickSwitchPetTeamPanel() then
		return
	end

	local player = pg.me

	if not player then
		return
	end

	local curPetFormationIndex = player.curPetFormationIndex

	self.panelUComponent:TryChangePage("TeamSel", 1)

	local petTeamFormationData = LuaUIUtils.getAllPetPrepareBattleTeamInfo(true)

	self.curQuickSwitchMaxIndex = #petTeamFormationData - 1
	self.curPetTeamFormationData = petTeamFormationData
	self.lastQuickSwitchSelectIndex = nil
	self.curQuickSwitchSelectIndex = 0

	for idx, data in ipairs(petTeamFormationData) do
		if data.index == curPetFormationIndex then
			self.curQuickSwitchSelectIndex = idx - 1

			break
		end
	end

	self.quickSwitchPetTeamUList:SetList(petTeamFormationData)
	self.quickSwitchPetTeamUList:SelectItem(self.curQuickSwitchSelectIndex)
	self.quickSwitchPetTeamUList:GoToIndex(self.curQuickSwitchSelectIndex, true)

	player.forbidCameraZoom = true

	pg.global.ui.interact:setUIHide(UIConst.UI_HIDE_KEY.PET_TEAM_QUICK_SWITCH, true)
end

function PetListUIComponent:getValidShieldPetIdx(petEnt)
	if not petEnt then
		return 0
	end

	local player = pg.me

	if not player or not player.petPrepareList then
		return
	end

	local refreshPetIdx = 0

	for idx, petId in pairs(player.petPrepareList) do
		if petId == petEnt.id then
			refreshPetIdx = idx

			break
		end
	end

	return refreshPetIdx
end

function PetListUIComponent:refreshPetShieldByPetEnt(petEnt)
	local refreshPetIdx = self:getValidShieldPetIdx(petEnt)

	if refreshPetIdx == 0 then
		return
	end

	self:refreshPetShield(nil, refreshPetIdx, petEnt)
end

function PetListUIComponent:refreshPetShield(btnObjectReference, petIdx, petEnt)
	if petIdx <= 0 or not petEnt then
		return
	end

	local objectReference = self.petBtnRefList[petIdx].objRef
	local barShieldUSlider = self.petBtnRefList[petIdx].barShieldUSlider

	if barShieldUSlider == nil then
		barShieldUSlider = objectReference:GetRefValue("barShieldUSlider")
		self.petBtnRefList[petIdx].barShieldUSlider = barShieldUSlider
	end

	local barShieldUWidget = self.petBtnRefList[petIdx].barShieldUWidget

	if barShieldUWidget == nil then
		barShieldUWidget = objectReference:GetRefValue("barShieldUWidget")
		self.petBtnRefList[petIdx].barShieldUWidget = barShieldUWidget
	end

	local barShieldAnimation = self.petBtnRefList[petIdx].barShieldAnimation

	if barShieldAnimation == nil then
		barShieldAnimation = objectReference:GetRefValue("barShieldAnimation")
		self.petBtnRefList[petIdx].barShieldAnimation = barShieldAnimation
	end

	if not barShieldUSlider or not barShieldUWidget then
		return
	end

	local curShieldPoint = 0
	local maxShieldPoint = 0
	local isShieldExist = false
	local shieldDataList = petEnt and petEnt.shieldDataList or {}

	for i = #shieldDataList, 1, -1 do
		local shieldData = shieldDataList[i]

		if shieldData.curPoint > 0 then
			curShieldPoint = math.max(curShieldPoint, shieldData.curPoint)
			petEnt.shieldMaxPointMap = petEnt.shieldMaxPointMap or {}
			maxShieldPoint = math.max(petEnt.shieldMaxPointMap[shieldData.buffInsId] or 0, curShieldPoint)
			petEnt.shieldMaxPointMap[shieldData.buffInsId] = maxShieldPoint
			isShieldExist = true

			break
		end
	end

	if not isShieldExist or curShieldPoint <= 0 then
		local masterEntity = petEnt:getMasterEntity()
		local masterShieldDataList = masterEntity.shieldDataList or {}

		for i = #masterShieldDataList, 1, -1 do
			local shieldData = masterShieldDataList[i]

			if shieldData.curPoint > 0 then
				curShieldPoint = math.max(curShieldPoint, shieldData.curPoint)
				masterEntity.shieldMaxPointMap = masterEntity.shieldMaxPointMap or {}
				maxShieldPoint = math.max(masterEntity.shieldMaxPointMap[shieldData.buffInsId] or 0, curShieldPoint)
				masterEntity.shieldMaxPointMap[shieldData.buffInsId] = maxShieldPoint
				isShieldExist = true

				break
			end
		end
	end

	local isActived = self.petSheildActiveRecords[petIdx] or false
	local isInBreaking = self.petSheildIsInBreakRecords[petIdx] or false

	if isShieldExist then
		if isActived and isInBreaking then
			self:killPetShieldBreakTimer(petIdx)

			isActived = false
		end

		if not isActived then
			LuaUIUtils.setUIViewVisible(barShieldUWidget, true)

			if barShieldAnimation then
				barShieldAnimation:Play("VX_Node_HUD_HP_Pet_BarShield_In")
			end
		end

		self.petSheildActiveRecords[petIdx] = true
	end

	local shieldPointRatio = 0

	if isShieldExist then
		maxShieldPoint = math.max(maxShieldPoint, 0.01)
		shieldPointRatio = math.clamp(curShieldPoint / maxShieldPoint, 0, 1)
	end

	barShieldUSlider:ProgressHp(shieldPointRatio)
end

function PetListUIComponent:refreshPetShieldBreakByPetEnt(petEnt)
	local refreshPetIdx = self:getValidShieldPetIdx(petEnt)

	if refreshPetIdx == 0 then
		return
	end

	self:refreshPetShieldBreak(nil, refreshPetIdx, petEnt)
end

function PetListUIComponent:refreshPetShieldBreak(btnObjectReference, petIdx, petEnt)
	if petIdx <= 0 or not petEnt then
		return
	end

	if self.petSheildIsInBreakRecords[petIdx] then
		return
	end

	local barShieldUWidget = self.petBtnRefList[petIdx].barShieldUWidget

	if barShieldUWidget == nil then
		local objectReference = self.petBtnRefList[petIdx].objRef

		barShieldUWidget = objectReference:GetRefValue("barShieldUWidget")
		self.petBtnRefList[petIdx].barShieldUWidget = barShieldUWidget
	end

	if not barShieldUWidget then
		return
	end

	local button = self.petBtnRefList[petIdx].button

	self.petSheildIsInBreakRecords[petIdx] = true

	local isActived = self.petSheildActiveRecords[petIdx] or false

	if isActived and button then
		button:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)

		self.delayHideBarShieldTimers[petIdx] = TimerManager.addTimer(0.5, function()
			self:killPetShieldBreakTimer(petIdx)
		end)
	end
end

function PetListUIComponent:killPetShieldBreakTimer(petIdx)
	if petIdx <= 0 then
		return
	end

	local barShieldUWidget = self.petBtnRefList[petIdx].barShieldUWidget

	if barShieldUWidget == nil then
		local objectReference = self.petBtnRefList[petIdx].objRef

		barShieldUWidget = objectReference:GetRefValue("barShieldUWidget")
		self.petBtnRefList[petIdx].barShieldUWidget = barShieldUWidget
	end

	if barShieldUWidget then
		LuaUIUtils.setUIViewVisible(barShieldUWidget, false)
	end

	self.petSheildActiveRecords[petIdx] = false
	self.petSheildIsInBreakRecords[petIdx] = false

	local timerId = self.delayHideBarShieldTimers and self.delayHideBarShieldTimers[petIdx]

	if timerId then
		TimerManager.removeTimer(timerId)
	end

	self.delayHideBarShieldTimers[petIdx] = nil
end

function PetListUIComponent:onPetFormationModified()
	self:refreshQuickSwitchPetTeamVisible(true)
end

function PetListUIComponent:onPetCrownStateChange(info)
	if not self.petInfoList then
		return
	end

	local changedPetId = info and info.petId

	for petIdx = 1, MAX_PET_COUNT do
		local data = self.petInfoList[petIdx]

		if data and data.id and (not changedPetId or data.id == changedPetId) then
			local objectReference = self:getButtonObjRef(petIdx)

			self:refreshPetCrown(objectReference, data, true)
		end
	end
end

function PetListUIComponent:registerSupportPetSkillBtn(skillBtn, petBtn, petIdx)
	skillBtn.enabledLongPress = true

	function skillBtn.luaBeginLongPress()
		local curPetEntity = Utils.getPlayerPetByTeamIndex(pg.me, petIdx)

		if not curPetEntity or curPetEntity.coreAbilityId == 0 then
			return
		end
	end

	function skillBtn.luaPress()
		if not self.showPetList then
			return
		end

		local curPetEntity = Utils.getPlayerPetByTeamIndex(pg.me, petIdx)

		if not curPetEntity or curPetEntity.coreAbilityId == 0 then
			pg.global.showBubbleMessageById(NoticeDef.NOT_EQUIP_SUPPORT_SKILL)
			petBtn:InvokeCallback(CS.XGUI.EInvokeTime.User2)

			return
		end

		pg.game.controller.longPressMap[curPetEntity.coreAbilityId] = Time.secondCache

		local abilityId = curPetEntity.coreAbilityId
		local endSwitch = curPetEntity:tryStopSwitchAbility(abilityId)

		if endSwitch then
			return
		end

		local rePressSkillSlotInfo = curPetEntity.rePressSkillSlotInfo and curPetEntity.rePressSkillSlotInfo[abilityId]

		if rePressSkillSlotInfo and curPetEntity:getGameTime() < rePressSkillSlotInfo.endTime then
			curPetEntity:serverMsg("RPC_CS_RePressSkillSlot", abilityId)
			curPetEntity.subject:notify(AbilityConst.COMBAT_EVENT_ON_RE_PRESS_SKILL_SLOT, abilityId)

			return
		end

		local lockedActorId = pg.me.lockedActorId ~= 0 and pg.me.lockedActorId or nil
		local result, reason = curPetEntity:checkCanCastAbility(abilityId, lockedActorId)

		if not result then
			local noticeId = Utils.abilityReason2noticeId(reason)

			if NoticeDef.FAIL ~= noticeId then
				pg.global.showBubbleMessageById(noticeId)
			end
		else
			pg.me:switchToPetByIndex(petIdx, true, abilityId)
		end
	end

	function skillBtn.luaRelease()
		local curPetEntity = Utils.getPlayerPetByTeamIndex(pg.me, petIdx)

		if not curPetEntity or curPetEntity.coreAbilityId == 0 then
			return
		end

		local abilityId = curPetEntity.coreAbilityId

		curPetEntity:stopChargeByAbilityId(abilityId)

		pg.game.controller.longPressMap[curPetEntity.coreAbilityId] = nil
	end
end

function PetListUIComponent:onModuleEnableChanged(changeInfo)
	local moduleKey = changeInfo.moduleKey

	if moduleKey == ClientConst.ModuleKey.PetList then
		self:refreshPetListVisible()
	end
end

function PetListUIComponent:onExtraTempPetStateChange()
	self:refreshPetListVisible()
end

function PetListUIComponent:refreshPossessHp(petIdx, ov, nv)
	if petIdx > 0 then
		self:refreshPetHp(nil, petIdx)
	end
end

function PetListUIComponent:refreshPetListOnLockedTgtChange()
	for idx = 1, self.curPetMaxCnt do
		local button = self:getButtonByIdx(idx)

		if button then
			self:showBtnResist(button, idx)
			self:showBtnRecommend(button, idx)
		end
	end
end

function PetListUIComponent:refreshChangeState(abilityId)
	local player = pg.me

	if not player then
		return
	end

	for i = 1, self.curPetMaxCnt do
		local petEntity = Utils.getPlayerPetByTeamIndex(player, i)

		if petEntity and petEntity.coreAbilityId == abilityId then
			local button = self:getButtonByIdx(i)

			if button then
				local data = self.petInfoList[i]

				if data.tIndex == 0 then
					local skillUContainer = self.petBtnRefList[i].skillUContainer

					self:refreshPetSupportSkillBtnState(skillUContainer, i)
				elseif data.tIndex == 1 then
					self:refreshSupportPet(button, i)
				end
			end
		end
	end
end

function PetListUIComponent:onBuffChange(info)
	local petIdx, isTeamBuff = self:m_checkBuffMsgRespond(info)

	if petIdx then
		self:refreshBuffList(nil, petIdx)
	elseif isTeamBuff then
		for i = 1, self.curPetMaxCnt do
			self:refreshBuffList(nil, i)
		end
	end
end

function PetListUIComponent:m_checkBuffMsgRespond(info)
	if not info then
		return nil, false
	end

	local entId = info.entId

	if not entId then
		return nil, false
	end

	local ret, idx = ClientUtils.checkPetIsFollowPet(entId)

	if ret then
		return idx, false
	end

	if info.isTeamBuff then
		return nil, true
	end

	return nil, false
end

function PetListUIComponent:m_getPartnerBuffUList(petIdx)
	local btnObjectReference = self:getButtonObjRef(petIdx)

	if not btnObjectReference then
		return nil
	end

	return btnObjectReference:GetRefValue("listBuffUList")
end

function PetListUIComponent:onBuffAdd(info)
	local buffData = info and info.newBuffData

	if not buffData then
		return
	end

	local petIdx, isTeamBuff = self:m_checkBuffMsgRespond(info)

	if petIdx then
		self:m_addBuffForPet(petIdx, buffData)
	elseif isTeamBuff then
		for i = 1, self.curPetMaxCnt do
			self:m_addBuffForPet(i, buffData)
		end
	end
end

function PetListUIComponent:m_addBuffForPet(petIdx, buffData)
	local petEnt = self.ctrl.model:getFollowPetEnt(petIdx)

	if not petEnt then
		return
	end

	self.curPetBuffLists[petIdx] = self.curPetBuffLists[petIdx] or {}

	local curList = self.curPetBuffLists[petIdx]
	local listBuff = self:m_getPartnerBuffUList(petIdx)
	local buffInfo = BuffUIUtils._addBuffInfo(buffData, petEnt, {})

	if not buffInfo then
		return
	end

	local maxCount = SysConfigData.teammateBuffCount or 4
	local idx = BuffUIUtils.computeInsertIndex(curList, buffInfo, maxCount)

	if idx <= 0 then
		return
	end

	if maxCount <= #curList then
		BuffUIUtils.tryRemoveBuff(listBuff, curList, #curList)
	end

	BuffUIUtils.tryInsertBuff(listBuff, curList, idx, buffInfo)

	if listBuff then
		LuaUIUtils.setUIViewVisible(listBuff, true)
	end

	local should, delayTime, instanceId = BuffUIUtils.scheduleDisappearHint(self, buffInfo)

	if should then
		self.buffDisappearHintTimer[instanceId] = TimerManager.addTimer(delayTime, function()
			BuffUIUtils.invokeDisappearHintFx(self:m_getPartnerBuffUList(petIdx), curList, instanceId)
		end)
	end
end

function PetListUIComponent:onBuffRemove(info)
	if not info then
		return
	end

	BuffUIUtils.clearBuffDisappearHintTimer(self, info.buffInsId)

	local petIdx, isTeamBuff = self:m_checkBuffMsgRespond(info)

	if petIdx then
		self:m_removeBuffForPet(petIdx, info.buffInsId)
	elseif isTeamBuff then
		for i = 1, self.curPetMaxCnt do
			self:m_removeBuffForPet(i, info.buffInsId)
		end
	end
end

function PetListUIComponent:m_removeBuffForPet(petIdx, buffInsId)
	local curList = self.curPetBuffLists and self.curPetBuffLists[petIdx]

	if not curList then
		return
	end

	local idx = BuffUIUtils.findBuffIndex(curList, buffInsId)

	if idx > 0 then
		local listBuff = self:m_getPartnerBuffUList(petIdx)

		BuffUIUtils.tryRemoveBuff(listBuff, curList, idx)

		if listBuff and #curList == 0 then
			LuaUIUtils.setUIViewVisible(listBuff, false)
		end
	end
end

function PetListUIComponent:onBuffExpiredTimeChange(info)
	local petIdx, isTeamBuff = self:m_checkBuffMsgRespond(info)

	if petIdx then
		self:m_updateBuffExpiredTimeForPet(petIdx, info)
	elseif isTeamBuff then
		for i = 1, self.curPetMaxCnt do
			self:m_updateBuffExpiredTimeForPet(i, info)
		end
	end
end

function PetListUIComponent:m_updateBuffExpiredTimeForPet(petIdx, info)
	local curList = self.curPetBuffLists and self.curPetBuffLists[petIdx]

	if not curList then
		return
	end

	local listBuff = self:m_getPartnerBuffUList(petIdx)
	local buffInfo = BuffUIUtils.updateBuffExpiredTime(listBuff, curList, info)

	if buffInfo then
		local should, delayTime, instanceId = BuffUIUtils.rescheduleDisappearHint(self, buffInfo)

		if should then
			self.buffDisappearHintTimer[instanceId] = TimerManager.addTimer(delayTime, function()
				BuffUIUtils.invokeDisappearHintFx(self:m_getPartnerBuffUList(petIdx), curList, instanceId)
			end)
		end
	end
end

function PetListUIComponent:onBuffLayerChange(info)
	local entId = info.entId
	local ret, idx = ClientUtils.checkPetIsFollowPet(entId)

	if ret then
		self:invokeBuffLayerFx(info, idx)
	elseif info.isTeamBuff then
		for i = 1, self.curPetMaxCnt do
			self:invokeBuffLayerFx(info, i)
		end
	end
end

function PetListUIComponent:invokeBuffLayerFx(info, petIdx)
	local curBuffList = self.curPetBuffLists[petIdx]

	if not curBuffList then
		return
	end

	BuffUIUtils.applyLayerChange(self:m_getPartnerBuffUList(petIdx), curBuffList, info)
end

function PetListUIComponent:invokeBuffDelayHintFx(info, petIdx)
	local curBuffList = self.curPetBuffLists[petIdx]

	if not curBuffList then
		return
	end

	for index, buffInfo in ipairs(curBuffList) do
		if buffInfo.instanceId == info.newBuffData.instanceId then
			local btnObjectReference = self:getButtonObjRef(petIdx)
			local listBuff = btnObjectReference:GetRefValue("listBuffUList")
			local flag, buffBtn = listBuff:TryGetChildAt(index - 1)

			if flag then
				buffBtn:InvokeCallback(CS.XGUI.EInvokeTime.Custom5)
			end

			break
		end
	end
end

function PetListUIComponent:onShowPetHealEffect(petId)
	for idx, id in ipairs(pg.me.petPrepareList) do
		if id == petId then
			self:showHealEffect(nil, idx)
		end
	end
end

function PetListUIComponent:refreshHudPetListByEnt(ent)
	if not ent then
		return
	end

	local petIdx = ent.partnerIndex

	if petIdx == nil or petIdx <= 0 then
		return
	end

	local button = self:getButtonByIdx(petIdx)

	if not button then
		return
	end

	local petData = self.petInfoList[petIdx]

	if not petData then
		return
	end

	if petData.index == INVALID_ITEM then
		PetListUIUtils.fillFollowPetInfos(self.petInfoList)
	end

	if petData.tIndex == 0 then
		self:refreshPet(button, petIdx, petData)
	elseif petData.tIndex == 1 then
		self:refreshSupportPet(button, petIdx)
	end
end

function PetListUIComponent:refreshPetListOnBattleModeChange(mode)
	if self.spaceBattleMode == mode then
		return
	end

	local hasSupportPet = mode > 0

	for i = 1, self.curPetMaxCnt do
		local curPetInfo = self.petInfoList[i]

		if hasSupportPet and mode < i then
			curPetInfo.tIndex = 1
		else
			curPetInfo.tIndex = 0
		end
	end

	self.spaceBattleMode = mode
	self.spaceBattleModeDirty = true

	self:forceClearInfo()
	self:refreshHudPetList()
end

function PetListUIComponent:refreshPetListOnControlEntChange(info)
	local controlInputEvent = info.inputEvent

	if controlInputEvent == Const.EVENT_CLIENT_PRE_EXPLORE then
		self:refreshPetListOnDelayExploreChange()
	else
		local player = pg.me
		local playerInFuse = not player:isControllingMaster()

		if self.curPlayerInFuse ~= playerInFuse then
			self.curPlayerInFuse = playerInFuse

			self:refreshPetBtnState(self.curSelectedPetIndex)
		end

		if pg.pawn.isInBuffControlST then
			self:refreshPetListOnDelayExploreChange()
		end
	end
end

function PetListUIComponent:refreshPetListOnCombatPetChange(curIndex)
	if curIndex ~= self.curSelectedPetIndex then
		self:refreshPetBtnState(self.curSelectedPetIndex)
		self:refreshPetBtnState(curIndex)

		self.curSelectedPetIndex = curIndex
	end
end

function PetListUIComponent:refreshPetListOnDelayExploreChange()
	for i = 1, self.curPetMaxCnt do
		self:refreshPetBtnState(i)
	end
end

function PetListUIComponent:onCharacterStateChanged()
	if pg.me:EXTRA_TEMP_PET_ST() then
		return
	end

	for i = 1, self.curPetMaxCnt do
		self:refreshPetBtnState(i)
	end
end

function PetListUIComponent:onSwitchPetBlockByExploreST()
	for i = 1, self.curPetMaxCnt do
		local maskAnimation = self.petBtnRefList[i].maskAnimation

		if maskAnimation == nil then
			local objectReference = self.petBtnRefList[i].objRef

			maskAnimation = objectReference:GetRefValue("maskAnimation")
			self.petBtnRefList[i].maskAnimation = maskAnimation
		end

		if maskAnimation then
			maskAnimation:Play("VX_Node_HUD_HP_Pet_Shake")
		end
	end

	ClientUtils.showBubbleMessage(NoticeDef.SWITCH_PET_BLOCKED_BY_EXPLORE_ST)
end

function PetListUIComponent:_cachePetBtnComponent(button, idx)
	local objectReference = button:GetComponent("ObjectReference")
	local btnRefInfo = self.petBtnRefList[idx]

	btnRefInfo.button = button
	btnRefInfo.objRef = objectReference
	btnRefInfo.itemTryingUContainer = objectReference:GetRefValue("itemTryingUContainer")
	btnRefInfo.skillUContainer = objectReference:GetRefValue("btnSkillContainerUContainer")
	btnRefInfo.functionTypeIcon = objectReference:GetRefValue("functionTypeIcon")
	btnRefInfo.icon = objectReference:GetRefValue("iconUImage")
	btnRefInfo.levelNum = objectReference:GetRefValue("numUBaseText")
	btnRefInfo.bloodKeyHintUWidget = objectReference:GetRefValue("bloodKeyHintUWidget")

	local isSelected = pg.me.curIndex == idx

	btnRefInfo.isSelected = isSelected

	btnRefInfo.skillUContainer:SetActiveByOutOfView(not isSelected)

	btnRefInfo.supportSkillVisible = not isSelected

	local isMobile = pg.global.ui.uiMgr:CheckIsMobileInteract()

	if not isMobile then
		local vXGlowUContainer = objectReference:GetRefValue("vXGlowUContainer")

		vXGlowUContainer:LoadDefaultUrlManually()
	end
end

function PetListUIComponent:setBloodKeyHintVisible(visible)
	if not self.petBtnRefList then
		return
	end

	for i = 1, MAX_PET_COUNT do
		local btnRefInfo = self.petBtnRefList[i]

		if btnRefInfo and btnRefInfo.bloodKeyHintUWidget then
			btnRefInfo.bloodKeyHintUWidget.gameObject:SetActiveEx(visible)
		end
	end
end

function PetListUIComponent:_cacheSupportPetBtnComponent(button, idx)
	local objectReference = button:GetComponent("ObjectReference")
	local btnRefInfo = self.petBtnRefList[idx]

	btnRefInfo.button = button
	btnRefInfo.objRef = objectReference
	btnRefInfo.supportSkillBtn = objectReference:GetRefValue("btnSkillUButton")
	btnRefInfo.icon = objectReference:GetRefValue("imgPetUImage")
end

function PetListUIComponent:_cachePetSupportSkillComponent(button, idx)
	local objectReference = button:GetComponent("ObjectReference")
	local btnRefInfo = self.petBtnRefList[idx]

	btnRefInfo.petCoreAbilityId = nil
	btnRefInfo.supportSkillEpCost = nil
	btnRefInfo.petSupportSkillBtn = button
	btnRefInfo.petSupportSkillCountDown = objectReference:GetRefValue("cDUCountDown")
	btnRefInfo.petSupportSkillCountDownVisible = false
	btnRefInfo.iconSkillUImage = objectReference:GetRefValue("iconUImage")
	btnRefInfo.skillCostUSDFText = objectReference:GetRefValue("numUSDFText")
end

function PetListUIComponent:getButtonByIdx(index)
	return self.petBtnRefList[index].button
end

function PetListUIComponent:getButtonObjRef(index)
	return self.petBtnRefList[index].objRef
end

function PetListUIComponent:checkLevelUpFxReadyAndPlay(petIdx)
	if self.petLevelUpContents[petIdx] then
		return true
	end

	local objectReference = self.petBtnRefList[petIdx].objRef
	local levelUpUContainer = objectReference:GetRefValue("levelNewUContainer")

	levelUpUContainer:LoadDefaultUrlManually(function(content)
		self.petLevelUpContents[petIdx] = content
		self.petLevelUpObjRefs[petIdx] = self.petLevelUpContents[petIdx]:GetComponent("ObjectReference")

		self:consumeLevelUpCmd(petIdx)
	end)

	return false
end

function PetListUIComponent:forceClearInfo()
	for i = 1, MAX_PET_COUNT do
		lume.clear(self.petInfoList[i])

		self.petInfoList[i].id = false

		lume.clear(self.petBtnRefList[i])

		self.petBtnRefList[i].imgTryVisible = false
		self.petBtnRefList[i].resistState = UIConst.RESIST_STATE.NONE
		self.petBtnRefList[i].petState = UIConst.PET_LIST_PET_STATE.NORMAL
	end
end

function PetListUIComponent:playShowAnim()
	if self.showAnim then
		self.showAnim:InvokeCallback(CS.XGUI.EInvokeTime.Show)
	end
end

function PetListUIComponent:playHideAnim()
	if self.showAnim then
		self.showAnim:InvokeCallback(CS.XGUI.EInvokeTime.Hide)
	end
end

return PetListUIComponent
