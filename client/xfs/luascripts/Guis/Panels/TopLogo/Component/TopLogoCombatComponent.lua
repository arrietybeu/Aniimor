-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Component\\TopLogoCombatComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local Utils = require("Common.Utils.Utils")
local Const = require("Common.Const.Const")
local ECSConst = require("Common.Const.ECSConst")
local EventConst = require("Const.EventConst")
local UIConst = require("Const.UIConst")
local TopLogoConst = require("Const.TopLogoConst")
local ClientUtils = require("Utils.ClientUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local BuffUIUtils = require("Utils.BuffUIUtils")
local FriendshipLevelData = require("Data.friendship_level_data")
local SysConfigData = require("Data.sys_config_data")
local ShowTitleUtils = require("Utils.ShowTitleUtils")
local TopLogoItemComponent = require("Guis.Panels.TopLogo.Component.TopLogoItemComponent")
local TopLogoPvp2Helper = require("Guis.Panels.TopLogo.TopLogoPvp2Helper")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientSettingUtils = require("Utils.ClientSettingUtils")
local TimerManager = require("Core.Timer.TimerManager")
local Time = require("Core.Common.Time")
local AddressDataConst = require("Const.AddressDataConst")
local logger = LoggerManager.getLogger("TopLogoCombatComponent")
local debugShowActorId = false
local IsNil = IsNil
local NotNil = NotNil
local pg = pg
local TopLogoCombatComponent = Class.LightClass("TopLogoCombatComponent", TopLogoItemComponent)
local UNLOCK_FX_DURATION = 0.4
local LVTITLE_IN_SPACE = {
	LEFT = "left",
	TOP = "top"
}
local BLOOD_TYPE = {
	NORMAL = 1,
	MINI = 2
}
local BLOOD_TYPE_LAYOUTS_OFFSET = {
	[BLOOD_TYPE.NORMAL] = {
		levelLocUWidget = {
			0,
			0
		},
		listElementLocUWidget = {
			8,
			0
		}
	},
	[BLOOD_TYPE.MINI] = {
		levelLocUWidget = {
			65,
			0
		},
		listElementLocUWidget = {
			-65,
			0
		}
	}
}
local COMBAT_INFO_MODE = {
	FULL = 1,
	SIMPLIFIED = 2
}
local STATUS_EFFECT_WIDTH = {
	[BLOOD_TYPE.NORMAL] = 372,
	[BLOOD_TYPE.MINI] = 250
}
local BLOOD_BREAK_VX = {
	[BLOOD_TYPE.NORMAL] = AddressDataConst.TOPLOGO_BLOOD_BREAK_VX,
	[BLOOD_TYPE.MINI] = AddressDataConst.TOPLOGO_BLOOD_BREAK_VX_MINI
}
local BROKEN_VX_DURATION = 1000

local function logBrokenVxError(self, fmt, ...)
	return
end

local function getBreakBarPageIndex(self)
	if not self.entity then
		return 0
	end

	local isPvp = pg.space and (pg.space:isPvpEnv() or pg.space.isPvp)

	return not Utils.isEnemy(pg.pawn, self.entity) and not isPvp and 1 or 0
end

local function countTitleElementList(elementList)
	local count = 0

	if elementList then
		for _ in pairs(elementList) do
			count = count + 1
		end
	end

	return count
end

local BLOOD_CB_FUNC = {
	FREEZE_HP = "freezeHp",
	REFRESH_BREAK_BAR = "refreshBreakBar",
	NAME_COLOR = "nameColor",
	BUFF_CHANGE = "buffChange",
	TPL_INFO = "tplInfo",
	SHIELD_BREAK = "shieldBreak",
	SHIELD_POINT = "shieldPoint",
	HEALTH_POINT = "healthPoint",
	FREEZE_HP_OUT = "freezeHpOut",
	FREEZE_HP_HIT = "freezeHpHit"
}

function TopLogoCombatComponent:ctor(refUContainer, topLogoItem)
	if not topLogoItem.entity and LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("TopLogoCombatComponent >> combatComponent need entity")
	end

	self.isBloodActive = false
	self.isBloodVisible = false
	self.isBuffAppearing = false

	TopLogoCombatComponent.super.ctor(self, refUContainer, topLogoItem)
end

function TopLogoCombatComponent:onCtor()
	self.name = nil
	self.state = nil
	self.bloodColor = nil
	self.nameColor = nil
	self.bloodType = ClientSettingUtils.get_bloodType()
	self.combatInfoMode = self.bloodType == 0 and COMBAT_INFO_MODE.SIMPLIFIED or COMBAT_INFO_MODE.FULL
	self.m_cbCacheCombatInfo = {
		[TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC1] = {},
		[TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC2] = {},
		[TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC3] = {},
		[TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC4] = {}
	}
	self.m_cbSubBloodCacheInfo = {
		[BLOOD_CB_FUNC.TPL_INFO] = {},
		[BLOOD_CB_FUNC.NAME_COLOR] = {},
		[BLOOD_CB_FUNC.FREEZE_HP] = {},
		[BLOOD_CB_FUNC.FREEZE_HP_HIT] = {},
		[BLOOD_CB_FUNC.FREEZE_HP_OUT] = {},
		[BLOOD_CB_FUNC.HEALTH_POINT] = {},
		[BLOOD_CB_FUNC.SHIELD_POINT] = {},
		[BLOOD_CB_FUNC.SHIELD_BREAK] = {},
		[BLOOD_CB_FUNC.REFRESH_BREAK_BAR] = {},
		[BLOOD_CB_FUNC.BUFF_CHANGE] = {}
	}

	self:m_initBloodCbFuncs()
	self:m_setBrokenContainerLoadedFunc()
	self:refreshVisible()

	local _h = TopLogoCombatComponent._platformHooks

	if _h and _h.onCtor then
		_h.onCtor(self)
	end
end

function TopLogoCombatComponent:m_initBloodCbFuncs()
	local cb = self.m_cbSubBloodCacheInfo

	cb[BLOOD_CB_FUNC.TPL_INFO].cbFunc = function(isSuccess)
		if not isSuccess then
			return
		end

		if self:checkBloodVisibleAndResetDirty(EventConst.TOPLOGO_HEALTH_POINT) then
			self:refreshHealthPoint(Utils.getEntityHealthInfo(self.entity))

			return
		end

		if self:checkBloodVisibleAndResetDirty(EventConst.TOPLOGO_SHIELD_POINT) then
			self:refreshShieldPoint(self.entity)

			return
		end

		if self:checkBloodVisibleAndResetDirty(EventConst.TOPLOGO_BREAK_POINT) then
			self:refreshBreakBar(Utils.getEntityBreakInfo(self.entity))

			return
		end

		if self:checkBloodVisibleAndResetDirty(EventConst.ON_BUFF_CHANGE) then
			self:refreshByBuffChange()

			return
		end
	end
	cb[BLOOD_CB_FUNC.NAME_COLOR].cbFunc = function(isSuccess, cbBloodColor)
		if isSuccess then
			self.bloodUComponent:TryChangePage("NameChar", cbBloodColor or self.bloodColor)
		end
	end
	cb[BLOOD_CB_FUNC.FREEZE_HP].cbFunc = function(isSuccess, cbIsFreezeHp)
		if isSuccess then
			if cbIsFreezeHp then
				self.bloodUComponent:TryChangePage("PaopaoHit", 1)
			else
				self.bloodUComponent:TryChangePage("PaopaoHit", 0)
			end
		end
	end
	cb[BLOOD_CB_FUNC.FREEZE_HP_HIT].cbFunc = function(isSuccess)
		if isSuccess then
			self.bloodUComponent:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
		end
	end
	cb[BLOOD_CB_FUNC.FREEZE_HP_OUT].cbFunc = function(isSuccess, cacheInfo)
		if isSuccess and cacheInfo then
			local cbValue = cacheInfo.value

			self.waringPaopaoUImage.gameObject:SetActiveEx(cbValue)

			if cbValue then
				self.waringPaopaoUImage.renderOpacity = cacheInfo.alpha or 1
			else
				self.waringPaopaoUImage.renderOpacity = 1
			end
		end
	end
	cb[BLOOD_CB_FUNC.HEALTH_POINT].cbFunc = function(isSuccess, cbInfo)
		if isSuccess then
			self:realRefreshHealthPoint(cbInfo)
		end
	end
	cb[BLOOD_CB_FUNC.SHIELD_POINT].cbFunc = function(isSuccess, cbEntity)
		if isSuccess and cbEntity then
			LuaUIUtils.setShieldBar(cbEntity, nil, self.barShieldUHealthbar)
		end
	end
	cb[BLOOD_CB_FUNC.SHIELD_BREAK].cbFunc = function(isSuccess)
		if isSuccess then
			self:m_onShieldBreak(true)
		end
	end
	cb[BLOOD_CB_FUNC.REFRESH_BREAK_BAR].cbFunc = function(isSuccess, newCbData)
		if isSuccess then
			self:m_refreshBreakBar(true, newCbData and newCbData.info or nil, newCbData and newCbData.deltaBp or nil, newCbData and newCbData.isIgnoreHpLock or nil)
		end
	end
	cb[BLOOD_CB_FUNC.BUFF_CHANGE].cbFunc = function(isSuccess, cbInfo)
		if isSuccess then
			local buffData, specialStateBuff = BuffUIUtils.getUIBuffList(self.entity, SysConfigData.toplogoBuffCount or 4)

			BuffUIUtils.filterEcsBuff(buffData)
			self.buffUList:SetList(buffData)

			self.curBuffList = buffData
			self.curSpecialStateBuff = specialStateBuff
			self.curSpecialStateBuffInsId = specialStateBuff and specialStateBuff.instanceId or nil

			self:refreshEcsAmount(self.entity)

			if specialStateBuff and self.isBloodBarVisible == true then
				self:safeSetActive(self.nameBarUWidget, true)
				self:m_showStatusEffectBuff(specialStateBuff)
			elseif cbInfo and cbInfo.isRemove and cbInfo.buffInsId == self.curSpecialStateBuffInsId then
				self:m_hideStatusEffectBuffWithDelay()
			end

			self:checkBuffDisappearFx(cbInfo, buffData)
		end
	end
end

function TopLogoCombatComponent:shouldBeActive()
	if not self.entity or not self.entity.actorCombatAttribute then
		return false
	end

	return self.isBloodVisible == true
end

function TopLogoCombatComponent:resetRender()
	local layout = TopLogoCombatComponent._platformTopLogoOnlineID

	if layout then
		layout.stopOnlineIDLayout(self)
	end

	BuffUIUtils.tryDestroyEleBuffsTimer(self)

	if self.m_showLeveTxtTimer then
		TimerManager.removeTimer(self.m_showLeveTxtTimer)

		self.m_showLeveTxtTimer = nil
	end

	if self.isDelayShowLevelTimer2 then
		TimerManager.removeTimer(self.isDelayShowLevelTimer2)

		self.isDelayShowLevelTimer2 = nil
	end

	if self.delayHideVxLineTimer then
		TimerManager.removeTimer(self.delayHideVxLineTimer)

		self.delayHideVxLineTimer = nil
	end

	if self.delayHideShieldTimer then
		TimerManager.removeTimer(self.delayHideShieldTimer)

		self.delayHideShieldTimer = nil
	end

	if self.delayChangeBreakTimer then
		TimerManager.removeTimer(self.delayChangeBreakTimer)

		self.delayChangeBreakTimer = nil
	end

	if self.delayHideStatuesEfxTimer then
		TimerManager.removeTimer(self.delayHideStatuesEfxTimer)

		self.delayHideStatuesEfxTimer = nil
	end

	self.name = nil
	self.bloodColor = nil
	self.nameColor = nil
	self.order = nil
	self.isControlPet = nil
	self.isFriend = nil
	self.friendLevel = nil
	self.isBloodBarVisible = nil
	self.isMiniBlood = nil
	self.m_bloodInfoLocVisible = nil
	self.bloodContainerLoaded = nil
	self.m_shieldBarResetedMap = nil
	self.bloodUComponent = nil
	self.barHPUHealthbar = nil
	self.barShieldUHealthbar = nil
	self.barBreakUHealthbar = nil
	self.barBreakCountdown = nil
	self.waringPaopaoUImage = nil
	self.shieldBlastUParticle = nil
	self.breakingCountDownUCountDown = nil
	self.vxCountdownAnimation = nil
	self.breakCountDownBarBreak = nil
	self.imgHandleUWidget = nil
	self.vxLineUWidget = nil
	self.uIComBloodNewTinyAnimation = nil
	self.imgBgStateUWidget = nil
	self.vxBrokenUWidget = nil
	self.vxBrokenUContainer = nil
	self.m_cbSubBloodCallbacks = nil
	self.m_breakBarNotReadyLogged = nil
	self.lvTitleInSpace = nil
	self.m_preForceShowSubName = nil
	self.curBuffList = nil
	self.curSpecialStateBuff = nil
	self.m_bloodSubContainerLoading = false
	self.m_deferHeavyRefresh = false

	if self.m_cbCacheCombatInfo then
		for _, info in pairs(self.m_cbCacheCombatInfo) do
			info.cbData = nil
		end
	end

	if self.m_cbSubBloodCacheInfo then
		for _, info in pairs(self.m_cbSubBloodCacheInfo) do
			info.cbData = nil
		end
	end

	if self.m_titleElementListApplied then
		self:m_clearTitleElementListForReuse()
	end

	self.m_titleElementListHasData = false
	self.m_titleElementListActive = nil

	self:m_clearElementToplogoContainerLoadInfo()
	self:m_setBrokenVxActive(false)

	self.objectReference = nil
	self.rootUComponent = nil
	self.bloodContainer = nil
	self.bloodBarUWidget = nil
	self.nameBarUWidget = nil
	self.titleAddonUWidget = nil
	self.teamUWidget = nil
	self.controlUWidget = nil
	self.likabilityUWidget = nil
	self.iconLikabilityUImage = nil
	self.levelUText = nil
	self.levelUWidget = nil
	self.nameUText = nil
	self.nameVariant1UBaseText = nil
	self.nameVariant2UBaseText = nil
	self.newLabelUImage = nil
	self.subTextUSDFText = nil
	self.onlineIDUContainer = nil
	self.onlineIDText = nil
	self.m_onlineIDLoadReqId = nil
	self._platformOnlineIDPendingLoad = nil
	self.listElementUList = nil
	self.buffUList = nil
	self.elementToplogoUContainer = nil
	self.statusEffectUContainer = nil
	self.topLogoBuffUButton = nil
	self.listElementLocUWidget = nil
	self.levelLocUWidget = nil
	self.levelLocUWidgetInitLocalPos = nil
	self.listElementLocUWidgetInitLocalPos = nil
	self.teamLocUWidgetOriginalParent = nil
	self.teamLocUWidgetOriginalAnchorMin = nil
	self.teamLocUWidgetOriginalAnchorMax = nil
	self.teamLocUWidgetOriginalLocalPos = nil

	TopLogoCombatComponent.super.resetRender(self)
	self:markDirty(EventConst.ON_BUFF_CHANGE)
	self:markDirty(EventConst.TOPLOGO_BREAK_POINT)
	self:markDirty(EventConst.TOPLOGO_HEALTH_POINT)
	self:markDirty(EventConst.TOPLOGO_SHIELD_POINT)
	self:markDirty("updateHealthBar")

	if self.isFreezeHp then
		self:markDirty(EventConst.ON_FREEZE_HP_CHANGED)
	end
end

function TopLogoCombatComponent:findObjects()
	self.objectReference = self.refUContainer.content:GetComponent("ObjectReference")
	self.rootUComponent = self.objectReference:GetRefValue("rootUComponent")
	self.bloodContainer = self.objectReference:GetRefValue("bloodContainer")
	self.levelUText = self.objectReference:GetRefValue("levelUText")
	self.levelUWidget = self.objectReference:GetRefValue("levelUWidget")
	self.teamUWidget = self.objectReference:GetRefValue("teamUWidget")
	self.nameUText = self.objectReference:GetRefValue("nameUText")
	self.nameVariant1UBaseText = self.objectReference:GetRefValue("nameVariant1UBaseText")
	self.nameVariant2UBaseText = self.objectReference:GetRefValue("nameVariant2UBaseText")

	local newLabelUImageTs = self.objectReference:GetRefValue("newLabelUImage")

	self.newLabelUImage = newLabelUImageTs:GetComponent("UWidget")
	self.listElementUList = self.objectReference:GetRefValue("listElementUList")
	self.buffUList = self.objectReference:GetRefValue("buffUList")
	self.titleAddonUWidget = self.objectReference:GetRefValue("titleAddonUWidget")
	self.nameBarUWidget = self.objectReference:GetRefValue("nameBarUWidget")
	self.bloodBarUWidget = self.objectReference:GetRefValue("bloodBarUWidget")
	self.subTextUSDFText = self.objectReference:GetRefValue("subTextUSDFText")
	self.onlineIDUContainer = self.objectReference:GetRefValue("onlineIDUContainer")
	self.onlineIDText = nil

	self:hideOnlineIDText()

	self.controlUWidget = self.objectReference:GetRefValue("controlUWidget")
	self.likabilityUWidget = self.objectReference:GetRefValue("likabilityUWidget")
	self.iconLikabilityUImage = self.objectReference:GetRefValue("iconLikabilityUImage")
	self.topLogoBuffUButton = self.objectReference:GetRefValue("topLogoBuffUButton")
	self.elementToplogoUContainer = self.objectReference:GetRefValue("elementToplogoUContainer")
	self.statusEffectUContainer = self.objectReference:GetRefValue("statusEffectUContainer")
	self.listElementLocUWidget = self.objectReference:GetRefValue("listElementLocUWidget")
	self.levelLocUWidget = self.objectReference:GetRefValue("levelLocUWidget")
	self.teamLocUWidget = self.objectReference:GetRefValue("teamLocUWidget")

	if self.teamLocUWidget then
		if not self.teamLocUWidgetOriginalParent then
			self.teamLocUWidgetOriginalParent = self.teamLocUWidget.transform.parent
		end

		if not self.teamLocUWidgetOriginalAnchorMin then
			local rectTransform = self.teamLocUWidget.transform

			self.teamLocUWidgetOriginalAnchorMin = rectTransform.anchorMin
			self.teamLocUWidgetOriginalAnchorMax = rectTransform.anchorMax
			self.teamLocUWidgetOriginalLocalPos = rectTransform.localPosition
		end
	end

	if not self.levelLocUWidgetInitLocalPos then
		self.levelLocUWidgetInitLocalPos = self.levelLocUWidget.transform.localPosition
	end

	if not self.listElementLocUWidgetInitLocalPos then
		self.listElementLocUWidgetInitLocalPos = self.listElementLocUWidget.transform.localPosition
	end

	local _h = TopLogoCombatComponent._platformHooks

	if _h and _h.onFindObjects then
		_h.onFindObjects(self)
	end
end

function TopLogoCombatComponent:initUI()
	self.state = nil
	self.isBloodBarVisible = nil

	self:safeSetActiveFastest(self.rootUComponent, false)
	self:m_setBloodInfoLocVisible(true)
	self:refreshLevelAndThreatState(true)
	self:refreshGender()
	self:refreshIcon()
	self:refreshSubName()
	self:refreshVariant()
	self:refreshTitleElementList()
	self:m_prefetchBloodContainer()

	self.buffDisappearHintTimer = {}
end

function TopLogoCombatComponent:m_prefetchBloodContainer()
	if self.bloodContainerLoaded then
		return
	end

	if self.m_bloodSubContainerLoading then
		return
	end

	if not self.bloodContainer then
		return
	end

	self:loadBloodSubContainerAsync()
end

function TopLogoCombatComponent:onDestroy()
	local _h = TopLogoCombatComponent._platformHooks

	if _h and _h.onDestroy then
		_h.onDestroy(self)
	end

	if self.entity and self.entity.enableNotifyEcsAmount then
		self.entity:enableNotifyEcsAmount(false, ECSConst.ECS_AMOUNT_NOTIFY_OWNER.TOP_LOGO)
	end

	self.m_shieldBarResetedMap = nil

	BuffUIUtils.tryDestroyEleBuffsTimer(self)

	if self.m_showLeveTxtTimer then
		TimerManager.removeTimer(self.m_showLeveTxtTimer)

		self.m_showLeveTxtTimer = nil
	end

	if self.isDelayShowLevelTimer2 then
		TimerManager.removeTimer(self.isDelayShowLevelTimer2)

		self.isDelayShowLevelTimer2 = nil
	end

	if self.delayHideVxLineTimer then
		TimerManager.removeTimer(self.delayHideVxLineTimer)

		self.delayHideVxLineTimer = nil
	end

	if self.delayHideShieldTimer then
		TimerManager.removeTimer(self.delayHideShieldTimer)

		self.delayHideShieldTimer = nil
	end

	if self.delayChangeBreakTimer then
		TimerManager.removeTimer(self.delayChangeBreakTimer)

		self.delayChangeBreakTimer = nil
	end

	if self.delayHideStatuesEfxTimer then
		TimerManager.removeTimer(self.delayHideStatuesEfxTimer)

		self.delayHideStatuesEfxTimer = nil
	end

	if self.entity then
		self.entity.eventEmitter:removeEventListener(EventConst.TOPLOGO_CATCH_LOCK, self.onCatchLockMsg)
		self.entity.eventEmitter:removeEventListener(EventConst.TOPLOGO_PET_SHIELD, self.onPetShieldMsg)
		self.entity.eventEmitter:removeEventListener(EventConst.TOPLOGO_SHIELD_POINT, self.onShieldMsg)
		self.entity.eventEmitter:removeEventListener(EventConst.TOPLOGO_SHIELD_BREAK, self.onShieldBreakMsg)
		self.entity.eventEmitter:removeEventListener(EventConst.TOPLOGO_BREAK_POINT, self.onBreakPointMsg)
		self.entity.eventEmitter:removeEventListener(EventConst.TOPLOGO_HEALTH_POINT, self.onHealthPointMsg)
		self.entity.eventEmitter:removeEventListener(EventConst.ON_FREEZE_HP_CHANGED, self.onFreezeHpChangedMsg)
		self.entity.eventEmitter:removeEventListener(EventConst.ON_FREEZE_HP_HIT, self.onFreezeHpHitMsg)
		self.entity.eventEmitter:removeEventListener(EventConst.ON_FREEZE_HP_OUT_TIME, self.onFreezeHpOutTime)
		self.entity.eventEmitter:removeEventListener(EventConst.ON_BUFF_CHANGE, self.onBuffChange)
		self.entity.eventEmitter:removeEventListener(EventConst.ON_BUFF_ADD, self.onBuffAdd)
		self.entity.eventEmitter:removeEventListener(EventConst.ON_BUFF_REMOVE, self.onBuffRemove)
		self.entity.eventEmitter:removeEventListener(EventConst.ON_BUFF_EXPIRED_TIME_CHANGE, self.onBuffExpiredTimeChange)
		self.entity.eventEmitter:removeEventListener(EventConst.BUFF_LAYER_CHANGE, self.onBuffLayerChange)
		self.entity.eventEmitter:removeEventListener(EventConst.APPEAR_FROM_TOPLOGO_BUFF, self.onAppearFromTopLogoBuffChange)
		self.entity.eventEmitter:removeEventListener(EventConst.ECS_MAX_AMOUNT_CHANGE, self.onEcsAmountChange)
	end

	if self.m_onBloodTypeChanged then
		pg.global.eventEmitter:removeEventListener(EventConst.SETTING_BLOOD_TYPE_CHANGED, self.m_onBloodTypeChanged)

		self.m_onBloodTypeChanged = nil
	end

	TopLogoCombatComponent.super.onDestroy(self)

	self.m_cbCacheCombatInfo = nil
	self.m_cbSubBloodCacheInfo = nil
	self.m_preEcsAmountCacheState = nil
	self.m_bloodSubContainerLoading = false

	self:m_clearElementToplogoContainerLoadInfo()
	self:m_setBrokenVxActive(false)

	if self.buffDisappearHintTimer then
		for _, timerId in pairs(self.buffDisappearHintTimer) do
			TimerManager.removeTimer(timerId)
		end

		self.buffDisappearHintTimer = nil
	end
end

function TopLogoCombatComponent:addEntityListener()
	function self.onCatchLockMsg(visible)
		return
	end

	function self.onPetShieldMsg()
		if self:checkBloodVisibleAndMarkDirty(EventConst.TOPLOGO_PET_SHIELD) then
			local entity = pg.me:getCurPetEntity()

			self:refreshShieldPoint(entity)
		end
	end

	function self.onShieldMsg()
		if self:checkBloodVisibleAndMarkDirty(EventConst.TOPLOGO_SHIELD_POINT) then
			self:refreshShieldPoint(self.entity)
		end
	end

	function self.onShieldBreakMsg()
		if self:checkFinalVisible() then
			self:onShieldBreak()
		end
	end

	function self.onBreakPointMsg(deltaBp, isIgnoreHpLock)
		if self:checkBloodVisibleAndMarkDirty(EventConst.TOPLOGO_BREAK_POINT) then
			self:refreshBreakBar(Utils.getEntityBreakInfo(self.entity), deltaBp, isIgnoreHpLock)
		end
	end

	function self.onHealthPointMsg(ov, nv)
		if self:checkBloodVisibleAndMarkDirty(EventConst.TOPLOGO_HEALTH_POINT) then
			self:refreshHealthPoint(Utils.getEntityHealthInfo(self.entity))

			if ov == self.entity.actorCombatAttribute:getMaxHp() and nv < ov and self:canUpdateHealthBarImmediately() then
				self:updateHealthBar()
			end
		end
	end

	function self.onFreezeHpChangedMsg(isFreezeHp)
		self.isFreezeHp = isFreezeHp

		if self:checkVisibleAndMarkDirty(EventConst.ON_FREEZE_HP_CHANGED) then
			self:refreshFreezeHp(self.isFreezeHp)
		end
	end

	function self.onFreezeHpHitMsg()
		if self:checkFinalVisible() then
			self:freezeHpHit()
		end
	end

	function self.onFreezeHpOutTime(value, alpha)
		self.freezeHpOutValue = value
		self.freezeHpOutAlpha = alpha

		if self:checkVisibleAndMarkDirty(EventConst.ON_FREEZE_HP_OUT_TIME) then
			self:freezeHpOutTimer(self.freezeHpOutValue, self.freezeHpOutAlpha)
		end
	end

	function self.onBuffChange(info)
		if self:checkBloodVisibleAndMarkDirty(EventConst.ON_BUFF_CHANGE) then
			self:refreshByBuffChange(info)
		end
	end

	function self.onBuffAdd(info)
		if not info or not info.newBuffData then
			return
		end

		if not self:checkBloodVisibleAndMarkDirty(EventConst.ON_BUFF_CHANGE) then
			return
		end

		if not self:m_canIncrementalBuff() then
			self:markDirty(EventConst.ON_BUFF_CHANGE)

			return
		end

		self:m_onBuffAddIncremental(info)
	end

	function self.onBuffRemove(info)
		if not info or not info.buffInsId then
			return
		end

		BuffUIUtils.clearBuffDisappearHintTimer(self, info.buffInsId)

		if not self:checkBloodVisibleAndMarkDirty(EventConst.ON_BUFF_CHANGE) then
			return
		end

		if not self:m_canIncrementalBuff() then
			self:markDirty(EventConst.ON_BUFF_CHANGE)

			return
		end

		self:m_onBuffRemoveIncremental(info)
	end

	function self.onBuffExpiredTimeChange(info)
		if not info or not info.buffInsId then
			return
		end

		self:m_refreshStatusEffectBuffExpiredTime(info)

		if not self:checkBloodVisibleAndMarkDirty(EventConst.ON_BUFF_CHANGE) then
			return
		end

		if not self:m_canIncrementalBuff() then
			self:markDirty(EventConst.ON_BUFF_CHANGE)

			return
		end

		local buffInfo = BuffUIUtils.updateBuffExpiredTime(self.buffUList, self.curBuffList, info)

		if buffInfo then
			local should, delayTime, instanceId = BuffUIUtils.rescheduleDisappearHint(self, buffInfo)

			if should then
				self.buffDisappearHintTimer[instanceId] = TimerManager.addTimer(delayTime, function()
					BuffUIUtils.invokeDisappearHintFx(self.buffUList, self.curBuffList, instanceId)
				end)
			end
		end
	end

	function self.onBuffLayerChange(info)
		if not info or not info.instanceId then
			return
		end

		if not self:checkBloodVisibleAndMarkDirty(EventConst.ON_BUFF_CHANGE) then
			return
		end

		if not self:m_canIncrementalBuff() then
			self:markDirty(EventConst.ON_BUFF_CHANGE)

			return
		end

		BuffUIUtils.applyLayerChange(self.buffUList, self.curBuffList, info)
	end

	function self.onAppearFromTopLogoBuffChange(info)
		if info.ent == self.entity then
			self:onAppearFromTopLogoBuff(info)
		end
	end

	function self.onEcsAmountChange(ent)
		self:refreshEcsAmount(ent)
	end

	function self.m_onBloodTypeChanged(bloodType)
		self:onBloodTypeChanged(bloodType)
	end

	if self.entity then
		self.entity.eventEmitter:addEventListener(EventConst.TOPLOGO_CATCH_LOCK, self.onCatchLockMsg)
		self.entity.eventEmitter:addEventListener(EventConst.TOPLOGO_PET_SHIELD, self.onPetShieldMsg)
		self.entity.eventEmitter:addEventListener(EventConst.TOPLOGO_SHIELD_POINT, self.onShieldMsg)
		self.entity.eventEmitter:addEventListener(EventConst.TOPLOGO_SHIELD_BREAK, self.onShieldBreakMsg)
		self.entity.eventEmitter:addEventListener(EventConst.TOPLOGO_BREAK_POINT, self.onBreakPointMsg)
		self.entity.eventEmitter:addEventListener(EventConst.TOPLOGO_HEALTH_POINT, self.onHealthPointMsg)
		self.entity.eventEmitter:addEventListener(EventConst.ON_FREEZE_HP_CHANGED, self.onFreezeHpChangedMsg)
		self.entity.eventEmitter:addEventListener(EventConst.ON_FREEZE_HP_HIT, self.onFreezeHpHitMsg)
		self.entity.eventEmitter:addEventListener(EventConst.ON_FREEZE_HP_OUT_TIME, self.onFreezeHpOutTime)
		self.entity.eventEmitter:addEventListener(EventConst.ON_BUFF_CHANGE, self.onBuffChange)
		self.entity.eventEmitter:addEventListener(EventConst.ON_BUFF_ADD, self.onBuffAdd)
		self.entity.eventEmitter:addEventListener(EventConst.ON_BUFF_REMOVE, self.onBuffRemove)
		self.entity.eventEmitter:addEventListener(EventConst.ON_BUFF_EXPIRED_TIME_CHANGE, self.onBuffExpiredTimeChange)
		self.entity.eventEmitter:addEventListener(EventConst.BUFF_LAYER_CHANGE, self.onBuffLayerChange)
		self.entity.eventEmitter:addEventListener(EventConst.APPEAR_FROM_TOPLOGO_BUFF, self.onAppearFromTopLogoBuffChange)
		self.entity.eventEmitter:addEventListener(EventConst.ECS_MAX_AMOUNT_CHANGE, self.onEcsAmountChange)
	end

	pg.global.eventEmitter:addEventListener(EventConst.SETTING_BLOOD_TYPE_CHANGED, self.m_onBloodTypeChanged)
end

function TopLogoCombatComponent:addListener()
	function self.listElementUList.luaRenderItem(button, index, data)
		button:TryChangePage("type", data.elementName)
	end

	function self.buffUList.luaRenderItem(b, i, d)
		BuffUIUtils.setBuffInfo(b, d)
	end
end

function TopLogoCombatComponent:refreshTopLogoInfo(callFromUpdate)
	if self:checkFinalVisible() then
		if self:checkContainerLoaded() then
			self:m_refreshTopLogoInfo(false)
		else
			local cbCacheInfo = self.m_cbCacheCombatInfo and self.m_cbCacheCombatInfo[TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC2]

			if cbCacheInfo and not cbCacheInfo.cbFunc then
				function cbCacheInfo.cbFunc(isSuccess)
					if isSuccess then
						self:m_refreshTopLogoInfo(true)
					end
				end
			end

			self:checkAndLoadUContainerUrlSupportAsync(cbCacheInfo.cbFunc, TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC2)
		end
	end
end

function TopLogoCombatComponent:m_refreshTopLogoInfo(forceRefreshName)
	local deferHeavy = self.m_deferHeavyRefresh

	self.m_deferHeavyRefresh = false

	self:refreshName(forceRefreshName)
	self:setNameColor()
	self:setTeamState()
	self:setControlPet()
	self:setFriendShip()

	if self:checkAndResetDirty(EventConst.ON_FREEZE_HP_CHANGED) then
		self:refreshFreezeHp(self.isFreezeHp)
	end

	if self:checkAndResetDirty(EventConst.ON_FREEZE_HP_OUT_TIME) then
		self:freezeHpOutTimer(self.freezeHpOutValue, self.freezeHpOutAlpha)
	end

	if self:checkAndResetDirty("updateHealthBar") and self:canUpdateHealthBarImmediately() then
		if deferHeavy then
			self:markDirty("updateHealthBar")
		else
			self:updateHealthBar()
		end
	end

	if self:checkBloodVisible() then
		self:checkAndLoadBloodUrlAsync(self.m_cbSubBloodCacheInfo[BLOOD_CB_FUNC.TPL_INFO].cbFunc, BLOOD_CB_FUNC.TPL_INFO)
	end
end

function TopLogoCombatComponent:setNameColor()
	local masterEnt = self.entity.getMasterEntity and self.entity:getMasterEntity()
	local ent = Utils.isPlayerPet(self.entity) and masterEnt or self.entity

	if masterEnt and (Utils.isPlayerPet(masterEnt) or Utils.isBotPet(masterEnt)) and masterEnt.getMasterEntity then
		ent = masterEnt:getMasterEntity()
	end

	local bloodColor, nameColor

	if ent.uid == pg.me.uid then
		bloodColor = "Normal"
		nameColor = "Normal"
	elseif Utils.isEnemy(ent, pg.me) then
		bloodColor = "Enemy"

		if Utils.isInPVPScene() then
			nameColor = "Enemy"
		else
			nameColor = "NPC"
		end
	elseif Utils.isTeamPlayerOrPet(ent) or Utils.isBotPlayer(masterEnt) or Utils.isBotPlayer(ent) then
		bloodColor = "Team"
		nameColor = "Normal"
	else
		bloodColor = "NPC"
		nameColor = "NPC"
	end

	if self.nameColor ~= nameColor or self.bloodColor ~= bloodColor then
		self.nameColor = nameColor
		self.bloodColor = bloodColor

		self.rootUComponent:TryChangePage("NameChar", self.nameColor)

		local cbInfo = self.m_cbSubBloodCacheInfo[BLOOD_CB_FUNC.NAME_COLOR]

		cbInfo.cbData = bloodColor

		self:checkAndLoadBloodUrlAsync(cbInfo.cbFunc, BLOOD_CB_FUNC.NAME_COLOR)
	end
end

function TopLogoCombatComponent:setTeamState()
	local masterEnt = self.entity.getMasterEntity and self.entity:getMasterEntity()
	local order = -1

	if Utils.isBotPlayer(masterEnt) then
		order = 5
	else
		local ent = Utils.isPlayerPet(self.entity) and masterEnt or self.entity

		order = pg.me:getTeamOrder(ent.uid)
	end

	if self.order ~= order then
		self.order = order

		if order >= 1 and order <= 5 then
			self:safeSetActive(self.teamLocUWidget, true)
			self.rootUComponent:TryChangePage("Teammate", self.order - 1)
		else
			self:safeSetActive(self.teamLocUWidget, false)
		end
	end
end

function TopLogoCombatComponent:setControlPet()
	if not self:needShowControlPet() then
		return
	end

	local masterEnt = Utils.isPlayerPet(self.entity) and self.entity:getMasterEntity() or nil
	local isControlPet = masterEnt and masterEnt:isControllingPet() or false

	if self.isControlPet ~= isControlPet then
		self.isControlPet = isControlPet

		self:safeSetActiveFastest(self.controlUWidget, self.isControlPet)
	end
end

function TopLogoCombatComponent:setFriendShip()
	local showFriend = self:needShowFriendShip()

	if not showFriend then
		return
	end

	local isFriend = self._isPlayer and pg.game.chat:checkFriendList(self.entity.uid)

	if self.isFriend ~= isFriend then
		self.isFriend = isFriend

		self:safeSetActiveFastest(self.likabilityUWidget, isFriend)
	end

	if isFriend and showFriend then
		local level = pg.game.chat:getFriendship(self.entity.uid)

		if self.friendLevel ~= level then
			self.friendLevel = level

			local friendShipData = FriendshipLevelData[level] or {}

			self.iconLikabilityUImage.url = friendShipData.levelIcon
		end
	end
end

function TopLogoCombatComponent:refreshLevelAndThreatState(forceVisible, isDelayShowLevel)
	if not self:checkContainerLoaded() then
		return
	end

	if forceVisible then
		if isDelayShowLevel then
			if self.m_showLeveTxtTimer then
				TimerManager.removeTimer(self.m_showLeveTxtTimer)

				self.m_showLeveTxtTimer = nil
			end

			self.m_showLeveTxtTimer = TimerManager.addTimer(0.6, function()
				local level = self.entity and self.entity.level or 0

				ClientTextUtils.setText(self.levelUText, level)
				self:refreshTitleLvUWidgetActive(true)

				self.m_showLeveTxtTimer = nil
			end)
		else
			local mIsDelayShowLevel = true
			local level = self.entity.level

			ClientTextUtils.setText(self.levelUText, level)

			if self._isPuppet and Utils.isEnemy(pg.pawn, self.entity) then
				local threatState = LuaUIUtils.getThreatLevelState(level)

				self.rootUComponent:TryChangePage("Threat", threatState)

				if threatState == "dangerous" then
					self.rootUComponent:TryChangePage("BattleWarning", 1)
				elseif threatState == "veryDangerous" then
					self.rootUComponent:TryChangePage("BattleWarning", 2)
				else
					self.rootUComponent:TryChangePage("BattleWarning", 0)

					mIsDelayShowLevel = false
				end
			else
				self.rootUComponent:TryChangePage("BattleWarning", 0)

				mIsDelayShowLevel = false
			end

			if self.isDelayShowLevelTimer2 then
				TimerManager.removeTimer(self.isDelayShowLevelTimer2)

				self.isDelayShowLevelTimer2 = nil
			end

			if mIsDelayShowLevel then
				self.isDelayShowLevelTimer2 = TimerManager.addTimer(0.6, function()
					self:refreshTitleLvUWidgetActive(true)

					self.isDelayShowLevelTimer2 = nil
				end)
			else
				self:refreshTitleLvUWidgetActive(true)
			end
		end
	elseif self.lvTitleInSpace == LVTITLE_IN_SPACE.LEFT then
		self:refreshTitleLvUWidgetActive(false)
	end
end

function TopLogoCombatComponent:refreshName(force)
	local name = self.entity:getAttachEntityName()

	if self.entity and self._isPuppet and Utils.isEnemy(self.entity, pg.me) then
		local configData = self.entity:getConfigData() or {}

		if configData.banFirstEncounter then
			self:m_setNewLabelActive(false)

			name = pg.getLocalizationText(name)
		else
			local isNew = not self:checkPuppetHasCached()

			self:m_setNewLabelActive(isNew)

			name = ClientUtils.checkIsNewKnowPuppet(self.entity) and "???" or pg.getLocalizationText(name)
		end
	else
		self:m_setNewLabelActive(false)

		name = pg.getLocalizationText(name)
	end

	if pg.game.setting:getShowDebugText() and debugShowActorId then
		local actorIdSuffix = string.format("_%d", self.entity.actorId or 0)

		name = name .. actorIdSuffix
	end

	local _h = TopLogoCombatComponent._platformHooks

	if _h and _h.refreshName then
		name = _h.refreshName(self, force, name)
	end

	if string.isNilOrEmpty(name) then
		return
	end

	if not force and name == self.name then
		return
	end

	ClientTextUtils.setText(self.nameUText, name)
	ClientTextUtils.setText(self.nameVariant1UBaseText, name)
	ClientTextUtils.setText(self.nameVariant2UBaseText, name)

	self.name = name
end

function TopLogoCombatComponent:onLanguageChanged()
	if not self:checkContainerLoaded() then
		return
	end

	TopLogoCombatComponent.super.onLanguageChanged(self)
	self:refreshName(true)

	if not string.isNilOrEmpty(self.name) then
		if NotNil(self.nameUText) then
			self.nameUText.text = self.name
		end

		if NotNil(self.nameVariant1UBaseText) then
			self.nameVariant1UBaseText.text = self.name
		end

		if NotNil(self.nameVariant2UBaseText) then
			self.nameVariant2UBaseText.text = self.name
		end
	end

	self:refreshSubName()
end

function TopLogoCombatComponent:m_setNewLabelActive(isActive)
	self:safeSetActive(self.newLabelUImage, isActive)
end

function TopLogoCombatComponent:refreshSubName()
	self.subName = nil
	self.m_preSubName = nil

	local directSubName

	if self._isPlayer then
		directSubName = self:getEntityTitleText(self.entity)
	elseif Utils.isPlayerPet(self.entity) then
		local masterEnt = self.entity:getMasterEntity()

		if masterEnt then
			if self.entity.CONTROLLING_PET_ST and self.entity:CONTROLLING_PET_ST() then
				directSubName = self:getEntityTitleText(masterEnt)
			else
				self.subName = self:m_getMastEntName(masterEnt.playerName or "", self.entity)
			end
		end
	elseif self._isPuppet or self._isVirtualPuppet then
		local masterName = self.entity:getConfigData().masterName

		if masterName then
			self.subName = masterName
		elseif self.entity.getMasterName then
			self.subName = self.entity:getMasterName()
		end
	elseif self.entity and self.entity.getMasterName then
		self.subName = self.entity:getMasterName()
	end

	local displaySubName = directSubName and directSubName or self.subName and pg.getLocalizationText(self.subName) or nil
	local _h = TopLogoCombatComponent._platformHooks

	displaySubName = _h and _h.refreshSubName and _h.refreshSubName(self, displaySubName) or displaySubName

	if not string.isNilOrEmpty(displaySubName) then
		self.m_preSubName = displaySubName
	end

	self:m_refreshSubNameVisible()
end

function TopLogoCombatComponent:m_refreshSubNameVisible()
	local isShow = false

	if self.state == UIConst.HEALTH_STATE.NAME then
		isShow = self.forceShowSubName == true
	elseif self.state == UIConst.HEALTH_STATE.NAME_INFO then
		isShow = not self.forceHideSubName
	end

	self:refreshSubNameTextShow(isShow)
end

function TopLogoCombatComponent:m_getMastEntName(mastEntName, ent)
	local playerName = mastEntName or ""

	if pg.space and pg.space:isGrabEgg() and Utils.isEnemy(ent, pg.me) then
		playerName = pg.getGameString("GRAB_EGG_ENEMY_PLAYER")
	end

	return playerName
end

function TopLogoCombatComponent:refreshGender()
	if self._isPuppet and Utils.isEnemy(self.entity, pg.me) then
		if self.entity.gender == Const.GENDER_TYPE_MALE then
			self.rootUComponent:TryChangePage("Gender", "Male")
		elseif self.entity.gender == Const.GENDER_TYPE_FEMALE then
			self.rootUComponent:TryChangePage("Gender", "Female")
		else
			self.rootUComponent:TryChangePage("Gender", "Null")
		end
	else
		self.rootUComponent:TryChangePage("Gender", "Null")
	end
end

function TopLogoCombatComponent:refreshIcon()
	if Utils.isLabelBoss(self.entity.label) then
		self.rootUComponent:TryChangePage("Type", "Boss")
	elseif Utils.isLabelElite(self.entity.label) then
		self.rootUComponent:TryChangePage("Type", "Elite")
	else
		self.rootUComponent:TryChangePage("Type", "Level")
	end
end

function TopLogoCombatComponent:refreshVariant()
	if not self:checkContainerLoaded() then
		return
	end

	self:m_setNameActive(true)
end

function TopLogoCombatComponent:m_setNameActive(active)
	if not active then
		self:safeSetActive(self.nameUText, false)
		self:safeSetActive(self.nameVariant1UBaseText, false)
		self:safeSetActive(self.nameVariant2UBaseText, false)

		return
	end

	local variantPage

	if Utils.isPlayerPet(self.entity) then
		variantPage = Utils.isLabelVariant(self.entity.label) and 1 or 0
	else
		variantPage = not string.isNilOrEmpty(pg.game.chat.specialFriendUId) and pg.game.chat.specialFriendUId == self.entity.uid and 1 or 0
	end

	local _, currentPage = self.rootUComponent:TryGetCurrentPage("isChange")

	if currentPage ~= variantPage then
		self.rootUComponent:TryChangePage("isChange", variantPage)

		return
	end

	local isVariant = variantPage == 1

	self:safeSetActive(self.nameUText, not isVariant)
	self:safeSetActive(self.nameVariant1UBaseText, isVariant)
	self:safeSetActive(self.nameVariant2UBaseText, isVariant)
end

function TopLogoCombatComponent:checkPuppetHasCached()
	if not self.entity then
		return true
	end

	local playerHandBookMap = pg.me.petHandbookMap
	local configData = self.entity:getConfigData()
	local petHandbookInfo = playerHandBookMap[configData.petPrototypeId]

	return petHandbookInfo and petHandbookInfo:isCatched()
end

function TopLogoCombatComponent:m_clearTitleElementListForReuse()
	local listElementUList = self.listElementUList

	if IsNil(listElementUList) then
		self.listElementUList = nil
		self.m_titleElementListApplied = false
		self.m_titleElementListHasData = false
		self.m_titleElementListActive = false

		return false
	end

	listElementUList:SetList({})

	self.m_titleElementListApplied = false
	self.m_titleElementListHasData = false

	self:setElementListActive()

	return true
end

function TopLogoCombatComponent:onNewKnowChanged()
	if not self:checkContainerLoaded() then
		return
	end

	self:refreshName(true)
	self:refreshTitleElementList()
end

function TopLogoCombatComponent:refreshTitleElementList(elementList)
	local listElementUList = self.listElementUList

	if IsNil(listElementUList) then
		self.listElementUList = nil
		self.m_titleElementListHasData = false
		self.m_titleElementListActive = false

		return
	end

	if not elementList or not next(elementList) then
		elementList = LuaUIUtils.getTargetElementsInfos(self.entity and self.entity.elementTypes) or {}
	end

	local elementCount = countTitleElementList(elementList)

	if ClientUtils.checkIsNewKnowPuppet(self.entity) then
		if self.m_titleElementListApplied then
			self:m_clearTitleElementListForReuse()
		else
			self.m_titleElementListHasData = false

			self:setElementListActive()
		end

		return
	end

	if elementCount <= 0 then
		if self.m_titleElementListApplied then
			self:m_clearTitleElementListForReuse()
		else
			self.m_titleElementListHasData = false

			self:setElementListActive()
		end

		return
	end

	listElementUList:SetList(elementList)

	self.m_titleElementListApplied = true
	self.m_titleElementListHasData = true

	self:setElementListActive()
end

function TopLogoCombatComponent:refreshTitleLvUWidgetActive(isActive)
	if IsNil(self.levelUWidget) then
		return
	end

	local isSetActive = isActive == true

	self:safeSetActiveFastest(self.levelUWidget, isSetActive)
	self:setElementListActive()
end

function TopLogoCombatComponent:setElementListActive()
	local listElementUList = self.listElementUList

	if IsNil(listElementUList) then
		return false
	end

	if ClientUtils.checkIsNewKnowPuppet(self.entity) then
		self:safeSetActiveFastest(listElementUList, false)

		self.m_titleElementListActive = false

		return false
	end

	if not self.m_titleElementListHasData then
		self:safeSetActiveFastest(listElementUList, false)

		self.m_titleElementListActive = false

		return false
	end

	self:safeSetActiveFastest(listElementUList, true)

	self.m_titleElementListActive = true

	return true
end

function TopLogoCombatComponent:m_setBrokenContainerLoadedFunc()
	self.m_brokenContainerLoading = false
	self.m_brokenContainerReqId = 0
	self.m_curBrokenVxUrl = nil
	self.m_isBrokenVxActiveWanted = false
	self.m_brokenContainerLoadStartClock = nil
	self.delayHideBrokenVxTimer = nil
end

function TopLogoCombatComponent:m_getBrokenVxUrl()
	return BLOOD_BREAK_VX[self.isMiniBlood and BLOOD_TYPE.MINI or BLOOD_TYPE.NORMAL]
end

function TopLogoCombatComponent:m_clearBrokenVxTimer()
	if self.delayHideBrokenVxTimer then
		TimerManager.removeTimer(self.delayHideBrokenVxTimer)

		self.delayHideBrokenVxTimer = nil
	end
end

function TopLogoCombatComponent:m_checkAndLoadBrokenVxContainer()
	if not self.m_isBrokenVxActiveWanted then
		return
	end

	local vxUrl = self.m_curBrokenVxUrl or self:m_getBrokenVxUrl()

	if not vxUrl or vxUrl == "" then
		self:m_setBrokenVxActive(false)

		return
	end

	local vxContainer = self.vxBrokenUContainer

	if IsNil(vxContainer) then
		return
	end

	if self.m_brokenContainerLoading then
		return
	end

	local function isCurrentVxContainer()
		return self.vxBrokenUContainer == vxContainer and NotNil(vxContainer)
	end

	local function safeDestroyLoadedContent()
		if isCurrentVxContainer() and vxContainer:CheckURLLoaded(vxUrl) then
			vxContainer:DestroyContent()
		end
	end

	self.m_curBrokenVxUrl = vxUrl

	local isLoaded = vxContainer:CheckURLLoaded(vxUrl)

	if isLoaded then
		self.m_brokenContainerLoading = false

		if isCurrentVxContainer() then
			self:safeSetActiveFastest(vxContainer, true)
		end

		return
	end

	self.m_brokenContainerLoading = true
	self.m_brokenContainerLoadStartClock = os.clock()
	self.m_brokenContainerReqId = (self.m_brokenContainerReqId or 0) + 1

	local curReqId = self.m_brokenContainerReqId

	self:safeSetActiveFastest(vxContainer, true)
	vxContainer:SetUrlWithCallback(vxUrl, function(content)
		if self.m_brokenContainerReqId ~= curReqId then
			safeDestroyLoadedContent()

			return
		end

		if not isCurrentVxContainer() then
			self.m_brokenContainerLoading = false
			self.m_brokenContainerLoadStartClock = nil

			return
		end

		self.m_brokenContainerLoading = false
		self.m_brokenContainerLoadStartClock = nil

		if not self.m_isBrokenVxActiveWanted then
			safeDestroyLoadedContent()

			return
		end

		if NotNil(content) and isCurrentVxContainer() then
			self:safeSetActiveFastest(vxContainer, true)
		end
	end)
end

function TopLogoCombatComponent:m_destroyBrokenVxContainer()
	self.m_brokenContainerReqId = (self.m_brokenContainerReqId or 0) + 1
	self.m_brokenContainerLoading = false
	self.m_brokenContainerLoadStartClock = nil
	self.m_curBrokenVxUrl = nil

	if NotNil(self.vxBrokenUContainer) then
		self.vxBrokenUContainer:DestroyContent()
	end
end

function TopLogoCombatComponent:m_setBrokenVxActive(active)
	local vxUWidget = self.vxBrokenUWidget

	if NotNil(vxUWidget) then
		self:safeSetActiveFastest(vxUWidget, active)
	end

	self.m_isBrokenVxActiveWanted = active == true

	if self.m_isBrokenVxActiveWanted then
		self:m_clearBrokenVxTimer()
		self:m_checkAndLoadBrokenVxContainer()

		self.delayHideBrokenVxTimer = TimerManager.addTimer(BROKEN_VX_DURATION, function()
			self.delayHideBrokenVxTimer = nil

			if self.m_brokenContainerLoading then
				local loadingCost = 0

				if self.m_brokenContainerLoadStartClock then
					loadingCost = os.clock() - self.m_brokenContainerLoadStartClock
				end
			end

			self:m_setBrokenVxActive(false)
		end)
	else
		self:m_clearBrokenVxTimer()
		self:m_destroyBrokenVxContainer()
	end
end

function TopLogoCombatComponent:m_switchBrokenVx()
	local vxUrl = self:m_getBrokenVxUrl()

	if vxUrl == self.m_curBrokenVxUrl then
		return
	end

	self.m_curBrokenVxUrl = vxUrl

	self:m_setBrokenVxActive(false)
end

function TopLogoCombatComponent:onBloodContainerLoaded()
	self.bloodContainerLoaded = true

	self:refreshBloodContainerUI()
	self:updateHealthBar()
end

function TopLogoCombatComponent:onBloodMiniContainerLoaded()
	self:onBloodContainerLoaded()
end

function TopLogoCombatComponent:switchBloodContainerState()
	if not self.bloodContainer or not self.bloodContainer.content then
		return
	end

	local bloodUIType = self.isMiniBlood and BLOOD_TYPE.MINI or BLOOD_TYPE.NORMAL

	self.bloodContainer.content:TryChangePage("BloodType", bloodUIType)

	for type, layout in pairs(BLOOD_TYPE_LAYOUTS_OFFSET) do
		if type == bloodUIType then
			for widgetName, offset in pairs(layout) do
				if self[widgetName] and self[widgetName].transform then
					local initPos = self[widgetName .. "InitLocalPos"] or Vector3.New(0, 0, 0)

					self[widgetName].transform.localPosition = Vector3.New(initPos.x + offset[1], initPos.y + offset[2], 0)
				end
			end
		end
	end

	self:m_switchBrokenVx()
end

function TopLogoCombatComponent:refreshBloodContainerUI()
	local bloodContainer = self.bloodContainer

	if not bloodContainer.content then
		return
	end

	local objectReference = bloodContainer.content:GetComponent("ObjectReference")

	self.bloodUComponent = bloodContainer.content:GetComponent("UComponent")

	if self.bloodColor then
		self.bloodUComponent:TryChangePage("NameChar", self.bloodColor)
	end

	self.barHPUHealthbar = objectReference:GetRefValue("barHPUHealthbar")
	self.barShieldUHealthbar = objectReference:GetRefValue("barShieldUHealthbar")
	self.barBreakUHealthbar = objectReference:GetRefValue("barBreakUHealthbar")
	self.barBreakCountdown = objectReference:GetRefValue("barBreakCountdown")
	self.waringPaopaoUImage = objectReference:GetRefValue("waringPaopaoUImage")
	self.shieldBlastUParticle = objectReference:GetRefValue("shieldBlastUParticle")
	self.breakingCountDownUCountDown = objectReference:GetRefValue("breakingCountDownUCountDown")
	self.vxCountdownAnimation = objectReference:GetRefValue("vxCountdownAnimation")
	self.breakCountDownBarBreak = objectReference:GetRefValue("breakCountDownBarBreak")
	self.imgHandleUWidget = objectReference:GetRefValue("imgHandleUWidget")
	self.vxLineUWidget = objectReference:GetRefValue("vxLineUWidget")
	self.uIComBloodNewTinyAnimation = objectReference:GetRefValue("uIComBloodNewTinyAnimation")
	self.imgBgStateUWidget = objectReference:GetRefValue("imgBgStateUWidget")
	self.vxBrokenUWidget = objectReference:GetRefValue("vxBrokenUWidget")
	self.vxBrokenUContainer = objectReference:GetRefValue("vxBrokenUContainer")

	self:m_checkAndLoadBrokenVxContainer()

	if self:checkBloodVisibleAndMarkDirty(EventConst.TOPLOGO_HEALTH_POINT) then
		local info = Utils.getEntityHealthInfo(self.entity)

		self:realRefreshHealthPoint(info)
	end

	self.onPetShieldMsg()
	self.onShieldMsg()
	self.onBreakPointMsg(0)
	self:refreshEcsAmount(self.entity)
	self:m_resetShieldBarUI()
end

function TopLogoCombatComponent:checkBreakBarReady()
	if not self:checkContainerLoaded() or self.bloodContainerLoaded ~= true then
		return false
	end

	if IsNil(self.rootUComponent) or IsNil(self.bloodContainer) or IsNil(self.bloodContainer.content) then
		return false
	end

	if IsNil(self.bloodUComponent) or IsNil(self.barBreakUHealthbar) then
		return false
	end

	if IsNil(self.uIComBloodNewTinyAnimation) then
		return false
	end

	if IsNil(self.breakingCountDownUCountDown) or IsNil(self.vxCountdownAnimation) or IsNil(self.breakCountDownBarBreak) then
		return false
	end

	return true
end

function TopLogoCombatComponent:m_logBreakBarNotReady()
	if self.m_breakBarNotReadyLogged then
		return
	end

	self.m_breakBarNotReadyLogged = true

	if not LoggerManager.checkLogger(LoggerConst.ERROR) then
		return
	end

	local missingRefs = {}

	local function addMissing(name, value)
		if IsNil(value) then
			table.insert(missingRefs, name)
		end
	end

	addMissing("rootUComponent", self.rootUComponent)
	addMissing("bloodContainer", self.bloodContainer)

	if NotNil(self.bloodContainer) then
		addMissing("bloodContainer.content", self.bloodContainer.content)
	end

	addMissing("bloodUComponent", self.bloodUComponent)
	addMissing("barBreakUHealthbar", self.barBreakUHealthbar)
	addMissing("uIComBloodNewTinyAnimation", self.uIComBloodNewTinyAnimation)
	addMissing("breakingCountDownUCountDown", self.breakingCountDownUCountDown)
	addMissing("vxCountdownAnimation", self.vxCountdownAnimation)
	addMissing("breakCountDownBarBreak", self.breakCountDownBarBreak)
	logger:error("TopLogoCombatComponent:m_refreshBreakBar() break refs not ready, actorId=%s, containerLoaded=%s, bloodContainerLoaded=%s, missingRefs=%s", self.entity and self.entity.actorId or "nil", tostring(self:checkContainerLoaded()), tostring(self.bloodContainerLoaded), table.concat(missingRefs, ","))
end

function TopLogoCombatComponent:m_deferRefreshBreakBar(info, deltaBp, isIgnoreHpLock)
	self:markDirty(EventConst.TOPLOGO_BREAK_POINT)

	local cbInfo = self.m_cbSubBloodCacheInfo and self.m_cbSubBloodCacheInfo[BLOOD_CB_FUNC.REFRESH_BREAK_BAR]

	if not cbInfo then
		return
	end

	cbInfo.cbData = cbInfo.cbData or {}
	cbInfo.cbData.info = info
	cbInfo.cbData.deltaBp = deltaBp
	cbInfo.cbData.isIgnoreHpLock = isIgnoreHpLock

	if not self:checkFinalVisible() or not self:checkBloodVisible() then
		return
	end

	if self:checkContainerLoaded() and self.bloodContainerLoaded == true then
		self:m_logBreakBarNotReady()

		return
	end

	self:checkAndLoadBloodUrlAsync(cbInfo.cbFunc, BLOOD_CB_FUNC.REFRESH_BREAK_BAR)
end

function TopLogoCombatComponent:initCombatInfo()
	if not self.entity or not self.entity.actorCombatAttribute then
		return
	end

	self:markDirty(EventConst.ON_BUFF_CHANGE)
	self:markDirty(EventConst.TOPLOGO_BREAK_POINT)
	self:markDirty(EventConst.TOPLOGO_HEALTH_POINT)
	self:markDirty(EventConst.TOPLOGO_SHIELD_POINT)
end

function TopLogoCombatComponent:refreshFreezeHp(isFreezeHp)
	local cbInfo = self.m_cbSubBloodCacheInfo[BLOOD_CB_FUNC.FREEZE_HP]

	cbInfo.cbData = isFreezeHp

	self:checkAndLoadBloodUrlAsync(cbInfo.cbFunc, BLOOD_CB_FUNC.FREEZE_HP)
end

function TopLogoCombatComponent:freezeHpHit()
	self:checkAndLoadBloodUrlAsync(self.m_cbSubBloodCacheInfo[BLOOD_CB_FUNC.FREEZE_HP_HIT].cbFunc, BLOOD_CB_FUNC.FREEZE_HP_HIT)
end

function TopLogoCombatComponent:freezeHpOutTimer(value, alpha)
	local cbInfo = self.m_cbSubBloodCacheInfo[BLOOD_CB_FUNC.FREEZE_HP_OUT]

	cbInfo.cbData = cbInfo.cbData or {}
	cbInfo.cbData.value = value
	cbInfo.cbData.alpha = alpha

	self:checkAndLoadBloodUrlAsync(cbInfo.cbFunc, BLOOD_CB_FUNC.FREEZE_HP_OUT)
end

function TopLogoCombatComponent:getWaringPaoPaoOpacity()
	return
end

function TopLogoCombatComponent:refreshHealthPoint(info)
	local cbInfo = self.m_cbSubBloodCacheInfo[BLOOD_CB_FUNC.HEALTH_POINT]

	cbInfo.cbData = info

	self:checkAndLoadBloodUrlAsync(cbInfo.cbFunc, BLOOD_CB_FUNC.HEALTH_POINT)
end

function TopLogoCombatComponent:realRefreshHealthPoint(info)
	self.barHPUHealthbar.maxHp = info.maxHp

	self.barHPUHealthbar:ProgressHp(info.curHp or 0)

	if self.vxLineUWidget then
		if self.breakState then
			self:safeSetActiveFastest(self.vxLineUWidget, true)

			if self.delayHideVxLineTimer then
				TimerManager.removeTimer(self.delayHideVxLineTimer)

				self.delayHideVxLineTimer = nil
			end

			self.delayHideVxLineTimer = TimerManager.addTimer(0.15, function()
				self:safeSetActiveFastest(self.vxLineUWidget, false)
			end)
		else
			self:safeSetActiveFastest(self.vxLineUWidget, false)
		end
	end
end

function TopLogoCombatComponent:refreshShieldPoint(entity)
	if self.bloodContainerLoaded and self.barShieldUHealthbar then
		LuaUIUtils.setShieldBar(entity, nil, self.barShieldUHealthbar)

		return
	end

	local cbInfo = self.m_cbSubBloodCacheInfo[BLOOD_CB_FUNC.SHIELD_POINT]

	cbInfo.cbData = entity

	self:checkAndLoadBloodUrlAsync(cbInfo.cbFunc, BLOOD_CB_FUNC.SHIELD_POINT)
end

function TopLogoCombatComponent:onShieldBreak()
	if self.bloodContainerLoaded == true and NotNil(self.barShieldUHealthbar) then
		self:m_onShieldBreak(false)

		return
	end

	local cbInfo = self.m_cbSubBloodCacheInfo and self.m_cbSubBloodCacheInfo[BLOOD_CB_FUNC.SHIELD_BREAK]

	if not cbInfo then
		return
	end

	cbInfo.cbData = nil

	self:checkAndLoadBloodUrlAsync(cbInfo.cbFunc, BLOOD_CB_FUNC.SHIELD_BREAK)
end

function TopLogoCombatComponent:m_onShieldBreak(isAsync)
	if self.bloodContainerLoaded ~= true then
		return
	end

	if IsNil(self.barShieldUHealthbar) then
		return
	end

	if self:checkParentVisible() and NotNil(self.shieldBlastUParticle) then
		self.shieldBlastUParticle:Play()
	end

	self.barShieldUHealthbar:InvokeCallback(CS.XGUI.EInvokeTime.Custom6)

	if self.delayHideShieldTimer then
		TimerManager.removeTimer(self.delayHideShieldTimer)

		self.delayHideShieldTimer = nil
	end

	self.delayHideShieldTimer = TimerManager.addTimer(1, function()
		if IsNil(self.barShieldUHealthbar) then
			return
		end

		self.barShieldUHealthbar:SetActive(false)
	end)
end

function TopLogoCombatComponent:m_resetShieldBarUI()
	self.m_shieldBarResetedMap = self.m_shieldBarResetedMap or {
		false,
		false
	}

	local checkIndex = self.isMiniBlood and 2 or 1

	if not self.m_shieldBarResetedMap[checkIndex] then
		self.barShieldUHealthbar:SetActive(false)

		self.m_shieldBarResetedMap[checkIndex] = true
	end
end

function TopLogoCombatComponent:refreshBreakBar(info, deltaBp, isIgnoreHpLock)
	if self:checkBreakBarReady() then
		self.m_isFirstRefreshBreakBar = true

		self:m_refreshBreakBar(true, info, deltaBp, isIgnoreHpLock)
	else
		self:m_deferRefreshBreakBar(info, deltaBp, isIgnoreHpLock)
	end
end

function TopLogoCombatComponent:m_refreshBreakBar(isAsync, info, deltaBp, isIgnoreHpLock)
	if not self:checkBreakBarReady() then
		self:m_deferRefreshBreakBar(info, deltaBp, isIgnoreHpLock)

		return
	end

	if not info and self.entity then
		info = Utils.getEntityBreakInfo(self.entity)
	end

	if not info then
		self:markDirty(EventConst.TOPLOGO_BREAK_POINT)

		return
	end

	self:checkAndResetDirty(EventConst.TOPLOGO_BREAK_POINT)

	self.isPreInBreak = self.isPreInBreak or false
	self.isCurInBreak = info and info.inBreakStatus

	if self.isCurInBreak then
		self.uIComBloodNewTinyAnimation:Stop()
		self:safeSetActiveFastest(self.imgBgStateUWidget, true)
		self.bloodUComponent:TryChangePage("Break", 1)

		if self.m_isFirstRefreshBreakBar then
			TimerManager.addTimer(0.1, function()
				self:safeSetActiveFastest(self.imgBgStateUWidget, false)
			end)
		end

		self:safeSetActiveFastest(self.imgHandleUWidget, false)

		if not self.isPreInBreak then
			if self.entity and not isIgnoreHpLock then
				self:setBarHpFxLockInfo(true, self:getBarHpFxLockInfoFillVal(self.entity))
			end

			self:m_setBrokenVxActive(true)
		end

		if info.breakBuffFreezeTime ~= 0 then
			self:safeSetActiveFastest(self.breakingCountDownUCountDown, true)
			self.breakingCountDownUCountDown:Play(math.min(info.breakEndTime - info.breakBuffFreezeTime))
			self.breakingCountDownUCountDown:Stop()

			self.breakState = UIConst.BLOOD_BREAK_STATE.STATE_BREAK
			self.breakCountDownBarBreak.hp = 0
		else
			self:setBp(0, 0, info.maxBp)

			local now = pg.me:getGameTime()

			if ToBool(info.breakRecoverEndTime) then
				self:safeSetActiveFastest(self.breakingCountDownUCountDown, false)

				if self.breakState ~= UIConst.BLOOD_BREAK_STATE.STATE_BREAK_RECOVER then
					self.vxCountdownAnimation:Play("VX_Node_HUD_HP_BOSS_Break_Loop_Disappear")
				end

				self.breakState = UIConst.BLOOD_BREAK_STATE.STATE_BREAK_RECOVER

				local startTime = info.breakRecoverEndTime - info.breakRecoverTime
				local diffTime = now - startTime

				if diffTime <= 0 then
					local curVale = math.max(0.01, diffTime)

					self:setBp(0, 0, info.breakRecoverTime)

					if NotNil(self.barBreakCountdown) then
						if info.breakRecoverFreezeTime == 0 then
							self.barBreakCountdown:Play(curVale, math.max(info.breakRecoverTime, 0.01))
						else
							self.barBreakCountdown:Play(math.max(info.breakRecoverEndTime - info.breakRecoverFreezeTime, 0.01), math.max(info.breakRecoverTime, 0.01))
							self.breakingCountDownUCountDown:Stop()
						end
					end
				end
			else
				self:safeSetActiveFastest(self.breakingCountDownUCountDown, true)

				if self.breakState ~= UIConst.BLOOD_BREAK_STATE.STATE_BREAK then
					self.vxCountdownAnimation:Play("VX_Node_HUD_HP_BOSS_Break_Loop")
				end

				self:setBp(0, 0, info.breakTime)
				self.breakingCountDownUCountDown:Play(math.min(info.breakTime, info.breakEndTime - now))

				self.breakState = UIConst.BLOOD_BREAK_STATE.STATE_BREAK
				self.breakCountDownBarBreak.hp = 0
			end
		end
	else
		if self.breakState then
			self.breakState = nil

			self.vxCountdownAnimation:Play("VX_Node_HUD_HP_BOSS_Break_Recover")
			self.bloodUComponent:InvokeCallback(CS.XGUI.EInvokeTime.Custom2)

			self.barBreakUHealthbar.hp = 1

			self:safeSetActiveFastest(self.imgHandleUWidget, true)

			if self.delayChangeBreakTimer then
				TimerManager.removeTimer(self.delayChangeBreakTimer)

				self.delayChangeBreakTimer = nil
			end

			self.delayChangeBreakTimer = TimerManager.addTimer(1, function()
				self.delayChangeBreakTimer = nil

				if NotNil(self.barBreakCountdown) then
					self.barBreakCountdown:Stop()
				end

				if NotNil(self.vxCountdownAnimation) and self:tryRevertBreak(isIgnoreHpLock, self.entity) then
					self:setBp(info.maxBp - info.curBp, deltaBp, info.maxBp)

					self.breakState = nil
				end
			end)

			return
		end

		if NotNil(self.barBreakCountdown) then
			self.barBreakCountdown:Stop()
		end

		if self:tryRevertBreak(isIgnoreHpLock, self.entity) then
			self:setBp(info.maxBp - info.curBp, deltaBp, info.maxBp)

			self.breakState = nil
		end
	end

	self.isPreInBreak = self.isCurInBreak

	local barBreakPageIndex = getBreakBarPageIndex(self)

	self.rootUComponent:TryChangePage("barBreakUHealthbar", barBreakPageIndex)
	self.bloodUComponent:TryChangePage("NoBreakBar", barBreakPageIndex)

	self.m_isFirstRefreshBreakBar = false
end

function TopLogoCombatComponent:tryRevertBreak(isIgnoreHpLock, entity)
	if not self:checkBreakBarReady() then
		self:m_deferRefreshBreakBar(Utils.getEntityBreakInfo(entity), nil, isIgnoreHpLock)

		return false
	end

	self:safeSetActiveFastest(self.imgBgStateUWidget, true)
	self.uIComBloodNewTinyAnimation:Stop()
	self.bloodUComponent:TryChangePage("Break", 0)
	self:safeSetActiveFastest(self.imgHandleUWidget, true)

	if not isIgnoreHpLock then
		self:setBarHpFxLockInfo(false, self:getBarHpFxLockInfoFillVal(entity), function()
			self.onBreakPointMsg(0, true)
		end)
	end

	return true
end

function TopLogoCombatComponent:getBarHpFxLockInfoFillVal(entity)
	local entHpInfo = Utils.getEntityHealthInfo(entity)
	local curHp = entHpInfo and entHpInfo.curHp or 0
	local maxHp = entHpInfo and entHpInfo.maxHp or 0

	return math.clamp(curHp / (maxHp - 0.01), 0, 1)
end

function TopLogoCombatComponent:setBarHpFxLockInfo(isLock, fxFillVal, callback, isSwitch)
	local bloodContainer = self.bloodContainer

	if not bloodContainer.content then
		return
	end

	local objectReference = bloodContainer.content:GetComponent("ObjectReference")
	local barHp = objectReference and objectReference:GetRefValue("barHPUHealthbar")

	if barHp and self:checkBloodVisibleAndMarkDirty(EventConst.TOPLOGO_HEALTH_POINT) then
		barHp:SetFxLockInfo(isLock, fxFillVal, UNLOCK_FX_DURATION, Const.DoTweenEaseType.InExpo, nil, callback)
	end
end

function TopLogoCombatComponent:setBp(curValue, deltaValue, maxValue)
	deltaValue = deltaValue or 0
	self.barBreakUHealthbar.maxHp = 1

	if maxValue == 0 then
		maxValue = maxValue + 0.01
	end

	self.barBreakUHealthbar:ProgressHp(curValue / maxValue)
	self:refreshBreakState(curValue, maxValue)
	self:refreshBreakShake(deltaValue, maxValue)
end

function TopLogoCombatComponent:refreshBreakState(curValue, maxValue)
	local config = SysConfigData.BREAK_STATE_CUTOFF
	local cutoffLower = config[1] < config[2] and config[1] or config[2]
	local cutoffUpper = config[1] < config[2] and config[2] or config[1]
	local percent = curValue / maxValue

	if percent >= 0 and percent < cutoffLower then
		self.rootUComponent:TryChangePage("BreakState", "Low")
	elseif cutoffLower <= percent and percent < cutoffUpper then
		self.rootUComponent:TryChangePage("BreakState", "Middle")
	else
		self.rootUComponent:TryChangePage("BreakState", "High")
	end
end

function TopLogoCombatComponent:refreshBreakShake(deltaValue, maxValue)
	local config = SysConfigData.BREAK_VIBRATION_CUTOFF
	local cutoffLower = config[1] < config[2] and config[1] or config[2]
	local cutoffUpper = config[1] < config[2] and config[2] or config[1]

	deltaValue = deltaValue or 0

	local percent = deltaValue / maxValue

	if cutoffLower <= percent and percent < cutoffUpper then
		self.bloodUComponent:InvokeCallback(CS.XGUI.EInvokeTime.User1)
	elseif cutoffUpper <= percent then
		self.bloodUComponent:InvokeCallback(CS.XGUI.EInvokeTime.User2)
	end
end

function TopLogoCombatComponent:checkAndLoadBloodUrlAsync(callback, callbackGroup)
	self.m_cbSubBloodCallbacks = self.m_cbSubBloodCallbacks or {}
	self.m_cbSubBloodCallbacks[callbackGroup] = callback

	local cbCacheInfo = self.m_cbCacheCombatInfo and self.m_cbCacheCombatInfo[TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC3]

	if cbCacheInfo and not cbCacheInfo.cbFunc then
		function cbCacheInfo.cbFunc(isSuccess)
			if isSuccess then
				self:loadBloodSubContainerAsync()
			else
				for cbGroup, cbFunc in pairs(self.m_cbSubBloodCallbacks or EMPTY_TABLE) do
					if cbFunc then
						local cbData = self.m_cbSubBloodCacheInfo and self.m_cbSubBloodCacheInfo[cbGroup] and self.m_cbSubBloodCacheInfo[cbGroup].cbData

						cbFunc(false, cbData)

						self.m_cbSubBloodCallbacks[cbGroup] = nil
					end
				end

				self.m_cbSubBloodCallbacks = nil
			end
		end
	end

	self:checkAndLoadUContainerUrlSupportAsync(cbCacheInfo.cbFunc, TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC3)
end

function TopLogoCombatComponent:loadBloodSubContainerAsync()
	local container = self.bloodContainer
	local loadedFlag = self.bloodContainerLoaded

	if loadedFlag then
		for callbackGroup, callbackFunc in pairs(self.m_cbSubBloodCallbacks or EMPTY_TABLE) do
			if callbackFunc then
				local cbData = self.m_cbSubBloodCacheInfo and self.m_cbSubBloodCacheInfo[callbackGroup] and self.m_cbSubBloodCacheInfo[callbackGroup].cbData

				callbackFunc(true, cbData)

				self.m_cbSubBloodCallbacks[callbackGroup] = nil
			end
		end

		return
	end

	if container:CheckURLLoaded() then
		self:onBloodContainerLoaded()

		for callbackGroup, callbackFunc in pairs(self.m_cbSubBloodCallbacks or EMPTY_TABLE) do
			if callbackFunc then
				local cbData = self.m_cbSubBloodCacheInfo and self.m_cbSubBloodCacheInfo[callbackGroup] and self.m_cbSubBloodCacheInfo[callbackGroup].cbData

				callbackFunc(true, cbData)

				self.m_cbSubBloodCallbacks[callbackGroup] = nil
			end
		end

		return
	end

	if self.m_bloodSubContainerLoading then
		return
	end

	self.m_bloodSubContainerLoading = true

	container:LoadDefaultUrlManually(function(content)
		self.m_bloodSubContainerLoading = false

		local success = content ~= nil

		if success then
			self:onBloodContainerLoaded()
		end

		for _, cbFuncGroup in pairs(BLOOD_CB_FUNC) do
			if self.m_cbSubBloodCallbacks and self.m_cbSubBloodCallbacks[cbFuncGroup] then
				local cbData = self.m_cbSubBloodCacheInfo and self.m_cbSubBloodCacheInfo[cbFuncGroup] and self.m_cbSubBloodCacheInfo[cbFuncGroup].cbData

				self.m_cbSubBloodCallbacks[cbFuncGroup](success, cbData)

				self.m_cbSubBloodCallbacks[cbFuncGroup] = nil
			end
		end
	end)
end

function TopLogoCombatComponent:checkTopLogoCompUpdate()
	if self.topLogoItem.distance > SysConfigData.PUPPET_HEALTH_DISTANCE then
		return false
	end

	return TopLogoCombatComponent.super.checkTopLogoCompUpdate(self)
end

function TopLogoCombatComponent:onTopLogoCompUpdate()
	if self.entity and self.entity.actorCombatAttribute then
		if self.entity.isTrapped or self.entity.isBeAttached then
			self:setCombatInfoState(UIConst.HEALTH_STATE.NONE)

			return
		end

		if self.entity.topLogoData.onlyShowAfterHit and not self.entity.topLogoData.isHitTriggered then
			self:setCombatInfoState(UIConst.HEALTH_STATE.NONE)

			return
		end

		local component = pg.global.ui.tips:getBossTitleItem()

		if component and component:checkIsShowBossTitle(self.entity.actorId) then
			self:setCombatInfoState(UIConst.HEALTH_STATE.NONE)

			return
		end

		local state = self:getCombatInfoState()

		if self:shouldRefreshSubNameOnUpdate(state) then
			if not self.preRefreshSubNameTime or Time.realSecondCache - self.preRefreshSubNameTime >= 1 then
				self.preRefreshSubNameTime = Time.realSecondCache

				self:refreshSubName()
			end
		else
			self.preRefreshSubNameTime = nil
		end

		self:setCombatInfoState(state)

		if state == UIConst.HEALTH_STATE.NAME and self.forceShowSubName ~= self.m_preForceShowSubName then
			self:m_reapplyPlayerTitleVisible()
		end

		self.m_preForceShowSubName = self.forceShowSubName
	end
end

function TopLogoCombatComponent:shouldRefreshSubNameOnUpdate(state)
	return state == UIConst.HEALTH_STATE.NAME_INFO or state == UIConst.HEALTH_STATE.NAME and self.forceShowSubName
end

function TopLogoCombatComponent:refreshTitleSubNameState()
	if not self.entity or not self.entity.actorCombatAttribute then
		return
	end

	if not self._isPlayer and not Utils.isPlayerPet(self.entity) then
		return
	end

	local state = self:getCombatInfoState()

	self:setCombatInfoState(state)
	self:markDirty("updateHealthBar")
	self:refreshTopLogoInfo()
end

function TopLogoCombatComponent:isMultiPlayer(entity)
	entity = entity or self._isPet and self.entity:getMasterEntity() or self.entity

	if not entity then
		return false
	end

	local isTeamMember = pg.me:isUidTeamMember(entity.uid)

	if isTeamMember then
		return true
	end

	if Utils.isBotPlayer(entity) then
		return true
	end

	if not entity.space then
		return false
	end

	local spaceType = Utils.getSpaceType(entity.space.sceneId)

	if Utils.isSpaceTown(spaceType) then
		return true
	end

	return entity.space:isGrabEgg()
end

function TopLogoCombatComponent:isFriendlyPetOrControllingPet()
	local masterEnt = self.entity.getMasterEntity and self.entity:getMasterEntity()

	if not Utils.isPlayerPet(self.entity) and not Utils.isBotPet(self.entity) then
		return false
	end

	if not masterEnt then
		return false
	end

	if Utils.isEnemy(pg.pawn, masterEnt) then
		return false
	end

	if Utils.isMainPlayer(masterEnt) then
		return false
	end

	return true
end

function TopLogoCombatComponent:isMainPlayerFollowPet()
	local masterEnt = Utils.isPlayerPet(self.entity) and self.entity:getMasterEntity() or nil
	local isControlPet = masterEnt and masterEnt:isControllingPet() or false

	if self._isPet and Utils.isMainPlayer(masterEnt) and not isControlPet then
		return true
	end

	return false
end

function TopLogoCombatComponent:shouldApplySimplifiedForFriendlyPet()
	if not self:checkNeedBloodSubContainerForState() then
		return false
	end

	if self.entity == nil then
		return
	end

	local inCombat = self.entity.isInCombat and self.entity:isInCombat() or TopLogoPvp2Helper.isPvp2FriendlyTarget(self.entity)

	if not inCombat then
		return false
	end

	if not self:isFriendlyPetOrControllingPet() and not self:isMainPlayerFollowPet() and not self:isFriendCreation() then
		return false
	end

	return self.combatInfoMode == COMBAT_INFO_MODE.SIMPLIFIED
end

function TopLogoCombatComponent:hideNpcDuelBotPetBloodState(state)
	if not pg.space or not pg.space.isNpcDuel or not pg.space:isNpcDuel() then
		return state
	end

	return UIConst.HEALTH_STATE.NONE
end

function TopLogoCombatComponent:applyPvp2EnemyCombatInfoState(state)
	if not TopLogoPvp2Helper.isPvp2EnemyTarget(self.entity) then
		return state
	end

	if not TopLogoPvp2Helper.canShowPvp2EnemyTarget(self.entity) then
		return UIConst.HEALTH_STATE.NONE
	end

	if state == UIConst.HEALTH_STATE.NAME_INFO then
		return UIConst.HEALTH_STATE.NAME_BLOOD
	end

	if state ~= UIConst.HEALTH_STATE.NONE then
		return state
	end

	return UIConst.HEALTH_STATE.NAME_BLOOD
end

function TopLogoCombatComponent:getCombatInfoState()
	self.forceShowSubName = false
	self.forceHideSubName = false
	self.forceHideTitleAddon = false

	if self.forceNameOnly then
		return UIConst.HEALTH_STATE.NAME
	end

	if self._isPet then
		local state

		if Utils.isEnemy(pg.pawn, self.entity) then
			state = UIConst.HEALTH_STATE.NAME_BLOOD
		else
			local inCombat = self.entity.isInCombat and self.entity:isInCombat()
			local masterEnt = self.entity:getMasterEntity()

			if not masterEnt then
				return UIConst.HEALTH_STATE.NONE
			end

			if self:isMultiPlayer(masterEnt) then
				if inCombat then
					if Utils.isMainPlayer(masterEnt) and masterEnt:isControllingPet() then
						state = UIConst.HEALTH_STATE.TEAM_ONLY
					else
						state = UIConst.HEALTH_STATE.NAME_BLOOD
					end
				elseif masterEnt:isControllingPet() then
					if self.entity.CONTROLLING_PET_ST and self.entity:CONTROLLING_PET_ST() then
						self.forceShowSubName = self:getEntityTitleText(masterEnt) ~= nil and self:m_checkPlayerTitleVisibleByDist(masterEnt)
					end

					state = UIConst.HEALTH_STATE.NAME
				else
					self.forceHideSubName = inCombat
					self.forceHideTitleAddon = not inCombat
					state = UIConst.HEALTH_STATE.NAME_INFO
				end
			else
				local isFullHp = self.entity.actorCombatAttribute:getHp() >= self.entity.actorCombatAttribute:getMaxHp()
				local isFullBp = self.entity.actorCombatAttribute:getBp() == 0

				state = pg.me.uid == masterEnt.uid and inCombat and (not isFullHp or not isFullBp) and not pg.me:isControllingPet() and UIConst.HEALTH_STATE.NAME_BLOOD or UIConst.HEALTH_STATE.NONE
			end
		end

		if TopLogoPvp2Helper.isPvp2EnemyTarget(self.entity) then
			return self:applyPvp2EnemyCombatInfoState(state)
		end

		if TopLogoPvp2Helper.isPvp2FriendlyTarget(self.entity) then
			local masterEnt = self.entity.getMasterEntity and self.entity:getMasterEntity()

			if masterEnt and (masterEnt.FALLEN_ST and masterEnt:FALLEN_ST() or masterEnt.isDead and masterEnt:isDead()) then
				return UIConst.HEALTH_STATE.NAME
			end

			if self.entity == pg.pawn then
				return state
			end

			return UIConst.HEALTH_STATE.NAME_BLOOD
		end

		return self:hideNpcDuelBotPetBloodState(state)
	elseif self._isPlayer then
		if self:isMultiPlayer(self.entity) then
			local inCombat = self.entity.isInCombat and self.entity:isInCombat()

			if inCombat then
				return UIConst.HEALTH_STATE.TEAM_ONLY
			end

			self.forceShowSubName = self:getEntityTitleText(self.entity) ~= nil and self:m_checkPlayerTitleVisibleByDist(self.entity)

			return UIConst.HEALTH_STATE.NAME
		end

		return UIConst.HEALTH_STATE.NONE
	elseif self._isPuppet then
		if Utils.isEnemy(pg.pawn, self.entity) then
			local isFullHp = self.entity.actorCombatAttribute:getHp() >= self.entity.actorCombatAttribute:getMaxHp()
			local isFullBp = self.entity.actorCombatAttribute:getBp() == 0
			local isLocked = pg.me.lockedActorId == self.entity.actorId
			local isAimed = pg.me.catchAimActorId == self.entity.actorId
			local rawState

			if isLocked or isAimed then
				rawState = isFullHp and isFullBp and UIConst.HEALTH_STATE.NAME_INFO or UIConst.HEALTH_STATE.NAME_BLOOD
			else
				rawState = isFullHp and isFullBp and UIConst.HEALTH_STATE.NONE or UIConst.HEALTH_STATE.BLOOD
			end

			if TopLogoPvp2Helper.isPvp2EnemyTarget(self.entity) then
				return self:applyPvp2EnemyCombatInfoState(rawState)
			end

			return rawState
		else
			local inCombat = self.entity.isInCombat and self.entity:isInCombat()

			if inCombat then
				if Utils.isCombatOnlyNameNpc(self.entity) then
					return UIConst.HEALTH_STATE.NAME
				end

				return UIConst.HEALTH_STATE.NAME_BLOOD
			else
				local isPetNpc = Utils.isPetNpc(self.entity)

				if isPetNpc and self.topLogoItem.distance > SysConfigData.NPC_NAME_DISTANCE then
					return UIConst.HEALTH_STATE.NONE
				end

				if self:isMultiPlayer() then
					self.forceShowSubName = true

					return UIConst.HEALTH_STATE.NAME
				else
					local isNpc = Utils.isNpc(self.entity)

					self.forceHideTitleAddon = isPetNpc or isNpc

					return UIConst.HEALTH_STATE.NAME_INFO
				end
			end
		end
	elseif self._isCreation then
		return UIConst.HEALTH_STATE.BLOOD
	end

	return UIConst.HEALTH_STATE.NONE
end

function TopLogoCombatComponent:moveInfoToTop()
	local alreadyAtTop = self.lvTitleInSpace == LVTITLE_IN_SPACE.TOP

	self.lvTitleInSpace = LVTITLE_IN_SPACE.TOP

	if not alreadyAtTop then
		self.levelUWidget.transform:SetParent(self.titleAddonUWidget.transform, false)
		self.listElementUList.transform:SetParent(self.titleAddonUWidget.transform, false)

		self.listElementUList.transform.localPosition = Vector3.zero
	end

	self:refreshLevelAndThreatState(not ToBool(self.entity:getConfigData().hideBloodLevel))

	self.m_preEcsAmountCacheState = nil

	self:setElementListActive()
end

function TopLogoCombatComponent:moveInfoToBlood()
	local alreadyAtBlood = self.lvTitleInSpace == LVTITLE_IN_SPACE.LEFT

	self.lvTitleInSpace = LVTITLE_IN_SPACE.LEFT

	if not alreadyAtBlood then
		self.levelUWidget.transform:SetParent(self.levelLocUWidget.transform, false)
		self.levelUWidget.transform:SetSiblingIndex(0)
		self.listElementUList.transform:SetParent(self.listElementLocUWidget.transform, false)

		self.listElementUList.transform.localPosition = Vector3.zero
	end

	self:refreshLevelAndThreatState(not ToBool(self.entity:getConfigData().hideBloodLevel))

	self.m_preEcsAmountCacheState = nil

	self:setElementListActive()
end

function TopLogoCombatComponent:setBloodVisible(visible)
	visible = visible == true

	if self.isBloodVisible == visible then
		return
	end

	self.isBloodVisible = visible

	self:refreshVisible()
	self:notifyActiveStateChanged(self:shouldBeActive())
end

function TopLogoCombatComponent:setBloodActive(active)
	active = active == true

	if self.isBloodActive == active then
		return
	end

	self.isBloodActive = active

	self:refreshVisible()
end

function TopLogoCombatComponent:setCombatInfoState(state)
	if self.state ~= state then
		local prevHadBlood = self:checkNeedBloodSubContainerForState()

		self.state = state

		if state ~= UIConst.HEALTH_STATE.NONE then
			self:setBloodActive(true)
		else
			self:setBloodActive(false)
		end

		self:markDirty("updateHealthBar")

		if not prevHadBlood and self:checkNeedBloodSubContainerForState() then
			self.m_deferHeavyRefresh = true
		end

		self:notifyActiveStateChanged(self:shouldBeActive())
	end
end

function TopLogoCombatComponent:m_applyCombatInfoTransientState()
	if self.curSpecialStateBuffInsId == nil and self.delayHideStatuesEfxTimer == nil then
		return
	end

	if self.state == UIConst.HEALTH_STATE.NAME or self.state == UIConst.HEALTH_STATE.NAME_INFO or self.state == UIConst.HEALTH_STATE.NAME_BLOOD then
		self:safeSetActive(self.nameBarUWidget, false)
	end
end

function TopLogoCombatComponent:updateHealthBar()
	if not self.state then
		return
	end

	if not self:checkContainerLoaded() then
		return
	end

	local isBloodBarVisible

	self:safeSetActiveFastest(self.rootUComponent, true)

	local shouldApplySimplified = self:shouldApplySimplifiedForFriendlyPet()
	local lastIsMiniBlood = self.isMiniBlood

	self.isMiniBlood = self.state == UIConst.HEALTH_STATE.BLOOD or shouldApplySimplified

	local miniBloodChanged = lastIsMiniBlood ~= self.isMiniBlood

	if miniBloodChanged then
		self.bloodColor = nil

		self:switchBloodContainerState()
		self:syncStatusEffectContainerWidth()
	end

	if self.combatInfoMode == COMBAT_INFO_MODE.FULL then
		self:m_applyFullMode()
	end

	self:m_setBloodInfoLocVisible(not self.isMiniBlood)

	local bpBarState

	if self.state == UIConst.HEALTH_STATE.NONE then
		self:safeSetActive(self.titleAddonUWidget, false)
		self:safeSetActive(self.nameBarUWidget, false)

		isBloodBarVisible = false

		self:refreshSubNameTextShow(false)
	elseif self.state == UIConst.HEALTH_STATE.NAME then
		self:safeSetActive(self.titleAddonUWidget, false)
		self:safeSetActive(self.nameBarUWidget, true)
		self:m_setNameActive(true)

		isBloodBarVisible = false

		if self.forceShowSubName then
			self:refreshSubName()
		else
			self:refreshSubNameTextShow(false)
		end

		self:moveInfoToTop()
		self.rootUComponent:TryChangePage("State", "Normal")
		self:refreshBloodContainerUI()
		self:setFriendShip()
	elseif self.state == UIConst.HEALTH_STATE.NAME_INFO then
		local showTitleAddon = ToBool(not self.forceHideTitleAddon)

		self:safeSetActive(self.titleAddonUWidget, showTitleAddon)
		self:safeSetActive(self.nameBarUWidget, true)
		self:m_setNameActive(true)

		isBloodBarVisible = false

		if self.forceHideSubName then
			self:refreshSubNameTextShow(false)
		else
			self:refreshSubName()
		end

		self:moveInfoToTop()
		self.rootUComponent:TryChangePage("State", "Normal")
		self:refreshBloodContainerUI()
		self:setFriendShip()
	elseif self.state == UIConst.HEALTH_STATE.NAME_BLOOD then
		self:safeSetActive(self.titleAddonUWidget, false)
		self:safeSetActive(self.nameBarUWidget, true)
		self:m_setNameActive(true)

		isBloodBarVisible = true

		self:refreshSubNameTextShow(false)
		self:moveInfoToBlood()

		if miniBloodChanged then
			self:refreshBloodContainerUI()
		end

		self.rootUComponent:TryChangePage("State", "Normal")

		local barBreakPageIndex = getBreakBarPageIndex(self)

		self.bloodUComponent:TryChangePage("NoBreakBar", barBreakPageIndex)
	elseif self.state == UIConst.HEALTH_STATE.BLOOD then
		self:safeSetActive(self.titleAddonUWidget, false)
		self:safeSetActive(self.nameBarUWidget, false)

		isBloodBarVisible = true

		self:refreshSubNameTextShow(false)
		self.rootUComponent:TryChangePage("State", "Normal")
		self:refreshBloodContainerUI()
		self.rootUComponent:TryChangePage("NoBreakBar", "Normal")
		self.bloodUComponent:TryChangePage("NoBreakBar", "Normal")
	elseif self.state == UIConst.HEALTH_STATE.PET_BLOOD then
		self:safeSetActive(self.titleAddonUWidget, false)
		self:safeSetActive(self.nameBarUWidget, false)

		isBloodBarVisible = true

		self:refreshSubNameTextShow(false)
		self.rootUComponent:TryChangePage("State", "Normal")
		self:refreshBloodContainerUI()
		self.rootUComponent:TryChangePage("NoBreakBar", "NoBreakBar")
		self.bloodUComponent:TryChangePage("NoBreakBar", "NoBreakBar")
	elseif self.state == UIConst.HEALTH_STATE.TEAM_ONLY then
		self:safeSetActive(self.titleAddonUWidget, false)
		self:safeSetActive(self.nameBarUWidget, true)

		isBloodBarVisible = false

		self:refreshSubNameTextShow(false)
		self.rootUComponent:TryChangePage("State", "Normal")
		self:m_setNameActive(false)
		self:safeSetActive(self.levelUWidget, false)

		if self.likabilityUWidget then
			self:safeSetActive(self.likabilityUWidget, false)
		end

		self:safeSetActive(self.controlUWidget, false)

		if self.teamUWidget then
			self:safeSetActive(self.teamUWidget, true)
		end
	end

	if self.combatInfoMode == COMBAT_INFO_MODE.SIMPLIFIED then
		if self:shouldApplySimplifiedForFriendlyPet() then
			self:m_applySimplifiedMode()
		else
			self:m_restoreTeamLocPosition()
		end
	end

	self:m_applyCombatInfoTransientState()

	if self.isBloodBarVisible ~= isBloodBarVisible then
		if self.isBloodBarVisible == nil then
			self.bloodBarUWidget:SetActive(isBloodBarVisible)
		else
			self.bloodBarUWidget:SetActive(true)

			if isBloodBarVisible then
				self.rootUComponent:InvokeCallback(CS.XGUI.EInvokeTime.User1)
			else
				self.rootUComponent:InvokeCallback(CS.XGUI.EInvokeTime.User2)
			end
		end

		self.isBloodBarVisible = isBloodBarVisible
	end
end

function TopLogoCombatComponent:m_setBloodInfoLocVisible(visible)
	local locVisible = visible == true

	if self.m_bloodInfoLocVisible == locVisible then
		return
	end

	local targetVisibility = locVisible and CS.XGUI.EVisibility.Visible or CS.XGUI.EVisibility.Hidden
	local applied = false

	if NotNil(self.levelUWidget) then
		self.levelUWidget.visibility = targetVisibility
		applied = true
	end

	if NotNil(self.listElementLocUWidget) then
		self.listElementLocUWidget.visibility = targetVisibility
		applied = true
	end

	if applied then
		self.m_bloodInfoLocVisible = locVisible
	end
end

function TopLogoCombatComponent:checkBloodVisibleAndMarkDirty(flag)
	if self:checkFinalVisible() and self:checkBloodVisible() then
		return true
	end

	return self:checkVisibleAndMarkDirty(flag)
end

function TopLogoCombatComponent:checkBloodVisibleAndResetDirty(flag)
	if self:checkFinalVisible() and self:checkBloodVisible() then
		return self:checkAndResetDirty(flag)
	end

	return false
end

function TopLogoCombatComponent:innerGetVisible()
	if not TopLogoCombatComponent.super.innerGetVisible(self) then
		return false
	end

	if not self.entity.actorCombatAttribute then
		return false
	end

	if self.entity.isTrapped or self.entity.isBeAttached then
		return false
	end

	if self.topLogoItem.distance > SysConfigData.PUPPET_HEALTH_DISTANCE then
		return false
	end

	if Utils.isSupportPet(self.entity) then
		return false
	end

	if self.entity and self.entity.isFishingCaptureBoss and self.entity:isFishingCaptureBoss() then
		return false
	end

	return self.isBloodVisible and (self.isBloodActive or self.isBuffAppearing)
end

function TopLogoCombatComponent:checkBloodVisible()
	return self:checkNeedBloodSubContainerForState()
end

function TopLogoCombatComponent:checkNeedBloodSubContainerForState()
	return self.state == UIConst.HEALTH_STATE.NAME_BLOOD or self.state == UIConst.HEALTH_STATE.BLOOD or self.state == UIConst.HEALTH_STATE.PET_BLOOD
end

function TopLogoCombatComponent:canUpdateHealthBarImmediately()
	if not self:checkNeedBloodSubContainerForState() then
		return true
	end

	return self.bloodContainerLoaded == true or self.bloodUComponent ~= nil
end

function TopLogoCombatComponent:onAppearFromTopLogoBuff(info)
	if self:checkContainerLoaded() then
		self:doAppearFromTopLogoBuffInternal(info)
	else
		local cbCacheInfo = self.m_cbCacheCombatInfo[TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC4]

		if cbCacheInfo and not cbCacheInfo.cbFunc then
			function cbCacheInfo.cbFunc(isSuccess)
				if isSuccess then
					self:doAppearFromTopLogoBuffInternal(info)
				end
			end
		end

		self:checkAndLoadUContainerUrlSupportAsync(cbCacheInfo.cbFunc, TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC4)
	end
end

function TopLogoCombatComponent:doAppearFromTopLogoBuffInternal(info)
	local buffData, specialStateBuff = BuffUIUtils.getUIBuffList(self.entity, SysConfigData.toplogoBuffCount or 4)

	specialStateBuff = BuffUIUtils.updateSpecialStateBuff(specialStateBuff, info.buffData, self.entity)

	if specialStateBuff and self.isBloodBarVisible == true then
		self:safeSetActive(self.nameBarUWidget, true)
		self:m_showStatusEffectBuff(specialStateBuff)
	else
		self:m_hideStatusEffectBuffWithDelay()
	end

	BuffUIUtils.doAppearFromTopLogoBuff(info, self, "entity")
end

function TopLogoCombatComponent:onTopLogoCompVisibleChanged(visible, skipRefresh)
	if visible and not skipRefresh then
		self.m_deferHeavyRefresh = true
	end

	TopLogoCombatComponent.super.onTopLogoCompVisibleChanged(self, visible, skipRefresh)

	if not visible then
		self:m_setBrokenVxActive(false)
	end

	if self.entity and self.entity.enableNotifyEcsAmount then
		self.entity:enableNotifyEcsAmount(visible, ECSConst.ECS_AMOUNT_NOTIFY_OWNER.TOP_LOGO)
		self:refreshEcsAmount(self.entity)
	end
end

function TopLogoCombatComponent:m_setElementToplogoContainerActive(active)
	local isActive = active == true

	self.m_elementToplogoContainerShouldActive = isActive

	if isActive then
		self:safeSetActiveFastest(self.elementToplogoUContainer, true)
	else
		self:safeSetActive(self.elementToplogoUContainer, false)
	end
end

function TopLogoCombatComponent:m_hideElementToplogoContainer()
	self:m_setElementToplogoContainerActive(false)
	BuffUIUtils.tryDestroyEleBuffsTimer(self)
end

function TopLogoCombatComponent:m_onElementToplogoContainerLoaded(content)
	self.m_elementToplogoUContainerIsLoading = false
	self.m_elementToplogoUContainerIsLoaded = content ~= nil
	self.m_elementToplogoUContainerLoadedContent = content

	if content == nil then
		self:m_setElementToplogoContainerActive(false)

		return
	end

	if not self.m_elementToplogoContainerShouldActive then
		self:m_setElementToplogoContainerActive(false)

		return
	end

	self:m_setElementToplogoContainerActive(true)

	self.m_elementToplogoUContainerActiveInitialized = true

	self:m_refreshEcsAmountContent()
end

function TopLogoCombatComponent:m_ensureElementToplogoContainerLoaded()
	if IsNil(self.elementToplogoUContainer) then
		return
	end

	if self.m_elementToplogoUContainerIsLoaded and self.m_elementToplogoUContainerLoadedContent then
		if self.m_elementToplogoContainerShouldActive and not self.m_elementToplogoUContainerActiveInitialized then
			self:m_setElementToplogoContainerActive(true)

			self.m_elementToplogoUContainerActiveInitialized = true
		end

		self:m_refreshEcsAmountContent()

		return
	end

	if self.m_elementToplogoUContainerIsLoading then
		return
	end

	self.m_elementToplogoUContainerIsLoading = true
	self.m_elementToplogoLoadReqId = (self.m_elementToplogoLoadReqId or 0) + 1

	local reqId = self.m_elementToplogoLoadReqId

	self.elementToplogoUContainer:LoadDefaultUrlManually(function(content)
		if self.m_elementToplogoLoadReqId ~= reqId then
			return
		end

		if IsNil(self.elementToplogoUContainer) then
			return
		end

		self:m_onElementToplogoContainerLoaded(content)
	end)
end

function TopLogoCombatComponent:m_clearStatusEffectHideTimer()
	if self.delayHideStatuesEfxTimer then
		TimerManager.removeTimer(self.delayHideStatuesEfxTimer)

		self.delayHideStatuesEfxTimer = nil
	end
end

function TopLogoCombatComponent:m_refreshStatusEffectBuffExpiredTime(info)
	local specialStateBuff = self.curSpecialStateBuff

	if not specialStateBuff or self.curSpecialStateBuffInsId ~= info.buffInsId then
		return
	end

	if info.newExpireTime ~= nil then
		specialStateBuff.expiredTime = info.newExpireTime
	end

	if info.newDuration ~= nil then
		specialStateBuff.duration = info.newDuration
	end

	if IsNil(self.statusEffectUContainer) or IsNil(self.statusEffectUContainer.content) then
		return
	end

	BuffUIUtils.refreshBuffCountDown(self.statusEffectUContainer.content, specialStateBuff)
end

function TopLogoCombatComponent:m_showStatusEffectBuff(specialStateBuff)
	if IsNil(self.statusEffectUContainer) then
		return
	end

	local interruptHide = self.delayHideStatuesEfxTimer ~= nil

	self:m_clearStatusEffectHideTimer()

	self.m_statusEffectBuffReqId = (self.m_statusEffectBuffReqId or 0) + 1

	local reqId = self.m_statusEffectBuffReqId
	local container = self.statusEffectUContainer

	self:safeSetActiveFastest(container, true)

	local function applyStateEffect(content)
		if self.m_statusEffectBuffReqId ~= reqId then
			return
		end

		if IsNil(container) then
			return
		end

		local targetContent = content or container.content

		if targetContent then
			if interruptHide and NotNil(targetContent.anim) then
				targetContent.anim:Play()
			end

			self:safeSetActive(self.nameBarUWidget, false)
			BuffUIUtils.setStateEffectBuff(targetContent, specialStateBuff)
		else
			self:safeSetActive(self.nameBarUWidget, false)
			self:safeSetActiveFastest(container, false)
		end

		self.curSpecialStateBuffInsId = specialStateBuff.instanceId
	end

	if container.content then
		applyStateEffect(container.content)
	else
		container:LoadDefaultUrlManually(function(content)
			applyStateEffect(content)
		end)
	end
end

function TopLogoCombatComponent:checkBuffDisappearFx(info, buffData)
	if info == nil then
		if IsNil(self.buffUList) then
			return
		end

		for _, buffInfo in ipairs(buffData) do
			local should, delayTime, instanceId = BuffUIUtils.checkBuffDisappearHint(self, buffInfo)

			if should then
				self.buffDisappearHintTimer[instanceId] = TimerManager.addTimer(delayTime, function()
					BuffUIUtils.invokeDisappearHintFx(self.buffUList, buffData, instanceId)
				end)
			end
		end
	else
		local should, delayTime, instanceId = BuffUIUtils.checkBuffDisappearHint(self, info.newBuffData)

		if should then
			self.buffDisappearHintTimer[instanceId] = TimerManager.addTimer(delayTime, function()
				BuffUIUtils.invokeDisappearHintFx(self.buffUList, buffData, instanceId)
			end)
		end
	end
end

function TopLogoCombatComponent:m_hideStatusEffectBuffWithDelay()
	if IsNil(self.statusEffectUContainer) then
		return
	end

	self:m_clearStatusEffectHideTimer()

	self.m_statusEffectBuffReqId = (self.m_statusEffectBuffReqId or 0) + 1

	local reqId = self.m_statusEffectBuffReqId
	local container = self.statusEffectUContainer

	if container.content then
		container.content:InvokeCallback(CS.XGUI.EInvokeTime.Custom1)
	end

	self.delayHideStatuesEfxTimer = TimerManager.addTimer(0.6, function()
		if self.m_statusEffectBuffReqId == reqId and self.statusEffectUContainer == container and NotNil(container) then
			self:safeSetActiveFastest(container, false)
		end

		self.delayHideStatuesEfxTimer = nil

		if (self.state == UIConst.HEALTH_STATE.NAME or self.state == UIConst.HEALTH_STATE.NAME_INFO or self.state == UIConst.HEALTH_STATE.NAME_BLOOD) and not self:shouldApplySimplifiedForFriendlyPet() then
			self:safeSetActive(self.nameBarUWidget, true)
		end

		self.curSpecialStateBuffInsId = nil

		self:refreshEcsAmount(self.entity)
	end)
end

function TopLogoCombatComponent:refreshEcsAmount(ent, cacheSpecailBuff)
	if not self:checkContainerLoaded() then
		return
	end

	self.m_preEcsAmountCacheState = {
		isDelayShowLevel = false,
		visibleSpecailBuff = false
	}

	if not self.elementToplogoUContainer then
		BuffUIUtils.tryDestroyEleBuffsTimer(self)

		return
	end

	if not self.entity then
		self:m_hideElementToplogoContainer()

		return
	end

	if self.entity ~= ent then
		self:m_hideElementToplogoContainer()

		return
	end

	local isInCombat = self.entity and self.entity.isInCombat and self.entity:isInCombat() or false

	if isInCombat and self.entity and self.entity.ecsAmountCache and self.entity.ecsAmountCache.maxElementType and self.entity.ecsAmountCache.maxValue > 0 then
		self:m_setElementToplogoContainerActive(true)
		self:m_ensureElementToplogoContainerLoaded()
	else
		self:m_hideElementToplogoContainer()
		self:refreshLevelAndThreatState(not ToBool(self.entity:getConfigData().hideBloodLevel), false)
	end
end

function TopLogoCombatComponent:m_clearElementToplogoContainerLoadInfo()
	self.m_elementToplogoLoadReqId = (self.m_elementToplogoLoadReqId or 0) + 1
	self.m_elementToplogoUContainerIsLoading = false
	self.m_elementToplogoUContainerIsLoaded = false
	self.m_elementToplogoUContainerLoadedContent = nil
	self.m_elementToplogoUContainerActiveInitialized = false
	self.m_elementToplogoContainerShouldActive = false
	self.elementToplogoRefs = nil

	BuffUIUtils.tryDestroyEleBuffsTimer(self)
end

function TopLogoCombatComponent:m_getElementToplogoRefs()
	if not self.elementToplogoRefs then
		local button = self.elementToplogoUContainer.content:GetComponent("UButton")
		local objectReference = button:GetComponent("ObjectReference")

		self.elementToplogoRefs = {
			button = button,
			objectReference = objectReference,
			animation = objectReference:GetRefValue("uINodeElementToplogoAnimation"),
			slider = objectReference:GetRefValue("sliderUSlider"),
			numText = objectReference:GetRefValue("numUBaseText")
		}
	end

	return self.elementToplogoRefs
end

function TopLogoCombatComponent:m_refreshEcsAmountContent()
	local refs = self:m_getElementToplogoRefs()
	local visibleSpecailBuff, isDelayShowLevel = BuffUIUtils.setElementBuff(refs.button, self.entity, self)

	self.m_preEcsAmountCacheState = {
		visibleSpecailBuff = visibleSpecailBuff,
		isDelayShowLevel = isDelayShowLevel
	}

	if visibleSpecailBuff then
		-- block empty
	else
		self:refreshLevelAndThreatState(not ToBool(self.entity:getConfigData().hideBloodLevel), isDelayShowLevel)
		self:m_setElementToplogoContainerActive(false)
	end
end

function TopLogoCombatComponent:m_rereshEcsAmount()
	self:m_refreshEcsAmountContent()
end

function TopLogoCombatComponent:refreshByBuffChange(info)
	local cbInfo = self.m_cbSubBloodCacheInfo[BLOOD_CB_FUNC.BUFF_CHANGE]

	cbInfo.cbData = info

	self:checkAndLoadBloodUrlAsync(cbInfo.cbFunc, BLOOD_CB_FUNC.BUFF_CHANGE)
end

function TopLogoCombatComponent:m_canIncrementalBuff()
	return self:checkContainerLoaded() and NotNil(self.buffUList) and self.curBuffList ~= nil
end

function TopLogoCombatComponent:m_onBuffAddIncremental(info)
	local buffData = info.newBuffData

	if BuffUIUtils.checkIsElementBuff(buffData.templateId) then
		self:refreshEcsAmount(self.entity)

		return
	end

	local buffInfo = BuffUIUtils._addBuffInfo(buffData, self.entity, {})

	if not buffInfo then
		return
	end

	local maxCount = SysConfigData.toplogoBuffCount or 4
	local idx = BuffUIUtils.computeInsertIndex(self.curBuffList, buffInfo, maxCount)

	if idx <= 0 then
		return
	end

	if maxCount <= #self.curBuffList then
		BuffUIUtils.tryRemoveBuff(self.buffUList, self.curBuffList, #self.curBuffList)
	end

	BuffUIUtils.tryInsertBuff(self.buffUList, self.curBuffList, idx, buffInfo)

	local newSpecial = BuffUIUtils.updateSpecialStateBuff(self.curSpecialStateBuff, buffData, self.entity)

	if newSpecial and newSpecial ~= self.curSpecialStateBuff and self.isBloodBarVisible == true then
		self.curSpecialStateBuff = newSpecial
		self.curSpecialStateBuffInsId = newSpecial.instanceId

		self:safeSetActive(self.nameBarUWidget, true)
		self:m_showStatusEffectBuff(newSpecial)
	end

	local should, delayTime, instanceId = BuffUIUtils.scheduleDisappearHint(self, buffInfo)

	if should then
		self.buffDisappearHintTimer[instanceId] = TimerManager.addTimer(delayTime, function()
			BuffUIUtils.invokeDisappearHintFx(self.buffUList, self.curBuffList, instanceId)
		end)
	end

	self:refreshEcsAmount(self.entity)
end

function TopLogoCombatComponent:m_onBuffRemoveIncremental(info)
	local instanceId = info.buffInsId
	local idx = BuffUIUtils.findBuffIndex(self.curBuffList, instanceId)

	if idx > 0 then
		BuffUIUtils.tryRemoveBuff(self.buffUList, self.curBuffList, idx)
	end

	if self.curSpecialStateBuffInsId == instanceId then
		local newSpecial = BuffUIUtils.computeSpecialStateBuff(self.curBuffList)

		if newSpecial and self.isBloodBarVisible == true then
			self.curSpecialStateBuff = newSpecial
			self.curSpecialStateBuffInsId = newSpecial.instanceId

			self:safeSetActive(self.nameBarUWidget, true)
			self:m_showStatusEffectBuff(newSpecial)
		else
			self.curSpecialStateBuff = nil
			self.curSpecialStateBuffInsId = nil

			self:m_hideStatusEffectBuffWithDelay()
		end
	end

	self:refreshEcsAmount(self.entity)
end

function TopLogoCombatComponent:getInitMaxDistance()
	if self.entity and self.entity.isInCombat then
		if self.entity:isInCombat() then
			return SysConfigData.PUPPET_HEALTH_DISTANCE
		else
			return SysConfigData.NPC_TOPLOGO_DISTANCE
		end
	end

	return SysConfigData.NPC_TOPLOGO_DISTANCE
end

function TopLogoCombatComponent:onEnterCombat()
	self:refreshEcsAmount(self.entity)
	TopLogoCombatComponent.super.onEnterCombat(self)
end

function TopLogoCombatComponent:onLeaveCombat()
	self:m_hideElementToplogoContainer()
	TopLogoCombatComponent.super.onLeaveCombat(self)
end

function TopLogoCombatComponent:forceSetGoActive(uwidget)
	if IsNil(uwidget) then
		return
	end

	if not uwidget.bActive then
		uwidget:SetActive(true)
	end
end

function TopLogoCombatComponent:safeSetActiveFastest(uwidget, isActive)
	if IsNil(uwidget) then
		return false
	end

	if isActive then
		self:forceSetGoActive(uwidget)
	end

	uwidget:SetActiveFastestAndMarkIgnoreLayout(isActive)

	return true
end

function TopLogoCombatComponent:safeSetActive(uwidget, isActive)
	if IsNil(uwidget) then
		return false
	end

	uwidget:SetActive(isActive)

	return true
end

function TopLogoCombatComponent:getEntityTitleText(ent)
	if not ent then
		return nil
	end

	local showTitles = ent.showTitles

	if not showTitles then
		return nil
	end

	local titleText = ShowTitleUtils.getShowTitleText(showTitles, ent.showTitleExtra, ent.isWholeTitle)

	if string.isNilOrEmpty(titleText) then
		return nil
	end

	return titleText
end

function TopLogoCombatComponent:m_checkPlayerTitleVisibleByDist(ownerEnt)
	if ownerEnt and Utils.isMainPlayer(ownerEnt) then
		return true
	end

	local dist = self.topLogoItem and self.topLogoItem.distance

	if not dist then
		return true
	end

	return dist <= SysConfigData.TOPLOGO_PLAYER_TITLE_VISIBLE_DIST
end

function TopLogoCombatComponent:refreshSubNameTextShow(isShow)
	local subText = self.subTextUSDFText

	if IsNil(subText) then
		return
	end

	isShow = isShow and not string.isNilOrEmpty(self.m_preSubName) or false

	self:safeSetActive(subText, isShow)
	ClientTextUtils.setText(subText, isShow and self.m_preSubName or "")
	self:safeSetActiveFastest(subText, isShow)
end

function TopLogoCombatComponent:hideOnlineIDText()
	local layout = TopLogoCombatComponent._platformTopLogoOnlineID

	if layout then
		layout.stopOnlineIDLayout(self)
	end

	self.m_onlineIDLoadReqId = (self.m_onlineIDLoadReqId or 0) + 1
	self._platformOnlineIDPendingLoad = nil

	self:safeSetActive(self.onlineIDUContainer, false)
	self:safeSetActiveFastest(self.onlineIDUContainer, false)

	if NotNil(self.onlineIDText) then
		ClientTextUtils.setText(self.onlineIDText, "")
	end

	self.onlineIDText = nil
end

function TopLogoCombatComponent:refreshOnlineIDText(text)
	if IsNil(self.onlineIDUContainer) then
		return
	end

	local hasText = not string.isNilOrEmpty(text)

	if not hasText then
		self:hideOnlineIDText()

		return
	end

	self.m_onlineIDLoadReqId = (self.m_onlineIDLoadReqId or 0) + 1

	local reqId = self.m_onlineIDLoadReqId
	local container = self.onlineIDUContainer
	local entity = self.entity

	local function applyContent(content)
		if self.m_onlineIDLoadReqId ~= reqId or self.entity ~= entity or self.onlineIDUContainer ~= container then
			return
		end

		if IsNil(container) or IsNil(content) then
			self:hideOnlineIDText()

			return
		end

		if not content.transform then
			self:hideOnlineIDText()

			return
		end

		local numTrans = content.transform:Find("Num")

		if not numTrans then
			self:hideOnlineIDText()

			return
		end

		local numText = numTrans:GetComponent("USDFText")

		if not numText then
			self:hideOnlineIDText()

			return
		end

		numText.overflow = 0

		ClientTextUtils.setText(numText, text)

		self.onlineIDText = numText

		self:safeSetActiveFastest(numText, true)
		self:safeSetActiveFastest(container, true)
	end

	if container.content then
		applyContent(container.content)
	else
		self:safeSetActive(container, false)
		self:safeSetActiveFastest(container, false)
		container:LoadDefaultUrlManually(function(content)
			applyContent(content)
		end)
	end
end

function TopLogoCombatComponent:m_reapplyPlayerTitleVisible()
	self:refreshSubName()
end

function TopLogoCombatComponent:syncStatusEffectContainerWidth()
	if not self.statusEffectUContainer or not self.bloodContainer then
		return
	end

	local bloodRect = self.bloodContainer.transform
	local statusRect = self.statusEffectUContainer.transform

	if bloodRect and statusRect then
		local bloodWidth = self.isMiniBlood and STATUS_EFFECT_WIDTH[BLOOD_TYPE.MINI] or STATUS_EFFECT_WIDTH[BLOOD_TYPE.NORMAL]

		statusRect.sizeDelta = Vector2.New(bloodWidth, statusRect.sizeDelta.y)
	end
end

function TopLogoCombatComponent:m_applySimplifiedMode()
	if not self:shouldApplySimplifiedForFriendlyPet() then
		return
	end

	if self.buffUList then
		self:safeSetActive(self.buffUList, false)
	end

	self:m_setBloodInfoLocVisible(false)

	if self.teamLocUWidget and self.levelUWidget then
		local rectTransform = self.teamLocUWidget.transform

		rectTransform:SetParent(self.levelLocUWidget.transform, false)
		rectTransform:SetSiblingIndex(0)

		rectTransform.anchorMin = Vector2.New(1, 0.5)
		rectTransform.anchorMax = Vector2.New(1, 0.5)
		rectTransform.localPosition = Vector3.New(-30, 2, 0)
	end

	self:safeSetActive(self.nameBarUWidget, false)
end

function TopLogoCombatComponent:m_restoreTeamLocPosition()
	if self.teamLocUWidget and self.teamLocUWidgetOriginalParent then
		local rectTransform = self.teamLocUWidget.transform

		rectTransform:SetParent(self.teamLocUWidgetOriginalParent, false)
		rectTransform:SetSiblingIndex(0)
	end
end

function TopLogoCombatComponent:m_applyFullMode()
	if self.buffUList then
		self:safeSetActive(self.buffUList, true)
	end

	if not self.isMiniBlood then
		self:m_setBloodInfoLocVisible(true)
	end

	self:m_restoreTeamLocPosition()
	self:safeSetActive(self.nameBarUWidget, true)
end

function TopLogoCombatComponent:needShowControlPet()
	return self.state ~= UIConst.HEALTH_STATE.TEAM_ONLY
end

function TopLogoCombatComponent:needShowFriendShip()
	return self.state ~= UIConst.HEALTH_STATE.TEAM_ONLY
end

function TopLogoCombatComponent:setCombatInfoMode(mode)
	if self.combatInfoMode == mode then
		return
	end

	self.combatInfoMode = mode

	self:markDirty("updateHealthBar")
end

function TopLogoCombatComponent:onBloodTypeChanged(bloodType)
	if self.bloodType == bloodType then
		return
	end

	self.bloodType = bloodType

	self:setCombatInfoMode(self.bloodType == 0 and COMBAT_INFO_MODE.SIMPLIFIED or COMBAT_INFO_MODE.FULL)
end

function TopLogoCombatComponent:getCombatInfoMode()
	return self.combatInfoMode
end

function TopLogoCombatComponent:isFriendCreation()
	if Utils.isEnemy(self.entity) then
		return false
	end

	local masterEnt = self.entity.getMasterEntity and self.entity:getMasterEntity()

	if masterEnt and (Utils.isPlayerPet(masterEnt) or Utils.isBotPet(masterEnt)) and masterEnt.getMasterEntity then
		local ent = masterEnt:getMasterEntity()

		if not ent then
			return false
		end

		if ent.id == pg.me.id or Utils.isTeamPlayerOrPet(ent) or Utils.isBotPlayer(ent) then
			return true
		end
	end

	return false
end

return TopLogoCombatComponent
