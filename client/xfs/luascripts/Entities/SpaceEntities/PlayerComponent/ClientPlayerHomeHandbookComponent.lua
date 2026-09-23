-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Entities\\SpaceEntities\\PlayerComponent\\ClientPlayerHomeHandbookComponent.lua

local class = require("Core.Framework.Class")
local NoticeDef = require("Common.NoticeDef")
local MessageName = require("Const.MessageName")
local HomeBookRedDotUtils = require("Utils.HomeBookRedDotUtils")
local HomeHandbookProductData = require("Data.home_handbook_product_data")
local HomeBookDataUtils = require("Utils.HomeBookDataUtils")
local ClientPlayerHomeHandbookComponent = class.Component("ClientPlayerHomeHandbookComponent")

local function notifyHomeBookDataChanged(categoryId, itemId)
	HomeBookRedDotUtils.refreshTree(categoryId)
	facade:sendMsgToUI(MessageName.ON_HOME_BOOK_DATA_CHANGED, {
		itemId = itemId
	})
end

function ClientPlayerHomeHandbookComponent:onHomeHandbookItem_added(itemId, itemInfo)
	if HomeHandbookProductData[itemId] then
		self.pendingCropFirstUnlockMap = self.pendingCropFirstUnlockMap or {}
		self.pendingCropFirstUnlockMap[itemId] = true
	end

	HomeBookRedDotUtils.recordNewUnlock(itemId)

	local entry = HomeBookDataUtils.getEntity(itemId)

	notifyHomeBookDataChanged(entry and entry.firstType, itemId)

	if pg.me.isHomelandCreate and pg.global.ui and pg.global.ui.tips then
		pg.global.ui.tips:showHomeBookUnlockTip(itemId)
	end
end

function ClientPlayerHomeHandbookComponent:onHomeHandbookItem_deleted(itemId, itemInfo)
	return
end

function ClientPlayerHomeHandbookComponent:onHomeHandbookItem_changed(ov, nv, itemId)
	return
end

function ClientPlayerHomeHandbookComponent:onHomeHandbookItemCount_changed(ov, nv, itemId)
	if nv <= ov then
		return
	end

	HomeBookRedDotUtils.recordComposeProgress(itemId, ov, nv)
	HomeBookRedDotUtils.refreshTree()
	facade:sendMsgToUI(MessageName.ON_HOME_BOOK_ITEM_COUNT_CHANGED, {
		itemId = itemId
	})
end

function ClientPlayerHomeHandbookComponent:onHomeHandbookScore_changed(ov, nv)
	notifyHomeBookDataChanged()
end

function ClientPlayerHomeHandbookComponent:onHomeHandbookCategoryCount_changed(ov, nv, categoryId)
	if categoryId ~= nil and not HomeBookDataUtils.getFirstType(categoryId) then
		return
	end

	notifyHomeBookDataChanged(categoryId)
end

function ClientPlayerHomeHandbookComponent:onHomeHandbookCategoryCount_added(categoryId, count)
	if categoryId ~= nil and not HomeBookDataUtils.getFirstType(categoryId) then
		return
	end

	notifyHomeBookDataChanged(categoryId)
end

function ClientPlayerHomeHandbookComponent:onHomeHandbookSeasonCount_changed(ov, nv, seasonId)
	notifyHomeBookDataChanged()
end

function ClientPlayerHomeHandbookComponent:onHomeHandbookSeasonCount_added(seasonId, count)
	notifyHomeBookDataChanged()
end

function ClientPlayerHomeHandbookComponent:onHomeHandbookReceivedCategoryReward_changed(ov, nv, categoryId)
	notifyHomeBookDataChanged(categoryId)
end

function ClientPlayerHomeHandbookComponent:onHomeHandbookReceivedCategoryReward_added(categoryId, count)
	notifyHomeBookDataChanged(categoryId)
end

function ClientPlayerHomeHandbookComponent:onHomeHandbookLastReceivedGrade_changed(ov, nv)
	notifyHomeBookDataChanged()
end

function ClientPlayerHomeHandbookComponent:onHomeHandbookLastViewedGrade_changed(ov, nv)
	notifyHomeBookDataChanged()
end

function ClientPlayerHomeHandbookComponent:getHomeHandbookItemInfo(itemId)
	return self.homeHandbookMap and self.homeHandbookMap[itemId]
end

function ClientPlayerHomeHandbookComponent:isHomeHandbookItemCollected(itemId)
	return self:getHomeHandbookItemInfo(itemId) ~= nil
end

function ClientPlayerHomeHandbookComponent:consumeHomeBookCropFirstUnlock(itemId)
	if not self.pendingCropFirstUnlockMap or not self.pendingCropFirstUnlockMap[itemId] then
		return false
	end

	self.pendingCropFirstUnlockMap[itemId] = nil

	return true
end

function ClientPlayerHomeHandbookComponent:getHomeHandbookScore()
	return self.homeHandbookMap and self.homeHandbookMap.homeHandbookScore or 0
end

function ClientPlayerHomeHandbookComponent:getHomeHandbookCategoryCount(categoryId)
	local countMap = self.homeHandbookMap and self.homeHandbookMap.homeHandbookCategoryCount

	return countMap and countMap[categoryId] or 0
end

function ClientPlayerHomeHandbookComponent:getHomeHandbookSeasonCount(seasonId)
	local countMap = self.homeHandbookMap and self.homeHandbookMap.homeHandbookSeasonCount

	return countMap and countMap[seasonId] or 0
end

function ClientPlayerHomeHandbookComponent:getHomeHandbookReceivedCategoryCount(categoryId)
	return self.receivedCategoryRewards and self.receivedCategoryRewards[categoryId] or 0
end

function ClientPlayerHomeHandbookComponent:getHomeHandbookLastReceivedGrade()
	return self.lastReceivedGrade or 0
end

function ClientPlayerHomeHandbookComponent:getHomeHandbookLastViewedGrade()
	return self.lastViewedGrade or 0
end

local function handleResponse(result, callback)
	if result ~= NoticeDef.SUCCESS then
		pg.global.showBubbleMessage(result)
	end

	if callback then
		callback(result)
	end
end

function ClientPlayerHomeHandbookComponent:reqReceiveHandbookGradeReward(callback)
	self:serverMsg("RPC_CS_ReceiveHandbookGradeReward", function(result)
		handleResponse(result, callback)
	end)
end

function ClientPlayerHomeHandbookComponent:reqRecordHomeHandbookViewedGrade(callback)
	self:serverMsg("RPC_CS_RecordHandbookViewedGrade", function(result)
		handleResponse(result, callback)
	end)
end

function ClientPlayerHomeHandbookComponent:reqReceiveCategoryProgressReward(categoryId, callback)
	self:serverMsg("RPC_CS_ReceiveCategoryProgressReward", categoryId, function(result)
		handleResponse(result, callback)
	end)
end

return ClientPlayerHomeHandbookComponent
