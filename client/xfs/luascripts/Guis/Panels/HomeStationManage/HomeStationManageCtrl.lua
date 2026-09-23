-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\HomeStationManage\\HomeStationManageCtrl.lua

local logger = require("Core.Log.LoggerManager").getLogger("HomeStationManageCtrl")
local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local UICtrl = require("Guis.UICtrl")
local HomeChangeStationComponent = require("Guis.Panels.HomeStationManage.Component.HomeChangeStationComponent")
local HomeCurrentStationComponent = require("Guis.Panels.HomeStationManage.Component.HomeCurrentStationComponent")
local HomeStationSearchComponent = require("Guis.Panels.HomeStationManage.Component.HomeStationSearchComponent")
local ClientTextUtils = require("Utils.ClientTextUtils")
local TimerManager = require("Core.Timer.TimerManager")
local KeyBindingPro = CS.FunPlus.WorldX.GUIS.Panels.Utils.KeyBindingPro
local HomeStationManageCtrl = Class.LightClass("HomeStationManageCtrl", UICtrl)
local CONSOLE_BAR_LISTENER_NAME = "HomeStationManage"
local NAV_GROUP_PLAYER_SLOTS = "ListPlayerSlots"
local PAGE_INDEX_CURRENT_STATION = 0

HomeStationManageCtrl.messages = {
	[MessageName.HOME_CUR_CAMP_STATIC_ID_CHANGED] = {
		"onCurCampStaticIdChanged",
		true
	}
}

function HomeStationManageCtrl:onCurCampStaticIdChanged()
	self:refreshHomeStationPage()
end

function HomeStationManageCtrl:onCreate(info)
	UICtrl.onCreate(self, info)

	self.homeCurrentStationComponent = HomeCurrentStationComponent.new(self, self.view.stationManageUContainer)
	self.homeChangeStationComponent = HomeChangeStationComponent.new(self, self.view.campSwitchUContainer, {
		inStationManage = true
	})
	self.homeStationSearchComponent = HomeStationSearchComponent.new(self, self.view.stationSearchUContainer)
end

function HomeStationManageCtrl:getTabList()
	local campId = pg.me.curCampStaticId
	local tabList = {}

	if campId and campId ~= 0 then
		table.insert(tabList, {
			clickFunc = "clickCurrentStation",
			tIndex = 0,
			name = pg.getGameString("HOMECAR_CURRENT_STATION")
		})
	end

	table.insert(tabList, {
		clickFunc = "clickChangeStation",
		tIndex = 1,
		name = pg.getGameString("HOMECAR_CHANGE_STATION")
	})
	table.insert(tabList, {
		clickFunc = "clickStationSearch",
		tIndex = 2,
		name = pg.getGameString("HOMECAR_STATION_SEARCH")
	})

	if #tabList == 2 then
		tabList[1].tIndex = 0
	end

	return tabList
end

function HomeStationManageCtrl:addListener()
	ClientTextUtils.setText(self.view.tMPUSDFText, pg.getGameString("HOME_CAMP_CAR_CAMP_MGR"))

	function self.view.btnBackUButton.luaClick()
		self:close()
	end

	function self.view.listTabUList.luaRenderItem(button, index, data)
		local objectReference = button:GetComponent("ObjectReference")
		local name1 = objectReference:GetRefValue("name1")
		local name2 = objectReference:GetRefValue("name2")

		ClientTextUtils.setText(name1, data.name)
		ClientTextUtils.setText(name2, data.name)

		function button.luaClick()
			if data.clickFunc then
				self.view.stationManageUContainer:SetActive(false)
				self.view.campSwitchUContainer:SetActive(false)
				self.view.stationSearchUContainer:SetActive(false)
				self[data.clickFunc](self)
			end
		end
	end

	if pg.global.navMgr then
		pg.global.navMgr:AddLuaFocusCursorMovedListener(CONSOLE_BAR_LISTENER_NAME, function()
			self:refreshConsoleBarState()
		end)
		pg.global.navMgr:AddLuaHotkeyActivationChangedListener(CONSOLE_BAR_LISTENER_NAME, function()
			self:refreshConsoleBarState()
		end)
	end
end

function HomeStationManageCtrl:onDestroy()
	if pg.global.navMgr then
		pg.global.navMgr:RemoveLuaFocusCursorMovedListener(CONSOLE_BAR_LISTENER_NAME)
		pg.global.navMgr:RemoveLuaHotkeyActivationChangedListener(CONSOLE_BAR_LISTENER_NAME)
	end

	if self.focusFirstSlotTimer then
		TimerManager.removeTimer(self.focusFirstSlotTimer)

		self.focusFirstSlotTimer = nil
	end

	UICtrl.onDestroy(self)
end

function HomeStationManageCtrl:onOpen(info)
	UICtrl.onOpen(self, info)

	self.choosePage = nil

	self:refreshHomeStationPage()
end

function HomeStationManageCtrl:refreshHomeStationPage()
	local tabList = self:getTabList()

	self.view.listTabUList:SetList(tabList)

	local selectIndex = self.choosePage or 0
	local res, button = self.view.listTabUList:TryGetChildAt(selectIndex)

	if res then
		button:OnClickSimulate()
	else
		local _res, _button = self.view.listTabUList:TryGetChildAt(0)

		if _res then
			_button:OnClickSimulate()
		end
	end
end

function HomeStationManageCtrl:clickCurrentStation()
	if self.choosePage == PAGE_INDEX_CURRENT_STATION then
		return
	end

	self.choosePage = PAGE_INDEX_CURRENT_STATION

	self.view.stationManageUContainer:SetActive(true)
	self.homeCurrentStationComponent:refreshPageInfo()
	self:requestFocusFirstSlot()
	self:refreshConsoleBarState()
end

function HomeStationManageCtrl:clickChangeStation()
	if self.choosePage == 1 then
		return
	end

	self.choosePage = 1

	self.view.campSwitchUContainer:SetActive(true)
	self.homeChangeStationComponent:refreshPageInfo()
	self:refreshConsoleBarState()
end

function HomeStationManageCtrl:clickStationSearch()
	if self.choosePage == 2 then
		return
	end

	self.choosePage = 2

	self.view.stationSearchUContainer:SetActive(true)
	self.homeStationSearchComponent:refreshPageInfo()
	self:refreshConsoleBarState()
end

function HomeStationManageCtrl:requestFocusFirstSlot()
	if self.focusFirstSlotTimer then
		TimerManager.removeTimer(self.focusFirstSlotTimer)

		self.focusFirstSlotTimer = nil
	end

	self.focusFirstSlotTimer = TimerManager.addNextFrameCb(function()
		self.focusFirstSlotTimer = nil

		if self.homeCurrentStationComponent and self.homeCurrentStationComponent.focusFirstSlot then
			self.homeCurrentStationComponent:focusFirstSlot()
		end
	end)
end

function HomeStationManageCtrl:isCurrentUserManager()
	local campInfo = pg.me:getPlayerHomeCampInfo()

	if not campInfo or not campInfo.lineInfo then
		return false
	end

	return campInfo.lineInfo.ownerUid == pg.me.uid
end

function HomeStationManageCtrl:getCurrentFocusedSlot()
	local component = self.homeCurrentStationComponent

	if component and component.getFocusedSlotInfo then
		local info = component:getFocusedSlotInfo()

		if info then
			return info
		end
	end

	local navMgr = CS.XGUI.Navigation.NavManager.Instance

	if not navMgr or navMgr.CurrentFocusedGroupName ~= NAV_GROUP_PLAYER_SLOTS then
		return nil
	end

	local navItem = navMgr.CurrentFocusedUContent

	return navItem and navItem.dataFromUList or nil
end

function HomeStationManageCtrl:refreshConsoleBarState()
	local consoleBar = CS.XGUI.Navigation.ConsoleBar

	if not consoleBar or not consoleBar.SetStateForAll then
		return
	end

	local isCurrentTab = self.choosePage == PAGE_INDEX_CURRENT_STATION
	local focusInfo = isCurrentTab and self:getCurrentFocusedSlot() or nil
	local hasFocus = focusInfo ~= nil
	local isEmpty = hasFocus and focusInfo.isEmpty == true
	local focusUid = focusInfo and focusInfo.uid or nil
	local isPlayer = hasFocus and focusUid ~= nil
	local isOtherPlayer = isPlayer and focusUid ~= pg.me.uid
	local isManager = self:isCurrentUserManager() == true

	consoleBar.SetStateForAll("canChangePosition", not not isCurrentTab and not not hasFocus and not not isEmpty)
	consoleBar.SetStateForAll("canViewPlayer", not not isCurrentTab and not not isPlayer)
	consoleBar.SetStateForAll("canKickMember", not not isCurrentTab and not not isOtherPlayer and not not isManager)
	consoleBar.SetStateForAll("canCopyStationId", not not isCurrentTab)
end

function HomeStationManageCtrl:bindVirtualHotKey(actionPath, bindName, func)
	local target = self.view and self.view.transform and self.view.transform.gameObject

	if not target then
		return
	end

	local bind = KeyBindingPro.GetOrAddKeyBindingByName(target, bindName)

	bind.actionPath = actionPath
	bind.isVirtual = true
	bind.priority = -1

	function bind.luaTrigger(inputInfo)
		if inputInfo.phase == "Performed" then
			if not pg.game.input or not pg.game.input:isUsingGamepad() then
				return
			end

			func()
		end
	end
end

function HomeStationManageCtrl:onShow()
	return
end

function HomeStationManageCtrl:onHide()
	return
end

return HomeStationManageCtrl
