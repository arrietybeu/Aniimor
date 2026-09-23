-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Common\\RpcSendValidator.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local CommonSwitch = require("Common.CommonSwitch")
local RpcArgValidator = require("Core.Common.RpcArgValidator")
local logger = LoggerManager.getLogger("RpcSendValidator")
local RpcSendValidator = {}
local registry = {}
local inited = false
local SEND_BUILD_OPTS = {
	allowUnknownField = false,
	checkRequired = true,
	deepCustom = true
}

function RpcSendValidator.init()
	local ok, argDict = pcall(require, "Config.RpcCSArgDict")

	if not ok then
		return
	end

	for rpcName, argTypes in pairs(argDict) do
		local validators = {}

		for i, argType in ipairs(argTypes) do
			validators[i] = RpcArgValidator.buildValidator(rpcName, argType, SEND_BUILD_OPTS)
		end

		registry[rpcName] = {
			validators = validators,
			argNum = #validators,
			argTypes = argTypes
		}
	end

	inited = true
end

function RpcSendValidator.validate(rpcName, ...)
	if not inited or not CommonSwitch.RpcSendValidate then
		return true
	end

	local entry = registry[rpcName]

	if not entry then
		return true
	end

	local num = select("#", ...)

	if num ~= entry.argNum then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("[SendValidate] %s expect %d args, got %d", rpcName, entry.argNum, num)
		end

		return false
	end

	local validators = entry.validators
	local argTypes = entry.argTypes

	for i = 1, num do
		local arg = select(i, ...)
		local ok, errMsg = validators[i](arg, string.format("%s arg#%d", rpcName, i))

		if not ok then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("[SendValidate] %s arg#%d (%s): %s", rpcName, i, argTypes[i], errMsg)
			end

			return false
		end
	end

	return true
end

function RpcSendValidator.validateArgs(rpcName, argsTable, argCount)
	if not inited or not CommonSwitch.RpcSendValidate then
		return true
	end

	local entry = registry[rpcName]

	if not entry then
		return true
	end

	argCount = argCount or #argsTable

	if argCount ~= entry.argNum then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("[SendValidate] %s expect %d args, got %d", rpcName, entry.argNum, argCount)
		end

		return false
	end

	local validators = entry.validators
	local argTypes = entry.argTypes

	for i = 1, argCount do
		local ok, errMsg = validators[i](argsTable[i], string.format("%s arg#%d", rpcName, i))

		if not ok then
			if LoggerManager.checkLogger(LoggerConst.ERROR) then
				logger:error("[SendValidate] %s arg#%d (%s): %s", rpcName, i, argTypes[i], errMsg)
			end

			return false
		end
	end

	return true
end

return RpcSendValidator
