-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Debugger.lua

local _M = {
	lib = false,
	wait_on_startup = false,
	server_mode = true,
	start_debug = false
}

function _M.openDebug()
	local AgentMeta = require("Common.AI.Behaviac.Agent.AgentMeta")
	local BehaviorTree = require("Common.AI.Behaviac.Core.BehaviorTree")
	local Tick = require("Common.AI.Behaviac.Agent.Tick")

	AgentMeta.switchToDebugMode(true)
	BehaviorTree.switchToDebugMode(true)
	Tick.switchToDebugMode(true)

	_M.lib = require("Common.AI.Behaviac.Debug.btdebugger")

	_M.lib.startDebugger(_M.wait_on_startup, _M.server_mode)
end

function _M.acceptConnect()
	_M.lib.reset()
	_M.lib.tryDebugger(5)

	_M.start_debug = true
end

function _M.closeDebug()
	local AgentMeta = require("Common.AI.Behaviac.Agent.AgentMeta")
	local BehaviorTree = require("Common.AI.Behaviac.Core.BehaviorTree")
	local Tick = require("Common.AI.Behaviac.Agent.Tick")

	AgentMeta.switchToDebugMode(false)
	BehaviorTree.switchToDebugMode(false)
	Tick.switchToDebugMode(false)

	_M.lib = require("Common.AI.Behaviac.Debug.btdebugger")

	_M.lib.finishDebugger()
end

return _M
