-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Core\\Common\\ProtobufConst.lua

local class = require("Core.Framework.Class")
local CommonRepo = require("Core.Common.CommonRepo")
local ProtobufConst = class.Class("ProtobufConst")

function ProtobufConst.init()
	local pb = CommonRepo.pb

	ProtobufConst.CONNECT_RESPONSE_TYPE_BUSY = pb.enum("phonest.proto.ConnectServerResp.RespType", "Busy")
	ProtobufConst.CONNECT_RESPONSE_TYPE_CONNECTED = pb.enum("phonest.proto.ConnectServerResp.RespType", "Connected")
	ProtobufConst.CONNECT_RESPONSE_TYPE_CONNECTREFUSED = pb.enum("phonest.proto.ConnectServerResp.RespType", "ConnectRefused")
	ProtobufConst.CONNECT_RESPONSE_TYPE_RECONNECTED = pb.enum("phonest.proto.ConnectServerResp.RespType", "Reconnected")
	ProtobufConst.CONNECT_RESPONSE_TYPE_RECONNECTREFUSED = pb.enum("phonest.proto.ConnectServerResp.RespType", "ReconnectRefused")
	ProtobufConst.CONNECT_RESPONSE_TYPE_FORBIDDEN = pb.enum("phonest.proto.ConnectServerResp.RespType", "Forbidden")
	ProtobufConst.CONNECT_RESPONSE_TYPE_MAX_CONNECTIONS = pb.enum("phonest.proto.ConnectServerResp.RespType", "MaxConnections")
	ProtobufConst.CONNECT_RECOVERY_MODE_FULLSYNC = pb.enum("phonest.proto.ConnectServerResp.RecoveryMode", "FullSync")
	ProtobufConst.CONNECT_RECOVERY_MODE_RESUME = pb.enum("phonest.proto.ConnectServerResp.RecoveryMode", "Resume")
	ProtobufConst.CONNECT_RESPONSE_TYPE_NORMALBROKEN = 101
	ProtobufConst.CONNECT_RESPONSE_TYPE_NORESPONSE = 102
	ProtobufConst.CONNECT_RESPONSE_TYPE_NORECONNECT = 103
	ProtobufConst.CONNECT_RESPONSE_TYPE_HANDSHAKE_FAILED = 104
	ProtobufConst.CONNECT_RESPONSE_TYPE_HEARTBEAT_TIMEOUT = 105

	assert(ProtobufConst.CONNECT_RESPONSE_TYPE_BUSY ~= nil)
	assert(ProtobufConst.CONNECT_RESPONSE_TYPE_CONNECTED ~= nil)
	assert(ProtobufConst.CONNECT_RESPONSE_TYPE_CONNECTREFUSED ~= nil)
	assert(ProtobufConst.CONNECT_RESPONSE_TYPE_RECONNECTED ~= nil)
	assert(ProtobufConst.CONNECT_RESPONSE_TYPE_RECONNECTREFUSED ~= nil)
	assert(ProtobufConst.CONNECT_RESPONSE_TYPE_FORBIDDEN ~= nil)
	assert(ProtobufConst.CONNECT_RESPONSE_TYPE_MAX_CONNECTIONS ~= nil)
	assert(ProtobufConst.CONNECT_RECOVERY_MODE_FULLSYNC ~= nil)
	assert(ProtobufConst.CONNECT_RECOVERY_MODE_RESUME ~= nil)

	ProtobufConst.CONNECT_REQUEST_TYPE_NEW_CONNECTION = pb.enum("phonest.proto.ConnectServerReq.ReqType", "NewConnection")
	ProtobufConst.CONNECT_REQUEST_TYPE_RE_CONNECTION = pb.enum("phonest.proto.ConnectServerReq.ReqType", "ReConnection")
	ProtobufConst.CONNECT_REQUEST_TYPE_BIND_SOUL = pb.enum("phonest.proto.ConnectServerReq.ReqType", "BindSoul")
	ProtobufConst.CONNECT_REQUEST_TYPE_BIND_AVATAR = pb.enum("phonest.proto.ConnectServerReq.ReqType", "BindAvatar")
	ProtobufConst.CONNECT_REQUEST_TYPE_BIND_ACCOUNT = pb.enum("phonest.proto.ConnectServerReq.ReqType", "BindAccount")
	ProtobufConst.CONNECT_REQUEST_TYPE_REBIND_SOUL = pb.enum("phonest.proto.ConnectServerReq.ReqType", "ReBindSoul")
	ProtobufConst.CONNECT_REQUEST_TYPE_LATENCY_DETECT = 9999

	assert(ProtobufConst.CONNECT_REQUEST_TYPE_BIND_SOUL ~= nil)
	assert(ProtobufConst.CONNECT_REQUEST_TYPE_BIND_AVATAR ~= nil)
	assert(ProtobufConst.CONNECT_REQUEST_TYPE_BIND_ACCOUNT ~= nil)
	assert(ProtobufConst.CONNECT_REQUEST_TYPE_NEW_CONNECTION ~= nil)
	assert(ProtobufConst.CONNECT_REQUEST_TYPE_RE_CONNECTION ~= nil)
	assert(ProtobufConst.CONNECT_REQUEST_TYPE_REBIND_SOUL ~= nil)

	ProtobufConst.DBMANAGER_STATUS_ACTIVE = pb.enum("phonest.proto.DBStatusInfo.DBStatusType", "Active")
	ProtobufConst.DBMANAGER_STATUS_INACTIVE = pb.enum("phonest.proto.DBStatusInfo.DBStatusType", "Inactive")
	ProtobufConst.DBMANAGER_DBTYPE_MONGO = pb.enum("phonest.proto.DBStatusInfo.DBType", "Mongo")
	ProtobufConst.DBMANAGER_DBTYPE_REDIS = pb.enum("phonest.proto.DBStatusInfo.DBType", "Redis")
	ProtobufConst.DBMANAGER_DBTYPE_CLUSTER_ID_NOT_MATCH = pb.enum("phonest.proto.DBStatusInfo.DBType", "ClusterIdNotMatch")
	ProtobufConst.GATE_BROADCAST_ALL = pb.enum("phonest.proto.FilterMessage.FilterType", "All")
	ProtobufConst.GATE_BROADCAST_BY_FILTER = pb.enum("phonest.proto.FilterMessage.FilterType", "ByFilter")
	ProtobufConst.GATE_BROADCAST_BY_IDS = pb.enum("phonest.proto.FilterMessage.FilterType", "ByIds")
	ProtobufConst.CHANNEL_DST_ATTACHED = pb.enum("phonest.proto.AttachChannelResp.AttachChannelRespType", "DstAttached")
	ProtobufConst.CHANNEL_DST_NOTFOUND = pb.enum("phonest.proto.AttachChannelResp.AttachChannelRespType", "DstNotFound")
	ProtobufConst.CHANNEL_DST_TIMEOUT = pb.enum("phonest.proto.AttachChannelResp.AttachChannelRespType", "DstTimeout")

	return true
end

function ProtobufConst.genEntityMailbox(entityId, serverName, clusterId)
	local mailbox = {
		entityId = entityId,
		serverName = serverName,
		clusterId = clusterId
	}

	return mailbox
end

function ProtobufConst.reprEntityMailbox(mb)
	if mb == nil then
		return "mb_nil"
	end

	return string.format("entityId=%s serverName=%s clusterId=%s", mb.entityId, mb.serverName, mb.clusterId)
end

return ProtobufConst
