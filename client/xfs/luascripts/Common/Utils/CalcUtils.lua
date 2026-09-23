-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\Utils\\CalcUtils.lua

local lume = require("Core.Common.lume")
local AiConst = require("Common.Const.AiConst")
local Utils = require("Common.Utils.Utils")
local math_sin = math.sin
local math_cos = math.cos
local math_rad = math.rad
local math_tan = math.tan
local math_pi = math.pi
local math_aTan = math.atan
local math_floor = math.floor
local math_abs = math.abs
local math_eps = math.epsilon
local math_max = math.max
local math_min = math.min
local math_deg = math.deg
local math_maxFloat = math.maxFloat
local math_huge = math.huge
local CalcUtils = {}
local sin_cache

if jit then
	local table_new = require("table.new")

	sin_cache = table_new(0, 360)
else
	sin_cache = {}
end

function CalcUtils.quickSin(degree)
	return math_sin(math_rad(degree))
end

local cos_cache

if jit then
	local table_new = require("table.new")

	cos_cache = table_new(0, 360)
else
	cos_cache = {}
end

function CalcUtils.quickCos(degree)
	return math_cos(math_rad(degree))
end

local tan_cache

if jit then
	local table_new = require("table.new")

	tan_cache = table_new(0, 360)
else
	tan_cache = {}
end

function CalcUtils.quickTan(degree)
	return math_tan(math_rad(degree))
end

function CalcUtils.calcLine(x, x1, y1, x2, y2)
	if x2 == x1 then
		return y2
	end

	return (y2 - y1) * (x - x1) / (x2 - x1) + y1
end

function CalcUtils.calcLineY(y, x1, y1, x2, y2)
	if y2 == y1 then
		return x2
	end

	return (y - y1) * (x2 - x1) / (y2 - y1) + x1
end

function CalcUtils.calcConic(x, x1, y1, x2, y2)
	if x1 < 0 or x2 < 0 then
		return 0
	end

	if x2 == x1 then
		return y2
	end

	return (y2 - y1) * (x * x - x1 * x1) / (x2 * x2 - x1 * x1) + y1
end

function CalcUtils.calcExtrac(x, x1, y1, x2, y2)
	if x1 < 0 or x2 < 0 then
		return 0
	end

	if x2 == x1 then
		return y2
	end

	return (y2 - y1) * (x^0.5 - x1^0.5) / (x2^0.5 - x1^0.5) + y1
end

local calcFuncs = {
	Line = CalcUtils.calcLine,
	LineY = CalcUtils.calcLineY,
	Conic = CalcUtils.calcConic,
	Extrac = CalcUtils.calcExtrac
}

function CalcUtils.getYawByDir(x, z)
	if x == 0 then
		if z > 0 then
			return 0
		else
			return math_pi
		end
	end

	local yaw = math_aTan(x / z)

	if yaw > 0 then
		if x < 0 then
			yaw = yaw - math_pi
		end
	elseif x > 0 then
		yaw = yaw + math_pi
	end

	if yaw < 0 then
		yaw = yaw + 2 * math_pi
	end

	return yaw
end

function CalcUtils.getYawByPos(src, tgt)
	if src[1] == nil then
		return CalcUtils.getYawByDir(tgt[1] - src[1], tgt[3] - tgt[3])
	end

	return CalcUtils.getYawByDir(tgt[1] - src[1], tgt[3] - src[3])
end

function CalcUtils.calcLink(x, points, isFloat)
	if not points then
		return 0
	end

	if type(points) == "number" then
		return points
	end

	local point_size = 0

	for k, _ in ipairs(points) do
		point_size = point_size + 1
	end

	assert(point_size >= 2)

	local point2 = point_size
	local funcName = points[point_size][3]

	for i = 1, point_size do
		if x < points[i][1] then
			point2 = i == 1 and 2 or i
			funcName = points[i][3]

			break
		end
	end

	local tb1 = points[point2 - 1]
	local tb2 = points[point2]

	funcName = funcName or "Line"

	local fnFunc = calcFuncs[funcName]

	assert(fnFunc)

	local ret = fnFunc(x, tb1[1], tb1[2], tb2[1], tb2[2])

	if not isFloat then
		return math_floor(ret)
	end

	return ret
end

function CalcUtils.calcLinkY(y, points, isFloat)
	if not points then
		return 0
	end

	if type(points) == "number" then
		return points
	end

	local point_size = #points

	assert(point_size >= 2)

	local point2 = point_size
	local funcName = points[point_size][3]

	for i = 1, point_size do
		if y < points[i][2] then
			point2 = i == 1 and 2 or i
			funcName = points[i][3]

			break
		end
	end

	local tb1 = points[point2 - 1]
	local tb2 = points[point2]

	funcName = funcName or "LineY"

	local fnFunc = calcFuncs[funcName]

	assert(fnFunc)

	local ret = fnFunc(y, tb1[1], tb1[2], tb2[1], tb2[2])

	if not isFloat then
		return math_floor(ret)
	end

	return ret
end

function CalcUtils.isPointInCirualSector(pointX, pointY, dirX, dirY, dotsX, dotsY, radius, theta)
	radius = radius < 0 and 0 or radius

	local pdX = pointX - dotsX
	local pdY = pointY - dotsY
	local squaredLength = pdX * pdX + pdY * pdY

	if squaredLength > radius * radius then
		return false
	end

	if theta <= math_eps then
		return true
	end

	local pointDirDotDir = pdX * dirX + pdY * dirY
	local cosTheta = math_cos(math_rad(theta))

	if pointDirDotDir >= 0 and cosTheta >= 0 then
		return pointDirDotDir * pointDirDotDir >= squaredLength * cosTheta * cosTheta
	elseif pointDirDotDir < 0 and cosTheta < 0 then
		return pointDirDotDir * pointDirDotDir <= squaredLength * cosTheta * cosTheta
	else
		return pointDirDotDir >= 0
	end
end

function CalcUtils.isPointInAnnularSector(pointX, pointY, dirX, dirY, dotsX, dotsY, radiusStart, radiusEnd, thetaStart, thetaEnd)
	local theta = math_abs(thetaStart - thetaEnd) / 2

	if thetaStart + thetaEnd ~= 0 then
		dirX, dirY = CalcUtils.rotationVector(dirX, dirY, -(thetaStart + thetaEnd) / 2)
	end

	if radiusStart <= 0 then
		return CalcUtils.isPointInCirualSector(pointX, pointY, dirX, dirY, dotsX, dotsY, radiusEnd, theta) == true
	end

	return CalcUtils.isPointInCirualSector(pointX, pointY, dirX, dirY, dotsX, dotsY, radiusEnd, theta) == true and CalcUtils.isPointInCirualSector(pointX, pointY, dirX, dirY, dotsX, dotsY, radiusStart, theta) == false
end

function CalcUtils.rotationVector(x, y, theta)
	local sinTheta = math_sin(math_rad(theta))
	local cosTheta = math_cos(math_rad(theta))
	local rotationX = x * cosTheta - y * sinTheta
	local rotationY = x * sinTheta + y * cosTheta

	return rotationX, rotationY
end

function CalcUtils.clockwiseRotateDegree(x, y, z, degree)
	local cosVal = CalcUtils.quickCos(degree)
	local sinVal = CalcUtils.quickSin(degree)

	return x * cosVal + z * sinVal, y, z * cosVal - x * sinVal
end

function CalcUtils.clockwiseRotateRad(x, y, z, rad)
	local cosVal = math_cos(rad)
	local sinVal = math_sin(rad)

	return x * cosVal + z * sinVal, y, z * cosVal - x * sinVal
end

function CalcUtils.getPosOnRayByYawRad(startPoint, yawRad, distance, refVector3)
	local x, y, z = CalcUtils.clockwiseRotateRad(0, 0, 1, yawRad)

	refVector3:Set(startPoint[1] + x * distance, startPoint[2] + y * distance, startPoint[3] + z * distance)

	return refVector3
end

function CalcUtils.getPosOnRayByYawDegree(startPoint, yawDegree, distance, refVector3)
	local x, y, z = CalcUtils.clockwiseRotateDegree(0, 0, 1, yawDegree)

	refVector3:Set(startPoint[1] + x * distance, startPoint[2] + y * distance, startPoint[3] + z * distance)

	return refVector3
end

function CalcUtils.getPosByLinkAngle(startPos, endPos, angleDegree, dist, refVector3)
	local dirDegree = math_deg(CalcUtils.getYawByPos(startPos, endPos))

	return CalcUtils.getPosOnRayByYawDegree(startPos, dirDegree + angleDegree, dist, refVector3)
end

function CalcUtils.getAngleByDir(dir1, dir2)
	local angle = lume.getVector3Angle(dir1, dir2)

	if lume.getVector3Cross(dir1, dir2)[2] < 0 then
		angle = -angle
	end

	return angle
end

function CalcUtils.findNearestPointIndex(myPos, pointList, propertyName, fromIndex)
	local findIndex = fromIndex or 1
	local closestDistance = math_maxFloat
	local allCount = #pointList
	local index = findIndex

	while index <= allCount do
		local tmpPos = pointList[index][propertyName]
		local currentDistance = Vector3.SqrDistance(tmpPos, myPos)

		if currentDistance < closestDistance then
			closestDistance = currentDistance
			findIndex = index
		end

		index = index + 1
	end

	return findIndex
end

function CalcUtils.isZeroDir(dir)
	local epsilon = 0.01

	if epsilon < math_abs(dir[1]) or epsilon < math_abs(dir[2]) or epsilon < math_abs(dir[3]) then
		return false
	end

	return true
end

function CalcUtils.getDirByEntity(entStart, entEnd)
	local posStart = entStart:getPosition()
	local posEnd = entEnd:getPosition()

	return Vector3.New(posEnd[1] - posStart[1], 0, posEnd[3] - posStart[3]):SetNormalize()
end

function CalcUtils.getAngleByEntityPos(entStart, entEnd)
	local posStart = entStart:getPosition()
	local posEnd = entEnd:getPosition()

	Vector3.enableCreateFromCache()

	local startForward = entStart:getRotation():Forward()
	local angle = math_deg(CalcUtils.getAngleByDir(startForward, posEnd - posStart))

	Vector3.disableCreateFromCache()

	return angle
end

function CalcUtils.checkInRange3D(myPos, tgtPos, minDistance, maxDistance)
	minDistance = minDistance or AiConst.AUTO_PATH_CLOSE_LEN

	local distance = Utils.squareDist(myPos, tgtPos)

	if not maxDistance then
		return distance >= minDistance * minDistance
	end

	if minDistance <= math_eps then
		return distance <= maxDistance * maxDistance
	end

	return distance <= maxDistance * maxDistance and distance >= minDistance * minDistance
end

function CalcUtils.checkInRange2D(myPos, tgtPos, minDistance, maxDistance)
	minDistance = minDistance or AiConst.AUTO_PATH_CLOSE_LEN
	minDistance = minDistance < 0 and AiConst.AUTO_PATH_CLOSE_LEN or minDistance

	local distance = Utils.squareDistNoYAxis(myPos, tgtPos)

	if not maxDistance then
		return distance >= minDistance * minDistance
	end

	return distance <= maxDistance * maxDistance and distance >= minDistance * minDistance
end

function CalcUtils.getBodySizeBias(entity1, entity2, entity1Need, entity2Need, entity1PartId, entity2PartId)
	local entity1BodySize = CalcUtils.getBodySize(entity1, entity1PartId)
	local entity2BodySize = CalcUtils.getBodySize(entity2, entity2PartId)
	local bodySizeBias1 = entity1Need ~= false and entity1BodySize or 0
	local bodySizeBias2 = entity2Need ~= false and entity2BodySize or 0

	return bodySizeBias1 + bodySizeBias2
end

function CalcUtils.getBodySize(entity, entityPartId)
	if entity == nil then
		return 0
	end

	if Utils.isEnvObj(entity) and entity.getBodySize then
		return entity:getBodySize(entityPartId)
	else
		return entity.bodySize or 0
	end
end

function CalcUtils.checkNumberInRange(number, targetNumber, range)
	return number >= targetNumber - range and number <= targetNumber + range
end

function CalcUtils.checkLine2DIntersection(lineAStartPos, lineAEndPos, lineBStartPos, lineBEndPos)
	if math_min(lineAStartPos[1], lineAEndPos[1]) <= math_max(lineBStartPos[1], lineBEndPos[1]) and math_min(lineBStartPos[1], lineBEndPos[1]) <= math_max(lineAStartPos[1], lineAEndPos[1]) and math_min(lineAStartPos[3], lineAEndPos[3]) <= math_max(lineBStartPos[3], lineBEndPos[3]) and math_min(lineBStartPos[3], lineBEndPos[3]) <= math_max(lineAStartPos[3], lineAEndPos[3]) then
		Vector3.enableCreateFromCache()

		local tAStart2BStart = Vector3.New(lineBStartPos[1] - lineAStartPos[1], 0, lineBStartPos[3] - lineAStartPos[3])
		local tAStart2AEnd = Vector3.New(lineAEndPos[1] - lineAStartPos[1], 0, lineAEndPos[3] - lineAStartPos[3])
		local tAStart2BEnd = Vector3.New(lineBEndPos[1] - lineAStartPos[1], 0, lineBEndPos[3] - lineAStartPos[3])
		local ret = false

		if Vector3.Dot(Vector3.Cross(tAStart2BStart, tAStart2AEnd), Vector3.Cross(tAStart2BEnd, tAStart2AEnd)) <= math_eps then
			ret = true
		end

		Vector3.disableCreateFromCache()

		return ret
	end

	return false
end

function CalcUtils.getValidPositiveValue(value, defaultValue)
	if value == nil or value == false or value < math_eps then
		return defaultValue
	end

	return value
end

function CalcUtils.getHoriDirection(from, to)
	local dir = to - from

	dir[2] = 0

	dir:SetNormalize()

	if math_abs(dir[1]) < math_eps and math_abs(dir[3]) < math_eps then
		dir[1] = 0
		dir[3] = 1
	end

	return dir
end

function CalcUtils.getMirrorPoint(pos, mirrorPos, mirrorDir)
	Vector3.enableCreateFromCache()

	local line = pos - mirrorPos
	local projectLen = Vector3.Dot(line, mirrorDir)
	local line2 = mirrorDir * (projectLen * 2) - line
	local ret = mirrorPos + line2
	local x, y, z = ret[1], ret[2], ret[3]

	Vector3.disableCreateFromCache()

	return x, y, z
end

function CalcUtils.pointToLineDistanceSqr(point, segmentStart, segmentEnd)
	local segVecX = segmentEnd.x - segmentStart.x
	local segVecZ = segmentEnd.z - segmentStart.z
	local pointVecX = point.x - segmentStart.x
	local pointVecZ = point.z - segmentStart.z
	local segLengthSquared = segVecX * segVecX + segVecZ * segVecZ

	if segLengthSquared == 0 then
		return pointVecX * pointVecX + pointVecZ * pointVecZ
	end

	local t = (pointVecX * segVecX + pointVecZ * segVecZ) / segLengthSquared

	t = math_max(0, math_min(1, t))

	local dx = point.x - (segmentStart.x + t * segVecX)
	local dz = point.z - (segmentStart.z + t * segVecZ)

	return dx * dx + dz * dz
end

function CalcUtils.getClosestPointOnPolygon(point, points)
	local closestPoint
	local closestIndex = -1
	local minDistanceSqr = math_huge
	local vertexCount = #points / 2

	Vector3.enableCreateFromCache()

	local fromPos = Vector3.New()
	local toPos = Vector3.New()

	for i = 1, vertexCount do
		local fromIndex = i * 2 - 1

		fromPos:Set(points[fromIndex], 0, points[fromIndex + 1])

		local toIndex = (i % vertexCount + 1) * 2 - 1

		toPos:Set(points[toIndex], 0, points[toIndex + 1])

		local distanceSqr = CalcUtils.pointToLineDistanceSqr(point, fromPos, toPos)

		if distanceSqr < minDistanceSqr then
			minDistanceSqr = distanceSqr
			closestIndex = i
		end
	end

	if closestIndex ~= -1 then
		local fromIndex = closestIndex * 2 - 1

		fromPos:Set(points[fromIndex], 0, points[fromIndex + 1])

		local toIndex = (closestIndex % vertexCount + 1) * 2 - 1

		toPos:Set(points[toIndex], 0, points[toIndex + 1])

		local segVecX = toPos.x - fromPos.x
		local segVecZ = toPos.z - fromPos.z
		local pointVecX = point.x - fromPos.x
		local pointVecZ = point.z - fromPos.z
		local segLengthSquared = segVecX * segVecX + segVecZ * segVecZ
		local t = (pointVecX * segVecX + pointVecZ * segVecZ) / segLengthSquared

		t = math_max(0, math_min(1, t))

		local closestX = fromPos.x + t * segVecX
		local closestZ = fromPos.z + t * segVecZ

		closestPoint = Vector3.New(closestX, point.y, closestZ)
	end

	Vector3.disableCreateFromCache(closestPoint)

	return closestPoint
end

function CalcUtils.saveDiv(a, b, defaultV)
	if b < math_eps then
		return defaultV and defaultV or a, false
	end

	return a / b, true
end

local fast2ValueMap = {
	[0] = 0,
	2,
	4,
	8,
	16,
	32,
	64,
	128,
	256,
	512,
	1024,
	2048,
	4096,
	8192,
	16384,
	32768,
	65536,
	131072,
	262144,
	524288,
	1048576,
	2097152,
	4194304,
	8388608,
	16777216,
	33554432,
	67108864,
	134217728,
	268435456,
	536870912,
	1073741824,
	2147483648,
	4294967296
}

function CalcUtils.fast2Value(a)
	return fast2ValueMap[a] or 2^a
end

return CalcUtils
