-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetResearchCountryReward\\PetResearchCountryRewardCtrl.lua

local MessageName = require("Const.MessageName")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local Const = require("Common.Const.Const")
local CountryAreaData = require("Data.country_area_data")
local Class = require("Core.Framework.Class")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local UIConst = require("Const.UIConst")
local UICtrl = require("Guis.UICtrl")
local PetResearchCountryRewardCtrl = Class.LightClass("PetResearchCountryRewardCtrl", UICtrl)
local GamePadNavigation = require("Utils.GamePadNavigation")
local ClientTextUtils = require("Utils.ClientTextUtils")

PetResearchCountryRewardCtrl.messages = {
	[MessageName.PET_RESEARCH_COUNTRY_REWARD_STATUS_CHANGE] = {
		"onRewardStatusChanged",
		true
	},
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

function PetResearchCountryRewardCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.countryId = info.countryId

	self:initGamepadNav()
end

function PetResearchCountryRewardCtrl:addListener()
	function self.view.btnClose.luaClick()
		UIUtils.PlayAnimation(self.view.windowAnimation, "VX_Pb_PanelGift_Out", function()
			self:dismiss()
		end)
	end

	function self.view.listReward.luaRenderItem(button, idx, data)
		self:setUpRewardList(button, idx, data)
	end

	function self.view.btnTakeAll.luaClick()
		if self.model.hasReward then
			self:tryGetReward(-1)
		end
	end

	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.btnClose.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			UIUtils.PlayAnimation(self.view.windowAnimation, "VX_Pb_PanelGift_Out", function()
				self:dismiss()
			end)
		end
	end
end

function PetResearchCountryRewardCtrl:refreshGetAllBtnState()
	self.view.btnTakeAll.interactable = self.model.hasReward
end

function PetResearchCountryRewardCtrl:onDestroy()
	UICtrl.onDestroy(self)
end

function PetResearchCountryRewardCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:refreshRewardList()

	self.countryName = CountryAreaData["300001"].name

	ClientTextUtils.setText(self.view.txtTitle, pg.getLocalizationText(self.countryName))
end

function PetResearchCountryRewardCtrl:refreshRewardList()
	self.rewardData = self.model:getCountryRewardData(self.countryId)

	self.view.listReward:SetList(self.rewardData)

	if self.model.defaultSelectIdx then
		self.view.listReward:GoToIndex(self.model.defaultSelectIdx - 1)
	end

	self:refreshGetAllBtnState()
	self:setRewardListNav(self.view.listReward, self.rewardData)
end

function PetResearchCountryRewardCtrl:setUpRewardList(button, idx, data)
	local objectReference = button:GetComponent("ObjectReference")
	local listProp = objectReference:GetRefValue("listProp")
	local txtDesc = objectReference:GetRefValue("txtDesc")
	local btnTake = objectReference:GetRefValue("btnTake")
	local textRank = objectReference:GetRefValue("textRank")
	local curUText = objectReference:GetRefValue("curUText")
	local allUText = objectReference:GetRefValue("allUText")
	local lineProgressUProgress = objectReference:GetRefValue("lineProgressUProgress")
	local starProgressUProgress = objectReference:GetRefValue("starProgressUProgress")

	starProgressUProgress.maxValue = data.maxProgressValue
	starProgressUProgress.value = data.progressValue
	lineProgressUProgress.maxValue = data.maxProgressValue
	lineProgressUProgress.value = data.progressValue

	function listProp.luaRenderItem(b, i, d)
		PetResearchUtils.setRewardList(b, i, d)
	end

	ClientTextUtils.setText(txtDesc, pg.getFormatText(pg.getGameString("PET_MANUAL_REWARD_TXT"), pg.getLocalizationText(self.countryName)))
	listProp:SetList(data.itemRewards)
	button:TryChangePage("State", data.state)
	button:TryChangePage("StarType", data.isGolden and 0 or 1)
	ClientTextUtils.setText(curUText, data.curLevel or 0)
	ClientTextUtils.setText(allUText, data.allLevel or 0)
	ClientTextUtils.setText(textRank, data.allLevel)

	function btnTake.luaClick()
		self:getReward(data)
	end
end

function PetResearchCountryRewardCtrl:getReward(data)
	if data.rewardStatues == Const.REWARD_STATUS_CANREWARD then
		self:tryGetReward(data.curLevel)
	end
end

function PetResearchCountryRewardCtrl:tryGetReward(starLevel)
	pg.me:getPetHandbookCountryLevelReward(self.countryId, starLevel)
end

function PetResearchCountryRewardCtrl:onShow()
	return
end

function PetResearchCountryRewardCtrl:onHide()
	return
end

function PetResearchCountryRewardCtrl:onRewardStatusChanged(info)
	self:refreshRewardList()
end

function PetResearchCountryRewardCtrl:initGamepadNav()
	self.navigation = GamePadNavigation.new(self)
	self.navigation.AREAS = {
		REWARD_LIST = 1
	}
	self.navigation.REWARD_LIST = {
		index = 1
	}
	self.navigation.AREA_TABLES = {
		self.navigation.REWARD_LIST
	}
end

function PetResearchCountryRewardCtrl:setRewardListNav(uList, data)
	local navMap = {}

	for x, item in ipairs(data) do
		navMap[x] = {}

		for y, reward in ipairs(item.itemRewards) do
			navMap[x][y] = {
				data = item
			}
			navMap[x][y].Fun2 = function(x, y)
				self:tryGetReward(-1)
			end
			navMap[x][y].Fun2Name = pg.getGameString("OBTAIN_ALL")
			navMap[x][y].Fun6 = function(x, y)
				local _, button = uList:TryGetChildAt(x - 1)
				local objectReference = button:GetComponent("ObjectReference")
				local listProp = objectReference:GetRefValue("listProp")
				local _, item = listProp:TryGetChildAt(y - 1)

				if item and item.luaClick then
					item.luaClick()
				end
			end
			navMap[x][y].Fun6Name = pg.getGameString("CHECK_OUT")
			navMap[x][y].Fun6IsImportant = true
			navMap[x][y].Fun4IsImportant = true
			navMap[x][y].Fun2IsImportant = true
		end
	end

	local function confirmFunc(item, x1, y1)
		self:getReward(item.data)
	end

	local function cancelFunc(item, x1, y1)
		self:dismiss()
	end

	local function focusFunc(item, x1, y1)
		local btns = uList:GetAllButtons()

		for i = 0, btns.Length - 1 do
			btns[i]:TryChangePage("button", 0)
			self.navigation:setButtonFocus(btns[i], 0)

			local objectReference = btns[i]:GetComponent("ObjectReference")
			local listProp = objectReference:GetRefValue("listProp")
			local items = listProp:GetAllButtons()

			for i = 0, items.Length - 1 do
				items[i]:TryChangePage("button", 0)
				self.navigation:setButtonFocus(items[i], 0)

				if pg.global.ui:checkUIOpen(UIConst.UI_ID_COMMON_ITEM_TIP) then
					pg.global.ui.commonItemTip:close()
				end
			end
		end

		local _, button = uList:TryGetChildAt(x1 - 1)

		if button then
			button:TryChangePage("button", 3)
			self.navigation:setButtonFocus(button, 1)

			local objectReference = button:GetComponent("ObjectReference")
			local listProp = objectReference:GetRefValue("listProp")
			local _, item = listProp:TryGetChildAt(y1 - 1)

			if item then
				item:TryChangePage("button", 3)
				self.navigation:setButtonFocus(item, 1)
			end
		end

		self.curSelectX = x1
		self.curSelectY = y1

		if x1 > 0 and x1 <= #data then
			if x1 == #data or x1 == 1 then
				uList:GoToIndex(x1 - 1)
			elseif x1 + 1 <= #data then
				local _, button = uList:TryGetChildAt(x1)

				if not button then
					uList:GoToIndex(x1 - 1)
				end
			end

			if x1 - 1 > 0 then
				local _, button = uList:TryGetChildAt(x1 - 2)

				if not button then
					uList:GoToIndex(x1 - 1)
				end
			end

			local _, button = uList:TryGetChildAt(x1 - 1)

			if not button then
				uList:GoToIndex(x1 - 1)
			end
		end
	end

	uList:RegisterToScrollEndEvent(function()
		if self.curSelectX then
			local _, button = uList:TryGetChildAt(self.curSelectX - 1)

			if button then
				button:TryChangePage("button", 3)
				self.navigation:setButtonFocus(button, 1)

				local objectReference = button:GetComponent("ObjectReference")
				local listProp = objectReference:GetRefValue("listProp")
				local _, item = listProp:TryGetChildAt(self.curSelectY - 1)

				if item then
					item:TryChangePage("button", 3)
					self.navigation:setButtonFocus(item, 1)
				end
			end
		end
	end)
	self.navigation:addConsoleEvent(self.navigation:initCommonKeyData("RS", uList.gameObject))
	self.navigation:setCustomArea(self.navigation.REWARD_LIST, navMap, self.view.keyListUList, confirmFunc, cancelFunc, pg.getGameString("OBTAIN_REWARD"), focusFunc)
	self:gamepadFocusDefault()
end

function PetResearchCountryRewardCtrl:onInputDeviceChanged(deviceType)
	if pg.game.input:isUsingGamepad() then
		self:gamepadFocusDefault()
	end
end

function PetResearchCountryRewardCtrl:gamepadFocusDefault()
	self.navigation:specificSet(self.navigation.AREAS.REWARD_LIST, self.model.defaultSelectIdx or 1, 1)
	self.navigation:reFocus()
	self:startTimer(function()
		local _, button = self.view.listReward:TryGetChildAt(0)

		if button then
			button:TryChangePage("button", 3)
		end
	end, 0.1)
end

return PetResearchCountryRewardCtrl
