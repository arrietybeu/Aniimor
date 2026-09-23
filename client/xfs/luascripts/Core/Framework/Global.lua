-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Framework\\Global.lua

local _GlobalNames = {}
local _SystemUsedNames = {
	bit = 1,
	socket = 1,
	phonestcore = 1,
	tcmalloc_debug = 1,
	libplua = 1,
	zlib = 1,
	md5 = 1,
	crontable = 1,
	lua_script_ptr = 1,
	memory = 1,
	pb = 1,
	bson = 1,
	cmsgpack = 1,
	lfs = 1,
	aoi = 1
}

local function __innerDeclare(name, defaultValue, override)
	if not rawget(_G, name) then
		rawset(_G, name, defaultValue or false)
	elseif override then
		rawset(_G, name, defaultValue or false)
	elseif name == "jit" or name == "UNITY_EDITOR" or name == "inspect" then
		-- block empty
	else
		print("[Warning] The global variable " .. name .. " is already declared!")
	end

	_GlobalNames[name] = true

	return _G[name]
end

local function __innerDeclareIndex(tbl, key)
	if not _GlobalNames[key] then
		error("Attempt to access an undeclared global variable : " .. key)
	end

	return nil
end

local function __innerDeclareNewindex(tbl, key, value)
	if not _GlobalNames[key] and not _SystemUsedNames[key] then
		error("Attempt to write an undeclared global variable : " .. key)
	else
		rawset(tbl, key, value)
	end
end

local function __GLDeclare(name, defaultValue, override)
	local ok, ret = pcall(__innerDeclare, name, defaultValue, override)

	if not ok then
		error(debug.traceback(ret, 2))

		return nil
	else
		return ret
	end
end

local function __isGLDeclared(name)
	if _GlobalNames[name] or rawget(_G, name) ~= nil then
		return true
	else
		return false
	end
end

local function __logGlobalError(res)
	local msg = string.format("%s, %s", tostring(res), debug.traceback())
	local packageRef = rawget(_G, "package")

	if packageRef and type(packageRef.loaded) == "table" then
		local loggerManager = packageRef.loaded["Core.Log.LoggerManager"]

		if type(loggerManager) == "table" and loggerManager.getLogger then
			local ok = pcall(function()
				local logger = loggerManager.getLogger("Global")

				logger:error("%s", msg)
			end)

			if ok then
				return
			end
		end
	end

	print(msg)
end

if not __isGLDeclared("GLDeclare") or not GLDeclare then
	__GLDeclare("GLDeclare", __GLDeclare)
end

if not __isGLDeclared("IsGLDeclared") or not IsGLDeclared then
	__GLDeclare("IsGLDeclared", __isGLDeclared)
end

setmetatable(_G, {
	__index = function(tbl, key)
		local ok, res = pcall(__innerDeclareIndex, tbl, key)

		if not ok then
			__logGlobalError(res)
		end

		return nil
	end,
	__newindex = function(tbl, key, value)
		local ok, res = pcall(__innerDeclareNewindex, tbl, key, value)

		if not ok then
			__logGlobalError(res)
		end
	end
})

return __GLDeclare
