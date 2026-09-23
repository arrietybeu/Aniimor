-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\AreaDebugBridge.lua

local LuaCondition = require("Common.Utils.LuaCondition")
local M = {}

local function getAreaData(space, id)
	if space and space.getAreaData then
		local ok, d = pcall(space.getAreaData, space, id)

		if ok then
			return d
		end
	end

	return nil
end

local function formatVal(v)
	local t = type(v)

	if t == "table" then
		local parts = {}

		for k = 1, #v do
			parts[k] = formatVal(v[k])
		end

		return "{" .. table.concat(parts, ",") .. "}"
	end

	return tostring(v)
end

function M.resolveEntity(mode, entityId)
	if mode == "me" then
		return pg and pg.me, "me"
	elseif mode == "pawn" then
		return pg and pg.pawn, "pawn"
	elseif mode == "id" then
		if not pg or not pg.getEntity then
			return nil, "no pg.getEntity"
		end

		local id = tonumber(entityId)

		if not id then
			return nil, "invalid id"
		end

		return pg.getEntity(id), "id=" .. tostring(id)
	end

	return nil, "unknown mode"
end

function M.dump(mode, entityId)
	local me, debugName = M.resolveEntity(mode, entityId)

	if not me then
		return {
			ok = false,
			err = "no entity (" .. tostring(debugName) .. ")"
		}
	end

	if not me.areas then
		return {
			ok = false,
			err = "entity has no ClientAreaHandlerComponent (id=" .. tostring(me.id) .. ")",
			pawnId = me.id
		}
	end

	local space = me.space
	local areas = {}

	for i, areaId in ipairs(me.areas) do
		local data = getAreaData(space, areaId)
		local entry = {
			statesStr = "",
			logicIdx = -1,
			loadType = -1,
			id = areaId,
			statesDetail = {}
		}

		if data then
			entry.loadType = data.areaLoadType or -1

			if data.logics then
				for li, logic in ipairs(data.logics) do
					local okCond, hit = pcall(LuaCondition.checkCondition, me, logic.condition)

					if okCond and hit then
						entry.logicIdx = li

						if logic.states then
							local sb = {}

							for _, s in ipairs(logic.states) do
								sb[#sb + 1] = tostring(s[1])

								local argParts = {}

								for k = 2, #s do
									argParts[#argParts + 1] = formatVal(s[k])
								end

								entry.statesDetail[#entry.statesDetail + 1] = {
									name = tostring(s[1]),
									args = table.concat(argParts, ", ")
								}
							end

							entry.statesStr = table.concat(sb, ",")
						end

						break
					end
				end
			end
		end

		areas[#areas + 1] = entry
	end

	local states = {}

	if me.areaStateMap then
		for name, bucket in pairs(me.areaStateMap) do
			local list = bucket.list
			local sb = {}

			for _, s in ipairs(list) do
				local parts = {}

				for k = 1, #s do
					parts[k] = tostring(s[k])
				end

				sb[#sb + 1] = "{" .. table.concat(parts, ",") .. "}"
			end

			states[#states + 1] = {
				name = name,
				count = #list,
				raw = table.concat(sb, " ")
			}
		end
	end

	return {
		ok = true,
		pawnId = me.id,
		areas = areas,
		states = states
	}
end

return M
