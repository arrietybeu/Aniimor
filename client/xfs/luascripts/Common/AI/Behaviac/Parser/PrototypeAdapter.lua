-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Parser\\PrototypeAdapter.lua

local enums = require("Common.AI.Behaviac.Enums")
local macros = require("Common.AI.Behaviac.Macros")
local functions = require("Common.AI.Behaviac.Functions")
local PrototypeAdapter = functions.class("PrototypeAdapter")

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("PrototypeAdapter", PrototypeAdapter)

local _M = PrototypeAdapter
local ParamAdapter = require("Common.AI.Behaviac.Parser.ParamAdapter")

function _M:ctor()
	self.prototypeName = false
	self.paramProperties = {}
end

function _M:setTaskParams(agent, tick, subTreeTick)
	local params = {}

	for i, paramProp in ipairs(self.paramProperties) do
		local paramName = enums.BEHAVIAC_LOCAL_TASK_PARAM_PRE .. tostring(i - 1)

		table.insert(params, {
			paramName,
			paramProp:getValue(agent, tick)
		})
	end

	if not subTreeTick then
		assert(false)
	end

	return subTreeTick:addLocalVariables(params)
end

function _M:buildTaskPrototype(prototypeName, paramStr)
	self.prototypeName = prototypeName
	self.paramProperties = ParamAdapter.s_createParamProperties(paramStr)
end

return _M
