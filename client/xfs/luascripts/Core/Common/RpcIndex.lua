-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Common\\RpcIndex.lua

local LoggerManager = require("Core.Log.LoggerManager")
local class = require("Core.Framework.Class")
local Const = require("Core.Common.Const")
local md5 = require("md5")
local RpcIndex = class.LightClass("RpcIndex")
local byte = string.byte
local bit = bit
local RPC_SALT = "x"

RpcIndex.SEND_CACHE = {}
RpcIndex.RECV_CACHE = {}
RpcIndex.RPC2INDEX = {}
RpcIndex.INDEX2RPC = {}
RpcIndex.RPC_INDEX2NAME = {}
RpcIndex.CLIENT_RPC_REPLAY_NO_SEQ_RPC = {
	"RPC_SC_Heartbeat",
	"RPC_SC_PveHeartbeat",
	"RPC_SC_LoseConnectTest"
}
RpcIndex.CLIENT_RPC_REPLAY_NO_SEQ_INDEX = {}

function RpcIndex.Init()
	local RpcIndexDict = require("Config.RpcIndexDict")
	local index

	for name, _ in pairs(RpcIndexDict) do
		index = RpcIndex.calculateRpcIndex(RPC_SALT, name)
		RpcIndex.RPC_INDEX2NAME[index] = name
	end

	local noSeqRpcs = {}

	for _, name in ipairs(RpcIndex.CLIENT_RPC_REPLAY_NO_SEQ_RPC) do
		if type(name) ~= "string" or name == "" then
			error("invalid ClientRpcReplay no-seq rpc name")
		end

		index = RpcIndex.sendRpcIndex(name)
		noSeqRpcs[#noSeqRpcs + 1] = index
	end

	RpcIndex.CLIENT_RPC_REPLAY_NO_SEQ_INDEX = noSeqRpcs
end

function RpcIndex.registerRpc(name)
	if RpcIndex.RPC2INDEX[name] then
		return
	end

	local index = RpcIndex.recvRpcIndex(name)

	if RpcIndex.INDEX2RPC[index] then
		error(string.format("RPC INDEX Of [%s] AND [%s] ARE CONFLICTED WITH SALT %s, index %d", name, RpcIndex.INDEX2RPC[index], RPC_SALT, index))
	end

	RpcIndex.INDEX2RPC[index] = name
	RpcIndex.RPC2INDEX[name] = index
end

function RpcIndex.calculateRpcIndex(salt, name)
	local a, b, c, d = md5.digest(salt .. name)

	return bit.lshift(bit.band(byte(a), 127), 24) + bit.lshift(byte(b), 16) + bit.lshift(byte(c), 8) + byte(d)
end

function RpcIndex.recvRpcIndex(name)
	local index = RpcIndex.RECV_CACHE[name]

	if index == nil then
		index = RpcIndex.calculateRpcIndex(RPC_SALT, name)
		RpcIndex.RECV_CACHE[name] = index
	end

	return index
end

function RpcIndex.sendRpcIndex(name)
	local index = RpcIndex.SEND_CACHE[name]

	if index == nil then
		index = RpcIndex.calculateRpcIndex(RPC_SALT, name)
		RpcIndex.SEND_CACHE[name] = index
	end

	return index
end

function RpcIndex.getClientRpcReplayNoSeqIndexList()
	return RpcIndex.CLIENT_RPC_REPLAY_NO_SEQ_INDEX
end

RpcIndex.Init()

return RpcIndex
