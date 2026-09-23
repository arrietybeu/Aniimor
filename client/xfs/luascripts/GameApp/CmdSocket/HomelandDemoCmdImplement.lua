-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\CmdSocket\\HomelandDemoCmdImplement.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("HomelandDemoCmdImplement")
local Const = require("Common.Const.Const")
local EventConst = require("Common.Const.EventConst")
local DialogueConst = require("Const.DialogueConst")
local Utils = require("Common.Utils.Utils")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local HomelandOperateData = require("Data.homeland_operate_data")
local HomelandFacilityData = require("Data.homeland_facility_data")
local PetData = require("Data.pet_data")
local PetNatureData = require("Data.pet_nature_data")
local HomelandDemoCmdImplement = {}

HomelandDemoCmdImplement.EVENT_TOPIC_BRIDGE_STATE = "homelandDemo.bridgeStateChanged"
HomelandDemoCmdImplement.EVENT_TOPIC_PLAYER_WORK = "homelandDemo.playerWorkChanged"
HomelandDemoCmdImplement.EVENT_TOPIC_PLAYER_ENTER = "homelandDemo.playerEnterHomeland"
HomelandDemoCmdImplement.EVENT_TOPIC_PLAYER_CHAT = "homelandDemo.playerChatMessage"
HomelandDemoCmdImplement.EVENT_TOPIC_LEARN_COMPLETED = "homelandDemo.learnCompleted"
HomelandDemoCmdImplement.EVENT_TOPIC_PET_ACTION_FINISHED = "homelandDemo.petActionFinished"
HomelandDemoCmdImplement.EVENT_TOPIC_DEMO_COMPLETED = "homelandDemo.completed"
HomelandDemoCmdImplement.DEFAULT_PULL_MAX_COUNT = 50
HomelandDemoCmdImplement.MAX_PULL_MAX_COUNT = 200
HomelandDemoCmdImplement.MAX_EVENT_QUEUE = 200
HomelandDemoCmdImplement.DEFAULT_BUBBLE_DURATION = 5
HomelandDemoCmdImplement.HOME_PET_ENTITY_CLASS_NAME = "ClientHomePet"
HomelandDemoCmdImplement.LEARN_PROGRESS_MAX = 100
HomelandDemoCmdImplement.DEMO_END_SUB_TARGET_SEQ = 1
HomelandDemoCmdImplement.INVALID_ASSET_ERROR_MSG = "没有当前的动画或者气泡资产"
HomelandDemoCmdImplement.ABILITY_ID_TO_NAME = {
	[1006] = "wind",
	[1008] = "light",
	[1001] = "seed",
	[1004] = "electric",
	[1007] = "harvest",
	[1000] = "heat",
	[1003] = "reclaim",
	[1002] = "water",
	[1100] = "transport",
	[1005] = "cool",
	[1101] = "craft",
	[1102] = "play",
	[1103] = "incense"
}
HomelandDemoCmdImplement.MINING_ABILITY_ID = 1003
HomelandDemoCmdImplement.STATE = {
	demoGreetTriggered = false,
	nextEventSeq = 1,
	demoCompletedTriggered = false,
	demoMiningTipTriggered = false,
	demoChatTriggered = false,
	enabled = false,
	eventQueue = {},
	subscribers = {},
	learnProgress = {}
}
HomelandDemoCmdImplement.CMD_META = {
	isInHomeland = {
		category = "query",
		desc = "检测当前是否在家园场景，并返回当前家园归属、spaceType、spaceId 等基础信息"
	},
	getPlayerInfo = {
		category = "query",
		desc = "获取当前玩家信息；包含 playerId / uid / actorId / 当前位置 / 当前朝向 / 当前家园工作状态等"
	},
	getFacilities = {
		category = "query",
		desc = "获取当前家园设施列表；用于外部 AI 选择 facilityId 并给宠物派工"
	},
	getFacility = {
		desc = "获取单个家园设施信息；用于按 ornamentId/facilityId 查询位置和当前工作状态",
		params = "{ornamentId|facilityId}",
		category = "query"
	},
	getMiningFacilities = {
		desc = "获取当前家园内可用于采矿的设施列表；默认排除 disable=true 的设施",
		params = "{includeDisabled?:bool=false}",
		category = "query"
	},
	getTransportFacilities = {
		desc = "获取当前家园内有可搬运产出(需要搬运)的设施列表；默认排除 disable=true 的设施",
		params = "{includeDisabled?:bool=false, onlyOverThreshold?:bool=false}",
		category = "query"
	},
	getRuntimeSnapshot = {
		category = "query",
		desc = "一次性获取 homelandDemo 常用运行时聚合快照：家园状态 + 玩家信息 + 设施列表 + 家园宠物信息"
	},
	getHomePets = {
		category = "query",
		desc = "获取当前家园内宠物列表；包含 id、名字、能力、所在设施、是否空闲等信息"
	},
	getHomePetsInRange = {
		desc = "获取离玩家一定距离内的家园宠物(带 distance 字段，近->远排序)；不传 range 返回全部",
		params = "{range?:num}",
		category = "query"
	},
	getCmdList = {
		category = "query",
		desc = "获取 homelandDemo 当前支持的查询 / 操作指令清单；命令名通过遍历模块公开函数自动枚举"
	},
	getState = {
		category = "query",
		desc = "获取 homelandDemo 当前开关、订阅者、事件队列、最近命令和最近事件等运行状态"
	},
	pullEvents = {
		desc = "拉取 homelandDemo 事件队列中 seq 大于 sinceSeq 的事件",
		params = "{sinceSeq?:int=0, maxCount?:int=50}",
		category = "query"
	},
	setEnabled = {
		desc = "开启 / 关闭 homelandDemo 事件推送模式；关闭后不再上报玩家工作事件",
		params = "{enabled:bool}",
		category = "action"
	},
	setPetCamera = {
		desc = "开启 / 关闭家园宠物观察镜头；开启时跟随指定宠物，并在进入瞬间对准宠物正面",
		params = "{enabled:bool, petId?:string, actorId?:int}",
		category = "action"
	},
	assignPetWork = {
		desc = "把指定家园宠物派去指定设施工作；默认会强制打断当前工作并派发 MOVING",
		category = "action",
		async = true,
		params = "{petId, facilityId, interruptWork?:bool=true, force?:bool=true}"
	},
	assignPetTransport = {
		desc = "把指定家园宠物派去搬运指定设施的产出；派发 GOTO_TRANSPORT 让宠物先移动到设施再搬，不会被满产设施中途打断。需家园内有存储箱、设施有可搬产出、宠物会 transport(1100)",
		category = "action",
		async = true,
		params = "{petId, facilityId, force?:bool=true}"
	},
	petAction = {
		desc = "统一的宠物 AI 特殊动作指令；通过 doSpecialPetAction 触发 BC_Wild_Home_NvdiaReviewDemo，由表情/动画/移动参数驱动。可用 demoTrigger 在派发动作时顺带触发家园demo打招呼/聊天玩法阶段",
		params = "{petId?|petIds?, actorId?:int, ornamentId?:int, toMaster?:bool, isFollow?:bool, targetPos?:number[3]|{x:num,y:num,z:num}, keepAway?:bool, stopDist?:num, emojiKey?:string, chatText?:string, chatDuration?:num, animationKey?:string, animationLoopKey?:string[3], speed?:num, speedRateType?:int, waitTime?:num, animationTime?:num, emojiTime?:num, interruptWork?:bool=true, demoTrigger?:enum(greet|chat)}",
		category = "action"
	},
	showBubble = {
		desc = "让指定家园宠物只冒表情气泡，不打断当前工作，不额外播放动作",
		params = "{petId?|petIds?, emojiName?:string=Happy, duration?:num=5}",
		category = "action"
	},
	showPetChat = {
		desc = "让指定家园宠物显示自定义文字对话气泡，不打断当前工作，不额外播放动作",
		params = "{petId?|petIds?, text:string, duration?:num=3}",
		category = "action"
	},
	getLearnProgress = {
		desc = "查询某宠物某个家园能力 abilityId 的学习进度；所有能力学习阈值统一为 100",
		params = "{petId, abilityId}",
		category = "query"
	},
	learnAbility = {
		desc = "推进指定宠物对某个家园能力 abilityId 的学习进度(只记录进度，不派指令)；首次达到 100 时推送学习完成事件",
		params = "{petId?|petIds?, abilityId:int, gain:num}",
		category = "action"
	},
	resetLearnProgress = {
		desc = "重置学习进度(调试用)；可按 petId / abilityId 精确清除，均不传则清空全部",
		params = "{petId?, abilityId?}",
		category = "action"
	},
	reset = {
		category = "action",
		desc = "重置 homelandDemo 运行时状态：开关、事件队列、订阅者、最近命令和最近事件"
	}
}
HomelandDemoCmdImplement.CMD_META.debugPetEntity = {
	desc = "debug homeland pet entity mapping",
	params = "{petId:string, limit?:int=20}",
	category = "query"
}

function HomelandDemoCmdImplement._err(code, msg)
	return {
		ok = false,
		error = {
			code = code,
			msg = msg
		}
	}
end

function HomelandDemoCmdImplement._ok(data)
	return {
		ok = true,
		data = data or {}
	}
end

function HomelandDemoCmdImplement._asyncOk(extra)
	local data = {
		async = true,
		dispatched = true
	}

	if extra then
		for key, value in pairs(extra) do
			data[key] = value
		end
	end

	return {
		ok = true,
		data = data
	}
end

function HomelandDemoCmdImplement._requireHomeland()
	if not pg.me or not pg.me.space then
		return HomelandDemoCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "no player space")
	end

	if not pg.me.space.isHomeland or not pg.me.space:isHomeland() then
		return HomelandDemoCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "not in homeland")
	end

	return nil
end

function HomelandDemoCmdImplement._safeCall(fn, ...)
	local ok, ret = pcall(fn, ...)

	if not ok then
		return nil, ret
	end

	return ret, nil
end

function HomelandDemoCmdImplement._cloneValue(value, depth)
	local valueType = type(value)

	if valueType ~= "table" then
		return value
	end

	depth = depth or 0

	if depth >= 6 then
		return "<max-depth>"
	end

	local out = {}

	for key, child in pairs(value) do
		out[key] = HomelandDemoCmdImplement._cloneValue(child, depth + 1)
	end

	return out
end

function HomelandDemoCmdImplement._cloneForCmd(value, depth)
	depth = depth or 0

	local valueType = type(value)

	if valueType ~= "table" and valueType ~= "userdata" then
		return value
	end

	if depth > 4 then
		return nil
	end

	local out = {}

	for key, child in pairs(value) do
		local keyType = type(key)
		local childType = type(child)

		if keyType == "string" or keyType == "number" then
			if childType == "string" or childType == "number" or childType == "boolean" then
				out[key] = child
			elseif childType == "table" or childType == "userdata" then
				out[key] = HomelandDemoCmdImplement._cloneForCmd(child, depth + 1)
			end
		end
	end

	return out
end

function HomelandDemoCmdImplement._addPetId(petIds, seen, allowSet, petId)
	if petId == nil or petId == 0 or petId == "" then
		return
	end

	local key = tostring(petId)

	if allowSet and not allowSet[key] then
		return
	end

	if seen[key] then
		return
	end

	seen[key] = true
	petIds[#petIds + 1] = petId
end

function HomelandDemoCmdImplement._isBlankAssetKey(assetKey)
	return assetKey == nil or assetKey == ""
end

function HomelandDemoCmdImplement._validateAssetKey(assetKey, validSet)
	if HomelandDemoCmdImplement._isBlankAssetKey(assetKey) then
		return true
	end

	if type(assetKey) ~= "string" then
		return false
	end

	if validSet == nil then
		return true
	end

	return validSet[assetKey] == true
end

function HomelandDemoCmdImplement._validateAssetKeyList(assetKeyList, validSet)
	if assetKeyList == nil then
		return true
	end

	if type(assetKeyList) ~= "table" then
		return false
	end

	if #assetKeyList ~= 3 then
		return false
	end

	for _, assetKey in ipairs(assetKeyList) do
		if not HomelandDemoCmdImplement._validateAssetKey(assetKey, validSet) or HomelandDemoCmdImplement._isBlankAssetKey(assetKey) then
			return false
		end
	end

	return true
end

function HomelandDemoCmdImplement._validatePetActionAssets(params)
	if not HomelandDemoCmdImplement._validateAssetKey(params.emojiKey, nil) then
		return HomelandDemoCmdImplement.INVALID_ASSET_ERROR_MSG
	end

	if not HomelandDemoCmdImplement._validateAssetKey(params.animationKey, nil) then
		return HomelandDemoCmdImplement.INVALID_ASSET_ERROR_MSG
	end

	if not HomelandDemoCmdImplement._validateAssetKeyList(params.animationLoopKey, nil) then
		return HomelandDemoCmdImplement.INVALID_ASSET_ERROR_MSG
	end

	if params.chatText ~= nil and (type(params.chatText) ~= "string" or #params.chatText == 0) then
		return "invalid params.chatText (must be non-empty string)"
	end

	if params.chatDuration ~= nil then
		if params.chatText == nil then
			return "params.chatDuration requires params.chatText"
		end

		if type(params.chatDuration) ~= "number" or params.chatDuration <= 0 then
			return "invalid params.chatDuration (must be positive number)"
		end
	end

	return nil
end

function HomelandDemoCmdImplement._resetState()
	HomelandDemoCmdImplement.STATE.enabled = false
	HomelandDemoCmdImplement.STATE.nextEventSeq = 1
	HomelandDemoCmdImplement.STATE.eventQueue = {}
	HomelandDemoCmdImplement.STATE.subscribers = {}
	HomelandDemoCmdImplement.STATE.lastCommand = nil
	HomelandDemoCmdImplement.STATE.lastEvent = nil
	HomelandDemoCmdImplement.STATE.learnProgress = {}
	HomelandDemoCmdImplement.STATE.demoGreetTriggered = false
	HomelandDemoCmdImplement.STATE.demoChatTriggered = false
	HomelandDemoCmdImplement.STATE.demoMiningTipTriggered = false
	HomelandDemoCmdImplement.STATE.demoCompletedTriggered = false
end

function HomelandDemoCmdImplement._resetDemoFlowState()
	HomelandDemoCmdImplement.STATE.learnProgress = {}
	HomelandDemoCmdImplement.STATE.demoGreetTriggered = false
	HomelandDemoCmdImplement.STATE.demoChatTriggered = false
	HomelandDemoCmdImplement.STATE.demoMiningTipTriggered = false
	HomelandDemoCmdImplement.STATE.demoCompletedTriggered = false
end

function HomelandDemoCmdImplement._removeSubscriber(connId)
	if connId == nil then
		return
	end

	HomelandDemoCmdImplement.STATE.subscribers[tostring(connId)] = nil
end

function HomelandDemoCmdImplement._vec3(value)
	if value == nil then
		return nil
	end

	local ok, x = pcall(function()
		return value.x
	end)

	if not ok or x == nil then
		return nil
	end

	return {
		x = value.x,
		y = value.y,
		z = value.z
	}
end

function HomelandDemoCmdImplement._getEntityPosition(entity)
	if entity == nil then
		return nil
	end

	local position

	if type(entity.getPosition) == "function" then
		position = HomelandDemoCmdImplement._safeCall(function()
			return entity:getPosition()
		end)
	end

	if position ~= nil then
		return HomelandDemoCmdImplement._vec3(position)
	end

	if entity.positionAgent and entity.positionAgent.position ~= nil then
		return HomelandDemoCmdImplement._vec3(entity.positionAgent.position)
	end

	return nil
end

function HomelandDemoCmdImplement._getEntityForward(entity)
	if entity == nil then
		return nil
	end

	local forward = HomelandDemoCmdImplement._safeCall(function()
		return entity:getForward()
	end)

	return HomelandDemoCmdImplement._vec3(forward)
end

function HomelandDemoCmdImplement._buildPlayerInfo()
	if not pg.me then
		return nil
	end

	local player = pg.me
	local data = {
		playerId = player.id,
		uid = player.uid,
		actorId = player.actorId,
		playerName = player.playerName,
		position = HomelandDemoCmdImplement._getEntityPosition(player),
		forward = HomelandDemoCmdImplement._getEntityForward(player)
	}
	local space = player.space

	if space then
		data.sceneId = space.sceneId
		data.spaceId = space.id
		data.spaceType = space.spaceType

		if space.isHomeland then
			local inHomeland = HomelandDemoCmdImplement._safeCall(function()
				return space:isHomeland()
			end)

			data.inHomeland = inHomeland and true or false
		else
			data.inHomeland = false
		end

		if data.inHomeland and space.isSelfHomeland then
			local isSelfHomeland = HomelandDemoCmdImplement._safeCall(function()
				return space:isSelfHomeland(player)
			end)

			data.isSelfHomeland = isSelfHomeland and true or false
		end

		local allocationInfo = space.playerAllocation and space.playerAllocation[player.id] or nil

		data.work = HomelandDemoCmdImplement._buildPlayerWorkEvent(player.id, allocationInfo)
	else
		data.inHomeland = false
	end

	return data
end

function HomelandDemoCmdImplement._localize(value)
	if value == nil then
		return nil
	end

	if type(value) ~= "number" then
		return value
	end

	local ok, text = pcall(function()
		return pgI18N.LocalizationText.GetFinalTextNoParam(value)
	end)

	if ok and type(text) == "string" and #text > 0 then
		return text
	end

	return value
end

function HomelandDemoCmdImplement._isUsableHomePetEntity(candidate)
	if not candidate or type(candidate) ~= "table" then
		return false
	end

	if candidate.eventEmitter ~= nil then
		return true
	end

	if candidate.isHomePet == true then
		return true
	end

	if candidate.eModel ~= nil and candidate.postComponentMethod ~= nil then
		return true
	end

	return false
end

function HomelandDemoCmdImplement._buildHomePetEntityDebugInfo(candidate, matchReason)
	if not candidate or type(candidate) ~= "table" then
		return nil
	end

	local globalId

	if type(candidate.getGlobalId) == "function" then
		globalId = HomelandDemoCmdImplement._safeCall(function()
			return candidate:getGlobalId()
		end)
	end

	local petInfoId

	if candidate.petInfo and candidate.petInfo.id ~= nil then
		petInfoId = candidate.petInfo.id
	end

	return {
		matchReason = matchReason,
		entityId = candidate.id,
		actorId = candidate.actorId,
		globalId = globalId,
		className = candidate.className,
		isHomePet = candidate.isHomePet == true,
		hasEventEmitter = candidate.eventEmitter ~= nil,
		petInfoId = petInfoId,
		isInited = candidate.isInited == true
	}
end

function HomelandDemoCmdImplement._matchHomePetEntityCandidate(candidate, petKey, numericPetId)
	if not HomelandDemoCmdImplement._isUsableHomePetEntity(candidate) then
		return nil
	end

	if candidate.isHomePet ~= true and candidate.className ~= HomelandDemoCmdImplement.HOME_PET_ENTITY_CLASS_NAME and (not candidate.petInfo or candidate.petInfo.id == nil) then
		return nil
	end

	if tostring(candidate.id) == petKey then
		return "entity.id"
	end

	if candidate.petInfo and tostring(candidate.petInfo.id) == petKey then
		return "entity.petInfo.id"
	end

	if candidate.actorId and tostring(candidate.actorId) == petKey then
		return "entity.actorId"
	end

	if numericPetId ~= nil and candidate.actorId == numericPetId then
		return "entity.actorId"
	end

	if type(candidate.getGlobalId) == "function" then
		local globalId = HomelandDemoCmdImplement._safeCall(function()
			return candidate:getGlobalId()
		end)

		if globalId ~= nil and tostring(globalId) == petKey then
			return "entity.globalId"
		end
	end

	return nil
end

function HomelandDemoCmdImplement._findHomePetEntityByScan(petId)
	local petKey = tostring(petId)
	local numericPetId = tonumber(petId)
	local entityMgr = pg and pg.global and pg.global.entityMgr or nil
	local allEntities = entityMgr and type(entityMgr.getAllEntities) == "function" and entityMgr.getAllEntities() or nil

	if type(allEntities) ~= "table" then
		return nil, nil
	end

	for _, candidate in pairs(allEntities) do
		local matchReason = HomelandDemoCmdImplement._matchHomePetEntityCandidate(candidate, petKey, numericPetId)

		if matchReason then
			return candidate, HomelandDemoCmdImplement._buildHomePetEntityDebugInfo(candidate, matchReason)
		end
	end

	return nil, nil
end

function HomelandDemoCmdImplement._findHomePetEntity(petId)
	local petEntity, debugInfo

	if pg and type(pg.getEntity) == "function" then
		petEntity = HomelandDemoCmdImplement._safeCall(function()
			return pg.getEntity(petId)
		end)

		if HomelandDemoCmdImplement._isUsableHomePetEntity(petEntity) then
			debugInfo = HomelandDemoCmdImplement._buildHomePetEntityDebugInfo(petEntity, "pg.getEntity")

			return petEntity, debugInfo
		end
	end

	if pg and type(pg.getEntityByGlobalId) == "function" then
		petEntity = HomelandDemoCmdImplement._safeCall(function()
			return pg.getEntityByGlobalId(petId)
		end)

		if HomelandDemoCmdImplement._isUsableHomePetEntity(petEntity) then
			debugInfo = HomelandDemoCmdImplement._buildHomePetEntityDebugInfo(petEntity, "pg.getEntityByGlobalId")

			return petEntity, debugInfo
		end
	end

	local actorId = tonumber(petId)

	if actorId ~= nil and pg and type(pg.getEntityByActorId) == "function" then
		petEntity = HomelandDemoCmdImplement._safeCall(function()
			return pg.getEntityByActorId(actorId)
		end)

		if HomelandDemoCmdImplement._isUsableHomePetEntity(petEntity) then
			debugInfo = HomelandDemoCmdImplement._buildHomePetEntityDebugInfo(petEntity, "pg.getEntityByActorId")

			return petEntity, debugInfo
		end
	end

	petEntity, debugInfo = HomelandDemoCmdImplement._findHomePetEntityByScan(petId)

	if petEntity then
		return petEntity, debugInfo
	end

	local space = HomelandDemoCmdImplement._getHomeSpace()

	if space and space.pets then
		local petKey = tostring(petId)

		for mapKey, candidate in pairs(space.pets) do
			local matchReason = HomelandDemoCmdImplement._matchHomePetEntityCandidate(candidate, petKey, actorId)

			if matchReason then
				return candidate, HomelandDemoCmdImplement._buildHomePetEntityDebugInfo(candidate, "space.pets." .. matchReason)
			end

			if tostring(mapKey) == petKey and HomelandDemoCmdImplement._isUsableHomePetEntity(candidate) then
				return candidate, HomelandDemoCmdImplement._buildHomePetEntityDebugInfo(candidate, "space.pets.mapKey")
			end
		end
	end

	return nil, nil
end

function HomelandDemoCmdImplement._collectHomePetEntityDebugList(limit)
	local result = {}
	local entityMgr = pg and pg.global and pg.global.entityMgr or nil
	local allEntities = entityMgr and type(entityMgr.getAllEntities) == "function" and entityMgr.getAllEntities() or nil

	if type(allEntities) ~= "table" then
		return result
	end

	local maxCount = tonumber(limit) or 20

	if maxCount <= 0 then
		maxCount = 20
	end

	for _, candidate in pairs(allEntities) do
		if HomelandDemoCmdImplement._isUsableHomePetEntity(candidate) and (candidate.isHomePet == true or candidate.className == HomelandDemoCmdImplement.HOME_PET_ENTITY_CLASS_NAME) then
			result[#result + 1] = HomelandDemoCmdImplement._buildHomePetEntityDebugInfo(candidate, "scan")

			if maxCount <= #result then
				break
			end
		end
	end

	table.sort(result, function(a, b)
		return tostring(a.entityId or "") < tostring(b.entityId or "")
	end)

	return result
end

function HomelandDemoCmdImplement._makeAbilityName(operateName)
	if type(operateName) ~= "string" then
		return operateName
	end

	local name = operateName

	name = string.gsub(name, "%.%.%.$", "")

	return name
end

function HomelandDemoCmdImplement._resolveAbilityName(abilityId, fallbackOperateName)
	if abilityId == nil then
		return nil
	end

	local numericId = tonumber(abilityId)
	local fixedName = numericId and HomelandDemoCmdImplement.ABILITY_ID_TO_NAME[numericId] or HomelandDemoCmdImplement.ABILITY_ID_TO_NAME[abilityId]

	if fixedName then
		return fixedName
	end

	local abilityName = HomelandDemoCmdImplement._makeAbilityName(fallbackOperateName)

	if abilityName ~= nil then
		return tostring(abilityName)
	end

	return tostring(abilityId)
end

function HomelandDemoCmdImplement._getAbilityInfo(abilityId)
	if abilityId == nil then
		return nil
	end

	if not HomelandDemoCmdImplement._abilityInfoCache then
		local cache = {}

		for operateId, row in pairs(HomelandOperateData) do
			local homeAbility = row and row.homeAbility
			local cachedAbilityId = homeAbility and homeAbility[1] or nil

			if cachedAbilityId ~= nil then
				local operateName = HomelandDemoCmdImplement._localize(row.workingNameWithoutEllipsis or row.workingName)
				local info = cache[cachedAbilityId]

				if not info or operateId < info.operateId then
					cache[cachedAbilityId] = {
						abilityId = cachedAbilityId,
						abilityName = HomelandDemoCmdImplement._resolveAbilityName(cachedAbilityId, operateName),
						operateId = operateId,
						operateName = operateName
					}
				end
			end
		end

		HomelandDemoCmdImplement._abilityInfoCache = cache
	end

	return HomelandDemoCmdImplement._abilityInfoCache[abilityId] or HomelandDemoCmdImplement._abilityInfoCache[tonumber(abilityId)]
end

function HomelandDemoCmdImplement._buildHomeAbilityList(homeAbility)
	local list = {}
	local valueType = type(homeAbility)

	if valueType ~= "table" and valueType ~= "userdata" then
		return list
	end

	for abilityId, level in pairs(homeAbility) do
		local numericId = tonumber(abilityId)

		if numericId ~= nil and type(level) == "number" then
			local abilityInfo = HomelandDemoCmdImplement._getAbilityInfo(numericId) or {}

			list[#list + 1] = {
				abilityId = numericId,
				abilityName = abilityInfo.abilityName or tostring(numericId),
				level = level
			}
		end
	end

	table.sort(list, function(a, b)
		return (a.abilityId or 0) < (b.abilityId or 0)
	end)

	return list
end

function HomelandDemoCmdImplement._serializePet(pet)
	if pet == nil then
		return nil
	end

	local templateId = pet.templateId
	local homeAbility = pet.homeAbility
	local natureId = pet.nature
	local natureData = natureId and PetNatureData[natureId] or nil
	local natureName = natureData and HomelandDemoCmdImplement._localize(natureData.name) or nil
	local configRow = templateId and PetData[templateId] or nil

	if type(homeAbility) ~= "table" and configRow then
		homeAbility = configRow.homeAbility or nil
	end

	local customName = pet.customName
	local speciesName = configRow and HomelandDemoCmdImplement._localize(configRow.name) or nil
	local displayName = customName ~= nil and customName ~= "" and customName or speciesName

	return {
		id = pet.id,
		templateId = templateId,
		name = pet.name,
		customName = customName,
		speciesName = speciesName,
		displayName = displayName,
		level = pet.level,
		natureId = natureId,
		nature = natureName,
		bornScale = pet.bornScale,
		label = pet.label,
		totalExp = pet.totalExp,
		homeAbility = HomelandDemoCmdImplement._cloneForCmd(homeAbility),
		homeAbilityList = HomelandDemoCmdImplement._buildHomeAbilityList(homeAbility)
	}
end

function HomelandDemoCmdImplement._getHomeSpace()
	if pg and pg.me and pg.me.space then
		return pg.me.space
	end

	return pg and pg.space or nil
end

function HomelandDemoCmdImplement._getRuntimeMapValue(mapName, key)
	local space = HomelandDemoCmdImplement._getHomeSpace()

	if space and space[mapName] and space[mapName][key] ~= nil then
		return space[mapName][key]
	end

	if pg and pg.space and pg.space[mapName] and pg.space[mapName][key] ~= nil then
		return pg.space[mapName][key]
	end

	return nil
end

function HomelandDemoCmdImplement._getHomePetBox()
	local runtimeSpace = pg and pg.space or nil
	local petBox = runtimeSpace and runtimeSpace.petBoxMap and runtimeSpace.petBoxMap[Const.HOMELAND_AREA_TYPE.PRODUCE] or nil

	if petBox then
		return petBox
	end

	local meSpace = pg and pg.me and pg.me.space or nil

	return meSpace and meSpace.petBoxMap and meSpace.petBoxMap[Const.HOMELAND_AREA_TYPE.PRODUCE] or nil
end

function HomelandDemoCmdImplement._getPetMapValue(map, petId)
	if not map or petId == nil then
		return nil
	end

	local value = map[petId]

	if value ~= nil then
		return value
	end

	value = map[tostring(petId)]

	if value ~= nil then
		return value
	end

	local numericId = tonumber(petId)

	if numericId ~= nil then
		return map[numericId]
	end

	return nil
end

function HomelandDemoCmdImplement._getPetInfoById(petId)
	local petInfo
	local homeSpace = HomelandDemoCmdImplement._getHomeSpace()

	if homeSpace and type(homeSpace.getPetInfo) == "function" then
		petInfo = HomelandDemoCmdImplement._safeCall(function()
			return homeSpace:getPetInfo(petId)
		end)
	end

	if not petInfo and homeSpace and homeSpace.pets then
		petInfo = HomelandDemoCmdImplement._getPetMapValue(homeSpace.pets, petId)
	end

	if not petInfo and pg.me and type(pg.me.getPetInfo) == "function" then
		petInfo = HomelandDemoCmdImplement._safeCall(function()
			return pg.me:getPetInfo(petId)
		end)
	end

	if not petInfo and pg.me and pg.me.pets then
		petInfo = HomelandDemoCmdImplement._getPetMapValue(pg.me.pets, petId)
	end

	return petInfo
end

function HomelandDemoCmdImplement._collectHomePetIds(filterPetIds)
	local allowSet

	if type(filterPetIds) == "table" then
		allowSet = {}

		for _, petId in pairs(filterPetIds) do
			if petId ~= nil then
				allowSet[tostring(petId)] = true
			end
		end
	end

	local seen = {}
	local petIds = {}
	local petBox = HomelandDemoCmdImplement._getHomePetBox()

	if petBox then
		local slotCount = HomelandDemoCmdImplement._getHomeSpace().petBoxMap:getSlotCount()

		for idx = 1, slotCount do
			HomelandDemoCmdImplement._addPetId(petIds, seen, allowSet, petBox[idx])
		end
	end

	local space = HomelandDemoCmdImplement._getHomeSpace()

	if space and space.pets then
		for petId in pairs(space.pets) do
			HomelandDemoCmdImplement._addPetId(petIds, seen, allowSet, petId)
		end
	end

	if space and space.allocation then
		for petId in pairs(space.allocation) do
			HomelandDemoCmdImplement._addPetId(petIds, seen, allowSet, petId)
		end
	end

	table.sort(petIds, function(a, b)
		return tostring(a) < tostring(b)
	end)

	return petIds
end

function HomelandDemoCmdImplement._refreshHomePetStepHeightUp()
	local refreshedCount = 0

	for _, petId in ipairs(HomelandDemoCmdImplement._collectHomePetIds()) do
		local petEntity = HomelandDemoCmdImplement._findHomePetEntity(petId)

		if petEntity and petEntity.refreshDemoModeStepHeightUp and petEntity:refreshDemoModeStepHeightUp() then
			refreshedCount = refreshedCount + 1
		end
	end

	return refreshedCount
end

function HomelandDemoCmdImplement._refreshHomePetCarryInteraction()
	local refreshedCount = 0

	for _, petId in ipairs(HomelandDemoCmdImplement._collectHomePetIds()) do
		local petEntity = HomelandDemoCmdImplement._findHomePetEntity(petId)

		if petEntity and petEntity.eModel ~= nil then
			petEntity:refreshInteractTrigger()

			refreshedCount = refreshedCount + 1
		end
	end

	return refreshedCount
end

function HomelandDemoCmdImplement._getHomePetEntity(petId)
	local petEntity = HomelandDemoCmdImplement._findHomePetEntity(petId)

	return petEntity
end

function HomelandDemoCmdImplement._getOperateDisplayInfo(operateId)
	if operateId == nil then
		return nil
	end

	local row = HomelandOperateData[operateId]

	if not row then
		return nil
	end

	local operateName = HomelandDemoCmdImplement._localize(row.workingNameWithoutEllipsis or row.workingName)

	return {
		operateId = operateId,
		operateName = operateName ~= nil and tostring(operateName) or tostring(operateId)
	}
end

function HomelandDemoCmdImplement._buildRequiredAbilityByOperateId(operateId)
	if operateId == nil then
		return nil
	end

	local row = HomelandOperateData[operateId]
	local homeAbility = row and row.homeAbility

	if type(homeAbility) ~= "table" and type(homeAbility) ~= "userdata" then
		return nil
	end

	local abilityId = homeAbility[1]

	if abilityId == nil then
		return nil
	end

	local abilityInfo = HomelandDemoCmdImplement._getAbilityInfo(abilityId) or {}
	local operateInfo = HomelandDemoCmdImplement._getOperateDisplayInfo(operateId) or {}

	return {
		abilityId = abilityId,
		abilityName = abilityInfo.abilityName or tostring(abilityId),
		requiredLevel = homeAbility[2] or 0,
		operateId = operateInfo.operateId or operateId,
		operateName = operateInfo.operateName or tostring(operateId)
	}
end

function HomelandDemoCmdImplement._serializeFacilityBrief(ornamentId)
	local ornamentInfo = HomelandDemoCmdImplement._getRuntimeMapValue("ornament", ornamentId)
	local facilityInfo = HomelandDemoCmdImplement._getRuntimeMapValue("facility", ornamentId)

	if not ornamentInfo and not facilityInfo then
		return nil
	end

	local data = {
		facilityId = ornamentId,
		ornamentId = ornamentId
	}

	if ornamentInfo then
		data.homeId = ornamentInfo.homeId

		local position = HomelandDemoCmdImplement._safeCall(function()
			return ornamentInfo:getPosition()
		end)

		if position then
			data.position = HomelandDemoCmdImplement._vec3(position)
		end
	end

	local homeEntity = HomelandDemoCmdImplement._getHomeEntityByOrnamentId(ornamentId)

	if homeEntity then
		data.actorId = homeEntity.actorId
	end

	if facilityInfo then
		data.formulaId = facilityInfo.formulaId
		data.facilityState = facilityInfo.facilityState
		data.disable = facilityInfo.disable and true or false
		data.outputMap = HomelandDemoCmdImplement._cloneForCmd(facilityInfo.outputMap) or {}
		data.specialOutputMap = HomelandDemoCmdImplement._cloneForCmd(facilityInfo.specialOutputMap) or {}
		data.extraStateMap = HomelandDemoCmdImplement._cloneForCmd(facilityInfo.extraStateMap) or {}
		data.outputCount = 0

		if facilityInfo.outputMap then
			for _, itemNum in pairs(facilityInfo.outputMap) do
				data.outputCount = data.outputCount + (tonumber(itemNum) or 0)
			end
		end

		data.autoMutationOutputCount = HomeLandUtils.sumAutoMutation(facilityInfo)
		data.transportOutputCount = data.outputCount + data.autoMutationOutputCount
		data.hasOutputLimitState = facilityInfo.extraStateMap and facilityInfo.extraStateMap[Const.HOMELAND_EXTRA_STATES.OUTPUT_LIMIT] ~= nil or false

		if ornamentInfo and ornamentInfo.homeId then
			local facilityId = Utils.getHomeObjectFacilityId(ornamentInfo.homeId)
			local facilityData = facilityId and HomelandFacilityData[facilityId] or nil

			data.outputLimit = facilityData and facilityData.outputLimit or nil
			data.isOverTransportThreshold = HomelandDemoCmdImplement._safeCall(function()
				return HomeLandUtils.checkIsOverTransportThreshold(ornamentInfo.homeId, facilityInfo)
			end) == true
		end

		local opInfo = HomelandDemoCmdImplement._getOperateDisplayInfo(data.facilityState)

		if opInfo then
			data.facilityStateName = opInfo.operateName
		end

		data.requiredAbility = HomelandDemoCmdImplement._buildRequiredAbilityByOperateId(data.facilityState)
	end

	local space = HomelandDemoCmdImplement._getHomeSpace()

	if space and space.allocation then
		local assignedPets = {}

		for petId, allocationInfo in pairs(space.allocation) do
			if allocationInfo and allocationInfo.ornamentId == ornamentId then
				local petInfo = HomelandDemoCmdImplement._getPetInfoById(petId)
				local petEntry = HomelandDemoCmdImplement._serializePet(petInfo) or {
					id = petId
				}

				if petEntry.id == nil then
					petEntry.id = petId
				end

				petEntry.opId = allocationInfo.opId
				petEntry.workload = allocationInfo.workload
				petEntry.fitPersonality = allocationInfo.fitTalent
				petEntry.isIdle = allocationInfo.opId == nil or allocationInfo.opId == 0
				assignedPets[#assignedPets + 1] = petEntry
			end
		end

		if #assignedPets > 0 then
			table.sort(assignedPets, function(a, b)
				return tostring(a.id) < tostring(b.id)
			end)

			data.assignedPets = assignedPets
			data.assignedPetIds = {}

			for _, petEntry in ipairs(assignedPets) do
				data.assignedPetIds[#data.assignedPetIds + 1] = petEntry.id
			end
		end

		data.assignedCount = #assignedPets
	end

	if space and space.playerAllocation then
		local assignedPlayers = {}

		for playerId, allocationInfo in pairs(space.playerAllocation) do
			if allocationInfo and allocationInfo.ornamentId == ornamentId then
				local playerEntry = {
					id = playerId
				}
				local playerEntity = HomelandDemoCmdImplement._safeCall(function()
					return pg and type(pg.getEntity) == "function" and pg.getEntity(playerId) or nil
				end)

				if playerEntity then
					playerEntry.playerName = playerEntity.playerName
					playerEntry.uid = playerEntity.uid
				end

				playerEntry.opId = allocationInfo.opId
				playerEntry.posIndex = allocationInfo.posIndex
				playerEntry.workload = allocationInfo.workload
				playerEntry.isIdle = allocationInfo.opId == nil or allocationInfo.opId == 0
				playerEntry.isLocalPlayer = pg.me and tostring(playerId) == tostring(pg.me.id) or false
				assignedPlayers[#assignedPlayers + 1] = playerEntry
			end
		end

		if #assignedPlayers > 0 then
			table.sort(assignedPlayers, function(a, b)
				return tostring(a.id) < tostring(b.id)
			end)

			data.assignedPlayers = assignedPlayers
			data.assignedPlayerIds = {}

			for _, playerEntry in ipairs(assignedPlayers) do
				data.assignedPlayerIds[#data.assignedPlayerIds + 1] = playerEntry.id
			end
		end

		data.assignedPlayerCount = #assignedPlayers
	end

	return data
end

function HomelandDemoCmdImplement._collectFacilities()
	local facilities = {}
	local seen = {}
	local space = HomelandDemoCmdImplement._getHomeSpace()
	local facilityMap = space and space.facility or nil

	if not facilityMap then
		return facilities
	end

	for ornamentId, _ in pairs(facilityMap) do
		local data = HomelandDemoCmdImplement._serializeFacilityBrief(ornamentId)

		if data ~= nil then
			facilities[#facilities + 1] = data
			seen[tostring(ornamentId)] = true
		end
	end

	table.sort(facilities, function(a, b)
		local left = tonumber(a and a.ornamentId) or 0
		local right = tonumber(b and b.ornamentId) or 0

		if left ~= right then
			return left < right
		end

		return tostring(a and a.ornamentId) < tostring(b and b.ornamentId)
	end)

	return facilities
end

function HomelandDemoCmdImplement._isMiningFacility(facilityData)
	local requiredAbility = facilityData and facilityData.requiredAbility or nil
	local abilityId = requiredAbility and requiredAbility.abilityId or nil

	return tonumber(abilityId) == HomelandDemoCmdImplement.MINING_ABILITY_ID
end

function HomelandDemoCmdImplement._collectMiningFacilities(includeDisabled)
	local allFacilities = HomelandDemoCmdImplement._collectFacilities()
	local facilities = {}

	for _, facilityData in ipairs(allFacilities) do
		if HomelandDemoCmdImplement._isMiningFacility(facilityData) and (includeDisabled or not facilityData.disable) then
			facilities[#facilities + 1] = facilityData
		end
	end

	return facilities
end

function HomelandDemoCmdImplement._collectTransportFacilities(includeDisabled, onlyOverThreshold)
	local allFacilities = HomelandDemoCmdImplement._collectFacilities()
	local facilities = {}

	for _, facilityData in ipairs(allFacilities) do
		local hasOutput = (tonumber(facilityData.transportOutputCount) or 0) > 0
		local passThreshold = not onlyOverThreshold or facilityData.isOverTransportThreshold == true

		if hasOutput and passThreshold and (includeDisabled or not facilityData.disable) then
			facilities[#facilities + 1] = facilityData
		end
	end

	return facilities
end

function HomelandDemoCmdImplement._normalizeAbilityId(abilityId)
	local numericId = tonumber(abilityId)

	if numericId == nil then
		return nil
	end

	return math.floor(numericId)
end

function HomelandDemoCmdImplement._getLearnProgress(petId, abilityId)
	local numericId = HomelandDemoCmdImplement._normalizeAbilityId(abilityId)

	if numericId == nil then
		return 0
	end

	local byPet = HomelandDemoCmdImplement.STATE.learnProgress[tostring(petId)]
	local progress = byPet and byPet[tostring(numericId)] or nil

	return tonumber(progress) or 0
end

function HomelandDemoCmdImplement._setLearnProgress(petId, abilityId, progress)
	local numericId = HomelandDemoCmdImplement._normalizeAbilityId(abilityId)

	if numericId == nil then
		return 0
	end

	local petKey = tostring(petId)
	local byPet = HomelandDemoCmdImplement.STATE.learnProgress[petKey]

	if not byPet then
		byPet = {}
		HomelandDemoCmdImplement.STATE.learnProgress[petKey] = byPet
	end

	local clamped = tonumber(progress) or 0

	if clamped < 0 then
		clamped = 0
	end

	if clamped > HomelandDemoCmdImplement.LEARN_PROGRESS_MAX then
		clamped = HomelandDemoCmdImplement.LEARN_PROGRESS_MAX
	end

	byPet[tostring(numericId)] = clamped

	return clamped
end

function HomelandDemoCmdImplement._buildHomePetEntry(petId, slotIdx)
	local petInfo = HomelandDemoCmdImplement._getPetInfoById(petId)
	local entry = HomelandDemoCmdImplement._serializePet(petInfo) or {
		id = petId
	}

	if entry.id == nil then
		entry.id = petId
	end

	entry.slotIdx = slotIdx
	entry.isInHomeland = true

	local space = HomelandDemoCmdImplement._getHomeSpace()
	local allocation = HomelandDemoCmdImplement._getPetMapValue(space and space.allocation, petId)

	if allocation then
		entry.ornamentId = allocation.ornamentId
		entry.opId = allocation.opId
		entry.workload = allocation.workload
		entry.fitPersonality = allocation.fitTalent
	end

	entry.isIdle = not allocation or not allocation.ornamentId or allocation.ornamentId == 0 or allocation.opId == 0

	local spacePet = HomelandDemoCmdImplement._getPetMapValue(space and space.pets, petId)

	if spacePet then
		if not allocation and spacePet.allocationInfo then
			allocation = spacePet.allocationInfo
			entry.ornamentId = allocation.ornamentId
			entry.opId = allocation.opId
			entry.workload = allocation.workload
			entry.fitPersonality = allocation.fitTalent
			entry.isIdle = not allocation or not allocation.ornamentId or allocation.ornamentId == 0 or allocation.opId == 0
		end

		if not entry.templateId and spacePet.templateId then
			entry.templateId = spacePet.templateId
		end

		if spacePet.checkAIHomeWorkState then
			local stateOk = HomelandDemoCmdImplement._safeCall(function()
				return spacePet:checkAIHomeWorkState()
			end)

			if stateOk ~= nil then
				entry.workStateOk = stateOk and true or false
			end
		end
	end

	local petEntity, entityDebug = HomelandDemoCmdImplement._findHomePetEntity(petId)

	if petEntity then
		entry.entityFound = true
		entry.entityId = petEntity.id
		entry.entityActorId = petEntity.actorId
		entry.entityClassName = petEntity.className
		entry.entityHasEventEmitter = petEntity.eventEmitter ~= nil
		entry.position = HomelandDemoCmdImplement._getEntityPosition(petEntity)

		if type(petEntity.getGlobalId) == "function" then
			entry.entityGlobalId = HomelandDemoCmdImplement._safeCall(function()
				return petEntity:getGlobalId()
			end)
		end
	else
		entry.entityFound = false
		entry.entityHasEventEmitter = false
	end

	if entityDebug then
		entry.entityMatchReason = entityDebug.matchReason
	end

	if allocation and allocation.ornamentId then
		local facilityInfo = HomelandDemoCmdImplement._getPetMapValue(space and space.facility, allocation.ornamentId)

		if facilityInfo and allocation.opId and allocation.opId ~= 0 and facilityInfo.facilityState == allocation.opId then
			local operateData = HomelandOperateData[allocation.opId]

			if operateData then
				entry.inFacility = true
				entry.opUrl = operateData.workingIcon

				local operateName = HomelandDemoCmdImplement._localize(operateData.workingNameWithoutEllipsis or operateData.workingName)

				if operateName ~= nil then
					entry.opName = tostring(operateName)
				end
			end
		end
	end

	return entry
end

function HomelandDemoCmdImplement._checkPetStateValid(target)
	if not target or not target.petEnt then
		return true
	end

	if type(Utils.checkHomePetStateValid) == "function" then
		local valid = HomelandDemoCmdImplement._safeCall(function()
			return Utils.checkHomePetStateValid(target.petEnt, pg.me.space)
		end)

		if valid ~= nil then
			return valid and true or false
		end
	end

	return true
end

function HomelandDemoCmdImplement._setLastCommand(name, data)
	HomelandDemoCmdImplement.STATE.lastCommand = {
		name = name,
		time = os.time(),
		data = HomelandDemoCmdImplement._cloneValue(data or {})
	}
end

function HomelandDemoCmdImplement._enqueueEvent(topic, data)
	local event = {
		seq = HomelandDemoCmdImplement.STATE.nextEventSeq,
		topic = topic,
		time = os.time(),
		data = HomelandDemoCmdImplement._cloneValue(data or {})
	}

	HomelandDemoCmdImplement.STATE.nextEventSeq = HomelandDemoCmdImplement.STATE.nextEventSeq + 1
	HomelandDemoCmdImplement.STATE.eventQueue[#HomelandDemoCmdImplement.STATE.eventQueue + 1] = event

	while #HomelandDemoCmdImplement.STATE.eventQueue > HomelandDemoCmdImplement.MAX_EVENT_QUEUE do
		table.remove(HomelandDemoCmdImplement.STATE.eventQueue, 1)
	end

	HomelandDemoCmdImplement.STATE.lastEvent = HomelandDemoCmdImplement._cloneValue(event)

	return event
end

function HomelandDemoCmdImplement._pushEvent(event)
	local system = pg.game and pg.game.cmdSocket or nil

	if not system or type(system.pushEvent) ~= "function" then
		return
	end

	for connId, subscribed in pairs(HomelandDemoCmdImplement.STATE.subscribers) do
		if subscribed then
			local ok, err = xpcall(function()
				system:pushEvent(tonumber(connId), event.topic, event.data, event.seq, event.time)
			end, debug.traceback)

			if not ok then
				logger:warn("push homelandDemo event failed connId=%s err=%s", tostring(connId), tostring(err))
			end
		end
	end
end

function HomelandDemoCmdImplement._publishEvent(topic, data)
	local event = HomelandDemoCmdImplement._enqueueEvent(topic, data)

	HomelandDemoCmdImplement._pushEvent(event)

	return event
end

function HomelandDemoCmdImplement._buildPlayerWorkEvent(playerId, allocationInfo)
	local data = {
		status = "idle",
		playerId = playerId,
		isLocalPlayer = pg.me and tostring(playerId) == tostring(pg.me.id) or false
	}

	if allocationInfo then
		local ornamentId = allocationInfo.ornamentId
		local opId = allocationInfo.opId
		local isWorking = ornamentId ~= nil and ornamentId ~= 0 and opId ~= nil and opId ~= 0

		data.ornamentId = ornamentId
		data.opId = opId
		data.posIndex = allocationInfo.posIndex
		data.workload = allocationInfo.workload
		data.status = isWorking and "working" or "idle"

		if isWorking then
			local opInfo = HomelandDemoCmdImplement._getOperateDisplayInfo(opId)

			if opInfo then
				data.opName = opInfo.operateName
			end

			data.facility = HomelandDemoCmdImplement._serializeFacilityBrief(ornamentId)
		end
	end

	local space = HomelandDemoCmdImplement._getHomeSpace()

	if space then
		data.sceneId = space.sceneId
		data.spaceId = space.id
	end

	return data
end

function HomelandDemoCmdImplement._isMiningAllocation(allocationInfo)
	local opId = allocationInfo and allocationInfo.opId

	if opId == nil or opId == 0 then
		return false
	end

	local operateData = HomelandOperateData[opId]
	local homeAbility = operateData and operateData.homeAbility

	return homeAbility ~= nil and homeAbility[1] == HomelandDemoCmdImplement.MINING_ABILITY_ID
end

function HomelandDemoCmdImplement._isAnyPetLearningMining()
	local byPet = HomelandDemoCmdImplement.STATE.learnProgress

	if type(byPet) ~= "table" then
		return false
	end

	local miningKey = tostring(HomelandDemoCmdImplement.MINING_ABILITY_ID)

	for _, abilityMap in pairs(byPet) do
		if type(abilityMap) == "table" then
			local progress = tonumber(abilityMap[miningKey]) or 0

			if progress > 0 then
				return true
			end
		end
	end

	return false
end

function HomelandDemoCmdImplement._tryTriggerMiningTipDialog(allocationInfo)
	if HomelandDemoCmdImplement.STATE.demoMiningTipTriggered then
		return
	end

	if not HomelandDemoCmdImplement.STATE.demoChatTriggered then
		return
	end

	if (pg.space == nil or pg.space.demoMode ~= true) and (pg.me == nil or pg.me.space == nil or pg.me.space.demoMode ~= true) then
		return
	end

	if not HomelandDemoCmdImplement._isMiningAllocation(allocationInfo) then
		return
	end

	if HomelandDemoCmdImplement._isAnyPetLearningMining() then
		return
	end

	local dialogueId = Const.HOMELAND_DEMO_MINING_TIP_DIALOGUE

	if dialogueId == nil then
		return
	end

	local communication = pg.game and pg.game.communication or nil

	if not communication or type(communication.startNpcDialog) ~= "function" then
		return
	end

	HomelandDemoCmdImplement.STATE.demoMiningTipTriggered = true

	HomelandDemoCmdImplement._safeCall(function()
		communication:startNpcDialog(dialogueId)
	end)
end

function HomelandDemoCmdImplement._onPlayerAllocationChanged(playerId, allocationInfo)
	if HomelandDemoCmdImplement.STATE.enabled ~= true then
		return
	end

	if not pg.me or tostring(playerId) ~= tostring(pg.me.id) then
		return
	end

	HomelandDemoCmdImplement._publishEvent(HomelandDemoCmdImplement.EVENT_TOPIC_PLAYER_WORK, HomelandDemoCmdImplement._buildPlayerWorkEvent(playerId, allocationInfo))
	HomelandDemoCmdImplement._tryTriggerMiningTipDialog(allocationInfo)
end

function HomelandDemoCmdImplement._onPlayerEnterHomeland()
	if HomelandDemoCmdImplement.STATE.enabled ~= true then
		return
	end

	if not pg.me then
		return
	end

	local playerInfo = HomelandDemoCmdImplement._buildPlayerInfo()

	if not playerInfo or playerInfo.inHomeland ~= true then
		return
	end

	HomelandDemoCmdImplement._publishEvent(HomelandDemoCmdImplement.EVENT_TOPIC_PLAYER_ENTER, {
		playerInfo = playerInfo,
		sceneId = playerInfo.sceneId,
		spaceId = playerInfo.spaceId,
		isSelfHomeland = playerInfo.isSelfHomeland
	})
end

function HomelandDemoCmdImplement._onPlayerChatMessageSent(text, channel, source)
	if HomelandDemoCmdImplement.STATE.enabled ~= true then
		return
	end

	if string.isNilOrEmpty(text) == true then
		return
	end

	if (pg.space == nil or pg.space.demoMode ~= true) and (pg.me == nil or pg.me.space == nil or pg.me.space.demoMode ~= true) then
		return
	end

	local playerInfo = HomelandDemoCmdImplement._buildPlayerInfo()

	HomelandDemoCmdImplement._publishEvent(HomelandDemoCmdImplement.EVENT_TOPIC_PLAYER_CHAT, {
		text = text,
		source = source or "text",
		playerInfo = playerInfo,
		playerId = pg.me and pg.me.id or nil,
		uid = pg.me and pg.me.uid or nil,
		playerName = pg.me and pg.me.playerName or nil,
		channelName = channel and channel.channelName or nil,
		channelType = channel and channel.channelType or nil,
		channelId = channel and channel.channelId or nil,
		sceneId = playerInfo and playerInfo.sceneId or nil,
		spaceId = playerInfo and playerInfo.spaceId or nil
	})
end

function HomelandDemoCmdImplement._onTargetSubTargetsCompleted(targetId, subTargetList)
	if HomelandDemoCmdImplement.STATE.enabled ~= true then
		return
	end

	if targetId ~= Const.HOMELAND_DEMO_TARGET_END then
		return
	end

	if HomelandDemoCmdImplement.STATE.demoCompletedTriggered then
		return
	end

	if (pg.space == nil or pg.space.demoMode ~= true) and (pg.me == nil or pg.me.space == nil or pg.me.space.demoMode ~= true) then
		return
	end

	local endSubTargetCompleted = false

	for _, seqId in ipairs(subTargetList or EMPTY_TABLE) do
		if tonumber(seqId) == HomelandDemoCmdImplement.DEMO_END_SUB_TARGET_SEQ then
			endSubTargetCompleted = true

			break
		end
	end

	if not endSubTargetCompleted then
		return
	end

	HomelandDemoCmdImplement.STATE.demoCompletedTriggered = true

	HomelandDemoCmdImplement._publishEvent(HomelandDemoCmdImplement.EVENT_TOPIC_DEMO_COMPLETED, {
		status = "completed",
		targetId = targetId,
		groupId = Const.HOMELAND_DEMO_TARGET_GROUP
	})
end

function HomelandDemoCmdImplement._onConnectionAuthed(connId)
	if connId == nil then
		return
	end

	if (pg.space == nil or pg.space.demoMode ~= true) and (pg.me == nil or pg.me.space == nil or pg.me.space.demoMode ~= true) then
		return
	end

	HomelandDemoCmdImplement.setEnabled(nil, connId, {
		enabled = true
	})
end

function HomelandDemoCmdImplement._sortCmdEntryByCmd(a, b)
	return a.cmd < b.cmd
end

function HomelandDemoCmdImplement._buildCmdListResult()
	local queries, actions, others = {}, {}, {}

	for fnName, fn in pairs(HomelandDemoCmdImplement) do
		if type(fn) == "function" and string.sub(fnName, 1, 1) ~= "_" then
			local entry = {
				cmd = "homelandDemo." .. fnName,
				fn = fnName
			}
			local meta = HomelandDemoCmdImplement.CMD_META[fnName]

			if meta then
				entry.category = meta.category
				entry.desc = meta.desc

				if meta.params then
					entry.params = meta.params
				end

				if meta.async then
					entry.async = true
				end
			else
				entry.category = "unknown"
			end

			if entry.category == "query" then
				queries[#queries + 1] = entry
			elseif entry.category == "action" then
				actions[#actions + 1] = entry
			else
				others[#others + 1] = entry
			end
		end
	end

	table.sort(queries, HomelandDemoCmdImplement._sortCmdEntryByCmd)
	table.sort(actions, HomelandDemoCmdImplement._sortCmdEntryByCmd)
	table.sort(others, HomelandDemoCmdImplement._sortCmdEntryByCmd)

	local result = {
		queries = queries,
		actions = actions,
		queryCount = #queries,
		actionCount = #actions
	}

	if #others > 0 then
		result.others = others
		result.otherCount = #others
	end

	return result
end

function HomelandDemoCmdImplement._buildSupportedCommandNames()
	local names = {}
	local cmdList = HomelandDemoCmdImplement._buildCmdListResult()

	for _, entry in ipairs(cmdList.queries) do
		names[#names + 1] = entry.cmd
	end

	for _, entry in ipairs(cmdList.actions) do
		names[#names + 1] = entry.cmd
	end

	if cmdList.others then
		for _, entry in ipairs(cmdList.others) do
			names[#names + 1] = entry.cmd
		end
	end

	return names
end

function HomelandDemoCmdImplement._getCmdPetIds(params)
	local petIds = {}

	if params and params.petId ~= nil then
		petIds[1] = params.petId

		return petIds
	end

	if type(params and params.petIds) == "table" and #params.petIds > 0 then
		for _, petId in ipairs(params.petIds) do
			petIds[#petIds + 1] = petId
		end

		return petIds
	end

	return HomelandDemoCmdImplement._collectHomePetIds()
end

function HomelandDemoCmdImplement._buildActionPetTargets(params)
	local targets = {}

	for _, petId in ipairs(HomelandDemoCmdImplement._getCmdPetIds(params)) do
		local target = {
			petId = petId
		}

		HomelandDemoCmdImplement._refreshActionTarget(target)

		targets[#targets + 1] = target
	end

	return targets
end

function HomelandDemoCmdImplement._refreshActionTarget(target)
	if not target or target.petId == nil then
		return target
	end

	target.entry = HomelandDemoCmdImplement._buildHomePetEntry(target.petId, nil) or {
		isInHomeland = false,
		id = target.petId
	}
	target.petEnt, target.petEntityDebug = HomelandDemoCmdImplement._findHomePetEntity(target.petId)

	return target
end

function HomelandDemoCmdImplement._clearPetBubble(petEnt)
	if not petEnt or not petEnt.eventEmitter then
		return
	end

	HomelandDemoCmdImplement._safeCall(function()
		petEnt.eventEmitter:emit(EventConst.TOPLOGO_BUBBLE, false)
	end)
end

function HomelandDemoCmdImplement._emitPetBubble(target, emojiName, duration)
	if not target.petEnt then
		local debugInfo = target and target.petEntityDebug or nil

		if debugInfo and type(debugInfo) == "table" then
			return false, "pet entity not found in homeland: " .. tostring(debugInfo.matchReason or "unknown")
		end

		return false, "pet entity not found in homeland"
	end

	if not target.petEnt.eventEmitter then
		local entityId = target.petEnt.id ~= nil and tostring(target.petEnt.id) or "nil"
		local className = target.petEnt.className ~= nil and tostring(target.petEnt.className) or "nil"

		return false, "pet entity has no eventEmitter: entityId=" .. entityId .. ", className=" .. className
	end

	if type(emojiName) ~= "string" or emojiName == "" then
		return false, "invalid emojiName"
	end

	HomelandDemoCmdImplement._clearPetBubble(target.petEnt)

	local _, errMsg = HomelandDemoCmdImplement._safeCall(function()
		target.petEnt.eventEmitter:emit(EventConst.TOPLOGO_BUBBLE, true, emojiName, duration or HomelandDemoCmdImplement.DEFAULT_BUBBLE_DURATION)
	end)

	if errMsg then
		return false, tostring(errMsg)
	end

	return true, nil
end

function HomelandDemoCmdImplement._emitPetChat(target, customText, customDuration)
	if not target.petEnt then
		local debugInfo = target and target.petEntityDebug or nil

		if debugInfo and type(debugInfo) == "table" then
			return false, "pet entity not found in homeland: " .. tostring(debugInfo.matchReason or "unknown")
		end

		return false, "pet entity not found in homeland"
	end

	if not target.petEnt.eventEmitter then
		local entityId = target.petEnt.id ~= nil and tostring(target.petEnt.id) or "nil"
		local className = target.petEnt.className ~= nil and tostring(target.petEnt.className) or "nil"

		return false, "pet entity has no eventEmitter: entityId=" .. entityId .. ", className=" .. className
	end

	local UIConst = require("Const.UIConst")

	if not customText or type(customText) ~= "string" or #customText == 0 then
		return false, "invalid customText: must be non-empty string"
	end

	local dialogueText = customText
	local duration = customDuration or DialogueConst.CUSTOM_BUBBLE_DEFAULT_DURATION

	if type(duration) ~= "number" or duration <= 0 then
		return false, "invalid customDuration: must be positive number"
	end

	local topLogoCtrl = pg.global.ui and pg.global.ui.topLogo

	if not topLogoCtrl or not topLogoCtrl:checkUIOpen() then
		return false, "topLogo UI closed"
	end

	local chatComponent = target.petEnt:ensureToplogoComponent(UIConst.TOPLOGO_COMPONENT.CHAT, "gm_dialogue")
	local topLogoItem = target.petEnt:peekTopLogoItem()

	if not chatComponent or not topLogoItem then
		return false, "pet TopLogo does not support CHAT component"
	end

	if duration ~= DialogueConst.CUSTOM_BUBBLE_DEFAULT_DURATION and not topLogoItem:isTopLogoPrefabReady() then
		return false, "pet topLogo prefab is loading; retry custom duration after it is ready"
	end

	local _, errMsg = HomelandDemoCmdImplement._safeCall(function()
		target.petEnt.eventEmitter:emit(EventConst.TOPLOGO_DIALOGUE, false)

		if topLogoItem:isTopLogoPrefabReady() then
			chatComponent.commandVisible = true

			chatComponent:notifyActiveStateChanged(true)
			chatComponent:tryShowTopDialogue(DialogueConst.CUSTOM_BUBBLE_DIALOGUE_ID, dialogueText, duration, nil, false)
		else
			target.petEnt.eventEmitter:emit(EventConst.TOPLOGO_DIALOGUE, true, DialogueConst.CUSTOM_BUBBLE_DIALOGUE_ID, dialogueText, nil, false)
		end
	end)

	if errMsg then
		return false, tostring(errMsg)
	end

	return true, nil
end

function HomelandDemoCmdImplement._onPetActionFinished(petEnt, actionParam)
	if HomelandDemoCmdImplement.STATE.enabled ~= true then
		return
	end

	if not petEnt or not actionParam then
		return
	end

	if actionParam.waitTime == nil then
		return
	end

	HomelandDemoCmdImplement._publishEvent(HomelandDemoCmdImplement.EVENT_TOPIC_PET_ACTION_FINISHED, {
		status = "finished",
		petId = petEnt.id,
		actorId = petEnt.actorId,
		extraIntParam = actionParam.extraIntParam,
		targetActorId = actionParam.actorId,
		emojiKey = actionParam.emojiKey,
		animationKey = actionParam.animationKey,
		animationLoopKey = actionParam.animationLoopKey,
		speed = actionParam.speed,
		speedRateType = actionParam.speedRateType,
		waitTime = actionParam.waitTime,
		animationTime = actionParam.animationTime,
		emojiTime = actionParam.emojiTime,
		isFollow = actionParam.isFollow,
		targetPos = actionParam.targetPos,
		stopDist = actionParam.stopDist,
		isGoTargetPos = actionParam.isGoTargetPos
	})
end

function HomelandDemoCmdImplement._checkPetActionAllowed(target, interruptWork)
	if not target.entry or target.entry.isInHomeland ~= true then
		return false, "pet is not in homeland"
	end

	if target.entry.isIdle ~= true and interruptWork ~= true then
		return false, "pet is working and interruptWork=false; reject action"
	end

	return true, nil
end

function HomelandDemoCmdImplement._resolveFacility(facilityId)
	local space = HomelandDemoCmdImplement._getHomeSpace()
	local facilityMap = space and space.facility or nil

	if not facilityMap then
		return nil, nil, "facility map not ready"
	end

	if facilityId == nil then
		return nil, nil, "missing params.facilityId"
	end

	local resolvedFacilityId = facilityId
	local facilityInfo = facilityMap[resolvedFacilityId]

	if facilityInfo == nil then
		local numericId = tonumber(facilityId)

		if numericId ~= nil then
			facilityInfo = facilityMap[numericId]
			resolvedFacilityId = numericId
		end
	end

	if not facilityInfo then
		return nil, nil, "facility not found: " .. tostring(facilityId)
	end

	return resolvedFacilityId, facilityInfo, nil
end

function HomelandDemoCmdImplement._resolveWorkFacility(facilityId)
	local facilityInfo, err

	facilityId, facilityInfo, err = HomelandDemoCmdImplement._resolveFacility(facilityId)

	if not facilityId then
		return nil, nil, err
	end

	local facilityState = tonumber(facilityInfo.facilityState)

	if facilityState == nil or facilityState == 0 then
		return nil, nil, "facility has no active work state: " .. tostring(facilityId)
	end

	return facilityId, facilityState, nil
end

function HomelandDemoCmdImplement._dispatchFacilityWork(petId, facilityId, force)
	if not pg.me or not pg.me.space then
		return false, "no player space"
	end

	HomelandDemoCmdImplement._clearPetBubble(HomelandDemoCmdImplement._findHomePetEntity(petId))

	local _, errMsg = HomelandDemoCmdImplement._safeCall(function()
		pg.me.space:allocateHomePetWork(petId, facilityId, Const.HOMELAND_FACILITY_OP_TYPE.MOVING, force)
	end)

	if errMsg then
		return false, "allocateHomePetWork failed: " .. tostring(errMsg)
	end

	return true, nil
end

function HomelandDemoCmdImplement._dispatchFacilityTransport(petId, facilityId, force)
	if not pg.me or not pg.me.space then
		return false, "no player space"
	end

	HomelandDemoCmdImplement._clearPetBubble(HomelandDemoCmdImplement._findHomePetEntity(petId))

	local _, errMsg = HomelandDemoCmdImplement._safeCall(function()
		pg.me.space:allocateHomePetWork(petId, facilityId, Const.HOMELAND_FACILITY_OP_TYPE.GOTO_TRANSPORT, force)
	end)

	if errMsg then
		return false, "allocateHomePetWork(GOTO_TRANSPORT) failed: " .. tostring(errMsg)
	end

	return true, nil
end

function HomelandDemoCmdImplement._normalizeFacilityId(facilityId)
	if facilityId == nil or facilityId == "" then
		return nil
	end

	local numericId = tonumber(facilityId)

	if numericId ~= nil then
		return numericId
	end

	return facilityId
end

function HomelandDemoCmdImplement._getHomeEntityByOrnamentId(ornamentId)
	if ornamentId == nil then
		return nil
	end

	local home = pg and pg.game and pg.game.home or nil

	if home and type(home.getHomeEntity) == "function" then
		local entity = HomelandDemoCmdImplement._safeCall(function()
			return home:getHomeEntity(ornamentId)
		end)

		if entity then
			return entity
		end

		local numericId = tonumber(ornamentId)

		if numericId ~= nil and numericId ~= ornamentId then
			entity = HomelandDemoCmdImplement._safeCall(function()
				return home:getHomeEntity(numericId)
			end)

			if entity then
				return entity
			end
		end
	end

	local entityMgr = pg and pg.global and pg.global.entityMgr or nil
	local allEntities = entityMgr and type(entityMgr.getAllEntities) == "function" and entityMgr.getAllEntities() or nil

	if type(allEntities) == "table" then
		local ornamentKey = tostring(ornamentId)

		for _, candidate in pairs(allEntities) do
			if candidate and candidate.ornamentId ~= nil and tostring(candidate.ornamentId) == ornamentKey then
				return candidate
			end
		end
	end

	return nil
end

function HomelandDemoCmdImplement._resolveFacilityActorId(facilityId)
	local normalizedFacilityId = HomelandDemoCmdImplement._normalizeFacilityId(facilityId)

	if normalizedFacilityId == nil then
		return nil, nil, "missing params.ornamentId"
	end

	local facilityInfo = HomelandDemoCmdImplement._getRuntimeMapValue("facility", normalizedFacilityId)

	if facilityInfo == nil then
		return nil, normalizedFacilityId, "facility ornament not found: " .. tostring(normalizedFacilityId)
	end

	local homeEntity = HomelandDemoCmdImplement._getHomeEntityByOrnamentId(normalizedFacilityId)

	if not homeEntity then
		return nil, normalizedFacilityId, "facility ornament entity not loaded: " .. tostring(normalizedFacilityId)
	end

	if homeEntity.actorId == nil then
		return nil, normalizedFacilityId, "facility ornament entity has no actorId: " .. tostring(normalizedFacilityId)
	end

	return homeEntity.actorId, normalizedFacilityId, nil
end

HomelandDemoCmdImplement.KEEP_AWAY_DISTANCE = 4

function HomelandDemoCmdImplement._resolveMasterEntity()
	local space = HomelandDemoCmdImplement._getHomeSpace()
	local ownerId = space and space.homeLandOwnerPlayerId or nil

	if ownerId == nil then
		return nil
	end

	return HomelandDemoCmdImplement._safeCall(function()
		return pg.getEntity(ownerId)
	end)
end

function HomelandDemoCmdImplement._calcKeepAwayTargetPos(petEnt)
	local masterEnt = HomelandDemoCmdImplement._resolveMasterEntity()

	if not petEnt or not masterEnt then
		return nil
	end

	local petPos = petEnt.getPosition and petEnt:getPosition() or nil
	local masterPos = masterEnt.getPosition and masterEnt:getPosition() or nil

	if not petPos or not masterPos then
		return nil
	end

	local dir = (petPos - masterPos):Normalize()

	if dir[1] == 0 and dir[2] == 0 and dir[3] == 0 then
		dir:Set(1, 0, 0)
	end

	local target = petPos + dir * HomelandDemoCmdImplement.KEEP_AWAY_DISTANCE

	return {
		target[1],
		target[2],
		target[3]
	}
end

function HomelandDemoCmdImplement._isFiniteNumber(value)
	return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end

function HomelandDemoCmdImplement._normalizePetActionTargetPos(targetPos)
	if targetPos == nil then
		return nil, nil
	end

	if type(targetPos) ~= "table" then
		return nil, "invalid params.targetPos (must be [x,y,z] or {x,y,z})"
	end

	local x = targetPos[1]
	local y = targetPos[2]
	local z = targetPos[3]

	if x == nil and y == nil and z == nil then
		x = targetPos.x
		y = targetPos.y
		z = targetPos.z
	end

	if not HomelandDemoCmdImplement._isFiniteNumber(x) or not HomelandDemoCmdImplement._isFiniteNumber(y) or not HomelandDemoCmdImplement._isFiniteNumber(z) then
		return nil, "invalid params.targetPos (x, y and z must be finite numbers)"
	end

	return {
		x,
		y,
		z
	}, nil
end

function HomelandDemoCmdImplement._resolveMasterActorId()
	local ownerEntity = HomelandDemoCmdImplement._resolveMasterEntity()
	local actorId = ownerEntity and ownerEntity.actorId or nil

	return actorId or 0
end

function HomelandDemoCmdImplement._resolvePetActionTargetActorId(params)
	if params.actorId ~= nil and params.actorId ~= "" then
		return params.actorId, {
			actorId = params.actorId
		}, nil
	end

	local facilityId = params.ornamentId or params.facilityId or params.targetFacilityId

	if facilityId ~= nil and facilityId ~= "" then
		local actorId, resolvedFacilityId, errMsg = HomelandDemoCmdImplement._resolveFacilityActorId(facilityId)

		if errMsg then
			return nil, {
				facilityId = resolvedFacilityId or facilityId
			}, errMsg
		end

		return actorId, {
			ornamentId = resolvedFacilityId,
			facilityId = resolvedFacilityId,
			actorId = actorId
		}, nil
	end

	if params.toMaster == true then
		local actorId = HomelandDemoCmdImplement._resolveMasterActorId()

		return actorId, {
			toMaster = true,
			actorId = actorId
		}, nil
	end

	return 0, nil, nil
end

function HomelandDemoCmdImplement._dispatchPetSpecialAction(petId, actionArgs)
	local petEnt, debugInfo = HomelandDemoCmdImplement._findHomePetEntity(petId)

	if not petEnt then
		local reason = debugInfo and type(debugInfo) == "table" and debugInfo.matchReason or "unknown"

		return false, "pet entity not found in homeland: " .. tostring(reason)
	end

	if type(petEnt.doSpecialPetAction) ~= "function" then
		return false, "pet entity has no doSpecialPetAction"
	end

	actionArgs = actionArgs or {}

	HomelandDemoCmdImplement._clearPetBubble(petEnt)

	local extraIntParam, errMsg = HomelandDemoCmdImplement._safeCall(function()
		return petEnt:doSpecialPetAction(actionArgs.actorId, actionArgs.emojiKey, actionArgs.animationKey, actionArgs.animationLoopKey, actionArgs.speed, actionArgs.speedRateType, actionArgs.waitTime, actionArgs.animationTime, actionArgs.emojiTime, actionArgs.isFollow, actionArgs.targetPos, actionArgs.stopDist, actionArgs.isGoTargetPos)
	end)

	if errMsg then
		return false, "doSpecialPetAction failed: " .. tostring(errMsg)
	end

	return true, nil, {
		petId = petEnt.id or petId,
		actorId = petEnt.actorId,
		extraIntParam = extraIntParam,
		targetActorId = actionArgs.actorId,
		emojiKey = actionArgs.emojiKey,
		animationKey = actionArgs.animationKey,
		animationLoopKey = actionArgs.animationLoopKey,
		speed = actionArgs.speed,
		speedRateType = actionArgs.speedRateType,
		waitTime = actionArgs.waitTime,
		animationTime = actionArgs.animationTime,
		emojiTime = actionArgs.emojiTime,
		isFollow = actionArgs.isFollow,
		targetPos = actionArgs.targetPos,
		stopDist = actionArgs.stopDist,
		isGoTargetPos = actionArgs.isGoTargetPos
	}
end

function HomelandDemoCmdImplement.isInHomeland(self_, connId, params)
	if not pg.me then
		return HomelandDemoCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "no player")
	end

	if not pg.me.space then
		return HomelandDemoCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "no player space")
	end

	local space = pg.me.space
	local inHomeland = false

	if space.isHomeland then
		local ok, ret = pcall(function()
			return space:isHomeland()
		end)

		if ok then
			inHomeland = ret and true or false
		end
	end

	local isSelfHomeland = false

	if inHomeland and space.isSelfHomeland then
		local ok, ret = pcall(function()
			return space:isSelfHomeland(pg.me)
		end)

		if ok then
			isSelfHomeland = ret and true or false
		end
	end

	local data = {
		inHomeland = inHomeland,
		isSelfHomeland = isSelfHomeland,
		spaceType = space.spaceType,
		spaceId = space.id
	}

	if type(Utils.getSelfHomelandKey) == "function" then
		local key = HomelandDemoCmdImplement._safeCall(function()
			return Utils.getSelfHomelandKey(pg.me)
		end)

		if key ~= nil then
			data.selfHomelandKey = key
		end
	end

	if inHomeland and space.id and type(HomeLandUtils.parseHomelandKey) == "function" then
		local pair = HomelandDemoCmdImplement._safeCall(function()
			local sid, uid = HomeLandUtils.parseHomelandKey(space.id)

			return {
				serverId = sid,
				uid = uid
			}
		end)

		if pair then
			data.ownerServerId = pair.serverId
			data.ownerUid = pair.uid
		end
	end

	return HomelandDemoCmdImplement._ok(data)
end

function HomelandDemoCmdImplement.getPlayerInfo(self_, connId, params)
	if not pg.me then
		return HomelandDemoCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "no player")
	end

	return HomelandDemoCmdImplement._ok(HomelandDemoCmdImplement._buildPlayerInfo() or {})
end

function HomelandDemoCmdImplement.getFacilities(self_, connId, params)
	local err = HomelandDemoCmdImplement._requireHomeland()

	if err then
		return err
	end

	local facilities = HomelandDemoCmdImplement._collectFacilities()

	return HomelandDemoCmdImplement._ok({
		facilities = facilities,
		total = #facilities
	})
end

function HomelandDemoCmdImplement.getMiningFacilities(self_, connId, params)
	local err = HomelandDemoCmdImplement._requireHomeland()

	if err then
		return err
	end

	params = params or {}

	local includeDisabled = params.includeDisabled and true or false
	local facilities = HomelandDemoCmdImplement._collectMiningFacilities(includeDisabled)

	return HomelandDemoCmdImplement._ok({
		facilities = facilities,
		total = #facilities,
		filter = {
			abilityId = HomelandDemoCmdImplement.MINING_ABILITY_ID,
			abilityName = HomelandDemoCmdImplement.ABILITY_ID_TO_NAME[HomelandDemoCmdImplement.MINING_ABILITY_ID],
			includeDisabled = includeDisabled
		}
	})
end

function HomelandDemoCmdImplement.getTransportFacilities(self_, connId, params)
	local err = HomelandDemoCmdImplement._requireHomeland()

	if err then
		return err
	end

	params = params or {}

	local includeDisabled = params.includeDisabled and true or false
	local onlyOverThreshold = params.onlyOverThreshold and true or false
	local facilities = HomelandDemoCmdImplement._collectTransportFacilities(includeDisabled, onlyOverThreshold)

	return HomelandDemoCmdImplement._ok({
		facilities = facilities,
		total = #facilities,
		filter = {
			includeDisabled = includeDisabled,
			onlyOverThreshold = onlyOverThreshold
		}
	})
end

function HomelandDemoCmdImplement.getFacility(self_, connId, params)
	local err = HomelandDemoCmdImplement._requireHomeland()

	if err then
		return err
	end

	local facilityId = params and (params.ornamentId or params.facilityId)

	if facilityId == nil or facilityId == "" then
		return HomelandDemoCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "missing params.ornamentId")
	end

	local space = HomelandDemoCmdImplement._getHomeSpace()
	local facilityMap = space and space.facility or nil
	local facilityInfo = facilityMap and facilityMap[facilityId] or nil

	if facilityInfo == nil then
		local numericId = tonumber(facilityId)

		if numericId ~= nil then
			facilityInfo = facilityMap and facilityMap[numericId] or nil
			facilityId = numericId
		end
	end

	if facilityInfo == nil then
		return HomelandDemoCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "facility not found: " .. tostring(facilityId))
	end

	return HomelandDemoCmdImplement._ok(HomelandDemoCmdImplement._serializeFacilityBrief(facilityId) or {})
end

function HomelandDemoCmdImplement.getRuntimeSnapshot(self_, connId, params)
	params = params or {}

	local err = HomelandDemoCmdImplement._requireHomeland()

	if err then
		return err
	end

	local snapshot = {
		bridgeVersion = "v1",
		snapshotId = "homelandDemoRuntimeSnapshot",
		errors = {}
	}
	local homelandResult = HomelandDemoCmdImplement.isInHomeland(nil, nil, {})

	if homelandResult and homelandResult.ok then
		snapshot.homeland = homelandResult.data or {}
	else
		local errorInfo = homelandResult and homelandResult.error or {
			msg = "unknown error"
		}

		snapshot.errors[#snapshot.errors + 1] = {
			section = "homeland",
			code = errorInfo.code,
			msg = errorInfo.msg
		}
	end

	local playerInfoResult = HomelandDemoCmdImplement.getPlayerInfo(nil, nil, {})

	if playerInfoResult and playerInfoResult.ok then
		snapshot.playerInfo = playerInfoResult.data or {}
	else
		local errorInfo = playerInfoResult and playerInfoResult.error or {
			msg = "unknown error"
		}

		snapshot.errors[#snapshot.errors + 1] = {
			section = "playerInfo",
			code = errorInfo.code,
			msg = errorInfo.msg
		}
	end

	local facilitiesResult = HomelandDemoCmdImplement.getFacilities(nil, nil, {})

	if facilitiesResult and facilitiesResult.ok then
		snapshot.facilities = facilitiesResult.data or {}
	else
		local errorInfo = facilitiesResult and facilitiesResult.error or {
			msg = "unknown error"
		}

		snapshot.errors[#snapshot.errors + 1] = {
			section = "facilities",
			code = errorInfo.code,
			msg = errorInfo.msg
		}
	end

	local homePetsResult = HomelandDemoCmdImplement.getHomePets(nil, nil, {})

	if homePetsResult and homePetsResult.ok then
		snapshot.homePets = homePetsResult.data or {}
	else
		local errorInfo = homePetsResult and homePetsResult.error or {
			msg = "unknown error"
		}

		snapshot.errors[#snapshot.errors + 1] = {
			section = "homePets",
			code = errorInfo.code,
			msg = errorInfo.msg
		}
	end

	snapshot.errorCount = #snapshot.errors

	return HomelandDemoCmdImplement._ok(snapshot)
end

function HomelandDemoCmdImplement.getHomePets(self_, connId, params)
	local err = HomelandDemoCmdImplement._requireHomeland()

	if err then
		return err
	end

	local pets, maxCount = HomelandDemoCmdImplement._collectHomePetEntries()

	return HomelandDemoCmdImplement._ok({
		pets = pets,
		current = #pets,
		max = maxCount
	})
end

function HomelandDemoCmdImplement._collectHomePetEntries()
	local pets = {}
	local seen = {}
	local petBox = HomelandDemoCmdImplement._getHomePetBox()

	if petBox then
		local slotCount = HomelandDemoCmdImplement._getHomeSpace().petBoxMap:getSlotCount()

		for idx = 1, slotCount do
			local petId = petBox[idx]

			if petId ~= nil and petId ~= 0 and petId ~= "" then
				seen[tostring(petId)] = true
				pets[#pets + 1] = HomelandDemoCmdImplement._buildHomePetEntry(petId, idx)
			end
		end
	end

	for _, petId in ipairs(HomelandDemoCmdImplement._collectHomePetIds()) do
		if not seen[tostring(petId)] then
			seen[tostring(petId)] = true
			pets[#pets + 1] = HomelandDemoCmdImplement._buildHomePetEntry(petId, nil)
		end
	end

	table.sort(pets, function(a, b)
		local leftSlot = a.slotIdx or 999999
		local rightSlot = b.slotIdx or 999999

		if leftSlot ~= rightSlot then
			return leftSlot < rightSlot
		end

		return tostring(a.id) < tostring(b.id)
	end)

	local maxCount = petBox and HomelandDemoCmdImplement._getHomeSpace().petBoxMap:getSlotCount() or HomelandDemoCmdImplement._safeCall(function()
		return HomeLandUtils.getPetMaxCount(HomelandDemoCmdImplement._getHomeSpace())
	end) or 0

	return pets, maxCount
end

function HomelandDemoCmdImplement._petSqrDistanceToPlayer(entry)
	local petPos = entry and entry.position

	if not petPos or petPos.x == nil then
		return nil
	end

	local playerPos = HomelandDemoCmdImplement._getEntityPosition(pg.me)

	if not playerPos or playerPos.x == nil then
		return nil
	end

	local dx = petPos.x - playerPos.x
	local dy = (petPos.y or 0) - (playerPos.y or 0)
	local dz = (petPos.z or 0) - (playerPos.z or 0)

	return dx * dx + dy * dy + dz * dz
end

function HomelandDemoCmdImplement.getHomePetsInRange(self_, connId, params)
	local err = HomelandDemoCmdImplement._requireHomeland()

	if err then
		return err
	end

	params = params or {}

	local range = tonumber(params.range)
	local allPets, maxCount = HomelandDemoCmdImplement._collectHomePetEntries()

	if range == nil or range <= 0 then
		return HomelandDemoCmdImplement._ok({
			outOfRange = 0,
			pets = allPets,
			current = #allPets,
			max = maxCount,
			total = #allPets
		})
	end

	local rangeSqr = range * range
	local pets = {}
	local outOfRange = 0

	for _, entry in ipairs(allPets) do
		local sqrDist = HomelandDemoCmdImplement._petSqrDistanceToPlayer(entry)

		if sqrDist ~= nil and sqrDist <= rangeSqr then
			entry.distance = math.sqrt(sqrDist)
			pets[#pets + 1] = entry
		else
			outOfRange = outOfRange + 1
		end
	end

	table.sort(pets, function(a, b)
		return (a.distance or 0) < (b.distance or 0)
	end)

	return HomelandDemoCmdImplement._ok({
		pets = pets,
		current = #pets,
		max = maxCount,
		range = range,
		total = #allPets,
		outOfRange = outOfRange
	})
end

function HomelandDemoCmdImplement.debugPetEntity(self_, connId, params)
	local err = HomelandDemoCmdImplement._requireHomeland()

	if err then
		return err
	end

	params = params or {}

	local petId = params.petId

	if petId == nil or petId == "" then
		return HomelandDemoCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "missing params.petId")
	end

	local petEntity, debugInfo = HomelandDemoCmdImplement._findHomePetEntity(petId)
	local result = {
		petId = petId,
		directEntity = debugInfo,
		allLoadedHomePetEntities = HomelandDemoCmdImplement._collectHomePetEntityDebugList(params.limit)
	}

	if petEntity == nil then
		result.directEntity = false
	end

	return HomelandDemoCmdImplement._ok(result)
end

function HomelandDemoCmdImplement.getCmdList(self_, connId, params)
	return HomelandDemoCmdImplement._ok(HomelandDemoCmdImplement._buildCmdListResult())
end

function HomelandDemoCmdImplement.getState(self_, connId, params)
	local subscribers = {}

	for connIdStr, subscribed in pairs(HomelandDemoCmdImplement.STATE.subscribers) do
		if subscribed then
			subscribers[#subscribers + 1] = tonumber(connIdStr) or connIdStr
		end
	end

	table.sort(subscribers, function(a, b)
		return tostring(a) < tostring(b)
	end)

	return HomelandDemoCmdImplement._ok({
		enabled = HomelandDemoCmdImplement.STATE.enabled,
		subscribers = subscribers,
		queuedEventCount = #HomelandDemoCmdImplement.STATE.eventQueue,
		nextEventSeq = HomelandDemoCmdImplement.STATE.nextEventSeq,
		lastCommand = HomelandDemoCmdImplement._cloneValue(HomelandDemoCmdImplement.STATE.lastCommand),
		lastEvent = HomelandDemoCmdImplement._cloneValue(HomelandDemoCmdImplement.STATE.lastEvent),
		supportedCommands = HomelandDemoCmdImplement._buildSupportedCommandNames()
	})
end

function HomelandDemoCmdImplement.setEnabled(self_, connId, params)
	HomelandDemoCmdImplement.STATE.enabled = params and params.enabled == true or false

	if HomelandDemoCmdImplement.STATE.enabled then
		if connId ~= nil then
			HomelandDemoCmdImplement.STATE.subscribers[tostring(connId)] = true
		elseif self_ and self_.authedConns then
			for authedConnId, authed in pairs(self_.authedConns) do
				if authed == true then
					HomelandDemoCmdImplement.STATE.subscribers[tostring(authedConnId)] = true
				end
			end
		end

		HomelandDemoCmdImplement._resetDemoFlowState()
	elseif connId ~= nil then
		HomelandDemoCmdImplement._removeSubscriber(connId)
	else
		HomelandDemoCmdImplement.STATE.subscribers = {}
	end

	HomelandDemoCmdImplement._refreshHomePetStepHeightUp()
	HomelandDemoCmdImplement._refreshHomePetCarryInteraction()
	HomelandDemoCmdImplement._setLastCommand("setEnabled", {
		enabled = HomelandDemoCmdImplement.STATE.enabled
	})
	HomelandDemoCmdImplement._publishEvent(HomelandDemoCmdImplement.EVENT_TOPIC_BRIDGE_STATE, {
		enabled = HomelandDemoCmdImplement.STATE.enabled
	})

	return HomelandDemoCmdImplement._ok({
		enabled = HomelandDemoCmdImplement.STATE.enabled
	})
end

function HomelandDemoCmdImplement.setPetCamera(self_, connId, params)
	params = params or {}

	local enabled = params.enabled

	if type(enabled) ~= "boolean" then
		return HomelandDemoCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "params.enabled must be boolean")
	end

	local actorId, petId

	if enabled then
		local err = HomelandDemoCmdImplement._requireHomeland()

		if err then
			return err
		end

		local targetId = params.petId

		if params.actorId ~= nil then
			actorId = tonumber(params.actorId)

			if actorId == nil or actorId <= 0 or actorId ~= math.floor(actorId) then
				return HomelandDemoCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "params.actorId must be a positive integer")
			end

			targetId = actorId
		end

		if targetId == nil or targetId == "" then
			return HomelandDemoCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "missing params.petId or params.actorId")
		end

		local petEntity = HomelandDemoCmdImplement._findHomePetEntity(targetId)

		if not petEntity or not Utils.isHomePet(petEntity) then
			return HomelandDemoCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "home pet entity not found: " .. tostring(targetId))
		end

		actorId = tonumber(petEntity.actorId)

		if actorId == nil or actorId <= 0 or actorId ~= math.floor(actorId) then
			return HomelandDemoCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "home pet actorId is not ready: " .. tostring(targetId))
		end

		petId = petEntity.petInfo and petEntity.petInfo.id or params.petId
	end

	local playerCameraMode = pg and pg.game and pg.game.camera and pg.game.camera.playerCameraMode or nil

	if not playerCameraMode or type(playerCameraMode.enableHomelandPetCamera) ~= "function" then
		return HomelandDemoCmdImplement._err(Const.CMD_SOCKET_ERROR.INTERNAL, "homeland pet camera is not ready")
	end

	local switched, switchErr = HomelandDemoCmdImplement._safeCall(function()
		return playerCameraMode:enableHomelandPetCamera(enabled, actorId)
	end)

	if switchErr ~= nil then
		return HomelandDemoCmdImplement._err(Const.CMD_SOCKET_ERROR.INTERNAL, "failed to switch homeland pet camera: " .. tostring(switchErr))
	end

	if switched ~= true then
		return HomelandDemoCmdImplement._err(Const.CMD_SOCKET_ERROR.INTERNAL, "failed to switch homeland pet camera")
	end

	local result = {
		enabled = enabled
	}

	if enabled then
		result.petId = petId
		result.actorId = actorId
	end

	HomelandDemoCmdImplement._setLastCommand("setPetCamera", result)

	return HomelandDemoCmdImplement._ok(result)
end

function HomelandDemoCmdImplement.assignPetWork(self_, connId, params)
	local err = HomelandDemoCmdImplement._requireHomeland()

	if err then
		return err
	end

	params = params or {}

	local petId = params.petId

	if petId == nil then
		return HomelandDemoCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "missing params.petId")
	end

	local target = {
		petId = petId,
		entry = HomelandDemoCmdImplement._buildHomePetEntry(petId, nil),
		petEnt = HomelandDemoCmdImplement._getHomePetEntity(petId)
	}

	if not target.entry or target.entry.isInHomeland ~= true then
		return HomelandDemoCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "pet not in homeland: " .. tostring(petId))
	end

	local facilityId, facilityState, facilityErr = HomelandDemoCmdImplement._resolveWorkFacility(params.facilityId)

	if not facilityId then
		return HomelandDemoCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, facilityErr)
	end

	if HomelandDemoCmdImplement._checkPetStateValid(target) ~= true then
		return HomelandDemoCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "pet state invalid for homeland work: " .. tostring(petId))
	end

	local interruptWork = params.interruptWork ~= false
	local force = params.force ~= false

	if not interruptWork and target.entry.isIdle ~= true then
		return HomelandDemoCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "pet is working and interruptWork=false; reject reassign work")
	end

	local ok, assignErr = HomelandDemoCmdImplement._dispatchFacilityWork(petId, facilityId, force)

	if not ok then
		return HomelandDemoCmdImplement._err(Const.CMD_SOCKET_ERROR.INTERNAL, assignErr)
	end

	HomelandDemoCmdImplement._setLastCommand("assignPetWork", {
		abilityCheckBypassed = true,
		petId = petId,
		facilityId = facilityId,
		facilityState = facilityState,
		interruptWork = interruptWork,
		force = force
	})

	return HomelandDemoCmdImplement._asyncOk({
		abilityCheckBypassed = true,
		petId = petId,
		facilityId = facilityId,
		facilityState = facilityState,
		opId = Const.HOMELAND_FACILITY_OP_TYPE.MOVING
	})
end

function HomelandDemoCmdImplement.assignPetTransport(self_, connId, params)
	local err = HomelandDemoCmdImplement._requireHomeland()

	if err then
		return err
	end

	params = params or {}

	local petId = params.petId

	if petId == nil then
		return HomelandDemoCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "missing params.petId")
	end

	local target = {
		petId = petId,
		entry = HomelandDemoCmdImplement._buildHomePetEntry(petId, nil),
		petEnt = HomelandDemoCmdImplement._getHomePetEntity(petId)
	}

	if not target.entry or target.entry.isInHomeland ~= true then
		return HomelandDemoCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "pet not in homeland: " .. tostring(petId))
	end

	local petInfo = HomelandDemoCmdImplement._getPetInfoById(petId)
	local canTransport = petInfo and HomelandDemoCmdImplement._safeCall(function()
		return Utils.checkHomePetCanDoOperId(petInfo.templateId, Const.HOMELAND_FACILITY_OP_TYPE.TRANSPORT)
	end)

	if canTransport ~= true then
		return HomelandDemoCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "该宠物不会搬运(无 transport 能力)，无法派去搬运: " .. tostring(petId))
	end

	local hasStore = HomelandDemoCmdImplement._safeCall(function()
		return Utils.checkHasStoreOrnament(HomelandDemoCmdImplement._getHomeSpace())
	end)

	if hasStore ~= true then
		return HomelandDemoCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "家园内没有存储箱(容器)，无法搬运；请先在家园放置一个存储箱再试")
	end

	local facilityId, facilityInfo, facilityErr = HomelandDemoCmdImplement._resolveFacility(params.facilityId)

	if not facilityId then
		return HomelandDemoCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, facilityErr)
	end

	local brief = HomelandDemoCmdImplement._serializeFacilityBrief(facilityId) or {}
	local transportOutputCount = tonumber(brief.transportOutputCount) or 0

	if transportOutputCount <= 0 then
		return HomelandDemoCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "该设施当前没有可搬运的产出: " .. tostring(facilityId))
	end

	local force = params.force ~= false
	local ok, assignErr = HomelandDemoCmdImplement._dispatchFacilityTransport(petId, facilityId, force)

	if not ok then
		return HomelandDemoCmdImplement._err(Const.CMD_SOCKET_ERROR.INTERNAL, assignErr)
	end

	HomelandDemoCmdImplement._setLastCommand("assignPetTransport", {
		petId = petId,
		facilityId = facilityId,
		transportOutputCount = transportOutputCount,
		force = force
	})

	return HomelandDemoCmdImplement._asyncOk({
		petId = petId,
		facilityId = facilityId,
		transportOutputCount = transportOutputCount,
		opId = Const.HOMELAND_FACILITY_OP_TYPE.GOTO_TRANSPORT
	})
end

function HomelandDemoCmdImplement.petAction(self_, connId, params)
	local err = HomelandDemoCmdImplement._requireHomeland()

	if err then
		return err
	end

	params = params or {}

	local interruptWork = params.interruptWork ~= false
	local paramErr = HomelandDemoCmdImplement._validatePetActionAssets(params)

	if paramErr then
		return HomelandDemoCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, paramErr)
	end

	local targetPos, targetPosErr = HomelandDemoCmdImplement._normalizePetActionTargetPos(params.targetPos)

	if targetPosErr then
		return HomelandDemoCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, targetPosErr)
	end

	local isFollow = params.isFollow == true
	local keepAway = params.keepAway == true
	local actorId = 0
	local targetInfo

	if isFollow then
		actorId = HomelandDemoCmdImplement._resolveMasterActorId()
		targetInfo = {
			isFollow = true,
			actorId = actorId
		}
		targetPos = nil
	elseif targetPos ~= nil then
		local hasExplicitActorId = params.actorId ~= nil and params.actorId ~= ""

		if hasExplicitActorId then
			actorId = params.actorId
		end

		targetInfo = {
			isGoTargetPos = true,
			targetPos = targetPos
		}

		if hasExplicitActorId then
			targetInfo.actorId = actorId
		end
	else
		local targetErr

		actorId, targetInfo, targetErr = HomelandDemoCmdImplement._resolvePetActionTargetActorId(params)

		if targetErr then
			return HomelandDemoCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, targetErr)
		end

		actorId = actorId or 0
	end

	local stopDist = tonumber(params.stopDist) or 0
	local actionArgs = {
		actorId = actorId,
		emojiKey = params.emojiKey,
		animationKey = params.animationKey,
		animationLoopKey = params.animationLoopKey,
		speed = params.speed,
		speedRateType = params.speedRateType,
		waitTime = params.waitTime,
		animationTime = params.animationTime,
		emojiTime = params.emojiTime,
		isFollow = isFollow,
		targetPos = targetPos,
		stopDist = stopDist,
		isGoTargetPos = targetPos ~= nil
	}
	local hasChatText = params.chatText and type(params.chatText) == "string" and #params.chatText > 0
	local emitFollowBubble = isFollow and not HomelandDemoCmdImplement._isBlankAssetKey(params.emojiKey) and not hasChatText
	local emitChatBubble = hasChatText
	local respondedPetIds = {}
	local actions = {}
	local rejected = {}
	local targets = HomelandDemoCmdImplement._buildActionPetTargets(params)

	for _, target in ipairs(targets) do
		local allowed, reason = HomelandDemoCmdImplement._checkPetActionAllowed(target, interruptWork)

		if not allowed then
			rejected[#rejected + 1] = {
				petId = target.petId,
				reason = reason
			}
		else
			local petActionArgs = actionArgs

			if keepAway and not isFollow and targetPos == nil or emitFollowBubble or emitChatBubble then
				petActionArgs = {}

				for k, v in pairs(actionArgs) do
					petActionArgs[k] = v
				end
			end

			if keepAway and not isFollow and targetPos == nil then
				local petEnt = HomelandDemoCmdImplement._findHomePetEntity(target.petId)
				local keepAwayPos = petEnt and HomelandDemoCmdImplement._calcKeepAwayTargetPos(petEnt) or nil

				petActionArgs.targetPos = keepAwayPos
				petActionArgs.isGoTargetPos = keepAwayPos ~= nil
			end

			if emitFollowBubble or emitChatBubble then
				petActionArgs.emojiKey = nil
			end

			local ok, dispatchReason, actionData = HomelandDemoCmdImplement._dispatchPetSpecialAction(target.petId, petActionArgs)

			if ok then
				respondedPetIds[#respondedPetIds + 1] = target.petId

				if actionData then
					if emitFollowBubble then
						actionData.emojiKey = params.emojiKey
					elseif emitChatBubble then
						actionData.chatText = params.chatText
						actionData.chatDuration = params.chatDuration or DialogueConst.CUSTOM_BUBBLE_DEFAULT_DURATION
					end

					actions[#actions + 1] = actionData
				end

				if emitFollowBubble then
					local bubbleOk, bubbleReason = HomelandDemoCmdImplement._emitPetBubble(target, params.emojiKey, params.emojiTime)

					if not bubbleOk then
						rejected[#rejected + 1] = {
							petId = target.petId,
							reason = "follow bubble failed: " .. tostring(bubbleReason)
						}
					end
				elseif emitChatBubble then
					local chatOk, chatReason = HomelandDemoCmdImplement._emitPetChat(target, params.chatText, params.chatDuration)

					if not chatOk then
						rejected[#rejected + 1] = {
							petId = target.petId,
							reason = "chat bubble failed: " .. tostring(chatReason)
						}
					end
				end
			else
				rejected[#rejected + 1] = {
					petId = target.petId,
					reason = dispatchReason
				}
			end
		end
	end

	HomelandDemoCmdImplement._setLastCommand("petAction", {
		petIds = HomelandDemoCmdImplement._getCmdPetIds(params),
		interruptWork = interruptWork,
		target = targetInfo,
		actionArgs = actionArgs,
		actions = actions,
		respondedPetIds = respondedPetIds,
		rejected = rejected
	})

	local demoTrigger = params.demoTrigger
	local demoTriggered = false

	if demoTrigger ~= nil and #respondedPetIds > 0 and pg.me and pg.me.serverMsg then
		if demoTrigger == "greet" then
			if not HomelandDemoCmdImplement.STATE.demoGreetTriggered then
				HomelandDemoCmdImplement.STATE.demoGreetTriggered = true

				pg.me:serverMsg("RPC_CS_HomelandDemoGreet")

				demoTriggered = true
			end
		elseif demoTrigger == "chat" and not HomelandDemoCmdImplement.STATE.demoChatTriggered then
			HomelandDemoCmdImplement.STATE.demoChatTriggered = true

			pg.me:serverMsg("RPC_CS_HomelandDemoChat")

			demoTriggered = true
		end
	end

	return HomelandDemoCmdImplement._ok({
		respondedPetIds = respondedPetIds,
		rejected = rejected,
		target = targetInfo,
		actions = actions,
		total = #respondedPetIds,
		demoTrigger = demoTrigger,
		demoTriggered = demoTriggered
	})
end

function HomelandDemoCmdImplement.showBubble(self_, connId, params)
	local err = HomelandDemoCmdImplement._requireHomeland()

	if err then
		return err
	end

	params = params or {}

	local emojiName = params.emojiName or "Happy"

	if type(emojiName) ~= "string" or emojiName == "" then
		return HomelandDemoCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "invalid params.emojiName")
	end

	local duration = tonumber(params.duration) or HomelandDemoCmdImplement.DEFAULT_BUBBLE_DURATION
	local respondedPetIds = {}
	local rejected = {}
	local targets = HomelandDemoCmdImplement._buildActionPetTargets(params)

	for _, target in ipairs(targets) do
		if not target.entry or target.entry.isInHomeland ~= true then
			rejected[#rejected + 1] = {
				reason = "pet is not in homeland",
				petId = target.petId
			}
		else
			local ok, reason = HomelandDemoCmdImplement._emitPetBubble(target, emojiName, duration)

			if ok then
				respondedPetIds[#respondedPetIds + 1] = target.petId
			else
				rejected[#rejected + 1] = {
					petId = target.petId,
					reason = reason
				}
			end
		end
	end

	HomelandDemoCmdImplement._setLastCommand("showBubble", {
		petIds = HomelandDemoCmdImplement._getCmdPetIds(params),
		emojiName = emojiName,
		duration = duration,
		respondedPetIds = respondedPetIds,
		rejected = rejected
	})

	return HomelandDemoCmdImplement._ok({
		respondedPetIds = respondedPetIds,
		rejected = rejected,
		emojiName = emojiName,
		duration = duration,
		total = #respondedPetIds
	})
end

function HomelandDemoCmdImplement.showPetChat(self_, connId, params)
	local err = HomelandDemoCmdImplement._requireHomeland()

	if err then
		return err
	end

	params = params or {}

	local text = params.text
	local duration = params.duration or DialogueConst.CUSTOM_BUBBLE_DEFAULT_DURATION

	if not text or type(text) ~= "string" or #text == 0 then
		return HomelandDemoCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "missing or invalid params.text (must be non-empty string)")
	end

	if type(duration) ~= "number" or duration <= 0 then
		return HomelandDemoCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "missing or invalid params.duration (must be positive number)")
	end

	local targets = HomelandDemoCmdImplement._buildActionPetTargets(params)
	local respondedPetIds = {}
	local rejected = {}

	for _, target in ipairs(targets) do
		if not target.entry or target.entry.isInHomeland ~= true then
			rejected[#rejected + 1] = {
				reason = "pet is not in homeland",
				petId = target.petId
			}
		else
			local ok, reason = HomelandDemoCmdImplement._emitPetChat(target, text, duration)

			if ok then
				respondedPetIds[#respondedPetIds + 1] = {
					success = true,
					petId = target.petId,
					duration = duration
				}
			else
				rejected[#rejected + 1] = {
					petId = target.petId,
					reason = reason
				}
			end
		end
	end

	HomelandDemoCmdImplement._setLastCommand("showPetChat", {
		petIds = HomelandDemoCmdImplement._getCmdPetIds(params),
		text = text,
		duration = duration,
		respondedPetIds = respondedPetIds,
		rejected = rejected
	})

	return HomelandDemoCmdImplement._ok({
		respondedPetIds = respondedPetIds,
		rejected = rejected,
		text = text,
		duration = duration,
		total = #respondedPetIds
	})
end

function HomelandDemoCmdImplement.getLearnProgress(self_, connId, params)
	params = params or {}

	local petId = params.petId

	if petId == nil or petId == "" then
		return HomelandDemoCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "missing params.petId")
	end

	local abilityId = HomelandDemoCmdImplement._normalizeAbilityId(params.abilityId)

	if abilityId == nil then
		return HomelandDemoCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "missing or invalid params.abilityId")
	end

	local progress = HomelandDemoCmdImplement._getLearnProgress(petId, abilityId)

	return HomelandDemoCmdImplement._ok({
		petId = petId,
		abilityId = abilityId,
		abilityName = HomelandDemoCmdImplement.ABILITY_ID_TO_NAME[abilityId],
		progress = progress,
		maxProgress = HomelandDemoCmdImplement.LEARN_PROGRESS_MAX,
		learned = progress >= HomelandDemoCmdImplement.LEARN_PROGRESS_MAX
	})
end

function HomelandDemoCmdImplement.learnAbility(self_, connId, params)
	local err = HomelandDemoCmdImplement._requireHomeland()

	if err then
		return err
	end

	params = params or {}

	local abilityId = HomelandDemoCmdImplement._normalizeAbilityId(params.abilityId)

	if abilityId == nil then
		return HomelandDemoCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "missing or invalid params.abilityId")
	end

	local abilityName = HomelandDemoCmdImplement.ABILITY_ID_TO_NAME[abilityId]
	local gain = tonumber(params.gain)

	if gain == nil then
		return HomelandDemoCmdImplement._err(Const.CMD_SOCKET_ERROR.PARAM, "missing or invalid params.gain (number required)")
	end

	local results = {}
	local completedResults = {}
	local rejected = {}
	local targets = HomelandDemoCmdImplement._buildActionPetTargets(params)

	for _, target in ipairs(targets) do
		if not target.entry or target.entry.isInHomeland ~= true then
			rejected[#rejected + 1] = {
				reason = "pet is not in homeland",
				petId = target.petId
			}
		else
			local oldProgress = HomelandDemoCmdImplement._getLearnProgress(target.petId, abilityId)
			local newProgress = HomelandDemoCmdImplement._setLearnProgress(target.petId, abilityId, oldProgress + gain)
			local learned = newProgress >= HomelandDemoCmdImplement.LEARN_PROGRESS_MAX
			local justLearned = oldProgress < HomelandDemoCmdImplement.LEARN_PROGRESS_MAX and learned
			local result = {
				petId = target.petId,
				abilityId = abilityId,
				abilityName = abilityName,
				progress = newProgress,
				maxProgress = HomelandDemoCmdImplement.LEARN_PROGRESS_MAX,
				learned = learned,
				justLearned = justLearned
			}

			results[#results + 1] = result

			if justLearned then
				completedResults[#completedResults + 1] = result
			end
		end
	end

	HomelandDemoCmdImplement._setLastCommand("learnAbility", {
		abilityId = abilityId,
		abilityName = abilityName,
		gain = gain,
		petIds = HomelandDemoCmdImplement._getCmdPetIds(params),
		results = results,
		completed = completedResults,
		completedCount = #completedResults,
		rejected = rejected
	})

	if #completedResults > 0 then
		HomelandDemoCmdImplement._publishEvent(HomelandDemoCmdImplement.EVENT_TOPIC_LEARN_COMPLETED, {
			abilityId = abilityId,
			abilityName = abilityName,
			gain = gain,
			maxProgress = HomelandDemoCmdImplement.LEARN_PROGRESS_MAX,
			results = completedResults
		})

		if abilityId == HomelandDemoCmdImplement.MINING_ABILITY_ID and pg.me and pg.me.serverMsg then
			pg.me:serverMsg("RPC_CS_HomelandDemoLearnMine")
		end
	end

	return HomelandDemoCmdImplement._ok({
		abilityId = abilityId,
		abilityName = abilityName,
		gain = gain,
		maxProgress = HomelandDemoCmdImplement.LEARN_PROGRESS_MAX,
		results = results,
		completed = completedResults,
		completedCount = #completedResults,
		rejected = rejected,
		total = #results
	})
end

function HomelandDemoCmdImplement.resetLearnProgress(self_, connId, params)
	params = params or {}

	local petId = params.petId
	local abilityId = HomelandDemoCmdImplement._normalizeAbilityId(params.abilityId)
	local scope

	if petId == nil or petId == "" then
		HomelandDemoCmdImplement.STATE.learnProgress = {}
		scope = "all"
	else
		local petKey = tostring(petId)
		local byPet = HomelandDemoCmdImplement.STATE.learnProgress[petKey]

		if abilityId == nil then
			HomelandDemoCmdImplement.STATE.learnProgress[petKey] = nil
			scope = "pet:" .. petKey
		elseif byPet then
			byPet[tostring(abilityId)] = nil
			scope = "pet:" .. petKey .. ",ability:" .. tostring(abilityId)
		else
			scope = "pet:" .. petKey .. " (no record)"
		end
	end

	HomelandDemoCmdImplement._setLastCommand("resetLearnProgress", {
		petId = petId,
		abilityId = abilityId,
		scope = scope
	})

	return HomelandDemoCmdImplement._ok({
		reset = true,
		scope = scope
	})
end

function HomelandDemoCmdImplement._onConnectionClose(connId)
	HomelandDemoCmdImplement._removeSubscriber(connId)

	if not next(HomelandDemoCmdImplement.STATE.subscribers) then
		HomelandDemoCmdImplement.STATE.enabled = false
	end
end

function HomelandDemoCmdImplement.pullEvents(self_, connId, params)
	params = params or {}

	local sinceSeq = tonumber(params.sinceSeq) or 0
	local maxCount = tonumber(params.maxCount) or HomelandDemoCmdImplement.DEFAULT_PULL_MAX_COUNT

	maxCount = math.max(1, math.min(HomelandDemoCmdImplement.MAX_PULL_MAX_COUNT, maxCount))

	local events = {}

	for _, event in ipairs(HomelandDemoCmdImplement.STATE.eventQueue) do
		if sinceSeq < event.seq then
			events[#events + 1] = HomelandDemoCmdImplement._cloneValue(event)

			if maxCount <= #events then
				break
			end
		end
	end

	HomelandDemoCmdImplement._setLastCommand("pullEvents", {
		connId = connId,
		sinceSeq = sinceSeq,
		maxCount = maxCount,
		returnedCount = #events
	})

	return HomelandDemoCmdImplement._ok({
		events = events,
		total = #events,
		nextSeq = HomelandDemoCmdImplement.STATE.nextEventSeq
	})
end

function HomelandDemoCmdImplement.reset(self_, connId, params)
	HomelandDemoCmdImplement._resetState()

	return HomelandDemoCmdImplement._ok({
		reset = true
	})
end

return HomelandDemoCmdImplement
