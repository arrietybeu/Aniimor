-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Utils\\HandheldAppearanceUIUtils.lua

local HandheldAppearanceUIUtils = {}
local APPEARANCE_TYPE_PERIPHERAL = 5
local DEFAULT_ATTACH_BONE = "Bip001 L Hand"
local DEFAULT_POINT_ICON = "$UI_Img_Avatar_Dress_Accessory.png"
local FOOTPRINT_POINT_ID = 201
local HANDHELD_POINT_ID = 202
local EFFECT_POINT_ID = 203
local EMPTY_OPTION_STATE = "Null"

local function supportsEmptyState(pointId)
	return pointId == FOOTPRINT_POINT_ID or pointId == EFFECT_POINT_ID
end

local function supportsUnequipState(pointId)
	return supportsEmptyState(pointId) or pointId == HANDHELD_POINT_ID
end

local function normalizeActionIds(value)
	if type(value) == "number" then
		value = {
			value
		}
	elseif type(value) ~= "table" then
		return {}
	end

	local result = {}
	local seen = {}

	for _, actionId in ipairs(value) do
		if actionId and actionId > 0 and not seen[actionId] then
			result[#result + 1] = actionId
			seen[actionId] = true
		end
	end

	return result
end

local function normalizeVector(value)
	if not value then
		return {
			0,
			0,
			0
		}
	end

	return {
		value[1] or value.x or 0,
		value[2] or value.y or 0,
		value[3] or value.z or 0
	}
end

local function containsPoint(points, targetPoint)
	if not points then
		return false
	end

	for _, point in ipairs(points) do
		if point == targetPoint then
			return true
		end
	end

	return false
end

local function matchesBody(configBody, body)
	if not body or not configBody or #configBody == 0 then
		return true
	end

	for _, value in ipairs(configBody) do
		if value == body then
			return true
		end
	end

	return false
end

local function normalizeConfig(config, fallbackId)
	if not config or config.type ~= APPEARANCE_TYPE_PERIPHERAL or not config.points or #config.points == 0 then
		return nil
	end

	local id = config.id or fallbackId

	if not id or id <= 0 or not config.res or config.res == "" then
		return nil
	end

	local attachBone = config.socket or config.attachBone or config.attach_bone

	if not attachBone or attachBone == "" then
		attachBone = (not containsPoint(config.points, HANDHELD_POINT_ID) or nil) and DEFAULT_ATTACH_BONE
	end

	local attachScale = config.attachScale or config.attach_scale

	if not attachScale or attachScale <= 0 then
		attachScale = 1
	end

	local actionIds = normalizeActionIds(config.action or config.action_id or config.actions or config.action_ids)

	return {
		id = id,
		type = APPEARANCE_TYPE_PERIPHERAL,
		points = config.points,
		body = config.body,
		res = config.res,
		actionId = actionIds[1] or 0,
		actionIds = actionIds,
		playable = config.playable,
		allowMove = config.allow_move or 0,
		loop = config.loop or 0,
		attachBone = attachBone,
		attachPosition = normalizeVector(config.attachPosition or config.attach_position),
		attachRotation = normalizeVector(config.attachRotation or config.attach_rotation),
		attachScale = attachScale,
		icon = config.icon,
		name = config.name or config.debug_name or "",
		desc = config.desc or config.translateDesc or "",
		fashion = config.fashion or 0,
		quality = config.quality or 0,
		initialClaim = config.initialClaim == 1,
		localClaimed = config.claimed == true or config.claimed == 1,
		showStatus = config.showStatus or 1
	}
end

function HandheldAppearanceUIUtils.buildPointList(configs, pointData, body, equippedLookup)
	local pointMap = {}

	if not configs then
		return {}
	end

	for key, config in pairs(configs) do
		local normalized = normalizeConfig(config, key)

		if normalized and normalized.showStatus ~= 2 and matchesBody(normalized.body, body) then
			for _, rawPoint in ipairs(normalized.points) do
				local pointId = rawPoint

				if pointId and pointId >= 201 and pointId <= 204 and pointMap[pointId] == nil then
					local definition = pointData and pointData[pointId] or nil

					if not definition or definition.hidden ~= 1 then
						local equippedId = equippedLookup and equippedLookup(pointId) or 0

						pointMap[pointId] = {
							slotId = pointId,
							sort = definition and definition.sort or pointId,
							state = equippedId and equippedId > 0 and "Have" or "Empty",
							icon = definition and definition.icon or normalized.icon or DEFAULT_POINT_ICON,
							text = definition and definition.text or tostring(pointId),
							pointName = definition and definition.name or tostring(pointId),
							appearanceId = equippedId
						}
					end
				end
			end
		end
	end

	local result = {}

	for _, slot in pairs(pointMap) do
		result[#result + 1] = slot
	end

	table.sort(result, function(left, right)
		if left.sort ~= right.sort then
			return left.sort < right.sort
		end

		return left.slotId < right.slotId
	end)

	return result
end

function HandheldAppearanceUIUtils.buildOptionList(configs, pointId, equippedId, body, ownedLookup, redDotLookup)
	local result = {}

	if not configs or not pointId then
		return result
	end

	for key, config in pairs(configs) do
		local normalized = normalizeConfig(config, key)

		if normalized and containsPoint(normalized.points, pointId) and normalized.showStatus ~= 2 and matchesBody(normalized.body, body) then
			local claimed = normalized.localClaimed or normalized.initialClaim

			if ownedLookup then
				claimed = ownedLookup(normalized.id, config) == true or normalized.initialClaim
			end

			local equipped = normalized.id == equippedId

			if equipped then
				claimed = true
			end

			if normalized.showStatus ~= 3 or claimed then
				local state = equipped and "RoleWear" or claimed and "Have" or "Locked"

				result[#result + 1] = {
					itemId = normalized.id,
					handheldId = normalized.id,
					pointId = pointId,
					points = normalized.points,
					res = normalized.res,
					actionId = normalized.actionId,
					actionIds = normalized.actionIds,
					playable = normalized.playable,
					allowMove = normalized.allowMove,
					loop = normalized.loop,
					attachBone = normalized.attachBone,
					attachPosition = normalized.attachPosition,
					attachRotation = normalized.attachRotation,
					attachScale = normalized.attachScale,
					icon = normalized.icon,
					name = normalized.name,
					desc = normalized.desc,
					fashion = normalized.fashion,
					quality = normalized.quality,
					claimed = claimed,
					equipped = equipped,
					state = state,
					showRedDot = claimed and not equipped and not normalized.initialClaim and redDotLookup ~= nil and redDotLookup(normalized.id, config) == true
				}
			end
		end
	end

	table.sort(result, function(left, right)
		if left.quality ~= right.quality then
			return left.quality > right.quality
		end

		return left.handheldId < right.handheldId
	end)

	if supportsEmptyState(pointId) then
		table.insert(result, 1, {
			claimed = true,
			itemId = -1,
			handheldId = 0,
			isEmpty = true,
			showRedDot = false,
			quality = 0,
			pointId = pointId,
			equipped = not equippedId or equippedId <= 0,
			state = EMPTY_OPTION_STATE
		})
	end

	return result
end

function HandheldAppearanceUIUtils.getDefaultActionId(item)
	if not item then
		return nil
	end

	for _, actionId in ipairs(item.actionIds or {}) do
		if actionId and actionId > 0 then
			return actionId
		end
	end

	local actionId = item.actionId

	return actionId and actionId > 0 and actionId or nil
end

function HandheldAppearanceUIUtils.getPreviewPlayable(item, fallback)
	local playable = item and item.playable

	if playable and playable ~= "" then
		return playable
	end

	return fallback
end

function HandheldAppearanceUIUtils.resolveSelection(equippedId, item)
	if item and item.isEmpty == true then
		if supportsUnequipState(item.pointId) then
			if not equippedId or equippedId <= 0 then
				return {
					commit = false,
					equippedId = 0,
					action = "KEEP"
				}
			end

			return {
				commit = true,
				equippedId = 0,
				action = "UNEQUIP"
			}
		end

		return {
			commit = false,
			action = "IGNORE",
			equippedId = equippedId
		}
	end

	if not item or not item.handheldId or not item.res or item.res == "" then
		return {
			commit = false,
			action = "IGNORE",
			equippedId = equippedId
		}
	end

	if not item.claimed then
		return {
			commit = false,
			action = "PREVIEW",
			equippedId = equippedId
		}
	end

	if item.handheldId == equippedId then
		if item.pointId == HANDHELD_POINT_ID then
			return {
				commit = true,
				equippedId = 0,
				action = "UNEQUIP"
			}
		end

		return {
			commit = false,
			action = "KEEP",
			equippedId = equippedId
		}
	end

	return {
		commit = true,
		action = "EQUIP",
		equippedId = item.handheldId
	}
end

function HandheldAppearanceUIUtils.resolveExit(equippedId, previewId)
	return {
		action = previewId and "RESTORE" or "KEEP",
		equippedId = equippedId,
		clearPreview = previewId ~= nil
	}
end

function HandheldAppearanceUIUtils.buildActionVisibility(configs, pointData, body, actionData)
	local result = {}

	for id, config in pairs(configs or {}) do
		if config.type == APPEARANCE_TYPE_PERIPHERAL then
			local actionIds = normalizeActionIds(config.action or config.action_id or config.actions or config.action_ids)

			if #actionIds > 0 then
				local hasVisiblePoint = #HandheldAppearanceUIUtils.buildPointList({
					[id] = config
				}, pointData, body) > 0

				for _, actionId in ipairs(actionIds) do
					local action = actionData and actionData[actionId]
					local visible = hasVisiblePoint and matchesBody(action and action.body, body)

					result[actionId] = result[actionId] == true or visible
				end
			end
		end
	end

	return result
end

return HandheldAppearanceUIUtils
