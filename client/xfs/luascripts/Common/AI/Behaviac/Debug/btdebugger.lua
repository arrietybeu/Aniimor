-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\Behaviac\\Debug\\btdebugger.lua

local require = require
local io = io or require("io")
local table = table or require("table")
local string = string or require("string")
local unpack = table.unpack or unpack
local utils = require("Utils.Utils")
local AiConst = require("Common.Const.AiConst")
local AiUtils = require("Common.Utils.AIUtils")
local bit = require("Common.Bitset")
local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local logger = LoggerManager.getLogger("btdebugger")
local crc32_table = {}

for i = 1, 256 do
	local crc = i - 1

	for _ = 1, 8 do
		crc = bit.band(crc, 1) == 1 and bit.bxor(bit.rshift(crc, 1), 3988292384) or bit.rshift(crc, 1)
	end

	crc32_table[i] = crc
end

local crc32 = {}

function crc32.hash(s)
	local crc = 4294967295

	for i = 1, s:len() do
		crc = bit.bxor(crc32_table[bit.band(bit.bxor(crc, s:byte(i)), 255) + 1], bit.rshift(crc, 8))
	end

	return bit.bxor(crc, 4294967295)
end

local socket = require("Common.AI.Behaviac.Debug.Socket.socket")
local os = os or (function(module)
	local ok, res = pcall(require, module)

	return ok and res or nil
end)("os")
local win = os and os.getenv and (os.getenv("WINDIR") or (os.getenv("OS") or ""):match("[Ww]indows")) and true or false
local mac = not win and (os and os.getenv and os.getenv("DYLD_LIBRARY_PATH") or not io.open("/proc")) and true or false
local iscasepreserving = win or mac and io.open("/library") ~= nil

local function _split_str(str, char)
	local ret = {}
	local e = 1
	local b = string.find(str, char, e)

	while b do
		table.insert(ret, string.sub(str, e, b - 1))

		e = b + 1
		b = string.find(str, char, e)
	end

	table.insert(ret, string.sub(str, e, -1))

	return ret
end

local function _normalize_path(file)
	local n

	repeat
		file, n = file:gsub("/+%.?/+", "/")
	until n == 0

	repeat
		file, n = file:gsub("[^/]+/%.%./", "", 1)
	until n == 0

	return (file:gsub("^(/?)%.%./", "%1"))
end

local function _makeVariableId(idStr)
	return crc32.hash(idStr)
end

local _M = {
	m_applogFilter = false,
	_DESCRIPTION = "Online debugger for behavior tree",
	_COPYRIGHT = "n.lee",
	_NAME = "btdebugger",
	_VERSION = "1.0",
	m_profiling = false,
	m_texts = "",
	m_frame = 0,
	m_seq = 0,
	m_running = false,
	m_client = false,
	m_server = false,
	m_host = "127.0.0.1",
	m_enable = true,
	m_sendBuffer = {},
	m_breakpoints = {},
	m_actions_count = {}
}
local constCommand = {
	kBreakpoint = "[breakpoint]",
	kPlatform = "[platform] Windows \n",
	kHitNumber = "Hit=",
	kWorkspace = "[workspace] lua \\\"\\\"\n",
	kCloseConnection = "[closeconnection]",
	kDebugTargetInfo = "[DebugTargetInfo]",
	kContinue = "[continue]",
	kAppLogFilter = "[applogfilter]",
	kStart = "[start]",
	kProfiling = "[profiling]",
	kProperty = "[property]"
}
local constCommandId = {
	CMDID_TEXT = 2,
	CMDID_INITIAL_SETTINGS = 1
}
local constPlatform = {
	WINDOWS = 0
}
local constEActionResult = {
	EAR_failure = 2,
	EAR_success = 1,
	EAR_none = 0,
	EAR_all = 3
}
local constLogMode = {
	ELM_breaked = 1,
	ELM_tick = 0,
	ELM_log = 5,
	ELM_return = 4,
	ELM_jump = 3,
	ELM_continue = 2
}
local kConstBufferLen = 2048

function _M.reset()
	if _M.m_client then
		_M.m_client:shutdown()

		_M.m_client = false
	end

	_M.m_sendBuffer = {}
	_M.m_seq = 0
	_M.m_frame = 0
end

local function _sendInitialSettings()
	return
end

local function _sendText(text, isProperty)
	if (isProperty and AiConst.AI_DEBUG.NODE_LOG.Console_Send_Property or not isProperty and AiConst.AI_DEBUG.NODE_LOG.Console_Send_Process) and LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:debug("[behaviac] server send: ", text)
	end

	if _M.m_client then
		_M.m_seq = _M.m_seq + 1

		local s = string.format("{\"text\":\"%s\",\"commandID\":2}", text)

		s = string.format("@@@@%04d%s", #s, s)

		table.insert(_M.m_sendBuffer, s)
	end
end

local function _flushSendBuffer()
	if _M.m_client and #_M.m_sendBuffer > 0 then
		local peer = _M.m_client
		local data = table.concat(_M.m_sendBuffer)

		_M.m_sendBuffer = {}

		local _, err = peer:send(data)

		if err == "closed" then
			_M.reset()
		end
	end
end

local function _sendWorkspaceSettings()
	_sendText(constCommand.kPlatform)
	_sendText(constCommand.kWorkspace)
end

local function _sendInitialProperties()
	return
end

local function _sendExistingPackets()
	return
end

local function _sendBtMsg(agent, btMsg, actionResult, mode)
	if not AiUtils.checkDebugEnt(agent.ent.actorId) then
		return
	end

	if btMsg then
		local agentName = agent:getDebugAgentName()
		local actionResultStr = ""

		actionResultStr = actionResult == constEActionResult.EAR_success and "success" or actionResult == constEActionResult.EAR_failure and "failure" or actionResult == constEActionResult.EAR_none and mode == constLogMode.ELM_tick and "running" or "none"

		if mode == constLogMode.ELM_continue then
			local count = _M.getActionCount(btMsg)
			local buffer = string.format("[continue]%s %s [%s] [%d]\n", agentName, btMsg, actionResultStr, count)

			_sendText(buffer)
		elseif mode == constLogMode.ELM_breaked then
			local count = _M.getActionCount(btMsg)
			local buffer = string.format("[breaked]%s %s [%s] [%d]\n", agentName, btMsg, actionResultStr, count)

			_sendText(buffer)
		elseif mode == constLogMode.ELM_tick then
			local count = _M.updateActionCount(btMsg)
			local buffer = string.format("[tick]%s %s [%s] [%d]\n", agentName, btMsg, actionResultStr, count)

			_sendText(buffer)
		elseif mode == constLogMode.ELM_jump then
			local buffer = string.format("[jump]%s %s\n", agentName, btMsg)

			_sendText(buffer)
		elseif mode == constLogMode.ELM_return then
			local buffer = string.format("[return]%s %s\n", agentName, btMsg)

			_sendText(buffer)
		else
			assert(false)
		end
	end
end

local function _createServer(host, port)
	host = host or "*"
	port = port or AiConst.AI_DEBUG.PORT

	local server, err = socket.bind(host, port)

	if err then
		if LoggerManager.checkLogger(LoggerConst.ERROR) then
			logger:error("[behaviac] debug server create error: ", err)
		end
	elseif LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:debug("[behaviac] debug server create success")
	end

	return server
end

local function _readNext(peer)
	local res, err, partial = peer:receive(kConstBufferLen)

	if AiConst.AI_DEBUG.NODE_LOG.Console_Receive and LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:debug("[behaviac] server receive: ", res, " , ", err, " , ", partial)
	end

	return res or partial or "", err
end

local function _readText()
	local text = #_M.m_texts > 0 and _M.m_texts

	_M.m_texts = ""

	return text
end

function _M.receivePackets(msgCheck)
	if _M.m_client then
		local peer = _M.m_client

		peer:settimeout(0)

		local chunks = {}
		local buf, err

		while true do
			buf, err = _readNext(peer)

			if buf and #buf > 0 then
				chunks[#chunks + 1] = buf
			else
				if err == "closed" then
					_M.reset()
				end

				break
			end
		end

		if #chunks > 0 then
			_M.m_texts = _M.m_texts .. table.concat(chunks)
		end

		peer:settimeout()
	end

	if msgCheck then
		return _M.m_texts:find(msgCheck, 1, true)
	else
		return false
	end
end

function _M.receivePacketsTimeout(msgCheck, waitTime)
	if _M.m_client then
		local peer = _M.m_client

		waitTime = waitTime or 1

		peer:settimeout(waitTime)

		local chunks = {}
		local buf, err
		local count = 0

		while true do
			buf, err = _readNext(peer)

			if buf and #buf > 0 then
				chunks[#chunks + 1] = buf
				count = count + #buf
			else
				if err == "closed" then
					_M.reset()
				end

				if err == "closed" or err == "timeout" or count > 0 then
					break
				end
			end
		end

		if #chunks > 0 then
			_M.m_texts = _M.m_texts .. table.concat(chunks)
		end

		peer:settimeout()
	end

	if msgCheck then
		return _M.m_texts:find(msgCheck, 1, true)
	else
		return false
	end
end

local function _onConnection()
	_sendInitialSettings()
	_sendWorkspaceSettings()
	_sendInitialProperties()
	_sendExistingPackets()
	_sendText("[connected]precached message done")
	_flushSendBuffer()

	local connectCountMax = 5
	local curConnectCount = 0
	local bFound = false

	while not bFound and curConnectCount < connectCountMax do
		if not _M.m_client then
			break
		end

		local bFound = _M.receivePacketsTimeout(constCommand.kStart)

		if bFound then
			_M.handleRequests()

			return true
		end

		curConnectCount = curConnectCount + 1
	end

	_M.reset()

	if LoggerManager.checkLogger(LoggerConst.ERROR) then
		logger:error("[behaviac]connected failed.")
	end

	return false
end

local function _doAccept()
	local client, err = _M.m_server:accept()

	if client then
		_M.m_client = client

		_onConnection()
	else
		_M.reset()
	end
end

local function _doAcceptNonblocking(timeout)
	_M.m_server:settimeout(timeout or 0)

	local client, err = _M.m_server:accept()

	if client then
		_M.m_client = client

		if _onConnection() and LoggerManager.checkLogger(LoggerConst.DEBUG) then
			logger:debug("[behaviac]connected.")
		end
	elseif err == "closed" or err == "timeout" then
		_M.reset()
	end

	if err and LoggerManager.checkLogger(LoggerConst.DEBUG) then
		logger:debug("[behaviac]:", err)
	end

	_M.m_server:settimeout()
end

function _M.startDebugger(bWaitOnStartup, server_mode)
	if not _M.m_running then
		_M.m_running = true
		_M.m_server = _createServer(_M.m_host, AiConst.AI_DEBUG.PORT)
		_M.server_mode = server_mode

		if bWaitOnStartup then
			_doAccept()
		else
			_doAcceptNonblocking()
		end
	end
end

function _M.tryRestartDebugger(timeout)
	if _M.m_running then
		_M.reset()

		if not _M.m_client then
			_doAcceptNonblocking(timeout)
		end
	end
end

function _M.stopDebugger()
	if _M.m_running then
		_M.reset()

		_M.m_running = false
	end
end

function _M.finishDebugger()
	_M.stopDebugger()

	if _M.m_server then
		if LoggerManager.checkLogger(LoggerConst.DEBUG) then
			logger:debug("[behaviac]m_server close.")
		end

		_M.m_server:close()

		_M.m_server = false
	end
end

function _M.tryDebugger(timeout)
	if _M.m_running and not _M.m_client then
		_doAcceptNonblocking(timeout)
	end
end

local function _parseBreakpoint(tokens)
	local bp = {
		hit_config = 0,
		btname = false,
		action_result = constEActionResult.EAR_all
	}
	local bAdd = false
	local bRemove = false

	if tokens[2] == "add" then
		bAdd = true
	elseif tokens[2] == "remove" then
		bRemove = true
	else
		assert(false)
	end

	bp.btname = tokens[3]

	if tokens[4] == "all" then
		assert(bp.action_result == constEActionResult.EAR_all)
	elseif tokens[4] == "success" then
		bp.action_result = constEActionResult.EAR_success
	elseif tokens[4] == "failure" then
		bp.action_result = constEActionResult.EAR_failure
	else
		assert(false)
	end

	local pos_b, pos_e = tokens[5]:find(constCommand.kHitNumber, 1, true)

	if pos_b then
		pos_b = pos_e + 1

		local _, pos_e2 = tokens[5]:find("\n", pos_b, true)

		if pos_e2 then
			pos_e = pos_e2 - 1
		else
			pos_e = #tokens[5]
		end

		local numString = tokens[5]:sub(pos_b, pos_e)

		bp.hit_config = tonumber(numString)
	end

	local bpid = _makeVariableId(bp.btname)

	if bAdd then
		_M.m_breakpoints[bpid] = bp
	elseif bRemove then
		_M.m_breakpoints[bpid] = nil
	end
end

local function _parseProfiling(tokens)
	return tokens[2] == "true"
end

local function _parseAppLogFilter(tokens)
	return tokens[2]
end

local function _parseProperty(tokens)
	local agentName = tokens[2]
	local pos_b, pos_e
	local size = 0
	local AgentMeta = require("Common.AI.Behaviac.Agent.AgentMeta")
	local agent = AgentMeta.getAgent(agentName)

	if agent and #tokens == 4 then
		local varNameValue = tokens[4]
		local pos_b = varNameValue:find("->", 1, true)

		if pos_b then
			local pos_e = varNameValue:find("\n", 1, true)

			pos_e = pos_e or #varNameValue

			local varName = varNameValue:sub(1, pos_b - 1)
			local varValue = varNameValue:sub(pos_b + 2, pos_e)
			local prop = agent[varName]

			if not prop then
				local ParamAdapter = require("Common.AI.Behaviac.Parser.ParamAdapter")

				prop = ParamAdapter.new()
			end

			prop:buildProperty(varValue)

			agent[varName] = prop
		end
	end
end

function _M.handleRequests()
	local bContinue = false
	local buf, err = _M.receivePackets()
	local text = _readText()

	if text then
		local cs = _split_str(text, "\n")

		for i, c in ipairs(cs) do
			if c:len() > 0 then
				local tokens = _split_str(c, " ")

				if tokens[1] == constCommand.kBreakpoint then
					_parseBreakpoint(tokens)
				elseif tokens[1] == constCommand.kProperty then
					_parseProperty(tokens)
				elseif tokens[1] == constCommand.kProfiling then
					_M.m_profiling = _parseProfiling(tokens)
				elseif tokens[1] == constCommand.kStart then
					_M.m_breakpoints = {}
					bContinue = true
				elseif tokens[1] == constCommand.kAppLogFilter then
					_M.m_applogFilter = _parseAppLogFilter(tokens)
				elseif tokens[1] == constCommand.kContinue then
					bContinue = true
				elseif tokens[1] == constCommand.kCloseConnection then
					_M.reset()

					_M.m_breakpoints = {}
					bContinue = true
				elseif tokens[1] == constCommand.kDebugTargetInfo then
					if LoggerManager.checkLogger(LoggerConst.INFO) then
						logger:info("[DebugTargetInfo]" .. tostring(tokens[2]))
					end

					if tonumber(tokens[2]) ~= nil then
						AiUtils.setDebugEnt(tonumber(tokens[2]))
					elseif LoggerManager.checkLogger(LoggerConst.ERROR) then
						logger:error("[DebugTargetInfo]" .. "传递了错误的actorid:" .. tostring(tokens[2]) .. "请重试")
					end

					bContinue = true
				else
					assert(false)
				end
			end
		end
	end

	return bContinue
end

local function _getParentTreeName(agent, node)
	local btName

	if node:isReferencedBehavior() then
		node = node:getParent()
	end

	local bIsTree = false
	local bIsRefTree = false

	while node do
		bIsTree = node:isBehaviorTree()
		bIsRefTree = node:isReferencedBehavior()

		if bIsTree or bIsRefTree then
			break
		end

		node = node:getParent()
	end

	if bIsTree then
		btName = node:getName()
	elseif bIsRefTree then
		btName = refTree:getReferencedTreeName(agent)
	else
		assert(false)
	end

	return btName
end

local function _getTickInfo(agent, node, action)
	if agent then
		local className = node:getClassNameString()

		if #className > 0 then
			local btName = _getParentTreeName(agent, node)
			local nodeId = node:getId()
			local bpstr = ""
			local temp

			if type(btName) == "string" and string.len(btName) > 0 then
				temp = string.format("%s.xml->", btName)
				bpstr = bpstr .. temp
			end

			temp = string.format("%s[%i]", className, nodeId)
			bpstr = bpstr .. temp

			if type(action) == "string" and string.len(action) > 0 then
				temp = string.format(":%s", action)
				bpstr = bpstr .. temp
			end

			return bpstr
		end
	end

	return ""
end

local function _checkBreakpoint(agent, bpStr, actionResult)
	if not AiUtils.checkDebugEnt(agent.ent.actorId) then
		return false
	end

	local bpid = _makeVariableId(bpStr)
	local bp = _M.m_breakpoints[bpid]

	if bp then
		local bHit = false

		if bp.action_result == constEActionResult.EAR_none then
			bHit = false
		elseif bp.action_result == constEActionResult.EAR_success or bp.action_result == constEActionResult.EAR_failure then
			bHit = actionResult == bp.action_result or actionResult == constEActionResult.EAR_all
		elseif bp.action_result == constEActionResult.EAR_all then
			bHit = true
		end

		if bHit then
			local count = _M.getActionCount(bpStr)

			if bp.hit_config == 0 or bp.hit_config == count then
				return true
			end
		end
	end

	return false
end

local function _waitforContinue()
	if UNITY_EDITOR then
		appFacade.PauseUnity()
	else
		while true do
			local bLoop = _M.m_client and not _M.handleRequests()

			if not bLoop then
				break
			end

			_M.receivePacketsTimeout(nil, 0.1)
		end
	end
end

function _M.CHECK_BREAKPOINT(agent, node, action, result)
	if not AiUtils.checkDebugEnt(agent.ent.actorId) then
		return
	end

	local bpstr = _getTickInfo(agent, node, action)

	if bpstr then
		local actionResult = result and constEActionResult.EAR_success or constEActionResult.EAR_failure

		_sendBtMsg(agent, bpstr, actionResult, constLogMode.ELM_tick)

		if _checkBreakpoint(agent, bpstr, actionResult) then
			_M.logVariables(agent)
			_sendBtMsg(agent, bpstr, actionResult, constLogMode.ELM_breaked)
			_flushSendBuffer()
			_waitforContinue()
			_sendBtMsg(agent, bpstr, actionResult, constLogMode.ELM_continue)
			_flushSendBuffer()
		end
	end
end

function _M.checkAppLogFilter(filter)
	if #_M.m_applogFilter > 0 then
		if _M.m_applogFilter == "ALL" then
			return true
		else
			local f = filter

			f = string.upper(f)

			if _M.m_applogFilter == f then
				return true
			end
		end
	end

	return false
end

function _M.updateActionCount(actionStr)
	local action = _makeVariableId(actionStr)
	local count = _M.m_actions_count[action] or 0

	count = count + 1
	_M.m_actions_count[action] = count

	return count
end

function _M.getActionCount(actionStr)
	local action = _makeVariableId(actionStr)

	return _M.m_actions_count[action] or 0
end

function _M.logFrames(agent)
	if AiConst.AI_DEBUG.ENT_ID ~= 0 and not AiUtils.checkDebugEnt(agent.ent.actorId) then
		return
	end

	_M.m_frame = _M.m_frame + 1

	if _M.m_client then
		local buffer = string.format("[frame]%d\n", _M.m_frame)

		_sendText(buffer)
	end
end

function _M.logFrameEnd(agent)
	if AiConst.AI_DEBUG.ENT_ID ~= 0 and not AiUtils.checkDebugEnt(agent.ent.actorId) then
		return
	end

	if _M.m_client then
		_sendText("[frameEnd]")
		_flushSendBuffer()
	end
end

function _M.logJumpTree(agent, newTree, version)
	if not AiUtils.checkDebugEnt(agent.ent.actorId) then
		return
	end

	if _M.m_client then
		local msg = newTree .. ".lua " .. version

		_sendBtMsg(agent, msg, constEActionResult.EAR_none, constLogMode.ELM_jump)
	end
end

function _M.logReturnTree(agent, returnFromTree)
	if not AiUtils.checkDebugEnt(agent.ent.actorId) then
		return
	end

	if _M.m_client then
		local msg = returnFromTree .. ".lua"

		_sendBtMsg(agent, msg, constEActionResult.EAR_none, constLogMode.ELM_return)
	end
end

function _M.logUpdate(agent, node)
	if not AiUtils.checkDebugEnt(agent.ent.actorId) then
		return
	end

	if _M.m_client then
		local btStr = _getTickInfo(agent, node, "update")

		if type(btStr) == "string" and #btStr > 0 then
			_sendBtMsg(agent, btStr, constEActionResult.EAR_none, constLogMode.ELM_tick)
		end
	end
end

local function _logProperty(agent, varName, varValue)
	if not AiUtils.checkDebugEnt(agent.ent.actorId) then
		return
	end

	local agentName = agent:getDebugAgentName()
	local buffer = string.format("[property]%s %s->%s\n", agentName, varName, varValue)

	_sendText(buffer, true)
end

function _M.logVariables(agent)
	if not AiUtils.checkDebugEnt(agent.ent.actorId) then
		return
	end

	if _M.m_client then
		_sendText("[startProperty]", true)

		if agent:getCurrentRunningTreeTick() then
			local localVars = agent:getCurrentRunningTreeTick().m_localVars

			for k, v in pairs(localVars) do
				_logProperty(agent, tostring(k), tostring(v))
			end
		end

		agent:traverseAllBlackboardProperties(_logProperty)
		_sendText("[endProperty]", true)
	end
end

return _M
