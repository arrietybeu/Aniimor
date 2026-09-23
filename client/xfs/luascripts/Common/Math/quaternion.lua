-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Math\\quaternion.lua

local Vector3 = Vector3
local sin = math.sin
local cos = math.cos
local acos = math.acos
local asin = math.asin
local sqrt = math.sqrt
local min = math.min
local max = math.max
local sign = math.sign
local atan2 = math.atan2
local clamp = math.clamp
local abs = math.abs
local setmetatable = setmetatable
local getmetatable = getmetatable
local rawget = rawget
local rawset = rawset
local raw_next = rawget(_G, "raw_next") or next

math.deg2Rad = 2 * math.pi / 360
math.rad2Deg = 1 / math.deg2Rad

local rad2Deg = math.rad2Deg
local halfDegToRad = 0.5 * math.deg2Rad
local _forward = Vector3.constForward
local _up = Vector3.constUp
local _next = {
	2,
	3,
	1
}
local Quaternion = {
	class = "Quaternion",
	banInspect = true
}
local cacheDic = {}
local usingTempQuaMap = {}
local manualCacheStack = {}
local sx = "x"
local sy = "y"
local sz = "z"
local sw = "w"
local sEulerAngles = "eulerAngles"
local sro = "ro"

setmetatable(Quaternion, Quaternion)
Vector3.setClearQuaFunction(function(returnCache)
	for k, _ in pairs(usingTempQuaMap) do
		usingTempQuaMap[k] = nil

		if returnCache then
			k[5] = 1
			cacheDic[k] = true
		end
	end
end)

function Quaternion.__index(t, name)
	if name == sx then
		return t[1]
	elseif name == sy then
		return t[2]
	elseif name == sz then
		return t[3]
	elseif name == sw then
		return t[4]
	elseif name == sro then
		return t[5]
	end

	local var = rawget(Quaternion, name)

	if var then
		return var
	end

	if name == "identity" then
		return Quaternion.New(0, 0, 0, 1)
	elseif name == "eulerAngles" then
		return t:ToEulerAngles()
	end

	return nil
end

function Quaternion:__call(x, y, z, w)
	return Quaternion.New(x, y, z, w)
end

function Quaternion.getFromCache()
	local v = raw_next(cacheDic)

	if v then
		v[4] = 0

		v:Set(0, 0, 0)

		cacheDic[v] = nil

		return v
	end

	return Quaternion.New()
end

function Quaternion.returnToCache(qua)
	cacheDic[qua] = true
	qua[5] = 1
end

function Quaternion.GetFromPool(x, y, z, w)
	if #manualCacheStack > 0 then
		local qua = table.remove(manualCacheStack)

		qua:Set(x or 0, y or 0, z or 0, w or 1)

		return qua
	end

	local qua = {
		x or 0,
		y or 0,
		z or 0,
		w or 1
	}

	setmetatable(qua, Quaternion)

	return qua
end

function Quaternion.returnToPool(qua)
	if not qua then
		return
	end

	assert(qua[5] ~= 1, "readOnly Quaternion")
	table.insert(manualCacheStack, qua)
end

function Quaternion.removeTempQuaterion(qua)
	usingTempQuaMap[qua] = nil
end

function Quaternion.New(x, y, z, w)
	local quat

	if Vector3.createFromCacheRefCnt > 0 and raw_next(cacheDic) then
		quat = raw_next(cacheDic)
		cacheDic[quat] = nil
		quat[5] = 0

		quat:Set(x or 0, y or 0, z or 0, w or 1)

		usingTempQuaMap[quat] = true
	else
		quat = {
			x or 0,
			y or 0,
			z or 0,
			w or 1
		}

		setmetatable(quat, Quaternion)

		if Vector3.createFromCacheRefCnt > 0 then
			usingTempQuaMap[quat] = true
		end
	end

	return quat
end

function Quaternion.NewReadOnly(x, y, z, w)
	local quat = {
		x or 0,
		y or 0,
		z or 0,
		w or 1,
		1
	}

	setmetatable(quat, Quaternion)

	return quat
end

function Quaternion:Set(x, y, z, w)
	self[1] = x or 0
	self[2] = y or 0
	self[3] = z or 0
	self[4] = w or 0
end

function Quaternion:Clone()
	if self == nil then
		return nil
	end

	return Quaternion.New(self[1] or self[1], self[2] or self[2], self[3] or self[3], self[4] or self[4])
end

function Quaternion:CloneFromPool()
	if self == nil then
		return nil
	end

	return Quaternion.GetFromPool(self[1], self[2], self[3], self[4])
end

function Quaternion:Get()
	return self[1], self[2], self[3], self[4]
end

function Quaternion:getRawTable()
	return {
		self[1],
		self[2],
		self[3],
		self[4]
	}
end

function Quaternion:Copy(from)
	self[1] = from[1] or 0
	self[2] = from[2] or 0
	self[3] = from[3] or 0
	self[4] = from[4] or 0
end

function Quaternion.Dot(a, b)
	return a[1] * b[1] + a[2] * b[2] + a[3] * b[3] + a[4] * b[4]
end

function Quaternion.Angle(a, b)
	local dot = Quaternion.Dot(a, b)

	if dot < 0 then
		dot = -dot
	end

	return acos(min(dot, 1)) * 2 * 57.29578
end

function Quaternion.AngleAxis(angle, axis)
	local normAxis = axis:Normalize()

	angle = angle * halfDegToRad

	local s = sin(angle)
	local w = cos(angle)
	local x = normAxis[1] * s
	local y = normAxis[2] * s
	local z = normAxis[3] * s

	return Quaternion.New(x, y, z, w)
end

function Quaternion:MulUnitAngleAxisNoGC(angle, ax, ay, az)
	local halfAngle = angle * halfDegToRad
	local s = sin(halfAngle)
	local rw = cos(halfAngle)
	local rx = ax * s
	local ry = ay * s
	local rz = az * s
	local lx = self[1]
	local ly = self[2]
	local lz = self[3]
	local lw = self[4]

	self:Set(lw * rx + lx * rw + ly * rz - lz * ry, lw * ry + ly * rw + lz * rx - lx * rz, lw * rz + lz * rw + lx * ry - ly * rx, lw * rw - lx * rx - ly * ry - lz * rz)

	return self
end

function Quaternion.Equals(a, b)
	return a[1] == b[1] and a[2] == b[2] and a[3] == b[3] and a[4] == b[4]
end

function Quaternion.Euler(x, y, z)
	local quat = Quaternion.New()

	quat:SetEuler(x, y, z)

	return quat
end

function Quaternion:SetEuler(x, y, z)
	if y == nil and z == nil then
		y = x[2]
		z = x[3]
		x = x[1]
	end

	x = x * halfDegToRad
	y = y * halfDegToRad
	z = z * halfDegToRad

	local sinX = sin(x)
	local cosX = cos(x)
	local sinY = sin(y)
	local cosY = cos(y)
	local sinZ = sin(z)
	local cosZ = cos(z)

	self[4] = cosY * cosX * cosZ + sinY * sinX * sinZ
	self[1] = cosY * sinX * cosZ + sinY * cosX * sinZ
	self[2] = sinY * cosX * cosZ - cosY * sinX * sinZ
	self[3] = cosY * cosX * sinZ - sinY * sinX * cosZ

	return self
end

function Quaternion:Normalize()
	local quat = self:Clone()

	quat:SetNormalize()

	return quat
end

function Quaternion:SetNormalize()
	local n = self[1] * self[1] + self[2] * self[2] + self[3] * self[3] + self[4] * self[4]

	if n ~= 1 and n > 0 then
		n = 1 / sqrt(n)
		self[1] = self[1] * n
		self[2] = self[2] * n
		self[3] = self[3] * n
		self[4] = self[4] * n
	end
end

function Quaternion.FromToRotation(from, to)
	local quat = Quaternion.New()

	quat:SetFromToRotation(from, to)

	return quat
end

function Quaternion:SetFromToRotation1(from, to)
	local v0 = from:Normalize()
	local v1 = to:Normalize()
	local d = Vector3.Dot(v0, v1)

	if d > -0.999999 then
		local s = sqrt((1 + d) * 2)
		local invs = 1 / s
		local c = Vector3.Cross(v0, v1) * invs

		self:Set(c[1], c[2], c[3], s * 0.5)
	elseif d > 0.999999 then
		return Quaternion.New(0, 0, 0, 1)
	else
		local axis = Vector3.Cross(Vector3.constRight, v0)

		if axis:SqrMagnitude() < 1e-06 then
			axis = Vector3.Cross(Vector3.constForward, v0)
		end

		self:Set(axis[1], axis[2], axis[3], 0)

		return self
	end

	return self
end

local function MatrixToQuaternion(rot, quat)
	local trace = rot[1][1] + rot[2][2] + rot[3][3]

	if trace > 0 then
		local s = sqrt(trace + 1)

		quat[4] = 0.5 * s
		s = 0.5 / s
		quat[1] = (rot[3][2] - rot[2][3]) * s
		quat[2] = (rot[1][3] - rot[3][1]) * s
		quat[3] = (rot[2][1] - rot[1][2]) * s

		quat:SetNormalize()
	else
		local i = 1
		local q = {
			0,
			0,
			0
		}

		if rot[2][2] > rot[1][1] then
			i = 2
		end

		if rot[3][3] > rot[i][i] then
			i = 3
		end

		local j = _next[i]
		local k = _next[j]
		local t = rot[i][i] - rot[j][j] - rot[k][k] + 1
		local s = 0.5 / sqrt(t)

		q[i] = s * t

		local w = (rot[k][j] - rot[j][k]) * s

		q[j] = (rot[j][i] + rot[i][j]) * s
		q[k] = (rot[k][i] + rot[i][k]) * s

		quat:Set(q[1], q[2], q[3], w)
		quat:SetNormalize()
	end
end

function Quaternion:SetFromToRotation(from, to)
	from = from:Normalize()
	to = to:Normalize()

	local e = Vector3.Dot(from, to)

	if e > 0.999999 then
		self:Set(0, 0, 0, 1)
	elseif e < -0.999999 then
		local left = {
			0,
			from[3],
			from[2]
		}
		local mag = left[2] * left[2] + left[3] * left[3]

		if mag < 1e-06 then
			left[1] = -from[3]
			left[2] = 0
			left[3] = from[1]
			mag = left[1] * left[1] + left[3] * left[3]
		end

		local invlen = 1 / sqrt(mag)

		left[1] = left[1] * invlen
		left[2] = left[2] * invlen
		left[3] = left[3] * invlen

		local up = {
			0,
			0,
			0
		}

		up[1] = left[2] * from[3] - left[3] * from[2]
		up[2] = left[3] * from[1] - left[1] * from[3]
		up[3] = left[1] * from[2] - left[2] * from[1]

		local fxx = -from[1] * from[1]
		local fyy = -from[2] * from[2]
		local fzz = -from[3] * from[3]
		local fxy = -from[1] * from[2]
		local fxz = -from[1] * from[3]
		local fyz = -from[2] * from[3]
		local uxx = up[1] * up[1]
		local uyy = up[2] * up[2]
		local uzz = up[3] * up[3]
		local uxy = up[1] * up[2]
		local uxz = up[1] * up[3]
		local uyz = up[2] * up[3]
		local lxx = -left[1] * left[1]
		local lyy = -left[2] * left[2]
		local lzz = -left[3] * left[3]
		local lxy = -left[1] * left[2]
		local lxz = -left[1] * left[3]
		local lyz = -left[2] * left[3]
		local rot = {
			{
				fxx + uxx + lxx,
				fxy + uxy + lxy,
				fxz + uxz + lxz
			},
			{
				fxy + uxy + lxy,
				fyy + uyy + lyy,
				fyz + uyz + lyz
			},
			{
				fxz + uxz + lxz,
				fyz + uyz + lyz,
				fzz + uzz + lzz
			}
		}

		MatrixToQuaternion(rot, self)
	else
		local v = Vector3.Cross(from, to)
		local h = (1 - e) / Vector3.Dot(v, v)
		local hx = h * v[1]
		local hz = h * v[3]
		local hxy = hx * v[2]
		local hxz = hx * v[3]
		local hyz = hz * v[2]
		local rot = {
			{
				e + hx * v[1],
				hxy - v[3],
				hxz + v[2]
			},
			{
				hxy + v[3],
				e + h * v[2] * v[2],
				hyz - v[1]
			},
			{
				hxz - v[2],
				hyz + v[1],
				e + hz * v[3]
			}
		}

		MatrixToQuaternion(rot, self)
	end
end

function Quaternion:Inverse()
	local quat = Quaternion.New()

	quat[1] = -self[1]
	quat[2] = -self[2]
	quat[3] = -self[3]
	quat[4] = self[4]

	return quat
end

function Quaternion.GetQuaternionInverse(x, y, z, w)
	local quat = Quaternion.New()

	quat[1] = -x
	quat[2] = -y
	quat[3] = -z
	quat[4] = w

	return quat
end

function Quaternion.Lerp(q1, q2, t)
	t = clamp(t, 0, 1)

	local q = Quaternion.New()

	if Quaternion.Dot(q1, q2) < 0 then
		q[1] = q1[1] + t * (-q2[1] - q1[1])
		q[2] = q1[2] + t * (-q2[2] - q1[2])
		q[3] = q1[3] + t * (-q2[3] - q1[3])
		q[4] = q1[4] + t * (-q2[4] - q1[4])
	else
		q[1] = q1[1] + (q2[1] - q1[1]) * t
		q[2] = q1[2] + (q2[2] - q1[2]) * t
		q[3] = q1[3] + (q2[3] - q1[3]) * t
		q[4] = q1[4] + (q2[4] - q1[4]) * t
	end

	q:SetNormalize()

	return q
end

local calcheRot = {
	{
		0,
		0,
		0
	},
	{
		0,
		0,
		0
	},
	{
		0,
		0,
		0
	}
}
local cacheQ = {
	0,
	0,
	0
}

function Quaternion.LookRotation(forward, up)
	local mag = forward:Magnitude()

	if mag < 1e-06 then
		error("error input forward to Quaternion.LookRotation" .. tostring(forward))

		return nil
	end

	forward = forward / mag
	up = up or _up

	local right = Vector3.Cross(up, forward)

	right:SetNormalize()

	up = Vector3.Cross(forward, right)
	right = Vector3.Cross(up, forward)

	local t = right[1] + up[2] + forward[3]

	if t > 0 then
		local x, y, z, w

		t = t + 1

		local s = 0.5 / sqrt(t)

		w = s * t
		x = (up[3] - forward[2]) * s
		y = (forward[1] - right[3]) * s
		z = (right[2] - up[1]) * s

		local ret = Quaternion.New(x, y, z, w)

		ret:SetNormalize()

		return ret
	else
		local rot = calcheRot

		for i = 1, 3 do
			rot[i][1] = right[i]
			rot[i][2] = up[i]
			rot[i][3] = forward[i]
		end

		local q = cacheQ

		q[1] = 0
		q[2] = 0
		q[3] = 0

		local i = 1

		if up[2] > right[1] then
			i = 2
		end

		if forward[3] > rot[i][i] then
			i = 3
		end

		local j = _next[i]
		local k = _next[j]
		local t = rot[i][i] - rot[j][j] - rot[k][k] + 1
		local s = 0.5 / sqrt(t)

		q[i] = s * t

		local w = (rot[k][j] - rot[j][k]) * s

		q[j] = (rot[j][i] + rot[i][j]) * s
		q[k] = (rot[k][i] + rot[i][k]) * s

		local ret = Quaternion.New(q[1], q[2], q[3], w)

		ret:SetNormalize()

		return ret
	end
end

function Quaternion.LookRotationXYZWNoGC(forward, up)
	local fx = forward[1]
	local fy = forward[2]
	local fz = forward[3]
	local forwardSqr = fx * fx + fy * fy + fz * fz

	if forwardSqr < 1e-12 then
		return nil
	end

	local invForward = 1 / sqrt(forwardSqr)

	fx = fx * invForward
	fy = fy * invForward
	fz = fz * invForward

	local ux, uy, uz

	if up then
		ux = up[1]
		uy = up[2]
		uz = up[3]
	else
		ux = 0
		uy = 1
		uz = 0
	end

	local rx = uy * fz - uz * fy
	local ry = uz * fx - ux * fz
	local rz = ux * fy - uy * fx
	local rightSqr = rx * rx + ry * ry + rz * rz

	if rightSqr <= 1e-10 then
		local absFx = abs(fx)
		local absFy = abs(fy)
		local absFz = abs(fz)

		if absFx <= absFy and absFx <= absFz then
			ux, uy, uz = 1, 0, 0
		elseif absFy <= absFz then
			ux, uy, uz = 0, 1, 0
		else
			ux, uy, uz = 0, 0, 1
		end

		rx = uy * fz - uz * fy
		ry = uz * fx - ux * fz
		rz = ux * fy - uy * fx
		rightSqr = rx * rx + ry * ry + rz * rz
	end

	local invRight = 1 / sqrt(rightSqr)

	rx = rx * invRight
	ry = ry * invRight
	rz = rz * invRight
	ux = fy * rz - fz * ry
	uy = fz * rx - fx * rz
	uz = fx * ry - fy * rx
	rx = uy * fz - uz * fy
	ry = uz * fx - ux * fz
	rz = ux * fy - uy * fx

	local qx, qy, qz, qw
	local trace = rx + uy + fz

	if trace > 0 then
		local s = sqrt(trace + 1) * 2

		qw = 0.25 * s
		qx = (uz - fy) / s
		qy = (fx - rz) / s
		qz = (ry - ux) / s
	elseif uy < rx and fz < rx then
		local s = sqrt(1 + rx - uy - fz) * 2

		qw = (uz - fy) / s
		qx = 0.25 * s
		qy = (ux + ry) / s
		qz = (fx + rz) / s
	elseif fz < uy then
		local s = sqrt(1 + uy - rx - fz) * 2

		qw = (fx - rz) / s
		qx = (ux + ry) / s
		qy = 0.25 * s
		qz = (uz + fy) / s
	else
		local s = sqrt(1 + fz - rx - uy) * 2

		qw = (ry - ux) / s
		qx = (fx + rz) / s
		qy = (fy + uz) / s
		qz = 0.25 * s
	end

	local quatSqr = qx * qx + qy * qy + qz * qz + qw * qw
	local invQuat = 1 / sqrt(quatSqr)

	return qx * invQuat, qy * invQuat, qz * invQuat, qw * invQuat
end

function Quaternion.LookRotationHoriXYZWNoGC(forwardX, forwardZ)
	local sqrMagnitude = forwardX * forwardX + forwardZ * forwardZ

	if sqrMagnitude < 1e-12 then
		return nil
	end

	local invMagnitude = 1 / sqrt(sqrMagnitude)
	local nx = forwardX * invMagnitude
	local nz = forwardZ * invMagnitude
	local y, w

	if nz >= 0 then
		w = sqrt((1 + nz) * 0.5)
		y = nx / (2 * w)
	else
		y = (nx < 0 and -1 or 1) * sqrt((1 - nz) * 0.5)
		w = nx / (2 * y)
	end

	return 0, y, 0, w
end

function Quaternion:SetIdentity()
	self[1] = 0
	self[2] = 0
	self[3] = 0
	self[4] = 1
end

local function UnclampedSlerp(from, to, t)
	local cosAngle = Quaternion.Dot(from, to)

	if cosAngle < 0 then
		cosAngle = -cosAngle
		to = Quaternion.New(-to[1], -to[2], -to[3], -to[4])
	end

	local t1, t2

	if cosAngle < 0.95 then
		local angle = acos(cosAngle)
		local sinAngle = sin(angle)
		local invSinAngle = 1 / sinAngle

		t1 = sin((1 - t) * angle) * invSinAngle
		t2 = sin(t * angle) * invSinAngle

		local quat = Quaternion.New(from[1] * t1 + to[1] * t2, from[2] * t1 + to[2] * t2, from[3] * t1 + to[3] * t2, from[4] * t1 + to[4] * t2)

		return quat
	else
		return Quaternion.Lerp(from, to, t)
	end
end

function Quaternion.Slerp(from, to, t)
	t = clamp(t, 0, 1)

	return UnclampedSlerp(from, to, t)
end

function Quaternion.RotateTowards(from, to, maxDegreesDelta)
	local angle = Quaternion.Angle(from, to)

	if angle == 0 then
		return to
	end

	local t = min(1, maxDegreesDelta / angle)

	return UnclampedSlerp(from, to, t)
end

local function Approximately(f0, f1)
	return abs(f0 - f1) < 1e-06
end

function Quaternion.Convert(t)
	if t then
		setmetatable(t, Quaternion)
	end

	return t
end

function Quaternion:ToAngleAxis()
	local angle = 2 * acos(self[4])

	if Approximately(angle, 0) then
		return angle * 57.29578, Vector3.New(1, 0, 0)
	end

	local div = 1 / sqrt(1 - sqrt(self[4]))

	return angle * 57.29578, Vector3.New(self[1] * div, self[2] * div, self[3] * div)
end

local pi = math.pi
local half_pi = pi * 0.5
local two_pi = 2 * pi
local negativeFlip = -0.0001
local positiveFlip = two_pi - 0.0001

local function SanitizeEuler(euler)
	if euler[1] < negativeFlip then
		euler[1] = euler[1] + two_pi
	elseif euler[1] > positiveFlip then
		euler[1] = euler[1] - two_pi
	end

	if euler[2] < negativeFlip then
		euler[2] = euler[2] + two_pi
	elseif euler[2] > positiveFlip then
		euler[2] = euler[2] - two_pi
	end

	if euler[3] < negativeFlip then
		euler[3] = euler[3] + two_pi
	elseif euler[3] > positiveFlip then
		euler[3] = euler[3] + two_pi
	end
end

function Quaternion:ToEulerAngles()
	local x = self[1]
	local y = self[2]
	local z = self[3]
	local w = self[4]
	local check = 2 * (y * z - w * x)

	if check < 0.999 then
		if check > -0.999 then
			local v = Vector3.New(-asin(check), atan2(2 * (x * z + w * y), 1 - 2 * (x * x + y * y)), atan2(2 * (x * y + w * z), 1 - 2 * (x * x + z * z)))

			SanitizeEuler(v)
			v:Mul(rad2Deg)

			return v
		else
			local v = Vector3.New(half_pi, atan2(2 * (x * y - w * z), 1 - 2 * (y * y + z * z)), 0)

			SanitizeEuler(v)
			v:Mul(rad2Deg)

			return v
		end
	else
		local v = Vector3.New(-half_pi, atan2(-2 * (x * y - w * z), 1 - 2 * (y * y + z * z)), 0)

		SanitizeEuler(v)
		v:Mul(rad2Deg)

		return v
	end
end

local _eulerAnglesYCacheV = Vector3.New(0, 0, 0)

function Quaternion:TestGetEulerAnglesY()
	local first = self:GetEulerAnglesY()
	local second = self:ToEulerAngles().y

	if first ~= second then
		error(string.format("function Quaternion:GetEulerAnglesY() old:%s new:%s", first, second))
	end

	return first
end

function Quaternion:GetEulerAnglesY()
	local x = self[1]
	local y = self[2]
	local z = self[3]
	local w = self[4]
	local check = 2 * (y * z - w * x)

	if check < 0.999 then
		if check > -0.999 then
			_eulerAnglesYCacheV:Set(-asin(check), atan2(2 * (x * z + w * y), 1 - 2 * (x * x + y * y)), atan2(2 * (x * y + w * z), 1 - 2 * (x * x + z * z)))
			SanitizeEuler(_eulerAnglesYCacheV)
			_eulerAnglesYCacheV:Mul(rad2Deg)

			return _eulerAnglesYCacheV.y
		else
			_eulerAnglesYCacheV:Set(half_pi, atan2(2 * (x * y - w * z), 1 - 2 * (y * y + z * z)), 0)
			SanitizeEuler(_eulerAnglesYCacheV)
			_eulerAnglesYCacheV:Mul(rad2Deg)

			return _eulerAnglesYCacheV.y
		end
	else
		_eulerAnglesYCacheV:Set(-half_pi, atan2(-2 * (x * y - w * z), 1 - 2 * (y * y + z * z)), 0)
		SanitizeEuler(_eulerAnglesYCacheV)
		_eulerAnglesYCacheV:Mul(rad2Deg)

		return _eulerAnglesYCacheV.y
	end
end

function Quaternion:Forward()
	return self:MulVec3(_forward)
end

function Quaternion:MulVec3(point)
	local vec = Vector3.New()
	local x, y, z = Quaternion.MulVec3NoGC(self, point)

	vec:Set(x, y, z)

	return vec
end

function Quaternion:MulVec3NoGC(point)
	local x, y, z
	local num = self[1] * 2
	local num2 = self[2] * 2
	local num3 = self[3] * 2
	local num4 = self[1] * num
	local num5 = self[2] * num2
	local num6 = self[3] * num3
	local num7 = self[1] * num2
	local num8 = self[1] * num3
	local num9 = self[2] * num3
	local num10 = self[4] * num
	local num11 = self[4] * num2
	local num12 = self[4] * num3

	x = (1 - (num5 + num6)) * point[1] + (num7 - num12) * point[2] + (num8 + num11) * point[3]
	y = (num7 + num12) * point[1] + (1 - (num4 + num6)) * point[2] + (num9 - num10) * point[3]
	z = (num8 - num11) * point[1] + (num9 + num10) * point[2] + (1 - (num4 + num5)) * point[3]

	return x, y, z
end

function Quaternion:MulXYZNoGC(x, y, z)
	local tx, ty, tz
	local num = self[1] * 2
	local num2 = self[2] * 2
	local num3 = self[3] * 2
	local num4 = self[1] * num
	local num5 = self[2] * num2
	local num6 = self[3] * num3
	local num7 = self[1] * num2
	local num8 = self[1] * num3
	local num9 = self[2] * num3
	local num10 = self[4] * num
	local num11 = self[4] * num2
	local num12 = self[4] * num3

	tx = (1 - (num5 + num6)) * x + (num7 - num12) * y + (num8 + num11) * z
	ty = (num7 + num12) * x + (1 - (num4 + num6)) * y + (num9 - num10) * z
	tz = (num8 - num11) * x + (num9 + num10) * y + (1 - (num4 + num5)) * z

	return tx, ty, tz
end

function Quaternion.MulXYZByXYZW(qx, qy, qz, qw, x, y, z)
	local tx, ty, tz
	local num = qx * 2
	local num2 = qy * 2
	local num3 = qz * 2
	local num4 = qx * num
	local num5 = qy * num2
	local num6 = qz * num3
	local num7 = qx * num2
	local num8 = qx * num3
	local num9 = qy * num3
	local num10 = qw * num
	local num11 = qw * num2
	local num12 = qw * num3

	tx = (1 - (num5 + num6)) * x + (num7 - num12) * y + (num8 + num11) * z
	ty = (num7 + num12) * x + (1 - (num4 + num6)) * y + (num9 - num10) * z
	tz = (num8 - num11) * x + (num9 + num10) * y + (1 - (num4 + num5)) * z

	return tx, ty, tz
end

function Quaternion:ToYaw()
	local x, y, z = self:MulVec3NoGC(_forward)

	return math.atan2(x, z)
end

function Quaternion.GetYawByXYZW(x, y, z, w)
	local num = x * 2
	local num2 = y * 2
	local num3 = z * 2
	local num4 = x * num
	local num5 = y * num2
	local num8 = x * num3
	local num11 = w * num2

	return math.atan2(num8 + num11, 1 - (num4 + num5))
end

function Quaternion.__mul(lhs, rhs)
	if Quaternion == getmetatable(rhs) then
		return Quaternion.New(lhs[4] * rhs[1] + lhs[1] * rhs[4] + lhs[2] * rhs[3] - lhs[3] * rhs[2], lhs[4] * rhs[2] + lhs[2] * rhs[4] + lhs[3] * rhs[1] - lhs[1] * rhs[3], lhs[4] * rhs[3] + lhs[3] * rhs[4] + lhs[1] * rhs[2] - lhs[2] * rhs[1], lhs[4] * rhs[4] - lhs[1] * rhs[1] - lhs[2] * rhs[2] - lhs[3] * rhs[3])
	elseif rhs.className == "Vector3" then
		return lhs:MulVec3(rhs)
	else
		error("rhs error" .. tostring(rhs))
	end
end

function Quaternion.__unm(q)
	return Quaternion.New(-q[1], -q[2], -q[3], -q[4])
end

function Quaternion.__eq(lhs, rhs)
	return Quaternion.Dot(lhs, rhs) > 0.999999
end

function Quaternion:__tostring()
	local x = self[1] or "nil"
	local y = self[2] or "nil"
	local z = self[3] or "nil"
	local w = self[4] or "nil"
	local eulerStr = ""

	if self[1] and self[2] and self[3] and self[4] then
		local eulerAngles = self:ToEulerAngles()

		eulerStr = string.format(" EulerAngles [%f, %f, %f]", eulerAngles[1], eulerAngles[2], eulerAngles[3])
	end

	local ret = string.format("Quaternion [%s, %s, %s, %s]", x, y, z, w)

	return ret .. eulerStr
end

function Quaternion:refreshReadOnly(x, y, z, w)
	self[5] = 0
	self[1] = x
	self[2] = y
	self[3] = z
	self[4] = w
	self[5] = 1
end

function Quaternion.__newindex(t, k, v)
	if k ~= sro and t.ro == 1 then
		error("Cannot modify a readonly Quaternion.")
	elseif k == sx then
		t[1] = v
	elseif k == sy then
		t[2] = v
	elseif k == sz then
		t[3] = v
	elseif k == sw then
		t[4] = v
	elseif k == sro then
		t[5] = v
	elseif k == 5 then
		rawset(t, 5, v)
	elseif k == sEulerAngles then
		t:SetEuler(v)
	else
		error("Quaternion only can set x,y,z,w,eulerAngles property")
	end
end

return Quaternion
