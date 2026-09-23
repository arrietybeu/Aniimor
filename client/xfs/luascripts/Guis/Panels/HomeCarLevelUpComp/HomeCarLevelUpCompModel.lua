-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeCarLevelUpComp\\HomeCarLevelUpCompModel.lua

local EMPTY_TABLE = require("Core.Common.EmptyTable")
local logger = require("Core.Log.LoggerManager").getLogger("HomeCarLevelUpCompModel")
local Class = require("Core.Framework.Class")
local UIModel = require("Guis.UIModel")
local HomeCarLevelUpCompModel = Class.LightClass("HomeCarLevelUpCompModel", UIModel)
local OpDef = require("Common.OpDef")
local NoticeDef = require("Common.NoticeDef")
local ClientUtils = require("Utils.ClientUtils")
local Utils = require("Common.Utils.Utils")
local RedDotConst = require("Const.RedDotConst")
local HomeLandUtils = require("Common.Utils.HomeLandUtils")
local ItemUtils = require("Common.Utils.ItemUtils")
local HomeCarComponentUpgradeData = require("Data.home_car_component_upgrade_data")
local HomeCarComponentData = require("Data.home_car_component_data")

HomeCarLevelUpCompModel.UpgradeMode = {
	LackCoin = 6,
	LackItem = 5,
	LackCondition = 4,
	CanNotUpgraded = 3,
	IsUpgraded = 2,
	Normal = 1
}

function HomeCarLevelUpCompModel:getHomeCarComponentMaxLevel(tabId)
	local compIdUpgradeInfo = HomeCarComponentUpgradeData[tabId] or {}

	return #compIdUpgradeInfo
end

function HomeCarLevelUpCompModel:getCanUpgradeMode(data, curLevel, levelId)
	if levelId <= curLevel then
		return self.UpgradeMode.IsUpgraded
	elseif levelId - curLevel > 1 then
		return self.UpgradeMode.CanNotUpgraded
	end

	local canUpgrade = HomeLandUtils.getHomeCarCanUpgrade(data, pg.me.triggerMap)

	if not canUpgrade then
		return self.UpgradeMode.LackCondition
	end

	local space = pg.me.space

	for _, info in ipairs(data.unlockItem or EMPTY_TABLE) do
		local itemCount = ItemUtils.getItemCountById(pg.me, info[1])

		if space and space:isHomeland() and space:isSelfHomeland(pg.me) then
			itemCount = itemCount + ClientUtils.getHomelandItemCountById(info[1])
		end

		if itemCount < info[2] then
			return self.UpgradeMode.LackItem
		end
	end

	if data.unlockCost then
		local itemCount = ItemUtils.getItemCountById(pg.me, data.unlockCost[1])

		if itemCount < data.unlockCost[2] then
			return self.UpgradeMode.LackCoin
		end
	end

	return self.UpgradeMode.Normal
end

function HomeCarLevelUpCompModel:redDot_GetComponentUpgradeState(compId, homeCarInfo)
	if not pg.me.isHomeCampUnlocked then
		return RedDotConst.RedDotStyle.NONE
	end

	homeCarInfo = homeCarInfo or HomeLandUtils.getHomeCarInfo()

	local componentInfo = HomeCarComponentData[compId]

	if not componentInfo or componentInfo.homeLevel > homeCarInfo.level then
		return RedDotConst.RedDotStyle.NONE
	end

	local curLevel = homeCarInfo.carCompsLevel[compId] or 0
	local levelId = curLevel + 1
	local upgradeData = HomeCarComponentUpgradeData[compId]
	local nextLevelData = upgradeData and upgradeData[levelId]

	if not nextLevelData then
		return RedDotConst.RedDotStyle.NONE
	end

	local upgradeMode = self:getCanUpgradeMode(nextLevelData, curLevel, levelId)

	if upgradeMode ~= self.UpgradeMode.Normal then
		return RedDotConst.RedDotStyle.NONE
	end

	return curLevel > 0 and RedDotConst.RedDotStyle.UP_HIGH or RedDotConst.RedDotStyle.NEW
end

function HomeCarLevelUpCompModel:redDot_GetUpgradeState()
	if not pg.me.isHomeCampUnlocked then
		return RedDotConst.RedDotStyle.NONE
	end

	local homeCarInfo = HomeLandUtils.getHomeCarInfo()

	for compId in pairs(HomeCarComponentData) do
		local redDotStyle = self:redDot_GetComponentUpgradeState(compId, homeCarInfo)

		if redDotStyle ~= RedDotConst.RedDotStyle.NONE then
			return RedDotConst.RedDotStyle.UP_HIGH
		end
	end

	return RedDotConst.RedDotStyle.NONE
end

function HomeCarLevelUpCompModel:upgradeHomeCarComp(compId, callback)
	if not compId then
		return
	end

	pg.me:requestHomeCampOp(OpDef.OP.CS_HC_UpgradeCarComp, {
		compId = compId
	}, function(noticeId, noticeArg)
		if noticeId == NoticeDef.SUCCESS then
			callback()
		else
			ClientUtils.showBubbleMessageById(noticeId, Utils.safeUnpack(noticeArg))
		end
	end)
end

return HomeCarLevelUpCompModel
