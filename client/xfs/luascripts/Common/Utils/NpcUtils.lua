-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\NpcUtils.lua

local lume = require("Core.Common.lume")
local puppetData = require("Data.puppet_data")
local NpcUtils = {}

function NpcUtils.getNpcTurnMultiplier(templateId, angle)
	local ncdd = puppetData[templateId]

	if ncdd and ncdd.turnCurve then
		local angles = {}

		for curAngle, _ in pairs(ncdd.turnCurve) do
			angles[#angles + 1] = curAngle
		end

		table.sort(angles)

		for i = 1, #angles - 1 do
			local curAngle = angles[i]
			local nextAngle = angles[i + 1]

			if curAngle <= angle and angle < nextAngle then
				local t = (angle - curAngle) / (nextAngle - curAngle)

				return lume.lerp(ncdd.turnCurve[curAngle], ncdd.turnCurve[nextAngle], t)
			end
		end

		return ncdd.turnCurve[angles[#angles]]
	end
end

function NpcUtils.getNpcTurnTime(templateId, angle)
	local turnSpeedMultiplier = getNpcTurnMultiplier(templateId, angle)

	if turnSpeedMultiplier and turnSpeedMultiplier > 0 then
		local ncdd = puppetData[templateId]

		if ncdd.defaultTurnTime then
			return ncdd.defaultTurnTime / turnSpeedMultiplier
		end
	end
end

return NpcUtils
