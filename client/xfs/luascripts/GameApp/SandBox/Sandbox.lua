-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\Sandbox.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local logger = LoggerManager.getLogger("Sandbox", "Sandbox", LoggerConst.ERROR)
local infoLogger = LoggerManager.getLogger("SandboxRefresh", "Sandbox")
local ClientUtils = require("Utils.ClientUtils")
local SceneUtils = require("Common.Utils.SceneUtils")
local ClientConst = require("Const.ClientConst")
local Utils = require("Common.Utils.Utils")
local level_item_config_data = require("Data.level_item_config_data")
local sandbox_config_data = require("Data.sandbox_config_data")
local Sandbox = Class.LightClass("Sandbox")
local AIControllerUtils = require("Common.Utils.AIControllerUtils")
local SandboxConst = require("Common.Const.SandboxConst")
local AIUtils = require("Common.Utils.AIUtils")
local AiConst = require("Const.AiConst")
local EventConst = require("Const.EventConst")
local Const = require("Const.Const")
local RandomMapBatchUtils = require("Common.Utils.RandomMapBatchUtils")
local SandboxHotfixSystem = require("GameApp.Sandbox.SandboxHotfixSystem")
local GRAPH_BUILDER_MODE_RESOURCE = 0
local GRAPH_BUILDER_MODE_HOTFIX = 2
local GRAPH_BUILDER_MODE_DATA_ONLY = 3

function Sandbox:ctor(sandboxId, space)
	self.id = sandboxId
	self.space = space
	self.ready = false
	self.entities = {}
	self.levelItems = {}
	self.playerPropertyChangedCBs = {}
end

function Sandbox:enable(sandboxData)
	if self.enabled then
		self:disable()
	end

	self.enabled = true
	self.levelItems = {}

	function self.onPlayerPropertyChanged(properName, newV, oldV)
		self:triggerPlayerPropertyChanged(properName, newV, oldV)
	end

	self.finished = sandboxData.finished
	self.sceneId = self.space.sceneId
	self.sceneSandboxData = SceneUtils.getSceneSandboxData(self.sceneId, self.space and self.space.id)[self.id] or {}

	local sandboxConfig = sandbox_config_data[self.sceneSandboxData.sandboxType]

	self.onFinished = sandboxConfig and sandboxConfig.onFinished or SandboxConst.ON_FINISH.FADE_OUT
	self.roomInstanceId = self.sceneSandboxData.roomInstanceId or 0
	self.editorName = self.sceneSandboxData.name or "Sandbox_" .. tostring(self.id)
	self.ownerName = self.sceneSandboxData.owner or ""
	self.graphId = self.sceneSandboxData.graphId or 0

	local name = self.editorName .. " by:" .. self.ownerName

	self.shell = appFacade.sandboxManager:CreateSandbox(self.id, name)

	if sandboxData.authorityId then
		self:setAuthority(sandboxData.authorityId)
	end

	self.shell:SetLuaTable(self)

	local dataOnly = self.finished and self.onFinished ~= SandboxConst.ON_FINISH.RETRAIN

	self:buildGraph(dataOnly)

	for levelItemId, v in pairs(sandboxData.levelItem or EMPTY_TABLE) do
		ClientUtils.tryWithLogError(function()
			self:addItem(levelItemId, v)
		end)
	end

	self.shell:Start()
	self:initAreas()

	pg.game.map.entityStaticIdInitRecord[self.id] = true
end

function Sandbox:buildGraph(dataOnly)
	local graphRef = self.sceneSandboxData.graphRef

	if dataOnly then
		local builder = self.shell:SetGraphBuilderMode(GRAPH_BUILDER_MODE_DATA_ONLY)

		builder:SetGraphResId(graphRef)

		return
	end

	local hotfix = SandboxHotfixSystem.getHotfix(self.id)

	if hotfix then
		local builder = self.shell:SetGraphBuilderMode(GRAPH_BUILDER_MODE_HOTFIX)

		builder:SetGraphResId(graphRef)
		builder:SetLuaHotfix(hotfix.modifyNodes, hotfix.removeNodeUIDs, hotfix.addConnections, hotfix.removeConnections)
	else
		local builder = self.shell:SetGraphBuilderMode(GRAPH_BUILDER_MODE_RESOURCE)

		builder:SetGraphResId(graphRef)
	end
end

function Sandbox:reset(sandboxData)
	for levelItemId, v in pairs(sandboxData.levelItem or EMPTY_TABLE) do
		ClientUtils.tryWithLogError(function()
			local item = self.levelItems[levelItemId]

			if item then
				item:setSyncInfo(v)
			end
		end)
	end
end

function Sandbox:initAreas()
	local areaIds = self.sceneSandboxData.areaIds or {}

	for _, areaId in ipairs(areaIds) do
		self.space:addArea(areaId)
	end
end

function Sandbox:addGameplay(ent)
	if self.gameplay and LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("repeat add gameplay", ent.id)
	end

	self.gameplay = ent

	if self.ready and self.gameplay and self.gameplay.onSandboxReady then
		self.gameplay:onSandboxReady()
	end
end

function Sandbox:addEntity(ent)
	self.entities[ent.id] = ent

	if not self.ready then
		if ent.setIsKinematic then
			ent:setIsKinematic(true, ClientConst.IsKinematicKey.SandboxLoading)
		end

		if ent.SetKccEnable then
			ent:SetKccEnable(false, Const.KccDisableReason.SandBoxLoading)
		end

		AIControllerUtils.pause(ent, AiConst.AIControllerDisableReason.SandBoxLoading)
		AIUtils.pauseBt(ent, AiConst.PauseBtReason.SandBoxLoading)
	else
		ent.sandboxReady = true
	end
end

function Sandbox:removeEntity(ent)
	self.entities[ent.id] = nil
end

function Sandbox:addItem(levelItemId, syncInfo)
	if self.levelItems[levelItemId] then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn("repeat add levelItem", levelItemId, inspect(syncInfo))
		end

		self.levelItems[levelItemId]:destroy()
	end

	local sceneLevelItems = self.sceneSandboxData.levelItems or EMPTY_TABLE
	local spawnInfo = sceneLevelItems[levelItemId]

	if spawnInfo then
		local itemCfg = level_item_config_data[spawnInfo.configId]
		local levelItemType = require("GameApp.Sandbox." .. itemCfg.subType)
		local levelItem = levelItemType.new(self, spawnInfo, syncInfo)

		self.levelItems[levelItemId] = levelItem

		local csItem = self.shell:CreateLevelItem(levelItemId)

		levelItem:bindShell(csItem)
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("add levelItem error spawnInfo is nil", levelItemId, inspect(syncInfo))
	end
end

function Sandbox:syncFieldValue(itemId, changeFields)
	if not self.isMain then
		return
	end

	self.space:changeLevelItemFieldValue(self.id, itemId, changeFields)
end

function Sandbox:sendSandboxEvent(itemId, eventType)
	if not self.isMain then
		return
	end

	self.space:sendSandboxEvent(self.id, itemId, eventType)
end

function Sandbox:sendClientLogicCompleteMsg(msgStr)
	if not self.isMain then
		return
	end

	self.space:sendClientLogicCompleteMsg(self.id, msgStr)
end

function Sandbox:onSandboxReady()
	self.ready = true

	for k, ent in pairs(self.entities) do
		if ent.setIsKinematic then
			ent:setIsKinematic(false, ClientConst.IsKinematicKey.SandboxLoading)
		end

		if ent.SetKccEnable then
			ent:SetKccEnable(true, Const.KccDisableReason.SandBoxLoading)
		end

		ent.sandboxReady = true

		if ent.onTriggerEnter and ent.triggerId and ent.eModel and ent.eModel:CheckTriggerDistanceValid(ent.triggerId) then
			ent:onTriggerEnter(ClientConst.TriggerType.FKey)
		end

		AIControllerUtils.resume(ent, AiConst.AIControllerDisableReason.SandBoxLoading)
		AIUtils.resumeBt(ent, AiConst.PauseBtReason.SandBoxLoading)
	end

	if self.gameplay and self.gameplay.onSandboxReady then
		self.gameplay:onSandboxReady()
	end

	pg.global.eventEmitter:addEventListener(EventConst.SANDBOX_PLAYER_PROPERTY_CHANGED, self.onPlayerPropertyChanged)
end

function Sandbox:serverMsgSb(levelItemId, name, ignoreAuthority, args)
	pg.me:reliableServerSpaceMsg("RPC_CS_LevelItemServerMsg", {
		self.id,
		levelItemId,
		name,
		ignoreAuthority,
		args
	})
end

function Sandbox:disable()
	if not self.enabled then
		return
	end

	self.enabled = false

	ClientUtils.tryWithLogError(function()
		if self.gameplay and self.gameplay.onSandboxDisabled then
			self.gameplay:onSandboxDisabled()
		end

		for _, item in pairs(self.levelItems) do
			ClientUtils.tryWithLogError(function()
				item:destroy()
			end)
		end

		pg.global.eventEmitter:removeEventListener(EventConst.SANDBOX_PLAYER_PROPERTY_CHANGED, self.onPlayerPropertyChanged)

		local areaIds = self.sceneSandboxData.areaIds or {}

		for _, areaId in ipairs(areaIds) do
			self.space:removeArea(areaId)
		end
	end)

	self.onPlayerPropertyChanged = nil
	self.levelItems = {}
	self.playerPropertyChangedCBs = {}

	ClientUtils.tryWithLogError(function()
		appFacade.sandboxManager:DestroySandbox(self.id)
	end)

	self.ready = false
	self.shell = nil
	pg.game.map.entityStaticIdInitRecord[self.id] = nil
end

function Sandbox:setAuthority(authorityId)
	self.authorityId = authorityId
	self.isMain = self.authorityId == pg.me.id

	if self.shell then
		self.shell:SetIsMain(self.isMain)
	end
end

function Sandbox:setPhotoIdentify(isActive)
	self.isPhotoIdentifyActive = isActive
end

function Sandbox:registerPlayerPropertyChangedCB(levelItemId, propertyName, funcName)
	self.playerPropertyChangedCBs[propertyName] = self.playerPropertyChangedCBs[propertyName] or {}
	self.playerPropertyChangedCBs[propertyName][levelItemId] = funcName
end

function Sandbox:triggerPlayerPropertyChanged(propertyName, newV, oldV)
	if self.playerPropertyChangedCBs[propertyName] then
		for levelItemId, funcName in pairs(self.playerPropertyChangedCBs[propertyName]) do
			local levelItem = self.levelItems[levelItemId]

			if levelItem and levelItem[funcName] then
				levelItem[funcName](levelItem, newV, oldV)
			elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("triggerPlayerPropertyChanged error levelItem is nil or level do not have function! levelItemId:%s, propertyName:%s, funcName:%s", levelItemId, propertyName, funcName)
			end
		end
	end
end

function Sandbox:checkPermission(permission, showToast)
	return self.space:checkPermission(permission, showToast)
end

function Sandbox:queryRandomMapGenerateId(staticId)
	if self.roomInstanceId == 0 then
		return staticId
	end

	return RandomMapBatchUtils.queryOrRecorderNewId(self.roomInstanceId, staticId, self.space and self.space.id)
end

return Sandbox
