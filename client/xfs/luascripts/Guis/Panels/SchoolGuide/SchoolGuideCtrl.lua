-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\SchoolGuide\\SchoolGuideCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("SchoolGuideCtrl")
local MessageName = require("Const.MessageName")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ActivityConst = require("Common.Const.ActivityConst")
local ActivityUtils = require("Common.Utils.ActivityUtils")
local Time = require("Core.Common.Time")
local Const = require("Common.Const.Const")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local LuaUIUtils = require("Utils.LuaUIUtils")
local EventConst = require("Const.EventConst")
local RedDotConst = require("Const.RedDotConst")
local SchoolGuideConst = require("Common.Const.SchoolGuideConst")
local GameGuideComponent = require("Guis.Panels.SchoolGuide.Component.GameGuideComponent")
local DailyActiveComponent = require("Guis.Panels.SchoolGuide.Component.DailyActiveComponent")
local BadgeCollectionComponent = require("Guis.Panels.SchoolGuide.Component.BadgeCollectionComponent")
local ItemCraftComponent = require("Guis.Panels.SchoolGuide.Component.ItemCraftComponent")
local MockGuideComponent = require("Guis.Panels.SchoolGuide.Component.MockGuideComponent")
local SchoolData = require("Data.college_guide_page_data")
local UIConst = require("Const.UIConst")
local Navigation = CS.XGUI.Navigation
local SchoolGuideCtrl = Class.LightClass("SchoolGuideCtrl", UICtrl)

SchoolGuideCtrl.EXConfigTypeInfo = {
	[SchoolGuideConst.EventType.BadgeCollection] = {
		container = "medalUContainer",
		cls = BadgeCollectionComponent
	},
	[SchoolGuideConst.EventType.DailyActive] = {
		container = "dailyActiveUContainer",
		cls = DailyActiveComponent
	},
	[SchoolGuideConst.EventType.ItemCraft] = {
		container = "itemCraftUContainer",
		cls = ItemCraftComponent
	}
}
SchoolGuideCtrl.messages = {
	[MessageName.PLAYER_ONTELEPORT] = {
		"onPlayerTeleport",
		true
	},
	[MessageName.ON_NOTIFY_ITEM] = {
		"onRefreshCurrencyList",
		true
	},
	[MessageName.ON_AWAITING_OPEN_REWARD_CHANGED] = {
		"onBadgeOpenChanged",
		true
	},
	[MessageName.CURRENCY_CHANGE] = {
		"onItemCountChanged",
		true
	},
	[MessageName.EVENT_APP_RED_DOT_CHANGED] = {
		"onEventAppRedDotChanged",
		true
	},
	[MessageName.UI_ON_CLOSE] = {
		"onUIClose",
		true
	},
	[MessageName.EVENT_CUR_PAGE_REFRESH] = {
		"onDayUpdate",
		true
	},
	[MessageName.EVENT_TASK_STATE_CHANGE] = {
		"onRefreshRedDot",
		true
	},
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

local VITALITY_ID = 1009

function SchoolGuideCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.gameGuideComponent = GameGuideComponent.new(self, self.view.guideUWidget.transform)
	self.mockGuideComponent = MockGuideComponent.new(self, self.view.holographicTrainingUWidget)
end

function SchoolGuideCtrl:addListener()
	function self.view.firstLevelTabUList.luaRenderItem(button, index, data)
		self:renderFirstTab(button, index, data)
	end

	function self.view.btnBackUButton.luaClick()
		self:dismiss()
	end

	local function infoClick()
		if self.curComponent and self.curComponent.mainTabType then
			local descId = SchoolData[self.curComponent.mainTabType].ruleId

			if descId then
				pg.global.ui.tips:openSchoolGuideDesc(descId)
			elseif self.curComponent.customRuleTip then
				self.curComponent:customRuleTip()
			end
		end
	end

	self.view.infoBtn.luaClick = infoClick

	self.view.infoBtnConsole:SetGamepadAction("Raw/GamepadStart", nil, infoClick)
	self.view.infoBtnConsole:SetHotkeyConsoleBar("CONSOLE_BAR_RULES_DESCRIPTION", 0)

	function self.view.listCurrencyUList.luaRenderItem(button, index, data)
		LuaUIUtils.setTopCurrencyItem(button, data.itemId, data.needAdd, data.maxValue)
	end

	function self.addMapMarkTrace(markType, spawnerId, data)
		self:onAddMapMarkTrace(markType, spawnerId, data)
	end

	pg.global.eventEmitter:addEventListener(EventConst.ON_MAP_MARK_TRACE_ADD, self.addMapMarkTrace)
end

function SchoolGuideCtrl:onDestroy()
	pg.global.eventEmitter:removeEventListener(EventConst.ON_MAP_MARK_TRACE_ADD, self.addMapMarkTrace)

	self.curComponent = nil
	self.curTabType = nil
	self.curTabIndex = nil
	self._pendingGroupIndex = nil

	UICtrl.onDestroy(self)
end

function SchoolGuideCtrl:onOpen(info)
	UICtrl.onOpen(self, info)
	self:refreshUI()

	local clickType = info and type(info[1]) == "number" and info[1] or nil
	local clickGroup = info and type(info[2]) == "number" and info[2] or nil

	self._pendingGroupIndex = clickGroup
	self.isProgrammaticFirstTabSelect = true

	local ok, err = pcall(function()
		if not clickType then
			local result, firstTab = self.view.firstLevelTabUList:TryGetChildAt(0)

			if result then
				firstTab:OnClickSimulate()
			end
		else
			local allData = self.view.firstLevelTabUList.itemData

			for idx, data in pairs(allData) do
				if data.tabType == clickType then
					local result, firstTab = self.view.firstLevelTabUList:TryGetChildAt(idx)

					if result then
						firstTab:OnClickSimulate()
					end

					break
				end
			end
		end
	end)

	self.isProgrammaticFirstTabSelect = false
	self._pendingGroupIndex = nil

	if not ok then
		error(err)
	end
end

function SchoolGuideCtrl:onShow()
	pg.game.audio:playEvent("SFX_UI_CollegeRecords_MoveIn")
end

function SchoolGuideCtrl:refreshConsoleBarState()
	if self.curTabType == SchoolGuideConst.EventType.BadgeCollection then
		Navigation.ConsoleBar.SetStateForAll("UI_SchoolGuide_Choose", true)
	else
		Navigation.ConsoleBar.SetStateForAll("UI_SchoolGuide_Choose", false)
	end
end

function SchoolGuideCtrl:onHide()
	return
end

function SchoolGuideCtrl:refreshUI()
	self.view.infoBtn.enabledTooltip = false

	self.view.listCurrencyUList:SetList({
		{
			itemId = VITALITY_ID,
			maxValue = LuaUIUtils.getVitalityMaxStoreNum()
		}
	})

	local firstTabData = self.model:getFirstTabList()

	self:_addComponentsByExConfig(firstTabData)
	self.view.firstLevelTabUList:SetList(firstTabData)
end

function SchoolGuideCtrl:_setFirstTabInteractableState(index, interactable)
	if index == nil or not self.view.firstLevelTabUList then
		return
	end

	local flag, targetButton = self.view.firstLevelTabUList:TryGetChildAt(index)

	if flag and targetButton then
		targetButton.interactable = interactable
	end
end

function SchoolGuideCtrl:renderFirstTab(button, index, data)
	local objectReference = button:GetComponent("ObjectReference")
	local iconUImage = objectReference:GetRefValue("iconUImage")
	local txtNameUBaseText = objectReference:GetRefValue("txtNameUBaseText")
	local uIComUp2UComponent = objectReference:GetRefValue("uIComUp2UComponent")

	iconUImage.url = data.icon

	ClientTextUtils.setText(txtNameUBaseText, pg.getLocalizationText(data.tabName))

	if data.tabType == SchoolGuideConst.EventType.BattleChallenge then
		local isOpen, eventId = ActivityUtils.isOprActivityUpOpenByType(ActivityConst.EventType.MockBattle)

		uIComUp2UComponent:SetActive(isOpen)
	else
		uIComUp2UComponent:SetActive(false)
	end

	button.interactable = self.curTabType ~= data.tabType

	function button.luaClick()
		if not self.isProgrammaticFirstTabSelect and self.curTabType == data.tabType then
			return
		end

		self:_setFirstTabInteractableState(self.curTabIndex, true)

		self.curTabType = data.tabType
		self.curTabIndex = index
		button.interactable = false

		self:refreshConsoleBarState()
		self.view.firstLevelTabUList:DeselectAll()
		self.view.firstLevelTabUList:SelectItem(index)

		local targetComponent

		if data.tabType == SchoolGuideConst.EventType.DailyActive then
			self.view.widget:TryChangePage("Content", "DailyActive")

			targetComponent = self:_getComponentByExConfig(data.cfgId)
		elseif data.tabType == SchoolGuideConst.EventType.BadgeCollection then
			self.view.widget:TryChangePage("Content", 2)

			targetComponent = self:_getComponentByExConfig(data.cfgId)
		elseif data.tabType == SchoolGuideConst.EventType.ItemCraft then
			self.view.widget:TryChangePage("Content", "ItemCrafting")

			targetComponent = self:_getComponentByExConfig(data.cfgId)
		elseif data.tabType == SchoolGuideConst.EventType.BossChallenge then
			self.view.widget:TryChangePage("Content", "GameGuide")

			targetComponent = self.gameGuideComponent
		else
			self.view.widget:TryChangePage("Content", "HolographicTraining")

			targetComponent = self.mockGuideComponent
		end

		if self.curComponent then
			self.curComponent:exit()
		end

		self.curComponent = targetComponent

		if self.curComponent then
			local groupIndex = targetComponent == self.gameGuideComponent and self._pendingGroupIndex or nil

			self._pendingGroupIndex = nil

			self.curComponent:enter(data.tabType, groupIndex)
			self.view.listCurrencyUList:SetActive(SchoolData[data.tabType].energySwitch == 1)
			self:refreshRuleButtonShow(data.tabType)
		end
	end

	self:_setFirstTabRed(button, index, data)
end

function SchoolGuideCtrl:onPlayerTeleport()
	self:dismiss()
end

function SchoolGuideCtrl:onRefreshCurrencyList()
	if self.view.listCurrencyUList then
		self.view.listCurrencyUList:SetList({
			{
				itemId = VITALITY_ID,
				maxValue = LuaUIUtils.getVitalityMaxStoreNum()
			}
		})
	end

	if self.curComponent == self.itemCraftUContainer then
		self.itemCraftUContainer:onRefreshCurrencyList()
	end
end

function SchoolGuideCtrl:onAddMapMarkTrace(markType, spawnerId, data)
	self:dismiss()
end

function SchoolGuideCtrl:onBadgeOpenChanged()
	if self.curComponent == self.medalUContainer then
		self.medalUContainer:onBadgeOpenChanged()
	end
end

function SchoolGuideCtrl:_addComponentsByExConfig(firstTabData)
	for _, v in pairs(firstTabData) do
		local info = SchoolGuideCtrl.EXConfigTypeInfo[v.cfgId]

		if info then
			self[info.container] = info.cls.new(self, self.view[info.container], v.cfgId)
		end
	end
end

function SchoolGuideCtrl:_getComponentByExConfig(cfgId)
	local info = SchoolGuideCtrl.EXConfigTypeInfo[cfgId]

	if info then
		return self[info.container]
	end

	return nil
end

function SchoolGuideCtrl:_setFirstTabRed(button, index, data)
	local cmp = self:_getComponentByExConfig(data.cfgId)

	if cmp then
		cmp:setFirstTabRed(button, index, data)
	end
end

function SchoolGuideCtrl:onItemCountChanged()
	if self.view.listCurrencyUList then
		self.view.listCurrencyUList:RefreshList()
	end

	if self.curComponent == self.medalUContainer then
		self.medalUContainer:onItemCountChanged()
	elseif self.curComponent == self.itemCraftUContainer then
		self.itemCraftUContainer:onItemCountChanged()
	end
end

function SchoolGuideCtrl:onEventAppRedDotChanged()
	self.view.firstLevelTabUList:RefreshList()
end

function SchoolGuideCtrl:onUIClose(uid)
	if not uid or not UIConst.UI_CONFIGS[uid] or UIConst.UI_CONFIGS[uid].uiType == UIConst.INFOS_LAYER or UIConst.UI_CONFIGS[uid].uiType == UIConst.POPUP_LAYER then
		return
	end

	if self.curComponent then
		if self.curComponent == self.dailyActiveUContainer then
			self.curComponent:enter()
		elseif self.curComponent.refreshUI then
			self.curComponent:refreshUI()
		end
	end
end

function SchoolGuideCtrl:onDayUpdate()
	if self.curComponent and self.curComponent.onDayUpdate then
		self.curComponent:onDayUpdate()
	end

	self:refreshUI()
end

function SchoolGuideCtrl:onRefreshRedDot()
	local data = self.view.firstLevelTabUList and self.view.firstLevelTabUList.itemData

	if not data then
		return
	end

	for i = 1, data.Count do
		local index = i - 1
		local flag, button = self.view.firstLevelTabUList:TryGetChildAt(index)

		if flag then
			self:_setFirstTabRed(button, index, data[index])
		end
	end
end

function SchoolGuideCtrl:onInputDeviceChanged()
	if self.curTabType == nil then
		return
	end

	self:refreshRuleButtonShow(self.curTabType)
end

function SchoolGuideCtrl:refreshRuleButtonShow(tabType)
	local isGamepad = pg.game.input:isUsingGamepad()
	local isShow = SchoolData[tabType].ruleId ~= nil and not isGamepad

	self.view.rulesUWidget:SetActive(isShow)
end

return SchoolGuideCtrl
