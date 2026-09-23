-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Framework\\Reload.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local reload = {}
local sandbox = {}
local table = table

table.unpack = unpack

local debug = debug
local _wrapperModule = {}
local _isRpcMethodFunc

local function _getPluginComponentsByClassName()
	return {}
end

local LoggerPath = "[Core.Log.LoggerManager]"
local ClassPath = "[Core.Framework.Class]"
local AccessControlPath = "[Core.Framework.AccessControl]"

do
	local imp_files = {}
	local dummy_cache = {}
	local dummy_module_cache = {}
	local __defaultMethods = {
		preInit = true,
		ctor = true,
		start = true,
		destroy = true,
		postInit = true,
		init = true
	}

	function sandbox.isDefaultMethods(key)
		return __defaultMethods[key]
	end

	function sandbox.isRpcMethod(entityName, rpcName)
		if _isRpcMethodFunc and _isRpcMethodFunc(entityName, rpcName) then
			return true
		end

		return false
	end

	local classWrapper = {}

	function classWrapper.Class(name, super, isSingleton)
		local newClass = {
			__IsClass = true,
			typeName = name,
			superType = classWrapper.GenerateClass(super),
			_IsSingleton = isSingleton or false,
			components = {}
		}

		classWrapper.class[newClass] = newClass
		classWrapper.class[name] = newClass

		return newClass
	end

	function classWrapper.OldLightClass(name, super, isSingleton)
		local newClass = {
			__IsClass = true,
			__IsOldLightClass = true,
			typeName = name,
			superType = classWrapper.GenerateOldLightClass(super),
			_IsSingleton = isSingleton or false
		}

		classWrapper.class[newClass] = newClass
		classWrapper.class[name] = newClass

		return newClass
	end

	function classWrapper.LiteClass(name, super)
		local newClass = {
			__IsClass = true,
			__IsLiteClass = true,
			typeName = name,
			superType = classWrapper.GenerateLiteClass(super)
		}

		classWrapper.class[newClass] = newClass
		classWrapper.class[name] = newClass

		return newClass
	end

	function classWrapper.Component(name, super)
		local newComponent = {
			__IsComponent = true,
			typeName = name,
			super = classWrapper.GenerateComponent(super)
		}

		return newComponent
	end

	function classWrapper.GenerateClass(cls)
		if getmetatable(cls) ~= nil then
			local k = dummy_module_cache[cls]

			if k == nil then
				cls = classWrapper.Class(cls.typeName, cls.superType, cls._IsSingleton)
			else
				local from, to, name = string.find(k, "^%[(.+)%]")

				if from == nil then
					error("Invalid module " .. k)
				end

				local dummyModule = sandbox.module(name)

				if dummyModule == nil then
					local realClass = debug.getregistry()._LOADED[name]

					assert(realClass, "class" .. k .. "can not found")

					cls = classWrapper.Class(realClass.typeName, realClass.superType, realClass._IsSingleton)
				else
					cls = classWrapper.Class(dummyModule.module.typeName, dummyModule.module.superType, dummyModule.module._IsSingleton)
				end
			end
		end

		return cls
	end

	function classWrapper.GenerateOldLightClass(cls)
		if getmetatable(cls) ~= nil then
			local k = dummy_module_cache[cls]

			if k == nil then
				cls = classWrapper.OldLightClass(cls.typeName, cls.superType, cls._IsSingleton)
			else
				local from, to, name = string.find(k, "^%[(.+)%]")

				if from == nil then
					error("Invalid module " .. k)
				end

				local dummyModule = sandbox.module(name)

				if dummyModule == nil then
					local realClass = debug.getregistry()._LOADED[name]

					assert(realClass, "class" .. k .. "can not found")

					cls = classWrapper.OldLightClass(realClass.typeName, realClass.superType, realClass._IsSingleton)
				else
					cls = classWrapper.OldLightClass(dummyModule.module.typeName, dummyModule.module.superType, dummyModule.module._IsSingleton)
				end
			end
		end

		return cls
	end

	function classWrapper:GenerateLiteClass(cls)
		if getmetatable(cls) ~= nil then
			local k = dummy_module_cache[cls]

			if k == nil then
				cls = classWrapper.LiteClass(cls.typeName, cls.superType)
			else
				local from, to, name = string.find(k, "^%[(.+)%]")

				if from == nil then
					error("Invalid module " .. k)
				end

				local dummyModule = sandbox.module(name)

				if dummyModule == nil then
					local realClass = debug.getregistry()._LOADED[name]

					assert(realClass, "class" .. k .. "can not found")

					cls = classWrapper.LiteClass(realClass.typeName, realClass.superType)
				else
					cls = classWrapper.LiteClass(dummyModule.module.typeName, dummyModule.module.superType)
				end
			end
		end

		return cls
	end

	function classWrapper.GenerateComponent(component)
		if getmetatable(component) ~= nil then
			local k = dummy_module_cache[component]

			if k == nil then
				component = classWrapper.Component(component.typeName, component.super)
			else
				local from, to, name = string.find(k, "^%[(.+)%]")

				if from == nil then
					error("Invalid module " .. k)
				end

				local dummyModule = sandbox.module(name)

				if dummyModule ~= nil then
					component = classWrapper.Component(dummyModule.module.typeName, dummyModule.module.super)
				else
					local realComponent = debug.getregistry()._LOADED[name]

					assert(realComponent, "component " .. k .. "can not found")

					component = classWrapper.Component(realComponent.typeName, realComponent.super)
				end
			end
		end

		return component
	end

	function classWrapper.AddComponent(cls, component)
		component = classWrapper.GenerateComponent(component)

		local clsObj = classWrapper.class[cls]

		if clsObj == nil then
			error(" AddComponent but can not find class " .. cls)

			return
		end

		table.insert(clsObj.components, component)
	end

	function classWrapper.AddComponents(cls, components)
		for i = 1, #components do
			local component = components[i]

			classWrapper.AddComponent(cls, component)
		end
	end

	local loggerWrapper = {}
	local _loggerMt = {
		__metatable = "LOGGER",
		__newindex = function()
			error("_loggerMt __newindex")
		end,
		__pairs = function()
			error("_loggerMt __pairs")
		end
	}

	function loggerWrapper.getLogger(name)
		local logger = {
			name = name
		}

		setmetatable(logger, _loggerMt)

		return logger
	end

	function loggerWrapper.setGenerateLoggerFunc(func)
		loggerWrapper.generateLogger = func
	end

	local accessControlWrapper = {}
	local _accessControlWrapperMt = {
		__metatable = "AccessControl",
		__newindex = function()
			error("_accessControlWrapperMt __newindex")
		end,
		__pairs = function()
			error("_accessControlWrapperMt __newindex")
		end
	}

	function accessControlWrapper.readOnly(original)
		return original
	end

	local wrapper_dummy_mt = {
		__metatable = "WRAPPER",
		__pairs = function()
			error("wrapper_dummy_mt __pairs")
		end,
		__tostring = function(self)
			return _wrapperModule[self]
		end
	}

	local function addWrapperMetaTable(wrapper, path)
		_wrapperModule[path] = wrapper
		_wrapperModule[wrapper] = path

		setmetatable(wrapper, wrapper_dummy_mt)
	end

	classWrapper.LightClass = classWrapper.LiteClass

	addWrapperMetaTable(classWrapper, ClassPath)
	addWrapperMetaTable(loggerWrapper, LoggerPath)
	addWrapperMetaTable(accessControlWrapper, AccessControlPath)

	local function findloader(name)
		if reload.postfix and not _wrapperModule[name] then
			name = name .. reload.postfix
		end

		local msg = {}

		for _, loader in ipairs(package.loaders) do
			local f, extra = loader(name)
			local t = type(f)

			if t == "function" then
				return f, extra
			elseif t == "string" then
				table.insert(msg, f)
			end
		end

		error(string.format("module '%s' not found:%s", name, table.concat(msg)))
	end

	local global_mt = {
		__metatable = "SANDBOX",
		__newindex = function()
			error("global_mt __newindex")
		end,
		__pairs = function()
			error("global_mt __pairs")
		end
	}
	local _LOADED_DUMMY = {}
	local _LOADED = {}
	local weak = {
		__mode = "kv"
	}
	local module_dummy_mt = {
		__metatable = "MODULE",
		__newindex = function()
			error("module_dummy_mt __newindex")
		end,
		__pairs = function()
			error("module_dummy_mt __pairs")
		end,
		__tostring = function(self)
			return dummy_module_cache[self]
		end
	}

	function module_dummy_mt:__index(k)
		assert(type(k) == "string", "module field is not string")

		local parent_key = dummy_module_cache[self]
		local key = parent_key .. "." .. k

		if dummy_module_cache[key] then
			return dummy_module_cache[key]
		else
			local obj = {}

			dummy_module_cache[key] = obj
			dummy_module_cache[obj] = key

			return setmetatable(obj, module_dummy_mt)
		end
	end

	local module_imp_dummy_mt = {
		__metatable = "IMP_MODULE",
		__pairs = function()
			error("module_imp_dummy_mt __pairs")
		end,
		__newindex = function(self, key, value)
			local name = dummy_module_cache[self]
			local from, to, _name = string.find(name, "^%[(.+)%]")

			if from == nil then
				error(string.format("Invalid module %s key %s", name, key))

				return
			end

			local mod = _LOADED[_name].module

			mod[key] = value
		end,
		__tostring = function(self)
			return dummy_module_cache[self]
		end
	}

	module_dummy_mt.__index = module_dummy_mt.__index

	local function make_dummy_module(name)
		local name = "[" .. name .. "]"

		if dummy_module_cache[name] then
			return dummy_module_cache[name]
		elseif _wrapperModule[name] then
			return _wrapperModule[name]
		elseif imp_files[name] then
			local obj = {}

			dummy_module_cache[name] = obj
			dummy_module_cache[obj] = name

			return setmetatable(obj, module_imp_dummy_mt)
		else
			local obj = {}

			dummy_module_cache[name] = obj
			dummy_module_cache[obj] = name

			return setmetatable(obj, module_dummy_mt)
		end
	end

	local function make_sandbox()
		return setmetatable({}, global_mt)
	end

	function sandbox.require(name)
		assert(type(name) == "string")

		if _LOADED_DUMMY[name] then
			return _LOADED_DUMMY[name]
		end

		local loader, arg = findloader(name)
		local oldEnv = debug.getfenv(loader)

		debug.setfenv(loader, make_sandbox())

		local ret = loader(name, arg) or true

		debug.setfenv(loader, oldEnv)

		_LOADED[name] = {
			module = ret,
			loader = loader
		}
		_LOADED_DUMMY[name] = make_dummy_module(name)

		return _LOADED_DUMMY[name]
	end

	function sandbox.import(moduleName)
		local currentModuleName = sandbox.current_mod
		local currentModuleNameParts
		local moduleFullName = moduleName
		local offset = 1

		while true do
			if string.byte(moduleName, offset) ~= 46 then
				moduleFullName = string.sub(moduleName, offset)

				if currentModuleNameParts and #currentModuleNameParts > 0 then
					moduleFullName = table.concat(currentModuleNameParts, ".") .. "." .. moduleFullName
				end

				break
			end

			offset = offset + 1
			currentModuleNameParts = currentModuleNameParts or string.split(currentModuleName, ".")

			table.remove(currentModuleNameParts, #currentModuleNameParts)
		end

		return sandbox.require(moduleFullName)
	end

	local global_dummy_mt = {
		__metatable = "GLOBAL",
		__tostring = function(self)
			return dummy_cache[self]
		end,
		__newindex = function()
			error("global_dummy_mt __newindex")
		end,
		__pairs = function()
			error("global_dummy_mt __pairs")
		end
	}

	local function make_dummy(k)
		if dummy_cache[k] then
			return dummy_cache[k]
		else
			local obj = {}

			dummy_cache[obj] = k
			dummy_cache[k] = obj

			return setmetatable(obj, global_dummy_mt)
		end
	end

	function global_dummy_mt:__index(k)
		local parent_key = dummy_cache[self]

		assert(type(k) == "string", "Global name must be a string")

		local key = parent_key .. "." .. k

		return make_dummy(key)
	end

	local _inext = ipairs({})
	local safe_function = {
		require = sandbox.require,
		pairs = pairs,
		next = next,
		ipairs = ipairs,
		_inext = _inext,
		print = print,
		import = sandbox.import,
		unpack = unpack,
		math = math,
		getmetatable = getmetatable,
		setmetatable = setmetatable,
		rawset = rawset,
		rawget = rawget,
		string = string,
		Vector2 = Vector2,
		Vector3 = Vector3,
		Vector4 = Vector4,
		pg = pg,
		Quaternion = Quaternion,
		bit = bit,
		loadfile = loadfile,
		type = type,
		EnableBotTest = EnableBotTest
	}

	function global_mt:__index(k)
		assert(type(k) == "string", "Global name must be a string")

		if safe_function[k] ~= nil then
			return safe_function[k]
		else
			return make_dummy(k)
		end
	end

	local function get_G(obj)
		local k = dummy_cache[obj]
		local G = _G

		for w in string.gmatch(k, "[_%a][_%w]*") do
			if G == nil then
				error("Invalid global", k)
			end

			G = G[w]
		end

		return G
	end

	local function get_M(obj)
		local k = dummy_module_cache[obj]
		local M = debug.getregistry()._LOADED
		local from, to, name = string.find(k, "^%[(.+)%]")

		if from == nil then
			error("Invalid module " .. k)
		end

		local mod = assert(M[name], "module " .. k .. "not found")
		local oldLen = string.len(k)
		local modLen = string.len(name)

		if modLen < oldLen - 2 then
			local var = mod
			local leftVarName = string.sub(k, to + 2)
			local loopCount = 1

			while loopCount < 10 do
				loopCount = loopCount + 1

				local startIndex, endIndex = string.find(leftVarName, "[^%.]*")

				if startIndex <= endIndex and endIndex ~= 0 then
					local varName = string.sub(leftVarName, startIndex, endIndex)

					var = assert(var[varName], "module " .. k .. " has no attribute: " .. varName)
					leftVarName = string.sub(leftVarName, endIndex + 2)
				else
					return var
				end
			end
		end

		return mod
	end

	local function get_W(obj)
		local k = _wrapperModule[obj]
		local M = debug.getregistry()._LOADED
		local from, to, name = string.find(k, "^%[(.+)%]")

		if from == nil then
			error("Invalid module " .. k)
		end

		local mod = assert(M[name])

		return mod
	end

	function sandbox.value(obj)
		local meta = getmetatable(obj)

		if meta == "GLOBAL" then
			return get_G(obj)
		elseif meta == "MODULE" or meta == "IMP_MODULE" then
			return get_M(obj)
		elseif meta == "WRAPPER" then
			return get_W(obj)
		else
			error("Invalid object" .. obj)
		end
	end

	function sandbox.init(list, impFiles)
		local my_print = reload.print

		dummy_cache = setmetatable({}, weak)
		dummy_module_cache = setmetatable({}, weak)

		for k, v in pairs(_LOADED_DUMMY) do
			_LOADED_DUMMY[k] = nil
		end

		for k, v in pairs(_LOADED) do
			_LOADED[k] = nil
		end

		imp_files = {}

		if impFiles then
			for _, k in ipairs(impFiles) do
				imp_files[k] = true
			end
		end

		if list then
			for _, name in ipairs(list) do
				if my_print then
					my_print("INITDUMMY ", name)
				end

				_LOADED_DUMMY[name] = make_dummy_module(name)
			end
		end

		classWrapper.class = {}
	end

	function sandbox.isdummy(v)
		if safe_function[v] then
			return true
		end

		return getmetatable(v) ~= nil
	end

	function sandbox.module(name)
		return _LOADED[name]
	end

	function sandbox.clear()
		dummy_cache = nil
		dummy_module_cache = nil

		for k, v in pairs(_LOADED) do
			_LOADED[k] = nil
		end

		for k, v in pairs(_LOADED_DUMMY) do
			_LOADED_DUMMY[k] = nil
		end

		classWrapper.class = nil
		imp_files = nil
	end
end

function reload.initEnv(envTable)
	_wrapperModule[LoggerPath].setGenerateLoggerFunc(envTable.loggerGenerateFunc)

	_isRpcMethodFunc = envTable.isRpcMethodFunc

	local getPluginComponentsByClassName = envTable.getPluginComponentsByClassName

	if type(getPluginComponentsByClassName) == "function" then
		_getPluginComponentsByClassName = getPluginComponentsByClassName
	end
end

function reload.list()
	local list = {}

	for k in pairs(debug.getregistry()._LOADED) do
		table.insert(list, k)
	end

	return list
end

local accept_key_type = {
	string = true,
	number = true,
	boolean = true
}

local function enum_object(value)
	local my_print = reload.print
	local all = {}
	local path = {}
	local objs = {}
	local classes = {}

	local function iterate(value)
		if sandbox.isdummy(value) then
			if my_print then
				my_print("ENUMDUMMY", value, table.concat(path, "."))
			end

			table.insert(all, {
				value,
				table.unpack(path)
			})

			return
		end

		local t = type(value)

		if t == "function" or t == "table" then
			if my_print then
				my_print("ENUM", value, table.concat(path, "."))
			end

			table.insert(all, {
				value,
				table.unpack(path)
			})

			if t == "table" and value.__IsClass then
				if my_print then
					my_print("ENUMFINDCLASS", value, table.concat(path, "."))
				end

				classes[value] = true
			end

			if objs[value] then
				return
			end

			objs[value] = true
		else
			return
		end

		local depth = #path + 1

		if t == "function" then
			local i = 1

			while true do
				local name, v = debug.getupvalue(value, i)

				if my_print then
					my_print("==yc== getupvalue ", value, " name is ", name, v)
				end

				if name == nil or name == "" then
					break
				else
					if not name:find("^[_%w]") then
						error("Invalid upvalue : " .. table.concat(path, "."))
					end

					local vt = type(v)

					if vt == "function" or vt == "table" then
						path[depth] = name
						path[depth + 1] = i

						iterate(v)

						path[depth] = nil
						path[depth + 1] = nil
					end
				end

				i = i + 1
			end
		else
			local newModuleDummyPair = {}
			local oldModuleDummyPair = {}

			for k, v in pairs(value) do
				if not accept_key_type[type(k)] then
					if sandbox.isdummy(k) then
						oldModuleDummyPair[k] = true
						k = sandbox.value(k)
						newModuleDummyPair[k] = v
					else
						error("Invalid key : " .. k .. " " .. table.concat(path, "."))
					end
				end

				if (value.__IsClass or value.__IsComponent) and sandbox.isRpcMethod(value.typeName, k) then
					k = "_Rpc_" .. k
				elseif value.__IsClass and not value.__IsOldLightClass and not value.__IsLiteClass and sandbox.isDefaultMethods(k) then
					k = "_" .. k
				end

				path[depth] = k

				iterate(v)

				path[depth] = nil
			end

			for k, _ in pairs(oldModuleDummyPair) do
				value[k] = nil
			end

			for k, v in pairs(newModuleDummyPair) do
				value[k] = v
			end
		end
	end

	iterate(value)

	return all, classes
end

local function find_object(mod, name, id, ...)
	if mod == nil or name == nil then
		return mod
	end

	local t = type(mod)

	if t == "table" then
		return find_object(mod[name], id, ...)
	else
		assert(t == "function")

		local i = 1

		while true do
			local n, value = debug.getupvalue(mod, i)

			if n == nil or name == "" then
				return
			end

			if n == name then
				return find_object(value, ...)
			end

			i = i + 1
		end
	end
end

local function sameComponent(oldComponent, newComponent, error)
	if newComponent.typeName ~= oldComponent.typeName then
		error = error .. " old class component index " .. i .. " is " .. oldComponent.typeName .. " new class component index " .. i .. " is " .. newComponent.typeName

		return false, error
	end

	local newComponentHasSuper = newComponent.super ~= nil
	local oldComponentHasSuper = oldComponent.super ~= nil

	if newComponentHasSuper ~= oldComponentHasSuper then
		error = error .. "old component has super " .. tostring(oldComponentHasSuper) .. " new component has super " .. tostring(newComponentHasSuper) .. " component is " .. oldComponent.typeName

		return false, error
	end

	if newComponentHasSuper and newComponent.super.typeName ~= oldComponent.super.typeName then
		error = error .. "old component super type is " .. oldComponent.super.typeName .. " new comopnent super type is " .. newComponent.super.typeName

		return false, error
	end

	return true, ""
end

local function sameClass(old, new)
	local error = "[Class " .. new.typeName .. " ] "

	if old == nil then
		return true
	end

	if not old.__IsClass then
		error = error .. "old is not a class " .. new.typeName

		return false, error
	end

	if old.typeName ~= new.typeName then
		error = error .. "old name is " .. old.typeName .. " new name is " .. new.typeName

		return false, error
	end

	local oldHasSuper = old.superType ~= nil
	local newHasSuper = new.superType ~= nil

	if oldHasSuper ~= newHasSuper then
		error = error .. "old has super " .. tostring(oldHasSuper) .. " new has super " .. tostring(newHasSuper)

		return false, error
	end

	if oldHasSuper and old.superType.typeName ~= new.superType.typeName then
		error = error .. "old super type is " .. old.superType.typeName .. " new super type is " .. new.superType.typeName

		return false, error
	end

	if old._IsSingleton ~= new._IsSingleton then
		error = error .. "old class singletons are " .. tostring(old._IsSingleton) .. " new class singletons are " .. tostring(new._IsSingleton)

		return false, error
	end

	local pluginComponents = _getPluginComponentsByClassName(old.typeName)

	if not old.__IsOldLightClass and not old.__IsLiteClass then
		local oldComponents = old.components
		local newComponents = new.components

		if #oldComponents ~= #newComponents + #pluginComponents then
			error = error .. " old class components num " .. #oldComponents .. " new class components num " .. #newComponents

			return false, error
		end

		for i, newComponent in ipairs(newComponents) do
			local oldComponent = oldComponents[i]
			local ret, errorStr = sameComponent(oldComponent, newComponent, error)

			if not ret then
				return errorStr
			end
		end

		for i, pluginComponent in ipairs(pluginComponents) do
			local oldComponent = oldComponents[#newComponents + i]
			local ret, errorStr = sameComponent(oldComponent, pluginComponent, error)

			if not ret then
				return errorStr
			end
		end
	end

	return true
end

local function match_objects(objects, old_module, map, globals, classes, excludeUpvalues, delKeyModels)
	local my_print = reload.print
	local objPath = {}

	for _, item in ipairs(objects) do
		local obj = item[1]

		if sandbox.isdummy(obj) then
			if my_print then
				my_print("==yc== match_globals ", obj)
			end

			table.insert(globals, item)
		else
			local ok, old_one = pcall(find_object, old_module, table.unpack(item, 2))
			local checkClass = false

			if table.unpack(item, 2) == nil then
				checkClass = true
			end

			if my_print then
				my_print("==yc== match object ", table.concat({
					table.unpack(item, 2)
				}, "."), obj, old_one, type(item[2]), old_module)
			end

			if old_one == nil then
				map[obj] = map[obj] or false
			end

			if map[obj] and old_one and map[obj] ~= old_one then
				local current = {
					table.unpack(item, 2)
				}

				error("Ambiguity table : " .. table.concat(current, ","))
			end

			if classes[obj] ~= nil and checkClass then
				local ret, msg = sameClass(old_one, obj)

				if not ret then
					local current = {
						table.unpack(item, 2)
					}

					error("Ambiguity Class : " .. table.concat(current, ",") .. " Error " .. msg)
				end

				classes[obj] = old_one
			end

			if old_one ~= nil then
				map[obj] = old_one
			else
				map[obj] = map[obj] or false
			end
		end
	end
end

local function find_upvalue(func, name)
	if not func then
		return
	end

	local i = 1

	while true do
		local n, v = debug.getupvalue(func, i)

		if n == nil or name == "" then
			return
		end

		if n == name then
			return i
		end

		i = i + 1
	end
end

local function match_upvalues(map, upvalues, excludeUpvalues, classes)
	local my_print = reload.print

	upvalues.exclude = {}
	upvalues._ENV = {}

	for new_one, old_one in pairs(map) do
		if type(new_one) == "function" then
			if excludeUpvalues[new_one] ~= nil then
				upvalues.exclude[new_one] = {}
			end

			upvalues._ENV[new_one] = {}

			local i = 1

			if old_one then
				assert(type(old_one) == "function")
				debug.setfenv(new_one, debug.getfenv(old_one))
			end

			while true do
				local name, value = debug.getupvalue(new_one, i)

				if name == nil or name == "" then
					break
				end

				if classes[value] ~= nil then
					debug.setupvalue(new_one, i, classes[value])

					value = classes[value]
				end

				if my_print then
					my_print("==yc== match_upvalues ", name, value)
				end

				local old_index = find_upvalue(old_one, name)
				local id = debug.upvalueid(new_one, i)

				if excludeUpvalues[new_one] ~= nil and old_index then
					upvalues.exclude[new_one][id] = {
						func = old_one,
						index = old_index
					}
				elseif not upvalues[id] and old_index then
					upvalues[id] = {
						func = old_one,
						index = old_index,
						oldid = debug.upvalueid(old_one, old_index)
					}
				elseif old_index then
					local oldid = debug.upvalueid(old_one, old_index)

					if oldid ~= upvalues[id].oldid then
						error(string.format("Ambiguity upvalue : %s .%s", tostring(new_one), name))
					end
				end

				i = i + 1
			end
		end
	end
end

local function reload_list(list, delKeyModels)
	local my_print = reload.print
	local _LOADED = debug.getregistry()._LOADED
	local all = {}

	for _, mod in ipairs(list) do
		sandbox.current_mod = mod

		sandbox.require(mod)
	end

	for _, mod in ipairs(list) do
		if delKeyModels[mod] == nil then
			if my_print then
				my_print("==yc== reload begin", mod)
			end

			if my_print then
				my_print("==yc== require begin ", mod)
			end

			sandbox.require(mod)

			if my_print then
				my_print("==yc== require end", mod)
			end

			local m = sandbox.module(mod)

			if my_print then
				my_print("==yc== enum object begin ", mod)
			end

			local objs, classes = enum_object(m.module)

			if my_print then
				my_print("==yc== enum object end ", mod)
			end

			local old_module = _LOADED[mod]
			local result = {
				globals = {},
				map = {},
				upvalues = {},
				excludeUpvalues = {},
				old_module = old_module,
				module = m,
				objects = objs,
				classes = classes
			}

			all[mod] = result

			if my_print then
				my_print("==yc== match object begin ", mod)
			end

			match_objects(objs, old_module, result.map, result.globals, result.classes, result.excludeUpvalues, delKeyModels)

			if my_print then
				my_print("==yc== match object end ", mod)
			end

			if my_print then
				my_print("==yc== match upvalue begin ", mod)
			end

			match_upvalues(result.map, result.upvalues, result.excludeUpvalues, result.classes)

			if my_print then
				my_print("==yc== match upvalue end ", mod)
			end

			if my_print then
				my_print("==yc== reload end", mod)
			end
		end
	end

	return all
end

local function set_object(v, mod, name, tmore, fmore, ...)
	if mod == nil or name == nil then
		return false
	end

	if type(mod) == "table" then
		if not tmore then
			mod[name] = v

			return true
		end

		return set_object(v, mod[name], tmore, fmore, ...)
	else
		local i = 1

		while true do
			local n, value = debug.getupvalue(mod, i)

			if n == nil or name == "" then
				return false
			end

			if n == name then
				if not fmore then
					debug.setupvalue(mod, i, v)

					return true
				end

				return set_object(v, value, fmore, ...)
			end

			i = i + 1
		end
	end
end

local function patch_funcs(upvalues, map)
	local my_print = reload.print

	for value in pairs(map) do
		if type(value) == "function" then
			local i = 1

			while true do
				local name, v = debug.getupvalue(value, i)

				if name == nil or name == "" then
					break
				end

				local id = debug.upvalueid(value, i)
				local uv

				if upvalues.exclude[value] ~= nil then
					uv = upvalues.exclude[value][id]
				elseif upvalues._ENV[value][id] ~= nil then
					uv = upvalues._ENV[value][id]
				else
					uv = upvalues[id]
				end

				if uv then
					if my_print then
						my_print("JOIN", value, name, uv.func, uv.index)
					end

					debug.upvaluejoin(value, i, uv.func, uv.index)
				end

				i = i + 1
			end
		end
	end
end

local function merge_objects(all, delKeyModels)
	local REG = debug.getregistry()
	local _LOADED = REG._LOADED
	local my_print = reload.print
	local test_one

	for mod_name, data in pairs(all) do
		if my_print then
			my_print("==yc== merge object begin ", mod_name)
		end

		local map = data.map
		local delete = false

		for _, rule in pairs(delKeyModels or EMPTY_TABLE) do
			if string.startsWith(mod_name, rule) then
				delete = true

				break
			end
		end

		if data.old_module then
			patch_funcs(data.upvalues, map)

			for new_one, old_one in pairs(map) do
				if type(new_one) == "table" and old_one then
					if my_print then
						my_print("COPY", old_one)
					end

					for k, v in pairs(new_one) do
						if type(v) ~= "table" or getmetatable(v) ~= nil or old_one[k] == nil then
							if (new_one.__IsClass or new_one.__IsComponent) and sandbox.isRpcMethod(new_one.typeName, k) then
								k = "_Rpc_" .. k
							end

							if type(k) ~= "string" and sandbox.isdummy(k) then
								k = sandbox.value(k)
							end

							if my_print then
								my_print("COPY k, v ", k, v, old_one)
							end

							if type(old_one) == "table" then
								old_one[k] = v
							end
						elseif delete and type(v) ~= type(old_one[k]) then
							old_one[k] = v
						end
					end

					if delete and not new_one.__IsClass and type(old_one) == "table" then
						local deleteKeys = {}

						for k in pairs(old_one) do
							if new_one[k] == nil then
								deleteKeys[k] = true
							end
						end

						for k in pairs(deleteKeys) do
							old_one[k] = nil
						end
					end
				end
			end

			for _, item in ipairs(data.objects) do
				local v = item[1]

				if not sandbox.isdummy(v) and not map[v] then
					if type(v) == "function" then
						debug.setfenv(v, _G)
					end

					local ok = set_object(v, data.old_module, table.unpack(item, 2))

					if my_print then
						my_print("MOVE", mod_name, table.concat(item, ".", 2), ok)
					end
				end
			end
		else
			for _, item in ipairs(data.objects) do
				local v = item[1]

				if type(v) == "function" then
					debug.setfenv(v, _G)
				end
			end

			_LOADED[mod_name] = data.module.module
		end

		if my_print then
			my_print("==yc== merge object end", mod_name)
		end
	end
end

local function solve_globals(all)
	local _LOADED = debug.getregistry()._LOADED
	local my_print = reload.print
	local i = 0

	for mod_name, data in pairs(all) do
		for gk, item in ipairs(data.globals) do
			local v = item[1]
			local path = tostring(v)
			local value, unsolved, invalid

			if getmetatable(v) == "GLOBAL" then
				local G = _G

				for w in string.gmatch(path, "[_%a][_%w]*") do
					if G == nil then
						invalid = true

						break
					end

					G = G[w]
				end

				value = G
			elseif getmetatable(v) == "MODULE" or getmetatable(v) == "IMP_MODULE" then
				value = sandbox.value(v)
			elseif getmetatable(v) == "WRAPPER" then
				value = sandbox.value(v)
			elseif getmetatable(v) == "LOGGER" then
				value = _wrapperModule[LoggerPath].generateLogger(v.name)
			else
				invalid = true
				unsolved = true
			end

			if invalid then
				if my_print then
					my_print("GLOBAL INVALID", path)
				end

				data.globals[gk] = nil
			elseif not unsolved then
				i = i + 1

				if my_print then
					my_print("GLOBAL", path, value, mod_name, table.unpack(item, 2))
				end

				set_object(value, _LOADED[mod_name], table.unpack(item, 2))

				data.globals[gk] = nil
			end
		end
	end

	return i
end

local function update_funcs(map)
	local root = debug.getregistry()
	local co = coroutine.running()
	local exclude = {
		[map] = true,
		[co] = true
	}
	local getmetatable = debug.getmetatable
	local getinfo = debug.getinfo
	local getlocal = debug.getlocal
	local setlocal = debug.setlocal
	local getupvalue = debug.getupvalue
	local setupvalue = debug.setupvalue
	local getuservalue = debug.getuservalue
	local setuservalue = debug.setuservalue
	local type = type
	local next = next
	local rawset = rawset

	exclude[exclude] = true

	local update_funcs_

	local function update_funcs_frame(co, level)
		local info = getinfo(co, level + 1, "f")

		if info == nil then
			return
		end

		local f = info.func

		info = nil

		update_funcs_(f)

		local i = 1

		while true do
			local name, v = getlocal(co, level + 1, i)

			if name == nil then
				if i > 0 then
					i = -1
				else
					break
				end
			end

			local nv = map[v]

			if nv then
				setlocal(co, level + 1, i, nv)
				update_funcs_(nv)
			else
				update_funcs_(v)
			end

			if i > 0 then
				i = i + 1
			else
				i = i - 1
			end
		end

		return update_funcs_frame(co, level + 1)
	end

	function update_funcs_(root)
		local my_print = reload.print

		if exclude[root] then
			return
		end

		local t = type(root)

		if t == "table" then
			exclude[root] = true

			local mt = getmetatable(root)

			if mt then
				update_funcs_(mt)
			end

			local tmp

			for k, v in next, root do
				local nv = map[v]

				if nv then
					rawset(root, k, nv)
					my_print("RAWSETFUNC ", root, k, v, nv)
					update_funcs_(nv)
				else
					update_funcs_(v)
				end

				local nk = map[k]

				if nk then
					if tmp == nil then
						tmp = {}
					end

					tmp[k] = nk
				else
					update_funcs_(k)
				end
			end

			if tmp then
				for k, v in next, tmp do
					root[k], root[v] = nil, root[k]

					update_funcs_(v)
				end

				tmp = nil
			end
		elseif t == "userdata" then
			exclude[root] = true

			local mt = getmetatable(root)

			if mt then
				update_funcs_(mt)
			end

			local uv = getuservalue(root)

			if uv then
				local tmp = map[uv]

				if tmp then
					setuservalue(root, tmp)
					update_funcs_(tmp)
				else
					update_funcs_(uv)
				end
			end
		elseif t == "thread" then
			exclude[root] = true

			update_funcs_frame(root, 2)
		elseif t == "function" then
			exclude[root] = true

			local i = 1

			while true do
				local name, v = getupvalue(root, i)

				if name == nil then
					break
				else
					local nv = map[v]

					if nv then
						setupvalue(root, i, nv)
						update_funcs_(nv)
					else
						update_funcs_(v)
					end
				end

				i = i + 1
			end
		end
	end

	for _, v in pairs({
		nil,
		0,
		true,
		"",
		co,
		update_funcs,
		debug.upvalueid(update_funcs, 1)
	}) do
		local mt = getmetatable(v)

		if mt then
			update_funcs_(mt)
		end
	end

	update_funcs_frame(co, 2)
	update_funcs_(root)
end

function reload.reload(list, impFiles, delKeyModels)
	local my_print = reload.print

	if my_print then
		my_print("==yc== reload all start")
	end

	local REG = debug.getregistry()
	local _LOADED = REG._LOADED
	local need_reload = {}
	local new_list = {}
	local subModel
	local prefix = "Common."

	for _, mod in ipairs(list) do
		if _LOADED[mod] then
			need_reload[mod] = true

			table.insert(new_list, mod)
		end

		if mod:startsWith(prefix) then
			subModel = mod:sub(#prefix + 1)

			if _LOADED[subModel] then
				need_reload[subModel] = true

				table.insert(new_list, subModel)
			end
		end
	end

	local tmp = {}

	for k in pairs(_LOADED) do
		if not need_reload[k] then
			table.insert(tmp, k)
		end
	end

	sandbox.init(tmp, impFiles)

	local function reload_list_wrapper()
		return reload_list(new_list, delKeyModels)
	end

	local ok, result = xpcall(reload_list_wrapper, debug.traceback)

	if not ok then
		print("reload occur error", result)
		sandbox.clear()

		return ok, result
	end

	merge_objects(result, delKeyModels)

	for _, data in pairs(result) do
		if data.module.loader then
			-- block empty
		end
	end

	repeat
		local n = solve_globals(result)
	until n == 0

	result = nil

	sandbox.clear()

	if my_print then
		my_print("==yc== reload all end")
	end

	return true, new_list
end

return reload
