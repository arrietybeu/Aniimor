-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\Bisect.lua

local Bisect = {}

function Bisect.insort(a, x, lo, hi)
	lo = lo or 1
	hi = hi or #a
	hi = hi + 1

	while lo < hi do
		local mid = math.floor((lo + hi) / 2)
		local v = a[mid]

		if x < v then
			hi = mid
		else
			lo = mid + 1
		end
	end

	table.insert(a, lo, x)
end

function Bisect.insort_left(a, x, lo, hi)
	lo = lo or 1
	hi = hi or #a
	hi = hi + 1

	while lo < hi do
		local mid = math.floor((lo + hi) / 2)
		local v = a[mid]

		if x <= v then
			hi = mid
		else
			lo = mid + 1
		end
	end

	table.insert(a, lo, x)
end

function Bisect.bisect(a, x, lo, hi)
	lo = lo or 1
	hi = hi or #a
	hi = hi + 1

	while lo < hi do
		local mid = math.floor((lo + hi) / 2)
		local v = a[mid]

		if x < v then
			hi = mid
		else
			lo = mid + 1
		end
	end

	return lo
end

function Bisect.bisect_left(a, x, lo, hi)
	lo = lo or 1
	hi = hi or #a

	local i = math.floor((lo + hi) / 2)

	while lo < hi do
		if x >= a[i] then
			lo = i + 1
		else
			hi = i
		end

		i = math.floor((lo + hi) / 2)
	end

	return i
end

return Bisect
