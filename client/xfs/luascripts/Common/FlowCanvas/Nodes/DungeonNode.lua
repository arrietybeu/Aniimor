-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Common\\FlowCanvas\\Nodes\\DungeonNode.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local AccessControl = require("Core.Framework.AccessControl")
local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local ListenBaseNode = require("Common.FlowCanvas.Nodes.ListenBaseNode")
local ServerUtils = require("GameServer.ServerUtils")
local Utils = require("Common.Utils.Utils")
local RougeStartLogic = require("Entities.SpaceEntities.PlayerComponent.PlayerRogue.rogueservice.RougeStartLogic")
local DungeonNode = Class.LiteClass("DungeonNode", ListenBaseNode)
local unpack = unpack

local function createSpawner(space, args)
	if #args < 1 then
		return
	end

	local spawner = space:getSpawner(args[1])

	if spawner then
		spawner:loadSpawnEntityManual()
	end
end

local function destroySpawner(space, args)
	if #args < 1 then
		return
	end

	local spawner = space:getSpawner(args[1])

	if spawner then
		spawner:unloadEntity()
	end
end

local function teleportPlayer(space, args)
	if #args < 1 then
		return
	end

	for _, player in pairs(space.players) do
		player:portal(space.sceneId, args[1])
	end
end

local function teleportEntity(space, args)
	if #args < 2 then
		return
	end

	local staticId, portalId = unpack(args)
	local entity = space:getEntityByStaticId(staticId)

	if not entity then
		return
	end

	local _, position, yaw = ServerUtils.getPortalBornInfo(entity:getPosition(), space, portalId)

	entity:setPosition(position, yaw)
end

local function selectBuff(space, args)
	if space and space.dungeonAction_selectBuff then
		space:dungeonAction_selectBuff(args)
	end
end

local function addBuff(space, args)
	if #args < 1 then
		return
	end

	local buffId = args[1]

	for _, player in pairs(space.players) do
		player:addTeamBuff(buffId)
	end

	space:addTmpBuffRecord(buffId)
end

local function fbRogueAddPuppetBuff(space, args)
	if #args < 1 then
		return
	end

	local buffId = args[1]

	if space and space.dungeonAction_addPuppetBuff then
		space:dungeonAction_addPuppetBuff(buffId)
	end
end

local function removeBuff(space, args)
	if #args < 1 then
		return
	end

	local buffId = args[1]

	for _, player in pairs(space.players) do
		player:removeGroupBuff(buffId)
	end
end

local function removeAllBuff(space, args)
	for _, player in pairs(space.players) do
		player:removeAllBuff()
	end
end

local function removeAllPetAllbuff(space, args)
	for _, player in pairs(space.players) do
		for _, pet in pairs(player:getAllPreparePetEntity()) do
			pet:removeAllBuff()
		end
	end
end

local function removeRogueBuffs(space, args)
	if #args < 3 then
		return
	end

	local count, series, stars = Utils.safeUnpack(args)

	if space and space.dungeonAction_removeRogueBuffs then
		space:dungeonAction_removeRogueBuffs(count, series, stars)
	end
end

local function recoverPlayerHp(space, args)
	if #args < 1 then
		return
	end

	local percent = args[1]

	for _, player in pairs(space.players) do
		player:changeHpPer(percent)
	end
end

local function recoverAllPetHp(space, args)
	if #args < 1 then
		return
	end

	local percent = args[1]

	for _, player in pairs(space.players) do
		for _, pet in pairs(player:getAllPreparePetEntity()) do
			pet:changeHpPer(percent)
		end
	end
end

local function playerCastAbility(space, args)
	if #args < 1 then
		return
	end

	local abilityId = args[1]

	for _, player in pairs(space.players) do
		player:castAbilityNoTarget(abilityId)
	end
end

local function petCastAbility(space, args)
	if #args < 1 then
		return
	end

	local abilityId = args[1]

	for _, player in pairs(space.players) do
		local curPet = player:getCurPetEntity()

		if curPet then
			curPet:castAbilityNoTarget(abilityId)
		end
	end
end

local function forceTmpPetTeam(space, args)
	if #args < 2 then
		return
	end

	local validTime, teamInfo = Utils.safeUnpack(args)

	if type(validTime) ~= "number" or type(teamInfo) ~= "table" then
		return
	end

	if #teamInfo == 1 and teamInfo[1][1] == 0 and teamInfo[1][2] == 0 then
		teamInfo = {}
	end

	for _, player in pairs(space.players) do
		if player.petTeamType == Const.PET_TEAM_TYPE_DEFAULT or player.petTeamType == Const.PET_TEAM_TYPE_TMP_EVENT then
			player:forceTmpPetTeam(validTime, teamInfo)
			space:addTmpPetTeamRecord(player, args)
		end
	end
end

local DittoPetDuration = 43200
local DittoPetTeamInfo = {
	{
		1,
		102410001
	}
}

local function forceMorphlingPet(space, args)
	local player = space:getMainPlayer()

	player:forceTmpPetTeam(DittoPetDuration, DittoPetTeamInfo)
	player:setForceControl(true)
end

local function showStage(space, args)
	if #args < 2 then
		return
	end

	local stage, totalStage = args[1], args[2]

	if space and space.notifyStageChange then
		space:notifyStageChange(stage, totalStage)
	end
end

local function showChallengeResult(space, args)
	if #args < 1 then
		return
	end

	local result = args[1]
	local failReason = args[2] or 0

	if space and space.notifyChallengeSuccess then
		space:notifyChallengeSuccess(result == 1 and true or false, failReason)
	end
end

local function selectBuffByArgs(space, args)
	if #args < 2 then
		return
	end

	local seriesList, starList = args[1], args[2]

	if space and space.dungeonAction_selectBuffByArgs then
		space:dungeonAction_selectBuffByArgs(seriesList, starList)
	end
end

local function addBuffByArgs(space, args)
	if #arg < 2 then
		return
	end

	local seriesList, starList = args[1], args[2]

	if space and space.dungeonAction_addBuffByArgs then
		space:dungeonAction_addBuffByArgs(seriesList, starList)
	end
end

local function forceEnterCombat(space, args)
	if space and space.forceEnterCombat then
		space:forceEnterCombat()
	end
end

local function forceLeaveCombat(space, args)
	if space and space.forceLeaveCombat then
		space:forceLeaveCombat()
	end
end

local function fbRogueSendSomeReward(space, args)
	if space and space.RogueSendSomeReward then
		space:RogueSendSomeReward()
	end
end

local function fbLevelStart(space, args)
	if space and space.onGraphNtfLevelStart then
		space:onGraphNtfLevelStart(args)
	end
end

local function startNewRogue(space, args)
	if not args or #args < 1 then
		return
	end

	local player = space:getMainPlayer()

	if not player then
		return
	end

	RougeStartLogic.startRogue(player, args[1])
end

local actionMap = {
	fbCreateSpawner = createSpawner,
	fbDestroySpawner = destroySpawner,
	fbTeleportPlayer = teleportPlayer,
	fbTeleportEntity = teleportEntity,
	fbAddBuff = addBuff,
	fbRemoveBuff = removeBuff,
	fbRemoveAllBuff = removeAllBuff,
	fbRemoveAllPetAllbuff = removeAllPetAllbuff,
	fbRecoverPlayerHp = recoverPlayerHp,
	fbRecoverAllPetHp = recoverAllPetHp,
	fbPlayerCastAbility = playerCastAbility,
	fbPetCastAbility = petCastAbility,
	fbSelectBuff = selectBuff,
	fbForceTmpPetTeam = forceTmpPetTeam,
	fbForceMorphlingPet = forceMorphlingPet,
	fbShowStage = showStage,
	fbShowChallengeSuccess = showChallengeResult,
	fbSelectBuffByArgs = selectBuffByArgs,
	fbAddBuffByArgs = addBuffByArgs,
	fbForceEnterCombat = forceEnterCombat,
	fbForceLeaveCombat = forceLeaveCombat,
	fbRogueSendSomeReward = fbRogueSendSomeReward,
	fbLevelStart = fbLevelStart,
	fbRogueAddPuppetBuff = fbRogueAddPuppetBuff,
	fbRemoveRogueBuffs = removeRogueBuffs,
	fbStartNewRogue = startNewRogue
}

function DungeonNode:ctor(nodeId, nodeData, graph)
	DungeonNode.super.ctor(self, nodeId, nodeData, graph)
end

function DungeonNode:registerPorts()
	DungeonNode.super.registerPorts(self)

	self.flowOut_Out = self:addFlowOutput("Out")
	self.valueInput_EventName = self:addValueInput("EventName")
	self.eventParams = self.nodeData.eventParams or {}
	self.preActions = self.nodeData.preActions or {}
	self.postActions = self.nodeData.postActions or {}
end

function DungeonNode:doActions(space, actions)
	if not actions then
		return
	end

	for _, actionInfo in ipairs(actions) do
		local actionName = actionInfo.eventName
		local args = actionInfo.eventParams
		local func = actionMap[actionName]

		if func then
			if LoggerManager.checkLogger(LoggerConst.DEBUG) then
				self.logger:debug("actionName: %s args: %s", actionName, inspect(args))
			end

			func(space, args)
		else
			for _, player in pairs(space.players) do
				player:doEventByData({
					actionName,
					args
				})
			end
		end
	end
end

function DungeonNode:On_In_PortCalled(context, inputPortName)
	local space = context:getSpace()

	if not space or not Utils.isSpaceDungeon(space.spaceType) then
		if LoggerManager.checkLogger(LoggerConst.WARN) then
			self.logger:warn("DungeonNode should be used in Dungeon space, curSpaceType: %s sceneId: %s", space.spaceType, space.sceneId)
		end

		return
	end

	self:doActions(space, self.preActions)

	local eventName = self:getContextValue(context, self.valueInput_EventName)

	local function listener(args)
		args = args or {}

		for k, v in pairs(self.eventParams) do
			local confValue = args[k]

			if confValue ~= v then
				return
			end
		end

		for k, v in pairs(args) do
			if self[k] then
				context:setContextValue(self[k], v)
			end
		end

		self:removeTimer(context)
		self:checkDoOnce(context)
		self:doActions(space, self.postActions)
		self.flowOut_Out:call(context)
	end

	self:addEventListen(context, eventName, listener)
end

return DungeonNode
