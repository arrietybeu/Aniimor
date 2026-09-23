-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Client\\ClientEntity.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local Entity = require("Core.Common.Entity")
local EntityManager = require("Core.Common.EntityManager")
local ClientRepo = require("Core.Client.ClientRepo")
local ClientRealPropertyComponent = require("Core.PropertySync.ClientRealPropertyComponent")
local CommonSwitch = require("Common.CommonSwitch")
local Const = require("Core.Common.Const")
local Time = require("Core.Common.Time")
local ClientEntity = class.Class("ClientEntity", Entity)
local ClientEntityComponents = {
	ClientRealPropertyComponent
}

class.AddComponents(ClientEntity, ClientEntityComponents)

function ClientEntity:ctor(entityId)
	ClientEntity.super.ctor(self, entityId)

	self.server = nil
	self.isInited = false
	self.csChannel = nil
	self.rid = 0
	self.callbacks = {}
	self.isClientEnt = true
end

function ClientEntity:init(dict)
	ClientEntity.super.init(self, dict)

	self.isInited = true

	self:recordMapMarkStaticInitId(dict)

	return true
end

function ClientEntity:recordMapMarkStaticInitId(dict)
	if dict.sceneId and dict.__Properties__ and dict.__Properties__.staticId then
		local staticId = dict.__Properties__.staticId
		local markInfo = pg.game.map:getSceneMarkInfoByMarkId(dict.sceneId, staticId)

		if markInfo then
			pg.game.map.entityStaticIdInitRecord[staticId] = true
			self.markBindStaticId = staticId
		end
	end
end

function ClientEntity:setServer(server)
	self.server = server

	server:setOwner(self)

	if self.csChannel ~= nil then
		self.server:attachChannel(self.csChannel)
	end
end

function ClientEntity:onBecomePlayer()
	return
end

function ClientEntity:onLoseServer()
	if self.csChannel ~= nil then
		self.server:detachChannel()
	end

	self.server = nil
end

function ClientEntity:isServerLost()
	return self.server == nil
end

function ClientEntity:destroy()
	if self.server ~= nil then
		self.server:setOwner(nil)

		self.server = nil
	end

	if self.csChannel ~= nil then
		self.csChannel:destroy()

		self.csChannel = nil
	end

	if self.markBindStaticId then
		pg.game.map.entityStaticIdInitRecord[self.markBindStaticId] = nil
		self.markBindStaticId = nil
	end

	ClientEntity.super.destroy(self)
end

function ClientEntity:repr()
	return string.format("clientEntity (%s, %s)", self:getClassType(), self.id)
end

function ClientEntity:serverMsg(name, ...)
	local nargs = select("#", ...)
	local argCount = nargs
	local callback

	if nargs > 0 then
		callback = select(nargs, ...)

		if type(callback) ~= "function" then
			callback = nil
		else
			argCount = argCount - 1
		end
	end

	if _G_IsDebugMode then
		local RpcDebugHelper = require("Utils.RpcDebugHelper")

		RpcDebugHelper.sendMsg(self.className, self.id, name, ...)
	end

	if self.server == nil then
		if self ~= pg.me then
			assert(callback == nil, "call other entity callback must nil")

			if EnableBotTest then
				pg.me:serverMsg("RPC_CS_OtherEntityMethod_Bot", self.id, name, {
					...
				})
			else
				pg.me:serverMsg("RPC_CS_OtherEntityMethod", self.id, name, {
					...
				})
			end

			return
		end

		if not FREE_WALK and LoggerManager.checkLogger(LoggerConst.WARN) then
			self.logger:warn("%s call serverMsg %s, but server lost", self:repr(), name)
		end

		return
	end

	if callback ~= nil then
		return self:_serverMsgWithCallback(callback, name, unpack({
			...
		}, 1, argCount))
	end

	self.server:serverMsg(name, ...)
end

function ClientEntity:getRealOwner(ownerId)
	local owner = EntityManager.getEntity(ownerId)

	if owner == nil and LoggerManager.checkLogger(LoggerConst.WARN) then
		self.logger:warn("getRealOwner %s not found", ownerId)
	end

	return owner
end

function ClientEntity:getClusterMsProxy()
	return self.server
end

function ClientEntity:genNextCallbackId()
	self.rid = self.rid + 1

	if self.rid >= 4294967295 then
		self.rid = 1
	end

	return self.rid
end

function ClientEntity:_serverMsgWithCallback(callback, name, ...)
	local rid = self:genNextCallbackId()

	self.callbacks[rid] = callback

	self.server:serverMsgWithCallback(rid, name, ...)

	return rid
end

function ClientEntity:RPC_SC_OnServerMsgCallabck(callbackId, parameters)
	local callback = self.callbacks[callbackId]

	if callback ~= nil then
		self.callbacks[callbackId] = nil

		callback(unpack(parameters))
	elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
		self.logger:error("%s RPC_SC_OnServerMsgCallabck with unknown callbackId %s", self:repr(), callbackId)
	end
end

function ClientEntity:addCallback(callback)
	local rid = self:genNextCallbackId()

	self.callbacks[rid] = callback

	return rid
end

function ClientEntity:delCallback(callbackId)
	self.callbacks[callbackId] = nil
end

function ClientEntity:clearCallbacks()
	self.callbacks = {}
end

function ClientEntity:getConfigData()
	return {}
end

return ClientEntity
