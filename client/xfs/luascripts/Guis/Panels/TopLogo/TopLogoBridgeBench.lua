-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\TopLogo\\TopLogoBridgeBench.lua

local File = require("Core.Common.File")
local TopLogoBridgeBench = {}
local _getNs = phonestcore.getNanosecondUTC
local _nsPerUs = 1000

local function baseline_add(n)
	local acc = 0

	for i = 1, n do
		acc = acc + i
	end

	return acc
end

local function bench_eModelPlayerDistance(ent, n)
	local sum = 0
	local m = ent.eModel

	for i = 1, n do
		sum = sum + m.playerDistance
	end

	return sum
end

local function bench_entityGetPlayerDistance(ent, n)
	local sum = 0

	for i = 1, n do
		sum = sum + ent:getPlayerDistance()
	end

	return sum
end

local function bench_shellDistance(ent, n)
	local sum = 0
	local shell = ent.topLogoShell

	if not shell then
		return -1
	end

	for i = 1, n do
		sum = sum + shell:getDistance()
	end

	return sum
end

local function bench_luaTableField(n)
	local t = {
		sqrDistance = 1234.5
	}
	local sum = 0

	for i = 1, n do
		sum = sum + t.sqrDistance
	end

	return sum
end

local function bench_vector3Distance(ent, n)
	if not pg.me or not pg.me.getPosition or not ent.getPosition then
		return -1
	end

	local sum = 0

	for i = 1, n do
		sum = sum + Vector3.Distance(ent:getPosition(), pg.me:getPosition())
	end

	return sum
end

local function measureOneRound(name, fn)
	fn()

	local t0 = _getNs()

	fn()

	local t1 = _getNs()

	return {
		name = name,
		us = (t1 - t0) / _nsPerUs
	}
end

local function pickEntity()
	local entities = pg.game and pg.game.space and pg.game.space.entities

	if entities then
		for _, ent in pairs(entities) do
			if ent and ent ~= pg.me and ent.eModel and ent.getPlayerDistance then
				return ent
			end
		end
	end

	return pg.me
end

function TopLogoBridgeBench.run(n, outputPath)
	n = n or 1000

	local ent = pickEntity()

	if not ent then
		print("[BridgeBench] no entity to test on")

		return
	end

	local groups = 5
	local accum = {}

	local function ensure(name)
		if not accum[name] then
			accum[name] = {
				rounds = 0,
				max_us = 0,
				total_us = 0,
				min_us = math.huge
			}
		end

		return accum[name]
	end

	for g = 1, groups do
		local rounds = {
			measureOneRound("baseline_add", function()
				baseline_add(n)
			end),
			measureOneRound("eModel.playerDistance", function()
				bench_eModelPlayerDistance(ent, n)
			end),
			measureOneRound("entity:getPlayerDistance()", function()
				bench_entityGetPlayerDistance(ent, n)
			end),
			measureOneRound("shell:getDistance()", function()
				bench_shellDistance(ent, n)
			end),
			measureOneRound("luaTable.sqrDistance", function()
				bench_luaTableField(n)
			end),
			measureOneRound("Vector3.Distance", function()
				bench_vector3Distance(ent, n)
			end)
		}

		for _, r in ipairs(rounds) do
			local a = ensure(r.name)

			a.total_us = a.total_us + r.us

			if r.us < a.min_us then
				a.min_us = r.us
			end

			if r.us > a.max_us then
				a.max_us = r.us
			end

			a.rounds = a.rounds + 1
		end
	end

	local order = {
		"baseline_add",
		"eModel.playerDistance",
		"entity:getPlayerDistance()",
		"shell:getDistance()",
		"luaTable.sqrDistance",
		"Vector3.Distance"
	}
	local lines = {}

	lines[#lines + 1] = string.format("===== TopLogoBridgeBench (n=%d per round, rounds=%d) =====", n, groups)
	lines[#lines + 1] = string.format("entity = %s (actorId=%s)", tostring(ent), tostring(ent and ent.actorId or "?"))
	lines[#lines + 1] = string.format("%-35s %12s %12s %12s %12s", "name", "avg_us", "min_us", "max_us", "ns/call(avg)")

	for _, name in ipairs(order) do
		local a = accum[name]

		if a and a.rounds > 0 then
			local avg = a.total_us / a.rounds
			local nsPerCall = avg * _nsPerUs / n

			lines[#lines + 1] = string.format("%-35s %12.2f %12.2f %12.2f %12.2f", name, avg, a.min_us, a.max_us, nsPerCall)
		end
	end

	lines[#lines + 1] = ""
	lines[#lines + 1] = "ns/call: 单次调用平均纳秒，用于横向比较桥调用与纯 Lua 开销"

	local text = table.concat(lines, "\n")

	print(text)

	if outputPath then
		File.writePath(outputPath, text)
	end

	return accum
end

function TopLogoBridgeBench.runOneFrame(n)
	n = n or 1000

	local ent = pickEntity()

	if not ent then
		print("[BridgeBench] no entity to test on")

		return
	end

	local t0 = _getNs()

	bench_eModelPlayerDistance(ent, n)

	local t1 = _getNs()

	print(string.format("[BridgeBench] eModel.playerDistance x%d in one frame: %.2f us (%.1f ns/call)", n, (t1 - t0) / _nsPerUs, (t1 - t0) / n))

	t0 = _getNs()

	bench_shellDistance(ent, n)

	t1 = _getNs()

	print(string.format("[BridgeBench] shell:getDistance() x%d in one frame: %.2f us (%.1f ns/call)", n, (t1 - t0) / _nsPerUs, (t1 - t0) / n))
end

return TopLogoBridgeBench
