-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetResearchReward\\PetResearchRewardCtrl.lua

local Class = require("Core.Framework.Class")
local Const = require("Common.Const.Const")
local Utils = require("Common.Utils.Utils")
local MessageName = require("Const.MessageName")
local UIConst = require("Const.UIConst")
local RewardItemListComponent = require("Guis.Panels.PetResearchReward.Component.RewardItemListComponent")
local UICtrl = require("Guis.UICtrl")
local PetResearchContentData = require("Data.pet_research_content_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetResearchRewardCtrl = Class.LightClass("PetResearchRewardCtrl", UICtrl)
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local LuaUIUtils = require("Utils.LuaUIUtils")

PetResearchRewardCtrl.messages = {
	[MessageName.PET_RESEARCH_LEVEL_REWARD_STATUS_CHANGE] = {
		"onRewardStatusChanged",
		true
	}
}

function PetResearchRewardCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.cardComponents = {}
	self.crownBottomPosition = {}
	self.templateId = info.templateId
	self.closeCb = info.closeCb

	self:init()
end

function PetResearchRewardCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function PetResearchRewardCtrl:init()
	self.petRewardInfo = self.model:getPetRewardInfo(self.templateId) or {}

	self.view.listReward:SetList(self.petRewardInfo)
	ClientTextUtils.setText(self.view.txtName, pg.getGameString("RESEARCH_LEVEL", self.model:getPetName(self.templateId)))
	self:initProgressBar()
	self:refreshClaimBtn()
end

function PetResearchRewardCtrl:initProgressBar()
	local rowSpacing = self.view.listReward.rowSpacing
	local cardHeight = self.view.cardHeight
	local progressBarHeight = #self.petRewardInfo * (cardHeight + rowSpacing)
	local progressBarWidth = self.view.progressRewardRect.sizeDelta.x

	self.view.progressRewardRect.sizeDelta = Vector2.New(progressBarWidth, progressBarHeight)

	local levelInfoList = self.model:getProgressLevelInfoList()

	self.view.listNumber2:SetList(levelInfoList)
	self:refreshProgressPercentage()
end

function PetResearchRewardCtrl:refreshProgressPercentage()
	self.view.progressReward.minValue = 0
	self.view.progressReward.maxValue = Const.PET_RESEARCH_REWARD_LEVEL_MAX

	local curLevel = self.model.level
	local nextLevel = curLevel + 1
	local exp = self.model.exp

	if nextLevel > Const.PET_RESEARCH_REWARD_LEVEL_MAX then
		self.view.progressReward.value = Const.PET_RESEARCH_REWARD_LEVEL_MAX
	else
		local prcdd = PetResearchContentData[self.templateId] or {}

		self.view.progressReward.value = curLevel + exp / (prcdd.needResearchPoint and prcdd.needResearchPoint[nextLevel] or 0)
	end
end

function PetResearchRewardCtrl:initProgressList(button, data)
	local txtNumber = button:Find("TxtNumber"):GetComponent("UBaseText")
	local txtName = button:Find("TxtName"):GetComponent("UBaseText")

	ClientTextUtils.setText(txtNumber, data.level)
	ClientTextUtils.setText(txtName, pg.getLocalizationText(data.title))
	button:TryChangePage("researchStage", data.level)
end

function PetResearchRewardCtrl:onShow()
	self.view.animation:Play("UI_Ani_Node_PetResearch_Gift_In")
end

function PetResearchRewardCtrl:addListener()
	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.widget.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			UIUtils.PlayAnimation(self.view.animation, "UI_Ani_Node_PetResearch_Gift_Out", function()
				self:dismiss()
			end)
		end
	end

	function self.view.mask.luaClick()
		UIUtils.PlayAnimation(self.view.animation, "UI_Ani_Node_PetResearch_Gift_Out", function()
			self:dismiss()
		end)
	end

	function self.view.listReward.luaRenderItem(button, index, data)
		self:onRefreshRewardCard(button, index, data)
	end

	function self.view.btnClaim.luaClick()
		self:claimAllReward()
	end

	function self.view.listNumber2.luaRenderItem(button, index, data)
		self:initProgressList(button, data)
	end
end

function PetResearchRewardCtrl:onRefreshRewardCard(button, index, info)
	if self.cardComponents[index] == nil then
		local data = {
			root = button,
			uiIndex = index,
			petTemplateId = self.templateId,
			itemList = info.itemList
		}

		self.cardComponents[index] = RewardItemListComponent.new(self, data)
	end

	local cardObjects = self.view:findRewardCardObjects(button)

	if self.view.cardHeight == nil then
		self.view.cardHeight = cardObjects.cardRect.rect.height
	end

	cardObjects.root:TryChangePage("panelStage", info.status)

	local uiLevel = index + 1
	local curLevel = self.model.level
	local nextLevel = curLevel + 1

	if nextLevel > Const.PET_RESEARCH_REWARD_LEVEL_MAX then
		ClientTextUtils.setText(cardObjects.number1, info.needExp)
		ClientTextUtils.setText(cardObjects.number2, info.needExp)
	else
		if nextLevel < uiLevel then
			ClientTextUtils.setText(cardObjects.number1, 0)
		elseif nextLevel == uiLevel then
			ClientTextUtils.setText(cardObjects.number1, math.min(self.model.exp, info.needExp))
		else
			ClientTextUtils.setText(cardObjects.number1, info.needExp)
		end

		ClientTextUtils.setText(cardObjects.number2, info.needExp)
	end
end

function PetResearchRewardCtrl:refreshClaimBtn()
	local hasReward = false

	for _, rewardInfo in pairs(self.petRewardInfo) do
		if rewardInfo.status == Const.REWARD_STATUS_CANREWARD then
			hasReward = true

			break
		end
	end

	LuaUIUtils.setUIViewVisible(self.view.btnClaim, hasReward)
end

function PetResearchRewardCtrl:claimAllReward()
	for index, rewardInfo in pairs(self.petRewardInfo) do
		if rewardInfo.status == Const.REWARD_STATUS_CANREWARD then
			self:claimReward(index)
		end
	end
end

function PetResearchRewardCtrl:claimReward(uiIndex)
	pg.me:getPetResearchLevelReward(self.templateId, uiIndex)
end

function PetResearchRewardCtrl:onRewardStatusChanged(body)
	local petTemplateId = body.templateId

	self.petRewardInfo = self.model:getPetRewardInfo(petTemplateId) or {}

	self.view.listReward:SetList(self.petRewardInfo)
	self:refreshClaimBtn()
end

return PetResearchRewardCtrl
