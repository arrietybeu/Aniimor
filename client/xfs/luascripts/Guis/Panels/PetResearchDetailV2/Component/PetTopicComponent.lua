-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetResearchDetailV2\\Component\\PetTopicComponent.lua

local PetResearchTargetData = require("Data.pet_research_target_data")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local Const = require("Const.Const")
local lume = require("Core.Common.lume")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Utils = require("Common.Utils.Utils")
local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local PetTopicComponent = Class.LightClass("PetTopicComponent2", UIComponent)
local ClientTextUtils = require("Utils.ClientTextUtils")
local MessageName = require("Const.MessageName")
local RedDotConst = require("Const.RedDotConst")
local CallbackHandler = require("Core.Common.CallbackHandler")

PetTopicComponent.messages = {
	[MessageName.PET_TOPIC_REWARD_CHANGED] = {
		"onGetReward",
		true
	}
}

local PET_TOPIC_FOCUS_REWARD = "PET_TOPIC_FOCUS_REWARD"
local MAX_REWARD_COUNT = 2

function PetTopicComponent:findObjects()
	self.rootUWidget = self.transform:GetComponent("UWidget")
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.listUList = self.objectReference:GetRefValue("listUList")
	self.btnGetRewardUButton = self.objectReference:GetRefValue("btnGetRewardUButton")
	self.progressUSDFText = self.objectReference:GetRefValue("progressUSDFText")
	self.bounsUSDFText = self.objectReference:GetRefValue("bounsUSDFText")

	local btnOC = self.btnGetRewardUButton:GetComponent("ObjectReference")

	self.btnGetRewardUSDFText = btnOC:GetRefValue("txtNameUText")
end

function PetTopicComponent:initView()
	self.tabIdx = self.model.TAB_IDX.TOPIC
	self.ctrl.tabMap[self.tabIdx] = self

	function self.listUList.luaRenderItem(button, idx, data)
		self:renderTopicItem(button, idx, data)
	end

	function self.btnGetRewardUButton.luaClick()
		self:reqGetAllPetTopicReward()
	end

	ClientTextUtils.setText(self.progressUSDFText, pg.getGameString("PET_RESEARCH_TOPIC_PROGRESS"))
	ClientTextUtils.setText(self.bounsUSDFText, pg.getGameString("PET_RESEARCH_TOPIC_EXTRA_REWARD"))
	ClientTextUtils.setText(self.btnGetRewardUSDFText, pg.getGameString("PET_RESEARCH_GET_ALL_PET_REWARD"))
	self.ctrl:addNavFocusListener(CallbackHandler(self, "refreshConsoleBarState"), PET_TOPIC_FOCUS_REWARD)
end

function PetTopicComponent:refreshConsoleBarState()
	local navItem = CS.XGUI.Navigation.NavManager.Instance.CurrentFocusedUContent
	local isCanGetReward = false

	if navItem then
		local navItemIndex = self.listUList:GetChildIndex(navItem)

		if navItemIndex and navItemIndex >= 0 then
			local data = self.topicDatas[navItemIndex + 1]

			isCanGetReward = self:_checkHasRewardGet(data)
		end
	end

	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("UI_PetManual_Explore_GetReward", isCanGetReward)
end

function PetTopicComponent:_checkHasRewardGet(data)
	local curProgressInfo = data.curProgressInfo

	if curProgressInfo and curProgressInfo.rewardId and curProgressInfo.canGet and not curProgressInfo.hasGet then
		return true
	end

	return false
end

function PetTopicComponent:renderTopicItem(button, idx, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local txtNameUText = objectReference:GetRefValue("txtNameUText")
	local listUList = objectReference:GetRefValue("listUList")
	local listRewordUList = objectReference:GetRefValue("listRewordUList")
	local textUText = objectReference:GetRefValue("textUText")

	ClientTextUtils.setText(txtNameUText, pg.getLocalizationText(data.desc))
	self:resizeProgressItem(listUList, data.progressItem, data.curProgressIdx)

	iconUImage.url = data.icon

	local curProgressInfo = data.curProgressInfo

	function listRewordUList.luaRenderItem(btn, i, d)
		if d.tIndex == 0 then
			LuaUIUtils.renderRewardItem(btn, d)
			pg.global.setRedDot(string.format(RedDotConst.RedDotPath.PET_RESEARCH_TOPIC_REWARD, data.idx, i), btn, d.canGet, RedDotConst.RedDotStyle.REWARD)
		end
	end

	local rewards = {}

	if curProgressInfo.rewardId then
		local exFunc

		if not curProgressInfo.hasGet and curProgressInfo.canGet then
			function exFunc()
				self:reqGetOnePetTopicReward()
			end
		end

		rewards = LuaUIUtils.getRewardItemByDropId(curProgressInfo.rewardId, curProgressInfo.hasGet, curProgressInfo.canGet, nil, exFunc)
	end

	local rewardNum = #rewards

	if rewardNum < MAX_REWARD_COUNT then
		for i = 1, MAX_REWARD_COUNT - rewardNum do
			table.insert(rewards, {
				tIndex = 1
			})
		end
	end

	listRewordUList:SetList(rewards)

	if data.hasReport then
		button:TryChangePage("Upload", 1)
	else
		button:TryChangePage("Upload", 0)
	end

	ClientTextUtils.setText(textUText, curProgressInfo.researchPoint and "+", curProgressInfo.researchPoint or "")

	local isAllComplete = data.isGetAll and curProgressInfo.hasGet

	button:TryChangePage("State", isAllComplete and 1 or 0)
end

function PetTopicComponent:resizeProgressItem(progressList, data, curIdx)
	if not self.hasInitWidthParm then
		self:initProgressTemplate(progressList)
	end

	local contentTrans = progressList.content.transform
	local childCount = contentTrans.childCount
	local dataCount = #data
	local reachingItemWidth = self.progressRootWidth - (self.progressTemplateWidth + self.progressInterWidth) * math.max(dataCount - 1, 0)

	for index = 1, childCount do
		local progressItem = contentTrans:GetChild(index - 1):GetComponent("UWidget")

		if dataCount < index then
			progressItem:SetActiveFastest(false)
		else
			progressItem:SetActiveFastest(true)

			local progressData = data[index]
			local uProgress = progressItem:Find("Progress"):GetComponent("UProgress")
			local progressDesc = progressItem:Find("Text"):GetComponent("UBaseText")

			if index == curIdx then
				progressItem.sizeDelta = Vector2(reachingItemWidth, self.progressTemplateHeight)

				progressItem:TryChangePage("Number", 1)
				ClientTextUtils.setText(progressDesc, progressData.curNum, "/", progressData.numLimit)
			else
				progressItem.sizeDelta = Vector2(self.progressTemplateWidth, self.progressTemplateHeight)

				progressItem:TryChangePage("Number", 0)
			end

			uProgress.maxValue = progressData.numLimit
			uProgress.value = progressData.curNum
		end
	end
end

function PetTopicComponent:initProgressTemplate(progressList)
	self.progressRootWidth = progressList.sizeDelta.x

	local templateBtn = progressList:GetTemplateItem(0)

	self.progressTemplateWidth = templateBtn.sizeDelta.x
	self.progressTemplateHeight = templateBtn.sizeDelta.y
	self.progressInterWidth = progressList.colSpacing
	self.hasInitWidthParm = true
end

function PetTopicComponent:onDestroy()
	UIComponent.onDestroy(self)
end

function PetTopicComponent:refreshPetTopicList(cb)
	self.ctrl.petScene:trySwitchView(self.tabIdx, cb)

	if self.templateId == self.model.curPetTemplateId then
		self.listUList:RefreshList()

		return
	end

	self:setupPetTopicList()
end

function PetTopicComponent:setupPetTopicList()
	self.templateId = self.model.curPetTemplateId
	self.baseTemplateId = Utils.getBasePetPrototypeId(self.templateId)
	self.topicDatas = self:getStatisticsInfo()

	self.listUList:SetList(self.topicDatas)
end

function PetTopicComponent:onSelectThisPage(cb)
	self.ctrl:setPageTitle("TITLE_TOPIC")
	self:refreshPetTopicList(cb)

	local pointInfo = self:getTopicResearchPoint(self.templateId)

	self.ctrl:setPageResearchPoint(pointInfo[1], pointInfo[2])
	self.ctrl.petScene:playPetPageAction(self.templateId, self.tabIdx)
	self:_refreshGetAllBtnState()
end

function PetTopicComponent:onDeselectThisTab()
	return
end

function PetTopicComponent:getTopicResearchPoint(templateId)
	local playerHandBookMap = pg.me.petHandbookMap
	local handbookInfo = playerHandBookMap[templateId]
	local conditions = PetResearchTargetData[templateId] or {}
	local sum = 0
	local unlock = 0

	for k, v in pairs(conditions) do
		for idx, conditionInfo in ipairs(v.condition) do
			local point = PetResearchUtils.getRewardResearchPoint(conditionInfo[3])

			sum = sum + point

			if handbookInfo.completedTargetMap[k] and handbookInfo.completedTargetMap[k][idx] then
				unlock = unlock + point
			end
		end
	end

	return {
		unlock,
		sum
	}
end

function PetTopicComponent:getStatisticsInfo()
	local templateId = self.baseTemplateId
	local ret = {}
	local finished = {}
	local player = pg.me
	local playerHandBookMap = player.petHandbookMap
	local playerData = playerHandBookMap[templateId]

	if not playerHandBookMap:isCatched(templateId) then
		return
	end

	local conditions = PetResearchTargetData[templateId]

	if conditions == nil then
		return
	end

	local rewardedTargetMap = playerData.rewardedTargetMap or {}
	local researchPointReportMap = pg.me.petHandbookMap[templateId].researchPointMap

	for k, v in pairs(conditions) do
		local item = {}

		item.idx = k
		item.icon = v.icon
		item.desc = v.conditionDesc
		item.progressItem = {}
		item.isGetAll = false
		item.sortId = k

		for idx, conditionInfo in ipairs(v.condition) do
			local temp = {}

			temp.idx = idx
			temp.numLimit = conditionInfo[2] or 1
			temp.reward = conditionInfo[4]
			temp.hasGet = true
			temp.canGet = false

			local branchCondition = conditionInfo[5] or 1

			temp.researchPoint = PetResearchUtils.getRewardResearchPoint(conditionInfo[3])

			if researchPointReportMap:hasParams(Const.PET_RESEARCH.BI_SOURCE_TARGET, {
				k,
				idx
			}) then
				item.hasReport = true
			end

			if playerData.completedTargetMap[k] and playerData.completedTargetMap[k][idx] then
				temp.curNum = temp.numLimit

				if temp.reward then
					temp.hasGet = rewardedTargetMap[k] and rewardedTargetMap[k][idx]
					temp.canGet = not temp.hasGet
				end

				if not temp.hasGet and not item.curProgressIdx then
					item.curProgressIdx = idx
				end
			else
				if not item.curProgressIdx then
					item.curProgressIdx = idx
				end

				local isComplete = player.triggerMap:isCompleteOrMeetCondition(conditionInfo[1])

				if temp.reward then
					temp.hasGet = false
					temp.canGet = isComplete
				end

				if branchCondition == -1 then
					temp.curNum = isComplete and 1 or 0
				elseif isComplete then
					temp.curNum = player.triggerMap:getConditionTargetCount(conditionInfo[1], branchCondition)
				else
					temp.curNum = player.triggerMap:getConditionFinishCount(conditionInfo[1], branchCondition) or 0
				end
			end

			item.progressItem[#item.progressItem + 1] = temp
		end

		if not item.curProgressIdx then
			item.isGetAll = true
			item.curProgressIdx = #v.condition
		end

		local temp = item.progressItem[item.curProgressIdx]

		item.curProgressInfo = {
			rewardId = temp.reward,
			researchPoint = temp.researchPoint,
			idx = temp.idx,
			hasGet = temp.hasGet,
			canGet = temp.canGet
		}

		if item.isGetAll then
			finished[#finished + 1] = item
		else
			ret[#ret + 1] = item
		end
	end

	table.sort(ret, function(a, b)
		return a.sortId < b.sortId
	end)
	table.sort(finished, function(a, b)
		return a.sortId < b.sortId
	end)
	lume.append(ret, finished)

	return ret
end

function PetTopicComponent:reqGetOnePetTopicReward()
	local data = PetResearchUtils.getPetAllTopicRewardByTemplateId(self.templateId)

	pg.me:reqGetPetTopicRewards(data)
end

function PetTopicComponent:reqGetAllPetTopicReward()
	local data = PetResearchUtils.getAllCanGetTopicReward(self.ctrl.petListDatas)

	pg.me:reqGetPetTopicRewards(data)
end

function PetTopicComponent:onGetReward()
	self:_refreshGetAllBtnState()
	self:setupPetTopicList()
	self.ctrl:refreshRedDot()
end

function PetTopicComponent:_refreshGetAllBtnState()
	local hasReward = PetResearchUtils.checkHasTopicReward(self.ctrl.petListDatas)

	self.btnGetRewardUButton.interactable = hasReward

	pg.global.setRedDot(RedDotConst.RedDotPath.PET_RESEARCH_TOPIC_GET_ALL_REWARD, self.btnGetRewardUButton, hasReward, RedDotConst.RedDotStyle.REWARD)
end

return PetTopicComponent
