-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\HomeCampDirectoryCaller.lua

local CommonSwitch = require("Common.CommonSwitch")
local CallbackHandler = require("Core.Common.CallbackHandler")
local HomeCampDirectoryCaller = {}
local METHODS = {
	CMD_GetRecommendCampLines = {
		"getRecommendCampLines",
		true,
		legacyMethod = "CMD_GetCampListN",
		legacyArgs = function(args)
			return {
				args[1],
				args[2],
				args[4],
				args[3]
			}
		end
	},
	CMD_FindCampByCode = {
		"findCampByCode",
		true
	},
	CMD_QueryCampLines = {
		"queryCampLines",
		true
	},
	CMD_GetLinesByIds = {
		"getLinesByIds",
		true
	},
	CMD_GetLinesBySpaceKeys = {
		"getLinesBySpaceKeys",
		true,
		legacyMethod = "CMD_GetCampListByIds"
	},
	CMD_GetLineRoute = {
		"getLineRoute"
	},
	CMD_SelectJoinBucket = {
		"selectJoinBucket"
	},
	CMD_SelectRandomJoinLine = {
		"selectRandomJoinLine"
	},
	CMD_SyncFromBucket = {
		"syncFromBucket"
	}
}

local function copyTable(source)
	local copy = {}

	if type(source) == "table" then
		for key, value in pairs(source) do
			copy[key] = value
		end
	end

	return copy
end

local function buildResponse(result, response)
	local copiedResponse = copyTable(response)
	local responseErr = response and (response.err or response.Err or response.reason or response.Reason)

	if type(response) == "table" then
		for key, value in pairs(response) do
			if type(key) == "string" and key:match("^%u") then
				copiedResponse[key:sub(1, 1):lower() .. key:sub(2)] = value
			end
		end
	end

	copiedResponse.flag = result and result.status == true

	if not copiedResponse.flag then
		copiedResponse.err = responseErr or result and (result.errmsg or result.err) or "home camp directory go service failed"
	end

	return copiedResponse
end

function HomeCampDirectoryCaller.dispatchResponse(caller, methodName, args, result, response)
	local method = caller[methodName]

	if not method then
		if caller.logger and caller.logger.error then
			caller.logger:error("home camp directory callback method not found: " .. tostring(methodName))
		end

		return
	end

	local callbackArgs = copyTable(args)

	callbackArgs[#callbackArgs + 1] = result
	callbackArgs[#callbackArgs + 1] = buildResponse(result, response)

	return method(caller, unpack(callbackArgs))
end

local function wrapCallback(caller, callback)
	if not callback then
		return nil
	end

	local upvalueName, objMgr, callbackOwner, methodName, args

	for i = 1, 4 do
		local name, value = debug.getupvalue(callback, i)

		if i == 1 then
			upvalueName, objMgr = name, value
		end

		if name == "methodName" then
			methodName = value
		elseif name == "args" then
			args = value
		elseif name == "obj" then
			callbackOwner = value
		end
	end

	if callbackOwner == caller and methodName and type(caller._homeCampDirectoryCallback) == "function" then
		return CallbackHandler(caller, "_homeCampDirectoryCallback", methodName, args or {})
	end

	if upvalueName == "objMgr" then
		return function(result, response)
			local _ = objMgr

			_ = methodName
			_ = args

			callback(result, buildResponse(result, response))
		end
	end

	return function(result, response)
		local _ = methodName

		_ = args

		callback(result, buildResponse(result, response))
	end
end

function HomeCampDirectoryCaller.call(caller, method, args, callback, options)
	local mapping = METHODS[method]

	if not mapping then
		local err = "unsupported home camp directory method: " .. tostring(method)

		if caller.logger and caller.logger.error then
			caller.logger:error(err)
		end

		if callback then
			callback({
				status = false
			}, {
				flag = false,
				err = err
			})
		end

		return
	end

	if CommonSwitch.UseNewHomeCampArch ~= true and mapping.legacyMethod then
		local legacyArgs = mapping.legacyArgs and mapping.legacyArgs(args) or args

		return caller:callService("HomeCampService", mapping.legacyMethod, legacyArgs, callback, options)
	end

	if CommonSwitch.UseGoHomeCampDirectory ~= true then
		return caller:callService("HomeCampDirectoryService", method, args, callback, options)
	end

	local goOptions = copyTable(options)

	if mapping[2] and goOptions.callerId == nil then
		goOptions.callerId = args and args[1]
	end

	return caller:callService("HomeCampDirectoryGoService", mapping[1], args, wrapCallback(caller, callback), goOptions)
end

return HomeCampDirectoryCaller
