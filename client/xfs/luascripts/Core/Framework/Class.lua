-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Framework\\Class.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local componentTypeToVtbl = {}

local function isCallable(obj)
	if type(obj) == "function" then
		return true
	elseif type(obj) == "table" then
		local mt = debug.getmetatable(obj)

		return type(mt) == "table" and type(mt.__call) == "function"
	else
		return false
	end
end

local function __buildBotMethodWhitelist(playerCls)
	local wl = {}

	local function collectComponent(comp)
		while comp do
			local cvtbl = componentTypeToVtbl[comp]

			if cvtbl then
				for k, v in pairs(cvtbl) do
					if type(v) == "function" then
						wl[k] = true
					end
				end
			end

			comp = comp.super
		end
	end

	local function collectClass(cls)
		if not cls or not cls.components then
			return
		end

		for _, comp in ipairs(cls.components) do
			collectComponent(comp)
		end
	end

	collectClass(playerCls)

	for _, sup in ipairs(playerCls._classInherits or EMPTY_TABLE) do
		collectClass(sup)
	end

	return wl
end

local __ClassTypeList = {}
local __LiteClassList = {}
local __InheritRelationship = {}
local Class = {}

Class.enableInstanceProfile = true

local __classCreatedCount = {}
local __classAliveInstances = {}

local function __recordInstance(typeName, inst)
	if not Class.enableInstanceProfile or typeName == nil then
		return
	end

	__classCreatedCount[typeName] = (__classCreatedCount[typeName] or 0) + 1

	local aliveSet = __classAliveInstances[typeName]

	if aliveSet == nil then
		aliveSet = setmetatable({}, {
			__mode = "k"
		})
		__classAliveInstances[typeName] = aliveSet
	end

	aliveSet[inst] = true
end

local __defaultMethods = {
	preDestroy = false,
	destroy = false,
	start = false,
	postInit = false,
	init = false,
	preInit = false,
	ctor = false
}
local __constructMethods = {
	start = true,
	postInit = true,
	init = true,
	preInit = true,
	ctor = true
}
local __worldxAoiMethods = {
	getAoiClients = true,
	getOwnClient = true,
	clientMsg = true,
	serverMsg = true
}
local reload = false
local ignoreDup = false
local __logger

function Class.setLogger(logger)
	__logger = logger
end

local function __createDefaultMethodFunc(classType, name, overrideFunc)
	local retFunction

	if __constructMethods[name] then
		function retFunction(...)
			if overrideFunc then
				overrideFunc(...)
			elseif classType.superType then
				local superMethod = classType.superType[name]

				if superMethod ~= nil and type(superMethod) == "function" then
					superMethod(...)
				end
			end

			local components = classType.components

			for i = 1, #components do
				local component = components[i]
				local v = component[name]

				if v and type(v) == "function" then
					local isOk, result = xpcall(v, debug.traceback, ...)

					if not isOk and __logger then
						local obj = select(1, ...)
						local ownerClass = obj and obj.className or classType.typeName
						local ownerRepr = obj and obj.repr and obj:repr() or tostring(obj)

						__logger:error(string.format("[ComponentError] ownerClass=%s owner=%s component=%s method=%s error=%s", ownerClass, ownerRepr, component.typeName, name, result))
					end
				end
			end

			if name == "start" then
				local obj = select(1, ...)

				if obj.className == classType.typeName and obj.__startfinish ~= nil then
					obj.__startfinish = true

					local cppTree = rawget(obj, "__CppTree__")

					if cppTree then
						phonestcore.cppTreeSetStartFinished(cppTree, true)
					end
				end
			end
		end
	else
		function retFunction(...)
			local components = classType.components

			for i = #components, 1, -1 do
				local v = components[i][name]

				if v and type(v) == "function" then
					local isOk, result = xpcall(v, debug.traceback, ...)

					if not isOk and __logger then
						__logger:error(result)
					end
				end
			end

			if overrideFunc then
				overrideFunc(...)
			elseif classType.superType then
				local superMethod = classType.superType[name]

				if superMethod ~= nil and type(superMethod) == "function" then
					superMethod(...)
				end
			end
		end
	end

	return retFunction
end

function Class.createSingletonClass(cls, ...)
	if cls._instance == nil then
		cls._instance = cls.new(...)
	end

	return cls._instance
end

function Class.setReload(flag, skipOnReload)
	if flag == true then
		reload = flag

		if not skipOnReload then
			Class.BeforeReload()
		end
	else
		if not skipOnReload then
			Class.OnReload()
		end

		reload = flag
	end
end

local TypeNames = {}

function Class.Class(typeName, superType, isSingleton, isBotPlayer, playerClassName)
	local classType = {
		__IsClass = true
	}

	classType.typeName = typeName

	if TypeNames[typeName] ~= nil then
		error("The class name is used already!!!" .. typeName)
	else
		TypeNames[typeName] = classType
	end

	classType._IsSingleton = isSingleton or false
	classType.__forceAttrRepeat = {}
	classType.components = {}
	classType.componentNames = {}
	classType.method2Components = {}
	classType.__flatPostMethodCache = {}
	classType.__Name2PropertyDeclare__ = {}
	classType.__ValueTypeDeclare__ = nil
	classType.__PropertyCallbacks__ = {}
	classType.__TickInterval__ = nil
	classType.superType = superType
	classType.superCachedKeys = {}
	classType.superNilKeys = {}
	classType._inheritsCount = 0

	if superType ~= nil then
		local cache = {}
		local counter = 1
		local curClass = superType

		while curClass do
			cache[counter] = curClass
			counter = counter + 1
			curClass = curClass.superType
		end

		classType._classInherits = cache
		classType._inheritsCount = counter
	end

	if superType then
		if __InheritRelationship[superType] == nil then
			__InheritRelationship[superType] = {}
		end

		table.insert(__InheritRelationship[superType], classType)
	else
		__InheritRelationship[classType] = {}
	end

	local function objToString(self)
		if not self then
			return classType.typeName
		end

		if not self.__instanceName then
			local str = tostring(self)
			local _, _, addr = string.find(str, "table%s*:%s*(0?[xX]?%x+)")

			self.__instanceName = string.format("Class %s : %s", classType.typeName, addr)
		end

		return self.__instanceName
	end

	local function objGetClass(self)
		return classType
	end

	local function objGetType(self)
		return classType.typeName
	end

	local vtbl = {}

	local function objGetClassFunc(self, funcName)
		return vtbl[funcName]
	end

	__ClassTypeList[classType] = vtbl
	classType.__objMetatable = {
		__index = vtbl
	}

	if isBotPlayer then
		classType.__botWhitelist = false
		classType.__botStubCache = {}
		classType.__botReportedSet = {}

		function classType.__objMetatable.__index(obj, key)
			local v = vtbl[key]

			if v ~= nil then
				return v
			end

			local whitelist = classType.__botWhitelist

			if not whitelist then
				whitelist = __buildBotMethodWhitelist(require(playerClassName))
				classType.__botWhitelist = whitelist
			end

			if not whitelist[key] then
				return nil
			end

			local stubCache = classType.__botStubCache
			local stub = stubCache[key]

			if not stub then
				function stub(self, ...)
					local reportedSet = classType.__botReportedSet

					if not reportedSet[key] then
						reportedSet[key] = true

						local log = self and self.logger

						if log then
							log:debug("[BotCompat] %s called unimplemented method '%s'", self.className or typeName, key)
						end
					end
				end

				stubCache[key] = stub
			end

			return stub
		end
	end

	vtbl.toString = objToString
	vtbl.getClass = objGetClass
	vtbl.getClassType = objGetType
	vtbl._getClassFunc = objGetClassFunc
	vtbl.className = classType.typeName

	function classType.new(...)
		local obj = {
			__IsInstance = true
		}

		setmetatable(obj, classType.__objMetatable)
		__recordInstance(classType.typeName, obj)

		if classType.ctor then
			classType.ctor(obj, ...)
		end

		return obj
	end

	if classType._IsSingleton then
		function classType.GetInstance(...)
			return Class.createSingletonClass(classType, ...)
		end
	end

	function classType.setSuperMeta()
		if superType then
			classType.super = setmetatable({}, {
				__index = function(tbl, key)
					local func = __ClassTypeList[superType][key]

					if isCallable(func) then
						tbl[key] = func

						return func
					end
				end
			})
		end
	end

	classType.setSuperMeta()
	setmetatable(classType, {
		__index = vtbl,
		__newindex = function(tbl, key, value)
			if __defaultMethods[key] ~= nil then
				if rawget(vtbl, key) == nil or reload or ignoreDup or classType.__canOverrideDefaumtMethods[key] then
					vtbl[key] = __createDefaultMethodFunc(classType, key, value)

					rawset(vtbl, "_" .. key, value)

					classType.__canOverrideDefaumtMethods[key] = false
				else
					error("class " .. classType.typeName .. " has repeat attr " .. key)
				end
			elseif rawget(vtbl, key) == nil or reload or ignoreDup or classType.__forceAttrRepeat[key] or __worldxAoiMethods[key] then
				vtbl[key] = value

				if isCallable(value) then
					classType.superCachedKeys[key] = nil
				end
			else
				error("class " .. classType.typeName .. " has repeat attr " .. key)
			end
		end,
		__call = function(self, ...)
			if classType._IsSingleton == true then
				return Class.createSingletonClass(classType, ...)
			else
				return classType.new(...)
			end
		end
	})

	function classType.getVtbl()
		return vtbl
	end

	function classType.postComponentMethod(obj, name, ...)
		local flat = classType.__flatPostMethodCache[name]

		if flat == nil then
			flat = {}

			local own = classType.method2Components[name]

			if own then
				for i = 1, #own do
					flat[#flat + 1] = own[i][name]
				end
			end

			local inherits = classType._classInherits

			if inherits then
				for j = 1, #inherits do
					local sup = inherits[j].method2Components
					local supList = sup and sup[name]

					if supList then
						for i = 1, #supList do
							flat[#flat + 1] = supList[i][name]
						end
					end
				end
			end

			classType.__flatPostMethodCache[name] = flat
		end

		if name == "tick" then
			for i = 1, #flat do
				flat[i](obj, ...)
			end

			return
		end

		for i = 1, #flat do
			local result, errorMsg = xpcall(flat[i], debug.traceback, obj, ...)

			if not result and __logger then
				__logger:error(errorMsg)
			end
		end
	end

	classType.__canOverrideDefaumtMethods = {}

	for k, v in pairs(__defaultMethods) do
		classType[k] = nil

		rawset(vtbl, "_" .. k, function()
			return
		end)

		classType.__canOverrideDefaumtMethods[k] = true
	end

	function classType.forceAttrRepeat(cls, key)
		cls.__forceAttrRepeat[key] = true
	end

	function classType.clearAttrRepeat(cls)
		cls.__forceAttrRepeat = {}
	end

	if superType then
		setmetatable(vtbl, {
			__index = function(tbl, key)
				if classType.superNilKeys[key] then
					return nil
				end

				local ret = __ClassTypeList[superType][key]

				if ret == nil and key ~= nil then
					classType.superNilKeys[key] = true
				elseif isCallable(ret) then
					classType.superCachedKeys[key] = true
					vtbl[key] = ret
				end

				return ret
			end
		})
	end

	return classType
end

function Class.OldLightClass(typeName, superType, isSingleton)
	local classType = {
		__IsClass = true,
		__IsOldLightClass = true
	}

	classType.typeName = typeName
	classType._IsSingleton = isSingleton or false

	if TypeNames[typeName] ~= nil then
		error("The class name is used already!!!" .. typeName)
	else
		TypeNames[typeName] = classType
	end

	classType.__forceAttrRepeat = {}
	classType.superType = superType
	classType.superCachedKeys = {}
	classType.superNilKeys = {}
	classType._inheritsCount = 0

	if superType ~= nil then
		local cache = {}
		local counter = 1
		local curClass = superType

		while curClass do
			cache[counter] = curClass
			counter = counter + 1
			curClass = curClass.superType
		end

		classType._classInherits = cache
		classType._inheritsCount = counter
	end

	if superType then
		if __InheritRelationship[superType] == nil then
			__InheritRelationship[superType] = {}
		end

		table.insert(__InheritRelationship[superType], classType)
	else
		__InheritRelationship[classType] = {}
	end

	local function objToString(self)
		if not self then
			return typeName
		end

		if not self.__instanceName then
			local str = tostring(self)
			local _, _, addr = string.find(str, "table%s*:%s*(0?[xX]?%x+)")

			self.__instanceName = string.format("LightClass %s : %s", classType.typeName, addr)
		end

		return self.__instanceName
	end

	local function objGetClass(self)
		return classType
	end

	local function objGetType(self)
		return classType.typeName
	end

	local vtbl = {}

	__ClassTypeList[classType] = vtbl
	classType.__objMetatable = {
		__index = vtbl
	}
	vtbl.toString = objToString
	vtbl.getClass = objGetClass
	vtbl.getClassType = objGetType
	vtbl.className = classType.typeName

	function classType.new(...)
		local obj = {
			__IsInstance = true
		}

		setmetatable(obj, classType.__objMetatable)
		__recordInstance(classType.typeName, obj)

		if classType.ctor then
			classType.ctor(obj, ...)
		end

		return obj
	end

	if classType._IsSingleton then
		function classType.GetInstance(...)
			return Class.createSingletonClass(classType, ...)
		end
	end

	function classType.setSuperMeta()
		if superType then
			classType.super = setmetatable({}, {
				__index = function(tbl, key)
					local func = __ClassTypeList[superType][key]

					if isCallable(func) then
						tbl[key] = func

						return func
					else
						error("Accessing super class field are not allowed!")
					end
				end
			})
		end
	end

	classType.setSuperMeta()
	setmetatable(classType, {
		__index = vtbl,
		__newindex = function(tbl, key, value)
			if rawget(vtbl, key) == nil or reload or ignoreDup or classType.__forceAttrRepeat[key] then
				vtbl[key] = value

				if isCallable(value) then
					classType.superCachedKeys[key] = nil
				end
			else
				error("class " .. classType.typeName .. " has repeat attr " .. key)
			end
		end,
		__call = function(self, ...)
			if classType._IsSingleton == true then
				return Class.createSingletonClass(classType, ...)
			else
				return classType.new(...)
			end
		end
	})

	function classType.getVtbl()
		return vtbl
	end

	function classType.forceAttrRepeat(cls, key)
		cls.__forceAttrRepeat[key] = true
	end

	function classType.clearAttrRepeat(cls)
		cls.__forceAttrRepeat = {}
	end

	if superType then
		setmetatable(vtbl, {
			__index = function(tbl, key)
				if classType.superNilKeys[key] then
					return nil
				end

				local ret = __ClassTypeList[superType][key]

				if ret == nil and key ~= nil then
					classType.superNilKeys[key] = true
				elseif isCallable(ret) then
					classType.superCachedKeys[key] = true
					vtbl[key] = ret
				end

				return ret
			end
		})
	end

	return classType
end

function Class.LiteClass(typeName, superType)
	local cls = {
		__IsClass = true,
		__IsLiteClass = true
	}

	cls.typeName = typeName
	cls.className = typeName
	cls.__index = cls
	cls.super = superType
	cls.__superCachedKeys = {}

	function cls:getClass()
		return cls
	end

	function cls.new(...)
		local instance = {}

		setmetatable(instance, cls)
		__recordInstance(cls.typeName, instance)

		local ctor = cls.ctor

		if ctor then
			ctor(instance, ...)
		end

		return instance
	end

	if superType then
		setmetatable(cls, {
			__index = function(t, key)
				local v = superType[key]

				if v ~= nil then
					rawset(t, key, v)

					cls.__superCachedKeys[key] = true
				end

				return v
			end,
			__call = function(self, ...)
				return cls.new(...)
			end
		})
	else
		setmetatable(cls, {
			__call = function(self, ...)
				return cls.new(...)
			end
		})
	end

	local function objGetType(self)
		return cls.typeName
	end

	cls.getClassType = objGetType
	__LiteClassList[typeName] = cls

	return cls
end

Class.LightClass = Class.LiteClass

function Class.isSubClassOf(cls, otherCls)
	if type(cls) ~= "table" or type(otherCls) ~= "table" then
		return false
	end

	return cls.__IsClass and otherCls.__IsClass and cls.superType and (cls.superType == otherCls or Class.isSubClassOf(cls.superType, otherCls))
end

function Class.isInstanceOf(obj, cls)
	if type(obj) ~= "table" or type(cls) ~= "table" then
		return false
	end

	if not obj.__IsInstance or not cls.__IsClass then
		return false
	end

	local objClass = obj:getClass()

	return objClass ~= nil and (cls == objClass or Class.isSubClassOf(objClass, cls))
end

local __ComponentRelationship = {}
local ComponentNames = {}

local function __defaultComponentMethod(...)
	return true
end

function Class.Component(typeName, superType)
	local componentType = {}

	componentType.__IsComponent = true
	componentType.typeName = typeName
	componentType.__Name2PropertyDeclare__ = {}
	componentType.__Name2ComponentMethod__ = {}
	componentType.__IsParseReady = false
	componentType.__PropertyCallbacks__ = {}
	componentType.__forceAttrRepeat = {}

	function componentType.forceAttrRepeat(comp, key)
		comp.__forceAttrRepeat[key] = true
	end

	function componentType.clearAttrRepeat(comp)
		comp.__forceAttrRepeat = {}
	end

	if ComponentNames[typeName] ~= nil then
		error("The component name is used already!!!" .. typeName)
	else
		ComponentNames[typeName] = componentType
	end

	componentType.super = nil

	if superType ~= nil then
		if not superType.__IsComponent then
			error("The superType must be a component ")
		end

		componentType.super = superType
	end

	componentType.superPostKeys = {}
	componentType.superDefaultKeys = {}

	local vtbl = {}

	componentTypeToVtbl[componentType] = vtbl

	setmetatable(componentType, {
		__index = vtbl,
		__newindex = function(tbl, key, value)
			if rawget(vtbl, key) ~= nil and not reload and not ignoreDup and __defaultMethods[key] == nil and componentType.__forceAttrRepeat[key] == nil then
				error("component " .. typeName .. " has repeat attr " .. key)
			else
				rawset(vtbl, key, value)
			end
		end
	})

	for k, v in pairs(__defaultMethods) do
		if not componentType[k] then
			componentType[k] = __defaultComponentMethod
		end
	end

	return componentType
end

local function _addComponentAttr(cls, component)
	local applyType = component.super

	while applyType ~= nil do
		for name, _ in pairs(applyType.__Name2ComponentMethod__) do
			local superFunc = applyType[name]

			if component[name] == nil then
				component[name] = superFunc
				component.superPostKeys[name] = true
				component.__Name2ComponentMethod__[name] = true
			end
		end

		applyType = applyType.super
	end

	local applyAttrs = {}

	applyType = component

	while applyType ~= nil do
		local realTable = componentTypeToVtbl[applyType]

		for name, attr in pairs(realTable) do
			if name ~= "__CLASS_NAME__" and applyType.__Name2ComponentMethod__[name] == nil and __defaultMethods[name] == nil then
				if not isCallable(attr) then
					error(string.format("[ERROR] The component attr %s can not be called", name))
				end

				if applyAttrs[name] == nil then
					applyAttrs[name] = attr
				end
			end
		end

		applyType = applyType.super
	end

	for name, attr in pairs(applyAttrs) do
		if cls[name] == nil or reload or ignoreDup or __worldxAoiMethods[name] then
			cls[name] = attr
		else
			error(string.format("[WARNING] The attribute name %s is already in the Class %s! or super", name, cls.toString(cls)))
		end
	end

	applyType = component.super

	while applyType ~= nil do
		for name, _ in pairs(__defaultMethods) do
			local superDefaultFunc = applyType[name]

			if superDefaultFunc ~= __defaultComponentMethod and component[name] == __defaultComponentMethod then
				component.superDefaultKeys[name] = true
				component[name] = superDefaultFunc
			end
		end

		applyType = applyType.super
	end
end

local function _addComponentPropertyCallbacks(cls, component)
	for opType, callbacks in pairs(component.__PropertyCallbacks__) do
		if cls.__PropertyCallbacks__[opType] == nil then
			cls.__PropertyCallbacks__[opType] = {}
		end

		for keyPath, callback in pairs(callbacks) do
			if cls.__PropertyCallbacks__[opType][keyPath] ~= nil and not reload and not ignoreDup then
				error(string.format("[WARNING] The propertyCallback %s is already in the Class %s!", keyPath, cls.toString(cls)))
			else
				cls.__PropertyCallbacks__[opType][keyPath] = callback
			end
		end
	end
end

local function _addComponentProperties(cls, component)
	for name, declare in pairs(component.__Name2PropertyDeclare__) do
		if cls.__Name2PropertyDeclare__[name] ~= nil and not reload and not ignoreDup then
			error(string.format("[WARNING] The property %s is already in the Class %s!", name, cls.toString(cls)))
		else
			cls.__Name2PropertyDeclare__[name] = declare
		end
	end
end

local function _addComponent(cls, component)
	assert(component.__IsComponent, "must be a component")
	assert(component.typeName ~= nil, "component must have a name")
	assert(ComponentNames[component.typeName] ~= nil, "component must register")
	assert(cls.__IsClass and not cls.__IsOldLightClass, "only class can add component")
	assert(cls.componentNames[component.typeName] == nil, "class already has same component " .. component.typeName)
	assert(component.__IsParseReady, "component " .. component.typeName .. " must be ready to add")

	cls.componentNames[component.typeName] = true
	cls.components[#cls.components + 1] = component

	_addComponentProperties(cls, component)
	_addComponentPropertyCallbacks(cls, component)
	_addComponentAttr(cls, component)

	for name, _ in pairs(component.__Name2ComponentMethod__) do
		if cls.method2Components[name] == nil then
			cls.method2Components[name] = {}
		end

		table.insert(cls.method2Components[name], component)
	end
end

function Class.AddComponents(cls, components, ignoreDupCheck)
	if ignoreDupCheck then
		ignoreDup = true
	end

	for i = 1, #components do
		local component = components[i]

		_addComponent(cls, component)
	end

	if ignoreDupCheck then
		ignoreDup = false
	end
end

function Class.AddComponent(cls, ...)
	local n = select("#", ...)

	for i = 1, n do
		local v = select(i, ...)

		_addComponent(cls, v)
	end
end

function Class.BeforeReload()
	for _, cls in pairs(TypeNames) do
		cls.setSuperMeta()

		for k, _ in pairs(cls.superCachedKeys) do
			cls[k] = nil
		end

		cls.superCachedKeys = {}
		cls.superNilKeys = {}
		cls.__flatPostMethodCache = {}

		if cls.__botStubCache then
			cls.__botWhitelist = false
			cls.__botStubCache = {}
			cls.__botReportedSet = {}
		end
	end

	for _, cls in pairs(__LiteClassList) do
		for k, _ in pairs(cls.__superCachedKeys) do
			cls[k] = nil
		end

		cls.__superCachedKeys = {}
	end

	for _, component in pairs(ComponentNames) do
		for k, _ in pairs(component.superPostKeys) do
			component[k] = nil
		end

		component.superPostKeys = {}

		for k, _ in pairs(component.superDefaultKeys) do
			component[k] = __defaultComponentMethod
		end

		component.superDefaultKeys = {}
	end
end

function Class.OnReload()
	for name, cls in pairs(TypeNames) do
		if not cls.__IsOldLightClass then
			for _, component in ipairs(cls.components) do
				_addComponentAttr(cls, component)
			end
		end
	end
end

function Class.profileInstanceCount()
	local ret = {}

	for typeName, aliveSet in pairs(__classAliveInstances) do
		local alive = 0

		for _ in pairs(aliveSet) do
			alive = alive + 1
		end

		ret[typeName] = {
			alive = alive,
			created = __classCreatedCount[typeName] or 0
		}
	end

	for typeName, created in pairs(__classCreatedCount) do
		if ret[typeName] == nil then
			ret[typeName] = {
				alive = 0,
				created = created
			}
		end
	end

	return ret
end

return Class
