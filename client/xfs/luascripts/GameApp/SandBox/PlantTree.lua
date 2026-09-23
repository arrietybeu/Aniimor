-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\SandBox\\PlantTree.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local Class = require("Core.Framework.Class")
local LevelItem = require("GameApp.Sandbox.LevelItem")
local LuaTimeline = require("GameApp.Timeline.LuaTimeline")
local ClientConst = require("Const.ClientConst")
local Const = require("Common.Const.Const")
local SandboxConst = require("Common.Const.SandboxConst")
local InteractionConst = require("Common.Const.InteractionConst")
local PlantTree = Class.LightClass("PlantTree", LevelItem)

function PlantTree:ctor(sandbox, spawnInfo, syncInfo)
	PlantTree.super.ctor(self, sandbox, spawnInfo, syncInfo)

	self.slotData = self:getSlotData()

	local configData = self:getConfigData()
	local initData = configData.initData or {}

	self.shiningRadius = initData.shiningRadius or 10
	self.shiningValue = initData.shiningValue or 15
	self.shiningId = "PlantTree_" .. self.sandbox.id .. "_" .. self.id
end

function PlantTree:onSandboxReady()
	PlantTree.super.onSandboxReady(self)

	self.treeSB = self.shell.gameObject:GetComponent("TreeSB")

	self:setChildTrans()
end

function PlantTree:destroy()
	self:stopTreeGrowAnim()
	pg.me:setFogShiningValue(self.shiningId, 0)
	PlantTree.super.destroy(self)
end

function PlantTree:setTreeState(treeState)
	self:syncFieldValue({
		state = treeState
	})
end

function PlantTree:getTreeState()
	return self.syncInfo.state or 0
end

function PlantTree:getSlotData()
	return (self.spawnInfo.defaultValue or EMPTY_TABLE).slotData or {}
end

function PlantTree:createChild(slotIdx, force)
	slotIdx = slotIdx or 1
	force = force or false

	self:serverMsg("createChildByClient", slotIdx, force)
end

function PlantTree:onValueChange(key, oldValue, value, isInit)
	if key == "envObjInfo" then
		return
	end

	local growAnimLen = self:getConfigData().growAnimLen or 5

	PlantTree.super.onValueChange(self, key, oldValue, value, isInit)

	if key == "state" then
		if value == Const.TreeState.Normal and oldValue ~= value then
			if isInit then
				self:setChildTrans()
			else
				self:playTreeGrowAnim(growAnimLen)
			end
		end
	elseif key == "isShining" then
		self:refreshShining()
	end
end

function PlantTree:getSlotTransform(slotIdx)
	if not self:isValid() or IsNil(self.treeSB) then
		return nil
	end

	return self.treeSB:GetSlotAttachTransform(slotIdx - 1)
end

function PlantTree:stopTreeGrowAnim()
	if self.treeGrowTimeline then
		self.treeGrowTimeline:stop()

		self.treeGrowTimeline = nil
	end
end

function PlantTree:getChildEntity(slotIdx)
	local envObjInfo = self.syncInfo.envObjInfo
	local envInfo = envObjInfo[slotIdx] or {}
	local entId = envInfo.entId

	if entId then
		local child = pg.getEntity(entId)

		return child
	end

	return nil
end

function PlantTree:isInGrowAnim()
	if self.treeGrowTimeline then
		return not self.treeGrowTimeline.isStop
	end

	return false
end

function PlantTree:playTreeGrowAnim(duration)
	self:stopTreeGrowAnim()

	self.treeGrowTimeline = LuaTimeline.new({})

	self.treeGrowTimeline:setDuration(duration)
	self.treeGrowTimeline:createAndAddClip(0, duration, function(_, currTime)
		self:setChildTrans()
	end)
	self.treeGrowTimeline:setStopCallback(function()
		self:resetChildTrans()
	end)
	self.treeGrowTimeline:start()
end

function PlantTree:alignToSlotTransform(childEnt, slotTransform)
	if childEnt and self:isValid() and NotNil(slotTransform) then
		childEnt:forceSetPosRot(slotTransform.position, slotTransform.rotation)
		childEnt.LevelFruitFeature:setFruitScale(slotTransform.localScale.x)
	end
end

function PlantTree:setChildTrans()
	for slotIdx, slotInfo in ipairs(self.slotData) do
		local childEnt = self:getChildEntity(slotIdx)

		if childEnt and childEnt.LevelFruitFeature and childEnt.LevelFruitFeature.isInTree then
			local slotTransform = self:getSlotTransform(slotIdx)

			self:alignToSlotTransform(childEnt, slotTransform)
		end
	end
end

function PlantTree:resetChildTrans()
	for slotIdx, slotInfo in ipairs(self.slotData) do
		local childEnt = self:getChildEntity(slotIdx)

		if childEnt and childEnt.LevelFruitFeature and childEnt.LevelFruitFeature.isInTree then
			childEnt.LevelFruitFeature:setFruitScale(nil)
		end
	end
end

function PlantTree:doDrop()
	self:serverMsg("RPC_CS_doDrop")
end

function PlantTree:startShining()
	self:serverMsg("RPC_CS_startShining")
end

function PlantTree:checkCanInteract(interactUnit)
	if interactUnit.interactionType == InteractionConst.INTERACTION_TYPE_LEVEL_ITEM_COMMON_INTERACT and self.syncInfo.isShining then
		return false
	end

	return true
end

function PlantTree:onInteract(interactUnit)
	if interactUnit.interactionType == InteractionConst.INTERACTION_TYPE_LEVEL_ITEM_COMMON_INTERACT then
		self:startShining()
	end
end

function PlantTree:refreshShining()
	if self.updatePlayerShinyTimer then
		self:removeTimer(self.updatePlayerShinyTimer)

		self.updatePlayerShinyTimer = nil
	end

	if self.syncInfo.isShining then
		self.updatePlayerShinyTimer = self:addTimer(0.1, function()
			if self:checkDistanceInShingRange() then
				pg.me:setFogShiningValue(self.shiningId, self.shiningValue)
			else
				pg.me:setFogShiningValue(self.shiningId, 0)
			end
		end, true)
	else
		pg.me:setFogShiningValue(self.shiningId, 0)
	end

	if self.shell then
		local isShining = self.syncInfo.isShining

		if self.isShining ~= isShining then
			self.isShining = isShining

			if self.isShining then
				self.shell:SendEventToFlowScript("StartShining")
			else
				self.shell:SendEventToFlowScript("StopShining")
			end
		end
	end
end

function PlantTree:checkDistanceInShingRange()
	local position = self:getPosition()
	local playerPos = pg.me:getPosition()
	local yDiff = playerPos.y - position.y

	if yDiff > self.shiningRadius then
		return false
	end

	local xDiff = playerPos.x - position.x
	local zDiff = playerPos.z - position.z
	local xzDisSqrt = xDiff * xDiff + zDiff * zDiff

	if xzDisSqrt > self.shiningRadius * self.shiningRadius then
		return false
	end

	return true
end

return PlantTree
