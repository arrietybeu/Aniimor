-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\ResPoint\\ResPointPort.lua

local Class = require("Core.Framework.Class")
local ResPointConst = require("Common.Const.ResPointConst")
local ResPointUtils = require("Common.Utils.ResPointUtils")
local ResPointPortDirDesc = require("Common.AI.ResPoint.ResPointPortDirDesc")
local TablePool = require("Common.Container.TablePool")
local Time = require("Core.Common.Time")
local ResPointPort = Class.LightClass("ResPointPort")

function ResPointPort:ctor()
	self.owner = nil
	self.portId = 0
	self.portIdTable = {}
	self.isStatic = false
	self.tags = {}
	self.maxNum = 0
	self.bodySize = 0
	self.interactDist = 0
	self.interactMaxHeight = 0
	self.dirDescs = {}
	self.dirIdCache = 0
	self.joinData = {}
	self.localPosition = nil
	self.worldPosition = Vector3.zero
	self.localRotation = nil
	self.worldRotation = Quaternion.identity
end

function ResPointPort:init(owner, portId, isStatic, portConfig, overrideConfig, extraTags)
	self.owner = owner
	self.portId = portId
	self.portIdTable = {
		owner.owner.actorId,
		owner.pointId,
		portId
	}

	if portConfig == nil then
		ResPointUtils.LogError("资源点端口配置不存在, templateId: %d, portId: %d", owner.templateId, portId)

		return
	end

	if overrideConfig then
		self:_initPos(isStatic, Vector3(unpack(overrideConfig.portPosition)))
	else
		self:_initPos(isStatic, Vector3(unpack(portConfig.portPosition)))
	end

	self:_initTag(portConfig.portTags, extraTags, owner:getAdditiveTags())
	self:_initBaseInfo(portConfig)

	if overrideConfig then
		self:_initDirDesc(overrideConfig.interactDirDescs)
	else
		self:_initDirDesc(portConfig.interactDirDescs)
	end

	ResPointUtils.LogWithPort(nil, self, "ResPointPort init")
end

function ResPointPort:_initPos(isStatic, localPos)
	self.isStatic = isStatic
	self.localPosition = localPos
	self.localRotation = Quaternion.identity

	if self.isStatic then
		self:_innerRefreshWorldPosition()
		self:_innerRefreshWorldRotation()
	end
end

function ResPointPort:_initTag(tags, extraTags, additiveTags)
	if tags ~= nil then
		for _, tag in ipairs(tags) do
			self.tags[tag] = true
		end
	end

	if extraTags ~= nil then
		for tag, _ in pairs(extraTags) do
			self.tags[tag] = true
		end
	end

	if additiveTags then
		for _, tag in ipairs(additiveTags) do
			self.tags[tag] = true
		end
	end
end

function ResPointPort:_initBaseInfo(portConfig)
	self.maxNum = portConfig.interactMaxNum or -1
	self.bodySize = portConfig.bodySize or 0
	self.interactDist = portConfig.interactDist or -1
	self.interactMaxHeight = portConfig.interactMaxHeight or -1
end

function ResPointPort:_initDirDesc(dirDescsConfig)
	if dirDescsConfig ~= nil and #dirDescsConfig > 0 then
		for _, dirDescConfig in ipairs(dirDescsConfig) do
			self:_addDirDesc(dirDescConfig)
		end
	else
		self:_addDirDesc(ResPointConst.DefaultDirDescConfig)
	end
end

function ResPointPort:_getNewDirId()
	self.dirIdCache = self.dirIdCache + 1

	return self.dirIdCache
end

function ResPointPort:_addDirDesc(dirDescConfig)
	local dirDesc = ResPointPortDirDesc.new()
	local dirId = self:_getNewDirId()

	dirDesc:init(self, dirId, dirDescConfig)

	self.dirDescs[dirId] = dirDesc
end

function ResPointPort:hasPortTag(tagName)
	if tagName == nil then
		return false
	end

	return self.tags[tagName]
end

function ResPointPort:getPortIdTable()
	return self.portIdTable
end

function ResPointPort:getTotalNum()
	local totalCount = 0

	for _, dirDesc in pairs(self.dirDescs) do
		totalCount = totalCount + dirDesc:getCurNum()
	end

	return totalCount
end

function ResPointPort:isFull()
	local portFull = self.maxNum >= 0 and self.maxNum <= self:getTotalNum()

	if portFull then
		return true
	end

	local dirAllFull = true

	for _, dirDesc in pairs(self.dirDescs) do
		if not dirDesc:isFull() then
			dirAllFull = false

			break
		end
	end

	return dirAllFull
end

function ResPointPort:update()
	local curTime = self.owner.owner.space:getGameTime()

	for actorId, data in pairs(self.joinData) do
		local ent = pg.getEntityByActorId(actorId)

		if not ent or data.exitTime and curTime > data.exitTime and Vector3.SqrDistance(self:getWorldPosition(), ent:getPosition()) > data.exitSqrDistance then
			self:_innerExit(actorId)
		end
	end
end

function ResPointPort:getNearestInteractPosition(actorId, lockDirDescId)
	local actor = pg.getEntityByActorId(actorId)

	if not actor then
		return false
	end

	local srcBodySize = actor.bodySize or 0
	local interactDist = math.max(self.interactDist, 0)
	local centerDist = self.bodySize + interactDist + srcBodySize

	return self:_innerGetNearestInteractPosition(actorId, lockDirDescId, centerDist)
end

function ResPointPort:getNearestInteractPositionInDist(actorId, lockDirDescId, interactDist, ignoreSelfBodySize, ignorePointBodySize)
	local actor = pg.getEntityByActorId(actorId)

	if not actor then
		return false
	end

	local srcBodySize = 0

	if not ignoreSelfBodySize then
		srcBodySize = actor.bodySize or 0
	end

	local pointBodySize = 0

	if not ignorePointBodySize then
		pointBodySize = self.bodySize
	end

	local centerDist = pointBodySize + interactDist + srcBodySize

	return self:_innerGetNearestInteractPosition(actorId, lockDirDescId, centerDist)
end

function ResPointPort:_innerGetNearestInteractPosition(actorId, lockDirDescId, centerDist)
	local ignoreNumCheck = self.joinData[actorId] ~= nil

	if not ignoreNumCheck and self:isFull() then
		return false
	end

	local actor = pg.getEntityByActorId(actorId)

	if not actor then
		return false
	end

	local srcPos = actor:getPosition()
	local portPos = self:getWorldPosition()
	local ret, pos, sqrDist, nearestPos, dirDescId, minSqrDist

	if lockDirDescId and self.dirDescs[lockDirDescId] then
		local dirDesc = self.dirDescs[lockDirDescId]

		ret, pos = dirDesc:getNearestInteractPosition(actorId, portPos, srcPos, centerDist, ignoreNumCheck)

		if ret then
			nearestPos = pos
			dirDescId = lockDirDescId
		end
	else
		for index, dirDesc in pairs(self.dirDescs) do
			ret, pos = dirDesc:getNearestInteractPosition(actorId, portPos, srcPos, centerDist, ignoreNumCheck)

			if ret then
				sqrDist = Vector3.SqrDistance(srcPos, pos)

				if nearestPos == nil or sqrDist < minSqrDist then
					nearestPos = pos
					dirDescId = index
					minSqrDist = sqrDist
				end
			end
		end
	end

	return nearestPos ~= nil, nearestPos, dirDescId
end

function ResPointPort:getInteractDirectionYaw(actorId)
	local actor = pg.getEntityByActorId(actorId)
	local data = self.joinData[actorId]

	if not actor or not data or not data.dirDesc or data.portInteractState ~= ResPointConst.PortInteractState.PreJoin then
		return
	end

	local dirDesc = data.dirDesc
	local srcPos = actor:getPosition()

	return dirDesc:getInteractDirectionYaw(actorId, srcPos)
end

function ResPointPort:preJoin(actorId, dirDescId)
	ResPointUtils.LogWithPort(actorId, self, "Port.preJoin, dirId: %d, nowActor: %d", dirDescId, actorId)

	local data = self.joinData[actorId]

	if data then
		return false
	end

	local dirDesc = self.dirDescs[dirDescId]

	if not dirDesc then
		return false
	end

	dirDesc:preJoin(actorId)

	local joinData = TablePool.getTable()

	joinData.dirDesc = dirDesc
	joinData.portInteractState = ResPointConst.PortInteractState.PreJoin
	self.joinData[actorId] = joinData

	return true
end

function ResPointPort:getPreJoinDirDescId(actorId)
	local data = self.joinData[actorId]

	return data and data.dirDesc and data.dirDesc.dirId
end

function ResPointPort:checkCanInteract(actorId)
	local actor = pg.getEntityByActorId(actorId)
	local data = self.joinData[actorId]

	if not actor or not data or not data.dirDesc or data.portInteractState ~= ResPointConst.PortInteractState.PreJoin then
		ResPointUtils.LogWithPort(actorId, self, "Port.checkCanInteract false, actorId: %d, reason: joinState", actorId)

		return false
	end

	local dirDesc = data.dirDesc
	local srcPos = actor:getPosition()
	local srcBodySize = actor.bodySize or 0
	local portPos = self:getWorldPosition()

	if self.interactMaxHeight >= 0 and math.abs(srcPos.y - portPos.y) > self.interactMaxHeight then
		ResPointUtils.LogWithPort(actorId, self, "Port.checkCanInteract false, actorId: %d, reason: interactMaxHeight", actorId)

		return false
	end

	local centerDist

	if self.interactDist < 0 then
		centerDist = self.interactDist
	else
		centerDist = self.bodySize + self.interactDist + srcBodySize
	end

	local ret = dirDesc:checkCanInteract(actorId, portPos, srcPos, centerDist)

	return ret
end

function ResPointPort:join(actorId)
	local data = self.joinData[actorId]

	if not data or not data.dirDesc or data.portInteractState ~= ResPointConst.PortInteractState.PreJoin then
		ResPointUtils.LogError("端口占用数据错误,交互失败")

		return
	end

	local dirDesc = data.dirDesc

	dirDesc:join(actorId)

	data.portInteractState = ResPointConst.PortInteractState.Join
end

function ResPointPort:exit(actorId, delayTime, exitDistance)
	ResPointUtils.LogWithPort(actorId, self, "Port.exit, nowActor: %d, delayTime: %s, exitDistance: %s", actorId, delayTime, exitDistance)

	local data = self.joinData[actorId]

	if data then
		data.exitTime = self.owner.owner.space:getGameTime() + (delayTime or 0)
		exitDistance = exitDistance or 0
		data.exitSqrDistance = exitDistance * exitDistance
	end
end

function ResPointPort:_innerExit(actorId)
	ResPointUtils.LogWithPort(actorId, self, "Port.exitReal, nowActor: %d", actorId)

	local data = self.joinData[actorId]

	if data then
		local dirDesc = data.dirDesc

		dirDesc:exit(actorId)

		self.joinData[actorId] = nil

		TablePool.returnTable(data)
	end
end

function ResPointPort:destroy()
	ResPointUtils.LogWithPort(nil, self, "ResPointPort destroy")

	for actorId, _ in pairs(self.joinData) do
		self:_innerExit(actorId)
	end
end

function ResPointPort:getLocalPosition()
	return self.localPosition
end

function ResPointPort:getWorldPosition()
	if not self.isStatic then
		self:_innerRefreshWorldPosition()
	end

	return self.worldPosition
end

function ResPointPort:_innerRefreshWorldPosition()
	Vector3.enableCreateFromCache()
	self.worldPosition:Copy(self.owner:getWorldPosition() + self.owner:getWorldRotation():MulVec3(self.localPosition))
	Vector3.disableCreateFromCache()
end

function ResPointPort:getLocalRotation()
	return self.localRotation
end

function ResPointPort:getWorldRotation()
	if not self.isStatic then
		self:_innerRefreshWorldRotation()
	end

	return self.worldRotation
end

function ResPointPort:_innerRefreshWorldRotation()
	Vector3.enableCreateFromCache()
	self.worldRotation:Copy(self.owner:getWorldRotation() * self.localRotation)
	Vector3.disableCreateFromCache()
end

return ResPointPort
