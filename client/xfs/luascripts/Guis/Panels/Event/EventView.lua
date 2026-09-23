-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Event\\EventView.lua

local logger = require("Core.Log.LoggerManager").getLogger("EventView")
local Class = require("Core.Framework.Class")
local UIView = require("Guis.UIView")
local ClientTextUtils = require("Utils.ClientTextUtils")
local LuaUIUtils = require("Utils.LuaUIUtils")
local ClientConst = require("Const.ClientConst")
local EventView = Class.LightClass("EventView", UIView)

function EventView:findObjects()
	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.backUButton = self.objectReference:GetRefValue("backUButton")
	self.titleUBaseText = self.objectReference:GetRefValue("titleUBaseText")
	self.tabUList = self.objectReference:GetRefValue("tabUList")
	self.parentWidget = self.objectReference:GetRefValue("parentWidget")
	self.petSaveUContainer = self.objectReference:GetRefValue("petSaveUContainer")
	self.tab1UButton = self.objectReference:GetRefValue("tab1UButton")
	self.tab2UButton = self.objectReference:GetRefValue("tab2UButton")
	self.prayersUContainer = self.objectReference:GetRefValue("prayersUContainer")
	self.dailySurveyUContainer = self.objectReference:GetRefValue("dailySurveyUContainer")
	self.officialGroupUContainer = self.objectReference:GetRefValue("officialGroupUContainer")
	self.fractureUContainer = self.objectReference:GetRefValue("fractureUContainer")
	self.mockBattleUContainer = self.objectReference:GetRefValue("mockBattleUContainer")
	self.leylinesTreeUContainer = self.objectReference:GetRefValue("leylinesTreeUContainer")
	self.eventTitleUContainer = self.objectReference:GetRefValue("eventTitleUContainer")
	self.morphologicalSurveyUContainer = self.objectReference:GetRefValue("morphologicalSurveyUContainer")
	self.catchPetUContainer = self.objectReference:GetRefValue("catchPetUContainer")
	self.vitalityContestUContainer = self.objectReference:GetRefValue("vitalityContestUContainer")
	self.ecologicalTraceabilityUContainer = self.objectReference:GetRefValue("ecologicalTraceabilityUContainer")
	self.arkPartyUContainer = self.objectReference:GetRefValue("arkPartyUContainer")
	self.waterAreaUContainer = self.objectReference:GetRefValue("waterAreaUContainer")
	self.unlockTxtName = self.objectReference:GetRefValue("unlockTxtName")
	self.blurUWidget = self.objectReference:GetRefValue("blurUWidget")

	local bgBlurTransform = self.blurUWidget and self.blurUWidget.transform:Find("BgBlur")

	self.bgBlurUIBlurEffect = bgBlurTransform and bgBlurTransform:GetComponent("UIBlurEffect")
	self.currencyUComponent = self.objectReference:GetRefValue("currencyUComponent")
	self.listCurrencyUList = self.objectReference:GetRefValue("listCurrencyUList")
	self.reunionTrainingUContainer = self.objectReference:GetRefValue("reunionTrainingUContainer")
	self.signNewbieUContainer = self.objectReference:GetRefValue("signNewbieUContainer")
	self.signVersionUContainer = self.objectReference:GetRefValue("signVersionUContainer")
	self.commonGuideUContainer = self.objectReference:GetRefValue("commonGuideUContainer")
	self.themeMonthUContainer = self.objectReference:GetRefValue("themeMonthUContainer")
	self.paidWipeTestUContainer = self.objectReference:GetRefValue("paidWipeTestUContainer")
	self.growthGiftUContainer = self.objectReference:GetRefValue("growthGiftUContainer")
	self.newHandSigninUContainer = self.objectReference:GetRefValue("newHandSigninUContainer")
	self.littleFireFestivalUContainer = self.objectReference:GetRefValue("tikTokUContainer")
	self.bindAccountUContainer = self.objectReference:GetRefValue("bindAccountUContainer")
	self.firstTopupUContainer = self.objectReference:GetRefValue("firstTopupUContainer")
	self.crossPlatformUContainer = self.objectReference:GetRefValue("crossPlatformUContainer")
	self.bossCatchUContainer = self.objectReference:GetRefValue("bossCatchUContainer")
	self.totalloginsUContainer = self.objectReference:GetRefValue("totalloginsUContainer")
	self.leftTabUWidget = self.objectReference:GetRefValue("leftTabUWidget")
	self.titleUWidget = self.objectReference:GetRefValue("titleUWidget")
end

function EventView:registerObjects()
	return
end

function EventView:initView()
	return
end

local RewardComs = {}

function EventView:getRewardCom(btn)
	if RewardComs[btn] == nil then
		RewardComs[btn] = {}

		local objectReference = btn.transform:GetComponent("ObjectReference")

		RewardComs[btn].button = btn
		RewardComs[btn].progressNum = objectReference:GetRefValue("progressNum")
		RewardComs[btn].progress = objectReference:GetRefValue("progress")
		RewardComs[btn].rewardItemAnim = objectReference:GetRefValue("rewardItemAnim")
		RewardComs[btn].rewardItem = objectReference:GetRefValue("rewardItem")
		RewardComs[btn].progressItemObj = objectReference:GetRefValue("progressItemObj")
		RewardComs[btn].progressAnimation = objectReference:GetRefValue("progressAnimation")
		RewardComs[btn].specialRewardUButton = objectReference:GetRefValue("specialRewardUButton")
		RewardComs[btn].specialRewardUImage = objectReference:GetRefValue("specialRewardUImage")
	end

	return RewardComs[btn]
end

function EventView:onRenderRewardItem(button, index, data)
	local itemComs = self:getRewardCom(button)

	ClientTextUtils.setText(itemComs.progressNum, data.targetNum)

	itemComs.progress.value = data.progress or 0

	local subData = {}
	local temp = LuaUIUtils.getRewardItemByDropId(data.dropId)

	if temp ~= nil and #temp > 0 then
		subData = temp[1]
	end

	table.merge(subData, data)

	subData.hasGet = data.state == ClientConst.RewardState.Claimed
	subData.canGet = data.state == ClientConst.RewardState.ReadyToClaim
	subData.hierarchyMode = 1
	subData.sortingOrder = 3

	LuaUIUtils.renderRewards(itemComs.rewardItem, nil, subData)

	if data.isSpecial then
		if itemComs.specialRewardUButton then
			itemComs.button:TryChangePage("Special", 1)

			function itemComs.specialRewardUButton.luaClick()
				LuaUIUtils.onRewardItemClick(itemComs.specialRewardUButton, subData)
			end
		end

		if itemComs.specialRewardUImage then
			itemComs.specialRewardUImage.url = LuaUIUtils.getIconByItemId(subData.id)
		end
	elseif itemComs.specialRewardUButton then
		itemComs.button:TryChangePage("Special", 0)

		itemComs.specialRewardUButton.luaClick = nil
	end
end

function EventView:onDestroy()
	for k in next, RewardComs do
		RewardComs[k] = nil
	end
end

return EventView
