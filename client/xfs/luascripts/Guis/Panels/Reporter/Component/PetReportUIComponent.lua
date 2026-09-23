-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Reporter\\Component\\PetReportUIComponent.lua

local UIComponent = require("Guis.Helper.UIComponent")
local UIConst = require("Const.UIConst")
local Class = require("Core.Framework.Class")
local PetReportUIComponent = Class.LightClass("PetReportUIComponent", UIComponent)
local LuaUIUtils = require("Utils.LuaUIUtils")
local ItemData = require("Data.item_data")
local CallbackHandler = require("Core.Common.CallbackHandler")
local ClientTextUtils = require("Utils.ClientTextUtils")
local GamePadNavigation = require("Utils.GamePadNavigation")
local AudioConst = require("Const.AudioConst")

function PetReportUIComponent:findObjects()
	if IsNil(self.transform) then
		return
	end

	self.objectReference = self.transform:GetComponent("ObjectReference")
	self.component = self.objectReference:GetRefValue("component")
	self.exitBtn = self.objectReference:GetRefValue("exitBtn")
	self.takeBtn = self.objectReference:GetRefValue("takeBtn")
	self.petBoxList = self.objectReference:GetRefValue("petBoxList")
	self.rewardList = self.objectReference:GetRefValue("rewardList")
	self.submitTip = self.objectReference:GetRefValue("submitTip")

	function self.exitBtn.luaClick()
		self:switchReportState(false)
	end

	function self.takeBtn.luaClick()
		self:onTakeReward()
	end

	function self.petBoxList.luaRenderItem(item, index, data)
		self:instantiatePetBoxItem(item, index, data)
	end

	function self.rewardList.luaRenderItem(item, index, data)
		self:instantiateRewardItem(item, index, data)
	end

	self.navigation = GamePadNavigation.new(self)

	self:initAreas()
end

function PetReportUIComponent:initView()
	self.navigation:addConsoleEvent(self.navigation:initCommonLeftStickMoveData(self.view.gameObject))
	self.navigation:addConsoleEvent(self.navigation:initCommonKeyData("A", self.view.gameObject))
	self.navigation:addConsoleEvent(self.navigation:initCommonKeyData("B", self.view.gameObject))
	self.navigation:addConsoleEvent(self.navigation:initCommonKeyData("RS", self.view.gameObject))
end

function PetReportUIComponent:initAreas()
	self.navigation.AREAS = {
		MODE_PET = 1,
		MODE_REWARD = 2
	}
	self.navigation.MODE_PET = {
		[self.navigation.MOVE_DIRECTION.LEFT] = self.navigation.AREAS.MODE_REWARD,
		[self.navigation.MOVE_DIRECTION.RIGHT] = self.navigation.AREAS.MODE_REWARD,
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.MODE_REWARD,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.MODE_REWARD
	}
	self.navigation.MODE_REWARD = {
		[self.navigation.MOVE_DIRECTION.LEFT] = self.navigation.AREAS.MODE_REWARD,
		[self.navigation.MOVE_DIRECTION.RIGHT] = self.navigation.AREAS.MODE_REWARD,
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.MODE_REWARD,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.MODE_REWARD
	}
	self.navigation.AREA_TABLES = {
		self.navigation.MODE_PET,
		self.navigation.MODE_REWARD
	}
end

function PetReportUIComponent:onDestroy()
	UIComponent.onDestroy(self)
end

function PetReportUIComponent:switchReportState(active)
	pg.game.camera:enableNpcInteract(active)
	self.ctrl:setPageIndex(active and self.model.REPORTER or self.model.NONE)

	if not active then
		pg.global.ui:show(UIConst.UI_ID_INTERACT)
	else
		pg.global.ui:hide(UIConst.UI_ID_INTERACT)
		self:refreshView()
	end
end

function PetReportUIComponent:refreshView()
	local pets = self.model:getReportPets()

	self.petBoxList:SetList(pets)
	self:bindAreaSupplement(self.petBoxList, self.navigation.MODE_PET)

	self.rewardDate = self.model:getPetReportAwardList()

	self.rewardList:SetList(self.rewardDate)
	self:bindRewardAreaSupplement(self.rewardList, self.navigation.MODE_REWARD)
	self.navigation:laterFramesFocus(function()
		self.navigation:specificSet(self.navigation.AREAS.MODE_REWARD, 1, 1)
	end, 1)
	ClientTextUtils.setText(self.submitTip, pg.getGameString("NO_CONSUME_SUBMIT"))
	self.takeBtn:TryChangePage("guideLabel", 1)
end

function PetReportUIComponent:instantiatePetBoxItem(item, index, data)
	item.draggable = false

	if data.isEmpty then
		item:TryChangePage("state", 2)

		return
	else
		item:TryChangePage("state", 0)
	end

	local oc = item:GetComponent("ObjectReference")
	local iIcon = oc:GetRefValue("iconUImage")
	local iNumb = oc:GetRefValue("numCPUSDFText")
	local iElem = oc:GetRefValue("singleElement")

	if data.isShiny then
		item:TryChangePage("Type", 1)
	else
		item:TryChangePage("Type", 0)
	end

	iIcon.url = data.icon

	ClientTextUtils.setText(iNumb, string.format("LV.%d", data.lv))
	LuaUIUtils.setElementButtonNew(iElem, data.elements[1].element)
end

function PetReportUIComponent:instantiateRewardItem(item, index, data)
	LuaUIUtils.renderRewards(item, index, {
		type = 0,
		id = data.id,
		num = data.count
	})
end

function PetReportUIComponent:onTakeReward()
	local me = pg.me

	me:serverMsg("RPC_CS_PetCatchReport")
	self.ctrl:dismiss()
end

function PetReportUIComponent:callbackOnPetReporter()
	pg.game.audio:triggerEvent(AudioConst.EVENT_UI_PET_REPORTER)
	self:switchReportState(false)
end

function PetReportUIComponent:bindAreaSupplement(xBtnList, area)
	local btnList = xBtnList:GetAllButtons()
	local t = {}

	for i = 0, btnList.Length - 1 do
		local rv = btnList[i]

		i = i + 1

		local row = math.floor((i - 1) / 5) + 1
		local col = (i - 1) % 5 + 1

		if t[row] == nil then
			t[row] = {}
		end

		t[row][col] = {}

		self:bindBtnSupplement(t[row][col], rv, t)
	end

	self.navigation:initAreaTableSlots(area, t)
end

function PetReportUIComponent:bindRewardAreaSupplement(xBtnList, area)
	local btnList = xBtnList:GetAllButtons()
	local t = {
		{}
	}

	for i = 0, btnList.Length - 1 do
		local rv = btnList[i]

		i = i + 1
		t[1][i] = {}

		self:bindBtnSupplement(t[1][i], rv, t, true)
	end

	self.navigation:initAreaTableSlots(area, t)
end

function PetReportUIComponent:bindBtnSupplement(table, btn, tables, isItem)
	function table.Focus(x, y)
		if isItem then
			btn.transform:Find("ConsoleSelected"):GetComponent("UComponent"):TryChangePage("GamePadFocus", 1)
		else
			btn:TryChangePage("GamePadFocus", 1)
		end

		self.navigation:baseFocus(tables, x, y, self.view.keyList)
	end

	function table.DisFocus(x, y)
		if isItem then
			btn.transform:Find("ConsoleSelected"):GetComponent("UComponent"):TryChangePage("GamePadFocus", 0)
		else
			btn:TryChangePage("GamePadFocus", 0)
		end

		btn:ClosePopup()
	end

	function table.Fun3(x, y)
		self:switchReportState(false)
	end

	table.Fun3Name = pg.getGameString("CHARACTER_REWARDS_CANCEL")

	function table.Fun4(x, y)
		self:onTakeReward()
	end

	table.Fun4Name = pg.getGameString("CHARACTER_REWARDS_GET")

	function table.Fun6(x, y)
		if isItem and pg.global.ui:checkUIShow(UIConst.UI_ID_COMMON_ITEM_TIP) then
			pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)

			btn.isSelected = true
		else
			btn:OnClickSimulate()
		end
	end

	table.Fun6Name = pg.getGameString("CHARACTER_REWARDS_DETAIL")
end

function PetReportUIComponent:onInputDeviceChanged(deviceType)
	if pg.game.input:isUsingGamepad() then
		self.navigation:laterFramesFocus(function()
			self.navigation:specificSet(self.navigation.AREAS.MODE_PET, 1, 1)
		end, 1)
	else
		self.navigation:clearNavigation(deviceType)
	end
end

return PetReportUIComponent
