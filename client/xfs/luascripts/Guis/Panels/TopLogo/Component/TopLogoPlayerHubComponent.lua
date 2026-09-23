-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Component\\TopLogoPlayerHubComponent.lua

local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local TopLogoConst = require("Const.TopLogoConst")
local EventConst = require("Const.EventConst")
local Utils = require("Common.Utils.Utils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TopLogoItemComponent = require("Guis.Panels.TopLogo.Component.TopLogoItemComponent")
local TopLogoPvp2Helper = require("Guis.Panels.TopLogo.TopLogoPvp2Helper")
local AbilitySettingGlobalConstData = require("Data.ability_setting_global_const_data")
local TopLogoPlayerHubComponent = Class.LightClass("TopLogoPlayerHubComponent", TopLogoItemComponent)
local DIRTY = {
	MAX_END = "maxEndurance",
	STAMINA_ROOT_VISIBLE = "staminaRootVisible",
	STAMINA = "stamina",
	HP = "hp",
	SHIELD_ROOT_VISIBLE = "shieldRootVisible"
}
local SHIELD_RED_FRAME_NAME = "RedFrame"

function TopLogoPlayerHubComponent:ctor(refUContainer, topLogoItem)
	TopLogoPlayerHubComponent.super.ctor(self, refUContainer, topLogoItem)
	self:m_initHpState()
	self:m_initStaminaState()
end

function TopLogoPlayerHubComponent:onCtor()
	self.m_pendingRefresh = false

	function self.m_onStaminaTick()
		self:m_doStaminaTick()
	end

	function self.m_onStaminaFlightStateTick()
		self:m_doStaminaFlightStateTick()
	end

	function self.m_onDelayHidden()
		self:m_doDelayHiddenFire()
	end

	function self.m_onHiddenHpFire()
		self:m_doHiddenHpFire()
	end

	function self.m_onShieldUnload()
		self:onShieldUnloadTimer()
	end

	function self.m_onWarningHide()
		self:m_doWarningHide()
	end

	function self.m_onRefreshDashCost()
		self:m_doRefreshDashCost()
	end

	self:refreshVisible()

	if self:shouldBeActive() then
		self.m_pendingRefresh = true

		self:notifyActiveStateChanged(true)
	end
end

function TopLogoPlayerHubComponent:m_isCurrentPawn()
	if self.entity == nil then
		return false
	end

	local pawn
	local ctrl = pg.global.ui and pg.global.ui.topLogo

	if ctrl and ctrl.getVisualPawn then
		pawn = ctrl:getVisualPawn()
	else
		pawn = pg.pawn or pg.me
	end

	return pawn ~= nil and pawn == self.entity
end

function TopLogoPlayerHubComponent:m_shouldKeepStaminaVisible()
	return self:m_isCurrentPawn() and self.entity and self.entity.FLY_ST and self.entity:FLY_ST()
end

function TopLogoPlayerHubComponent:m_isTeamMate()
	if self.entity == nil then
		return false
	end

	if not pg.me then
		return false
	end

	if self:m_isCurrentPawn() then
		return false
	end

	if pg.me == self.entity then
		return false
	end

	if pg.me.isInTeam and pg.me:isInTeam() then
		local teamInfo = pg.me:getCurTeamInfo()

		if teamInfo and teamInfo.membersInfo then
			for _, memberInfo in pairs(teamInfo.membersInfo) do
				if memberInfo.uid == self.entity.uid then
					return true
				end
			end
		end
	end

	return false
end

function TopLogoPlayerHubComponent:m_getHpTargetEntity()
	if self:m_isCurrentPawn() then
		return pg.me
	end

	if self:m_isTeamMate() or TopLogoPvp2Helper.canShowPvp2EnemyPlayer(self.entity) then
		return self.entity
	end

	return nil
end

function TopLogoPlayerHubComponent:shouldBeActive()
	return self:m_isCurrentPawn() or self:m_isTeamMate() or TopLogoPvp2Helper.canShowPvp2EnemyPlayer(self.entity)
end

function TopLogoPlayerHubComponent:innerGetVisible()
	if not TopLogoPlayerHubComponent.super.innerGetVisible(self) then
		return false
	end

	return self:m_isCurrentPawn() or self:m_isTeamMate() or TopLogoPvp2Helper.canShowPvp2EnemyPlayer(self.entity)
end

function TopLogoPlayerHubComponent:syncPawnActiveState(refreshVisible)
	if self.entity and self.entity.refreshTopLogoVisibleGate then
		self.entity:refreshTopLogoVisibleGate()
	end

	local active = self:shouldBeActive()

	self:notifyActiveStateChanged(active)

	if refreshVisible ~= false then
		self:refreshVisible()
	end

	return active
end

function TopLogoPlayerHubComponent:notifyPawnChanged()
	local shouldBeActive = self:shouldBeActive()
	local isCurrentPawn = self:m_isCurrentPawn()

	self.m_staminaShowStatic = shouldBeActive or nil

	local curStamina

	if isCurrentPawn and pg.me then
		curStamina = pg.me:getStamina()
		self.curEnduranceValue = curStamina
		self.curEnduranceValueReduce = curStamina
		self.targetValue = curStamina

		if self:checkContainerLoaded() then
			self:m_syncStaminaVisualImmediately(curStamina)
		end
	end

	local active = self:syncPawnActiveState()

	if active then
		local shouldShowStamina = pg.me and (pg.me:getStamina() < pg.me.maxStamina or self:m_shouldKeepStaminaVisible())

		self.m_pendingRefresh = true

		if self:checkContainerLoaded() then
			self:refreshPlayerHp(nil, true)

			if isCurrentPawn then
				self:refreshMaxEnduranceValue()
				self:m_syncStaminaVisualImmediately(curStamina)
			end

			if shouldShowStamina then
				self:onEnduranceChange(true)
			end
		else
			self:markDirty(DIRTY.MAX_END)
			self:markDirty(DIRTY.HP)

			if shouldShowStamina then
				self:markDirty(DIRTY.STAMINA)
			end

			self:prewarmContainers()
		end
	end
end

function TopLogoPlayerHubComponent:prewarmContainers()
	if self.refContainersLoaded then
		return
	end

	if not self.m_prewarmCallback then
		function self.m_prewarmCallback(loadState)
			if not loadState then
				return
			end

			self:refreshTopLogoInfo()
		end
	end

	self:checkAndLoadUContainerUrlSupportAsync(self.m_prewarmCallback, TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC2)
end

function TopLogoPlayerHubComponent:notifyTeamChanged()
	local active = self:shouldBeActive()

	self:notifyActiveStateChanged(active)
	self:refreshVisible()

	if self:m_isTeamMate() then
		self:addEntityListener()
	elseif not TopLogoPvp2Helper.canShowPvp2EnemyPlayer(self.entity) then
		self:removeEntityListener()
	end

	if active then
		self.m_pendingRefresh = true

		if self.refContainersLoaded then
			self:refreshPlayerHp(nil, true)
		end
	end
end

function TopLogoPlayerHubComponent:notifyPvp2RevealChanged()
	if not TopLogoPvp2Helper.isPvp2EnemyPlayer(self.entity) then
		return
	end

	local revealActive = TopLogoPvp2Helper.canShowPvp2EnemyPlayer(self.entity)

	if revealActive then
		self:addEntityListener()

		self.m_pendingRefresh = true

		local targetEntity = self.entity

		if not targetEntity or targetEntity.curHp == nil then
			return
		end

		self.lastHp = targetEntity.curHp

		local shouldShowShield = targetEntity and targetEntity.curHp < targetEntity.maxHp and self._shieldRootVisibleReq ~= false

		if shouldShowShield then
			self:cancelShieldUnload()

			if self.shieldRootUWidget and not IsNil(self.shieldRootUWidget) then
				self.shieldRootUWidget.renderOpacity = 1
			else
				self._shieldShowOnLoad = true
			end
		end
	end

	self:notifyActiveStateChanged(revealActive)
	self:refreshVisible()

	if revealActive then
		self:refreshPlayerHp(nil, true)
	else
		self._shieldShowOnLoad = nil

		self:removeEntityListener()
	end
end

function TopLogoPlayerHubComponent:getInitMaxDistance()
	return nil
end

function TopLogoPlayerHubComponent:m_initHpState()
	self.alwaysShowLimit = AbilitySettingGlobalConstData.playerDisplyHpRange[1]
	self.warningShowLimit = AbilitySettingGlobalConstData.playerDisplyHpRange[2]
	self.hpShowTime = 5
	self.shieldUnloadDelay = 5
	self.lastHp = self.entity and self.entity.curHp or nil
	self.isWarning = false
	self.hiddenHpTimer = nil
	self.shieldUnloadTimer = nil
	self._shieldShowOnLoad = nil
	self._shieldRootVisibleReq = true
	self.m_isRespawnRecovery = false
end

function TopLogoPlayerHubComponent:m_initStaminaState()
	self.fullAni = "VX_Node_Hud_PlayerHub_Stamina_StaFull"
	self.addAni = "VX_Node_Hud_PlayerHub_Stamina_SliderUp"
	self.staminaAngleRate = 2.2222222222222223
	self.staminaOneSegment = 100

	if pg.me then
		self.dashCost = pg.me:getOneDashCost() or 0
		self.curEnduranceValue = pg.me:getStamina() or 0
	else
		self.dashCost = 0
		self.curEnduranceValue = 0
	end

	self.deltaTime = 0.03
	self.smoothRate = 1
	self.smoothRateReduce = 16
	self.delayHiddenTime = 1.83
	self.warnDelayTime = 0.1
	self.warningDuration = 0.6
	self.showRedLimit = self.dashCost
	self.curEnduranceValueReduce = self.curEnduranceValue
	self.targetValue = self.curEnduranceValue
	self.isShow = false
	self.barState = 0
	self.reduceTimers = {}
	self.staminaFlightStateTimer = nil
	self._staminaRootVisibleReq = true
end

function TopLogoPlayerHubComponent:addEntityListener()
	if (self:m_isTeamMate() or TopLogoPvp2Helper.canShowPvp2EnemyPlayer(self.entity)) and self.entity and self.entity.eventEmitter and not self.m_hpListenerRegistered then
		if not self.m_onTeamMateHealthChange then
			function self.m_onTeamMateHealthChange(ov, nv)
				local active = self:shouldBeActive()

				self:notifyActiveStateChanged(active)
				self:refreshVisible()
				self:refreshPlayerHp(nil, false)
			end
		end

		self.entity.eventEmitter:addEventListener(EventConst.TOPLOGO_HEALTH_POINT, self.m_onTeamMateHealthChange)

		self.m_hpListenerRegistered = true
	end
end

function TopLogoPlayerHubComponent:removeEntityListener()
	if self.entity and self.entity.eventEmitter and self.m_onTeamMateHealthChange and self.m_hpListenerRegistered then
		self.entity.eventEmitter:removeEventListener(EventConst.TOPLOGO_HEALTH_POINT, self.m_onTeamMateHealthChange)

		self.m_hpListenerRegistered = nil
	end
end

function TopLogoPlayerHubComponent:findObjects()
	local content = self.refUContainer and self.refUContainer.content

	if not content then
		return
	end

	local objRef = content:GetComponent("ObjectReference")

	self.playerHubUComponent = content
	self.shieldUContainer = objRef:GetRefValue("shieldUContainer")
	self.staminaRootUWidget = objRef:GetRefValue("staminaRootUWidget")
	self.staminaObjRef = self.staminaRootUWidget:GetComponent("ObjectReference")
	self.sike2Transform = self.staminaObjRef:GetRefValue("sike2Transform")
	self.bgFillUImage = self.staminaObjRef:GetRefValue("bgFillUImage")
	self.reduceFillUImage = self.staminaObjRef:GetRefValue("reduceFillUImage")
	self.normalFillUImage = self.staminaObjRef:GetRefValue("normalFillUImage")
	self.fxFillUImage = self.staminaObjRef:GetRefValue("fxFillUImage")
	self.warningUImage = self.staminaObjRef:GetRefValue("warningUImage")
	self.staminaRootAni = self.staminaRootUWidget and self.staminaRootUWidget:GetComponent("Animation")
	self.enduranceGlowTransform = objRef:GetRefValue("enduranceGlowTransform")
end

function TopLogoPlayerHubComponent:bindShieldObjects(content)
	if content == nil or IsNil(content) then
		return false
	end

	local shieldObjRef = content:GetComponent("ObjectReference")

	if shieldObjRef == nil or IsNil(shieldObjRef) then
		return false
	end

	self.shieldObjRef = shieldObjRef
	self.numUText = shieldObjRef:GetRefValue("numUText")
	self.point1UComponent = shieldObjRef:GetRefValue("point1UComponent")
	self.point2UComponent = shieldObjRef:GetRefValue("point2UComponent")
	self.point3UComponent = shieldObjRef:GetRefValue("point3UComponent")
	self.point4UComponent = shieldObjRef:GetRefValue("point4UComponent")
	self.point5UComponent = shieldObjRef:GetRefValue("point5UComponent")
	self.shieldRootUWidget = shieldObjRef:GetRefValue("rootUWidget")

	if self.shieldRootUWidget == nil or IsNil(self.shieldRootUWidget) then
		return false
	end

	self.shieldRootUWidget.renderOpacity = self._shieldShowOnLoad and 1 or 0

	self.shieldRootUWidget.gameObject:SetActiveEx(self._shieldRootVisibleReq ~= false)

	self._shieldShowOnLoad = nil

	self:checkAndResetDirty(DIRTY.SHIELD_ROOT_VISIBLE)
	self:checkAndResetDirty(DIRTY.HP)
	self:refreshPlayerHp(nil, true)

	return true
end

function TopLogoPlayerHubComponent:clearShieldObjects()
	self.shieldRootUWidget = nil
	self.shieldObjRef = nil
	self.numUText = nil
	self.point1UComponent = nil
	self.point2UComponent = nil
	self.point3UComponent = nil
	self.point4UComponent = nil
	self.point5UComponent = nil
	self.isWarning = false
end

function TopLogoPlayerHubComponent:cancelShieldUnload()
	if self.shieldUnloadTimer then
		self:killTimer(self.shieldUnloadTimer)

		self.shieldUnloadTimer = nil
	end
end

function TopLogoPlayerHubComponent:unloadShieldContainer()
	if self.hiddenHpTimer then
		self:killTimer(self.hiddenHpTimer)

		self.hiddenHpTimer = nil
	end

	self:cancelShieldUnload()

	self.m_shieldContainerLoadReqId = (self.m_shieldContainerLoadReqId or 0) + 1
	self.m_shieldContainerLoading = nil
	self._shieldShowOnLoad = nil

	self:clearShieldObjects()

	if self.shieldUContainer and not IsNil(self.shieldUContainer) then
		self.shieldUContainer:DestroyContent()
	end
end

function TopLogoPlayerHubComponent:loadShieldContainerAsync()
	if self.m_shieldContainerLoading then
		return
	end

	if self.shieldRootUWidget and not IsNil(self.shieldRootUWidget) then
		return
	end

	self:cancelShieldUnload()
	self:clearShieldObjects()

	local container = self.shieldUContainer

	if container == nil or IsNil(container) then
		return
	end

	self.m_shieldContainerLoading = true
	self.m_shieldContainerLoadReqId = (self.m_shieldContainerLoadReqId or 0) + 1

	local reqId = self.m_shieldContainerLoadReqId

	container:LoadDefaultUrlManually(function(content)
		if self.m_shieldContainerLoadReqId ~= reqId then
			return
		end

		self.m_shieldContainerLoading = false

		if self.refContainersLoaded ~= true or self.shieldUContainer ~= container or IsNil(container) then
			return
		end

		self:bindShieldObjects(content)
	end)
end

function TopLogoPlayerHubComponent:initUI()
	TopLogoPlayerHubComponent.super.initUI(self)

	if self.staminaRootUWidget then
		self.staminaRootUWidget.renderOpacity = 0
	end

	self:refreshMaxEnduranceValue()

	if self._shieldShowOnLoad then
		self:loadShieldContainerAsync()
	end

	self:addEntityListener()
end

function TopLogoPlayerHubComponent:onTopLogoCompVisibleChanged(visible, skipRefresh)
	if not visible then
		local shouldRestore = self._shieldShowOnLoad == true

		if not shouldRestore and not self.hiddenHpTimer and self.shieldRootUWidget and not IsNil(self.shieldRootUWidget) then
			shouldRestore = self.shieldRootUWidget.renderOpacity > 0.0001
		end

		self:unloadShieldContainer()

		self._shieldShowOnLoad = shouldRestore and true or nil
	end

	TopLogoPlayerHubComponent.super.onTopLogoCompVisibleChanged(self, visible, skipRefresh)

	if visible and self._shieldShowOnLoad then
		self:loadShieldContainerAsync()
	end
end

function TopLogoPlayerHubComponent:refreshTopLogoInfo(callFromUpdate)
	if self.m_pendingRefresh then
		self.m_pendingRefresh = false
	end

	if not self:checkFinalVisible() then
		return
	end

	if not self.m_loadedPlayerHubCallback then
		function self.m_loadedPlayerHubCallback(loadState)
			if not loadState then
				return
			end

			if self:checkAndResetDirty(DIRTY.MAX_END) then
				self:refreshMaxEnduranceValue()
			end

			if self:checkAndResetDirty(DIRTY.HP) then
				self:refreshPlayerHp(nil, true)
			end

			if self:checkAndResetDirty(DIRTY.STAMINA) then
				if self.m_staminaShowStatic then
					self:m_syncStaminaVisualImmediately()
				end

				self:onEnduranceChange()
			end

			if self:checkAndResetDirty(DIRTY.SHIELD_ROOT_VISIBLE) then
				self:setShieldRootVisible(self._shieldRootVisibleReq)
			end

			if self:checkAndResetDirty(DIRTY.STAMINA_ROOT_VISIBLE) then
				self:setStaminaRootVisible(self._staminaRootVisibleReq)
			end
		end
	end

	self:checkAndLoadUContainerUrlSupportAsync(self.m_loadedPlayerHubCallback, TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC1)
end

function TopLogoPlayerHubComponent:resetRender()
	self:m_stopStaminaTick()
	self:m_stopStaminaFlightStateTick()

	if self.warningTimer then
		self:killTimer(self.warningTimer)

		self.warningTimer = nil
	end

	if self.delayHiddenTimer then
		self:killTimer(self.delayHiddenTimer)

		self.delayHiddenTimer = nil
	end

	self:killReduceTimer()

	self.isShow = false

	self:removeEntityListener()

	self.playerHubUComponent = nil

	self:unloadShieldContainer()

	self.shieldUContainer = nil
	self.staminaRootUWidget = nil
	self.sike2Transform = nil
	self.bgFillUImage = nil
	self.reduceFillUImage = nil
	self.normalFillUImage = nil
	self.fxFillUImage = nil
	self.warningUImage = nil
	self.enduranceGlowTransform = nil
	self.staminaRootAni = nil
	self.staminaObjRef = nil
	self.m_loadedPlayerHubCallback = nil
	self.m_prewarmCallback = nil
	self.m_staminaShowStatic = nil

	TopLogoPlayerHubComponent.super.resetRender(self)
end

function TopLogoPlayerHubComponent:onDestroy()
	self:m_stopStaminaTick()
	self:m_stopStaminaFlightStateTick()

	if self.warningTimer then
		self:killTimer(self.warningTimer)

		self.warningTimer = nil
	end

	if self.delayHiddenTimer then
		self:killTimer(self.delayHiddenTimer)

		self.delayHiddenTimer = nil
	end

	self:killReduceTimer()
	self:removeEntityListener()
	self:unloadShieldContainer()

	self.m_loadedPlayerHubCallback = nil
	self.m_prewarmCallback = nil
	self.m_staminaShowStatic = nil
	self.m_onShieldUnload = nil
	self.m_onTeamMateHealthChange = nil

	TopLogoPlayerHubComponent.super.onDestroy(self)
end

function TopLogoPlayerHubComponent:refreshPlayerHp(changeData, force)
	if changeData and changeData.newv ~= nil and changeData.oldv ~= nil and changeData.newv < changeData.oldv then
		self.m_isRespawnRecovery = false
	end

	if not self:shouldBeActive() then
		return
	end

	local targetEntity = self:m_getHpTargetEntity()

	if not targetEntity then
		return
	end

	if targetEntity.curHp >= targetEntity.maxHp then
		self.m_isRespawnRecovery = false
	end

	if not self:checkVisibleAndMarkDirty(DIRTY.HP) then
		if TopLogoPvp2Helper.canShowPvp2EnemyPlayer(self.entity) and targetEntity.curHp < targetEntity.maxHp and self._shieldRootVisibleReq ~= false then
			self._shieldShowOnLoad = true
		elseif self._finalVisible and not force and self.lastHp ~= targetEntity.curHp and self._shieldRootVisibleReq ~= false then
			self._shieldShowOnLoad = true
		end

		return
	end

	if not self.shieldRootUWidget or IsNil(self.shieldRootUWidget) then
		local shouldShow = self._shieldShowOnLoad == true

		shouldShow = shouldShow or not force and self.lastHp ~= targetEntity.curHp and self._shieldRootVisibleReq ~= false

		if shouldShow then
			self._shieldShowOnLoad = true

			self:loadShieldContainerAsync()
		end

		return
	end

	local hpChanged = self.lastHp ~= targetEntity.curHp

	self.lastHp = targetEntity.curHp

	local ratio = targetEntity.curHp / targetEntity.maxHp

	if self.shieldRootUWidget and not force and hpChanged then
		self:cancelShieldUnload()

		self.shieldRootUWidget.renderOpacity = 1
	end

	if self.point1UComponent and self.point1UComponent.TryChangePage then
		self.point1UComponent:TryChangePage("ShieldState", targetEntity.curHp >= 6 and 0 or 1)
	end

	if self.point2UComponent and self.point2UComponent.TryChangePage then
		self.point2UComponent:TryChangePage("ShieldState", targetEntity.curHp >= 5 and 0 or 1)
	end

	if self.point3UComponent and self.point3UComponent.TryChangePage then
		self.point3UComponent:TryChangePage("ShieldState", targetEntity.curHp >= 4 and 0 or 1)
	end

	if self.point4UComponent and self.point4UComponent.TryChangePage then
		self.point4UComponent:TryChangePage("ShieldState", targetEntity.curHp >= 3 and 0 or 1)
	end

	if self.point5UComponent and self.point5UComponent.TryChangePage then
		self.point5UComponent:TryChangePage("ShieldState", targetEntity.curHp >= 2 and 0 or 1)
	end

	if self.shieldRootUWidget and not self.m_isRespawnRecovery then
		self.shieldRootUWidget:TryChangePage("ShieldWaring", targetEntity.curHp > 1 and 0 or 1)
	end

	if self.numUText then
		ClientTextUtils.setText(self.numUText, math.max(targetEntity.curHp - 1, 0))
	end

	local shouldWarn = targetEntity.curHp <= 1

	if self.m_isRespawnRecovery then
		self:m_resetShieldWarningDisplay()
	elseif shouldWarn then
		if not self.isWarning then
			self:m_invokePoints(CS.XGUI.EInvokeTime.User2)

			self.isWarning = true
		end
	elseif self.isWarning or force then
		self:m_resetShieldWarningDisplay()
	end

	local visibleNow = self.shieldRootUWidget and self.shieldRootUWidget.renderOpacity > 0.0001

	if visibleNow and ratio >= 1 then
		if hpChanged or not self.hiddenHpTimer then
			if self.hiddenHpTimer then
				self:killTimer(self.hiddenHpTimer)

				self.hiddenHpTimer = nil
			end

			self.hiddenHpTimer = self:startTimer(self.m_onHiddenHpFire, self.hpShowTime)
		end
	elseif self.hiddenHpTimer then
		self:killTimer(self.hiddenHpTimer)

		self.hiddenHpTimer = nil
	end
end

function TopLogoPlayerHubComponent:m_invokePoints(invokeTime, instant)
	instant = instant == true

	if self.point1UComponent then
		self.point1UComponent:InvokeCallback(invokeTime, instant)
	end

	if self.point2UComponent then
		self.point2UComponent:InvokeCallback(invokeTime, instant)
	end

	if self.point3UComponent then
		self.point3UComponent:InvokeCallback(invokeTime, instant)
	end

	if self.point4UComponent then
		self.point4UComponent:InvokeCallback(invokeTime, instant)
	end

	if self.point5UComponent then
		self.point5UComponent:InvokeCallback(invokeTime, instant)
	end
end

function TopLogoPlayerHubComponent:m_getPointRedFrameUWidget(pointUComponent)
	if pointUComponent == nil or IsNil(pointUComponent) then
		return nil
	end

	local pointT = pointUComponent.transform

	if pointT == nil or IsNil(pointT) then
		return nil
	end

	local okFind, redFrameT = pcall(function()
		return pointT:Find(SHIELD_RED_FRAME_NAME)
	end)

	if not okFind or redFrameT == nil or IsNil(redFrameT) then
		return nil
	end

	local okGet, redFrameUWidget = pcall(function()
		return redFrameT:GetComponent("UWidget")
	end)

	if not okGet or redFrameUWidget == nil or IsNil(redFrameUWidget) then
		return nil
	end

	return redFrameUWidget
end

function TopLogoPlayerHubComponent:m_resetPointRedFrame(pointUComponent)
	local redFrameUWidget = self:m_getPointRedFrameUWidget(pointUComponent)

	if redFrameUWidget == nil then
		return
	end

	pcall(function()
		redFrameUWidget.renderOpacity = 0
	end)
end

function TopLogoPlayerHubComponent:m_resetShieldRedFrames()
	self:m_resetPointRedFrame(self.point1UComponent)
	self:m_resetPointRedFrame(self.point2UComponent)
	self:m_resetPointRedFrame(self.point3UComponent)
	self:m_resetPointRedFrame(self.point4UComponent)
	self:m_resetPointRedFrame(self.point5UComponent)
end

function TopLogoPlayerHubComponent:m_resetShieldWarningDisplay()
	self.isWarning = false

	if self.shieldRootUWidget then
		self.shieldRootUWidget:TryChangePage("ShieldWaring", 0, true)
	end

	self:m_invokePoints(CS.XGUI.EInvokeTime.User3, true)
	self:m_resetShieldRedFrames()
end

function TopLogoPlayerHubComponent:setShieldRootVisible(visible)
	self._shieldRootVisibleReq = visible ~= false

	if not self._shieldRootVisibleReq then
		self:unloadShieldContainer()

		return
	end

	self._shieldShowOnLoad = true

	if not self:checkVisibleAndMarkDirty(DIRTY.SHIELD_ROOT_VISIBLE) then
		return
	end

	if not self.shieldRootUWidget or IsNil(self.shieldRootUWidget) then
		self:loadShieldContainerAsync()

		return
	end

	self.shieldRootUWidget.gameObject:SetActiveEx(self._shieldRootVisibleReq)

	if self._shieldRootVisibleReq and pg.me and pg.me.curHp > 1 then
		self:m_resetShieldWarningDisplay()
	end
end

function TopLogoPlayerHubComponent:onPlayerHubLifeUnalive()
	self.m_isRespawnRecovery = false

	self:setShieldRootVisible(false)
	self:resetStaminaDisplay()
end

function TopLogoPlayerHubComponent:onPlayerHubLifeAlive()
	self.m_isRespawnRecovery = true

	self:setShieldRootVisible(true)
	self:resetStaminaDisplay()
	self:refreshPlayerHp(nil, true)
end

function TopLogoPlayerHubComponent:onCharacterStateChanged()
	if not self:m_shouldKeepStaminaVisible() then
		return
	end

	self:onEnduranceChange(true)
end

function TopLogoPlayerHubComponent:onEnduranceChange(staticShow)
	if not self:shouldBeActive() then
		return
	end

	if not self:m_isCurrentPawn() then
		return
	end

	if not pg.me then
		return
	end

	local ctrl = pg.global.ui and pg.global.ui.topLogo

	if ctrl and ctrl.isPawnSwitchTransiting and ctrl:isPawnSwitchTransiting() then
		return
	end

	if pg.me.isDead and pg.me:isDead() or pg.me.FALLEN_ST and pg.me:FALLEN_ST() then
		return
	end

	if not self:syncPawnActiveState(false) then
		return
	end

	local useStatic = staticShow == true or self.m_staminaShowStatic == true

	if not self:checkVisibleAndMarkDirty(DIRTY.STAMINA) then
		if useStatic then
			self.m_staminaShowStatic = true
		end

		self:refreshVisible()

		return
	end

	self:refreshTick()

	if self.delayHiddenTimer then
		self:killTimer(self.delayHiddenTimer)

		if self.staminaRootAni and self.staminaRootAni:IsPlaying(self.fullAni) then
			if self.staminaRootUWidget then
				self.staminaRootUWidget:InvokeCallback(CS.XGUI.EInvokeTime.User1)
			end

			self.staminaRootAni:Stop()
		end

		self.delayHiddenTimer = nil
	end

	if self.staminaRootUWidget and self.staminaRootUWidget.renderOpacity <= 0.0001 then
		if useStatic then
			self.staminaRootUWidget.renderOpacity = 1
		else
			self.staminaRootUWidget:InvokeCallback(CS.XGUI.EInvokeTime.User2)
		end
	end

	self.m_staminaShowStatic = nil

	if not self.isShow then
		self.isShow = true
		self.ticId = self:startTimer(self.m_onStaminaTick, self.deltaTime, true)
	end
end

function TopLogoPlayerHubComponent:m_startStaminaFlightStateTick()
	if self.staminaFlightStateTimer == nil then
		self.staminaFlightStateTimer = self:startTimer(self.m_onStaminaFlightStateTick, 0.1, true)
	end
end

function TopLogoPlayerHubComponent:m_stopStaminaFlightStateTick()
	if self.staminaFlightStateTimer then
		self:killTimer(self.staminaFlightStateTimer)

		self.staminaFlightStateTimer = nil
	end
end

function TopLogoPlayerHubComponent:m_stopStaminaTick()
	if self.ticId then
		self:killTimer(self.ticId)

		self.ticId = nil
	end

	if self.refreshDashCost then
		self:killTimer(self.refreshDashCost)

		self.refreshDashCost = nil
	end

	self.isShow = false
end

function TopLogoPlayerHubComponent:m_doStaminaFlightStateTick()
	if self:m_shouldKeepStaminaVisible() then
		return
	end

	self:m_stopStaminaFlightStateTick()
	self:onEnduranceChange()
end

function TopLogoPlayerHubComponent:m_doStaminaTick()
	if not pg.me then
		return
	end

	if not self:m_isCurrentPawn() then
		self:m_stopStaminaTick()
		self:m_stopStaminaFlightStateTick()

		return
	end

	local ctrl = pg.global.ui and pg.global.ui.topLogo

	if ctrl and ctrl.isPawnSwitchTransiting and ctrl:isPawnSwitchTransiting() then
		self:m_stopStaminaTick()
		self:m_stopStaminaFlightStateTick()

		return
	end

	local curRealValue = pg.me:getStamina()

	if curRealValue <= self.dashCost then
		self.barState = 1
	else
		self.barState = 0
	end

	if self.playerHubUComponent then
		self.playerHubUComponent:TryChangePage("StaWarning", self.barState)
	end

	if curRealValue >= pg.me.maxStamina then
		self:m_stopStaminaTick()

		if self:m_shouldKeepStaminaVisible() then
			self:m_startStaminaFlightStateTick()
		else
			self:m_stopStaminaFlightStateTick()

			if self.staminaRootAni and not self.staminaRootAni:IsPlaying(self.addAni) and self.playerHubUComponent then
				self.playerHubUComponent:TryChangePage("StaWarning", 2)
			end

			self:delayHidden()
		end
	end

	self:setEnduranceValue(self:calculateCurrentShowValue())
end

function TopLogoPlayerHubComponent:delayHidden()
	self.delayHiddenTimer = self:startTimer(self.m_onDelayHidden, self.delayHiddenTime)
end

function TopLogoPlayerHubComponent:resetStaminaDisplay()
	self:m_stopStaminaTick()
	self:m_stopStaminaFlightStateTick()

	if self.warningTimer then
		self:killTimer(self.warningTimer)

		self.warningTimer = nil
	end

	if self.delayHiddenTimer then
		self:killTimer(self.delayHiddenTimer)

		self.delayHiddenTimer = nil
	end

	self:killReduceTimer()

	self.isShow = false
	self.barState = 0

	if self.reduceFillUImage then
		self.reduceFillUImage:SetActive(false)
	end

	if self.playerHubUComponent then
		self.playerHubUComponent:TryChangePage("StaWarning", 0)
	end

	if self.staminaRootUWidget then
		self.staminaRootUWidget.renderOpacity = 0
	end
end

function TopLogoPlayerHubComponent:m_doDelayHiddenFire()
	self.delayHiddenTimer = nil

	if self:m_shouldKeepStaminaVisible() then
		self:m_startStaminaFlightStateTick()

		return
	end

	if self.staminaRootUWidget then
		self.staminaRootUWidget.renderOpacity = 0
	end
end

function TopLogoPlayerHubComponent:m_doHiddenHpFire()
	self.hiddenHpTimer = nil

	if not self.shieldRootUWidget or IsNil(self.shieldRootUWidget) then
		return
	end

	self.shieldRootUWidget.renderOpacity = 0

	self:cancelShieldUnload()

	self.shieldUnloadTimer = self:startTimer(self.m_onShieldUnload, self.shieldUnloadDelay)
end

function TopLogoPlayerHubComponent:onShieldUnloadTimer()
	self.shieldUnloadTimer = nil

	self:unloadShieldContainer()
end

function TopLogoPlayerHubComponent:calculateCurrentShowValue()
	local curValue = self.curEnduranceValue
	local curValueReduce = self.curEnduranceValueReduce
	local newTargetValue = pg.me:getStamina()

	if self.targetValue ~= newTargetValue then
		if math.abs(newTargetValue - self.targetValue) >= self.showRedLimit then
			if self.warningTimer then
				self:killTimer(self.warningTimer)
			end

			self:killReduceTimer()

			if self.reduceFillUImage then
				self.reduceFillUImage:SetActive(true)
			end

			self.warningTimer = self:startTimer(self.m_onWarningHide, self.warningDuration)
		end

		self.targetValue = newTargetValue
		self.increaseValue = (self.targetValue - curValue) / self.smoothRate
		self.increaseValueReduce = (self.targetValue - curValueReduce) / self.smoothRateReduce
	end

	local newValue = curValue
	local newValueReduce = curValueReduce

	if math.abs(self.targetValue - curValueReduce) > 0.01 then
		newValueReduce = newValueReduce + (self.increaseValueReduce or 0)
	end

	if math.abs(self.targetValue - curValue) > 0.01 then
		newValue = newValue + (self.increaseValue or 0)
	end

	return newValue, newValueReduce
end

function TopLogoPlayerHubComponent:killReduceTimer()
	if self.reduceTimers then
		for _, tid in ipairs(self.reduceTimers) do
			self:killTimer(tid)
		end
	end

	self.reduceTimers = {}
end

function TopLogoPlayerHubComponent:m_syncStaminaVisualImmediately(curStamina)
	if curStamina == nil then
		if not pg.me then
			return
		end

		curStamina = pg.me:getStamina()
	end

	if pg.me and pg.me.maxStamina then
		curStamina = math.min(curStamina, pg.me.maxStamina)
	end

	self:killReduceTimer()

	if self.warningTimer then
		self:killTimer(self.warningTimer)

		self.warningTimer = nil
	end

	self.curEnduranceValue = curStamina
	self.curEnduranceValueReduce = curStamina
	self.targetValue = curStamina

	local curRate = curStamina / self.staminaAngleRate / 360

	if NotNil(self.normalFillUImage) then
		self.normalFillUImage.fillAmount = curRate
	end

	if NotNil(self.fxFillUImage) then
		self.fxFillUImage.fillAmount = curRate
	end

	if NotNil(self.reduceFillUImage) then
		self.reduceFillUImage.fillAmount = curRate

		self.reduceFillUImage:SetActive(false)
	end

	self.barState = curStamina <= self.dashCost and 1 or 0

	if NotNil(self.playerHubUComponent) then
		self.playerHubUComponent:TryChangePage("StaWarning", self.barState)
	end
end

function TopLogoPlayerHubComponent:setEnduranceValue(curShowValue, curShowValueReduce)
	self.curEnduranceValue = curShowValue
	self.curEnduranceValueReduce = curShowValueReduce

	local curRate = curShowValue / self.staminaAngleRate / 360

	if self.normalFillUImage then
		self.normalFillUImage.fillAmount = curRate
	end

	if self.fxFillUImage then
		self.fxFillUImage.fillAmount = curRate
	end

	local reduceRate = (curShowValueReduce or 0) / self.staminaAngleRate / 360
	local reduceTimer = self:startTimer(function()
		if self.reduceFillUImage then
			self.reduceFillUImage.fillAmount = reduceRate
		end
	end, self.warnDelayTime)

	if self.reduceTimers then
		table.insert(self.reduceTimers, reduceTimer)
	end

	if self.staminaRootUWidget and pg.me then
		self.staminaRootUWidget:SetActive(pg.me:isAlive())
	end
end

function TopLogoPlayerHubComponent:refreshTick()
	if self.refreshDashCost == nil then
		self.refreshDashCost = self:startTimer(self.m_onRefreshDashCost, 1, true)
	end
end

function TopLogoPlayerHubComponent:m_doWarningHide()
	if self.reduceFillUImage then
		self.reduceFillUImage:SetActive(false)
	end
end

function TopLogoPlayerHubComponent:m_doRefreshDashCost()
	if pg.me then
		self.dashCost = pg.me:getOneDashCost()
		self.showRedLimit = self.dashCost
	end
end

function TopLogoPlayerHubComponent:onPlayerEnduranceChange(info)
	if not self:shouldBeActive() then
		return
	end

	if not self:m_isCurrentPawn() then
		return
	end

	self:refreshMaxEnduranceValue()
	self:onEnduranceChange()
end

function TopLogoPlayerHubComponent:refreshMaxEnduranceValue()
	if not self:m_isCurrentPawn() then
		return
	end

	if not pg.me then
		return
	end

	if not self:checkVisibleAndMarkDirty(DIRTY.MAX_END) then
		return
	end

	local maxValue = pg.me.maxStamina
	local angle = maxValue / self.staminaAngleRate
	local fillAmount = angle / 360

	if self.bgFillUImage then
		self.bgFillUImage.fillAmount = fillAmount
	end

	if self.warningUImage then
		self.warningUImage.fillAmount = fillAmount
	end

	if self.staminaRootUWidget then
		self.staminaRootUWidget.transform.rotation = Quaternion.Euler(0, 0, -angle / 2)
	end

	if self.sike2Transform then
		self.sike2Transform.localRotation = Quaternion.Euler(0, 0, angle - 90)
	end

	if self.enduranceGlowTransform then
		self.enduranceGlowTransform.localScale = Vector3.New(1, maxValue / self.staminaOneSegment, 1)
	end

	if self.playerHubUComponent then
		local showSecondLimit = maxValue >= self.staminaOneSegment * 2

		self.playerHubUComponent:TryChangePage("StaAdd", showSecondLimit and 1 or 0)
	end

	if maxValue < self.curEnduranceValue then
		self.curEnduranceValue = maxValue
		self.curEnduranceValueReduce = maxValue
	end

	if maxValue < self.targetValue then
		self.targetValue = maxValue
	end
end

function TopLogoPlayerHubComponent:onEnduranceNotEnough()
	return
end

function TopLogoPlayerHubComponent:showEnduranceAddFx()
	if not self:shouldBeActive() then
		return
	end

	if not self:m_isCurrentPawn() then
		return
	end

	if not self:checkVisibleAndMarkDirty(nil) then
		return
	end

	if self.playerHubUComponent then
		self.playerHubUComponent:InvokeCallback(CS.XGUI.EInvokeTime.User2)
	end
end

function TopLogoPlayerHubComponent:setStaminaRootVisible(visible)
	self._staminaRootVisibleReq = visible ~= false

	if not self:checkVisibleAndMarkDirty(DIRTY.STAMINA_ROOT_VISIBLE) then
		return
	end

	if self.staminaRootUWidget then
		LuaUIUtils.setUIViewVisible(self.staminaRootUWidget, self._staminaRootVisibleReq)
	end
end

return TopLogoPlayerHubComponent
