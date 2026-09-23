-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\PhotographyStudioEditBIUtils.lua

local PhotographyStudioEditBIUtils = {}
local EMPTY_TABLE = {}

local function getUidKey(uid)
	if uid == nil then
		return nil
	end

	return tostring(uid)
end

local function appendAssetIds(result, list, idField)
	if type(list) ~= "table" then
		return
	end

	for _, data in ipairs(list) do
		local assetId = type(data) == "table" and tonumber(data[idField]) or nil

		if assetId then
			result[#result + 1] = assetId
		end
	end

	table.sort(result)
end

local function appendActionId(result, actionId)
	local id = tonumber(actionId)

	if id then
		result[#result + 1] = id
	end
end

local function appendStringId(result, id)
	if id ~= nil then
		result[#result + 1] = tostring(id)
	end
end

local function buildMemberSet(studioInfo)
	if type(studioInfo) ~= "table" then
		return nil
	end

	local memberSet = {}
	local masterUidKey = getUidKey(studioInfo.masterUid)

	if masterUidKey then
		memberSet[masterUidKey] = true
	end

	if type(studioInfo.members) == "table" then
		for _, member in ipairs(studioInfo.members) do
			local uidKey = type(member) == "table" and getUidKey(member.uid) or nil

			if uidKey then
				memberSet[uidKey] = true
			end
		end
	end

	return memberSet
end

function PhotographyStudioEditBIUtils.buildLogData(content, studioInfo, metadata)
	content = type(content) == "table" and content or EMPTY_TABLE
	metadata = type(metadata) == "table" and metadata or EMPTY_TABLE

	local common = type(content.common) == "table" and content.common or EMPTY_TABLE
	local players = type(content.players) == "table" and content.players or EMPTY_TABLE
	local memberSet = buildMemberSet(studioInfo)
	local playerActions = {}
	local petActions = {}
	local stickerIds = {}
	local ornamentIds = {}
	local petIds = {}
	local playerUids = {}
	local countedPlayerUids = {}

	for uid, playerData in pairs(players) do
		local uidKey = getUidKey(uid)
		local isCurrentMember = memberSet == nil or memberSet[uidKey] == true

		if type(playerData) == "table" and isCurrentMember and not countedPlayerUids[uidKey] then
			countedPlayerUids[uidKey] = true

			appendStringId(playerUids, uidKey)
			appendActionId(playerActions, playerData.playerPoseId)

			if type(playerData.pets) == "table" then
				for _, petData in ipairs(playerData.pets) do
					if type(petData) == "table" then
						appendStringId(petIds, petData.petId)
						appendActionId(petActions, petData.petPoseId)
					end
				end
			end
		end
	end

	table.sort(playerActions)
	table.sort(petActions)
	table.sort(petIds)
	table.sort(playerUids)
	appendAssetIds(stickerIds, common.diyInfo, "id")
	appendAssetIds(ornamentIds, common.ornaments, "ornamentId")

	local lightIds = {}
	local lightId = tonumber(common.lightId)

	if lightId and lightId > 0 then
		lightIds[1] = lightId
	end

	return {
		studio_id = tonumber(metadata.studioId) or 0,
		studio_identity = tonumber(metadata.studioIdentity) or 0,
		duration = tonumber(metadata.duration) or 0,
		studio_group = {
			{
				player_action = playerActions,
				pet_action = petActions,
				sticker_id = stickerIds,
				filter_id = tonumber(common.filterId) or 0,
				light_id = lightIds,
				bg_id = tonumber(common.backgroundId) or 0,
				prop_id = ornamentIds,
				pet_id = petIds,
				player_uid = playerUids
			}
		}
	}
end

return PhotographyStudioEditBIUtils
