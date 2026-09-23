-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Lib\\Pg.lua

local pg = pg

pg.component = "client"

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local SceneAdapter = require("GameApp.Core.SceneAdapter")
local ActorManager = require("Core.Common.ActorManager")
local EntityManager = require("Core.Common.EntityManager")
local PrefsCacheUtils = require("Utils.PrefsCacheUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ClientUtils = require("Utils.ClientUtils")
local RedDotUtils = require("Utils.RedDotUtils")
local UIAdapter = require("Guis.UIAdapter")
local ClientConst = require("Const.ClientConst")
local PlatformManager = require("Utils.PlatformManager")
local SDKManager = require("SDK.SDKManager")
local GMEManager = require("SDK.GMEManager")
local logger = LoggerManager.getLogger("pg")
local AIUtils = require("Utils.AIUtils")
local AiConst = require("Const.AiConst")

pg.global = pg.global or {}
pg.global.proxy = pg.global.proxy or {}
pg.global.socketMgr = appFacade.socketManager
pg.global.cmdSocketMgr = appFacade.cmdSocketManager
pg.global.resMgr = appFacade.resManager
pg.global.gameMgr = appFacade.gameManager
pg.global.inputMgr = appFacade.inputManager
pg.global.cameraMgr = appFacade.cameraManager
pg.global.cameraImpulseMgr = appFacade.impulseManager
pg.global.effectMgr = appFacade.effectManager
pg.global.uiMgr = appFacade.uiManager
pg.global.mobileCameraMgr = appFacade.mobileCameraManager
pg.global.cutsceneMgr = appFacade.cutsceneManager
pg.global.dialogueGraphMgr = appFacade.dialogueGraphManager
pg.global.voxelMgr = appFacade.voxelManager
pg.global.physicsMgr = appFacade.physicsManager
pg.global.localizationMgr = appFacade.localizationManager
pg.languageType = pg.global.localizationMgr.SelectedLanguage or 0
pg.global.dungeonManager = appFacade.dungeonManager
pg.global.avatarMgr = appFacade.avatarManager
pg.global.lightMgr = appFacade.lightManager
pg.global.aiClimbMgr = appFacade.aiClimbManager
pg.global.worldXProfileMgr = appFacade.worldXProfilerManager
pg.global.qrCodeMgr = appFacade.qrCodeManager
pg.global.homelandMgr = appFacade.homelandManager
pg.global.csAbilityMgr = appFacade.abilityMgr
pg.global.ecsCompMgr = {}
pg.global.navMgr = CS.XGUI.Navigation.NavManager.Instance
pg.global.ui = UIAdapter.GetInstance()
pg.global.prefsCacheUtils = PrefsCacheUtils.GetInstance()
pg.global.scene = SceneAdapter.GetInstance()
pg.global.entityMgr = EntityManager
pg.global.actorMgr = ActorManager
pg.global.abilityMgr = nil
pg.global.sdkManager = SDKManager.GetInstance()
pg.global.gmeManager = GMEManager.GetInstance()
pg.global.platform = PlatformManager.GetInstance()
pg.global.showBubbleMessage = ClientUtils.showBubbleMessage
pg.global.showBubbleMessageById = ClientUtils.showBubbleMessageById
pg.global.hideBubbleMessageById = ClientUtils.hideBubbleMessageById
pg.global.showBubbleMessageRaw = ClientUtils.showBubbleMessageRaw
pg.global.showConfirmMsg = ClientUtils.showConfirm
pg.global.showConfirmMsgRaw = ClientUtils.showConfirmRaw
pg.global.showCommonTipUse = ClientUtils.showCommonTipUse
pg.global.setRedDot = RedDotUtils.setRedDot
pg.global.setPreViewRedDot = RedDotUtils.setPreViewRedDot
pg.global.setCustomRedDotHandle = RedDotUtils.setCustomRedDotHandle
pg.global.refreshRedDotState = RedDotUtils.refreshRedDotState
pg.global.calculateRedDotPriority = RedDotUtils.calculateRedDotPriority
pg.global.bindCurvedUI = RedDotUtils.bindCurvedUI
pg._psIconUIVisibleStates = pg._psIconUIVisibleStates or {}
pg.global.localHostMode = 0

function pg.setPSIconUIVisiable(ui, visible)
	if not ui then
		return false
	end

	logger:info("pg.setPSIconUIVisiable ui:%s, visible:%s", tostring(ui), tostring(visible))

	pg._psIconUIVisibleStates[ui] = visible and true or false

	for k, isVisible in pairs(pg._psIconUIVisibleStates) do
		if isVisible then
			logger:info("pg.setPSIconUIVisiable ui:%s, visible:%s, return true", tostring(k), tostring(visible))

			return true
		end
	end

	return false
end

function pg.openDebug()
	local curFileDir = require("Common.Utils.Utils").getCurrentFileDir()

	package.cpath = package.cpath .. ";" .. curFileDir .. "/../../../server/vscode/?.dll"
	package.path = package.path .. ";" .. curFileDir .. "/../../../server/vscode/?.lua"

	if pg.me and pg.me.doGmCmd2 ~= nil then
		pg.me:doGmCmd2("requestDebug", {})
	end

	local ok, debugger = pcall(require, "emmy_debugger")

	if ok and debugger ~= nil then
		debugger.tryOpen(9966, true)
	end

	pg.patchEmmyHelper()
end

function pg.initEmmyDebug()
	ClientUtils.initEmmyDebug()
end

function pg.openAIDebug()
	if not AIUtils.checkOpenCPP() then
		local AIDebugger = require("Common.AI.Behaviac.Debugger")

		AIDebugger.openDebug()
		pg.global.ui.tips:showTextTip("AIDebug Server 开启" .. (AIDebugger.lib.m_server and "成功" or "失败"))
	else
		pg.world.openBXSocket()
		pg.global.ui.tips:showTextTip("AIDebug Server 开启 成功")
	end
end

function pg.startAIDebug()
	if not AIUtils.checkOpenCPP() then
		local AIDebugger = require("Common.AI.Behaviac.Debugger")

		AIDebugger.acceptConnect()
		pg.global.ui.tips:showTextTip("AIDebug Client 连接" .. (AIDebugger.lib.m_client and "成功" or "失败"))
	end
end

function pg.closeAIDebug()
	if not AIUtils.checkOpenCPP() then
		local AIDebugger = require("Common.AI.Behaviac.Debugger")

		AIDebugger.closeDebug()
		pg.global.ui.tips:showTextTip("AIDebug Client 关闭")
	end
end

function pg.getEntity(entId)
	if type(entId) == "number" and LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("错误使用了getEntity函数,请使用getEntityByActorId来替换")
	end

	local entity = pg.global.entityMgr.getEntity(entId)

	if not entity or not entity.isInited then
		return nil
	end

	return entity
end

function pg.ent(entName)
	local ents = {}

	for key, value in pairs(pg.global.entityMgr.getAllEntities()) do
		if value.className == entName then
			ents[key] = value
		end
	end

	return ents
end

function pg.getEntities()
	local validEntities = {}
	local entities = pg.global.entityMgr.getAllEntities()

	for id, entity in pairs(entities) do
		if entity.isInited then
			validEntities[id] = entity
		end
	end

	return validEntities
end

function pg.getEntityByActorId(actorId)
	if type(actorId) == "string" and LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("错误使用了getEntityByActorId函数,请使用getEntity来替换")
	end

	return pg.global.actorMgr.getEntity(actorId)
end

function pg.getEntityByUid(uid)
	if uid == nil then
		return nil
	end

	return pg.global.actorMgr.uid2Ent[uid]
end

function pg.getEntitiesByTemplateId(templateId)
	local temp = {}
	local entities = pg.global.entityMgr.getAllEntities()

	for id, entity in pairs(entities) do
		if entity.isInited and entity.templateId ~= nil and entity.templateId == templateId then
			temp[id] = entity
		end
	end

	return temp
end

function pg.getEntitiesByPetPrototypeId(petPrototypeId)
	local temp = {}
	local entities = pg.global.entityMgr.getAllEntities()

	for id, entity in pairs(entities) do
		if entity.isInited and entity.getConfigData then
			local entityConfig = entity:getConfigData()

			if entityConfig ~= nil and entityConfig.petPrototypeId ~= nil and entityConfig.petPrototypeId == petPrototypeId then
				temp[id] = entity
			end
		end
	end

	return temp
end

function pg.getEntityByGlobalId(globalId)
	if pg.space then
		return pg.space:getEntityByGlobalId(globalId)
	else
		return nil
	end
end

function pg.getActorEntities()
	return pg.global.actorMgr.entities
end

function pg.profileEntityCount()
	local ret = {}
	local entCounts = pg.global.entityMgr.profileEntityCount()

	ret.total = entCounts

	if pg.game ~= nil then
		ret.displayLevel = pg.game.entityCount:getDisplayLevel1CountByType()
	end

	return ret
end

function pg.profileInstanceCount()
	local Class = require("Core.Framework.Class")
	local oldMem = collectgarbage("count")

	collectgarbage("collect")

	local newMem = collectgarbage("count")
	local counts = Class.profileInstanceCount()
	local list = {}
	local total = 0

	for className, info in pairs(counts) do
		total = total + 1
		list[#list + 1] = {
			className = className,
			alive = info.alive,
			created = info.created
		}
	end

	table.sort(list, function(a, b)
		if a.alive ~= b.alive then
			return a.alive > b.alive
		end

		return a.className < b.className
	end)
	print("garbage collect", oldMem, newMem)

	local path = "Logs\\InstanceCount.txt"
	local file = io.open(path, "w")

	if file then
		file:write(string.format("total: %d\n", total))

		for i, data in ipairs(list) do
			file:write(string.format("{className: %s, alive: %d, created: %d}\n", data.className, data.alive, data.created))
		end

		file:close()
	end
end

function pg.profilePuppetDistance()
	local Utils = require("Common.Utils.Utils")
	local ents = EntityManager._entities
	local entClass
	local disList = {}
	local index = 1
	local playerPos = pg.me:getPosition()

	for _, entity in pairs(ents) do
		if entity then
			entClass = entity:getClassType()

			if entClass == "ClientPuppet" then
				disList[index] = Utils.distance2D(playerPos, entity:getPosition())
				index = index + 1
			end
		end
	end

	table.sort(disList)

	return disList
end

function pg.getLocalizationText(hashId, ...)
	return ClientTextUtils.getLocalizationText(hashId, ...)
end

function pg.getLocalizationTextWithoutSuffix(hashId, ...)
	return ClientTextUtils.getLocalizationTextWithoutSuffix(hashId, ...)
end

function pg.LocalizationNumber(content)
	return ClientTextUtils.getFormatNumber(content)
end

function pg.getGameString(key)
	return ClientTextUtils.getGameString(key)
end

function pg.setLocalizationText(uText, hashId, ...)
	return ClientTextUtils.setLocalizationText(uText, hashId, ...)
end

function pg.getFormatText(content, ...)
	return ClientTextUtils.getFormatText(content, ...)
end

function pg.getLocalizationTimeYMD(ts, onlyDate)
	ts = ts or os.time()

	if (pg.languageType or 0) == ClientConst.LANGUAGE_TYPE_MAP.zh_CN then
		if onlyDate then
			return os.date("%Y/%m/%d", ts)
		end

		return os.date("%Y/%m/%d %H:%M:%S", ts)
	end

	if onlyDate then
		return os.date("%m/%d/%Y", ts)
	end

	return os.date("%m/%d/%Y %H:%M:%S", ts)
end

function pg.getLocalizationCountDown(seconds)
	return ClientTextUtils.getLocalizationCountDown(seconds)
end

function pg.parseDescText(descText, dataInfo)
	return ClientTextUtils.parseDescText(descText, dataInfo)
end

function pg.execRpcMsg(entId, methodName, ...)
	if not _G_IsDebugMode then
		return
	end

	local ent = pg.getEntity(entId)

	if ent == nil then
		return "entity is nil"
	end

	local RpcDebugHelper = require("Utils.RpcDebugHelper")

	RpcDebugHelper.TmpClosed = true

	ent:serverMsg(methodName, ...)

	RpcDebugHelper.TmpClosed = false
end

function pg.logDebug()
	return LoggerManager.checkLogger(LoggerConst.DEBUG)
end

function pg.logInfo()
	return LoggerManager.checkLogger(LoggerConst.INFO)
end

function pg.logWarn()
	return LoggerManager.checkLogger(LoggerConst.WARN)
end

function pg.logError()
	return LoggerManager.checkLogger(LoggerConst.ERROR)
end

function pg.patchEmmyHelper()
	local AccessControl = require("Core.Framework.AccessControl")
	local patchState = rawget(ClientUtils, "__worldxEmmyPatchState")

	if not patchState then
		patchState = {}

		rawset(ClientUtils, "__worldxEmmyPatchState", patchState)
	end

	local emmyHelper = rawget(_G, "emmyHelper")
	local LUA_TNONE = -1
	local LUA_TNIL = 0
	local LUA_TBOOLEAN = 1
	local LUA_TLIGHTUSERDATA = 2
	local LUA_TNUMBER = 3
	local LUA_TSTRING = 4
	local LUA_TTABLE = 5
	local LUA_TFUNCTION = 6
	local LUA_TUSERDATA = 7
	local LUA_TTHREAD = 8
	local LUA_NUMTAGS = 9

	local function typeNumber(typeName)
		if typeName == "number" then
			return LUA_TNUMBER
		elseif typeName == "string" then
			return LUA_TSTRING
		elseif typeName == "table" then
			return LUA_TTABLE
		elseif typeName == "boolean" then
			return LUA_TBOOLEAN
		elseif typeName == "function" then
			return LUA_TSTRING
		elseif typeName == "string" then
			return LUA_TFUNCTION
		elseif typeName == "userdata" then
			return LUA_TUSERDATA
		elseif typeName == "lightuserdata" then
			return LUA_TLIGHTUSERDATA
		else
			return LUA_TNIL
		end
	end

	local function createNewNode(key, value)
		local newNode = emmyHelper.createNode()

		newNode.name = tostring(key)
		newNode.value = tostring(value)

		local valueType = type(value)

		newNode.valueTypeName = valueType
		newNode.valueType = typeNumber(valueType)

		return newNode, valueType
	end

	local function changeReadonly(variable, obj, typeName, depth)
		local raw = AccessControl.RawDataMap[obj] or obj

		variable.value = tostring(raw) .. " readonly"
		variable.valueTypeName = typeName

		local count = 0

		for k, v in pairs(raw) do
			count = count + 1
		end

		if count == #raw then
			for i, v in ipairs(raw) do
				local newNode, valueType = createNewNode(i, v)

				variable:addChild(newNode)

				if valueType == "table" then
					changeReadonly(newNode, v, "table", depth - 1)
				end
			end
		else
			for i, v in pairs(raw) do
				local newNode, valueType = createNewNode(i, v)

				variable:addChild(newNode)

				if valueType == "table" then
					changeReadonly(newNode, v, "table", depth - 1)
				end
			end
		end
	end

	local function changeBdd(variable, obj, typeName, depth, isRootTable)
		local raw = obj

		if isRootTable == 2 then
			variable.valueTypeName = typeName

			local cacheCount = 0

			for i, v in pairs(raw) do
				local cached = rawget(raw, i) ~= nil

				cacheCount = cacheCount + (cached and 1 or 0)

				local newNode, valueType = createNewNode(i, v, cached)

				variable:addChild(newNode)

				if valueType == "table" or valueType == "userdata" then
					local metatable = getmetatable(v)

					if metatable and obj._BddData_ == true then
						changeBdd(newNode, v, "table", depth - 1, cached and 1 or 0)
					end
				end
			end

			variable.value = string.format("%s bdd cached %d", tostring(raw), cacheCount)
		else
			if isRootTable == 1 then
				variable.value = tostring(raw) .. " bdd cacehd"
			else
				variable.value = tostring(raw) .. " bdd"
			end

			variable.valueTypeName = typeName

			for i, v in pairs(raw) do
				local newNode, valueType = createNewNode(i, v)

				variable:addChild(newNode)

				if valueType == "table" or valueType == "userdata" then
					local metatable = getmetatable(v)

					if metatable and obj._BddData_ == true then
						changeBdd(newNode, v, "table", depth - 1)
					end
				end
			end
		end
	end

	local function _changeCustomDict(variable, obj, typeName, depth, collect)
		local raw = obj

		collect[raw] = true
		variable.valueTypeName = typeName

		if depth >= 6 then
			variable.value = tostring(raw) .. " CustomDict ..."

			return
		end

		local count = 0

		for i, v in pairs(raw) do
			local newNode, valueType = createNewNode(i, v)

			variable:addChild(newNode)

			if valueType == "table" and v._properties and not collect[v] then
				_changeCustomDict(newNode, v, "table", depth + 1, collect)
			end

			count = count + 1
		end

		variable.value = string.format("%s CustomDict %s", tostring(raw), count)
	end

	local function changeCustomDict(variable, obj, typeName, depth)
		local collect = {}

		_changeCustomDict(variable, obj, typeName, depth, collect)
	end

	local function changeQueryVariable(variable, obj, typeName, depth)
		if not obj then
			return false
		end

		if AccessControl.RawDataMap[obj] ~= nil then
			changeReadonly(variable, obj, typeName, depth)

			return true
		end

		local objType = type(obj)

		if objType == "userdata" or objType == "table" then
			local metatable = getmetatable(obj)

			if metatable and obj._BddData_ == true then
				changeBdd(variable, obj, typeName, depth, objType == "table" and 2)

				return true
			end
		end

		if objType == "table" and obj._properties then
			changeCustomDict(variable, obj, typeName, depth)

			return true
		end

		return false
	end

	local function patchSingleEmmyHelper(emmy)
		if type(emmy) ~= "table" then
			return false
		end

		if emmy.__worldxQueryVariablePatched then
			return true
		end

		if emmyHelperInit then
			emmyHelperInit()
		end

		emmy.queryVariable = changeQueryVariable
		emmy.__worldxQueryVariablePatched = true

		return true
	end

	if not patchState.globalHookInstalled then
		local globalMt = getmetatable(_G)

		if globalMt and not globalMt.__worldxEmmyHelperHookInstalled then
			local originalNewIndex = globalMt.__newindex

			globalMt.__worldxEmmyHelperHookInstalled = true
			globalMt.__worldxEmmyHelperOriginalNewIndex = originalNewIndex

			function globalMt.__newindex(tbl, key, value)
				if type(originalNewIndex) == "function" then
					originalNewIndex(tbl, key, value)
				elseif type(originalNewIndex) == "table" then
					originalNewIndex[key] = value
				else
					rawset(tbl, key, value)
				end

				if key == "emmyHelper" then
					patchSingleEmmyHelper(rawget(tbl, key) or value)
				end
			end
		end

		patchState.globalHookInstalled = true
	end

	if not patchSingleEmmyHelper(emmyHelper) then
		-- block empty
	end
end

function pg.patchEmmyHelperForIDEA()
	local AccessControl = require("Core.Framework.AccessControl")
	local patchState = rawget(ClientUtils, "__worldxEmmyPatchState")

	if not patchState then
		patchState = {}

		rawset(ClientUtils, "__worldxEmmyPatchState", patchState)
	end

	local function normalizeQueryVariableObj(obj, typeName)
		if not obj then
			return obj, typeName, false
		end

		if AccessControl.RawDataMap[obj] ~= nil then
			return AccessControl:getRawTable(obj), "table", true
		end

		local objType = type(obj)

		if objType == "table" and type(bdd2DeepTable) == "function" then
			local metatable = getmetatable(obj)

			if rawget(obj, "_BddData_") == true or metatable and obj._BddData_ == true then
				return bdd2DeepTable(obj), "table", true
			end
		end

		if objType == "userdata" then
			local metatable = getmetatable(obj)

			if metatable and metatable._BddData_ == true and type(bdd2DeepTable) == "function" then
				return bdd2DeepTable(obj), "table", true
			end
		end

		return obj, typeName, false
	end

	local function patchSingleEmmyHelper(emmy)
		if type(emmy) ~= "table" then
			return false
		end

		if emmy.__worldxQueryVariablePatched then
			return true
		end

		local originalQv = emmy.queryVariable

		if type(originalQv) == "function" then
			function emmy.queryVariable(variable, obj, typeName, depth)
				local queryObj, queryTypeName, handled = normalizeQueryVariableObj(obj, typeName)

				if handled then
					variable:query(queryObj, depth, true)

					return true
				end

				return originalQv(variable, queryObj, queryTypeName, depth)
			end
		else
			function emmy.queryVariable(variable, obj, typeName, depth)
				local queryObj, _, handled = normalizeQueryVariableObj(obj, typeName)

				if handled then
					variable:query(queryObj, depth, true)

					return true
				end
			end
		end

		emmy.__worldxQueryVariablePatched = true

		print("patchEmmyHelper success", tostring(_G), tostring(originalQv), tostring(emmy.queryVariable))

		return true
	end

	if not patchState.globalHookInstalled then
		local globalMt = getmetatable(_G)

		if globalMt and not globalMt.__worldxEmmyHelperHookInstalled then
			local originalNewIndex = globalMt.__newindex

			globalMt.__worldxEmmyHelperHookInstalled = true
			globalMt.__worldxEmmyHelperOriginalNewIndex = originalNewIndex

			function globalMt.__newindex(tbl, key, value)
				if type(originalNewIndex) == "function" then
					originalNewIndex(tbl, key, value)
				elseif type(originalNewIndex) == "table" then
					originalNewIndex[key] = value
				else
					rawset(tbl, key, value)
				end

				if key == "emmyHelper" then
					patchSingleEmmyHelper(rawget(tbl, key) or value)
				end
			end
		end

		patchState.globalHookInstalled = true
	end

	if not patchState.retryTimerStarted then
		local TimerManager = require("Core.Timer.TimerManager")
		local ok, timerId = pcall(TimerManager.addRepeatTimer, 1, function()
			patchSingleEmmyHelper(rawget(_G, "emmyHelper"))
		end)

		if ok then
			patchState.retryTimerStarted = true
			patchState.retryTimerId = timerId
		end
	end

	local emmy = rawget(_G, "emmyHelper")

	if not patchSingleEmmyHelper(emmy) then
		print("patchEmmyHelper skipped", tostring(_G), "emmyHelper is nil")
	end
end

function pg.patchRiderEmmyHelper()
	local AccessControl = require("Core.Framework.AccessControl")
	local patchState = rawget(ClientUtils, "__riderEmmyPatchState")

	if not patchState then
		patchState = {
			retryTimerStarted = false,
			globalHookInstalled = false
		}

		rawset(ClientUtils, "__riderEmmyPatchState", patchState)
	end

	local function normalizeQueryVariableObj(obj, typeName)
		if not obj then
			return obj, typeName, false
		end

		if AccessControl.RawDataMap and AccessControl.RawDataMap[obj] ~= nil then
			return AccessControl:getRawTable(obj), "table", true
		end

		local objType = type(obj)

		if (objType == "table" or objType == "userdata") and type(bdd2DeepTable) == "function" then
			local mt = getmetatable(obj)

			if rawget(obj, "_BddData_") == true or mt and mt._BddData_ == true then
				return bdd2DeepTable(obj), "table", true
			end
		end

		return obj, typeName, false
	end

	local function patchSingleEmmyHelper(emmy)
		if type(emmy) ~= "table" then
			return false
		end

		if emmy.__riderPatched then
			return true
		end

		local originalQv = emmy.queryVariable

		function emmy.queryVariable(variable, obj, typeName, depth)
			local queryObj, queryTypeName, handled = normalizeQueryVariableObj(obj, typeName)

			if handled then
				variable:query(queryObj, depth, true)

				return true
			end

			if type(originalQv) == "function" then
				return originalQv(variable, queryObj, queryTypeName, depth)
			end
		end

		emmy.__riderPatched = true

		print("[RiderPatch] EmmyHelper hooked successfully.")

		return true
	end

	if not patchState.globalHookInstalled then
		local globalMt = getmetatable(_G) or {}
		local oldNewIndex = globalMt.__newindex

		function globalMt.__newindex(t, k, v)
			if type(oldNewIndex) == "function" then
				oldNewIndex(t, k, v)
			elseif type(oldNewIndex) == "table" then
				oldNewIndex[k] = v
			else
				rawset(t, k, v)
			end

			if k == "emmyHelper" then
				patchSingleEmmyHelper(v)
			end
		end

		setmetatable(_G, globalMt)

		patchState.globalHookInstalled = true
	end

	if not patchState.retryTimerStarted then
		local TimerManager = require("Core.Timer.TimerManager")

		if TimerManager and TimerManager.addRepeatTimer then
			pcall(TimerManager.addRepeatTimer, 2, function()
				local emmy = rawget(_G, "emmyHelper")

				if emmy and not emmy.__riderPatched then
					patchSingleEmmyHelper(emmy)
				end
			end)

			patchState.retryTimerStarted = true
		end
	end

	patchSingleEmmyHelper(rawget(_G, "emmyHelper"))
end

function pg.patchRiderEmmyHelper()
	local AccessControl = require("Core.Framework.AccessControl")
	local patchState = rawget(ClientUtils, "__riderEmmyPatchState")

	if not patchState then
		patchState = {
			retryTimerStarted = false,
			globalHookInstalled = false
		}

		rawset(ClientUtils, "__riderEmmyPatchState", patchState)
	end

	local function normalizeQueryVariableObj(obj, typeName)
		if not obj then
			return obj, typeName, false
		end

		if AccessControl.RawDataMap and AccessControl.RawDataMap[obj] ~= nil then
			return AccessControl:getRawTable(obj), "table", true
		end

		local objType = type(obj)

		if (objType == "table" or objType == "userdata") and type(bdd2DeepTable) == "function" then
			local mt = getmetatable(obj)

			if rawget(obj, "_BddData_") == true or mt and mt._BddData_ == true then
				return bdd2DeepTable(obj), "table", true
			end
		end

		return obj, typeName, false
	end

	local function patchSingleEmmyHelper(emmy)
		if type(emmy) ~= "table" then
			return false
		end

		if emmy.__riderPatched then
			return true
		end

		local originalQv = emmy.queryVariable

		function emmy.queryVariable(variable, obj, typeName, depth)
			local queryObj, queryTypeName, handled = normalizeQueryVariableObj(obj, typeName)

			if handled then
				variable:query(queryObj, depth, true)

				return true
			end

			if type(originalQv) == "function" then
				return originalQv(variable, queryObj, queryTypeName, depth)
			end
		end

		emmy.__riderPatched = true

		print("[RiderPatch] EmmyHelper hooked successfully.")

		return true
	end

	if not patchState.globalHookInstalled then
		local globalMt = getmetatable(_G) or {}
		local oldNewIndex = globalMt.__newindex

		function globalMt.__newindex(t, k, v)
			if type(oldNewIndex) == "function" then
				oldNewIndex(t, k, v)
			elseif type(oldNewIndex) == "table" then
				oldNewIndex[k] = v
			else
				rawset(t, k, v)
			end

			if k == "emmyHelper" then
				patchSingleEmmyHelper(v)
			end
		end

		setmetatable(_G, globalMt)

		patchState.globalHookInstalled = true
	end

	if not patchState.retryTimerStarted then
		local TimerManager = require("Core.Timer.TimerManager")

		if TimerManager and TimerManager.addRepeatTimer then
			pcall(TimerManager.addRepeatTimer, 2, function()
				local emmy = rawget(_G, "emmyHelper")

				if emmy and not emmy.__riderPatched then
					patchSingleEmmyHelper(emmy)
				end
			end)

			patchState.retryTimerStarted = true
		end
	end

	patchSingleEmmyHelper(rawget(_G, "emmyHelper"))
end

return pg
