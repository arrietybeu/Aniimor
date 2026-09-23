-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Framework\\Exception.lua

local functionType = "function"

local function try_finally(finallyBlock, catchBlockDeclared, status, err)
	if type(finallyBlock) == functionType then
		finallyBlock()
	end

	if not catchBlockDeclared and not status then
		error(err)
	end
end

local function try_catch(catchBlock, status, err)
	local catchBlockDeclared = type(catchBlock) == functionType

	if not status and catchBlockDeclared then
		local ex = err or "unknown error occurred"

		catchBlock(ex)
	end

	return try_finally, catchBlockDeclared, status, err
end

local function try(tryBlock)
	local status, err = true

	if type(tryBlock) == functionType then
		status, err = xpcall(tryBlock, debug.traceback)
	end

	return try_catch, try_finally, status, err
end

return try
