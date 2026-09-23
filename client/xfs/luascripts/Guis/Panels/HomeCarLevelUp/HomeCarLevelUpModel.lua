-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeCarLevelUp\\HomeCarLevelUpModel.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("HomeCarLevelUpModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local HomeCarLevelUpModel = Class.LightClass("HomeCarLevelUpModel", UIModel)
local OpDef = require("Common.OpDef")
local NoticeDef = require("Common.NoticeDef")
local ClientUtils = require("Utils.ClientUtils")
local Utils = require("Common.Utils.Utils")
local RedDotConst = require("Const.RedDotConst")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local ItemUtils = require("Common.Utils.ItemUtils")
local HomeCarUpgradeData = require("Data.home_car_upgrade_data")
local HomeCarComponentUpgradeData = require("Data.home_car_component_upgrade_data")
local HomeCarComponentData = require("Data.home_car_component_data")

HomeCarLevelUpModel.UpgradeMode = {
	LackCondition = 4,
	CanNotUpgraded = 3,
	IsUpgraded = 2,
	Normal = 1,
	Upgrading = 7,
	LackCoin = 6,
	LackItem = 5
}

function HomeCarLevelUpModel:upgradeHomeCar(callback)
	pg.me:requestHomeCampOp(OpDef.OP.CS_HC_UpgradeCar, {}, function(noticeId, noticeArg)
		if noticeId == NoticeDef.SUCCESS then
			callback()
		else
			ClientUtils.showBubbleMessageById(noticeId, Utils.safeUnpack(noticeArg))
		end
	end)
end

function HomeCarLevelUpModel:getHomeCarLevelReward(level, callback)
	if not level then
		return
	end

	pg.me:requestHomeCampOp(OpDef.OP.CS_HC_UpgradeReward, {
		level = level
	}, function(noticeId, noticeArg)
		if noticeId == NoticeDef.SUCCESS then
			callback(noticeArg)
		else
			ClientUtils.showBubbleMessageById(noticeId, Utils.safeUnpack(noticeArg))
		end
	end)
end

function HomeCarLevelUpModel:canGetHomeCarLevelReward()
	local canGet = false
	local homeCarInfo = HomeLandUtils.getHomeCarInfo()
	local homeCarLevel = homeCarInfo.level
	local rewardsReceived = pg.me.homeUpgradeRewardsReceived or {}

	for i = 1, homeCarLevel do
		if rewardsReceived[i] ~= true then
			canGet = true

			break
		end
	end

	return canGet
end

function HomeCarLevelUpModel:getCanUpgradeMode(data, curLevel, levelId)
	levelId = levelId or data.levelId

	if levelId <= curLevel then
		return HomeCarLevelUpModel.UpgradeMode.IsUpgraded
	elseif levelId - curLevel > 1 then
		return HomeCarLevelUpModel.UpgradeMode.CanNotUpgraded
	end

	local homeCarInfo = HomeLandUtils.getHomeCarInfo()

	if homeCarInfo.upgradeEndTs > 0 then
		return HomeCarLevelUpModel.UpgradeMode.Upgrading
	end

	local canUpgrade = HomeLandUtils.getHomeCarCanUpgrade(data, pg.me.triggerMap)

	if not canUpgrade then
		return HomeCarLevelUpModel.UpgradeMode.LackCondition
	end

	local space = pg.me.space

	for _, info in ipairs(data.unlockItem or EMPTY_TABLE) do
		local itemCount = ItemUtils.getItemCountById(pg.me, info[1])

		if space and space:isHomeland() and space:isSelfHomeland(pg.me) then
			itemCount = itemCount + ClientUtils.getHomelandItemCountById(info[1])
		end

		if itemCount < info[2] then
			return HomeCarLevelUpModel.UpgradeMode.LackItem
		end
	end

	if data.unlockCost then
		local itemCount = ItemUtils.getItemCountById(pg.me, data.unlockCost[1])

		if itemCount < data.unlockCost[2] then
			return HomeCarLevelUpModel.UpgradeMode.LackCoin
		end
	end

	return HomeCarLevelUpModel.UpgradeMode.Normal
end

function HomeCarLevelUpModel:canUpgradeHomeCar()
	if not pg.me.isHomeCampUnlocked then
		return false
	end

	local currentLevel = HomeLandUtils.getHomeCarInfo().level
	local nextLevel = currentLevel + 1
	local nextLevelData = HomeCarUpgradeData[nextLevel]

	if not nextLevelData then
		return false
	end

	local upgradeMode = self:getCanUpgradeMode(nextLevelData, currentLevel, nextLevel)

	return upgradeMode == HomeCarLevelUpModel.UpgradeMode.Normal
end

function HomeCarLevelUpModel:redDot_GetLevelRewardState()
	if pg.me.isHomeCampUnlocked and self:canGetHomeCarLevelReward() then
		return RedDotConst.RedDotStyle.REWARD
	end

	return RedDotConst.RedDotStyle.NONE
end

function HomeCarLevelUpModel:redDot_GetUpgradeState()
	if self:canUpgradeHomeCar() then
		return RedDotConst.RedDotStyle.UP_HIGH
	end

	local rewardState = self:redDot_GetLevelRewardState()

	return rewardState
end

return HomeCarLevelUpModel
