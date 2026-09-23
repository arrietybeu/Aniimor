-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetResearchProgressReward\\PetResearchProgressRewardCtrl.lua

local MessageName = require("Const.MessageName")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local Const = require("Common.Const.Const")
local LuaUIUtils = require("Utils.LuaUIUtils")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local PetResearchRewardData = require("Data.pet_research_reward_data")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local PetResearchContentData = require("Data.pet_research_content_data")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UIConst = require("Const.UIConst")
local PetResearchProgressRewardCtrl = Class.LightClass("PetResearchProgressRewardCtrl", UICtrl)
local GamePadNavigation = require("Utils.GamePadNavigation")
local ClientTextUtils = require("Utils.ClientTextUtils")
local RedDotConst = require("Const.RedDotConst")
local RewardStateUtils = require("Common.Utils.RewardStateUtils")

PetResearchProgressRewardCtrl.messages = {
	[MessageName.PET_RESEARCH_LEVEL_REWARD_STATUS_CHANGE] = {
		"onRewardStatusChanged",
		true
	},
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

function PetResearchProgressRewardCtrl:onCreate(info)
	UICtrl.onCreate(self, info)
end

function PetResearchProgressRewardCtrl:addListener()
	function self.view.btnBackUButton.luaClick()
		self:dismiss()
	end

	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.btnBackUButton.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:dismiss()
		end
	end

	function self.view.researchList1.luaRenderItem(button, idx, data)
		self:setRewardList(button, idx, data)
	end

	function self.view.researchList2.luaRenderItem(button, idx, data)
		self:setRewardList(button, idx, data)
	end

	function self.view.researchList3.luaRenderItem(button, idx, data)
		self:setRewardList(button, idx, data)
	end

	function self.view.researchList4.luaRenderItem(button, idx, data)
		self:setRewardList(button, idx, data)
	end

	function self.view.btnGetAllRewardUButton.luaClick()
		if self:checkHasReward(self.templateId) then
			self:tryGotReward(-1)
		end
	end

	for idx = 1, 4 do
		local progress = self.view["progress" .. idx]

		progress.minValue = 0
		progress.maxValue = 1
	end
end

function PetResearchProgressRewardCtrl:setRewardList(button, idx, data)
	LuaUIUtils.renderRewards(button, idx, data)
end

function PetResearchProgressRewardCtrl:onRewardStatusChanged(info)
	if info.templateId == self.templateId then
		local level = info.level

		self:refreshRewardStatus(self.view["reward" .. level], info.newStatus, level)
	end

	self:refreshClaimAllState()
end

function PetResearchProgressRewardCtrl:setRewardInfo(rewardComponent, rewardLevel, petHandbookInfo, rewardInfo, needResearchList)
	local curLevel = petHandbookInfo.level
	local targetLevel = math.min(curLevel + 1, self.maxRewardLevel)
	local targetNeedPoint = needResearchList[targetLevel]
	local exp = petHandbookInfo.exp

	if targetLevel == curLevel then
		exp = targetNeedPoint
	end

	local rewardNeedPoint = needResearchList[rewardLevel]

	if rewardLevel <= curLevel then
		rewardComponent:TryChangePage("reached", 1)

		self.view["progress" .. rewardLevel].value = 1

		ClientTextUtils.setText(self.view["researchText" .. rewardLevel], string.format("%s/%s", rewardNeedPoint, rewardNeedPoint))
	elseif rewardLevel == targetLevel then
		rewardComponent:TryChangePage("reached", 0)
		ClientTextUtils.setText(self.view["researchText" .. rewardLevel], string.format("%s/%s", exp, targetNeedPoint))

		self.view["progress" .. rewardLevel].value = exp / targetNeedPoint
	else
		rewardComponent:TryChangePage("reached", 0)
		ClientTextUtils.setText(self.view["researchText" .. rewardLevel], string.format("%s/%s", 0, rewardNeedPoint))

		self.view["progress" .. rewardLevel].value = 0
	end

	local dropId = rewardInfo.reward
	local rewardList = LuaUIUtils.getRewardItemByDropId(dropId)

	self.view["researchList" .. rewardLevel]:SetList(rewardList)

	local btnGotReward = rewardComponent:Find("BtnGet"):GetComponent("UButton")

	function btnGotReward.luaClick()
		self:tryGotReward(rewardLevel)
	end

	local status = petHandbookInfo:getLevelRewardStatus(rewardLevel)

	self:refreshRewardStatus(rewardComponent, status, rewardLevel)
end

function PetResearchProgressRewardCtrl:checkHasReward(templateId)
	local playerData = pg.me.petHandbookMap
	local petHandBookInfo = playerData[templateId]
	local rewardData = PetResearchRewardData[templateId]

	if petHandBookInfo then
		for level, _ in pairs(rewardData) do
			local status = petHandBookInfo:getLevelRewardStatus(level)

			if status == Const.REWARD_STATUS_CANREWARD then
				return true
			end
		end
	end

	return false
end

function PetResearchProgressRewardCtrl:refreshRewardStatus(rewardComponent, status, rewardLevel)
	local state = RewardStateUtils.applyStatus(rewardComponent, status, Const.REWARD_STATUS_CANREWARD, Const.REWARD_STATUS_DONE)

	if rewardLevel then
		local btnGet = rewardComponent:Find("BtnGet"):GetComponent("UButton")

		RewardStateUtils.applyClaimButton(btnGet, state == RewardStateUtils.State.ReadyToClaim, RedDotConst.RedDotPath.PET_RESEARCH, false, "progressReward", self.templateId or 0, "item", rewardLevel)
	end
end

function PetResearchProgressRewardCtrl:refreshClaimAllState()
	local canClaim = self:checkHasReward(self.templateId)

	RewardStateUtils.applyClaimButton(self.view.btnGetAllRewardUButton, canClaim, RedDotConst.RedDotPath.PET_RESEARCH, true, "progressReward", self.templateId or 0, "claimAll")
end

function PetResearchProgressRewardCtrl:setRewardBranch(petHandBookInfo, needResearchPointList)
	local rewardData = PetResearchRewardData[self.templateId]

	self.maxRewardLevel = table.maxn(rewardData)

	for level, rewardInfo in pairs(rewardData) do
		self:setRewardInfo(self.view["reward" .. level], level, petHandBookInfo, rewardInfo, needResearchPointList)
	end

	self:setCurProgress()
end

function PetResearchProgressRewardCtrl:setCurProgress()
	local researchPointInfo = PetResearchUtils.getPetResearchPoint(self.templateId)

	self.view.btnResProgressUButton:TryChangePage("Crown", PetResearchUtils.LEVEL_QUALITY_NAME[researchPointInfo.level])
	ClientTextUtils.setText(self.view.progressUText, string.format("%s/%s", researchPointInfo.exp, researchPointInfo.needExp))
end

function PetResearchProgressRewardCtrl:onDestroy()
	UICtrl.onDestroy(self)
	self.petScene:onLeaveProgressReward()

	self.onHideFunc = nil
end

function PetResearchProgressRewardCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.templateId = info.templateId
	self.onHideFunc = info.onHideFunc

	local playerData = pg.me.petHandbookMap
	local petHandBookInfo = playerData[self.templateId]
	local needResearchPointList = PetResearchContentData[self.templateId].needResearchPoint

	self.petScene = pg.game.uiScene:getScene(UISceneConst.PET_RESEARCH_DETAIL_V2)

	self:setRewardBranch(petHandBookInfo, needResearchPointList)
	ClientTextUtils.setText(self.view.backTitleText, pg.getLocalizationText(PetResearchContentData[self.templateId].name))
	self:refreshClaimAllState()
	self.petScene:onEnterProgressReward()
end

function PetResearchProgressRewardCtrl:tryGotReward(level)
	pg.me:getPetResearchLevelReward(self.templateId, level)
end

function PetResearchProgressRewardCtrl:onShow()
	UICtrl.onShow(self)
	pg.global.ui.petResearchDetail:onPetResearchRewardChange(true)
end

function PetResearchProgressRewardCtrl:onHide()
	if self.onHideFunc then
		self.onHideFunc()
	end

	pg.global.ui.petResearchDetail:onPetResearchRewardChange(false)
end

function PetResearchProgressRewardCtrl:initGamepadNav()
	self.navigation = GamePadNavigation.new(self)
	self.navigation.AREAS = {
		PET_REWARD = 1
	}
	self.navigation.PET_REWARD = {
		index = 1
	}
	self.navigation.AREA_TABLES = {
		self.navigation.PET_REWARD
	}
end

function PetResearchProgressRewardCtrl:setNavMap()
	local navMap = {}
	local index = 0

	navMap[1] = {}

	for i = 1, self.view.researchList1.itemCount do
		index = index + 1

		local _, itemButton = self.view.researchList1:TryGetChildAt(i - 1)

		navMap[1][index] = {
			getRewardButton = self.view.reward1:Find("BtnGet"):GetComponent("UButton"),
			element = itemButton
		}
	end

	for i = 1, self.view.researchList3.itemCount do
		index = index + 1

		local _, itemButton = self.view.researchList3:TryGetChildAt(i - 1)

		navMap[1][index] = {
			getRewardButton = self.view.reward3:Find("BtnGet"):GetComponent("UButton"),
			element = itemButton
		}
	end

	index = 0
	navMap[2] = {}

	for i = 1, self.view.researchList4.itemCount do
		index = index + 1

		local _, itemButton = self.view.researchList4:TryGetChildAt(i - 1)

		navMap[2][index] = {
			getRewardButton = self.view.reward4:Find("BtnGet"):GetComponent("UButton"),
			element = itemButton
		}
	end

	index = 0
	navMap[3] = {}

	for i = 1, self.view.researchList2.itemCount do
		index = index + 1

		local _, itemButton = self.view.researchList2:TryGetChildAt(i - 1)

		navMap[3][index] = {
			getRewardButton = self.view.reward2:Find("BtnGet"):GetComponent("UButton"),
			element = itemButton
		}
	end

	for _, items in ipairs(navMap) do
		for _, item in ipairs(items) do
			function item.Fun6(x, y)
				if item.element.luaClick then
					item.element.luaClick()
				end
			end

			item.Fun6Name = pg.getGameString("CHECK_OUT")

			function item.Fun2(x, y)
				self:tryGotReward(-1)
			end

			item.Fun2Name = pg.getGameString("OBTAIN_ALL")
			item.Fun6IsImportant = true
			item.Fun4IsImportant = true
			item.Fun2IsImportant = true
		end
	end

	self.navigation:addConsoleEvent(self.navigation:initCommonKeyData("RS", self.view.bottomKeyListUList.gameObject))

	self.mainNavMap = navMap

	self.navigation:setCustomArea(self.navigation.PET_REWARD, navMap, self.view.bottomKeyListUList, function(item)
		if item.getRewardButton.gameObject.activeSelf and item.getRewardButton.luaClick then
			item.getRewardButton.luaClick()
		end
	end, function(item)
		self:dismiss()
	end, pg.getGameString("OBTAIN_REWARD"), function(item, x1, y1)
		self.navigation:defaultFocusAction(navMap, item)

		if pg.global.ui:checkUIOpen(UIConst.UI_ID_COMMON_ITEM_TIP) then
			pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)
		end
	end)
	self:gamepadFocusDefault()
end

function PetResearchProgressRewardCtrl:onInputDeviceChanged(deviceType)
	return
end

function PetResearchProgressRewardCtrl:gamepadFocusDefault()
	if not pg.game.input:isUsingGamepad() then
		return
	end

	self:startTimer(function()
		self.navigation:specificSet(self.navigation.AREAS.PET_REWARD, 1, 1)
		self.navigation:reFocus()

		if self.mainNavMap and self.mainNavMap[1] and self.mainNavMap[1][1] then
			self.mainNavMap[1][1].element:TryChangePage("button", 3)
			self.navigation:setButtonFocus(self.mainNavMap[1][1].element, 1)
		end
	end, 0.1)
end

return PetResearchProgressRewardCtrl
