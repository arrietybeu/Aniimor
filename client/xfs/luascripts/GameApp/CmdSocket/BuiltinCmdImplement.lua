-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\CmdSocket\\BuiltinCmdImplement.lua

local LoggerManager = require("Core.Log.LoggerManager")
local Const = require("Common.Const.Const")
local logger = LoggerManager.getLogger("BuiltinCmdImplement")
local BuiltinCmdImplement = {}

BuiltinCmdImplement.noAuth = {
	auth = true,
	ping = true
}

function BuiltinCmdImplement.auth(self_, connId, params)
	local token = params and params.token or ""

	if pg.global.cmdSocketMgr:CheckAuthToken(token) then
		self_.authedConns[connId] = true

		local ok, homelandDemoCmdImplement = pcall(require, "GameApp.CmdSocket.HomelandDemoCmdImplement")

		if ok and type(homelandDemoCmdImplement) == "table" and type(homelandDemoCmdImplement._onConnectionAuthed) == "function" then
			local hookOk, hookErr = xpcall(function()
				homelandDemoCmdImplement._onConnectionAuthed(connId)
			end, debug.traceback)

			if not hookOk then
				logger:warn("homelandDemo auth hook failed connId=%s err=%s", tostring(connId), tostring(hookErr))
			end
		end

		return {
			ok = true,
			data = {
				authed = true
			}
		}
	end

	return {
		ok = false,
		error = {
			msg = "invalid token",
			code = Const.CMD_SOCKET_ERROR.AUTH
		}
	}
end

function BuiltinCmdImplement.ping(self_, connId, params)
	return {
		ok = true,
		data = {
			pong = true,
			ts = os.time()
		}
	}
end

function BuiltinCmdImplement.echo(self_, connId, params)
	return {
		ok = true,
		data = params or {}
	}
end

return BuiltinCmdImplement
