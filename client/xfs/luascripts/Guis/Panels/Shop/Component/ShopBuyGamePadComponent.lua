-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\Shop\\Component\\ShopBuyGamePadComponent.lua

local Class = require("Core.Framework.Class")
local UIConst = require("Const.UIConst")
local LuaUIUtils = require("Utils.LuaUIUtils")
local HotkeyConst = require("Const.HotkeyConst")
local TimerManager = require("Core.Timer.TimerManager")
local UIComponent = require("Guis.Helper.UIComponent")
local GamePadNavigation = require("Utils.GamePadNavigation")
local ShopBuyGamePadComponent = Class.LightClass("ShopBuyGamePadComponent", UIComponent)

function ShopBuyGamePadComponent:findObjects()
	self.root = self.view.transform
	self.navigation = GamePadNavigation.new(self)
	self.navigation.longPressDelay = 0.55
	self.onRightStickMoveCallback = nil
	self.rightStickMoveY = 0
	self.ltLongPress = false
	self.rtLongPress = false
	self.longPressMarkTime = nil

	self:initAreas()
end

function ShopBuyGamePadComponent:initView()
	self.navigation:addConsoleEvent(self.navigation:initCommonLeftStickMoveData(self.root.gameObject))
	self.navigation:addConsoleEvent(self:initRightStickMoveData())
	self.navigation:addConsoleEvent(self:initGamepadLTData())
	self.navigation:addConsoleEvent(self:initGamepadRTData())
	self.navigation:addConsoleEvent(self.navigation:initCommonKeyData("B", self.root.gameObject))
	self.navigation:addConsoleEvent(self.navigation:initCommonKeyData("A", self.root.gameObject))
	LuaUIUtils.bindHotKey(self.root.gameObject, HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadDUp, function()
		local maxCount = self.ctrl.shopBuyComponent.maxCount
		local selector = self.ctrl.shopBuyComponent:getPurchaseNumSelector()

		if selector and selector.value ~= maxCount then
			selector.value = maxCount
		end
	end)
	LuaUIUtils.bindHotKey(self.root.gameObject, HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadDDown, function()
		local selector = self.ctrl.shopBuyComponent:getPurchaseNumSelector()

		if selector and selector.value ~= 1 then
			selector.value = 1
		end
	end)

	self.rightTickTimer = self:startTimer(function()
		self:startTick()
	end, 0, true)
end

function ShopBuyGamePadComponent:addCount()
	local selector = self.ctrl.shopBuyComponent:getPurchaseNumSelector()

	if not selector then
		return
	end

	local curValue = selector.value

	if curValue < self.ctrl.shopBuyComponent.maxCount then
		curValue = curValue + 1
		selector.value = curValue
	end
end

function ShopBuyGamePadComponent:minusCount()
	local selector = self.ctrl.shopBuyComponent:getPurchaseNumSelector()

	if not selector then
		return
	end

	local curValue = selector.value

	if curValue > 1 then
		curValue = curValue - 1
		selector.value = curValue
	end
end

function ShopBuyGamePadComponent:initAreas()
	self.navigation.AREAS = {
		SHOP_PROP_DETAIL_AREA = 3,
		SHOP_PROP_LIST_AREA = 2,
		SHOP_TAG_LIST_AREA = 1
	}
	self.navigation.SHOP_TAG_LIST_AREA = {
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.SHOP_TAG_LIST_AREA,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.SHOP_TAG_LIST_AREA,
		[self.navigation.MOVE_DIRECTION.RIGHT] = self.navigation.AREAS.SHOP_PROP_LIST_AREA
	}
	self.navigation.SHOP_PROP_LIST_AREA = {
		[self.navigation.MOVE_DIRECTION.UP] = self.navigation.AREAS.SHOP_PROP_LIST_AREA,
		[self.navigation.MOVE_DIRECTION.DOWN] = self.navigation.AREAS.SHOP_PROP_LIST_AREA,
		[self.navigation.MOVE_DIRECTION.LEFT] = self.navigation.AREAS.SHOP_TAG_LIST_AREA,
		[self.navigation.MOVE_DIRECTION.RIGHT] = self.navigation.AREAS.SHOP_PROP_LIST_AREA
	}
	self.navigation.SHOP_PROP_DETAIL_AREA = {}
	self.navigation.AREA_TABLES = {
		self.navigation.SHOP_TAG_LIST_AREA,
		self.navigation.SHOP_PROP_LIST_AREA,
		self.navigation.SHOP_PROP_DETAIL_AREA
	}
end

function ShopBuyGamePadComponent:startTick()
	if self.rightStickMoveY ~= 0 then
		-- block empty
	end

	if self.ltLongPress then
		self:minusCount()
	end

	if self.rtLongPress then
		self:addCount()
	end
end

function ShopBuyGamePadComponent:initRightStickMoveData()
	return {
		id = "rightStickMove",
		actionPath = "Hud/RightStickMove",
		isVirtual = true,
		parent = self.root.gameObject,
		event = function(inputInfo)
			TimerManager.removeTimer(self.navigation.longPressTimer)

			if self.navigation.longPressMayPerformed == true then
				return
			end

			if inputInfo.phase == "Performed" then
				self.rightStickMoveY = inputInfo.valueVec2.y
			else
				self.rightStickMoveY = 0
			end
		end
	}
end

function ShopBuyGamePadComponent:initGamepadLTData()
	return {
		id = "gamepadLT",
		isVirtual = true,
		parent = self.root.gameObject,
		actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadLT,
		event = function(inputInfo)
			TimerManager.removeTimer(self.navigation.longPressTimer)

			if self.navigation.longPressMayPerformed == true then
				return
			end

			if inputInfo.phase == "Performed" then
				if inputInfo.isPressed == true then
					if self.ltLongPress ~= true and self.delayPressTimer == nil then
						self:minusCount()

						self.delayPressTimer = self:startTimer(function()
							self.ltLongPress = inputInfo.isPressed
							self.delayPressTimer = nil
						end, 0.55, false)
					end
				else
					self.ltLongPress = false

					self:removeLongPressTimer()
				end
			else
				self.ltLongPress = false

				self:removeLongPressTimer()
			end
		end
	}
end

function ShopBuyGamePadComponent:initGamepadRTData()
	return {
		id = "gamepadRT",
		isVirtual = true,
		parent = self.root.gameObject,
		actionPath = HotkeyConst.INPUT_MAP_ACTION_KEY.GamepadRT,
		event = function(inputInfo)
			TimerManager.removeTimer(self.navigation.longPressTimer)

			if self.navigation.longPressMayPerformed == true then
				return
			end

			if inputInfo.phase == "Performed" then
				if inputInfo.isPressed == true then
					if self.rtLongPress ~= true and self.delayPressTimer == nil then
						self:addCount()

						self.delayPressTimer = self:startTimer(function()
							self.rtLongPress = inputInfo.isPressed
							self.delayPressTimer = nil
						end, 0.55, false)
					end
				else
					self:removeLongPressTimer()

					self.rtLongPress = false
				end
			else
				self.rtLongPress = false

				self:removeLongPressTimer()
			end
		end
	}
end

function ShopBuyGamePadComponent:removeLongPressTimer()
	if self.delayPressTimer ~= nil then
		self:killTimer(self.delayPressTimer)

		self.delayPressTimer = nil
	end
end

function ShopBuyGamePadComponent:onInputDeviceChanged(deviceType)
	if pg.game.input:isUsingGamepad() then
		self.navigation:specificSet(self.navigation.AREAS.SHOP_TAG_LIST_AREA, 1, 1)
		self.navigation:reFocus()
	end
end

function ShopBuyGamePadComponent:initShopTagAreaTable(dataList, ulist, locateTag)
	local focusX = 1
	local focusY = 1
	local t = {}

	for i = 1, #dataList do
		local data = dataList[i]
		local x = i
		local y = 1

		if t[x] == nil then
			t[x] = {}
		end

		t[x][y] = {}
		t[x][y].Focus = function(x1, y1)
			self.navigation:baseFocus(t, x1, y1, self.view.consoleKeyUList)

			local ret, btn = ulist:TryGetChildAt(i - 1)

			btn.luaClick()
			self:unfocusShopItem()
			self:cancelFocusTag()
			self:focusShopTag(btn)
		end
		t[x][y].Fun3Name = pg.getGameString("SHOP_CANCEL")
		t[x][y].Fun3 = function(x1, y1)
			self.ctrl:dismiss()
		end
		t[x][y].Fun4Name = pg.getGameString("SHOP_VIEW")
		t[x][y].Fun4 = function(x1, y1)
			self.navigation:specificSet(self.navigation.AREAS.SHOP_PROP_LIST_AREA, 1, 1)
			self.navigation:reFocus()
		end

		if locateTag ~= nil and locateTag == data.id then
			focusX = x
			focusY = y
		end
	end

	self.navigation:initAreaTableSlots(self.navigation.SHOP_TAG_LIST_AREA, t)

	return focusX, focusY
end

function ShopBuyGamePadComponent:initShopPropsAreaTable(dataList, ulist, locateTag)
	local left = ulist:GetPaddings()[2]
	local right = ulist:GetPaddings()[3]
	local colSpacing = ulist:GetSpacings()[1]
	local templateItemWidth = ulist:GetTemplateItem(0):GetComponent("RectTransform").rect.width
	local listWidth = ulist:GetComponent("RectTransform").rect.width
	local colCount = math.floor((listWidth - left - right + colSpacing) / (colSpacing + templateItemWidth))
	local focusX, focusY
	local t = {}

	for i = 1, #dataList do
		local data = dataList[i]
		local x = math.ceil(i / colCount)
		local y = (i - 1) % colCount + 1

		if t[x] == nil then
			t[x] = {}
		end

		t[x][y] = {}
		t[x][y].Focus = function(x1, y1)
			self:unfocusShopItem()
			self:cancelFocusTag()

			local ret, btn = ulist:TryGetChildAt(i - 1)

			if btn then
				btn.luaClick()
				self:focusShopItem(btn)
			end

			self.navigation:baseFocus(t, x1, y1, self.view.consoleKeyUList)
		end
		t[x][y].Fun3Name = pg.getGameString("SHOP_CANCEL")
		t[x][y].Fun3 = function(x1, y1)
			self.navigation:specificSet(self.navigation.AREAS.SHOP_TAG_LIST_AREA, 1, 1)
			self.navigation:reFocus()
		end
		t[x][y].Fun4IsImportant = true
		t[x][y].Fun4Name = pg.getGameString("SHOP_BUY")
		t[x][y].Fun4 = function(x1, y1)
			self.ctrl.shopBuyComponent:onConfirmToBuy()
		end

		if locateTag ~= nil and locateTag == data.id then
			focusX = x
			focusY = y
		end
	end

	self.navigation:initAreaTableSlots(self.navigation.SHOP_PROP_LIST_AREA, t)

	return focusX, focusY
end

function ShopBuyGamePadComponent:focusShopItem(btn)
	local itemComs = self.view:getBuyPropItemComs(btn)

	itemComs:TryChangePage("GamePadFocus", 1)

	self.focusShopItemBtn = btn
end

function ShopBuyGamePadComponent:unfocusShopItem()
	if self.focusShopItemBtn ~= nil then
		self.focusShopItemBtn:TryChangePage("GamePadFocus", 0)

		self.focusShopItemBtn = nil
	end
end

function ShopBuyGamePadComponent:focusShopTag(tagBtn)
	tagBtn:TryChangePage("GamePadFocus", 1)

	self.focusTagBtn = tagBtn
end

function ShopBuyGamePadComponent:cancelFocusTag()
	if self.focusTagBtn ~= nil then
		self.focusTagBtn:TryChangePage("GamePadFocus", 0)

		self.focusTagBtn = nil
	end
end

function ShopBuyGamePadComponent:onDestroy()
	self.root = nil
	self.navigation = nil
	self.rightStickMoveY = 0

	UIComponent.onDestroy(self)
end

return ShopBuyGamePadComponent
