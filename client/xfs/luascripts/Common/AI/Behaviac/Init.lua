-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Init.lua

local Utils = require("Common.Utils.Utils")
local lib_behaviac = {
	_LICENSE = "MIT/X11",
	_VERSION = "1.0.0.1",
	_URL = "http://",
	_DESCRIPTION = "Behaviac Lib..."
}
local _M = lib_behaviac

_M.functions = require("Common.AI.Behaviac.Functions")
_M.macros = require("Common.AI.Behaviac.Macros")
_M.debugger = require("Common.AI.Behaviac.Debugger")
_M.enums = require("Common.AI.Behaviac.Enums")
_M.BaseAgent = require("Common.AI.Behaviac.Agent.BaseAgent")
_M.AgentMeta = require("Common.AI.Behaviac.Agent.AgentMeta")
_M.BehaviorTreeFactory = require("Common.AI.Behaviac.Parser.BehaviorTreeFactory")
_M.NodeFactory = require("Common.AI.Behaviac.Parser.NodeFactory")

_M.AgentMeta.setBehaviorTreeFolder("Common/Data/BehaviacData/")
_M.AgentMeta.loadLuaMeta()

return _M
