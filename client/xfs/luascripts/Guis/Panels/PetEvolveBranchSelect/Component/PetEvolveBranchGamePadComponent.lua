-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\PetEvolveBranchSelect\\Component\\PetEvolveBranchGamePadComponent.lua

local LoggerManager = require("Core.Log.LoggerManager")
local LoggerConst = require("Core.Log.LoggerConst")
local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local TimerManager = require("Core.Timer.TimerManager")
local UIComponent = require("Guis.Helper.UIComponent")
local PetEvolveBranchGamePadComponent = Class.LightClass("PetEvolveBranchGamePadComponent", UIComponent)
local GamePadNavigation = require("Utils.GamePadNavigation")
local logger = LoggerManager.getLogger("PetEvolveBranchGamePadComponent")

function PetEvolveBranchGamePadComponent:findObjects()
	self.root = self.view.root
	self.navigation = GamePadNavigation.new(self)
	self.navigation.longPressDelay = 0.55

	self:initAreas()
end

function PetEvolveBranchGamePadComponent:initView()
	self.navigation:addConsoleEvent(self.navigation:initCommonLeftStickMoveData(self.root.gameObject))
	self.navigation:addConsoleEvent(self.navigation:initCommonKeyData("LS", self.root.gameObject))
	self.navigation:addConsoleEvent(self.navigation:initCommonKeyData("RS", self.root.gameObject))
	self.navigation:addConsoleEvent(self.navigation:initCommonKeyData("B", self.root.gameObject))
	self.navigation:addConsoleEvent(self.navigation:initCommonKeyData("A", self.root.gameObject))
end

function PetEvolveBranchGamePadComponent:initAreas()
	self.navigation.AREAS = {
		PET_EVOLVE_CONDITION_AREA = 1,
		PET_EVOLVE_ITEM_DETAIL_AREA = 2
	}
	self.navigation.PET_EVOLVE_CONDITION_AREA = {
		[self.navigation.MOVE_DIRECTION.LEFT] = self.navigation.AREAS.PET_EVOLVE_CONDITION_AREA,
		[self.navigation.MOVE_DIRECTION.RIGHT] = self.navigation.AREAS.PET_EVOLVE_CONDITION_AREA
	}
	self.navigation.PET_EVOLVE_ITEM_DETAIL_AREA = {}
	self.navigation.AREA_TABLES = {
		self.navigation.PET_EVOLVE_CONDITION_AREA,
		self.navigation.PET_EVOLVE_ITEM_DETAIL_AREA
	}
end

function PetEvolveBranchGamePadComponent:onInputDeviceChanged(deviceType)
	self:unlockEvolveDetailArea()

	if pg.game.input:isUsingGamepad() then
		self.navigation:specificSet(self.navigation.AREAS.PET_EVOLVE_CONDITION_AREA, 1, 1)
		self.navigation:reFocus()
		self.view.condtionConsoleSelected:TryChangePage("GamePadFocus", 1)
	else
		self.view.condtionConsoleSelected:TryChangePage("GamePadFocus", 0)
	end
end

function PetEvolveBranchGamePadComponent:initPetEvolveConditionArea(branchInfos)
	local t = {}

	for i = 1, #branchInfos do
		local data = branchInfos[i]
		local x = 1
		local y = i

		if t[x] == nil then
			t[x] = {}
		end

		t[x][y] = {}
		t[x][y].Focus = function(x1, y1)
			if self.ctrl.branchId ~= y then
				self.ctrl.branchId = y

				self.ctrl:showEvolveCondition()
			end

			if self.ctrl.petInfo:canEvolveBranch(self.ctrl.branchId) then
				t[x][y].Fun4 = function(x1, y1)
					self.view.btnEvolveUButton.luaClick()
				end
			end

			if self.view.branchInfoUWidget.bActive and self.ctrl.itemConditions then
				t[x][y].Fun5Name = pg.getGameString("PET_EVOLVE_LOCK")
				t[x][y].Fun5 = function(x1, y1)
					self:lockEvolveDetailArea()
				end
				t[x][y].Fun5IsImportant = true
			end

			self.navigation:baseFocus(t, x1, y1, self.view.consoleKeyUList)
		end
		t[x][y].Fun3Name = pg.getGameString("PET_EVOLVE_CANCEL")
		t[x][y].Fun3 = function(x1, y1)
			self.ctrl:dismiss()
		end
	end

	self.navigation:initAreaTableSlots(self.navigation.PET_EVOLVE_CONDITION_AREA, t)
end

function PetEvolveBranchGamePadComponent:initEvolveDetailArea(itemConditionData)
	local t = {}

	if itemConditionData ~= nil then
		for i = 1, #itemConditionData do
			local x = 1
			local y = i

			if t[x] == nil then
				t[x] = {}
			end

			t[x][y] = {}
			t[x][y].Focus = function(x1, y1)
				self.navigation:baseFocus(t, x1, y1, self.view.consoleKeyUList)

				local ret, button = self.view.itemList:TryGetChildAt(y1 - 1)

				self:unfocusRewardItem()
				self:focusRewardItem(button)
			end
			t[x][y].Fun3Name = pg.getGameString("PET_EVOLVE_CANCEL")
			t[x][y].Fun3 = function(x1, y1)
				self:unlockEvolveDetailArea()
			end

			if self.ctrl.petInfo:canEvolveBranch(self.ctrl.branchId) then
				t[x][y].Fun4 = function(x1, y1)
					self.view.btnEvolveUButton.luaClick()
				end
			end

			t[x][y].Fun5 = function(x1, y1)
				self:unlockEvolveDetailArea()
			end
			t[x][y].Fun5IsImportant = true
			t[x][y].Fun6Name = pg.getGameString("PET_EVOLVE_DETAIL")
			t[x][y].Fun6 = function(x1, y1)
				if pg.global.ui:checkUIOpen(UIConst.UI_ID_COMMON_ITEM_TIP) then
					pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)

					return
				end

				local ret, button = self.view.itemList:TryGetChildAt(y1 - 1)

				if button then
					button.luaClick()
				end
			end
		end
	end

	self.navigation:initAreaTableSlots(self.navigation.PET_EVOLVE_ITEM_DETAIL_AREA, t)
end

function PetEvolveBranchGamePadComponent:lockEvolveDetailArea()
	if LoggerManager.checkLogger(LoggerConst.INFO) then
		logger:info("锁定区域 ", self.markAreaId)
	end

	self.markAreaId = self.navigation.cursorArea
	self.markCcursorIndex = self.navigation.cursorIndex

	self.navigation:specificSet(self.navigation.AREAS.PET_EVOLVE_ITEM_DETAIL_AREA, 1, 1)
	self.navigation:reFocus()
	self.view.branchConsoleSelected:TryChangePage("GamePadFocus", 2)
end

function PetEvolveBranchGamePadComponent:unlockEvolveDetailArea()
	if self.markAreaId ~= nil then
		if LoggerManager.checkLogger(LoggerConst.INFO) then
			logger:info("解锁区域 ", self.markAreaId)
		end

		self.navigation:specificSet(self.markAreaId, self.markCcursorIndex.x, self.markCcursorIndex.y)
		self.navigation:reFocus()

		self.markAreaId = nil
		self.markCcursorIndex = nil
	end

	self:unfocusRewardItem()
	self.view.branchConsoleSelected:TryChangePage("GamePadFocus", 0)
end

function PetEvolveBranchGamePadComponent:focusRewardItem(itemBtn)
	if itemBtn == nil then
		return
	end

	local consoleSelected = itemBtn.transform:GetComponent("ObjectReference"):GetRefValue("consoleSelected")

	consoleSelected:TryChangePage("GamePadFocus", 1)

	self.curRewardItem = itemBtn
end

function PetEvolveBranchGamePadComponent:unfocusRewardItem()
	if pg.global.ui:checkUIOpen(UIConst.UI_ID_COMMON_ITEM_TIP) then
		pg.global.ui:close(UIConst.UI_ID_COMMON_ITEM_TIP)
	end

	if self.curRewardItem ~= nil then
		local consoleSelected = self.curRewardItem.transform:GetComponent("ObjectReference"):GetRefValue("consoleSelected")

		consoleSelected:TryChangePage("GamePadFocus", 0)

		self.curRewardItem = nil
	end
end

function PetEvolveBranchGamePadComponent:onDestroy()
	self.root = nil
	self.navigation = nil

	UIComponent.onDestroy(self)
end

return PetEvolveBranchGamePadComponent
