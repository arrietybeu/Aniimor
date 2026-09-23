-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\LevelItem.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local ClientUtils = require("Utils.ClientUtils")
local SceneUtils = require("Common.Utils.SceneUtils")
local MessageName = require("Const.MessageName")
local LevelItemConfigData = require("Data.level_item_config_data")
local ShareDataType = require("Const.ClientConst").ShareDataType
local TimerManager = require("Core.Timer.TimerManager")
local ShareMem = require("Utils.ShareMem")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("LevelItem", "Sandbox", LoggerConst.ERROR)
local TriggerConst = require("Common.Const.TriggerConst")
local SandboxConst = require("Common.Const.SandboxConst")
local ClientLevelUtils = require("Utils.ClientLevelUtils")
local Const = require("Common.Const.Const")
local level_item_prefab_data = require("Common.Data.level_item_prefab_data")
local SandBoxConfig = require("GameApp.Sandbox.SandBoxConfig")
local LevelItem = Class.LightClass("LevelItem")
local rawget = rawget
local setmetatable = setmetatable
local subCompInfoMeta = {
	__index = function(compData, field)
		local instValue = rawget(compData, 1)[field]

		if instValue ~= nil then
			return instValue
		end

		return rawget(compData, 2)[field]
	end
}

function LevelItem:ctor(sandbox, spawnInfo, syncInfo)
	self._timerIds = {}
	self.id = spawnInfo.id
	self.sandbox = sandbox
	self.spawnInfo = spawnInfo
	self.configId = spawnInfo.configId
	self.editorName = self.spawnInfo.EditorName
	self.componentsInfo = SandBoxConfig.convertToLuaTable(spawnInfo.componentsInfo)
	self.logger = logger
	self.syncInfo = syncInfo

	if syncInfo and syncInfo.ecsSyncObject then
		pg.game.ecs:registerSyncObject(syncInfo.ecsSyncObject)
	end

	self._interactionCache = {}
	self._interactSBs = {}
	self.subComps = {}

	local prefabComps = level_item_prefab_data[self.configId] or EMPTY_TABLE
	local instSubComps = self.componentsInfo or EMPTY_TABLE

	for compId, prefabCompData in pairs(prefabComps) do
		if prefabCompData.subCompType then
			local compData = prefabCompData
			local instCompData = instSubComps[compId]

			if instCompData and instCompData.subCompType and instCompData ~= prefabCompData then
				compData = setmetatable({
					instCompData,
					prefabCompData
				}, subCompInfoMeta)
			end

			self:addSubComp(compId, compData)
		end
	end

	self:onInit()
	self:initShareMem()
end

function LevelItem:onInit()
	return
end

function LevelItem:bindShell(shell)
	self.shell = shell

	shell:BindLua(self, self.shareMem.shell)
	shell:Load(self:getResId())
end

function LevelItem:onSandboxReady()
	return
end

function LevelItem:isValid()
	return NotNil(self.shell)
end

function LevelItem:getConfigData()
	if not self.configId then
		return {}
	end

	return LevelItemConfigData[self.configId] or {}
end

function LevelItem:getPosition()
	local position = self.syncInfo.position or self.spawnInfo.position

	return Vector3(position[1], position[2], position[3])
end

function LevelItem:getRotation()
	local rotation = self.syncInfo.rotation or self.spawnInfo.rotation

	return Quaternion.Euler(rotation[1], rotation[2], rotation[3])
end

function LevelItem:initShareMem()
	self.shareMem = ShareMem.new()

	self:onInitShareMem()
	self.shareMem:set("isActive", self.spawnInfo.isActive)
	self.shareMem:set("position", self.spawnInfo.position)
	self.shareMem:set("rotation", self.spawnInfo.rotation)
	self.shareMem:set("scale", self.spawnInfo.scale)
	self:setSyncInfo(self.syncInfo, true)
end

function LevelItem:onInitShareMem()
	return
end

function LevelItem:getMajorConfig()
	if self.majorConfig then
		return self.majorConfig
	end

	local initInfo = self.spawnInfo

	self.majorConfig = setmetatable({}, {
		__index = function(t, k)
			local majorCompId = initInfo.majorCompId
			local instVal = table.safe_get(initInfo, "componentsInfo", majorCompId, k)

			if instVal ~= nil then
				return instVal
			end

			return table.safe_get(level_item_prefab_data, self.configId, majorCompId, k)
		end
	})

	return self.majorConfig
end

function LevelItem:setSyncInfo(syncInfo, isInit)
	for k, v in pairs(syncInfo) do
		local oldV = self.syncInfo[k]

		self.syncInfo[k] = v

		self:onValueChange(k, oldV, v, isInit)
	end

	self.shareMem:flush()
end

function LevelItem:onValueChange(key, oldValue, value, isInit)
	if not isInit then
		self:onLevelItemValueChange(key, oldValue, value)
	end

	self.shareMem:set(key, value)
end

function LevelItem:onLevelItemValueChange(key, oldValue, value)
	return
end

function LevelItem:syncFieldValue(changeFields)
	self.sandbox:syncFieldValue(self.id, changeFields)
end

function LevelItem:syncSingleFieldValue(key, value, clientFirst)
	local changeFields = {}

	changeFields[key] = value

	if clientFirst then
		self.shareMem:set(key, value)
		self.shareMem:flush()
	end

	self.sandbox:syncFieldValue(self.id, changeFields)
end

function LevelItem:sendSandboxEvent(eventType)
	self.sandbox:sendSandboxEvent(self.id, eventType)
end

function LevelItem:destroy()
	self:killAllTimer()
	self:clearInteractData()
	self.shareMem:destroy()

	self.shareMem = nil
	self.componentsInfo = nil
	self.shell = nil
end

function LevelItem:serverMsg(name, ...)
	local sandbox = self.sandbox

	if not sandbox or not sandbox.space then
		return
	end

	local ignoreAuthority = true

	sandbox:serverMsgSb(self.id, name, ignoreAuthority, {
		...
	})
end

function LevelItem:addTimer(delay, func, loop)
	local timerId

	loop = loop or false

	if loop then
		timerId = TimerManager.addRepeatTimer(delay, func)
	else
		timerId = TimerManager.addTimer(delay, func)
	end

	self._timerIds[timerId] = loop

	return timerId
end

function LevelItem:removeTimer(timerId)
	TimerManager.removeTimer(timerId)

	self._timerIds[timerId] = nil
end

function LevelItem:killAllTimer()
	for timerId, loop in pairs(self._timerIds) do
		TimerManager.removeTimer(timerId)
	end

	self._timerIds = {}
end

function LevelItem:getInteractGlobalId(interactPartId)
	if interactPartId then
		return "LevelItem#" .. self.id .. "#" .. tostring(interactPartId)
	end

	return "LevelItem#" .. self.id
end

function LevelItem:getInteractionListData(interactPartId)
	local configData = self:getConfigData()
	local actionPrototypeIds = configData.actionPrototypeIds

	if not actionPrototypeIds then
		return nil
	end

	local interactListData = {}

	for _, actionPrototypeId in ipairs(actionPrototypeIds) do
		local interactData = {
			interactPartId = interactPartId,
			actionPrototypeId = actionPrototypeId,
			globalId = self:getInteractGlobalId(interactPartId),
			interactFunc = function(interactUnit)
				if not self:checkPermission(SandboxConst.Permission.OwnerInScene, true) then
					return
				end

				self:onInteract(interactUnit)
				self:informServerInteract()
			end,
			canInteractiveFunc = function(interactUnit)
				local result = self:checkCanInteract(interactUnit)

				return result
			end
		}

		table.insert(interactListData, interactData)
	end

	return interactListData
end

function LevelItem:checkPermission(permission, showToast)
	return self.sandbox:checkPermission(permission, showToast)
end

function LevelItem:playerFaceToInteractUnit(interactPartId, instant)
	if interactPartId then
		local levelItemInteractSB = self._interactSBs[interactPartId]

		if levelItemInteractSB then
			local targetRotation = levelItemInteractSB.transform.rotation

			pg.me:forbidPositionCheck({
				Const.FORBID_POSITION_REASON.LEVEL_ITEM_INTERACT,
				self.id,
				levelItemInteractSB.transform.position,
				self.sandbox.id
			})
			pg.pawn:forceSetPosRot(levelItemInteractSB.transform.position, targetRotation, instant)
		end
	end
end

function LevelItem:informServerInteract()
	pg.me:serverMsg("RPC_CS_InteractWithLevelItem", self.sandbox.id, self.spawnInfo.id, self.spawnInfo.configId)

	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:debug("informServerInteract", self.sandbox.id, self.spawnInfo.id, self.spawnInfo.configId)
	end
end

function LevelItem:registerInteractSB(levelItemInteractSB)
	if not levelItemInteractSB then
		return
	end

	local interactPartId = levelItemInteractSB.interactPartId or 0

	self._interactSBs[interactPartId] = levelItemInteractSB
end

function LevelItem:enterInteractRange(levelItemInteractSB)
	if not levelItemInteractSB then
		return
	end

	local interactPartId = levelItemInteractSB.interactPartId or 0
	local curData = self._interactionCache[interactPartId]

	if curData then
		if curData.levelItemInteractSB == levelItemInteractSB then
			return
		end

		self:leaveInteractRange(curData.levelItemInteractSB)
	end

	local interactionData = self:getInteractionListData(interactPartId)

	self._interactionCache[interactPartId] = {
		interactionData = interactionData,
		levelItemInteractSB = levelItemInteractSB
	}

	if interactionData then
		facade:SendMessageCommand(MessageName.ENTER_TRIGGER_MULTI_INTERACT, interactionData)
	end
end

function LevelItem:leaveInteractRange(levelItemInteractSB)
	if not levelItemInteractSB then
		return
	end

	local interactPartId = levelItemInteractSB.interactPartId or 0
	local curData = self._interactionCache[interactPartId]

	if curData then
		if curData.levelItemInteractSB ~= levelItemInteractSB then
			return
		end

		local interactionData = curData.interactionData

		self._interactionCache[interactPartId] = nil

		if interactionData then
			facade:SendMessageCommand(MessageName.LEAVE_TRIGGER_MULTI_INTERACT, interactionData)
		end
	end
end

function LevelItem:clearInteractData()
	for interactIndex, interactInfo in pairs(self._interactionCache) do
		local interactionData = interactInfo.interactionData

		if interactionData then
			facade:SendMessageCommand(MessageName.LEAVE_TRIGGER_MULTI_INTERACT, interactionData)
		end
	end

	self._interactionCache = {}
end

function LevelItem:onInteract(interactUnit)
	return
end

function LevelItem:checkCanInteract(interactUnit)
	return true
end

function LevelItem:setIsActive(isActive)
	self.shareMem:set("isActive", isActive)
	self.shareMem:flush()
end

function LevelItem:getResId()
	local defaultValue = self.spawnInfo.defaultValue

	if defaultValue and defaultValue.resId then
		return defaultValue.resId
	end

	local configData = self:getConfigData()

	if IS_MOBILE and configData.mobileResId then
		return configData.mobileResId
	end

	return configData.resId
end

function LevelItem:queryStaticEntInitPosRot(staticId)
	local result = {}
	local sceneEntityData = SceneUtils.getSceneEntityData(self.sandbox.space.sceneId, self.sandbox.space.id)
	local entitySpawnInfo = sceneEntityData[staticId] or {}
	local position = entitySpawnInfo.position or {
		0,
		0,
		0
	}
	local rotation = entitySpawnInfo.rotation or {
		0,
		0,
		0,
		1
	}

	result.position = Vector3(position[1], position[2], position[3])
	result.rotation = Quaternion.New(rotation[1], rotation[2], rotation[3], rotation[4])

	return result
end

function LevelItem:registerPlayerPropertyChangedCB(propertyName, funcName)
	self.sandbox:registerPlayerPropertyChangedCB(self.id, propertyName, funcName)
end

function LevelItem:getSubComp(key)
	return self.subComps[key]
end

function LevelItem:addSubComp(key, compInfo)
	local cls = ClientLevelUtils.getSubCompCls(compInfo.subCompType)

	if cls then
		local subComp = cls.new(key, self, compInfo)

		if self.subComps[key] and LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("LevelItem:addSubComp failed, duplicate subComp key:", key, "compInfo:", compInfo.subCompType)

			return
		end

		self.subComps[key] = subComp
	end
end

function LevelItem:RPC_SC_SubCompMsg(subCompId, name, params)
	local subComp = self:getSubComp(subCompId)

	if subComp and subComp[name] then
		subComp[name](subComp, params)
	end
end

function LevelItem:subCompServerMsg(id, name, ...)
	local sandbox = self.sandbox

	if not sandbox or not sandbox.space then
		return
	end

	local ignoreAuthority = true

	sandbox:serverMsgSb(self.id, "RPC_CS_SubCompMsg", ignoreAuthority, {
		id,
		name,
		...
	})
end

function LevelItem:setPosRot(pos, rot)
	self.shareMem:set("position", pos)
	self.shareMem:set("rotation", rot)
	self.shareMem:flush()
end

return LevelItem
