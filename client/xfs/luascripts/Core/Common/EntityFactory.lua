-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Common\\EntityFactory.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local lfs = require("lfs")
local RpcMethod = require("Core.Common.RpcMethod")
local Const = require("Core.Common.Const")
local RpcArgValidator = require("Core.Common.RpcArgValidator")
local RpcIndex = require("Core.Common.RpcIndex")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("EntityFactory")
local EntityFactory = {
	_entities = {},
	_entityNameToRpcMethods = {}
}

function EntityFactory.hasClass(name)
	return EntityFactory._entities[name] ~= nil
end

function EntityFactory.getEntity(name)
	return EntityFactory._entities[name]
end

function EntityFactory.isRpcMethod(entityName, rpcName)
	local rpcMethods = EntityFactory._entityNameToRpcMethods[entityName]

	if rpcMethods == nil then
		return false
	end

	return rpcMethods[rpcName] ~= nil
end

function EntityFactory._recordRpcMethod(entityName, rpcName)
	EntityFactory._entityNameToRpcMethods[entityName][rpcName] = true
end

function EntityFactory._registerEntity(name, entity)
	EntityFactory._entities[name] = entity
end

function EntityFactory.createEntity(name, entityId)
	if EntityFactory._entities[name] == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("createEntity failed: can not find entity class %s", name)
		end

		return nil
	end

	return EntityFactory._entities[name](entityId)
end

function EntityFactory.parseEntity(config)
	local entitiesData = config.Entities or {}

	for k, v in pairs(entitiesData) do
		EntityFactory._parseClass(k, v, true)
	end
end

local CustomTypesComponentString = "CustomTypesServerMethods"

function EntityFactory.parseCustomTypesComponent(config)
	local componentsData = config.Components or {}

	for k, v in pairs(componentsData) do
		if v.NameSpace:find(CustomTypesComponentString) then
			EntityFactory._parseClass(k, v, false)
		end
	end
end

function EntityFactory.parseComponent(config)
	local componentsData = config.Components or {}

	for k, v in pairs(componentsData) do
		if not v.NameSpace:find(CustomTypesComponentString) then
			EntityFactory._parseClass(k, v, false)
		end
	end
end

function EntityFactory.parseUniversal(config)
	local universalsData = config.Universal or {}

	for k, v in pairs(universalsData) do
		EntityFactory._parseClass(k, v, false)
	end
end

function EntityFactory._parseClass(name, data, isEntity)
	if name == nil or type(name) ~= "string" then
		error("Entitites config get invalid name")
	end

	if EntityFactory.hasClass(name) then
		error("Entitites config get repeat entity " .. name)
	end

	local namespace = data.NameSpace

	if namespace == nil then
		error("Entitites config for " .. name .. " get invalid namespace nil")
	end

	local cls = require(namespace)

	cls.__CLASS_NAME__ = name
	EntityFactory._entityNameToRpcMethods[name] = {}

	EntityFactory._parseMethod(cls, data, Const.ACCESSOR_CLIENT, isEntity)
	EntityFactory._parseMethod(cls, data, Const.ACCESSOR_SERVER, isEntity)
	EntityFactory._parseMethod(cls, data, Const.ACCESSOR_CHANNEL, isEntity)
	EntityFactory._parseMethod(cls, data, Const.ACCESSOR_ENGINE, isEntity)

	if isEntity == true then
		EntityFactory._registerEntity(name, cls)
	end

	if cls.__IsParseReady == false then
		cls.__IsParseReady = true
	end
end

function EntityFactory._parseMethod(cls, data, methodType, isEntity)
	local methodTypeStr = Const.ACCESSOR_INT_TO_STRING[methodType]
	local methods = data[methodTypeStr] or {}
	local name = cls.__CLASS_NAME__

	for k, v in pairs(methods) do
		local func = cls[k]

		if func == nil then
			error("entity " .. cls.__CLASS_NAME__ .. " has no function " .. k)
		end

		if type(func) ~= "function" then
			error("entity " .. cls.__CLASS_NAME__ .. " has wrong type " .. k)
		end

		for i = 1, #v do
			v[i] = RpcArgValidator.parseArgConfig(k, v[i])
		end

		local originKey = "_Rpc_" .. k

		cls[originKey] = func

		EntityFactory._recordRpcMethod(name, k)
		RpcIndex.registerRpc(k)
		cls:forceAttrRepeat(k)

		cls[k] = RpcMethod(methodType, v, k, cls, originKey, data.Switch)

		cls:clearAttrRepeat()
	end
end

return EntityFactory
