-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HudV2\\BaseComponent\\FocusUIComponent.lua

local HudBaseComponent = require("Guis.Panels.HudV2.HudBaseComponent")
local Class = require("Core.Framework.Class")
local TimerManager = require("Core.Timer.TimerManager")
local AbilityConst = require("Common.Const.AbilityConst")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientSettingUtils = require("Utils.ClientSettingUtils")
local AbilitySettingGlobalConstData = require("Data.ability_setting_global_const_data")
local MessageName = require("Const.MessageName")
local SysConfigData = require("Data.sys_config_data")
local cameraSystem = pg.game.camera
local UIUtils = UIUtils
local Vector3 = Vector3
local Color = Color
local LOCK_STRONG_LOOP_ANIM = "VX_Pb_Focus_LockWeak_Loop"
local targetLineColorConfig = SysConfigData.FOCUS_TARGET_LINE_COLOR or {
	0.3,
	0.85,
	1,
	0.85
}
local FocusTargetLineParams = {
	lineColor = Color(targetLineColorConfig[1], targetLineColorConfig[2], targetLineColorConfig[3], targetLineColorConfig[4]),
	lineWidth = SysConfigData.FOCUS_TARGET_LINE_WIDTH or 0.08,
	arcHeight = SysConfigData.FOCUS_TARGET_LINE_ARC_HEIGHT or 1,
	alpha = SysConfigData.FOCUS_TARGET_LINE_ALPHA or 1,
	meYOffset = SysConfigData.FOCUS_TARGET_LINE_ME_OFFSET or 0.8,
	targetYOffset = SysConfigData.FOCUS_TARGET_LINE_TARGET_OFFSET or 0.2
}
local FocusUIComponent = Class.LightClass("FocusUIComponent", HudBaseComponent)

FocusUIComponent.messages = {
	[MessageName.LOCKED_TARGET_CHANGE] = {
		"onLockedTargetChange"
	},
	[MessageName.PLAYER_COMBAT_STATUS_UPDATE] = {
		"onPlayerCombatStatusUpdate"
	},
	[MessageName.COMBAT_PET_CHANGED] = {
		"onCombatPetChanged"
	},
	[MessageName.COMBAT_PET_TEMPLATE_CHANGE] = {
		"onCombatPetChanged"
	},
	[MessageName.CATCH_MODE_CHANGE_UI] = {
		"onCatchModeChange"
	}
}

function FocusUIComponent:findObjects()
	local objectReference = self.transform:GetComponent("ObjectReference")

	self.focusUComponent = objectReference:GetRefValue("focusUComponent")
	self.focusTransform = objectReference:GetRefValue("focusTransform")
	self.chainAttackBtn = objectReference:GetRefValue("chainAttackBtn")
	self.lockStrongAnim = objectReference:GetRefValue("lockStrongAnim")
	self.lockStrongUWidget = self.lockStrongAnim.transform:GetComponent("UWidget")
	self.lockStrongUProgress = objectReference:GetRefValue("lockStrongUProgress")
	self.lockAnim = objectReference:GetRefValue("imageLockAnim")
	self.lockWidget = self.lockAnim.transform:GetComponent("UWidget")
	self.lockStrongActive = nil
	self._parentVisible = true

	local resistHighTxt = objectReference:GetRefValue("resistHighTxt")
	local resistLowTxt = objectReference:GetRefValue("resistLowTxt")

	ClientTextUtils.setText(resistHighTxt, pg.getGameString("RESET_HIGH_TXT"))
	ClientTextUtils.setText(resistLowTxt, pg.getGameString("RESET_LOW_TXT"))

	self.focusPages = {}
end

function FocusUIComponent:initView()
	self:onLockedTargetChange()
	self:SetStrongActive(false)
end

function FocusUIComponent:SetStrongActive(active)
	if active and self._parentVisible == false then
		return
	end

	if self.lockStrongActive ~= active and self.lockStrongUWidget then
		self.lockStrongActive = active

		self.lockStrongUWidget:SetActiveFastest(active)

		if active then
			UIUtils.PlayAnimation(self.lockStrongAnim)
		end
	end
end

function FocusUIComponent:onLockedTargetChange()
	local player = pg.me

	self.lockedEntity = pg.getEntityByActorId(player.lockedActorId)

	if not self.lockedEntity then
		self:onLeaveLockMode()

		return
	end

	self.lockArrowState = Utils.getLockState(player)

	if self.lockArrowState ~= AbilityConst.LockState.None then
		self:onEnterLockMode(true)
	end
end

function FocusUIComponent:onEnterLockMode(isLockTargetChange)
	if self._parentVisible == false then
		return
	end

	self:SetStrongActive(self.lockArrowState == AbilityConst.LockState.Lock)

	self.isFarDistance = false

	self:focusChangePage("Distance", "near")
	self:focusChangePage("State", self.lockArrowState)
	self:focusChangePage("Resist", 1)

	if self.lockTimer ~= nil then
		cameraSystem:removeLateUpdateTimer(self.lockTimer)

		self.lockTimer = nil
	end

	self.lockTimer = cameraSystem:addLateUpdateTimer(function()
		self:startLockTick()
	end)

	self:refreshResistAttachedToPuppet(false, isLockTargetChange)
end

function FocusUIComponent:onLeaveLockMode()
	if self.lockTimer then
		cameraSystem:removeLateUpdateTimer(self.lockTimer)
	end

	self.lockTimer = nil

	self:stopFocusLinkLine()
	self:SetStrongActive(false)
	self:focusChangePage("State", AbilityConst.LockState.None)
	self:focusChangePage("Resist", 1)
end

function FocusUIComponent:getLockPosition()
	return self.lockedEntity:getLockPosition()
end

local _lockWorldPos = Vector3.zero

function FocusUIComponent:startLockTick()
	Vector3.enableCreateFromCache()

	local worldPos = self:getLockPosition()

	_lockWorldPos:Copy(worldPos)
	Vector3.disableCreateFromCache()
	UIUtils.SetFollowTransform(self.focusTransform, _lockWorldPos[1], _lockWorldPos[2], _lockWorldPos[3])

	if pg.game.camera:checkInViewportFull(_lockWorldPos) then
		if self.lockArrowState == AbilityConst.LockState.Lock and ClientSettingUtils.isFocusTargetLineOpenEnabled() then
			self:refreshFocusLinkLine(_lockWorldPos)
		else
			self:stopFocusLinkLine()
		end

		local distance = Vector3.SqrDistance(_lockWorldPos, pg.pawn:getPosition())

		if distance >= AbilitySettingGlobalConstData.forceLockDis^2 then
			if not self.isFarDistance then
				self.lockAnim:Play("VX_Hud_Focus_DistanceNearToFar")

				self.isFarDistance = true
			end

			self:focusChangePage("Distance", "far")
		else
			if self.isFarDistance then
				self.lockAnim:Play("VX_Hud_Focus_DistanceFarToNear")

				self.isFarDistance = false
			end

			self:focusChangePage("Distance", "near")
		end

		self:focusChangePage("State", self.lockArrowState)

		if self.lockArrowState == AbilityConst.LockState.Lock then
			if not self.lockStrongActive then
				self:SetStrongActive(true)
			elseif self.lockWidget.renderOpacity == 1 then
				local _, distanceState = self.focusUComponent:TryGetCurrentPage("Distance")

				UIUtils.PlayAnimation(self.lockStrongAnim, LOCK_STRONG_LOOP_ANIM, nil, distanceState == 0 and 1 or 0.7)
			end
		end
	else
		if self.lockArrowState == AbilityConst.LockState.Lock and ClientSettingUtils.isFocusTargetLineOpenEnabled() then
			self:refreshFocusLinkLine(_lockWorldPos)
		else
			self:stopFocusLinkLine()
		end

		self:SetStrongActive(false)
		self:focusChangePage("State", AbilityConst.LockState.None)
		self:focusChangePage("Distance", "near")
		self:focusChangePage("Resist", 1)
	end
end

function FocusUIComponent:focusChangePage(name, value)
	if self.focusPages[name] ~= value then
		self.focusPages[name] = value

		self.focusUComponent:TryChangePage(name, value)
	end
end

function FocusUIComponent:refreshResistAttachedToPuppet(isChangePet, isChangePuppet)
	local visible = LuaUIUtils.isResistInfoVisible()

	if not visible then
		self:focusChangePage("Resist", 1)

		return
	end

	local isLock = self.lockArrowState == AbilityConst.LockState.Lock
	local factor = self:getResistFactor()
	local lockEnt = pg.getEntityByActorId(pg.me.lockedActorId)
	local puppetBasePetPrototypeId = lockEnt and lockEnt.basePetPrototypeId
	local resistFactor = 1

	if factor == 1 then
		self:hideResist(false)

		self.puppetBasePetPrototypeId = puppetBasePetPrototypeId
		self.resistFactor = resistFactor

		return
	end

	resistFactor = factor > 1 and 2 or 0

	local isInCombat = pg.me:isInCombat()

	if not isInCombat then
		if isLock then
			self:showResist(factor, false)
		end
	elseif isChangePet then
		if resistFactor ~= self.resistFactor then
			self:showResist(factor, true)
		end
	elseif isChangePuppet then
		if puppetBasePetPrototypeId ~= self.puppetBasePetPrototypeId then
			self:showResist(factor, true)
		end
	else
		self:showResist(factor, true)
	end

	self.puppetBasePetPrototypeId = puppetBasePetPrototypeId
end

function FocusUIComponent:refreshResistOnCombatChanged(status)
	if status == Const.COMBAT_STATUS_IN_COMBAT then
		self:refreshResistAttachedToPuppet()
	end
end

function FocusUIComponent:showResist(factor, delayHide)
	if self._parentVisible == false then
		return
	end

	if self.resistTimer then
		TimerManager.removeTimer(self.resistTimer)

		self.resistTimer = nil
	end

	if factor > 1 then
		self:focusChangePage("Resist", 2)

		self.resistFactor = 2
	elseif factor < 1 then
		self:focusChangePage("Resist", 0)

		self.resistFactor = 0
	else
		self.resistFactor = 1

		self:hideResist()

		return
	end

	if delayHide then
		self.resistTimer = TimerManager.addTimer(2, function()
			self:hideResist(true)
		end)
	end
end

function FocusUIComponent:hideResist()
	if self.resistTimer then
		TimerManager.removeTimer(self.resistTimer)

		self.resistTimer = nil
	end

	self:focusChangePage("Resist", 1)
end

function FocusUIComponent:getResistFactor()
	local factor = 1
	local player = pg.me

	if not player then
		return factor
	end

	local petEnt = player:getCurPetEntity()

	if not petEnt then
		return factor
	end

	if not self.lockedEntity then
		return factor
	end

	local petData = petEnt:getConfigData()

	factor = Utils.getElementAgainstValue(petData.mainElementType, self.lockedEntity.elementTypes)

	return factor
end

function FocusUIComponent:onPlayerCombatStatusUpdate(status)
	self:refreshResistOnCombatChanged(status)
end

function FocusUIComponent:onCombatPetChanged()
	self:refreshResistAttachedToPuppet(true, false)
end

function FocusUIComponent:onCatchModeChange(enable)
	if enable then
		self:onLeaveLockMode()
	else
		self:onLockedTargetChange()
	end
end

function FocusUIComponent:onParentHide()
	self:_suspendLockUI()
end

function FocusUIComponent:onParentShow()
	self:_restoreLockUI()
end

function FocusUIComponent:onVisibleChange(visible)
	if visible then
		self:_restoreLockUI()
	else
		self:_suspendLockUI()
	end
end

function FocusUIComponent:_suspendLockUI()
	self._parentVisible = false

	if self.lockTimer then
		cameraSystem:removeLateUpdateTimer(self.lockTimer)

		self.lockTimer = nil
	end

	if self.resistTimer ~= nil then
		TimerManager.removeTimer(self.resistTimer)

		self.resistTimer = nil

		self:hideResist()
	end

	self:stopFocusLinkLine()
	self:SetStrongActive(false)
end

function FocusUIComponent:_restoreLockUI()
	self._parentVisible = true

	if not self.transform then
		return
	end

	self:onLockedTargetChange()
end

function FocusUIComponent:onDestroy()
	if self.lockTimer ~= nil then
		cameraSystem:removeLateUpdateTimer(self.lockTimer)

		self.lockTimer = nil
	end

	self:destroyFocusLinkLine()

	if self.resistTimer ~= nil then
		TimerManager.removeTimer(self.resistTimer)

		self.resistTimer = nil
	end

	HudBaseComponent.onDestroy(self)
end

function FocusUIComponent:ensureFocusLinkLine()
	if self.focusTargetLineController and NotNil(self.focusTargetLineController) then
		return self.focusTargetLineController
	end

	if self.focusLinkLineEffectId then
		return nil
	end

	local effectId = pg.game.effect:playRawEffectAt(0, "$Eff_Common_Target_LockOn.prefab", Vector3.zero, {
		forceLodLevel = 0,
		duration = -1,
		loadCallback = function(effectItem)
			if not effectItem or IsNil(effectItem.effectTrans) then
				return
			end

			local particleTransform = effectItem.effectTrans:Find("TargetLineParticle")
			local controller = particleTransform:GetComponent("TargetLineController")

			self.focusTargetLineController = controller
			self.focusLinkLineStarted = false

			controller:StopTargetLine()
		end
	})

	self.focusLinkLineEffectId = effectId

	return nil
end

function FocusUIComponent:stopFocusLinkLine()
	if self.focusTargetLineController and NotNil(self.focusTargetLineController) then
		self.focusTargetLineController:StopTargetLine()
	end

	self.focusLinkLineStarted = false
end

function FocusUIComponent:destroyFocusLinkLine()
	self:stopFocusLinkLine()

	self.focusTargetLineController = nil

	local effectId = self.focusLinkLineEffectId

	self.focusLinkLineEffectId = nil

	if effectId and effectId ~= 0 then
		pg.game.effect:stopEffect(0, effectId, true)
	end
end

function FocusUIComponent:refreshFocusLinkLine(targetPos)
	local startPos = pg.pawn:getLockPosition()
	local controller = self:ensureFocusLinkLine()

	if not controller then
		return
	end

	Vector3.enableCreateFromCache()

	local startPoint = Vector3.New(startPos[1] or 0, (startPos[2] or 0) + FocusTargetLineParams.meYOffset, startPos[3] or 0)
	local targetPoint = Vector3.New(targetPos[1] or 0, (targetPos[2] or 0) + FocusTargetLineParams.targetYOffset, targetPos[3] or 0)

	if self.focusLinkLineStarted then
		controller:UpdateTargetLinePositions(startPoint, targetPoint)
	else
		controller:PlayTargetLine(startPoint, targetPoint, FocusTargetLineParams.lineColor, FocusTargetLineParams.lineWidth, FocusTargetLineParams.arcHeight, FocusTargetLineParams.alpha)

		self.focusLinkLineStarted = true
	end

	Vector3.disableCreateFromCache()
end

return FocusUIComponent
