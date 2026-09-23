-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\PropertySync\\CustomTypeFactory.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("CustomTypeFactory")
local CustomTypeFactory = {
	_customTypes = {}
}

function CustomTypeFactory.hasRegistered(name)
	return CustomTypeFactory._customTypes[name] ~= nil
end

function CustomTypeFactory.register(name, cls)
	if CustomTypeFactory._customTypes[name] ~= nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("repeat register custom class %s", name)
		end
	else
		CustomTypeFactory._customTypes[name] = cls
	end
end

function CustomTypeFactory.create(name, initDict)
	local customCls = CustomTypeFactory._customTypes[name]

	if customCls == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("create custom property failed: can not find custom class %s", name)
		end

		return nil
	end

	initDict = initDict or {}

	local customObj = customCls()

	customObj:init(initDict)

	return customObj
end

function CustomTypeFactory.createReadonly(clstype, name, value, owner, parent, fixed, aoiscopeForLazy)
	local customCls = CustomTypeFactory._customTypes[clstype]

	if customCls == nil then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("create custom property failed: can not find custom class %s", clstype)
		end

		return nil
	end

	local customObj = customCls()

	customObj:roinit(name, value, owner, parent, fixed, aoiscopeForLazy)

	return customObj
end

return CustomTypeFactory
