-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\ClientLevelUtils.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local MessageName = require("Const.MessageName")
local SceneUtils = require("Common.Utils.SceneUtils")
local InteractionConst = require("Common.Const.InteractionConst")
local VirtualEntUtils = require("Common.Utils.VirtualEntUtils")
local ClientUtils = require("Utils.ClientUtils")
local logger = LoggerManager.getLogger("ClientLevelUtils")
local Utils = require("Common.Utils.Utils")
local UIConst = require("Const.UIConst")
local SandboxConst = require("Common.Const.SandboxConst")
local RandomMapBatchUtils = require("Common.Utils.RandomMapBatchUtils")
local ClientLevelUtils = {}

function ClientLevelUtils.onSwitchInteract(switch, isEnter, actionPrototypeId, pos, id)
	if isEnter then
		facade:SendMessageCommand(MessageName.ENTER_TRIGGER, {
			dist = 1,
			interactionType = InteractionConst.INTERACTION_TYPE_SWITCH,
			interactFunc = function()
				local space = pg.space

				if not space then
					return
				end

				if not space:checkPermission(SandboxConst.Permission.OwnerInScene, true) then
					return
				end

				switch:Toggle()
			end,
			actionPrototypeId = actionPrototypeId,
			targetPos = pos,
			globalId = id
		})
	else
		facade:SendMessageCommand(MessageName.LEAVE_TRIGGER, {
			interactionType = InteractionConst.INTERACTION_TYPE_SWITCH,
			actionPrototypeId = actionPrototypeId,
			globalId = id
		})
	end
end

function ClientLevelUtils.onPushInteract(switch, isEnter, actionPrototypeId, pos, id)
	if isEnter then
		facade:SendMessageCommand(MessageName.ENTER_TRIGGER, {
			dist = 1,
			interactionType = InteractionConst.INTERACTION_TYPE_SWITCH,
			interactFunc = function()
				local space = pg.space

				if not space then
					return
				end

				if not space:checkPermission(SandboxConst.Permission.OwnerInScene, true) then
					return
				end

				switch:TryPush()
			end,
			actionPrototypeId = actionPrototypeId,
			targetPos = pos,
			globalId = id
		})
	else
		facade:SendMessageCommand(MessageName.LEAVE_TRIGGER, {
			interactionType = InteractionConst.INTERACTION_TYPE_SWITCH,
			actionPrototypeId = actionPrototypeId,
			globalId = id
		})
	end
end

local Time = require("Core.Common.Time")

function ClientLevelUtils.onInteract(cb, isEnter, actionPrototypeId, pos, id, cd)
	local context = {}

	if isEnter then
		facade:SendMessageCommand(MessageName.ENTER_TRIGGER, {
			dist = 1,
			interactionType = InteractionConst.INTERACTION_TYPE_SWITCH,
			interactFunc = function()
				local space = pg.space

				if not space then
					return
				end

				xpcall(cb, debug.traceback)

				context.lastInteractTime = Time.realSecondCache

				ClientLevelUtils.doInteractCustom(actionPrototypeId)
			end,
			canInteractiveFunc = function(interactUnit)
				if cd and cd > 0 then
					local lastTime = context.lastInteractTime or 0
					local now = Time.realSecondCache

					if now - lastTime < cd then
						return false
					end
				end

				return true
			end,
			actionPrototypeId = actionPrototypeId,
			targetPos = pos,
			globalId = id
		})
	else
		facade:SendMessageCommand(MessageName.LEAVE_TRIGGER, {
			interactionType = InteractionConst.INTERACTION_TYPE_SWITCH,
			actionPrototypeId = actionPrototypeId,
			globalId = id
		})
	end
end

local ItemConst = require("Common.Const.ItemConst")

function ClientLevelUtils.doInteractCustom(actionPrototypeId)
	if actionPrototypeId == ItemConst.ROB_EGG_INTERACT_TYPE.EGG_END_ORGAN and ToBool(pg.me) and ToBool(pg.space) and pg.space:isGrabEgg() then
		pg.me:serverMsg("RPC_CS_RobEggActivateDG")
	end
end

function ClientLevelUtils.getPawnEModel()
	return pg.pawn.eModel
end

function ClientLevelUtils.getEthnicGroup(actorId)
	local entity = pg.getEntityByActorId(actorId)

	if not entity then
		return 0
	end

	local configData = entity:getConfigData()

	return configData and configData.ethnicGroup or 0
end

function ClientLevelUtils.forceLeavePet()
	pg.me:serverMsg("RPC_CS_LeavePet")
end

function ClientLevelUtils.setFogMaskRadius(radius)
	pg.me:setFogMaskRadius(radius)
end

function ClientLevelUtils.enterMeteorArea(meteorId)
	pg.me:onEnterMeteorArea(meteorId)
end

function ClientLevelUtils.unlockHomeZone(zoneId)
	pg.global.ui:open(UIConst.UI_ID_HOME_PLATEINFO, {
		zoneId = zoneId
	})
end

function ClientLevelUtils.onMicrophoneInteract(luaObj, isEnter, actionPrototypeId, pos)
	if LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:debug("onMicrophoneInteract", isEnter, actionPrototypeId)
	end

	if isEnter then
		facade:SendMessageCommand(MessageName.ENTER_TRIGGER, {
			faceToTarget = true,
			needCheckDis = false,
			interactionType = InteractionConst.INTERACTION_TYPE_MICROPHONE,
			interactFunc = function()
				luaObj:StartCamera()
				facade:SendMessageCommand(MessageName.LEAVE_TRIGGER, {
					interactionType = InteractionConst.INTERACTION_TYPE_MICROPHONE,
					actionPrototypeId = actionPrototypeId
				})
			end,
			actionPrototypeId = actionPrototypeId,
			targetPos = pos
		})
	else
		facade:SendMessageCommand(MessageName.LEAVE_TRIGGER, {
			interactionType = InteractionConst.INTERACTION_TYPE_MICROPHONE,
			actionPrototypeId = actionPrototypeId
		})
	end
end

function ClientLevelUtils.createVirtualTarget(position)
	return ClientUtils.createClientEntity("ClientVirtualTarget", VirtualEntUtils.getNewVirtualEntityId(), {
		position = position
	})
end

local GET_SKILL_ACCUMULATE_FUNC_ID = 3010
local GET_SKILL_ACCUMULATE_SKILL_FUNC_ID = 3069
local ecs_global_const_data = require("Data.ecs_global_const_data")

function ClientLevelUtils.getSkillAccumulate(atkLevel, defLevel, power, srcElementLv, abilityId, instanceDmgRateV)
	local atkValue = ecs_global_const_data.elementCriterion[atkLevel] or 0
	local defValue = ecs_global_const_data.materialBarrier[defLevel] or 0

	if abilityId and abilityId ~= 0 then
		local paramData = pg.global.abilityMgr:getAbilityParamData(abilityId)
		local epCost = paramData.epCost or 0
		local ecsChange = paramData.ecsChange or 0

		return Utils.formulaSafeCall(0, GET_SKILL_ACCUMULATE_SKILL_FUNC_ID, atkValue, defValue, power, srcElementLv, epCost, instanceDmgRateV or 0, ecsChange)
	end

	local ret = Utils.formulaSafeCall(0, GET_SKILL_ACCUMULATE_FUNC_ID, atkValue, defValue, power, srcElementLv)

	return ret
end

local GET_SKILL_ACCUMULATE_ON_BODY_FUNC_ID = 3019

function ClientLevelUtils.getSkillAccumulateOnBody(atkLevel, defLevel, power, srcElementLv, abilityId)
	local atkValue = ecs_global_const_data.elementCriterion[atkLevel] or 0
	local defValue = ecs_global_const_data.materialBarrier[defLevel] or 0
	local ret = Utils.formulaSafeCall(0, GET_SKILL_ACCUMULATE_ON_BODY_FUNC_ID, atkValue, defValue, power, srcElementLv, abilityId)

	return ret
end

function ClientLevelUtils.registerEntityAIEventInfo(staticId, behaviorName)
	if not pg.me then
		return
	end

	pg.me:registerEntityAIEventInfo(staticId, behaviorName)
end

function ClientLevelUtils.playCameraShakeById(shakeId)
	if shakeId == nil or shakeId == 0 then
		return
	end

	pg.game.camera:playCameraShakeById(pg.me, shakeId)
end

function ClientLevelUtils.unRegisterEntityAIEventInfo(staticId, behaviorName)
	if not pg.me then
		return
	end

	pg.me:unRegisterEntityAIEventInfo(staticId, behaviorName)
end

local ClientConst = require("Const.ClientConst")

function ClientLevelUtils.setIsKinematicByFlowCanvas(staticId, isKinematic)
	local entity = pg.me.space:getEntityByStaticId(staticId)

	if entity and entity.setIsKinematic then
		entity:setIsKinematic(isKinematic, ClientConst.IsKinematicKey.FlowCanvas)
	end
end

function ClientLevelUtils.getWeather()
	if not pg.me then
		return 1
	end

	if not pg.me.getWeather then
		return 1
	end

	return pg.me:getWeather()
end

function ClientLevelUtils.notifyEcsWeather()
	if not appFacade or not appFacade.ecsMgr then
		return
	end

	local weatherId = ClientLevelUtils.getWeather()
	local info = ClientLevelUtils.getWeatherElementInfo(weatherId)

	appFacade.ecsMgr:SetWeather(info[1] or 0, info[2] or 0, info[3] or 0)
end

function ClientLevelUtils.notifyEcsTemperature()
	if not appFacade or not appFacade.ecsMgr then
		return
	end

	local temperature = ClientLevelUtils.calcEnvTemperature()

	appFacade.ecsMgr:SetEnvTemperature(temperature)
end

function ClientLevelUtils.calcEnvTemperature()
	return
end

local WeatherData = require("Data.weather_data")

function ClientLevelUtils.getWeatherElementInfo(weatherId)
	local wtd = WeatherData[weatherId]

	if not wtd or not wtd.ecsInfo then
		return {
			0,
			0,
			0
		}
	end

	return Utils.deepCopyTable(wtd.ecsInfo)
end

function ClientLevelUtils.setDungeonGoalStr(key)
	if not key then
		return
	end

	local str = pg.getGameString(key)

	facade:sendMsgToUI(MessageName.DUNGEON_GOAL_REFRESH, {
		goal = str
	})
end

function ClientLevelUtils.isSelfSpace()
	if pg.me and pg.me.space then
		if pg.me.space.ownerPlayerId and not string.isNilOrEmpty(pg.me.space.ownerPlayerId) then
			return pg.me.space.ownerPlayerId == pg.me.id
		else
			return true
		end
	end

	return false
end

function ClientLevelUtils.initSubComps()
	if ClientLevelUtils.factoryCls then
		return
	end

	ClientLevelUtils.factoryCls = {}

	for _, levelItemType in pairs(SandboxConst.SUB_COMPONENT_TYPE) do
		local status, cls = pcall(require, "GameApp.Sandbox.SubComponents." .. levelItemType)

		if not status then
			logger:error("can't find level item class", levelItemType)
		end

		ClientLevelUtils.factoryCls[levelItemType] = cls
	end
end

function ClientLevelUtils.getLastDittoDungeonState()
	local state = pg.global.prefsCacheUtils:getInt(pg.me.uid .. ClientConst.PrefKey.DittoState, 0)

	if state > 0 then
		pg.global.prefsCacheUtils:setInt(pg.me.uid .. ClientConst.PrefKey.DittoState, SandboxConst.DITTO_DUNGEON_RESULT.DEFAULT)
	end

	return state
end

function ClientLevelUtils.playCfgAnimation(staticId, startAni, loopAni, endAni)
	if not pg.me or not pg.me.space then
		return
	end

	local entity = pg.me.space:getEntityByStaticId(staticId)

	if entity then
		entity:playCfgAnimation({
			startAni,
			loopAni,
			endAni,
			{
				true
			}
		})
	end
end

function ClientLevelUtils.getSubCompCls(name)
	ClientLevelUtils.initSubComps()

	local cls = ClientLevelUtils.factoryCls[name]

	if not cls then
		logger:error("can't find node class %s configId %s", name)

		return
	end

	return cls
end

return ClientLevelUtils
