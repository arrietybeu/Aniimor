-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Math\\luaVector3.lua

local Vector3 = LuaVector3

Vector3.class = "Vector3"
Vector3.className = "Vector3"
Vector3.banInspect = true

function Vector3.BezierLerp(points, t)
	assert(type(points) == "table" and #points > 0, "can not lerp invalid points list")

	if #points == 1 then
		return points[1]
	end

	local newPoints = {}

	for i = 1, #points - 1 do
		local vec = points[i + 1] - points[i]

		table.insert(newPoints, points[i] + t * vec)
	end

	return Vector3.BezierLerp(newPoints, t)
end

function Vector3:__tostring()
	local x = self[1] or 0
	local y = self[2] or 0
	local z = self[3] or 0

	return string.format("3:%.2f|%.2f|%.2f", x, y, z)
end

function Vector3:toString()
	return string.format("{%.2f, %.2f, %.2f}", self[1], self[2], self[3])
end

function Vector3.Reflect(inDirection, inNormal)
	local num = -2 * Vector3.Dot(inNormal, inDirection)

	inNormal = inNormal * num

	inNormal:Add(inDirection)

	return inNormal
end

function Vector3.ToYaw(dir)
	return math.atan2(dir[1], dir[3])
end

function Vector3.CrossByCache(lhs, rhs, cacheVector3)
	cacheVector3[1] = lhs[2] * rhs[3] - lhs[3] * rhs[2]
	cacheVector3[2] = lhs[3] * rhs[1] - lhs[1] * rhs[3]
	cacheVector3[3] = lhs[1] * rhs[2] - lhs[2] * rhs[1]

	return cacheVector3
end

function Vector3:Equals(other)
	return self == other
end

function Vector3.ToYaw(dir)
	return math.atan2(dir[1], dir[3])
end

function Vector3.AddByCache(lhs, rhs, cacheVector3)
	cacheVector3[1] = lhs[1] + rhs[1]
	cacheVector3[2] = lhs[2] + rhs[2]
	cacheVector3[3] = lhs[3] + rhs[3]

	return cacheVector3
end

function Vector3.SubByCache(lhs, rhs, cacheVector3)
	cacheVector3[1] = lhs[1] - rhs[1]
	cacheVector3[2] = lhs[2] - rhs[2]
	cacheVector3[3] = lhs[3] - rhs[3]

	return cacheVector3
end

setmetatable(Vector3, Vector3)

return Vector3
