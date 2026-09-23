-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Net\\Etcd\\EtcdProcessor.lua

local class = require("Core.Framework.Class")
local EtcdProcessor = class.Class("EtcdProcessor")
local EtcdClient = require("Core.Net.Etcd.EtcdClient")
local ProcessInfo = require("Core.Net.Etcd.ProcessInfo")
local LoggerManager = require("Core.Log.LoggerManager")
local TimerManager = require("Core.Timer.TimerManager")
local GameServerRepo = require("Core.Server.GameServerRepo")
local ServerSwitch = require("ServerSwitch")
local INIT = 0
local LEASE_GRANT = 1
local LEASE_KEEP_ALIVE = 2
local MEMBER_LIST_INTERVAL = 60
local _TTL = 120
local _TTL_ALIVE = _TTL / 5
local _CHECK_REGISTER_INTERVAL = 1
local _CHECK_REGISTER_DEADLINE = 180
local _FAILED_BASE_INTERVAL = 5
local _FAILED_MAX_INTERVAL = 120
local _SEPARATOR = "/"
local WATCH_NAMESPACE = 1
local WATCH_GLOBAL = 2
local _LOGGER = LoggerManager.getLogger("EtcdProcessor")

local function incrementLastByte(str)
	local len = string.len(str)
	local res = {}

	table.insert(res, string.sub(str, 1, -2))

	local lastByte = string.byte(str, -1, -1)

	table.insert(res, string.char(lastByte + 1))

	return table.concat(res)
end

local function generateKeyFromProcessInfo(processInfo)
	return string.format("%s%s%s%s%s%s%s", processInfo.namespace, _SEPARATOR, processInfo.processKind, _SEPARATOR, processInfo.processType, _SEPARATOR, processInfo.pid)
end

local function generatePrefixKeyFromProcessInfo(processInfo)
	return string.format("%s%s", processInfo.namespace, _SEPARATOR)
end

local function generateServiceFailedOpName(opType, serviceInfo)
	return string.format("%s:%s", opType, tostring(serviceInfo.pid))
end

local function getFailedRetryDelay(attempt)
	local exponent = math.min(attempt, 5)
	local maxInterval = math.min(_FAILED_MAX_INTERVAL, _FAILED_BASE_INTERVAL * 2^exponent)

	return math.random(_FAILED_BASE_INTERVAL * 1000, maxInterval * 1000) / 1000
end

function EtcdProcessor:ctor(etcdServers, namespace, processInfo, listener)
	self.etcdServers = {}
	self.etcdClients = {}
	self.etcdServerToClient = {}
	self.etcdClientToServer = {}
	self.usedClient = nil
	self.namespace = namespace
	self.processInfo = processInfo
	self.listener = listener
	self.pidToProcessInfo = {}
	self.lease = nil
	self.leaseKeepAliveTimer = nil
	self.status = INIT
	self.checkRegisterFinished = false
	self.checkRegisterTimeout = false
	self.checkRegisterTimer = nil
	self.checkRegisterDeadlineTimer = nil
	self.hasInitProcess = false
	self.waitRegisteServiceNum = 0
	self.etcdRevision = 0
	self.namespaceWatchValid = false
	self.namespaceWatchID = nil
	self.enableGlobalWatch = ServerSwitch.EnableEtcdGlobalWatch == true
	self.globalWatchValid = not self.enableGlobalWatch
	self.globalWatchID = nil
	self.enableMemberList = ServerSwitch.EnableEtcdMemberList == true
	self.memberListTimer = nil
	self.failedOpName2State = {}
	self.failedOpName2Context = {}
	self.destroyed = false
	self.needWatchAndMember = false

	local newServers = {}

	for _, v in ipairs(etcdServers) do
		newServers[v] = true
	end

	self:_adjustEtcdServers(newServers)
end

function EtcdProcessor:repr()
	return string.format("EtcdProcessor (%s %s)", self.namespace, tostring(self))
end

function EtcdProcessor:start()
	assert(self.status == INIT)
	self:_leaseGrant()

	self.status = LEASE_GRANT
end

function EtcdProcessor:destroy()
	if self.destroyed then
		return
	end

	self.destroyed = true

	if self.usedClient ~= nil then
		self:deleteProcessInfo()
		self.listener:deleteServices()
	else
		_LOGGER:warn("%s destroy without valid etcd client, skip delete process and service info", self:repr())
	end

	for _, client in ipairs(self.etcdClients) do
		client:destroy()
	end

	TimerManager.removeTimer(self.leaseKeepAliveTimer)

	self.leaseKeepAliveTimer = nil

	TimerManager.removeTimer(self.memberListTimer)

	self.memberListTimer = nil

	for _, state in pairs(self.failedOpName2State) do
		TimerManager.removeTimer(state.timer)
	end

	self.failedOpName2State = nil
	self.failedOpName2Context = nil

	if self.checkRegisterTimer then
		TimerManager.removeTimer(self.checkRegisterTimer)

		self.checkRegisterTimer = nil
	end

	if self.checkRegisterDeadlineTimer then
		TimerManager.removeTimer(self.checkRegisterDeadlineTimer)

		self.checkRegisterDeadlineTimer = nil
	end
end

function EtcdProcessor:getInitStatus()
	if self.destroyed then
		return false, "DESTROYED"
	end

	if self.lease == nil then
		return false, "WAIT_LEASE"
	end

	if not self.hasInitProcess then
		return false, "WAIT_PROCESS_REGISTER"
	end

	if self.waitRegisteServiceNum ~= 0 then
		return false, "WAIT_SERVICE_REGISTER", tostring(self.waitRegisteServiceNum)
	end

	if not self.namespaceWatchValid then
		return false, "WAIT_NAMESPACE_WATCH"
	end

	if self.enableGlobalWatch and not self.globalWatchValid then
		return false, "WAIT_GLOBAL_WATCH"
	end

	return true, "READY"
end

function EtcdProcessor:initFinished()
	local finished = self:getInitStatus()

	return finished
end

function EtcdProcessor:_leaseGrant()
	_LOGGER:info("%s lease grant", self:repr())

	local client = self:_getEtcdClient(false)

	local function callback(resp)
		self:_leaseGrantCallback(resp, client)
	end

	client:leaseGrant(callback, _TTL)
end

function EtcdProcessor:_leaseGrantCallback(resp, client)
	if resp.retCode ~= 0 then
		_LOGGER:error("%s lease grant callback err %s", self:repr(), resp.retMsg)

		if self:_adjustNormalClient(client) then
			self:_leaseGrant()
		end
	else
		self.lease = resp.lease

		_LOGGER:info("%s grant lease %s success", self:repr(), self.lease)

		local function callback()
			self:_leaseKeepAlive(true)
		end

		self.leaseKeepAliveTimer = TimerManager.addTimer(_TTL_ALIVE, callback)
		self.status = LEASE_KEEP_ALIVE

		local function registerCheck()
			if not GameServerRepo.isService then
				if self.checkRegisterTimer then
					TimerManager.removeTimer(self.checkRegisterTimer)

					self.checkRegisterTimer = nil
				end
			elseif self.checkRegisterTimeout or GameServerRepo.gateProxyManager:isAllGateRegisted() then
				if self.checkRegisterTimer then
					TimerManager.removeTimer(self.checkRegisterTimer)

					self.checkRegisterTimer = nil
				end
			else
				_LOGGER:debug("check register not finished")

				return
			end

			if self.checkRegisterFinished then
				return
			end

			self.checkRegisterFinished = true

			local function initProcessInfoCallback()
				self.hasInitProcess = true
			end

			self:refreshProcessInfo(initProcessInfoCallback)

			local function registerServiceCallback()
				if self.waitRegisteServiceNum > 0 then
					self.waitRegisteServiceNum = self.waitRegisteServiceNum - 1
				end
			end

			self.listener:refreshServices(registerServiceCallback)
		end

		self.checkRegisterTimer = TimerManager.addRepeatTimer(_CHECK_REGISTER_INTERVAL, registerCheck)

		local function registerCheckDeadline()
			if not self.checkRegisterFinished then
				self.checkRegisterTimeout = true

				_LOGGER:error("%s check register deadline timeout", self:repr())
			end

			if self.checkRegisterDeadlineTimer then
				TimerManager.removeTimer(self.checkRegisterDeadlineTimer)

				self.checkRegisterDeadlineTimer = nil
			end
		end

		self.checkRegisterDeadlineTimer = TimerManager.addTimer(_CHECK_REGISTER_DEADLINE, registerCheckDeadline)

		self:_watchAndUpdateMember()
	end
end

function EtcdProcessor:_watchAndUpdateMember()
	assert(self.needWatchAndMember == true)

	if self.needWatchAndMember == false then
		_LOGGER:error("%s _watchAndUpdateMember but got needWatch false", self:repr())

		return
	end

	self:_initWatch(WATCH_NAMESPACE)

	if self.enableGlobalWatch then
		self:_initWatch(WATCH_GLOBAL)
	end

	if self.enableMemberList then
		local function memberList()
			self:_memberList()
		end

		if self.memberListTimer then
			TimerManager.removeTimer(self.memberListTimer)
		end

		self.memberListTimer = TimerManager.addTimer(MEMBER_LIST_INTERVAL, memberList)
	end

	self.needWatchAndMember = false
end

function EtcdProcessor:_leaseKeepAlive(flag)
	assert(self.status == LEASE_KEEP_ALIVE)

	local client = self:_getEtcdClient(flag)

	local function callback(resp)
		self:_leaseKeepAliveCallback(resp, client)
	end

	client:leaseKeepAlive(callback, self.lease)
end

function EtcdProcessor:_leaseKeepAliveFailed(failedClient)
	if self:_adjustNormalClient(failedClient) then
		self:_leaseKeepAlive(false)
	end
end

function EtcdProcessor:_leaseKeepAliveCallback(resp, client)
	if resp.retCode ~= 0 then
		_LOGGER:error("%s lease %s keep alive failed reason %s", self:repr(), self.lease, resp.retMsg)
		self:_leaseKeepAliveFailed(client)
	elseif resp.lease ~= self.lease then
		_LOGGER:error("%s lease %s keep alive failed reason %s %s", self:repr(), self.lease, "got wrong alive lease id", resp.lease)
		self:_leaseKeepAliveFailed(client)
	else
		if resp.ttl == 0 then
			_LOGGER:error("%s lease %s keep alive failed lease is out of date", self:repr(), self.lease)
			self:_leaseReGrant(true)

			return
		end

		local function callback()
			self:_leaseKeepAlive(true)
		end

		self.leaseKeepAliveTimer = TimerManager.addTimer(_TTL_ALIVE, callback)

		if self.needWatchAndMember then
			_LOGGER:info("%s lease keep alive need reWatch", self:repr())
			self:_watchAndUpdateMember()
		end
	end
end

function EtcdProcessor:_leaseReGrant(flag)
	_LOGGER:info("%s lease re grant ", self:repr())

	local client = self:_getEtcdClient(flag)

	local function callback(resp)
		self:_leaseReGrantCallback(resp, client)
	end

	client:leaseGrant(callback, _TTL)
end

function EtcdProcessor:_leaseReGrantCallback(resp, client)
	if resp.retCode ~= 0 then
		_LOGGER:error("%s lease regrant callback err %s", self:repr(), resp.retMsg)

		if self:_adjustNormalClient(client) then
			self:_leaseReGrant(false)
		end
	else
		self.lease = resp.lease

		_LOGGER:info("%s regrant lease %s success", self:repr(), self.lease)

		local function callback()
			self:_leaseKeepAlive(true)
		end

		self.leaseKeepAliveTimer = TimerManager.addTimer(_TTL_ALIVE, callback)

		if self.needWatchAndMember then
			self:_watchAndUpdateMember()
		end

		self.listener:onLeaseChanged()
	end
end

function EtcdProcessor:_refreshProcessInfoCallback(resp, cb)
	if resp.retCode ~= 0 then
		_LOGGER:error("%s refresh process info failed %s", self:repr(), resp.retMsg)

		local function refresh()
			self:refreshProcessInfo(cb)
		end

		self:_addFailedOp("refreshProcessInfo", refresh, resp.retMsg)
	else
		self:_clearFailedOp("refreshProcessInfo")
		_LOGGER:info("%s refresh process info success", self:repr())

		if cb ~= nil then
			cb()
		end
	end
end

function EtcdProcessor:refreshProcessInfo(cb)
	local info = self.processInfo:dump()

	assert(type(info) == "string")

	if cb ~= nil then
		assert(type(cb) == "function")
	end

	local key = generateKeyFromProcessInfo(self.processInfo)

	_LOGGER:info("%s refresh process info [%s]", self:repr(), key)

	local client = self:_getEtcdClient(true)

	local function callback(resp)
		self:_refreshProcessInfoCallback(resp, cb)
	end

	client:kvPut(callback, key, info, self.lease)
end

function EtcdProcessor:refreshGlobalInfo(globalInfo, cb)
	local info = globalInfo:dump()

	assert(type(info) == "string")
	assert(type(cb) == "function")

	local key = generateKeyFromProcessInfo(globalInfo)

	_LOGGER:info("%s refresh global info [%s]", self:repr(), key)

	local client = self:_getEtcdClient(true)

	local function callback(resp)
		self:_refreshGlobalInfoCallback(resp, globalInfo, cb)
	end

	client:kvPut(callback, key, info, self.lease)
end

function EtcdProcessor:_refreshGlobalInfoCallback(resp, globalInfo, callback)
	if resp.retCode ~= 0 then
		_LOGGER:error("%s refresh global info failed", self:repr())

		local function refresh()
			self:refreshGlobalInfo(globalInfo, callback)
		end

		self:_addFailedOp("refreshGlobalInfo", refresh, resp.retMsg)
	else
		self:_clearFailedOp("refreshGlobalInfo")
		_LOGGER:info("%s refresh global info success", self:repr())

		if callback ~= nil then
			callback()
		end
	end
end

function EtcdProcessor:refreshServiceInfo(serviceInfo, cb, retryGeneration)
	local opName = generateServiceFailedOpName("refreshServiceInfo", serviceInfo)
	local generation = retryGeneration

	if generation == nil then
		generation = self:_beginFailedOpGeneration(opName)

		if cb ~= nil then
			assert(type(cb) == "function")
			self:_addFailedOpCallback(opName, cb)
		end
	elseif not self:_isCurrentFailedOpGeneration(opName, generation) then
		return
	end

	local info = serviceInfo:dump()

	assert(type(info) == "string")

	local key = generateKeyFromProcessInfo(serviceInfo)

	_LOGGER:info("%s refresh service info [%s]", self:repr(), key)

	local client = self:_getEtcdClient(true)

	local function callback(resp)
		self:_refreshServiceInfoCallback(resp, serviceInfo, opName, generation)
	end

	client:kvPut(callback, key, info, self.lease)
end

function EtcdProcessor:_refreshServiceInfoCallback(resp, serviceInfo, opName, generation)
	if not self:_isCurrentFailedOpGeneration(opName, generation) then
		_LOGGER:debug("%s ignore stale refresh service info callback %s generation %s", self:repr(), opName, tostring(generation))

		return
	end

	if resp.retCode ~= 0 then
		_LOGGER:error("%s refresh service info failed", self:repr())

		local function refresh()
			self:refreshServiceInfo(serviceInfo, nil, generation)
		end

		self:_addFailedOp(opName, refresh, resp.retMsg, generation)
	else
		self:_clearFailedOp(opName, generation)
		_LOGGER:info("%s refresh service info success", self:repr())
		self:_finishFailedOpCallbacks(opName)
	end
end

function EtcdProcessor:_initWatch(watchType)
	local key = ""

	if watchType == WATCH_NAMESPACE then
		self.namespaceWatchValid = false
		key = generatePrefixKeyFromProcessInfo(self.processInfo)
	elseif watchType == WATCH_GLOBAL then
		self.globalWatchValid = false
		key = ProcessInfo.GLOBAL_KEY
	else
		assert(0)
	end

	local client = self:_getEtcdClient(true)

	local function callback(resp)
		self:_initWatchCallback(resp, watchType)
	end

	client:kvRange(callback, key, true)
end

function EtcdProcessor:_initWatchCallback(resp, watchType)
	if resp.retCode ~= 0 and resp.retCode ~= 100 then
		_LOGGER:error("%s init watch %d info got error %s", self:repr(), watchType, resp.retMsg)

		local function initWatch()
			self:_initWatch(watchType)
		end

		self:_addFailedOp(string.format("initWatch%d", watchType), initWatch, resp.retMsg)
	else
		self.etcdRevision = resp.revision

		assert(self.etcdRevision ~= nil)

		if watchType == WATCH_NAMESPACE then
			assert(self.namespaceWatchID == nil)
		elseif watchType == WATCH_GLOBAL then
			assert(self.globalWatchID == nil)
		end

		local olds = self:_getProcessInfoBySource(watchType)
		local news = {}
		local sortedNews = {}

		for _, rangeInfo in ipairs(resp.values) do
			local processInfo = ProcessInfo.newProcessInfoFromRangeInfo(rangeInfo, watchType)

			news[processInfo.pid] = processInfo

			table.insert(sortedNews, processInfo)
		end

		for pid, processInfo in pairs(olds) do
			if news[pid] == nil then
				self:_removeProcessInfo(pid)
			end
		end

		local startVersion = 0

		for _, processInfo in ipairs(sortedNews) do
			assert(startVersion < processInfo.createVersion)

			startVersion = processInfo.createVersion

			self:_addProcessInfo(processInfo)
		end

		self:_startWatch(watchType)
	end
end

function EtcdProcessor:_startWatch(watchType)
	local key = ""

	if watchType == WATCH_NAMESPACE then
		key = generatePrefixKeyFromProcessInfo(self.processInfo)

		assert(self.namespaceWatchID == nil)
	elseif watchType == WATCH_GLOBAL then
		key = ProcessInfo.GLOBAL_KEY

		assert(self.globalWatchID == nil)
	else
		assert(0)
	end

	local client = self:_getEtcdClient(true)

	local function callback(resp)
		self:_startWatchCallback(resp, watchType, client)
	end

	if watchType == WATCH_NAMESPACE then
		self.namespaceWatchID = client:addWatch(callback, key, true, self.etcdRevision + 1)
	elseif watchType == WATCH_GLOBAL then
		self.globalWatchID = client:addWatch(callback, key, true, self.etcdRevision + 1)
	end
end

function EtcdProcessor:_startWatchCallback(resp, watchType, client)
	if resp.retCode ~= 0 then
		_LOGGER:error("%s start %d watch failed %s", self:repr(), watchType, resp.retMsg)

		if watchType == WATCH_NAMESPACE then
			client:cancelWatch(self.namespaceWatchID)

			self.namespaceWatchID = nil
		elseif watchType == WATCH_GLOBAL then
			client:cancelWatch(self.globalWatchID)

			self.globalWatchID = nil
		end

		local function initWatch()
			self:_initWatch(watchType)
		end

		self:_addFailedOp(string.format("initWatch%d", watchType), initWatch, resp.retMsg)
	else
		self:_clearFailedOp(string.format("initWatch%d", watchType))
		_LOGGER:info("%s watch %d got info changed", self:repr(), watchType)

		local maxRevision = self.etcdRevision

		if watchType == WATCH_NAMESPACE then
			self.namespaceWatchValid = true
		elseif watchType == WATCH_GLOBAL then
			self.globalWatchValid = true
		end

		for i, event in ipairs(resp.events) do
			if maxRevision < event[5] then
				maxRevision = event[5]
			end

			if event[1] == 1 then
				local namespace, processKind, processType, pid = ProcessInfo.parseKey(event[2])

				self:_removeProcessInfo(pid)
			else
				local processInfo = ProcessInfo.newProcessInfoFromEvent(event, watchType)

				self:_addProcessInfo(processInfo)
			end
		end

		self.etcdRevision = maxRevision
	end
end

function EtcdProcessor:_memberList()
	local client = self:_getEtcdClient(true)

	local function callback(resp)
		self:_memberListCallback(resp)
	end

	client:memberList(callback)
end

function EtcdProcessor:_memberListCallback(resp)
	if resp.retCode ~= 0 then
		_LOGGER:error("%s member list failed %s", self:repr(), resp.retMsg)

		local function memberList()
			self:_memberList()
		end

		self:_addFailedOp("memberList", memberList, resp.retMsg)
	else
		self:_clearFailedOp("memberList")

		local etcdServers = {}

		for _, member in ipairs(resp.members) do
			for _, clienturl in ipairs(member) do
				etcdServers[clienturl] = true
			end
		end

		if self:_adjustEtcdServers(etcdServers) then
			_LOGGER:info("%s member list got used client failed, enter lease keep alive process", self:repr())
			self:_leaseKeepAlive(false)
			self.listener:onLeaseChanged()
		elseif self.enableMemberList then
			local function memberList()
				self:_memberList()
			end

			self.memberListTimer = TimerManager.addTimer(MEMBER_LIST_INTERVAL, memberList)
		end
	end
end

function EtcdProcessor:_adjustNormalClient(failedClient)
	if self.destroyed then
		return false
	end

	_LOGGER:info("%s adjustNormalClient %s ", self:repr(), tostring(failedClient))

	local index = 0

	for i, v in ipairs(self.etcdClients) do
		if v == failedClient then
			index = i

			break
		end
	end

	if index == 0 then
		_LOGGER:warn("%s adjustNormalClient  %s but got index 0", self:repr(), tostring(failedClient))
	else
		table.remove(self.etcdClients, index)

		local server = self.etcdClientToServer[failedClient]

		assert(server ~= nil)

		self.etcdServerToClient[server] = nil
		self.etcdClientToServer[failedClient] = nil

		_LOGGER:error("%s disconnect with etcd server %s", self:repr(), server)
		failedClient:destroy()

		if failedClient == self.usedClient then
			self.usedClient = nil

			if self.memberListTimer then
				TimerManager.removeTimer(self.memberListTimer)

				self.memberListTimer = nil
			end

			if self.leaseKeepAliveTimer then
				TimerManager.removeTimer(self.leaseKeepAliveTimer)

				self.leaseKeepAliveTimer = nil
			end

			for _, state in pairs(self.failedOpName2State) do
				TimerManager.removeTimer(state.timer)
			end

			self.failedOpName2State = {}
		end
	end

	if #self.etcdClients == 0 then
		_LOGGER:error("%s got all client broken ", self:repr())
		self:destroy()
		self.listener:onDisconnectWithEtcd()

		return false
	end

	return true
end

function EtcdProcessor:_adjustEtcdServers(servers)
	local newServers = {}
	local delServers = {}
	local updateServers = {}
	local isChangeUsedClient = false

	for server, _ in pairs(servers) do
		if self.etcdServers[server] == nil then
			table.insert(newServers, server)
		else
			table.insert(updateServers, server)
		end
	end

	for server, _ in pairs(self.etcdServers) do
		if servers[server] == nil then
			table.insert(delServers, server)
		end
	end

	for _, server in ipairs(newServers) do
		assert(self.etcdServerToClient[server] == nil)
		self:_initEtcdClient(server)
	end

	for _, server in ipairs(delServers) do
		local client = self.etcdServerToClient[server]

		if client ~= nil then
			if client == self.usedClient then
				isChangeUsedClient = true
			end

			self:_adjustNormalClient(client)
		end
	end

	for _, server in ipairs(updateServers) do
		local client = self.etcdServerToClient[server]

		if client == nil then
			self:_initEtcdClient(server)
		end
	end

	self.etcdServers = servers

	return isChangeUsedClient
end

function EtcdProcessor:_beginFailedOpGeneration(name)
	local context = self.failedOpName2Context[name]

	if context == nil then
		context = {
			generation = 0,
			callbacks = {}
		}
		self.failedOpName2Context[name] = context
	end

	context.generation = context.generation + 1

	self:_clearFailedOp(name)

	return context.generation
end

function EtcdProcessor:_addFailedOpCallback(name, callback)
	table.insert(self.failedOpName2Context[name].callbacks, callback)
end

function EtcdProcessor:_finishFailedOpCallbacks(name)
	if self.failedOpName2Context == nil then
		return
	end

	local context = self.failedOpName2Context[name]

	if context == nil then
		return
	end

	local callbacks = context.callbacks

	context.callbacks = {}

	for _, callback in ipairs(callbacks) do
		callback()
	end
end

function EtcdProcessor:_isCurrentFailedOpGeneration(name, generation)
	local context = self.failedOpName2Context and self.failedOpName2Context[name]

	return context ~= nil and context.generation == generation
end

function EtcdProcessor:_addFailedOp(name, func, failedReason, generation)
	if self.destroyed then
		return
	end

	if generation ~= nil and not self:_isCurrentFailedOpGeneration(name, generation) then
		_LOGGER:debug("%s ignore stale failed op %s generation %s", self:repr(), name, tostring(generation))

		return
	end

	_LOGGER:info("%s add failed op %s", self:repr(), name)

	if failedReason == EtcdClient.ETCD_CLIENT_DESTROYED_MSG then
		_LOGGER:info("%s got op %s canceld , no need to retry", self:repr(), name)
		self:_clearFailedOp(name, generation)

		return
	end

	local client = self:_getEtcdClient(true)

	if client == nil then
		_LOGGER:error("%s add failed op %s, but has no etcd client", self:repr(), name)

		return
	end

	local state = self.failedOpName2State[name]

	if state == nil then
		state = {
			attempt = 0
		}
		self.failedOpName2State[name] = state
	elseif state.timer ~= nil then
		_LOGGER:info("%s add failed op, but already exists, cancel old one %s", self:repr(), name)
		TimerManager.removeTimer(state.timer)
	end

	state.attempt = state.attempt + 1

	local delay = getFailedRetryDelay(state.attempt)
	local timer

	local function retry()
		if self.destroyed then
			return
		end

		local currentState = self.failedOpName2State[name]

		if currentState ~= state or currentState.timer ~= timer then
			return
		end

		currentState.timer = nil

		func()
	end

	timer = TimerManager.addTimer(delay, retry)
	state.timer = timer

	_LOGGER:info("%s retry failed op %s attempt %d after %.3fs", self:repr(), name, state.attempt, delay)
end

function EtcdProcessor:_clearFailedOp(name, generation)
	if self.failedOpName2State == nil then
		return
	end

	if generation ~= nil and not self:_isCurrentFailedOpGeneration(name, generation) then
		return
	end

	local state = self.failedOpName2State[name]

	if state == nil then
		return
	end

	TimerManager.removeTimer(state.timer)

	self.failedOpName2State[name] = nil
end

function EtcdProcessor:_initEtcdClient(server)
	_LOGGER:info("%s init etcd client for %s", self:repr(), server)

	local client = EtcdClient(server)

	table.insert(self.etcdClients, client)

	self.etcdServerToClient[server] = client
	self.etcdClientToServer[client] = server
end

function EtcdProcessor:_getEtcdClient(hasUsedClientDebugFlag)
	assert(hasUsedClientDebugFlag and self.usedClient ~= nil or not hasUsedClientDebugFlag and self.usedClient == nil)

	if self.usedClient ~= nil then
		return self.usedClient
	end

	local len = #self.etcdClients

	if len == 0 then
		return nil
	end

	self.usedClient = self.etcdClients[math.random(len)]
	self.needWatchAndMember = true

	return self.usedClient
end

function EtcdProcessor:_getProcessInfoBySource(source)
	local rets = {}

	for k, v in pairs(self.pidToProcessInfo) do
		if v.source == source then
			rets[k] = v
		end
	end

	return rets
end

function EtcdProcessor:_addProcessInfo(processInfo)
	local pid = processInfo.pid

	if self.pidToProcessInfo[pid] == nil then
		_LOGGER:info("%s add process (%s,%s,%s) ", self:repr(), processInfo.pid, processInfo.processType, processInfo.createVersion)

		self.pidToProcessInfo[pid] = processInfo

		self.listener:onAddProcess(processInfo)
	else
		_LOGGER:info("%s update process (%s,%s, %s) ", self:repr(), processInfo.pid, processInfo.processType, processInfo.createVersion)
		self.listener:onUpdateProcess(processInfo)
	end
end

function EtcdProcessor:_removeProcessInfo(pid)
	if self.pidToProcessInfo[pid] == nil then
		_LOGGER:error("%s removeProcessInfo %s , but not exist", self:repr(), pid)

		return
	end

	_LOGGER:info("%s remove process (%s) ", self:repr(), pid)

	self.pidToProcessInfo[pid] = nil

	self.listener:onRemoveProcess(pid)
end

function EtcdProcessor:_deleteProcessInfoCallback(resp, cb)
	if resp.retCode ~= 0 then
		_LOGGER:error("%s delete process info failed %s", self:repr(), resp.retMsg)

		local function redelete()
			self:deleteProcessInfo(cb)
		end

		self:_addFailedOp("deleteProcessInfo", redelete, resp.retMsg)
	else
		self:_clearFailedOp("deleteProcessInfo")
		_LOGGER:info("%s delete process info success", self:repr())

		if cb ~= nil then
			cb()
		end
	end
end

function EtcdProcessor:deleteProcessInfo(cb)
	local key = generateKeyFromProcessInfo(self.processInfo)

	_LOGGER:info("%s delete process info [%s]", self:repr(), key)

	local client = self:_getEtcdClient(true)

	local function callback(resp)
		self:_deleteProcessInfoCallback(resp, cb)
	end

	client:kvDelete(callback, key)
end

function EtcdProcessor:_deleteServiceInfoCallback(resp, serviceInfo, opName, generation)
	if not self:_isCurrentFailedOpGeneration(opName, generation) then
		_LOGGER:debug("%s ignore stale delete service info callback %s generation %s", self:repr(), opName, tostring(generation))

		return
	end

	if resp.retCode ~= 0 then
		_LOGGER:error("%s delete service info failed %s", self:repr(), resp.retMsg)

		local function redelete()
			self:deleteServiceInfo(serviceInfo, nil, generation)
		end

		self:_addFailedOp(opName, redelete, resp.retMsg, generation)
	else
		self:_clearFailedOp(opName, generation)
		_LOGGER:info("%s delete service info success", self:repr())
		self:_finishFailedOpCallbacks(opName)
	end
end

function EtcdProcessor:deleteServiceInfo(serviceInfo, cb, retryGeneration)
	local opName = generateServiceFailedOpName("deleteServiceInfo", serviceInfo)
	local generation = retryGeneration

	if generation == nil then
		generation = self:_beginFailedOpGeneration(opName)

		if cb ~= nil then
			assert(type(cb) == "function")
			self:_addFailedOpCallback(opName, cb)
		end
	elseif not self:_isCurrentFailedOpGeneration(opName, generation) then
		return
	end

	local key = generateKeyFromProcessInfo(serviceInfo)

	_LOGGER:info("%s delete service info [%s]", self:repr(), key)

	local client = self:_getEtcdClient(true)

	local function callback(resp)
		self:_deleteServiceInfoCallback(resp, serviceInfo, opName, generation)
	end

	client:kvDelete(callback, key)
end

return EtcdProcessor
