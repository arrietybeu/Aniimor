-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\ResPoint\\ResPointPortDirDesc.lua

local Class = require("Core.Framework.Class")
local ResPointConst = require("Common.Const.ResPointConst")
local CalcUtils = require("Common.Utils.CalcUtils")
local ResPointUtils = require("Common.Utils.ResPointUtils")
local ResPointPortDirDesc = Class.LightClass("ResPointPortDirDesc")

function ResPointPortDirDesc:ctor()
	self.owner = nil
	self.dirId = 0
	self.dirMaxNum = 0
	self.dirCurNum = 0
	self.dirLimitRefType = ResPointConst.DirRefType.NoLimit
	self.dirLimitDescType = ResPointConst.DirDescType.FixAngle
	self.dirLimitParams = nil
	self.dirTowardsRefType = ResPointConst.DirRefType.NoLimit
	self.dirTowardsAngle = 0
	self.joinActors = {}
end

function ResPointPortDirDesc:init(owner, dirId, dirDescConfig)
	self.owner = owner
	self.dirId = dirId

	if dirDescConfig == nil then
		ResPointUtils.LogError("资源点端口方向配置不存在, templateId: %d, portId: %d, dirId: %d", owner.owner.templateId, owner.portId, dirId)

		return
	end

	self.dirMaxNum = dirDescConfig.dirInteractMaxNum or -1
	self.dirLimitRefType = dirDescConfig.limitYawRangeType or ResPointConst.DirRefType.NoLimit
	self.dirLimitParams = dirDescConfig.limitYawRange
	self.dirTowardsRefType = dirDescConfig.towardsYawType or ResPointConst.DirRefType.NoLimit
	self.dirTowardsAngle = dirDescConfig.towardsYaw or 0

	if self.dirLimitRefType ~= ResPointConst.DirRefType.NoLimit then
		if self.dirLimitParams == nil then
			self.dirLimitParams = {
				0,
				0
			}

			ResPointUtils.LogError("资源点端口方向配置的yawRange配置无效,请检查, templateId: %d, portId: %d, dirId: %d", owner.owner.templateId, owner.portId, dirId)
		end

		self.dirLimitDescType = math.Approximately(self.dirLimitParams[1], self.dirLimitParams[2]) and ResPointConst.DirDescType.FixAngle or ResPointConst.DirDescType.Range
	end

	ResPointUtils.LogWithDirDesc(nil, self, "ResPointPortDirDesc Init")
end

function ResPointPortDirDesc:getCurNum()
	return self.dirCurNum
end

function ResPointPortDirDesc:isFull()
	if self.dirMaxNum < 0 then
		return false
	end

	return self.dirCurNum >= self.dirMaxNum
end

function ResPointPortDirDesc:getRefDirection(dirRefType, srcPos)
	if dirRefType == ResPointConst.DirRefType.WorldNorth then
		return Vector3(0, 0, 1)
	elseif dirRefType == ResPointConst.DirRefType.PointForward then
		return self.owner:getWorldRotation():Forward()
	elseif dirRefType == ResPointConst.DirRefType.PortToPoint then
		return -self.owner:getWorldRotation():MulVec3(self.owner:getLocalPosition()):Normalize()
	elseif dirRefType == ResPointConst.DirRefType.EntToPort then
		return (self.owner:getWorldPosition() - srcPos):Normalize()
	else
		ResPointUtils.LogError("未定义的资源点端口参考方向类型: %d", dirRefType)
	end

	return Vector3(0, 0, 1)
end

function ResPointPortDirDesc:getNearestInteractPosition(actorId, portPos, srcPos, centerDist, ignoreNumCheck)
	if not ignoreNumCheck and self:isFull() then
		return false
	end

	local ret = false
	local targetPos = Vector3.zero

	Vector3.enableCreateFromCache()

	if self.dirLimitRefType == ResPointConst.DirRefType.NoLimit then
		local srcDir = (srcPos - portPos):Normalize()

		targetPos:Copy(portPos + srcDir * centerDist)

		ret = true
	else
		local refDir = self:getRefDirection(self.dirLimitRefType, srcPos)

		if self.dirLimitDescType == ResPointConst.DirDescType.FixAngle then
			local x, y, z = CalcUtils.clockwiseRotateDegree(refDir.x, refDir.y, refDir.z, self.dirLimitParams[1])

			targetPos:Copy(portPos + Vector3(x, y, z) * centerDist)

			ret = true
		elseif self.dirLimitDescType == ResPointConst.DirDescType.Range then
			local srcDir = (srcPos - portPos):Normalize()
			local x1, y1, z1 = CalcUtils.clockwiseRotateDegree(refDir.x, refDir.y, refDir.z, self.dirLimitParams[1])
			local x2, y2, z2 = CalcUtils.clockwiseRotateDegree(refDir.x, refDir.y, refDir.z, self.dirLimitParams[2])
			local x3, y3, z3 = CalcUtils.clockwiseRotateDegree(refDir.x, refDir.y, refDir.z, (self.dirLimitParams[1] + self.dirLimitParams[2]) * 0.5)
			local cosRange = x1 * x3 + y1 * y3 + z1 * z3
			local cosSrc = srcDir.x * x3 + srcDir.y * y3 + srcDir.z * z3

			if cosRange <= cosSrc then
				targetPos:Copy(portPos + srcDir * centerDist)

				ret = true
			else
				local targetPos1 = portPos + Vector3(x1, y1, z1) * centerDist
				local targetPos2 = portPos + Vector3(x2, y2, z2) * centerDist

				targetPos:Copy(Vector3.SqrDistance(targetPos1, srcPos) < Vector3.SqrDistance(targetPos2, srcPos) and targetPos1 or targetPos2)

				ret = true
			end
		else
			ResPointUtils.LogError("未定义的资源点端口参数描述类型: %d", self.dirLimitDescType)
		end
	end

	Vector3.disableCreateFromCache()

	if ResPointConst.OpenLog then
		ResPointUtils.LogWithDirDesc(actorId, self, "PortDirDesc.getNearestInteractPosition, portPos: %s, srcPos: %s, centerDist: %d, targetPos: %s", inspect(portPos), inspect(srcPos), centerDist, inspect(targetPos))
	end

	return ret, targetPos
end

function ResPointPortDirDesc:getInteractDirectionYaw(actorId, srcPos)
	local targetYaw

	if self.dirTowardsRefType == ResPointConst.DirRefType.NoLimit then
		-- block empty
	else
		Vector3.enableCreateFromCache()

		local refDir = self:getRefDirection(self.dirTowardsRefType, srcPos)

		targetYaw = math.deg(refDir:ToYaw()) + self.dirTowardsAngle

		Vector3.disableCreateFromCache()
	end

	return targetYaw
end

function ResPointPortDirDesc:checkCanInteract(actorId, portPos, srcPos, centerDist)
	local ret, pos, sqrDist

	if centerDist < 0 then
		ret = true
	else
		ret, pos = self:getNearestInteractPosition(actorId, portPos, srcPos, centerDist, true)

		if ret then
			pos.y = srcPos.y
			sqrDist = Vector3.SqrDistance(srcPos, pos)
			ret = sqrDist < ResPointConst.DefaultInteractCheckSqrDist
		end

		if not ret then
			ResPointUtils.LogWithDirDesc(actorId, self, "PortDirDesc.checkCanInteract false, actorId: %d, reason: interactDist", actorId)
		end
	end

	return ret
end

function ResPointPortDirDesc:preJoin(actorId)
	self.joinActors[actorId] = true
	self.dirCurNum = self.dirCurNum + 1
end

function ResPointPortDirDesc:join(actorId)
	return
end

function ResPointPortDirDesc:exit(actorId)
	self.joinActors[actorId] = nil
	self.dirCurNum = self.dirCurNum - 1
end

return ResPointPortDirDesc
