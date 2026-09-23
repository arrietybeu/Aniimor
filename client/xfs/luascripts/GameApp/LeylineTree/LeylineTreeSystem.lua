-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\GameApp\\LeylineTree\\LeylineTreeSystem.lua

local Class = require("Core.Framework.Class")
local SystemBase = require("GameApp.Core.SystemBase")
local MessageName = require("Const.MessageName")
local Const = require("Common.Const.Const")
local ClientActivityUtils = require("Utils.ClientActivityUtils")
local MapAreaConfigData = require("Data.map_area_config_data")
local MapBlockConfigData = require("Data.map_block_config_data")
local LeylineTreeLevelData = require("Data.leylinetree_level_data")
local LeylineTreeData = require("Data.leylinetree_data")
local LeylineFlowerConst = require("Const.LeylineFlowerConst")
local SysConfigData = require("Data.sys_config_data")
local MapHelper = require("GameApp.Map.MapHelper")
local ClientUtils = require("Utils.ClientUtils")
local Time = require("Core.Common.Time")
local LeylineFlowerStatusData = require("Data.leylineflower_status_data")
local LeylineFlowerTributeData = require("Data.leylineflower_tribute_data")
local PlentyHappenEffectData = require("Data.plenty_happen_effect_data")
local LeylineTreeSystemEntityPoolHelper = require("GameApp.LeylineTree.Helper.LeylineTreeSystemEntityPoolHelper")
local LeylineTreeSystem = Class.LightClass("LeylineTreeSystem", SystemBase)

LeylineTreeSystem.FLOWER_INST_STATE = {
	ShowRing = 1,
	ShowPillar = 2
}

function LeylineTreeSystem:onCtor()
	SystemBase.onCtor(self)

	self.poolHelper = LeylineTreeSystemEntityPoolHelper.new()

	self.poolHelper:initPool()
end

function LeylineTreeSystem:onDestroy()
	self.poolHelper:destroyPool()

	self.poolHelper = nil
end

function LeylineTreeSystem:refreshRings()
	self.poolHelper:recycleAll()

	local leylineFlowerInfoMap = pg.me:getSpaceOwnerSceneLeylineFlowerInfoMap() or pg.me.leylineFlowerInfoMap:getRawTable()

	for flowerId, v in pairs(leylineFlowerInfoMap) do
		if v.plentyTableId and v.flowerState and (v.flowerState == LeylineFlowerConst.FLOWER_STATE.Budding or v.flowerState == LeylineFlowerConst.FLOWER_STATE.Blooming) then
			self.poolHelper:createFromPool(flowerId, Const.MAP_MARK_LeylineTree_Create, function(info)
				local markPoint = pg.game.map.sceneMarkPointData[flowerId]

				if not markPoint then
					return
				end

				local leylineFlowerInst = info.gameObject:GetComponent("LeylineTreeRing")

				if not leylineFlowerInst then
					return
				end

				local plentyInfo = MapHelper.getLeylineFlowerPlentyInfo(flowerId, v.plentyTableId)

				if not plentyInfo then
					return
				end

				info.gameObject.transform.position = markPoint.markPosition

				local val = plentyInfo.radius * 2 < SysConfigData.SCENE_PLENTY_MIN_RANGE and SysConfigData.SCENE_PLENTY_MIN_RANGE or plentyInfo.radius * 2
				local state

				if v.flowerState == LeylineFlowerConst.FLOWER_STATE.Budding then
					state = LeylineTreeSystem.FLOWER_INST_STATE.ShowPillar
				else
					state = LeylineTreeSystem.FLOWER_INST_STATE.ShowRing
				end

				leylineFlowerInst:BindEnterEvent(function()
					self:flowerCountDown(flowerId, true)
				end)
				leylineFlowerInst:BindExitEvent(function()
					self:flowerCountDown(flowerId, false)
				end)
				leylineFlowerInst:InitArea(plentyInfo.radius)
				leylineFlowerInst:SetState(state, val)

				local tributeValue = v.bloomQuality

				self:createRing(leylineFlowerInst, tributeValue)
				self:refreshFlowerPillarEffect(flowerId, v.flowerState, tributeValue)
			end)
		end
	end

	self:createEcoTraceSearch()
end

function LeylineTreeSystem:claTributeItems(infoMap)
	local nourishCostItems = infoMap.nourishCostItems or {}
	local pendingNourishCostItems = infoMap.pendingNourishCostItems or {}
	local curItems = nourishCostItems

	if not next(curItems) then
		curItems = pendingNourishCostItems
	end

	if not next(curItems) then
		return 0
	end

	local totalValue = 0

	for itemId, itemCount in pairs(curItems) do
		local curValue = 0

		if LeylineFlowerTributeData[itemId] and LeylineFlowerTributeData[itemId].value then
			curValue = LeylineFlowerTributeData[itemId].value
		end

		totalValue = totalValue + curValue * itemCount
	end

	return totalValue
end

function LeylineTreeSystem:createRing(leylineFlowerInst, tributeValue)
	if not tributeValue or tributeValue <= 0 then
		tributeValue = 1
	end

	local effectData = PlentyHappenEffectData[tributeValue] or {}
	local ringResId = effectData.resId1 or ""

	leylineFlowerInst:CreateLeylineAsset(ringResId, LeylineTreeSystem.FLOWER_INST_STATE.ShowRing)
end

function LeylineTreeSystem:refreshFlowerPillarEffect(flowerId, flowerState, bloomQuality)
	local space = pg.me and pg.me.space
	local flowerEntity = space and space:getEntityByStaticId(flowerId)

	if not flowerEntity or not flowerEntity.refreshPlentyPillarEffect then
		return
	end

	flowerEntity:refreshPlentyPillarEffect(flowerState, bloomQuality)
end

function LeylineTreeSystem:flowerCountDown(leylineFlowerId, enable)
	if enable then
		local leylineFlowerInfoMap = pg.me:getSpaceOwnerSceneLeylineFlowerInfoMap() or pg.me.leylineFlowerInfoMap:getRawTable()
		local info = leylineFlowerInfoMap and leylineFlowerInfoMap[leylineFlowerId]

		if info and next(info) and info.flowerState == LeylineFlowerConst.FLOWER_STATE.Blooming and info.stateStartTime then
			local defaultValue = 120
			local duringTime = LeylineFlowerStatusData[info.flowerState] and (LeylineFlowerStatusData[info.flowerState].stateTime or defaultValue) or defaultValue
			local entTime = info.stateStartTime + duringTime
			local remainTime = entTime - Time.secondCache

			if remainTime > 0 then
				ClientUtils.showUICountDownWithId(remainTime, leylineFlowerId, true)
			end
		end
	else
		ClientUtils.hideUICountDownWithId(leylineFlowerId)
	end
end

function LeylineTreeSystem:getMessageBindMap()
	return {
		[MessageName.LEYLINEFLOWER_FLOWER_STATE_CHANGED] = "onLeylineFlowerStateChanged",
		[MessageName.LEYLINEFLOWER_RAINBOW_STAGE_CHANGED] = "onLeylineFlowerRainbowStageChanged",
		[MessageName.EVENT_ECO_TRACE_SEARCH_CHANGE] = "createEcoTraceSearch"
	}
end

function LeylineTreeSystem:onLeylineFlowerRainbowStageChanged(info)
	if not info or not info.leylineFlowerId or not info.rainbowStage then
		return
	end

	local space = pg.me and pg.me.space
	local flowerEntity = space and space:getEntityByStaticId(info.leylineFlowerId)

	if flowerEntity and flowerEntity.refreshRainbowStageAppearance then
		flowerEntity:refreshRainbowStageAppearance(info.rainbowStage)
	end
end

function LeylineTreeSystem:onLeylineFlowerStateChanged(info)
	if not info.leylineFlowerId then
		return
	end

	local flowerInfo = pg.me:getCurFlowerInfo(info.leylineFlowerId) or {}
	local plentyInfo = MapHelper.getLeylineFlowerPlentyInfo(info.leylineFlowerId, pg.me:getCurFlowerCreateId(info.leylineFlowerId))

	if not plentyInfo then
		self:refreshFlowerPillarEffect(info.leylineFlowerId, nil, flowerInfo.bloomQuality)
		self.poolHelper:recycleToPool(info.leylineFlowerId)

		return
	end

	self:refreshFlowerPillarEffect(info.leylineFlowerId, info.newValue, flowerInfo.bloomQuality)

	if info.newValue == LeylineFlowerConst.FLOWER_STATE.Budding or info.newValue == LeylineFlowerConst.FLOWER_STATE.Blooming then
		self.poolHelper:createFromPool(info.leylineFlowerId, Const.MAP_MARK_LeylineTree_Create, function(info1)
			local markPoint = pg.game.map.sceneMarkPointData[info.leylineFlowerId]

			if not markPoint then
				return
			end

			local leylineFlowerInst = info1.gameObject:GetComponent("LeylineTreeRing")

			if not leylineFlowerInst then
				return
			end

			info1.gameObject.transform.position = markPoint.markPosition

			local val = plentyInfo.radius * 2 < SysConfigData.SCENE_PLENTY_MIN_RANGE and SysConfigData.SCENE_PLENTY_MIN_RANGE or plentyInfo.radius * 2
			local state

			if info.newValue == LeylineFlowerConst.FLOWER_STATE.Budding then
				state = LeylineTreeSystem.FLOWER_INST_STATE.ShowPillar
			else
				state = LeylineTreeSystem.FLOWER_INST_STATE.ShowRing
			end

			leylineFlowerInst:BindEnterEvent(function()
				self:flowerCountDown(info.leylineFlowerId, true)
			end)
			leylineFlowerInst:BindExitEvent(function()
				self:flowerCountDown(info.leylineFlowerId, false)
			end)
			leylineFlowerInst:InitArea(plentyInfo.radius)
			leylineFlowerInst:SetState(state, val)

			local tributeValue = flowerInfo.bloomQuality

			self:createRing(leylineFlowerInst, tributeValue)
		end)
	else
		self.poolHelper:recycleToPool(info.leylineFlowerId)
		self:flowerCountDown(info.leylineFlowerId, false)
	end
end

function LeylineTreeSystem:createEcoTraceSearch()
	local activityData = ClientActivityUtils.getEcoTraceActivityData()
	local ecoTraceSearchMarkId = activityData and activityData.ecoTraceSearchMarkId or 0

	if ecoTraceSearchMarkId == 0 then
		if self.ecoTraceSearchMarkId then
			pg.global.ui.tips:showTextTip(pg.getGameString("ECOLOGICAL_SEARCH_END_TIP"))
			self:onEcoTraceSearchEnd()
		end

		return
	end

	if not pg.game.map.sceneMarkPointData or not pg.game.map.sceneMarkPointData[ecoTraceSearchMarkId] then
		return
	end

	local radius = ClientActivityUtils.getEcoTraceMarkRadius()

	self.ecoTraceSearchMarkId = ecoTraceSearchMarkId

	self.poolHelper:createFromPool(ecoTraceSearchMarkId, Const.MAP_MARK_EcoTrace_Search, function(info)
		info.gameObject.transform.position = pg.game.map.sceneMarkPointData[ecoTraceSearchMarkId].markPosition

		local coe = 2
		local val = radius * coe
		local defaultScale = info.gameObject.transform.localScale

		info.gameObject.transform.localScale = Vector3.New(val, defaultScale.y, val)
	end)
end

function LeylineTreeSystem:onEcoTraceSearchEnd()
	if self.ecoTraceSearchMarkId then
		self.poolHelper:recycleToPool(self.ecoTraceSearchMarkId)

		self.ecoTraceSearchMarkId = nil
	end
end

function LeylineTreeSystem:getLeylineTreeBuffRewardState(treeId, level)
	if not LeylineTreeLevelData[treeId] or LeylineTreeLevelData[treeId][level].isLargeBuff ~= 1 then
		return false
	end

	local leylineTreeInfo = pg.me.leylineTreeInfoMap[treeId]

	if not leylineTreeInfo then
		return false
	end

	local levelRewardStatusMap = leylineTreeInfo.levelRewardStatus

	if not levelRewardStatusMap then
		return false
	end

	local status = levelRewardStatusMap[level]

	if not status then
		return false
	end

	return status == Const.REWARD_STATUS_CANREWARD
end

function LeylineTreeSystem:getLeylineTreeTotalRewardState()
	local largeBlockId = pg.game.map:getCurLargeBlockId()
	local configData = MapAreaConfigData[largeBlockId]

	if not largeBlockId or not configData then
		return false
	end

	local leylineTreeLevelData = LeylineTreeLevelData[configData.treeId]

	for level, v in ipairs(leylineTreeLevelData) do
		if self:getLeylineTreeBuffRewardState(configData.treeId, level) then
			return true
		end
	end

	return false
end

function LeylineTreeSystem:getCurLeylineTreeId()
	local curLargeBlockId = pg.game.map:getCurLargeBlockId()

	if not curLargeBlockId then
		return nil
	end

	if not MapAreaConfigData[curLargeBlockId] then
		return nil
	end

	return MapAreaConfigData[curLargeBlockId].treeId
end

function LeylineTreeSystem:getCurLeylineTreeCostItemId(leylineTreeId)
	if not leylineTreeId then
		return
	end

	local leylineTreeLevelData = LeylineTreeData[leylineTreeId]

	if not leylineTreeLevelData then
		return
	end

	if not leylineTreeLevelData[1] then
		return
	end

	return leylineTreeLevelData[1].stoneId
end

function LeylineTreeSystem:checkLeylineTreeUnlockedBySmallAreaId(smallAreaId)
	if not smallAreaId then
		return false
	end

	if not MapBlockConfigData[smallAreaId] then
		return false
	end

	local largeBlockId = MapBlockConfigData[smallAreaId].mapAreaId

	if not largeBlockId then
		return false
	end

	return MapHelper.checkBlockLeylineTreeUnlocked(largeBlockId, pg.me.leylineTreeInfoMap)
end

return LeylineTreeSystem
