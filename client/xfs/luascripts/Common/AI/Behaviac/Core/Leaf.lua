-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Core\\Leaf.lua

local enums = require("Common.AI.Behaviac.Enums")
local common = require("Common.AI.Behaviac.Common")
local macros = require("Common.AI.Behaviac.Macros")
local functions = require("Common.AI.Behaviac.Functions")
local EBTStatus = enums.EBTStatus
local ENodePhase = enums.ENodePhase
local EPreconditionPhase = enums.EPreconditionPhase
local TriggerMode = enums.TriggerMode
local EOperatorType = enums.EOperatorType
local constSupportedVersion = enums.constSupportedVersion
local constInvalidChildIndex = enums.constInvalidChildIndex
local constBaseKeyStrDef = enums.constBaseKeyStrDef
local constPropertyValueType = enums.constPropertyValueType
local Logging = common.d_log
local StringUtils = common.StringUtils
local BaseNode = require("Common.AI.Behaviac.Core.BaseNode")
local Leaf = functions.class("Leaf", BaseNode)

macros.ADD_BEHAVIAC_DYNAMIC_TYPE("Leaf", Leaf)
macros.BEHAVIAC_DECLARE_DYNAMIC_TYPE("Leaf", "BaseNode")

local _M = Leaf

function _M:ctor()
	_M.super.ctor(self)
end

function _M:release()
	_M.super.release(self)
end

function _M:isLeaf()
	return true
end

function _M:traverse(childFirst, handler, agent, tick, userData)
	handler(self, agent, tick, userData)
end

return _M
