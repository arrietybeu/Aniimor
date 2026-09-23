-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\Mobile3CUIComponent.lua

local logger = require("Core.Log.LoggerManager").getLogger("Mobile3CUIComponent")
local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local AbilityUIUtils = require("Utils.AbilityUIUtils")
local AbilityUtils = require("Common.Utils.AbilityUtils")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local ClientConst = require("Const.ClientConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local MessageName = require("Const.MessageName")
local AddressDataConst = require("Const.AddressDataConst")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local Mobile3CUIComponent = Class.LightClass("Mobile3CUIComponent", HudBaseComponent)
local Const = require("Common.Const.Const")
local TagMask = CS.FunPlus.WorldX.Animations.TagMask

Mobile3CUIComponent.messages = {
	[MessageName.CHARACTER_STATE_CHANGED] = {
		"onCharacterStateChanged",
		true
	},
	[MessageName.CONTROLLER_SWITCH_UPDATE] = {
		"onControllerSwitchUpdate",
		true
	},
	[MessageName.SPACE_FOLLOW_UPDATE] = {
		"onSpaceFollowInfoChanged",
		true
	},
	[MessageName.MODULE_ENABLE_CHANGED] = {
		"onModuleEnableChanged",
		true
	},
	[MessageName.ON_CONTROL_ENT] = {
		"refreshSkillUIVisible",
		true
	},
	[MessageName.INTERACT_GESTURE_STATE_CHANGE] = {
		"onInteractGestureStateChanged",
		true
	},
	[MessageName.DUNGEON_TEAMMATEVIEW_CHANGE] = {
		"onTeammateViewChange",
		true
	},
	[MessageName.ENTER_LIFE_FALLEN] = {
		"refreshSkillUIVisible",
		true
	},
	[MessageName.ENTER_LIFE_ALIVE] = {
		"refreshSkillUIVisible",
		true
	},
	[MessageName.PET_EXPLORE_STATE_CHANGED] = {
		"onPetExploreStateChange",
		true
	}
}

function Mobile3CUIComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnDashUButton = objectReference:GetRefValue("btnDashUButton")
	self.btnJumpUButton = objectReference:GetRefValue("btnJumpUButton")
	self.btnUButton = objectReference:GetRefValue("btnUButton")
	self.normalAttackUImage = objectReference:GetRefValue("normalAttackUImage")

	local dashBtnObjRef = self.btnDashUButton:GetComponent("ObjectReference")

	self.dashBtnUImage = dashBtnObjRef:GetRefValue("petUImage")

	local jumpBtnObjRef = self.btnJumpUButton:GetComponent("ObjectReference")

	self.jumpBtnUImage = jumpBtnObjRef:GetRefValue("petUImage")

	local normalAttackObjectReference = self.btnUButton:GetComponent("ObjectReference")

	self.vXStrengthenGlowUContainer = normalAttackObjectReference:GetRefValue("vXStrengthenGlowUContainer")
	self.transUContainer = normalAttackObjectReference:GetRefValue("transUContainer")
	self.countdownUContainer = normalAttackObjectReference:GetRefValue("countdownUContainer")
	self.normalAttackBtnRef = {
		button = self.btnUButton,
		icon = self.normalAttackUImage,
		strengthenUContainer = self.vXStrengthenGlowUContainer,
		transUContainer = self.transUContainer,
		countdownUContainer = self.countdownUContainer
	}
end

function Mobile3CUIComponent:initView()
	self.btnUButton.enabledLongPress = true
	self.btnUButton.longPressDelay = 0.1

	function self.btnUButton.luaPress()
		if self.isGliding then
			pg.pawn:stopGlide()

			return
		end

		AbilityUIUtils.handleNormalAttackActionPerformed(self)
	end

	function self.btnUButton.luaRelease()
		if self.isGliding then
			return
		end

		AbilityUIUtils.handleNormalAttackActionCanceled(self)
	end

	function self.btnJumpUButton.luaPress()
		if self.isGliding and not pg.me:isInCombat() then
			pg.pawn:glideRise()

			return
		end

		if pg.game.controller ~= nil then
			self.hasPressedJump = true

			local pawnCharacterState = pg.pawn and pg.pawn.characterState
			local isClimbing = pawnCharacterState and CharacterStateConst.isChildOfState(pawnCharacterState, CharacterStateConst.CLIMBING)
			local isWaterClimbing = pawnCharacterState and CharacterStateConst.isChildOfState(pawnCharacterState, CharacterStateConst.CLIMBWATERFALL)

			if isClimbing or isWaterClimbing then
				pg.game.controller:onHandleDash(true)
			else
				pg.game.controller:onHandleJump(true)
			end
		end
	end

	function self.btnJumpUButton.luaRelease()
		if self.isGliding and not pg.me:isInCombat() then
			return
		end

		if pg.game.controller ~= nil then
			self.hasPressedJump = false

			local pawnCharacterState = pg.pawn and pg.pawn.characterState
			local isClimbing = pawnCharacterState and CharacterStateConst.isChildOfState(pawnCharacterState, CharacterStateConst.CLIMBING)
			local isWaterClimbing = pawnCharacterState and CharacterStateConst.isChildOfState(pawnCharacterState, CharacterStateConst.CLIMBWATERFALL)

			if isClimbing or isWaterClimbing then
				pg.game.controller:onHandleDash(false)
			else
				pg.game.controller:onHandleJump(false)
			end
		end
	end

	function self.btnDashUButton.luaPress()
		if pg.game.controller ~= nil then
			pg.game.controller:onHandleDash(true)
		end
	end

	function self.btnDashUButton.luaRelease()
		if pg.game.controller ~= nil then
			pg.game.controller:onHandleDash(false)
		end
	end

	self.isInExploreMode = false
	self.exploreBtnVisible = false
	self.normalAtkBtnStateByExplore = self:initNormalAtkBtnState()

	self:refreshSkillUIVisible()
	self:refreshSkillCharacterState()
	self:refreshDashJumpBtnState()

	if self.ctrl.mobileSkill then
		self.ctrl.mobileSkill:tryBindNormalAttackButton(self)
	end

	self:refreshArkMode()
end

function Mobile3CUIComponent:onTeammateViewChange()
	if pg.me.inTeammateView then
		self.transform.gameObject:SetActiveEx(false)
	else
		self.transform.gameObject:SetActiveEx(true)
	end
end

function Mobile3CUIComponent:refreshArkMode()
	if pg.me:checkArkSceneState() then
		self:enterArkMode()
	else
		self:exitArkMode()
	end
end

function Mobile3CUIComponent:enterArkMode()
	self.uWidget:TryChangePage("Synopsis", self.model.ARK)
end

function Mobile3CUIComponent:exitArkMode()
	self.uWidget:TryChangePage("Synopsis", self.model.NORMAL_PAGE)
end

function Mobile3CUIComponent:onDestroy()
	if self.ctrl.mobileSkill then
		self.ctrl.mobileSkill:unbindNormalAttackButton(self)
	end

	HudBaseComponent.onDestroy(self)
end

function Mobile3CUIComponent:refreshSkillUIVisible(excludeNormalAtk)
	if not excludeNormalAtk then
		self:refreshNormalAttackBtn()
	end

	local dashVisible, dashIcon, dashEnabled, jumpVisible, jumpIcon, jumpEnabled
	local dashAndJumpCommonVisible = self:getDashJumpCommonVisible()

	if dashAndJumpCommonVisible == false then
		dashVisible = false
		jumpVisible = false
	else
		local isSwimming, isGliding, isFlying, isClimbing, isWaterClimb = self:getCurPawnExploreState()

		dashVisible, dashIcon, dashEnabled = self:getDashVisible(isSwimming, isGliding, isFlying, isClimbing, isWaterClimb)
		jumpVisible, jumpIcon, jumpEnabled = self:getJumpVisible(isSwimming, isGliding, isFlying, isClimbing, isWaterClimb)
	end

	if dashVisible and dashIcon and dashIcon ~= self.dashBtnIcon then
		self.dashBtnIcon = dashIcon
		self.dashBtnUImage.url = dashIcon
	end

	if jumpVisible and jumpIcon and jumpIcon ~= self.jumpBtnIcon then
		self.jumpBtnIcon = jumpIcon
		self.jumpBtnUImage.url = jumpIcon
	end

	if self.dashBtnVisible ~= dashVisible then
		self.dashBtnVisible = dashVisible

		LuaUIUtils.setUIVisible(self.btnDashUButton, dashVisible)
	end

	if self.jumpBtnVisible ~= jumpVisible then
		self.jumpBtnVisible = jumpVisible

		LuaUIUtils.setUIVisible(self.btnJumpUButton, jumpVisible)
	end

	local dashBtnDisabled = dashEnabled == false
	local jumpBtnDisabled = jumpEnabled == false
	local dashInteractable = dashVisible and not dashBtnDisabled
	local jumpInteractable = jumpVisible and not jumpBtnDisabled

	if self.dashInteractable ~= dashInteractable then
		self.dashInteractable = dashInteractable
		self.btnDashUButton.interactable = dashInteractable
	end

	if self.jumpInteractable ~= jumpInteractable then
		self.jumpInteractable = jumpInteractable
		self.btnJumpUButton.interactable = jumpInteractable
	end

	if self.dashBtnDisabled ~= dashBtnDisabled then
		self.dashBtnDisabled = dashBtnDisabled

		self.btnDashUButton:TryChangePage("button", dashBtnDisabled and 4 or 0)
	end

	if self.jumpBtnDisabled ~= jumpBtnDisabled then
		self.jumpBtnDisabled = jumpBtnDisabled

		self.btnJumpUButton:TryChangePage("button", jumpBtnDisabled and 4 or 0)
	end
end

function Mobile3CUIComponent:refreshSkillCharacterState()
	if not pg.pawn then
		return
	end

	local characterState = pg.pawn.characterState

	self.btnDashUButton:TryChangePage("Hold", characterState == CharacterStateConst.SPRINT and 1 or 0)
end

function Mobile3CUIComponent:refreshExploreBtnState()
	self:refreshDashJumpBtnState()
	self:refreshSkillUIVisible(true)
end

function Mobile3CUIComponent:refreshDashJumpBtnState()
	if not pg.game.controller:isInDelayExit() then
		local btnFuseState = pg.me:isControllingPet() and 1 or 0

		if self.btnFuseState ~= btnFuseState then
			self.btnFuseState = btnFuseState

			self.btnDashUButton:TryChangePage("FuseState", btnFuseState)
			self.btnJumpUButton:TryChangePage("FuseState", btnFuseState)
		end
	end

	local pawnCharacterState = pg.pawn and pg.pawn.characterState
	local isFlying = pawnCharacterState and CharacterStateConst.isChildOfState(pawnCharacterState, CharacterStateConst.FLYING)
	local isGliding = pawnCharacterState and CharacterStateConst.isChildOfState(pawnCharacterState, CharacterStateConst.GLIDING)

	if self.isFlying ~= isFlying then
		self.isFlying = isFlying

		self.btnDashUButton:TryChangePage("CanFly", isFlying and 1 or 0)
	end

	if self.isGliding ~= isGliding then
		self.isGliding = isGliding

		self.btnJumpUButton:TryChangePage("CanFly", isGliding and 1 or 0)

		local mobileSkill = self.ctrl.mobileSkill
		local normalAttackRefreshed = mobileSkill and mobileSkill:refreshNormalAttackBtn()

		if not normalAttackRefreshed then
			self.normalAttackUImage.url = isGliding and AddressDataConst.EXPORE_SKILL_GLIDE_EXIT or AddressDataConst.MOBILE_NORMAL_ATTACK
		end
	end
end

function Mobile3CUIComponent:refreshNormalAttackFlyEmptyState()
	local pawnCharacterState = pg.pawn and pg.pawn.characterState
	local isFlying = pawnCharacterState and CharacterStateConst.isChildOfState(pawnCharacterState, CharacterStateConst.FLYING)
	local interactable = true
	local emptyState = self:getIsNormalAttackEmpty() and 1 or 0

	if emptyState ~= 1 and isFlying then
		if pg.me:isControllingExplorePet() then
			self.btnUButton:TryChangePage("Ready", 1)

			emptyState = 1
		else
			local abilityId = AbilityUtils:getNormalAttackAbilityId()

			abilityId = abilityId and pg.pawn:getSwitchSkill(abilityId)

			if not abilityId or abilityId == 0 or pg.pawn and pg.pawn.checkCharacterStateCastAbilityValid and not pg.pawn:checkCharacterStateCastAbilityValid(abilityId) then
				self.btnUButton:TryChangePage("Ready", 2)

				interactable = false
			end
		end
	end

	if self.normalAtkBtnEmptyState ~= emptyState then
		self.normalAtkBtnEmptyState = emptyState

		self.btnUButton:TryChangePage("EmptyState", emptyState)
	end

	interactable = interactable and emptyState == 0
	self.btnUButton.interactable = interactable
end

function Mobile3CUIComponent:initNormalAtkBtnState()
	local ent = pg.pawn

	if not ent then
		return ClientConst.NORMAL_ATTACK_BTN_SHOW_MODE.EMPTY
	end

	if CharacterStateConst.isChildOfState(ent.characterState, CharacterStateConst.SWIMMING) then
		return ClientConst.NORMAL_ATTACK_BTN_SHOW_MODE.EMPTY
	elseif CharacterStateConst.isChildOfState(ent.characterState, CharacterStateConst.CLIMBWATERFALL) then
		return ClientConst.NORMAL_ATTACK_BTN_SHOW_MODE.HIDE
	elseif CharacterStateConst.isChildOfState(ent.characterState, CharacterStateConst.CLIMBING) then
		return ClientConst.NORMAL_ATTACK_BTN_SHOW_MODE.HIDE
	elseif CharacterStateConst.isChildOfState(ent.characterState, CharacterStateConst.GLIDING) then
		return ClientConst.NORMAL_ATTACK_BTN_SHOW_MODE.NORMAL
	elseif CharacterStateConst.isChildOfState(ent.characterState, CharacterStateConst.FLYING) then
		return ClientConst.NORMAL_ATTACK_BTN_SHOW_MODE.NORMAL
	elseif pg.game.controller:isInDelayExit() then
		return ClientConst.NORMAL_ATTACK_BTN_SHOW_MODE.HIDE
	elseif pg.me:isControllingExploreEnt() then
		return ClientConst.NORMAL_ATTACK_BTN_SHOW_MODE.EMPTY
	elseif pg.game.social.interactGestureComponent:checkInteractGesturePlaying() then
		return ClientConst.NORMAL_ATTACK_BTN_SHOW_MODE.HIDE
	elseif pg.me.space and pg.me.space:isSpaceFollowMember(pg.me.uid) and (pg.me.followState == Const.SpaceFollowMemberState.Normal or pg.me.followState == Const.SpaceFollowMemberState.Attach) then
		return ClientConst.NORMAL_ATTACK_BTN_SHOW_MODE.HIDE
	end

	return ClientConst.NORMAL_ATTACK_BTN_SHOW_MODE.NORMAL
end

function Mobile3CUIComponent:refreshNormalAttackBtn()
	local normalAttackVisible = self:getNormalAttackVisible()

	if self.normalAtkBtnVisible ~= normalAttackVisible then
		self.normalAtkBtnVisible = normalAttackVisible

		LuaUIUtils.setUIVisible(self.btnUButton, normalAttackVisible)
	end

	self:refreshNormalAttackFlyEmptyState()
	self:refreshNormalAttackIntensity()
end

function Mobile3CUIComponent:getNormalAttackVisible()
	if self.normalAtkBtnStateByExplore == ClientConst.NORMAL_ATTACK_BTN_SHOW_MODE.HIDE then
		return false
	end

	if Utils.isPlayer(pg.pawn) and pg.pawn:SWIM_ST() then
		return false
	end

	if not pg.game:checkModuleEnable(ClientConst.ModuleKey.NormalAttack) then
		local disableInfo = pg.game.moduleDisableMap[ClientConst.ModuleKey.NormalAttack]

		if disableInfo.EggMode == nil and disableInfo.Magnesis == nil then
			return true
		end

		return false
	end

	if pg.me and pg.me:FALLEN_ST() then
		return false
	end

	return true
end

function Mobile3CUIComponent:getIsNormalAttackEmpty()
	if pg.me:checkArkSceneState() and self.normalAtkBtnStateByExplore ~= ClientConst.NORMAL_ATTACK_BTN_SHOW_MODE.HIDE then
		return true
	end

	if self.normalAtkBtnStateByExplore == ClientConst.NORMAL_ATTACK_BTN_SHOW_MODE.EMPTY then
		return true
	end

	if not pg.game:checkModuleEnable(ClientConst.ModuleKey.NormalAttack) then
		local disableInfo = pg.game.moduleDisableMap[ClientConst.ModuleKey.NormalAttack]

		if disableInfo.EggMode == nil and disableInfo.Magnesis == nil then
			return true
		end
	end

	return false
end

function Mobile3CUIComponent:getDashJumpCommonVisible()
	local player = pg.me

	if player then
		if pg.space and pg.space:isSpaceFollowMember(player.uid) and player.followState == Const.SpaceFollowMemberState.Normal then
			return false
		end

		if player:RIDING_ST() then
			return false
		end

		if player:FALLEN_ST() then
			return false
		end
	end

	if pg.game.social and pg.game.social.interactGestureComponent and pg.game.social.interactGestureComponent:checkInteractGesturePlaying() then
		return false
	end

	return true
end

function Mobile3CUIComponent:getCurPawnExploreState()
	local pawnCharacterState = pg.pawn and pg.pawn.characterState
	local isSwimming = false
	local isGliding = false
	local isFlying = false
	local isClimbing = false
	local isWaterClimb = false

	if pawnCharacterState then
		if CharacterStateConst.isChildOfState(pawnCharacterState, CharacterStateConst.SWIMMING) then
			isSwimming = true
		elseif CharacterStateConst.isChildOfState(pawnCharacterState, CharacterStateConst.GLIDING) then
			isGliding = true
		elseif CharacterStateConst.isChildOfState(pawnCharacterState, CharacterStateConst.FLYING) then
			isFlying = true
		elseif CharacterStateConst.isChildOfState(pawnCharacterState, CharacterStateConst.CLIMBING) then
			isClimbing = true
		elseif CharacterStateConst.isChildOfState(pawnCharacterState, CharacterStateConst.CLIMBWATERFALL) then
			isWaterClimb = true
		end
	end

	return isSwimming, isGliding, isFlying, isClimbing, isWaterClimb
end

function Mobile3CUIComponent:getDashVisible(isSwimming, isGliding, isFlying, isClimbing, isWaterClimb)
	if not pg.game:checkModuleEnable(ClientConst.ModuleKey.Dash) then
		return false
	end

	if Utils.isPlayer(pg.pawn) and isSwimming then
		return false
	end

	local icon = AddressDataConst.EXPORE_SKILL_SWIM

	if isGliding then
		return false
	end

	if isSwimming then
		icon = AddressDataConst.EXPORE_SKILL_SWIM
	end

	if isFlying then
		if pg.pawn:getConfigData().canFly ~= 3 then
			return false
		end

		icon = AddressDataConst.EXPORE_SKILL_FLY

		if pg.me:judgeStaminaInCombat(TagMask.Fly) then
			return true, icon, false
		end
	end

	if isClimbing then
		return false
	end

	if isWaterClimb then
		return false
	end

	return true, icon
end

function Mobile3CUIComponent:getJumpVisible(isSwimming, isGliding, isFlying, isClimbing, isWaterClimb)
	local icon = AddressDataConst.EXPLORE_SKILL_JUMP

	if isGliding and pg.me:isInCombat() then
		return true, nil, false
	end

	if isFlying then
		return false
	end

	if isClimbing then
		icon = AddressDataConst.EXPORE_SKILL_CLIMB
	end

	if isSwimming then
		local isControllingPet = pg.me:isControllingPet()

		icon = AddressDataConst.EXPORE_SKILL_SWIM_RISE

		return isControllingPet, icon
	end

	if isWaterClimb then
		local isControllingPet = pg.me:isControllingPet()

		icon = AddressDataConst.EXPORE_SKILL_WATER_CLIMB_DASH

		return isControllingPet, icon
	end

	return true, icon
end

function Mobile3CUIComponent:refreshNormalAttackIntensity()
	local mobileSkill = self.ctrl.mobileSkill
	local skillInfo = mobileSkill and mobileSkill:getNormalAttackSkillInfo()

	if not skillInfo or not self.normalAttackBtnRef or not self.normalAttackBtnRef.dataValid then
		return
	end

	mobileSkill:fillIntensityData(skillInfo)
	AbilityUIUtils.refreshSkillIntensityStyle(self.normalAttackBtnRef, skillInfo)
end

function Mobile3CUIComponent:onCharacterStateChanged()
	self:refreshSkillCharacterState()
	self:refreshExploreBtnState()

	if self.isFlying and self.hasPressedJump then
		self.hasPressedJump = false

		if pg.game.controller ~= nil then
			pg.game.controller:onHandleJump(false)
		end
	end
end

function Mobile3CUIComponent:onControllerSwitchUpdate(info)
	if info == nil then
		return
	end

	self:refreshDashJumpBtnState()
end

function Mobile3CUIComponent:onSpaceFollowInfoChanged(info)
	self:refreshSkillUIVisible()
end

function Mobile3CUIComponent:onModuleEnableChanged(changeInfo)
	local moduleKey = changeInfo.moduleKey or ""

	if moduleKey == ClientConst.ModuleKey.NormalAttack or moduleKey == ClientConst.ModuleKey.Dash then
		self:refreshSkillUIVisible()
	end
end

function Mobile3CUIComponent:onInteractGestureStateChanged()
	self:refreshSkillUIVisible()
end

function Mobile3CUIComponent:onPetExploreStateChange()
	self:refreshExploreBtnState()
end

function Mobile3CUIComponent:onExploreModeChanged(inExplore)
	self.isInExploreMode = inExplore

	self:refreshExploreBtnState()
end

function Mobile3CUIComponent:notifyNormalAtkBtnStateChanged(state)
	self.normalAtkBtnStateByExplore = state

	self:refreshNormalAttackBtn()
end

function Mobile3CUIComponent:playShowAnim()
	if self.uWidget then
		self.uWidget:InvokeCallback(CS.XGUI.EInvokeTime.Show)
	end
end

function Mobile3CUIComponent:playHideAnim()
	if self.uWidget then
		self.uWidget:InvokeCallback(CS.XGUI.EInvokeTime.Hide)
	end
end

return Mobile3CUIComponent
