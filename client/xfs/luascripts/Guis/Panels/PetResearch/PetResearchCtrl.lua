-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetResearch\\PetResearchCtrl.lua

local MessageName = require("Const.MessageName")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HotkeyConst = require("Const.HotkeyConst")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local Const = require("Common.Const.Const")
local AudioConst = require("Const.AudioConst")
local ClientTextUtils = require("Utils.ClientTextUtils")
local PetResearchUtils = require("Guis.Utils.PetResearchUtils")
local PetResearchCardComponent = require("Guis.Panels.PetResearch.Component.PetResearchCardComponent")
local PetResearchCtrl = Class.LightClass("PetResearchCtrl", UICtrl)

PetResearchCtrl.messages = {
	[MessageName.PET_RESEARCH_COUNTRY_REWARD_STATUS_CHANGE] = {
		"onRewardStatusChanged",
		true
	},
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	},
	[MessageName.PET_RESEARCH_LEVEL_REWARD_STATUS_CHANGE] = {
		"onPetRewardStatusChanged",
		true
	},
	[MessageName.PET_RESEARCH_PET_NEW_LABEL_STATUS_CHANGE] = {
		"onPetNewStatusChanged",
		true
	},
	[MessageName.PET_RESEARCH_FORM_DISPLAY_CHANGE] = {
		"onPetDisplayChanged",
		true
	}
}

function PetResearchCtrl:onCreate(info)
	self.focusTemplateId = info and info.templateId or nil

	UICtrl.onCreate(self, info)

	self.petResearch = PetResearchCardComponent.new(self, self.view.tabCardUWidget.transform)

	CS.XGUI.Navigation.NavManager.Instance:AddLuaFocusGroupChangedListener("UI_PetResearchCardComponent", function(groupName)
		if self.petResearch then
			self.petResearch:refreshGamepadDefaultFocus(groupName, true)
		end
	end)
end

function PetResearchCtrl:setScrollPosLocalCache(pos)
	if not pos then
		return
	end

	local xPath, yPath = self:getScrollPosCachePath()

	pg.global.prefsCacheUtils:setFloat(xPath, pos[1])
	pg.global.prefsCacheUtils:setFloat(yPath, pos[2])
end

function PetResearchCtrl:onPetDisplayChanged(info)
	if info.countryId ~= self.model.areaId then
		return
	end

	self.petResearch:onPetDisplayChanged(info)
end

function PetResearchCtrl:getScrollPosLocalCache()
	local xPath, yPath = self:getScrollPosCachePath()
	local x = pg.global.prefsCacheUtils:getFloat(xPath, nil)
	local y = pg.global.prefsCacheUtils:getFloat(yPath, nil)

	if x and y then
		return {
			x,
			y
		}
	end
end

function PetResearchCtrl:getScrollPosCachePath()
	return string.format("%sPetResearchPosX%s_%s", pg.me.id, self.model.areaId, self.model.showTab), string.format("%sPetResearchPosY%s_%s", pg.me.id, self.model.areaId, self.model.showTab)
end

function PetResearchCtrl:setScrollIndexLocalCache(index)
	pg.global.prefsCacheUtils:setInt(pg.me.id .. "PetResearchPetIndex" .. self.model.areaId, index)
end

function PetResearchCtrl:getScrollIndexLocalCache()
	pg.global.prefsCacheUtils:getInt(pg.me.id .. "PetResearchPetIndex" .. self.model.areaId, nil)
end

function PetResearchCtrl:addListener()
	local closeBind = KeyBindingPro.GetOrAddKeyBindingByName(self.view.btnCloseUButton.gameObject, "closeBind")

	closeBind.isVirtual = true
	closeBind.priority = -1
	closeBind.actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.Cancel

	function closeBind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:dismiss()
		end
	end

	function self.view.btnCloseUButton.luaClick()
		self:dismiss()
	end

	local closeBind2 = KeyBindingPro.GetOrAddKeyBindingByName(self.view.btnCloseUButton.gameObject, "closeBind2")

	closeBind2.isVirtual = true
	closeBind2.priority = -1
	closeBind2.actionPath = LuaUIUtils.getFuncActionPath(Const.FUNCTION_IDS.PETRESEARCH)

	function closeBind2.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			self:dismiss()
		end
	end

	function self.view.btnOverviewUButton.luaClick()
		pg.global.ui.petOverview:open({
			disableSelectState = true,
			areaId = self.model.areaId,
			clickFunc = PetResearchUtils.tryOpenPetResearchDetail,
			switchTabCallback = function(tab)
				PetResearchUtils.savePetShowTab(tab)
			end
		})
	end

	ClientTextUtils.setText(self.view.btnOverviewNameUSDFText, pg.getGameString("BUTTON_OVERVIEW"))
end

function PetResearchCtrl:onRewardStatusChanged()
	if self.petResearch then
		self.petResearch:setUpRewardList(self.model.areaId)
		self.petResearch:refreshCountryRedDot()
		self.petResearch:refreshBtnSwitchRedDot()
	end
end

function PetResearchCtrl:checkSkipBgmAttenuation()
	return true
end

function PetResearchCtrl:onVisibleChange(visible)
	self:refreshBgmState()

	if visible and pg.game.input:isUsingGamepad() then
		-- block empty
	end

	if visible and self.petResearch then
		if self._skipNextVisibleRefresh then
			self._skipNextVisibleRefresh = nil
		else
			self.petResearch:onUICtrlVisible()
		end
	end
end

function PetResearchCtrl:onPetRewardStatusChanged(info)
	self.petResearch:refreshPetRewardRedDot()
	self.petResearch:setUpRewardList()
end

function PetResearchCtrl:onPetNewStatusChanged()
	self.petResearch:refreshPetRewardRedDot()
end

function PetResearchCtrl:refreshBgmState()
	return
end

function PetResearchCtrl:initGamepadNav()
	self.rightStickValue = Vector2(0, 0)
end

function PetResearchCtrl:refreshRewardFocusNav(slotId)
	if self.petResearch then
		-- block empty
	end
end

function PetResearchCtrl:selectTab()
	self.tabList[self.tabCurNavIndex]:CheckPressController()

	if self.tabList[self.tabCurNavIndex].luaClick then
		self.tabList[self.tabCurNavIndex].luaClick()
	end
end

function PetResearchCtrl:setPetListNav(uList, data)
	return
end

function PetResearchCtrl:setFinalRewardNav()
	return
end

function PetResearchCtrl:setRewardListNav(uList, data)
	return
end

function PetResearchCtrl:onInputDeviceChanged(deviceType)
	if pg.game.input:isUsingGamepad() then
		self:gamepadFocusDefault()
	end
end

function PetResearchCtrl:gamepadFocusDefault(uList)
	if not pg.game.input:isUsingGamepad() then
		return
	end

	if not uList and not self.petResearch then
		return
	end

	uList = uList or self.petResearch.listPetUList

	local curSelectedIndex = math.max(uList.selectedIndex, 1)

	uList:DeselectAll()
	self:startTimer(function()
		local _, button = self.petResearch.listPetUList:TryGetChildAt(curSelectedIndex - 1)

		if button then
			button:TryChangePage("button", 3)
		end
	end, 0.5)
end

function PetResearchCtrl:onDestroy()
	UICtrl.onDestroy(self)

	self.petResearch = nil

	if self.cardScrollTimer then
		self:killTimer(self.cardScrollTimer)

		self.cardScrollTimer = nil
	end

	CS.XGUI.Navigation.NavManager.Instance:RemoveLuaFocusGroupChangedListener("UI_PetResearchCardComponent")
end

function PetResearchCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self._skipNextVisibleRefresh = not self:checkUIVisible()
	self.focusTemplateId = info and info.templateId or nil

	if pg.global.ui.petResearchLoading:checkUIOpen() then
		pg.global.ui.petResearchLoading:dismiss()
	end

	self.model:initData(info)
	self.petResearch:refreshView()
end

function PetResearchCtrl:refreshConsoleBarState()
	CS.XGUI.Navigation.ConsoleBar.SetStateForAll("UI_PetManual_Choose", true)
end

function PetResearchCtrl:onShow()
	return
end

function PetResearchCtrl:onHide()
	return
end

return PetResearchCtrl
