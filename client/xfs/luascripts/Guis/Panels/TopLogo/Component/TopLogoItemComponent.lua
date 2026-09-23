-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Component\\TopLogoItemComponent.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("TopLogoItemComponent")
local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local ClientConst = require("Const.ClientConst")
local TopLogoConst = require("Const.TopLogoConst")
local Utils = require("Common.Utils.Utils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local LuaTopLogoUtils = require("Utils.LuaTopLogoUtils")
local IsNil = IsNil
local NotNil = NotNil
local TopLogoItemComponent = Class.LightClass("TopLogoItemComponent")

function TopLogoItemComponent:ctor(refUContainer, topLogoItem)
	self:resetSelf()

	self.compName = topLogoItem._constructionComponentName or ""
	self.topLogoItem = topLogoItem
	self.entity = topLogoItem.entity

	local ent = self.entity

	self._isPlayer = Utils.isPlayer(ent) or false
	self._isMainPlayer = Utils.isMainPlayer(ent) or false
	self._isPet = Utils.isPet(ent) or false
	self._isPuppet = Utils.isPuppet(ent) or false
	self._isVirtualPuppet = Utils.isVirtualPuppet(ent) or false
	self._isCreation = Utils.isCreation(ent) or false
	self._isStaticNpcWithNpcTopLogo = Utils.isStaticNpcWithNpcTopLogo(ent) or false

	local isDeferred = false
	local componentName

	if topLogoItem.isDeferringComponentInitialization then
		isDeferred, componentName = topLogoItem:isDeferringComponentInitialization()
	end

	if isDeferred then
		self._deferredInitialization = true
		self._deferredRefUContainer = refUContainer
		self._deferredComponentName = componentName
	else
		self:m_onRootContainerLoaded(refUContainer)
		self:addEntityListener()
	end

	self:onCtor()
end

function TopLogoItemComponent:destroy()
	self:onDestroy()
	self:clearAysncLoadingInfo()

	if NotNil(self.refUContainer) then
		self.refUContainer:SetActiveFastestAndMarkIgnoreLayout(true)
		self.refUContainer:SetActiveQuickly(true)
	end

	self:resetSelf()
end

function TopLogoItemComponent:resetSelf()
	if NotNil(self.refUContainer) then
		self.refUContainer.ignoreLayout = false

		self.refUContainer:DestroyContent()
	end

	if NotNil(self.transform) then
		local preSizeDelta = self.transform.sizeDelta

		self.transform:SetSizeDeltaEx(preSizeDelta[1], 0)
	end

	self.refUContainer = nil
	self.refContainersLoaded = nil
	self.transform = nil
	self.topLogoItem = nil
	self.entity = nil
	self.dirtyFlags = {}
	self._self = nil
	self._finalVisible = true
	self._inUpdate = true
	self._visibleInfo = {}
	self.m_loadedRefContainerCallback = nil
	self._deferredInitialization = nil
	self._deferredRefUContainer = nil
	self._deferredComponentName = nil
	self._deferredRefreshPending = nil
	self._deferredLoadPending = nil
	self._deferredLoadRequests = nil
	self.compName = ""
end

function TopLogoItemComponent:resetRender()
	self:clearAysncLoadingInfo()

	if NotNil(self.refUContainer) then
		self.refUContainer:SetActiveFastestAndMarkIgnoreLayout(true)
		self.refUContainer:SetActiveQuickly(true)
		self.refUContainer:ProgressActive(true)
	end

	if NotNil(self.transform) then
		self.transform:SetLocalScaleEx(1, 1, 1)

		local preSizeDelta = self.transform.sizeDelta

		self.transform:SetSizeDeltaEx(preSizeDelta[1], 0)
	end

	if NotNil(self.refUContainer) then
		self.refUContainer:DestroyContent()
	end

	self.refUContainer = nil
	self.refContainersLoaded = nil
	self.transform = nil
	self.dirtyFlags = {}
	self._selfVisible = nil
	self._finalVisible = true
	self._inUpdate = true
	self.m_loadedRefContainerCallback = nil
end

function TopLogoItemComponent:onDestroy()
	return
end

function TopLogoItemComponent:onParentVisibleChanged(visible)
	self:refreshVisible()
end

function TopLogoItemComponent:onTopLogoCompVisibleChanged(visible, skipRefresh)
	if self._deferredInitialization then
		self._deferredRefreshPending = true

		return
	end

	if visible and not skipRefresh then
		self:refreshTopLogoInfo()
	end
end

function TopLogoItemComponent:m_clearInvalidRefUContainer()
	local invalidRef = self.refUContainer ~= nil and IsNil(self.refUContainer)
	local invalidTransform = self.transform ~= nil and IsNil(self.transform)

	if not invalidRef and not invalidTransform then
		return false
	end

	self:clearAysncLoadingInfo()

	self.refUContainer = nil
	self.refContainersLoaded = nil
	self.transform = nil
	self.m_loadedRefContainerCallback = nil

	return true
end

function TopLogoItemComponent:checkContainerLoaded()
	if self:m_clearInvalidRefUContainer() then
		return false
	end

	return self.refContainersLoaded == true
end

function TopLogoItemComponent:onUContainerLoaded(isSuccess)
	self.refContainersLoaded = isSuccess

	if not isSuccess then
		return
	end

	if self:m_clearInvalidRefUContainer() then
		return
	end

	self:findObjects()
	self:registerObjects()
	self:addListener()
	self:initUI()

	if NotNil(self.refUContainer) then
		self.refUContainer:RefreshAdaptChildRectSize()
	end

	if NotNil(self.refUContainer) then
		self.refUContainer:SetActiveFastestAndMarkIgnoreLayout(self._selfVisible == true)
	end
end

function TopLogoItemComponent:checkVisibleAndMarkDirty(flag)
	if self._finalVisible and self:checkContainerLoaded() then
		return true
	end

	self.dirtyFlags[flag] = true

	return false
end

function TopLogoItemComponent:markDirty(flag)
	if not flag then
		return
	end

	self.dirtyFlags[flag] = true
end

function TopLogoItemComponent:checkAndResetDirty(flag)
	if self.dirtyFlags[flag] then
		self.dirtyFlags[flag] = nil

		return true
	end

	return false
end

function TopLogoItemComponent:checkParentVisible()
	return self.topLogoItem and self.topLogoItem._realVisible
end

function TopLogoItemComponent:checkTopLogoCompUpdate()
	return self:checkParentVisible()
end

function TopLogoItemComponent:updateTopLogoComponent(distance)
	self.compDistance = distance

	local canUpdate = self:checkTopLogoCompUpdate()

	if self._inUpdate ~= canUpdate then
		self._inUpdate = canUpdate

		self:onTopLogoCompUpdateChanged(canUpdate)
	end

	if not self._inUpdate then
		return
	end

	self:onTopLogoCompUpdate()
	self:refreshVisible()
end

function TopLogoItemComponent:onTopLogoCompUpdateChanged(canUpdate)
	return
end

function TopLogoItemComponent:onTopLogoCompUpdate()
	return
end

function TopLogoItemComponent:refreshTopLogoInfo(callFromUpdate)
	return
end

function TopLogoItemComponent:innerUpdateTopLogo()
	return
end

function TopLogoItemComponent:findObjects()
	return
end

function TopLogoItemComponent:registerObjects()
	return
end

function TopLogoItemComponent:addEntityListener()
	return
end

function TopLogoItemComponent:restoreStateFromEntity()
	return
end

function TopLogoItemComponent:addListener()
	return
end

function TopLogoItemComponent:onCtor()
	self:refreshVisible()
end

function TopLogoItemComponent:initUI()
	self.refUContainer:SetActiveFastestAndMarkIgnoreLayout(true)

	if self.refUContainer and self.refUContainer.content then
		self.refUContainer:ProgressActive(true)
	end
end

function TopLogoItemComponent:setVisible(visible, visibleKey)
	visibleKey = visibleKey or UIConst.TOPLOGO_VISIBLE_KEY.DEFAULT

	if not visible then
		if self._visibleInfo[visibleKey] == false then
			return
		end

		self._visibleInfo[visibleKey] = false
	else
		if self._visibleInfo[visibleKey] == nil then
			return
		end

		self._visibleInfo[visibleKey] = nil
	end

	self:refreshVisible()
	self:notifyActiveStateChanged(self:shouldBeActive())
end

function TopLogoItemComponent:checkFinalVisible()
	return self._finalVisible
end

function TopLogoItemComponent:checkSelfVisible()
	return self._selfVisible
end

function TopLogoItemComponent:innerGetVisible()
	return Utils.tableIsEmptyOrNil(self._visibleInfo)
end

function TopLogoItemComponent:isActive()
	return Utils.tableIsEmptyOrNil(self._visibleInfo)
end

function TopLogoItemComponent:getInitMaxDistance()
	return nil
end

function TopLogoItemComponent:shouldBeActive()
	return self:isActive()
end

function TopLogoItemComponent:notifyActiveStateChanged(isActive)
	if self.topLogoItem and self.topLogoItem.onComponentActiveStateChanged then
		self.topLogoItem:onComponentActiveStateChanged(self.compName, isActive)
	end

	if self.entity and self.entity._syncShellMaxDistance then
		self.entity:_syncShellMaxDistance()
	end
end

function TopLogoItemComponent:notifyMaxDistanceChanged()
	if not self.topLogoItem or not self.entity then
		return
	end

	if self.entity._syncShellMaxDistance then
		self.entity:_syncShellMaxDistance()
	end
end

function TopLogoItemComponent:refreshVisible(skipRefresh)
	if self._deferredInitialization then
		local compVisible = self:innerGetVisible()

		self._selfVisible = compVisible
		self._finalVisible = compVisible and self:checkParentVisible()
		self._deferredRefreshPending = true

		return
	end

	self:m_clearInvalidRefUContainer()

	local compVisible = self:innerGetVisible()

	if self._selfVisible ~= compVisible then
		self._selfVisible = compVisible

		if self.refUContainer then
			self.refUContainer:SetActiveFastestAndMarkIgnoreLayout(compVisible)
		end
	end

	local finalVisible = compVisible and self:checkParentVisible()

	if self._finalVisible ~= finalVisible then
		self._finalVisible = finalVisible

		self:onTopLogoCompVisibleChanged(finalVisible, skipRefresh)

		return
	end

	if self._finalVisible and not skipRefresh then
		self:refreshTopLogoInfo(true)
	end
end

function TopLogoItemComponent:startTimer(func, delay, loop)
	if self.topLogoItem then
		return self.topLogoItem:startTimer(func, delay, loop)
	end
end

function TopLogoItemComponent:killTimer(timerId)
	if self.topLogoItem then
		self.topLogoItem:killTimer(timerId)
	end
end

function TopLogoItemComponent:checkAndLoadUContainerUrl()
	self:m_clearInvalidRefUContainer()

	if not self.refUContainer then
		return false
	end

	if not self.refContainersLoaded then
		if self.refUContainer:CheckURLLoaded() then
			self:onUContainerLoaded(true)

			return true
		end

		self.refUContainer:LoadDefaultUrlManually(function(retContent)
			self:onUContainerLoaded(retContent ~= nil)
		end)

		return self.refContainersLoaded
	end

	return true
end

function TopLogoItemComponent:m_tryLoadCompRootContainer()
	if self._deferredInitialization then
		self._deferredLoadPending = true

		return
	end

	self:m_clearInvalidRefUContainer()

	if self.refUContainer then
		return
	end

	if not self.topLogoItem or not self.topLogoItem.transform then
		return
	end

	local compName = self.compName

	if self.topLogoItem then
		self.topLogoItem:getOrAddCompRootContainer(compName, function(refUContainer, mCompName)
			self:m_onRootContainerLoaded(refUContainer, mCompName)
		end)
	end
end

function TopLogoItemComponent:m_onRootContainerLoaded(refUContainer, mCompName)
	if not refUContainer or IsNil(refUContainer) then
		return
	end

	local resetDefaultUrl = LuaTopLogoUtils.getTopLogoCompPrefabUrl(mCompName)

	self:m_clearInvalidRefUContainer()

	if self.refUContainer then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			local ent = self.topLogoItem and self.topLogoItem.entity or "nil"

			logger:error("TopLogoItemComponent:m_onRootContainerLoaded() refUContainer is not nil, entId=", ent and ent.actorId or "nil")
		end

		if self.refUContainer.defaultUrl ~= resetDefaultUrl then
			self.refUContainer.defaultUrl = resetDefaultUrl

			self.refUContainer:SetActive(true)
		end

		return
	end

	self.transform = refUContainer.transform
	self.refUContainer = refUContainer

	if not self.refUContainer or IsNil(self.refUContainer) or not self.transform or IsNil(self.transform) then
		self.refUContainer = nil
		self.transform = nil

		return
	end

	self.refUContainer.IsEnableAdaptChildRectSize = true
	self.refUContainer.defaultUrl = resetDefaultUrl

	self.refUContainer:SetActive(true)
	self.transform:SetLocalPositionEx(0, 0, 0)

	if self.refUContainer.IsEnableAdaptChildRectSize then
		self.transform:SetSizeDeltaEx(0, 0)
	end

	self.transform:SetLocalScaleEx(1, 1, 1)

	local compVisible = self:innerGetVisible()

	self._selfVisible = compVisible

	self.refUContainer:SetActiveFastestAndMarkIgnoreLayout(compVisible)
end

function TopLogoItemComponent:_consumeDeferredRefUContainer()
	local refUContainer = self._deferredRefUContainer
	local componentName = self._deferredComponentName

	if refUContainer == nil or IsNil(refUContainer) then
		return
	end

	self:m_onRootContainerLoaded(refUContainer, componentName)
end

function TopLogoItemComponent:m_recordDeferredLoadRequest(callback, cbFuncGroupId)
	local requests = self._deferredLoadRequests

	if not requests then
		requests = {}
		self._deferredLoadRequests = requests
	end

	if cbFuncGroupId then
		for i = 1, #requests do
			if requests[i].cbFuncGroupId == cbFuncGroupId then
				requests[i].callback = callback

				return
			end
		end
	end

	requests[#requests + 1] = {
		callback = callback,
		cbFuncGroupId = cbFuncGroupId
	}
end

function TopLogoItemComponent:completeDeferredInitialization(allowRefresh)
	if not self._deferredInitialization then
		return
	end

	self:addEntityListener()
	self:restoreStateFromEntity()
	self:_consumeDeferredRefUContainer()

	local loadRequests = self._deferredLoadRequests

	self._deferredInitialization = nil
	self._deferredRefUContainer = nil
	self._deferredComponentName = nil
	self._deferredRefreshPending = nil
	self._deferredLoadPending = nil
	self._deferredLoadRequests = nil

	if allowRefresh then
		self:refreshVisible()
	end

	for i = 1, #(loadRequests or EMPTY_TABLE) do
		local request = loadRequests[i]

		self:checkAndLoadUContainerUrlSupportAsync(request.callback, request.cbFuncGroupId)
	end
end

function TopLogoItemComponent:checkAndLoadUContainerUrlSupportAsync(callback, cbFuncGroupId)
	if self._deferredInitialization then
		self._deferredLoadPending = true

		self:m_recordDeferredLoadRequest(callback, cbFuncGroupId)

		return
	end

	self:m_clearInvalidRefUContainer()

	if not self.refUContainer then
		self:m_tryLoadCompRootContainer()
	end

	if not self.refUContainer then
		if callback then
			callback(false)
		end

		if LoggerManager.checkLogger(LoggerConst.ERROR) and self.topLogoItem and self.topLogoItem.transform then
			local tplName = self.topLogoItem:getTopLogoName() or "nil"

			logger:error("TopLogoItemComponent:checkAndLoadUContainerUrlSupportAsync() refUContainer is nil, tplName=%s; compName=%s", tplName, self.compName)
		end

		return
	end

	if self.refContainersLoaded then
		if callback then
			callback(true)
		end

		return
	end

	if callback then
		if cbFuncGroupId then
			self.m_onlyOneCallbacks = self.m_onlyOneCallbacks or {}
			self.m_onlyOneCallbacks[cbFuncGroupId] = callback
		else
			self.m_notOnlyOneCallbacks = self.m_notOnlyOneCallbacks or {}

			table.insert(self.m_notOnlyOneCallbacks, callback)
		end
	end

	if self._isRefContainersLoading then
		return
	end

	self._isRefContainersLoading = true

	if not self.m_loadedRefContainerCallback then
		function self.m_loadedRefContainerCallback(retContent)
			if self:m_clearInvalidRefUContainer() or not self.refUContainer then
				return
			end

			local isSuccess = retContent ~= nil

			if not isSuccess and LoggerManager.checkLogger(LoggerConst.ERROR) then
				local defContentUrl = self.refUContainer.defaultUrl or "nil"

				logger:error("ERROR LoadDefaultUrlManually failed, component=%s; topLogoName=%s; defContentUrl=%s", self.compName, self.topLogoItem and self.topLogoItem:getTopLogoName() or "nil", defContentUrl)
			end

			self:onUContainerLoaded(isSuccess)

			for _, cb in ipairs(self.m_notOnlyOneCallbacks or EMPTY_TABLE) do
				if cb then
					cb(isSuccess)
				end
			end

			for _, gCb in pairs(self.m_onlyOneCallbacks or EMPTY_TABLE) do
				if gCb then
					gCb(isSuccess)
				end
			end

			self:clearAysncLoadingInfo()
		end
	end

	self.refUContainer:LoadDefaultUrlManually(self.m_loadedRefContainerCallback)
end

function TopLogoItemComponent:checkContainerLoading()
	return self._isRefContainersLoading
end

function TopLogoItemComponent:clearAysncLoadingInfo()
	self._isRefContainersLoading = false
	self.m_onlyOneCallbacks = nil
	self.m_notOnlyOneCallbacks = nil
end

function TopLogoItemComponent:onLanguageChanged()
	if not self:checkContainerLoaded() then
		return
	end

	self:m_refreshStaticLocalization()
end

function TopLogoItemComponent:m_refreshStaticLocalization()
	if not self:checkContainerLoaded() then
		return
	end

	if IsNil(self.refUContainer) or IsNil(self.refUContainer.content) then
		return
	end

	local languageName = ClientConst.LANGUAGE_TYPE_DESC_MAP[pg.languageType or 0]

	if languageName then
		local components = self.refUContainer.content.transform:GetComponentsInChildren(typeof(CS.XGUI.UComponent), true)

		if components then
			for i = 1, components.Length do
				local component = components[i - 1]

				if NotNil(component) then
					component:TryChangePage("localization", languageName, true)
				end
			end
		end
	end

	local texts = self.refUContainer.content.transform:GetComponentsInChildren(typeof(CS.XGUI.UBaseText), true)

	if texts then
		for i = 1, texts.Length do
			local uText = texts[i - 1]

			if NotNil(uText) then
				uText:RefreshLocalization()
			end
		end
	end
end

function TopLogoItemComponent:onEnterCombat()
	return
end

function TopLogoItemComponent:onLeaveCombat()
	return
end

return TopLogoItemComponent
