-- chunkname: @C:\\dev\\jkroot\\ws\\workspace\\XWinPublish\\proj\\p4dir\\client\\LuaScripts\\Guis\\Panels\\ShopARK\\ShopARKCtrl.lua

local MessageName = require("Const.MessageName")
local Class = require("Core.Framework.Class")
local ShopBaseCtrl = require("Guis.Panels.Shop.ShopBaseCtrl")
local ShopEventData = require("Data.shop_event_data")
local ClientTextUtils = require("Utils.ClientTextUtils")
local ShopARKCtrl = Class.LightClass("ShopARKCtrl", ShopBaseCtrl)

ShopARKCtrl.messages = {
	[MessageName.SHOP_ON_BUY_ITEMS] = {
		"onBuyItemsCallback",
		true
	},
	[MessageName.SHOP_ON_SELL_ITEMS_BY_GENID] = {
		"onSellItemsCallback",
		true
	},
	[MessageName.MONEY_UNBOUND_CHANGE] = {
		"onMoneyChanged",
		true
	},
	[MessageName.ITEM_COUNT_MAP_CHANGE] = {
		"onMoneyChanged",
		true
	},
	[MessageName.LOGIC_TIME_UPDATE] = {
		"onLogicTimeUpdate",
		true
	},
	[MessageName.INPUT_DEVICE_CHANGED] = {
		"onInputDeviceChanged",
		true
	}
}

local shopTabName = {
	[38] = 6,
	[4] = 0,
	[27] = 1,
	[28] = 2,
	[31] = 3,
	[32] = 4,
	[33] = 5
}

function ShopARKCtrl:onCreate(info)
	ShopARKCtrl.super.onCreate(self, info)
	self:Init()
end

function ShopARKCtrl:_rebuildShopContext(info)
	ShopARKCtrl.super._rebuildShopContext(self, info)
	self.view.uIPrefabShopPanelUComponent:TryChangePage("Type", shopTabName[self.shopId] or 0)
end

function ShopARKCtrl:getNavigationListenerName()
	return "ShopARK"
end

function ShopARKCtrl:onShow()
	ShopARKCtrl.super.onShow(self)
	self:refreshAFKShopInfo()
end

function ShopARKCtrl:update()
	if self.uiScene then
		self.uiScene:updateLookAt()
	end
end

function ShopARKCtrl:setLookAtAble(bool)
	if self.uiScene then
		self.uiScene:setLookAtAble(bool)
	end
end

function ShopARKCtrl:onVisibleChange(visible)
	if visible then
		self:refreshVisibleShopList()
	end
end

function ShopARKCtrl:onDestroy()
	if self.isAFKShop then
		local shopEventCfg = ShopEventData[self.shopId]
		local leaveCfg = shopEventCfg[4]

		if leaveCfg and leaveCfg.sound then
			self:playAudio(leaveCfg)
		end

		self:clearAFKShopTimers()
	end

	if self.tickTimer then
		self:killTimer(self.tickTimer)

		self.tickTimer = nil
	end

	self:removeNavigationListener()
	ShopARKCtrl.super.onDestroy(self)
end

function ShopARKCtrl:addListener()
	ShopARKCtrl.super.addListener(self)

	self.tickTimer = self:startTimer(function()
		self:update()
	end, 0.01, true)
end

function ShopARKCtrl:onShopBuyItemsCallback(data, shopEventCfg)
	local exItemCfg = shopEventCfg[5]

	if exItemCfg and exItemCfg.itemId == data.shopItemId then
		if exItemCfg.sound then
			self:playAudio(exItemCfg)
		end

		self:playAnim(exItemCfg, 1)
	else
		local buyCfg = shopEventCfg[3]

		if buyCfg then
			if buyCfg.sound then
				self:playAudio(buyCfg)
			end

			self:playAnim(buyCfg, 1)
		end
	end
end

function ShopARKCtrl:refreshAFKShopInfo()
	ClientTextUtils.setText(self.view.txtShopName, pg.getLocalizationText(self.shopClassCfg.name))
	ClientTextUtils.setText(self.view.txtShopName2, pg.getLocalizationText(self.shopClassCfg.subtitle))

	local shopEventCfg = ShopEventData[self.shopId]
	local enterCfg = shopEventCfg[1]

	if enterCfg then
		if enterCfg.sound then
			self:playAudio(enterCfg)
		end

		self:playAnim(enterCfg, 1)
	end

	local waitCfg = shopEventCfg[2]

	if not waitCfg then
		return
	end

	local waitTime = waitCfg.value or 30

	self.sleepTime = 0
	self.sleepTimer = self:startTimer(function()
		if not self.sleeping then
			self.sleepTime = self.sleepTime + 0.1

			if self.sleepTime >= waitTime then
				self.sleeping = true
				self.sleepTime = 0

				if self.uiScene then
					if waitCfg.sound then
						self:playAudio(waitCfg)
					end

					if waitCfg.action_start then
						self:setLookAtAble(false)

						local startState = self.uiScene:playAnimation(waitCfg.action_start)

						if waitCfg.action_loop then
							self.waitTimer = self:startTimer(function()
								self.uiScene:playAnimation(waitCfg.action_loop, false, nil, true)
							end, startState.Length - 0.1)
						end
					end
				end
			end
		end
	end, 0.1, true)
end

function ShopARKCtrl:trySleepEnd()
	if self.sleeping then
		self.sleeping = false

		if not self.uiScene then
			return
		end

		local shopEventCfg = ShopEventData[self.shopId]
		local endCfg = shopEventCfg[2]

		if endCfg and endCfg.action_end then
			local startState = self.uiScene:playAnimation(endCfg.action_end)

			self.waitTimer = self:startTimer(function()
				self:setLookAtAble(true)
			end, startState.Length - 0.1)
		end
	end

	self.sleepTime = 0
end

function ShopARKCtrl:playAudio(waitCfg)
	if waitCfg.object and waitCfg.object == 1 then
		pg.game.audio:playEvent(waitCfg.sound)
	else
		pg.game.audio:triggerEvent(waitCfg.sound)
	end
end

local loopAnim = {
	"action_start",
	"action_loop",
	"action_end"
}

function ShopARKCtrl:playAnim(eventCfg, index)
	if eventCfg and eventCfg[loopAnim[index]] then
		local state = self.uiScene:playAnimation(eventCfg[loopAnim[index]])

		if not state then
			self:setLookAtAble(true)

			return
		end

		if self.waitTimer then
			self:killTimer(self.waitTimer)

			self.waitTimer = nil
		end

		self:setLookAtAble(false)

		self.waitTimer = self:startTimer(function()
			index = index + 1

			self:playAnim(eventCfg, index)
		end, state.Length)
	else
		self:setLookAtAble(true)
	end
end

return ShopARKCtrl
