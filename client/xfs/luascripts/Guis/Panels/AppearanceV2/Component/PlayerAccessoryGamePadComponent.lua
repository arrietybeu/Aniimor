-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\AppearanceV2\\Component\\PlayerAccessoryGamePadComponent.lua

local Class = require("Core.Framework.Class")
local UIComponent = require("Guis.Helper.UIComponent")
local UISceneConst = require("GameApp.UIScene.UISceneConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local PlayerAccessoryGamePadComponent = Class.LightClass("PlayerAccessoryGamePadComponent", UIComponent)
local GamePadNavigation = require("Utils.GamePadNavigation")

function PlayerAccessoryGamePadComponent:findObjects()
	self.root = self.transform
	self.navigation = GamePadNavigation.new(self)

	self:initAreas()
end

function PlayerAccessoryGamePadComponent:initView()
	self.avatarScene = pg.game.uiScene:getScene(UISceneConst.AVATAR_SCENE)
	self.zoomSpeed = 0.2
	self.rotateRatioX = 15
	self.rotateRatioY = 10
end

function PlayerAccessoryGamePadComponent:initAreas()
	self.navigation.AREAS = {
		SLOT_AREA = 1,
		AREA_VALUE_ADJUST = 4,
		AREA_SOURCE = 3,
		ACCESSORY_AREA = 2
	}
	self.navigation.SLOT_AREA = {
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.SLOT_AREA,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.SLOT_AREA,
		[self.navigation.MOVE_DIRECTION.RIGHT] = self.navigation.AREAS.ACCESSORY_AREA,
		matchType = self.navigation.MATCH_MODE.MATCH_OLD_CACHE,
		OutAreaActionPost = function(slot)
			if slot == nil then
				return
			end

			slot:Select()
		end,
		EnterAreaAction = function(slot)
			for _, subList in ipairs(self.navigation.SLOT_AREA) do
				for _, v in ipairs(subList) do
					v:DisFocus()
				end
			end
		end,
		CheckCanMoveOut = function(slot, newArea)
			if newArea ~= self.navigation.AREAS.ACCESSORY_AREA then
				return true
			end

			return slot.CheckCanMoveOut()
		end
	}
	self.navigation.ACCESSORY_AREA = {
		[self.navigation.MOVE_DIRECTION.LEFT] = self.navigation.AREAS.SLOT_AREA,
		[self.navigation.MOVE_DIRECTION.RIGHT] = self.navigation.AREAS.ACCESSORY_AREA,
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.ACCESSORY_AREA,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.ACCESSORY_AREA,
		EnterAreaSelectedSlot = function(areaTable)
			local slotItem = self.view.tabUList.selectedItem

			if IsNil(slotItem) then
				return nil
			end

			for i, map in ipairs(areaTable) do
				for j, v in ipairs(map) do
					if v:GetData().accessoryId == slotItem.accessoryId then
						return {
							x = i,
							y = j
						}
					end
				end
			end

			return nil
		end
	}
	self.navigation.AREA_SOURCE = {
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.AREA_SOURCE,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.AREA_SOURCE
	}
	self.navigation.AREA_VALUE_ADJUST = {
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.AREA_VALUE_ADJUST,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.AREA_VALUE_ADJUST
	}
	self.navigation.AREA_TABLES = {
		self.navigation.SLOT_AREA,
		self.navigation.ACCESSORY_AREA,
		self.navigation.AREA_SOURCE,
		self.navigation.AREA_VALUE_ADJUST
	}
end

function PlayerAccessoryGamePadComponent:bind_SlotArea(xBtnList)
	local btnList = xBtnList:GetAllButtons()
	local t = {}

	for i = 0, btnList.Length - 1 do
		local v = btnList[i]

		i = i + 1
		t[i] = {}
		t[i][1] = {
			Focus = function(x, y)
				if v.dataFromUList.state ~= LuaUIUtils.SLOT_STATE.LOCKED then
					v.isSelected = true
				end

				v:TryChangePage("GamePadFocus", 1)
				self.navigation:baseFocus(t, x, y, self.view.consoleKeyUList)
				xBtnList:GoToItem(v)
			end,
			DisFocus = function(x, y)
				v:TryChangePage("GamePadFocus", 0)
			end,
			Select = function()
				v.isSelected = true

				v:TryChangePage("GamePadFocus", 2)
			end,
			CheckCanMoveOut = function()
				return self.ctrl:checkSlotCanFocus(v.dataFromUList)
			end
		}

		if v.dataFromUList.state ~= LuaUIUtils.SLOT_STATE.EMPTY then
			t[i][1].Fun1 = function(x, y)
				v:OnClickSimulate()
			end

			if v.dataFromUList.state == LuaUIUtils.SLOT_STATE.HAVE then
				t[i][1].Fun1Name = pg.getGameString("ACCESSORY_UN_EQUIP")
			elseif v.dataFromUList.state == LuaUIUtils.SLOT_STATE.LOCKED then
				t[i][1].Fun1Name = pg.getGameString("ACCESSORY_UNLOCK")
			end
		end

		t[i][1].Fun3 = function(x, y)
			self.ctrl:closePanel()
		end
		t[i][1].Fun3Name = pg.getGameString("CHARACTER_REWARDS_CANCEL")

		if self.ctrl:checkSlotCanFocus(v.dataFromUList) then
			t[i][1].Fun4 = function(x, y)
				self:focusArea(self.navigation.AREAS.ACCESSORY_AREA)
			end

			if v.dataFromUList.state == LuaUIUtils.SLOT_STATE.EMPTY then
				t[i][1].Fun4Name = pg.getGameString("ACCESSORY_EQUIP")
			else
				t[i][1].Fun4Name = pg.getGameString("CHARACTER_LEVEL_DETAIL")
			end
		end

		t[i][1].Fun7Name = pg.getGameString("ACCESSORY_CAMERA_ZOOM_IN")
		t[i][1].Fun7 = function(x, y)
			self.avatarScene:cameraZoomIn(-self.zoomSpeed)
		end
		t[i][1].Fun8Name = pg.getGameString("ACCESSORY_CAMERA_ZOOM_OUT")
		t[i][1].Fun8 = function(x, y)
			self.avatarScene:cameraZoomIn(self.zoomSpeed)
		end
		t[i][1].Fun18Name = pg.getGameString("ACCESSORY_ROTATE")
		t[i][1].Fun18 = function(moveX, moveY)
			self.avatarScene:swipeModel({
				x = moveX * self.rotateRatioX,
				y = moveY * self.rotateRatioY
			})
		end
	end

	self.navigation:initAreaTableSlots(self.navigation.SLOT_AREA, t)
end

function PlayerAccessoryGamePadComponent:bind_AccessoriesArea(xBtnList)
	local btnList = xBtnList:GetAllButtons()
	local t = {}

	for i = 0, btnList.Length - 1 do
		local v = btnList[i]

		i = i + 1

		local colNum = 3
		local m = math.floor((i - 1) / colNum) + 1
		local n = (i - 1) % colNum + 1

		t[m] = t[m] or {}
		t[m][n] = {
			Focus = function(x, y)
				v:TryChangePage("GamePadFocus", 1)
				self.navigation:baseFocus(t, x, y, self.view.consoleKeyUList)
				xBtnList:GoToItem(v)
			end,
			DisFocus = function(x, y)
				v:TryChangePage("GamePadFocus", 0)
			end,
			GetData = function()
				return v.dataFromUList
			end
		}
		t[m][n].Fun3 = function(x, y)
			self:focusArea(self.navigation.AREAS.SLOT_AREA)
		end
		t[m][n].Fun3Name = pg.getGameString("CHARACTER_REWARDS_CANCEL")
		t[m][n].Fun4 = function(x, y)
			v:OnClickSimulate()
		end

		if not self.ctrl:checkAccessoryHave(v.dataFromUList) then
			t[m][n].Fun4Name = pg.getGameString("CHARACTER_LEVEL_DETAIL")
		elseif not self.ctrl:checkAccessoryEquipped(v.dataFromUList) then
			t[m][n].Fun4Name = pg.getGameString("ACCESSORY_EQUIP")
		else
			t[m][n].Fun4Name = pg.getGameString("ACCESSORY_UN_EQUIP")
		end

		if not self.ctrl:checkAccessoryHave(v.dataFromUList) then
			t[m][n].Fun6 = function(x, y)
				self:focusArea(self.navigation.AREAS.AREA_SOURCE)
			end
			t[m][n].Fun6Name = pg.getGameString("ACCESSORY_SOURCE")
		end

		t[m][n].Fun7Name = pg.getGameString("ACCESSORY_CAMERA_ZOOM_IN")
		t[m][n].Fun7 = function(x, y)
			self.avatarScene:cameraZoomIn(-self.zoomSpeed)
		end
		t[m][n].Fun8Name = pg.getGameString("ACCESSORY_CAMERA_ZOOM_OUT")
		t[m][n].Fun8 = function(x, y)
			self.avatarScene:cameraZoomIn(self.zoomSpeed)
		end
		t[m][n].Fun18Name = pg.getGameString("ACCESSORY_ROTATE")
		t[m][n].Fun18 = function(moveX, moveY)
			self.avatarScene:swipeModel({
				x = moveX * self.rotateRatioX,
				y = moveY * self.rotateRatioY
			})
		end
	end

	self.navigation:initAreaTableSlots(self.navigation.ACCESSORY_AREA, t)
end

function PlayerAccessoryGamePadComponent:bind_SourceArea(xBtnList)
	local btnList = xBtnList:GetAllButtons()
	local t = {}

	for i = 0, btnList.Length - 1 do
		local v = btnList[i]

		i = i + 1
		t[i] = {}
		t[i][1] = {
			Focus = function(x, y)
				v:TryChangePage("GamePadFocus", 1)
				self.navigation:baseFocus(t, x, y, self.view.consoleKeyUList)
				xBtnList:GoToItem(v)
			end,
			DisFocus = function(x, y)
				v:TryChangePage("GamePadFocus", 0)
			end
		}
		t[i][1].Fun3 = function(x, y)
			self:focusArea(self.navigation.AREAS.ACCESSORY_AREA)
		end
		t[i][1].Fun3Name = pg.getGameString("CHARACTER_REWARDS_CANCEL")
		t[i][1].Fun4 = function(x, y)
			v:OnClickSimulate()
		end
		t[i][1].Fun4Name = pg.getGameString("CHARACTER_LEVEL_DETAIL")
		t[i][1].Fun7Name = pg.getGameString("ACCESSORY_CAMERA_ZOOM_IN")
		t[i][1].Fun7 = function(x, y)
			self.avatarScene:cameraZoomIn(-self.zoomSpeed)
		end
		t[i][1].Fun8Name = pg.getGameString("ACCESSORY_CAMERA_ZOOM_OUT")
		t[i][1].Fun8 = function(x, y)
			self.avatarScene:cameraZoomIn(self.zoomSpeed)
		end
		t[i][1].Fun18Name = pg.getGameString("ACCESSORY_ROTATE")
		t[i][1].Fun18 = function(moveX, moveY)
			self.avatarScene:swipeModel({
				x = moveX * self.rotateRatioX,
				y = moveY * self.rotateRatioY
			})
		end
	end

	self.navigation:initAreaTableSlots(self.navigation.AREA_SOURCE, t)
end

function PlayerAccessoryGamePadComponent:bind_AdjustArea(xBtnList)
	local btnList = xBtnList:GetAllButtons()
	local t = {}
	local i = 1

	for m = 0, btnList.Length - 1 do
		local sBtn = btnList[m]
		local oc = sBtn:GetComponent("ObjectReference")
		local xList = oc:GetRefValue("contentUList")
		local cBtn = xList:GetAllButtons()

		for n = 0, cBtn.Length - 1 do
			local v = cBtn[n]

			t[i] = {}
			t[i][1] = {
				Focus = function(x, y)
					v:TryChangePage("GamePadFocus", 1)
					self.navigation:baseFocus(t, x, y, self.view.consoleKeyUList)
					xBtnList:GoToItem(m)
				end,
				DisFocus = function(x, y)
					v:TryChangePage("GamePadFocus", 0)
				end
			}
			t[i][1].Fun3 = function(x, y)
				self.view.rootUComponent:TryChangePage("State", "Normal")
				self:focusArea(self.navigation.AREAS.ACCESSORY_AREA)
			end
			t[i][1].Fun3Name = pg.getGameString("CHARACTER_REWARDS_CANCEL")
			t[i][1].Fun4Name = pg.getGameString("ACCESSORY_SAVE")
			t[i][1].Fun4 = function(x, y)
				self.ctrl:saveEditor()
				self:focusArea(self.navigation.AREAS.ACCESSORY_AREA)
			end
			t[i][1].Fun7Name = pg.getGameString("ACCESSORY_CAMERA_ZOOM_IN")
			t[i][1].Fun7 = function(x, y)
				self.avatarScene:cameraZoomIn(-self.zoomSpeed)
			end
			t[i][1].Fun8Name = pg.getGameString("ACCESSORY_CAMERA_ZOOM_OUT")
			t[i][1].Fun8 = function(x, y)
				self.avatarScene:cameraZoomIn(self.zoomSpeed)
			end
			t[i][1].Fun17Name = pg.getGameString("ACCESSORY_ADJUST")
			t[i][1].Fun17 = function(moveX, moveY)
				local subOc = v:GetComponent("ObjectReference")
				local slider = subOc:GetRefValue("sliderUSlider")

				if self.navigation.leftStickContinueMoveDelay == self.navigation.LEFT_STICK_MOVE_DELAY_FAST then
					slider.value = slider.value + slider.stepSize * 4 * (moveX / math.abs(moveX))
				else
					slider.value = slider.value + slider.stepSize * 2 * (moveX / math.abs(moveX))
				end
			end
			t[i][1].Fun18Name = pg.getGameString("ACCESSORY_ROTATE")
			t[i][1].Fun18 = function(moveX, moveY)
				self.avatarScene:swipeModel({
					x = moveX * self.rotateRatioX,
					y = moveY * self.rotateRatioY
				})
			end
			i = i + 1
		end
	end

	self.navigation:initAreaTableSlots(self.navigation.AREA_VALUE_ADJUST, t)
end

function PlayerAccessoryGamePadComponent:onInputDeviceChanged(deviceType)
	if pg.game.input:isUsingGamepad() then
		self:reFocusSlotArea()
	else
		self.navigation:clearNavigation()
	end
end

function PlayerAccessoryGamePadComponent:onDestroy()
	self.root = nil
	self.navigation = nil

	UIComponent.onDestroy(self)
end

function PlayerAccessoryGamePadComponent:focusArea(area, x, y)
	self.navigation:laterFramesFocus(function()
		self.navigation:specificSet(area, x, y)
	end, 1)
end

function PlayerAccessoryGamePadComponent:reFocusSlotArea()
	self:focusArea(self.navigation.AREAS.SLOT_AREA, 1, 1)
end

return PlayerAccessoryGamePadComponent
