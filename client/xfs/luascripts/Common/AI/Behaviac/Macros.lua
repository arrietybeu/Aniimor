-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Macros.lua

local macros = {}
local NODE_FACTORY = {}
local common = require("Common.AI.Behaviac.Common")
local Logging = common.d_log

function macros.REGISTER_NODE_CTOR(nodeName, ctor)
	assert(type(nodeName) == "string", string.format("REGISTER_NODE_CTOR param nodeName is not string (%s)", type(nodeName)))
	assert(type(ctor) == "function", string.format("REGISTER_NODE_CTOR param fun is not function (%s)", type(ctor)))

	if NODE_FACTORY[nodeName] then
		Logging.error("REGISTER_NODE_CTOR: error -- node(%s) duplicated!!!", nodeName)

		return
	end

	NODE_FACTORY[nodeName] = ctor
end

function macros.REGISTER_NODE_CLASS(nodeName, nodeClass)
	assert(type(nodeName) == "string", string.format("REGISTER_NODE_CLASS param nodeName is not string (%s)", type(nodeName)))
	assert(type(nodeClass) == "table", string.format("REGISTER_NODE_CLASS param nodeClass is not table (%s)", type(nodeClass)))
	assert(type(nodeClass.new) == "function", string.format("REGISTER_NODE_CLASS param nodeClass has not new function"))

	if NODE_FACTORY[nodeName] then
		Logging.error("REGISTER_NODE_CLASS: error -- node(%s) duplicated!!!", nodeName)

		return
	end

	NODE_FACTORY[nodeName] = nodeClass.new
end

function macros.FACTORY_CREATE_NODE(nodeName)
	if not NODE_FACTORY[nodeName] then
		Logging.error("FACTORY_CREATE_NODE: error -- node(%s) does not exist!!!", nodeName)

		return nil
	else
		return NODE_FACTORY[nodeName]()
	end
end

local FATHER_CLASS_INFO = {}
local BEHAVIAC_DYNAMIC_TYPES = {}
local STATIC_BEHAVIAC_HierarchyLevels = setmetatable({}, {
	__index = function()
		return 0
	end
})

macros.NODE_FACTORY = NODE_FACTORY
macros.FATHER_CLASS_INFO = FATHER_CLASS_INFO
macros.BEHAVIAC_DYNAMIC_TYPES = BEHAVIAC_DYNAMIC_TYPES
macros.STATIC_BEHAVIAC_HierarchyLevels = STATIC_BEHAVIAC_HierarchyLevels

function macros.ADD_BEHAVIAC_DYNAMIC_TYPE(className, classDeclare)
	if BEHAVIAC_DYNAMIC_TYPES[className] and BEHAVIAC_DYNAMIC_TYPES[className] ~= classDeclare then
		assert(false, "ADD_BEHAVIAC_DYNAMIC_TYPE had add different TYPE " .. className)

		return
	end

	classDeclare.__name = className

	function classDeclare:getName()
		return self.__name or "no name"
	end

	BEHAVIAC_DYNAMIC_TYPES[className] = classDeclare

	macros.REGISTER_NODE_CLASS(className, classDeclare)
end

function macros.BEHAVIAC_INTERNAL_DECLARE_DYNAMIC_TYPE_COMPOSER(className)
	assert(BEHAVIAC_DYNAMIC_TYPES[className], string.format("BEHAVIAC_INTERNAL_DECLARE_DYNAMIC_TYPE_COMPOSER %s must be called after ADD_BEHAVIAC_DYNAMIC_TYPE", className))

	BEHAVIAC_DYNAMIC_TYPES[className].sm_HierarchyLevel = 0
	BEHAVIAC_DYNAMIC_TYPES[className].getClassTypeName = function(self)
		return className
	end
end

function macros.BEHAVIAC_INTERNAL_DECLARE_DYNAMIC_PUBLIC_METHODS(nodeClassName, fatherClassName)
	assert(BEHAVIAC_DYNAMIC_TYPES[nodeClassName], string.format("BEHAVIAC_INTERNAL_DECLARE_DYNAMIC_PUBLIC_METHODS %s must be called after ADD_BEHAVIAC_DYNAMIC_TYPE", nodeClassName))
	assert(BEHAVIAC_DYNAMIC_TYPES[fatherClassName], string.format("BEHAVIAC_INTERNAL_DECLARE_DYNAMIC_PUBLIC_METHODS %s must be called after ADD_BEHAVIAC_DYNAMIC_TYPE", fatherClassName))

	STATIC_BEHAVIAC_HierarchyLevels[nodeClassName] = STATIC_BEHAVIAC_HierarchyLevels[fatherClassName] + 1
	BEHAVIAC_DYNAMIC_TYPES[nodeClassName].sm_HierarchyLevel = STATIC_BEHAVIAC_HierarchyLevels[nodeClassName]

	local checkFunName = string.format("is%s", string.sub(nodeClassName, 2, -1))

	BEHAVIAC_DYNAMIC_TYPES[nodeClassName][checkFunName] = function()
		return true
	end

	local rootFatherName = fatherClassName
	local fName = fatherClassName

	while fName do
		fName = FATHER_CLASS_INFO[fName]

		if fName then
			rootFatherName = fName
		end
	end

	if rootFatherName and not BEHAVIAC_DYNAMIC_TYPES[rootFatherName][checkFunName] then
		BEHAVIAC_DYNAMIC_TYPES[rootFatherName][checkFunName] = function()
			return false
		end
	end

	BEHAVIAC_DYNAMIC_TYPES[nodeClassName].getClassHierarchyInfoDecl = function(self)
		Logging.error("getClassHierarchyInfoDecl ????????")

		return "getClassHierarchyInfoDecl"
	end
	BEHAVIAC_DYNAMIC_TYPES[nodeClassName].getHierarchyInfo = function(self)
		local decl = self:getClassHierarchyInfoDecl()

		if not decl.m_szCassTypeName then
			decl:InitClassLayerInfo(self:getClassTypeName(), BEHAVIAC_DYNAMIC_TYPES[fatherClassName]:getHierarchyInfo())
		end

		return decl
	end
	BEHAVIAC_DYNAMIC_TYPES[nodeClassName].getClassTypeId = function(self)
		Logging.error("getClassTypeId = %s", nodeClassName)

		return 1
	end
	BEHAVIAC_DYNAMIC_TYPES[nodeClassName].isClassAKindOf = function(self)
		return true
	end
	BEHAVIAC_DYNAMIC_TYPES[nodeClassName].dynamicCast = function(self, other)
		Logging.error("dynamicCast use is%s fun", string.sub(nodeClassName, 2, -1))

		return false
	end
end

function macros.BEHAVIAC_ASSERT(check, msgFormat, ...)
	if not check then
		Logging.error("BEHAVIAC_ASSERT " .. msgFormat, ...)
	end
end

function macros.BEHAVIAC_DECLARE_DYNAMIC_TYPE(nodeClassName, fatherClassName)
	FATHER_CLASS_INFO[nodeClassName] = fatherClassName

	macros.BEHAVIAC_INTERNAL_DECLARE_DYNAMIC_TYPE_COMPOSER(nodeClassName)
	macros.BEHAVIAC_INTERNAL_DECLARE_DYNAMIC_PUBLIC_METHODS(nodeClassName, fatherClassName)
end

return macros
