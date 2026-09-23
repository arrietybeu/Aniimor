-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\SpaceComponent\\ClientSpaceSandboxComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local inspect = require("Core.Common.inspect")
local Sandbox = require("GameApp.Sandbox.Sandbox")
local Utils = require("Common.Utils.Utils")
local ClientUtils = require("Utils.ClientUtils")
local SandboxConst = require("Common.Const.SandboxConst")
local NoticeDef = require("Common.NoticeDef")
local EventConst = require("Common.Const.EventConst")
local SANDBOX_DEBUG = false
local logger = LoggerManager.getLogger("SpaceSandboxComponent", "Sandbox", LoggerConst.ERROR)
local ClientSpaceSandboxComponent = Class.Component("ClientSpaceSandboxComponent")

function ClientSpaceSandboxComponent:ctor()
	self.sandboxes = {}
	self.clientVisibleDict = {}
	self.pendingInitialSandboxData = nil
end

function ClientSpaceSandboxComponent:init(dict)
	self:setSpaceOwner()

	self.pendingInitialSandboxData = dict.loadSandbox
	self.loadSandboxDebug = dict.loadSandbox

	if pg and pg.me and pg.me.space == self then
		self:loadPendingInitialSandbox()
	end
end

function ClientSpaceSandboxComponent:loadPendingInitialSandbox()
	local loadSandbox = self.pendingInitialSandboxData

	self.pendingInitialSandboxData = nil

	if loadSandbox then
		self:loadAllSandbox(loadSandbox)
	end
end

function ClientSpaceSandboxComponent:onChunkLoadEvent(chunkKey, load)
	return
end

function ClientSpaceSandboxComponent:loadAllSandbox(loadSandbox)
	for sandboxId, v in pairs(loadSandbox) do
		if not self.sandboxes[sandboxId] then
			self.sandboxes[sandboxId] = Sandbox.new(sandboxId, self)
		end

		ClientUtils.tryWithLogError(function()
			if SANDBOX_DEBUG then
				logger:debug("[SANDBOX] load ", inspect(v))
			end

			self.sandboxes[sandboxId]:enable(v)
		end)
	end
end

function ClientSpaceSandboxComponent:RPC_SC_SyncSandboxInfo(loadSandbox, unloadSandbox)
	self:loadAllSandbox(loadSandbox)

	for _, sandboxId in ipairs(unloadSandbox) do
		if self.sandboxes[sandboxId] then
			self.sandboxes[sandboxId]:disable()
		end

		if SANDBOX_DEBUG then
			logger:debug("[SANDBOX] unload ", sandboxId)
		end
	end

	pg.global.eventEmitter:emit(EventConst.SANDBOX_UPDATE)
end

function ClientSpaceSandboxComponent:registerSandboxEntity(sandboxId, ent)
	if not self.sandboxes[sandboxId] then
		self.sandboxes[sandboxId] = Sandbox.new(sandboxId, self)

		pg.global.eventEmitter:emit(EventConst.SANDBOX_UPDATE, sandboxId)
	end

	self.sandboxes[sandboxId]:addEntity(ent)
end

function ClientSpaceSandboxComponent:unregisterSandboxEntity(sandboxId, ent)
	if self.sandboxes[sandboxId] then
		self.sandboxes[sandboxId]:removeEntity(ent)
	end
end

function ClientSpaceSandboxComponent:getSandbox(sandboxId)
	return self.sandboxes[sandboxId]
end

function ClientSpaceSandboxComponent:getSandboxLevelItem(sandboxId, levelItemId)
	local sandbox = self.sandboxes[sandboxId]

	if not sandbox then
		return
	end

	return sandbox.levelItems[levelItemId]
end

function ClientSpaceSandboxComponent:setLevelItemState(sandboxId, levelItemId, state)
	local levelItem = self:getSandboxLevelItem(sandboxId, levelItemId)

	if levelItem then
		levelItem:syncFieldValue({
			state = state
		})
	end
end

function ClientSpaceSandboxComponent:RPC_SC_ResetSandboxInfo(sandboxInfo)
	for sandboxId, v in pairs(sandboxInfo) do
		if not self.sandboxes[sandboxId] then
			self.sandboxes[sandboxId] = Sandbox.new(sandboxId, self)
		end

		ClientUtils.tryWithLogError(function()
			if SANDBOX_DEBUG then
				logger:debug("[SANDBOX] reset ", inspect(v))
			end

			self.sandboxes[sandboxId]:reset(v)
		end)
	end

	pg.global.eventEmitter:emit(EventConst.SANDBOX_UPDATE)
end

function ClientSpaceSandboxComponent:RPC_SC_SwitchSandboxAuthority(sandboxId, authorityId)
	if SANDBOX_DEBUG then
		logger:debug("[SANDBOX] switch authority ", sandboxId, authorityId)
	end

	local sandbox = self.sandboxes[sandboxId]

	if sandbox then
		sandbox:setAuthority(authorityId)
	end
end

function ClientSpaceSandboxComponent:RPC_SC_LevelItemChangeFields(sandboxId, levelItemId, changeFields)
	if SANDBOX_DEBUG then
		logger:debug("[SANDBOX] levelItem change ", sandboxId, levelItemId, inspect(changeFields))
	end

	local sandbox = self.sandboxes[sandboxId]

	if sandbox == nil or sandbox.levelItems == nil then
		sandbox = self:getEntityByStaticId(sandboxId)

		if sandbox then
			sandbox.levelItem:setSyncInfo(changeFields)
		end

		return
	end

	local levelItem = sandbox.levelItems[levelItemId]

	if not levelItem then
		return
	end

	levelItem:setSyncInfo(changeFields)
end

function ClientSpaceSandboxComponent:RPC_SC_LevelItemClientMsg(sandboxId, levelItemId, name, parameters)
	if SANDBOX_DEBUG then
		logger:debug("[SANDBOX] levelItem msg ", sandboxId, levelItemId, name, inspect(parameters))
	end

	local sandbox = self.sandboxes[sandboxId]

	if sandbox == nil or sandbox.levelItems == nil then
		sandbox = self:getEntityByStaticId(sandboxId)

		local levelItem = sandbox and sandbox.levelItem
		local func = levelItem and levelItem[name]

		if func then
			func(levelItem, unpack(parameters))
		end

		return
	end

	local levelItem = sandbox.levelItems[levelItemId]

	if not levelItem then
		return
	end

	local func = levelItem[name]

	if func then
		func(levelItem, unpack(parameters))
	end
end

function ClientSpaceSandboxComponent:changeLevelItemFieldValue(sandboxId, levelItemId, changeFields)
	pg.me:reliableServerSpaceMsg("RPC_CS_LevelItemFieldChange", {
		sandboxId,
		levelItemId,
		changeFields
	})
end

function ClientSpaceSandboxComponent:sendSandboxEvent(sandboxId, levelItemId, eventType)
	pg.me:reliableServerSpaceMsg("RPC_CS_SandboxEvent", {
		sandboxId,
		levelItemId,
		eventType
	})
end

function ClientSpaceSandboxComponent:sendClientLogicCompleteMsg(sandboxId, msgStr)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:debug("RPC_CS_SandboxCustomEvent", sandboxId, msgStr)
	end

	pg.me:reliableServerSpaceMsg("RPC_CS_SandboxCustomEvent", {
		sandboxId,
		msgStr
	})
end

function ClientSpaceSandboxComponent:replayDialoguePlayerOnReconnect()
	for _, sandbox in pairs(self.sandboxes) do
		for _, levelItem in pairs(sandbox.levelItems) do
			if levelItem.className == "DialoguePlayer" then
				levelItem:replayOnReconnect()
			end
		end
	end
end

function ClientSpaceSandboxComponent:callServerReloadSandbox(sandboxId)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:debug("RPC_CS_ReloadSandbox", sandboxId)
	end

	pg.me:reliableServerSpaceMsg("RPC_CS_ReloadSandbox", {
		sandboxId
	})
end

function ClientSpaceSandboxComponent:destroy()
	self.pendingInitialSandboxData = nil

	for _, sandbox in pairs(self.sandboxes) do
		ClientUtils.tryWithLogError(function()
			sandbox:disable()
		end)
	end

	self.sandboxes = {}
end

function ClientSpaceSandboxComponent:getSandboxPuppet(sandboxId)
	if not pg.me.sandboxStressTesting then
		return
	end

	local sandbox = self.sandboxes[sandboxId]

	if not sandbox then
		return
	end

	local Utils = require("Common.Utils.Utils")
	local puppets = {}

	for _, entity in pairs(sandbox.entities) do
		if Utils.isPuppet(entity) then
			puppets[#puppets + 1] = entity
		end
	end

	return puppets
end

function ClientSpaceSandboxComponent:setClientEntVisible(staticId, visible, enableCollide)
	if not staticId then
		return
	end

	local changed = false
	local visibleInfo = self.clientVisibleDict[staticId]

	enableCollide = enableCollide or false
	visible = visible or false

	if visible and enableCollide then
		if visibleInfo then
			self.clientVisibleDict[staticId] = nil
			changed = true
		end
	elseif not visibleInfo or visibleInfo[1] ~= visible or visibleInfo[2] ~= enableCollide then
		self.clientVisibleDict[staticId] = {
			visible,
			enableCollide
		}
		changed = true
	end

	if changed then
		local ent = self:getEntityByStaticId(staticId)

		if ent then
			ent:refreshVisible()
		end
	end
end

function ClientSpaceSandboxComponent:getClientEntVisible(staticId)
	if not staticId then
		return true, true
	end

	local visibleInfo = self.clientVisibleDict[staticId]

	if not visibleInfo then
		return true, true
	end

	return visibleInfo[1], visibleInfo[2]
end

function ClientSpaceSandboxComponent:RPC_SC_SandboxPhaseChange(sandboxId, phase)
	if SANDBOX_DEBUG then
		logger:debug("[SANDBOX] phase change ", sandboxId, phase)
	end

	facade:sendLuaEvent("SandboxPhaseChange" .. tostring(sandboxId), phase)
end

function ClientSpaceSandboxComponent:isSpaceOwner()
	if not pg.me then
		return false
	end

	return self.ownerPlayerId == pg.me.id
end

function ClientSpaceSandboxComponent:ownerExist()
	return self.ownerPlayerId ~= nil and self.ownerPlayerId ~= ""
end

function ClientSpaceSandboxComponent:on_ownerPlayerId_changed(oldVal, newVal)
	self:setSpaceOwner()
end

function ClientSpaceSandboxComponent:setSpaceOwner()
	if self:ownerExist() then
		appFacade.sandboxManager.isSpaceOwner = self:isSpaceOwner()
	else
		appFacade.sandboxManager.isSpaceOwner = true
	end
end

function ClientSpaceSandboxComponent:checkPermission(permission, showToast)
	local isSingle = Utils.isSceneSingleWorld(self.sceneId)

	if not isSingle then
		return true
	end

	if permission == SandboxConst.Permission.OnlyOwner then
		local isOwner = self:isSpaceOwner()

		if not isOwner and showToast then
			pg.global.showBubbleMessage(NoticeDef.SANDBOX_INTERACT_FAILED_GUEST)
		end

		return isOwner
	else
		local isScene = self:ownerExist()

		if not isScene and showToast then
			pg.global.showBubbleMessage(NoticeDef.SANDBOX_INTERACT_FAILED_OWNER_LEAVE)
		end

		return isScene
	end
end

function ClientSpaceSandboxComponent:RPC_SC_DebugSandboxInfo(sandboxInfo)
	clientSandboxUtils.callCsCallback(sandboxInfo)
end

function ClientSpaceSandboxComponent:RPC_SC_ShowStage(stage, totalStage)
	pg.global.ui.tips:showA1Tips({
		id = "TowerResultWave",
		params = {
			totalStage = totalStage,
			stage = stage
		}
	})
end

return ClientSpaceSandboxComponent
