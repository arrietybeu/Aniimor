-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\ClientSandboxUtils.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local logger = LoggerManager.getLogger("ClientSandboxUtils")
local ClientSandboxUtils = {}

function ClientSandboxUtils.debugGetSandboxInfo()
	if not pg.me then
		return
	end

	pg.me:serverSpaceMsg("RPC_CS_DebugGetSandboxInfo", {})
end

function ClientSandboxUtils.setCsCallback(callback)
	ClientSandboxUtils.csCallback = callback
end

function ClientSandboxUtils.callCsCallback(infos)
	if ClientSandboxUtils.csCallback then
		ClientSandboxUtils.csCallback(infos)
	end
end

function ClientSandboxUtils.setDebugLoadSandbox(infos)
	if not pg.me then
		return
	end

	pg.me:serverSpaceMsg("RPC_CS_DebugLoadSandbox", {
		infos
	})
end

return ClientSandboxUtils
