-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\LeylineTree\\LeylineTreeModel.lua

local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local ItemConst = require("Common.Const.ItemConst")
local ClientUtils = require("Utils.ClientUtils")
local LeylineTreeData = require("Data.leylinetree_data")
local LeylineTreeLevelData = require("Data.leylinetree_level_data")
local LeylineTreePosData = require("Data.leylinetree_pos_data")
local ItemData = require("Data.item_data")
local DropData = require("Data.drop_data")
local SceneLeylineTreeTemplateData = require("Data.scene_leylineTree_template_data")
local SysConfigData = require("Data.sys_config_data")
local SceneUtils = require("Common.Utils.SceneUtils")
local LeylineTreeModel = Class.LightClass("LeylineTreeModel", UIModel)

function LeylineTreeModel:getPlayerOwnedImprintCount(leylineTreeId)
	local costItemId = pg.game.leylineTree:getCurLeylineTreeCostItemId(leylineTreeId) or ItemConst.ITEM_SPECIAL_LEYLINETREE_POINT
	local num = ClientUtils.getItemCountById(costItemId) or 0
	local icon = ItemData[costItemId].icon
	local itemId = costItemId

	return num, icon, itemId
end

function LeylineTreeModel:getMaxNeededImprintCount(leylineTreeId)
	local maxLevel = #LeylineTreeData[leylineTreeId]

	return LeylineTreeData[leylineTreeId][maxLevel].point
end

function LeylineTreeModel:getNeededImprintCount(leylineTreeId, level)
	return LeylineTreeData[leylineTreeId][level].point
end

function LeylineTreeModel:getLeylineTreeData(leylineTreeId)
	local max = self:getMaxNeededImprintCount(leylineTreeId)
	local leylineTreeInfoMapData = pg.me.leylineTreeInfoMap[leylineTreeId]
	local imprintList = leylineTreeInfoMapData.activePointList
	local imprintInjectedCount = leylineTreeInfoMapData.leylineTreePoint
	local progress = imprintInjectedCount / max > 1 and 1 or imprintInjectedCount / max
	local activePointUseCount = leylineTreeInfoMapData.activePointUseCount

	return imprintList, imprintInjectedCount, progress, activePointUseCount
end

function LeylineTreeModel:getBuffProgress(leylineTreeId)
	local ret = {}
	local maxLevel = #LeylineTreeData[leylineTreeId]
	local maxImprintNeeded = self:getMaxNeededImprintCount(leylineTreeId)
	local levelInfo = LeylineTreeData[leylineTreeId]

	for i = 1, maxLevel do
		ret[i] = {
			level = i,
			progress = levelInfo[i].point / maxImprintNeeded
		}
	end

	return ret
end

function LeylineTreeModel:getBuffDetails(leylineTreeId, buffLevel)
	local leylineTreeLevelData = LeylineTreeLevelData[leylineTreeId]

	return leylineTreeLevelData[buffLevel]
end

function LeylineTreeModel:getPointAndFragmentIndex(staticId)
	local staticInfo = LeylineTreePosData[staticId]

	if not staticInfo then
		return nil
	end

	return staticInfo
end

function LeylineTreeModel:getAreaName(leylineTreeId)
	return pg.getLocalizationText(LeylineTreeData[leylineTreeId][0].name)
end

function LeylineTreeModel:getCurBuffLevel(leylineTreeId, imprintInjectedCount)
	if imprintInjectedCount <= 0 then
		return 0
	end

	for i = 0, #LeylineTreeData[leylineTreeId] do
		if imprintInjectedCount < LeylineTreeData[leylineTreeId][i].point then
			return i - 1
		end
	end

	return #LeylineTreeData[leylineTreeId]
end

function LeylineTreeModel:isImprintNumSuitForExactlyBuffLevel(leylineTreeId, imprintInjectedCount)
	local levelInfo = LeylineTreeData[leylineTreeId]

	for level, info in pairs(levelInfo) do
		if info.point == imprintInjectedCount then
			return level
		end
	end

	return nil
end

function LeylineTreeModel:getBuffGearLevel(leylineTreeId, buffLevel)
	local buffDetail = self:getBuffDetails(leylineTreeId, buffLevel)

	if not buffDetail then
		return 0
	end

	return buffDetail.gearLevel
end

function LeylineTreeModel:getNourishRequiredPointsByLeylineTreeLevel(leylineTreeId)
	return LeylineTreeData[leylineTreeId][SysConfigData.LEYLINETREE_CREATEPLENTY_LEVEL or 4].point
end

function LeylineTreeModel:getWeatherRequiredPointsByLeylineTreeLevel(leylineTreeId)
	return LeylineTreeData[leylineTreeId][SysConfigData.LEYLINETREE_CHANGEMETEOROLOGY_LEVEL].point
end

function LeylineTreeModel:getNextLargeBuffIndex(leylineTreeId, curLevel)
	if curLevel < 0 then
		return nil
	end

	if curLevel + 1 > #LeylineTreeLevelData[leylineTreeId] then
		return nil
	end

	for i = curLevel + 1, #LeylineTreeLevelData[leylineTreeId] do
		if LeylineTreeLevelData[leylineTreeId][i].isLargeBuff == 1 then
			return i
		end
	end

	return nil
end

function LeylineTreeModel:getRewardTable(leylineTreeId, buffLevel)
	local t = {}
	local leylineTreeLevelData = LeylineTreeData[leylineTreeId]

	if not leylineTreeLevelData then
		return t
	end

	local buffData = leylineTreeLevelData[buffLevel]

	if not buffData or not buffData.levelReward then
		return t
	end

	if not DropData[buffData.levelReward] then
		return t
	end

	if not DropData[buffData.levelReward].displayReward then
		return t
	end

	for _, itemGroup in pairs(DropData[buffData.levelReward].displayReward) do
		t[#t + 1] = {
			hierarchyMode = 1,
			sortingOrder = 30001,
			id = itemGroup[1],
			num = itemGroup[2]
		}
	end

	return t
end

function LeylineTreeModel:checkSceneIdValid(leylineTreeId)
	if not leylineTreeId then
		return false
	end

	if not pg.me or not pg.me.space or not pg.me.space.sceneId then
		return false
	end

	local treeData = SceneLeylineTreeTemplateData[leylineTreeId]

	if not treeData or not treeData.sceneId then
		return false
	end

	local currentMainSceneId = SceneUtils.getMainSceneId(pg.me.space.sceneId)

	return treeData.sceneId == currentMainSceneId
end

return LeylineTreeModel
