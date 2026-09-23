-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Math\\vector2.lua

local sqrt = math.sqrt
local clamp = math.clamp
local acos = math.acos
local setmetatable = setmetatable
local rawset = rawset
local rawget = rawget
local Vector2 = {
	banInspect = true,
	class = "Vector2"
}

setmetatable(Vector2, Vector2)

local fields = {}

function Vector2.__index(t, k)
	if k == "x" then
		return t[1]
	elseif k == "y" then
		return t[2]
	end

	local var = rawget(Vector2, k)

	if var == nil then
		var = rawget(fields, k)

		if var ~= nil then
			return var(t)
		end
	end

	return var
end

function Vector2:__call(x, y)
	return Vector2.New(x, y)
end

function Vector2.New(x, y)
	local v = {
		x or 0,
		y or 0
	}

	setmetatable(v, Vector2)

	return v
end

function Vector2:Set(x, y)
	self[1] = x or 0
	self[2] = y or 0
end

function Vector2:Get()
	return self[1], self[2]
end

function Vector2:SqrMagnitude()
	return self[1] * self[1] + self[2] * self[2]
end

function Vector2:Clone()
	return Vector2.New(self[1] or self.x, self[2] or self.y)
end

function Vector2:Normalize()
	local v = self:Clone()

	return v:SetNormalize()
end

function Vector2:SetNormalize()
	local num = self:Magnitude()

	if num == 1 then
		return self
	elseif num > 1e-05 then
		self:Div(num)
	else
		self:Set(0, 0)
	end

	return self
end

function Vector2.NormalizeVec2XY(x, y)
	local num = sqrt(x * x + y * y)

	if num == 1 then
		return x, y
	elseif num > 1e-05 then
		x = x / num
		y = y / num
	else
		x = 0
		y = 0
	end

	return x, y
end

function Vector2.Dot(lhs, rhs)
	return lhs[1] * rhs[1] + lhs[2] * rhs[2]
end

function Vector2.Cross(lhs, rhs)
	return lhs[1] * rhs[2] - lhs[2] * rhs[1]
end

function Vector2.Angle(from, to)
	return acos(clamp(Vector2.Dot(from:Normalize(), to:Normalize()), -1, 1)) * 57.29578
end

function Vector2.Intersect(a, b, c, d)
	if (a[1] > b[1] and a[1] or b[1]) < (c[1] < d[1] and c[1] or d[1]) or (c[1] > d[1] and c[1] or d[1]) < (a[1] < b[1] and a[1] or b[1]) or (a[2] > b[2] and a[2] or b[2]) < (c[2] < d[2] and c[2] or d[2]) or (c[2] > d[2] and c[2] or d[2]) < (a[2] < b[2] and a[2] or b[2]) then
		return false
	end

	local ab = b - a
	local cd = d - c
	local abXac = Vector2.Cross(ab, c - a)
	local abXad = Vector2.Cross(ab, d - a)
	local cdXca = Vector2.Cross(cd, a - c)
	local cdXcb = Vector2.Cross(cd, b - c)

	if abXac * abXad > 0 or cdXca * cdXcb > 0 then
		return false
	end

	return true
end

function Vector2.Magnitude(v2)
	return sqrt(v2[1] * v2[1] + v2[2] * v2[2])
end

function Vector2:Div(d)
	self[1] = self[1] / d
	self[2] = self[2] / d

	return self
end

function Vector2:Mul(d)
	self[1] = self[1] * d
	self[2] = self[2] * d

	return self
end

function Vector2:Add(b)
	self[1] = self[1] + b[1]
	self[2] = self[2] + b[2]

	return self
end

function Vector2:Sub(b)
	self[1] = self[1] - b[1]
	self[2] = self[2] - b[2]
end

local v2 = {}

function Vector2.Distance(x1, y1, x2, y2)
	v2[1] = x1 - x2
	v2[2] = y1 - y2

	return sqrt(v2[1] * v2[1] + v2[2] * v2[2])
end

function Vector2.Lerp(from, to, t)
	t = clamp(t, 0, 1)

	return Vector2.New(from[1] + (to[1] - from[1]) * t, from[2] + (to[2] - from[2]) * t)
end

function Vector2:__tostring()
	local x = self[1] or "nil"
	local y = self[2] or "nil"

	return string.format("2:%s|%s", x, y)
end

function Vector2.__div(va, d)
	return Vector2.New(va[1] / d, va[2] / d)
end

function Vector2.__mul(va, d)
	return Vector2.New(va[1] * d, va[2] * d)
end

function Vector2.__add(va, vb)
	return Vector2.New(va[1] + vb[1], va[2] + vb[2])
end

function Vector2.__sub(va, vb)
	return Vector2.New(va[1] - vb[1], va[2] - vb[2])
end

function Vector2.__unm(va)
	return Vector2.New(-va[1], -va[2])
end

function Vector2.__eq(va, vb)
	return va[1] == vb[1] and va[2] == vb[2]
end

function fields.up()
	return Vector2.New(0, 1)
end

function fields.right()
	return Vector2.New(1, 0)
end

function fields.zero()
	return Vector2.New(0, 0)
end

function fields.one()
	return Vector2.New(1, 1)
end

fields.magnitude = Vector2.Magnitude
fields.normalized = Vector2.Normalize
fields.sqrMagnitude = Vector2.SqrMagnitude

function Vector2.__newindex(t, k, v)
	if k == "x" then
		rawset(t, 1, v)
	elseif k == "y" then
		rawset(t, 2, v)
	else
		error("Vector2 only can set x,y property")
	end
end

return Vector2
