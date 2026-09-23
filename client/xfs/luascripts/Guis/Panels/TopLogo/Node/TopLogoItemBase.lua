-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\Node\\TopLogoItemBase.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("TopLogoItemBase")
local Class = require("Core.Framework.Class")
local AddressDataConst = require("Const.AddressDataConst")
local UIConst = require("Const.UIConst")
local Utils = require("Common.Utils.Utils")
local TopLogoConst = require("Const.TopLogoConst")
local LuaTopLogoUtils = require("Utils.LuaTopLogoUtils")
local perFrameUpdateComponents = TopLogoConst.TOPLOGO_PER_FRAME_UPDATE_COMPONENTS
local Const = require("Const.Const")
local DisableGo = Const.RecycleGameObjectType.DisableGo
local EnableGo = Const.RecycleGameObjectType.EnableGo
local IsNil = IsNil
local NotNil = NotNil
local OpenCacheDebugName = TopLogoConst.OpenCacheDebugName

local function shouldComponentTickPerFrame(compName)
	return perFrameUpdateComponents and perFrameUpdateComponents[compName] == true
end

local function isExpectedNpcCombatMutex(compNames)
	if #compNames ~= 2 then
		return false
	end

	local firstCompName = compNames[1]
	local secondCompName = compNames[2]
	local npcCompName = UIConst.TOPLOGO_COMPONENT.NPC
	local combatCompName = UIConst.TOPLOGO_COMPONENT.COMBAT

	return firstCompName == npcCompName and secondCompName == combatCompName or firstCompName == combatCompName and secondCompName == npcCompName
end

local function tryGetRootContainerGameObject(rootContainerT)
	if IsNil(rootContainerT) then
		return nil
	end

	return rootContainerT.gameObject
end

local function tryGetGameObjectTransform(gameObject)
	if IsNil(gameObject) then
		return nil
	end

	return gameObject.transform
end

local function isValidRootContainerTransform(rootContainerT)
	return tryGetRootContainerGameObject(rootContainerT) ~= nil
end

local function tryGetRootContainerComponent(rootContainerT)
	if not isValidRootContainerTransform(rootContainerT) then
		return nil
	end

	local rootContainer = rootContainerT:GetComponent("UContainer")

	if NotNil(rootContainer) then
		return rootContainer
	end
end

local function tryFindChildTransform(parentT, childName)
	if not isValidRootContainerTransform(parentT) or Utils.strIsNilOrEmpty(childName) then
		return nil
	end

	local childT = parentT:Find(childName)

	if isValidRootContainerTransform(childT) then
		return childT
	end
end

local TopLogoItemBase = Class.LightClass("TopLogoItemBase")

function TopLogoItemBase:ctor(topLogoHelper)
	self.topLogoHelper = topLogoHelper or pg.global.ui.topLogo.topLogoHelper
	self.ctrl = self.topLogoHelper.ctrl
	self.visible = true
	self._realVisible = nil
	self.distance = 0
	self.components = {}
	self.activeComps = {}
	self.silenceComps = {}
	self._otherCompVisiblePolicies = {}
	self._tickComps = {}
	self.initInfo = nil
	self._timerIds = {}
	self.refContainers = nil
	self.resId = self.resId or AddressDataConst.TOPLOGO_TOP_RESID
	self.topLogoGlobalId = self:getTopLogoGlobalId()

	self.topLogoHelper:registerTopLogo(self.topLogoGlobalId, self)

	self.taskId = 0
	self.cacheZoneRootContainerTransforms = nil
	self._loadVersion = 0

	self:onCtor()
end

function TopLogoItemBase:destroy()
	self._destroying = true

	if self.topLogoGlobalId then
		self.topLogoHelper:unRegisterTopLogo(self.topLogoGlobalId)

		self.topLogoGlobalId = nil
	end

	self:onDestroy()
	self:killAllTimer()
	self:destroyTopLogo()

	if self.components and next(self.components) then
		for _, component in pairs(self.components) do
			if component and component.destroy then
				component:destroy()
			end
		end

		self.components = {}
		self.activeComps = {}
		self.silenceComps = {}
		self._tickComps = {}
	end

	self.isDestroyed = true
	self._destroying = nil
	self._constructingComponents = nil
	self._constructionComponentName = nil
	self._initializingComponents = nil
	self._initializingLogicComponents = nil
	self._otherCompVisiblePolicies = nil
end

function TopLogoItemBase:onTopLogoCtrlDestroy()
	if not self.isDestroyed then
		self:destroy()
	end
end

function TopLogoItemBase:getTopLogoGlobalId()
	return self.topLogoHelper:genNoEntTopLogoGlobalId()
end

function TopLogoItemBase:getTopLogoName()
	return "TopLogoItemBase"
end

function TopLogoItemBase:checkCreate()
	if self.taskId ~= 0 then
		return true
	end

	return self.objectInfo ~= nil
end

function TopLogoItemBase:isTopLogoPrefabReady()
	return NotNil(self.transform)
end

function TopLogoItemBase:createTopLogo(callback, initInfo)
	if self:checkCreate() then
		return
	end

	self.initInfo = initInfo
	self.callback = callback
	self._loadVersion = (self._loadVersion or 0) + 1

	local myVersion = self._loadVersion

	local function onLoaded(objInfo)
		self:_handleLoadCallback(objInfo, myVersion)
	end

	self.taskId = self.topLogoHelper:getTopLogoPrefab(self.resId, onLoaded)
end

function TopLogoItemBase:_handleLoadCallback(objInfo, version)
	if self.isDestroyed or self._loadVersion ~= version then
		if objInfo and objInfo.gameObject then
			self.topLogoHelper:destroyInstance(objInfo.gameObject)
		end

		return
	end

	if not objInfo then
		return
	end

	local loadSuccess = false

	if objInfo.cached then
		self:_onTopLogoLoaded(objInfo)

		loadSuccess = true
	else
		local gameObject = objInfo.gameObject

		if gameObject then
			local topLogoScript = objInfo.transform:GetComponent("TopLogo")

			if topLogoScript then
				objInfo.cached = true
				objInfo.topLogoScript = topLogoScript
				objInfo.objectReference = objInfo.transform:GetComponent("ObjectReference")

				self:_onTopLogoLoaded(objInfo)

				loadSuccess = true
			else
				self.topLogoHelper:destroyInstance(gameObject)
			end
		end
	end

	if loadSuccess and self.callback and not self.isDestroyed then
		self.callback()
	end
end

function TopLogoItemBase:destroyTopLogo()
	self._realVisible = false

	if not self:checkCreate() then
		return
	end

	self:onTopLogoDestroy()

	for _, component in pairs(self.components or EMPTY_TABLE) do
		if component and component.resetRender then
			component:resetRender()
		end
	end

	self:_returnAllRootUContainers()

	if self.taskId ~= 0 then
		self.topLogoHelper:cancelUIAsyncTask(self.taskId)

		self.taskId = 0
	end

	self._loadVersion = (self._loadVersion or 0) + 1

	if self.objectInfo then
		self.topLogoScript:AttachToTrans(nil)
		self.topLogoScript:SetMonoEnabled(false)

		local refContainers = self:resetTopLogoPrefab()

		self.objectInfo.refContainers = refContainers

		self.topLogoHelper:returnTopLogoPrefab(self.resId, self.objectInfo)
	end

	self.objectInfo = nil
	self.transform = nil
	self.gameObject = nil
	self.topLogoScript = nil
	self.mainTransform = nil
end

function TopLogoItemBase:updateTopLogoItem(distance)
	self.distance = distance

	for _, component in pairs(self._tickComps) do
		if component and component.updateTopLogoComponent then
			component:updateTopLogoComponent(distance)
		end
	end
end

function TopLogoItemBase:_onTopLogoLoaded(objectInfo)
	self.objectInfo = objectInfo
	self.gameObject = objectInfo.gameObject
	self.topLogoScript = objectInfo.topLogoScript
	self.transform = objectInfo.transform

	self.topLogoScript:ForceInitWidget()

	self._lastPushedVisible = nil

	self:refreshTopLogoVisible()
	self:setEnableRaycast(self.enableRaycast, true)
	self.topLogoScript:SetLuaProxy(self)
	self.topLogoScript:SetMonoEnabled(true)

	self._realVisible = self.topLogoScript.curVisible

	if OpenCacheDebugName then
		objectInfo.gameObject.name = self:getTopLogoName()
	end

	self.objectReference = objectInfo.objectReference
	self.refContainers = objectInfo.refContainers or {}

	self:onTopLogoLoaded()
end

function TopLogoItemBase:resetTopLogoPrefab()
	self:onTopLogoReset()

	local refContainers = self:clearRefContainers()

	if pg.game.setting.useTopLogoCache and NotNil(self.topLogoScript) then
		self.topLogoScript:ForceInitWidget()
		self.topLogoScript:ResetState()
	end

	return refContainers
end

function TopLogoItemBase:clearRefContainers()
	local refContainers = self.refContainers

	if refContainers then
		for refName, container in pairs(refContainers) do
			if not container.enableLoadOnInit then
				container.url = nil
			end
		end

		self.refContainers = nil
	end

	return refContainers
end

function TopLogoItemBase:onTopLogoReset()
	return
end

function TopLogoItemBase:getContainerAndAddRef(refName)
	if self.objectReference then
		local container = self.objectReference:GetRefValue(refName)

		if container then
			container = container:GetComponent("UContainer")
			self.refContainers[refName] = container

			return container
		end
	end

	return nil
end

function TopLogoItemBase:onTopLogoItemRealVisibleChanged(visible)
	self._realVisible = visible

	for _, component in pairs(self.components) do
		if component.onParentVisibleChanged then
			component:onParentVisibleChanged(visible)
		end
	end
end

function TopLogoItemBase:setTopLogoVisible(visible)
	self.visible = visible

	self:refreshTopLogoVisible()
end

function TopLogoItemBase:getTopLogoVisible()
	return self.visible
end

function TopLogoItemBase:getFinalTopLogoVisible()
	return self:getTopLogoVisible()
end

function TopLogoItemBase:refreshTopLogoVisible()
	if self.topLogoScript then
		local finalVisible = self:getFinalTopLogoVisible()

		if self._lastPushedVisible ~= finalVisible then
			self._lastPushedVisible = finalVisible

			self.topLogoScript:SetVisible(finalVisible)
		end
	end
end

function TopLogoItemBase:setEnableRaycast(enableRaycast, forceRefresh)
	if forceRefresh or self.enableRaycast ~= enableRaycast then
		self.enableRaycast = enableRaycast
	end
end

function TopLogoItemBase:onTopLogoDestroy()
	return
end

function TopLogoItemBase:onTopLogoLoaded()
	self:initTopLogoAttach()
	self:findObjects()
	self:m_classifyComponents()
	pg.game.topLogo:setTopLogoComponentGlobalVisible(self)
	self:m_refreshActiveComponents()
	self:refreshTopLogoItemOnLoaded()

	if self.entity and self.entity.refreshTopLogoHeight then
		self.entity:refreshTopLogoHeight()
	end
end

function TopLogoItemBase:startTimer(func, delay, loop)
	local timerId = self.ctrl:startTimer(func, delay, loop)

	self._timerIds[timerId] = loop

	return timerId
end

function TopLogoItemBase:killTimer(timerId)
	if not timerId then
		return
	end

	self.ctrl:killTimer(timerId)

	self._timerIds[timerId] = nil
end

function TopLogoItemBase:killAllTimer()
	for timerId, loop in pairs(self._timerIds) do
		self.ctrl:killTimer(timerId)
	end

	self._timerIds = {}
end

function TopLogoItemBase:initTopLogoAttach()
	return
end

function TopLogoItemBase:findObjects()
	return
end

function TopLogoItemBase:createLogicComponents()
	return
end

function TopLogoItemBase:_classifyComponent(compName, comp)
	self.activeComps = self.activeComps or {}
	self.silenceComps = self.silenceComps or {}
	self._tickComps = self._tickComps or {}
	self.activeComps[compName] = nil
	self.silenceComps[compName] = nil
	self._tickComps[compName] = nil

	if not comp then
		return
	end

	if comp:shouldBeActive() then
		self.activeComps[compName] = comp

		if shouldComponentTickPerFrame(compName) then
			self._tickComps[compName] = comp
		end
	else
		self.silenceComps[compName] = comp
	end
end

function TopLogoItemBase:m_classifyComponents()
	self.activeComps = {}
	self.silenceComps = {}
	self._tickComps = {}

	for name, comp in pairs(self.components or EMPTY_TABLE) do
		comp.compName = name

		self:_classifyComponent(name, comp)
	end
end

function TopLogoItemBase:m_refreshActiveComponents()
	if not next(self.activeComps) then
		return
	end

	for _, comp in pairs(self.activeComps) do
		comp:refreshTopLogoInfo()
	end
end

function TopLogoItemBase:onComponentActiveStateChanged(compName, isActive)
	if self._initializingComponents and self._initializingComponents[compName] then
		return
	end

	local comp = self.components[compName]

	if not comp then
		return
	end

	if isActive then
		self.activeComps[compName] = comp
		self.silenceComps[compName] = nil

		if shouldComponentTickPerFrame(compName) then
			self._tickComps[compName] = comp
		end

		if not comp:isActive() then
			return
		end

		if not self:checkCreate() then
			local entity = self.entity

			if entity and entity._isInTopLogoEnterRange and not entity:_isInTopLogoEnterRange() then
				return
			end

			self:onActiveCompsNonEmpty()
		end
	else
		self.activeComps[compName] = nil
		self.silenceComps[compName] = comp
		self._tickComps[compName] = nil
	end
end

function TopLogoItemBase:onActiveCompsNonEmpty()
	return
end

function TopLogoItemBase:refreshTopLogoItemOnLoaded()
	return
end

function TopLogoItemBase:onCtor()
	self.multiType = TopLogoConst.MULTI_TOPLOGO_ATTACH_TYPE.TOP

	for typeId, resIds in pairs(TopLogoConst.TOPLOGO_RES_FRAME_CONFIG) do
		if resIds then
			for _, resId in pairs(resIds) do
				if resId == self.resId then
					self.multiType = typeId

					break
				end
			end
		end
	end
end

function TopLogoItemBase:onDestroy()
	return
end

function TopLogoItemBase:getOrAddCompRootContainer(componentName, callBack)
	local zoneName = LuaTopLogoUtils.getTopLogoCompZoneName(componentName)
	local rootContainerGo = self:getOrAddCompRootContainerGo(componentName)
	local rootContainerT = tryGetGameObjectTransform(rootContainerGo)
	local rootContainer = tryGetRootContainerComponent(rootContainerT)

	if isValidRootContainerTransform(rootContainerT) and rootContainer then
		if callBack then
			callBack(rootContainer, componentName)
		end

		self:resetZoneSibling(zoneName)
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("m_tryLoadCompRootContainer failed, topLogoName=%s, compoName=%s", self:getTopLogoName(), componentName)
	end
end

function TopLogoItemBase:_isCurrentTopLogoContainer(containerT)
	if not isValidRootContainerTransform(containerT) or IsNil(self.transform) then
		return false
	end

	local current = containerT

	while current and not IsNil(current) do
		if current == self.transform then
			return true
		end

		current = current.parent
	end

	return false
end

function TopLogoItemBase:getOrAddCompRootContainerGo(componentName)
	local cacheRet = self:getRootUContainer(componentName)
	local cacheGo = tryGetRootContainerGameObject(cacheRet)

	if cacheGo and self:_isCurrentTopLogoContainer(cacheRet) then
		cacheGo:RecycleCacheGameObject(EnableGo)

		return cacheGo
	end

	if cacheRet then
		self:resetCacheRootUContainer(componentName)
	end

	local isLogError = LoggerManager.checkLogger(LoggerConst.ERROR)
	local topLogoView = self.topLogoHelper and self.topLogoHelper.view

	if not topLogoView then
		if isLogError then
			logger:error("getOrAddCompRootContainerGo topLogoView is nil")
		end

		return
	end

	local parentZoneName = LuaTopLogoUtils.getTopLogoCompZoneName(componentName)
	local parentZoneT = self:findZoneTransform(parentZoneName)

	if not isValidRootContainerTransform(parentZoneT) then
		if isLogError then
			logger:error("getOrAddCompRootContainerGo parentZoneT is nil, topLogoName=%s, compoName=%s; zoneName=%s", self:getTopLogoName(), componentName, parentZoneName)
		end

		return
	end

	local newName = LuaTopLogoUtils.getTopLogoCompRootContainerGoName(componentName)

	if newName then
		local rootContainerT = tryFindChildTransform(parentZoneT, newName)
		local rootContainerGo = tryGetRootContainerGameObject(rootContainerT)

		if rootContainerGo then
			rootContainerGo:RecycleCacheGameObject(EnableGo)
			self:pushRootUContainer(componentName, rootContainerT, newName)

			return rootContainerGo
		end
	end

	local compRootContainerUrl = AddressDataConst.TOPLOGO_COMP_ROOTCONTAINER_GENERAL
	local rootContainerGo = self.topLogoHelper:getTopLogoUContainerGo(parentZoneT, compRootContainerUrl)
	local rootContainerT = tryGetGameObjectTransform(rootContainerGo)

	if isValidRootContainerTransform(rootContainerT) then
		rootContainerGo:RecycleCacheGameObject(EnableGo)
		self:pushRootUContainer(componentName, rootContainerT, newName)

		return rootContainerGo
	end
end

function TopLogoItemBase:pushRootUContainer(componentName, rootContainerT, newName)
	if not componentName or not isValidRootContainerTransform(rootContainerT) then
		return
	end

	local zoneName = LuaTopLogoUtils.getTopLogoCompZoneName(componentName)

	if not zoneName then
		return
	end

	self.cacheZoneRootContainerTransforms = self.cacheZoneRootContainerTransforms or {}
	self.cacheZoneRootContainerTransforms[zoneName] = self.cacheZoneRootContainerTransforms[zoneName] or {}
	self.cacheZoneRootContainerTransforms[zoneName][componentName] = rootContainerT

	if newName then
		local rootContainerGo = tryGetRootContainerGameObject(rootContainerT)

		if rootContainerGo then
			rootContainerGo.name = newName
		end
	end
end

function TopLogoItemBase:getRootUContainer(componentName)
	if not componentName then
		return nil
	end

	local zoneName = LuaTopLogoUtils.getTopLogoCompZoneName(componentName)

	if not zoneName then
		return nil
	end

	self.cacheZoneRootContainerTransforms = self.cacheZoneRootContainerTransforms or {}
	self.cacheZoneRootContainerTransforms[zoneName] = self.cacheZoneRootContainerTransforms[zoneName] or {}

	local cachedTransform = self.cacheZoneRootContainerTransforms[zoneName][componentName]

	if cachedTransform ~= nil and not isValidRootContainerTransform(cachedTransform) then
		self.cacheZoneRootContainerTransforms[zoneName][componentName] = nil

		return nil
	end

	return cachedTransform
end

function TopLogoItemBase:findZoneTransform(zoneName)
	if Utils.strIsNilOrEmpty(zoneName) then
		return nil
	end

	if IsNil(self.transform) then
		return
	end

	local zoneTransform = self.transform:Find(zoneName)

	if isValidRootContainerTransform(zoneTransform) then
		return zoneTransform
	end
end

function TopLogoItemBase:resetCacheRootUContainer(componentName)
	if componentName then
		local zoneName = LuaTopLogoUtils.getTopLogoCompZoneName(componentName)

		if zoneName then
			self.cacheZoneRootContainerTransforms = self.cacheZoneRootContainerTransforms or {}

			if self.cacheZoneRootContainerTransforms and self.cacheZoneRootContainerTransforms[zoneName] and self.cacheZoneRootContainerTransforms[zoneName][componentName] then
				self.cacheZoneRootContainerTransforms[zoneName][componentName] = nil
			end
		end
	end
end

function TopLogoItemBase:_returnAllRootUContainers()
	if not self.cacheZoneRootContainerTransforms then
		return
	end

	for _, zoneMap in pairs(self.cacheZoneRootContainerTransforms) do
		for _, containerT in pairs(zoneMap) do
			local containerGo = tryGetRootContainerGameObject(containerT)

			if containerGo then
				containerGo:RecycleCacheGameObject(DisableGo)
			end
		end
	end
end

function TopLogoItemBase:resetZoneSibling(zoneName)
	local resetZone = self.cacheZoneRootContainerTransforms and self.cacheZoneRootContainerTransforms[zoneName] or {}
	local compConfigs = LuaTopLogoUtils.getTopLogoZoneGroupConfigs(self.multiType, zoneName)

	if not compConfigs then
		return
	end

	local sortedComponents = {}
	local mutexGroupCheck = {}

	for _, compName in ipairs(compConfigs) do
		local config = LuaTopLogoUtils.getTopLogoCompZoneConfig(compName)
		local checkTransform = resetZone[compName]

		if isValidRootContainerTransform(checkTransform) then
			if config.mutexGroup then
				mutexGroupCheck[config.mutexGroup] = mutexGroupCheck[config.mutexGroup] or {}

				table.insert(mutexGroupCheck[config.mutexGroup], compName)
			end

			local sortValue = config.sort or math.huge

			table.insert(sortedComponents, {
				compName = compName,
				transform = checkTransform,
				sort = sortValue
			})
		elseif checkTransform ~= nil then
			resetZone[compName] = nil
		end
	end

	if LoggerManager.checkLogger(LoggerConst.ERROR) and mutexGroupCheck then
		for _, compNames in pairs(mutexGroupCheck) do
			if #compNames >= 2 and not isExpectedNpcCombatMutex(compNames) then
				local mutexGroupStr = table.concat(compNames, ", ")

				logger:error("%s-topLogo 存在互斥组件, [%s]", self.entity.actorId, mutexGroupStr)
			end
		end
	end

	table.sort(sortedComponents, function(a, b)
		return a.sort < b.sort
	end)

	for index, compInfo in ipairs(sortedComponents) do
		if isValidRootContainerTransform(compInfo.transform) then
			compInfo.transform:SetSiblingIndex(index - 1)
		elseif resetZone[compInfo.compName] == compInfo.transform then
			resetZone[compInfo.compName] = nil
		end
	end
end

function TopLogoItemBase:peekToplogoComponent(componentName)
	return self.components and self.components[componentName]
end

TopLogoItemBase.getToplogoComponent = TopLogoItemBase.peekToplogoComponent

local function cloneOtherCompNames(componentNames)
	if componentNames == nil then
		return {}
	end

	if type(componentNames) ~= "table" then
		return componentNames
	end

	local snapshot = {}

	for componentName, value in pairs(componentNames) do
		snapshot[componentName] = value
	end

	return snapshot
end

local function isOtherCompPolicyRetained(componentNames, componentName)
	if type(componentNames) == "table" then
		return componentNames[componentName] == true
	end

	return componentNames == componentName
end

function TopLogoItemBase:applyOtherCompsVisiblePolicies(componentName, component)
	if not component then
		return
	end

	for visibleKey, componentNames in pairs(self._otherCompVisiblePolicies or EMPTY_TABLE) do
		if not isOtherCompPolicyRetained(componentNames, componentName) then
			component:setVisible(false, visibleKey)
		end
	end
end

function TopLogoItemBase:setOtherCompsVisible(componentNames, visibleKey, visible)
	visibleKey = visibleKey or UIConst.TOPLOGO_VISIBLE_KEY.DEFAULT
	visible = visible == true

	local componentNamesSnapshot = cloneOtherCompNames(componentNames)

	self._otherCompVisiblePolicies = self._otherCompVisiblePolicies or {}

	local componentNamesToApply = componentNamesSnapshot
	local previousComponentNames = self._otherCompVisiblePolicies[visibleKey]

	if visible then
		componentNamesToApply = previousComponentNames or componentNamesSnapshot
	else
		self._otherCompVisiblePolicies[visibleKey] = componentNamesSnapshot
	end

	for componentName, component in pairs(self.components or EMPTY_TABLE) do
		if not isOtherCompPolicyRetained(componentNamesToApply, componentName) then
			component:setVisible(visible, visibleKey)
		elseif not visible and previousComponentNames ~= nil and not isOtherCompPolicyRetained(previousComponentNames, componentName) then
			component:setVisible(true, visibleKey)
		end
	end

	if visible then
		self._otherCompVisiblePolicies[visibleKey] = nil
	end
end

function TopLogoItemBase:getLogicComponentDefinition(componentName)
	return nil
end

function TopLogoItemBase:isDeferringComponentInitialization(componentName)
	componentName = componentName or self._constructionComponentName

	return self._constructingComponents ~= nil and self._constructingComponents[componentName] == true, componentName
end

function TopLogoItemBase:_isDefinitionEligible(definition)
	if not definition then
		return false
	end

	if not definition.isEligible then
		return true
	end

	return definition.isEligible(self) == true
end

function TopLogoItemBase:_applyInitPolicies(componentName, component)
	local topLogoSystem = pg and pg.game and pg.game.topLogo

	if topLogoSystem and topLogoSystem.applyGlobalVisibleToComponent then
		topLogoSystem:applyGlobalVisibleToComponent(componentName, component)
	end

	if self.topLogoHelper and self.topLogoHelper.applyTopLogoComponentVisiblePolicies then
		self.topLogoHelper:applyTopLogoComponentVisiblePolicies(componentName, component)
	end

	if self.applyOtherCompsVisiblePolicies then
		self:applyOtherCompsVisiblePolicies(componentName, component)
	end
end

local function clearComponentGuard(item, guardName, componentName)
	local guard = item[guardName]

	if not guard then
		return
	end

	guard[componentName] = nil

	if next(guard) == nil then
		item[guardName] = nil
	end
end

local function clearComponentInitializationGuards(item, componentName, previousComponentName)
	clearComponentGuard(item, "_constructingComponents", componentName)
	clearComponentGuard(item, "_initializingComponents", componentName)

	if item._constructionComponentName == componentName then
		item._constructionComponentName = previousComponentName
	end
end

function TopLogoItemBase:ensureToplogoComponent(componentName, reason)
	if self.isDestroyed or self._destroying or not self.entity then
		return nil
	end

	if self._constructingComponents and self._constructingComponents[componentName] then
		return nil
	end

	self.components = self.components or {}

	local resident = self.components[componentName]

	if resident then
		return resident
	end

	self._constructingComponents = self._constructingComponents or {}
	self._initializingComponents = self._initializingComponents or {}

	local previousComponentName = self._constructionComponentName

	self._constructingComponents[componentName] = true
	self._initializingComponents[componentName] = true
	self._constructionComponentName = componentName

	local definition = self:getLogicComponentDefinition(componentName)

	if not definition or not definition.create or not self:_isDefinitionEligible(definition) then
		clearComponentInitializationGuards(self, componentName, previousComponentName)

		return nil
	end

	local component = definition.create(self)

	if component then
		component.compName = componentName
	end

	local isValidComponent = component and component.compName == componentName and component.completeDeferredInitialization

	if not isValidComponent then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("TopLogo component factory returned an invalid component: %s", tostring(componentName))
		end

		self.components[componentName] = nil

		if self.activeComps then
			self.activeComps[componentName] = nil
		end

		if self.silenceComps then
			self.silenceComps[componentName] = nil
		end

		if self._tickComps then
			self._tickComps[componentName] = nil
		end

		if component and component.destroy then
			component:destroy()
		end

		clearComponentInitializationGuards(self, componentName, previousComponentName)

		return nil
	end

	self.components[componentName] = component

	if self._applyInitPolicies then
		self:_applyInitPolicies(componentName, component)
	end

	component:completeDeferredInitialization(false)

	if not self._initializingLogicComponents then
		self:_classifyComponent(componentName, component)
	end

	clearComponentInitializationGuards(self, componentName, previousComponentName)

	if not self._initializingLogicComponents then
		if self.activeComps and self.activeComps[componentName] == component and component.isActive and component:isActive() then
			if self:isTopLogoPrefabReady() then
				if component.refreshVisible then
					component:refreshVisible()
				end
			elseif not self:checkCreate() then
				local entity = self.entity
				local shouldNotifyActiveCompsNonEmpty = not entity or not entity._isInTopLogoEnterRange or entity:_isInTopLogoEnterRange()

				if shouldNotifyActiveCompsNonEmpty then
					self:onActiveCompsNonEmpty()
				end
			end
		end

		if self.entity and self.entity._syncShellMaxDistance then
			self.entity:_syncShellMaxDistance()
		end
	end

	return component
end

function TopLogoItemBase:initializeLogicComponents(definitions)
	self._initializingLogicComponents = true

	for _, definition in ipairs(definitions and definitions.ordered or EMPTY_TABLE) do
		if self:_isDefinitionEligible(definition) then
			local shouldCreate = not definition.lazy

			if definition.lazy and definition.shouldCreateInitially then
				shouldCreate = definition.shouldCreateInitially(self) == true
			end

			if shouldCreate then
				self:ensureToplogoComponent(definition.componentName)
			end
		end
	end

	self._initializingLogicComponents = nil

	self:m_classifyComponents()

	if self.entity and self.entity._syncShellMaxDistance then
		self.entity:_syncShellMaxDistance()
	end

	return self.components
end

function TopLogoItemBase:getEffectiveMaxDistance()
	local maxDist = 0

	for _, comp in pairs(self.activeComps or EMPTY_TABLE) do
		local d = comp:getInitMaxDistance()

		if d and maxDist < d then
			maxDist = d
		end
	end

	return maxDist > 0 and maxDist or UIConst.TopLogoEnterRange
end

function TopLogoItemBase:onLanguageChanged()
	for _, comp in pairs(self.components or EMPTY_TABLE) do
		if comp.onLanguageChanged then
			comp:onLanguageChanged()
		end
	end
end

function TopLogoItemBase:onEnterCombat()
	for _, comp in pairs(self.activeComps or EMPTY_TABLE) do
		comp:onEnterCombat()
	end
end

function TopLogoItemBase:onLeaveCombat()
	for _, comp in pairs(self.activeComps or EMPTY_TABLE) do
		comp:onLeaveCombat()
	end
end

return TopLogoItemBase
