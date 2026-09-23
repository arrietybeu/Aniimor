-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\MobileSkillRDUIComponent.lua

local Class = require("Core.Framework.Class")
local EventConst = require("Const.EventConst")
local AbilityConst = require("Common.Const.AbilityConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local SkillRDUIComponent = require("Guis.Panels.HudV2.BaseComponent.SkillRDUIComponent")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local Utils = require("Common.Utils.Utils")
local AbilityUIUtils = require("Utils.AbilityUIUtils")
local SkillTagData = require("Data.skill_tag_data")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local AddressDataConst = require("Const.AddressDataConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientConst = require("Const.ClientConst")
local Time = require("Core.Common.Time")
local MessageName = require("Const.MessageName")
local MobileSkillRDUIComponent = Class.LightClass("MobileSkillRDUIComponent", SkillRDUIComponent)
local NORMAL_ATTACK_BTN_INDEX = 2

function MobileSkillRDUIComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.skill1Widget = objectReference:GetRefValue("Skill1")
	self.skill1Btn = objectReference:GetRefValue("skill1Btn")
	self.skill2Widget = objectReference:GetRefValue("Skill2")
	self.skill2Btn = objectReference:GetRefValue("skill2Btn")
	self.skill3Widget = objectReference:GetRefValue("Skill3")
	self.skill3Btn = objectReference:GetRefValue("skill3Btn")
	self.bigSkillWidget = objectReference:GetRefValue("SkillFinal")
	self.finalSkillBtn = objectReference:GetRefValue("finalSkillBtn")
	self.finalSkillBtnObjRef = self.finalSkillBtn:GetComponent("ObjectReference")
	self.panelSkill = objectReference:GetRefValue("skillPanel")
end

function MobileSkillRDUIComponent:initView()
	self.skillList = {
		self.skill3Btn,
		self.skill1Btn,
		self.skill2Btn
	}
	self.skillWidgets = {
		self.skill3Widget,
		self.skill1Widget,
		self.skill2Widget
	}

	self:initSkillListNecessaryTable()
	self:initFinalBtnRefInfo()
	AbilityUIUtils.fillExploreSkillInfo(self.skillListInfo[1])
	AbilityUIUtils.fillMobileBtnExtraSkillInfo(self.skillListInfo[1], self.skillWidgets[1])
	AbilityUIUtils.fillNormalAttackSkillInfo(self.skillListInfo[NORMAL_ATTACK_BTN_INDEX])
	AbilityUIUtils.fillCombatSkillInfo(self.skillListInfo[3], AbilityConst.PLAYER_INITIATIVE_TYPE.INITIATIVE_Q)
	AbilityUIUtils.fillMobileBtnExtraSkillInfo(self.skillListInfo[3], self.skillWidgets[2])
	AbilityUIUtils.fillCombatSkillInfo(self.skillListInfo[4], AbilityConst.PLAYER_INITIATIVE_TYPE.INITIATIVE_E)
	AbilityUIUtils.fillMobileBtnExtraSkillInfo(self.skillListInfo[4], self.skillWidgets[3])
	self:_initMobileCombatSkillBtn(self.skill3Btn, 1)
	self:_initMobileCombatSkillBtn(self.skill1Btn, 3)
	self:_initMobileCombatSkillBtn(self.skill2Btn, 4)
	self:tryBindNormalAttackButton()
	self:refreshSkillUIVisible()
	self:refreshArkMode()
	self:refreshExploreBtnVisible()
	self:refreshFinalSkill()
	self:refreshRogueSkill()
end

function MobileSkillRDUIComponent:onTeammateViewChange()
	if pg.me.inTeammateView then
		self.transform.gameObject:SetActiveEx(false)
	else
		self.transform.gameObject:SetActiveEx(true)
	end
end

function MobileSkillRDUIComponent:_initMobileCombatSkillBtn(button, index)
	local btnRefInfo = self:_cacheSkillBtnComponent(button, index)
	local skillInfo = self.skillListInfo[index]

	AbilityUIUtils.setSkillBtnInfo(btnRefInfo, skillInfo)
	AbilityUIUtils.registSkillBtnEventMobile(button, skillInfo)

	local skillBtnValid = skillInfo.abilityId ~= AbilityConst.ABILITY_ID_EMPTY

	btnRefInfo.dataValid = skillBtnValid

	LuaUIUtils.setUIVisible(button, skillInfo.visible and skillBtnValid)
end

function MobileSkillRDUIComponent:tryBindNormalAttackButton(mobile3C)
	if not self.skillListInfo or not self.skillBtnRefList then
		return
	end

	mobile3C = mobile3C or self.ctrl and self.ctrl.mobile3C

	if not mobile3C or not mobile3C.btnUButton or not mobile3C.normalAttackUImage then
		return
	end

	local btnRefInfo = self.skillBtnRefList[NORMAL_ATTACK_BTN_INDEX]

	if btnRefInfo.button == mobile3C.btnUButton and mobile3C.normalAttackBtnRef == btnRefInfo then
		return true
	end

	btnRefInfo = self:_cacheSkillBtnComponent(mobile3C.btnUButton, NORMAL_ATTACK_BTN_INDEX)
	btnRefInfo.icon = mobile3C.normalAttackUImage
	btnRefInfo.strengthenUContainer = btnRefInfo.strengthenUContainer or mobile3C.vXStrengthenGlowUContainer
	btnRefInfo.transUContainer = btnRefInfo.transUContainer or mobile3C.transUContainer
	btnRefInfo.countdownUContainer = btnRefInfo.countdownUContainer or mobile3C.countdownUContainer

	if not btnRefInfo.countdownUContainer:CheckURLLoaded() then
		btnRefInfo.countdownUContainer:LoadDefaultUrlManually(function(content)
			if content then
				local objectReference = content:GetComponent("ObjectReference")

				btnRefInfo.switchSkillCountDown = objectReference:GetRefValue("switchSkillCountDown")
			end
		end)
	end

	mobile3C.normalAttackBtnRef = btnRefInfo

	local skillInfo = self.skillListInfo[NORMAL_ATTACK_BTN_INDEX]
	local enableLuaStateCache = skillInfo.enableLuaStateCache

	skillInfo.enableLuaStateCache = false

	self:refreshNormalAttackBtn()

	skillInfo.enableLuaStateCache = enableLuaStateCache

	return true
end

function MobileSkillRDUIComponent:unbindNormalAttackButton(mobile3C)
	local btnRefInfo = self.skillBtnRefList and self.skillBtnRefList[NORMAL_ATTACK_BTN_INDEX]

	if btnRefInfo and mobile3C and btnRefInfo.button == mobile3C.btnUButton then
		self.skillBtnRefList[NORMAL_ATTACK_BTN_INDEX] = {
			dataValid = false
		}
	end
end

function MobileSkillRDUIComponent:getNormalAttackSkillInfo()
	return self.skillListInfo and self.skillListInfo[NORMAL_ATTACK_BTN_INDEX]
end

function MobileSkillRDUIComponent:_refreshNormalAttackOverride(btnRefInfo, skillInfo, icon)
	skillInfo.intensityData = nil

	AbilityUIUtils.setSkillIcon(btnRefInfo, skillInfo, icon)
	AbilityUIUtils.refreshSkillIntensityStyle(btnRefInfo, skillInfo)
	AbilityUIUtils.tryChangeButtonPage(btnRefInfo, skillInfo, "Change", 0)
	btnRefInfo.button:TryChangePage("Ready", 0)

	if btnRefInfo.switchSkillCountDown then
		btnRefInfo.switchSkillCountDown:Stop()
	end
end

function MobileSkillRDUIComponent:refreshNormalAttackBtn()
	local skillInfo = self:getNormalAttackSkillInfo()
	local btnRefInfo = self.skillBtnRefList and self.skillBtnRefList[NORMAL_ATTACK_BTN_INDEX]

	if not skillInfo or not btnRefInfo or not btnRefInfo.button then
		return false
	end

	local pawnCharacterState = pg.pawn and pg.pawn.characterState
	local isGliding = pawnCharacterState and CharacterStateConst.isChildOfState(pawnCharacterState, CharacterStateConst.GLIDING)
	local isSupportPet = pg.pawn and Utils.isSupportPet(pg.pawn)

	btnRefInfo.dataValid = skillInfo.abilityId ~= AbilityConst.ABILITY_ID_EMPTY and not isGliding and not isSupportPet

	if not btnRefInfo.dataValid then
		local icon = isGliding and AddressDataConst.EXPORE_SKILL_GLIDE_EXIT or skillInfo.skillIcon

		self:_refreshNormalAttackOverride(btnRefInfo, skillInfo, icon)
	else
		self:fillIntensityData(skillInfo)
		AbilityUIUtils.refreshSkillState(btnRefInfo, skillInfo)
	end

	local mobile3C = self.ctrl and self.ctrl.mobile3C

	if mobile3C then
		mobile3C:refreshNormalAttackFlyEmptyState()
	end

	return true
end

function MobileSkillRDUIComponent:refreshArkMode()
	if pg.me:checkArkSceneState() then
		self:enterArkMode()
	else
		self:exitArkMode()
	end
end

function MobileSkillRDUIComponent:enterArkMode()
	self.uWidget:TryChangePage("Synopsis", self.model.ARK)
end

function MobileSkillRDUIComponent:exitArkMode()
	self.uWidget:TryChangePage("Synopsis", self.model.NORMAL_PAGE)
end

function MobileSkillRDUIComponent:lockBtnPress()
	local _, page = self.uWidget:TryGetCurrentPage("Synopsis")

	if page == 2 then
		local controller = pg.game.controller

		if controller ~= nil then
			pg.global.eventEmitter:emit(EventConst.LOCK_ENITY_MSG, "switch", self)
		end
	else
		pg.game.input.skillInputProcessor:handleLockTargetActionPerformed()
	end
end

function MobileSkillRDUIComponent:switchBtnPress()
	local _, page = self.uWidget:TryGetCurrentPage("Synopsis")

	if page == 2 then
		local controller = pg.game.controller

		if controller ~= nil then
			pg.global.eventEmitter:emit(EventConst.LOCK_ENITY_MSG, "switch", self)
		end
	else
		pg.game.input.skillInputProcessor:handleLockTargetActionPerformed()
		pg.game.input.skillInputProcessor:handleLockTargetActionCanceled()
	end
end

function MobileSkillRDUIComponent:cancelLock(isPress)
	local _, page = self.uWidget:TryGetCurrentPage("Synopsis")

	if page == 2 then
		return
	else
		pg.game.controller.lockHelper:cancelLockTarget()
	end
end

function MobileSkillRDUIComponent:refreshSkillList(resetBtn)
	local skillListInfo = self.skillListInfo

	if not skillListInfo then
		return
	end

	if SampleUtils.sampleOn() then
		SampleUtils.beginSample("MobileSkillRDUIComponent.refreshSkillList")
	end

	self:refreshSkillUIVisible()
	AbilityUIUtils.fillExploreSkillInfo(self.skillListInfo[1])
	AbilityUIUtils.fillNormalAttackSkillInfo(self.skillListInfo[NORMAL_ATTACK_BTN_INDEX])
	AbilityUIUtils.fillCombatSkillInfo(self.skillListInfo[3], AbilityConst.PLAYER_INITIATIVE_TYPE.INITIATIVE_Q)
	AbilityUIUtils.fillCombatSkillInfo(self.skillListInfo[4], AbilityConst.PLAYER_INITIATIVE_TYPE.INITIATIVE_E)
	self:cacheResistInfo()
	self:refreshNormalAttackBtn()

	for idx, skillWidget in ipairs(self.skillWidgets) do
		local infoIndex = idx

		if idx > 1 then
			infoIndex = idx + 1
		end

		local skillInfo = skillListInfo[infoIndex]
		local btnRefInfo = self.skillBtnRefList[infoIndex]
		local button = btnRefInfo.button
		local skillBtnValid = self:_refreshSkillBtnValid(button, infoIndex, skillInfo)

		if skillInfo.skillWidgetVisible ~= skillBtnValid then
			skillInfo.skillWidgetVisible = skillBtnValid

			skillWidget:SetActiveFastestAndMarkIgnoreLayout(skillBtnValid)
		end

		if skillBtnValid then
			self:fillIntensityData(skillInfo)
			AbilityUIUtils.refreshSkillState(btnRefInfo, skillInfo)
		end
	end

	if self.lastEntId ~= pg.pawn.id then
		self.lastEntId = pg.pawn.id

		self:reactiveSkillItems()
	end

	self:refreshRogueSkill()
	self:refreshExploreBtnVisible()
	self:applyExploreFlyOverride()

	if SampleUtils.sampleOn() then
		SampleUtils.endSample()
	end
end

function MobileSkillRDUIComponent:applyExploreFlyOverride()
	local btnRefInfo = self.skillBtnRefList and self.skillBtnRefList[1]

	if not btnRefInfo or not btnRefInfo.icon then
		return
	end

	local pawnState = pg.pawn and pg.pawn.characterState
	local isFlying = pawnState and CharacterStateConst.isChildOfState(pawnState, CharacterStateConst.FLYING)
	local showUpDown = isFlying and not pg.me:isInCombat()
	local exploreInBattle = isFlying and pg.me:isInCombat() and pg.me.inExploreState

	if showUpDown or exploreInBattle then
		local skill1Info = self.skillListInfo[3]

		if skill1Info.skillWidgetVisible ~= false then
			skill1Info.skillWidgetVisible = false

			self.skill1Widget:SetActiveFastestAndMarkIgnoreLayout(false)
		end

		local skill2Info = self.skillListInfo[4]

		if skill2Info.skillWidgetVisible ~= false then
			skill2Info.skillWidgetVisible = false

			self.skill2Widget:SetActiveFastestAndMarkIgnoreLayout(false)
		end
	end

	if isFlying then
		local skillInfo = self.skillListInfo[1]

		skillInfo.isFloatingState = true
		skillInfo.ignoreValidation = true
		skillInfo.useCustomEvent = true
		skillInfo.btnText = pg.getGameString("HUD_FLOAT_BUTTON_EXIT")
		skillInfo.btnIcon = AddressDataConst.EXPORE_SKILL_FLY_EXIT

		AbilityUIUtils.refreshChangeState(btnRefInfo, skillInfo)
		AbilityUIUtils.refreshCostState(btnRefInfo, skillInfo)

		if btnRefInfo.countDown then
			LuaUIUtils.setUIViewVisible(btnRefInfo.countDown, false)
		end

		if btnRefInfo.pointListUContainer then
			skillInfo.loadCntVisible = false

			btnRefInfo.pointListUContainer.gameObject:SetActiveEx(false)
		end

		self.skill3Btn.interactable = true

		function self.skill3Btn.luaPress()
			if pg.pawn then
				pg.pawn:stopFly()
			end
		end

		self.skill3Btn.luaRelease = nil

		LuaUIUtils.setUIVisible(self.skill3Btn, true)

		if skillInfo.skillWidgetVisible ~= true then
			skillInfo.skillWidgetVisible = true

			self.skill3Widget:SetActiveFastestAndMarkIgnoreLayout(true)
		end

		self:refreshFinalSkillFlyEmptyState(true)

		self.exploreFlyOverrideActive = true
	elseif self.exploreFlyOverrideActive then
		local skillInfo = self.skillListInfo[1]

		skillInfo.isFloatingState = nil
		skillInfo.ignoreValidation = nil
		skillInfo.useCustomEvent = nil
		skillInfo.btnText = nil
		skillInfo.btnIcon = nil
		self.skill3Btn.interactable = true

		AbilityUIUtils.setSkillBtnInfo(btnRefInfo, skillInfo)
		AbilityUIUtils.registSkillBtnEventMobile(self.skill3Btn, skillInfo)
		self:refreshFinalSkillFlyEmptyState(false)

		self.exploreFlyOverrideActive = false
	end
end

function MobileSkillRDUIComponent:refreshFinalSkillFlyEmptyState(isFlying)
	self:refreshFinalBtnEmptyState()
end

function MobileSkillRDUIComponent:refreshSkillUIVisible()
	local skillListVisible = LuaUIUtils.getSkillListVisible()

	if pg.pawn and CharacterStateConst.isChildOfState(pg.pawn.characterState, CharacterStateConst.GLIDING) then
		skillListVisible = false
	end

	if self.skillUIVisible ~= skillListVisible then
		self.skillUIVisible = skillListVisible

		LuaUIUtils.setUIVisible(self.panelSkill, skillListVisible)
	end
end

function MobileSkillRDUIComponent:getSkillTipInfo(abilityId, templateId)
	local abParm = pg.global.abilityMgr:getAbilityParamData(abilityId)
	local item = {
		icon = LuaUIUtils.getSkillIcon(abParm.icon),
		desc = LuaUIUtils.getSkillDesc(abParm),
		eType = abParm.elementType,
		name = abParm.name,
		rare = AbilityUtils.isRareAbilityId(abilityId, templateId),
		tags = abParm.tags,
		epCost = abParm.epCost,
		power = abParm.power
	}

	return item
end

function MobileSkillRDUIComponent:setSkillAttrList(button, idx, data)
	local name = button:Find("TxtName"):GetComponent("UBaseText")
	local num = button:Find("Num"):GetComponent("UBaseText")

	if data.attrType == 0 then
		ClientTextUtils.setText(name, pg.getGameString(data.name))
		ClientTextUtils.setText(num, data.num)
		LuaUIUtils.setUIViewVisible(num, true)
		button:TryChangePage("IconType", data.iconIdx)
	elseif data.attrType == 1 then
		ClientTextUtils.setText(name, pg.getLocalizationText(data.name))
		LuaUIUtils.setUIViewVisible(num, false)
	end
end

function MobileSkillRDUIComponent:refreshRogueSkill()
	self:tryInitRogueSkillBtn()

	if not self.btnPetExChangeUContainer then
		return
	end

	local skillInfo = self:getRogueSkill()
	local rogueSkillVisible = skillInfo ~= nil

	if self.rogueSkillVisible ~= rogueSkillVisible then
		self.rogueSkillVisible = rogueSkillVisible

		self.btnPetExChangeUContainer:SetActive(rogueSkillVisible)
	end

	if skillInfo then
		AbilityUIUtils.refreshRogueSkill(self.btnPetExChangeUContainer, skillInfo)
	end
end

function MobileSkillRDUIComponent:refreshRogueChangeState()
	self:tryInitRogueSkillBtn()

	if not self.btnPetExChangeUContainer then
		return
	end

	local skillInfo = self:getRogueSkill()

	if skillInfo then
		self.btnPetExChangeUContainer:SetActive(true)
		AbilityUIUtils.refreshRogueSkill(self.btnPetExChangeUContainer, skillInfo)
	else
		self.btnPetExChangeUContainer:SetActive(false)
	end
end

function MobileSkillRDUIComponent:tryInitRogueSkillBtn()
	if not self.btnPetExChangeUContainer and pg.global.ui.hudV2.LD and pg.global.ui.hudV2.LD.mobileAddonBtn then
		self.btnPetExChangeUContainer = pg.global.ui.hudV2.LD.mobileAddonBtn.btnPetExChangeUContainer
	end
end

function MobileSkillRDUIComponent:onCombatStatusChange()
	if not pg.pawn.isExplorePet then
		self:refreshSkillList()
	end
end

function MobileSkillRDUIComponent:refreshExploreBtnState()
	local isControllingPet = pg.me:isControllingPet()
	local isControllingEgg = pg.me:isControllingEgg()
	local exploreBtn = self.ctrl and self.ctrl.exploreBtn
	local hudExploreState = exploreBtn and exploreBtn.exploreState or 0
	local isInHudExplorePage = exploreBtn and hudExploreState ~= exploreBtn.EXPLORE_TYPE.None and hudExploreState ~= exploreBtn.EXPLORE_TYPE.SpaceFollow
	local exploreJumpBtnVisible = true
	local exploreDashBtnVisible = true

	if not pg.game.controller:isInDelayExit() then
		self.dashBtn:TryChangePage("FuseState", isControllingPet and 1 or 0)
		self.jumpBtn:TryChangePage("FuseState", isControllingPet and 1 or 0)
	end

	local pawnCharacterState = pg.pawn.characterState

	if CharacterStateConst.isChildOfState(pawnCharacterState, CharacterStateConst.SWIMMING) then
		if isControllingPet then
			self.btnJumpAndDashVisible = true
		else
			self.btnJumpAndDashVisible = false
		end
	elseif CharacterStateConst.isChildOfState(pawnCharacterState, CharacterStateConst.GLIDING) then
		self.btnJumpAndDashVisible = false
	elseif pg.pawn and pg.pawn:RIDING_ST() then
		self.btnJumpAndDashVisible = false
	else
		self.btnJumpAndDashVisible = true

		if CharacterStateConst.isChildOfState(pawnCharacterState, CharacterStateConst.CLIMBING) then
			exploreJumpBtnVisible = false
		end
	end

	if isControllingEgg then
		self.btnJumpAndDashVisible = true
		exploreJumpBtnVisible = true
		exploreDashBtnVisible = true
	end

	local canShowExploreJumpDashBtn = isInHudExplorePage and self.btnJumpAndDashVisible

	self:refreshSkillUIVisible()
end

function MobileSkillRDUIComponent:onSpaceFollowInfoChanged(info)
	self.btnJumpAndDashVisible = not pg.me.space:isSpaceFollowMember(pg.me.uid)

	self:refreshSkillUIVisible()
end

function MobileSkillRDUIComponent:onVehicleShowStateChanged(info)
	if info.showVehicleInter then
		self.uWidget:TryChangePage("Synopsis", self.model.VEHICLE)
	else
		self:refreshArkMode()
	end
end

function MobileSkillRDUIComponent:playShowAnim()
	if self.uWidget then
		self.uWidget:InvokeCallback(CS.XGUI.EInvokeTime.Show)
	end
end

function MobileSkillRDUIComponent:playHideAnim()
	if self.uWidget then
		self.uWidget:InvokeCallback(CS.XGUI.EInvokeTime.Hide)
	end
end

return MobileSkillRDUIComponent
