-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientPlayerRiftComponent.lua

local Class = require("Core.Framework.Class")
local LoggerManager = require("Core.Log.LoggerManager")
local logger = LoggerManager.getLogger("RiftComponent")
local RiftLevelData = require("Data.rift_level_data")
local MessageName = require("Const.MessageName")
local Const = require("Common.Const.Const")
local ClientPlayerRiftComponent = Class.Component("ClientPlayerRiftComponent")

function ClientPlayerRiftComponent:ctor()
	self.riftLevelIdsByNpcId = self:buildNpcLevelMap()
end

function ClientPlayerRiftComponent:start()
	return
end

function ClientPlayerRiftComponent:buildNpcLevelMap()
	local npcLevelMap = {}

	for levelId, cfg in pairs(RiftLevelData) do
		local npcId = cfg.npcid

		if npcId then
			local levelList = npcLevelMap[npcId]

			if not levelList then
				levelList = {}
				npcLevelMap[npcId] = levelList
			end

			levelList[#levelList + 1] = levelId
		end
	end

	for _, levelList in pairs(npcLevelMap) do
		table.sort(levelList, function(a, b)
			local cfgA = RiftLevelData[a]
			local cfgB = RiftLevelData[b]
			local lvA = cfgA and cfgA.entity_lv or 0
			local lvB = cfgB and cfgB.entity_lv or 0

			if lvA == lvB then
				return a < b
			end

			return lvA < lvB
		end)
	end

	return npcLevelMap
end

function ClientPlayerRiftComponent:startFissureChallenge(levelId)
	self:serverMsg("RPC_CS_RiftStart", levelId, function(res)
		self:clearRiftFocusCamera()

		self.curLevelId = levelId

		facade:sendMsgToUI(MessageName.ON_PLAYER_START_RIFT)
	end)
end

function ClientPlayerRiftComponent:resetFissureChallenge()
	self:serverMsg("RPC_CS_RiftRestart", self.curLevelId)
end

function ClientPlayerRiftComponent:endFissureChallenge()
	self:serverMsg("RPC_CS_RiftEnd", function(res)
		self:clearRiftFocusCamera()

		self.curLevelId = nil

		facade:sendMsgToUI(MessageName.ON_PLAYER_END_RIFT)
	end)
end

function ClientPlayerRiftComponent:getRiftReward(levelId)
	if levelId == nil or levelId == 0 then
		return
	end

	self:serverMsg("RPC_CS_RiftClaimReward", levelId, function()
		facade:sendMsgToUI(MessageName.UPDATE_INTERACT_VIEW, {})
	end)
end

function ClientPlayerRiftComponent:setRiftLevelId(levelId)
	self.curLevelId = levelId
end

function ClientPlayerRiftComponent:getRiftRewardByNpc(npcParam)
	local npcId = npcParam and npcParam[1]
	local levelId = self:canGetReward(npcId)

	self:getRiftReward(levelId)
end

function ClientPlayerRiftComponent:claimRiftRewardByEventParam(eventParam)
	if not eventParam or #eventParam == 0 then
		return
	end

	local levelId

	if #eventParam == 1 then
		levelId = self:canGetReward(eventParam[1])
	else
		levelId = self:firstRewardableLevel(eventParam)
	end

	self:getRiftReward(levelId)
end

function ClientPlayerRiftComponent:firstRewardableLevel(levelIds)
	local map = self.riftStateMap

	if not map or not levelIds then
		return Const.RiftState.None
	end

	for _, levelId in ipairs(levelIds) do
		if map[levelId] == Const.RiftState.Win then
			return levelId
		end
	end

	if logger then
		logger:debug("firstRewardableLevel no reward level in given levels")
	end

	return Const.RiftState.None
end

function ClientPlayerRiftComponent:canGetReward(npcId)
	local map = self.riftStateMap

	if not npcId or not map then
		return 0
	end

	local levelList = self.riftLevelIdsByNpcId and self.riftLevelIdsByNpcId[npcId]

	if not levelList then
		return 0
	end

	for _, levelId in ipairs(levelList) do
		if map[levelId] == Const.RiftState.Win then
			return levelId
		end
	end

	return 0
end

function ClientPlayerRiftComponent:allRewardGot(npcId)
	local map = self.riftStateMap

	if not npcId or not map then
		return 0
	end

	local levelList = self.riftLevelIdsByNpcId and self.riftLevelIdsByNpcId[npcId]

	if not levelList then
		return 0
	end

	for _, levelId in ipairs(levelList) do
		if map[levelId] ~= Const.RiftState.Got then
			return 0
		end
	end

	return 1
end

function ClientPlayerRiftComponent:getLevelState(levelId)
	local map = self.riftStateMap

	if not map or not levelId then
		return 0
	end

	return map[levelId] or 0
end

function ClientPlayerRiftComponent:isInRiftMode()
	return self.curLevelId ~= nil and self.curLevelId ~= 0
end

function ClientPlayerRiftComponent:destroy()
	self.riftLevelIdsByNpcId = nil
end

function ClientPlayerRiftComponent:getRiftFocusCameraTransform(targetEntity)
	if not pg.pawn or not targetEntity or not pg.pawn.getPositionAgentPosition or not targetEntity.getPositionAgentPosition then
		return nil, nil
	end

	local playerPos = pg.pawn:getPositionAgentPosition()
	local targetPos = targetEntity:getPositionAgentPosition()
	local targetDir = targetEntity:getPositionAgentPosition() - pg.pawn:getPositionAgentPosition()

	targetDir.y = 0

	local targetDistanceSqr = targetDir:SqrMagnitude()

	if targetDistanceSqr <= 0.0001 then
		return nil, nil
	end

	local targetRotation = Quaternion.LookRotation(targetDir, Vector3.up)

	pg.pawn:faceToRotation(targetRotation)
	targetDir:SetNormalize()

	local right = targetRotation * Vector3.right
	local cameraPos = playerPos - targetDir * 4.2 + Vector3.up * 1.35
	local lookAtPos = targetPos + Vector3.up * 1.55 + right * 1.2
	local cameraRot = Quaternion.LookRotation(lookAtPos - cameraPos, Vector3.up)

	return cameraPos, cameraRot
end

function ClientPlayerRiftComponent:focusRift(targetEntity)
	local cameraPos, cameraRot = self:getRiftFocusCameraTransform(targetEntity)

	if not cameraPos or not cameraRot then
		return
	end

	pg.game.camera:enableFocusTarget(true, {
		rift = targetEntity
	}, {
		fov = 55,
		blendTime = 0.8,
		position = cameraPos,
		rotation = cameraRot
	})
end

function ClientPlayerRiftComponent:clearRiftFocusCamera()
	if pg.game and pg.game.camera then
		pg.game.camera:enableFocusTarget(false)
	end
end

return ClientPlayerRiftComponent
