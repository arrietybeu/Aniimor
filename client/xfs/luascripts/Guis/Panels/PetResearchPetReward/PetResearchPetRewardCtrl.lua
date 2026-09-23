-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetResearchPetReward\\PetResearchPetRewardCtrl.lua

local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local PetResearchTargetData = require("Data.pet_research_target_data")
local Const = require("Const.Const")
local HotkeyConst = require("Const.HotkeyConst")
local PetTraitData = require("Data.pet_trait_data")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local ItemData = require("Data.item_data")
local PetResearchRewardData = require("Data.pet_research_reward_data")
local Class = require("Core.Framework.Class")
local RedDotConst = require("Const.RedDotConst")
local UICtrl = require("Guis.UICtrl")
local Utils = require("Common.Utils.Utils")
local PetResearchContentData = require("Data.pet_research_content_data")
local PetResearchPetRewardCtrl = Class.LightClass("PetResearchPetRewardCtrl", UICtrl)
local ClientTextUtils = require("Utils.ClientTextUtils")
local FORM_UNLOCK_ID = 0
local FORM_LOCK_ID = 1

PetResearchPetRewardCtrl.messages = {
	[MessageName.PET_RESEARCH_LEVEL_REWARD_STATUS_CHANGE] = {
		"onRewardStatusChanged",
		true
	}
}

function PetResearchPetRewardCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.countryId = 300001
end

function PetResearchPetRewardCtrl:addListener()
	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.btnBackUButton.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:dismiss()
		end
	end

	function self.view.btnBackUButton.luaClick()
		self:dismiss()
	end

	function self.view.listUList.luaRenderItem(button, idx, data)
		self:renderTitlePetList(button, idx, data)
	end

	function self.view.listUList.luaResetItem(button)
		local objectReference = button:GetComponent("ObjectReference")
		local petIcon = objectReference:GetRefValue("iconUImage")

		petIcon.url = nil
	end

	function self.view.listUList.luaSelectedChanged(uList)
		local data = uList.selectedItem

		if data then
			self.templateId = data.templateId
			self.baseTemplateId = Utils.getBasePetPrototypeId(self.templateId)

			self:tryShowPetReward()
		end
	end

	function self.view.btnGetRewardUButton.luaClick()
		pg.me:getAllPetResearchLevelReward()
	end

	function self.view.btnSurveyUButton.luaClick()
		self:gotoPage(UIConst.HANDBOOK_PAGE_IDX.SURVEY)
	end

	function self.view.btnTopicUButton.luaClick()
		self:gotoPage(UIConst.HANDBOOK_PAGE_IDX.TOPIC)
	end

	function self.view.colorAccessoryUButton.luaClick()
		local configData = PetResearchUtils.getPetResearchContent(self.templateId)

		if pg.me.colorJewelryIds and pg.me.colorJewelryIds[configData.flashId] then
			-- block empty
		else
			local petHandBookInfo = pg.me.petHandbookMap[self.templateId]

			if petHandBookInfo and petHandBookInfo:isShinyCatched() then
				pg.me:doEventByData({
					"addColorJewelry",
					{
						configData.flashId
					}
				})
				self:refreshColorJewelryButton()
			else
				pg.global.ui:open(UIConst.UI_ID_COMMON_ITEM_TIP, {
					num = 1,
					id = configData.flashId,
					targetRect = self.view.colorAccessoryUButton
				})
			end
		end
	end
end

function PetResearchPetRewardCtrl:onVisibleChange(visible)
	pg.global.ui.petResearch:refreshBgmState()
end

function PetResearchPetRewardCtrl:tryShowPetReward()
	local rewardData = PetResearchRewardData[self.baseTemplateId]
	local playerData = pg.me.petHandbookMap
	local petHandBookInfo = playerData[self.baseTemplateId]
	local configData = PetResearchUtils.getPetResearchContent(self.baseTemplateId)
	local needResearchPointList = configData.needResearchPoint
	local accumulatePointList = {}
	local accumulatePoint = 0

	for idx = 1, #needResearchPointList do
		accumulatePoint = needResearchPointList[idx] + accumulatePoint
		accumulatePointList[#accumulatePointList + 1] = accumulatePoint
	end

	self.maxRewardLevel = table.maxn(rewardData)

	for level, rewardInfo in pairs(rewardData) do
		self:setRewardItem(self.view["btnItem" .. level], level, petHandBookInfo, rewardInfo, accumulatePointList)
	end

	self.view.btnGetRewardUButton.interactable = self:checkHasReward(self.baseTemplateId)
	self.view.iconUImage.url = configData.bigIcon
	self.view.littleIcon.url = configData.flashId and ItemData[configData.flashId].icon or ""

	local surveyPoints = self:getPetSurveyPoint(self.baseTemplateId)

	ClientTextUtils.setText(self.view.surveyPoint, string.format("%s/%s", surveyPoints[1], surveyPoints[2]))

	local topicPoints = self:getPetTopicPoint(petHandBookInfo)

	ClientTextUtils.setText(self.view.topicPoint, string.format("%s/%s", topicPoints[1], topicPoints[2]))
	self:refreshColorJewelryButton()
end

function PetResearchPetRewardCtrl:gotoPage(pageIdx)
	if pg.global.ui.petResearchDetailV2:checkUIOpen() then
		self:dismiss()
		pg.global.ui.petResearchDetailV2:gotoPage(pageIdx, self.templateId)
	else
		PetResearchUtils.openPetResearchDetail({
			templateId = self.templateId,
			subPageIdx = pageIdx
		})
	end
end

function PetResearchPetRewardCtrl:setRewardItem(button, level, petHandbookInfo, rewardInfo, needResearchPointList)
	local objectReference = button:GetComponent("ObjectReference")
	local rewardList = objectReference:GetRefValue("listUList")
	local pointNum = objectReference:GetRefValue("numberUSDFText")
	local specialAbilityUImage = objectReference:GetRefValue("specialAbilityUImage")
	local tipsUSDFText = objectReference:GetRefValue("tipsUSDFText")
	local gotBtn = objectReference:GetRefValue("btnConfirmUButton")
	local circleSliderUSlider = objectReference:GetRefValue("circleSliderUSlider")

	function rewardList.luaRenderItem(btn, idx, data)
		LuaUIUtils.renderRewards(btn, idx, data)
	end

	function gotBtn.luaClick()
		self:tryGotReward(level)
	end

	local rewardNeedPoint = needResearchPointList[level]
	local prePoint = needResearchPointList[level - 1] or 0

	if petHandbookInfo.level + 1 == level then
		button:TryChangePage("Progress", 0)

		local curExp = prePoint + petHandbookInfo.exp

		circleSliderUSlider.maxValue = rewardNeedPoint
		circleSliderUSlider.value = petHandbookInfo.exp

		ClientTextUtils.setText(pointNum, curExp, "/", rewardNeedPoint)
	else
		button:TryChangePage("Progress", 1)
		ClientTextUtils.setText(pointNum, rewardNeedPoint)
	end

	local rewardStatus = petHandbookInfo:getLevelRewardStatus(level)

	if rewardInfo.rewardType == 1 then
		local dropId = rewardInfo.reward

		rewardList:SetList(LuaUIUtils.getRewardItemByDropId(dropId, rewardStatus == Const.REWARD_STATUS_DONE, rewardStatus == Const.REWARD_STATUS_CANREWARD))
		button:TryChangePage("IsReward", 0)
	elseif rewardInfo.rewardType == 2 then
		ClientTextUtils.setText(tipsUSDFText, pg.getLocalizationText(rewardInfo.specialAbilityDesc))

		specialAbilityUImage.url = rewardInfo.specialAbilityIcon

		button:TryChangePage("IsReward", 1)
	end

	self:refreshRewardStatus(button, rewardStatus)
end

function PetResearchPetRewardCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function PetResearchPetRewardCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.templateId = info.templateId
	self.onHideFunc = info.onHideFunc
	self.baseTemplateId = Utils.getBasePetPrototypeId(self.templateId)
	self.showTab = PetResearchUtils.getLastPetShowTab()

	self:initTitleList()
	self:tryShowPetReward()
end

function PetResearchPetRewardCtrl:tryGotReward(level)
	pg.me:getPetResearchLevelReward(self.baseTemplateId, level)
end

function PetResearchPetRewardCtrl:initTitleList()
	self.petListDatas = PetResearchUtils.tryGetPetInfos(nil, nil, {
		PetResearchUtils.PET_STATE_IS_CATCH,
		PetResearchUtils.PET_STATE_IS_AllSTAR
	}, self.countryId, self.showTab)

	self.view.arrowUWidget:SetActiveFastest(#self.petListDatas > 7)
	self.view.listUList:SetList(self.petListDatas)

	local selectedIdx = 0

	for idx, data in ipairs(self.petListDatas) do
		if data.templateId == self.templateId then
			selectedIdx = idx - 1

			break
		end
	end

	self.view.listUList:SelectItem(selectedIdx or 0, false)
	self.view.listUList:GoToIndex(selectedIdx or 0, true)
end

function PetResearchPetRewardCtrl:renderTitlePetList(button, idx, data)
	local objectReference = button:GetComponent("ObjectReference")
	local petIcon = objectReference:GetRefValue("iconUImage")
	local label = data.displayLabel == Const.PET_LABEL_MASK.SHINY and 1 or 0

	petIcon.url = LuaUIUtils.getPetIcon(data.iconName, LuaUIUtils.PET_ICON, label)

	button:TryChangePage("Flash", label)
end

function PetResearchPetRewardCtrl:checkHasReward()
	return false
end

function PetResearchPetRewardCtrl:onRewardStatusChanged(info)
	if info.templateId == self.baseTemplateId then
		local level = info.level

		self:refreshRewardStatus(self.view["btnItem" .. level], info.newStatus)
	end

	self.view.btnGetRewardUButton.interactable = self:checkHasReward()

	self.view.listUList:RefreshList()
end

function PetResearchPetRewardCtrl:refreshRewardStatus(rewardComponent, status)
	local objectReference = rewardComponent:GetComponent("ObjectReference")

	if status == Const.REWARD_STATUS_CANREWARD then
		rewardComponent:TryChangePage("State", 2)
	elseif status == Const.REWARD_STATUS_DONE then
		rewardComponent:TryChangePage("State", 1)
	else
		rewardComponent:TryChangePage("State", 0)
	end
end

function PetResearchPetRewardCtrl:getPetSurveyPoint(baseTemplateId)
	return PetResearchUtils.getPetSurveyPoint(baseTemplateId)
end

function PetResearchPetRewardCtrl:getPetTopicPoint(handbookInfo)
	local conditions = PetResearchTargetData[self.baseTemplateId] or {}
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

function PetResearchPetRewardCtrl:refreshColorJewelryButton()
	local configData = PetResearchUtils.getPetResearchContent(self.templateId)

	if configData.flashId then
		self.view.rootUComponent:TryChangePage("FlashProps", "Show")
	else
		self.view.rootUComponent:TryChangePage("FlashProps", "Hide")
	end

	if pg.me.colorJewelryIds and pg.me.colorJewelryIds[configData.flashId] then
		self.view.colorAccessoryUButton:TryChangePage("State", "Get")
	else
		local petHandBookInfo = pg.me.petHandbookMap[self.templateId]

		if petHandBookInfo and petHandBookInfo:isShinyCatched() then
			self.view.colorAccessoryUButton:TryChangePage("State", "Recive")
		else
			self.view.colorAccessoryUButton:TryChangePage("State", "Normal")
		end
	end
end

function PetResearchPetRewardCtrl:onShow()
	return
end

function PetResearchPetRewardCtrl:onHide()
	if self.onHideFunc then
		self.onHideFunc()
	end
end

return PetResearchPetRewardCtrl
