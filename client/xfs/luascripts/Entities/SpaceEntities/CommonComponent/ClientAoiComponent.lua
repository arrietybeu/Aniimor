-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\CommonComponent\\ClientAoiComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local ClientSwitch = require("Common.ClientSwitch")
local Switch = require("Core.Common.Switch")
local ActorManager = require("Core.Common.ActorManager")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local RpcIndex = require("Core.Common.RpcIndex")
local CoreConst = require("Core.Common.Const")
local ClientConst = require("Const.ClientConst")
local RpcMethod = require("Core.Common.RpcMethod")
local lume = require("Core.Common.lume")
local Time = require("Core.Common.Time")
local CommonSwitch = require("Common.CommonSwitch")
local EModelUtils = require("Entities.Utils.EModelUtils")
local RpcSendValidator = require("Core.Common.RpcSendValidator")
local Vector3 = Vector3
local Quaternion = Quaternion
local FuncNameEntitiesInRange = "entitiesInRange"
local FuncNameEntitiesInRangeWithTable = "entitiesInRangeWithTable"
local FuncNameEntitiesInRangeByPos = "entitiesInRangeByPos"
local FuncNameSetSyncFpsRange = "setSyncFpsRange"
local FuncNameServerMsg = "serverMsg"
local FuncNameEcsMsg = "ecsMsg"
local FuncNameSetPosition = "setPosition"
local FuncNameSetRotation = "setRotation"
local FuncNameAddRangeEvent = "addRangeEvent"
local FuncNameRemoveRangeEvent = "removeRangeEvent"
local FuncNameEnterSpace = "enterSpace"
local FuncNameLeaveSpace = "leaveSpace"
local _emptyEntities = {}
local ClientAoiComponent = class.Component("ClientAoiComponent")

function ClientAoiComponent:ctor()
	self.proxy = nil
	self.aoiResultCacheDic = {}
	self.aoiFuncCache = {}
	self.aoiState = false
	self.aoiDisableReason = {}
	self.inMainPlayerTrap = false
end

function ClientAoiComponent:init(dict)
	if FREE_WALK then
		return true
	end

	local isMainPlayer = self.isMainPlayer or false
	local position = dict.position or Vector3.constZero
	local rotation = dict.rotation or Quaternion.identity

	position = Vector3.Convert(position)
	rotation = Quaternion.Convert(rotation)

	self:initPosRot(position.x, position.y, position.z, rotation.x, rotation.y, rotation.z, rotation.w)

	if not self.actorId then
		return true
	end

	self:destroyAoi()

	if not self.clenUsrType then
		self.clenUsrType = Const.CLEN_USR_TYPE_CLIENT_MAP[self.className] or Const.CLEN_USR_TYPE_NONE
	end

	if self.clenUsrType == Const.CLEN_USR_TYPE_NONE and LoggerManager.checkLogger(LoggerConst.ERROR) then
		self.logger:error("entity not set clenUsrType", self:repr(), self.clenUsrType)
	end

	if self.clenUsrType < 0 then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:info("entity clenUsrType error", self:repr(), self.clenUsrType)
		end

		return false
	end

	local clenUsrType = self.clenUsrType

	if EnableBotTest then
		clenUsrType = -self.clenUsrType
	end

	if not self.skipAoiActor then
		self.aoi = pg.world.createActor(self.id, clenUsrType, self.actorId, isMainPlayer, position.x, position.y, position.z, rotation.x, rotation.y, rotation.z, rotation.w, dict.syncVersion or 0)
	end

	ActorManager.addEntity(self.actorId, self, dict.uid)

	if isMainPlayer and self.aoi then
		pg.playerPos = self:getPosition()

		self:forceSetPosRot(position, rotation)
		self.aoi:setServer(self.server.stub.cObj)
	end

	return true
end

function ClientAoiComponent:start()
	self:pauseAoiState(Const.AOI_DISABLE_REASON.SPACE_LOADING)

	if clientUtils.checkIsHideEntity(self) then
		self:pauseAoiState(Const.AOI_DISABLE_REASON.HIDE_SHOW_ENTITY_DIC)
	else
		self:resumeAoiState(Const.AOI_DISABLE_REASON.HIDE_SHOW_ENTITY_DIC)
	end
end

function ClientAoiComponent:enterSpace(space)
	if self.space == nil then
		if ClientSwitch.EnableDebugAoi and LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:info("%s:enterSpace", self:repr())
		end

		self.space = space

		self:resumeAoiState(Const.AOI_DISABLE_REASON.SPACE_LOADING)
		space:onEntityJoin(self)

		if self.onEnterSpace then
			self:onEnterSpace()
		end
	elseif Utils.isCatchBall(self) then
		self:resumeAoiState(Const.AOI_DISABLE_REASON.SPACE_LOADING)
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		self.logger:error("%s:enter space error, self.space is not nil", self:repr())
	end

	self:refreshSyncFpsRange()
end

function ClientAoiComponent:leaveSpace()
	if self.space ~= nil then
		if ClientSwitch.EnableDebugAoi and LoggerManager.checkLogger(LoggerConst.INFO) then
			self.logger:info("%s:leaveSpace", self:repr())
		end

		if self.onLeaveSpace and self._preDestroyLeaveSpace ~= self.space then
			self:onLeaveSpace()
		end

		if self.space.onEntityLeave then
			self.space:onEntityLeave(self)
		end

		self:pauseAoiState(Const.AOI_DISABLE_REASON.SPACE_LOADING)

		self.space = nil
		self._preDestroyLeaveSpace = nil
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		self.logger:error("%s:leave space error, self.space is nil", self:repr())
	end
end

function ClientAoiComponent:addRangeEvent(eventId, radiusX, radiusZ, filtPlayer, filtNpc)
	if filtPlayer == nil then
		filtPlayer = false
	end

	if filtNpc == nil then
		filtNpc = false
	end

	return self:__callAoiFunc(FuncNameAddRangeEvent, eventId, radiusX, radiusZ, filtPlayer, filtNpc)
end

function ClientAoiComponent:removeRangeEvent(eventId, rangeLeave)
	self:__callAoiFunc(FuncNameRemoveRangeEvent, eventId, rangeLeave)
end

function ClientAoiComponent:pauseAoiState(disableReason)
	self.aoiDisableReason[disableReason] = true

	if self.aoi and not EnableBotTest and self.aoiState then
		self:__callAoiFunc(FuncNameLeaveSpace)

		self.aoiState = false
	end
end

function ClientAoiComponent:resumeAoiState(disableReason)
	self.aoiDisableReason[disableReason] = nil

	if self.aoi and not EnableBotTest and self.aoiState == false and Utils.isEmptyTable(self.aoiDisableReason) then
		self.aoiState = true

		self:__callAoiFunc(FuncNameEnterSpace)
	end
end

function ClientAoiComponent:entitiesInAoiRange(userType, maxFindCount)
	return self:entitiesInRange(math.floor(self.aoiRange / 100), userType, maxFindCount)
end

function ClientAoiComponent:entitiesInAoiRangeWithTable(userType, maxFindCount, outputTable)
	return self:entitiesInRangeWithTable(math.floor(self.aoiRange / 100), userType, maxFindCount, outputTable)
end

function ClientAoiComponent:entitiesInRange(range, userType, maxFindCount)
	if ClientSwitch.EnableDebugAoi and LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("%s:entitiesInRange range=%s, userType=%s, maxFindCount=%s", self:repr(), range, userType, maxFindCount)
	end

	return self:__callAoiFunc(FuncNameEntitiesInRange, range, userType, maxFindCount or 0) or _emptyEntities
end

function ClientAoiComponent:entitiesInRangeWithTable(range, userType, maxFindCount, outputTable, searchByDis)
	if ClientSwitch.EnableDebugAoi and LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("%s:entitiesInRange range=%s, userType=%s, maxFindCount=%s", self:repr(), range, userType, maxFindCount)
	end

	return self:__callAoiFunc(FuncNameEntitiesInRangeWithTable, range, userType, maxFindCount or 0, outputTable, searchByDis or false) or 0
end

function ClientAoiComponent:entitiesInRangeByPos(pos, range, userType, maxFindCount)
	if ClientSwitch.EnableDebugAoi and LoggerManager.checkLogger(LoggerConst.INFO) then
		self.logger:info("%s:entitiesInRange range=%s, userType=%s, maxFindCount=%s", self:repr(), range, userType, maxFindCount)
	end

	return self:__callAoiFunc(FuncNameEntitiesInRangeByPos, pos, range, userType, maxFindCount or 0) or _emptyEntities
end

function ClientAoiComponent:setServerProxy(player)
	self.proxy = player
end

function ClientAoiComponent:onMultiPlayerEnvChanged(multiPlayerEnvValue)
	self:refreshSyncFpsRange()
end

function ClientAoiComponent:EVENT_OnAuthorityChanged()
	self:refreshSyncFpsRange()
end

function ClientAoiComponent:refreshSyncFpsRange()
	if not self.isMainAuthority then
		return
	end

	if self.aoi and self.space then
		if self.space:isMultiPlayerEnv() then
			local isBossRush = self.space:isBossRushEnv()

			if self.isMainPlayer or self.isMainPet or isBossRush then
				self:setSyncFps(30)
			else
				self:setSyncFps(10)
			end
		elseif self.inMainPlayerTrap or self.isMainPlayer or self.isMainPet then
			self:setSyncFps(10)
		else
			self:setSyncFps(0.2)
		end
	end
end

function ClientAoiComponent:setSyncFps(range)
	if self.syncFps == range then
		return
	end

	self.syncFps = range

	self:__callAoiFunc(FuncNameSetSyncFpsRange, range, range)
end

local paramCache = {}

local function parseVarArgs(...)
	lume.clear(paramCache)

	local callback
	local argLen = select("#", ...)

	if argLen > 0 then
		local final = select(argLen, ...)

		if type(final) == "function" then
			callback = final
			argLen = argLen - 1
		end
	end

	if argLen > 0 then
		for i = 1, argLen do
			paramCache[i] = select(i, ...)
		end
	end

	return callback, paramCache
end

function ClientAoiComponent:serverMsgNoGC(name, ...)
	self:serverMsg(name, ...)
end

function ClientAoiComponent:serverMsg(name, ...)
	if EnableBotTest then
		local ClientEntity = require("Core.Client.ClientEntity")

		ClientEntity.serverMsg(self, name, ...)

		return
	end

	if Utils.isVirtualEntity(self) then
		return
	end

	local nargs = select("#", ...)
	local callback

	if nargs > 0 then
		callback = select(nargs, ...)

		if type(callback) ~= "function" then
			callback = nil
		end
	end

	if self.aoi then
		if _G_IsDebugMode then
			local RpcDebugHelper = require("Utils.RpcDebugHelper")

			RpcDebugHelper.sendMsg(self.className, self.id, name, ...)
		end

		local callbackId = 0

		if callback ~= nil then
			callbackId = self:addCallback(callback)
			nargs = nargs - 1
		end

		if self.clenUsrType == Const.CLEN_USR_TYPE_PLAYER then
			if self:isServerLost() then
				self:delCallback(callbackId)

				if LoggerManager.checkLogger(LoggerConst.WARN) then
					self.logger:warn("%s call serverMsg %s, but server lost", self:repr(), name)
				end

				return
			end

			local index = RpcIndex.sendRpcIndex(name)

			if callbackId == 0 then
				if not RpcSendValidator.validate(name, ...) then
					return
				end

				self:__callAoiFunc(FuncNameServerMsg, index, callbackId, ...)
			else
				local _, paramsTbl = parseVarArgs(...)

				if not RpcSendValidator.validateArgs(name, paramsTbl) then
					self:delCallback(callbackId)

					return
				end

				self:__callAoiFunc(FuncNameServerMsg, index, callbackId, unpack(paramsTbl))
			end
		elseif self.authority == Const.AUTHORITY_MASTER then
			local index = RpcIndex.sendRpcIndex(name)

			if callbackId == 0 then
				if not RpcSendValidator.validate(name, ...) then
					return
				end

				self:__callAoiFunc(FuncNameServerMsg, index, callbackId, ...)
			else
				local _, paramsTbl = parseVarArgs(...)

				if not RpcSendValidator.validateArgs(name, paramsTbl) then
					self:delCallback(callbackId)

					return
				end

				self:__callAoiFunc(FuncNameServerMsg, index, callbackId, unpack(paramsTbl))
			end
		end
	else
		local ClientEntity = require("Core.Client.ClientEntity")

		ClientEntity.serverMsg(self, name, ...)
	end
end

function ClientAoiComponent:ecsMsg(byte, callback)
	if not self.aoi then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			self.logger:error("%s:ecs msg aoi is nil", self:repr())
		end

		return
	end

	local callbackId = 0

	if callback ~= nil then
		callbackId = self:addCallback(callback)
	end

	if self.clenUsrType == Const.CLEN_USR_TYPE_PLAYER then
		if self:isServerLost() then
			self:delCallback(callbackId)

			if LoggerManager.checkLogger(LoggerConst.WARN) then
				self.logger:warn("%s call ecsMsg %s, but server lost", self:repr(), inspect(byte))
			end

			return
		end

		self:__callAoiFunc(FuncNameEcsMsg, callbackId, byte)
	elseif self.authority == Const.AUTHORITY_MASTER then
		self:__callAoiFunc(FuncNameEcsMsg, callbackId, byte)
	end
end

function ClientAoiComponent:preDestroy()
	if self.space and self.onLeaveSpace then
		local leavingSpace = self.space

		self:onLeaveSpace()

		self._preDestroyLeaveSpace = leavingSpace
	end
end

function ClientAoiComponent:destroy()
	self.proxy = nil

	if self.space ~= nil then
		self:leaveSpace()
	end

	self:destroyAoi()

	if self.actorId then
		ActorManager.removeEntity(self.actorId, self)
	end
end

function ClientAoiComponent:destroyAoi()
	if self.aoi then
		self.aoi:destroy()

		self.aoi = nil
	end

	self.aoiState = false
	self.aoiFuncCache = {}
end

function ClientAoiComponent:EVENT_EModelCreate()
	local position = self:getPosition()
	local rot = self:getRotation()

	self:forceSetPosRot(position, rot, true)
end

function ClientAoiComponent:EVENT_EnterScene()
	local position = self:getPosition()
	local rot = self:getRotation()

	self:forceSetPosRot(position, rot, true)
end

function ClientAoiComponent:EVENT_ResetScene()
	local position = self:getPosition()
	local rot = self:getRotation()

	self:forceSetPosRot(position, rot, true)
end

function ClientAoiComponent:EVENT_OnCharacterStateChange(oldState, newState)
	if self.aoi then
		self.aoi.movementMode = newState
	end
end

function ClientAoiComponent:EVENT_OnHideShowEntityDictChange()
	if clientUtils.checkIsHideEntity(self) then
		self:pauseAoiState(Const.AOI_DISABLE_REASON.HIDE_SHOW_ENTITY_DIC)
	else
		self:resumeAoiState(Const.AOI_DISABLE_REASON.HIDE_SHOW_ENTITY_DIC)

		if not self.isMainPlayer then
			local position = self:getPosition()
			local rot = self:getRotation()

			self:forceSetPosRot(position, rot)
		end
	end
end

function ClientAoiComponent:getCharacterState()
	if self.aoi then
		return self.aoi.movementMode
	end

	return 0
end

function ClientAoiComponent:forceSetPos(position, isTeleport)
	isTeleport = isTeleport or false

	self:setPosition(position, isTeleport and Const.AgentTransformReasonConst.TeleportFromLua or Const.AgentTransformReasonConst.LogicFromLua)
end

function ClientAoiComponent:forceSetPosEx(x, y, z, isTeleport)
	isTeleport = isTeleport or false

	self:setPositionEx(x, y, z, isTeleport and Const.AgentTransformReasonConst.TeleportFromLua or Const.AgentTransformReasonConst.LogicFromLua)
end

function ClientAoiComponent:forceSetPosRot(position, rot, instant, isTeleport)
	instant = instant or false
	isTeleport = isTeleport or false

	local reason = isTeleport and Const.AgentTransformReasonConst.TeleportFromLua or Const.AgentTransformReasonConst.LogicFromLua

	self:setPosition(position, reason)
	self:setRotation(rot, instant, reason)
end

function ClientAoiComponent:forceSetPosRotEx(px, py, pz, rx, ry, rz, rw, instant, isTeleport)
	instant = instant or false
	isTeleport = isTeleport or false

	local reason = isTeleport and Const.AgentTransformReasonConst.TeleportFromLua or Const.AgentTransformReasonConst.LogicFromLua

	self:setPositionEx(px, py, pz, reason)
	self:setRotationEx(rx, ry, rz, rw, instant, reason)
end

function ClientAoiComponent:forceSetRot(rot)
	self:setRotation(rot, true, Const.AgentTransformReasonConst.LogicFromLua)
end

function ClientAoiComponent:forceSetRotEx(x, y, z, w)
	self:setRotationEx(x, y, z, w, true, Const.AgentTransformReasonConst.LogicFromLua)
end

function ClientAoiComponent:getVelocity()
	if self.eModel then
		return self.eModel.Velocity
	end
end

function ClientAoiComponent:RPC_SC_DispatchSpaceMsg(methodName, parameters)
	if self.space == nil then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			self.logger:warn("RPC_SC_DispatchSpaceMsg %s, %s", self:repr(), methodName)
		end

		return
	end

	local method = self.space[methodName]

	if method == nil or not class.isInstanceOf(method, RpcMethod) then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			self.logger:warn("RPC_SC_DispatchSpaceMsg has no rpc method %s", methodName)
		end

		return
	end

	method(CoreConst.ACCESSOR_SERVER, self.space, unpack(parameters))
end

function ClientAoiComponent:forbidPositionCheck(args)
	self:serverMsg("RPC_CS_ForbidPositionCheck", args)
end

function ClientAoiComponent:onMoveTile(tileX, tileZ)
	return
end

function ClientAoiComponent:onMarkerMoveTile(tileX, tileZ)
	if self.space and self.space.markerMoveTile then
		self.space:markerMoveTile(self.id, tileX, tileZ)
	end
end

function ClientAoiComponent:entitiesInRangeWithCache(range, userType, outputTable, acceptDelay)
	local count = self:getAoiCache(range, userType, outputTable, acceptDelay)

	if count < 0 then
		count = self:entitiesInRangeWithTable(range, userType, 0, outputTable)

		self:setAoiCache(range, userType, outputTable, count)

		return count
	end

	return count
end

function ClientAoiComponent:getAoiCache(range, userType, outputTable, acceptDelay)
	local cache = self.aoiResultCacheDic[userType]

	if not cache then
		return -1
	end

	acceptDelay = acceptDelay or Const.AOI_CACHE_TIME_DEFAULT

	if range > cache.range or Time.realSecondCache > cache.time + acceptDelay then
		return -1
	end

	local count = 0

	if cache.range - range < 0.01 then
		for actorId, _ in pairs(cache.ret) do
			if pg.getEntityByActorId(actorId) then
				count = count + 1
				outputTable[count] = actorId
			end
		end
	else
		local sqrRange = range * range

		for actorId, sqrDist in pairs(cache.ret) do
			if sqrDist < 0 then
				local ent = pg.getEntityByActorId(actorId)

				if ent then
					sqrDist = Vector3.SqrDistance(self:getPosition(), ent:getPosition())
					cache.ret[actorId] = sqrDist
				end
			end

			if sqrDist < sqrRange and pg.getEntityByActorId(actorId) then
				count = count + 1
				outputTable[count] = actorId
			end
		end
	end

	return count
end

function ClientAoiComponent:setAoiCache(range, userType, outputTable, count)
	if not self.aoiResultCacheDic[userType] then
		self.aoiResultCacheDic[userType] = {
			range = range,
			time = Time.realSecondCache,
			ret = {}
		}
	end

	local cache = self.aoiResultCacheDic[userType]

	cache.range = range
	cache.time = Time.realSecondCache

	table.clear(cache.ret)

	for i = 1, count do
		cache.ret[outputTable[i]] = -1
	end
end

function ClientAoiComponent:__callAoiFunc(funcName, ...)
	if not self.aoi then
		return
	end

	if not Utils.isMainPlayer(self) and not self.aoiState then
		return
	end

	local func = self.aoiFuncCache[funcName]

	if not func then
		func = self.aoi[funcName]

		if func then
			self.aoiFuncCache[funcName] = func
		else
			self.logger:error("self.aoi 函数不存在 funcName: %s", funcName)

			return
		end
	end

	return func(self.aoi, ...)
end

return ClientAoiComponent
