-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\SDK\\Platform\\PlatformShellTokenUtils.lua

local PlatformShellTokenUtils = {}
local Uri = CS.System.Uri
local logger = require("SDK.Platform.PlatformLogger")
local PlatformShellConst = require("Common.Const.PlatformShellConst")
local GlobalData = require("Core.Client.GlobalData")

PlatformShellTokenUtils.TokenType = PlatformShellConst.TokenType
PlatformShellTokenUtils.JOIN_GAME_REQUIRED_CONNECTION_FIELDS = {
	"tokenType",
	"inviteId",
	"inviteToken",
	"inviterGameUid",
	"inviterPlatformUserId",
	"targetKey",
	"serverId"
}
PlatformShellTokenUtils.DIRECTED_REQUIRED_CONNECTION_FIELDS = {
	"tokenType",
	"inviteId",
	"inviteToken",
	"inviterGameUid",
	"inviterPlatformUserId",
	"invitedPlatformUserId",
	"targetKey",
	"serverId"
}
PlatformShellTokenUtils.INVITE_WORLD_REQUIRED_CONNECTION_FIELDS = {
	"tokenType",
	"inviteId",
	"inviteToken",
	"inviterGameUid",
	"inviterPlatformUserId",
	"invitedPlatformUserId",
	"targetKey",
	"serverId",
	"inviteWorldType"
}
PlatformShellTokenUtils.HOME_CAMP_REQUIRED_CONNECTION_FIELDS = {
	"tokenType",
	"inviteId",
	"inviteToken",
	"inviterGameUid",
	"inviterPlatformUserId",
	"invitedPlatformUserId",
	"targetKey",
	"serverId",
	"homeCampInviteId"
}
PlatformShellTokenUtils._ConnectionStringFieldConfig = {
	[PlatformShellTokenUtils.TokenType.JoinGameByShell] = {
		BuildConnectionString = "buildExistingTeamConnectionString",
		requiredFields = PlatformShellTokenUtils.JOIN_GAME_REQUIRED_CONNECTION_FIELDS
	},
	[PlatformShellTokenUtils.TokenType.InviteJoinTeam] = {
		BuildConnectionString = "buildDirectTeamInviteConnectionString",
		requiredFields = PlatformShellTokenUtils.DIRECTED_REQUIRED_CONNECTION_FIELDS
	},
	[PlatformShellTokenUtils.TokenType.RequestJoinTeam] = {
		BuildConnectionString = "buildTeamRequestJoinInviteConnectionString",
		requiredFields = PlatformShellTokenUtils.DIRECTED_REQUIRED_CONNECTION_FIELDS
	},
	[PlatformShellTokenUtils.TokenType.InviteEnterWorld] = {
		BuildConnectionString = "buildEnterWorldInviteConnectionString",
		requiredFields = PlatformShellTokenUtils.INVITE_WORLD_REQUIRED_CONNECTION_FIELDS
	},
	[PlatformShellTokenUtils.TokenType.RequestEnterWorld] = {
		BuildConnectionString = "buildEnterWorldInviteConnectionString",
		requiredFields = PlatformShellTokenUtils.DIRECTED_REQUIRED_CONNECTION_FIELDS
	},
	[PlatformShellTokenUtils.TokenType.InviteExchangePet] = {
		BuildConnectionString = "buildEnterWorldInviteConnectionString",
		requiredFields = PlatformShellTokenUtils.INVITE_WORLD_REQUIRED_CONNECTION_FIELDS
	},
	[PlatformShellTokenUtils.TokenType.InviteEnterPhotoWorld] = {
		BuildConnectionString = "buildPhotoWorldConnectionString",
		requiredFields = PlatformShellTokenUtils.DIRECTED_REQUIRED_CONNECTION_FIELDS
	},
	[PlatformShellTokenUtils.TokenType.InviteSpaceFollow] = {
		BuildConnectionString = "buildSpaceFollowInviteConnectionString",
		requiredFields = PlatformShellTokenUtils.DIRECTED_REQUIRED_CONNECTION_FIELDS
	},
	[PlatformShellTokenUtils.TokenType.ReuquestSpaceFollow] = {
		BuildConnectionString = "buildSpaceFollowRequestInviteConnectionString",
		requiredFields = PlatformShellTokenUtils.DIRECTED_REQUIRED_CONNECTION_FIELDS
	},
	[PlatformShellTokenUtils.TokenType.InviteQuickSpaceFollow] = {
		BuildConnectionString = "buildQuickTeamSpaceFollowInviteConnectionString",
		requiredFields = PlatformShellTokenUtils.DIRECTED_REQUIRED_CONNECTION_FIELDS
	},
	[PlatformShellTokenUtils.TokenType.InviteHomeCamp] = {
		BuildConnectionString = "buildHomeCampInviteConnectionString",
		requiredFields = PlatformShellTokenUtils.HOME_CAMP_REQUIRED_CONNECTION_FIELDS
	},
	[PlatformShellTokenUtils.TokenType.RequestHomeCamp] = {
		BuildConnectionString = "buildHomeCampInviteConnectionString",
		requiredFields = PlatformShellTokenUtils.HOME_CAMP_REQUIRED_CONNECTION_FIELDS
	}
}

function PlatformShellTokenUtils.buildShellInvitePayload(fields, tokenType)
	return {
		tokenType = tokenType,
		contextType = fields.contextType or "",
		inviteId = fields.inviteId or "",
		inviterGameUid = fields.inviterGameUid or "",
		inviterPlatformUserId = fields.inviterPlatformUserId or "",
		invitedPlatformUserId = fields.invitedPlatformUserId or "",
		targetKey = fields.targetKey or "",
		inviteToken = fields.inviteToken or "",
		homeCampInviteId = fields.homeCampInviteId or "",
		inviteWorldType = fields.inviteWorldType or "",
		serverId = fields.serverId or ""
	}
end

PlatformShellTokenUtils._AcceptTokenConfig = {
	[PlatformShellTokenUtils.TokenType.JoinGameByShell] = {
		requireOwnerInfo = false,
		preAcceptDropChecks = {
			"xboxTeamFunctionLocked",
			"teamFunctionLocked",
			"preparingRoomConfirm",
			"alreadyInTeam",
			"matchStatus"
		},
		buildPayload = PlatformShellTokenUtils.buildShellInvitePayload
	},
	[PlatformShellTokenUtils.TokenType.InviteJoinTeam] = {
		requireOwnerInfo = false,
		preAcceptDropChecks = {
			"xboxTeamFunctionLocked",
			"teamFunctionLocked",
			"preparingRoomConfirm",
			"alreadyInTeam",
			"matchStatus"
		},
		buildPayload = PlatformShellTokenUtils.buildShellInvitePayload
	},
	[PlatformShellTokenUtils.TokenType.RequestJoinTeam] = {
		requireOwnerInfo = false,
		preAcceptDropChecks = {
			"xboxTeamFunctionLocked",
			"teamFunctionLocked",
			"matchStatus"
		},
		buildPayload = PlatformShellTokenUtils.buildShellInvitePayload
	},
	[PlatformShellTokenUtils.TokenType.InviteEnterWorld] = {
		requireOwnerInfo = false,
		preAcceptDropChecks = {
			"xboxTeamFunctionLocked",
			"preparingRoomBlockEnterWorld",
			"alreadyInTeam",
			"ugcDestinationEntryFilter"
		},
		buildPayload = PlatformShellTokenUtils.buildShellInvitePayload
	},
	[PlatformShellTokenUtils.TokenType.RequestEnterWorld] = {
		requireOwnerInfo = false,
		preAcceptDropChecks = {
			"xboxTeamFunctionLocked",
			"requestEnterWorldDestinationEntryFilter"
		},
		buildPayload = PlatformShellTokenUtils.buildShellInvitePayload
	},
	[PlatformShellTokenUtils.TokenType.InviteExchangePet] = {
		requireOwnerInfo = false,
		preAcceptDropChecks = {
			"ugcDestinationEntryFilter"
		},
		buildPayload = PlatformShellTokenUtils.buildShellInvitePayload
	},
	[PlatformShellTokenUtils.TokenType.InviteEnterPhotoWorld] = {
		requireOwnerInfo = false,
		preAcceptDropChecks = {
			"ugcDestinationEntryFilter"
		},
		buildPayload = PlatformShellTokenUtils.buildShellInvitePayload
	},
	[PlatformShellTokenUtils.TokenType.InviteSpaceFollow] = {
		requireOwnerInfo = false,
		preAcceptDropChecks = {
			"ugcDestinationEntryFilter"
		},
		buildPayload = PlatformShellTokenUtils.buildShellInvitePayload
	},
	[PlatformShellTokenUtils.TokenType.ReuquestSpaceFollow] = {
		requireOwnerInfo = false,
		preAcceptDropChecks = {
			"ugcDestinationEntryFilter"
		},
		buildPayload = PlatformShellTokenUtils.buildShellInvitePayload
	},
	[PlatformShellTokenUtils.TokenType.InviteQuickSpaceFollow] = {
		requireOwnerInfo = false,
		preAcceptDropChecks = {
			"ugcDestinationEntryFilter"
		},
		buildPayload = PlatformShellTokenUtils.buildShellInvitePayload
	},
	[PlatformShellTokenUtils.TokenType.InviteHomeCamp] = {
		requireOwnerInfo = true,
		preAcceptDropChecks = {
			"ugcDestinationEntryFilter"
		},
		buildPayload = PlatformShellTokenUtils.buildShellInvitePayload
	},
	[PlatformShellTokenUtils.TokenType.RequestHomeCamp] = {
		requireOwnerInfo = true,
		preAcceptDropChecks = {
			"ugcDestinationEntryFilter"
		},
		buildPayload = PlatformShellTokenUtils.buildShellInvitePayload
	}
}

function PlatformShellTokenUtils.escapeValue(value)
	local text = tostring(value or "")

	if string.isNilOrEmpty(text) then
		return ""
	end

	local ok, escaped = pcall(Uri.EscapeDataString, text)

	if ok and not string.isNilOrEmpty(escaped) then
		return escaped
	end

	return text
end

function PlatformShellTokenUtils.unescapeValue(value)
	local text = tostring(value or "")

	if string.isNilOrEmpty(text) then
		return ""
	end

	local ok, unescaped = pcall(Uri.UnescapeDataString, text)

	if ok and not string.isNilOrEmpty(unescaped) then
		return unescaped
	end

	return text
end

function PlatformShellTokenUtils.encodeConnectionString(fields)
	local parts = {}

	for _, entry in ipairs(fields) do
		local key = tostring(entry.key or "")

		if not string.isNilOrEmpty(key) then
			parts[#parts + 1] = string.format("%s=%s", PlatformShellTokenUtils.escapeValue(key), PlatformShellTokenUtils.escapeValue(entry.value))
		end
	end

	return table.concat(parts, "&")
end

function PlatformShellTokenUtils.joinFields(fields)
	if type(fields) ~= "table" then
		return ""
	end

	return table.concat(fields, ",")
end

function PlatformShellTokenUtils.getServerId()
	return tostring(pg and pg.me and pg.me.serverId or "")
end

function PlatformShellTokenUtils.getClusterId()
	return tostring(GlobalData.ServerId or "")
end

function PlatformShellTokenUtils.getClusterName()
	return tostring(GlobalData.ServerName or "")
end

function PlatformShellTokenUtils.normalizeTokenKey(key)
	return key
end

function PlatformShellTokenUtils.copyArray(source)
	local result = {}

	if type(source) ~= "table" then
		return result
	end

	for index, value in ipairs(source) do
		result[index] = value
	end

	return result
end

function PlatformShellTokenUtils.getConnectionStringFieldConfig(tokenType)
	return PlatformShellTokenUtils._ConnectionStringFieldConfig[tostring(tokenType or "")]
end

function PlatformShellTokenUtils.findMissingRequiredFields(sourceFields, requiredFields)
	local missingFields = {}

	if #requiredFields == 0 then
		return {
			"tokenType"
		}
	end

	for _, fieldName in ipairs(requiredFields) do
		local value = sourceFields and sourceFields[fieldName] or nil

		if string.isNilOrEmpty(value) then
			missingFields[#missingFields + 1] = fieldName
		end
	end

	return missingFields
end

function PlatformShellTokenUtils.copyFieldMap(fields)
	local fieldMap = {}

	if type(fields) ~= "table" then
		return fieldMap
	end

	for key, value in pairs(fields) do
		fieldMap[key] = value
	end

	return fieldMap
end

function PlatformShellTokenUtils.normalizeConnectionFields(tokenType, fields)
	local fieldMap = PlatformShellTokenUtils.copyFieldMap(fields)

	fieldMap.tokenType = tokenType

	if string.isNilOrEmpty(fieldMap.serverId) then
		fieldMap.serverId = PlatformShellTokenUtils.getServerId()
	end

	if string.isNilOrEmpty(fieldMap.clusterId) then
		fieldMap.clusterId = PlatformShellTokenUtils.getClusterId()
	end

	if string.isNilOrEmpty(fieldMap.clusterName) then
		fieldMap.clusterName = PlatformShellTokenUtils.getClusterName()
	end

	return fieldMap
end

function PlatformShellTokenUtils.buildRequiredConnectionFields(fieldMap, requiredFields)
	local fields = {}

	for _, fieldName in ipairs(requiredFields) do
		fields[#fields + 1] = {
			key = fieldName,
			value = fieldMap[fieldName]
		}
	end

	return fields
end

function PlatformShellTokenUtils.validateBuildRequiredFields(tokenType, fieldMap, requiredFields)
	local missingFields = PlatformShellTokenUtils.findMissingRequiredFields(fieldMap, requiredFields)

	if #missingFields == 0 then
		return true
	end

	logger:error("PlatformShellTokenUtils.buildConnectionString failed: missing required fields tokenType=%s missingFields=%s requiredFields=%s", tostring(tokenType or ""), PlatformShellTokenUtils.joinFields(missingFields), PlatformShellTokenUtils.joinFields(requiredFields))

	return false
end

function PlatformShellTokenUtils.buildConfiguredConnectionString(tokenType, fieldMap, config)
	config = config or PlatformShellTokenUtils.getConnectionStringFieldConfig(tokenType)

	local requiredFields = config and config.requiredFields or {}

	if not PlatformShellTokenUtils.validateBuildRequiredFields(tokenType, fieldMap, requiredFields) then
		return ""
	end

	local fields = PlatformShellTokenUtils.buildRequiredConnectionFields(fieldMap, requiredFields)

	if not string.isNilOrEmpty(fieldMap.clusterId) then
		fields[#fields + 1] = {
			key = "clusterId",
			value = fieldMap.clusterId
		}
	end

	if not string.isNilOrEmpty(fieldMap.clusterName) then
		fields[#fields + 1] = {
			key = "clusterName",
			value = fieldMap.clusterName
		}
	end

	return PlatformShellTokenUtils.encodeConnectionString(fields)
end

function PlatformShellTokenUtils.buildConnectionString(tokenType, fields)
	local fieldMap = PlatformShellTokenUtils.normalizeConnectionFields(tokenType, fields)
	local config = PlatformShellTokenUtils.getConnectionStringFieldConfig(tokenType)

	if not config then
		logger:error("PlatformShellTokenUtils.buildConnectionString failed: missing config tokenType=%s", tostring(tokenType or ""))

		return ""
	end

	local buildConnectionStringName = tostring(config.BuildConnectionString or "")
	local buildConnectionStringFunc = PlatformShellTokenUtils[buildConnectionStringName]

	if type(buildConnectionStringFunc) ~= "function" then
		logger:error("PlatformShellTokenUtils.buildConnectionString failed: invalid BuildConnectionString tokenType=%s BuildConnectionString=%s", tostring(tokenType or ""), buildConnectionStringName)

		return ""
	end

	return buildConnectionStringFunc(tokenType, fieldMap, config)
end

function PlatformShellTokenUtils.buildInviteConnectionString(tokenType, inviteId, inviterPlatformUserId, inviterGameUid, inviteToken, invitedGameUid, invitedPlatformUserId, options)
	return PlatformShellTokenUtils.buildConnectionString(tokenType, {
		inviteId = inviteId or "",
		inviterPlatformUserId = inviterPlatformUserId,
		inviterGameUid = inviterGameUid or "",
		inviteToken = inviteToken or "",
		invitedPlatformUserId = invitedPlatformUserId or "",
		targetKey = options and options.targetKey or "",
		inviteWorldType = options and options.inviteWorldType or "",
		homeCampInviteId = options and options.homeCampInviteId or ""
	})
end

function PlatformShellTokenUtils.canBuildConnectionString(tokenType)
	local config = PlatformShellTokenUtils.getConnectionStringFieldConfig(tokenType)
	local buildConnectionStringName = tostring(config and config.BuildConnectionString or "")

	return type(PlatformShellTokenUtils[buildConnectionStringName]) == "function"
end

function PlatformShellTokenUtils.canBuildInviteConnectionString(tokenType)
	return PlatformShellTokenUtils.canBuildConnectionString(tokenType)
end

function PlatformShellTokenUtils.buildExistingTeamConnectionString(tokenType, fieldMap, config)
	return PlatformShellTokenUtils.buildConfiguredConnectionString(tokenType, fieldMap, config)
end

function PlatformShellTokenUtils.buildPendingCreateConnectionString(tokenType, fieldMap, config)
	return PlatformShellTokenUtils.buildConfiguredConnectionString(tokenType, fieldMap, config)
end

function PlatformShellTokenUtils.buildPhotoWorldConnectionString(tokenType, fieldMap, config)
	return PlatformShellTokenUtils.buildConfiguredConnectionString(tokenType, fieldMap, config)
end

function PlatformShellTokenUtils.buildEnterWorldInviteConnectionString(tokenType, fieldMap, config)
	return PlatformShellTokenUtils.buildConfiguredConnectionString(tokenType, fieldMap, config)
end

function PlatformShellTokenUtils.buildDirectTeamInviteConnectionString(tokenType, fieldMap, config)
	return PlatformShellTokenUtils.buildConfiguredConnectionString(tokenType, fieldMap, config)
end

function PlatformShellTokenUtils.buildDirectTeamPendingCreateConnectionString(tokenType, fieldMap, config)
	return PlatformShellTokenUtils.buildConfiguredConnectionString(tokenType, fieldMap, config)
end

function PlatformShellTokenUtils.buildPhotoWorldInviteConnectionString(tokenType, fieldMap, config)
	return PlatformShellTokenUtils.buildConfiguredConnectionString(tokenType, fieldMap, config)
end

function PlatformShellTokenUtils.buildSpaceFollowInviteConnectionString(tokenType, fieldMap, config)
	return PlatformShellTokenUtils.buildConfiguredConnectionString(tokenType, fieldMap, config)
end

function PlatformShellTokenUtils.buildSpaceFollowRequestInviteConnectionString(tokenType, fieldMap, config)
	return PlatformShellTokenUtils.buildConfiguredConnectionString(tokenType, fieldMap, config)
end

function PlatformShellTokenUtils.buildQuickTeamSpaceFollowInviteConnectionString(tokenType, fieldMap, config)
	return PlatformShellTokenUtils.buildConfiguredConnectionString(tokenType, fieldMap, config)
end

function PlatformShellTokenUtils.buildHomeCampInviteConnectionString(tokenType, fieldMap, config)
	return PlatformShellTokenUtils.buildConfiguredConnectionString(tokenType, fieldMap, config)
end

function PlatformShellTokenUtils.buildTeamRequestJoinInviteConnectionString(tokenType, fieldMap, config)
	return PlatformShellTokenUtils.buildConfiguredConnectionString(tokenType, fieldMap, config)
end

function PlatformShellTokenUtils.parseConnectionString(connectionString)
	local result = {}
	local source = tostring(connectionString or "")

	if string.isNilOrEmpty(source) then
		return result
	end

	for token in string.gmatch(source, "[^&]+") do
		local equalIndex = string.find(token, "=", 1, true)

		if equalIndex and equalIndex > 1 then
			local key = PlatformShellTokenUtils.unescapeValue(string.sub(token, 1, equalIndex - 1))
			local value = PlatformShellTokenUtils.unescapeValue(string.sub(token, equalIndex + 1))

			if not string.isNilOrEmpty(key) then
				local normalizedKey = PlatformShellTokenUtils.normalizeTokenKey(key)

				if normalizedKey == "invitedGameUid" then
					-- block empty
				elseif normalizedKey ~= "inviteToken" then
					result[normalizedKey] = value
				elseif string.isNilOrEmpty(result.inviteToken) then
					result.inviteToken = value
				end
			end
		end
	end

	return result
end

function PlatformShellTokenUtils.isKnownTokenType(tokenType)
	return PlatformShellConst.KnownTokenTypes[tostring(tokenType or "")] == true
end

function PlatformShellTokenUtils.getRequiredFields(tokenType)
	local config = PlatformShellTokenUtils.getConnectionStringFieldConfig(tokenType)

	return PlatformShellTokenUtils.copyArray(config and config.requiredFields)
end

function PlatformShellTokenUtils.getAcceptTokenConfig(tokenType)
	return PlatformShellTokenUtils._AcceptTokenConfig[tostring(tokenType or "")]
end

function PlatformShellTokenUtils.validateRequiredFields(parsedFields)
	local tokenType = parsedFields and parsedFields.tokenType or nil
	local requiredFields = PlatformShellTokenUtils.getRequiredFields(tokenType)
	local missingFields = PlatformShellTokenUtils.findMissingRequiredFields(parsedFields, requiredFields)

	return #missingFields == 0, missingFields, requiredFields
end

function PlatformShellTokenUtils.scanConnectionStringFieldConfig()
	local requiredByTokenType = {}

	for tokenType, config in pairs(PlatformShellTokenUtils._ConnectionStringFieldConfig) do
		requiredByTokenType[tokenType] = PlatformShellTokenUtils.copyArray(config.requiredFields)
	end

	return {
		requiredByTokenType = requiredByTokenType
	}
end

return PlatformShellTokenUtils
