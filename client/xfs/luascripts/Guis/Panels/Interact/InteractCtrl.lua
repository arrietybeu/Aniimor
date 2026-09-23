-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Interact\\InteractCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local InteractUIComponent = require("Guis.Panels.Interact.Component.InteractUIComponent")
local InteractClassicUIComponent = require("Guis.Panels.Interact.Component.InteractClassicUIComponent")
local InteractHomeFacilityPetComponent = require("Guis.Panels.Interact.Component.InteractHomeFacilityPetComponent")
local InteractCtrl = Class.LightClass("InteractCtrl", UICtrl)
local Utils = require("Common.Utils.Utils")
local ClientConst = require("Const.ClientConst")
local UIConst = require("Const.UIConst")
local TimerManager = require("Core.Timer.TimerManager")
local LuaUIUtils = require("Utils.LuaUIUtils")
local InteractionConst = require("Common.Const.InteractionConst")
local AbilityConst = require("Common.Const.AbilityConst")
local Const = require("Common.Const.Const")
local ClientCaptureUtils = require("Utils.ClientCaptureUtils")
local SysConfigData = require("Data.sys_config_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PuppetData = require("Data.puppet_data")
local HotkeyConst = require("Const.HotkeyConst")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro

InteractCtrl.messages = {
	[MessageName.UPDATE_INTERACT_VIEW] = {
		"onInteractChange",
		true
	},
	[MessageName.UPDATE_QUICK_CAPTURE_STATE] = {
		"onQuickCaptureChange",
		false
	},
	[MessageName.CONTROLLER_SWITCH_UPDATE] = {
		"onControllerSwitchUpdate",
		true
	},
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChange",
		true
	},
	[MessageName.UPDATE_INTERACT_VISIBLE] = {
		"refreshUIVisible",
		true
	},
	[MessageName.SPECIAL_ABILITY_TRIGGERED] = {
		"doSpecialAbility",
		true
	},
	[MessageName.UPDATE_INTERACT_MODE] = {
		"onInteractModeChange",
		true
	},
	[MessageName.TIMESCALE_CHANGE] = {
		"onTimescaleChange",
		true
	},
	[MessageName.HOMELAND_FACILITY_ALLOCATE_CHANGED] = {
		"onFacilityAllocateChanged",
		true
	},
	[MessageName.SPACE_FOLLOW_UPDATE] = {
		"refreshSwitchCtrlBtnVisible",
		true
	}
}

function InteractCtrl:ctor()
	UICtrl.ctor(self)

	self.photoInteractingSandbox = {}
end

function InteractCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.interactNew = InteractUIComponent.new(self)
	self.interactClassic = InteractClassicUIComponent.new(self)
	self.interactHomeFacilityPet = InteractHomeFacilityPetComponent.new(self)

	self:refreshInteractMode()

	self.breakPuppetMap = {}
	self.curInteractInfo = {}
	self.curSwitchCtrlInfo = {}
	self.visibleInfo = {}
	self.quickCaptureTimer = nil
	self.extraControllerSwitchActive = true
	self.controllerSwitchActive = false

	self:onInteractChange()

	if self._pendingQuickCaptureInfo then
		self:onQuickCaptureChange(self._pendingQuickCaptureInfo)

		self._pendingQuickCaptureInfo = nil
	end
end

function InteractCtrl:refreshInteractMode()
	if pg.game.interaction.isClassic then
		self.interact = self.interactClassic
	else
		self.interact = self.interactNew
	end

	self.interact:initView()
	self.interactHomeFacilityPet:initView()
	self:refreshCameraZoomInput()
end

function InteractCtrl:onInteractModeChange()
	self:refreshInteractMode()
end

function InteractCtrl:onVisibleChange(visible)
	self:refreshCameraZoomInput()
end

function InteractCtrl:refreshCameraZoomInput()
	return
end

function InteractCtrl:onDestroy()
	UICtrl.onDestroy(self)

	self.interact = nil
	self.interactHomeFacilityPet = nil
end

function InteractCtrl:addListener()
	function self.view.petSwitchCtrlInteractBtn.luaPress()
		self:doSpecialAbility()
	end

	self.quickCaptureBtn = self.view.catchUButton

	function self.quickCaptureBtn.luaClick()
		local quickCaptureData = pg.game.interaction.quickCaptureUnit:getInteractBtnStyle()

		if quickCaptureData then
			pg.game.interaction.quickCaptureUnit:tryInteractive()
		end
	end

	local scrollBinding = KeyBindingPro.GetOrAddKeyBindingByName(self.view.gameObject, "interactScroll")

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

	local gamepadMoveUpBinding = KeyBindingPro.GetOrAddKeyBindingByName(self.view.gameObject, "padMoveUp")

	gamepadMoveUpBinding.isVirtual = true
	gamepadMoveUpBinding.actionPath = "Hud/DPadMoveUp"

	function gamepadMoveUpBinding.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" and self:triggerOnGamepadSwitchUp() then
			return false
		end

		return true
	end

	local gamepadMoveDownBinding = KeyBindingPro.GetOrAddKeyBindingByName(self.view.gameObject, "padMoveDown")

	gamepadMoveDownBinding.isVirtual = true
	gamepadMoveDownBinding.actionPath = "Hud/DPadMoveDown"

	function gamepadMoveDownBinding.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" and self:triggerOnGamepadSwitchDown() then
			return false
		end

		return true
	end

	self.quickCaptureBtn:SetActiveFastest(false)
end

function InteractCtrl:doSpecialAbility()
	if self.model.abilityIndex and self.model.switchGlobalId then
		pg.pawn.eModel:TryAutoSwitch(Const.COMPONENT_INDEX_CHARACETER_CONTROLLER, self.model.abilityIndex, self.model.switchGlobalId, true)
	else
		pg.game.controller:onHandleSpecialAbility(true)
	end
end

function InteractCtrl:onShow()
	return
end

function InteractCtrl:getWhiteList()
	local whiteList = {}

	whiteList[UIConst.UI_ID_VEHICLE_INTERATION_PANEL] = true

	return whiteList
end

function InteractCtrl:onCatchModeChange()
	if NotNil(self.quickCaptureBtn) then
		local hasQuickCaptureTarget = pg.game.interaction.quickCaptureEntId ~= nil
		local isInCatchMode = pg.me and pg.me:isInCatchMode()

		self.quickCaptureBtn:SetActiveFastest(hasQuickCaptureTarget and not isInCatchMode)
	end

	self:refreshUIVisible()
end

function InteractCtrl:setInteractVisible(key, visible)
	if not self.interact then
		return
	end

	if visible then
		self.visibleInfo[key] = nil
	else
		self.visibleInfo[key] = false
	end

	self:refreshUIVisible()
end

function InteractCtrl:getUIVisible()
	local visible = UICtrl.getUIVisible(self)

	if not visible then
		return false
	end

	for key, _ in pairs(self.visibleInfo) do
		if key == ClientConst.InteractVisibleKey.GamepadSkillModifier then
			if pg.game.input:isUsingGamepad() then
				return false
			end
		else
			return false
		end
	end

	local me = pg.me

	if me and me:INTERACT_ST() then
		return false
	end

	return true
end

function InteractCtrl:onInteractChange(info)
	self:refreshUIVisible()

	if self.interact then
		self.interact:onInteractChange(info)
		self:refreshCurInteractInfo()
	end

	local currentInteractList = pg.game.interaction.currentInteractList

	if #currentInteractList == 0 then
		pg.global.ui.interactSecond:close()
	end

	if self.interactHomeFacilityPet then
		self.interactHomeFacilityPet:refreshPetList()
	end
end

function InteractCtrl:triggerOnMouseScroll(delta)
	if self.interact and self.interact:onMouseScroll(delta) then
		return true
	end

	return false
end

function InteractCtrl:triggerOnGamepadSwitchUp()
	if self.interact and self.interact:onGamepadSwitch(-1) then
		return true
	end

	return false
end

function InteractCtrl:triggerOnGamepadSwitchDown()
	if self.interact and self.interact:onGamepadSwitch(1) then
		return true
	end

	return false
end

function InteractCtrl:setControllerSwitchActive(active)
	self.controllerSwitchActive = active

	if self.view and self.view.petSwitchCtrlInteractBtn then
		self.view.petSwitchCtrlInteractBtn:SetActiveFastest(active and self.extraControllerSwitchActive, true)
	end
end

function InteractCtrl:onControllerSwitchUpdate(info)
	local show = info.show

	pg.game.interaction:setCanClimbHereState(show and info.abilityIndex == AbilityConst.SPECIFIC_ABILITY_INDEX_CLIMB)

	show = (not pg.global.ui.uiMgr:CheckIsMobileInteract() or info.abilityIndex ~= AbilityConst.SPECIFIC_ABILITY_INDEX_GLIDE or false) and show

	if show then
		self.model:setSwitchCtrlInfo(info)

		self.switchData = self.model:getSwitchCtrlBtnStyle()

		if self.view then
			self.view:showSwitchCtrl(self.switchData)
		end

		self:setControllerSwitchActive(true)
	else
		self.model:setSwitchCtrlInfo({})
		self:setControllerSwitchActive(false)
	end

	self:refreshCurSwitchInfo()
end

function InteractCtrl:refreshSwitchCtrlBtnVisible()
	self.extraControllerSwitchActive = true

	if pg.me and pg.me.followState == Const.SpaceFollowMemberState.Attach then
		self.extraControllerSwitchActive = false
	end

	if self.view and self.view.petSwitchCtrlInteractBtn then
		self.view.petSwitchCtrlInteractBtn:SetActiveFastest(self.controllerSwitchActive and self.extraControllerSwitchActive, true)
	end
end

function InteractCtrl:onSelectItemChange()
	self:refreshCurInteractInfo()
end

function InteractCtrl:refreshCurInteractInfo()
	self.curInteractInfo = self:innerGetCurInteractInfo()

	facade:SendMessageCommand(MessageName.INTERACT_ITEM_CHANGE, {})
end

function InteractCtrl:getCurInteractInfo()
	return self.curInteractInfo
end

function InteractCtrl:checkHasMultiInteract()
	return self.interact.interactList.itemCount > 1
end

function InteractCtrl:innerGetCurInteractInfo()
	local interactItem = self.interact:getCurInteractItem()

	if not Utils.tableIsEmptyOrNil(interactItem) then
		return interactItem
	end

	return nil
end

function InteractCtrl:getSelectItem()
	return self.interact:getCurInteractItem()
end

function InteractCtrl:refreshCurSwitchInfo()
	self.curSwitchCtrlInfo = self:innerGetCurSwitchInfo()

	facade:SendMessageCommand(MessageName.SWITCH_ITEM_CHANGE, {})
end

function InteractCtrl:innerGetCurSwitchInfo()
	if self.controllerSwitchActive then
		return self.switchData
	end

	return nil
end

function InteractCtrl:getCurSwitchInfo()
	return self.curSwitchCtrlInfo
end

function InteractCtrl:onInputDeviceChange()
	self:refreshUIVisible()
	self.interact:onInputDeviceChange()
end

function InteractCtrl:refreshInteractionData()
	return
end

function InteractCtrl:enterTriggerPhotoIdentifyInteract(sandboxId)
	if self.photoInteractingSandbox[sandboxId] then
		return
	end

	self.photoInteractingSandbox[sandboxId] = true

	facade:SendMessageCommand(MessageName.ENTER_TRIGGER, {
		dist = 0,
		interactionType = InteractionConst.INTERACTION_TYPE_QUICK_PHOTO,
		actionPrototypeId = InteractionConst.STYLE_CONST.PHOTO_IDENTIFY,
		interactFunc = function()
			local photo = pg.global.ui.photo

			photo:open({
				photoMode = photo.ModeType.PHOTO_IDENTIFY
			})
		end
	})
end

function InteractCtrl:onQuickCaptureChange(info)
	if not self.view then
		self._pendingQuickCaptureInfo = info

		return
	end

	if info.visible then
		self.view.widget:TryChangePage("InteractionMode", "QuickCatch")

		local quickCaptureData = pg.game.interaction.quickCaptureUnit:getInteractBtnStyle()

		self:setupQuickCatchBtn(self.quickCaptureBtn, quickCaptureData[1])

		local isInCatchMode = pg.me and pg.me:isInCatchMode()

		self.quickCaptureBtn:SetActiveFastest(not isInCatchMode)

		if self.quickCaptureTimer then
			self:killTimer(self.quickCaptureTimer)

			self.quickCaptureTimer = nil
		end

		self.quickCaptureTimer = self:startTimer(function()
			local btnStyle = pg.game.interaction.quickCaptureUnit:getInteractBtnStyle()

			if btnStyle and btnStyle[1] then
				local data = btnStyle[1]
				local colorState = ClientCaptureUtils.getColorPageByRate(data.rate or 0)

				colorState = colorState == 5 and 1 or colorState

				self.quickCaptureBtn:TryChangePage("SuccessRate", colorState)
				ClientTextUtils.setText(self.view.quickTxtName, pg.getLocalizationText(data.actionName))
				ClientTextUtils.setText(self.view.quickEmptyTxtName, pg.getLocalizationText(data.actionName))

				self.view.quickItemIcon.url = pg.game.interaction.quickCaptureUnit:getIcon()

				self.quickCaptureBtn:TryChangePage("BallState", data.ballState or 0)

				local rate = data.rate or 0

				ClientTextUtils.setText(self.view.quickTxtRate, LuaUIUtils.formatCatchRate(rate) .. "%")
			end
		end, 0.2, true)
	else
		self.quickCaptureBtn:SetActiveFastest(false)
		self.view.widget:TryChangePage("InteractionMode", "Normal")

		if self.quickCaptureTimer then
			self:killTimer(self.quickCaptureTimer)

			self.quickCaptureTimer = nil
		end
	end
end

function InteractCtrl:leaveTriggerPhotoIdentifyInteract(sandboxId)
	if not self.photoInteractingSandbox[sandboxId] then
		return
	end

	self.photoInteractingSandbox[sandboxId] = nil

	for k, v in pairs(self.photoInteractingSandbox) do
		return
	end

	facade:SendMessageCommand(MessageName.LEAVE_TRIGGER, {
		interactionType = InteractionConst.INTERACTION_TYPE_QUICK_PHOTO
	})
end

function InteractCtrl:setupQuickCatchBtn(button, data)
	button.enableInputActon = true

	local colorState = ClientCaptureUtils.getColorPageByRate(data.rate or 0)

	colorState = colorState == 5 and 1 or colorState

	button:TryChangePage("SuccessRate", colorState)
	ClientTextUtils.setText(self.view.quickTxtName, pg.getLocalizationText(data.actionName))
	ClientTextUtils.setText(self.view.quickEmptyTxtName, pg.getLocalizationText(data.actionName))

	self.view.quickItemIcon.url = pg.game.interaction.quickCaptureUnit:getIcon()

	button:TryChangePage("BallState", data.ballState or 0)

	local rate = data.rate or 0

	ClientTextUtils.setText(self.view.quickTxtRate, LuaUIUtils.formatCatchRate(rate) .. "%")

	local duration
	local ent = data.entity
	local totalTime

	if not ent then
		duration = 0
	elseif ent:isDead() then
		duration = SysConfigData.deadCatchTimeTolerance or 1
	else
		local bpInfo = Utils.getEntityBreakInfo(data.entity)
		local puppetData = PuppetData[ent.templateId]

		totalTime = puppetData and puppetData.battleBreakTime or nil
		duration = bpInfo.breakEndTime - pg.me:getGameTime()
	end

	self.view.quickProgress.maxValue = 100

	local curValue

	if totalTime and duration <= totalTime then
		curValue = duration / totalTime * 100
	else
		curValue = 100
	end

	self.view.quickProgress.value = curValue

	self.view.quickProgress:ProgressToValue(0, nil, duration, 0, CS.DG.Tweening.Ease.__CastFrom(1))

	data.selected = true

	if data.selected then
		button.enableInputActon = true
		button.interactable = true
		button.visualInteractable = true
	else
		button.enableInputActon = false
	end

	local bind = button.transform:GetComponent("KeyBindingPro")

	bind.isVirtual = true

	function bind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			button:OnClickSimulate()
		end
	end
end

function InteractCtrl:checkUIShowVirtualMouseCursor()
	return false
end

function InteractCtrl:onTimescaleChange(timeScale)
	local _, curPage = self.view.widget:TryGetCurrentPage("InteractionMode")

	if curPage == 1 then
		if timeScale < 1 then
			local target = self.view.quickProgress.value

			self.view.quickProgress:ProgressToValue(target, nil, 0.1, 0, CS.DG.Tweening.Ease.__CastFrom(1))
		else
			local quickCaptureData = pg.game.interaction.quickCaptureUnit:getInteractBtnStyle()
			local data = quickCaptureData[1]
			local duration
			local ent = data.entity
			local totalTime

			if not ent then
				duration = 0
			elseif ent:isDead() then
				duration = SysConfigData.deadCatchTimeTolerance or 1
			else
				local bpInfo = Utils.getEntityBreakInfo(data.entity)
				local puppetData = PuppetData[ent.templateId]

				totalTime = puppetData and puppetData.battleBreakTime or nil
				duration = bpInfo.breakEndTime - pg.me:getGameTime()
			end

			self.view.quickProgress:ProgressToValue(0, nil, duration, 0, CS.DG.Tweening.Ease.__CastFrom(1))
		end
	end
end

function InteractCtrl:onFacilityAllocateChanged()
	self.interactHomeFacilityPet:onFacilityAllocateChanged()
end

return InteractCtrl
