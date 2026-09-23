-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\UIBridge\\ImpPlatformTopLogoCombatComponent.lua

local M = {}
local Utils = require("Common.Utils.Utils")
local PlatformNameMaskService = require("SDK.Platform.PlatformNameMaskService")
local PlatformPetNameMaskService = require("SDK.Platform.PlatformPetNameMaskService")
local PlatformNameMaskRefreshHelper = require("SDK.Platform.PlatformNameMaskRefreshHelper")
local PlatformDisplayNameInjector = require("SDK.Platform.UIBridge.PlatformDisplayNameInjector")
local PlatformDisplayNameConfig = require("SDK.Platform.UIBridge.PlatformDisplayNameConfig")
local PlatformIdentityUtils = require("SDK.Platform.PlatformIdentityUtils")
local PlatformPlayerInfoQueryService = require("SDK.Platform.PlatformPlayerInfoQueryService")

M.CONFIG = PlatformDisplayNameConfig.UI_Node_Toplogo_HP
M.SwitchQueryState = {
	Completed = "completed",
	Pending = "pending"
}
M.switchQueryStates = {}

function M.isMissingTargetUGCSwitch(playerInfo)
	if type(playerInfo) ~= "table" then
		return false
	end

	local identity = PlatformIdentityUtils.resolvePlayerIdentity(playerInfo) or {}
	local switch = identity.platformUGCSwitch

	if switch == nil then
		switch = playerInfo.platformUGCSwitch
	end

	return switch == nil
end

M.DISPLAY_FIELDS = {
	"uid",
	"playerId",
	"playerName"
}
M.IDENTITY_FIELDS = {
	"platformDisplayName",
	"platformUserId",
	"platformFamily",
	"platform",
	"os",
	"isAllowedCrossPlatform",
	"platformUGCSwitch"
}
M.CONSOLE_IDENTITY_FIELDS = {
	"platformDisplayName",
	"platformUserId"
}

function M.isMissing(value)
	return value == nil or value == ""
end

function M.readField(source, fieldName)
	if source == nil then
		return nil
	end

	local success, value = pcall(function()
		return source[fieldName]
	end)

	if not success then
		return nil
	end

	return value
end

function M.getPlayerFamily(playerInfo)
	if PlatformIdentityUtils.resolvePlayerInfoFamily then
		return PlatformIdentityUtils.resolvePlayerInfoFamily(playerInfo)
	end

	local identity = PlatformIdentityUtils.resolvePlayerIdentity(playerInfo) or {}

	return identity.platformFamily
end

function M.isConsolePlayerInfo(playerInfo)
	local family = M.getPlayerFamily(playerInfo)

	return PlatformIdentityUtils.isConsoleFamily and PlatformIdentityUtils.isConsoleFamily(family) == true
end

function M.shouldRequeryMissingTargetUGCSwitch()
	if not PlatformNameMaskService.isCurrentConsoleFamily() then
		return false
	end

	return PlatformIdentityUtils.getCurrentPlatformFamily() ~= PlatformIdentityUtils.Family.PlayStation
end

function M.assertRequiredIdentity(playerInfo)
	if M.isMissing(playerInfo.platformFamily) then
		error("TopLogo playerInfo missing required field: platformFamily")
	end

	if not M.isConsolePlayerInfo(playerInfo) then
		return
	end

	for _, fieldName in ipairs(M.CONSOLE_IDENTITY_FIELDS) do
		if not playerInfo or M.isMissing(playerInfo[fieldName]) then
			error(string.format("TopLogo playerInfo missing required field: %s", fieldName))
		end
	end
end

M.REQUIRED_IDENTITY_FIELDS = {
	"platformFamily"
}
M.OwnerInfoQueryState = {
	Pending = "pending"
}

function M.getOwnerPlayerInfoQueryKey(uid, refreshMethodName)
	return tostring(refreshMethodName or "") .. ":" .. tostring(uid or "")
end

function M.getOwnerPlayerInfoQueryStates(component)
	if component == nil then
		return nil
	end

	component._platformTopLogoOwnerInfoQueryStates = component._platformTopLogoOwnerInfoQueryStates or {}

	return component._platformTopLogoOwnerInfoQueryStates
end

function M.getOwnerPlayerInfoQueryState(component, uid, refreshMethodName)
	local states = M.getOwnerPlayerInfoQueryStates(component)

	if states == nil then
		return nil
	end

	return states[M.getOwnerPlayerInfoQueryKey(uid, refreshMethodName)]
end

function M.setOwnerPlayerInfoQueryState(component, uid, refreshMethodName, state)
	local states = M.getOwnerPlayerInfoQueryStates(component)

	if states == nil then
		return
	end

	states[M.getOwnerPlayerInfoQueryKey(uid, refreshMethodName)] = state
end

function M.copyPlayerInfo(playerInfo)
	local copiedInfo = {}

	for _, fieldName in ipairs(M.DISPLAY_FIELDS) do
		copiedInfo[fieldName] = M.readField(playerInfo, fieldName)
	end

	local identity = PlatformIdentityUtils.resolvePlayerIdentity(playerInfo) or {}

	for _, fieldName in ipairs(M.IDENTITY_FIELDS) do
		copiedInfo[fieldName] = identity[fieldName]
	end

	M.assertRequiredIdentity(copiedInfo)

	return copiedInfo
end

function M.resolveDisplayInfo(playerInfo)
	return M.copyPlayerInfo(playerInfo)
end

function M.isObjectAlive(obj)
	if obj == nil then
		return false
	end

	if type(NotNil) == "function" then
		return NotNil(obj)
	end

	return true
end

function M.isComponentAlive(component, boundEntity)
	if not component or component.entity ~= boundEntity then
		return false
	end

	if type(component.checkContainerLoaded) == "function" and not component:checkContainerLoaded() then
		return false
	end

	return M.isObjectAlive(component.refUContainer) and M.isObjectAlive(component.objectReference)
end

function M.isSameUid(left, right)
	return left ~= nil and right ~= nil and tostring(left) == tostring(right)
end

function M.getCachedPlayerInfo(uid)
	if string.isNilOrEmpty(uid) then
		return nil
	end

	return pg.game.chat:getPlayerInfo(uid)
end

function M.requestOwnerPlayerInfo(uid, component, refreshMethodName, onResolved)
	if string.isNilOrEmpty(uid) or component == nil then
		return false
	end

	local state = M.getOwnerPlayerInfoQueryState(component, uid, refreshMethodName)

	if state ~= nil then
		return false
	end

	local boundEntity = component.entity

	M.setOwnerPlayerInfoQueryState(component, uid, refreshMethodName, M.OwnerInfoQueryState.Pending)

	local sent = PlatformPlayerInfoQueryService:requestLatest(uid, PlatformPlayerInfoQueryService.RequestPurpose.TopLogoUGCOwner, {
		force = true,
		requestKey = component
	}, function(ok, playerInfo)
		if type(onResolved) == "function" then
			onResolved(ok == true and playerInfo ~= nil, playerInfo)
		end

		if ok == true and playerInfo ~= nil then
			M.setOwnerPlayerInfoQueryState(component, uid, refreshMethodName, nil)

			if M.isComponentAlive(component, boundEntity) and type(component[refreshMethodName]) == "function" then
				component[refreshMethodName](component, true)
			end

			return
		end

		M.setOwnerPlayerInfoQueryState(component, uid, refreshMethodName, nil)
	end)

	if sent ~= true and M.getOwnerPlayerInfoQueryState(component, uid, refreshMethodName) == M.OwnerInfoQueryState.Pending then
		M.setOwnerPlayerInfoQueryState(component, uid, refreshMethodName, nil)
	end

	return sent == true
end

function M.isLocalPlayerUid(uid)
	return M.isSameUid(uid, pg.me.uid)
end

function M.getTopLogoDisplayPlayerInfo(playerInfo)
	return M.resolveDisplayInfo(playerInfo)
end

function M.getTopLogoUGCOwnerInfo(entity)
	if not entity then
		return nil, nil
	end

	if Utils.isPet(entity) or Utils.isPlayerPet(entity) then
		local masterEnt = entity.getMasterEntity and entity:getMasterEntity() or nil
		local ownerUid = masterEnt and masterEnt.uid or entity.ownerUid or entity.playerUID

		return ownerUid, M.getCachedPlayerInfo(ownerUid)
	end

	if Utils.isPlayer(entity) then
		local ownerUid = entity.uid

		return ownerUid, M.getCachedPlayerInfo(ownerUid)
	end

	return nil, nil
end

function M.getPetConfigName(entity)
	if not entity or not Utils.isPet(entity) and not Utils.isPlayerPet(entity) then
		return nil
	end

	local configData = entity.getConfigData and entity:getConfigData() or nil

	return configData and configData.name or nil
end

function M.isPetConfigName(entity, name)
	local configName = M.getPetConfigName(entity)

	return configName ~= nil and name ~= nil and tostring(name) == tostring(configName)
end

function M.isPetEntity(entity)
	return entity and (Utils.isPet(entity) or Utils.isPlayerPet(entity))
end

function M.getPetMasterEntity(entity)
	if not M.isPetEntity(entity) or type(entity.getMasterEntity) ~= "function" then
		return nil
	end

	return entity:getMasterEntity()
end

function M.isControlledPetOwnerName(entity, name, masterEnt)
	if not masterEnt or type(masterEnt.isControllingPet) ~= "function" or not masterEnt:isControllingPet() then
		return false
	end

	local ownerName = masterEnt.playerName or ""

	if type(entity.m_getMastEntName) == "function" then
		ownerName = entity:m_getMastEntName(ownerName, entity)
	end

	return not string.isNilOrEmpty(ownerName) and name ~= nil and tostring(name) == tostring(ownerName)
end

function M.getLocalizedText(text)
	if type(pg.getLocalizationText) == "function" then
		return pg.getLocalizationText(text)
	end

	return text
end

function M.injectTopLogoDisplayName(playerInfo, displayText)
	if string.isNilOrEmpty(displayText) then
		return displayText
	end

	return PlatformDisplayNameInjector.getDisplayName({
		playerInfo = playerInfo,
		config = M.CONFIG,
		rawName = displayText
	})
end

function M.bindPetTopLogoName(component, uid, playerInfo, customName, configName)
	local localizedConfigName = M.getLocalizedText(configName)

	return PlatformPetNameMaskService.getMaskedDisplayPetName({
		action = PlatformPetNameMaskService.Action.TopLogoPetName,
		uid = uid,
		playerInfo = playerInfo,
		customName = customName,
		configName = localizedConfigName
	})
end

function M.resolveUGCDisplayText(component, requestKey, action, uid, playerInfo, rawText)
	if string.isNilOrEmpty(rawText) or string.isNilOrEmpty(uid) or M.isLocalPlayerUid(uid) then
		return rawText
	end

	return PlatformNameMaskService.getMaskedDisplayName({
		action = action,
		uid = uid,
		playerInfo = playerInfo,
		rawText = rawText
	})
end

function M.isPsnMultiplayerSpace(entity)
	local space = pg and pg.space or entity and entity.space or nil

	if space == nil then
		return false
	end

	if type(space.isMultiPlayerEnv) == "function" then
		return space:isMultiPlayerEnv() == true
	end

	return space.multiPlayerEnv == true
end

function M.isOnlineIDOwnerEntity(entity)
	return Utils.isPlayer(entity) or Utils.isPlayerPet(entity)
end

function M.getOnlineIDTargetFamily(entity, playerInfo)
	if playerInfo ~= nil then
		local playerFamily = M.getPlayerFamily(playerInfo)

		if playerFamily ~= nil then
			return playerFamily
		end
	end

	return M.getPlayerFamily(entity)
end

function M.shouldShowTopLogoOnlineID(component, playerInfo)
	local entity = component and component.entity or nil

	if not entity then
		return false
	end

	if not M.isOnlineIDOwnerEntity(entity) then
		return false
	end

	if not M.isPsnMultiplayerSpace(entity) then
		return false
	end

	local currentFamily = PlatformIdentityUtils.getCurrentPlatformFamily()

	if currentFamily ~= PlatformIdentityUtils.Family.PlayStation then
		return false
	end

	return M.getOnlineIDTargetFamily(entity, playerInfo) == PlatformIdentityUtils.Family.PlayStation
end

local function isOnlineIDNameVisible(widget)
	return NotNil(widget) and widget.bActive and widget.isVisible and UIUtils.IsVisible(widget.gameObject)
end

function M.applyOnlineIDLocalOffset(component)
	local container = component and component.onlineIDUContainer or nil

	if IsNil(container) or IsNil(container.content) then
		return
	end

	if not container.bActive or not container.gameObject.activeInHierarchy or not container.content.bActive or not container.content.gameObject.activeInHierarchy or IsNil(component.onlineIDText) then
		return
	end

	local target = isOnlineIDNameVisible(component.nameUText) and component.nameUText or isOnlineIDNameVisible(component.nameVariant1UBaseText) and component.nameVariant1UBaseText or isOnlineIDNameVisible(component.nameVariant2UBaseText) and component.nameVariant2UBaseText

	if not target then
		return
	end

	local content = container.content.rectTransform
	local parent = content and content.parent
	local nameRect = target.rectTransform

	if IsNil(parent) or nameRect.rect.width <= 0 then
		return
	end

	local anchor = content.anchoredPosition

	if math.abs(anchor.y) > 0.001 then
		content.anchoredPosition = Vector2.New(anchor.x, 0)
	end

	local center = nameRect.rect.center
	local nameCenter = parent:InverseTransformPoint(nameRect:TransformPoint(Vector3.New(center.x, center.y, 0)))

	center = content.rect.center

	local accountCenter = parent:InverseTransformPoint(content:TransformPoint(Vector3.New(center.x, center.y, 0)))
	local delta = nameCenter.x - accountCenter.x

	if math.abs(delta) > 0.001 then
		local position = content.localPosition

		content.localPosition = Vector3.New(position.x + delta, position.y, position.z)
	end
end

function M.stopOnlineIDLayout(component)
	local state = component._platformOnlineIDLayout

	component._platformOnlineIDLayout = nil

	if state then
		state.camera:removeLateUpdateTimer(state.timer)
	end
end

function M.bindOnlineIDLayout(component, playerInfo)
	local camera = pg.game.camera
	local container = component.onlineIDUContainer

	if not camera or IsNil(container) or IsNil(container.content) or IsNil(component.onlineIDText) then
		return
	end

	local state = component._platformOnlineIDLayout

	if state and state.camera == camera and state.entity == component.entity and state.container == container and state.content == container.content then
		state.playerInfo = playerInfo

		return
	end

	M.stopOnlineIDLayout(component)

	state = {
		camera = camera,
		entity = component.entity,
		container = container,
		content = container.content,
		playerInfo = playerInfo
	}
	component._platformOnlineIDLayout = state
	state.timer = camera:addLateUpdateTimer(function()
		if component._platformOnlineIDLayout ~= state then
			return
		end

		if component.entity ~= state.entity or component.onlineIDUContainer ~= container or IsNil(container) or container.content ~= state.content or IsNil(state.content) then
			M.stopOnlineIDLayout(component)

			return
		end

		if not M.shouldShowTopLogoOnlineID(component, state.playerInfo) then
			component:hideOnlineIDText()

			return
		end

		if container.bActive and container.isVisible and container.gameObject.activeInHierarchy and NotNil(component.onlineIDText) then
			M.applyOnlineIDLocalOffset(component)
		end
	end)
end

function M.refreshOnlineIDTextAndOffset(component, text, playerInfo)
	local container = component.onlineIDUContainer

	if IsNil(container) or string.isNilOrEmpty(text) then
		component:refreshOnlineIDText(text)

		return
	end

	local pending = component._platformOnlineIDPendingLoad

	if pending and pending.container == container and pending.entity == component.entity then
		pending.text = text
		pending.playerInfo = playerInfo

		return
	end

	component.m_onlineIDLoadReqId = (component.m_onlineIDLoadReqId or 0) + 1

	local reqId = component.m_onlineIDLoadReqId

	pending = {
		container = container,
		entity = component.entity,
		text = text,
		playerInfo = playerInfo
	}
	component._platformOnlineIDPendingLoad = pending

	local function applyContent(content)
		if component._platformOnlineIDPendingLoad ~= pending or component.m_onlineIDLoadReqId ~= reqId then
			return
		end

		component._platformOnlineIDPendingLoad = nil

		if component.entity ~= pending.entity or component.onlineIDUContainer ~= container then
			return
		end

		if IsNil(container) or IsNil(content) or not M.shouldShowTopLogoOnlineID(component, pending.playerInfo) then
			component:hideOnlineIDText()

			return
		end

		component:refreshOnlineIDText(pending.text)
		M.applyOnlineIDLocalOffset(component)
		M.bindOnlineIDLayout(component, pending.playerInfo)
	end

	if container.content then
		applyContent(container.content)
	else
		M.stopOnlineIDLayout(component)
		component:safeSetActive(container, false)
		component:safeSetActiveFastest(container, false)
		container:LoadDefaultUrlManually(applyContent)
	end
end

function M.refreshOnlineID(component, ownerUid, playerInfo)
	if not component or type(component.refreshOnlineIDText) ~= "function" then
		return
	end

	if not M.shouldShowTopLogoOnlineID(component, playerInfo) then
		if type(component.hideOnlineIDText) == "function" then
			component:hideOnlineIDText()
		else
			component:refreshOnlineIDText("")
		end

		return
	end

	if string.isNilOrEmpty(ownerUid) then
		component:refreshOnlineIDText("")

		return
	end

	if playerInfo == nil then
		M.requestOwnerPlayerInfo(ownerUid, component, "refreshName")
		component:refreshOnlineIDText("")

		return
	end

	local displayPlayerInfo = M.getTopLogoDisplayPlayerInfo(playerInfo)
	local identity = PlatformIdentityUtils.resolvePlayerIdentity(displayPlayerInfo) or {}
	local entityIdentity = PlatformIdentityUtils.resolvePlayerIdentity(component.entity) or {}

	M.refreshOnlineIDTextAndOffset(component, identity.platformDisplayName or entityIdentity.platformDisplayName or "", playerInfo)
end

function M:onCtor()
	PlatformNameMaskRefreshHelper.register(self, function(component)
		if type(component.refreshName) == "function" then
			component:refreshName(true)
		end

		if type(component.refreshSubName) == "function" then
			component:refreshSubName()
		end
	end)
end

function M:onFindObjects()
	if self == nil then
		return
	end

	local function enableRichText(textNode)
		if M.isObjectAlive(textNode) then
			textNode.supportRichText = true
		end
	end

	enableRichText(self.nameUText)
	enableRichText(self.nameVariant1UBaseText)
	enableRichText(self.nameVariant2UBaseText)
	enableRichText(self.subTextUSDFText)
end

function M:refreshName(force, rawName)
	local ownerUid, ownerPlayerInfo = M.getTopLogoUGCOwnerInfo(self.entity)
	local name = rawName

	if not ownerUid then
		M.refreshOnlineID(self, ownerUid, ownerPlayerInfo)

		return name
	end

	M.refreshOnlineID(self, ownerUid, ownerPlayerInfo)

	if string.isNilOrEmpty(name) then
		return name
	end

	if M.isPetConfigName(self.entity, name) then
		return name
	end

	if ownerPlayerInfo == nil then
		M.requestOwnerPlayerInfo(ownerUid, self, "refreshName")

		if PlatformPetNameMaskService.isCurrentConsoleFamily() and M.isPetEntity(self.entity) then
			local pendingPetConfigName = M.getPetConfigName(self.entity)

			if not string.isNilOrEmpty(pendingPetConfigName) then
				return M.getLocalizedText(pendingPetConfigName)
			end
		end

		return name
	end

	local uidKey = tostring(ownerUid)

	if M.switchQueryStates[uidKey] ~= M.SwitchQueryState.Pending then
		M.setOwnerPlayerInfoQueryState(self, ownerUid, "refreshName", nil)
	end

	local displayPlayerInfo = M.getTopLogoDisplayPlayerInfo(ownerPlayerInfo)

	if M.shouldRequeryMissingTargetUGCSwitch() and not M.isPetEntity(self.entity) and not M.isLocalPlayerUid(ownerUid) and M.isMissingTargetUGCSwitch(displayPlayerInfo) then
		local queryState = M.switchQueryStates[uidKey]

		if queryState ~= M.SwitchQueryState.Completed then
			local function onSwitchQueryResolved(ok)
				M.switchQueryStates[uidKey] = ok == true and M.SwitchQueryState.Completed or nil
			end

			if queryState ~= M.SwitchQueryState.Pending then
				M.switchQueryStates[uidKey] = M.SwitchQueryState.Pending

				local sent = M.requestOwnerPlayerInfo(ownerUid, self, "refreshName", onSwitchQueryResolved)

				if sent ~= true and M.switchQueryStates[uidKey] == M.SwitchQueryState.Pending then
					M.switchQueryStates[uidKey] = nil
				end

				queryState = M.switchQueryStates[uidKey]
			else
				M.requestOwnerPlayerInfo(ownerUid, self, "refreshName", onSwitchQueryResolved)
			end

			if queryState ~= M.SwitchQueryState.Completed then
				return M.injectTopLogoDisplayName(displayPlayerInfo, PlatformNameMaskService:getMaskedPlayerName(ownerUid))
			end

			ownerPlayerInfo = M.getCachedPlayerInfo(ownerUid) or ownerPlayerInfo
			displayPlayerInfo = M.getTopLogoDisplayPlayerInfo(ownerPlayerInfo)
		end
	end

	local petConfigName = M.getPetConfigName(self.entity)

	if M.isPetEntity(self.entity) and petConfigName ~= nil then
		local masterEnt = M.getPetMasterEntity(self.entity)

		if not M.isControlledPetOwnerName(self.entity, name, masterEnt) then
			local displayText = M.bindPetTopLogoName(self, ownerUid, displayPlayerInfo, name, petConfigName)

			return M.injectTopLogoDisplayName(displayPlayerInfo, displayText)
		end
	end

	local displayText = M.resolveUGCDisplayText(self, "nameUgcRequestId", PlatformNameMaskService.Action.TopLogoName, ownerUid, displayPlayerInfo, name)

	return M.injectTopLogoDisplayName(displayPlayerInfo, displayText)
end

function M:refreshSubName(rawName)
	if not Utils.isPlayerPet(self.entity) then
		return
	end

	local masterEnt = self.entity:getMasterEntity()
	local ownerUid = masterEnt and masterEnt.uid or nil

	if not ownerUid then
		return
	end

	local ownerPlayerInfo = M.getCachedPlayerInfo(ownerUid)
	local displaySubName = rawName or self.subName or ""

	if string.isNilOrEmpty(displaySubName) then
		return
	end

	if ownerPlayerInfo == nil then
		M.requestOwnerPlayerInfo(ownerUid, self, "refreshSubName")

		return displaySubName
	end

	M.setOwnerPlayerInfoQueryState(self, ownerUid, "refreshSubName", nil)

	local displayPlayerInfo = M.getTopLogoDisplayPlayerInfo(ownerPlayerInfo)
	local displayText = M.resolveUGCDisplayText(self, "subNameUgcRequestId", PlatformNameMaskService.Action.TopLogoSubName, ownerUid, displayPlayerInfo, displaySubName)

	return M.injectTopLogoDisplayName(displayPlayerInfo, displayText)
end

function M:onDestroy()
	M.stopOnlineIDLayout(self)
	PlatformNameMaskRefreshHelper.unregister(self)
end

return M
