-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Agent\\AgentMeta.lua

local _M = {
	_behaviorTreeFolder = "./lua/data/",
	_agentMetas = {},
	_agentInstances = {},
	_agentEnums = {},
	_agentPaths = {},
	_agentPool = {}
}
local AGENT_PATH = "Common.AI.BehaviacAgent.%s"
local enums = require("Common.AI.Behaviac.Enums")
local macros = require("Common.AI.Behaviac.Macros")
local constCharByte = enums.constCharByte
local lib_loader = require("Common.AI.Behaviac.Parser.loader")
local metaData = require("Common.Data.BehaviacData.Meta.MetaData")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("AgentMeta")
local BehaviorPathMapData = require("Common.Data.BehaviacData.Meta.BehaviorPathMapData")
local BaseEnum = require("Common.Data.BehaviacData.BaseEnum.BaseEnum")

_M.OpenAgentPoolSetting = true

function _M.registerMeta(metaClassName, meta)
	if not _M._agentMetas[metaClassName] then
		_M._agentMetas[metaClassName] = meta
	end
end

function _M.getMeta(metaClassName)
	return _M._agentMetas[metaClassName]
end

function _M.registerInstance(instanceName, instance)
	_M._agentInstances[instanceName] = instance
end

function _M.unRegisterInstance(instanceName)
	_M._agentInstances[instanceName] = nil
end

function _M.clearInstance()
	_M._agentInstances = {}

	_M.clearPool()
end

function _M.clearPool()
	_M._agentPool = {}
end

function _M.getAgentPath(typeName)
	if _M._agentPaths[typeName] then
		return _M._agentPaths[typeName]
	end

	local agentPath = string.format(AGENT_PATH, typeName)

	_M._agentPaths[typeName] = agentPath

	return agentPath
end

function _M.getInstance(instanceName, className, ...)
	local instance = _M._agentInstances[instanceName]

	if not instance and className then
		local pool = _M._agentPool[className]

		if _M.OpenAgentPoolSetting and pool and #pool > 0 then
			instance = pool[#pool]
			pool[#pool] = nil
		else
			local tmpAgentClass = require(_M.getAgentPath(className))

			instance = tmpAgentClass.new(...)
		end

		instance:init(...)
	end

	return instance
end

function _M.releaseInstance(className, instance)
	if not className or not instance then
		return
	end

	instance:release()

	if not _M.OpenAgentPoolSetting then
		return
	end

	local pool = _M._agentPool[className]

	if not pool then
		pool = {}
		_M._agentPool[className] = pool
	end

	pool[#pool + 1] = instance
end

function _M.getAgent(agentName, className, ...)
	return _M.getInstance(agentName, className, ...)
end

function _M.registerEnumType(enumTypeName, enumType)
	_M._agentEnums[enumTypeName] = enumType
end

function _M.getEnum(enumTypeName, enumName)
	local enumType = BaseEnum[enumTypeName] or _M._agentEnums[enumTypeName]

	if not enumType then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			logger:warn(enumTypeName .. " error: enum meta not found!!!")
		end
	elseif not enumType[enumName] and LoggerManager.checkLogger(LoggerConst.WARN) then
		logger:warn(enumTypeName .. "." .. enumName .. " error: enum name not found!!!")
	end

	return enumType and enumType[enumName] or 0
end

function _M.setBehaviorTreeFolder(folderName)
	if string.byte(folderName, -1, -1) ~= constCharByte.Slash then
		folderName = folderName .. string.char(constCharByte.Slash)
	end

	_M._behaviorTreeFolder = folderName
end

function _M.getBehaviorTreePath(treeName)
	local path = BehaviorPathMapData.PathMap[treeName]

	if not path and LoggerManager.checkLogger(LoggerConst.WARN) then
		logger:warn("getBehaviorTreePath error: ", treeName, " not found!!!")
	end

	return path
end

function _M.loadLuaMeta()
	for _, v in ipairs(metaData) do
		local typeName = v.type

		_M.registerMeta(typeName, v)
	end
end

function _M.switchToDebugMode(debug)
	for className, v in pairs(_M._agentMetas) do
		local agentPath = _M.getAgentPath(className)
		local realClass = require(agentPath)

		realClass:switchToDebugMode(debug)
	end
end

return _M
