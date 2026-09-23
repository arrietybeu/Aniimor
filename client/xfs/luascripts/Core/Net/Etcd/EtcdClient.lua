-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Net\\Etcd\\EtcdClient.lua

local phonestcore = require("phonestcore")
local class = require("Core.Framework.Class")
local IDManager = require("Core.Common.IDManager")
local CallbackManager = require("Core.Net.CallbackManager")
local EtcdClient = class.Class("EtcdClient")

EtcdClient.ETCD_CLIENT_DESTROYED_MSG = "clientDestroyed"

function EtcdClient:ctor(url)
	self.cobj = phonestcore.newEtcdClient(url)

	assert(self.cobj ~= nil)

	self.watchID2callbackID = {}
	self.callbackIDMap = {}
end

function EtcdClient:destroy()
	assert(self.cobj ~= nil)

	local resp = {
		retCode = 1,
		retMsg = EtcdClient.ETCD_CLIENT_DESTROYED_MSG
	}

	for id, _ in pairs(self.callbackIDMap) do
		CallbackManagerHandler(id, resp)
		CallbackManager.unRegisterHandler(id)
	end

	self.callbackIDMap = {}

	self.cobj:destroyEtcdClient()

	self.cobj = nil
	self.watchID2callbackID = {}
end

local PUT_TIMEOUT = 5000

function EtcdClient:kvPut(callback, key, value, leaseID)
	assert(type(key) == "string")
	assert(type(value) == "string")
	assert(type(leaseID) == "string")
	assert(type(callback) == "function")
	assert(self.cobj ~= nil)

	local callbackID = self:_generateCallbackID(callback)

	self.cobj:put(callbackID, key, value, leaseID, PUT_TIMEOUT)
end

local RANGE_TIMEOUT = 5000

function EtcdClient:kvRange(callback, key, recursive)
	assert(type(key) == "string")
	assert(type(recursive) == "boolean")
	assert(type(callback) == "function")
	assert(self.cobj ~= nil)

	local callbackID = self:_generateCallbackID(callback)

	self.cobj:range(callbackID, key, recursive, RANGE_TIMEOUT)
end

local DELETE_TIMEOUT = 5000

function EtcdClient:kvDelete(callback, key)
	assert(type(key) == "string")
	assert(type(callback) == "function")
	assert(self.cobj ~= nil)

	local callbackID = self:_generateCallbackID(callback)

	self.cobj:del(callbackID, key, DELETE_TIMEOUT)
end

local WATCH_TIMEOUT = 5000

function EtcdClient:addWatch(callback, key, recursive, fromIndex)
	local watchID = IDManager.genB64ID()

	assert(type(key) == "string")
	assert(type(recursive) == "boolean")
	assert(type(callback) == "function")
	assert(self.cobj ~= nil)

	if fromIndex ~= nil then
		assert(type(fromIndex) == "number")
	else
		fromIndex = 0
	end

	local callbackID = self:_generateCallbackID(callback, true)

	self.watchID2callbackID[watchID] = callbackID

	self.cobj:addWatch(watchID, callbackID, key, recursive, fromIndex, WATCH_TIMEOUT)

	return watchID
end

function EtcdClient:cancelWatch(watchID)
	assert(type(watchID) == "string")
	assert(self.cobj ~= nil)

	local callbackID = self.watchID2callbackID[watchID]

	assert(callbackID ~= nil)
	CallbackManager.unRegisterHandler(callbackID)

	self.watchID2callbackID[watchID] = nil

	self.cobj:cancelWatch(watchID)
end

local LEASE_GRANT_TIMEOUT = 5000

function EtcdClient:leaseGrant(callback, ttl)
	assert(type(callback) == "function")
	assert(type(ttl) == "number")
	assert(self.cobj ~= nil)

	local callbackID = self:_generateCallbackID(callback)

	self.cobj:leaseGrant(callbackID, ttl, LEASE_GRANT_TIMEOUT)
end

local LEASE_ALIVE_TIMEOUT = 5000

function EtcdClient:leaseKeepAlive(callback, id)
	assert(type(id) == "string")
	assert(type(callback) == "function")
	assert(self.cobj ~= nil)

	local callbackID = self:_generateCallbackID(callback)

	self.cobj:leaseKeepAlive(callbackID, id, LEASE_ALIVE_TIMEOUT)
end

function EtcdClient:_generateCallbackID(callback, repeated)
	local id = IDManager.genB64ID()

	local function realCallback(...)
		if repeated == nil then
			CallbackManager.unRegisterHandler(id)

			self.callbackIDMap[id] = nil
		end

		callback(...)
	end

	CallbackManager.registerHandler(id, realCallback)

	self.callbackIDMap[id] = true

	return id
end

local MEMBER_LIST_TIMEOUT = 5000

function EtcdClient:memberList(callback)
	assert(type(callback) == "function")
	assert(self.cobj ~= nil)

	local callbackID = self:_generateCallbackID(callback)

	self.cobj:memberList(callbackID, MEMBER_LIST_TIMEOUT)
end

return EtcdClient
