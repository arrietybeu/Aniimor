-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Math\\vector3.lua

local acos = math.acos
local sqrt = math.sqrt
local max = math.max
local min = math.min
local clamp = math.clamp
local cos = math.cos
local sin = math.sin
local abs = math.abs
local sign = math.sign
local setmetatable = setmetatable
local rawset = rawset
local rawget = rawget
local smallNumber = math.smallNumber
local k1OverSqrt2 = 0.7071067811865476
local rad2Deg = math.rad2Deg
local deg2Rad = math.deg2Rad
local raw_next = rawget(_G, "raw_next") or next
local profileDebug = false
local Vector3 = {
	banInspect = true,
	className = "Vector3",
	class = "Vector3",
	createFromCacheRefCnt = 0
}
local cacheDic = {}
local usingTempVectorMap = {}
local lightCacheStack = {}
local manualCacheStack = {}
local clearQuaternionFunction

function Vector3.setClearQuaFunction(fun)
	clearQuaternionFunction = fun
end

function Vector3.enableCreateFromCache()
	Vector3.createFromCacheRefCnt = Vector3.createFromCacheRefCnt + 1
end

function Vector3.disableCreateFromCache(...)
	for i = 1, select("#", ...) do
		Vector3.removeTempVector3(select(i, ...))
	end

	if Vector3.createFromCacheRefCnt > 0 then
		Vector3.createFromCacheRefCnt = Vector3.createFromCacheRefCnt - 1

		if Vector3.createFromCacheRefCnt == 0 then
			for k, _ in pairs(usingTempVectorMap) do
				k[4] = 1
				usingTempVectorMap[k] = nil
				cacheDic[k] = true
			end

			clearQuaternionFunction(true)
		end
	end
end

function Vector3.checkCache()
	if Vector3.createFromCacheRefCnt ~= 0 then
		if pg.me then
			pg.me.logger:error("createFromCacheRefCnt ~= 0", Vector3.createFromCacheRefCnt)
		end

		if not UNITY_EDITOR then
			Vector3.createFromCacheRefCnt = 0
		end

		for k, _ in pairs(usingTempVectorMap) do
			usingTempVectorMap[k] = nil
		end

		clearQuaternionFunction(false)
	end
end

function Vector3.getCacheDic()
	return cacheDic
end

function Vector3.getUsingTempVectorMap()
	return usingTempVectorMap
end

function Vector3.removeTempVector3(v)
	if not v then
		return
	end

	if usingTempVectorMap[v] then
		usingTempVectorMap[v] = nil
	end
end

function Vector3.getFromCache()
	local v = raw_next(cacheDic)

	if v then
		v[4] = 0

		v:Set(0, 0, 0)

		cacheDic[v] = nil

		return v
	end

	return Vector3.New()
end

function Vector3.returnToCache(v)
	cacheDic[v] = true
	v[4] = 1
end

function Vector3.GetFromPool(x, y, z)
	if #manualCacheStack > 0 then
		local v = table.remove(manualCacheStack)

		v:Set(x, y, z)

		return v
	else
		return Vector3.ForceNew(x, y, z)
	end
end

function Vector3.returnToPool(v)
	if not v then
		return
	end

	assert(v[4] ~= 1, "ReadOnlyVector3")
	table.insert(manualCacheStack, v)
end

local fields = {}
local sx = "x"
local sy = "y"
local sz = "z"
local sro = "ro"

setmetatable(Vector3, Vector3)

function Vector3.__index(t, k)
	if k == sx then
		return t[1]
	elseif k == sy then
		return t[2]
	elseif k == sz then
		return t[3]
	elseif k == sro then
		return t[4]
	end

	local var = rawget(Vector3, k)

	if var == nil then
		var = rawget(fields, k)

		if var ~= nil then
			return var(t)
		end
	end

	return var
end

function Vector3:__call(x, y, z)
	return Vector3.New(x, y, z)
end

local AppMemAllocStats = require("Core.Profiler.AppMemAllocStats")

if profileDebug then
	function Vector3.New(x, y, z)
		local v

		if Vector3.createFromCacheRefCnt > 0 and raw_next(cacheDic) then
			v = raw_next(cacheDic)
			cacheDic[v] = nil
			v[4] = 0

			v:Set(x or 0, y or 0, z or 0)

			usingTempVectorMap[v] = true
		else
			AppMemAllocStats.collect_stack(93)

			v = {
				x or 0,
				y or 0,
				z or 0
			}

			setmetatable(v, Vector3)

			if Vector3.createFromCacheRefCnt > 0 then
				usingTempVectorMap[v] = true
			end
		end

		return v
	end

	function Vector3.ForceNew(x, y, z)
		local v = {
			x or 0,
			y or 0,
			z or 0
		}

		AppMemAllocStats.collect_stack(93)
		setmetatable(v, Vector3)

		return v
	end
else
	function Vector3.New(x, y, z)
		local v

		if Vector3.createFromCacheRefCnt > 0 and raw_next(cacheDic) then
			v = raw_next(cacheDic)
			cacheDic[v] = nil
			v[4] = 0

			v:Set(x or 0, y or 0, z or 0)

			usingTempVectorMap[v] = true
		else
			v = {
				x or 0,
				y or 0,
				z or 0
			}

			setmetatable(v, Vector3)

			if Vector3.createFromCacheRefCnt > 0 then
				usingTempVectorMap[v] = true
			end
		end

		return v
	end

	function Vector3.ForceNew(x, y, z)
		local v = {
			x or 0,
			y or 0,
			z or 0
		}

		setmetatable(v, Vector3)

		return v
	end
end

function Vector3.Convert(t)
	if t then
		setmetatable(t, Vector3)
	end

	return t
end

function Vector3.NewReadOnly(x, y, z)
	local v = Vector3.New(x, y, z)

	v[4] = 1

	return v
end

function Vector3:Set(x, y, z)
	assert(self[4] == nil or self[4] == 0, "can not set a read-only Vector3")

	self[1] = x or 0
	self[2] = y or 0
	self[3] = z or 0
end

function Vector3:Copy(from)
	assert(self[4] == nil or self[4] == 0, "can not set a read-only Vector3")

	self[1] = from[1] or 0
	self[2] = from[2] or 0
	self[3] = from[3] or 0
end

function Vector3:CopyTo(destVec)
	assert(destVec[4] == nil or self[4] == 0, "can not set a read-only Vector3")

	destVec[1] = self[1] or 0
	destVec[2] = self[2] or 0
	destVec[3] = self[3] or 0
end

function Vector3:Get()
	return self[1], self[2], self[3]
end

function Vector3:getRawTable()
	return {
		self[1],
		self[2],
		self[3]
	}
end

function Vector3:toString()
	return string.format("{%.2f, %.2f, %.2f}", self[1], self[2], self[3])
end

function Vector3:Clone()
	if self == nil then
		return nil
	end

	return Vector3.New(self[1] or self[1], self[2] or self[2], self[3] or self[3])
end

function Vector3:CloneFromPool()
	if self == nil then
		return nil
	end

	return Vector3.GetFromPool(self[1] or self[1], self[2] or self[2], self[3] or self[3])
end

function Vector3:ForceClone()
	if self == nil then
		return nil
	end

	return Vector3.ForceNew(self[1], self[2], self[3])
end

function Vector3.HoriDistance(va, vb)
	local dx, dz = va[1] - vb[1], va[3] - vb[3]

	return sqrt(dx * dx + dz * dz)
end

function Vector3.HoriDistanceEx(px, pz, qx, qz)
	local dx, dz = px - qx, pz - qz

	return sqrt(dx * dx + dz * dz)
end

function Vector3.HoriManhattanDistance(va, vb)
	return abs(va[1] - vb[1]) + abs(va[3] - vb[3])
end

function Vector3.HoriSqrDistance(va, vb)
	local dx, dz = va[1] - vb[1], va[3] - vb[3]

	return dx * dx + dz * dz
end

function Vector3.Distance(va, vb)
	local dx, dy, dz = va[1] - vb[1], va[2] - vb[2], va[3] - vb[3]

	return sqrt(dx * dx + dy * dy + dz * dz)
end

function Vector3.SqrDistance(va, vb)
	local dx, dy, dz = va[1] - vb[1], va[2] - vb[2], va[3] - vb[3]

	return dx * dx + dy * dy + dz * dz
end

function Vector3.SqrDistanceEx(px, py, pz, qx, qy, qz)
	local dx, dy, dz = px - qx, py - qy, pz - qz

	return dx * dx + dy * dy + dz * dz
end

function Vector3.Dot(lhs, rhs)
	return lhs[1] * rhs[1] + lhs[2] * rhs[2] + lhs[3] * rhs[3]
end

function Vector3.HasChanged(v1, v2, epsilon)
	epsilon = epsilon or 1e-05

	return epsilon < math.abs(v1.x - v2.x) or epsilon < math.abs(v1.y - v2.y) or epsilon < math.abs(v1.z - v2.z)
end

function Vector3.squareDistNoZAxis(pos1, pos2)
	local x = pos1[1] - pos2[1]
	local y = pos1[2] - pos2[2]

	return x * x + y * y
end

function Vector3.Lerp(from, to, t)
	t = clamp(t, 0, 1)

	return Vector3.New(from[1] + (to[1] - from[1]) * t, from[2] + (to[2] - from[2]) * t, from[3] + (to[3] - from[3]) * t)
end

function Vector3.BezierLerpQuad(p1, p2, controlPoint, t)
	local oneMinusT = 1 - t
	local oneMinusTquad = oneMinusT * oneMinusT
	local tQuad = t * t
	local lerpX = oneMinusTquad * p1[1] + 2 * oneMinusT * t * controlPoint[1] + tQuad * p2[1]
	local lerpY = oneMinusTquad * p1[2] + 2 * oneMinusT * t * controlPoint[2] + tQuad * p2[2]
	local lerpZ = oneMinusTquad * p1[3] + 2 * oneMinusT * t * controlPoint[3] + tQuad * p2[3]

	return Vector3.New(lerpX, lerpY, lerpZ)
end

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

function Vector3:Magnitude()
	return sqrt(self[1] * self[1] + self[2] * self[2] + self[3] * self[3])
end

function Vector3.Max(lhs, rhs)
	return Vector3.New(max(lhs[1], rhs[1]), max(lhs[2], rhs[2]), max(lhs[3], rhs[3]))
end

function Vector3.Min(lhs, rhs)
	return Vector3.New(min(lhs[1], rhs[1]), min(lhs[2], rhs[2]), min(lhs[3], rhs[3]))
end

function Vector3:Normalize()
	local v = Vector3.Clone(self)

	return v:SetNormalize()
end

function Vector3:SetNormalize()
	local num = Vector3.Magnitude(self)

	if num == 1 then
		return self
	elseif num > 1e-05 then
		self:Div(num)
	else
		self:Set(0, 0, 0)
	end

	return self
end

function Vector3:SqrMagnitude()
	return self[1] * self[1] + self[2] * self[2] + self[3] * self[3]
end

local dot = Vector3.Dot

function Vector3.Angle(from, to)
	return acos(clamp(dot(from:Normalize(), to:Normalize()), -1, 1)) * rad2Deg
end

function Vector3.SignedAngle(from, to, normal)
	local fromXTo = Vector3.Cross(from, to)
	local angle = Vector3.Angle(from, to)

	return sign(dot(fromXTo, normal)) * angle
end

function Vector3:ClampMagnitude(maxLength)
	if self:SqrMagnitude() > maxLength * maxLength then
		self:SetNormalize()
		self:Mul(maxLength)
	end

	return self
end

function Vector3.OrthoNormalVectorFast(n)
	local res = Vector3(0, 0, 0)

	if abs(n[3]) > k1OverSqrt2 then
		local a = n[2] * n[2] + n[3] * n[3]
		local k = 1 / sqrt(a)

		res[1] = 0
		res[2] = -n[3] * k
		res[3] = n[2] * k
	else
		local a = n[1] * n[1] + n[2] * n[2]
		local k = 1 / sqrt(a)

		res[1] = -n[2] * k
		res[2] = n[1] * k
		res[3] = 0
	end

	return res
end

function Vector3.OrthoNormalize(inU, inV, inW)
	local mag = Vector3.Magnitude(inU)

	if mag > smallNumber then
		inU = inU / mag
	else
		inU = Vector3(1, 0, 0)
	end

	local dot0 = Vector3.Dot(inU, inV)

	inV = inV - inU * dot0
	mag = Vector3.Magnitude(inV)

	if mag > smallNumber then
		inV = inV / mag
	else
		inV = Vector3.OrthoNormalVectorFast(inU)
	end

	local dot1 = Vector3.Dot(inV, inW)

	dot0 = Vector3.Dot(inU, inW)
	inW = inW - inU * dot0 + inV * dot1
	mag = Vector3.Magnitude(inW)

	if mag > 1e-05 then
		inW = inW / mag
	else
		inW = Vector3.Cross(inU, inV)
	end

	return inU, inV, inW
end

function Vector3.RotateTowards2(from, to, maxRadiansDelta, maxMagnitudeDelta)
	local v2 = to:Clone()
	local v1 = from:Clone()
	local len2 = to:Magnitude()
	local len1 = from:Magnitude()

	v2:Div(len2)
	v1:Div(len1)

	local dota = dot(v1, v2)
	local angle = acos(dota)
	local theta = min(angle, maxRadiansDelta)
	local len = 0

	if len1 < len2 then
		len = min(len2, len1 + maxMagnitudeDelta)
	elseif len1 == len2 then
		len = len1
	else
		len = max(len2, len1 - maxMagnitudeDelta)
	end

	v2:Sub(v1 * dota)
	v2:SetNormalize()
	v2:Mul(sin(theta))
	v1:Mul(cos(theta))
	v2:Add(v1)
	v2:SetNormalize()
	v2:Mul(len)

	return v2
end

function Vector3.RotateTowards1(from, to, maxRadiansDelta, maxMagnitudeDelta)
	local omega, sinom, scale0, scale1, len, theta
	local v2 = to:Clone()
	local v1 = from:Clone()
	local len2 = to:Magnitude()
	local len1 = from:Magnitude()

	v2:Div(len2)
	v1:Div(len1)

	local cosom = dot(v1, v2)

	if len1 < len2 then
		len = min(len2, len1 + maxMagnitudeDelta)
	elseif len1 == len2 then
		len = len1
	else
		len = max(len2, len1 - maxMagnitudeDelta)
	end

	if 1 - cosom > 1e-06 then
		omega = acos(cosom)
		theta = min(omega, maxRadiansDelta)
		sinom = sin(omega)
		scale0 = sin(omega - theta) / sinom
		scale1 = sin(theta) / sinom

		v1:Mul(scale0)
		v2:Mul(scale1)
		v2:Add(v1)
		v2:Mul(len)

		return v2
	else
		v1:Mul(len)

		return v1
	end
end

function Vector3.MoveTowards(current, target, maxDistanceDelta)
	local delta = target - current
	local sqrDelta = delta:SqrMagnitude()
	local sqrDistance = maxDistanceDelta * maxDistanceDelta

	if sqrDistance < sqrDelta then
		local magnitude = sqrt(sqrDelta)

		if magnitude > 1e-06 then
			delta:Mul(maxDistanceDelta / magnitude)
			delta:Add(current)

			return delta
		else
			return current:Clone()
		end
	end

	return target:Clone()
end

function Vector3.ClampedMove(lhs, rhs, clampedDelta)
	local delta = rhs - lhs

	if delta > 0 then
		return lhs + min(delta, clampedDelta)
	else
		return lhs - min(-delta, clampedDelta)
	end
end

local overSqrt2 = 0.7071067811865476

local function OrthoNormalVector(vec)
	local res = Vector3.New()

	if abs(vec[3]) > overSqrt2 then
		local a = vec[2] * vec[2] + vec[3] * vec[3]
		local k = 1 / sqrt(a)

		res[1] = 0
		res[2] = -vec[3] * k
		res[3] = vec[2] * k
	else
		local a = vec[1] * vec[1] + vec[2] * vec[2]
		local k = 1 / sqrt(a)

		res[1] = -vec[2] * k
		res[2] = vec[1] * k
		res[3] = 0
	end

	return res
end

function Vector3.RotateTowards(current, target, maxRadiansDelta, maxMagnitudeDelta)
	local len1 = current:Magnitude()
	local len2 = target:Magnitude()

	if len1 > 1e-06 and len2 > 1e-06 then
		local from = current / len1
		local to = target / len2
		local cosom = dot(from, to)

		if cosom > 0.999999 then
			return Vector3.MoveTowards(current, target, maxMagnitudeDelta)
		elseif cosom < -0.999999 then
			local axis = OrthoNormalVector(from)
			local q = Quaternion.AngleAxis(maxRadiansDelta * rad2Deg, axis)
			local rotated = q:MulVec3(from)
			local delta = Vector3.ClampedMove(len1, len2, maxMagnitudeDelta)

			rotated:Mul(delta)

			return rotated
		else
			local angle = acos(cosom)
			local axis = Vector3.Cross(from, to)

			axis:SetNormalize()

			local q = Quaternion.AngleAxis(min(maxRadiansDelta, angle) * rad2Deg, axis)
			local rotated = q:MulVec3(from)
			local delta = Vector3.ClampedMove(len1, len2, maxMagnitudeDelta)

			rotated:Mul(delta)

			return rotated
		end
	end

	return Vector3.MoveTowards(current, target, maxMagnitudeDelta)
end

function Vector3.SmoothDamp(current, target, currentVelocity, deltaTime, smoothTime)
	local maxSpeed = math.huge

	smoothTime = max(0.0001, smoothTime)

	local num = 2 / smoothTime
	local num2 = num * deltaTime
	local num3 = 1 / (1 + num2 + 0.48 * num2 * num2 + 0.235 * num2 * num2 * num2)
	local vector2 = target:Clone()
	local maxLength = maxSpeed * smoothTime
	local vector = current - target

	vector:ClampMagnitude(maxLength)

	target = current - vector

	local vec3 = (currentVelocity + vector * num) * deltaTime

	currentVelocity = (currentVelocity - vec3 * num) * num3

	local vector4 = target + (vector + vec3) * num3

	if Vector3.Dot(vector2 - current, vector4 - vector2) > 0 then
		vector4 = vector2

		currentVelocity:Set(0, 0, 0)
	end

	return vector4, currentVelocity
end

function Vector3.Scale(a, b)
	local v = a:Clone()

	return v:SetScale(b)
end

function Vector3:SetScale(b)
	self[1] = self[1] * b[1]
	self[2] = self[2] * b[2]
	self[3] = self[3] * b[3]

	return self
end

function Vector3.Cross(lhs, rhs)
	local x = lhs[2] * rhs[3] - lhs[3] * rhs[2]
	local y = lhs[3] * rhs[1] - lhs[1] * rhs[3]
	local z = lhs[1] * rhs[2] - lhs[2] * rhs[1]

	return Vector3.New(x, y, z)
end

function Vector3.CrossByCache(lhs, rhs, cacheVector3)
	cacheVector3[1] = lhs[2] * rhs[3] - lhs[3] * rhs[2]
	cacheVector3[2] = lhs[3] * rhs[1] - lhs[1] * rhs[3]
	cacheVector3[3] = lhs[1] * rhs[2] - lhs[2] * rhs[1]

	return cacheVector3
end

function Vector3.Intersect(a, b, c, d, intersectPos)
	if (a[1] > b[1] and a[1] or b[1]) < (c[1] < d[1] and c[1] or d[1]) or (c[1] > d[1] and c[1] or d[1]) < (a[1] < b[1] and a[1] or b[1]) or (a[3] > b[3] and a[3] or b[3]) < (c[3] < d[3] and c[3] or d[3]) or (c[3] > d[3] and c[3] or d[3]) < (a[3] < b[3] and a[3] or b[3]) then
		return false
	end

	local ab = b - a
	local cd = d - c
	local abXac = Vector3.Cross(ab, c - a)
	local abXad = Vector3.Cross(ab, d - a)
	local cdXca = Vector3.Cross(cd, a - c)
	local cdXcb = Vector3.Cross(cd, b - c)

	if Vector3.Dot(abXac, abXad) > 0 or Vector3.Dot(cdXca, cdXcb) > 0 then
		return false
	end

	if intersectPos then
		local abXcd = Vector3.Cross(ab, cd)
		local ratio = Vector3.Dot(cdXca, abXcd) / abXcd:SqrMagnitude()
		local p = a + ab * ratio

		intersectPos:Set(p[1], p[2], p[3])
	end

	return true
end

function Vector3:Equals(other)
	return self[1] == other[1] and self[2] == other[2] and self[3] == other[3]
end

function Vector3.Reflect(inDirection, inNormal)
	local num = -2 * dot(inNormal, inDirection)

	inNormal = inNormal * num

	inNormal:Add(inDirection)

	return inNormal
end

function Vector3.ToYaw(dir)
	return math.atan2(dir[1], dir[3])
end

function Vector3.Project(vector, onNormal)
	local num = onNormal:SqrMagnitude()

	if num < 1.175494e-38 then
		return Vector3.New(0, 0, 0)
	end

	local num2 = dot(vector, onNormal)
	local v3 = onNormal:Clone()

	v3:Mul(num2 / num)

	return v3
end

function Vector3.ProjectOnPlane(vector, planeNormal)
	local v3 = Vector3.Project(vector, planeNormal)

	v3:Mul(-1)
	v3:Add(vector)

	return v3
end

function Vector3.Slerp2(from, to, t)
	if t <= 0 then
		return from:Clone()
	elseif t >= 1 then
		return to:Clone()
	end

	local v2 = to:Clone()
	local v1 = from:Clone()
	local len2 = to:Magnitude()
	local len1 = from:Magnitude()

	v2:Div(len2)
	v1:Div(len1)

	local omega = dot(v1, v2)
	local len = (len2 - len1) * t + len1
	local theta = acos(omega) * t

	v2:Sub(v1 * omega)
	v2:SetNormalize()
	v2:Mul(sin(theta))
	v1:Mul(cos(theta))
	v2:Add(v1)
	v2:SetNormalize()
	v2:Mul(len)

	return v2
end

function Vector3.Slerp(from, to, t)
	local omega, sinom, scale0, scale1

	if t <= 0 then
		return from:Clone()
	elseif t >= 1 then
		return to:Clone()
	end

	local v2 = to:Clone()
	local v1 = from:Clone()
	local len2 = to:Magnitude()
	local len1 = from:Magnitude()

	v2:Div(len2)
	v1:Div(len1)

	local len = (len2 - len1) * t + len1
	local cosom = dot(v1, v2)

	if 1 - cosom > 1e-06 then
		omega = acos(cosom)
		sinom = sin(omega)
		scale0 = sin((1 - t) * omega) / sinom
		scale1 = sin(t * omega) / sinom
	else
		scale0 = 1 - t
		scale1 = t
	end

	v1:Mul(scale0)
	v2:Mul(scale1)
	v2:Add(v1)
	v2:Mul(len)

	return v2
end

function Vector3:Mul(q)
	if type(q) == "number" then
		self[1] = self[1] * q
		self[2] = self[2] * q
		self[3] = self[3] * q
	else
		self:MulQuat(q)
	end

	return self
end

function Vector3:Div(d)
	self[1] = self[1] / d
	self[2] = self[2] / d
	self[3] = self[3] / d

	return self
end

function Vector3:Add(vb)
	self[1] = self[1] + vb[1]
	self[2] = self[2] + vb[2]
	self[3] = self[3] + vb[3]

	return self
end

function Vector3.AddByCache(lhs, rhs, cacheVector3)
	cacheVector3[1] = lhs[1] + rhs[1]
	cacheVector3[2] = lhs[2] + rhs[2]
	cacheVector3[3] = lhs[3] + rhs[3]

	return cacheVector3
end

function Vector3:Sub(vb)
	self[1] = self[1] - vb[1]
	self[2] = self[2] - vb[2]
	self[3] = self[3] - vb[3]

	return self
end

function Vector3.SubByCache(lhs, rhs, cacheVector3)
	cacheVector3[1] = lhs[1] - rhs[1]
	cacheVector3[2] = lhs[2] - rhs[2]
	cacheVector3[3] = lhs[3] - rhs[3]

	return cacheVector3
end

function Vector3:MulVector3(other)
	self[1] = self[1] * other[1]
	self[2] = self[2] * other[2]
	self[3] = self[3] * other[3]

	return self
end

function Vector3.AngleAroundAxis(from, to, axis)
	from = from - Vector3.Project(from, axis)
	to = to - Vector3.Project(to, axis)

	local angle = Vector3.Angle(from, to)

	return angle * (Vector3.Dot(axis, Vector3.Cross(from, to)) < 0 and -1 or 1)
end

function Vector3:__tostring()
	local x = self[1] or 0
	local y = self[2] or 0
	local z = self[3] or 0

	return string.format("3:%.2f|%.2f|%.2f", x, y, z)
end

function Vector3.__div(va, d)
	return Vector3.New(va[1] / d, va[2] / d, va[3] / d)
end

function Vector3.__mul(va, d)
	if type(d) == "number" then
		return Vector3.New(va[1] * d, va[2] * d, va[3] * d)
	elseif type(va) == "number" then
		return Vector3.New(d[1] * va, d[2] * va, d[3] * va)
	else
		local vec = va:Clone()

		vec:MulQuat(d)

		return vec
	end
end

function Vector3.__add(va, vb)
	return Vector3.New(va[1] + vb[1], va[2] + vb[2], va[3] + vb[3])
end

function Vector3.__sub(va, vb)
	return Vector3.New(va[1] - vb[1], va[2] - vb[2], va[3] - vb[3])
end

function Vector3.__unm(va)
	return Vector3.New(-va[1], -va[2], -va[3])
end

function Vector3.__eq(a, b)
	return Vector3.SqrDistance(a, b) < 1e-10
end

function fields.up()
	return Vector3.New(0, 1, 0)
end

function fields.down()
	return Vector3.New(0, -1, 0)
end

function fields.right()
	return Vector3.New(1, 0, 0)
end

function fields.left()
	return Vector3.New(-1, 0, 0)
end

function fields.forward()
	return Vector3.New(0, 0, 1)
end

function fields.back()
	return Vector3.New(0, 0, -1)
end

function fields.zero()
	return Vector3.New(0, 0, 0)
end

function fields.one()
	return Vector3.New(1, 1, 1)
end

fields.magnitude = Vector3.Magnitude
fields.normalized = Vector3.Normalize
fields.sqrMagnitude = Vector3.SqrMagnitude
Vector3.constUp = Vector3.NewReadOnly(0, 1, 0)
Vector3.constDown = Vector3.NewReadOnly(0, -1, 0)
Vector3.constRight = Vector3.NewReadOnly(1, 0, 0)
Vector3.constLeft = Vector3.NewReadOnly(-1, 0, 0)
Vector3.constForward = Vector3.NewReadOnly(0, 0, 1)
Vector3.constBack = Vector3.NewReadOnly(0, 0, -1)
Vector3.constZero = Vector3.NewReadOnly(0, 0, 0)
Vector3.constOne = Vector3.NewReadOnly(1, 1, 1)

function Vector3:refreshReadOnly(x, y, z)
	self[4] = 0
	self[1] = x
	self[2] = y
	self[3] = z
	self[4] = 1
end

function Vector3.createTempLightVector(x, y, z)
	local vec = table.remove(lightCacheStack)

	if vec then
		vec[1] = x
		vec[2] = y
		vec[3] = z
		vec.x = x
		vec.y = y
		vec.z = z
	else
		vec = {
			x,
			y,
			z,
			x = x,
			y = y,
			z = z
		}
	end

	return vec
end

function Vector3.returnTempLightVector(vec)
	lightCacheStack[#lightCacheStack + 1] = vec
end

function Vector3.returnTempLightVectorArray(vecArray)
	for i = #vecArray, 1, -1 do
		local vec = vecArray[i]

		lightCacheStack[#lightCacheStack + 1] = vec
		vecArray[i] = nil
	end
end

function Vector3.__newindex(t, k, v)
	if k ~= sro and t[4] == 1 then
		error("Cannot modify a read only vector3.")
	elseif k == sx then
		t[1] = v
	elseif k == sy then
		t[2] = v
	elseif k == sz then
		t[3] = v
	elseif k == sro then
		t[4] = v
	elseif k == 4 then
		rawset(t, k, v)
	else
		error("Vector3 only can set x,y,z property" .. string.format("now: K:%s v:%s", tostring(k), tostring(v)))
	end
end

return Vector3
