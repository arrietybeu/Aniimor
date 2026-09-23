-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\AI\\ResPoint\\ResPoint.lua

local Class = require("Core.Framework.Class")
local ResPointPort = require("Common.AI.ResPoint.ResPointPort")
local ResPointUtils = require("Common.Utils.ResPointUtils")
local ResPointConst = require("Common.Const.ResPointConst")
local ResPointTemplateData = require("Common.Data.ResPoint.resource_point_temp_data")
local GroupBehaviourConst = require("Common.Const.GroupBehaviourConst")
local GroupBehaviourUtils = require("Common.Utils.GroupBehaviourUtils")
local TimerManager = require("Core.Timer.TimerManager")
local PhotoIdentifyData = require("Data.photo_identify_data")
local Time = require("Core.Common.Time")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local AIUtils = require("Common.Utils.AIUtils")
local ResPoint = Class.LightClass("ResPoint")

function ResPoint:ctor()
	self.isActive = false
	self.owner = nil
	self.pointId = 0
	self.templateId = 0
	self.rawData = nil
	self.isStatic = false
	self.tags = {}
	self.ports = {}
	self.portIdCache = 0
	self.portTickTime = 0
	self.groupBehaviour = nil
	self.isNearPlayer = false
	self.activeType = 0
	self.activeRange = 0
	self.inactiveRange = 0
	self.isInPhotoEcology = false
	self.isInPhotoTipRange = false
	self.photoEcologyActorIds = nil
	self.photoId = nil
	self.photoMinDist = 0
	self.photoMaxDist = 0
	self.formationConfig = nil
	self.formationActorIds = nil
	self.tempPlayerTable = {}
	self.localPosition = nil
	self.worldPosition = Vector3.zero
	self.localRotation = nil
	self.worldRotation = Quaternion.identity
end

function ResPoint:init(owner, pointId, pointInfo)
	self.owner = owner
	self.pointId = pointId
	self.pointType = pointInfo.pointType

	local initResult = true

	if self.pointType == ResPointConst.PointType.Static then
		initResult = self:_initStaticPoint(pointInfo)
	elseif self.pointType == ResPointConst.PointType.Dynamic then
		initResult = self:_initDynamicPoint(pointInfo)
	elseif self.pointType == ResPointConst.PointType.Formation then
		initResult = self:_initFormationPoint(pointInfo)
	else
		initResult = false

		ResPointUtils.LogError("资源点初始化失败,类型不存在, pointType: %d", self.pointType)
	end

	if not initResult then
		return
	end

	local aiMgr = self.owner and self.owner.space and self.owner.space.aiMgr

	if aiMgr then
		aiMgr.resPointModule:onResPointInit(self)
	end

	ResPointUtils.LogWithPoint(nil, self, "ResPoint init")
end

function ResPoint:_initStaticPoint(pointInfo)
	local config = ResPointTemplateData[pointInfo.templateId]

	if config == nil then
		ResPointUtils.LogError("资源点的模板配置不存在, pointInfo: %s", inspect(pointInfo))

		return false
	end

	self.templateId = pointInfo.templateId

	local rawData = ResPointUtils.GetResPointData(pointInfo.sceneId, self.owner and self.owner.space and self.owner.space.id)[pointInfo.staticId]

	self.rawData = rawData

	self:_initPos(true, Vector3.zero, Quaternion.identity)
	self:_initTag(config.tags, rawData and rawData.additiveTags)
	self:_initPort(config.interactPorts)
	self:_initGroupBehaviour(config.groupBehaviour)
	self:_initActiveParam(config.activeType, config.activeRange)
	self:_initPhoto(rawData and rawData.photoId)

	return true
end

function ResPoint:_initDynamicPoint(pointInfo)
	local config = ResPointTemplateData[pointInfo.templateId]

	if config == nil then
		ResPointUtils.LogError("资源点的模板配置不存在, pointInfo: %s", inspect(pointInfo))

		return false
	end

	self.templateId = pointInfo.templateId
	self.dynamicInfo = pointInfo

	self:_initPos(false, Vector3(unpack(pointInfo.offsetPos)), Quaternion.Euler(0, pointInfo.offsetYaw, 0))
	self:_initTag(config.tags)
	self:_initPort(config.interactPorts)
	self:_initGroupBehaviour(config.groupBehaviour)
	self:_initActiveParam(config.activeType, config.activeRange)

	return true
end

function ResPoint:_initFormationPoint(pointInfo)
	local formationConfig = ResPointConst.FormationConfig[pointInfo.formationId]

	if formationConfig == nil then
		ResPointUtils.LogError("资源点的阵型配置不存在, formationId: %s", inspect(pointInfo))

		return false
	end

	self:_initPos(false, Vector3.zero, Quaternion.identity)
	self:_initActiveParam(ResPointConst.ActiveType.None)

	self.formationConfig = formationConfig
	self.formationActorIds = {}

	return true
end

function ResPoint:_initPos(isStatic, localPos, localRot)
	self.isStatic = isStatic
	self.localPosition = localPos
	self.localRotation = localRot

	if isStatic then
		self:_innerRefreshWorldPosition()
		self:_innerRefreshWorldRotation()
	end
end

function ResPoint:_initTag(tags, additiveTags)
	if tags then
		for _, tag in ipairs(tags) do
			self.tags[tag] = true
		end
	end

	if additiveTags then
		for _, tag in ipairs(additiveTags) do
			self.tags[tag] = true
		end
	end
end

function ResPoint:_initPort(portsConfig)
	if portsConfig ~= nil and #portsConfig > 0 then
		for idx, portConfig in ipairs(portsConfig) do
			if self:isPortOverride() then
				self:_addPort(portConfig, self:getPortOverrideData(idx))
			else
				self:_addPort(portConfig)
			end
		end
	else
		self:_addPort(ResPointConst.DefaultPortConfig, nil, self.tags)
	end
end

function ResPoint:_getNewPortId()
	self.portIdCache = self.portIdCache + 1

	return self.portIdCache
end

function ResPoint:_addPort(portConfig, overrideConfig, extraTags)
	local port = ResPointPort.new()
	local portId = self:_getNewPortId()

	port:init(self, portId, self.isStatic, portConfig, overrideConfig, extraTags)

	self.ports[portId] = port

	return port
end

function ResPoint:_initGroupBehaviour(behavName)
	if string.isNilOrEmpty(behavName) then
		return
	end

	local aiMgr = self.owner and self.owner.space and self.owner.space.aiMgr

	if aiMgr then
		self.groupBehaviour = aiMgr:createBehaviour(behavName)
	end

	if not self.groupBehaviour then
		GroupBehaviourUtils.LogError("资源点配置的活动不存在, 资源点模板ID: %d, 活动名: %s", self.templateId, behavName)

		return
	end

	self.groupBehaviour.bindResPoint = self

	if self.groupBehaviour.minStartMemberCount < 0 then
		self.groupBehaviour.minStartMemberCount = table.getCount(self.ports)
	end

	if self.groupBehaviour.minHoldMemberCount < 0 then
		self.groupBehaviour.minHoldMemberCount = table.getCount(self.ports)
	end

	if self.groupBehaviour.maxMemberCount < 0 then
		self.groupBehaviour.maxMemberCount = table.getCount(self.ports)
	end

	GroupBehaviourUtils.LogWithBehav(self.groupBehaviour, "init finished, bind respoint: (actorId: %d, pointId: %d), memberCount: %d", self.owner.actorId, self.pointId, self.groupBehaviour.maxMemberCount)
	self.groupBehaviour:start()
end

function ResPoint:_initActiveParam(activeType, rangeIdx)
	self.activeType = activeType or ResPointConst.ActiveType.PlayerRange

	if self:isPointOverride() then
		rangeIdx = self:getPointOverrideActiveRange()
	end

	self.activeRange = ResPointConst.ActiveRange[rangeIdx or 0]
	self.inactiveRange = self.activeRange + ResPointConst.InactiveRangeDelta
end

function ResPoint:_initPhoto(photoId)
	if not photoId or not PhotoIdentifyData[photoId] then
		return
	end

	local data = PhotoIdentifyData[photoId]

	self.photoId = photoId
	self.photoMinDist = data.showDistance and data.showDistance[1] or 0
	self.photoMaxDist = data.showDistance and data.showDistance[2] or 0
end

function ResPoint:update()
	if self.owner.actorType == Const.ACTOR_TYPE_PET and not self.owner.isSummon then
		return
	end

	self:_checkPlayer()
	self:_checkPhoto()
	self:_checkInactive()
	self:_portsUpdate()
end

function ResPoint:_checkPlayer()
	local count = AIUtils.SearchEntitiesInRangeWithTable(self.owner, self.activeRange, Const.SEARCH_USR_TYPE_PLAYER, 1, self.tempPlayerTable)

	if self.isNearPlayer then
		if count <= 0 then
			self.isNearPlayer = false
		end
	elseif count > 0 then
		self.isNearPlayer = true

		self:_checkActive()
	end
end

function ResPoint:_checkPhoto()
	if not Utils.checkClient() then
		return
	end

	if not self.photoId then
		return
	end

	local playerSqrDist = Vector3.SqrDistance(pg.me:getPosition(), self:getWorldPosition())

	if self.isInPhotoTipRange then
		local minDist = math.max(self.photoMinDist - ResPointConst.InactiveRangeDelta, 0)
		local maxDist = self.photoMaxDist + ResPointConst.InactiveRangeDelta

		if playerSqrDist < minDist * minDist or playerSqrDist > maxDist * maxDist then
			self:onPlayerExitPhotoRange()
		end
	elseif playerSqrDist > self.photoMinDist * self.photoMinDist and playerSqrDist < self.photoMaxDist * self.photoMaxDist then
		self:onPlayerEnterPhotoRange()
	end
end

function ResPoint:_checkActive()
	if self.activeType == ResPointConst.ActiveType.PlayerRange and not self.isActive and self.isNearPlayer then
		self:_activate()
	end
end

function ResPoint:_checkInactive()
	if self.activeType == ResPointConst.ActiveType.PlayerRange and self.isActive and not self.isNearPlayer and self:isFree() then
		self:_inactivate()
	end
end

function ResPoint:_activate()
	self.isActive = true
end

function ResPoint:_inactivate()
	self.isActive = false
end

function ResPoint:activeByScene(enable)
	if enable then
		self:_activate()
	else
		self:_inactivate()
	end
end

function ResPoint:_portsUpdate()
	local curTime = self.owner.space:getGameTime()

	if curTime > self.portTickTime then
		self.portTickTime = curTime + 1

		for _, resPointPort in pairs(self.ports) do
			resPointPort:update()
		end
	end
end

function ResPoint:isFree()
	if self.groupBehaviour and self.groupBehaviour:getMemberCount() > 0 then
		return false
	end

	for _, resPointPort in pairs(self.ports) do
		if resPointPort:getTotalNum() > 0 then
			return false
		end
	end

	return true
end

function ResPoint:canBeSearch()
	if not self.isActive then
		return false
	end

	if self.groupBehaviour and (self.groupBehaviour:isRunning() or self.groupBehaviour:isInCD()) then
		return false
	end

	return true
end

function ResPoint:canPhoto()
	return self.isInPhotoEcology
end

function ResPoint:onPlayerEnterPhotoRange()
	if not Utils.checkClient() then
		return
	end

	if self.photoId then
		self.isInPhotoTipRange = true

		self:_sendMsgToUI("ENTER_PHOTO_AI_TRAIT", {
			fixPointId = self:getFixPointId(),
			photoId = self.photoId
		})
	end
end

function ResPoint:onPlayerExitPhotoRange()
	if not Utils.checkClient() then
		return
	end

	if self.photoId then
		self.isInPhotoTipRange = false

		self:_sendMsgToUI("LEAVE_PHOTO_AI_TRAIT", {
			fixPointId = self:getFixPointId(),
			photoId = self.photoId
		})
	end
end

function ResPoint:refreshPhotoMessage()
	if not Utils.checkClient() then
		return
	end

	if self.photoId then
		if self.isInPhotoTipRange then
			self:_sendMsgToUI("ENTER_PHOTO_AI_TRAIT", {
				fixPointId = self:getFixPointId(),
				photoId = self.photoId
			})
		end

		if self.isInPhotoEcology then
			self:_sendMsgToUI("AI_PHOTO_TRAIT_START", {
				fixPointId = self:getFixPointId(),
				photoId = self.photoId,
				memberActorIds = self.photoEcologyActorIds
			})
		end
	end
end

function ResPoint:tryEnterPhotoEcology(memberActorIds)
	if not Utils.checkClient() then
		return
	end

	if self.photoId and not self.isInPhotoEcology then
		self.isInPhotoEcology = true
		self.photoEcologyActorIds = memberActorIds

		self:_sendMsgToUI("AI_PHOTO_TRAIT_START", {
			fixPointId = self:getFixPointId(),
			photoId = self.photoId,
			memberActorIds = memberActorIds
		})
	end
end

function ResPoint:tryExitPhotoEcology()
	if not Utils.checkClient() then
		return
	end

	if self.photoId and self.isInPhotoEcology then
		self.isInPhotoEcology = false

		self:_sendMsgToUI("AI_PHOTO_TRAIT_END", {
			fixPointId = self:getFixPointId(),
			photoId = self.photoId
		})
	end
end

function ResPoint:_sendMsgToUI(msgName, context)
	if not Utils.checkClient() then
		return
	end

	local MessageName = require("Const.MessageName")

	if MessageName[msgName] then
		facade:sendMsgToUI(MessageName[msgName], context)
	end
end

function ResPoint:joinFormationFollow(actorId)
	if self.pointType ~= ResPointConst.PointType.Formation then
		ResPointUtils.LogError("资源点类型错误,当前类型无法使用阵列跟随功能, pointType: %s", self.pointType)

		return false
	end

	if #self.formationActorIds >= self.formationConfig.num then
		return false
	end

	local ent = pg.getEntityByActorId(actorId)

	if not ent or not ent.ResPoint then
		return false
	end

	if #self.formationActorIds == 0 then
		self.owner:setFormationFollowActive(true)
	end

	self.formationActorIds[#self.formationActorIds + 1] = actorId

	self:_reArrangeFormationMembers()

	return true
end

function ResPoint:exitFormationFollow(actorId)
	if self.pointType ~= ResPointConst.PointType.Formation then
		ResPointUtils.LogError("资源点类型错误,当前类型无法使用阵列跟随功能, pointType: %s", self.pointType)

		return false
	end

	local removeIdx

	for _idx, _actorId in ipairs(self.formationActorIds) do
		if _actorId == actorId then
			removeIdx = _idx

			break
		end
	end

	if removeIdx then
		table.remove(self.formationActorIds, removeIdx)
		self:_reArrangeFormationMembers()

		if #self.formationActorIds == 0 then
			self.owner:setFormationFollowActive(false)
		end

		return true
	end

	return false
end

function ResPoint:_reArrangeFormationMembers()
	local num = #self.formationActorIds

	for i = 1, num do
		local actorId = self.formationActorIds[i]
		local ent = pg.getEntityByActorId(actorId)

		if ent then
			ent:setFormationFollowTarget(self.owner.actorId, self.pointId, i)
		end
	end
end

function ResPoint:onGroupBehavStartRunning()
	local memberActorIds = self.groupBehaviour:getMemberActorIdList()

	self:tryEnterPhotoEcology(memberActorIds)
end

function ResPoint:onGroupBehavEndRunning()
	self:tryExitPhotoEcology()
end

function ResPoint:hasPointTag(tagName)
	if tagName == nil then
		return false
	end

	return self.tags[tagName]
end

function ResPoint:getFixPointId()
	return ResPointUtils.ToFixPointId(self.owner.actorId, self.pointId)
end

function ResPoint:destroy()
	if self.isInPhotoTipRange then
		self:onPlayerExitPhotoRange()
	end

	if self.isInPhotoEcology then
		self:tryExitPhotoEcology()
	end

	for _, resPointPort in pairs(self.ports) do
		resPointPort:destroy()
	end

	self.ports = {}

	local aiMgr = self.owner and self.owner.space and self.owner.space.aiMgr

	if self.groupBehaviour then
		if aiMgr then
			aiMgr:destroyBehaviour(self.groupBehaviour)
		end

		self.groupBehaviour = nil
	end

	if aiMgr then
		aiMgr.resPointModule:onResPointDestroy(self)
	end

	ResPointUtils.LogWithPoint(nil, self, "ResPoint destroy")
end

function ResPoint:getStaticId()
	if self.rawData then
		return self.rawData.id
	end

	return 0
end

function ResPoint:getRouteId()
	if self.rawData then
		return self.rawData.routeId
	end

	return 0
end

function ResPoint:getRouteIdWithIndex(index)
	if self.rawData then
		return self.rawData.routeIds and self.rawData.routeIds[index] or 0
	end

	return 0
end

function ResPoint:getClimbDataId()
	if self.rawData then
		return self.rawData.climbTreeId or 0
	end

	return 0
end

function ResPoint:isPortOverride()
	return self.rawData and self.rawData.usePortOverride or false
end

function ResPoint:getPortOverrideData(idx)
	return self.rawData and self.rawData.portOverrideDatas[idx]
end

function ResPoint:isPointOverride()
	return self.rawData and self.rawData.usePointOverride or false
end

function ResPoint:getPointOverrideActiveRange()
	return self.rawData and self.rawData.activeRangeOverride or 0
end

function ResPoint:getPhotoId()
	return self.rawData and self.rawData.photoId or 0
end

function ResPoint:getGroupBehaviourSandboxId()
	return self.rawData and self.rawData.groupBehaviourSandboxId or 0
end

function ResPoint:getGroupBehaviourLevelItemId()
	return self.rawData and self.rawData.groupBehaviourLevelItemId or 0
end

function ResPoint:getRoleConditionStaticId(roleType)
	if self.rawData and self.rawData.roleConditionStaticIds then
		return self.rawData.roleConditionStaticIds[roleType] or 0
	end

	return 0
end

function ResPoint:getAdditiveTags()
	return self.rawData and self.rawData.additiveTags
end

function ResPoint:getFollowRotateType()
	local followRotateType = ResPointConst.FollowRotateType.All

	if self.pointType == ResPointConst.PointType.Dynamic then
		followRotateType = self.dynamicInfo.followRotateType
	elseif self.pointType == ResPointConst.PointType.Formation then
		followRotateType = ResPointConst.FollowRotateType.FormationFollow
	end

	return followRotateType
end

function ResPoint:getLocalPosition()
	return self.localPosition
end

function ResPoint:getWorldPosition()
	if not self.isStatic then
		self:_innerRefreshWorldPosition()
	end

	return self.worldPosition
end

function ResPoint:_innerRefreshWorldPosition()
	Vector3.enableCreateFromCache()
	self.worldPosition:Copy(self.owner:getPosition() + self:_innerGetParentRotation():MulVec3(self.localPosition))
	Vector3.disableCreateFromCache()
end

function ResPoint:getLocalRotation()
	return self.localRotation
end

function ResPoint:getWorldRotation()
	if not self.isStatic then
		self:_innerRefreshWorldRotation()
	end

	return self.worldRotation
end

function ResPoint:_innerRefreshWorldRotation()
	Vector3.enableCreateFromCache()
	self.worldRotation:Copy(self:_innerGetParentRotation() * self.localRotation)
	Vector3.disableCreateFromCache()
end

function ResPoint:_innerGetParentRotation()
	local followRotateType = self:getFollowRotateType()

	if followRotateType == ResPointConst.FollowRotateType.All then
		return self.owner:getRotation()
	elseif followRotateType == ResPointConst.FollowRotateType.None then
		return Quaternion.identity
	elseif followRotateType == ResPointConst.FollowRotateType.OnlyYaw then
		local yawDegree = math.deg(self.owner:getRotation():ToYaw())

		return Quaternion.Euler(0, yawDegree, 0)
	elseif followRotateType == ResPointConst.FollowRotateType.FormationFollow then
		return self.owner:getFormationFollowTargetRotation()
	end

	return self.owner:getRotation()
end

function ResPoint:getFormationFollowPointWorldPosition(index, refTargetPos)
	if self.formationActorIds == nil or self.formationConfig == nil then
		return
	end

	local num = #self.formationActorIds
	local posArray = self.formationConfig.posArrays[num]
	local pos = posArray[index]

	Vector3.enableCreateFromCache()
	refTargetPos:Copy(self:getWorldPosition() + self:getWorldRotation():MulVec3(pos))
	Vector3.disableCreateFromCache()
end

return ResPoint
