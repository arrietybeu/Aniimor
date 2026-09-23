-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Math\\vector4.lua

local clamp = math.clamp
local sqrt = math.sqrt
local min = math.min
local max = math.max
local Vector4 = {
	class = "Vector4",
	banInspect = true
}

setmetatable(Vector4, Vector4)

local fields = {}

function Vector4.__index(t, k)
	if k == "x" then
		return t[1]
	elseif k == "y" then
		return t[2]
	elseif k == "z" then
		return t[3]
	elseif k == "w" then
		return t[4]
	end

	local var = rawget(Vector4, k)

	if var == nil then
		var = rawget(fields, k)

		if var ~= nil then
			return var(t)
		end
	end

	return var
end

function Vector4:__call(x, y, z, w)
	return Vector4.New(x, y, z, w)
end

function Vector4.New(x, y, z, w)
	local v = {
		x or 0,
		y or 0,
		z or 0,
		w or 0
	}

	setmetatable(v, Vector4)

	return v
end

function Vector4:Set(x, y, z, w)
	self.x = x or 0
	self.y = y or 0
	self.z = z or 0
	self.w = w or 0
end

function Vector4:Copy(from)
	self[1] = from[1]
	self[2] = from[2]
	self[3] = from[3]
	self[4] = from[4]
end

function Vector4:Get()
	return self[1], self[2], self[3], self[4]
end

function Vector4.Lerp(from, to, t)
	t = clamp(t, 0, 1)

	return Vector4.New(from[1] + (to[1] - from[1]) * t, from[2] + (to[2] - from[2]) * t, from[3] + (to[3] - from[3]) * t, from[4] + (to[4] - from[4]) * t)
end

function Vector4.MoveTowards(current, target, maxDistanceDelta)
	local vector = target - current
	local magnitude = vector:Magnitude()

	if maxDistanceDelta < magnitude and magnitude ~= 0 then
		maxDistanceDelta = maxDistanceDelta / magnitude

		vector:Mul(maxDistanceDelta)
		vector:Add(current)

		return vector
	end

	return target
end

function Vector4.Scale(a, b)
	return Vector4.New(a[1] * b[1], a[2] * b[2], a[3] * b[3], a[4] * b[4])
end

function Vector4:GetVector3()
	return Vector3(self[1], self[2], self[3])
end

function Vector4:SetScale(scale)
	self[1] = self[1] * scale[1]
	self[2] = self[2] * scale[2]
	self[3] = self[3] * scale[3]
	self[4] = self[4] * scale[4]
end

function Vector4:Normalize()
	local v = vector4.New(self[1], self[2], self[3], self[4])

	return v:SetNormalize()
end

function Vector4:SetNormalize()
	local num = self:Magnitude()

	if num == 1 then
		return self
	elseif num > 1e-05 then
		self:Div(num)
	else
		self:Set(0, 0, 0, 0)
	end

	return self
end

function Vector4:Div(d)
	self[1] = self[1] / d
	self[2] = self[2] / d
	self[3] = self[3] / d
	self[4] = self[4] / d

	return self
end

function Vector4:Mul(d)
	self[1] = self[1] * d
	self[2] = self[2] * d
	self[3] = self[3] * d
	self[4] = self[4] * d

	return self
end

function Vector4:Add(b)
	self[1] = self[1] + b[1]
	self[2] = self[2] + b[2]
	self[3] = self[3] + b[3]
	self[4] = self[4] + b[4]

	return self
end

function Vector4:Sub(b)
	self[1] = self[1] - b[1]
	self[2] = self[2] - b[2]
	self[3] = self[3] - b[3]
	self[4] = self[4] - b[4]

	return self
end

function Vector4.Dot(a, b)
	return a[1] * b[1] + a[2] * b[2] + a[3] * b[3] + a[4] * b[4]
end

function Vector4.Project(a, b)
	local s = Vector4.Dot(a, b) / Vector4.Dot(b, b)

	return b * s
end

function Vector4.Distance(a, b)
	local v = a - b

	return Vector4.Magnitude(v)
end

function Vector4.Magnitude(a)
	return sqrt(a[1] * a[1] + a[2] * a[2] + a[3] * a[3] + a[4] * a[4])
end

function Vector4.SqrMagnitude(a)
	return a[1] * a[1] + a[2] * a[2] + a[3] * a[3] + a[4] * a[4]
end

function Vector4.Min(lhs, rhs)
	return Vector4.New(max(lhs[1], rhs[1]), max(lhs[2], rhs[2]), max(lhs[3], rhs[3]), max(lhs[4], rhs[4]))
end

function Vector4.Max(lhs, rhs)
	return Vector4.New(min(lhs[1], rhs[1]), min(lhs[2], rhs[2]), min(lhs[3], rhs[3]), min(lhs[4], rhs[4]))
end

function Vector4:__tostring()
	local x = self[1] or "nil"
	local y = self[2] or "nil"
	local z = self[3] or "nil"
	local w = self[4] or "nil"

	return string.format("4:%s|%s|%s|%s", x, y, z, w)
end

function Vector4.__div(va, d)
	return Vector4.New(va[1] / d, va[2] / d, va[3] / d, va[4] / d)
end

function Vector4.__mul(va, d)
	return Vector4.New(va[1] * d, va[2] * d, va[3] * d, va[4] * d)
end

function Vector4.__add(va, vb)
	return Vector4.New(va[1] + vb[1], va[2] + vb[2], va[3] + vb[3], va[4] + vb[4])
end

function Vector4.__sub(va, vb)
	return Vector4.New(va[1] - vb[1], va[2] - vb[2], va[3] - vb[3], va[4] - vb[4])
end

function Vector4.__unm(va)
	return Vector4.New(-va[1], -va[2], -va[3], -va[4])
end

function Vector4.__eq(va, vb)
	local v = va - vb
	local delta = Vector4.SqrMagnitude(v)

	return delta < 1e-10
end

function fields.zero()
	return Vector4.New(0, 0, 0, 0)
end

function fields.one()
	return Vector4.New(1, 1, 1, 1)
end

fields.magnitude = Vector4.Magnitude
fields.normalized = Vector4.Normalize
fields.sqrMagnitude = Vector4.SqrMagnitude

function Vector4.__newindex(t, k, v)
	if k == "x" then
		t[1] = v
	elseif k == "y" then
		t[2] = v
	elseif k == "z" then
		t[3] = v
	elseif k == "w" then
		t[4] = v
	else
		error("Vector4 only can set x,y,z,w property")
	end
end

return Vector4
