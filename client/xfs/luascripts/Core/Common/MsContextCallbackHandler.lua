-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Common\\MsContextCallbackHandler.lua

local CommonRepo = require("Core.Common.CommonRepo")
local MsContext = require("Core.MicroService.MsContext")
local MsContextCallbackHandler = {}

local function packResults(...)
	return {
		n = select("#", ...),
		...
	}
end

function MsContextCallbackHandler.clone(src)
	if not src then
		return nil
	end

	local ctx = MsContext()

	for key, value in pairs(src) do
		ctx[key] = value
	end

	return ctx
end

function MsContextCallbackHandler.run(msContext, callback, ...)
	local oldContext = CommonRepo.msContext

	CommonRepo.msContext = msContext

	local args = packResults(...)
	local results = packResults(xpcall(function()
		return callback(unpack(args, 1, args.n))
	end, debug.traceback))

	CommonRepo.msContext = oldContext

	if not results[1] then
		error(results[2], 0)
	end

	return unpack(results, 2, results.n)
end

function MsContextCallbackHandler.wrap(callback)
	if callback == nil then
		return nil
	end

	local msContext = MsContextCallbackHandler.clone(CommonRepo.msContext)

	if msContext == nil then
		return callback
	end

	return function(...)
		return MsContextCallbackHandler.run(msContext, callback, ...)
	end
end

setmetatable(MsContextCallbackHandler, {
	__call = function(_, callback)
		return MsContextCallbackHandler.wrap(callback)
	end
})

return MsContextCallbackHandler
