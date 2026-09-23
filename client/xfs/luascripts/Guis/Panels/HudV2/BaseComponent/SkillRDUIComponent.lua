-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\SkillRDUIComponent.lua

local ClientConst = require("Const.ClientConst")
local Const = require("Common.Const.Const")
local AbilityConst = require("Common.Const.AbilityConst")
local AttributeConst = require("Common.Const.AttributeConst")
local HotkeyConst = require("Const.HotkeyConst")
local AddressDataConst = require("Const.AddressDataConst")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local SkillTagData = require("Data.skill_tag_data")
local Utils = require("Common.Utils.Utils")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local AbilityUIUtils = require("Utils.AbilityUIUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientUtils = require("Utils.ClientUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local MessageName = require("Const.MessageName")
local NoticeDef = require("Common.NoticeDef")
local lume = require("Core.Common.lume")
local UIStringPool = require("Guis.Utils.UIStringPool")
local TimerManager = require("Core.Timer.TimerManager")
local Time = require("Core.Common.Time")
local Class = require("Core.Framework.Class")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local RobEggSkillButtonUIComponent = require("Guis.Panels.HudV2.BaseComponent.RobEggSkillButtonUIComponent")
local SkillRDUIComponent = Class.LightClass("SkillRDUIComponent", HudBaseComponent)
local SceneData = require("Data.scene_data")
local LevelData = require("Data.level_data")
local UIConst = require("Const.UIConst")
local SandboxConst = require("Common.Const.SandboxConst")
local SysNoticeData = require("Data.sys_notice_data")
local EventConst = require("Const.EventConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local ToBool = ToBool
local MAX_SKILL_COUNT = 4
local EXPLORE_BTN_INDEX = 1
local NORMAL_ATTACK_BTN_INDEX = 2
local SKILLQ_BTN_INDEX = 3
local SKILLE_BTN_INDEX = 4

SkillRDUIComponent.messages = {
	[MessageName.ON_CONTROL_ENT] = {
		"refreshSkillListAndFinalSkill",
		true
	},
	[MessageName.PLAYER_CUR_SKILL_MAP] = {
		"onSkillMapChanged",
		true
	},
	[MessageName.PLAYER_PET_CUR_ABILITY_CHANGED] = {
		"onPetSkillMapChanged",
		true
	},
	[MessageName.PLAYER_COMBAT_STATUS_UPDATE] = {
		"onCombatStatusChange",
		true
	},
	[MessageName.SKILL_VISIBLE_CHANGE] = {
		"onSkillVisibleMapChange",
		true
	},
	[MessageName.MODULE_ENABLE_CHANGED] = {
		"onModuleEnableChanged",
		true
	},
	[MessageName.SPECIAL_ATTACK_MODE_CHANGE] = {
		"refreshCostState",
		true
	},
	[MessageName.ON_ABILITY_EP_COST_CHANGED] = {
		"refreshCostStateWithoutCD",
		true
	},
	[MessageName.SPECIAL_STATE_CHANGE] = {
		"onPawnStateChanged",
		true
	},
	[MessageName.MAIN_PLAYER_EP_CHANGE] = {
		"refreshPlayerEp",
		true
	},
	[MessageName.MAIN_PLAYER_SP_CHANGE] = {
		"onPlayerSpChange",
		true
	},
	[MessageName.LOCKED_TARGET_CHANGE] = {
		"onLockedTargetChange",
		true
	},
	[MessageName.SKILL_SWITCH_UPDATE] = {
		"refreshChangeState",
		true
	},
	[MessageName.ITEM_COUNT_MAP_CHANGE] = {
		"onInvItemChange",
		true
	},
	[MessageName.COMBAT_PET_CHANGED] = {
		"onCombatPetChange",
		true
	},
	[MessageName.COMBAT_PET_TEMPLATE_CHANGE] = {
		"onCurCombatPetTemplateChange",
		true
	},
	[MessageName.PREPARE_PETS_UPDATE] = {
		"onPreparePetsUpdate",
		true
	},
	[MessageName.SKILL_CD_END_TIME_UPDATE] = {
		"onSkillCdUpdate",
		true
	},
	[MessageName.GRAB_EGG_CHIP_SKILL_ID_CHANGED] = {
		"onChipSkillIdChanged",
		true
	},
	[MessageName.BACK_LIST_CHANGED] = {
		"onBackListChanged",
		true
	},
	[MessageName.REFRESH_SKILL_GRAY] = {
		"onRefreshSkillGray",
		true
	},
	[MessageName.MAIN_PET_ENTER_SPACE] = {
		"onMainPetEnterSpace",
		true
	},
	[MessageName.SYNC_TEAM_INFO] = {
		"refreshTeamInfo",
		true
	},
	[MessageName.SKILL_INTENSITY_CHANGE] = {
		"onSkillIntensityChange",
		true
	},
	[MessageName.NORMAL_ATTACK_SHOW_CHANGE] = {
		"onNormalAttackShowChange",
		true
	},
	[MessageName.SKILL_TAG_UPDATE] = {
		"onSkillTagChange",
		true
	},
	[MessageName.ROGUE_EXTRA_TEMP_PET_STATE_CHANGE] = {
		"onExtraTempPetStateChange",
		true
	},
	[MessageName.ROGUE_COMBAT_DATA_CHANGE] = {
		"onRogueCombatDataChange",
		true
	},
	[MessageName.ON_BUFF_FORBID_ABILITY_CHANGED] = {
		"onBuffForbidAbilityChanged",
		true
	},
	[MessageName.CONTROL_STATE_CHANGE] = {
		"onControlStateChange",
		true
	},
	[MessageName.VEHICLE_SHOW_STATE_CHANGED] = {
		"onVehicleShowStateChanged",
		true
	},
	[MessageName.MAGNESIS_MODE_CHANGE] = {
		"onMagnesisModeChange",
		true
	},
	[MessageName.PET_EXPLORE_SKILL_VAL_CHANGED] = {
		"refreshWaterStorage",
		true
	},
	[MessageName.PET_EXPLORE_STATE_CHANGED] = {
		"onPetExploreStateChange",
		true
	},
	[MessageName.DUNGEON_TEAMMATEVIEW_CHANGE] = {
		"onTeammateViewChange",
		true
	},
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

function SkillRDUIComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.baseSkillList = objectReference:GetRefValue("baseSkillList")
	self.listSkillAddonUList = objectReference:GetRefValue("listSkillAddonUList")
	self.bigSkillWidget = objectReference:GetRefValue("bigSkillWidget")
	self.finalSkillBtn = objectReference:GetRefValue("finalSkillBtn")
	self.finalSkillBtnObjRef = self.finalSkillBtn:GetComponent("ObjectReference")
	self.panelSkill = objectReference:GetRefValue("panelSkill")
	self.btnPetModeUButton = objectReference:GetRefValue("btnPetModeUButton")

	local petModeObjectReference = self.btnPetModeUButton:GetComponent("ObjectReference")

	self.petModeIcon0 = petModeObjectReference:GetRefValue("petModeIcon0")
	self.petModeIcon1 = petModeObjectReference:GetRefValue("petModeIcon1")
	self.petModeIcon2 = petModeObjectReference:GetRefValue("petModeIcon2")
	self.itemAddon = objectReference:GetRefValue("itemAddon")
	self.itemAddonBtn = RobEggSkillButtonUIComponent.new(self.itemAddon)

	self.itemAddonBtn:setExternalVisible(not pg.global.ui:runPlatformByMobile() and pg.space and pg.space:isGrabEgg())
	self.itemAddonBtn:setSkillId(pg.me and pg.me.chipSkillId)

	self.btnPetExChangeUContainer = objectReference:GetRefValue("btnPetExChangeUContainer")
	self.skillAddonSpeicalUContainer = objectReference:GetRefValue("skillAddonSpeicalUContainer")
	self.exploreSkillListUList = objectReference:GetRefValue("exploreSkillListUList")
	self.subSkillUWidget = objectReference:GetRefValue("subSkillUWidget")
end

function SkillRDUIComponent:initView()
	self:initSkillListNecessaryTable()
	self:initUIListener()
	self:initSkillListView()
	self:initFinalBtnRefInfo()
	self:initNormalAttackEvent()
	self:initPetActionMode()
	self:refreshSkillUIVisible()
	self:refreshSkillList()
	self:refreshFinalSkill()
	self:initSkillAddonBtn()
end

function SkillRDUIComponent:initSkillListView()
	local exploreSkillInfo = self.skillListInfo[EXPLORE_BTN_INDEX]
	local qSkillInfo = self.skillListInfo[SKILLQ_BTN_INDEX]
	local eSkillInfo = self.skillListInfo[SKILLE_BTN_INDEX]
	local normalSkillInfo = self.skillListInfo[NORMAL_ATTACK_BTN_INDEX]

	self.baseSkillList:SetList({
		normalSkillInfo,
		qSkillInfo,
		eSkillInfo
	})
	self.listSkillAddonUList:SetList({
		exploreSkillInfo
	})
end

function SkillRDUIComponent:initSkillListNecessaryTable()
	if jit then
		local table_new = require("table.new")

		self.skillListInfo = table_new(3, 0)
		self.skillBtnRefList = table_new(3, 0)
	else
		self.skillListInfo = {}
		self.skillBtnRefList = {}
	end

	for i = 1, MAX_SKILL_COUNT do
		self.skillListInfo[i] = {
			enableLuaStateCache = true,
			abilityId = AbilityConst.ABILITY_ID_EMPTY
		}
		self.skillBtnRefList[i] = {
			dataValid = false
		}
	end

	local exploreSkillInfo = self.skillListInfo[EXPLORE_BTN_INDEX]

	exploreSkillInfo.actionPath = AbilityConst.PLAYER_ABILITY_HOTKEY[AbilityConst.PLAYER_INITIATIVE_TYPE.INITIATIVE_T]
	exploreSkillInfo.isExploreSkill = true

	local qSkillInfo = self.skillListInfo[SKILLQ_BTN_INDEX]

	qSkillInfo.actionPath = AbilityConst.PLAYER_ABILITY_HOTKEY[AbilityConst.PLAYER_INITIATIVE_TYPE.INITIATIVE_Q]

	local eSkillInfo = self.skillListInfo[SKILLE_BTN_INDEX]

	eSkillInfo.actionPath = AbilityConst.PLAYER_ABILITY_HOTKEY[AbilityConst.PLAYER_INITIATIVE_TYPE.INITIATIVE_E]

	local normalSkillInfo = self.skillListInfo[NORMAL_ATTACK_BTN_INDEX]

	normalSkillInfo.actionPath = AbilityConst.PLAYER_ABILITY_HOTKEY[AbilityConst.PLAYER_INITIATIVE_TYPE.INITIATIVE_NORMAL]
	normalSkillInfo.isNormalAttack = true
	normalSkillInfo.visible = false

	local skillVisibleMap = pg.me and pg.me.skillVisibleMap

	if skillVisibleMap == nil then
		exploreSkillInfo.visible = true
		qSkillInfo.visible = true
		eSkillInfo.visible = true
	else
		exploreSkillInfo.visible = skillVisibleMap.T ~= false
		qSkillInfo.visible = skillVisibleMap.Q ~= false
		eSkillInfo.visible = skillVisibleMap.E ~= false
	end

	self.finalSkillInfo = {
		isFinalSkill = true,
		enableLuaStateCache = true
	}
	self.skillIntensityDatas = {}
	self.skillIntensityTimer = {}
	self.normalAttackShowMap = {}
end

function SkillRDUIComponent:initFinalBtnRefInfo()
	self.finalBtnRefInfo = {}
	self.finalBtnRefInfo.button = self.finalSkillBtn
	self.finalBtnRefInfo.allRightUcontainer = self.finalSkillBtnObjRef:GetRefValue("btnSkillsAllRightUContainer")

	self:getFinalSkillInfo()
	AbilityUIUtils.getSkillBtnRefInfo(self.finalSkillBtn, self.finalBtnRefInfo)
	AbilityUIUtils.setFinalSkillBtnInfo(self.finalBtnRefInfo, self.finalSkillInfo)

	if pg.global.ui:runPlatformByMobile() then
		AbilityUIUtils.registSkillBtnEventMobileClickVer(self.finalSkillBtn, self.finalSkillInfo)
	else
		AbilityUIUtils.registUltimateBtnEventNormal(self.finalSkillBtn, self.finalSkillInfo)
	end
end

function SkillRDUIComponent:initUIListener()
	function self.baseSkillList.luaRenderItem(button, index, data)
		local listIndex = index + 2
		local btnRefInfo = self:_cacheSkillBtnComponent(button, listIndex)

		AbilityUIUtils.setSkillBtnInfo(btnRefInfo, data)

		if not data.isNormalAttack then
			AbilityUIUtils.registSkillBtnEventNormal(button, data)
		end

		local skillBtnValid = data.abilityId ~= AbilityConst.ABILITY_ID_EMPTY

		btnRefInfo.dataValid = skillBtnValid

		button:SetActiveFastestAndMarkIgnoreLayout(data.visible and skillBtnValid)

		if skillBtnValid and data.gameObjectNameAbilityId ~= data.abilityId then
			data.gameObjectNameAbilityId = data.abilityId
			button.gameObject.name = data.abilityId
		end
	end

	function self.listSkillAddonUList.luaRenderItem(button, index, data)
		local listIndex = index + 1
		local btnRefInfo = self:_cacheSkillBtnComponent(button, listIndex)

		AbilityUIUtils.setSkillBtnInfo(btnRefInfo, data)
		AbilityUIUtils.registSkillBtnEventNormal(button, data)

		local skillBtnValid = data.abilityId ~= AbilityConst.ABILITY_ID_EMPTY

		btnRefInfo.dataValid = skillBtnValid

		self:refreshExploreBtnVisible()
		button:SetActiveFastestAndMarkIgnoreLayout(data.visible and skillBtnValid)

		if skillBtnValid and data.gameObjectNameAbilityId ~= data.abilityId then
			data.gameObjectNameAbilityId = data.abilityId
			button.gameObject.name = data.abilityId
		end
	end

	function self.exploreSkillListUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local txtNameUText = objectReference:GetRefValue("txtNameUText")
		local iconUImage = objectReference:GetRefValue("iconUImage")
		local btnNormalKeyBindingPro = objectReference:GetRefValue("btnNormalKeyBindingPro")

		ClientTextUtils.setText(txtNameUText, data.btnText or "")

		iconUImage.url = data.btnIcon or ""

		if btnNormalKeyBindingPro then
			btnNormalKeyBindingPro.actionPath = data.actionPath or ""
		end

		button.luaPress = data.luaPress
		button.luaRelease = data.luaRelease

		button:TryChangePage("button", data.isDisabled and 4 or 0)

		button.interactable = not data.isDisabled
	end

	if pg.me and pg.me:isInTeam() then
		function self.onSetActionState(actionState)
			if pg.me.inTeammateView then
				for id, info in pairs(pg.me:getCurTeamInfo().membersInfo) do
					if info.entityId ~= pg.me.id then
						local target = pg.getEntity(info.entityId)

						if target:isControllingPet() then
							local pet = target:getCurPetEntity()

							if pet then
								target = pet
							end
						end

						pg.game.camera:setTargetPlayer(target, 0)
					end
				end
			end
		end

		for id, info in pairs(pg.me:getCurTeamInfo().membersInfo) do
			if info.entityId ~= pg.me.id then
				local other = pg.getEntity(info.entityId)

				if other ~= nil and other.eventEmitter ~= nil then
					self.hasAddStateEvent = true

					other.eventEmitter:addEventListener(EventConst.PLAYER_ACTION_STATE_CHANGED, self.onSetActionState)
				end

				break
			end
		end
	end
end

function SkillRDUIComponent:initNormalAttackEvent()
	local attackKeyBinding = KeyBindingPro.GetOrAddKeyBindingByName(self.gameObject, "normalAttack")

	attackKeyBinding.isVirtual = true
	attackKeyBinding.actionPath = "Hud/NormalAttack"

	function attackKeyBinding.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			local normalAtkBtn = self:getValidSkillBtn(NORMAL_ATTACK_BTN_INDEX)

			if normalAtkBtn then
				normalAtkBtn:TryChangePage("button", 1)
			end

			AbilityUIUtils.handleNormalAttackActionPerformed(self)
		else
			local normalAtkBtn = self:getValidSkillBtn(NORMAL_ATTACK_BTN_INDEX)

			if normalAtkBtn then
				normalAtkBtn:TryChangePage("button", 0)
			end

			AbilityUIUtils.handleNormalAttackActionCanceled(self)
		end
	end
end

function SkillRDUIComponent:onDestroy()
	if self.inTeammateView then
		self:switchTeammateView()
	end

	if pg.me and pg.me:isInTeam() and self.hasAddStateEvent then
		self.hasAddStateEvent = false

		for id, info in pairs(pg.me:getCurTeamInfo().membersInfo) do
			if info.entityId ~= pg.me.id then
				local other = pg.getEntity(info.entityId)

				if other ~= nil and other.eventEmitter ~= nil then
					other.eventEmitter:removeEventListener(EventConst.PLAYER_ACTION_STATE_CHANGED, self.onSetActionState)
				end

				break
			end
		end
	end

	self.skillListInfo = nil
	self.skillBtnRefList = nil
	self.finalSkillInfo = nil
	self.finalBtnRefInfo = nil

	if self.skillIntensityDatas then
		for _, intensityDatas in pairs(self.skillIntensityDatas) do
			for _, intensityData in pairs(intensityDatas) do
				if intensityData.timer then
					TimerManager.removeTimer(intensityData.timer)

					intensityData.timer = nil
				end
			end
		end
	end

	self.skillIntensityDatas = nil
	self.skillIntensityTimer = nil
	self.normalAttackShowMap = nil

	HudBaseComponent.onDestroy(self)
end

function SkillRDUIComponent:_cacheSkillBtnComponent(button, idx)
	local objectReference = button:GetComponent("ObjectReference")
	local btnRefInfo = self.skillBtnRefList[idx]

	btnRefInfo.button = button
	btnRefInfo.objRef = objectReference

	local skillNameRoot = objectReference:GetRefValue("skillName")

	if skillNameRoot then
		btnRefInfo.skillNameRoot = skillNameRoot:GetComponent("UWidget")
	end

	btnRefInfo.skillName = objectReference:GetRefValue("txtNameUText")
	btnRefInfo.icon = objectReference:GetRefValue("iconUImage")
	btnRefInfo.keyBindingPro = objectReference:GetRefValue("keyBindingPro")
	btnRefInfo.pointListUContainer = objectReference:GetRefValue("pointListUContainer")
	btnRefInfo.countDown = objectReference:GetRefValue("cDUCountDown")
	btnRefInfo.maskMana = objectReference:GetRefValue("maskManaTransform")
	btnRefInfo.costRoot = objectReference:GetRefValue("costTransform")

	if NotNil(btnRefInfo.costRoot) then
		btnRefInfo.costNum = btnRefInfo.costRoot:Find("Num"):GetComponent("UBaseText")
	end

	btnRefInfo.itemNumber = objectReference:GetRefValue("itemNumber")
	btnRefInfo.switchSkillCountDown = objectReference:GetRefValue("countDownMultiSkillUCountDown")
	btnRefInfo.strengthenUContainer = objectReference:GetRefValue("vXStrengthenGlowUContainer")
	btnRefInfo.transUContainer = objectReference:GetRefValue("transUContainer")
	btnRefInfo.waterStorageUContainer = objectReference:GetRefValue("waterStorageUContainer")

	return btnRefInfo
end

function SkillRDUIComponent:getValidSkillBtn(index)
	local btnRefInfo = self.skillBtnRefList[index]

	return btnRefInfo.dataValid and btnRefInfo.button or nil
end

function SkillRDUIComponent:fillIntensityData(skillInfo)
	local intensityDatas = self.skillIntensityDatas[pg.pawn.actorId]
	local curAbilityId = self:tryGetCurAbilityId(skillInfo)
	local intensityData = intensityDatas and intensityDatas[curAbilityId]

	if intensityData then
		if intensityData.endTime ~= 0 and intensityData.endTime < Time.realSecondCache or not intensityData.isOpen then
			self.skillIntensityDatas[pg.pawn.actorId][curAbilityId] = nil
			skillInfo.intensityData = nil
		else
			skillInfo.intensityData = intensityData
		end
	else
		skillInfo.intensityData = nil
	end
end

function SkillRDUIComponent:cacheResistInfo()
	local resistVisible, resistTargetEntity = AbilityUIUtils.getResistInfo()

	for _, skillInfo in ipairs(self.skillListInfo) do
		skillInfo.resistVisible = resistVisible
		skillInfo.resistTargetEntity = resistTargetEntity
	end

	self.finalSkillInfo.resistVisible = resistVisible
	self.finalSkillInfo.resistTargetEntity = resistTargetEntity
end

function SkillRDUIComponent:refreshSkillList()
	local skillListInfo = self.skillListInfo

	if not skillListInfo then
		return
	end

	if SampleUtils.sampleOn() then
		SampleUtils.beginSample("SkillRDUIComponent.refreshSkillList")
	end

	self:refreshExploreBtnList()
	AbilityUIUtils.fillExploreSkillInfo(skillListInfo[EXPLORE_BTN_INDEX])
	AbilityUIUtils.fillCombatSkillInfo(skillListInfo[SKILLQ_BTN_INDEX], AbilityConst.PLAYER_INITIATIVE_TYPE.INITIATIVE_Q)
	AbilityUIUtils.fillCombatSkillInfo(skillListInfo[SKILLE_BTN_INDEX], AbilityConst.PLAYER_INITIATIVE_TYPE.INITIATIVE_E)
	AbilityUIUtils.fillNormalAttackSkillInfo(skillListInfo[NORMAL_ATTACK_BTN_INDEX])
	self:cacheResistInfo()

	for i = 1, MAX_SKILL_COUNT do
		local skillInfo = skillListInfo[i]
		local btnRefInfo = self.skillBtnRefList[i]
		local button = btnRefInfo.button
		local skillBtnValid = self:_refreshSkillBtnValid(button, i, skillInfo)

		if skillBtnValid then
			self:fillIntensityData(skillInfo)

			if i == NORMAL_ATTACK_BTN_INDEX then
				self:refreshNormalAttackBtn()
			else
				AbilityUIUtils.refreshSkillState(btnRefInfo, skillInfo)
			end
		end

		if skillBtnValid and skillInfo.gameObjectNameAbilityId ~= skillInfo.abilityId then
			skillInfo.gameObjectNameAbilityId = skillInfo.abilityId
			button.gameObject.name = skillInfo.abilityId
		end
	end

	if self.lastEntId ~= pg.pawn.id then
		self.lastEntId = pg.pawn.id

		self:reactiveSkillItems()
	end

	if SampleUtils.sampleOn() then
		SampleUtils.endSample()
	end

	self:refreshRogueSkill()
end

function SkillRDUIComponent:_refreshSkillBtnValid(button, index, skillInfo)
	local skillBtnValid = skillInfo.abilityId ~= AbilityConst.ABILITY_ID_EMPTY
	local btnRefInfo = self.skillBtnRefList[index]

	if skillBtnValid ~= btnRefInfo.dataValid then
		btnRefInfo.dataValid = skillBtnValid

		if skillBtnValid then
			button:SetActiveFastestAndMarkIgnoreLayout(skillInfo.visible)
		elseif skillInfo.visible then
			button:SetActiveFastestAndMarkIgnoreLayout(false)
		end
	end

	return skillBtnValid
end

function SkillRDUIComponent:setSkillListVisible(visible)
	if self.skillListVisible ~= visible and self.baseSkillList then
		self.skillListVisible = visible

		self.baseSkillList:SetActiveFastestAndMarkIgnoreLayout(visible)
	end
end

function SkillRDUIComponent:setExploreBtnListVisible(visible)
	if self.exploreBtnListVisible ~= visible then
		self.exploreBtnListVisible = visible

		if self.exploreSkillListUList then
			self.exploreSkillListUList.ignoreLayout = not visible

			LuaUIUtils.setUIVisible(self.exploreSkillListUList, visible)
		end
	end
end

function SkillRDUIComponent:refreshSkillUIVisible()
	local visible = self:getSkillUIVisible()

	if self.skillUIVisible ~= visible then
		self.skillUIVisible = visible

		LuaUIUtils.setUIVisible(self.panelSkill, visible)
		LuaUIUtils.setUIVisible(self.subSkillUWidget, visible)
	end
end

function SkillRDUIComponent:getSkillUIVisible()
	if not pg.game:checkModuleEnable(ClientConst.ModuleKey.Skill) then
		return false
	end

	local curSceneId = pg.me.space and pg.me.space.sceneId

	if curSceneId and SceneData[curSceneId] and ToBool(SceneData[curSceneId].hideSkill) then
		return false
	end

	if pg.me.inTeammateView then
		return false
	end

	return true
end

function SkillRDUIComponent:onPetExploreStateChange()
	local characterState = pg.pawn.characterState

	if CharacterStateConst.isChildOfState(characterState, CharacterStateConst.FLYING) then
		self:refreshFlyStateSkillVisible()

		if pg.global.ui:runPlatformByMobile() then
			self:applyExploreFlyOverride()
		end

		self:refreshFinalBtnEmptyState()
	end

	self:refreshFinalSkillVisible()
end

function SkillRDUIComponent:refreshFlyStateSkillVisible()
	if pg.me:isInCombat() and not pg.me.inExploreState then
		self:setSkillListVisible(true)
	else
		self:setSkillListVisible(false)
	end

	self:refreshExploreBtnVisible()
end

function SkillRDUIComponent:refreshExploreBtnList()
	local playerSpace = pg.me and pg.me.space
	local curSceneCfg = playerSpace and SceneData[playerSpace.sceneId] or Const.CACHED_EMPTY_TABLE
	local characterState = pg.pawn.characterState

	if CharacterStateConst.isChildOfState(characterState, CharacterStateConst.FLYING) then
		local exploreList = {}
		local exitBtn = {}

		LuaUIUtils.fillExploreBtnViewData(exitBtn, "HUD_FLOAT_BUTTON_EXIT", AddressDataConst.EXPORE_SKILL_FLY_EXIT, "Fly/StopFly")

		function exitBtn.luaPress()
			pg.pawn:stopFly()
		end

		table.insert(exploreList, exitBtn)

		local inCombat = pg.me:isInCombat()

		if not inCombat then
			local downBtn = {}

			LuaUIUtils.fillExploreBtnViewData(downBtn, "HUD_FLOAT_BUTTON_DOWN", AddressDataConst.EXPORE_SKILL_FLY_DROP, "Fly/Drop")

			function downBtn.luaPress()
				pg.pawn:beginStraightDown()
			end

			function downBtn.luaRelease()
				pg.pawn:endStraightDown()
			end

			downBtn.isDisabled = inCombat or curSceneCfg.canFlyVerticalAndSprint ~= 1

			table.insert(exploreList, downBtn)

			local upBtn = {}

			LuaUIUtils.fillExploreBtnViewData(upBtn, "HUD_FLOAT_BUTTON_UP", AddressDataConst.EXPORE_SKILL_FLY_RISE, "Fly/Rise")

			function upBtn.luaPress()
				pg.pawn:beginStraightUp()
			end

			function upBtn.luaRelease()
				pg.pawn:endStraightUp()
			end

			upBtn.isDisabled = inCombat or curSceneCfg.canFlyVerticalAndSprint ~= 1

			table.insert(exploreList, upBtn)
		end

		if self.exploreSkillListUList then
			self.exploreSkillListUList:SetList(exploreList)
		end

		self:setExploreBtnListVisible(true)
		self:refreshFlyStateSkillVisible()
	elseif CharacterStateConst.isChildOfState(characterState, CharacterStateConst.GLIDING) then
		local inCombat = pg.me:isInCombat()
		local exploreList = {}
		local flapBtn = {}

		LuaUIUtils.fillExploreBtnViewData(flapBtn, "HUD_GLIDE_BUTTON_RISE", AddressDataConst.EXPORE_SKILL_GLIDE_RISE, "Fly/GlideRise")

		flapBtn.isDisabled = inCombat or curSceneCfg.canGlideRise ~= 1

		function flapBtn.luaPress()
			if not inCombat then
				pg.pawn:glideRise()
			end
		end

		table.insert(exploreList, flapBtn)

		local exitBtn = {}

		LuaUIUtils.fillExploreBtnViewData(exitBtn, "HUD_FLOAT_BUTTON_EXIT", AddressDataConst.EXPORE_SKILL_GLIDE_EXIT, "Fly/StopFly")

		function exitBtn.luaPress()
			pg.pawn:stopGlide()
		end

		table.insert(exploreList, exitBtn)

		if self.exploreSkillListUList then
			self.exploreSkillListUList:SetList(exploreList)
		end

		self:setExploreBtnListVisible(true)
		self:setSkillListVisible(false)
		self:refreshExploreBtnVisible()
	else
		self:setExploreBtnListVisible(false)
		self:setSkillListVisible(true)
		self:refreshExploreBtnVisible()
	end

	self:refreshFinalBtnEmptyState()
end

function SkillRDUIComponent:refreshFinalBtnEmptyState()
	if self.finalSkillInfo and self.finalSkillBtn then
		local isEmpty, isDisable = AbilityUIUtils.checkFinalSkillEmptyState(self.finalSkillInfo)

		if isEmpty then
			self.finalSkillBtn:TryChangePage("EmptyState", 1)
		else
			self.finalSkillBtn:TryChangePage("EmptyState", 0)
		end

		if isDisable then
			self.finalSkillBtn:TryChangePage("Ready", 2)
		else
			self.finalSkillBtn:TryChangePage("Ready", 1)
		end
	end
end

function SkillRDUIComponent:checkAndPlayFinalSkillReadyEffect(finalSkillCostValid)
	if finalSkillCostValid == nil then
		local finalSkillInfo = self:getFinalSkillInfo()

		finalSkillCostValid = false

		if finalSkillInfo and finalSkillInfo.pawn and finalSkillInfo.abilityId then
			finalSkillCostValid = finalSkillInfo.pawn:checkAbilityCost(finalSkillInfo.abilityId)
		end
	end

	if self.lastCheckFinalSkillPawnId == pg.pawn.id and finalSkillCostValid and self.lastCheckFinalSkillCostValid ~= finalSkillCostValid then
		pg.game.audio:playEvent("SFX_UI_Battle_SkillEnergy")
	end

	self.lastCheckFinalSkillPawnId = pg.pawn.id
	self.lastCheckFinalSkillCostValid = finalSkillCostValid
end

function SkillRDUIComponent:refreshCostState(skipCD)
	for idx, skillInfo in ipairs(self.skillListInfo) do
		local btnRefInfo = self.skillBtnRefList[idx]

		if btnRefInfo.dataValid then
			AbilityUIUtils.refreshCostState(btnRefInfo, skillInfo)
		end
	end

	self:refreshFinalBtnState(skipCD)
end

function SkillRDUIComponent:refreshCostStateWithoutCD()
	self:refreshCostState(true)
end

function SkillRDUIComponent:refreshWaterStorage()
	local skillInfo = self.skillListInfo[EXPLORE_BTN_INDEX]
	local btnRefInfo = self.skillBtnRefList[EXPLORE_BTN_INDEX]

	if btnRefInfo.dataValid then
		AbilityUIUtils.refreshWaterStorage(btnRefInfo, skillInfo)
	end
end

function SkillRDUIComponent:onPawnStateChanged()
	for idx, skillInfo in ipairs(self.skillListInfo) do
		local btnRefInfo = self.skillBtnRefList[idx]

		if btnRefInfo.dataValid then
			AbilityUIUtils.refreshCostState(btnRefInfo, skillInfo)
			AbilityUIUtils.refreshChangeState(btnRefInfo, skillInfo)
		end
	end
end

function SkillRDUIComponent:onBuffForbidAbilityChanged()
	local isBuffForbidAbility = pg.pawn.isBuffForbidAbility

	for idx, skillInfo in ipairs(self.skillListInfo) do
		local btnRefInfo = self.skillBtnRefList[idx]

		if btnRefInfo.dataValid and not skillInfo.isNormalAttack and not skillInfo.ignoreValidation then
			if isBuffForbidAbility then
				btnRefInfo.button:TryChangePage("Ready", 2)
			else
				AbilityUIUtils.refreshCostState(btnRefInfo, skillInfo)
			end
		end
	end

	if self.finalSkillInfo and self.finalBtnRefInfo then
		if isBuffForbidAbility then
			AbilityUIUtils.tryChangeButtonPage(self.finalBtnRefInfo, self.finalSkillInfo, "BigSkill", 0)
			AbilityUIUtils.tryChangeButtonPage(self.finalBtnRefInfo, self.finalSkillInfo, "thickness", 1)
		else
			AbilityUIUtils.refreshCostState(self.finalBtnRefInfo, self.finalSkillInfo)
		end
	end
end

function SkillRDUIComponent:reactiveSkillItems()
	for idx, skillData in ipairs(self.skillListInfo) do
		local button = self:getValidSkillBtn(idx)

		if button then
			local ret, controllerPage = button:TryGetCurrentPage("Ready")

			if ret and controllerPage == 1 then
				button:InvokeCallback(CS.XGUI.EInvokeTime.User1)
			end
		end
	end
end

function SkillRDUIComponent:onSkillCdUpdate(info)
	local abilityId = info.abilityId

	if not abilityId then
		return
	end

	for idx, skillInfo in ipairs(self.skillListInfo) do
		if skillInfo.abilityId == abilityId then
			local pawn = skillInfo.pawn or pg.pawn
			local abilityMap = pawn.abilityMap
			local ability = abilityMap[abilityId]

			if ability and ability.cdEndTime then
				local btnRefInfo = self.skillBtnRefList[idx]

				if btnRefInfo.dataValid then
					AbilityUIUtils.refreshSkillState(btnRefInfo, skillInfo)
				end
			end

			return
		end
	end

	if self.finalSkillInfo and abilityId == self.finalSkillInfo.abilityId then
		AbilityUIUtils.refreshFinalSkillState(self.finalBtnRefInfo, self.finalSkillInfo)

		return
	end

	if self.itemAddonBtn then
		self.itemAddonBtn:onSkillCdUpdate(abilityId)
	end
end

function SkillRDUIComponent:onChipSkillIdChanged(skillId)
	if self.itemAddonBtn then
		self.itemAddonBtn:setSkillId(skillId)
	end
end

function SkillRDUIComponent:onRefreshSkillGray()
	for idx, skillInfo in ipairs(self.skillListInfo) do
		local btnRefInfo = self.skillBtnRefList[idx]

		if btnRefInfo.dataValid then
			AbilityUIUtils.refreshAbilityGrayState(btnRefInfo, skillInfo)
		end
	end

	if self.finalSkillInfo and self.finalSkillInfo.abilityId then
		AbilityUIUtils.refreshAbilityGrayState(self.finalBtnRefInfo, self.finalSkillInfo)
	end
end

function SkillRDUIComponent:setIntensityStyleData(args)
	if not self.skillIntensityDatas[args.actorId] then
		self.skillIntensityDatas[args.actorId] = {}
	end

	for _, abilityId in ipairs(args.abilityIds) do
		local oldData = self.skillIntensityDatas[args.actorId][abilityId]

		if args.isOpen or not oldData or oldData.isOpen then
			if oldData and oldData.timer then
				TimerManager.removeTimer(oldData.timer)

				oldData.timer = nil
			end

			self.skillIntensityDatas[args.actorId][abilityId] = args

			self:refreshIntensityStyle(abilityId, args)
		end
	end

	if args.isOpen and (args.endTime or 0) > 0 and args.endTime - Time.realSecondCache > 0 then
		args.timer = TimerManager.addTimer(math.max(0, args.endTime - Time.realSecondCache), function()
			args.timer = nil

			local intensityDatas = self.skillIntensityDatas and self.skillIntensityDatas[args.actorId]

			if not intensityDatas then
				return
			end

			for _, abilityId in ipairs(args.abilityIds) do
				if intensityDatas[abilityId] == args then
					self:refreshIntensityStyle(abilityId, args)
				end
			end
		end)
	end
end

function SkillRDUIComponent:tryGetCurAbilityId(skillInfo)
	local pawn = skillInfo.pawn or pg.pawn
	local switchInfo = pawn.abilitySwitchInfo[skillInfo.abilityId]

	if switchInfo and switchInfo[2] then
		return switchInfo[1]
	end

	return skillInfo.abilityId
end

function SkillRDUIComponent:refreshIntensityStyle(abilityId, intensityData)
	if intensityData.actorId ~= pg.pawn.actorId then
		return
	end

	for idx, skillInfo in ipairs(self.skillListInfo) do
		local abilityIdCur = self:tryGetCurAbilityId(skillInfo)

		if abilityId == abilityIdCur then
			skillInfo.intensityData = intensityData

			if idx == NORMAL_ATTACK_BTN_INDEX then
				self:refreshNormalAttackBtn()

				break
			end

			do
				local btnRefInfo = self.skillBtnRefList[idx]

				if btnRefInfo.dataValid then
					AbilityUIUtils.refreshSkillIntensityStyle(btnRefInfo, skillInfo)
				end
			end

			break
		end
	end

	local curFinalAbilityId = self:tryGetCurAbilityId(self.finalSkillInfo)

	if self.finalSkillInfo and curFinalAbilityId == abilityId then
		self.finalSkillInfo.intensityData = intensityData

		if self.finalBtnRefInfo then
			AbilityUIUtils.refreshSkillIntensityStyle(self.finalBtnRefInfo, self.finalSkillInfo)
		end
	end

	if pg.global.ui:runPlatformByMobile() and self.ctrl.mobile3C then
		self.ctrl.mobile3C:refreshNormalAttackIntensity()
	end
end

function SkillRDUIComponent:onNormalAttackShowChange(args)
	if not self.normalAttackShowMap or not args then
		return
	end

	self.normalAttackShowMap[args.actorId] = args.show and true or nil

	self:refreshNormalAttackBtn()
end

function SkillRDUIComponent:refreshNormalAttackBtn()
	local btnRefInfo = self.skillBtnRefList[NORMAL_ATTACK_BTN_INDEX]
	local skillInfo = self.skillListInfo[NORMAL_ATTACK_BTN_INDEX]

	if not btnRefInfo or not skillInfo then
		return
	end

	local wantShow = self.normalAttackShowMap and pg.pawn and self.normalAttackShowMap[pg.pawn.actorId] == true and not Utils.isSupportPet(pg.pawn)
	local shouldShow = wantShow and btnRefInfo.dataValid or false

	skillInfo.visible = shouldShow

	if NotNil(btnRefInfo.button) then
		btnRefInfo.button:SetActiveFastestAndMarkIgnoreLayout(shouldShow)

		if shouldShow then
			AbilityUIUtils.setSkillBtnInfo(btnRefInfo, skillInfo)
		end
	end
end

function SkillRDUIComponent:refreshChangeState(abilityId)
	for idx, skillInfo in ipairs(self.skillListInfo) do
		if skillInfo.abilityId == abilityId then
			local btnRefInfo = self.skillBtnRefList[idx]

			if btnRefInfo.dataValid then
				AbilityUIUtils.refreshChangeState(btnRefInfo, skillInfo)
				AbilityUIUtils.refreshCostState(btnRefInfo, skillInfo)
				AbilityUIUtils.refreshCDState(btnRefInfo, skillInfo)
				self:fillIntensityData(skillInfo)
				AbilityUIUtils.refreshSkillIntensityStyle(btnRefInfo, skillInfo)
			end

			break
		end
	end

	if self.finalSkillInfo and abilityId == self.finalSkillInfo.abilityId then
		local skillValid = AbilityUIUtils.refreshCostState(self.finalBtnRefInfo, self.finalSkillInfo)

		AbilityUIUtils.refreshChangeState(self.finalBtnRefInfo, self.finalSkillInfo, skillValid)
		AbilityUIUtils.refreshCDState(self.finalBtnRefInfo, self.finalSkillInfo)
		self:fillIntensityData(self.finalSkillInfo)
		AbilityUIUtils.refreshSkillIntensityStyle(self.finalBtnRefInfo, self.finalSkillInfo)
	end

	self:refreshRogueChangeState()
end

function SkillRDUIComponent:getExploreBtnVisible(exploreSkillInfo)
	local player = pg.me
	local playerSkillVisibleMap = player.skillVisibleMap

	if playerSkillVisibleMap.T == false then
		return false
	end

	local characterState = pg.pawn.characterState

	if CharacterStateConst.isChildOfState(characterState, CharacterStateConst.FLYING) or CharacterStateConst.isChildOfState(characterState, CharacterStateConst.GLIDING) then
		return false
	end

	local existAnyPet = table.getCount(player.petPrepareList) > 0

	return existAnyPet
end

function SkillRDUIComponent:refreshExploreBtnVisible()
	if not self.skillListInfo then
		return
	end

	local exploreSkillInfo = self.skillListInfo[EXPLORE_BTN_INDEX]
	local exploreSkillVisible = self:getExploreBtnVisible(exploreSkillInfo)

	if exploreSkillVisible ~= exploreSkillInfo.visible then
		exploreSkillInfo.visible = exploreSkillVisible

		local button = self:getValidSkillBtn(EXPLORE_BTN_INDEX)

		if button then
			button:SetActiveFastestAndMarkIgnoreLayout(exploreSkillVisible)
		end
	end
end

function SkillRDUIComponent:onPreparePetsUpdate()
	self:refreshExploreBtnVisible()
	self:refreshFinalSkillVisible()
end

function SkillRDUIComponent:refreshFinalSkillVisible()
	local visible = self:getFinalSkillVisible()

	if visible ~= self.finalSkillVisible then
		self.finalSkillVisible = visible

		self.bigSkillWidget:SetActiveFastestAndMarkIgnoreLayout(visible)
	end
end

function SkillRDUIComponent:getFinalSkillVisible()
	if not pg.game:checkModuleEnable(ClientConst.ModuleKey.Skill) then
		return false
	end

	if pg.me:checkArkSceneState() then
		return false
	end

	if pg.me.skillVisibleMap.R == false then
		return false
	end

	if not pg.me.hasUltimatePetInPrepareList and not pg.me:EXTRA_TEMP_PET_ST() then
		return false
	end

	if CharacterStateConst.isChildOfState(pg.pawn.characterState, CharacterStateConst.GLIDING) then
		return false
	end

	local finalSkillInfo = self.finalSkillInfo

	if not finalSkillInfo or not ToBool(finalSkillInfo.abilityId) then
		return false
	end

	return true
end

function SkillRDUIComponent:refreshFinalSkill(skipCD)
	if pg.game.seamless:seam_sys_isSwitchSeamless() then
		return
	end

	local skillInfo = self:getFinalSkillInfo()
	local skillValid, costValid, cdValid

	skillInfo.actionPath = "Hud/SkillR"

	if skillInfo.abilityId and skillInfo.abilityId ~= 0 then
		skillValid, costValid, cdValid = AbilityUIUtils.setFinalSkillBtnInfo(self.finalBtnRefInfo, self.finalSkillInfo, skipCD)
	end

	self:refreshFinalSkillVisible()

	local readyCostValid = skillInfo.abilityId ~= AbilityConst.ABILITY_ID_EMPTY and costValid or false

	return skillValid, readyCostValid, cdValid
end

function SkillRDUIComponent:getFinalSkillInfo()
	local skillInfo = self.finalSkillInfo

	skillInfo.abilityId = nil
	skillInfo.isUsePetSkillMode = false
	skillInfo.playerAbilityId = nil
	skillInfo.rogueEpCost = nil
	skillInfo.elementType = nil

	local isControllongPet = Utils.isPet(pg.pawn)

	if not isControllongPet then
		local pet = pg.me:getCurMainCombatPetEntity()
		local rawSkillInfo = self.model:getPetSkillInfByType(pet, AbilityConst.ULTIMATE_ABILITY)

		table.merge(skillInfo, rawSkillInfo)

		if not skillInfo.abilityId then
			skillInfo.abilityId = AbilityConst.ABILITY_ID_EMPTY
		end

		skillInfo.pawn = pet
		skillInfo.playerAbilityId = AbilityConst.USE_PET_SKILL_IDS[3]
		skillInfo.isUsePetSkillMode = true
		skillInfo.showCost = false
	else
		local pet = pg.me:getCurMainCombatPetEntity()
		local rawSkillInfo = self.model:getPetSkillInfByType(pet, AbilityConst.ULTIMATE_ABILITY)

		table.merge(skillInfo, rawSkillInfo)

		if not skillInfo.abilityId then
			skillInfo.abilityId = AbilityConst.ABILITY_ID_EMPTY
		end

		skillInfo.pawn = pet
		skillInfo.showCost = false
	end

	skillInfo.isFinalSkill = true
	skillInfo.actionPath = "Hud/SkillR"

	if skillInfo.abilityType == nil then
		skillInfo.abilityType = AbilityConst.EnumAbilityType.Ultimate
	end

	self:fillIntensityData(skillInfo)

	return skillInfo
end

function SkillRDUIComponent:refreshFinalBtnState(skipCD)
	if self.finalSkillInfo and self.finalSkillInfo.abilityId then
		AbilityUIUtils.refreshFinalSkillState(self.finalBtnRefInfo, self.finalSkillInfo, skipCD)
	end
end

function SkillRDUIComponent:triggerFinalSkillEffect()
	local btnSkillsAllRightUContainer = self.finalBtnRefInfo.allRightUcontainer

	if not btnSkillsAllRightUContainer:CheckURLLoaded() then
		btnSkillsAllRightUContainer:LoadDefaultUrlManually(function()
			self.finalSkillBtn:InvokeCallback(CS.XGUI.EInvokeTime.User1)
		end)
	else
		self.finalSkillBtn:InvokeCallback(CS.XGUI.EInvokeTime.User1)
	end
end

function SkillRDUIComponent:onSpChange(changeData)
	if changeData then
		local oldVal = changeData[1] or 0
		local newVal = changeData[2] or 0

		if math.floor(newVal / 100) > math.floor(oldVal / 100) then
			self:triggerFinalSkillEffect()
		end
	end

	local _, costValid = self:refreshFinalSkill(true)

	return costValid
end

function SkillRDUIComponent:refreshRogueSkill()
	local skillInfo = self:getRogueSkill()

	if skillInfo then
		AbilityUIUtils.refreshRogueSkill(self.btnPetExChangeUContainer, skillInfo)
	end
end

function SkillRDUIComponent:refreshRogueChangeState()
	local skillInfo = self:getRogueSkill()

	if skillInfo then
		AbilityUIUtils.refreshRogueSkill(self.btnPetExChangeUContainer, skillInfo)
	end
end

function SkillRDUIComponent:onRogueCombatDataChange(param)
	if param.key == AbilityConst.ROGUE_BATTLE_DATA_KEY.SKILL_EP or param.key == AbilityConst.ROGUE_BATTLE_DATA_KEY.SKILL_EP_MAX then
		AbilityUIUtils.refreshRogueSkillCost(self.btnPetExChangeUContainer)
	end
end

function SkillRDUIComponent:getRogueSkill()
	if not pg.space or not pg.space:isRogueEnv() then
		return nil
	end

	local skillInfo = self.model:getPlayerSkillInfBySkillType(AbilityConst.PLAYER_INITIATIVE_TYPE.INITIATIVE_M)

	skillInfo.name = nil

	if skillInfo.abilityId then
		skillInfo.actionPath = AbilityConst.PLAYER_ABILITY_HOTKEY[AbilityConst.PLAYER_INITIATIVE_TYPE.INITIATIVE_M]
		skillInfo.pawn = pg.me

		return skillInfo
	end

	return nil
end

function SkillRDUIComponent:onExtraTempPetStateChange()
	local _, finalSkillCostValid = self:refreshFinalSkill()

	self:checkAndPlayFinalSkillReadyEffect(finalSkillCostValid)
	AbilityUIUtils.refreshRogueSkillCost(self.btnPetExChangeUContainer)
end

function SkillRDUIComponent:getLoadedSkillInfo(id)
	for index, info in ipairs(self.skillListInfo) do
		if info.abilityId == id then
			local btnRefInfo = self.skillBtnRefList[index]

			return info, btnRefInfo
		end
	end
end

function SkillRDUIComponent:onBackListChanged(data)
	local num = data.newCnt
	local id = data.abilityId

	if id == nil or num == nil then
		return
	end

	local skillInfo, btnRefInfo = self:getLoadedSkillInfo(id)

	if skillInfo == nil or btnRefInfo == nil or not btnRefInfo.dataValid then
		return
	end

	AbilityUIUtils.refreshCDState(btnRefInfo, skillInfo)
	AbilityUIUtils.refreshNormalCostState(btnRefInfo, skillInfo)

	if skillInfo.backListNum ~= nil and skillInfo.backListNum > 1 then
		local pointListUContainer = btnRefInfo.pointListUContainer
		local oldNum = skillInfo.loadCntAbilityId == id and skillInfo.loadCntValue or nil
		local res, btn

		for i = 1, skillInfo.backListNum do
			res, btn = pointListUContainer.content:TryGetChildAt(i - 1)

			if res and (oldNum == nil or i <= oldNum ~= (i <= num)) then
				btn:SetSelected(i <= num)
			end
		end

		skillInfo.loadCntAbilityId = id
		skillInfo.loadCntMax = skillInfo.backListNum
		skillInfo.loadCntValue = num
	end
end

function SkillRDUIComponent:refreshSkillListAndFinalSkill(info)
	if pg.game.seamless:seam_sys_isSwitchSeamless() then
		return
	end

	if info.inputEvent == Const.EVENT_CLIENT_PRE_EXPLORE and info.targetEnt and info.targetEnt.isExplorePet and info.targetEnt.id == pg.me.clientExploreEntId then
		self:refreshExploreBtnList()

		return
	end

	self:refreshSkillList()

	local _, finalSkillCostValid = self:refreshFinalSkill(false)

	self:checkAndPlayFinalSkillReadyEffect(finalSkillCostValid)
end

function SkillRDUIComponent:onModuleEnableChanged(changeInfo)
	local moduleKey = changeInfo.moduleKey
	local enable = changeInfo.enable

	if moduleKey == ClientConst.ModuleKey.Skill or moduleKey == ClientConst.ModuleKey.NormalAttack or moduleKey == ClientConst.ModuleKey.Dash then
		self:refreshSkillUIVisible()
		self:refreshFinalSkillVisible()
	end
end

function SkillRDUIComponent:onSkillVisibleMapChange()
	local playerSkillVisibleMap = pg.me.skillVisibleMap
	local exploreSkillInfo = self.skillListInfo[EXPLORE_BTN_INDEX]
	local exploreSkillVisible = self:getExploreBtnVisible(exploreSkillInfo)

	if exploreSkillVisible ~= exploreSkillInfo.visible then
		exploreSkillInfo.visible = exploreSkillVisible

		LuaUIUtils.setUIVisible(self:getValidSkillBtn(EXPLORE_BTN_INDEX), exploreSkillVisible)
	end

	local qSkillInfo = self.skillListInfo[SKILLQ_BTN_INDEX]
	local qSkillVisible = playerSkillVisibleMap.Q ~= false

	if qSkillVisible ~= qSkillInfo.visible then
		qSkillInfo.visible = qSkillVisible

		LuaUIUtils.setUIVisible(self:getValidSkillBtn(SKILLQ_BTN_INDEX), qSkillVisible)
	end

	local eSkillInfo = self.skillListInfo[SKILLE_BTN_INDEX]
	local eSkillVisible = playerSkillVisibleMap.E ~= false

	if eSkillVisible ~= eSkillInfo.visible then
		eSkillInfo.visible = eSkillVisible

		LuaUIUtils.setUIVisible(self:getValidSkillBtn(SKILLE_BTN_INDEX), eSkillVisible)
	end

	self:refreshFinalSkill()
end

function SkillRDUIComponent:refreshPlayerEp()
	local player = pg.me

	if pg.game.controller:isInControlEnt() then
		self:refreshCostState(true)
	end
end

function SkillRDUIComponent:onPlayerSpChange(changeData)
	local finalSkillCostValid = self:onSpChange(changeData)

	self:checkAndPlayFinalSkillReadyEffect(finalSkillCostValid)
end

function SkillRDUIComponent:onSkillMapChanged(args)
	local ent = args[1]

	if not ent or ent ~= pg.pawn then
		return
	end

	local reason = args[2] or AbilityConst.CHANGE_ABILITY_MAP_REASON.Default
	local changed = args[3]

	if changed == nil then
		changed = true
	end

	if reason == AbilityConst.CHANGE_ABILITY_MAP_REASON.CombatChange then
		self:refreshSkillList()
		self:reactiveSkillItems()
	elseif reason == AbilityConst.CHANGE_ABILITY_MAP_REASON.ChangeCustomIndex then
		self:refreshSkillList()
	elseif changed then
		self:refreshSkillList()
		self:refreshFinalSkill()
	end
end

function SkillRDUIComponent:onPetSkillMapChanged(info)
	if info.petId ~= pg.pawn.id then
		return
	end

	self:refreshSkillList()
	self:refreshFinalSkill()
end

function SkillRDUIComponent:onCombatPetChange()
	local isControllingPlayer = pg.me:isControllingMaster()

	if isControllingPlayer then
		local _, finalSkillCostValid = self:refreshFinalSkill()

		self:checkAndPlayFinalSkillReadyEffect(finalSkillCostValid)
	end
end

function SkillRDUIComponent:onCurCombatPetTemplateChange()
	local isControllingPet = pg.me:isControllingPet()

	if isControllingPet then
		self:refreshSkillList()
	end

	local _, finalSkillCostValid = self:refreshFinalSkill()

	self:checkAndPlayFinalSkillReadyEffect(finalSkillCostValid)
end

function SkillRDUIComponent:onCombatStatusChange()
	local characterState = pg.pawn.characterState

	if CharacterStateConst.isChildOfState(characterState, CharacterStateConst.FLYING) then
		self:refreshExploreBtnList()
	end

	if pg.pawn ~= pg.me then
		return
	end

	local btnRefInfo = self.skillBtnRefList[EXPLORE_BTN_INDEX]

	if btnRefInfo.dataValid then
		AbilityUIUtils.refreshSkillState(btnRefInfo, self.skillListInfo[EXPLORE_BTN_INDEX])
	end
end

function SkillRDUIComponent:onLockedTargetChange()
	if not self.skillListInfo then
		return
	end

	local resistVisible, resistTargetEntity = AbilityUIUtils.getResistInfo()

	for idx, skillInfo in ipairs(self.skillListInfo) do
		skillInfo.resistVisible = resistVisible
		skillInfo.resistTargetEntity = resistTargetEntity

		local btnRefInfo = self.skillBtnRefList[idx]

		if btnRefInfo.dataValid then
			AbilityUIUtils.refreshResistState(btnRefInfo, skillInfo)
		end
	end

	if self.finalSkillInfo and self.finalSkillInfo.abilityId then
		self.finalSkillInfo.resistVisible = resistVisible
		self.finalSkillInfo.resistTargetEntity = resistTargetEntity

		AbilityUIUtils.refreshResistState(self.finalBtnRefInfo, self.finalSkillInfo)
	end
end

function SkillRDUIComponent:onMainPetEnterSpace(entity)
	return
end

function SkillRDUIComponent:onInvItemChange(info)
	local itemId = info.itemId

	if not itemId then
		return
	end

	for idx, skillInfo in ipairs(self.skillListInfo) do
		local abilityParamData = skillInfo.abilityParamData

		if abilityParamData and abilityParamData.costItemId == itemId then
			local btnRefInfo = self.skillBtnRefList[idx]

			if btnRefInfo.dataValid then
				AbilityUIUtils.refreshCostState(btnRefInfo, skillInfo)
			end
		end
	end
end

function SkillRDUIComponent:refreshTeamInfo()
	local memberCount = pg.me:getTeamMemberCount()
	local teammateInScene = false

	if not pg.me.inTeammateView then
		return
	end

	for id, info in pairs(pg.me:getCurTeamInfo().membersInfo) do
		if info.entityId ~= pg.me.id then
			local other = pg.getEntity(info.entityId)

			teammateInScene = other ~= nil
		end
	end

	if memberCount <= 1 or not teammateInScene then
		self:switchTeammateView()
	end
end

function SkillRDUIComponent:onSkillTagChange(info)
	local abilityId = info.abilityId
	local overrideTagId = info.overrideTagId

	for idx, skillInfo in ipairs(self.skillListInfo) do
		if abilityId == skillInfo.abilityId then
			skillInfo.overrideTagId = overrideTagId

			local btnRefInfo = self.skillBtnRefList[idx]

			if btnRefInfo.dataValid then
				if overrideTagId == nil then
					skillInfo.appliedOverrideTagId = nil

					AbilityUIUtils.refreshChangeState(btnRefInfo, skillInfo)

					break
				end

				AbilityUIUtils.refreshSkillBtnTag(btnRefInfo, skillInfo)
			end

			break
		end
	end
end

function SkillRDUIComponent:onMagnesisModeChange(enable)
	if not pg.game.controller:isInControlMainPlayer() then
		return
	end

	if enable then
		pg.global.ui.crawl:openOrShow()
	end
end

function SkillRDUIComponent:onSkillIntensityChange(args)
	self:setIntensityStyleData(args)
end

function SkillRDUIComponent:onVehicleShowStateChanged(info)
	return
end

function SkillRDUIComponent:initPetActionMode()
	function self.btnPetModeUButton.luaClick()
		self:setPetBattleState((pg.me.petActionMode + 1) % 3)
	end

	self:bindPetModeLongPress()
	self.btnPetModeUButton:TryChangePage("PetMode", pg.me.petActionMode)
	self:refreshPetActionModeVisible()

	local player = pg.me

	if player.petActionMode == Const.PetActionMode.Catch then
		self.petModeIcon0.gameObject:SetActiveEx(true)
	elseif player.petActionMode == Const.PetActionMode.Peace then
		self.petModeIcon1.gameObject:SetActiveEx(true)
	elseif player.petActionMode == Const.PetActionMode.Invade then
		self.petModeIcon2.gameObject:SetActiveEx(true)
	end
end

function SkillRDUIComponent:bindPetModeLongPress()
	local petModeObjectReference = self.btnPetModeUButton:GetComponent("ObjectReference")
	local hotKeyContent = petModeObjectReference and petModeObjectReference:GetRefValue("keyHotKeyContent")

	if not hotKeyContent then
		return
	end

	hotKeyContent:SetHotKeyPaths("Hud/SwitchPetMode")
	LuaUIUtils.waitHotKeyContentObjectReference(self, hotKeyContent, function(objectReference)
		local progressPressContainers = {}
		local progressPressContainer1 = objectReference:GetRefValue("progressPressContainerSet1UContainer")

		if progressPressContainer1 then
			progressPressContainers[#progressPressContainers + 1] = progressPressContainer1
		end

		local progressPressContainer2 = objectReference:GetRefValue("progressPressContainerSet2UContainer")

		if progressPressContainer2 then
			progressPressContainers[#progressPressContainers + 1] = progressPressContainer2
		end

		if #progressPressContainers == 0 then
			return
		end

		progressPressContainer1:SetActive(pg.game.input:isUsingGamepad())
		progressPressContainer2:SetActive(pg.game.input:isUsingGamepad())

		self.petModeProgressPressContainers = progressPressContainers

		local loadedProgresses = {}
		local pendingContainerCount = #progressPressContainers

		local function bindPetModeHotKey()
			if #loadedProgresses == 0 then
				return
			end

			local progress = {}

			function progress:ProgressToValue(value, options, duration)
				for _, loadedProgress in ipairs(loadedProgresses) do
					loadedProgress:ProgressToValue(value, options, duration)
				end
			end

			progress:ProgressToValue(0, nil, 0)
			self.ctrl.ctrl:bindHotKeyWithProgress("Hud/SwitchPetMode", function()
				progress:ProgressToValue(0, nil, 0)

				if self.petModeVisible == false then
					return
				end

				self.btnPetModeUButton.luaClick()
			end, self.btnPetModeUButton.gameObject, progress, function()
				progress:ProgressToValue(0, nil, 0)
			end, {
				gamepadOnly = true
			})
		end

		local function loadProgressContainer(container)
			container:SetActive(pg.game.input:isUsingGamepad())
			container:LoadDefaultUrlManually(function()
				local progress = container.content

				if progress then
					loadedProgresses[#loadedProgresses + 1] = progress
				end

				pendingContainerCount = pendingContainerCount - 1

				if pendingContainerCount == 0 then
					bindPetModeHotKey()
				end
			end)
		end

		for _, container in ipairs(progressPressContainers) do
			loadProgressContainer(container)
		end
	end)
end

function SkillRDUIComponent:onInputDeviceChanged()
	if self.petModeProgressPressContainers then
		local isGamepad = pg.game.input:isUsingGamepad()

		for _, container in ipairs(self.petModeProgressPressContainers) do
			container:SetActive(isGamepad)
		end
	end
end

function SkillRDUIComponent:bindPetActionModeAttributeNotify()
	local actorCombatAttribute = pg.me.actorCombatAttribute

	if self.petModeAttrOwner == actorCombatAttribute then
		return
	end

	self.petModeAttrOwner = actorCombatAttribute

	actorCombatAttribute:registerAttributeNotify(AttributeConst.open_go_multi_mode, function()
		self:refreshPetActionModeVisible()
	end)
end

function SkillRDUIComponent:setPetBattleState(state)
	self.btnPetModeUButton:TryChangePage("PetMode", state)
	pg.me:serverMsg("RPC_CS_SetPetActionMode", state)

	local noticeId = NoticeDef.SWITCH_PET_MODE_CATCH + state

	ClientUtils.showBubbleMessageById(noticeId)
end

function SkillRDUIComponent:refreshPetActionModeVisible()
	if not self.btnPetModeUButton then
		return
	end

	local player = pg.me

	if not player then
		return
	end

	local showPetModel = player:isControlFollow() and player.actorCombatAttribute:getAttribValue(AttributeConst.open_go_multi_mode) == 1

	if showPetModel and (Utils.isInSocialScene() or Utils.isSpaceTown(pg.space and pg.space.spaceType)) then
		showPetModel = false
	end

	self.petModeVisible = showPetModel

	self.btnPetModeUButton:SetActiveFastest(showPetModel)
end

function SkillRDUIComponent:onControlStateChange()
	self:refreshPetActionModeVisible()
end

function SkillRDUIComponent:initSkillAddonBtn()
	if pg.space then
		local levelData = LevelData[pg.space.sceneId]

		self.isInMultiDungeon = levelData and levelData.playerNumMax > 1 and levelData.isTemple == 1

		if self.isInMultiDungeon then
			self.skillAddonSpeicalUContainer:LoadDefaultUrlManually(function(widget)
				self.skillAddonReference = self.skillAddonSpeicalUContainer.content:GetComponent("ObjectReference")
				self.txtNameUText = self.skillAddonReference:GetRefValue("txtNameUText")
				self.iconUImage = self.skillAddonReference:GetRefValue("iconUImage")
				self.btnNormalKeyBindingPro = self.skillAddonReference:GetRefValue("btnNormalKeyBindingPro")
				self.keyHotKeyContent = self.skillAddonReference:GetRefValue("keyHotKeyContent")
				self.specialUButton = self.skillAddonReference:GetRefValue("specialUButton")
				self.countDown = self.skillAddonReference:GetRefValue("countDown")

				self.skillAddonSpeicalUContainer.gameObject:SetActiveEx(true)
				ClientTextUtils.setText(self.txtNameUText, pg.getGameString("TEMPLE_SWITCH_VIEW"))

				self.iconUImage.url = "$UI_SkillIcon_People_Peep.png"

				self.keyHotKeyContent:SetHotKeyPaths("Hud/TeamMateView")

				function self.specialUButton.luaClick()
					self:switchTeammateView()
				end

				LuaUIUtils.bindFuncBtnHotKey(self.specialUButton.gameObject, "teammateView", "Hud/TeamMateView", function()
					self:switchTeammateView()
				end)
			end)
		else
			self.skillAddonSpeicalUContainer.gameObject:SetActiveEx(false)
		end
	end
end

function SkillRDUIComponent:refreshSkillAddonBtn(data)
	if not self.skillAddonSpeicalUContainer:CheckURLLoaded() then
		self.skillAddonSpeicalUContainer:LoadDefaultUrlManually(function()
			local skillAddonSpeicalReference = self.skillAddonSpeicalUContainer.content:GetComponent("ObjectReference")

			self.btnSwitchUButton = skillAddonSpeicalReference:GetRefValue("specialUButton")
			self.iconSwitchUImage = skillAddonSpeicalReference:GetRefValue("iconUImage")
			self.txtSwitchUText = skillAddonSpeicalReference:GetRefValue("txtNameUText")
			self.hotKeySwitchContent = skillAddonSpeicalReference:GetRefValue("keyHotKeyContent")

			self:refreshSkillAddonBtnInternal(data)
		end)
	else
		self:refreshSkillAddonBtnInternal(data)
	end
end

function SkillRDUIComponent:refreshSkillAddonBtnInternal(data)
	self.skillAddonInfo = data
	self.btnSwitchUButton.luaClick = data.func

	LuaUIUtils.bindFuncBtnHotKey(self.btnSwitchUButton.gameObject, "skillAddon", data.actionPath, function()
		self.btnSwitchUButton:OnClickSimulate()
	end)
	self:refreshSkillAddonBtnVisible()

	self.iconSwitchUImage.url = data.imgUrl

	ClientTextUtils.setText(self.txtSwitchUText, data.text)
	self.hotKeySwitchContent:SetHotKeyPaths(data.actionPath)
end

function SkillRDUIComponent:refreshSkillAddonBtnVisible()
	if not self.btnSwitchUButton then
		return
	end

	local data = self.skillAddonInfo
	local skillAddonBtnVisible = data and data.getVisibleFunc()

	LuaUIUtils.setUIVisible(self.btnSwitchUButton, skillAddonBtnVisible)
end

function SkillRDUIComponent:switchTeammateView()
	if self.inTeammateView then
		self.baseSkillList.gameObject:SetActiveEx(true)
		self.listSkillAddonUList.gameObject:SetActiveEx(true)

		if pg.me:isControllingPet() then
			local pet = pg.me:getCurPetEntity()

			pg.game.camera:setTargetPlayer(pet, 0)
		else
			pg.game.camera:setTargetPlayer(pg.me, 0)
		end

		self.inTeammateView = false
		pg.me.inTeammateView = false

		if self.teammateViewTarget then
			self.teammateViewTarget:setLodTickEnable(Const.LOD_TICK_KEY.TEAMMATEVIEW, false)
		end

		pg.global.ui:show(UIConst.UI_ID_TIPS)

		pg.me.inPeep = false

		if pg.pawn.updateStateCache then
			pg.pawn:updateStateCache("PEEP_ST")
		end

		if self.lastInFixedCamera then
			pg.game.camera:cameraBlendToFixed(self.lastCameraPos, self.lastCameraRotation, self.lastCameraFov, 0)

			self.lastInFixedCamera = false
		end

		ClientTextUtils.setText(self.txtNameUText, pg.getGameString("TEMPLE_SWITCH_VIEW"))
		facade:sendMsgToUI(MessageName.DUNGEON_TEAMMATEVIEW_CHANGE)
		facade:sendLuaEvent(pg.me.id .. SandboxConst.COMMON_EVENT.TEAMATE_VIEW_CHANGE, false)
	elseif pg.me:isInTeam() then
		local teammateInScene = false

		for id, info in pairs(pg.me:getCurTeamInfo().membersInfo) do
			if info.entityId ~= pg.me.id then
				local other = pg.getEntity(info.entityId)

				teammateInScene = other ~= nil
			end
		end

		if teammateInScene then
			if pg.me.disableTeammateView then
				return
			end

			for id, info in pairs(pg.me:getCurTeamInfo().membersInfo) do
				if info.entityId ~= pg.me.id then
					local target = pg.getEntity(info.entityId)

					if target:isControllingPet() then
						local pet = target:getCurPetEntity()

						if pet then
							target = pet
						end
					end

					pg.game.camera:setTargetPlayer(target, 0)

					self.inTeammateView = true
					pg.me.inTeammateView = true

					target:setLodTickEnable(Const.LOD_TICK_KEY.TEAMMATEVIEW, true)

					self.teammateViewTarget = target
				end
			end

			self.baseSkillList.gameObject:SetActiveEx(false)
			self.listSkillAddonUList.gameObject:SetActiveEx(false)
			pg.global.ui:hide(UIConst.UI_ID_TIPS)

			pg.me.inPeep = true

			if pg.pawn.updateStateCache then
				pg.pawn:updateStateCache("PEEP_ST")
			end

			if pg.game.camera.fixedCameraMode ~= nil then
				self.lastCameraPos = pg.game.camera.fixedCameraMode.lastPos
				self.lastCameraRotation = pg.game.camera.fixedCameraMode.lastRotation
				self.lastCameraFov = pg.game.camera.fixedCameraMode.lastFov

				pg.game.camera:cancelBlendToFixed(0, true)

				self.lastInFixedCamera = true
			end

			ClientTextUtils.setText(self.txtNameUText, pg.getGameString("COMMON_CANCEL"))
			facade:sendMsgToUI(MessageName.DUNGEON_TEAMMATEVIEW_CHANGE)
			facade:sendLuaEvent(pg.me.id .. SandboxConst.COMMON_EVENT.TEAMATE_VIEW_CHANGE, true)
		else
			pg.global.ui.tips:showTextTip(pg.getLocalizationText(SysNoticeData[NoticeDef.TEMPLE_SEE_TEAMMATE_FAILED].text))
		end
	end
end

function SkillRDUIComponent:onTeammateViewChange()
	return
end

function SkillRDUIComponent:playShowAnim()
	if self.uWidget then
		self.uWidget:InvokeCallback(CS.XGUI.EInvokeTime.Show)
	end
end

function SkillRDUIComponent:playHideAnim()
	if self.uWidget then
		self.uWidget:InvokeCallback(CS.XGUI.EInvokeTime.Hide)
	end
end

return SkillRDUIComponent
