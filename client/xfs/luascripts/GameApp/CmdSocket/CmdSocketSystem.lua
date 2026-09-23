-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\CmdSocket\\CmdSocketSystem.lua

local Class = require("Core.Framework.Class")
local SystemBase = require("GameApp.Core.SystemBase")
local LoggerManager = require("Core.Log.LoggerManager")
local json = require("json")
local Const = require("Common.Const.Const")
local CmdImplement = require("GameApp.CmdSocket.CmdImplement")
local logger = LoggerManager.getLogger("CmdSocketSystem")
local CmdSocketSystem = Class.LightClass("CmdSocketSystem", SystemBase)

CmdSocketSystem.MAX_JSON_DEPTH = 16

function CmdSocketSystem._isPositiveIntegerKey(key)
	return type(key) == "number" and key >= 1 and key == math.floor(key)
end

function CmdSocketSystem._isArrayTable(tbl)
	local maxIndex = 0
	local count = 0

	for key, _ in pairs(tbl) do
		if not CmdSocketSystem._isPositiveIntegerKey(key) then
			return false
		end

		if maxIndex < key then
			maxIndex = key
		end

		count = count + 1
	end

	return maxIndex == count
end

function CmdSocketSystem._toJsonSafe(value, depth, seen)
	local valueType = type(value)

	if valueType == "nil" or valueType == "boolean" or valueType == "number" or valueType == "string" then
		return value
	end

	if valueType ~= "table" then
		return tostring(value)
	end

	depth = depth or 0

	if depth > CmdSocketSystem.MAX_JSON_DEPTH then
		return "<max-depth>"
	end

	seen = seen or {}

	if seen[value] then
		return "<cycle>"
	end

	seen[value] = true

	local result = {}

	if CmdSocketSystem._isArrayTable(value) then
		for index = 1, #value do
			result[index] = CmdSocketSystem._toJsonSafe(value[index], depth + 1, seen)
		end
	else
		for key, child in pairs(value) do
			result[tostring(key)] = CmdSocketSystem._toJsonSafe(child, depth + 1, seen)
		end
	end

	seen[value] = nil

	return result
end

function CmdSocketSystem:onCtor(name)
	self.cmdPrefixes = {}
	self.authedConns = {}

	CmdImplement.registerAll(self)
end

function CmdSocketSystem:onInit()
	return
end

function CmdSocketSystem:startServer()
	local mgr = pg.global.cmdSocketMgr

	if not mgr then
		logger:error("startServer failed: cmdSocketMgr not ready")

		return false
	end

	if self:isServerRunning() then
		logger:info("startServer already")

		return true
	end

	local ok = mgr:StartServer()

	if ok then
		logger:info("cmd socket server started, port=%s", tostring(mgr:GetActivePort()))
	else
		logger:error("cmd socket server start failed")
	end

	return ok
end

function CmdSocketSystem:stopServer()
	local mgr = pg.global.cmdSocketMgr

	if not mgr then
		return
	end

	mgr:StopServer()
	logger:info("cmd socket server stopped")
end

function CmdSocketSystem:isServerRunning()
	local mgr = pg.global.cmdSocketMgr

	if not mgr then
		return false
	end

	return mgr:IsRunning()
end

function CmdSocketSystem:onDestroy()
	self.cmdPrefixes = {}
	self.authedConns = {}
end

function CmdSocketSystem:registerPrefix(prefix, modulePath, opts)
	opts = opts or {}

	local requireAuth = opts.requireAuth

	if requireAuth == nil then
		requireAuth = true
	end

	self.cmdPrefixes[prefix] = {
		modulePath = modulePath,
		requireAuth = requireAuth
	}
end

function CmdSocketSystem:onConnectionOpen(connId)
	self.authedConns[connId] = nil

	if pg.global.cmdSocketMgr:HasAuthToken() ~= true then
		self.authedConns[connId] = true

		local ok, homelandDemoCmdImplement = pcall(require, "GameApp.CmdSocket.HomelandDemoCmdImplement")

		if ok and type(homelandDemoCmdImplement) == "table" and type(homelandDemoCmdImplement._onConnectionAuthed) == "function" then
			local hookOk, hookErr = xpcall(function()
				homelandDemoCmdImplement._onConnectionAuthed(connId)
			end, debug.traceback)

			if not hookOk then
				logger:warn("homelandDemo onConnectionOpen failed connId=%s err=%s", tostring(connId), tostring(hookErr))
			end
		end
	end

	logger:info("connection open #" .. tostring(connId))
end

function CmdSocketSystem:onConnectionClose(connId)
	self.authedConns[connId] = nil

	local ok, homelandDemoCmdImplement = pcall(require, "GameApp.CmdSocket.HomelandDemoCmdImplement")

	if ok and type(homelandDemoCmdImplement) == "table" and type(homelandDemoCmdImplement._onConnectionClose) == "function" then
		local hookOk, hookErr = xpcall(function()
			homelandDemoCmdImplement._onConnectionClose(connId)
		end, debug.traceback)

		if not hookOk then
			logger:warn("homelandDemo onConnectionClose failed connId=%s err=%s", tostring(connId), tostring(hookErr))
		end
	end

	logger:info("connection close #" .. tostring(connId))
end

function CmdSocketSystem:onMessage(connId, jsonStr)
	local ok, err = xpcall(function()
		self:_dispatch(connId, jsonStr)
	end, debug.traceback)

	if not ok then
		logger:error("onMessage failure: " .. tostring(err))
		self:_safeSend(connId, self:_buildError(nil, Const.CMD_SOCKET_ERROR.INTERNAL, "internal error"))
	end
end

function CmdSocketSystem:_dispatch(connId, jsonStr)
	local okDecode, req = pcall(json.decode, jsonStr)

	if not okDecode or type(req) ~= "table" then
		self:_safeSend(connId, self:_buildError(nil, Const.CMD_SOCKET_ERROR.PARSE, "invalid json"))

		return
	end

	local cmd = req.cmd
	local entry = cmd and self:_resolveCmd(cmd)

	if not entry then
		self:_safeSend(connId, self:_buildError(req.id, Const.CMD_SOCKET_ERROR.UNKNOWN_CMD, "unknown cmd: " .. tostring(cmd)))

		return
	end

	if entry.requireAuth and not self:_isAuthed(connId) then
		self:_safeSend(connId, self:_buildError(req.id, Const.CMD_SOCKET_ERROR.AUTH, "not authenticated"))

		return
	end

	local params = req.params or {}
	local handlerOk, result = xpcall(entry.handler, debug.traceback, self, connId, params)

	if not handlerOk then
		logger:error("handler '" .. tostring(cmd) .. "' threw: " .. tostring(result))
		self:_safeSend(connId, self:_buildError(req.id, Const.CMD_SOCKET_ERROR.INTERNAL, "handler error"))

		return
	end

	if type(result) ~= "table" then
		self:_safeSend(connId, self:_buildError(req.id, Const.CMD_SOCKET_ERROR.INTERNAL, "handler returned non-table"))

		return
	end

	local resp = {
		id = req.id,
		ok = result.ok and true or false
	}

	if result.ok then
		resp.data = result.data or {}
	else
		resp.error = result.error or {
			msg = "unspecified error",
			code = Const.CMD_SOCKET_ERROR.INTERNAL
		}
	end

	self:_safeSend(connId, resp)
end

function CmdSocketSystem:_resolveCmd(cmd)
	local prefix, action
	local dot = string.find(cmd, ".", 1, true)

	if dot then
		if dot == 1 or dot == #cmd then
			return nil
		end

		prefix = string.sub(cmd, 1, dot - 1)
		action = string.sub(cmd, dot + 1)
	else
		prefix = ""
		action = cmd
	end

	if string.sub(action, 1, 1) == "_" then
		return nil
	end

	local entry = self.cmdPrefixes[prefix]

	if not entry then
		return nil
	end

	local ok, mod = pcall(require, entry.modulePath)

	if not ok then
		logger:error("require '" .. entry.modulePath .. "' failed: " .. tostring(mod))

		return nil
	end

	if type(mod) ~= "table" then
		return nil
	end

	local fn = mod[action]

	if type(fn) ~= "function" then
		return nil
	end

	local requireAuth = entry.requireAuth

	if mod.noAuth and mod.noAuth[action] then
		requireAuth = false
	end

	return {
		handler = fn,
		requireAuth = requireAuth
	}
end

function CmdSocketSystem:_isAuthed(connId)
	if not pg.global.cmdSocketMgr:HasAuthToken() then
		return true
	end

	return self.authedConns[connId] == true
end

function CmdSocketSystem:_buildError(id, code, msg)
	return {
		ok = false,
		id = id,
		error = {
			code = code,
			msg = msg
		}
	}
end

function CmdSocketSystem:pushEvent(connId, topic, data, seq, time)
	if type(topic) ~= "string" or topic == "" then
		return
	end

	local event = {
		type = "event",
		topic = topic,
		data = data or {}
	}

	if seq ~= nil then
		event.seq = seq
	end

	if time ~= nil then
		event.time = time
	end

	self:_safeSend(connId, event)
end

function CmdSocketSystem:_safeSend(connId, respTbl)
	local safeResp = CmdSocketSystem._toJsonSafe(respTbl)
	local ok, encoded = pcall(json.encode, safeResp)

	if not ok then
		logger:error("encode response failed: " .. tostring(encoded))

		local fallback = {
			ok = false,
			id = respTbl and respTbl.id or nil,
			error = {
				msg = "encode response failed",
				code = Const.CMD_SOCKET_ERROR.INTERNAL
			}
		}
		local fallbackOk, fallbackEncoded = pcall(json.encode, fallback)

		if not fallbackOk then
			return
		end

		encoded = fallbackEncoded
	end

	pg.global.cmdSocketMgr:SendString(connId, encoded)
end

return CmdSocketSystem
