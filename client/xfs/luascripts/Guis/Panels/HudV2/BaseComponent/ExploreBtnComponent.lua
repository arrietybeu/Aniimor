-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\ExploreBtnComponent.lua

local Class = require("Core.Framework.Class")
local MessageName = require("Const.MessageName")
local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientConst = require("Const.ClientConst")
local CharacterStateConst = require("Common.Const.CharacterStateConst")
local InputCommand = require("GameApp.Input.InputCommand")
local Const = require("Common.Const.Const")
local AddressDataConst = require("Const.AddressDataConst")
local ExploreBtnComponent = Class.LightClass("ExploreBtnComponent", HudBaseComponent)
local EXPLORE_TYPE = {
	WaterfallClimb = 9,
	Fly = 8,
	InteractGesture = 7,
	SpaceFollow = 6,
	InExploreEnt = 5,
	DelayExit = 4,
	Glide = 3,
	Swim = 2,
	Climb = 1,
	None = 0
}

ExploreBtnComponent.EXPLORE_TYPE = EXPLORE_TYPE
ExploreBtnComponent.messages = {
	[MessageName.ON_CONTROL_EXPLORE_PET] = {
		"onControlExplorePet",
		true
	},
	[MessageName.PET_EXPLORE_STATE_CHANGED] = {
		"onPetExploreStateChanged",
		true
	},
	[MessageName.PET_GHOST_EYE_STATE_CHANGED] = {
		"onPetGhostEyeStateChanged",
		true
	},
	[MessageName.SCENT_TRACK_STATE_CHANGED] = {
		"refreshHudExplorePageState",
		true
	},
	[MessageName.ENTER_EXIT_DELAY_EXPLORE_STATE] = {
		"onDelayExitExploreStateChange",
		true
	},
	[MessageName.EXIT_EXIT_DELAY_EXPLORE_STATE] = {
		"onDelayExitExploreStateChange",
		true
	},
	[MessageName.PLAYER_START_CARRY] = {
		"onPlayerStartCarryEnt",
		true
	},
	[MessageName.PLAYER_STOP_CARRY] = {
		"onPlayerStopCarryEnt",
		true
	},
	[MessageName.SPACE_FOLLOW_UPDATE] = {
		"onSpaceFollowInfoChanged",
		true
	},
	[MessageName.CHARACTER_STATE_CHANGED] = {
		"onCharacterStateChanged",
		true
	},
	[MessageName.MODULE_ENABLE_CHANGED] = {
		"onModuleEnableChanged",
		true
	},
	[MessageName.INTERACT_GESTURE_STATE_CHANGE] = {
		"onInteractGestureStateChanged",
		true
	},
	[MessageName.ON_CONTROL_ENT] = {
		"refreshHudExplorePageState",
		true
	},
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"refreshHudExplorePageState",
		true
	},
	[MessageName.GRAB_EGG_STRUGGLE_STATE_CHANGED] = {
		"refreshHudExplorePageState",
		true
	},
	[MessageName.GRAB_EGG_HUG_STATE_CHANGED] = {
		"refreshHudExplorePageState",
		true
	}
}

function ExploreBtnComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.btnNormalUButton = objectReference:GetRefValue("btnSpecialUButton")
end

function ExploreBtnComponent:initView()
	self.checkExploreState = false
	self.isInExploreMode = false
	self.normalBtnVisible = false

	LuaUIUtils.setUIViewVisible(self.btnNormalUButton, false)
end

function ExploreBtnComponent:getCurExploreState()
	local ent = pg.pawn

	if not ent then
		return EXPLORE_TYPE.None
	end

	if CharacterStateConst.isChildOfState(ent.characterState, CharacterStateConst.SWIMMING) then
		return EXPLORE_TYPE.Swim
	elseif CharacterStateConst.isChildOfState(ent.characterState, CharacterStateConst.CLIMBWATERFALL) then
		return EXPLORE_TYPE.WaterfallClimb
	elseif CharacterStateConst.isChildOfState(ent.characterState, CharacterStateConst.CLIMBING) then
		return EXPLORE_TYPE.Climb
	elseif CharacterStateConst.isChildOfState(ent.characterState, CharacterStateConst.GLIDING) then
		return EXPLORE_TYPE.Glide
	elseif CharacterStateConst.isChildOfState(ent.characterState, CharacterStateConst.FLYING) then
		return EXPLORE_TYPE.Fly
	elseif pg.game.controller:isInDelayExit() then
		return EXPLORE_TYPE.DelayExit
	elseif pg.me:isControllingExploreEnt() then
		return EXPLORE_TYPE.InExploreEnt
	elseif pg.game.social.interactGestureComponent:checkInteractGesturePlaying() then
		return EXPLORE_TYPE.InteractGesture
	elseif pg.me.space and pg.me.space:isSpaceFollowMember(pg.me.uid) and (pg.me.followState == Const.SpaceFollowMemberState.Normal or pg.me.followState == Const.SpaceFollowMemberState.Attach) then
		return EXPLORE_TYPE.SpaceFollow
	end

	return EXPLORE_TYPE.None
end

function ExploreBtnComponent:innerRefreshExploreState(exploreState)
	local ent = pg.pawn

	if not ent then
		return false
	end

	local result = false

	self.btnNormalUButton.luaPress = nil
	self.btnNormalUButton.luaRelease = nil
	self.btnNormalUButton.luaClick = nil

	if exploreState == EXPLORE_TYPE.Swim then
		self:_setNormalBtnVisible(false, ClientConst.NORMAL_ATTACK_BTN_SHOW_MODE.EMPTY)
		self.btnNormalUButton:TryChangePage("PetChar", 3)

		result = true
	elseif exploreState == EXPLORE_TYPE.WaterfallClimb then
		self:_setNormalBtnVisible(true, ClientConst.NORMAL_ATTACK_BTN_SHOW_MODE.HIDE)
		self.btnNormalUButton:TryChangePage("PetChar", 0)

		local objectReference = self.btnNormalUButton:GetComponent("ObjectReference")
		local btnNormalKeyBindingPro = objectReference:GetRefValue("btnNormalKeyBindingPro")
		local icon = objectReference:GetRefValue("iconUImage")

		if icon then
			icon.url = AddressDataConst.EXPLORE_SKILL_WATER_CLIMB_QUIT
		end

		btnNormalKeyBindingPro.actionPath = "Bind/WaterClimbJump"

		function self.btnNormalUButton.luaClick()
			pg.pawn.eModel:SetInputCommand(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, InputCommand.ClimbJump)
		end

		result = true
	elseif exploreState == EXPLORE_TYPE.Climb then
		self:_setNormalBtnVisible(true, ClientConst.NORMAL_ATTACK_BTN_SHOW_MODE.HIDE)
		self.btnNormalUButton:TryChangePage("PetChar", 1)

		local objectReference = self.btnNormalUButton:GetComponent("ObjectReference")
		local btnNormalKeyBindingPro = objectReference:GetRefValue("btnNormalKeyBindingPro")

		btnNormalKeyBindingPro.actionPath = "Player/ClimbJump"

		function self.btnNormalUButton.luaClick()
			pg.pawn.eModel:SetInputCommand(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, InputCommand.ClimbJump)
		end

		result = true
	elseif exploreState == EXPLORE_TYPE.Glide or exploreState == EXPLORE_TYPE.Fly then
		self:_setNormalBtnVisible(false, ClientConst.NORMAL_ATTACK_BTN_SHOW_MODE.NORMAL)
	elseif exploreState == EXPLORE_TYPE.DelayExit then
		self:setExitExploreButton()

		result = true
	elseif exploreState == EXPLORE_TYPE.InExploreEnt then
		self:_setNormalBtnVisible(false, ClientConst.NORMAL_ATTACK_BTN_SHOW_MODE.EMPTY)

		result = true
	elseif exploreState == EXPLORE_TYPE.SpaceFollow then
		self:_setNormalBtnVisible(true, ClientConst.NORMAL_ATTACK_BTN_SHOW_MODE.HIDE)
		self.btnNormalUButton:TryChangePage("PetChar", 4)

		local objectReference = self.btnNormalUButton:GetComponent("ObjectReference")
		local btnNormalKeyBindingPro = objectReference:GetRefValue("btnNormalKeyBindingPro")

		btnNormalKeyBindingPro.actionPath = "Hud/QuitExploreState"

		function self.btnNormalUButton.luaClick()
			pg.me:exitSpaceFollow()
		end

		result = true
	elseif exploreState == EXPLORE_TYPE.InteractGesture then
		self:_setNormalBtnVisible(true, ClientConst.NORMAL_ATTACK_BTN_SHOW_MODE.HIDE)
		self.btnNormalUButton:TryChangePage("PetChar", 4)

		local objectReference = self.btnNormalUButton:GetComponent("ObjectReference")
		local btnNormalKeyBindingPro = objectReference:GetRefValue("btnNormalKeyBindingPro")

		btnNormalKeyBindingPro.actionPath = "Hud/QuitExploreState"

		function self.btnNormalUButton.luaClick()
			pg.game.social.interactGestureComponent:cancelCurInteraction()
		end

		result = true
	else
		self:_setNormalBtnVisible(false, ClientConst.NORMAL_ATTACK_BTN_SHOW_MODE.NORMAL)
	end

	return result
end

function ExploreBtnComponent:setExitExploreButton()
	self.btnNormalUButton:TryChangePage("PetChar", 0)
	self:_setNormalBtnVisible(true, ClientConst.NORMAL_ATTACK_BTN_SHOW_MODE.HIDE)

	local info = self.model:getExitExploreDelaySkillInfo()
	local objectReference = self.btnNormalUButton:GetComponent("ObjectReference")
	local txtName = objectReference:GetRefValue("txtNameUText")

	ClientTextUtils.setText(txtName, pg.getLocalizationText(info.name or ""))

	local icon = objectReference:GetRefValue("iconUImage")

	icon.forceSyncLoad = true
	icon.url = info.skillIcon or ""

	local btnNormalKeyBindingPro = objectReference:GetRefValue("btnNormalKeyBindingPro")

	btnNormalKeyBindingPro.actionPath = info.actionPath

	function self.btnNormalUButton.luaClick()
		pg.game.controller:realCancelExploreSwitch(nil, true)
	end
end

function ExploreBtnComponent:setGhostEyeExitButton()
	self.btnNormalUButton:TryChangePage("PetChar", 0)
	self:_setNormalBtnVisible(true, ClientConst.NORMAL_ATTACK_BTN_SHOW_MODE.HIDE)

	local info = self.model:getGhostEyeSwitchSkillInfo()
	local objectReference = self.btnNormalUButton:GetComponent("ObjectReference")
	local txtName = objectReference:GetRefValue("txtNameUText")

	ClientTextUtils.setText(txtName, pg.getLocalizationText(info.name or ""))

	local icon = objectReference:GetRefValue("iconUImage")

	icon.forceSyncLoad = true
	icon.url = info.skillIcon or ""

	local btnNormalKeyBindingPro = objectReference:GetRefValue("btnNormalKeyBindingPro")

	btnNormalKeyBindingPro.actionPath = info.actionPath

	function self.btnNormalUButton.luaClick()
		pg.game.controller:useSkill(info.abilityId, info.abilityType)
	end
end

function ExploreBtnComponent:setExplorePageNormalButton(info, clickCb)
	local visible = true

	if info.checkPetLinkModuleEnable then
		visible = pg.game:checkModuleEnable(ClientConst.ModuleKey.PetLink)
	end

	self.btnNormalUButton:TryChangePage("PetChar", 0)
	self:_setNormalBtnVisible(visible, visible and ClientConst.NORMAL_ATTACK_BTN_SHOW_MODE.HIDE or ClientConst.NORMAL_ATTACK_BTN_SHOW_MODE.NORMAL)

	local objectReference = self.btnNormalUButton:GetComponent("ObjectReference")
	local txtName = objectReference:GetRefValue("txtNameUText")

	ClientTextUtils.setText(txtName, pg.getLocalizationText(info.name or ""))

	local icon = objectReference:GetRefValue("iconUImage")

	icon.url = info.skillIcon or ""

	local btnNormalKeyBindingPro = objectReference:GetRefValue("btnNormalKeyBindingPro")
	local btnKeyHotKeyContent = objectReference:GetRefValue("keyHotKeyContent")

	btnNormalKeyBindingPro.actionPath = info.actionPath

	btnKeyHotKeyContent:SetHotKeyPaths(info.actionPath)

	self.btnNormalUButton.luaClick = clickCb
	self.curExploreNormalBtnInfo = info
end

function ExploreBtnComponent:refreshExplorePageNormalButtonVisible()
	if self.curExploreNormalBtnInfo and self.curExploreNormalBtnInfo.checkPetLinkModuleEnable then
		local visible = pg.game:checkModuleEnable(ClientConst.ModuleKey.PetLink)

		self:_setNormalBtnVisible(visible, visible and ClientConst.NORMAL_ATTACK_BTN_SHOW_MODE.HIDE or ClientConst.NORMAL_ATTACK_BTN_SHOW_MODE.NORMAL)
	end
end

function ExploreBtnComponent:_setExploreMode(inExplore)
	if self.isInExploreMode == inExplore then
		return
	end

	self.isInExploreMode = inExplore

	if self.ctrl and self.ctrl.onExploreModeChanged then
		self.ctrl:onExploreModeChanged(inExplore)
	end
end

function ExploreBtnComponent:_setNormalBtnVisible(visible, normalAtkBtnState)
	if self.normalBtnVisible ~= visible then
		self.normalBtnVisible = visible

		LuaUIUtils.setUIViewVisible(self.btnNormalUButton, visible)
	end

	if self.ctrl and self.ctrl.notifyNormalAtkBtnStateChanged then
		self.ctrl:notifyNormalAtkBtnStateChanged(normalAtkBtnState)
	end
end

function ExploreBtnComponent:refreshHudExplorePageState()
	if not self.btnNormalUButton then
		return
	end

	if not pg.me then
		return
	end

	self.checkExploreState = true

	if pg.me.isHudInSkillExState then
		self.checkExploreState = false

		self:_setNormalBtnVisible(false, ClientConst.NORMAL_ATTACK_BTN_SHOW_MODE.NORMAL)
		self:_setExploreMode(false)

		return
	end

	if pg.me:RIDING_ST() then
		self:_setNormalBtnVisible(false, ClientConst.NORMAL_ATTACK_BTN_SHOW_MODE.NORMAL)
		self:_setExploreMode(false)

		return
	end

	if pg.me:isEggStruggleButtonNeeded() then
		self:setExplorePageNormalButton(self.model:getEggStruggleInfo(), function()
			pg.me:onClickEggStruggleButton()
		end)
		self:_setExploreMode(true)

		return
	end

	if pg.me:CARRY_EGG_ST() then
		self:setExplorePageNormalButton(self.model:getExitCarryEggInfo(), function()
			if pg.me then
				pg.me:exitCarryEgg()
			end
		end)
		self:_setExploreMode(true)

		return
	end

	local exploreState = self:getCurExploreState()

	if self:innerRefreshExploreState(exploreState) then
		self:_setExploreMode(true)

		return
	end

	if pg.me:isControllingEgg() then
		if not pg.me:EGG_BE_CARRIED_ST() then
			self:setExplorePageNormalButton(self.model:getExitControlEggInfo(), function()
				if pg.global.ui.hudV2 and pg.global.ui.hudV2.MD and pg.global.ui.hudV2.MD.hpFuse then
					pg.global.ui.hudV2.MD.hpFuse:performSwitchPet()
				end
			end)
		end

		self:_setExploreMode(true)
	elseif pg.game.controller:isInControlEnt() then
		if pg.me:isInGhostEyeState() then
			self:setGhostEyeExitButton()
			self:_setExploreMode(true)
		elseif pg.me:isInScentTrackReadyState() then
			self:setExplorePageNormalButton(self.model:getGhostEyeSwitchSkillInfo(), function()
				pg.me:exitScentTracking()
			end)
			self:_setExploreMode(true)
		elseif pg.global.ui:runPlatformByMobile() and pg.pawn.eModel.CharacterControllerIsFloating then
			self:_setExploreMode(true)
		else
			self:_setExploreMode(false)
		end
	else
		self:_setExploreMode(false)
	end
end

function ExploreBtnComponent:refreshHudExploreStateIfChanged()
	local exploreState = self:getCurExploreState()

	if self.exploreState ~= exploreState then
		self.exploreState = exploreState

		self:refreshHudExplorePageState()
	end
end

function ExploreBtnComponent:onModuleEnableChanged(changeInfo)
	if changeInfo.moduleKey == ClientConst.ModuleKey.PetLink then
		self:refreshExplorePageNormalButtonVisible()
	end
end

function ExploreBtnComponent:onCharacterStateChanged()
	if self.checkExploreState then
		self:refreshHudExploreStateIfChanged()
	end
end

function ExploreBtnComponent:onControlExplorePet()
	if self.checkExploreState then
		self:refreshHudExploreStateIfChanged()
	end
end

function ExploreBtnComponent:onPetExploreStateChanged()
	self:refreshHudExplorePageState()
end

function ExploreBtnComponent:onPetGhostEyeStateChanged()
	self:refreshHudExplorePageState()
end

function ExploreBtnComponent:onDelayExitExploreStateChange()
	if self.checkExploreState then
		self:refreshHudExploreStateIfChanged()
	end
end

function ExploreBtnComponent:onSpaceFollowInfoChanged()
	self:refreshHudExploreStateIfChanged()
end

function ExploreBtnComponent:onInteractGestureStateChanged()
	self:refreshHudExploreStateIfChanged()
end

function ExploreBtnComponent:onPlayerStartCarryEnt()
	self:_setNormalBtnVisible(false, ClientConst.NORMAL_ATTACK_BTN_SHOW_MODE.HIDE)
end

function ExploreBtnComponent:onPlayerStopCarryEnt()
	self:refreshHudExplorePageState()
end

function ExploreBtnComponent:onDestroy()
	HudBaseComponent.onDestroy(self)

	self.curExploreNormalBtnInfo = nil
	self.btnNormalUButton = nil
end

function ExploreBtnComponent:playShowAnim()
	if self.uWidget then
		self.uWidget:InvokeCallback(CS.XGUI.EInvokeTime.Show)
	end
end

function ExploreBtnComponent:playHideAnim()
	if self.uWidget then
		self.uWidget:InvokeCallback(CS.XGUI.EInvokeTime.Hide)
	end
end

return ExploreBtnComponent
