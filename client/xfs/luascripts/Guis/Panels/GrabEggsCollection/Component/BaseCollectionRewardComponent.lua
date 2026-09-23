-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\GrabEggsCollection\\Component\\BaseCollectionRewardComponent.lua

local Class = require("Core.Framework.Class")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TimerManager = require("Core.Timer.TimerManager")
local Const = require("Const.Const")
local RedDotConst = require("Const.RedDotConst")
local RobEggBookGroupData = require("Data.egg_book_group_data")
local RobEggBookRewardData = require("Data.egg_book_reward_data")
local BaseCollectionRewardComponent = Class.LightClass("BaseCollectionRewardComponent")
local BASE_CASE_ID = 1001

function BaseCollectionRewardComponent:ctor(rootTransform, ctrl, model)
	self.rootTransform = rootTransform
	self.ctrl = ctrl
	self.model = model
	self.maxRewardLevel = 0
end

function BaseCollectionRewardComponent:init()
	self:findObjects()
	self:addListener()
end

function BaseCollectionRewardComponent:findObjects()
	local objectReference = self.rootTransform:GetComponent("ObjectReference")

	self.rewardPanel = objectReference:GetRefValue("rewardPanel")
	self.rewardBar = objectReference:GetRefValue("rewardBar")

	if self.rewardPanel then
		local rewardPanelRef = self.rewardPanel:GetComponent("ObjectReference")

		self.collectionTxt = rewardPanelRef:GetRefValue("collectionTxt")

		ClientTextUtils.setText(self.collectionTxt, pg.getGameString("GRAB_EGG_Collection_Point"))

		self.totalProgressText = rewardPanelRef:GetRefValue("totalProgressText")
		self.rewardList = rewardPanelRef:GetRefValue("rewardList")
		self.finalRewardItem = rewardPanelRef:GetRefValue("finalRewardItem")
	end
end

function BaseCollectionRewardComponent:addListener()
	if self.rewardList then
		function self.rewardList.luaRenderItem(item, index, data)
			self:renderRewardItem(item, index, data)
		end
	end
end

function BaseCollectionRewardComponent:renderRewardItem(item, index, data)
	local objectReference = item:GetComponent("ObjectReference")

	if not objectReference then
		return
	end

	local rewardItem = objectReference:GetRefValue("rewardItem")
	local progressText = objectReference:GetRefValue("progressText")
	local circleSlider = objectReference:GetRefValue("sliderUSlider")

	if rewardItem and data.rewards and #data.rewards > 0 then
		LuaUIUtils.renderRewards(rewardItem, 1, data.rewards[1])

		local rewardStatus = data.rewardStatus or 0

		if rewardStatus == Const.REWARD_STATUS_CANREWARD then
			function rewardItem.luaClick()
				self:tryGetReward(data.level)
			end
		else
			function rewardItem.luaClick()
				LuaUIUtils.onRewardItemClick(rewardItem, data.rewards[1])
			end
		end
	end

	local needPoint = data.needPoint or 0
	local levelProgress = data.levelProgress or 0
	local levelNeed = data.levelNeed or 0

	if progressText then
		ClientTextUtils.setText(progressText, needPoint)
	end

	if circleSlider then
		circleSlider.maxValue = levelNeed
		circleSlider.value = levelProgress
	end

	local rewardStatus = data.rewardStatus or 0

	self:refreshRewardItemStatus(item, rewardStatus)
	self:refreshRewardItemRedDot(item, data.level, rewardStatus)
end

function BaseCollectionRewardComponent:refreshRewardDisplay()
	local rewardConfig = self:getRewardConfig()
	local progressData = self:getProgressData()

	if not rewardConfig or not progressData then
		return
	end

	self.maxRewardLevel = #rewardConfig

	local rewardListData = {}

	for level = 1, self.maxRewardLevel - 1 do
		local rewardInfo = rewardConfig[level]

		if rewardInfo then
			local itemData = self:buildRewardItemData(level, rewardInfo, progressData, rewardConfig)

			table.insert(rewardListData, itemData)
		end
	end

	if self.rewardList then
		self.rewardList:SetList(rewardListData)
	end

	if self.maxRewardLevel > 0 then
		self:setFinalRewardItem(rewardConfig[self.maxRewardLevel], progressData)
	end

	self:refreshProgressText()
end

function BaseCollectionRewardComponent:buildRewardItemData(level, rewardInfo, progressData, rewardConfig)
	local needPoint = rewardInfo.nodePoint or 0
	local currentPoint = progressData.currentPoint or 0
	local currentLevel = progressData.level or 0
	local prePoint = level > 1 and (rewardConfig[level - 1].nodePoint or 0) or 0
	local levelProgress = math.max(0, currentPoint - prePoint)
	local levelNeed = needPoint - prePoint
	local itemData = {
		level = level,
		needPoint = needPoint,
		currentPoint = currentPoint,
		isCurrentLevel = currentLevel + 1 == level,
		levelProgress = levelProgress,
		levelNeed = levelNeed,
		rewardStatus = self:getRewardStatus(level, progressData)
	}

	if rewardInfo.reward then
		itemData.rewards = LuaUIUtils.getRewardItemByDropId(rewardInfo.reward, itemData.rewardStatus == Const.REWARD_STATUS_DONE, itemData.rewardStatus == Const.REWARD_STATUS_CANREWARD)
	else
		itemData.rewards = {}
	end

	return itemData
end

function BaseCollectionRewardComponent:refreshRewardItemStatus(itemView, status)
	if status == Const.REWARD_STATUS_CANREWARD then
		itemView:TryChangePage("State", 2)
	elseif status == Const.REWARD_STATUS_DONE then
		itemView:TryChangePage("State", 1)
	else
		itemView:TryChangePage("State", 0)
	end
end

function BaseCollectionRewardComponent:refreshRewardItemRedDot(itemView, level, status)
	local showRedDot = status == Const.REWARD_STATUS_CANREWARD

	self:setRewardItemRedDot(itemView, level, showRedDot)
end

function BaseCollectionRewardComponent:setRewardItemRedDot(itemView, level, show)
	local redDotPathTemplate = self:getRewardRedDotPath()

	if redDotPathTemplate and itemView then
		local fullPath = string.format(redDotPathTemplate, level)
		local style = show and RedDotConst.RedDotStyle.REWARD or RedDotConst.RedDotStyle.NONE

		pg.global.setRedDot(fullPath, itemView, show, style)
	end
end

function BaseCollectionRewardComponent:getRewardRedDotPath()
	return RedDotConst.RedDotPath.GRAB_EGG_COLLECTION_BASE_REWARD
end

function BaseCollectionRewardComponent:setFinalRewardItem(rewardInfo, progressData)
	if not self.finalRewardItem or not rewardInfo then
		return
	end

	local itemView = self.finalRewardItem
	local level = self.maxRewardLevel
	local objectReference = itemView:GetComponent("ObjectReference")
	local rewardItem = objectReference:GetRefValue("rewardItem")
	local progressText = objectReference:GetRefValue("progressText")
	local circleSlider = objectReference:GetRefValue("sliderUSlider")
	local needPoint = rewardInfo.nodePoint or 0
	local currentPoint = progressData.currentPoint or 0
	local rewardConfig = self:getRewardConfig()
	local prePoint = level > 1 and (rewardConfig[level - 1].nodePoint or 0) or 0
	local levelProgress = math.max(0, currentPoint - prePoint)
	local levelNeed = needPoint - prePoint

	if progressText then
		ClientTextUtils.setText(progressText, needPoint)
	end

	if circleSlider then
		circleSlider.maxValue = levelNeed
		circleSlider.value = levelProgress
	end

	local rewardStatus = self:getRewardStatus(level, progressData)

	if rewardItem and rewardInfo.reward then
		local rewards = LuaUIUtils.getRewardItemByDropId(rewardInfo.reward, rewardStatus == Const.REWARD_STATUS_DONE, rewardStatus == Const.REWARD_STATUS_CANREWARD)

		if rewards and #rewards > 0 then
			LuaUIUtils.renderRewards(rewardItem, 1, rewards[1])

			if rewardStatus == Const.REWARD_STATUS_CANREWARD then
				function rewardItem.luaClick()
					self:tryGetReward(level)
				end
			else
				function rewardItem.luaClick()
					LuaUIUtils.onRewardItemClick(rewardItem, rewards[1])
				end
			end
		end
	end

	self:refreshRewardItemStatus(self.rewardBar, rewardStatus)
	self:refreshRewardItemRedDot(rewardItem, level, rewardStatus)
end

function BaseCollectionRewardComponent:refreshProgressText()
	if not self.totalProgressText then
		return
	end

	local progressData = self:getProgressData()

	if progressData then
		local current = progressData.currentPoint or 0

		ClientTextUtils.setText(self.totalProgressText, current)
	end
end

function BaseCollectionRewardComponent:getRewardConfig()
	local groupCfg = RobEggBookGroupData[BASE_CASE_ID]

	if not groupCfg or not groupCfg.reward then
		return {}
	end

	local rewardCfg = RobEggBookRewardData[groupCfg.reward]

	if not rewardCfg then
		return {}
	end

	return rewardCfg
end

function BaseCollectionRewardComponent:getBaseShowCase()
	if not pg.me or not pg.me.showCases then
		return nil
	end

	local showCase = pg.me.showCases[BASE_CASE_ID]

	return showCase
end

function BaseCollectionRewardComponent:getProgressData()
	local showCase = self:getBaseShowCase()

	if not showCase then
		return {
			level = 0,
			totalPoint = 0,
			currentPoint = 0,
			rewardStatus = {}
		}
	end

	local rewardCfg = self:getRewardConfig()
	local maxPoint = 0

	for _, cfg in pairs(rewardCfg) do
		if cfg.nodePoint and maxPoint < cfg.nodePoint then
			maxPoint = cfg.nodePoint
		end
	end

	local currentPoint = showCase.allPoint or 0
	local rewardRecord = showCase.rewardRecord or {}
	local currentLevel = 0

	for nodeId, cfg in pairs(rewardCfg) do
		if currentPoint >= cfg.nodePoint then
			currentLevel = math.max(currentLevel, nodeId)
		end
	end

	local rewardStatus = {}

	for nodeId, cfg in pairs(rewardCfg) do
		if rewardRecord[nodeId] and rewardRecord[nodeId] > 0 then
			rewardStatus[nodeId] = Const.REWARD_STATUS_DONE
		elseif currentPoint >= cfg.nodePoint then
			rewardStatus[nodeId] = Const.REWARD_STATUS_CANREWARD
		else
			rewardStatus[nodeId] = Const.REWARD_STATUS_INIT
		end
	end

	return {
		level = currentLevel,
		currentPoint = currentPoint,
		totalPoint = maxPoint,
		rewardStatus = rewardStatus
	}
end

function BaseCollectionRewardComponent:getRewardStatus(level, progressData)
	if progressData.rewardStatus and progressData.rewardStatus[level] then
		return progressData.rewardStatus[level]
	end

	local needPoint = 0
	local rewardConfig = self:getRewardConfig()

	if rewardConfig and rewardConfig[level] then
		needPoint = rewardConfig[level].nodePoint or 0
	end

	local currentPoint = progressData.currentPoint or 0

	if needPoint <= currentPoint then
		return Const.REWARD_STATUS_CANREWARD
	else
		return Const.REWARD_STATUS_INIT
	end
end

function BaseCollectionRewardComponent:tryGetReward(level)
	if not level then
		return
	end

	pg.me:serverMsg("RPC_CS_GetShowCaseReward", BASE_CASE_ID, level, function(noticeId)
		if noticeId == 0 or noticeId == nil then
			TimerManager.addTimer(0.1, function()
				self:refresh()

				if self.ctrl and self.ctrl.refreshCollectionEntryRedDots then
					self.ctrl:refreshCollectionEntryRedDots()
				end
			end)
		end
	end)
end

function BaseCollectionRewardComponent:refresh()
	self:refreshRewardDisplay()
end

function BaseCollectionRewardComponent:destroy()
	self.rewardPanel = nil
	self.rewardList = nil
	self.finalRewardItem = nil
	self.totalProgressText = nil
	self.rootTransform = nil
	self.ctrl = nil
	self.model = nil
end

return BaseCollectionRewardComponent
