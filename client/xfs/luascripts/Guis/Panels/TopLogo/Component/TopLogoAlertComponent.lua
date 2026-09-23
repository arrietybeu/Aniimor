-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Component\\TopLogoAlertComponent.lua

local Class = require("Core.Framework.Class")
local EventConst = require("Const.EventConst")
local UIConst = require("Const.UIConst")
local TopLogoConst = require("Const.TopLogoConst")
local SysConfigData = require("Data.sys_config_data")
local PerceptibilityConst = require("Common.Const.PerceptibilityConst")
local TopLogoItemComponent = require("Guis.Panels.TopLogo.Component.TopLogoItemComponent")
local Time = require("Core.Common.Time")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("TopLogoAlertDebug")

local function dbg(self, tag, fmt, ...)
	if not TopLogoConst.IsDebugAlertLog then
		return
	end

	local entId = self.entity and self.entity.actorId or 0
	local ok, line = pcall(string.format, "[AlertDbg][ent=%s][%s] " .. fmt, tostring(entId), tag, ...)

	if not ok then
		return
	end

	logger:info(line)
end

local TopLogoAlertComponent = Class.LightClass("TopLogoAlertComponent", TopLogoItemComponent)
local STAGE = {
	HIDE = 0,
	FULL = 2,
	NORMAL = 1
}
local LERP_SMOOTH_TAU = 0.18
local LERP_MAX_DT = 0.2
local LERP_SNAP_EPS = 0.005
local FULL_TRIGGER_PERCENT = 0.99

function TopLogoAlertComponent:ctor(refUContainer, topLogoItem)
	TopLogoAlertComponent.super.ctor(self, refUContainer, topLogoItem)

	self.m_cbCacheAlertInfo = {
		[TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC1] = {},
		[TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC2] = {},
		[TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC3] = {},
		[TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC4] = {}
	}
end

function TopLogoAlertComponent:onCtor()
	self.stage = STAGE.HIDE
	self.visible = false
	self.lastPerceptibility = 0

	self:m_resetLerpState()

	self.m_pendingShowType = nil

	local topLogoData = self.entity and self.entity.topLogoData

	if topLogoData and topLogoData.alertVisible then
		self.m_pendingShowType = topLogoData.alertMarkType
	end

	self:refreshVisible()
end

function TopLogoAlertComponent:m_resetLerpState()
	self.m_targetPercent = 0
	self.m_displayPercent = 0
	self.m_wantFull = false
	self.m_appliedTier = nil
	self.m_lastLerpTime = nil
end

function TopLogoAlertComponent:shouldBeActive()
	if not self:isActive() then
		return false
	end

	return self.stage ~= nil and self.stage ~= STAGE.HIDE
end

function TopLogoAlertComponent:resetRender()
	if self.questionMarkTimer then
		self:killTimer(self.questionMarkTimer)

		self.questionMarkTimer = nil
	end

	self.lastPerceptibility = 0

	self:m_resetLerpState()

	if self.stage and self.stage ~= STAGE.HIDE then
		self.m_pendingShowType = self.m_pendingShowType or self.stage
		self.m_pendingRestore = true
	end

	if self.m_cbCacheAlertInfo then
		for _, info in pairs(self.m_cbCacheAlertInfo) do
			info.cbData = nil
		end
	end

	self.objectReference = nil
	self.rootUComponent = nil
	self.attentionUComponent = nil
	self.progress1 = nil
	self.progress2 = nil

	TopLogoAlertComponent.super.resetRender(self)
end

function TopLogoAlertComponent:initUI()
	self.attentionUComponent:TryChangePage("AlertState", "null")
	self:_setProgress(0, true)
end

function TopLogoAlertComponent:onDestroy()
	if self.entity then
		self.entity.eventEmitter:removeEventListener(EventConst.TOPLOGO_ALERT, self.onAlertMsg)

		if self.onPerceptChanged then
			self.entity.eventEmitter:removeEventListener(EventConst.TOPLOGO_PERCEPT_CHANGED, self.onPerceptChanged)
		end
	end

	if self.questionMarkTimer then
		self:killTimer(self.questionMarkTimer)

		self.questionMarkTimer = nil
	end

	pg.game.topLogo.alertLimiter:unregister(self.entity.actorId)
	TopLogoAlertComponent.super.onDestroy(self)

	self.m_cbCacheAlertInfo = nil
end

function TopLogoAlertComponent:findObjects()
	self.objectReference = self.refUContainer.content:GetComponent("ObjectReference")
	self.rootUComponent = self.objectReference:GetRefValue("rootUComponent")
	self.attentionUComponent = self.objectReference:GetRefValue("attentionUComponent")
	self.progress1 = self.objectReference:GetRefValue("progress1")
	self.progress2 = self.objectReference:GetRefValue("progress2")
end

function TopLogoAlertComponent:onLanguageChanged()
	if not self:checkContainerLoaded() then
		return
	end

	TopLogoAlertComponent.super.onLanguageChanged(self)
end

function TopLogoAlertComponent:registerObjects()
	return
end

function TopLogoAlertComponent:addEntityListener()
	function self.onAlertMsg(visible, markType)
		if visible then
			self:showQuestionMark(markType)
		else
			self:hideQuestionMark()
		end
	end

	function self.onPerceptChanged(percent)
		dbg(self, "EVENT", "TOPLOGO_PERCEPT_CHANGED percent=%.3f stage=%s", percent or -1, tostring(self.stage))
		self:m_refreshPerceptibility("event")
	end

	if self.entity then
		self.entity.eventEmitter:addEventListener(EventConst.TOPLOGO_ALERT, self.onAlertMsg)
		self.entity.eventEmitter:addEventListener(EventConst.TOPLOGO_PERCEPT_CHANGED, self.onPerceptChanged)
	end
end

function TopLogoAlertComponent:refreshTopLogoInfo(callFromUpdate)
	if self.m_pendingShowType ~= nil then
		local pendingType = self.m_pendingShowType

		self.m_pendingShowType = nil

		self:showQuestionMark(pendingType)

		return
	end

	self:m_refreshPerceptibility(callFromUpdate and "tick" or "refresh")
end

function TopLogoAlertComponent:m_refreshPerceptibility(src)
	if self.stage ~= STAGE.NORMAL then
		dbg(self, "TARGET", "skip stage=%s src=%s", tostring(self.stage), tostring(src))

		return
	end

	local maxPerceptibility = 0

	if self.entity.getMaxPerceivedValuePercent then
		maxPerceptibility = self.entity:getMaxPerceivedValuePercent()
	end

	dbg(self, "TARGET", "raw=%.3f src=%s (curTarget=%.3f curDisplay=%.3f)", maxPerceptibility, tostring(src), self.m_targetPercent or -1, self.m_displayPercent or -1)

	if maxPerceptibility < math.epsilon then
		self:hideQuestionMark()

		return
	end

	if maxPerceptibility >= 0.99 then
		self.m_wantFull = true
		self.m_targetPercent = 1
	else
		self.m_targetPercent = maxPerceptibility
	end

	self.lastPerceptibility = maxPerceptibility
end

function TopLogoAlertComponent:onTopLogoCompUpdate()
	if self.stage ~= STAGE.NORMAL then
		return
	end

	local now = Time.getTickSecond()
	local dt = self.m_lastLerpTime and now - self.m_lastLerpTime or 0

	self.m_lastLerpTime = now

	if dt < 0 then
		dt = 0
	end

	local rawDt = dt

	if dt > LERP_MAX_DT then
		dt = LERP_MAX_DT
	end

	local target = self.m_targetPercent or 0
	local oldDisplay = self.m_displayPercent or 0
	local display = oldDisplay
	local branch

	if math.abs(target - display) <= LERP_SNAP_EPS then
		display = target
		branch = "snap"
	elseif dt > 0 then
		local k = 1 - math.exp(-dt / LERP_SMOOTH_TAU)

		display = display + (target - display) * k
		branch = "lerp"
	else
		branch = "dt0"
	end

	self.m_displayPercent = display

	dbg(self, "TICK", "target=%.3f disp %.3f->%.3f d=%+.3f rawDt=%.3f dt=%.3f br=%s loaded=%s", target, oldDisplay, display, display - oldDisplay, rawDt, dt, branch, tostring(self:checkContainerLoaded()))
	self:m_applyDisplayPercent(display)

	if self.m_wantFull and display >= FULL_TRIGGER_PERCENT and self:checkContainerLoaded() then
		dbg(self, "FULL", "trigger playFullPerceptibility disp=%.3f", display)
		self:playFullPerceptibility()
	end
end

function TopLogoAlertComponent:m_applyDisplayPercent(display)
	if not self:checkContainerLoaded() then
		return
	end

	local tier

	tier = display < SysConfigData.ToplogoAlertThreshold1 and "Low" or display < SysConfigData.ToplogoAlertThreshold2 and "Mid" or "High"

	if self.m_appliedTier ~= tier then
		dbg(self, "APPLY", "tier %s->%s disp=%.3f", tostring(self.m_appliedTier), tier, display)

		self.m_appliedTier = tier

		self.attentionUComponent:TryChangePage("ProgressState", tier)
	end

	self:_setProgress(display, true)
end

function TopLogoAlertComponent:innerGetVisible()
	if not TopLogoAlertComponent.super.innerGetVisible(self) then
		return false
	end

	if self.topLogoItem.distance > SysConfigData.SHOW_ALERT_MARK_DISTANCE then
		return false
	end

	return true
end

function TopLogoAlertComponent:showQuestionMark(type)
	self.m_pendingShowType = type

	self:notifyActiveStateChanged(true)

	if not self.topLogoItem:isTopLogoPrefabReady() then
		return
	end

	self.m_pendingShowType = nil

	if self:checkContainerLoaded() then
		self:m_showTplQuestionMark(false, type)
	else
		self.m_cbCacheAlertInfo = self.m_cbCacheAlertInfo or {}

		local cacheInfo = self.m_cbCacheAlertInfo[TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC1]

		cacheInfo.cbData = cacheInfo.cbData or {}
		cacheInfo.cbData.type = type

		if not cacheInfo.cbFunc then
			function cacheInfo.cbFunc(isSuccess)
				if isSuccess then
					local cacheInfo = self.m_cbCacheAlertInfo[TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC1]
					local cbType = cacheInfo.cbData and cacheInfo.cbData.type

					self:m_showTplQuestionMark(true, cbType)
				end
			end
		end

		self:checkAndLoadUContainerUrlSupportAsync(cacheInfo.cbFunc, TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC1)
	end
end

function TopLogoAlertComponent:m_showTplQuestionMark(isAsync, type)
	dbg(self, "SHOW", "m_showTplQuestionMark type=%s isAsync=%s stage=%s restore=%s", tostring(type), tostring(isAsync), tostring(self.stage), tostring(self.m_pendingRestore))

	local isRestore = self.m_pendingRestore

	self.m_pendingRestore = nil

	if not isRestore and type ~= "DirectFull" and self.stage == STAGE.NORMAL then
		dbg(self, "SHOW", "skip duplicate Normal show (already NORMAL, keep progress)")

		return
	end

	self:_setProgress(0, true)
	pg.game.topLogo.alertLimiter:register(self.entity.actorId, self)
	self:refreshTopLogoInfo()

	if type == "DirectFull" then
		dbg(self, "SHOW", "DirectFull -> playFullPerceptibility (跳过lerp)")
		self:playFullPerceptibility()

		return
	end

	self.stage = STAGE.NORMAL

	self:notifyMaxDistanceChanged()

	self.lastPerceptibility = 0

	self:m_resetLerpState()

	if self.questionMarkTimer then
		self:killTimer(self.questionMarkTimer)

		self.questionMarkTimer = nil
	end

	if self.entity.getPerceptibilityVisionType and self.entity:getPerceptibilityVisionType() == PerceptibilityConst.VisionType.Audition then
		self.attentionUComponent:TryChangePage("AlertType", "Audition")
	else
		self.attentionUComponent:TryChangePage("AlertType", "Sight")
	end

	self.attentionUComponent:TryChangePage("AlertState", "normal")
end

function TopLogoAlertComponent:playFullPerceptibility()
	if self:checkContainerLoaded() then
		self:m_playFullPerceptiblity()
	else
		local cacheInfo = self.m_cbCacheAlertInfo[TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC3]

		if not cacheInfo.cbFunc then
			function cacheInfo.cbFunc(isSuccess)
				if isSuccess then
					self:m_playFullPerceptiblity()
				end

				cacheInfo.cbData = nil
			end
		end

		self:checkAndLoadUContainerUrlSupportAsync(cacheInfo.cbFunc, TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC3)
	end
end

function TopLogoAlertComponent:m_playFullPerceptiblity()
	dbg(self, "FULL", "m_playFullPerceptiblity 进FULL stage %s->FULL disp=%.3f", tostring(self.stage), self.m_displayPercent or -1)

	self.stage = STAGE.FULL

	self:notifyMaxDistanceChanged()
	self.attentionUComponent:TryChangePage("AlertState", "alert")

	if self.questionMarkTimer then
		self:killTimer(self.questionMarkTimer)

		self.questionMarkTimer = nil
	end

	if self.questionMarkTimerFunc == nil then
		function self.questionMarkTimerFunc()
			self:hideQuestionMark()
		end
	end

	self.questionMarkTimer = self:startTimer(self.questionMarkTimerFunc, SysConfigData.ToplogoAlertExclamationTimeout)
end

function TopLogoAlertComponent:hideQuestionMark()
	self.m_pendingShowType = nil
	self.m_pendingRestore = nil

	pg.game.topLogo.alertLimiter:unregister(self.entity.actorId)

	self.stage = STAGE.HIDE

	self:notifyMaxDistanceChanged()
	self:notifyActiveStateChanged(false)

	if self.questionMarkTimer then
		self:killTimer(self.questionMarkTimer)

		self.questionMarkTimer = nil
	end

	if self:checkContainerLoaded() then
		self.attentionUComponent:TryChangePage("AlertState", "null")
	end
end

function TopLogoAlertComponent:_setProgress(val, immediate)
	if self:checkContainerLoaded() then
		self:m_setProgress(false, val, immediate)
	else
		local cacheInfo = self.m_cbCacheAlertInfo[TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC4]

		cacheInfo.cbData = {
			val = val,
			immediate = immediate
		}

		if not cacheInfo.cbFunc then
			function cacheInfo.cbFunc(isSuccess)
				if isSuccess then
					local cacheInfo = self.m_cbCacheAlertInfo[TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC4]
					local cbVal = cacheInfo.cbData and cacheInfo.cbData.val or val
					local cbImmediate = cacheInfo.cbData and cacheInfo.cbData.immediate or immediate

					self:m_setProgress(true, cbVal, cbImmediate)
				end

				cacheInfo.cbData = nil
			end
		end

		self:checkAndLoadUContainerUrlSupportAsync(cacheInfo.cbFunc, TopLogoConst.REF_CONTAINER_LOADED_CALLBACK_GROUP.CB_FUNC4)
	end
end

function TopLogoAlertComponent:m_setProgress(isAsync, val, immediate)
	dbg(self, "SETPROG", "val=%.3f immediate=%s isAsync=%s", val or -1, tostring(immediate), tostring(isAsync))

	if immediate then
		self.progress1.value = val
		self.progress2.value = val
	else
		self.progress1:ProgressToValue(val, nil, 0.5)
		self.progress2:ProgressToValue(val, nil, 0.5)
	end
end

function TopLogoAlertComponent:getInitMaxDistance()
	return SysConfigData.SHOW_ALERT_MARK_DISTANCE
end

return TopLogoAlertComponent
